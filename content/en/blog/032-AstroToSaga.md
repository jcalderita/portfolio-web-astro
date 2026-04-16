---
title: Astro to Saga
slug: astro-to-saga
date: 2026-04-15
description: Why I migrated my portfolio from Astro to Saga, a static site generator written in Swift, and how I removed Node from my stack for good.
tags: Swift, Astro, Saga
cover: AstroToSaga
coverDescription: Jorge sailing a Viking ship named Saga through stormy waves, with shields of Swift, HTML5, CSS3, Markdown and Saga on the hull, representing the portfolio migration to a native Swift stack.
publish: true
---
---
## My Problem 🤔

My portfolio was running on <span class="high">Astro</span> with <span class="high">Bun</span>. Everything worked fine. Fast, comfortable, no technical complaints.

But something didn't feel right. Every time I opened the project I found a <span class="high">package.json</span>, a <span class="high">tailwind.config</span>, an <span class="high">astro.config</span>, and a <span class="high">node_modules</span> folder with hundreds of dependencies I didn't even know existed. That feeling of losing control over what lives inside your own project bothers me. I like to know what my code runs and why it's there.

And at the end of the day, I'm a Swift developer. My daily work is Swift. Yet to generate my own portfolio I depended on a completely foreign ecosystem. If someone visited my repository, they wouldn't see a Swift developer. They'd see just another JavaScript project.

The question was simple: if I trust Swift for everything else, why don't I trust Swift for this?

---

## My Solution 🧩

I stopped to think about what I actually needed. My portfolio is not a web application. It has no state and no complex interactivity. It's a set of static HTML pages generated from Markdown. I don't need React, Vue, or hydration. I need something that reads Markdown, transforms it into HTML, and writes it to disk.

I found [Saga](https://github.com/loopwerk/Saga), a static site generator written in Swift. Deliberately minimalist: it reads files, applies transformations, and writes HTML. What it doesn't include, you decide. It also features hot reload for development, something I didn't expect to find in such a small project. That philosophy convinced me more than any feature list.

| Advantages | Disadvantages |
|---|---|
| Entire stack in Swift — one language, no context switching | Small ecosystem — if something doesn't exist, you build it yourself |
| Compiler-verified HTML thanks to the typed DSL | Learning curve with the DSL syntax |
| Native image pipeline with no external dependencies | Image pipeline only works on macOS |
| Node removed from the local environment | Limited community and documentation |
| Full control over every dependency in the project | More upfront work for features that come out of the box in other frameworks |

### The underlying reflection

The decision wasn't technical. It was about coherence. I want anyone visiting my repository to see Swift. I'm not saying <span class="high">Astro</span> is bad — it's excellent. But my portfolio is my business card, and that card has to speak about me.

---

## My Result 🎯

The site you're reading right now is generated with <span class="high">Saga</span>, compiled with Swift, and deployed on <span class="high">Cloudflare Workers</span> without Node ever touching my machine.

What surprised me wasn't the technical outcome. It was the feeling of coherence. Opening my portfolio and seeing that everything, from the first line to the last deploy, is Swift gives me a sense of calm that's hard to explain.

If you're a Swift developer and your portfolio runs on Node, I'm not saying you should change. I'm saying it's worth asking yourself why. In the end, the tool you choose to present yourself says something about you. I chose the one that represents me.

**Keep coding, keep running** 🏃‍♂️

---
