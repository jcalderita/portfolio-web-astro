import ImageOptimizer
import Saga

try ImageOptimizer().run()

try await Saga()
    .i18n()
    .registerBlog()
    .registerLegal()
    .createAllPages()
    .highlightCode()
    .injectCopyButtons()
    .cleanupUnhashedAssets()
    .run()
