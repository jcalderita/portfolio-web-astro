If you prefer to read this page in English, you can find the [🇺🇸 English version here](README.md).
# jcalderita-portfolio

> **Portfolio profesional de Jorge Calderita – Desarrollador especializado en iOS, VisionOS y Swift**

[![Deploy on Cloudflare Pages](https://img.shields.io/badge/Cloudflare-Pages-orange?logo=cloudflare)](https://pages.cloudflare.com/)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-F05138?logo=swift&logoColor=white)](https://swift.org/)
[![Saga 3.3](https://img.shields.io/badge/Saga-3.3-blueviolet)](https://github.com/loopwerk/Saga)

## 🚀 Descripción

Este es el portfolio personal y profesional de Jorge Calderita, construido con [Saga](https://github.com/loopwerk/Saga) (un generador de sitios estáticos en Swift) y desplegado en [Cloudflare Pages](https://pages.cloudflare.com/).
El sitio soporta varios idiomas (español e inglés), está optimizado para SEO y accesibilidad (WAI-ARIA) y es totalmente responsive.

- **Lenguaje:** Swift 6.3
- **Generador de sitios estáticos:** Saga
- **DSL HTML:** Swim (HTML tipado)
- **Estilos:** CSS vanilla con design tokens
- **Resaltado de sintaxis:** Moon (clases Prism.js, tema Xcode Dark)
- **Accesibilidad:** Cumple con estándares WCAG y usa atributos ARIA
- **Despliegue:** Cloudflare Pages mediante GitHub Actions
- **Automatización social:** Auto-post al publicar en X (OAuth 1.0a) y LinkedIn (webhook Make.com)
- **Tema claro/oscuro:** Soporte automático y manual
- **Política de cookies:** Solo cookie técnica para el idioma

## 📁 Estructura del proyecto

```text
/
├── Sources/
│   ├── PortfolioSite/     # Generador del sitio (layouts, páginas, componentes, SEO, i18n)
│   └── ImageOptimizer/    # Pipeline de optimización de imágenes PNG → WebP
├── worker/
│   └── index.js           # Cloudflare Worker (sin uso — conservado como referencia)
├── content/
│   ├── en/blog/           # Artículos del blog en inglés (Markdown)
│   ├── es/blog/           # Artículos del blog en español (Markdown)
│   ├── {en,es}/legal/     # Páginas legales (ambos idiomas)
│   ├── robots.txt         # Robots.txt (permite todo, referencia al sitemap)
│   ├── llms.txt           # Descripción para crawlers de IA (spec llmstxt.org)
│   └── static/            # CSS, imágenes, favicons, PDFs
├── Package.swift           # Manifiesto de Swift Package Manager
├── wrangler.toml           # Configuración de Cloudflare Workers (binding ASSETS)
└── deploy/                 # Salida generada (ignorado por git)
```

## 🛠️ Comandos de compilación

| Comando | Acción |
|---------|--------|
| `swift build` | Compilar el proyecto |
| `swift build -c release` | Compilación en modo release |
| `swift run PortfolioSite` | Generar sitio (ImageOptimizer + Saga → `deploy/`) |
| `saga dev` | Servidor de desarrollo con recarga automática |
| `saga build` | Build via saga-cli (equivalente a `swift run`) |

## 📋 Requisitos

- Swift 6.3+
- macOS 26+

## 🌎 Multilenguaje

El inglés es el idioma por defecto (sin prefijo en la URL). El español está disponible bajo `/es/`.
Cada idioma tiene su propio feed RSS y todas las páginas legales están disponibles en ambos idiomas.

## 🔒 Accesibilidad y SEO

- Navegación mediante teclado y lectores de pantalla.
- Atributos ARIA y landmarks semánticos.
- Meta etiquetas para redes sociales (Open Graph, Twitter Card).
- Tags canonical y hreflang para SEO multilingüe.
- JSON-LD con datos estructurados (Person en home, BlogPosting en artículos).
- Sitemap personalizado con fechas `lastmod` y alternativas hreflang.
- `robots.txt` y `llms.txt` para crawlers de búsqueda e IA.
- Modo DNS-only en Cloudflare (sin Workers) para evitar bloqueo de bots.
- Responsive en móvil, tablet y desktop.

## ☁️ Despliegue

Desplegado automáticamente en [Cloudflare Pages](https://pages.cloudflare.com/) mediante GitHub Actions.

| Rama | Entorno |
|------|---------|
| `main` | Producción |
| `developing` | Staging |

Cuando un artículo del blog se publica (`publish: true`), el workflow publica automáticamente en **X** y **LinkedIn** en español e inglés. Los posts de X usan el `description` del frontmatter + URL + `tags` como hashtags. Los posts de LinkedIn incluyen un extracto de 80 palabras, enlace al artículo con vista previa y hashtags — enviados vía webhook de Make.com. Toda la automatización social se ejecuta como un único script Swift (`.github/scripts/publish-social.swift`).

## 📄 Páginas legales

- `/es/cookies` y `/en/cookies` – Política de cookies
- `/es/aviso-legal` y `/en/legal-notice` – Aviso legal / Legal Notice

## 📦 Dependencias principales

- [Saga](https://github.com/loopwerk/Saga) – Generador de sitios estáticos
- [Swim](https://github.com/robb/Swim) – DSL HTML tipado
- [Moon](https://github.com/loopwerk/Moon) – Resaltado de sintaxis
- [Parsley](https://github.com/loopwerk/Parsley) – Parseador de Markdown

## 👨‍💻 Autor

**Jorge Calderita**

[![LinkedIn](https://img.shields.io/badge/linkedin-0077B5?style=for-the-badge&logoColor=white&labelColor=101010)](https://www.linkedin.com/in/jcalderita)
[![GitHub](https://img.shields.io/badge/github-181717?style=for-the-badge&logoColor=white&labelColor=101010)](https://github.com/jcalderita)

## 📄 Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).

---
