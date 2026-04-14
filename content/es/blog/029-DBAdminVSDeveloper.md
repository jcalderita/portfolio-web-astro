---
title: DB Admin vs Dev
slug: db-admin-vs-developer
date: 2026-03-23
description: Separar la administración de base de datos del desarrollo no es una opinión: es una responsabilidad.
tags: DataBase
cover: DBAdminVSDeveloper
coverDescription: Un desarrollador satisfecho diseñando esquemas, tablas y vistas en su mundo estructurado, mientras en el fondo ocurre el caos típico de la administración: cache miss, bucles infinitos de queries y sobrecarga del administrador.
publish: true
---
---
## El problema 🤔

En muchos proyectos he visto cómo el código de la aplicación termina haciendo cosas que no le corresponden: crear roles, configurar parámetros del servidor de base de datos, gestionar permisos a nivel de instancia. Todo mezclado en el mismo sitio, como si fuera una sola responsabilidad.

Pero no lo es. La base de datos tiene **dos mundos distintos**: la <span class="high">administración</span> 🛡️ y el <span class="high">desarrollo</span> 💻.

Mezclarlos es uno de los errores más comunes, y también uno de los más costosos 💸. Un desarrollador que configura la instancia desde su código está cruzando una frontera que no le corresponde. Y un administrador que intenta decidir qué tablas o esquemas usa la aplicación está haciendo lo mismo desde el otro lado.

---

## La idea 🧩

La separación es conceptualmente limpia: **la administración pertenece al servidor, el desarrollo pertenece al código**.

### El territorio del administrador 🛡️

El administrador gestiona la **instancia** de la base de datos. Su trabajo incluye:

- 🔧 **Configuración del servidor** — parámetros de rendimiento, extensiones a nivel de instancia, ajustes que requieren reinicio
- 👤 **Roles y credenciales** — crear usuarios, asignar contraseñas seguras, definir quién puede conectarse
- 🗄️ **Bases de datos** — crearlas, establecer timeouts, revocar accesos por defecto

Todo esto es infraestructura 🔐. Son decisiones que se toman una vez, las ejecuta alguien con permisos de superusuario, y no tienen nada que ver con la lógica de negocio. Lo ideal es que vivan como scripts SQL versionados en el repositorio, pero separados del código de la aplicación.

### El territorio del desarrollador 💻

El desarrollador gestiona la **estructura de datos de la aplicación**: esquemas, tablas, índices, vistas, y todo lo que necesita existir para que la aplicación funcione.

Esta responsabilidad se expresa a través de <span class="high">migraciones</span> ✨ — piezas de código versionadas, reversibles y revisables como cualquier otro cambio. Da igual si usas Swift, Python, Go o TypeScript: el principio es el mismo. La estructura de datos de tu aplicación debe poder reproducirse automáticamente en cualquier entorno 🔄.

### La zona gris: ¿admin o desarrollo? 🤷

Hay casos que parecen ambiguos. Los roles de base de datos son un buen ejemplo. El **rol en sí** — con su contraseña y permisos de conexión — es un concepto de infraestructura. Lo crea el administrador 🛡️.

Pero los **permisos sobre tablas concretas** — qué puede leer, qué puede escribir, sobre qué esquema — eso depende del desarrollador 💻. La tabla tiene que existir antes de que pueda tener permisos, así que esos permisos van en las migraciones, no en scripts de infraestructura.

La regla que yo aplico es sencilla: si el objeto existe **antes** que la aplicación, es administración. Si su existencia **depende** de que la aplicación lo cree, es desarrollo ✅.

---

## El resultado 🎯

Cuando aplicas esta separación, el proceso de puesta en marcha queda claro y reproducible:

1. 🛡️ El administrador prepara la instancia → servidor configurado, roles creados, base de datos lista
2. 💻 El desarrollador ejecuta las migraciones → esquemas, tablas y permisos de aplicación aplicados automáticamente

Cada capa tiene su herramienta. El administrador no toca el código de la aplicación. El desarrollador no necesita credenciales de superusuario 🔒. Nadie pisa el territorio del otro.

Esta separación también facilita el trabajo en equipo 🤝: los scripts de administración los ejecuta quien tiene acceso al servidor, una sola vez. Las migraciones las ejecuta cualquier desarrollador del equipo en su entorno local, tantas veces como necesite.

**La base de datos no es solo tuya como desarrollador. Pero la estructura de datos de tu aplicación, sí.** 🏗️


**Keep coding, keep running** 🏃‍♂️

---
