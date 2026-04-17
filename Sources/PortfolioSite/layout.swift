import Foundation
import HTML
import Saga
import SagaSwimRenderer

// MARK: - Page context

struct PageContext {
    let title: String
    let locale: Locale
    let slug: String
    var description: String = ""
    var ogImage: String = "/static/web.webp"
    var ogType: String = "website"
    var articleTags: [String] = []
    var articleDate: Date?
    var noIndex: Bool = false
    var jsonLD: String?
}

// MARK: - Base layout (portfolio home)

func baseLayout(_ context: PageContext, @NodeBuilder children: () -> NodeConvertible) -> Node {
    html(lang: context.locale.rawValue) {
        renderHead(context)
        body(class: "bodyLayout") {
            renderHeader(locale: context.locale, isNotMain: false)
            main(class: "mainLayout") {
                div(class: "contentLayout") {
                    children()
                }
            }
            renderFooter(locale: context.locale)
            script {
                Node.raw(themeToggleJS)
                Node.raw("\n")
                Node.raw(hamburgerMenuJS)
            }
        }
    }
}

// MARK: - Blog layout

func blogLayout(_ context: PageContext, @NodeBuilder children: () -> NodeConvertible) -> Node {
    html(lang: context.locale.rawValue) {
        renderHead(context)
        body(class: "bodyLayout") {
            renderHeader(locale: context.locale, isNotMain: true)
            main(class: "mainLayout blogMain") {
                div(class: "contentLayout") {
                    children()
                }
            }
            renderFooter(locale: context.locale)
            script {
                Node.raw(themeToggleJS)
                Node.raw("\n")
                Node.raw(hamburgerMenuJS)
                Node.raw("\n")
                Node.raw(copyButtonJS)
            }
        }
    }
}

// MARK: - Blog index layout

func blogIndexLayout(_ context: PageContext, @NodeBuilder children: () -> NodeConvertible) -> Node {
    html(lang: context.locale.rawValue) {
        renderHead(context)
        body(class: "bodyLayout") {
            renderHeader(locale: context.locale, isNotMain: true)
            main(class: "mainLayout blogMain") {
                div(class: "contentLayout") {
                    children()
                }
            }
            renderFooter(locale: context.locale)
            script {
                Node.raw(themeToggleJS)
                Node.raw("\n")
                Node.raw(hamburgerMenuJS)
                Node.raw("\n")
                Node.raw(tagFilterJS)
            }
        }
    }
}

// MARK: - Legal layout

func legalLayout(_ context: PageContext, @NodeBuilder children: () -> NodeConvertible) -> Node {
    html(lang: context.locale.rawValue) {
        renderHead(context)
        body(class: "bodyLayout") {
            renderHeader(locale: context.locale, isNotMain: true)
            main {
                section(class: "legalSection") {
                    h1(class: "legalTitle") { context.title }
                    children()
                }
            }
            renderFooter(locale: context.locale)
            script {
                Node.raw(themeToggleJS)
                Node.raw("\n")
                Node.raw(hamburgerMenuJS)
            }
        }
    }
}

// MARK: - Head

nonisolated(unsafe) let iso8601Formatter = ISO8601DateFormatter()

private func renderHead(_ context: PageContext) -> Node {
    let siteURL = SiteConfig.baseURL.absoluteString

    var nodes: [Node] = [
        script { Node.raw(restoreThemeJS) },
        meta(charset: "utf-8"),
        meta(content: "width=device-width, initial-scale=1", name: "viewport"),
        HTML.title { context.title },
        link(href: Saga.hashed("/static/style.css"), rel: "stylesheet"),
        link(href: "/static/favicon.svg", rel: "icon", type: "image/svg+xml"),
        link(href: "/static/favicon.ico", rel: "icon", customAttributes: ["sizes": "any"]),
        link(href: "/static/apple-touch-icon.png", rel: "apple-touch-icon"),
        link(href: "/static/site.webmanifest", rel: "manifest"),
    ]

    // SEO
    if !context.description.isEmpty {
        nodes.append(meta(content: context.description, name: "description"))
    }
    nodes.append(meta(content: SiteConfig.author, name: "author"))
    nodes.append(meta(content: context.locale.metaKeywords, name: "keywords"))
    nodes.append(meta(content: context.noIndex ? "noindex, nofollow" : "index, follow", name: "robots"))

    // Open Graph
    nodes.append(meta(content: context.ogType, customAttributes: ["property": "og:type"]))
    nodes.append(meta(content: context.title, customAttributes: ["property": "og:title"]))
    if !context.description.isEmpty {
        nodes.append(meta(content: context.description, customAttributes: ["property": "og:description"]))
    }
    nodes.append(meta(content: "\(siteURL)\(context.slug)", customAttributes: ["property": "og:url"]))
    nodes.append(meta(content: "\(siteURL)\(context.ogImage)", customAttributes: ["property": "og:image"]))
    nodes.append(meta(
        content: context.locale == .es ? "es_ES" : "en_US",
        customAttributes: ["property": "og:locale"]
    ))

    // Twitter Card
    nodes.append(meta(content: "summary_large_image", name: "twitter:card"))
    nodes.append(meta(content: context.title, name: "twitter:title"))
    if !context.description.isEmpty {
        nodes.append(meta(content: context.description, name: "twitter:description"))
    }
    nodes.append(meta(content: "\(siteURL)\(context.ogImage)", name: "twitter:image"))
    nodes.append(meta(content: SiteConfig.twitterHandle, name: "twitter:site"))
    nodes.append(meta(content: SiteConfig.twitterHandle, name: "twitter:creator"))

    // Article meta
    if let date = context.articleDate {
        nodes.append(meta(
            content: iso8601Formatter.string(from: date),
            customAttributes: ["property": "article:published_time"]
        ))
    }
    for tag in context.articleTags {
        nodes.append(meta(content: tag, customAttributes: ["property": "article:tag"]))
    }

    // Canonical
    nodes.append(link(href: "\(siteURL)\(context.slug)", rel: "canonical"))

    // Hreflang (only for indexable pages with locale variants)
    if !context.noIndex {
        let enSlug = context.locale == .en ? context.slug : context.locale.otherPath(for: context.slug)
        let esSlug = context.locale == .es ? context.slug : context.locale.otherPath(for: context.slug)
        nodes.append(link(href: "\(siteURL)\(enSlug)", hreflang: "en", rel: "alternate"))
        nodes.append(link(href: "\(siteURL)\(esSlug)", hreflang: "es", rel: "alternate"))
        nodes.append(link(href: "\(siteURL)\(enSlug)", hreflang: "x-default", rel: "alternate"))
    }

    // JSON-LD
    if let jsonLD = context.jsonLD {
        nodes.append(script(type: "application/ld+json") { Node.raw(jsonLD) })
    }

    // Speculation Rules (prefetch on hover)
    nodes.append(script(type: "speculationrules") {
        Node.raw("""
        {"prerender":[{"source":"document","where":{"href_matches":"/*"},"eagerness":"moderate"}]}
        """)
    })

    return head { Node.fragment(nodes) }
}
