---
title: My First Macro
slug: my-first-macro
date: 2026-04-01
description: Macro para generar automáticamente el ID, los timestamps y el espacio de nombres en cada modelo Fluent.
tags: Swift, Server
cover: MyFirstMacro
coverDescription: Jorge en su escritorio junto a su MacBook, estampando el símbolo @ con un sello sobre unos documentos.
publish: true
---
---
## Mi Problema 🤔

En mi proyecto tengo decenas de modelos <span class="high">Fluent</span>, y hay un bloque de código que se me repite en absolutamente todos ellos:

```swift
public static let space: String? = "sales"

@ID() public var id: UUID?
public init() {}

@Timestamp(.createdAt, on: .create) public var createdAt: Date?
@Timestamp(.updatedAt, on: .update) public var updatedAt: Date?
@Timestamp(.deletedAt, on: .delete) public var deletedAt: Date?
```

Siempre el mismo bloque. En cada modelo. Sin excepción.

El espacio de nombres cambia, pero la estructura es idéntica. Con cada modelo nuevo, copio y pego, ajusto el espacio y espero no olvidarme de nada. Con 30 modelos, ese boilerplate se convierte en ruido que me dificulta leer lo que realmente importa: la lógica del modelo.

Mi solución en Swift para este tipo de problemas es una <span class="high">macro</span>.

---

## Mi Solución 🧩

Una macro de Swift puede generar miembros nuevos en una clase o struct en tiempo de compilación. Exactamente lo que necesito. El resultado que busco es escribir esto:

```swift
@FluentModel(.sales)
public final class ProductModel: Model {
    public static let schema = "products"

    @Field(.name) public var name: String
}
```

Y que el compilador inyecte automáticamente <span class="high">space</span>, <span class="high">id</span>, <span class="high">init()</span> y los tres <span class="high">timestamps</span>. Sin escribirlos. Sin mantenerlos.

### Estructura del paquete

Las macros en Swift requieren dos targets separados: la **interfaz pública** (lo que consumo como desarrollador) y el **plugin** (la implementación que ejecuta el compilador). En mi caso, ambos viven en el mismo paquete <span class="high">Macros</span>:

- <span class="high">Macros</span> — declara la macro y el enum <span class="high">DatabaseSpace</span>
- <span class="high">MacrosPlugin</span> — implementa la expansión con <span class="high">SwiftSyntax</span>

### DatabaseSpace — los espacios como tipos

Antes de definir la macro, necesito modelar los espacios de nombres disponibles. En lugar de usar strings sueltos, decidí que el enum <span class="high">DatabaseSpace</span> los haga exhaustivos y seguros en tiempo de compilación:

```swift
public enum DatabaseSpace: String, CaseIterable, Sendable {
    case sales, warehouse
}
```

Esto permite escribir <span class="high">@FluentModel(.sales)</span> en lugar de <span class="high">@FluentModel("sales")</span>. Si el espacio no existe, el compilador lo dice antes de ejecutar nada.

### La declaración del macro

La interfaz pública de la macro es sorprendentemente compacta:

```swift
@attached(member, names: named(space), named(id), named(init), named(createdAt), named(updatedAt), named(deletedAt))
public macro FluentModel(_ space: DatabaseSpace? = nil) = #externalMacro(
    module: "MacrosPlugin",
    type: "FluentModelMacro"
)
```

El atributo <span class="high">@attached(member, names:)</span> le dice al compilador dos cosas: que esta macro añade miembros a la declaración donde se aplica, y cuáles son los nombres exactos que va a generar. Declarar los nombres es obligatorio — Swift los necesita para resolver el árbol de símbolos antes de expandir la macro.

### La implementación — FluentModelMacro

La implementación conforma el protocolo <span class="high">MemberMacro</span> y devuelve un array de <span class="high">DeclSyntax</span> — fragmentos de código Swift que el compilador inserta en el modelo:

```swift
import SwiftSyntax
import SwiftSyntaxMacros

public struct FluentModelMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        [
            spaceDecl(from: node),
            "@ID() public var id: UUID?",
            "public init() {}",
            "@Timestamp(.createdAt, on: .create) public var createdAt: Date?",
            "@Timestamp(.updatedAt, on: .update) public var updatedAt: Date?",
            "@Timestamp(.deletedAt, on: .delete) public var deletedAt: Date?",
        ]
    }

    private static func spaceDecl(from node: AttributeSyntax) -> DeclSyntax {
        let value = node.arguments?.as(LabeledExprListSyntax.self)?
            .first?.expression.as(MemberAccessExprSyntax.self)
            .map { "\"\($0.declName.baseName.text)\"" } ?? "nil"
        return "public static let space: String? = \(raw: value)"
    }
}
```

El método <span class="high">expansion</span> devuelve directamente el array de declaraciones, sin variables intermedias. Cada elemento es código Swift literal que el compilador inyecta tal cual en el modelo.

La clave está en <span class="high">spaceDecl</span>, que encapsula toda la lógica de extracción y generación en un solo método. Navega el árbol sintáctico del atributo con <span class="high">SwiftSyntax</span> usando optional chaining: accede a los argumentos como <span class="high">LabeledExprListSyntax</span>, toma la primera expresión, la castea a <span class="high">MemberAccessExprSyntax</span> (porque el argumento es un caso de enum como <span class="high">.sales</span>) y con <span class="high">.map</span> lo convierte en un string entrecomillado. Si cualquier paso de la cadena falla, el operador <span class="high">??</span> devuelve <span class="high">"nil"</span>. Finalmente, <span class="high">\\(raw:)</span> interpola el valor directamente en el <span class="high">DeclSyntax</span>.

Por último, necesito un <span class="high">CompilerPlugin</span> que registre la macro — es el punto de entrada que el compilador carga para saber qué macros están disponibles:

```swift
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FluentModelMacro.self,
    ]
}
```

---

## Mi Resultado 🎯

Con la macro instalada, cada modelo queda limpio y sin ruido:

```swift
@FluentModel(.sales)
public final class ProductModel: Model {
    public static let schema = "products"

    @Field(.name) public var name: String
    @OptionalField(.description) public var description: String?
}
```

El compilador expande <span class="high">@FluentModel(.sales)</span> y genera automáticamente:

```swift
public static let space: String? = "sales"
@ID() public var id: UUID?
public init() {}
@Timestamp(.createdAt, on: .create) public var createdAt: Date?
@Timestamp(.updatedAt, on: .update) public var updatedAt: Date?
@Timestamp(.deletedAt, on: .delete) public var deletedAt: Date?
```

Y si un modelo no pertenece a ningún espacio de nombres — como las vistas — simplemente se omite el argumento:

```swift
@FluentModel()
public final class OrderSummaryModel: Model {
    public static let schema = "order_summaries"
}
```

En ese caso, <span class="high">space</span> se genera como <span class="high">nil</span> y Fluent ignora el prefijo de esquema.

Los beneficios en números: **32 modelos** con la macro aplicada. **6 líneas eliminadas** por modelo. Más de **190 líneas de boilerplate** que ya no existen en el repositorio y que nunca más habrá que mantener.


**Keep coding, keep running** 🏃‍♂️

---
