---
title: AI Status Bar
slug: ai-status-bar
date: 2026-06-17
description: Cómo monté una status bar personalizada en Claude Code para tener siempre visible el contexto, tokens y límites de uso sin gastar ni un token extra.
tags: AI, Shell
cover: AIStatusBar
coverDescription: Ilustración de Jorge corriendo por un camino de tierra junto a un río con una ciudad medieval al fondo, mientras en la parte inferior aparece una barra de estado con datos: modelo, barra de progreso, distancia 150k/1000k, velocidad 15km/h, energía 67%, esfuerzo Medium y ubicación Pamplona.
publish: false
---
---
## Mi Problema 🤔

Cuando trabajo con <span class="high">Claude Code</span> en la shell, hay información que necesito consultar constantemente: cuánto contexto llevo consumido, en qué porcentaje estoy de los límites de uso, qué rama de git tengo activa, con qué modelo estoy trabajando. Información que no cambia cada segundo, pero que sí necesito tener a mano para tomar decisiones.

El problema es que obtenerla tiene fricción. Puedo pedírsela a la IA directamente, pero eso implica gastar tokens en una pregunta cuya respuesta es completamente determinista. También puedo abrir otra sesión de terminal, o lanzar un comando en background para consultarlo cada cierto tiempo. Pero todas esas opciones interrumpen el flujo de trabajo.

Lo que en realidad necesitaba era algo más simple: **una línea siempre visible** que me diera esa información sin que yo tuviera que pedirla, sin consumir contexto, y sin interrumpir lo que estaba haciendo.

---
## Mi Solución 🧩

<span class="high">Claude Code</span> tiene una funcionalidad llamada <span class="high">statusLine</span> que permite definir un comando externo que se ejecuta cuando hay cambios en la sesión: tras cada respuesta del asistente, al terminar un <span class="high">/compact</span>, al cambiar el modo de permisos o al togglear el modo vim. La herramienta llama al script, le pasa información del estado actual de la sesión como JSON por <span class="high">stdin</span>, y muestra lo que el script devuelva por <span class="high">stdout</span> en la barra inferior de la interfaz.

La configuración vive en <span class="high">settings.json</span> y es de una sola línea:

```json
{
  "statusLine": {
    "type": "command",
    "command": "zsh statusline-command.zsh"
  }
}
```

El JSON que recibe el script por <span class="high">stdin</span> contiene toda la información relevante de la sesión: modelo activo, directorio de trabajo, porcentaje de uso del contexto, tamaño total de la ventana, y límites de uso de los periodos de 5 horas y 7 días, cada uno con su porcentaje y timestamp de reset.

El script se ejecuta en cada uno de esos eventos, con un debounce de 300 ms que agrupa cambios rápidos. Y aquí hay un detalle importante: si llega un nuevo evento mientras el script todavía corre, <span class="high">Claude Code</span> cancela la ejecución en curso y lanza una nueva — un script lento se interrumpiría a sí mismo. Por eso lo escribí buscando que fuera barato: <span class="high">builtins</span> de zsh en lugar de subprocesos, una única llamada a <span class="high">jq</span> en lugar de nueve, y helpers que devuelven el resultado en <span class="high">REPLY</span> para evitar capturarlo con <span class="high">$(...)</span> en el camino caliente.

Lo primero es cargar el módulo de fecha de zsh y extraer los nueve campos del JSON en una sola pasada. La salida de <span class="high">jq</span> es una lista ordenada de valores que voy capturando posicionalmente con <span class="high">read</span>:

```bash
#!/bin/zsh

zmodload zsh/datetime

MAGENTA=$'\e[35m'; CYAN=$'\e[36m'; YELLOW=$'\e[33m'; GREEN=$'\e[32m'
BLUE=$'\e[34m';    RED=$'\e[31m';  DIM=$'\e[2m';     RESET=$'\e[0m'

input=$(</dev/stdin)
{
    read -r model_display_name
    read -r current_dir
    read -r used_percentage
    read -r context_window_size
    read -r five_hour_pct
    read -r five_hour_reset
    read -r seven_day_pct
    read -r seven_day_reset
    read -r effort_level
} < <(jq -r '
    .model.display_name // "",
    .workspace.current_dir // "",
    (.context_window.used_percentage // 0),
    (.context_window.context_window_size // 0),
    (.rate_limits.five_hour.used_percentage as $p | if $p then ($p | floor) else "" end),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage as $p | if $p then ($p | floor) else "" end),
    (.rate_limits.seven_day.resets_at // ""),
    ((.effortLevel // .effort) as $e | if ($e | type) == "object" then $e.level else ($e // "") end)
' <<<"$input")
```

