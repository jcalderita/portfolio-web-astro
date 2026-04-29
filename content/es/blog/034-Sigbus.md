---
title: SIGBUS
slug: sigbus
date: 2026-04-29
description: Cómo Swift Testing crashea con SIGBUS al formatear errores de enums con valores asociados, y cómo lo solucioné con tres helpers propios.
tags: Swift, Testing
cover: SIGBUS
coverDescription: Ilustración estilo cómic. A la izquierda, Jorge frente a un espejo agrietado, con camiseta naranja y pantalón corto azul, expresión de pánico. A la derecha, su reflejo dentro del espejo con la ropa de los colores invertidos — camiseta azul y pantalón naranja — también horrorizado. El espejo tiene un punto de impacto central del que salen grietas radiales y caen trozos de cristal al suelo. Representa el bug SIGBUS de Swift Testing: cuando los valores no coinciden, el runtime intenta usar Mirror para describir la diferencia y el espejo se hace añicos.
publish: true
---
---
## Mi Problema 🤔

Estoy escribiendo tests con <span class="high">Swift Testing</span>, el stack nativo de Apple. Comparo dos modelos con <span class="high">#expect(a == b)</span> y verifico errores con <span class="high">#expect(throws: MyError.self)</span> — la API que la propia librería ofrece de serie. Lanzo los tests. Y mi binario muere con esto:

```text
*** Signal 10: Backtracing from 0x18a3c4e8c... done ***
Process terminated by signal 10 (SIGBUS)
Stack trace:
  ...
  _swift_buildDemanglingForMetadata
  ...
  swift_testing.Issue.record(...)
```

<span class="high">SIGBUS</span>. No es un fallo de aserción. Es el **runtime de Swift** rompiéndose dentro del propio test runner. Y solo pasa cuando un test **falla** — si todos pasan, no me entero del problema.

El patrón es muy concreto. El runtime crashea cuando uso <span class="high">#expect(==)</span> sobre <span class="high">enums con valores asociados</span>, o cuando uso <span class="high">#expect(throws:)</span> sobre un tipo de error que es un enum con valores asociados. En cuanto el test falla, swift-testing intenta construir el mensaje de error pidiéndole al runtime que reconstruya los metadatos de tipo de los valores que comparó. Y ahí truena: <span class="high">_swift_buildDemanglingForMetadata</span>, signal 10, fin.

Es el bug [swiftlang/swift#76608](https://github.com/swiftlang/swift/issues/76608), abierto desde septiembre de 2024 y reproducible en Swift 6.3.1 sobre macOS 26 — tanto en debug como en release.

Lo curioso es que el camino feliz no toca nunca este bug. Si la comparación pasa, no hay mensaje de error que formatear, no hay <span class="high">Mirror</span>, no hay SIGBUS. El bug solo aparece justo cuando más necesitas el output del test: cuando algo falla. Y no podía mover una pieza hasta resolverlo.

---

## Mi Solución 🧩

La pista clave es **dónde** crashea swift-testing: en el camino del *failure message*, formateando los valores. Si yo hago la comparación por mi cuenta y le paso al reporter solamente un <span class="high">Bool</span>, swift-testing no tiene nada que reconstruir. No hay metadata que reflejar. El espejo no se rompe porque no se llega a usar.

El truco que evita el SIGBUS cabe en dos líneas:

```swift
let isEqual = actual == expected
#expect(isEqual)
```

Esa es toda la idea. La igualdad la calculo yo, swift-testing solo recibe un <span class="high">Bool</span> ya resuelto. Sin valores que reflejar, no hay <span class="high">Mirror</span>, no hay SIGBUS. El precio es perder los valores en el mensaje de fallo — pero eso lo recupero formateando el texto a mano antes de pasarlo a <span class="high">Issue.record</span>.

A partir de ahí monté un paquete <span class="high">TestKit</span> con tres helpers que aplican esa misma idea para los tres casos en los que tropezaba con el bug:

- <span class="high">expectEqual(actual, expected)</span> — comparación de cualquier <span class="high">Equatable</span>: structs, modelos, enums con valores asociados. Sustituye a <span class="high">#expect(a == b)</span> en todos los tests del monorepo.
- <span class="high">expectThrows(E.self) { ... }</span> — verifica que un closure lanza un error del tipo esperado. Hace <span class="high">do/catch</span> a mano y comprueba con <span class="high">catch is E</span> — solo el tipo, nunca el valor. Cubre lo que <span class="high">#expect(throws:)</span> intentaba dar de serie. Tiene overload sync y async.
- <span class="high">expectEqualLines(actual, expected)</span> — diff línea a línea para verificar SQL generado y otros snapshots inline. La comparación también se reduce a <span class="high">Bool</span> antes de tocar el reporter.

Tres helpers, una sola idea: **calcular el resultado fuera del macro, pasar solo el booleano**. Cuando algún día Swift 6.4 cierre [el issue 76608](https://github.com/swiftlang/swift/issues/76608), basta con sustituir el cuerpo de los helpers por <span class="high">#expect</span> directos y la suite ni se entera.

Hay un detalle adicional para que los mensajes de fallo sigan siendo legibles: conformé los tipos de error y schema a <span class="high">CustomStringConvertible</span> con un <span class="high">switch</span> estático sobre los casos — **nunca interpolando <span class="high">\(self)</span>**, porque eso volvería a invocar <span class="high">Mirror</span> y reabriría la trampa.

---

## Mi Resultado 🎯

Mi suite de tests vuelve a correr sin SIGBUS y con mensajes de error suficientemente legibles. La regla que aplico ahora en todo el monorepo:

- <span class="high">expectEqual(a, b)</span> para cualquier comparación entre structs, enums o modelos
- <span class="high">expectThrows(E.self) { ... }</span> para verificar el tipo de error lanzado
- <span class="high">#expect(...)</span> directo solo cuando el argumento ya es <span class="high">Bool</span>, <span class="high">nil</span> o <span class="high">contains</span> — ahí no hay metadata de valores que reflejar y el bug no se dispara

Los beneficios:

- **Suite que no crashea** — los fallos cuentan como fallos, no como abortos del proceso
- **Stack mínimo** — solo dependo de <span class="high">Testing</span> y del propio toolchain de Swift
- **Mensajes propios** — controlo cómo se imprime cada lado al fallar, gracias a <span class="high">CustomStringConvertible</span>
- **Aislamiento del bug del runtime** — cuando Swift 6.4 lo solucione, basta con cambiar el cuerpo de los helpers y la suite ni se entera

La lección que me llevo: cuando una herramienta del runtime se rompe en el camino del error, la solución no es renunciar al lenguaje, es no dejar que la herramienta entre por ese camino. Hago yo la comparación, le paso un booleano al reporter, y el mirror se queda intacto.


**Keep coding, keep running** 🏃‍♂️

---
