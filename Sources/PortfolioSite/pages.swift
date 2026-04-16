import Foundation
import HTML
import Saga
import SagaSwimRenderer

// MARK: - Home page

func renderHome(context: PageRenderingContext) -> Node {
    let locale = Locale(from: context.locale)
    let portfolio = try! loadPortfolio(for: locale)

    let jobTitle = locale.jobsTitle
    let educationTitle = locale.educationTitle
    let projectTitle = locale.projectsTitle

    let allTechnologies = Array(Set(
        (portfolio.jobs + portfolio.education).flatMap(\.technologies)
    )).sorted()

    var page = PageContext(
        title: portfolio.metadata.webTitle,
        locale: locale,
        slug: locale.homePath,
        description: portfolio.metadata.description
    )
    page.jsonLD = buildPersonJsonLD(
        name: SiteConfig.author,
        jobTitle: portfolio.role,
        description: portfolio.introduction,
        url: SiteConfig.baseURL.absoluteString,
        sameAs: [SiteConfig.githubURL, SiteConfig.linkedinURL, SiteConfig.xURL, SiteConfig.discordURL],
        email: SiteConfig.email,
        knowsAbout: allTechnologies
    )

    return baseLayout(page) {
        renderRole(role: portfolio.role, introduction: portfolio.introduction)
        renderExperiences(title: jobTitle, experiences: portfolio.jobs, locale: locale)
        renderExperiences(title: educationTitle, experiences: portfolio.education, locale: locale)
        renderProjects(title: projectTitle, projects: portfolio.projects, locale: locale)
    }
}

// MARK: - Blog index

func renderBlogIndex(context: PageRenderingContext) -> Node {
    let locale = Locale(from: context.locale)

    let blogItems: [Item<BlogMetadata>] = context.allItems.compactMap { $0 as? Item<BlogMetadata> }
    let posts = blogItems
        .filter { $0.locale == locale.rawValue }
        .sorted { $0.date > $1.date }

    let allTags = Array(Set(posts.flatMap(\.metadata.tags))).sorted()

    let page = PageContext(
        title: "Blog",
        locale: locale,
        slug: "\(locale.prefix)/blog/",
        description: locale.blogDescription
    )

    return blogIndexLayout(page) {
        h1(class: "sr-only") { "Blog" }
        div(class: "tagButtons") {
            renderTagButton(tag: "all", locale: locale)
            Node.fragment(allTags.map { renderTagButton(tag: $0, locale: locale) })
            renderRSSLink(locale: locale)
        }
        div(class: "postList", id: "posts-list") {
            Node.fragment(posts.map { renderBlogCard(post: $0, locale: locale) })
        }
    }
}

// MARK: - Blog post

func renderBlogPost(context: ItemRenderingContext<BlogMetadata>) -> Node {
    let locale = Locale(from: context.locale)
    let post = context.item
    let (headings, bodyWithIds) = extractHeadings(from: post.body)

    let siteURL = SiteConfig.baseURL.absoluteString

    var page = PageContext(
        title: post.title,
        locale: locale,
        slug: post.url,
        description: post.metadata.description,
        ogImage: "/static/blog/\(post.metadata.cover).webp",
        ogType: "article",
        articleTags: post.metadata.tags,
        articleDate: post.date
    )
    page.jsonLD = buildBlogPostingJsonLD(
        headline: post.title,
        description: post.metadata.description,
        datePublished: post.date,
        url: "\(siteURL)\(post.url)",
        imageURL: "\(siteURL)/static/blog/\(post.metadata.cover).webp",
        authorName: SiteConfig.author,
        authorURL: siteURL,
        keywords: post.metadata.tags,
        inLanguage: locale.rawValue
    )

    return blogLayout(page) {
        // Post title
        h1(class: "sr-only") { post.title }

        // Cover image
        img(class: "postImage", customAttributes: [
            "src": "/static/blog/\(post.metadata.cover).webp",
            "alt": post.metadata.coverDescription,
            "style": "--vt-name: post-\(post.metadata.slug)",
        ])

        // Table of contents
        h2(class: "postTitle") { locale.tableOfContents }
        ol(class: "postIndex") {
            Node.fragment(
                headings.filter { $0.level == 2 }.enumerated().map { idx, entry in
                    li {
                        button(
                            class: "postIndexButton",
                            customAttributes: [
                                "type": "button",
                                "onclick":
                                    "document.getElementById('\(entry.id)')?.scrollIntoView({behavior:'smooth',block:'start'})",
                            ]
                        ) {
                            span(class: "postIndexNumber") { "\(idx + 1)" }
                            entry.title
                        }
                    }
                }
            )
        }

        // Content
        article(class: "prose proseArticle") {
            Node.raw(bodyWithIds)
        }

        // Bottom bar
        div(class: "blogBottom") {
            div(class: "blogBackButton") {
                renderBackButton(locale: locale)
            }
            renderUpButton(locale: locale)
        }
    }
}

