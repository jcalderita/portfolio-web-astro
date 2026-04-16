---
title: ¡Gracias, La Liga!
slug: la-liga-thanks
date: 2025-08-18
description: Cómo La Liga bloquea mi web durante los partidos por medidas antipiratería que afectan a sitios legítimos en Cloudflare.
tags: Web, Astro
cover: LaLiga
coverDescription: “¡Gracias, La Liga!” Un programador futbolista intenta marcar gol en la portería de su web, que es—literalmente—un muro de ladrillos.
publish: true
---
---
## Mi web bloqueada en partidos de La Liga

Si estás intentando visitar mi web durante un partido de La Liga y no carga, no te lo estás imaginando: en realidad, está siendo bloqueada.

En España, **La Liga aplica medidas antipiratería muy agresivas**, y una de ellas consiste en **bloquear el acceso a sitios web alojados en la red de Cloudflare** durante los partidos en directo. Desafortunadamente, esto significa que si tu web está alojada en Cloudflare —como la mía— puedes verte afectado aunque no estés emitiendo ni distribuyendo ningún contenido ilegal.

Cloudflare protege y acelera millones de sitios web en todo el mundo, pero debido a la política de La Liga, **rangos enteros de IP o nodos CDN pueden ser incluidos en listas negras**, lo cual afecta a **innumerables webs legítimas**.

## ¿Por qué sucede esto?

- La Liga utiliza sistemas automatizados y bloqueos a nivel DNS para restringir el acceso a lo que considera fuentes potenciales de piratería.
- Cloudflare es utilizado por todo tipo de sitios, incluidos aquellos que sí albergan retransmisiones ilegales —por lo que sus IPs se marcan.
- Como resultado, muchas **webs inocentes se bloquean** durante los partidos, simplemente por compartir infraestructura.

## ¿Qué puedes hacer?

- Si estás en España y no puedes acceder a mi portfolio durante un partido, vuelve a intentarlo más tarde.
- Si te pica la curiosidad, existen herramientas online para comprobar si un dominio está siendo bloqueado.
- O puedes usar una VPN para evitar temporalmente la restricción (solo para visitar mi portfolio, claro 😅).

Es un ejemplo frustrante de cómo una aplicación excesiva de medidas digitales puede dañar la web abierta —incluso portfolios pequeños como el mío.

*”¡Gracias, La Liga!”*

**Actualización:** Finalmente encontré una solución sencilla para este problema. Si quieres saber cómo lo resolví en 5 minutos, lee [Only DNS](/es/blog/only-dns/).

**Keep coding, keep running** 🏃‍♂️

---
