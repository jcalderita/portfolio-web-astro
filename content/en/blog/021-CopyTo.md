---
title: Copy To
slug: copy-to
date: 2026-01-07
description: Export large datasets from PostgreSQL to CSV in Vapor using the native COPY TO command, avoiding manual serialization and reducing memory consumption.
tags: Swift, Vapor
cover: CopyTo
coverDescription: Many sneakers falling on Jorge when opening the closet.
publish: true
---
---
## Problem

In backend applications with <span class="high">Vapor</span>, we often need to **export large volumes of data** from the database to files for different purposes: backups, offline analysis, integration with external systems, or data audits.

Using traditional queries with <span class="high">Fluent</span> and then manually serializing the results presents several drawbacks:
- **High memory consumption**: loading thousands of records into memory to process them one by one.
- **Slow processing**: manual serialization to <span class="high">CSV</span> requires iterating and formatting each record.
- **Lack of optimization**: doesn't leverage the native export capabilities of the database engine.
- **Unnecessary complexity**: manual management of formats, character escaping, and null value handling.

For bulk export scenarios, we need a strategy that leverages <span class="high">PostgreSQL</span>'s native capabilities to generate files efficiently.

---

## Solution

We extend <span class="high">Database</span> with a function that executes the <span class="high">COPY ... TO</span> command from <span class="high">PostgreSQL</span>, allowing data export directly from the table schema to <span class="high">CSV</span> files in the filesystem.

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

Key points:
- Uses <span class="high">PostgreSQL</span>'s <span class="high">COPY ... TO</span>, the most efficient method for bulk exports.
- The <span class="high">model.space</span> parameter supports custom schemas (defaults to <span class="high">"public"</span>).
- <span class="high">model.schema</span> automatically obtains the table name from the <span class="high">Fluent</span> model.
- Standard <span class="high">CSV</span> configuration: headers included, delimiters, and proper null value handling.
- Uses <span class="high">unsafeRaw</span> for direct interpolation in the SQL query.

---

## Result

```swift
func exportRegions() async throws {
    try await db.exportCSV(
        LocationRegionModel.self,
        file: file
    )
}
```

Benefits of this approach:

🚀 **Optimal performance**: <span class="high">COPY ... TO</span> is much faster than manual serialization.<br />
💾 **Resource efficiency**: <span class="high">PostgreSQL</span> writes directly to the file without loading data into application memory.<br />
📦 **Consistent format**: the database engine guarantees a valid <span class="high">CSV</span> with proper escaping.<br />
🔧 **Native integration**: leverages optimized capabilities of the <span class="high">PostgreSQL</span> engine.<br />
📊 **Scalability**: allows exporting millions of records without impacting application performance.

This solution is the perfect complement to <span class="high">importCSV</span>, forming a pair of functions that enables **bidirectional data movement** between <span class="high">PostgreSQL</span> and the filesystem efficiently and reliably. If you haven't seen the import side yet, I explain how to build it using PostgreSQL's `COPY FROM` in [Copy From](/blog/copy-from/).

**Keep coding, keep running** 🏃‍♂️

---
