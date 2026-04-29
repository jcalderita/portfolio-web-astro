---
title: SIGBUS
slug: sigbus
date: 2026-04-29
description: How Swift Testing crashes with SIGBUS when formatting errors from enums with associated values, and how I fixed it with three custom helpers.
tags: Swift, Testing
cover: SIGBUS
coverDescription: Comic-style illustration. On the left, Jorge in front of a cracked mirror, wearing an orange shirt and blue shorts, with a panicked expression. On the right, his reflection inside the mirror with the colors swapped — blue shirt and orange shorts — also horrified. The mirror has a central impact point with radial cracks and shards of glass falling to the floor. It represents the SIGBUS bug in Swift Testing: when values don't match, the runtime tries to use Mirror to describe the difference and the mirror shatters.
publish: true
---
---
## My Problem 🤔

I'm writing tests with <span class="high">Swift Testing</span>, Apple's native stack. I compare two models with <span class="high">#expect(a == b)</span> and verify errors with <span class="high">#expect(throws: MyError.self)</span> — the API the library ships with out of the box. I run the tests. And my binary dies with this:

```text
*** Signal 10: Backtracing from 0x18a3c4e8c... done ***
Process terminated by signal 10 (SIGBUS)
Stack trace:
  ...
  _swift_buildDemanglingForMetadata
  ...
  swift_testing.Issue.record(...)
```

<span class="high">SIGBUS</span>. It's not an assertion failure. It's the **Swift runtime** breaking inside the test runner itself. And it only happens when a test **fails** — if everything passes, I never notice the problem.

The pattern is very specific. The runtime crashes when I use <span class="high">#expect(==)</span> on <span class="high">enums with associated values</span>, or when I use <span class="high">#expect(throws:)</span> on an error type that is an enum with associated values. As soon as the test fails, swift-testing tries to build the error message by asking the runtime to reconstruct the type metadata of the values it compared. And there it blows up: <span class="high">_swift_buildDemanglingForMetadata</span>, signal 10, end of story.

It's bug [swiftlang/swift#76608](https://github.com/swiftlang/swift/issues/76608), open since September 2024 and reproducible on Swift 6.3.1 on macOS 26 — both in debug and release.

The curious thing is that the happy path never touches this bug. If the comparison passes, there's no error message to format, no <span class="high">Mirror</span>, no SIGBUS. The bug only shows up exactly when you need the test output the most: when something fails. And I couldn't move a single piece forward until I solved it.

---

## My Solution 🧩

The key clue is **where** swift-testing crashes: on the *failure message* path, formatting the values. If I do the comparison myself and only pass swift-testing a <span class="high">Bool</span>, there's nothing for it to reconstruct. No metadata to reflect on. The mirror doesn't break because it's never used.

The trick that avoids the SIGBUS fits in two lines:

```swift
let isEqual = actual == expected
#expect(isEqual)
```

That's the whole idea. I compute the equality myself, swift-testing only receives an already-resolved <span class="high">Bool</span>. With no values to reflect on, there's no <span class="high">Mirror</span>, no SIGBUS. The price is losing the values in the failure message — but I get that back by formatting the text by hand before passing it to <span class="high">Issue.record</span>.

From there I built a <span class="high">TestKit</span> package with three helpers that apply the same idea to the three cases where I was tripping over the bug:

- <span class="high">expectEqual(actual, expected)</span> — comparison of any <span class="high">Equatable</span>: structs, models, enums with associated values. Replaces <span class="high">#expect(a == b)</span> across every test in the monorepo.
- <span class="high">expectThrows(E.self) { ... }</span> — verifies that a closure throws an error of the expected type. It does <span class="high">do/catch</span> by hand and checks with <span class="high">catch is E</span> — only the type, never the value. Covers what <span class="high">#expect(throws:)</span> tried to provide out of the box. Has both sync and async overloads.
- <span class="high">expectEqualLines(actual, expected)</span> — line-by-line diff for verifying generated SQL and other inline snapshots. The comparison is also reduced to <span class="high">Bool</span> before touching the reporter.

Three helpers, one single idea: **compute the result outside the macro, pass only the boolean**. When Swift 6.4 eventually closes [issue 76608](https://github.com/swiftlang/swift/issues/76608), I just have to swap the body of the helpers for direct <span class="high">#expect</span> calls and the suite won't even notice.

There's one extra detail to keep failure messages readable: I conformed the error and schema types to <span class="high">CustomStringConvertible</span> with a static <span class="high">switch</span> over the cases — **never interpolating <span class="high">\(self)</span>**, because that would invoke <span class="high">Mirror</span> again and reopen the trap.

---

## My Result 🎯

My test suite runs again without SIGBUS and with reasonably readable failure messages. The rule I now apply across the monorepo:

- <span class="high">expectEqual(a, b)</span> for any comparison between structs, enums or models
- <span class="high">expectThrows(E.self) { ... }</span> to verify the type of error thrown
- <span class="high">#expect(...)</span> directly only when the argument is already <span class="high">Bool</span>, <span class="high">nil</span> or <span class="high">contains</span> — there's no value metadata to reflect on, and the bug is not triggered

The benefits:

- **A suite that doesn't crash** — failures count as failures, not as process aborts
- **Minimal stack** — I only depend on <span class="high">Testing</span> and Swift's own toolchain
- **Custom messages** — I control how each side is printed on failure, thanks to <span class="high">CustomStringConvertible</span>
- **Runtime bug isolation** — when Swift 6.4 fixes it, I just swap the body of the helpers and the suite won't even notice

The lesson I'm taking away: when a runtime tool breaks on the error path, the solution isn't to give up on the language, it's to keep the tool from going down that path. I do the comparison myself, I pass a boolean to the reporter, and the mirror stays intact.


**Keep coding, keep running** 🏃‍♂️

---
