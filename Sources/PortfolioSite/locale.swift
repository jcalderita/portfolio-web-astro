enum Locale: String, CaseIterable {
    case en
    case es

    static let `default`: Self = .en

    init(from sagaLocale: String?) {
        self = Locale(rawValue: sagaLocale ?? Locale.default.rawValue) ?? .default
    }

    // MARK: - Identity

    var isDefault: Bool { self == .default }

    var flag: String {
        switch self {
        case .en: "🇺🇸"
        case .es: "🇪🇸"
        }
    }

    var other: Locale {
        switch self {
        case .en: .es
        case .es: .en
        }
    }

    func text(_ en: String, es: String) -> String {
        switch self {
        case .en: en
        case .es: es
        }
    }

    // MARK: - Routing

    var prefix: String { isDefault ? "" : "/\(rawValue)" }

    var homePath: String { "\(prefix)/" }

    func path(for slug: String) -> String { "\(prefix)/\(slug)/" }

    func blogPath(for slug: String) -> String { "\(prefix)/blog/\(slug)/" }

    func otherPath(for slug: String) -> String {
        let stripped = slug.dropFirst(prefix.count)
        let clean = stripped.isEmpty ? "/" : String(stripped)
        return "\(other.prefix)\(clean)"
    }

    var feedPath: String { "\(prefix)/blog/feed.xml" }

    var cookiesPath: String {
        text("/legal/cookies/", es: "/es/legal/cookies/")
    }
}

// MARK: - UI Translations

extension Locale {
    // Header
    var toggleDarkMode: String { text("Toggle dark mode", es: "Cambiar modo oscuro") }
    var switchLanguage: String { text("Switch language", es: "Cambiar idioma") }
    var openMenu: String { text("Open menu", es: "Abrir menú") }

    // Navigation
    var jobsTitle: String { text("Jobs", es: "Trabajos") }
    var educationTitle: String { text("Education", es: "Educación") }
    var projectsTitle: String { text("Projects", es: "Proyectos") }
    var blogTitle: String { "Blog" }

    // Blog
    var allTags: String { text("All", es: "Todos") }
    var tableOfContents: String { text("Table of contents", es: "Tabla de contenidos") }
    var subscribeRSS: String { text("Subscribe to RSS", es: "Suscribirse al RSS") }
    var backLabel: String { text("Go back", es: "Volver atrás") }
    var topLabel: String { text("Back to top", es: "Volver arriba") }

    // Footer
    var footerAria: String { text("Jorge Calderita's social medias", es: "Redes sociales de Jorge Calderita") }
    var linkedinAria: String { text("Go to Jorge Calderita's LinkedIn", es: "Ir al LinkedIn de Jorge Calderita") }
    var githubAria: String { text("Go to Jorge Calderita's GitHub", es: "Ir al GitHub de Jorge Calderita") }
    var xAria: String { text("Go to Jorge Calderita's X profile", es: "Ir al perfil de X de Jorge Calderita") }
    var discordAria: String { text("Join Jorge Calderita's Discord", es: "Unirse al Discord de Jorge Calderita") }
    var mailAria: String { text("Send an email to Jorge Calderita", es: "Enviar un email a Jorge Calderita") }
    var pdfAria: String { text("Download portfolio in PDF format", es: "Descargar CV en PDF") }
    var cookiePolicy: String { text("Cookie policy", es: "Política de cookies") }

    // Projects
    func projectGithubAria(_ name: String) -> String { text("Go to \(name) on GitHub", es: "Ir a \(name) en GitHub") }

    // Diploma
    var viewDiploma: String { text("View full-size certificate", es: "Ver diploma ampliado") }
    var closeDiploma: String { text("Close", es: "Cerrar") }

    // Meta
    var blogDescription: String { text("Jorge Calderita's personal Blog", es: "Blog personal de Jorge Calderita") }
    var metaKeywords: String { "Jorge Calderita, Calderita, Swift, iOS, VisionOS, SwiftUI, Vapor, Portfolio, Developer, Accessibility" }

    // 404
    var notFoundTitle: String { text("Page not found", es: "Página no encontrada") }
    var notFoundMessage: String { text("The page you're looking for doesn't exist.", es: "La página que buscas no existe.") }
    var goHome: String { text("Go home", es: "Ir al inicio") }

    // Date formatting
    var dateLocaleIdentifier: String { text("en_US", es: "es_ES") }
}
