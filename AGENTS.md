# Shadows of Kharuun — instrucciones para agentes

RPG narrativo 3D para un jugador, desarrollado en Godot con Blender previsto para arte. Comunicar en español. Evitar sobreingeniería y distinguir decisiones aprobadas, propuestas, implementación real y verificación.

## Documentos y fuente de verdad

1. **Leer `docs/project/GESTION_DESARROLLO.md` antes de organizar tareas**: es la guía vigente y prevalece sobre instrucciones antiguas de gestión.
2. **Leer `docs/project/ORGANIZACION.md`** para convenciones del entorno, versión estable y rutina de trabajo.
3. **Consultar la issue de propuesta de alcance, las issues de trabajo y las fichas pertinentes de `docs/design/`**. Las carpetas de `docs/versions/0.3.0/` y `docs/versions/0.4.0/` son archivo histórico, no especifican versiones nuevas. `docs/project/` contiene las guías comunes; `docs/design/` conserva especificaciones de diseño vigentes.
4. `README.md` explica cómo ejecutar la versión estable y `docs/project/CHANGELOG.md` resume lo publicado e identifica los tags/commits y referencias relacionadas disponibles. Las carpetas históricas conservan documentación y evidencia de 0.3.0 y 0.4.0.
5. **GitHub Issues es la única fuente de estado operativo de tareas.** No copiar ni mantener en paralelo sus estados en `docs/versions/0.3.0/PENDIENTES.md`: ese documento es registro histórico de 0.3.0 y propuestas FUT sin aprobación automática.
6. Registrar propuestas de alcance, trabajo y su estado operativo en GitHub Issues. No crear carpetas ni Markdown por versión por defecto. Actualizar la ficha de `docs/design/` cuando cambie un diseño persistente, `docs/project/` cuando cambie una guía común y `docs/project/CHANGELOG.md` al publicar una entrega.

## Decisiones, planificación e implementación

- Distinguir el estado de diseño (`propuesta`, `pendiente de decisión`, `aprobada`, `descartada/sustituida`) registrado en la ficha de `docs/design/`, el estado de decisión del alcance en su Issue y el estado operativo (`planificado`, `en-curso`, `verificado-en-rama`, `cerrada/entregada`) registrado con labels en GitHub Issues. Un diseño aprobado no implica que esté producido.
- Durante exploración o diseño, no cambiar escenas/scripts ni interpretar la aprobación de una idea como petición de implementarla. Puede documentarse lo solicitado. Ejecutar desarrollo **solo cuando el usuario autorice el alcance**.
- Se permite una única issue de **propuesta de alcance** antes de aprobar una versión, usando `.github/ISSUE_TEMPLATE/propuesta-alcance-version.md`; debe indicar que no autoriza implementación. No crear milestone ni issues de diseño/implementación hasta aprobar explícitamente ese alcance. Tras aprobarlo, un milestone agrupa la versión y las issues de trabajo; la issue de propuesta queda como registro, no como tarjeta release.
- Mantener trazables en las Issues las decisiones de alcance y los criterios de trabajo, y en las fichas de `docs/design/` el diseño vigente, sus criterios observables, las decisiones sustituidas y los enlaces a Issues pertinentes. Conservar los IDs históricos; no inventar uno por cada idea ni reabrir acuerdos vigentes por falta de contexto.
- Antes de editar, comprobar rama, HEAD y cambios locales/no integrados. Trabajar en el alcance autorizado, evitando mezclar trabajo ajeno. Crear commits coherentes y PRs revisables; no sobreescribir la rama o cambios locales del usuario.
- Validar flujos afectados y regresiones, incluyendo pruebas reales de Godot/GPU cuando proceda. No marcar `verificado-en-rama` sin evidencia. La QA humana exigida debe quedar registrada antes de entregar. Nunca etiquetar trabajo futuro como versión estable.
- Al cerrar una sesión, registrar qué se hizo, qué falta, qué evidencia existe y el próximo paso **en el lugar correspondiente**, evitando duplicar el estado de la issue en Markdown.

## Engram

Memoria MCP **auxiliar**, subordinada a Git y GitHub. Proyecto exclusivo `shadowsofkharuun`: usar `project = shadowsofkharuun` y `scope = project`; no usar `all_projects` ni recuperar recuerdos ajenos. Recuperar por ID solo registros obtenidos con búsqueda filtrada. Si no carga o no puede escribir por fallo de identificación de sesión, continuar con Git/Issues y registrar la limitación; no usar CLI/SQL/HTTP para eludir hooks. No borrar ni reasignar memorias de otros proyectos.

**Base estable comprobada:** `v0.4.0` en `main`, PR #29, Vigía y pipeline Blender–Godot con presentación integrada aprobada. Las carpetas `docs/versions/0.3.0/` y `docs/versions/0.4.0/` conservan su archivo y evidencia histórica; no son plantilla obligatoria para futuras entregas. Planificar versiones siguientes está permitido; implementarlas requiere autorización. No introducir multijugador ni ampliar sistemas/universo fuera del alcance aprobado.
