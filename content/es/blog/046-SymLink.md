---
title: SymLink
slug: symlink
date: 2026-07-22
description: Cómo uso symlinks para compartir configuración de Claude entre equipos y máquinas sin exponer archivos privados en repositorios públicos.
tags: AI, Shell
cover: SymLink
coverDescription: Jorge de dibujos animados con camiseta naranja corriendo por delante del resto de atletas en una pista de atletismo, con un arco de START al fondo y la ciudad en el horizonte, mientras una flecha dorada señala su ventaja.
publish: false
---
---
## Mi Problema 🤔

Trabajo con <span class="high">Claude Code</span> desde varios sitios: en casa, de viaje, y a veces colaborando con otros compañeros en proyectos compartidos. Con el tiempo fui acumulando rules, skills y configuración personalizada que quería tener disponible en todas las máquinas y poder compartir con mi equipo sin fricciones.

El problema llegó cuando intenté poner esos archivos en un repositorio. Algunos contienen instrucciones internas, convenciones del equipo o rutas absolutas que no deberían ser públicas. Otros son perfectamente compartibles, pero mezclados con los privados era difícil decidir qué publicar y qué no.

La solución obvia de tener un repositorio privado por equipo rompía otro requisito: quería que mis skills y rules personales también estuvieran en todos los sitios, sin tener que mantener dos repositorios y sincronizarlos manualmente cada vez que cambiaba algo.

---
## Mi Solución 🧩

La solución que encontré fue combinar <span class="high">symlinks</span> con repositorios de Git separados: uno público para lo compartible y otro privado para lo que no puede salir. Cada repositorio vive en su propia carpeta, y <span class="high">~/.claude/</span> es la suma de ambos a través de enlaces simbólicos.

### La estructura base

Tengo dos repositorios en <span class="high">~/Developer/</span>:

```
~/Developer/
├── dotfiles/           ← repositorio público en GitHub
│   └── claude/
│       ├── skills/     ← skills que puedo compartir con cualquiera
│       └── shared/     ← convenciones compartidas entre proyectos
│
└── dotfiles-private/   ← repositorio privado (equipo o personal)
    └── claude/
        ├── rules/      ← reglas internas del equipo
        └── projects/   ← contexto específico de proyectos
```

Y <span class="high">~/.claude/</span> apunta a los contenidos de ambos mediante symlinks:

```
~/.claude/
├── skills/     → ~/Developer/dotfiles/claude/skills/
├── shared/     → ~/Developer/dotfiles/claude/shared/
├── rules/      → ~/Developer/dotfiles-private/claude/rules/
└── projects/   → ~/Developer/dotfiles-private/claude/projects/
```

### Una skill que automatiza los symlinks

Crear los symlinks a mano funciona, pero en cuanto añado un proyecto nuevo o configuro una máquina, el proceso se vuelve repetitivo. La parte interesante es que se puede automatizar con una skill de <span class="high">Claude Code</span> apoyada en un script <span class="high">zsh</span>, usando una convención muy simple para los proyectos privados.

La convención es la siguiente: dentro de <span class="high">dotfiles-private/</span> creo una carpeta con el mismo nombre que el proyecto público al que pertenece. Si tengo <span class="high">~/Developer/portfolio/</span> como repositorio público, en el privado existe <span class="high">dotfiles-private/portfolio/</span> con las rules y el contexto que no puede salir. Esa coincidencia de nombres es lo que permite al script enlazar todo sin que yo tenga que mantener una lista de proyectos.

El script vive en la skill y recorre las carpetas del repositorio privado. Por cada una que coincida con un proyecto en <span class="high">~/Developer/</span>, monta el symlink dentro de <span class="high">~/.claude/projects/</span>:

```bash
#!/bin/zsh
setopt err_exit no_unset pipe_fail

DOTFILES="$HOME/Developer/dotfiles"
PRIVATE="$HOME/Developer/dotfiles-private"
DEV="$HOME/Developer"
CLAUDE="$HOME/.claude"

mkdir -p "$CLAUDE/projects"

ln -sf "$DOTFILES/claude/skills" "$CLAUDE/skills"
ln -sf "$DOTFILES/claude/shared" "$CLAUDE/shared"
ln -sf "$PRIVATE/claude/rules"   "$CLAUDE/rules"

for dir in $PRIVATE/*/(N); do
  name=${dir:h:t}
  [[ $name == claude ]] && continue
  [[ -d $DEV/$name ]] || continue
  ln -sf "$dir" "$CLAUDE/projects/$name"
  print "Conectado: $name"
done
```

Encima del script monto la skill en <span class="high">dotfiles/claude/skills/sync-symlinks/</span> con su <span class="high">SKILL.md</span> describiendo cuándo invocarla. Cuando le digo a Claude algo como "sincroniza mis symlinks" o "monta la configuración en esta máquina", la skill se activa, ejecuta el script y deja todo conectado sin que tenga que recordar comandos ni rutas.

El flujo para añadir un proyecto privado nuevo se reduce a un paso: crear la carpeta dentro de <span class="high">dotfiles-private/</span> con el nombre del proyecto público y volver a invocar la skill. El script detecta la coincidencia y crea el symlink al instante, sin tocar ni el bootstrap ni la propia skill.

### Por qué no commitar directamente en ~/.claude

La alternativa sería convertir <span class="high">~/.claude/</span> directamente en un repositorio de Git. He probado ese enfoque y tiene un problema práctico: mezcla en el mismo repositorio cosas que tienen distintos niveles de privacidad y distintos propietarios. Si quiero compartir solo las skills con un compañero, no puedo hacerlo sin darle acceso a todo lo demás.

Con symlinks, cada repositorio tiene su propio ciclo de vida. Puedo hacer pública la carpeta de skills sin tocar las rules del equipo. Puedo actualizar las convenciones privadas sin hacer un commit en el repositorio público. Y puedo añadir un tercer repositorio en el futuro sin cambiar la estructura visible en <span class="high">~/.claude/</span>.

---
## Mi Resultado 🎯

El resultado es que tengo la misma configuración de <span class="high">Claude Code</span> disponible en todas mis máquinas, con una sola operación de bootstrap, sin exponer nada que no deba ser público.

Lo que cambió en mi flujo:

- **Configuración consistente** — cualquier máquina nueva queda configurada en minutos, con exactamente las mismas skills y rules que el resto
- **Privacidad sin fricción** — lo público y lo privado viven en repositorios separados; nunca tengo que pensar qué puedo commitar y qué no
- **Colaboración real** — comparto el repositorio público con cualquier compañero; ellos crean su propio repositorio privado con sus reglas específicas y conectan ambos con los mismos symlinks
- **Un solo punto de actualización** — edito una skill en <span class="high">dotfiles</span>, hago push, y cualquier máquina que haga pull tiene la versión nueva al instante; no hay copia que sincronizar manualmente

Lo que me pareció especialmente útil fue la separación por equipos. Puedo tener un repositorio privado por equipo de software, cada uno con sus reglas y contexto de proyecto, y todos apuntando a las mismas skills públicas. El symlink hace que para <span class="high">Claude Code</span> todo parezca una sola carpeta <span class="high">~/.claude/</span> unificada.

Como complemento a este flujo, el artículo sobre [Save Tokens](/es/blog/save-tokens/) explica cómo estructurar las skills para que la lógica determinista viva en scripts y no en las instrucciones que la IA procesa en cada invocación.

**Keep coding, keep running** 🏃‍♂️

---
