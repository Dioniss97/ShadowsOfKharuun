# Vigía del Umbral

**Tipo:** estatua monumental / asset de entorno  
**Estado de diseño:** aprobada  
**Mundo o contexto:** patio del templo de la misión jugable. La documentación consultada no establece el planeta ni una cultura de origen para asignarle una ficha de mundo.  
**Fichas relacionadas:** —  
**Issues relacionadas:** [#26 — pipeline Blender–Godot](https://github.com/Dioniss97/ShadowsOfKharuun/issues/26), [#27 — modelar y revisar el Vigía](https://github.com/Dioniss97/ShadowsOfKharuun/issues/27)  
**Ficha que sustituye, si aplica:** —

## Identidad y propósito

Estatua original de un guerrero ceremonial que reemplaza visualmente las dos estatuas provisionales del patio. Un mismo GLB se reutiliza en ambas posiciones; no altera las reglas jugables ni la geometría de colisión del nivel.

## Diseño actual

Representa un guardián antiguo, monumental y erguido, con realismo estilizado oscuro. La forma debe leerse como escultura monolítica: rostro oculto por una capucha profunda, túnica pétrea larga con pliegues tallados, hombros y mangas integrados, postura asimétrica natural y una vibrohoja ceremonial original sostenida en vertical, con la punta hacia el pedestal.

La proporción aproximada de mitad humanoide y mitad estatua describe el lenguaje visual, no medidas anatómicas. Las dimensiones exploradas en producción son orientativas; no son requisitos aprobados.

La piedra es mate, de gris pizarra con un matiz azul discreto. El arma ofrece contraste con piedra más clara y bronce envejecido. La estola y los bordes de la capucha son más oscuros; las runas tienen pigmento rojo desgastado, mate y sin emisión. Se mantienen hasta tres materiales y no se emplea emisión.

La estola lleva el Código Sith completo, sus seis versos en inglés, transliterados gráficamente con runas. Es una representación visual solicitada, no una traducción a la lengua Sith ni una afirmación de grafía oficial. La fuente Sith AF conserva su licencia y atribución en las rutas de créditos.

## Criterios observables

- [x] Silueta vertical y monolítica; rostro oculto; continuidad de capucha, manto y túnica.
- [x] Manos, muñecas y agarre de la vibrohoja legibles; postura conserva asimetría natural.
- [x] La inscripción completa se lee en la estola; pigmento rojo mate y sin emisión.
- [x] El mismo GLB se usa en las dos posiciones orientadas al patio.
- [x] La integración conserva las 49 formas de colisión existentes.
- [x] La presentación integrada y el modelo VIII fueron aceptados por el usuario en v0.4.0.

## Referencias y procedencia

| Referencia | Qué aporta | Fuente, autoría o licencia |
|---|---|---|
| [Diseño de v0.4.0](../../../versions/0.4.0/DISENO_0_4_0.md) | Decisiones A04-01–A04-13, sustituciones e iteraciones | Decisiones y aprobación del usuario |
| [Galería de geometría](../../../../art/references/vigia_umbral/README.md) | Vistas, detalles e informes del modelo VIII | Renders de Blender del repositorio |
| [Comparación integrada](../../../../art/references/vigia_umbral/integration/README.md) | Capturas del patio real y evidencia de integración | Capturas de Godot del repositorio |
| [QA de v0.4.0](../../../versions/0.4.0/QA_0_4_0.md) | Verificación de presentación, colisiones y cámaras | Evidencia de la entrega |
| [Créditos del GLB](../../../../assets/models/environment/vigia_umbral.CREDITS.md) | Atribución de la fuente usada para las runas | Sith AF, Ender Smith / AurekFonts, CC BY 3.0 US |
| [Inventario de recursos](../../../project/ASSETS.md) | Procedencia y límites de redistribución | Documento del proyecto |

Las referencias visuales aportadas en la conversación guiaron la forma, pero no se distribuyen como texturas ni modelos.

## Variantes y relaciones

- **Pertenece a / forma parte de:** escenario del patio del templo.
- **Piezas o elementos enlazados:** modelo y vibrohoja ceremonial forman un único asset.
- **Variantes:** ninguna aprobada.
- **Otros mundos o contextos donde se usa:** dos instancias en el mismo patio; no hay otros mundos definidos para este elemento.

## Rutas de producción

| Artefacto | Ruta en el repositorio | Estado |
|---|---|---|
| Fuente editable | `art/source/statues/vigia_umbral.blend` | Disponible |
| Generador Blender | `tools/blender/create_vigia.py` | Disponible |
| Exportador GLB | `tools/blender/export_vigia.py` | Disponible |
| Recurso de ejecución | `assets/models/environment/vigia_umbral.glb` | Integrado en ambas posiciones |
| Galería y evidencia | `art/references/vigia_umbral/` | Disponible |
| Atribución del modelo | `assets/models/environment/vigia_umbral.CREDITS.md` | Disponible |

## Decisiones y cambios de diseño

- A04-01 a A04-11 recogen la dirección artística aprobada y las revisiones; el diseño aceptado sustituye alternativas previas. Se conserva el historial detallado en [DISENO_0_4_0.md](../../../versions/0.4.0/DISENO_0_4_0.md).
- A04-12 acepta el modelo VIII para integración. A04-13 registra la aprobación de la presentación integrada y el uso de GPL-2.0-or-later exclusivamente para los dos scripts Blender; no extiende esa licencia al modelo ni al juego.
