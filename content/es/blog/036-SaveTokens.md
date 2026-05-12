---
title: Save Tokens
slug: save-tokens
date: 2026-05-13
description: Cómo reducir tokens en Claude Code moviendo la lógica bash de tus skills a scripts reutilizables que la IA invoca con una sola línea.
tags: AI, Swift
cover: SaveTokens
coverDescription: Ilustración de Jorge programando en su portátil mientras una fila de tokens dorados con la letra T cae desde la pantalla a una hucha cerdito, junto a un cuaderno con la etiqueta Skills /scripts save.sh y una ventana al fondo con corredores en el parque.
publish: true
---
---
## Mi Problema 🤔

Trabajo con <span class="high">Claude Code</span> a diario y empecé a notar un patrón que me llamó la atención: cada vez que una skill o una conversación necesitaba ejecutar algo en el shell, la IA gastaba tokens antes de ejecutar nada. Razonaba sobre qué comando construir, lo redactaba, lo lanzaba, leía el output y luego lo interpretaba para seguir trabajando.

En una operación aislada, ese coste se nota poco. El problema real aparece en cuanto hay **repetición**. Una skill que recorre varios archivos, una conversación que reorganiza directorios, un flujo que necesita hacer la misma operación con argumentos distintos — todo eso multiplica el coste del razonamiento por cada iteración. Cada vuelta del bucle vuelve a construir un comando que, en el fondo, es idéntico al de la vuelta anterior salvo por un parámetro.

Y aquí la clave: ese razonamiento es **trabajo determinista** disfrazado de razonamiento. No estoy pidiéndole a la IA que decida nada — solo que vuelva a escribir un comando que ya escribió antes. Es exactamente el tipo de tarea que un script resuelve mejor que un modelo.

---

## Mi Solución 🧩

La idea es sencilla: si una skill o un flujo necesita ejecutar lógica de shell, esa lógica no debería vivir en la cabeza de la IA — debería vivir en un <span class="high">.sh</span> que la IA invoca con una sola línea.

### El cambio mental

El instinto natural cuando configuras una skill es describir paso a paso lo que la IA tiene que hacer:

> Lista los archivos del directorio, filtra los que terminan en <span class="high">.json</span>, lee cada uno, extrae el campo <span class="high">version</span>, encuentra el mayor, y devuélvelo.

Esa descripción obliga a la IA a construir cada comando, ejecutarlo, interpretar la salida y encadenar el siguiente paso. En su lugar, la instrucción debería ser:

> Ejecuta la script <span class="high">latest-version</span> /ruta.

La diferencia es que todo el razonamiento sobre **cómo** se hace la operación deja de ocurrir en cada invocación. Ocurre una sola vez, cuando escribes el script. A partir de ahí, la IA solo necesita saber **qué** ejecutar y **qué formato** recibir.

### Por qué los bucles son el caso crítico

El ahorro se nota incluso en operaciones puntuales, pero se vuelve **enorme** cuando la skill itera. Sin script, cada vuelta del bucle paga el coste de razonar y construir el comando. Con script, la IA lanza una sola invocación y recibe el agregado completo.

La regla práctica que aplico: si la operación se puede agregar en un único paso de shell, debería hacerlo el script — no la IA iterando externamente.

### Estructura que uso en mis skills

Cada skill mía sigue la misma forma: un <span class="high">SKILL.md</span> corto que describe el contrato, y una carpeta <span class="high">scripts/</span> con la lógica empaquetada.

```
~/.claude/skills/
└── mi-skill/
    ├── SKILL.md          ← instrucciones para la IA (qué ejecutar, qué esperar)
    └── scripts/
        ├── operacion-a.zsh
        └── operacion-b.zsh
```

Cada vez que la skill necesita una capacidad nueva, añado un script en lugar de añadir instrucciones bash inline. La skill gana funcionalidad sin engordar el contexto que la IA tiene que procesar en cada invocación.

> Uso <span class="high">.zsh</span> porque trabajo en macOS, donde es el shell por defecto desde Catalina y puedo aprovechar features que bash no tiene. El patrón funciona exactamente igual con <span class="high">.sh</span> y bash. Elige la que case con tu entorno.

Y un detalle importante: los scripts los escribo con ayuda de la propia IA, una sola vez. Ese razonamiento — el de diseñar el comando correcto, manejar los edge cases, devolver el JSON adecuado — ocurre durante la creación del script. Después, ese trabajo queda **cristalizado** en el archivo y no se vuelve a pagar.

---

## Mi Resultado 🎯

El cambio es directamente observable en cuanto separas la lógica determinista del razonamiento. La IA pasa de construir comandos a consumirlos. De interpretar salidas variables a leer JSON estructurado. De iterar externamente a recibir el agregado completo en una llamada.

Los beneficios concretos que estoy viendo:

- **Menos tokens por invocación** — el razonamiento sobre cómo hacer la operación ocurre una sola vez, al escribir el script, no cada vez que la skill se ejecuta
- **Consistencia** — el script siempre devuelve el mismo formato; la IA no interpreta salidas variables en cada ejecución
- **Mantenibilidad** — cuando cambia la lógica, edito el script en un sitio; el <span class="high">SKILL.md</span> no se toca
- **Escalabilidad en bucles** — el script agrega antes de devolver; una llamada sustituye a N iteraciones
- **Skills más simples** — el <span class="high">SKILL.md</span> describe **qué** hacer, no **cómo**; la complejidad operacional vive en los scripts

El patrón se aplica a cualquier skill o flujo que tenga que operar sobre el sistema de archivos, procesar texto estructurado o ejecutar lógica repetitiva. Si te encuentras describiendo en el <span class="high">SKILL.md</span> una secuencia de comandos bash que la IA debería construir y ejecutar, esa secuencia probablemente debería ser un script.

Como exploré en el artículo sobre [Claude Code](/es/blog/claude-code/), la clave no es darle más capacidad de razonamiento a la IA para que resuelva más cosas — es estructurar el trabajo para que **solo razone donde aporta valor**. Lo determinista lo resuelve un script. Lo creativo y contextual lo resuelve la IA. Cada uno en su sitio.

**Keep coding, keep running** 🏃‍♂️

---
