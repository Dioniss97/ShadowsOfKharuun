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
| GitHub Issues | Seguimiento operativo de tareas y milestone; enlaces y resumen local en `PENDIENTES.md`, detalles y aceptación en los MD. |
| Engram | Memoria local auxiliar: recuperar decisiones, hallazgos y cierres con referencias a archivos/commits. MCP/plugin configurados; recargar Codex para cargar herramientas y hooks. |

Las nuevas instrucciones del usuario prevalecen. El diseño distingue intención futura de comportamiento existente: una regla documentada no es una función implementada. Los recuerdos externos deben remitirse al repositorio y comprobarse contra su estado vigente.

## Versiones y ramas

| Versión | Commit de entrega | Situación |
|---|---|---|
| 0.1.0 | `138d459` | Misión original verificada. Etiqueta retrospectiva `v0.1.0`. |
| 0.2.0 | `f516f41` | Misión original y duelo táctico verificados. Etiqueta retrospectiva `v0.2.0`; versión jugable actual. |
| 0.3.0 | Aún no existe | Misión unificada y segunda vuelta; planificada, sin etiqueta. |

Convención para este prototipo: `0.MINOR.PATCH`. Incrementar MINOR cuando una entrega añade un conjunto importante de funciones; PATCH para correcciones o ajustes pequeños de una entrega. Los cambios solo de documentación conservan la versión jugable. No crear etiquetas definitivas para funciones meramente acordadas ni reutilizar/mover una etiqueta existente.

La rama local actual es `feature/tactical-duel`; hay commits de diseño y entorno posteriores a `v0.2.0`, sin cambios de código del juego. El remoto tiene `main` como rama predeterminada con el estado vigente y conserva `feature/tactical-duel` y `master`; esta última identifica el estado de la primera entrega. Al iniciar la implementación nueva, usar una rama descriptiva desde `origin/main`; no cambiar ahora de rama ni alterar el árbol mientras se estudia o prueba la demo. No imponer GitFlow ni ramas de release adicionales en esta fase.

