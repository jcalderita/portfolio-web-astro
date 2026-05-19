---
title: NPX Skills
slug: npx-skills
date: 2026-07-15
description: Por qué no uso skills npx de otros y creo las mías propias directamente con Claude Code: cada flujo es distinto y las skills deben encajar conmigo.
tags: AI, Shell
cover: NPXSkills
coverDescription: Ilustración de dos Jorges de dibujos animados corriendo por Pamplona: a la izquierda, Jorge con camiseta naranja con el texto 'npx skills' cargado con una mochila enorme y todo tipo de equipamiento; a la derecha, Jorge con camiseta naranja con el texto 'skill' corriendo ligero y sonriendo.
publish: false
---
---
## Mi Problema 🤔

Llevo meses usando <span class="high">Claude Code</span> con skills personalizadas. Una skill es un conjunto de instrucciones y scripts que la IA invoca como si fuera un comando propio: pasos claros, scripts deterministas, resultado consistente.

Al asomarme al ecosistema de skills vi que el modelo dominante para compartirlas era <span class="high">npx</span>. Instalas la skill de otra persona, la ejecutas y reutilizas su trabajo. Sobre el papel suena bien, pero al probarlo me di cuenta de dos cosas.

La primera, la dependencia. <span class="high">npx</span> exige Node, y eso significa instalar un runtime entero — con su <span class="high">node_modules</span> y su mantenimiento — solo para lanzar un script. Si Node no forma parte de tu stack, es un coste desproporcionado por una mejora de productividad.

La segunda, y más importante: la skill de otra persona resuelve el flujo de otra persona. Sus convenciones, su tono, su manera de escribir <span class="high">commits</span>, su forma de organizar los pull requests — nada de eso tiene por qué encajar con cómo trabajas tú. O adaptas tu flujo a su skill, o adaptas su skill a tu flujo. En ambos casos pierdes justo el motivo por el que existían las skills.

---
## Mi Solución 🧩

Construir mis propias skills usando el propio <span class="high">Claude Code</span>.

Cada skill nace en una conversación. Le describo a Claude qué pasos repito siempre y qué decisiones tomo en cada uno; a cambio recibo una estructura: un <span class="high">SKILL.md</span> con las instrucciones que la IA debe seguir y una carpeta <span class="high">scripts/</span> con los helpers deterministas. Itero hasta que la skill captura cómo trabajo, y a partir de ese momento queda disponible como un comando más.

Además, como trabajo en macOS, esos scripts son <span class="high">zsh</span> y se apoyan en lo que el sistema ya trae — <span class="high">curl</span>, <span class="high">jq</span>, <span class="high">sed</span>, <span class="high">find</span>, <span class="high">awk</span> — utilidades presentes desde el primer arranque y estables entre versiones. Es el mismo enfoque que desgranaba en [Save Tokens](/es/blog/save-tokens/): el script hace el trabajo determinista con las herramientas del sistema, y la IA se queda solo con la parte conversacional. Cero dependencias instaladas, cero versiones que mantener.

### El flujo de creación

Crear una skill nueva resulta más corto que instalar la de otro:

1. Le cuento a Claude qué hago manualmente y por qué.
2. Claude propone un <span class="high">SKILL.md</span> con triggers, instrucciones y scripts opcionales.
3. Reviso, ajusto las decisiones que solo conozco yo y guardo el directorio.
4. En la siguiente sesión, la skill ya está disponible.

Sin <span class="high">npm install</span>, sin <span class="high">npx</span>, sin <span class="high">node_modules</span>. La skill vive en <span class="high">~/.claude/skills/</span> y queda disponible al instante.

---
## Mi Resultado 🎯

El resultado es un conjunto pequeño de skills que sí encajan conmigo. Lo que cambió en mi flujo:

- **Sin dependencias externas** — ningún runtime de Node, ningún paquete que actualizar, ninguna sorpresa al cambiar de máquina
- **Convenciones propias dentro** — cada skill conoce mi tono, mi estructura y mis reglas; no hay fase de adaptación
- **Iteración instantánea** — si quiero cambiar cómo escribe los commits o cómo traduce los posts, edito el <span class="high">SKILL.md</span> y la siguiente invocación ya usa la versión nueva
- **Cero mantenimiento heredado** — nada que sincronizar con un repositorio ajeno; el código de la skill es mío y solo cambia cuando yo decido

Lo bonito del patrón de <span class="high">SKILL.md</span> + <span class="high">scripts/</span> aplicado a skills propias es la autoría: el script y las instrucciones hablan exactamente mi idioma porque los dos los he escrito yo, con ayuda de Claude. No hay caja negra que descifrar ni convenciones ajenas que tener que aprender.

Construir tu propia skill con Claude no es más trabajo que instalar la de otro: es más rápido, porque te saltas entera la fase de adaptación. Y cada persona escribimos, pensamos y resolvemos distinto, así que lo que es útil para ti probablemente no lo sea para mí. Tu skill ideal no está en <span class="high">npx</span> — la tienes que escribir tú.

**Keep coding, keep running** 🏃‍♂️

---
