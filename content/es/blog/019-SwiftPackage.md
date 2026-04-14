---
title: Swift Package
slug: swift-package
date: 2025-12-24
description: Guía completa sobre los comandos de limpieza de Swift Package Manager: clean, reset, purge-cache y cuándo usar cada uno para resolver problemas de dependencias.
tags: Swift, Vapor
cover: SwiftPackage
coverDescription: Jorge frente a su Mac, rodeado de cajas marcadas como clean, reset y purge, junto a una máquina retro con un gran botón rm, simbolizando el caos de limpiar dependencias en Swift Package Manager.
publish: true
---
---
## El dilema de las dependencias rotas

Cuando trabajas con **Swift Package Manager (SPM)**, eventualmente te encontrarás con un error de compilación que parece no tener sentido. Has intentado compilar varias veces, has reiniciado Xcode, pero el error persiste. La solución muchas veces está en **limpiar correctamente las cachés y artefactos** de SPM, pero ¿qué comando usar?

Existen múltiples formas de "limpiar" en SPM, cada una con un propósito específico. Usar el comando equivocado puede no resolver tu problema o, peor aún, forzarte a descargar gigabytes de dependencias nuevamente.

---

## Los cuatro caminos para limpiar

SPM ofrece tres comandos oficiales más una alternativa manual. Cada uno afecta diferentes partes del sistema:

| Comando | Elimina .build local | Elimina Package.resolved | Elimina caché global |
|---------|---------------------|-------------------------|---------------------|
| <span class="high">swift package clean</span> | ❌ (solo binarios compilados) | ❌ | ❌ |
| <span class="high">swift package reset</span> | ✅ (completo) | ✅ | ❌ |
| <span class="high">swift package purge-cache</span> | ❌ | ❌ | ✅ |
| <span class="high">rm -rf .build</span> | ✅ (completo) | ❌ | ❌ |

### Swift package clean

```bash
swift package clean
```

**Qué hace:**
Elimina únicamente los **binarios compilados finales** dentro de la carpeta <span class="high">.build</span>, pero **mantiene dependencias descargadas y archivos intermedios**.

**Cuándo usarlo:**
- Después de cambiar configuraciones de compilación
- Para forzar una recompilación completa sin re-descargar dependencias
- Cuando los binarios están corruptos pero las fuentes están bien

> 💡 No descarga dependencias nuevamente ni resuelve problemas de caché de paquetes.

### Swift package reset

```bash
swift package reset
```

**Qué hace:**
Elimina **completamente** la carpeta <span class="high">.build</span> (incluyendo dependencias descargadas) y el archivo <span class="high">Package.resolved</span>.

**Cuándo usarlo:**
- Cuando hay conflictos en las versiones de dependencias
- Después de cambios importantes en <span class="high">Package.swift</span>
- Para resolver errores de "dependencia no encontrada"
- Cuando <span class="high">Package.resolved</span> está desactualizado o corrupto

> ⚠️ La próxima compilación descargará y resolverá todas las dependencias desde cero. Esto puede tardar varios minutos dependiendo de la cantidad de paquetes.

### Swift package purge-cache

```bash
swift package purge-cache
```

💡 Disponible desde Swift 5.7 en adelante.

**Qué hace:**
Elimina la **caché global de paquetes** ubicada en:
```
~/Library/Caches/org.swift.swiftpm/
```

Esta caché contiene repositorios clonados y artefactos binarios compartidos entre todos tus proyectos.

**Cuándo usarlo:**
- Cuando múltiples proyectos tienen el mismo problema
- Después de actualizar Xcode o herramientas de Swift
- Para liberar espacio en disco (puede ocupar varios GB)
- Cuando sospechas que la caché global está corrupta

> ⚠️ Todos tus proyectos tendrán que re-descargar dependencias comunes.

### rm -rf .build

```bash
rm -rf .build
```

