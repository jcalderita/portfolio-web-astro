# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Package Manager
This project uses **Bun** as the package manager, not npm or yarn.

| Command | Action |
|---------|--------|
| `bun install` | Install dependencies |
| `bun dev` | Start development server (localhost:4321) |
| `bun build` | Build for production (outputs to ./dist/) |
| `bun preview` | Preview production build |
| `bun astro ...` | Run Astro CLI commands |

### Development Workflow
- Use `bun dev` for local development
- The dev server runs on `localhost:4321`
- Production builds are output to `./dist/` directory

## Architecture Overview

This is a **multilingual personal portfolio and blog** built with Astro 5, featuring Spanish and English content.

### Key Architectural Decisions

**Framework:** Astro 5 with static site generation
**Styling:** Tailwind CSS 4 with Vite plugin integration
**Content Management:** Astro's content collections for blog posts (MDX format)
**Data Validation:** Zod schemas for type safety
**Multilingual:** Manual i18n with separate routes (`/es/` and `/en/`)
**Package Manager:** Bun (not npm/yarn)

### Content Strategy
- **Static Data:** Portfolio information stored in JSON files (`src/data/English.json`, `src/data/Spanish.json`)
- **Blog Content:** MDX files in `src/content/blog/` organized by language (`en/`, `es/`)
- **Content Schema:** Defined in `src/content/config.ts` using Zod validation
- **Images:** Blog images in `src/content/blog/images/`, public assets in `public/`

### Component Architecture
```
src/components/
├── Blog/         # Blog-specific components (cards, filters, navigation)
├── Common/       # Shared components (Head)
├── Footer/       # Footer component
├── Header/       # Navigation, theme toggle, language toggle, hamburger menu
├── Meta/         # SEO and metadata components
├── Portfolio/    # Portfolio sections (experience, projects, diplomas)
└── Utils/        # Utility components (badges, social links, buttons)
```

### Routing Structure
- Root redirects to language-specific routes
- `/es/` - Spanish content
- `/en/` - English content  
- `/es/blog/` and `/en/blog/` - Blog listing pages
- `/es/blog/[slug]` and `/en/blog/[slug]` - Individual blog posts
- Legal pages: `/es/aviso-legal`, `/en/legal-notice`, cookies pages

### Data Flow
1. **Portfolio Data:** JSON files validated against `PortfolioSchema` from `src/types/PortfolioSchema.ts`
2. **Blog Posts:** MDX files processed through Astro content collections
3. **RSS Feeds:** Generated dynamically using `src/utils/blogData.ts`
4. **Theme/Language:** Client-side persistence via localStorage and cookies

### Styling Approach
- **Tailwind CSS 4** with Vite plugin integration (not PostCSS)
- **Global styles** in `src/styles/global.css`
- **Responsive design** with mobile-first approach
- **Dark/light theme** support with system preference detection
- **Typography plugin** for blog content styling

### Key Features to Understand
- **Language Detection:** Automatic based on browser preference with manual override
- **Theme Toggle:** Persists in localStorage with system preference fallback
- **Blog Filtering:** Client-side tag filtering on blog index pages
- **Accessibility:** WCAG compliant with ARIA attributes and semantic HTML
- **SEO:** Open Graph, Twitter Card, and RSS feed support

### Important Files
- `src/content/config.ts` - Content collection schemas
- `src/types/PortfolioSchema.ts` - Type definitions for portfolio data
- `src/utils/blogData.ts` - RSS and blog utilities
- `astro.config.mjs` - Astro configuration with MDX and icon integrations
- `src/data/` - Portfolio content in JSON format

### Development Notes
- Blog posts must have `publish: true` to appear in production
- Images should be optimized and placed in appropriate directories
- All content requires both Spanish and English versions
- Component props should follow existing TypeScript patterns
- Use existing utility components before creating new ones

## Communication Guidelines

The user is learning English and requests assistance with English corrections when asking about project tasks. When the user makes English grammar or syntax errors in their requests, gently provide the corrected version along with completing their request.

### Git Commit Messages
When creating git commits, NEVER include the Claude Code footer. Keep commit messages clean without any AI attribution.