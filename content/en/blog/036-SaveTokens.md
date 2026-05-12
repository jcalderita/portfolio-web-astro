---
title: Save Tokens
slug: save-tokens
date: 2026-05-13
description: How to cut tokens in Claude Code by moving the bash logic of your skills into reusable scripts that the AI invokes with a single line.
tags: AI, Swift
cover: SaveTokens
coverDescription: Illustration of Jorge coding on his laptop while a row of golden tokens marked with the letter T falls from the screen into a piggy bank, next to a notebook labeled Skills /scripts save.sh and a window in the background showing runners in the park.
publish: true
---
---
## My Problem 🤔

I work with <span class="high">Claude Code</span> every day and started to notice a pattern that caught my attention: every time a skill or a conversation needed to run something in the shell, the AI burned tokens before executing anything. It reasoned about which command to build, drafted it, launched it, read the output, and then interpreted it to keep working.

In a one-off operation, that cost is barely noticeable. The real problem shows up the moment there is **repetition**. A skill that iterates over several files, a conversation that reorganizes directories, a flow that needs to perform the same operation with different arguments — all of that multiplies the reasoning cost by each iteration. Every loop pass rebuilds a command that, at heart, is identical to the previous one except for a single parameter.

And here is the key point: that reasoning is **deterministic work** dressed up as reasoning. I am not asking the AI to decide anything — only to rewrite a command it has already written before. It is exactly the kind of task a script solves better than a model.

---

## My Solution 🧩

The idea is simple: if a skill or a flow needs to run shell logic, that logic should not live in the AI's head — it should live in a <span class="high">.sh</span> file that the AI invokes with a single line.

### The mental shift

The natural instinct when configuring a skill is to describe step by step what the AI has to do:

> List the files in the directory, filter the ones ending in <span class="high">.json</span>, read each one, extract the <span class="high">version</span> field, find the largest, and return it.

That description forces the AI to build each command, execute it, interpret the output, and chain the next step. Instead, the instruction should be:

> Run the script <span class="high">latest-version</span> /path.

The difference is that all the reasoning about **how** the operation is done stops happening on every invocation. It happens just once, when you write the script. From then on, the AI only needs to know **what** to run and **what format** to expect back.

### Why loops are the critical case

The savings show up even in one-off operations, but they become **huge** when the skill iterates. Without a script, every loop pass pays the cost of reasoning and building the command. With a script, the AI fires a single invocation and gets back the full aggregate.

The practical rule I apply: if the operation can be aggregated in a single shell step, the script should do it — not the AI iterating externally.

### The structure I use in my skills

Each of my skills follows the same shape: a short <span class="high">SKILL.md</span> describing the contract, and a <span class="high">scripts/</span> folder with the packaged logic.

```
~/.claude/skills/
└── my-skill/
    ├── SKILL.md          ← instructions for the AI (what to run, what to expect)
    └── scripts/
        ├── operation-a.zsh
        └── operation-b.zsh
```

Every time the skill needs a new capability, I add a script instead of adding inline bash instructions. The skill gains functionality without bloating the context the AI has to process on every invocation.

> I use <span class="high">.zsh</span> because I work on macOS, where it has been the default shell since Catalina and lets me take advantage of features bash does not have. The pattern works exactly the same with <span class="high">.sh</span> and bash. Pick the one that matches your environment.

And one important detail: I write the scripts with the help of the AI itself, just once. That reasoning — designing the right command, handling the edge cases, returning the proper JSON — happens while creating the script. After that, the work stays **crystallized** in the file and is never paid for again.

---

## My Result 🎯

The change is directly observable as soon as you separate deterministic logic from reasoning. The AI shifts from building commands to consuming them. From interpreting variable outputs to reading structured JSON. From iterating externally to receiving the full aggregate in a single call.

The concrete benefits I am seeing:

- **Fewer tokens per invocation** — the reasoning about how to perform the operation happens just once, when writing the script, not every time the skill runs
- **Consistency** — the script always returns the same format; the AI does not interpret variable outputs on every execution
- **Maintainability** — when the logic changes, I edit the script in one place; the <span class="high">SKILL.md</span> is not touched
- **Scalability in loops** — the script aggregates before returning; one call replaces N iterations
- **Simpler skills** — the <span class="high">SKILL.md</span> describes **what** to do, not **how**; operational complexity lives in the scripts

The pattern applies to any skill or flow that has to operate on the filesystem, process structured text, or run repetitive logic. If you find yourself describing in the <span class="high">SKILL.md</span> a sequence of bash commands the AI should build and execute, that sequence should probably be a script.

As I explored in the article on [Claude Code](/blog/claude-code/), the key is not to give the AI more reasoning capacity so it solves more things — it is to structure the work so that it **only reasons where it adds value**. The deterministic part is solved by a script. The creative and contextual part is solved by the AI. Each in its place.

**Keep coding, keep running** 🏃‍♂️

---
