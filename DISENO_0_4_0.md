# Diseño de la versión 0.4.0 — alcance aprobado para planificación

**Fecha:** 14 de octubre de 2026  
**Revisión de dirección artística:** 15 de octubre de 2026  
**Estado:** alcance aprobado para planificación; crea issues planificadas, pero **no autoriza implementación ni producción artística**.  
**Base estable:** `v0.3.0` integrada en `main`, PR #14 aceptada.  
**Procedimiento obligatorio:** [AGENTS.md](AGENTS.md), [GESTION_DESARROLLO.md](GESTION_DESARROLLO.md) y [ORGANIZACION.md](ORGANIZACION.md).  
**Histórico, no backlog activo:** [PENDIENTES.md](PENDIENTES.md) y [DISENO_DEMO.md](DISENO_DEMO.md).

Este documento consolida las decisiones de diseño confirmadas para planificar 0.4.0. Distingue acuerdos aprobados de parámetros orientativos y de criterios que se aceptarán al revisar el asset real. La aprobación permite crear el milestone y las issues, pero no autoriza implementarlas.

## 1. Situación de partida y objetivo

En `v0.3.0`, el nivel usa geometría procedural en Godot. `scripts/architecture.gd` genera las estatuas, columnas, obeliscos y braseros; `scripts/level.gd` los sitúa en la misión del templo. El cielo y los materiales del escenario ya tienen shaders propios. Los personajes todavía utilizan el rig procedural `KhRig`.

**Alcance aprobado para 0.4.0:** establecer un **primer flujo reproducible Blender → Godot** y crear una estatua original, el **Vigía del Umbral**, que sustituya visualmente las dos estatuas provisionales de la misión mediante el **mismo archivo GLB**. Se conservan las posiciones, colisiones y reglas jugables de `v0.3.0`.

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

## 3. Alcance aprobado para 0.4.0

- **P04-01 — Flujo mínimo Blender–Godot (aprobado):** conservar la fuente editable `.blend` en `art/source/statues/vigia_umbral.blend`, la referencia visual en `art/references/vigia_umbral/`, el recurso de juego en `assets/models/environment/vigia_umbral.glb` y los automatismos en `tools/blender/`. Usar Blender 5.2.2 LTS cuando se autorice instalarlo. Un automatismo genera y guarda la fuente; otro exporta el GLB. Godot usará el GLB, no dependerá de abrir directamente la fuente Blender.
- **P04-02 — Vigía del Umbral (aprobado):** producir una estatua monumental original reutilizable en las dos posiciones actuales. Concepto B, orientación hacia el patio y acabado/materiales acordados (A04-01–A04-03). La lámina de referencias y las iteraciones del modelo son entregables de la issue, no decisiones que bloqueen crearla.
- **P04-03 — Integración en la misión (aprobada):** reemplazar solo la geometría visual provisional por el GLB o una escena reutilizable que lo contenga, conservando ubicaciones, rotaciones, colisiones y comportamiento. Aplicar T04-04 y A04-02.
- **P04-04 — Revisión y QA (aprobada como criterio):** comprobar importación, aspecto en Godot, materiales, rendimiento y regresiones del recorrido de `v0.3.0`. La aceptación visual humana sigue siendo necesaria al revisar el modelo real.

**Límite de alcance:** el trabajo se centra en una estatua reutilizada dos veces, no en una remodelación completa del templo. Quedan fuera inventario, equipamiento, arte ambiental general, personajes animados, cambios narrativos o de combate y nuevos sistemas.

### Decisiones técnicas aprobadas (actualizadas el 15-10-2026)

El alcance global 0.4.0 está aprobado para planificación. Las decisiones siguientes no autorizan por sí solas empezar a producir; la implementación requerirá una autorización posterior.

- **T04-04 — Un GLB, dos instancias (aprobada):** producir **un único recurso de estatua** y utilizarlo en **ambas posiciones actuales** de `scripts/level.gd`: `(-10.8, 0, -13.8)` y `(10.8, 0, -13.8)`, conservando sus rotaciones actuales (`0` y `-0.05` rad), colisiones y funcionalidad. No crear un modelo independiente por posición. **Criterio verificable, tras autorización:** las dos instancias utilizan el mismo GLB y el recorrido jugable conserva las colisiones/transformaciones previas. Esta decisión resuelve Q04-03.
- **T04-06 — Exportación con Blender Python (aprobada):** un script pequeño, específico para la estatua, exportará la fuente `.blend` al modelo `.glb`; documentará versión, comando, entrada y salida. Sin gestor general de assets, dependencias adicionales ni CI artístico por defecto.
- **T04-07 — Generación automatizada de la estatua (aprobada):** un script sencillo de Blender Python construirá el modelo y guardará el `.blend` editable en la ruta acordada. El usuario no necesita modelar manualmente: revisará imágenes y solicitará ajustes. Los scripts se mantendrán específicos para este experimento, no como generador universal.

