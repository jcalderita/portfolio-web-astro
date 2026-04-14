import Moon
import Saga
import SagaParsleyMarkdownReader
import SagaPathKit
import SagaSwimRenderer

extension Saga {
    convenience init() throws {
        try self.init(input: SiteConfig.input)
    }

    func i18n() -> Self {
        i18n(locales: Locale.allCases.map(\.rawValue), defaultLocale: Locale.default.rawValue)
    }

    // MARK: - Content sections

    func registerBlog() -> Self {
        register(
            folder: ContentSection.blog.path,
            metadata: BlogMetadata.self,
            readers: [.parsleyMarkdownReader],
            filter: \.metadata.publish,
            writers: [
                .itemWriter(swim(renderBlogPost)),
                .listWriter(
                    Saga.atomFeed(
                        title: "Jorge Calderita's Blog",
                        author: SiteConfig.author,
                        baseURL: SiteConfig.baseURL,
                        summary: { $0.metadata.description },
                        image: { "/static/blog/\($0.metadata.cover).avif" }
                    ),
                    output: "feed.xml"
                ),
            ]
        )
    }

    func registerLegal() -> Self {
        register(
            folder: ContentSection.legal.path,
            metadata: LegalMetadata.self,
            readers: [.parsleyMarkdownReader],
            writers: [.itemWriter(swim(renderLegal))]
        )
    }

    // MARK: - Pages

    func createAllPages() -> Saga {
        Page.allCases.reduce(self) { $1.create(on: $0) }
    }

    // MARK: - Post-processing

    func highlightCode() -> Self {
        postProcess { page, path in
            guard path.string.hasSuffix(".html") else { return page }
            return Moon.shared.highlightCodeBlocks(in: page)
        }
    }

    func injectCopyButtons() -> Self {
        postProcess { page, path in
            guard path.string.hasSuffix(".html") else { return page }
            return page.replacingOccurrences(
                of: "<pre>",
                with: #"<pre class="has-copy">"#
            )
        }
    }

    // MARK: - Cleanup

    func cleanupUnhashedAssets() -> Self {
        afterWrite {
            guard !Saga.isDev else { return }
            let path = $0.outputPath + "static/style.css"
            try? path.delete()
        }
    }
}
