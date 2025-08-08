Si prefieres leer esta página en español, puedes encontrar la [🇪🇸 Versión en español aquí](README_es.md).
# jcalderita-portfolio

> **Professional portfolio of Jorge Calderita – Developer specialized in iOS, VisionOS, and Swift**

[![Deploy on Cloudflare Pages](https://img.shields.io/badge/Cloudflare-Pages-orange?logo=cloudflare)](https://pages.cloudflare.com/)
[![Astro v5](https://img.shields.io/badge/Astro-5.x-blue?logo=astro)](https://astro.build/) 
[![Bun](https://img.shields.io/badge/Bun-1.x-pink?logo=bun)](https://bun.sh/)

## 🚀 Description

This is the personal and professional portfolio of Jorge Calderita, developed with [Astro](https://astro.build/) and deployed on Cloudflare Pages.  
The site supports multiple languages (Spanish and English), is optimized for SEO and accessibility (WAI-ARIA), and is fully responsive.

- **Framework:** Astro 5
- **Package manager:** Bun
- **Styling:** Tailwind CSS 4
- **Data validation:** Zod (for JSON validation)
- **Accessibility:** Complies with WCAG standards and uses ARIA attributes
- **Deployment:** Cloudflare Pages
- **Light/dark theme:** Automatic and manual support (persists in localStorage)
- **Cookie policy:** Only a technical cookie for language preference

## 📁 Project structure

Inside of your Astro project, you'll see the following folders and files:

```text
/
├── public/           # Images and static assets (favicons, diplomas, etc.)
├── src/
│   ├── components/   # Reusable components (navbar, footer, toggles, etc.)
│   ├── content/      # Blog content in Markdown
│   ├── data/         # JSON files with structured content
│   ├── icons/        # SVG files for icons
│   ├── layouts/      # Global layouts (MainLayout, LegalLayout)
│   ├── pages/        # .astro pages (multi-language, legal, portfolio, blog)
│   ├── styles/       # Global styles
│   ├── types/        # Schema used by the portfolio
│   └── utils/        # Common reusable utilities
├── package.json
├── bun.lockb
└── tailwind.config.js
```

## 🛠️ Useful Scripts

| Command            | Action                                         |
| ------------------ | ---------------------------------------------- |
| `bun install`      | Install dependencies                           |
| `bun dev`          | Local development server (`localhost:4321`)    |
| `bun build`        | Build the site for production (`./dist/`)      |
| `bun preview`      | Preview the compiled site                      |
| `bun astro ...`    | Advanced Astro commands                        |

## 🌎 Multilanguage

The site detects the user's preferred language and saves the selection using a technical cookie (`lang`).  
All legal pages are available in both Spanish and English.

## 🔒 Accessibility and SEO

- Keyboard navigation and screen reader support.
- ARIA attributes and semantic landmarks.
- Meta tags for social sharing (Open Graph, Twitter Card).
- Responsive on mobile, tablet, and desktop.

## ☁️ Deployment

Automatically deployed on [Cloudflare Pages](https://pages.cloudflare.com/).  
Language and preference rules are managed by Workers.

## 📄 Legal Pages

- `/es/cookies` and `/en/cookies` – Cookie Policy
- `/es/aviso-legal` and `/en/legal-notice` – Legal Notice

## 📦 Main dependencies

- [Astro](https://astro.build/)
- [Bun](https://bun.sh/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Zod](https://zod.dev/)

## 👨‍💻 Author

**Jorge Calderita**

[![LinkedIn](https://img.shields.io/badge/linkedin-0077B5?style=for-the-badge&logoColor=white&labelColor=101010)](https://www.linkedin.com/in/jcalderita)
[![GitHub](https://img.shields.io/badge/github-181717?style=for-the-badge&logoColor=white&labelColor=101010)](https://github.com/jcalderita)

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---