**Qué hace:**
Elimina manualmente la carpeta <span class="high">.build</span> completa, similar a <span class="high">reset</span> pero **sin tocar** <span class="high">Package.resolved</span>. Es menos agresivo que reset porque no re-resuelve dependencias.

**Cuándo usarlo:**
- Para limpiar artefactos de compilación manteniendo la resolución de versiones
- En scripts de CI/CD donde quieres control total
- Cuando <span class="high">swift package reset</span> no está disponible

> 💡 Preserva <span class="high">Package.resolved</span>, lo que significa que las versiones de dependencias no se re-resolverán.

---

## Estrategia de resolución de problemas

**Nivel 1: Limpieza ligera**
```bash
swift package clean
```
> 💡 Prueba primero lo menos invasivo. Resuelve el 30% de los problemas.

**Nivel 2: Reset completo del proyecto**
```bash
swift package reset
```
> 💡 Si el nivel 1 falla. Resuelve el 60% de los problemas restantes.

**Nivel 3: Purgar caché global**
```bash
swift package purge-cache
swift package reset
```
> 💡 Para problemas persistentes o que afectan múltiples proyectos.

**Nivel 4: Nuclear**
```bash
rm -rf .build
rm Package.resolved
swift package purge-cache
```
> 💡 Última opción. Borrón y cuenta nueva total.

---

## Casos de uso reales

### Escenario 1: Error después de actualizar Xcode
```bash
swift package purge-cache
swift package reset
```

> 💡 Las herramientas de compilación cambiaron y la caché puede tener artefactos incompatibles.

### Escenario 2: Conflicto de versiones de dependencias
```bash
swift package reset
```

> 💡 Necesitas re-resolver todas las dependencias con las nuevas restricciones.

### Escenario 3: Espacio en disco lleno
```bash
swift package purge-cache
```

> 💡 La caché global puede crecer hasta varios GB sin que lo notes.

### Escenario 4: CI/CD builds
```bash
rm -rf .build
```

> 💡 En entornos de integración continua, quieres builds limpios pero reproducibles con `Package.resolved` versionado.

---

## Entendiendo los componentes

### .build (local)
- Artefactos de compilación del proyecto actual
- Dependencias descargadas específicas del proyecto
- Archivos intermedios de compilación

### Package.resolved
- "Lockfile" que fija versiones exactas de dependencias
- Garantiza builds reproducibles
- Debe versionarse en Git para proyectos compartidos

### Caché global
- Compartida entre todos tus proyectos Swift
- Contiene clones de repositorios de dependencias
- Artefactos binarios pre-compilados
- Puede alcanzar varios GB con el tiempo

---

## Mejores prácticas

✅ **Versiona** <span class="high">Package.resolved</span> en Git para garantizar que todo el equipo use las mismas versiones<br />
✅ **Usa** <span class="high">reset</span> **después de cambios en Package.swift** para asegurar una resolución limpia<br />
✅ **Purga la caché periódicamente** si trabajas con muchos proyectos<br />
✅ **En CI/CD, mantén** <span class="high">Package.resolved</span> pero elimina <span class="high">.build</span> para builds limpios<br />
❌ **No ignores** <span class="high">.build</span> **en .gitignore** - ya está ignorado por defecto<br />
❌ **No borres** <span class="high">Package.resolved</span> a menos que realmente necesites re-resolver versiones

---

## Conclusión

Entender la diferencia entre estos comandos te ahorra tiempo y frustración. No todos los problemas de compilación necesitan una limpieza nuclear:

- <span class="high">clean</span> → Solo binarios compilados
- <span class="high">reset</span> → Proyecto completo + Package.resolved
- <span class="high">purge-cache</span> → Caché global compartida
- <span class="high">rm -rf</span> → Control manual quirúrgico

La próxima vez que SPM te muestre un error extraño, ya sabes exactamente qué herramienta usar.


**Keep coding, keep running** 🏃‍♂️

---
