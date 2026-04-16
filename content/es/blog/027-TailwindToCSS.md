---
title: Tailwind to CSS
slug: tailwind-to-css
date: 2026-03-07
description: Por qué migré mi portfolio de Tailwind CSS a vanilla CSS y qué ventajas obtuve en rendimiento, peso y control total del código.
tags: Astro, Tailwind
cover: TailwindToCSS
coverDescription: Jorge pintándose a sí mismo en un lienzo, representando el control total sobre los estilos de su portfolio.
publish: true
---
---
## 🎨 ¿Por Qué Tocar Lo Que Funciona?

Mi portfolio llevaba meses funcionando perfectamente con <span class="high">Tailwind CSS</span>. Todo iba bien. Los estilos estaban en su sitio, los componentes se veían geniales y la web cargaba rápido.

Entonces, ¿por qué cambiar?

Porque **funcionar bien** y **funcionar de la mejor manera posible** son cosas distintas. Y cuando te paras a analizar qué hay debajo del capó, a veces descubres que llevas una capa que <span class="high">no necesitas</span> 🧅.

---

## 🤔 El Problema con Tailwind (en mi caso)

No me malinterpretéis: <span class="high">Tailwind CSS</span> es una herramienta **brutal**. Lo he usado en proyectos profesionales y lo seguiré usando donde tenga sentido. Pero en un portfolio personal con <span class="high">Astro</span>, empecé a notar ciertas cosas:

- **Dependencia innecesaria**: 3 paquetes extra (<span class="high">tailwindcss</span>, <span class="high">@tailwindcss/vite</span>, <span class="high">@tailwindcss/typography</span>) para un proyecto que no los necesitaba realmente 📦
- **Capa de abstracción**: Tailwind genera CSS a partir de clases de utilidad. Es una capa entre lo que escribes y lo que el navegador interpreta. En un proyecto pequeño, esa capa **suma sin aportar** 🧱
- **Peso extra**: El CSS generado incluía utilidades que no siempre aprovechaba al máximo. ~20KB de más que el usuario descargaba sin necesidad 📊
- **Menor control**: Cuando quieres algo muy específico, acabas luchando contra el framework en vez de escribir directamente lo que necesitas ⚔️

---

## 💡 La Decisión: Vanilla CSS con Design Tokens

La idea era sencilla: **eliminar Tailwind** y sustituirlo por <span class="high">CSS vanilla</span> con un sistema de **design tokens** usando <span class="high">custom properties</span> de CSS.

¿Qué son los design tokens? Son variables CSS que definen tu sistema de diseño:

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

Con esto tienes **consistencia** en todo el proyecto sin depender de ningún framework. Solo CSS puro que el navegador entiende <span class="high">directamente</span> 🎯.

---

## 🔧 La Migración

El proceso fue migrar **38 archivos** en un solo commit. Cada componente <span class="high">Astro</span> pasó de usar clases de Tailwind a tener su propio bloque <span class="high">&lt;style&gt;</span> con estilos scoped:

**Antes (Tailwind):**
```astro
<header class="flex items-center justify-between px-6 py-4 bg-white dark:bg-gray-900">
  <nav class="flex gap-4">
    <a class="text-sm font-medium text-gray-700 hover:text-blue-500">Blog</a>
  </nav>
</header>
```

**Después (Vanilla CSS):**
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

¿Más líneas? Sí. ¿Más claro y mantenible? **Absolutamente** ✅.

---

## 📚 Lo Que Aprendí por el Camino

La migración no fue solo "quitar Tailwind y poner CSS". Hubo trampas interesantes que vale la pena compartir:

### Estilos scoped y <span class="high">&lt;slot&gt;</span>

En <span class="high">Astro</span>, los estilos dentro de <span class="high">&lt;style&gt;</span> son **scoped** por defecto. Esto significa que cada componente recibe un atributo único (<span class="high">data-astro-cid-*</span>) y los estilos solo afectan a ese componente.

El problema: el contenido que llega por <span class="high">&lt;slot&gt;</span> **no recibe** ese atributo. Si un componente padre intenta estilizar lo que viene por slot, los estilos no se aplican 😱.

**La solución**: usar <span class="high">:global()</span> para los selectores que afectan a contenido slotted:

```css
.container :global(a) {
  color: var(--color-primary);
  text-decoration: underline;
}
```

### <span class="high">opacity</span> vs transparencia de fondo

Con Tailwind usaba clases como <span class="high">bg-opacity-70</span>. Al migrar, el primer instinto fue usar la propiedad <span class="high">opacity</span>. **Error**: <span class="high">opacity</span> afecta al elemento entero, **incluidos sus hijos** 👶.

**La solución correcta**: <span class="high">color-mix()</span> para transparencia solo en el fondo:

```css
.modal-overlay {
  /* MAL: afecta a todo */
  opacity: 0.7;

  /* BIEN: solo el fondo es transparente */
  background-color: color-mix(in oklab, var(--color-gray-900) 70%, transparent);
}
```

---

## 📊 Los Resultados

Los números hablan por sí solos:

- **~20KB menos** de CSS entregado al navegador 📉
- **3 dependencias eliminadas** del `package.json` 🗑️
- **0 capas de abstracción** entre tu código y el navegador 🎯
- **Build más rápido** al no necesitar el procesamiento de Tailwind ⚡
- **Control total** sobre cada línea de CSS que se genera 🎛️

El <span class="high">package.json</span> pasó de tener <span class="high">tailwindcss</span>, <span class="high">@tailwindcss/vite</span> y <span class="high">@tailwindcss/typography</span> a **no tener ninguna dependencia de estilos**. Solo CSS puro.

Y lo mejor: se eliminó el archivo <span class="high">tailwind.config.mjs</span> por completo. <span class="high">Una configuración menos</span> que mantener 🧹.

---

## 🏗️ La Arquitectura Final

El sistema de estilos quedó organizado en 4 archivos CSS:

| Archivo | Responsabilidad |
|---------|----------------|
| <span class="high">design-tokens.css</span> | Colores, tipografía, espaciado, sombras, transiciones |
| <span class="high">base-reset.css</span> | Reset CSS mínimo y utilidades como <span class="high">.sr-only</span> |
| <span class="high">prose.css</span> | Tipografía para contenido del blog con soporte dark mode |
| <span class="high">layout.css</span> | Clases de layout globales (<span class="high">.bodyLayout</span>, <span class="high">.mainLayout</span>) |

Todo importado desde un único <span class="high">global.css</span>. Limpio, predecible y sin magia negra 🧙‍♂️.

---

## 💭 Reflexión Final

Migrar de <span class="high">Tailwind CSS</span> a <span class="high">vanilla CSS</span> no es para todos ni para todos los proyectos. En equipos grandes o proyectos con muchos desarrolladores, Tailwind sigue siendo una **opción fantástica** por su consistencia y velocidad de desarrollo.

Pero en un proyecto personal como un portfolio con <span class="high">Astro</span>, donde el rendimiento importa y el control total es un lujo que puedes permitirte, **quitarte esa capa de abstracción** es liberador 🕊️. De hecho, acabé llevando esta filosofía aún más lejos y migré todo el portfolio de Astro a Swift — cuento la historia completa en [Astro to Saga](/es/blog/astro-to-saga/).

Es como pintar un cuadro: puedes usar plantillas y herramientas que te guíen, o puedes coger el pincel y crear **exactamente** lo que tienes en mente. Ambas opciones son válidas. Pero cuando el lienzo es tuyo, <span class="high">pintar a mano tiene su encanto</span> 🎨.


**Keep coding, keep running** 🏃‍♂️

---
