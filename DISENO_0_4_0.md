# Diseño de la versión 0.4.0 — borrador para aprobación

**Fecha:** 14 de octubre de 2026  
**Estado:** borrador de alcance; **no** autoriza implementar ni equivale a una versión aprobada.  
**Base estable:** `v0.3.0` integrada en `main`, PR #14 aceptada.  
**Procedimiento obligatorio:** [AGENTS.md](AGENTS.md), [GESTION_DESARROLLO.md](GESTION_DESARROLLO.md) y [ORGANIZACION.md](ORGANIZACION.md).  
**Histórico, no backlog activo:** [PENDIENTES.md](PENDIENTES.md) y [DISENO_DEMO.md](DISENO_DEMO.md).

Este documento recupera las conversaciones de planificación de arte, Godot y Blender. Separa acuerdos generales del proyecto de un **alcance de versión todavía pendiente de ratificación**. La existencia de este archivo no crea issues implementables.

## 1. Situación de partida y objetivo

En `v0.3.0`, el nivel usa geometría procedural en Godot. `scripts/architecture.gd` genera las estatuas, columnas, obeliscos y braseros; `scripts/level.gd` los sitúa en la misión del templo. El cielo y los materiales del escenario ya tienen shaders propios. Los personajes todavía utilizan el rig procedural `KhRig`.

**Propuesta de objetivo para 0.4.0:** demostrar un **primer pipeline artístico reproducible Blender → Godot** con **un modelo original de estatua monumental** que sustituya visualmente la estatua provisional de la misión, sin cambiar las reglas ni la estructura jugable de la 0.3.0.

Este incremento aborda la incertidumbre principal: si el flujo de trabajo asistido por IA produce geometría 3D utilizable y visualmente convincente **dentro de Godot**, no solo renders de referencia.

## 2. Acuerdos generales confirmados (no implican aprobación de 0.4.0)

- **C04-01 — Responsabilidades:** Godot es el motor de ejecución, gameplay, física y renderizado; Blender es la herramienta artística prevista. No migrar de motor ni abrir otra infraestructura sin motivo.
- **C04-02 — Un solo repositorio de juego:** conservar las fuentes artísticas propias y los recursos exportados en el repositorio de Shadows of Kharuun, separados por función. No crear ahora una biblioteca comercial ni otro repositorio artístico.
- **C04-03 — Integración verificable:** los modelos deben probarse en el juego; un render aislado en Blender no valida un asset. Preservar gameplay, cámara, colisiones e interacciones de la entrega estable.
- **C04-04 — Producción incremental por IA:** dividir trabajos artísticos en resultados pequeños con revisiones visuales iterativas; no exigir de entrada humanoides completos, vestimentas animadas ni un sistema extensible de personalización.
- **C04-05 — Inventario desacoplado de la representación:** un personaje puede tener un modelo vestido fijo sin sistema de inventario. Un futuro atuendo completo equipable es un problema diferente y no requiere implementar ahora todas las ranuras.
- **C04-06 — Investigación separada:** para investigar KOTOR.js, reone o PyKotor, se contempla un directorio local hermano llamado `ShadowsOfKharuun_references/`, fuera del repositorio del juego. Los clones de referencia no se incorporan como dependencias ni forman parte por defecto del alcance artístico. No hace falta RAG/vectorización de código como requisito inicial.
- **C04-07 — Gestión:** GitHub Issues será la única fuente de estado operativo. Las decisiones y dudas viven en este diseño; un milestone solo se crea con alcance aprobado; el desarrollo exige autorización posterior. Las ideas `FUT-xx` no se aprueban automáticamente.

Los identificadores C04 registran acuerdos transversales recuperados de la conversación; no afirman que el pipeline Blender o los componentes 3D estén ya construidos.

## 3. Propuesta prioritaria para 0.4.0 — **pendiente de aprobación**

