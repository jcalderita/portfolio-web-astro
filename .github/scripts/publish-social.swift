import Foundation
import CryptoKit

// MARK: - Environment

enum Env {
    static subscript(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }

    static func require(_ key: String) -> String {
        guard let value = self[key], !value.isEmpty else {
            fatalError("Missing environment variable: \(key)")
        }
        return value
    }
}

// MARK: - Shell

@discardableResult
func shell(_ args: String...) -> String {
    let pipe = Pipe()
    let process = Process()
    process.executableURL = URL(filePath: "/usr/bin/env")
    process.arguments = args
    process.standardOutput = pipe
    process.standardError = nil
    try? process.run()
    process.waitUntilExit()
    return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

// MARK: - Frontmatter

struct Frontmatter {
    let slug: String
    let title: String
    let description: String
    let tags: [String]
    let cover: String
    let excerpt: String

    init?(path: String) {
        let url = URL(filePath: path)
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }

        var fields: [String: String] = [:]
        var inside = false
        var frontmatterEnd = content.startIndex

        for line in content.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "---" {
                if inside {
                    frontmatterEnd = line.endIndex
                    break
                }
                inside = true
                continue
            }
            if inside, let colon = line.firstIndex(of: ":") {
                let key = line[line.startIndex..<colon].trimmingCharacters(in: .whitespaces)
                let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
                fields[key] = value
            }
        }

        guard let slug = fields["slug"], !slug.isEmpty else { return nil }
        self.slug = slug
        self.title = fields["title"] ?? ""
        self.description = fields["description"] ?? ""
        self.cover = fields["cover"] ?? ""
        self.tags = (fields["tags"] ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        self.excerpt = Self.extractExcerpt(from: String(content[frontmatterEnd...]), wordCount: 80)
    }

    private static func extractExcerpt(from body: String, wordCount: Int) -> String {
        var text = body
        text = text.replacing(#/<span[^>]*>|<\/span>/#, with: "")
        text = text.replacing(#/\[([^\]]+)\]\([^)]+\)/#, with: { "\($0.output.1)" })
        text = text.replacing(#/(?m)^#{1,6}\s+.*$/#, with: "")
        text = text.replacing(#/(?m)^---$/#, with: "")
        text = text.replacing(#/(?ms)```.*?```/#, with: "")
        text = text.replacing(#/``[^`]+``/#, with: "")
        text = text.replacing(#/\*\*([^*]+)\*\*/#, with: { "\($0.output.1)" })
        text = text.replacing(#/`([^`]+)`/#, with: { "\($0.output.1)" })
        text = text.replacing(#/(?m)\|[^\n]+\|/#, with: "")
        text = text.replacing(#/(?m)^>\s*/#, with: "")
        text = text.replacing(#/(?m)^\d+\.\s+/#, with: "")
        text = text.replacing(#/\n{2,}/#, with: "\n")

        let words = text.split(whereSeparator: \.isWhitespace)
        guard words.count > wordCount else { return words.joined(separator: " ") }
        return words.prefix(wordCount).joined(separator: " ") + "..."
    }

    static func find(slug: String, locale: String) -> Frontmatter? {
        let url = URL(filePath: "content/\(locale)/blog/", directoryHint: .isDirectory)
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: url, includingPropertiesForKeys: nil
        ) else { return nil }
        return urls
            .filter { $0.pathExtension == "md" }
            .lazy
            .compactMap { Frontmatter(path: $0.path()) }
            .first { $0.slug == slug }
    }
}

// MARK: - Detection

func detectNewPosts(baseSHA: String) -> [String] {
    shell("git", "diff", "--name-only", baseSHA, "HEAD", "--", "content/es/blog/*.md")
        .split(separator: "\n")
        .compactMap { file -> String? in
            let path = String(file)
            let diff = shell("git", "diff", baseSHA, "HEAD", "--", path)
            guard diff.contains("+publish: true") else { return nil }
            guard let frontmatter = Frontmatter(path: path) else { return nil }
            print("Detected new post: \(frontmatter.slug)")
            return frontmatter.slug
        }
}

// MARK: - Tweet

struct Tweet {
    let slug: String
    let locale: String
    let text: String

    init?(slug: String, locale: String) {
        guard let fm = Frontmatter.find(slug: slug, locale: locale) else { return nil }
        self.slug = slug
        self.locale = locale

        let hashtags = fm.tags.map { "#\($0)" }.joined(separator: " ")
        let url = locale == "es"
            ? "jcalderita.com/es/blog/\(slug)/"
            : "jcalderita.com/blog/\(slug)/"
        self.text = "\(fm.description)\n\n\(url)\n\n\(hashtags)"
    }
}

// MARK: - LinkedIn Post

struct LinkedInPost {
    let slug: String
    let locale: String
    let text: String
    let url: String
    let title: String
    let thumbnail: String

    init?(slug: String, locale: String) {
        guard let fm = Frontmatter.find(slug: slug, locale: locale) else { return nil }
        self.slug = slug
        self.locale = locale

        let hashtags = fm.tags.map { "#\($0)" }.joined(separator: " ")
        self.text = "\(fm.excerpt)\n\n\(hashtags)"
        self.url = locale == "es"
            ? "https://jcalderita.com/es/blog/\(slug)/"
            : "https://jcalderita.com/blog/\(slug)/"
        self.title = "\(fm.title): \(fm.description)"
        self.thumbnail = "https://jcalderita.com/static/blog/\(fm.cover).webp"
    }
}

// MARK: - OAuth 1.0a

enum OAuth {
    private static func percentEncode(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }

    private static func sign(key: String, data: String) -> String {
        let symmetricKey = SymmetricKey(data: Data(key.utf8))
        let signature = HMAC<Insecure.SHA1>.authenticationCode(for: Data(data.utf8), using: symmetricKey)
        return Data(signature).base64EncodedString()
    }

    static func authorizationHeader(
        url: String,
        method: String = "POST",
        apiKey: String,
        apiSecret: String,
        accessToken: String,
        accessSecret: String
    ) -> String {
        let params: [(String, String)] = [
            ("oauth_consumer_key", apiKey),
            ("oauth_nonce", UUID().uuidString.replacingOccurrences(of: "-", with: "")),
            ("oauth_signature_method", "HMAC-SHA1"),
            ("oauth_timestamp", "\(Int(Date.now.timeIntervalSince1970))"),
            ("oauth_token", accessToken),
            ("oauth_version", "1.0"),
        ]

        let paramString = params
            .sorted { $0.0 < $1.0 }
            .map { "\(percentEncode($0.0))=\(percentEncode($0.1))" }
            .joined(separator: "&")

        let baseString = [method, percentEncode(url), percentEncode(paramString)].joined(separator: "&")
        let signingKey = [percentEncode(apiSecret), percentEncode(accessSecret)].joined(separator: "&")
        let signature = sign(key: signingKey, data: baseString)

        return "OAuth " + (params + [("oauth_signature", signature)])
            .sorted { $0.0 < $1.0 }
            .map { #"\#($0.0)="\#(percentEncode($0.1))""# }
            .joined(separator: ", ")
    }
}

// MARK: - X API

struct XResponse: Decodable {
    struct Data: Decodable { let id: String }
    let data: Data?
}

func postToX(_ tweet: Tweet) async -> Bool {
    let endpoint = "https://api.x.com/2/tweets"

    var request = URLRequest(url: URL(string: endpoint)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
        OAuth.authorizationHeader(
            url: endpoint,
            apiKey: Env.require("X_API_KEY"),
            apiSecret: Env.require("X_API_SECRET"),
            accessToken: Env.require("X_ACCESS_TOKEN"),
            accessSecret: Env.require("X_ACCESS_TOKEN_SECRET")
        ),
        forHTTPHeaderField: "Authorization"
    )
    request.httpBody = try? JSONEncoder().encode(["text": tweet.text])

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        guard (200...299).contains(status) else {
            print("  [\(tweet.locale.uppercased())] Error \(status): \(String(data: data, encoding: .utf8) ?? "")")
            return false
        }

        if let id = (try? JSONDecoder().decode(XResponse.self, from: data))?.data?.id {
            print("  [\(tweet.locale.uppercased())] Tweet posted: id=\(id)")
        }
        return true
    } catch {
        print("  [\(tweet.locale.uppercased())] Request failed: \(error.localizedDescription)")
        return false
    }
}

// MARK: - LinkedIn via Make.com

func postToLinkedIn(_ post: LinkedInPost, webhookURL: String) async -> Bool {
    guard let url = URL(string: webhookURL) else {
        print("  [\(post.locale.uppercased())] Invalid webhook URL")
        return false
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let payload: [String: String] = [
        "text": post.text,
        "url": post.url,
        "title": post.title,
        "thumbnail": post.thumbnail,
    ]
    request.httpBody = try? JSONEncoder().encode(payload)

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        guard (200...299).contains(status) else {
            print("  [\(post.locale.uppercased())] LinkedIn error \(status): \(String(data: data, encoding: .utf8) ?? "")")
            return false
        }

        print("  [\(post.locale.uppercased())] LinkedIn post sent via webhook")
        return true
    } catch {
        print("  [\(post.locale.uppercased())] LinkedIn request failed: \(error.localizedDescription)")
        return false
    }
}

// MARK: - Cover Polling

func waitForCovers(_ urls: [String], retries: Int = 10, interval: UInt64 = 5) async {
    for urlString in Set(urls) {
        guard let url = URL(string: urlString) else { continue }
        for attempt in 1...retries {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            if let (_, response) = try? await URLSession.shared.data(for: request),
               (response as? HTTPURLResponse)?.statusCode == 200 {
                print("Cover available: \(urlString) (attempt \(attempt))")
                break
            }
            if attempt < retries {
                print("Cover not ready: \(urlString) (attempt \(attempt), retrying in \(interval)s...)")
                try? await Task.sleep(for: .seconds(interval))
            } else {
                print("Cover not available after \(retries) attempts: \(urlString), proceeding anyway")
            }
        }
    }
}

// MARK: - Main

let baseSHA = Env["BASE_SHA"] ?? ""

guard !baseSHA.isEmpty, baseSHA != String(repeating: "0", count: 40) else {
    print("No base SHA available — skipping social media publish")
    exit(0)
}

let slugs = detectNewPosts(baseSHA: baseSHA)
guard !slugs.isEmpty else {
    print("No new posts detected")
    exit(0)
}

let tweets = slugs.flatMap { slug in
    ["es", "en"].compactMap { Tweet(slug: slug, locale: $0) }
}

let linkedInPosts = slugs.flatMap { slug in
    ["es", "en"].compactMap { LinkedInPost(slug: slug, locale: $0) }
}

let webhookURL = Env["MAKE_WEBHOOK_URL"]

guard !tweets.isEmpty else {
    print("No posts to compose")
    exit(0)
}

for tweet in tweets {
    print("[X] [\(tweet.locale.uppercased())] \(tweet.slug) (\(tweet.text.count) chars)")
}

if webhookURL != nil {
    for post in linkedInPosts {
        print("[LinkedIn] [\(post.locale.uppercased())] \(post.slug)")
    }
} else {
    print("MAKE_WEBHOOK_URL not set — skipping LinkedIn")
}

let coverURLs = linkedInPosts.map(\.thumbnail)
await waitForCovers(coverURLs)

await withDiscardingTaskGroup { group in
    for tweet in tweets {
        group.addTask {
            let success = await postToX(tweet)
            if !success {
                print("  Failed: [X] [\(tweet.locale.uppercased())] \(tweet.slug)")
            }
        }
    }

    if let webhookURL {
        for post in linkedInPosts {
            group.addTask {
                let success = await postToLinkedIn(post, webhookURL: webhookURL)
                if !success {
                    print("  Failed: [LinkedIn] [\(post.locale.uppercased())] \(post.slug)")
                }
            }
        }
    }
}

print("\nDone")
