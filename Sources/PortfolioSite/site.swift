import Foundation
import HTML
import Saga
import SagaPathKit
import SagaSwimRenderer

// MARK: - Site configuration

enum SiteConfig {
    static let input: Path = "content"
    static let baseURL = URL(string: "https://jcalderita.com")!
    static let author = "Jorge Calderita"
    static let twitterHandle = "@jcalderita"
    static let githubURL = "https://github.com/jcalderita"
    static let linkedinURL = "https://www.linkedin.com/in/jcalderita"
    static let xURL = "https://x.com/jcalderita"
    static let discordURL = "https://discord.com/users/jcalderita"
    static let email = "mailto:contacto@jcalderita.com"
}

// MARK: - Blog metadata

struct BlogMetadata: Metadata {
    let slug: String
    let description: String
    let tags: [String]
    let cover: String
    let coverDescription: String
    let publish: Bool
}

// MARK: - Legal metadata

struct LegalMetadata: Metadata {
    let title: String
}

// MARK: - Content sections

enum ContentSection: String, CaseIterable {
    case blog
    case legal

    var path: Path { Path(rawValue) }
}

// MARK: - Pages

enum Page: CaseIterable {
    case home
    case blogIndex
    case sitemap
    case notFound

    func create(on saga: Saga) -> Saga {
        switch self {
        case .home:
            saga.createPage("index.html", forEachLocale: swim(renderHome))
        case .blogIndex:
            saga.createPage("blog/index.html", forEachLocale: swim(renderBlogIndex))
        case .sitemap:
            saga.createPage(
                "sitemap.xml",
                using: Saga.sitemap(
                    baseURL: SiteConfig.baseURL,
                    filter: { $0.string != "404.html" }
                )
            )
        case .notFound:
            saga.createPage("404.html", using: swim(render404))
        }
    }
}