Remoto privado: [Dioniss97/ShadowsOfKharuun](https://github.com/Dioniss97/ShadowsOfKharuun), `origin = https://github.com/Dioniss97/ShadowsOfKharuun.git`. El usuario confirmó la cuenta autenticada con dos «s». Historial y etiquetas `v0.1.0`/`v0.2.0` están subidos. La prueba SSH devolvió `Permission denied (publickey)`; HTTPS con GitHub CLI autenticado funciona, sin modificar claves SSH ni el protocolo global de Git.

La carpeta del Godot portátil está excluida de Git y debe conservarse o descargarse aparte al preparar otra máquina. Memoria global, credenciales, ejecutables, descargas y copias de seguridad no se suben al repositorio.

## Backlog en GitHub

Milestone: [Demo 0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/1). Los 13 issues DEMO tienen dependencias, resultado esperado y verificación basada en el diseño. Al crearlos, DEMO-01 lleva `pendiente-decision` y los demás `planificado`; todos están abiertos y sin implementar.

Los issues siguen el avance operativo; `PENDIENTES.md` conserva el resumen local y los enlaces. Al cambiar estado o cerrar una tarea, actualizar ambos, añadir evidencia/commit al issue y mantener el acuerdo detallado en `DISENO_DEMO.md`. Si GitHub no está disponible, registrar el avance local y señalar la sincronización pendiente. Las FUT pospuestas permanecen en los MD, sin crear tarjetas fuera del alcance actual.

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

## Engram: integración local preparada

Ejecutable: `C:\Users\dedeb\bin\engram.exe`, actualizado de **1.7.1 a 3.3.2 estable**. Archivo oficial `engram_3.3.2_windows_amd64.zip`, SHA256 verificado: `e00afe91d1baade484d217606d78c2fd91e26a4f9823b603d050c1e4be78233c`.

Antes de actualizar se respaldaron base SQLite, ejecutable anterior y configuración de Codex. La prueba de migración sobre copia pasó `quick_check` y preservó 50 sesiones, 129 observaciones y 2 prompts; después se comprobó que todos sus IDs siguen presentes en la base real. Respaldos locales:

- `C:\Users\dedeb\.engram\backups\20261012-kharuun-3889f64f`.
- `C:\Users\dedeb\.codex\backups\20261012-kharuun-3889f64f`.

Se ejecutó el instalador oficial `engram setup codex`. El MCP `engram` está habilitado y el plugin **`engram@engram` 0.1.5** instalado y habilitado. Se comprobaron las otras entradas de configuración/MCP/marketplaces para asegurar que se conservan; no hay `model_instructions_file` ni `experimental_compact_prompt_file` que sustituyan el prompt base de Codex.

Usarlo como memoria auxiliar, conservando decisiones y tareas en Git. Un recuerdo debe incluir proyecto, ID D/Q, estado confirmado/pendiente, archivo de referencia y commit cuando exista. Guardar hallazgos significativos y un resumen al cerrar; no duplicar toda la especificación ni cada mensaje. Una hipótesis no se guarda como hecho.

Configuración instalada en `C:\Users\dedeb\.codex\config.toml`:

```toml
[mcp_servers.engram]
command = 'C:\Users\dedeb\bin\engram.exe'
args = ['mcp', '--tools=agent']
```

El proyecto se fija mediante `.engram/config.json` (`project_name = ShadowsOfKharuun`); Engram normaliza su identificador como `shadowsofkharuun`. Solo ese archivo de identificación se versiona; no se exportan base global ni recuerdos de otros proyectos.

Se guardaron **cinco resúmenes manuales administrativos**, IDs 130–134: base/versiones, combate D01–D15, narrativa D16–D20, Q01 pendiente y entorno. Estos registros no se presentan como escrituras atribuidas a una sesión de agente Codex. Una prueba directa de MCP inicializó el servidor 3.3.2, enumeró 19 herramientas y recuperó contexto mediante búsqueda.

**Paso pendiente del cliente:** recargar/reiniciar Codex y volver al proyecto para cargar el MCP y los hooks nuevos. Engram es un MCP/plugin local de Codex, no una cuenta que deba aparecer en el catálogo de conectores de ChatGPT. La guía del proveedor requiere una sesión nueva tras cambiar ejecutable/configuración.

En la sesión nueva, comprobar que `mem_current_project` identifica Kharuun, que los resúmenes son recuperables y que el hook confirma el ID real de sesión antes de escrituras de agente. No inventar un ID Codex ni confundir guardados manuales con ese registro. La prueba del servidor y el plugin configurado están verificados; la atribución de memoria desde una sesión nueva queda pendiente de esa recarga.

## Por qué no Changesets ahora

Este proyecto no tiene paquetes npm ni componentes publicables con versiones coordinadas. Git, etiquetas y un changelog manual cubren la necesidad actual sin añadir un gestor de paquetes o una cadena de publicación. Si más adelante aparecen paquetes o publicaciones que coordinar, se reevaluará.

Referencias: [Changesets](https://github.com/changesets/changesets), [guía Engram para Codex](https://github.com/Gentleman-Programming/engram/blob/main/docs/AGENT-SETUP.md#codex), [versión estable 3.3.2](https://github.com/Gentleman-Programming/engram/releases/tag/v3.3.2) y [MCP en Codex](https://learn.chatgpt.com/docs/extend/mcp).

## Punto de reanudación actual

- Versión que se puede probar: **0.2.0**; el código no incorpora aún la segunda vuelta.
- Acuerdos confirmados: D01–D20. La oferta del guardián permite combate o paso pacífico y ambos conducen al mismo objetivo del templo.
- Regla principal pendiente: **Q01**, el usuario comprobará en KOTOR qué pasa con una orden sin energía al final o en medio de la cola. No volver a preguntarla mientras espera esa prueba.
- Q02/Q03/Q07 tienen propuestas explícitas en el diseño; revisarlas solo cuando afecten a la tarea siguiente.
- Próximo paso de diseño: incorporar la observación de Q01 cuando llegue. Si el usuario solicita implementar antes, avanzar con las partes independientes y aislar la regla pendiente.
- Entorno listo: repositorio privado y versiones remotas, 13 issues y milestone, Engram actualizado/configurado y resúmenes recuperables. Falta recargar el cliente para que el agente reciba herramientas y registro de sesión; no se ha iniciado la producción de 0.3.0.
