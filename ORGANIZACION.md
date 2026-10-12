# Organización mínima del trabajo

Actualizado: 12 de octubre de 2026. Proyecto Godot para un jugador. La segunda vuelta está en diseño; esta organización no autoriza a iniciar su implementación.

## Qué registra cada lugar

| Lugar | Responsabilidad |
|---|---|
| Git | Cambios exactos y recuperación de código/documentación por commit. |
| Etiquetas `vX.Y.Z` | Identificar una entrega jugable concreta y verificada. |
| [CHANGELOG.md](CHANGELOG.md) | Cambios visibles realmente entregados y trabajo realizado aún sin publicar. |
| [DISENO_DEMO.md](DISENO_DEMO.md) | Reglas acordadas, decisiones D, preguntas Q, propuestas y alcance vigente. |
| [PENDIENTES.md](PENDIENTES.md) | Tareas DEMO/FUT, dependencias, estado, aceptación y siguiente paso. |
| [RESULTADO.md](RESULTADO.md) | Evidencia, límites y resultados de la última entrega verificada. |
| [README.md](README.md) | Cómo ejecutar y usar la versión jugable actual. |
| [AGENTS.md](AGENTS.md) | Instrucciones breves para consultar y mantener estos registros al retomar trabajo. |
| Engram, cuando esté conectado | Recuperar contexto mediante recuerdos breves de decisiones, hallazgos y cierres, con referencias a archivos/commits. |

Las nuevas instrucciones del usuario prevalecen. El diseño distingue intención futura de comportamiento existente: una regla documentada no es una función implementada. Los recuerdos externos deben remitirse al repositorio y comprobarse contra su estado vigente.

## Versiones y ramas

| Versión | Commit de entrega | Situación |
|---|---|---|
| 0.1.0 | `138d459` | Misión original verificada. Etiqueta retrospectiva `v0.1.0`. |
| 0.2.0 | `f516f41` | Misión original y duelo táctico verificados. Etiqueta retrospectiva `v0.2.0`; versión jugable actual. |
| 0.3.0 | Aún no existe | Misión unificada y segunda vuelta; planificada, sin etiqueta. |

Convención para este prototipo: `0.MINOR.PATCH`. Incrementar MINOR cuando una entrega añade un conjunto importante de funciones; PATCH para correcciones o ajustes pequeños de una entrega. Los cambios solo de documentación conservan la versión jugable. No crear etiquetas definitivas para funciones meramente acordadas ni reutilizar/mover una etiqueta existente.

La rama actual es `feature/tactical-duel`; hay commits de diseño posteriores a `v0.2.0`, sin cambios de código del juego. `master` conserva la primera entrega. Al iniciar la implementación nueva, usar una rama de trabajo descriptiva desde el estado vigente; no cambiar ahora de rama ni alterar el árbol mientras se estudia o prueba la demo. No imponer GitFlow ni ramas de release adicionales en esta fase.

Las etiquetas y commits son locales. Actualmente no hay remoto configurado. Una copia externa/privada del repositorio queda como tarea organizativa opcional; no se ha publicado ni sincronizado el proyecto. La carpeta del Godot portátil está excluida de Git y debe conservarse o descargarse aparte al preparar otra máquina.

## Inicio de una sesión

1. Leer `AGENTS.md`, diseño y pendientes; comprobar rama, cambios locales y última entrega identificada por etiqueta.
2. Separar el objetivo autorizado de lo que solo está propuesto. Elegir una tarea con ID y un resultado concreto para esta sesión.
3. Consultar las preguntas de esa tarea. Una duda sobre energía no bloquea cámara, interfaz o redacción independientes. Marcar exactamente qué parte espera respuesta.
4. Si Engram está disponible, recuperar contexto del proyecto `ShadowsOfKharuun` y verificarlo contra los documentos actuales.

Durante la fase de diseño actual, seguir con documentación y pruebas de la versión existente solicitadas por el usuario. Comenzar funciones de la segunda vuelta cuando el usuario pida implementarlas.

## Durante el trabajo y al terminar