// MARK: - Legal page

func renderLegal(context: ItemRenderingContext<LegalMetadata>) -> Node {
    let locale = Locale(from: context.locale)
    let page = PageContext(
        title: context.item.metadata.title,
        locale: locale,
        slug: context.item.url,
        noIndex: true
    )

    return legalLayout(page) {
        Node.raw(context.item.body)
    }
}

// MARK: - 404

func render404(context: PageRenderingContext) -> Node {
    let locale = Locale.default
    let page = PageContext(
        title: "404",
        locale: locale,
        slug: "/404",
        noIndex: true
    )

    return baseLayout(page) {
        div(class: "notFound") {
            h1 { "404" }
            p { locale.notFoundMessage }
            a(class: "btn", href: locale.homePath) { locale.goHome }
        }
    }
}

// MARK: - Sitemap

private let dateOnlyFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.timeZone = TimeZone(identifier: "UTC")
    return f
}()

func renderSitemap(context: PageRenderingContext) -> String {
    let base = SiteConfig.baseURL.absoluteString

    // Build date lookup from blog items
    let blogItems: [Item<BlogMetadata>] = context.allItems.compactMap { $0 as? Item<BlogMetadata> }
    var dateByURL: [String: Date] = [:]
    for item in blogItems {
        dateByURL[item.relativeDestination.string] = item.date
    }

    // Collect all generated pages except this sitemap and 404
    let paths = context.generatedPages
        .filter { $0 != context.outputPath && $0.string != "404.html" }
        .sorted { $0.string < $1.string }

    // Build item lookup for hreflang alternates
    let pathSet = Set(paths.map(\.string))
    let itemByDest = context.allItems
        .filter { $0.locale != nil && pathSet.contains($0.relativeDestination.string) }
        .reduce(into: [String: AnyItem]()) { $0[$1.relativeDestination.string] = $1 }

    var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    xml += "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\"\n"
    xml += " xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">\n"

    for path in paths {
        let url = path.string.hasPrefix("/") ? path.string : "/\(path.string)"
        let cleanURL = url.hasSuffix("index.html")
            ? String(url.dropLast("index.html".count))
            : url

        xml += "<url>\n"
        xml += "<loc>\(base)\(cleanURL)</loc>\n"

        // lastmod from blog post date
        if let date = dateByURL[path.string] {
            xml += "<lastmod>\(dateOnlyFormatter.string(from: date))</lastmod>\n"
        }

        // hreflang alternates
        if let item = itemByDest[path.string], let locale = item.locale, !item.translations.isEmpty {
            var alternates = [(locale, path)]
            for (tLocale, tItem) in item.translations {
                if pathSet.contains(tItem.relativeDestination.string) {
                    alternates.append((tLocale, tItem.relativeDestination))
                }
            }
            alternates.sort { $0.0 < $1.0 }
            for (altLocale, altPath) in alternates {
                let altURL = altPath.string.hasPrefix("/") ? altPath.string : "/\(altPath.string)"
                let cleanAltURL = altURL.hasSuffix("index.html")
                    ? String(altURL.dropLast("index.html".count))
                    : altURL
                xml += "<xhtml:link rel=\"alternate\" hreflang=\"\(altLocale)\" href=\"\(base)\(cleanAltURL)\"/>\n"
            }
        }

        xml += "</url>\n"
    }

    xml += "</urlset>"
    return xml
}
