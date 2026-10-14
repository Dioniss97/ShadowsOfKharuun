# Organización mínima del trabajo

Actualizado: 14 de octubre de 2026. QA humana de 0.3.0 aprobada; cierre de integración y publicación autorizado. Después se espera la definición de 0.4.

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
| Engram | Memoria local auxiliar del proyecto `shadowsofkharuun`: lectura por MCP verificada en esta sesión. Escrituras pendientes del registro del cliente; acuerdos recientes conservados en Git. |

Las nuevas instrucciones del usuario prevalecen. El diseño distingue intención futura de comportamiento existente: una regla documentada no es una función implementada. Los recuerdos externos deben remitirse al repositorio y comprobarse contra su estado vigente.

## Versiones y ramas

| Versión | Commit de entrega | Situación |
|---|---|---|
| 0.1.0 | `138d459` | Misión original verificada. Etiqueta retrospectiva `v0.1.0`. |
| 0.2.0 | `f516f41` | Misión original y duelo táctico verificados. Etiqueta retrospectiva `v0.2.0`; entrega anterior. |
| 0.3.0 | RC2 aceptada: `f8ada97`; entrega: `v0.3.0` | Misión unificada implementada, comprobada y aceptada por el usuario; integración/publicación autorizadas. |

Convención para este prototipo: `0.MINOR.PATCH`. Incrementar MINOR cuando una entrega añade un conjunto importante de funciones; PATCH para correcciones o ajustes pequeños de una entrega. Los cambios solo de documentación conservan la versión jugable. No crear etiquetas definitivas para funciones meramente acordadas ni reutilizar/mover una etiqueta existente.

La rama de implementación es `feature/temple-tactical-demo`, creada desde `origin/main` después de `c0aab67`. La PR #14 integra la misión unificada en `main` tras la aprobación humana del 14 de octubre. El remoto conserva `feature/tactical-duel` y `master`; esta última identifica la primera entrega. No imponer GitFlow ni ramas de release adicionales.