- Mantener D/Q/DEMO estables; registrar una decisión sustituida y su motivo, en lugar de reabrirla o conservar dos reglas incompatibles.
- Una pregunta importante usa opciones clicables. Una observación pendiente, como Q01 en KOTOR, sigue siendo hipótesis y no pasa a confirmado por falta de respuesta.
- Distinguir componentes parcialmente terminados de los que todavía dependen de otra tarea. Evitar que un criterio de integración exija por adelantado las funciones que se integrarán después.
- Actualizar estados y evidencia tras comprobar el trabajo. Para documentación, revisar coherencia, enlaces y diff; para juego, comprobar los flujos afectados y las reglas relevantes.
- Crear un commit coherente con referencia al ID de tarea cuando corresponda; no mezclar cambios ajenos del usuario. No son obligatorios Conventional Commits ni un changeset por cada cambio.
- Al cerrar, dejar: qué se hizo, qué se verificó, qué sigue abierto y cuál es el próximo paso. El siguiente agente debe poder retomar desde los archivos.
- Añadir al changelog únicamente cambios efectivamente realizados. El trabajo futuro permanece en diseño/pendientes.

## Entrega jugable

Una entrega requiere su alcance cumplido, verificaciones pertinentes, informe actualizado y notas de cambios. Entonces se asigna versión, se crea el commit de entrega y se etiqueta ese commit. No mover las etiquetas retrospectivas al commit que documenta la organización.

Para revisar historial sin modificar archivos:

```powershell
git log --oneline --decorate -10
git tag --list
git show v0.2.0:RESULTADO.md
```

No usar `reset --hard` o restaurar una versión encima de cambios locales para probar una entrega anterior. Preparar un checkout aparte si hace falta compararlas.

## Engram: complemento opcional

Comprobación local de esta sesión: `C:\Users\dedeb\bin\engram.exe`, versión **1.7.1**, con comando MCP por stdio. Sus herramientas `mem_*` no están expuestas aquí; no se ha cambiado la configuración de Codex ni escrito recuerdos en su base de datos.

Recomendación: aprovecharlo como memoria auxiliar al conectarlo, conservando decisiones y tareas en Git. No es una dependencia necesaria para avanzar. Un recuerdo de decisión debe incluir proyecto, ID D/Q, estado confirmado/pendiente, archivo de referencia y commit cuando exista. Guardar hallazgos significativos y un resumen al cerrar; no duplicar toda la especificación ni cada mensaje del chat. Una hipótesis no se guarda como hecho.

Ejemplo preparado para una futura conexión en la configuración de Codex, no aplicado ahora:

```toml
[mcp_servers.engram]
command = 'C:\Users\dedeb\bin\engram.exe'
args = ['mcp', '--tools=agent']
```

El perfil `agent` está confirmado por el `help` de la versión instalada. Al conectarlo, verificar que las herramientas aparecen en una sesión de Codex y pueden recuperar/guardar un recuerdo del proyecto. No considerar una integración probada solo porque el ejecutable esté instalado. No exportar la base global completa ni recuerdos de otros proyectos al repositorio.

## Por qué no Changesets ahora

Este proyecto no tiene paquetes npm ni componentes publicables con versiones coordinadas. Git, etiquetas y un changelog manual cubren la necesidad actual sin añadir un gestor de paquetes o una cadena de publicación. Si más adelante aparecen paquetes o publicaciones que coordinar, se reevaluará.

Referencias: [Changesets](https://github.com/changesets/changesets), [memoria de Engram](https://github.com/Gentleman-Programming/engram/blob/main/docs/codebase/mental-model.md) y [MCP en Codex](https://learn.chatgpt.com/docs/extend/mcp).

## Punto de reanudación actual

- Versión que se puede probar: **0.2.0**; el código no incorpora aún la segunda vuelta.
- Acuerdos confirmados: D01–D20. La oferta del guardián permite combate o paso pacífico y ambos conducen al mismo objetivo del templo.
- Regla principal pendiente: **Q01**, el usuario comprobará en KOTOR qué pasa con una orden sin energía al final o en medio de la cola. No volver a preguntarla mientras espera esa prueba.
- Q02/Q03/Q07 tienen propuestas explícitas en el diseño; revisarlas solo cuando afecten a la tarea siguiente.
- Próximo paso de diseño: incorporar la observación de Q01 cuando llegue. Si el usuario solicita implementar antes, avanzar con las partes independientes y aislar la regla pendiente.
