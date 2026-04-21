---
title: DB Integration Test
slug: db-integration-test
date: 2026-05-13
description: Cómo usar SchemaDescribable y un contenedor efímero de PostgreSQL para verificar que cada migración crea exactamente la estructura que el modelo declara.
tags: Swift, Server, DataBase, Testing
cover: DBIntegrationTest
coverDescription: Ilustración estilo cómic: a la izquierda Jorge corre en una cinta de correr con gafas de realidad virtual, mientras una pantalla muestra un dashboard 'DB integration test' con una pista de atletismo, estado Running, latencia y TPS. A la derecha Jorge corre libremente por el suelo del laboratorio futurista, con un científico observando datos en una tablet junto a un brazo robótico y monitores con gráficas al fondo.
publish: false
---
---
## Mi Problema 🤔

Una migración de <span class="high">Fluent</span> se ejecuta una vez en producción. Si el índice que declaré no coincide con el que el modelo espera, o si la clave foránea apunta a la tabla equivocada, lo descubro cuando algo falla en producción — no antes.

Los tests unitarios no me ayudan aquí. Puedo verificar el comportamiento del tipo, la lógica del parser, los valores de los enums. Pero no puedo saber si la migración creó realmente la tabla correcta, con las columnas correctas, con los índices correctos y los permisos adecuados sin ejecutarla contra una base de datos real.

El problema es que, hasta ahora, la metadata estructural de cada tabla — índices, claves foráneas, restricciones únicas — vivía enterrada dentro del método <span class="high">prepare</span> de cada migración. No había forma de consultarla desde fuera sin ejecutarla. Y sin esa información accesible, escribir un test de integración genérico que verifique la estructura real sería repetir strings hardcodeados en cada verificación.

En el [artículo anterior](/es/blog/model-parts/) introduje <span class="high">SchemaDescribable</span>: un protocolo que convierte el modelo en la única fuente de verdad para toda su metadata estructural. Ahora ese protocolo tiene un segundo beneficio que es el que hace posible este artículo: los tests pueden leer la estructura esperada directamente del modelo, sin strings, sin duplicación.

---

## Mi Solución 🧩

Mi solución tiene tres partes: un contenedor efímero de <span class="high">PostgreSQL</span>, un protocolo de metadata para los tests, y el test de ciclo de vida completo.

### Contenedor efímero con Apple container CLI

Mi test necesita una base de datos real. En lugar de depender de una instalación local o de <span class="high">Docker</span>, uso el CLI <span class="high">container</span> de Apple — contenedores ligeros sobre <span class="high">Virtualization.framework</span> en macOS — para arrancar un <span class="high">PostgreSQL</span> efímero por cada ejecución. El <span class="high">actor</span> garantiza acceso seguro al estado del contenedor desde código concurrente. Arranca con <span class="high">container run</span>, espera a que <span class="high">PostgreSQL</span> esté listo, y se destruye completamente al finalizar — sin rastro en el sistema.

### MigrationInfo — metadata accesible desde los tests

Para que el test pueda verificar la estructura sin strings hardcodeados, cada migración expone su metadata a través del protocolo <span class="high">MigrationInfo</span>. Este protocolo vive en el target de tests, no en producción — es metadata de verificación, no lógica de negocio:

```swift
protocol MigrationInfo {
    associatedtype ModelType: SchemaDescribable
}

extension MigrationInfo {
    var modelSchema: String    { ModelType.schema }
    var modelSpace: String?    { ModelType.space }
    var modelKeys: [FieldKey]  { ModelType.keys }
    var modelIndexes: [IndexDefinition]      { ModelType.indexes }
    var modelForeignKeys: [ForeignKeyDefinition] { ModelType.foreignKeys }
    var modelUniques: [UniqueDefinition]     { ModelType.uniques }
}
```

La conformancia en cada migración es una línea vacía — toda la implementación viene de <span class="high">SchemaDescribable</span> a través del tipo asociado. Añadir una migración nueva al test es una sola línea.

### SchemaAssertions — consultas SQL para verificación

El helper <span class="high">SchemaAssertions</span> ejecuta queries directas sobre el catálogo de <span class="high">PostgreSQL</span> y devuelve los resultados como tipos Swift:

```swift
enum SchemaAssertions {
    static func schemaExists(_ name: String, on db: Database) async throws -> Bool
    static func tables(in schema: String, on db: Database) async throws -> [String]
    static func columns(for table: String, in schema: String, on db: Database) async throws -> [ColumnInfo]
    static func indexes(for table: String, in schema: String, on db: Database) async throws -> [IndexInfo]
    static func foreignKeys(for table: String, in schema: String, on db: Database) async throws -> [ForeignKeyInfo]
    static func uniqueConstraints(for table: String, in schema: String, on db: Database) async throws -> [UniqueInfo]
    static func tablePrivileges(for table: String, in schema: String, on db: Database) async throws -> [PrivilegeInfo]
    static func migrationLog(on db: Database) async throws -> [MigrationLogEntry]
}
```

Cada método consulta las tablas del catálogo de <span class="high">PostgreSQL</span> (<span class="high">information_schema</span>, <span class="high">pg_indexes</span>, <span class="high">pg_constraint</span>) y devuelve structs tipados que puedo comparar directamente con la metadata del modelo.

### El test de ciclo de vida completo

Con las tres piezas anteriores, el test cabe en un único método. Arranca el contenedor, registra las migraciones, ejecuta <span class="high">migrate</span>, verifica toda la estructura, revierte, y verifica que no queda nada:

