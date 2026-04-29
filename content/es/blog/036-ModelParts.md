---
title: Model Parts
slug: model-parts
date: 2026-05-13
description: Cómo centralizar índices, claves foráneas y restricciones únicas en el propio modelo para que las migraciones y los tests hablen el mismo idioma.
tags: Swift, Server, DataBase
cover: ModelParts
coverDescription: Jorge como sastre sosteniendo una camiseta deportiva frente a un maniquí, con prendas apiladas en una silla a su lado, representando cómo se ensamblan las piezas de un modelo (índices, claves foráneas, restricciones únicas) para dar forma a la estructura final de la base de datos.
publish: false
---
---
## Mi Problema 🤔

Cuando escribo migraciones con <span class="high">Fluent</span>, los índices, las claves foráneas y las restricciones únicas se definen dentro del método <span class="high">prepare</span> de la migración. Pertenecen a la migración, no al modelo.

```swift
func prepare(on db: Database) async throws {
    try await db.schema("products")
        .id()
        .field(.externalId, .string, .required)
        .field(.categoryId, .uuid, .references("categories", "id", onDelete: .cascade, onUpdate: .cascade))
        .unique(on: .externalId)
        .create()
}
```

El problema es que esa información **no es legible fuera de la migración**. Forma parte de un método que se ejecuta una vez y no expone nada al resto del código. Cuando quiero escribir un test de integración que verifique que la migración creó los índices correctos, ¿de dónde saco los nombres esperados? Los tengo que repetir como strings en el test. Y cuando quiero verificar que las claves foráneas existen, lo mismo: strings hardcodeados, acoplados a lo que esté dentro del <span class="high">prepare</span>.

Mi modelo sabe qué tabla representa. Mi modelo sabe qué campos tiene. Pero no sabe nada de su propia estructura de base de datos: índices, referencias, unicidad. Esa información pertenece a la migración, y la única forma de acceder a ella es ejecutándola.

---

## Mi Solución 🧩

Mi idea es convertir el modelo en la **única fuente de verdad** para toda la metadata estructural de su tabla. Creé un protocolo <span class="high">SchemaDescribable</span> que extiende <span class="high">Model</span> de <span class="high">Fluent</span> con tres propiedades estáticas: índices, claves foráneas y restricciones únicas.

```swift
protocol SchemaDescribable: Model {
    static var indexes: [IndexDefinition] { get }
    static var foreignKeys: [ForeignKeyDefinition] { get }
    static var uniques: [UniqueDefinition] { get }
}
```

Cada tipo de constraint tiene su propio tipo con factory methods que hacen la declaración legible y segura. La conformancia la declaro en la capa de base de datos, no en el modelo compartido:

```swift
extension ProductModel: SchemaDescribable {
    static var indexes: [IndexDefinition] {
        [
            .btree("idx_products_sku", [.sku]),
            .btree("idx_products_category_id", [.categoryId]),
            .btree("idx_products_brand_id", [.brandId]),
            .btree("idx_products_supplier_id", [.supplierId]),
            .btree("idx_products_warehouse_id", [.warehouseId]),
            .btree("idx_products_parent_id", [.parentId]),
            .lower("idx_products_name_prefix", .name),
        ]
    }

    static var foreignKeys: [ForeignKeyDefinition] {
        [
            .references(.parentId, on: ProductModel.self),
            .references(.categoryId, on: CategoryModel.self),
            .references(.brandId, on: BrandModel.self),
            .references(.supplierId, on: SupplierModel.self),
            .references(.warehouseId, on: WarehouseModel.self),
        ]
    }

    static var uniques: [UniqueDefinition] { [.on(.externalId)] }
}
```

Cada modelo declara de forma explícita todos sus índices <span class="high">B-Tree</span>, sus claves foráneas y sus restricciones únicas. Los factory methods como <span class="high">.btree</span>, <span class="high">.lower</span>, <span class="high">.references</span> y <span class="high">.on</span> hacen que la declaración sea compacta y difícil de equivocar.

Con las definiciones en el modelo, la migración se limita a aplicarlas. Un método <span class="high">addConstraints(for:)</span> sobre <span class="high">SchemaBuilder</span> añade las claves foráneas y las restricciones únicas, y <span class="high">createIndexes</span> genera los índices — todo a partir de lo que el modelo declara:

```swift
struct CreateProducts: AsyncMigration, MigrationProtocol {
    typealias ModelType = ProductModel
    let target: DeployTarget

    func prepare(on db: Database) async throws {
        try await db.schema(model)
            .id(default: true)
            .field(.externalId, .string, .required)
            .field(.name, .string, .required)
            .field(.sku, .string, .required)
            .field(.price, .double, .required)
            .field(.weight, .double)
            .field(.stock, .int)
            .field(.parentId, .uuid)
            .field(.categoryId, .uuid)
            .field(.brandId, .uuid)
            .field(.supplierId, .uuid)
            .field(.warehouseId, .uuid)
            .timestamps(default: true)
            .addConstraints(for: model)
            .create()

        try await createIndexes(on: db)
    }

    func revert(on db: Database) async throws {
        try await db.schema(model).delete()
    }
}
```

La migración ya no contiene ninguna definición de constraint. Solo declara los campos y delega toda la estructura de índices, foreign keys y uniques al modelo a través de <span class="high">addConstraints(for:)</span> y <span class="high">createIndexes</span>. El protocolo <span class="high">MigrationProtocol</span> proporciona estos métodos gracias al <span class="high">typealias ModelType</span>, que conecta la migración con su modelo y permite acceder a las definiciones de <span class="high">SchemaDescribable</span>.

---

## Mi Resultado 🎯

Ahora los índices, claves foráneas y restricciones únicas son **propiedades del modelo**, no código enterrado en una migración. Cualquier parte de mi proyecto puede leerlas.

El beneficio más inmediato son las migraciones limpias. Pero el que me compensa a futuro es que **los tests pueden hablar directamente con el modelo** — en un próximo artículo veremos cómo aprovecho esto para escribir tests de integración que verifican la estructura de la base de datos sin un solo string hardcodeado.

- **Un solo sitio** donde leer toda la metadata estructural de cada modelo
- **Migraciones sin repetición** — <span class="high">addConstraints(for: model)</span> aplica todo de un paso
- **Cambios localizados** — añadir un índice o FK solo toca la conformancia del modelo

La clave es reconocer que un modelo no es solo un contenedor de campos: es también la descripción completa de su tabla. <span class="high">SchemaDescribable</span> hace explícito lo que antes estaba implícito — y pertenecía solo a la migración.


**Keep coding, keep running** 🏃‍♂️

---
