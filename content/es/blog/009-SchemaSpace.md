---
title: Esquemas y Espacios
slug: schema-space
date: 2025-10-06
description: Aprende a usar la propiedad space en los modelos Fluent de Vapor para organizar tablas en namespaces, y evita un sutil bug en la declaración de tipo opcional.
tags: Swift, Vapor
cover: SchemaSpace
coverDescription: Jorge sentado programando pensando en Schemas y Spaces
publish: true
---
---
## Esquema y Espacio de Nombres

Al definir un modelo de datos en Vapor, es posible especificar el <span class="high">schema</span>, que corresponde al nombre de la tabla en la base de datos. Sin embargo, para mantener una arquitectura organizada, es recomendable agrupar las tablas en diferentes espacios de nombres según criterios funcionales, en lugar de concentrarlas todas en el esquema predeterminado. Esta práctica facilita la separación lógica por dominios o módulos de la aplicación.

---

## Implementación

Para asignar una tabla a un espacio de nombres específico, se debe sobrescribir la propiedad estática <span class="high">space</span> en el modelo. Esta propiedad permite definir el namespace donde residirá la tabla, proporcionando una organización más granular de la estructura de base de datos.

```swift
public final class LocationCityModel: Model {
    public static let schema = "cities"
    public static let space: String? = "location"

    @ID() public var id: UUID?
    @Field(.name) public var name: String

    public init() { }
}
```

---

## Consideración

Es fundamental declarar la propiedad <span class="high">space</span> como tipo <span class="high">String?</span> **(opcional)**. Si se declara como <span class="high">String</span> **(no opcional)**, no se sobrescribirá la propiedad heredada del protocolo <span class="high">Model</span>, sino que se creará una nueva propiedad con el mismo nombre. Esto ocasionará que el framework ignore la configuración del espacio de nombres, manteniendo las tablas en el esquema predeterminado sin indicación de error aparente.

Si te preguntas cómo crear estos espacios de nombres automáticamente en la base de datos, explico cómo convertirlo en una migración en [Migrate Spaces](/es/blog/migrate-spaces/).

**Keep coding, keep running** 🏃‍♂️

---