```swift
@Suite("Migration Lifecycle", .tags(.integration))
struct MigrationLifecycleTests {

    @Test("Full migration lifecycle: migrate → verify → revert → verify")
    func fullLifecycle() async throws {
        try await ensureContainerCLI()

        let pg = PostgresContainer()
        do {
            try await pg.start()

            let hostname = await pg.hostname
            try await withTestFluent(hostname: hostname) {
                let db = try $0.database

                await $0.registerMigrations(target: .development)

                // Migrate
                try await $0.migrate()

                let migrations = allTableMigrations(target: .development)

                // Verify
                try await verifySchemas(on: db)
                try await verifyTablesColumnsAndIndexes(migrations: migrations, on: db)
                try await verifyForeignKeys(migrations: migrations, on: db)
                try await verifyUniqueConstraints(migrations: migrations, on: db)
                try await verifyPermissions(on: db)
                try await verifyMigrationLog(on: db)

                // Revert
                try await $0.revert()

                // Verify cleanup
                try await verifyCleanup(migrations: migrations, on: db)
            }
            try await pg.stop()
        } catch {
            try? await pg.stop()
            throw error
        }
    }
}
```

El flujo es lineal: primero compruebo que el CLI <span class="high">container</span> está disponible, arranco <span class="high">PostgreSQL</span> en un contenedor efímero, conecto <span class="high">Fluent</span> y ejecuto las migraciones. Después verifico cada aspecto de la estructura contra el catálogo real de la base de datos. Finalmente revierto todo y confirmo que no queda ninguna tabla ni esquema residual. El bloque <span class="high">do/catch</span> garantiza que el contenedor se detiene incluso si el test falla.

Cada función de verificación itera sobre las migraciones, castea a <span class="high">MigrationInfo</span> para extraer la metadata del modelo, y la compara con lo que realmente existe en la base de datos. Por ejemplo, así verifico las tablas, columnas e índices:

```swift
private func verifyTablesColumnsAndIndexes(
    migrations: [any Migration], on db: Database
) async throws {
    for migration in migrations {
        guard let info = migration as? any MigrationInfo else { continue }
        let schema = info.modelSchema
        let space = info.modelSpace ?? "public"

        let tables = try await SchemaAssertions.tables(in: space, on: db)
        #expect(tables.contains(schema), "Table '\(schema)' should exist in '\(space)'")

        let columns = try await SchemaAssertions.columns(for: schema, in: space, on: db)
        let columnNames = Set(columns.map(\.name))
        for key in info.modelKeys {
            #expect(
                columnNames.contains(key.description),
                "Missing column '\(key.description)' in \(schema)")
        }

        guard !info.modelIndexes.isEmpty else { continue }
        let indexes = try await SchemaAssertions.indexes(for: schema, in: space, on: db)
        let indexNames = Set(indexes.map(\.name))
        for idx in info.modelIndexes {
            #expect(
                indexNames.contains(idx.name),
                "Missing index '\(idx.name)' on \(schema)")
        }
    }
}
```

Y la verificación de claves foráneas sigue el mismo patrón — itero, extraigo metadata del modelo, consulto el catálogo y comparo:

```swift
private func verifyForeignKeys(
    migrations: [any Migration], on db: Database
) async throws {
    for migration in migrations {
        guard let info = migration as? any MigrationInfo else { continue }
        guard !info.modelForeignKeys.isEmpty else { continue }
        let space = info.modelSpace ?? "public"
        let fks = try await SchemaAssertions.foreignKeys(
            for: info.modelSchema, in: space, on: db)
        let fkColumns = Set(fks.map(\.column))
        for expected in info.modelForeignKeys {
            #expect(
                fkColumns.contains(expected.field.description),
                "Missing FK '\(expected.field)' in \(info.modelSchema)")
            let dbFK = fks.first { $0.column == expected.field.description }
            #expect(
                dbFK?.referencedTable == expected.referencedFullSchema,
                "FK '\(expected.field)' should reference \(expected.referencedFullSchema)")
        }
    }
}
```

Sin un solo string hardcodeado. Si añado un índice al modelo, el test lo verifica automáticamente. Si una migración olvida crear una clave foránea, el test falla con el mensaje exacto de qué falta y dónde.

---

## Mi Resultado 🎯

El ciclo completo — descargar la imagen, arrancar el contenedor <span class="high">PostgreSQL</span> desde cero, migrar, verificar, revertir y eliminar tanto el contenedor como la imagen — tarda alrededor de 52 segundos en local, sin nada previo y sin dejar rastro. Una inversión razonable para garantizar que mi base de datos real coincide exactamente con lo que mi código espera.

- **Verificación real** — contra una base de datos de verdad, no mocks
- **Sin strings hardcodeados** — toda la metadata viene de <span class="high">SchemaDescribable</span>
- **Ciclo completo** — migrate, verify, revert, verify cleanup
- **Efímero** — el contenedor se destruye al terminar, sin estado residual
- **Escalable** — añadir conformancia <span class="high">MigrationInfo</span> a una migración nueva es una línea

<span class="high">SchemaDescribable</span> convierte el modelo en la fuente de verdad. <span class="high">MigrationInfo</span> la hace accesible a los tests. Y el contenedor efímero cierra el ciclo: la estructura que el modelo declara es exactamente la que existe en la base de datos — verificado, no asumido.


**Keep coding, keep running** 🏃‍♂️

---