Con eso tengo las nueve variables pobladas con un único <span class="high">fork</span> de <span class="high">jq</span>. Si el nivel de esfuerzo no venía en el JSON, lo busco primero en el <span class="high">settings.json</span> del proyecto y, si tampoco está, en el del usuario. Después calculo los derivados y construyo la barra de progreso con el left-padding nativo de zsh:

```bash
extract_effort='(.effortLevel // .effort // empty) | if type == "object" then .level else . end // empty'
[[ -z "$effort_level" && -f "$current_dir/.claude/settings.json" ]] && \
    effort_level=$(jq -r "$extract_effort" "$current_dir/.claude/settings.json" 2>/dev/null)
[[ -z "$effort_level" && -f "$HOME/.claude/settings.json" ]] && \
    effort_level=$(jq -r "$extract_effort" "$HOME/.claude/settings.json" 2>/dev/null)

current_tokens=$(( used_percentage * context_window_size / 100 ))
current_k=$(( current_tokens / 1000 ))
max_k=$(( context_window_size / 1000 ))
project_name=${current_dir:t}
git_branch=$(git -C "$current_dir" -c core.fileMode=false rev-parse --abbrev-ref HEAD 2>/dev/null)

bar_width=20
filled=$(( used_percentage * bar_width / 100 ))
empty=$(( bar_width - filled ))
progress_bar="${(l:filled::=:):-}${(l:empty:: :):-}"
```

Detalles que evitan procesos hijo: <span class="high">${current_dir:t}</span> es el equivalente nativo de <span class="high">basename</span>, y <span class="high">${(l:filled::=:):-}</span> construye una cadena rellenada por la izquierda con caracteres <span class="high">=</span> sin bucles ni concatenación.

Luego vienen los umbrales de color. En la primera versión tenía dos funciones casi idénticas, una para porcentajes y otra para tokens absolutos. Las unifiqué en una sola que recibe el valor y los dos umbrales como argumentos, y aproveché para que devolviera el resultado en <span class="high">REPLY</span> en lugar de imprimirlo:

```bash
threshold_color() {
    if (( $1 >= $2 )); then REPLY=$RED
    elif (( $1 >= $3 )); then REPLY=$YELLOW
    else REPLY=$GREEN
    fi
}

format_reset() {
    REPLY=
    [[ -z "$1" ]] && return
    if (( $1 - EPOCHSECONDS < 86400 )); then
        strftime -s REPLY '%H:%M' $1
    else
        strftime -s REPLY '%a %H:%M' $1
    fi
}

build_rate_part() {
    local part
    if [[ -n "$2" ]]; then
        threshold_color $2 80 50
        part="${MAGENTA}$1:${RESET} ${REPLY}$2%${RESET}"
    else
        part="${MAGENTA}$1:${RESET} ${DIM}-${RESET}"
    fi
    format_reset $3
    [[ -n "$REPLY" ]] && part+=" ${DIM}($REPLY)${RESET}"
    REPLY=$part
}
```

Aplicando esos umbrales:

- <span class="high-green">Contexto verde</span> por debajo de 100k tokens — zona segura
- <span class="high-yellow">Contexto amarillo</span> entre 100k y 150k tokens — señal para considerar un <span class="high">/clear</span>
- <span class="high-red">Contexto rojo</span> por encima de 150k tokens — hay que actuar

Lo mismo para los límites de uso de 5 horas y 7 días: verde por debajo del 50%, amarillo entre 50% y 79%, rojo a partir del 80%.

