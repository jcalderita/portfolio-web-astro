Si prefieres leer esta página en español, puedes encontrar la [🇪🇸 Versión en español aquí](README_es.md).
# jcalderita-portfolio

> **Professional portfolio of Jorge Calderita – Developer specialized in iOS, VisionOS, and Swift**

[![Deploy on Cloudflare Pages](https://img.shields.io/badge/Cloudflare-Pages-orange?logo=cloudflare)](https://pages.cloudflare.com/)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-F05138?logo=swift&logoColor=white)](https://swift.org/)
[![Saga 3.3](https://img.shields.io/badge/Saga-3.3-blueviolet)](https://github.com/loopwerk/Saga)

## 🚀 Description

This is the personal and professional portfolio of Jorge Calderita, built with [Saga](https://github.com/loopwerk/Saga) (a Swift static site generator) and deployed on [Cloudflare Pages](https://pages.cloudflare.com/).
The site supports multiple languages (Spanish and English), is optimized for SEO and accessibility (WAI-ARIA), and is fully responsive.

- **Language:** Swift 6.3
- **Static site generator:** Saga
- **HTML DSL:** Swim (type-safe HTML)
- **Styling:** Vanilla CSS with design tokens
- **Syntax highlighting:** Moon (Prism.js classes, Xcode Dark theme)
- **Accessibility:** Complies with WCAG standards and uses ARIA attributes
- **Deployment:** Cloudflare Pages via GitHub Actions
- **Social automation:** Auto-post on publish to X (OAuth 1.0a) and LinkedIn (Make.com webhook)
- **Light/dark theme:** Automatic and manual support
- **Cookie policy:** Only a technical cookie for language preference

## 📁 Project structure

```text
/
├── Sources/
│   ├── PortfolioSite/     # Site generator (layouts, pages, components, SEO, i18n)
│   └── ImageOptimizer/    # PNG → WebP image optimization pipeline
├── worker/
│   └── index.js           # Cloudflare Worker (unused — kept for reference)
├── content/
│   ├── en/blog/           # English blog posts (Markdown)
│   ├── es/blog/           # Spanish blog posts (Markdown)
│   ├── {en,es}/legal/     # Legal pages (both languages)
│   ├── robots.txt         # Robots.txt (allow all, sitemap reference)
│   ├── llms.txt           # LLM crawler description (llmstxt.org spec)
│   └── static/            # CSS, images, favicons, PDFs
├── Package.swift           # Swift Package Manager manifest
├── wrangler.toml           # Cloudflare Workers config (ASSETS binding)
└── deploy/                 # Generated output (git-ignored)
```

## 🛠️ Build commands

| Command | Action |
|---------|--------|
| `swift build` | Build the project |
| `swift build -c release` | Release build |
| `swift run PortfolioSite` | Build site (ImageOptimizer + Saga → `deploy/`) |
| `saga dev` | Dev server with file watching and auto-reload |
| `saga build` | Build via saga-cli (equivalent to `swift run`) |

## 📋 Requirements

- Swift 6.3+
- macOS 26+

## 🌎 Multilanguage

English is the default locale (no URL prefix). Spanish is available under `/es/`.
Each locale has its own RSS feed and all legal pages are available in both languages.

## 🔒 Accessibility and SEO

- Keyboard navigation and screen reader support.
- ARIA attributes and semantic landmarks.
- Meta tags for social sharing (Open Graph, Twitter Card).
- Canonical and hreflang tags for multilingual SEO.
- JSON-LD structured data (Person on home, BlogPosting on articles).
- Custom sitemap with `lastmod` dates and hreflang alternates.
- `robots.txt` and `llms.txt` for search and AI crawlers.
- DNS-only mode on Cloudflare (no Workers) to avoid bot blocking.
- Responsive on mobile, tablet, and desktop.

## ☁️ Deployment

Automatically deployed on [Cloudflare Pages](https://pages.cloudflare.com/) via GitHub Actions.

| Branch | Environment |
|--------|-------------|
| `main` | Production |
| `developing` | Staging |

When a blog post is published (`publish: true`), the workflow automatically posts to **X** and **LinkedIn** in both Spanish and English. X posts use the frontmatter `description` + URL + `tags` as hashtags. LinkedIn posts include an 80-word excerpt, article link with preview, and hashtags — sent via Make.com webhook. The entire social automation runs as a single Swift script (`.github/scripts/publish-social.swift`).

## 📄 Legal Pages

- `/es/cookies` and `/en/cookies` – Cookie Policy
- `/es/aviso-legal` and `/en/legal-notice` – Legal Notice

## 📦 Main dependencies

- [Saga](https://github.com/loopwerk/Saga) – Static site generator
- [Swim](https://github.com/robb/Swim) – Type-safe HTML DSL
- [Moon](https://github.com/loopwerk/Moon) – Syntax highlighting
- [Parsley](https://github.com/loopwerk/Parsley) – Markdown parsing

## 👨‍💻 Author

**Jorge Calderita**

[![LinkedIn](https://img.shields.io/badge/linkedin-0077B5?style=for-the-badge&logoColor=white&labelColor=101010)](https://www.linkedin.com/in/jcalderita)
[![GitHub](https://img.shields.io/badge/github-181717?style=for-the-badge&logoColor=white&labelColor=101010)](https://github.com/jcalderita)

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---