- **P04-01 — Contrato mínimo Blender–Godot:** definir una ubicación para `.blend`, una ruta para el `.glb` exportado, escala/orientación, importación y procedencia/licencias. La elección del script de exportación Blender Python ya está aprobada como decisión técnica T04-06; el alcance global del pipeline sigue pendiente. No crear un sistema de builds artísticos general.
- **P04-02 — Estatua Sith original:** producir **una única malla o conjunto artístico reutilizable** de estatua monumental para el templo, con aspecto coherente con una dirección de realismo estilizado oscuro (pendiente de referencias concretas). Varias instancias de esa misma pieza no obligan a crear múltiples modelos.
- **P04-03 — Integración en la misión:** reemplazar la **geometría visual** de las estatuas de `scripts/architecture.gd` por el recurso importado o escena reutilizable, conservando posiciones, colisiones y comportamiento. La reutilización de **un mismo GLB en las dos instancias existentes** ya está aprobada como decisión técnica T04-04; implementar la integración aún requiere aprobar y autorizar el alcance.
- **P04-04 — Revisión y QA:** validar tanto el resultado visual como la importación, materiales, rendimiento y regresiones del recorrido jugable de la 0.3.0. Mantener revisión humana explícita antes de aprobar una entrega artística.

**Principio de alcance:** la 0.4.0 propuesta tiene como protagonista **una estatua**, no una remodelación completa del templo. No incorporar tareas adicionales por el mero hecho de que Blender esté configurado.

### Decisiones técnicas aprobadas dentro del borrador (14-10-2026)

Estas decisiones resuelven opciones concretas de arquitectura; **no aprueban todavía el alcance global de 0.4.0 ni autorizan implementar**. Se conservan los IDs T04-04 y T04-06 de la propuesta técnica debatida; otros puntos técnicos continúan como propuestas.

- **T04-04 — Un GLB, dos instancias (aprobada):** producir **un único recurso de estatua** y utilizarlo en **ambas posiciones actuales** de `scripts/level.gd`: `(-10.8, 0, -13.8)` y `(10.8, 0, -13.8)`, conservando sus rotaciones actuales (`0` y `-0.05` rad), colisiones y funcionalidad. No crear un modelo independiente por posición. **Criterio verificable, tras autorización:** las dos instancias utilizan el mismo GLB y el recorrido jugable conserva las colisiones/transformaciones previas. Esta decisión resuelve Q04-03.
- **T04-06 — Script Blender Python sencillo (aprobada):** la exportación de la fuente `.blend` al modelo `.glb` se realizará mediante **un script pequeño ejecutable con Blender Python**, específico para la estatua y reproducible por Codex. Se documentarán su invocación, versión de Blender, entrada y salida. **No** introducir un gestor de assets, una automatización general, dependencias adicionales ni CI artístico por defecto. **Criterio verificable, tras autorización:** Codex puede ejecutar el script en Windows para regenerar e importar el GLB en Godot. La elección del script resuelve esa parte de Q04-04; siguen pendientes las rutas y la comprobación del entorno local.

## 4. Criterios de aceptación propuestos (si se aprueba P04)

1. **Fuente editable:** el recurso tiene fuente Blender versionada y trazabilidad de sus materiales/texturas; puede reconstruirse la exportación sin depender de una imagen generada ni de un archivo externo desconocido.
2. **Exportación comprobada:** el modelo se entrega como `.glb` compatible con Godot, con escala, orientación, sombreado y materiales apropiados; un script Blender Python sencillo permite repetir y documentar la exportación conforme a T04-06.
3. **Calidad artística:** la estatua mantiene una silueta reconocible y un nivel de detalle superior al conjunto de cajas/cilindros actual; las capturas reales de Godot desde las vistas jugables permiten revisarla. **Su aceptación visual depende del usuario**, no solo del agente.
4. **Integración segura:** ambas instancias existentes utilizan el mismo GLB (T04-04), conservan sus posiciones/rotaciones y no se rompen interacciones, colisiones, navegación practicable, iluminación esencial ni la misión del templo.
5. **Pruebas y evidencia:** documentar al menos una ejecución/importación verificable, capturas reales dentro de Godot y pruebas relevantes de regresión de la `v0.3.0`. No confundir pruebas automáticas con QA visual humana.
6. **Procedencia:** conservar registro de autoría/origen/licencia de los assets; no incorporar modelos, voces, música ni texturas extraídos de KOTOR.
7. **Cierre:** solo después de implementación autorizada, QA, PR y aprobación humana se actualizarán los informes de entrega y se creará `v0.4.0`. No crear tag anticipado.

## 5. Fuera del alcance **propuesto** de esta versión