Implementación inicial en `2a6cd6b`; RC2 aceptada en `f8ada97`; [PR #14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14). La promoción final solo cambia versión/textos/documentación, sin nuevas mecánicas. Las 21 issues se cierran al integrar y conservan su historial y criterios.

Remoto privado: [Dioniss97/ShadowsOfKharuun](https://github.com/Dioniss97/ShadowsOfKharuun), `origin = https://github.com/Dioniss97/ShadowsOfKharuun.git`. El usuario confirmó la cuenta autenticada con dos «s». Historial y etiquetas `v0.1.0`/`v0.2.0` están subidos. La prueba SSH devolvió `Permission denied (publickey)`; HTTPS con GitHub CLI autenticado funciona, sin modificar claves SSH ni el protocolo global de Git.

La carpeta del Godot portátil está excluida de Git y debe conservarse o descargarse aparte al preparar otra máquina. Memoria global, credenciales, ejecutables, descargas y copias de seguridad no se suben al repositorio.

## Backlog en GitHub

Milestone: [Demo 0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/milestone/1). DEMO-01–13 y B1–B8 (#15–22) implementadas y aceptadas; la comprobación de RC2 incluye D33–D36 y HUD ancho. La aprobación global cierra DEMO-10/11. El cierre de las 21 issues y milestone está autorizado junto con la integración de PR #14.

Los issues siguen el avance operativo; `PENDIENTES.md` conserva el resumen local y los enlaces. Al cambiar estado o cerrar una tarea, actualizar ambos, añadir evidencia/commit al issue y mantener el acuerdo detallado en `DISENO_DEMO.md`. Si GitHub no está disponible, registrar el avance local y señalar la sincronización pendiente. Las FUT pospuestas permanecen en los MD, sin crear tarjetas fuera del alcance actual.

## Inicio de una sesión

1. Leer `AGENTS.md`, diseño y pendientes; comprobar rama, cambios locales y última entrega identificada por etiqueta.
2. Separar el objetivo autorizado de lo que solo está propuesto. Elegir una tarea con ID y un resultado concreto para esta sesión.
3. Consultar las preguntas de esa tarea. Una duda sobre energía no bloquea cámara, interfaz o redacción independientes. Marcar exactamente qué parte espera respuesta.
4. Si Engram está disponible, confirmar el proyecto y recuperar contexto con `project = shadowsofkharuun`, `scope = project` y sin `all_projects`; verificarlo contra los documentos actuales. Ignorar memorias ajenas incluso si falta contexto del juego.

El usuario aprobó expresamente la QA de 0.3.0 el 14 de octubre de 2026. D01–D36 y B1–B8 (D27 sustituida por D33) están implementados y aceptados. El cierre actual integra la PR, cierra los issues cubiertos y milestone, y publica `v0.3.0`. Después se detiene hasta que el usuario defina 0.4; no escoger una tarea FUT por iniciativa propia.

## Durante el trabajo y al terminar

- Mantener D/Q/DEMO estables; registrar una decisión sustituida y su motivo, en lugar de reabrirla o conservar dos reglas incompatibles.
- Una pregunta importante usa opciones clicables. Una observación pendiente sigue siendo hipótesis hasta que el usuario la compruebe; Q01 y Q10 quedaron confirmadas por el usuario y se registraron en D31.
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

El proyecto se fija mediante `.engram/config.json` (`project_name = ShadowsOfKharuun`); Engram normaliza su identificador como `shadowsofkharuun`. Solo ese archivo de identificación se versiona; no se exportan base global ni recuerdos de otros proyectos. Es una separación lógica dentro de la base existente, no una base nueva: las memorias ajenas permanecen intactas. La configuración fija el proyecto predeterminado, pero no es un bloqueo de seguridad contra consultas explícitas a otros proyectos.

La instrucción de trabajo para este repositorio exige filtros explícitos `project = shadowsofkharuun`, `scope = project` en búsqueda y contexto. No usar búsqueda global ni recuperar contexto ajeno como alternativa. La respuesta de contexto puede incluir estadísticas globales; no son recuerdos del juego ni se incorporan al diseño. La recuperación por ID no filtra propiedad: usar solo IDs devueltos por una búsqueda ya filtrada. Guardar nuevos recuerdos con proyecto y ámbito explícitos, después de verificar el registro real de sesión. No borrar, fusionar, reasignar ni exportar memorias previas.

Se guardaron **cinco resúmenes manuales administrativos**, IDs 130–134: base/versiones, combate D01–D15, narrativa D16–D20, Q01 pendiente y entorno. Estos registros no se presentan como escrituras atribuidas a una sesión de agente Codex. Una prueba directa de MCP inicializó el servidor 3.3.2, enumeró 19 herramientas y recuperó contexto mediante búsqueda.

**Repaso del 12 de octubre:** las herramientas se han cargado durante esta sesión. `mem_current_project` confirma el proyecto desde la configuración; `mem_search` devuelve únicamente los cinco recuerdos 130–134 de Kharuun con ámbito `project`; `mem_context` devuelve sus sesiones/observaciones. Acceso de lectura por el MCP del agente verificado, además de la prueba directa anterior.

La escritura sigue pendiente: el hook `PreToolUse` rechazó `mem_session_start` con `Codex host session resolution could not be confirmed`, incluso usando el ID real del entorno. No se elude este rechazo mediante guardados CLI/HTTP/SQL ni se inventa otro ID. Los acuerdos D21–D24 y el cierre de revisión quedan en los MD y GitHub hasta que el cliente confirme el registro.

Se comprobó una dependencia ausente en los scripts oficiales: `jq`. Se instaló **jq 1.8.2** oficial en `C:\Users\dedeb\bin\jq.exe`, SHA256 `a6fc67fedaf9128a3309a1e2ebb8b986aeccf70122ee46d2cb4849e423f0c627`, y Git Bash ya encuentra el ejecutable. No se modificaron los hooks del proveedor ni el PATH global. El servidor HTTP auxiliar no respondía en el puerto local 7437 durante el diagnóstico; no se da por resuelta la atribución solo por instalar la dependencia.

**Paso pendiente del cliente:** recargar/reiniciar Codex y volver a este proyecto para ejecutar el hook de inicio/reanudación con la dependencia disponible. Confirmar el vínculo real de sesión antes de guardar por MCP el resumen de esta revisión. Engram es un MCP/plugin local de Codex, no una cuenta del catálogo de conectores de ChatGPT. La lectura ya está operativa; las escrituras requieren esta verificación separada.

## Por qué no Changesets ahora

Este proyecto no tiene paquetes npm ni componentes publicables con versiones coordinadas. Git, etiquetas y un changelog manual cubren la necesidad actual sin añadir un gestor de paquetes o una cadena de publicación. Si más adelante aparecen paquetes o publicaciones que coordinar, se reevaluará.

Referencias: [Changesets](https://github.com/changesets/changesets), [guía Engram para Codex](https://github.com/Gentleman-Programming/engram/blob/main/docs/AGENT-SETUP.md#codex), [versión estable 3.3.2](https://github.com/Gentleman-Programming/engram/releases/tag/v3.3.2) y [MCP en Codex](https://learn.chatgpt.com/docs/extend/mcp).

## Punto de reanudación actual

- Build local: **0.3.0**, `PLAY.bat`; RC2 `f8ada97` aceptada por el usuario el 14 de octubre de 2026.
- D01–D36 y B1–B8 (D27 sustituida por D33) implementados. Evidencia vigente en RESULTADO, controles en README, guía humana en QA_0_3_0.md.
- Próximo paso de cierre: integrar PR #14, cerrar las 21 issues/milestone y etiquetar v0.3.0. Después esperar instrucciones; no iniciar 0.4 sin definición del usuario.
- Engram: lectura de proyecto verificada; escritura MCP pendiente del registro de sesión por el host. Este turno conserva el resumen en MD/Git y no intenta registrar otra sesión ni usar CLI como alternativa.


Historial de QA RC1: D33 sustituye D27; B1 vuelve al giro del actor. B7 #21 cubre vida seleccionada/HUD compacto, B8 #22 orbe con mano/clic. La nueva captura de KOTOR II es la referencia; no confundir la imagen de Codex enviada antes con una captura del juego. RC2 recibió después la aceptación humana global.
