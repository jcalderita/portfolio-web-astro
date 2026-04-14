---
title: DB Admin vs Dev
slug: db-admin-vs-developer
date: 2026-03-23
description: Separating database administration from development is not an opinion: it's a responsibility.
tags: DataBase
cover: DBAdminVSDeveloper
coverDescription: A satisfied developer designing schemas, tables, and views in his structured world, while in the background the typical chaos of administration unfolds: cache misses, infinite query loops, and an overloaded administrator.
publish: true
---
---
## The problem 🤔

In many projects I've seen how application code ends up doing things it shouldn't: creating roles, configuring database server parameters, managing instance-level permissions. Everything mixed in the same place, as if it were a single responsibility.

But it's not. The database has **two distinct worlds**: <span class="high">administration</span> 🛡️ and <span class="high">development</span> 💻.

Mixing them is one of the most common mistakes, and also one of the most expensive 💸. A developer configuring the instance from their code is crossing a boundary that doesn't belong to them. And an administrator trying to decide which tables or schemas the application uses is doing the same from the other side.

---

## The idea 🧩

The separation is conceptually clean: **administration belongs to the server, development belongs to the code**.

### The administrator's territory 🛡️

The administrator manages the database **instance**. Their work includes:

- 🔧 **Server configuration** — performance parameters, instance-level extensions, settings that require a restart
- 👤 **Roles and credentials** — creating users, assigning secure passwords, defining who can connect
- 🗄️ **Databases** — creating them, setting timeouts, revoking default access

All of this is infrastructure 🔐. These are decisions made once, executed by someone with superuser privileges, and they have nothing to do with business logic. Ideally, they live as versioned SQL scripts in the repository, but separate from the application code.

### The developer's territory 💻

The developer manages the **application's data structure**: schemas, tables, indexes, views, and everything that needs to exist for the application to work.

This responsibility is expressed through <span class="high">migrations</span> ✨ — versioned, reversible, and reviewable pieces of code like any other change. It doesn't matter if you use Swift, Python, Go, or TypeScript: the principle is the same. Your application's data structure must be automatically reproducible in any environment 🔄.

### The gray area: admin or development? 🤷

There are cases that seem ambiguous. Database roles are a good example. The **role itself** — with its password and connection permissions — is an infrastructure concept. The administrator creates it 🛡️.

But **permissions on specific tables** — what it can read, what it can write, on which schema — that depends on the developer 💻. The table has to exist before it can have permissions, so those permissions go in migrations, not in infrastructure scripts.

The rule I apply is simple: if the object exists **before** the application, it's administration. If its existence **depends** on the application creating it, it's development ✅.

---

## The result 🎯

When you apply this separation, the setup process becomes clear and reproducible:

1. 🛡️ The administrator prepares the instance → server configured, roles created, database ready
2. 💻 The developer runs the migrations → schemas, tables, and application permissions applied automatically

Each layer has its own tool. The administrator doesn't touch the application code. The developer doesn't need superuser credentials 🔒. Nobody steps on the other's territory.

This separation also makes teamwork easier 🤝: the administration scripts are run by whoever has server access, just once. The migrations are run by any developer on the team in their local environment, as many times as needed.

**The database is not yours alone as a developer. But the data structure of your application is.** 🏗️


**Keep coding, keep running** 🏃‍♂️

---
