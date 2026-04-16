---
title: Async Concurrent Map
slug: async-concurrent-map
date: 2026-01-21
description: How to combine concurrent processing with chunking to optimize resource usage in massive asynchronous operations.
tags: Swift, Vapor
cover: AsyncConcurrentMap
coverDescription: Jorge organizing multiple shoe boxes in groups to process them efficiently.
publish: true
---
---
## Problem

In backend applications with <span class="high">Vapor</span>, when we process **large volumes of data** concurrently, we face an optimization dilemma:

- **Sequential processing** with <span class="high">asyncMap</span>: guarantees resource control, but is **slow** by processing elements one by one.
- **Fully concurrent processing** with <span class="high">concurrentMap</span>: maximizes speed, but can **saturate resources** by launching thousands of simultaneous tasks.

For example, when processing 10,000 records with external API calls:
- <span class="high">asyncMap</span>: 10,000 sequential calls → very slow but controlled.
- <span class="high">concurrentMap</span>: 10,000 simultaneous calls → very fast but can exhaust connections/memory.

We need a solution that **combines both approaches**: divide the work into manageable groups and process each group concurrently, balancing speed and resource usage.

---

## Solution

We extend <span class="high">Collection</span> with a function that combines **chunking** (division into groups) and **concurrent processing**, allowing configuration of chunk size and timeout per chunk.

```swift
extension Collection where Element: Sendable {
    func asyncConcurrentMap<T: Sendable>(
        chunkSize: Int? = nil,
        timeout: Double? = nil,
        _ transform: @escaping @Sendable (Element) async throws -> T
    ) async throws -> [T] {
        guard let chunkSize else {
            return try await concurrentMap(transform)
        }

        return try await chunks(ofCount: chunkSize)
            .asyncMap(timeout: timeout) {
                try await $0.concurrentMap(transform)
            }.flatMap { $0 }
    }
}
```

Key points:
- If <span class="high">chunkSize</span> is not specified, uses pure <span class="high">concurrentMap</span> (fully concurrent processing).
- If <span class="high">chunkSize</span> is specified, divides the collection into groups with <span class="high">chunks(ofCount:)</span>.
- Processes the **chunks sequentially** with <span class="high">asyncMap</span> (with optional timeout).
- Within each chunk, processes the elements **concurrently** with <span class="high">concurrentMap</span>.
- Flattens the results with <span class="high">flatMap</span> to return a unified array.

---

## Result

```swift
// Process 10,000 records in chunks of 100
// 100 concurrent tasks at a time, 100 times
let results = try await records.asyncConcurrentMap(
    chunkSize: 100,
    timeout: 30.0
) { record in
    try await apiClient.process(record)
}
```

Benefits of this approach:

⚡ **Perfect balance**: combines the speed of concurrent processing with the control of sequential processing by chunks.<br />
🎯 **Resource control**: limits the number of simultaneous tasks to the chunk size, avoiding saturation.<br />
⏱️ **Timeout per chunk**: detects and handles problematic chunks without blocking all processing.<br />
🔧 **Full flexibility**: use chunking when you need it, or pure concurrent processing when you don't.<br />
📊 **Scalability**: allows processing millions of records by adjusting chunk size according to available resources.

If you need pure parallel execution, I covered that in [Concurrent Map](/blog/concurrent-map/). And if your sequential chunks need rate limiting between them, I added that capability in [Async Map Timeout](/blog/async-map-timeout/).

This solution is the **natural evolution** of <span class="high">asyncMap</span> and <span class="high">concurrentMap</span>, combining the best of both worlds to optimize massive data processing in backend applications.


**Keep coding, keep running** 🏃‍♂️

---