### Dirección artística: Vigía del Umbral (decisiones actualizadas el 15-10-2026)

**El usuario aprobó el alcance 0.4.0 y las decisiones artísticas indicadas aquí.** La aprobación permite planificar; la aceptación del modelo final se realizará mediante revisión humana del asset en Godot.

- **A04-01 — Concepto B, Vigía del Umbral (aprobada):** representar un antiguo guerrero ceremonial mediante **realismo estilizado oscuro**, mezcla cualitativa aproximada de 70 % humanoide y 30 % arquitectura monumental. Silueta dominante, erguida, predominantemente simétrica, con cabeza ceremonial de rostro oculto, capa/armadura pétrea y arma vertical con punta hacia el pedestal. «70/30» orienta el lenguaje visual, **no** es una proporción anatómica que deba medirse. La figura será original y no copiará iconografía, armaduras, personajes o modelos de Star Wars.
- **A04-02 — Orientación al patio (aprobada):** el Vigía mira hacia el jugador que se acerca desde el patio, es decir, **aproximadamente hacia `+Z` del nivel**, frente a la orientación visual `-Z` de la estatua procedural. Esta orientación se resolverá en el **asset visual o su nodo contenedor**, sin cambiar las posiciones ni las rotaciones de T04-04 ni las colisiones. **Verificarla en una captura real de Godot:** la convención de ejes de Blender y el resultado glTF no se dan por correctos solo por los valores del script.
- **A04-03 — Acabado del Vigía (aprobada el 15-10-2026):** basalto azul grisáceo mate como material dominante, planos de piedra clara y pequeños acentos de bronce envejecido; hasta tres materiales; sin emisión ni texturas complejas; pocas grietas grandes y hoja ceremonial invertida. El peto y los motivos secundarios siguen sujetos a iteración visual.

#### Hoja de estilo: decisiones confirmadas y parámetros orientativos

- **Escala y postura:** altura total orientativa **7,5–8 m**, pedestal cercano al existente (**3,7 × 3,1 × 0,9 m**). Son valores iniciales para ajustar al revisar capturas, no cifras aprobadas. Pose equilibrada, brazos cerca del tronco y manos ante el cuerpo sobre una **hoja ceremonial ancha e invertida** (A04-03), sin referencias a armas reconocibles de otra franquicia.
- **Silueta:** grandes planos angulares en hombros y torso, piernas diferenciables, capa de piedra en paneles continuos, cabeza como marco profundo con cavidad oscura **sin rasgos faciales esculpidos**. La estatua debe leerse desde el patio incluso con material gris neutro.
- **Identidad:** un peto de dos placas con hendidura geométrica discontinua, arma «anclada» al pedestal y cavidad facial como motivos originales. Son **propuestas de detalle**, no símbolos doctrinales ni canon narrativo confirmados.
- **Materiales — A04-03 (aprobada):** basalto azul grisáceo mate como dominante, planos de piedra clara y pequeños acentos de bronce envejecido. **Hasta tres materiales**, sin emisión ni texturas complejas; aprovechar la iluminación existente del templo.
- **Nivel de detalle — A04-03 (aprobada):** geometría facetada, biseles y articulaciones legibles; grietas grandes, escasas y localizadas; evitar ruido visual fino. El rango orientativo **5.000–12.000 triángulos por estatua** no es una condición de aceptación. Sin esqueleto, animación, esculpido orgánico de alta densidad ni simulaciones.

#### Construcción y referencias para el primer experimento de IA (planificadas)

