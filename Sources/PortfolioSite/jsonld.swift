import Foundation

// MARK: - JSON escape

private func jsonEscape(_ string: String) -> String {
    string
        .replacing("\\", with: "\\\\")
        .replacing("\"", with: "\\\"")
        .replacing("\n", with: "\\n")
        .replacing("\r", with: "\\r")
        .replacing("\t", with: "\\t")
}

// MARK: - Person (home page)

func buildPersonJsonLD(
    name: String,
    jobTitle: String,
    description: String,
    url: String,
    sameAs: [String],
    email: String,
    knowsAbout: [String]
) -> String {
    let sameAsItems = sameAs.map { "\"\(jsonEscape($0))\"" }.joined(separator: ", ")
    let knowsItems = knowsAbout.map { "\"\(jsonEscape($0))\"" }.joined(separator: ", ")

    return """
    {
      "@context": "https://schema.org",
      "@type": "Person",
      "name": "\(jsonEscape(name))",
      "jobTitle": "\(jsonEscape(jobTitle))",
      "description": "\(jsonEscape(description))",
      "url": "\(jsonEscape(url))",
      "image": "\(jsonEscape(url))/static/web.webp",
      "sameAs": [\(sameAsItems)],
      "email": "\(jsonEscape(email))",
      "knowsAbout": [\(knowsItems)]
    }
    """
}

// MARK: - BlogPosting (blog posts)

func buildBlogPostingJsonLD(
    headline: String,
    description: String,
    datePublished: Date,
    url: String,
    imageURL: String,
    authorName: String,
    authorURL: String,
    keywords: [String],
    inLanguage: String
) -> String {
    let keywordItems = keywords.map { "\"\(jsonEscape($0))\"" }.joined(separator: ", ")
    let dateString = iso8601Formatter.string(from: datePublished)

    return """
    {
      "@context": "https://schema.org",
      "@type": "BlogPosting",
      "headline": "\(jsonEscape(headline))",
      "description": "\(jsonEscape(description))",
      "datePublished": "\(dateString)",
      "url": "\(jsonEscape(url))",
      "image": "\(jsonEscape(imageURL))",
      "author": {
        "@type": "Person",
        "name": "\(jsonEscape(authorName))",
        "url": "\(jsonEscape(authorURL))"
      },
      "publisher": {
        "@type": "Person",
        "name": "\(jsonEscape(authorName))",
        "url": "\(jsonEscape(authorURL))"
      },
      "keywords": [\(keywordItems)],
      "inLanguage": "\(jsonEscape(inLanguage))"
    }
    """
}
