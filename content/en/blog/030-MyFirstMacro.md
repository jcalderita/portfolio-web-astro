---
title: My First Macro
slug: my-first-macro
date: 2026-04-01
description: A macro to automatically generate the ID, timestamps, and namespace in every Fluent model.
tags: Swift, Server
cover: MyFirstMacro
coverDescription: Jorge at his desk next to his MacBook, stamping the @ symbol with a rubber stamp onto documents.
publish: true
---
---
## My Problem 🤔

In my project I have dozens of <span class="high">Fluent</span> models, and there is a block of code that repeats in absolutely every single one of them:

```swift
public static let space: String? = "sales"

@ID() public var id: UUID?
public init() {}

@Timestamp(.createdAt, on: .create) public var createdAt: Date?
@Timestamp(.updatedAt, on: .update) public var updatedAt: Date?
@Timestamp(.deletedAt, on: .delete) public var deletedAt: Date?
```

Always the same block. In every model. No exceptions.

The namespace changes, but the structure is identical. With every new model, I copy and paste, adjust the namespace, and hope I don't forget anything. With 30 models, that boilerplate becomes noise that makes it harder for me to read what actually matters: the model's logic.

My solution in Swift for this kind of problem is a <span class="high">macro</span>.

---

## My Solution 🧩

A Swift macro can generate new members in a class or struct at compile time. Exactly what I need. The result I'm looking for is to write this:

```swift
@FluentModel(.sales)
public final class ProductModel: Model {
    public static let schema = "products"

    @Field(.name) public var name: String
}
```

And have the compiler automatically inject <span class="high">space</span>, <span class="high">id</span>, <span class="high">init()</span>, and the three <span class="high">timestamps</span>. Without writing them. Without maintaining them.

### Package structure

Swift macros require two separate targets: the **public interface** (what I consume as a developer) and the **plugin** (the implementation that the compiler executes). In my case, both live in the same <span class="high">Macros</span> package:

- <span class="high">Macros</span> — declares the macro and the <span class="high">DatabaseSpace</span> enum
- <span class="high">MacrosPlugin</span> — implements the expansion with <span class="high">SwiftSyntax</span>

### DatabaseSpace — namespaces as types

Before defining the macro, I need to model the available namespaces. Instead of using loose strings, I decided that the <span class="high">DatabaseSpace</span> enum should make them exhaustive and safe at compile time:

```swift
public enum DatabaseSpace: String, CaseIterable, Sendable {
    case sales, warehouse
}
```

This allows writing <span class="high">@FluentModel(.sales)</span> instead of <span class="high">@FluentModel("sales")</span>. If the namespace doesn't exist, the compiler tells you before anything runs.

### The macro declaration

The public interface of the macro is surprisingly compact:

```swift
@attached(member, names: named(space), named(id), named(init), named(createdAt), named(updatedAt), named(deletedAt))
public macro FluentModel(_ space: DatabaseSpace? = nil) = #externalMacro(
    module: "MacrosPlugin",
    type: "FluentModelMacro"
)
```

The <span class="high">@attached(member, names:)</span> attribute tells the compiler two things: that this macro adds members to the declaration where it's applied, and exactly which names it will generate. Declaring the names is mandatory — Swift needs them to resolve the symbol tree before expanding the macro.

### The implementation — FluentModelMacro

The implementation conforms to the <span class="high">MemberMacro</span> protocol and returns an array of <span class="high">DeclSyntax</span> — fragments of Swift code that the compiler inserts into the model:

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

The <span class="high">expansion</span> method directly returns the array of declarations, with no intermediate variables. Each element is a Swift literal that the compiler injects as-is into the model.

The key is <span class="high">spaceDecl</span>, which encapsulates all the extraction and generation logic in a single method. It navigates the attribute's syntax tree with <span class="high">SwiftSyntax</span> using optional chaining: it accesses the arguments as <span class="high">LabeledExprListSyntax</span>, takes the first expression, casts it to <span class="high">MemberAccessExprSyntax</span> (because the argument is an enum case like <span class="high">.sales</span>), and with <span class="high">.map</span> converts it into a quoted string. If any step in the chain fails, the <span class="high">??</span> operator returns <span class="high">"nil"</span>. Finally, <span class="high">\\(raw:)</span> interpolates the value directly into the <span class="high">DeclSyntax</span>.

Lastly, I need a <span class="high">CompilerPlugin</span> to register the macro — it's the entry point that the compiler loads to know which macros are available:

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

## My Result 🎯

With the macro installed, each model is clean and noise-free:

```swift
@FluentModel(.sales)
public final class ProductModel: Model {
    public static let schema = "products"

    @Field(.name) public var name: String
    @OptionalField(.description) public var description: String?
}
```

The compiler expands <span class="high">@FluentModel(.sales)</span> and automatically generates:

```swift
public static let space: String? = "sales"
@ID() public var id: UUID?
public init() {}
@Timestamp(.createdAt, on: .create) public var createdAt: Date?
@Timestamp(.updatedAt, on: .update) public var updatedAt: Date?
@Timestamp(.deletedAt, on: .delete) public var deletedAt: Date?
```

And if a model doesn't belong to any namespace — like views — you simply omit the argument:

```swift
@FluentModel()
public final class OrderSummaryModel: Model {
    public static let schema = "order_summaries"
}
```

In that case, <span class="high">space</span> is generated as <span class="high">nil</span> and Fluent ignores the schema prefix.

The benefits in numbers: **32 models** with the macro applied. **6 lines removed** per model. Over **190 lines of boilerplate** that no longer exist in the repository and will never need to be maintained again.


**Keep coding, keep running** 🏃‍♂️

---