No producir en 0.4.0: inventario o pantalla de equipamiento; ranuras Body/casco/brazaletes y catálogo de objetos; humanoide, botas, túnicas, rigging o animaciones; remodelado general de suelos, paredes o cielo; antorchas/efectos de fuego; nuevas misiones, compañeros, progresión o sistemas narrativos; cambios del combate obtenidos de KotOR.js/reone/PyKotor; motor de mundo abierto, Houdini, USD o una base vectorial para analizar repositorios.

Esos temas pueden estudiarse en sus conversaciones y documentos correspondientes. No se asigna versión ni se crean issues por aparecer aquí.

## 6. Cuestiones abiertas antes de fijar el milestone

- **Q04-01 — Aprobación del recorte:** ¿se confirma expresamente **0.4.0 = pipeline Blender–Godot + una estatua Sith original integrada**, sin inventario ni más arte ambiental? La conversación mostró acuerdo favorable con la orientación, pero aún no se ha registrado una aprobación inequívoca de este recorte como milestone.
- **Q04-02 — Dirección visual:** confirmar referencias concretas de silueta, piedra/materiales, complejidad y acabado de la estatua. Puede resolverse al iniciar el issue artístico antes de producir su geometría; la ausencia de referencias no justifica generar modelos arbitrarios.
- **Q04-04 — Pipeline mínimo (parcialmente resuelto):** **aprobada** la exportación con script Blender Python sencillo (T04-06). **Pendiente** concretar carpetas, parámetros/convenciones de exportación y verificar Blender disponible en el entorno local de Codex. No presuponer que esté instalado o accesible.
- **Q04-05 — Calidad aceptable:** especificar en la revisión visual cómo reconocer que la estatua tiene calidad suficiente sin exigir fotorrealismo. Esta decisión se valida con capturas del juego, no con un número arbitrario de polígonos.

**Q04-03 — Resuelta el 14-10-2026:** reutilizar el mismo GLB en ambas posiciones existentes (T04-04). No sigue abierta.

Las preguntas restantes no impiden redactar el diseño; sí impiden tratar como aprobada una funcionalidad concreta cuando afecten a su alcance o aceptación.

## 7. Desglose de GitHub **previsto, no creado**

**Solo tras resolver Q04-01 y confirmar el alcance**:

- **Milestone `0.4.0`**: agrupa los entregables; no necesita issue «hacer versión 0.4.0».
- **Issue padre «Primera estatua artística integrada en la misión»**: representa el resultado verificable global, no una segunda copia del milestone.
  - **Sub-issue A «Establecer pipeline mínimo Blender–Godot»**: rutas, formatos, convenciones, script Blender Python pequeño (T04-06), comprobación de exportación/importación y documentación.
  - **Sub-issue B «Modelar y revisar estatua Sith original»**: fuente editable, materiales, iteraciones y revisión visual del modelo exportado.
  - **Sub-issue C «Integrar estatua en el templo y verificar la misión»**: escena reutilizable con el mismo GLB en las dos estatuas (T04-04), sustitución visual, capturas reales, regresiones y aceptación humana.

**Dependencias:** C queda bloqueada por las entregas de A y B; A y B pueden avanzar parcialmente en paralelo acordando escala y pose/emplazamiento. No registrar más bloqueos si no son reales.

Cada issue debe usar la plantilla `.github/ISSUE_TEMPLATE/funcionalidad-aprobada.md`, enlazar los IDs pertinentes, indicar fuera de alcance y aceptación. Aplicar `planificado` exclusivamente después de aprobar el alcance. Registrar estados **solo en GitHub**; este documento no tendrá una tabla espejo de progreso.

## 8. Condiciones para pasar del borrador a la planificación aprobada

1. Obtener confirmación del usuario para **Q04-01** y perfilar las cuestiones que sigan abiertas (Q04-02, parte pendiente de Q04-04 y Q04-05). **Q04-03 ya está resuelta** por T04-04.
2. Cambiar el estado de este documento a **alcance aprobado**, conservando qué ideas siguen abiertas o pospuestas.
3. Crear el milestone `0.4.0`, la issue padre y sub-issues **nativas**, dependencias reales y etiquetas conforme a `GESTION_DESARROLLO.md`. Verificar enlaces, jerarquía y ausencia de duplicación.
4. **No implementar el videojuego ni iniciar producción artística** hasta una autorización explícita posterior del usuario.

La versión `v0.3.0` permanece como referencia estable e inmutable mientras solo se planifica.
