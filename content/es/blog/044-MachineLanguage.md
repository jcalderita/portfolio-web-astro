---
title: Machine Language
slug: machine-language
date: 2026-07-08
description: Cómo los dispositivos se comunican entre ellos en el mundo de la IA y por qué el output compacto con jq -c ahorra tokens sin perder información.
tags: AI, Shell
cover: MachineLanguage
coverDescription: Ilustración en estilo cómic de Jorge con camiseta naranja rodeado de dispositivos Apple —iMac, MacBook, iPhones y Apple Watches— conectados entre sí mediante cadenas de unos y ceros que forman un círculo a su alrededor, mientras mira desconcertado con signos de interrogación sobre su cabeza.
publish: false
---
---
## Mi Problema 🤔

Trabajo con agentes de IA de forma habitual. En algún momento empecé a notar que pasaba mucho tiempo pensando en cómo presentar la información: qué formato enviar, cómo estructurar el output, si conviene indentar el JSON para que sea legible. El instinto natural, el mismo que tenemos cuando escribimos código, es producir salida bonita. Salida que un humano pueda leer de un vistazo.

El problema es que en un flujo orientado a IA **no hay humano leyendo ese output**. Lo lee una máquina. Y a esa máquina el espacio en blanco no le aporta comprensión — le cuesta tokens.

Me lo hizo ver un caso concreto. Tenía un script que consultaba una API y pasaba el resultado a un modelo. El JSON venía indentado, con claves descriptivas, bien estructurado. Perfecto para que yo lo leyera. Pero yo no lo estaba leyendo — lo leía el modelo. Y cada salto de línea, cada tabulación, cada espacio de indentación era un token que el modelo pagaba antes de llegar al dato real.

---
## Mi Solución 🧩

La solución fue separar dos conceptos que llevaba tiempo mezclando: el lenguaje de los humanos y el lenguaje de las máquinas.

### Dos audiencias, dos formatos

Cuando dos dispositivos se hablan entre ellos, no necesitan que el mensaje sea bonito. No se formatea el JSON. Se comprime al mínimo. Lo entienden igual, porque la información es idéntica.

El mismo principio aplica cuando el destinatario es un modelo de IA. Un modelo que recibe JSON compacto y uno que recibe JSON indentado extraen exactamente la misma información. Pero el segundo paga más tokens por el privilegio de leer espacios.

La regla que empecé a aplicar es directa: si el output lo consume una máquina, lo comprimo. Si lo leo yo — en el debug, en el log de desarrollo — lo indento.

### jq -c en la práctica

La diferencia entre los dos mundos cabe en un flag. Con <span class="high">jq</span>, la opción <span class="high">-c</span> produce output compacto — sin saltos de línea, sin indentación, todo en una sola línea. La información es idéntica. Los tokens, no.

```bash
# Salida para humanos — lo que usaría en el debug
curl -s https://api.example.com/products | jq '.'
```

```json
{
  "id": "prod_123",
  "name": "Widget Pro",
  "status": "active",
  "price": 49.99,
  "inventory": {
    "available": 142,
    "reserved": 8
  }
}
```

```bash
# Salida para máquinas — lo que pasa al modelo
curl -s https://api.example.com/products | jq -c '.'
```

```json
{"id":"prod_123","name":"Widget Pro","status":"active","price":49.99,"inventory":{"available":142,"reserved":8}}
```

El modelo entiende ambos. Pero el segundo usa bastantes menos tokens.

### Seleccionar solo lo necesario

<span class="high">jq -c</span> también permite filtrar antes de comprimir. Si el modelo solo necesita el identificador y el estado, no tiene sentido enviarle el inventario completo:

```bash
# Solo los campos que el modelo necesita procesar
curl -s https://api.example.com/products \
  | jq -c '{id: .id, status: .status}'
```

```json
{"id":"prod_123","status":"active"}
```

El ahorro aquí es doble: menos tokens de formato y menos tokens de contenido. Si la respuesta de la API tiene cincuenta campos y el modelo solo usa tres, enviar los cincuenta es regalar cuarenta y siete campos de contexto que no aportan nada a la tarea.

### El momento del debug es diferente

Esta separación no significa que tenga que renunciar a la legibilidad cuando la necesito. El debug sigue siendo para mí. Cuando algo falla, cuando quiero inspeccionar el dato antes de pasarlo al modelo, uso la salida indentada:

```bash
# Inspeccionando antes de pasarlo al modelo
response=$(curl -s https://api.example.com/orders)

# Debug: lo leo yo
echo "$response" | jq '.'

# Producción: lo lee el modelo
payload=$(echo "$response" | jq -c '{id: .id, total: .total, items: [.items[].id]}')
send_to_model "$payload"
```

La variable <span class="high">payload</span> que viaja al modelo es compacta. La salida que aparece en mi terminal durante el debug es legible. Son dos vistas del mismo dato para dos audiencias distintas.

### El mismo patrón en scripts de CI

En mis scripts de CI donde los agentes encadenan llamadas, aplico el mismo principio. Cada paso produce output compacto que el siguiente paso consume directamente:

```bash
# Obtener lista de recursos pendientes
pending=$(curl -s "$API_URL/queue" \
  | jq -c '[.items[] | select(.status == "pending") | {id: .id, type: .type}]')

# Pasar directamente al agente que procesa
process_with_agent "$pending"
```

Sin el <span class="high">-c</span>, ese array de objetos vendría con saltos de línea y sangría. Con él, es una sola cadena que el agente consume de una vez. El agente no pierde información — gana eficiencia.

---
## Mi Resultado 🎯

El cambio de mentalidad es pequeño pero el efecto se acumula. Cada vez que un script pasa datos a un modelo, la diferencia entre output compacto e indentado puede ser del 20% al 40% en tokens dependiendo de la profundidad del JSON. En llamadas puntuales es insignificante. En flujos que encadenan varias llamadas, o en agentes que procesan lotes, ese porcentaje se convierte en coste real.

Lo que empecé a aplicar de forma sistemática:

- **Output para modelos siempre compacto** — <span class="high">jq -c</span> como opción por defecto cuando el destinatario es una máquina
- **Filtrar antes de enviar** — solo los campos que el modelo necesita, no la respuesta completa de la API
- **Debug indentado, producción compacto** — dos vistas del mismo dato para dos audiencias distintas
- **El código sí tiene que ser legible** — el output no necesita serlo

La clave es que los dispositivos no necesitan que el mensaje sea bonito para entenderse. Llevan décadas hablándose en binario sin que ninguno pida que el otro lo formatee mejor. Los modelos de IA son la misma historia: entienden el dato, no el formato. Dárselo compacto es respetarles el tiempo — y el coste.

Este enfoque conecta con lo que ya exploraba en [Save Tokens](/es/blog/save-tokens/): mover el trabajo determinista fuera del modelo. Formatear JSON es trabajo determinista. Lo hace <span class="high">jq</span>. El modelo se queda con la parte que solo él puede hacer.

**Keep coding, keep running** 🏃‍♂️

---
