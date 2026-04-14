---
title: OnlyDNS
slug: only-dns
date: 2026-04-08
description: Cómo desactivar el proxy de Cloudflare y pasar a modo Solo DNS resolvió en 5 minutos el bloqueo de La Liga que arrastraba desde hacía meses.
tags: Web, Cloudflare, DNS
cover: OnlyDNS
coverDescription: Ilustración estilo cómic: Jorge con un gorro de burro de pie frente a un televisor que muestra un partido de fútbol con marcador 2-1, mientras a su derecha un Mac mini con un monitor muestra el texto 'ONLY DNS' en letras grandes.
publish: true
---
---
## Mi Problema 🤔

En el [artículo anterior](/es/blog/la-liga-thanks-es/) hablé de cómo <span class="high">La Liga</span> bloqueaba mi web durante los partidos. Gente intentando visitar mi portfolio y mi blog se encontraba con que la página no cargaba, simplemente porque mi dominio pasaba por la infraestructura de <span class="high">Cloudflare</span>, y <span class="high">La Liga</span> bloqueaba rangos enteros de IPs de <span class="high">Cloudflare</span> para frenar las retransmisiones ilegales.

Lo sabía. Lo documenté. Y me quedé ahí.

Durante meses no hice nada para solucionarlo. No por pereza ni por pensar que fuese complicado — sino por enfado. Mi web funcionaba perfectamente, era <span class="high">La Liga</span> la que aplicaba bloqueos indiscriminados y la dejaba inaccesible. No era culpa mía. Así que me planté: no tenía por qué ser yo quien moviese ficha.

Así que no hice nada. Durante meses.

Lo que pasa es que tenía el proxy de <span class="high">Cloudflare</span> activo — la famosa nube naranja. Mi web está alojada en <span class="high">Cloudflare Pages</span>, así que todo está dentro del ecosistema de <span class="high">Cloudflare</span>. Pero con el proxy activado, el tráfico pasa por la capa de CDN/proxy de <span class="high">Cloudflare</span>, que usa unos rangos de IPs compartidas. Y esos rangos son precisamente los que <span class="high">La Liga</span> bloqueaba.

---

## Mi Solución 🧩

La solución es desactivar el proxy de <span class="high">Cloudflare</span> y pasar al modo <span class="high">Solo DNS</span> — la nube gris.

Con la nube naranja activa, <span class="high">Cloudflare</span> es un "centro comercial": todos los visitantes entran por la puerta de su proxy/CDN, que usa rangos de IPs compartidas con miles de sitios. Son esas IPs las que <span class="high">La Liga</span> bloquea en masa para frenar las retransmisiones ilegales — y mi web queda como daño colateral.

Con la nube gris, <span class="high">Cloudflare</span> pasa a ser solo un "director de tráfico": resuelve el DNS y apunta directamente a <span class="high">Cloudflare Pages</span>. Mi web sigue alojada en <span class="high">Cloudflare</span>, pero el tráfico llega a través de los rangos de IPs de <span class="high">Pages</span> — que son distintos a los del proxy y que <span class="high">La Liga</span> no tiene en su lista de bloqueo.

El proceso en el panel de <span class="high">Cloudflare</span> es este:

1. Entrar en el panel de <span class="high">Cloudflare</span> y navegar a **DNS > Registros (Records)**.
2. Buscar los registros que apuntan a la web — normalmente un registro **A** o **CNAME** con el nombre del dominio.
3. En la columna **Estado del proxy**, hacer clic en el interruptor con la nube naranja para convertirla en una nube gris (**Solo DNS**).
4. Guardar los cambios.

El cambio propaga en minutos. A partir de ese momento, el tráfico llega por una ruta distinta dentro de <span class="high">Cloudflare</span> — una que no está en el punto de mira de los bloqueos de <span class="high">La Liga</span>.

Como mi web es estática y sigue alojada en <span class="high">Cloudflare Pages</span>, no noto prácticamente ninguna diferencia de velocidad. Pierdo algunas funciones de la capa proxy — como el firewall a nivel de CDN o la caché en sus edge nodes — pero para una web estática de portfolio esas ventajas son marginales comparadas con el beneficio de que la web funcione para todo el mundo durante los partidos.

---

## Mi Resultado 🎯

Mi web ya carga durante los partidos de <span class="high">La Liga</span>. Cualquier persona que intente visitar mi portfolio o blog mientras suena el himno de la Champions no se va a encontrar con una pantalla en blanco.

Cinco minutos. Un clic. Meses de problema resuelto.

La lección que me llevo no es técnica — es pragmática. Tuviese razón o no, mi problema o lo solucionaba yo o no lo iba a solucionar nadie. Y creo que tengo razón: mi web no tiene por qué ser daño colateral de los bloqueos de <span class="high">La Liga</span>. Gracias, <span class="high">La Liga</span>.

**Keep coding, keep running** 🏃‍♂️

---
