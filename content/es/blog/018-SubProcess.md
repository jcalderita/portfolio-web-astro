---
title: Subprocess
slug: sub-process
date: 2025-12-17
description: Cambiando el uso de process por Subprocess, la nueva libreria Subprocess es un paquete multiplataforma para lanzar procesos en Swift.
tags: Swift, Vapor
cover: Subprocess
coverDescription: Varios Jorges corriendo en una carrera de relevos, cada uno pasando un testigo con forma del logo de Swift al siguiente, representando la migración de Process a Subprocess.
publish: true
---
---
## Problema

Al trabajar con procesos externos en aplicaciones <span class="high">Swift</span>, la clase tradicional <span class="high">Process</span> presenta varias limitaciones importantes:

- **Gestión manual de recursos**: Requiere configuración explícita de URLs ejecutables, argumentos y manejo de salidas
- **Falta de soporte async/await**: Utiliza métodos síncronos que bloquean el hilo de ejecución
- **Manejo complejo de errores**: Dificulta la captura y procesamiento de errores del proceso hijo
- **Configuración verbosa**: Cada ejecución requiere múltiples líneas de configuración repetitiva

En el código anterior, necesitaba ejecutar <span class="high">Ghostscript</span> para convertir archivos PDF a imágenes PNG, pero la implementación con <span class="high">Process</span> resulta extensa y poco elegante.

```swift
func _PDFToImages(
    _ fileName: PathEnum
) async throws {
    let process = Process()

    process.executableURL = URL(
        fileURLWithPath: "/opt/homebrew/bin/gs"
    )

    process.arguments = [
        "-dNOPAUSE", "-dBATCH",
        "-dQUIET", "-sDEVICE=png16m",
        "-r300",
        "-sOutputFile=\(fileName.rawValue)-%d.png",
        fileName.rawValue.appending(".pdf"),
    ]

    try process.run()
    process.waitUntilExit()
}
```

---

## Solución

La nueva librería <span class="high">Subprocess</span> de Apple proporciona una API moderna y robusta para la ejecución de procesos en <span class="high">Swift</span>. Esta librería **multiplataforma** ofrece soporte nativo para <span class="high">async/await</span> y gestión automática de recursos.

**Características principales:**

✅ **API nativa async/await** para operaciones no bloqueantes.<br />
✅ **Gestión automática de recursos** y limpieza de procesos.<br />
✅ **Control granular de salidas** (stdout, stderr).<br />
✅ **Verificación de estado de terminación** integrada.<br />
✅ **Sintaxis concisa y expresiva.**  

La implementación modernizada utiliza la función <span class="high">run</span> de <span class="high">Subprocess</span>:

```swift
func _PDFToImages(
    _ fileName: PathEnum
) async throws {
    let result = try await run(
        .path(.init("/opt/homebrew/bin/gs")),
        arguments: [
            "-dNOPAUSE", "-dBATCH",
            "-dQUIET", "-sDEVICE=png16m",
            "-r300",
            "-sOutputFile=\(fileName.rawValue)-%d.png",
            fileName.rawValue.appending(".pdf"),
        ],
        output: .discarded,
        error: .string(limit: .max)
    )

    try guardAndLogError(
        result.terminationStatus == .exited(0),
        message: result.standardError,
        status: .internalServerError
    )
}
```

**Parámetros clave:**
- <span class="high">.path</span>: Especifica el ejecutable de forma directa
- <span class="high">output: .discarded</span>: Descarta la salida estándar ya que no necesitamos procesarla
- <span class="high">error: .string(limit: .max)</span>: Captura errores como string para logging
- <span class="high">result.terminationStatus</span>: Verifica que el proceso terminó exitosamente

---

## Resultado

La migración a <span class="high">Subprocess</span> transforma el código de gestión de procesos en una solución **más limpia, segura y eficiente**:

**Beneficios obtenidos:**

🚀 **Rendimiento mejorado** con operaciones asíncronas reales.<br />
🔒 **Mejor manejo de errores** con captura integrada de stderr.<br />
📝 **Código más legible** con menos configuración manual.<br />
⚡ **Integración perfecta** con el ecosistema moderno de Swift concurrency.<br />

La nueva implementación no solo reduce la complejidad sino que también **mejora la robustez** del sistema al proporcionar mejor visibilidad de errores y un manejo más elegante de la ejecución asíncrona en aplicaciones <span class="high">Vapor</span>.

---

## Nota sobre DYLD_LIBRARY_PATH

En versiones anteriores de <span class="high">Swift</span>, existía un problema conocido con la variable de entorno <span class="high">DYLD_LIBRARY_PATH</span> al ejecutar procesos externos. Debido a las restricciones de **System Integrity Protection (SIP)** de macOS, esta variable era eliminada automáticamente al lanzar subprocesos, lo que causaba errores de "Library not loaded" en ciertos casos.

La solución temporal requería configurar manualmente las rutas de las librerías usando <span class="high">install_name_tool</span> con <span class="high">@rpath</span>, o bien establecer la variable <span class="high">DYLD_LIBRARY_PATH</span> en su lugar.

**¡Buenas noticias!** 🎉 Este problema ha sido resuelto en las versiones más recientes de <span class="high">Swift</span>. La librería <span class="high">Subprocess</span> maneja correctamente las variables de entorno del sistema, incluida <span class="high">DYLD_LIBRARY_PATH</span>, sin necesidad de configuraciones adicionales.


**Keep coding, keep running** 🏃‍♂️

---
