---
title: UUID v7
slug: uuid-v7
date: 2026-05-06
description: Swift usa UUID v4 por defecto, pero con una pequeña extensión puedes aprovechar todas las ventajas de UUID v7 sin sacrificar rendimiento.
tags: Swift, Server, DataBase
cover: UUID-V7
coverDescription: Ilustración comparativa estilo cómic: a la izquierda Jorge con UUID-V4 atrapado en una pista enredada y caótica, a la derecha Jorge con UUID-V7 avanzando por una pista de atletismo ordenada y recta.
publish: false
---
---
## Mi Problema 🤔

En mi proyecto uso <span class="high">PostgreSQL</span> como base de datos y <span class="high">UUID</span> como identificador en todos mis modelos. Es el estándar habitual: universal, sin colisiones, seguro. Pero me encontré con un problema cuando mis tablas empezaron a crecer.

<span class="high">UUID v4</span> es completamente aleatorio. Esto significa que cada nuevo registro se inserta en una posición aleatoria dentro del índice <span class="high">B-Tree</span>. El índice se fragmenta, las páginas se dividen, y el rendimiento de escritura degrada progresivamente. En tablas con millones de registros, el impacto es real.

La solución existe desde hace tiempo en bases de datos como <span class="high">MongoDB</span> con <span class="high">ObjectID</span> o en sistemas que usan <span class="high">ULID</span>: embeber el timestamp en el identificador para que los registros nuevos se inserten siempre al final del índice.

<span class="high">UUID v7</span>, definido en el <span class="high">RFC 9562</span>, trae exactamente eso al estándar UUID. <span class="high">PostgreSQL 18</span> ya incluye la función nativa <span class="high">uuidv7()</span>. Pero Swift — y por extensión <span class="high">Fluent</span> — sigue generando <span class="high">UUID v4</span> por defecto con <span class="high">UUID()</span>.

Si el identificador lo genera mi aplicación antes de persistirlo, estoy perdiendo las ventajas de v7 aunque mi base de datos ya lo soporte.

---

## Mi Solución 🧩

Decidí crear una extensión sobre <span class="high">UUID</span> que implementa la generación de <span class="high">UUID v7</span> directamente en Swift, siguiendo la especificación del <span class="high">RFC 9562</span>.

### Estado monotónico

Lo primero que necesito es un estado compartido que garantice que dos UUIDs generados en el mismo milisegundo sean distintos y estén ordenados. Uso un <span class="high">Mutex</span> del framework <span class="high">Synchronization</span> para hacerlo thread-safe sin recurrir a <span class="high">DispatchQueue</span> ni <span class="high">actor</span>:

```swift
import Foundation
import Synchronization

private let v7State = Mutex(V7State())

private struct V7State: Sendable {
    var lastTimestamp: UInt64 = 0
    var sequence: UInt16 = 0
}
```

### La generación del UUID

La extensión principal implementa el método estático <span class="high">v7()</span> que genera un UUID conforme al <span class="high">RFC 9562</span>:

```swift
extension UUID {
    public static func v7() -> UUID {
        var bytes = (
            UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0),
            UInt8(0), UInt8(0), UInt8(0), UInt8(0)
        )

        let (timestamp, seq) = v7State.withLock { state -> (UInt64, UInt16) in
            var now = UInt64(Date().timeIntervalSince1970 * 1000)

            if now == state.lastTimestamp {
                if state.sequence >= 0x0FFF {
                    while now == state.lastTimestamp {
                        now = UInt64(Date().timeIntervalSince1970 * 1000)
                    }
                    state.lastTimestamp = now
                    state.sequence = UInt16.random(in: 0...0x0FFF)
                } else {
                    state.sequence += 1
                }
            } else {
                state.lastTimestamp = now
                state.sequence = UInt16.random(in: 0...0x0FFF)
            }

            return (now, state.sequence)
        }

        // Bytes 0–5: 48-bit timestamp (big-endian)
        bytes.0 = UInt8(truncatingIfNeeded: timestamp >> 40)
        bytes.1 = UInt8(truncatingIfNeeded: timestamp >> 32)
        bytes.2 = UInt8(truncatingIfNeeded: timestamp >> 24)
        bytes.3 = UInt8(truncatingIfNeeded: timestamp >> 16)
        bytes.4 = UInt8(truncatingIfNeeded: timestamp >> 8)
        bytes.5 = UInt8(truncatingIfNeeded: timestamp)

        // Byte 6: version (0x7_) | top 4 bits of sequence
        bytes.6 = 0x70 | UInt8(seq >> 8)

        // Byte 7: lower 8 bits of sequence
        bytes.7 = UInt8(truncatingIfNeeded: seq)

        // Bytes 8–15: random, then set variant
        var random: UInt64 = 0
        withUnsafeMutableBytes(of: &random) { buf in
            _ = SecRandomCopyBytes(kSecRandomDefault, buf.count, buf.baseAddress!)
        }
        bytes.8  = UInt8(truncatingIfNeeded: random >> 56)
        bytes.9  = UInt8(truncatingIfNeeded: random >> 48)
        bytes.10 = UInt8(truncatingIfNeeded: random >> 40)
        bytes.11 = UInt8(truncatingIfNeeded: random >> 32)
        bytes.12 = UInt8(truncatingIfNeeded: random >> 24)
        bytes.13 = UInt8(truncatingIfNeeded: random >> 16)
        bytes.14 = UInt8(truncatingIfNeeded: random >> 8)
        bytes.15 = UInt8(truncatingIfNeeded: random)

        // Byte 8: variant 0b10xx_xxxx
        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return UUID(uuid: bytes)
    }
}
```

