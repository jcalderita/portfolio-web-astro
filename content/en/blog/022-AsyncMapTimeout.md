---
title: Async Map Timeout
slug: async-map-timeout
date: 2026-01-14
description: Updating asyncMap to add rate limiting control through timeouts between operations.
tags: Swift, Vapor
cover: AsyncMapTimeout
coverDescription: Jorge running on a treadmill, pausing briefly between each step to control the pace.
publish: true
---
---
## Problem

In the [post about AsyncMap](/blog/async-map/) we saw how to process collections in a **sequential asynchronous** manner. However, when working with **external APIs** that implement rate limiting, we face a critical problem:

```swift
// Process 1000 URLs sequentially
let results = try await urls.asyncMap { url in
    try await apiClient.fetch(url)  // ⚠️ 1000 calls without pause
}
// Error 429: Too Many Requests
```

Making consecutive calls without pauses can:
- **Exceed rate limits**: APIs reject with <span class="high">429 Too Many Requests</span>.
- **Saturate external services**: overload of simultaneous connections.
- **Waste resources**: forcing retries consumes more time and bandwidth.
- **Temporary blocks**: some APIs block the IP after multiple violations.

We need a way to **control the pace** of sequential operations, adding intentional pauses between each processing.

---

## Solution

We update <span class="high">asyncMap</span> by adding an optional <span class="high">timeout</span> parameter that introduces a configurable pause after processing each element.

```swift
extension Sequence {
    func asyncMap<T>(
        timeout: Double? = nil,
        _ transform: (Element) async throws -> T
    ) async throws -> [T] {
        var results = [T]()
        results.reserveCapacity(underestimatedCount)
        for element in self {
            try await results.append(transform(element))
            if let timeout {
                try await Task.sleep(for: .seconds(timeout))
            }
        }
        return results
    }
}
```

**Key changes from the original version**:

✨ Optional and backward-compatible <span class="high">timeout: Double? = nil</span> parameter.<br />
⏱️ If timeout is specified, adds <span class="high">Task.sleep(for: .seconds(timeout))</span> after each element.<br />
🔄 Maintains original behavior when timeout is not specified (no pauses).<br />
📊 Allows dynamic rate limiting adjustment according to each API's limits.

---

## Result

```swift
// Rate limiting: 1 call per second
let results = try await urls.asyncMap(timeout: 1.0) {
    try await apiClient.fetch($0)
}

// Aggressive rate limiting: 1 call every 5 seconds
let results = try await endpoints.asyncMap(timeout: 5.0) {
    try await scraper.parse($0)
}

// Without timeout: original behavior (maximum speed)
let results = try await localFiles.asyncMap {
    try await processFile($0)
}
```

Benefits of this update:

⏱️ **Configurable rate limiting**: controls the call pace according to each API's limits.<br />
🛡️ **Block prevention**: avoids <span class="high">429</span> errors and temporary IP suspensions.<br />
🔄 **Full backward compatibility**: without timeout it works exactly as before.<br />
🎯 **Flexibility per use case**: adjusts timeout based on external service tolerance.<br />
📊 **Predictable processing**: easily calculate total time (n elements × timeout).

This update turns <span class="high">asyncMap</span> into a **complete tool for controlled sequential processing**, ideal for integration with APIs that impose rate limits and need a regulated request flow.


**Keep coding, keep running** 🏃‍♂️

---
