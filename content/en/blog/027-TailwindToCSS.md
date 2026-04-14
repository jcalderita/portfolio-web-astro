---
title: Tailwind to CSS
slug: tailwind-to-css
date: 2026-03-07
description: Why I migrated my portfolio from Tailwind CSS to vanilla CSS and the benefits I gained in performance, bundle size, and full control over the code.
tags: Astro, Tailwind
cover: TailwindToCSS
coverDescription: Jorge painting himself on a canvas, representing full control over his portfolio's styles.
publish: true
---
---
## 🎨 Why Touch What Already Works?

My portfolio had been running perfectly with <span class="high">Tailwind CSS</span> for months. Everything was fine. Styles were in place, components looked great, and the site loaded fast.

So why change?

Because **working well** and **working the best way possible** are two different things. And when you stop to analyze what's under the hood, you sometimes discover you're carrying a layer you <span class="high">don't need</span> 🧅.

---

## 🤔 The Problem with Tailwind (In My Case)

Don't get me wrong: <span class="high">Tailwind CSS</span> is an **amazing** tool. I've used it in professional projects and will continue using it where it makes sense. But in a personal portfolio built with <span class="high">Astro</span>, I started noticing a few things:

- **Unnecessary dependency**: 3 extra packages (<span class="high">tailwindcss</span>, <span class="high">@tailwindcss/vite</span>, <span class="high">@tailwindcss/typography</span>) for a project that didn't really need them 📦
- **Abstraction layer**: Tailwind generates CSS from utility classes. It's a layer between what you write and what the browser interprets. In a small project, that layer **adds overhead without adding value** 🧱
- **Extra weight**: The generated CSS included utilities I wasn't always taking full advantage of. ~20KB extra that the user downloaded unnecessarily 📊
- **Less control**: When you want something very specific, you end up fighting the framework instead of writing exactly what you need ⚔️

---

## 💡 The Decision: Vanilla CSS with Design Tokens

The idea was simple: **remove Tailwind** and replace it with <span class="high">vanilla CSS</span> using a **design tokens** system with CSS <span class="high">custom properties</span>.

What are design tokens? They're CSS variables that define your design system:

```css
:root {
  --color-primary: oklch(0.55 0.2 260);
  --color-gray-100: oklch(0.97 0 0);
  --color-gray-900: oklch(0.21 0.006 285.75);

  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-xl: 1.25rem;

  --spacing: 0.25rem;
  --radius-lg: 0.5rem;

  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --transition-colors: color 0.15s, background-color 0.15s, border-color 0.15s;
}
```

With this, you get **consistency** across the entire project without depending on any framework. Just pure CSS that the browser understands <span class="high">directly</span> 🎯.

---

## 🔧 The Migration

The process involved migrating **38 files** in a single commit. Each <span class="high">Astro</span> component went from using Tailwind classes to having its own scoped <span class="high">&lt;style&gt;</span> block:

**Before (Tailwind):**
```astro
<header class="flex items-center justify-between px-6 py-4 bg-white dark:bg-gray-900">
  <nav class="flex gap-4">
    <a class="text-sm font-medium text-gray-700 hover:text-blue-500">Blog</a>
  </nav>
</header>
```

**After (Vanilla CSS):**
```astro
<header class="header">
  <nav class="nav">
    <a class="nav-link">Blog</a>
  </nav>
</header>

<style>
  .header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: calc(var(--spacing) * 4) calc(var(--spacing) * 6);
    background-color: var(--color-white);
  }

  :global(.dark) .header {
    background-color: var(--color-gray-900);
  }

  .nav {
    display: flex;
    gap: calc(var(--spacing) * 4);
  }

  .nav-link {
    font-size: var(--text-sm);
    font-weight: 500;
    color: var(--color-gray-700);
    transition: var(--transition-colors);
  }

  .nav-link:hover {
    color: var(--color-blue-500);
  }
</style>
```

More lines? Yes. Clearer and more maintainable? **Absolutely** ✅.

---

## 📚 What I Learned Along the Way

The migration wasn't just "remove Tailwind and add CSS." There were interesting pitfalls worth sharing:

### Scoped styles and <span class="high">&lt;slot&gt;</span>

In <span class="high">Astro</span>, styles inside <span class="high">&lt;style&gt;</span> are **scoped** by default. This means each component receives a unique attribute (<span class="high">data-astro-cid-*</span>) and styles only affect that component.

The catch: content passed via <span class="high">&lt;slot&gt;</span> **does not receive** that attribute. If a parent component tries to style slotted content, the styles won't apply 😱.

**The solution**: use <span class="high">:global()</span> for selectors targeting slotted content:

```css
.container :global(a) {
  color: var(--color-primary);
  text-decoration: underline;
}
```

### <span class="high">opacity</span> vs background transparency

With Tailwind, I used classes like <span class="high">bg-opacity-70</span>. When migrating, my first instinct was to use the <span class="high">opacity</span> property. **Mistake**: <span class="high">opacity</span> affects the entire element, **including its children** 👶.

**The correct solution**: <span class="high">color-mix()</span> for background-only transparency:

```css
.modal-overlay {
  /* BAD: affects everything */
  opacity: 0.7;

  /* GOOD: only the background is transparent */
  background-color: color-mix(in oklab, var(--color-gray-900) 70%, transparent);
}
```

---

## 📊 The Results

The numbers speak for themselves:

- **~20KB less** CSS delivered to the browser 📉
- **3 dependencies removed** from `package.json` 🗑️
- **0 abstraction layers** between your code and the browser 🎯
- **Faster builds** by eliminating Tailwind's processing step ⚡
- **Full control** over every line of CSS generated 🎛️

The <span class="high">package.json</span> went from having <span class="high">tailwindcss</span>, <span class="high">@tailwindcss/vite</span>, and <span class="high">@tailwindcss/typography</span> to **no styling dependencies at all**. Just pure CSS.

And the best part: the <span class="high">tailwind.config.mjs</span> file was completely removed. <span class="high">One less configuration</span> to maintain 🧹.

---

## 🏗️ The Final Architecture

The styling system ended up organized into 4 CSS files:

| File | Responsibility |
|------|---------------|
| <span class="high">design-tokens.css</span> | Colors, typography, spacing, shadows, transitions |
| <span class="high">base-reset.css</span> | Minimal CSS reset and utilities like <span class="high">.sr-only</span> |
| <span class="high">prose.css</span> | Blog content typography with dark mode support |
| <span class="high">layout.css</span> | Global layout classes (<span class="high">.bodyLayout</span>, <span class="high">.mainLayout</span>) |

All imported from a single <span class="high">global.css</span>. Clean, predictable, and no black magic 🧙‍♂️.

---

## 💭 Final Thoughts

Migrating from <span class="high">Tailwind CSS</span> to <span class="high">vanilla CSS</span> isn't for everyone or every project. In large teams or projects with many developers, Tailwind remains a **fantastic choice** for its consistency and development speed.

But in a personal project like a portfolio built with <span class="high">Astro</span>, where performance matters and full control is a luxury you can afford, **removing that abstraction layer** is liberating 🕊️.

It's like painting a picture: you can use templates and tools to guide you, or you can pick up the brush and create **exactly** what you have in mind. Both options are valid. But when the canvas is yours, <span class="high">painting by hand has its charm</span> 🎨.


**Keep coding, keep running** 🏃‍♂️

---
