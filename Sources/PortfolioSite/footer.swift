import Foundation
import HTML

// MARK: - Footer

func renderFooter(locale: Locale) -> Node {
    let year = Calendar.current.component(.year, from: Date())
    let pdfRoute = "/static/JorgeCalderita-\(locale.rawValue).pdf"

    return footer(
        class: "footer",
        customAttributes: [
            "role": "contentinfo",
            "aria-label": locale.footerAria,
        ]
    ) {
        div(class: "footerLinks") {
            renderSocialLink(href: SiteConfig.linkedinURL, label: locale.linkedinAria, icon: linkedinSVG)
            renderSocialLink(href: SiteConfig.githubURL, label: locale.githubAria, icon: githubSVG)
            renderSocialLink(href: SiteConfig.xURL, label: locale.xAria, icon: xSVG)
            renderSocialLink(href: SiteConfig.discordURL, label: locale.discordAria, icon: discordSVG)
            renderSocialLink(href: SiteConfig.email, label: locale.mailAria, icon: mailSVG)
            renderSocialLink(href: pdfRoute, label: locale.pdfAria, icon: pdfSVG)
        }

        div(class: "footerBottom") {
            "© \(year) Jorge Calderita"
            a(
                class: "footerCookie",
                href: locale.cookiesPath,
                customAttributes: ["aria-label": locale.cookiePolicy]
            ) { "Cookies" }
        }
    }
}

// MARK: - Social link

func renderSocialLink(href: String, label: String, icon: String) -> Node {
    a(
        class: "socialLink",
        href: href,
        customAttributes: [
            "aria-label": label,
            "target": "_blank",
            "rel": "noopener noreferrer",
        ]
    ) {
        Node.raw(icon)
    }
}