Las tres funciones devuelven en <span class="high">REPLY</span>: así me ahorro el <span class="high">$(...)</span> y el subshell asociado en cada llamada, lo que reduce el riesgo de que una invocación se cancele a sí misma cuando llegan eventos seguidos. <span class="high">format_reset</span> tira del builtin <span class="high">strftime</span> y de <span class="high">$EPOCHSECONDS</span> del módulo <span class="high">zsh/datetime</span>, así que tampoco arranca un proceso <span class="high">date</span> cada vez.

Finalmente la composición. La primera línea siempre lleva los mismos elementos: modelo, barra de progreso, porcentaje de contexto, tokens actuales sobre el máximo y nombre del proyecto. La segunda se construye solo con las partes que tengan datos — si no hay límite de 5h, no hay nivel de esfuerzo configurado o no hay rama de git, simplemente no aparecen y los separadores se ajustan:

```bash
threshold_color $current_tokens 150000 100000
context_color=$REPLY
status_line="${MAGENTA}${model_display_name}${RESET} ${CYAN}[${RESET}${progress_bar}${CYAN}]${RESET}"
status_line+=" ${context_color}${used_percentage}%${RESET} |"
status_line+=" ${context_color}${current_k}k/${max_k}k${RESET} |"
status_line+=" ${BLUE}${project_name}${RESET}"

typeset -a parts
build_rate_part 5h "$five_hour_pct" "$five_hour_reset"; parts+=("$REPLY")
build_rate_part 7d "$seven_day_pct" "$seven_day_reset"; parts+=("$REPLY")
[[ -n "$effort_level" ]] && parts+=("${MAGENTA}effort:${RESET} ${YELLOW}${effort_level}${RESET}")
[[ -n "$git_branch" ]]   && parts+=("${GREEN}${git_branch}${RESET}")

sep=" ${CYAN}|${RESET} "
(( ${#parts} )) && status_line+=$'\n'"${(pj.$sep.)parts}"

print -rn -- "$status_line"
```

La expansión <span class="high">${(pj.$sep.)parts}</span> une los elementos del array <span class="high">parts</span> con el separador <span class="high">sep</span> — un join nativo de zsh, sin bucles ni hacks con <span class="high">IFS</span>.

Un detalle importante sobre la hora de reset: el script la formatea como <span class="high">HH:MM</span> si el reset ocurre dentro de las próximas 24 horas, y como <span class="high">Día HH:MM</span> si es más adelante. Así sé de un vistazo cuándo se libera el límite sin tener que hacer cálculos.

---
## Mi Resultado 🎯

El resultado es exactamente lo que buscaba: información siempre presente sin interrumpir nada ni gastar un solo token en obtenerla.

Lo que veo de un vistazo en cualquier momento:

- **Modelo activo** — qué versión de Claude está usando la sesión actual
- **Barra de contexto** — representación visual de cuánto contexto he consumido
- **Tokens actuales sobre el máximo** — por ejemplo, <span class="high">87k/200k</span>, que me dice exactamente en qué punto estoy de la ventana
- **Uso 5h y 7d con hora de reset** — para saber si me acerco a un límite de tasa y cuándo se libera
- **Nivel de esfuerzo** — confirmación visual de que la sesión tiene el nivel correcto configurado
- **Rama de git** — en qué rama estoy trabajando en el proyecto activo

Lo que más valoro es que esta información **no cuesta nada**. No es una pregunta a la IA, no es un comando que tengo que recordar lanzar, no es una ventana adicional que abrir. Es texto que aparece, se actualiza solo, y desaparece del foco en cuanto me pongo a trabajar.

El enfoque también encaja bien con lo que exploraba en [Back to Shell](/es/blog/back-to-shell/): la shell como espacio de composición, donde los scripts hacen el trabajo determinista y la IA hace el trabajo contextual. La status bar es el ejemplo más visible de esa separación — toda la lógica de formateo y colores vive en el script, y la IA no sabe que existe.

Si trabajas con <span class="high">Claude Code</span> y tienes información que consultas repetidamente, la <span class="high">statusLine</span> es la forma más eficiente de tenerla siempre a mano. El script puede mostrar lo que necesites: uso de APIs externas, estado de un servicio, variables de entorno, lo que quieras exponer desde un comando de shell.

**Keep coding, keep running** 🏃‍♂️

---
