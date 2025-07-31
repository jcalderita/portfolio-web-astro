If you prefer to read this page in English, you can find the [🇺🇸 English version here](README.md).
# jcalderita-portfolio

> **Portfolio profesional de Jorge Calderita – Desarrollador especializado en iOS, VisionOS y Swift**

[![Deploy on Cloudflare Pages](https://img.shields.io/badge/Cloudflare-Pages-orange?logo=cloudflare)](https://pages.cloudflare.com/)
[![Astro v5](https://img.shields.io/badge/Astro-5.x-blue?logo=astro)](https://astro.build/) 
[![Bun](https://img.shields.io/badge/Bun-1.x-pink?logo=bun)](https://bun.sh/)

## 🚀 Descripción

Este es el portfolio personal y profesional de Jorge Calderita, desarrollado con [Astro](https://astro.build/) y desplegado en Cloudflare Pages.  
El sitio soporta varios idiomas (español e inglés), está optimizado para SEO y accesibilidad (WAI-ARIA) y es totalmente responsive.

- **Framework:** Astro 5
- **Gestor de paquetes:** Bun
- **Estilos:** Tailwind CSS 4
- **Tipado de datos:** Zod (para validación de JSON)
- **Accesibilidad:** Cumple con estándares WCAG y usa atributos ARIA
- **Despliegue:** Cloudflare Pages
- **Tema claro/oscuro:** Soporte automático y manual (persistencia en localStorage)
- **Política de cookies:** Solo cookie técnica para el idioma

## 📁 Estructura del proyecto

Inside of your Astro project, you'll see the following folders and files:

```text
/
├── public/            # Imágenes y assets estáticos (favicons, diplomas, etc)
├── src/
│   ├── components/    # Componentes reutilizables (navbar, footer, toggles, etc)
│   ├── layouts/       # Layouts globales (MainLayout, LegalLayout)
│   ├── pages/         # Páginas .astro (multi-idioma, legales, portfolio, blog)
│   ├── data/          # Archivos JSON con el contenido estructurado
│   └── styles/        # Archivos de estilos globales
├── package.json
├── bun.lockb
└── tailwind.config.js
```

## 🛠️ Scripts útiles

| Comando            | Acción                                        |
| ------------------ | --------------------------------------------- |
| `bun install`      | Instala dependencias                          |
| `bun dev`          | Servidor local de desarrollo (`localhost:4321`)|
| `bun build`        | Compila el sitio para producción (`./dist/`)  |
| `bun preview`      | Previsualiza el sitio ya compilado            |
| `bun astro ...`    | Comandos avanzados de Astro                   |

## 🌎 Multilenguaje

El sitio detecta el idioma preferido del usuario y guarda la selección mediante una cookie técnica (`lang`).  
Todas las páginas legales tienen versión en español e inglés.

## 🔒 Accesibilidad y SEO

- Navegación mediante teclado y screen readers.
- Etiquetas ARIA y landmarks semánticos.
- Meta etiquetas para redes sociales (Open Graph, Twitter Card).
- Responsive en móvil, tablet y desktop.

## ☁️ Despliegue

Desplegado automáticamente en [Cloudflare Pages](https://pages.cloudflare.com/).  
Las reglas de idioma y preferencia se gestionan mediante Workers.

## 📄 Páginas legales

- `/es/cookies` y `/en/cookies` – Política de cookies
- `/es/aviso-legal` y `/en/legal-notice` – Aviso legal/Legal Notice

## 📦 Dependencias principales

- [Astro](https://astro.build/)
- [Bun](https://bun.sh/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Zod](https://zod.dev/)

## 👨‍💻 Autor

**Jorge Calderita**

[![LinkedIn](https://img.shields.io/badge/linkedin-0077B5?style=for-the-badge&logoColor=white&labelColor=101010)](https://www.linkedin.com/in/jcalderita)
[![GitHub](https://img.shields.io/badge/github-181717?style=for-the-badge&logoColor=white&labelColor=101010)](https://github.com/jcalderita)

## 📄 Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).

---
