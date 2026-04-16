---
title: Migrate Spaces
slug: migrate-spaces
date: 2026-03-14
description: How to automate PostgreSQL namespace creation using FluentKit migrations in Vapor, replacing error-prone manual setup with versioned, reversible code.
tags: Swift, Vapor
cover: MigrateSpaces
coverDescription: Jorge managing namespaces in a PostgreSQL database from Swift code.
publish: true
---
---
## 🧩 Problem

In the previous article about [Schemas and Spaces](/en/blog/schema-space-en) we saw how to assign a namespace to a model using the <span class="high">space</span> property. Many of you asked the same question: **how are those spaces created in the database?** 🤔

The most common answer was to do it manually, running a <span class="high">CREATE SCHEMA</span> in the PostgreSQL console before launching the migrations. It works, but it breaks something fundamental: if the database doesn't exist or the environment is new, **the process fails** before reaching the actual migrations 💥.

The other problem is that managing namespaces manually doesn't scale. As soon as you have multiple environments (development, staging, production) or a team, keeping that manual sync becomes a source of silent errors 😬.

---

## 💡 Solution

The solution is to turn namespace creation into just another <span class="high">migration</span>. This way, it runs automatically in the correct order, is reversible, and is versioned alongside the rest of the code ✅.

The key lies in combining <span class="high">FluentKit</span> with <span class="high">SQLKit</span>. FluentKit manages the migration lifecycle, but to execute arbitrary SQL we need to access the underlying driver through the <span class="high">SQLDatabase</span> protocol. To keep the code organized, we encapsulate the namespaces in an enum with an action that determines whether they are created or dropped:

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

Some important details 📋:

- **SRSchema** as **CaseIterable**: by iterating over <span class="high">allCases</span>, we ensure all defined spaces are created without having to list them manually in the migration. Adding a new space only requires adding a case to the enum 🔄.
- **Action**: the inner enum models the two possible operations (<span class="high">create</span> and <span class="high">drop</span>), allowing the same <span class="high">execute</span> method to be reused in both the migration's <span class="high">prepare</span> and <span class="high">revert</span> ♻️.
- **Switch expression**: a Swift *switch expression* is used to select the SQL template based on the action. Each branch returns a closure that generates the corresponding statement, keeping the logic compact and readable 🧹.
- **CREATE SCHEMA IF NOT EXISTS**: makes the migration idempotent. If the schema already exists, it doesn't fail — it simply continues 🛡️.
- **DROP SCHEMA ... RESTRICT**: in the <span class="high">revert</span>, the <span class="high">RESTRICT</span> modifier prevents dropping a schema that contains tables. It's a safety net that avoids accidental data loss when reverting 🔒.
- **unsafeRaw**: used to interpolate the schema name directly into the SQL. It's safe here because the value comes from our own enum, never from external input ⚠️.

---

## 📊 Result

This migration must be the **first** one registered ☝️. Before creating any table, the namespaces need to exist. In the migration runner, the order looks like this:

```swift
fluent.migrations.add(
    SchemasMigration()
)
```

When running migrations in a new environment, the entire process is automatic ⚡:

And if at any point you need to add a new domain, you just add a case to the <span class="high">SRSchema</span> enum and the next time migrations run, the schema appears. **No touching the database manually, no extra documentation to maintain** 🎯.


**Keep coding, keep running** 🏃‍♂️

---
