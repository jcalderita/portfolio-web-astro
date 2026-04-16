---
title: Copy From
slug: copy-from
date: 2025-12-31
description: Como hacer bulk insert con Vapor para acelerar tus inserciones de datos a base de datos.
tags: Swift, Vapor
cover: CopyFrom
coverDescription: Jorge metiendo en un armario un montón de zapatillas a la vez.
publish: true
---
---
## Problema

En aplicaciones backend con <span class="high">Vapor</span>, cuando necesitamos insertar **grandes volúmenes de datos** en la base de datos (migraciones iniciales, importación de catálogos, carga masiva desde APIs externas), usar <span class="high">.save()</span> en un bucle genera **múltiples transacciones individuales**.

Esto resulta en:
- **Alta latencia**: cada insert abre/cierra conexión y transaction overhead.
- **Pobre throughput**: no aprovecha las capacidades de inserción masiva del motor de base de datos.
- **Riesgo de timeout**: operaciones lentas que pueden fallar en entornos con límites de tiempo.

Para escenarios de importación masiva (miles o millones de registros), necesitamos una estrategia de **bulk insert** que aproveche las capacidades nativas de <span class="high">PostgreSQL</span>.

---

## Solución

Extendemos <span class="high">Database</span> con una función que ejecuta el comando <span class="high">COPY</span> de <span class="high">PostgreSQL</span>, permitiendo importar archivos <span class="high">CSV</span> directamente desde el sistema de archivos al schema de la tabla.

```swift
extension Database {
    func importCSV(
        _ model: any Model.Type,
        file: PathEnum
        ) async throws {
        let query = SQLQueryString(
            """
            COPY \"\(unsafeRaw: model.space ?? "public")\".
            \"\(unsafeRaw: model.schema)\"
            FROM '\(unsafeRaw: file.rawValue)'
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
- Usa <span class="high">COPY</span> de <span class="high">PostgreSQL</span>, el método más rápido para bulk insert desde archivos.
- El parámetro <span class="high">model.space</span> soporta schemas personalizados (por defecto <span class="high">"public"</span>).
- <span class="high">model.schema</span> obtiene automáticamente el nombre de la tabla del modelo <span class="high">Fluent</span>.
- Configuración <span class="high">CSV</span> estándar: headers, delimitadores y manejo de valores nulos.
- Utiliza <span class="high">unsafeRaw</span> para interpolación directa en la query SQL.

---

## Resultado

```swift
private func importRegions() async throws {
    try await db.importCSV(
        RegionModel.self,
        file: .LocationFile("regions", .csv)
    )
}
```

Beneficios de esta aproximación:

🚀 **Performance extremo**: <span class="high">COPY</span> es hasta **10-100x más rápido** que inserts individuales.<br />
📦 **Transacción atómica**: toda la importación ocurre en una sola operación, garantizando consistencia.<br />
💾 **Eficiencia de recursos**: minimiza el uso de memoria y conexiones de base de datos.<br />
🔧 **Integración nativa**: aprovecha capacidades optimizadas del motor <span class="high">PostgreSQL</span>.<br />
📊 **Escalabilidad**: permite importar millones de registros sin degradación significativa.

---

## Notas

Esta implementación utiliza <span class="high">COPY ... FROM</span> con archivos del sistema. Actualmente existe una **issue abierta en Vapor** para implementar soporte nativo de <span class="high">COPY ... FROM STDIN</span>, que permitiría realizar bulk inserts directamente desde memoria sin necesidad de archivos intermedios.

Estoy vigilando esta issue de manera activa para integrar esta funcionalidad cuando esté disponible, lo que proporcionará una API aún más flexible y eficiente para operaciones de importación masiva.

Si también necesitas la operación inversa — exportar datos de PostgreSQL a archivos CSV — lo cubrí en [Copy To](/es/blog/copy-to/).

**Keep coding, keep running** 🏃‍♂️

---
