---
title: Migrate Spaces
slug: migrate-spaces
date: 2026-03-14
description: Cómo crear espacios de nombres en PostgreSQL con migraciones de FluentKit en Vapor, reemplazando la configuración manual por código versionado y reversible.
tags: Swift, Vapor
cover: MigrateSpaces
coverDescription: Jorge administrando espacios de nombres en una base de datos PostgreSQL desde código Swift.
publish: true
---
---
## 🧩 Problema

En el artículo anterior sobre [Esquemas y Espacios](/es/blog/schema-space-es) vimos cómo asignar un espacio de nombres a un modelo usando la propiedad <span class="high">space</span>. Muchos me preguntasteis lo mismo: **¿cómo se crean esos espacios en la base de datos?** 🤔

La respuesta más habitual era hacerlo a mano, ejecutando un <span class="high">CREATE SCHEMA</span> en la consola de PostgreSQL antes de lanzar las migraciones. Funciona, pero rompe algo fundamental: si la base de datos no existe o el entorno es nuevo, **el proceso falla** antes de llegar a las migraciones reales 💥.

El otro problema es que administrar espacios de nombres a mano no escala. En cuanto tienes varios entornos (desarrollo, staging, producción) o un equipo, mantener esa sincronía manual se convierte en una fuente de errores silenciosos 😬.

---

## 💡 Solución

La solución es convertir la creación de espacios de nombres en una <span class="high">migración</span> más. De esta forma, se ejecuta automáticamente en el orden correcto, es reversible y está versionada junto al resto del código ✅.

La clave está en combinar <span class="high">FluentKit</span> con <span class="high">SQLKit</span>. FluentKit gestiona el ciclo de vida de las migraciones, pero para ejecutar SQL arbitrario necesitamos acceder al driver subyacente mediante el protocolo <span class="high">SQLDatabase</span>. Para mantener el código organizado, encapsulamos los espacios de nombres en un enum con una acción que determina si se crean o se eliminan:

```swift
import FluentKit
import SQLKit

enum SRSchema: String, CaseIterable {
    case account, ai, device, location, sport, task, view

    enum Action {
        case create, drop
    }

    static func execute(_ action: Action, on db: Database) async throws {
        let sql = db as! any SQLDatabase
        let template: (String) -> String =
            switch action {
            case .create: { "CREATE SCHEMA IF NOT EXISTS \($0)" }
            case .drop: { "DROP SCHEMA IF EXISTS \($0) RESTRICT" }
            }
        for schema in allCases {
            try await sql.raw("\(unsafeRaw: template(schema.rawValue))").run()
        }
    }
}

struct SchemasMigration: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await SRSchema.execute(.create, on: db)
    }

    func revert(on db: Database) async throws {
        try await SRSchema.execute(.drop, on: db)
    }
}
```

Algunos detalles importantes 📋:

- **SRSchema** como **CaseIterable**: al iterar sobre <span class="high">allCases</span>, nos aseguramos de que todos los espacios definidos se crean sin tener que listarlos manualmente en la migración. Añadir un nuevo espacio solo requiere agregar un caso al enum 🔄.
- **Action**: el enum interno modela las dos operaciones posibles (<span class="high">create</span> y <span class="high">drop</span>), lo que permite reutilizar el mismo método <span class="high">execute</span> tanto en el <span class="high">prepare</span> como en el <span class="high">revert</span> de la migración ♻️.
- **Switch expression**: se usa una *switch expression* de Swift para seleccionar el template SQL según la acción. Cada rama devuelve un closure que genera la sentencia correspondiente, manteniendo la lógica compacta y legible 🧹.
- **CREATE SCHEMA IF NOT EXISTS**: hace que la migración sea idempotente. Si el esquema ya existe, no falla, simplemente continúa 🛡️.
- **DROP SCHEMA ... RESTRICT**: en el <span class="high">revert</span>, el modificador <span class="high">RESTRICT</span> impide eliminar un esquema que contenga tablas. Es una red de seguridad que evita pérdidas accidentales de datos al revertir 🔒.
- **unsafeRaw**: se usa para interpolar el nombre del schema directamente en el SQL. Es seguro aquí porque el valor proviene de un enum propio, nunca de input externo ⚠️.

---

## 📊 Resultado

Esta migración debe ser la **primera** en registrarse ☝️. Antes de crear cualquier tabla, los espacios de nombres tienen que existir. En el runner de migraciones, el orden queda así:

```swift
fluent.migrations.add(
    SchemasMigration()
)
```

Al ejecutar las migraciones en un entorno nuevo, el proceso completo es automático ⚡:

Y si en algún momento necesitas añadir un nuevo dominio, solo añades el caso al enum <span class="high">SRSchema</span> y la próxima vez que se ejecuten las migraciones, el esquema aparece. **Sin tocar la base de datos a mano, sin documentación extra que mantener** 🎯.


**Keep coding, keep running** 🏃‍♂️

---
