---
title: Async Concurrent Map
slug: async-concurrent-map
date: 2026-01-21
description: Como combinar procesamiento concurrente con chunking para optimizar el uso de recursos en operaciones asíncronas masivas.
tags: Swift, Vapor
cover: AsyncConcurrentMap
coverDescription: Jorge organizando múltiples cajas de zapatos en grupos para procesarlas de forma eficiente.
publish: true
---
---
## Problema

En aplicaciones backend con <span class="high">Vapor</span>, cuando procesamos **grandes volúmenes de datos** de forma concurrente, nos enfrentamos a un dilema de optimización:

- **Procesamiento secuencial** con <span class="high">asyncMap</span>: garantiza control sobre los recursos, pero es **lento** al procesar elementos uno a uno.
- **Procesamiento totalmente concurrente** con <span class="high">concurrentMap</span>: maximiza la velocidad, pero puede **saturar recursos** al lanzar miles de tareas simultáneas.

Por ejemplo, al procesar 10,000 registros con llamadas a APIs externas:
- <span class="high">asyncMap</span>: 10,000 llamadas secuenciales → muy lento pero controlado.
- <span class="high">concurrentMap</span>: 10,000 llamadas simultáneas → muy rápido pero puede agotar conexiones/memoria.

Necesitamos una solución que **combine ambos enfoques**: dividir el trabajo en grupos manejables y procesar cada grupo de forma concurrente, equilibrando velocidad y uso de recursos.

---

## Solución

Extendemos <span class="high">Collection</span> con una función que combina **chunking** (división en grupos) y **procesamiento concurrente**, permitiendo configurar el tamaño de los grupos y timeout por chunk.

```swift
extension Collection where Element: Sendable {
    func asyncConcurrentMap<T: Sendable>(
        chunkSize: Int? = nil,
        timeout: Double? = nil,
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async throws -> [T] {
        guard let chunkSize else {
            return try await concurrentMap(transform)
        }

        return try await chunks(ofCount: chunkSize)
            .asyncMap(timeout: timeout) {
                try await $0.concurrentMap(transform)
            }.flatMap { $0 }
    }
}
```

Puntos clave:
- Si no se especifica <span class="high">chunkSize</span>, usa <span class="high">concurrentMap</span> puro (procesamiento totalmente concurrente).
- Si se especifica <span class="high">chunkSize</span>, divide la colección en grupos con <span class="high">chunks(ofCount:)</span>.
- Procesa los **chunks secuencialmente** con <span class="high">asyncMap</span> (con timeout opcional).
- Dentro de cada chunk, procesa los elementos **concurrentemente** con <span class="high">concurrentMap</span>.
- Aplana los resultados con <span class="high">flatMap</span> para devolver un array unificado.

---

## Resultado

```swift
// Procesar 10,000 registros en chunks de 100
// 100 tareas concurrentes a la vez, 100 veces
let results = try await records.asyncConcurrentMap(
    chunkSize: 100,
    timeout: 30.0
) { record in
    try await apiClient.process(record)
}
```

Beneficios de esta aproximación:

⚡ **Balance perfecto**: combina la velocidad del procesamiento concurrente con el control del procesamiento secuencial por chunks.<br />
🎯 **Control de recursos**: limita la cantidad de tareas simultáneas al tamaño del chunk, evitando saturación.<br />
⏱️ **Timeout por chunk**: detecta y maneja chunks problemáticos sin bloquear todo el procesamiento.<br />
🔧 **Flexibilidad total**: usa chunking cuando lo necesites, o procesamiento concurrente puro cuando no.<br />
📊 **Escalabilidad**: permite procesar millones de registros ajustando el tamaño del chunk según los recursos disponibles.

Si necesitas ejecución paralela pura, lo cubrí en [Concurrent Map](/es/blog/concurrent-map/). Y si tus chunks secuenciales necesitan rate limiting entre ellos, añadí esa capacidad en [Async Map Timeout](/es/blog/async-map-timeout/).

Esta solución es la **evolución natural** de <span class="high">asyncMap</span> y <span class="high">concurrentMap</span>, combinando lo mejor de ambos mundos para optimizar el procesamiento de datos masivos en aplicaciones backend.


**Keep coding, keep running** 🏃‍♂️

---
