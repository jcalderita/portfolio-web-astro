---
title: Copy To
slug: copy-to
date: 2026-01-07
description: Exporta grandes conjuntos de datos de PostgreSQL a CSV en Vapor usando el comando nativo COPY TO, evitando serialización manual y reduciendo consumo de memoria.
tags: Swift, Vapor
cover: CopyTo
coverDescription: Muchas zapatillas cayendose encima de Jorge al abrir el armario.
publish: true
---
---
## Problema

En aplicaciones backend con <span class="high">Vapor</span>, a menudo necesitamos **exportar grandes volúmenes de datos** desde la base de datos a archivos para diferentes propósitos: backups, análisis offline, integración con sistemas externos, o auditorías de datos.

Usar consultas tradicionales con <span class="high">Fluent</span> para luego serializar los resultados manualmente presenta varios inconvenientes:
- **Alto consumo de memoria**: cargar miles de registros en memoria para procesarlos uno a uno.
- **Procesamiento lento**: serialización manual a <span class="high">CSV</span> requiere iterar y formatear cada registro.
- **Falta de optimización**: no aprovecha las capacidades nativas de exportación del motor de base de datos.
- **Complejidad innecesaria**: gestión manual de formatos, escapado de caracteres y manejo de valores nulos.

Para escenarios de exportación masiva, necesitamos una estrategia que aproveche las capacidades nativas de <span class="high">PostgreSQL</span> para generar archivos de forma eficiente.

---

## Solución

Extendemos <span class="high">Database</span> con una función que ejecuta el comando <span class="high">COPY ... TO</span> de <span class="high">PostgreSQL</span>, permitiendo exportar datos directamente desde el schema de la tabla a archivos <span class="high">CSV</span> en el sistema de archivos.

```swift
extension Database {
    func exportCSV(
        _ model: any Model.Type,
        file: PathEnum)
        async throws {
        let query = SQLQueryString(
            """
            COPY \"\(unsafeRaw: model.space ?? "public")\".
            \"\(unsafeRaw: model.schema)\"
            TO '\(unsafeRaw: file.rawValue)'
            WITH (FORMAT csv, HEADER true, DELIMITER ',',
            QUOTE '"', ESCAPE '"', NULL '')
            """
        )

        try await self.sqlDatabase
            .raw(query).run()
    }
}
```

Puntos clave:
- Usa <span class="high">COPY ... TO</span> de <span class="high">PostgreSQL</span>, el método más eficiente para exportación masiva.
- El parámetro <span class="high">model.space</span> soporta schemas personalizados (por defecto <span class="high">"public"</span>).
- <span class="high">model.schema</span> obtiene automáticamente el nombre de la tabla del modelo <span class="high">Fluent</span>.
- Configuración <span class="high">CSV</span> estándar: headers incluidos, delimitadores y manejo correcto de valores nulos.
- Utiliza <span class="high">unsafeRaw</span> para interpolación directa en la query SQL.

---

## Resultado

```swift
func exportRegions() async throws {
    try await db.exportCSV(
        LocationRegionModel.self, 
        file: file
    )
}
```

Beneficios de esta aproximación:

🚀 **Performance óptimo**: <span class="high">COPY ... TO</span> es mucho más rápido que serialización manual.<br />
💾 **Eficiencia de recursos**: <span class="high">PostgreSQL</span> escribe directamente al archivo sin cargar datos en memoria de la aplicación.<br />
📦 **Formato consistente**: el motor de base de datos garantiza un <span class="high">CSV</span> válido con escapado correcto.<br />
🔧 **Integración nativa**: aprovecha capacidades optimizadas del motor <span class="high">PostgreSQL</span>.<br />
📊 **Escalabilidad**: permite exportar millones de registros sin impacto en el rendimiento de la aplicación.

Esta solución es el complemento perfecto para <span class="high">importCSV</span>, formando un par de funciones que permite **movimiento bidireccional de datos** entre <span class="high">PostgreSQL</span> y el sistema de archivos de forma eficiente y confiable. Si aún no has visto la parte de importación, explico cómo construirla usando `COPY FROM` de PostgreSQL en [Copy From](/es/blog/copy-from/).

**Keep coding, keep running** 🏃‍♂️

---
