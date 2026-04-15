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

    let page = PageContext(
        title: portfolio.metadata.webTitle,
        locale: locale,
        slug: locale.homePath,
        description: portfolio.metadata.description
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

    let page = PageContext(
        title: post.title,
        locale: locale,
        slug: post.url,
        description: post.metadata.description,
        ogImage: "/static/blog/\(post.metadata.cover).webp",
        ogType: "article",
        articleTags: post.metadata.tags,
        articleDate: post.date
    )

    return blogLayout(page) {
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
