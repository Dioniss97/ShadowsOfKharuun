# Interfaz de combate

**Tipo:** interfaz de gameplay  
**Estado de diseño:** aprobada  
**Mundo o contexto:** misión jugable, interfaz aceptada en v0.3.0 y conservada en v0.4.0  
**Fichas relacionadas:** [Combate de la misión unificada](../gameplay/combate-mision-unificada.md)  
**Issues relacionadas:** historial de decisiones y QA en [PENDIENTES.md](../../../versions/0.3.0/PENDIENTES.md), [RESULTADO.md](../../../versions/0.4.0/RESULTADO.md) y [PR #14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14)  
**Ficha que sustituye, si aplica:** —

## Identidad y propósito

Dar acceso claro a objetivos, acciones y recursos sin tapar la escena. La selección para preparar la próxima orden se distingue de la acción que ya está en curso y del destinatario guardado en una orden.

## Diseño actual

La acción actual aparece a la derecha de la cola; hasta cuatro órdenes pendientes aparecen en iconos compactos y se pueden cancelar de forma individual. Al pasar el cursor, cada orden muestra acción y destinatario. «Limpiar cola» elimina solo las pendientes y conserva la acción en curso.

Los tres selectores flotan sobre el enemigo seleccionado y permiten recorrer acciones sin encolarlas; el clic en un icono crea la orden con el objetivo seleccionado en ese momento. Se ocultan al salir del combate, cancelar con F o cuando no hay un objetivo válido/visible. Se mantienen también durante la pausa táctica. El nombre y la salud aparecen sobre el personaje vivo seleccionado, incluso si es neutral; no hay barras 3D generales sobre los enemigos.

Abajo a la izquierda se muestran primero los poderes personales y después los consumibles, incluido el contador de tres botiquines iniciales. Los selectores grises no disponibles indican que no se pueden encolar. Flechas y rueda permiten recorrerlos sin enviar órdenes.

## Criterios observables

- [x] La acción actual se distingue visualmente de las cuatro posiciones pendientes.
- [x] Cada orden conserva su objetivo aunque cambie la selección y ofrece acción/destinatario al pasar el cursor.
- [x] Las órdenes pendientes se cancelan individualmente; limpiar la cola no interrumpe la acción en curso.
- [x] Los selectores siguen al objetivo visible, permanecen durante pausa y se ocultan al salir del combate o perder el objetivo.
- [x] Solo el personaje vivo seleccionado muestra nombre y salud; no hay barras generales.
- [x] Los controles y paneles dejan visible la escena y siguen la presentación compacta aprobada.

## Referencias y procedencia

- [COMBATE.md](../../../versions/0.3.0/COMBATE.md): controles, objetivos y presentación aprobados.
- [Resultado y evidencia de v0.4.0](../../../versions/0.4.0/RESULTADO.md).
- [README de la demo](../../../README.md): controles vigentes para el jugador.

## Variantes y relaciones

- **Pertenece a / forma parte de:** misión jugable.
- **Piezas o elementos enlazados:** [sistema de combate](../gameplay/combate-mision-unificada.md).
- **Variantes:** HUD de misión; no hay variante alternativa aprobada.
- **Otros mundos o contextos donde se usa:** no definidos.

## Rutas de producción

| Artefacto | Ruta en el repositorio | Estado |
|---|---|---|
| Lógica de la interfaz táctica | `scripts/tactical_ui.gd` | Implementada |
| Interfaz común | `scripts/ui.gd` | Implementada |
| Escena de misión | `scenes/level.tscn` | Implementada |
| Evidencia | `docs/versions/0.4.0/QA_0_4_0.md` | Conservada |

## Decisiones y cambios de diseño

Las decisiones de HUD de D01–D36 y B1–B8 se conservan en la documentación histórica de v0.3.0. v0.4.0 integra el Vigía sin sustituir estas reglas de interfaz; la ficha es su resumen canónico para cambios futuros.
