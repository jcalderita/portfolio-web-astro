---
title: Degraded Context
slug: degraded-context
date: 2026-07-29
description: Por qué el contexto de la IA se degrada con el uso y cómo mantener límites claros que preservan la calidad de respuesta y la velocidad del modelo.
tags: AI, Shell
cover: DegradedContext
coverDescription: Ilustración en tres paneles de Jorge corriendo: en el primero avanza ágil y sonriente junto a una piedra con "100k"; en el segundo corre agotado bajo un atardecer hacia "150k"; en el tercero yace arrastrado por el suelo en la oscuridad frente a "150k+".
publish: false
---
---
## Mi Problema 🤔

Trabajando con <span class="high">Claude Code</span> de forma intensiva, noté que las respuestas al final de una sesión larga eran peores que las del principio. El modelo se equivocaba más, repetía instrucciones ya dadas, o generaba código que ignoraba decisiones de varios mensajes atrás.

Pensé que era mi prompt, luego variabilidad del modelo. Pero comparando sesiones cortas contra largas sobre la misma tarea, el patrón era demasiado consistente: **a mayor contexto acumulado, peor calidad de respuesta**.

El problema tiene mecánica. Los modelos trabajan con una ventana de contexto finita. Cuando se llena, procesan las partes antiguas con menor atención por la naturaleza del mecanismo de <span class="high">attention</span>. Lo que para mí era una conversación coherente, para el modelo era una secuencia larga en la que las instrucciones del principio competían con el código del turno anterior.

La degradación no es binaria: respuestas más genéricas, menos adherencia a las convenciones, más tendencia a inventar. Y lo más traicionero es que el modelo nunca te avisa: sigue respondiendo con la misma confianza, aunque la calidad haya bajado.

---
## Mi Solución 🧩

La solución tiene dos partes: **medir el contexto en tiempo real** y **establecer límites que disparen una acción concreta** antes de que la degradación afecte al trabajo.

### Parte 1: visibilidad en tiempo real

Monté la <span class="high">statusLine</span> de <span class="high">Claude Code</span> para tener siempre visible el porcentaje de contexto consumido. Lo explico en detalle en [AI Status Bar](/es/blog/ai-status-bar/). La idea es que el uso de contexto sea información pasiva, siempre presente, sin costar un token.

### Parte 2: cuándo usar /compact y cuándo /clear

Este es el punto que más me costó interiorizar. Tenía la tentación de usar siempre <span class="high">/compact</span> porque preserva el hilo. Pero hay dos situaciones distintas:

**Usa <span class="high">/compact</span> cuando:**
- La tarea sigue siendo la misma y el contexto es relevante
- Estás en medio de una refactorización y los archivos editados importan para los siguientes turnos
- El contexto es denso en decisiones, no en output de comandos

**Usa <span class="high">/clear</span> cuando:**
- Terminaste una subtarea y vas a empezar algo diferente
- El contexto está lleno de output que ya no necesitas (builds, tests, logs)
- El modelo está "confundido" por instrucciones contradictorias

La clave: <span class="high">/compact</span> resume pero no limpia. Si el contexto está lleno de ruido, el resumen también. <span class="high">/clear</span> es el reinicio real, y tiene un coste: pierdes el hilo.

### Parte 3: el CLAUDE.md como instrucciones de proyecto

El <span class="high">CLAUDE.md</span> es un archivo versionado en el repositorio que el modelo carga al arrancar cualquier sesión. No es memoria: son instrucciones de proyecto, las mismas para cualquiera que clone el repo.

Lo que incluyo:

- Convenciones de código del proyecto
- Decisiones de arquitectura que no se deducen leyendo el código
- Restricciones técnicas (qué dependencias no se pueden añadir)
- Comandos de build, dev y release con sus flags

Lo que no incluyo:

- Estado actual de la tarea
- Código de módulos que el modelo puede leer
- Listas de archivos que puede explorar por sí mismo
- Información personal o preferencias

El <span class="high">CLAUDE.md</span> no es un dump del proyecto: es lo que el modelo no puede inferir del código y necesita saber desde el primer turno.

### Parte 4: el sistema de memoria automática

El <span class="high">CLAUDE.md</span> habla del proyecto; la memoria habla de mí. Vive a nivel de usuario, fuera del repositorio, en <span class="high">~/.claude/projects/</span>.

La memoria la gestiona el propio modelo: detecta hechos que merece la pena recordar entre sesiones y los guarda en Markdown indexados por un <span class="high">MEMORY.md</span>. Cada entrada se clasifica:

- <span class="high">user</span> — quién soy, qué hago, cómo prefiero colaborar
- <span class="high">feedback</span> — correcciones y aprobaciones a recordar
- <span class="high">project</span> — estado del trabajo, decisiones, deadlines
- <span class="high">reference</span> — punteros a recursos externos

La memoria no duplica lo que ya está en el código ni en el <span class="high">CLAUDE.md</span>: es para el contexto humano del proyecto.

La combinación de las dos capas es lo que hace barato un <span class="high">/clear</span>. El modelo lee el <span class="high">CLAUDE.md</span> y obtiene las reglas, consulta su memoria para recuperar quién soy y en qué estábamos. Entre las dos absorben casi todo el coste de reinicialización.

---
## Mi Resultado 🎯

La calidad de las sesiones largas mejoró visiblemente. No porque el modelo haya cambiado, sino porque dejé de acumular contexto de forma pasiva y empecé a gestionarlo de forma activa.

Lo que cambió en mi flujo:

- **Nunca supero el 80% de contexto** sin una decisión consciente
- **Uso <span class="high">/compact</span> preventivo** alrededor del 60–70% cuando sé que la tarea va a ser larga
- **Arranco sesiones nuevas con confianza** porque <span class="high">CLAUDE.md</span> y memoria absorben el coste
- **Reconozco los síntomas de degradación** antes de que afecten al output: respuestas más largas, código con nombres genéricos, sugerencias que ya rechacé

El cambio de mentalidad fue dejar de ver el contexto como "la memoria del modelo" y empezar a verlo como **el espacio de trabajo de una sesión**. Un espacio que se llena, que tiene un coste cuando está lleno, y que hay que gestionar como cualquier otro recurso.

Si trabajas con modelos de lenguaje de forma intensiva, empieza por la visibilidad. Una vez que ves el número, desarrollas intuición sobre cuándo actuar. Y esa intuición, con el tiempo, se convierte en hábito.

**Keep coding, keep running** 🏃‍♂️

---
