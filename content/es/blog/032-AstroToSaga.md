---
title: Astro to Saga
slug: astro-to-saga
date: 2026-04-15
description: Por qué migré mi portfolio de Astro a Saga, un generador de sitios estáticos en Swift, y cómo eliminé Node de mi stack para siempre.
tags: Swift, Astro, Saga
cover: AstroToSaga
coverDescription: Jorge navegando en un barco vikingo llamado Saga entre olas tormentosas, con escudos de Swift, HTML5, CSS3, Markdown y Saga en el casco, representando la migración del portfolio a un stack nativo en Swift.
publish: true
---
---
## Mi Problema 🤔

Mi portfolio funcionaba sobre <span class="high">Astro</span> con <span class="high">Bun</span>. Todo iba bien. Rápido, cómodo, sin quejas técnicas.

Pero había algo que no encajaba. Cada vez que abría el proyecto me encontraba con un <span class="high">package.json</span>, un <span class="high">tailwind.config</span>, un <span class="high">astro.config</span>, y una carpeta <span class="high">node_modules</span> con cientos de dependencias que ni sabía que existían. Esa sensación de perder el control sobre lo que hay dentro de tu propio proyecto me incomoda. Me gusta saber qué ejecuta mi código y por qué está ahí. Ya había eliminado Tailwind en una [migración previa a vanilla CSS](/es/blog/tailwind-to-css/), pero el resto del ecosistema JavaScript seguía ahí.

Y al final, soy desarrollador Swift. Mi día a día es Swift. Y sin embargo, para generar mi propio portfolio dependía de un ecosistema completamente ajeno. Si alguien entraba en mi repositorio, no veía a un desarrollador Swift. Veía un proyecto JavaScript más.

La pregunta era sencilla: si confío en Swift para todo lo demás, ¿por qué no confío en Swift para esto?

---

## Mi Solución 🧩

Me paré a pensar qué necesitaba realmente. Mi portfolio no es una aplicación web. No tiene estado ni interactividad compleja. Es un conjunto de páginas HTML estáticas generadas a partir de Markdown. No necesito React, ni Vue, ni hidratación. Necesito algo que lea Markdown, lo transforme en HTML y lo escriba en disco.

Encontré [Saga](https://github.com/loopwerk/Saga), un generador de sitios estáticos en Swift. Deliberadamente minimalista: lee archivos, aplica transformaciones, escribe HTML. Lo que no incluye, lo decides tú. Además incluye hot reload para desarrollo, algo que no esperaba encontrar en un proyecto tan pequeño. Esa filosofía me convenció más que cualquier feature list.

| Ventajas | Desventajas |
|---|---|
| Todo el stack en Swift — un solo lenguaje, sin cambio de contexto | Ecosistema pequeño — si algo no existe, lo construyes tú |
| HTML verificado por el compilador gracias al DSL tipado | Curva de aprendizaje con la sintaxis del DSL |
| Pipeline de imágenes nativo sin dependencias externas | Pipeline de imágenes solo funciona en macOS |
| Node eliminado del entorno local | Comunidad y documentación limitadas |
| Control total sobre cada dependencia del proyecto | Más trabajo inicial para funcionalidades que en otros frameworks vienen de serie |

### La reflexión de fondo

La decisión no fue técnica. Fue sobre coherencia. Quiero que si alguien visita mi repositorio, vea Swift. No digo que <span class="high">Astro</span> sea malo — es excelente. Pero mi portfolio es mi tarjeta de presentación, y esa tarjeta tiene que hablar de mí.

---

## Mi Resultado 🎯

El sitio que lees ahora mismo está generado con <span class="high">Saga</span>, compilado con Swift, y desplegado sobre <span class="high">Cloudflare Workers</span> sin que Node haya intervenido en mi máquina.

Lo que me sorprendió no fue el resultado técnico. Fue la sensación de coherencia. Abrir mi portfolio y ver que todo, desde la primera línea hasta el último deploy, es Swift me produce una tranquilidad difícil de explicar.

Si eres desarrollador Swift y tu portfolio corre sobre Node, no digo que debas cambiar. Digo que merece la pena preguntarse por qué. Al final, la herramienta que eliges para presentarte dice algo sobre ti. Yo elegí la que me representa.

**Keep coding, keep running** 🏃‍♂️

---
