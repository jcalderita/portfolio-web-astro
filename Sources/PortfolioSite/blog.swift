import Foundation
import HTML
import Saga

// MARK: - Blog card

func renderBlogCard(post: Item<BlogMetadata>, locale: Locale) -> Node {
    let slug = post.metadata.slug
    let cover = post.metadata.cover

    return a(
        class: "blogCard",
        href: locale.blogPath(for: slug),
        customAttributes: ["aria-label": post.title]
    ) {
        div(class: "blogCardTitle") {
            span { post.title }
        }
        div(class: "blogCardImage") {
            img(customAttributes: [
                "src": "/static/blog/\(cover).avif",
                "alt": post.metadata.coverDescription,
                "loading": "lazy",
                "style": "--vt-name: post-\(slug)",
            ])
        }
        div(class: "blogCardBottom") {
            div(class: "blogCardTags") {
                Node.fragment(post.metadata.tags.map { renderBadge($0, dataInfo: true) })
            }
            p(class: "blogCardDate") { formatDate(post.date, locale: locale) }
        }
    }
}

// MARK: - Tag button

func renderTagButton(tag: String, locale: Locale) -> Node {
    let label = tag == "all" ? locale.allTags : tag

    return button(
        class: "tagButton",
        customAttributes: ["data-tag": tag]
    ) { label }
}

// MARK: - RSS link

func renderRSSLink(locale: Locale) -> Node {
    a(
        class: "rssLink",
        href: locale.feedPath,
        customAttributes: [
            "target": "_blank",
            "rel": "noopener noreferrer",
            "title": locale.subscribeRSS,
            "aria-label": locale.subscribeRSS,
        ]
    ) {
        Node.raw(rssSVG)
        span(class: "rssLabel") { "RSS" }
    }
}

// MARK: - Date formatting

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yy"
    return formatter
}()

func formatDate(_ date: Date, locale: Locale) -> String {
    dateFormatter.locale = Foundation.Locale(identifier: locale.dateLocaleIdentifier)
    return dateFormatter.string(from: date)
}
