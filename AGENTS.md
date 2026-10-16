# Shadows of Kharuun — instrucciones para agentes

RPG narrativo 3D para un jugador, desarrollado en Godot con Blender previsto para arte. Comunicar en español. Evitar sobreingeniería y distinguir decisiones aprobadas, propuestas, implementación real y verificación.

## Documentos y fuente de verdad

1. **Leer `GESTION_DESARROLLO.md` antes de organizar tareas**: es la guía vigente y prevalece sobre instrucciones antiguas de gestión.
2. **Leer `ORGANIZACION.md`** para convenciones del entorno, versión estable y rutina de trabajo.
3. **Consultar el diseño correspondiente al trabajo activo**. `DISENO_DEMO.md` especifica lo aceptado en **v0.3.0**, no el backlog ni las decisiones de la siguiente versión. Para 0.4.0 consultar su documento propio cuando exista (p. ej. `DISENO_0_4_0.md`).
4. `README.md` explica cómo ejecutar la versión estable, `COMBATE.md` detalla el combate actual, `RESULTADO.md` y `QA_0_3_0.md` conservan evidencia, y `CHANGELOG.md` registra entregas.
5. **GitHub Issues es la única fuente de estado operativo de tareas.** No copiar ni mantener en paralelo sus estados en `PENDIENTES.md`: ese documento es registro histórico de 0.3.0 y propuestas FUT sin aprobación automática.

## Decisiones, planificación e implementación

- Distinguir `propuesta`, `pendiente de decisión`, `aprobada` y `descartada/sustituida` para **decisiones Markdown**; y `planificado`, `en-curso`, `verificado-en-rama` y `cerrada/entregada` para **issues**. Una decisión aprobada no implica que exista código.
- Durante exploración o diseño, no cambiar escenas/scripts ni interpretar la aprobación de una idea como petición de implementarla. Puede documentarse lo solicitado. Ejecutar desarrollo **solo cuando el usuario autorice el alcance**.
- No crear milestones, issues o PRs para versiones futuras sin alcance aprobado; las ideas FUT no son compromisos. Un milestone agrupa una versión; una issue padre representa una funcionalidad divisible, no una segunda tarjeta «release».
- Mantener IDs de decisión rastreables, criterios observables, decisiones sustituidas y enlaces a issues pertinentes. No reabrir acuerdos vigentes por falta de contexto ni convertir hipótesis en hechos.
- Antes de editar, comprobar rama, HEAD y cambios locales/no integrados. Trabajar en el alcance autorizado, evitando mezclar trabajo ajeno. Crear commits coherentes y PRs revisables; no sobreescribir la rama o cambios locales del usuario.
- Validar flujos afectados y regresiones, incluyendo pruebas reales de Godot/GPU cuando proceda. No marcar `verificado-en-rama` sin evidencia. La QA humana exigida debe quedar registrada antes de entregar. Nunca etiquetar trabajo futuro como versión estable.
- Al cerrar una sesión, registrar qué se hizo, qué falta, qué evidencia existe y el próximo paso **en el lugar correspondiente**, evitando duplicar el estado de la issue en Markdown.

## Engram

Memoria MCP **auxiliar**, subordinada a Git y GitHub. Proyecto exclusivo `shadowsofkharuun`: usar `project = shadowsofkharuun` y `scope = project`; no usar `all_projects` ni recuperar recuerdos ajenos. Recuperar por ID solo registros obtenidos con búsqueda filtrada. Si no carga o no puede escribir por fallo de identificación de sesión, continuar con Git/Issues y registrar la limitación; no usar CLI/SQL/HTTP para eludir hooks. No borrar ni reasignar memorias de otros proyectos.

**Base estable comprobada:** `v0.4.0` en `main`, PR #29, Vigía y pipeline Blender–Godot con presentación integrada aprobada. QA y aprendizajes en `QA_0_4_0.md` y `APRENDIZAJES_0_4_0.md`; `v0.3.0` conserva su tag inmutable. Planificar versiones siguientes está permitido; implementarlas requiere autorización. No introducir multijugador ni ampliar sistemas/universo fuera del alcance aprobado.

## Gentle AI / ODD (adopción 2026-10-16)

Gentle AI será el flujo principal de los agentes una vez activado localmente. **Leer `GENTLE_AI.md`** para instalación y compatibilidad; la activación local sigue pendiente de prueba. Aplicar el principio ODD de **autorizar → explorar → implementar → verificar**: preguntas de investigación no autorizan escrituras, tareas pequeñas no requieren artefacto de planificación y tareas grandes pueden usar `odd/tasks/<feature>.md` como registro de ejecución, **no como segundo backlog**. No sobrescribir este `AGENTS.md` con prompts generados ni dar por activa una instrucción depositada únicamente en `.codex/AGENTS.md`. GitHub Issues y el diseño siguen siendo autoridades; Engram solo es auxiliar. Las revisiones RDD jamás sustituyen QA en Godot ni aceptación humana.