- Descomponer la fuente Blender en **pedestal, piernas, torso/peto, brazos/manos, cabeza, capa, arma y detalles**; conservar objetos editables y nombres reconocibles. Emplear perfiles extruidos, mallas facetadas, biseles y materiales simples. No exigir una sola malla fusionada; **un GLB** puede contener varias mallas.
- Revisar primero la silueta con material neutro; después los materiales y detalles; finalmente importar a Godot. Los scripts aprobados T04-06/T04-07 son pequeños y específicos para este asset.
- Preparar una **lámina del mismo diseño** con frontal, perfil, tres cuartos y posterior, pose/escala coherentes y sin iluminación dramática. Añadir una silueta negra y una versión con materiales como ayuda de revisión. Las imágenes generadas con IA pueden contradecirse entre vistas: **no son planos geométricos infalibles** ni certifican por sí solas el modelo final.
- No seleccionar recursos externos para importarlos automáticamente a partir de fotografías de referencia. Registrar en `ASSETS.md` la autoría, materiales, fuentes y licencias de cualquier recurso real incorporado; una referencia visual no concede permiso para reutilizar su modelo.

#### Verificación artística prevista en Godot (criterios de revisión)

Comparar **antes/después** de la estatua procedural y la nueva, bajo la misma resolución (referencia **1280 × 720**), cámara, iluminación y condiciones de juego. Guardar capturas auténticas del viewport, no renders de Blender rotulados como capturas de Godot:

1. **Patio / vista lejana:** las dos instancias enmarcan el acceso y la silueta se distingue.
2. **Escaleras / aproximación:** se ve la parte frontal aprobada; cabeza, hombros, peto y arma se leen desde una distancia jugable.
3. **Vista cercana y lateral:** hay volumen real, biseles y conexiones correctas; sin piezas flotantes, penetraciones grotescas ni normales defectuosas.
4. **Combate / recorrido:** el nuevo asset no oculta información crucial ni modifica el espacio transitable, colisiones o encuentros de la misión.

**Aceptación visual humana obligatoria:** debe apreciarse una mejora clara respecto a cajas y cilindros, con materiales consistentes con el templo y sin defectos evidentes. Revisar también coste de renderizado con ambas instancias, importación, sombreado y regresiones de 0.3.0. **No basta** una cifra de polígonos, una imagen conceptual bonita o una prueba automática superada.

**Pendiente para producción, no para definir el alcance:** generar la lámina y el modelo, ajustar medidas según su lectura en Godot y obtener la aceptación visual humana. Los detalles no confirmados del peto y otros adornos se decidirán durante la iteración y no se tratarán como canon narrativo.

## 4. Criterios de aceptación para las issues planificadas

1. **Fuente editable:** el recurso tiene fuente Blender versionada y trazabilidad de sus materiales/texturas; puede reconstruirse la exportación sin depender de una imagen generada ni de un archivo externo desconocido.
2. **Exportación comprobada:** el modelo se entrega como `.glb` compatible con Godot, con escala, orientación, sombreado y materiales apropiados; un script Blender Python sencillo permite repetir y documentar la exportación conforme a T04-06.
3. **Calidad artística:** el Vigía aplica A04-01 y A04-02: silueta reconocible, cara orientada al patio y calidad visual claramente superior a la estatua procedural. Comparar capturas de Godot antes/después con cámara, resolución e iluminación equivalentes en patio, escaleras, cerca de la estatua y durante combate. **Su aceptación visual depende del usuario**, no solo del agente; las propuestas de detalle no se aprueban automáticamente.
4. **Integración segura:** ambas instancias existentes utilizan el mismo GLB (T04-04), conservan posiciones/rotaciones y colisiones y muestran la figura hacia el patio (A04-02) ajustando solo la orientación visual. No se rompen interacciones, navegación practicable, iluminación esencial ni la misión del templo.
5. **Pruebas y evidencia:** documentar al menos una ejecución/importación verificable, capturas reales dentro de Godot y pruebas relevantes de regresión de la `v0.3.0`. No confundir pruebas automáticas con QA visual humana.
6. **Procedencia:** conservar registro de autoría/origen/licencia de los assets; no incorporar modelos, voces, música ni texturas extraídos de KOTOR.
7. **Cierre:** solo después de implementación autorizada, QA, PR y aprobación humana se actualizarán los informes de entrega y se creará `v0.4.0`. No crear tag anticipado.

## 5. Fuera del alcance aprobado de esta versión

No producir en 0.4.0: inventario o pantalla de equipamiento; ranuras Body/casco/brazaletes y catálogo de objetos; humanoide, botas, túnicas, rigging o animaciones; remodelado general de suelos, paredes o cielo; antorchas/efectos de fuego; nuevas misiones, compañeros, progresión o sistemas narrativos; cambios del combate obtenidos de KotOR.js/reone/PyKotor; motor de mundo abierto, Houdini, USD o una base vectorial para analizar repositorios.

