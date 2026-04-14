import HTML

// MARK: - Role

func renderRole(role: String, introduction: String) -> Node {
    div(class: "roleSection") {
        h1(class: "roleTitle") { role }
        hr(class: "roleDivider")
        p(class: "roleIntro") { introduction }
    }
}

// MARK: - Experiences

func renderExperiences(title: String, experiences: [Experience], locale: Locale) -> Node {
    div(class: "sectionWrapper", id: title) {
        h2(class: "sectionTitle") { title }
        Node.fragment(experiences.map { renderExperience($0, locale: locale) })
    }
}

private func renderExperience(_ exp: Experience, locale: Locale) -> Node {
    div(class: "expCard") {
        div(class: "expHeader") {
            div(class: "expHeaderText") {
                h2 { exp.title }
                h3 { exp.role }
                h3 {
                    exp.place
                    span(class: "expInterval") { " \(exp.interval)" }
                }
            }
            if let code = exp.diploma, let alt = exp.alt {
                renderDiploma(code: code, alt: alt, locale: locale)
            }
        }
        div(class: "expBody") {
            ul {
                Node.fragment(exp.responsibilities.map { resp in li { resp } })
            }
        }
        div(class: "expFooter") {
            Node.fragment(exp.technologies.map { renderBadge($0) })
        }
    }
}

// MARK: - Diploma (native dialog modal)

func renderDiploma(code: String, alt: String, locale: Locale) -> Node {
    span(class: "diplomaWrapper") {
        button(
            class: "diplomaThumbLabel",
            customAttributes: [
                "type": "button",
                "aria-label": locale.viewDiploma,
                "title": locale.viewDiploma,
                "onclick": "this.nextElementSibling.showModal()",
            ]
        ) {
            img(
                class: "diplomaThumbImg",
                customAttributes: [
                    "src": "/static/diplomas/\(code).png",
                    "alt": alt,
                    "loading": "lazy",
                ]
            )
        }
        dialog(
            class: "diplomaModal",
            customAttributes: ["aria-label": alt]
        ) {
            button(
                class: "diplomaModalClose",
                customAttributes: [
                    "type": "button",
                    "aria-label": locale.closeDiploma,
                    "onclick": "this.closest('dialog').close()",
                ]
            ) {
                img(
                    class: "diplomaModalImg",
                    customAttributes: [
                        "src": "/static/diplomas/\(code).png",
                        "alt": alt,
                        "loading": "lazy",
                    ]
                )
            }
        }
    }
}

// MARK: - Projects

func renderProjects(title: String, projects: [Project], locale: Locale) -> Node {
    div(class: "sectionWrapper", id: title) {
        h2(class: "sectionTitle") { title }
        div(class: "projectsGrid") {
            Node.fragment(projects.map { renderProject($0, locale: locale) })
        }
    }
}

private func renderProject(_ project: Project, locale: Locale) -> Node {
    div(class: "projCard") {
        div(class: "projHeader") {
            h2 { project.name }
        }
        div(class: "projBody") {
            Node.raw(renderMarkdownInline(project.description))
        }
        div(class: "projFooter") {
            renderSocialLink(href: project.link, label: locale.projectGithubAria(project.name), icon: githubSVG)
        }
    }
}

// MARK: - Badge

func renderBadge(_ info: String, dataInfo: Bool = false) -> Node {
    if dataInfo {
        return span(class: "badge", customAttributes: ["data-info": info]) { info }
    }
    return span(class: "badge") { info }
}

// MARK: - Up button

func renderUpButton(locale: Locale) -> Node {
    button(
        class: "upButton",
        customAttributes: [
            "type": "button",
            "aria-label": locale.topLabel,
            "onclick": "window.scrollTo({top:0})",
        ]
    ) {
        Node.raw(chevronUpSVG)
    }
}

// MARK: - Back button

func renderBackButton(locale: Locale) -> Node {
    button(
        class: "backButton",
        customAttributes: [
            "type": "button",
            "aria-label": locale.backLabel,
            "onclick": "history.back()",
        ]
    ) {
        Node.raw(chevronLeftSVG)
    }
}

// MARK: - Simple inline markdown

/// Converts **bold** and *italic* markdown to HTML inline.
/// Used for project descriptions only.
func renderMarkdownInline(_ text: String) -> String {
    let result = text
        .replacing(/\*\*(.+?)\*\*/) { "<strong>\($0.1)</strong>" }
        .replacing(/\*(.+?)\*/) { "<em>\($0.1)</em>" }
    return "<p>\(result)</p>"
}
