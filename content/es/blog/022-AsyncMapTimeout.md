---
title: Async Map Timeout
slug: async-map-timeout
date: 2026-01-14
description: Actualización de asyncMap para añadir control de rate limiting mediante timeouts entre operaciones.
tags: Swift, Vapor
cover: AsyncMapTimeout
coverDescription: Jorge corriendo en una cinta, pausando brevemente entre cada paso para controlar el ritmo.
publish: true
---
---
## Problema

En el [post sobre AsyncMap](/es/blog/async-map-es) vimos cómo procesar colecciones de forma **secuencial asíncrona**. Sin embargo, al trabajar con **APIs externas** que implementan rate limiting, nos enfrentamos a un problema crítico:

```swift
// Procesar 1000 URLs secuencialmente
let results = try await urls.asyncMap { url in
    try await apiClient.fetch(url)  // ⚠️ 1000 llamadas sin pausa
}
// Error 429: Too Many Requests
```

Realizar llamadas consecutivas sin pausas puede:
- **Exceder límites de rate**: APIs rechazan con <span class="high">429 Too Many Requests</span>.
- **Saturar servicios externos**: sobrecarga de conexiones simultáneas.
- **Desperdiciar recursos**: forzar reintentos consume más tiempo y ancho de banda.
- **Bloqueos temporales**: algunas APIs bloquean la IP tras múltiples infracciones.

Necesitamos una forma de **controlar el ritmo** de las operaciones secuenciales, añadiendo pausas intencionales entre cada procesamiento.

---

## Solución

Actualizamos <span class="high">asyncMap</span> añadiendo un parámetro opcional <span class="high">timeout</span> que introduce una pausa configurable después de procesar cada elemento.

```swift
extension Sequence {
    func asyncMap<T>(
        timeout: Double? = nil,
        _ transform: (Element) async throws -> T
    ) async throws -> [T] {
        var results = [T]()
        results.reserveCapacity(underestimatedCount)
        for element in self {
            try await results.append(transform(element))
            if let timeout {
                try await Task.sleep(for: .seconds(timeout))
            }
        }
        return results
    }
}
```

**Cambios clave respecto a la versión original**:

✨ Parámetro <span class="high">timeout: Double? = nil</span> opcional y retrocompatible.<br />
⏱️ Si se especifica timeout, añade <span class="high">Task.sleep(for: .seconds(timeout))</span> después de cada elemento.<br />
🔄 Mantiene el comportamiento original cuando no se especifica timeout (sin pausas).<br />
📊 Permite ajustar dinámicamente el rate limiting según los límites de cada API.

---

## Resultado

```swift
// Rate limiting: 1 llamada por segundo
let results = try await urls.asyncMap(timeout: 1.0) {
    try await apiClient.fetch($0)
}

// Rate limiting agresivo: 1 llamada cada 5 segundos
let results = try await endpoints.asyncMap(timeout: 5.0) {
    try await scraper.parse($0)
}

// Sin timeout: comportamiento original (máxima velocidad)
let results = try await localFiles.asyncMap {
    try await processFile($0)
}
```

Beneficios de esta actualización:

⏱️ **Rate limiting configurable**: controla el ritmo de llamadas según los límites de cada API.<br />
🛡️ **Prevención de bloqueos**: evita errores <span class="high">429</span> y suspensiones temporales de IP.<br />
🔄 **Retrocompatibilidad total**: sin timeout funciona exactamente igual que antes.<br />
🎯 **Flexibilidad por caso de uso**: ajusta el timeout según la tolerancia del servicio externo.<br />
📊 **Procesamiento predecible**: calcula fácilmente el tiempo total (n elementos × timeout).

Esta actualización convierte <span class="high">asyncMap</span> en una herramienta **completa para procesamiento secuencial controlado**, ideal para integración con APIs que imponen límites de tasa y necesitan un flujo de peticiones regulado.


**Keep coding, keep running** 🏃‍♂️

---