Esos temas pueden estudiarse en sus conversaciones y documentos correspondientes. No se asigna versión ni se crean issues por aparecer aquí.

## 6. Cuestiones abiertas de producción y aceptación (no bloquean planificar)

- **Q04-01 — Recorte de 0.4.0: resuelta el 15-10-2026.** El usuario confirma pipeline Blender→Godot + un Vigía del Umbral original, usando el mismo GLB en las dos posiciones existentes; sin inventario ni remodelación general. La planificación del milestone queda aprobada.
- **Q04-02 — Dirección visual: resuelta para iniciar la planificación el 15-10-2026.** Aprobados el concepto y orientación A04-01/A04-02 y el acabado A04-03: basalto azul grisáceo mate, piedra clara, pequeños acentos de bronce envejecido, hasta tres materiales, sin emisión ni texturas complejas, grietas grandes escasas y hoja ceremonial invertida. La lámina de referencia y la aceptación del modelo son tareas de producción/revisión, no bloqueos de diseño.
- **Q04-03 — Mismo GLB, dos posiciones: resuelta el 14-10-2026 (T04-04).**
- **Q04-04 — Pipeline y herramientas: resuelta el 15-10-2026.** Rutas aprobadas: `art/source/statues/vigia_umbral.blend`, `art/references/vigia_umbral/`, `assets/models/environment/vigia_umbral.glb` y `tools/blender/`. Flujo aprobado: script Blender Python genera y guarda `.blend`; otro script exporta `.glb`; el usuario revisa imágenes. Usar Blender 5.2.2 LTS cuando se autorice instalarlo. Blender no está localizado en el equipo; no instalarlo durante esta fase de planificación.
- **Q04-05 — Aceptación visual del modelo real: pendiente hasta disponer del asset.** Las cuatro vistas de revisión en Godot y la aprobación humana siguen como gate de QA. No bloquea crear las issues; incluirlo como criterio de aceptación de integración/QA.

No quedan decisiones de diseño que bloqueen la creación del milestone y las issues. Sigue prohibido iniciar la producción o implementación sin autorización posterior.

## 7. Desglose de GitHub aprobado para creación

El desglose está aprobado. Crear un milestone `0.4.0`, una issue padre y las tres sub-issues siguientes, sin issue adicional que duplique la versión:

- **Milestone `0.4.0`**: agrupa los entregables; no necesita issue «hacer versión 0.4.0».
- **Issue padre «Primera estatua artística integrada en la misión»**: representa el resultado verificable global, no una segunda copia del milestone.
  - **Sub-issue A «Establecer pipeline mínimo Blender–Godot»**: rutas, formatos, convenciones, script Blender Python pequeño (T04-06), comprobación de exportación/importación y documentación.
  - **Sub-issue B «Modelar y revisar el Vigía del Umbral»**: fuente editable, lámina de referencias, materiales, iteraciones y revisión visual del modelo exportado (A04-01 y A04-02).
  - **Sub-issue C «Integrar estatua en el templo y verificar la misión»**: escena reutilizable con el mismo GLB en las dos estatuas (T04-04), sustitución visual, capturas reales, regresiones y aceptación humana.

**Dependencias:** C queda bloqueada por las entregas de A y B; A y B pueden avanzar parcialmente en paralelo acordando escala y pose/emplazamiento. No registrar más bloqueos si no son reales.

Cada issue debe usar la plantilla `.github/ISSUE_TEMPLATE/funcionalidad-aprobada.md`, enlazar los IDs pertinentes, indicar fuera de alcance y aceptación. Aplicar `planificado` exclusivamente después de aprobar el alcance. Registrar estados **solo en GitHub**; este documento no tendrá una tabla espejo de progreso.

## 8. Estado de planificación y límites de autorización

1. El alcance y las decisiones necesarias para planificar quedaron aprobados el 15-10-2026.
2. Crear el milestone `0.4.0`, la issue padre y las tres sub-issues nativas, con las dependencias reales y etiquetas indicadas en `GESTION_DESARROLLO.md`. No inventar fechas.
3. La aceptación visual humana de Q04-05 se resolverá cuando exista el modelo y se pruebe dentro de Godot.
4. **No implementar el videojuego ni iniciar producción artística** hasta una autorización explícita posterior del usuario.

La versión `v0.3.0` permanece como referencia estable e inmutable mientras solo se planifica.
