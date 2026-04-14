import HTML

// MARK: - Header

func renderHeader(locale: Locale, isNotMain: Bool) -> Node {
    let homeHref = isNotMain ? locale.homePath : "#"

    return header(class: "header") {
        nav(class: "headerNav") {
            a(
                class: "headerBrand",
                href: homeHref,
                customAttributes: [
                    "title": locale.text("Home", es: "Inicio"),
                    "aria-label": locale.text("Home", es: "Inicio"),
                ]
            ) { "Jorge Calderita" }

            // Desktop nav
            div(class: "headerLinks") {
                renderNavLinks(locale: locale, isNotMain: isNotMain)
            }

            // Mobile hamburger
            renderHamburgerMenu(locale: locale, isNotMain: isNotMain)

            // Toggles
            div(class: "headerActions") {
                div(class: "headerToggles") {
                    renderFlagToggle(locale: locale)
                    renderThemeToggle(locale: locale)
                }
            }
        }
    }
}

// MARK: - Navigation links

private func renderNavLinks(locale: Locale, isNotMain: Bool) -> Node {
    let sections = [locale.jobsTitle, locale.educationTitle, locale.projectsTitle]
    let prefix = locale.text("Go to section ", es: "Ir a la sección ")

    return Node.fragment(
        sections.map { section in
            a(
                href: isNotMain ? "\(locale.homePath)#\(section)" : "#\(section)",
                customAttributes: [
                    "aria-label": "\(prefix)\(section)",
                    "title": "\(prefix)\(section)",
                ]
            ) { section }
        }
        + [
            a(
                href: "\(locale.prefix)/blog/",
                customAttributes: ["aria-label": "Blog", "title": "Blog"]
            ) { "Blog" }
        ]
    )
}

// MARK: - Hamburger menu

private func renderHamburgerMenu(locale: Locale, isNotMain: Bool) -> Node {
    Node.fragment([
        button(
            class: "toggleMenu",
            id: "menu-toggle",
            customAttributes: [
                "title": locale.openMenu,
                "aria-label": locale.openMenu,
                "aria-controls": "mobile-menu",
                "aria-expanded": "false",
                "popovertarget": "mobile-menu",
            ]
        ) {
            Node.raw(hamburgerSVG)
        },
        div(class: "mobileMenu", id: "mobile-menu", customAttributes: ["popover": ""]) {
            renderNavLinks(locale: locale, isNotMain: isNotMain)
        },
    ])
}

// MARK: - Flag toggle

private func renderFlagToggle(locale: Locale) -> Node {
    a(
        class: "flagToggle",
        href: locale.other.homePath,
        id: "flag-toggle",
        customAttributes: [
            "title": locale.switchLanguage,
            "aria-label": locale.switchLanguage,
        ]
    ) {
        span(customAttributes: ["aria-hidden": "true"]) { locale.other.flag }
    }
}

// MARK: - Theme toggle

private func renderThemeToggle(locale: Locale) -> Node {
    button(
        class: "themeToggle",
        customAttributes: [
            "type": "button",
            "title": locale.toggleDarkMode,
            "aria-label": locale.toggleDarkMode,
        ]
    ) {
        span(class: "iconSun") { Node.raw(sunSVG) }
        span(class: "iconMoon") { Node.raw(moonSVG) }
    }
}