La estructura del UUID generado respeta la especificación del <span class="high">RFC 9562</span>:

- **Bytes 0–5** (48 bits): <span class="high">timestamp</span> en milisegundos desde epoch, en big-endian. Esto es lo que garantiza el orden cronológico.
- **Byte 6** (nibble alto): versión <span class="high">0x7</span> — identifica el UUID como v7.
- **Bytes 6–7** (12 bits inferiores): contador de secuencia. Garantiza monotonicidad dentro del mismo milisegundo.
- **Bytes 8–15** (64 bits): aleatorios generados con <span class="high">SecRandomCopyBytes</span>, con los dos bits superiores del byte 8 forzados a <span class="high">0b10</span> para marcar el variante <span class="high">RFC 4122</span>.

La lógica monotónica dentro del <span class="high">withLock</span> funciona así: cuando dos llamadas ocurren en el mismo milisegundo, el contador se incrementa. Si el contador alcanza el máximo (<span class="high">0x0FFF</span>, es decir 4095 UUIDs en un solo milisegundo), la implementación espera activamente al siguiente milisegundo antes de continuar — nunca genera dos UUIDs idénticos.

### Utilidades de inspección

Además de la generación, añadí dos propiedades para poder inspeccionar cualquier UUID: una que verifica si es v7 y otra que extrae el <span class="high">timestamp</span> embebido:

```swift
extension UUID {
    public var isV7: Bool {
        (uuid.6 >> 4) == 0x07 && (uuid.8 >> 6) == 0x02
    }

    public var v7Timestamp: Date? {
        guard isV7 else { return nil }

        let ms = UInt64(uuid.0) << 40
            | UInt64(uuid.1) << 32
            | UInt64(uuid.2) << 24
            | UInt64(uuid.3) << 16
            | UInt64(uuid.4) << 8
            | UInt64(uuid.5)

        return Date(timeIntervalSince1970: Double(ms) / 1000.0)
    }
}
```

<span class="high">isV7</span> comprueba que el nibble alto del byte 6 sea <span class="high">0x07</span> (versión 7) y que los dos bits superiores del byte 8 sean <span class="high">0b10</span> (variante RFC 4122). <span class="high">v7Timestamp</span> reconstruye los 48 bits del timestamp desde los bytes 0–5 y los convierte en un <span class="high">Date</span>.

---

## Mi Resultado 🎯

La adopción es inmediata. En cualquier modelo <span class="high">Fluent</span>, me basta con sustituir <span class="high">UUID()</span> por <span class="high">UUID.v7()</span> en el inicializador:

```swift
// Antes
self.id = UUID()

// Después
self.id = UUID.v7()
```

El tipo en base de datos no cambia — sigue siendo <span class="high">UUID</span>. <span class="high">Fluent</span> no necesita ninguna modificación. El cambio es completamente transparente para el ORM.

Los beneficios que he obtenido son directos:

- **Índices ordenados** — los nuevos registros se insertan siempre al final del <span class="high">B-Tree</span>, eliminando la fragmentación
- **Ordenación cronológica nativa** — <span class="high">ORDER BY id</span> equivale a <span class="high">ORDER BY created_at</span> sin columna extra
- **Timestamp embebido** — puedo extraer cuándo se creó un registro directamente del UUID con <span class="high">v7Timestamp</span>
- **Compatible hacia atrás** — el formato sigue siendo UUID estándar; cualquier sistema que acepte <span class="high">UUID v4</span> acepta <span class="high">v7</span>
- **Thread-safe** — funciona correctamente desde múltiples hilos concurrentes gracias al <span class="high">Mutex</span>

```swift
let id = UUID.v7()

print(id.isV7)          // true
print(id.v7Timestamp!)  // la fecha de creación embebida en el UUID
```

Y si ya estás en <span class="high">PostgreSQL 18</span>, la función nativa <span class="high">uuidv7()</span> genera UUIDs con la misma estructura. Los UUIDs generados desde Swift y desde PostgreSQL son intercambiables y comparables entre sí.

El cambio de <span class="high">UUID()</span> a <span class="high">UUID.v7()</span> es de una línea. Las ventajas, permanentes.


**Keep coding, keep running** 🏃‍♂️

---
