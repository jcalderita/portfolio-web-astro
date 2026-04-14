---
title: Async Task List
slug: task-list
date: 2025-11-20
description: Implementación de un sistema robusto para la gestión de listas de tareas asíncronas con persistencia de estado en base de datos utilizando Swift y Vapor.
tags: Swift, Vapor
cover: TaskList
coverDescription: Jorge participando en las distintas pruebas de una Decatlón y checkeando las realizadas.
publish: true
---
---
## Problema

En sistemas distribuidos con microservicios, un proceso complejo puede generar dificultades de control y fiabilidad. Una solución es **dividirlo** en tareas **atómicas**, lo que permite un control más granular del **flujo**, mejorar la **observabilidad**, asegurar la **idempotencia** y facilitar la **recuperación** ante fallos.

El reto es diseñar un patrón que permita una **degradación controlada**, de modo que el fallo de una tarea no afecte al flujo completo, garantizando **resiliencia** y **tolerancia a fallos** en entornos de producción.

---
## Solución

Crear un <span class="high">task executor</span> que orquesta tareas asíncronas.  
La función <span class="high">execute</span> envuelve cada tarea, gestiona errores con <span class="high">do-catch</span> como <span class="high">circuit breaker</span>, actualiza el estado en caso de **éxito**, registra y persiste los fallos, y asegura una **transacción atómica** para mantener la consistencia de datos.

```swift
func execute(
    status: StatusEnum,
    process: ProcessModel,
    _ work: () async throws -> ProcessModel
) async throws {
    do {
        let job = try await work()
        process.setStatus(job.status)
    } catch {
        process.setError(type: status, message: "\(error)")
    }
    try await repo.updateProcess(process)
}
```

---
## Resultado

Esta implementación ofrece una **abstracción de alto nivel** que permite una **orquestación precisa** de procesos asíncronos complejos con garantías de **atomicidad** y **durabilidad**.

🎯 **Separation of Concerns:** cada tarea aísla su contexto de ejecución y su gestión de errores.<br />
🔄 **Workflow Orchestration:** posibilita encadenar tareas mediante el pipeline pattern.<br />
📊 **Observability:** genera un audit trail completo para depuración y monitorización.<br />
⚡ **Performance:** mantiene alta concurrencia sin comprometer la consistencia de datos.<br />
🛡️ **Resilience:** incorpora fail-fast y recovery patterns automáticos.

```swift
try await execute(status: .loadImages, process: process) {
    // Your implementation
}
```


**Keep coding, keep running** 🏃‍♂️

---
