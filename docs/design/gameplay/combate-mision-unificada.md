# Combate de la misión unificada

**Tipo:** sistema de gameplay  
**Estado de diseño:** aprobado  
**Mundo o contexto:** misión jugable, reglas aceptadas en v0.3.0 y conservadas en la versión estable v0.4.0  
**Fichas relacionadas:** [Interfaz de combate](../ui/interfaz-de-combate.md)  
**Issues relacionadas:** decisiones y seguimiento histórico de v0.3.0 en [PENDIENTES.md](../../versions/0.3.0/PENDIENTES.md)  
**Ficha que sustituye, si aplica:** —

## Identidad y propósito

Combate de acción en tiempo real con pausa táctica y una ronda independiente por combatiente. El diseño prioriza preparar una secuencia de órdenes contra destinatarios explícitos y reanudar el mundo cuando el jugador lo decida.

## Diseño actual

Cada combatiente usa su propio reloj. El jugador puede pausar el mundo para seleccionar objetivos y preparar órdenes. Hay una acción en curso y hasta cuatro órdenes pendientes; cada orden conserva el destinatario que tenía al encolarse. Una acción explícita puede acercar al personaje cuando el objetivo está fuera de alcance o línea de visión. Un bloqueo persistente descarta la orden con explicación.

Al agotarse la cola, el ataque básico automático continúa contra el destinatario de la última acción ofensiva ejecutada, aunque el jugador haya cambiado su selección. Las curaciones no cambian ese destinatario. Si muere, se busca un agresor vivo, visible y alcanzable. La ráfaga tiene dos impactos independientes sobre el mismo objetivo y no transfiere el segundo impacto a otro personaje.

Los valores iniciales de equilibrio son provisionales, no una reproducción exacta de KOTOR:

| Acción | Coste | Resultado inicial | Alcance |
|---|---|---|---|
| Básico | Una acción | Un intento, daño base 26 | 2,15 m |
| Ráfaga | Una acción | Dos intentos independientes, daño base 17 cada uno | 2,15 m |
| Empuje | Una acción y 24 de energía | Daño base 30; desplaza y aturde si acierta | 5,5 m |
| Descarga | Una acción y 32 de energía | Daño base 58 | 11 m |
| Curación propia | Una acción y 28 de energía | Hasta 68 de salud sobre el protagonista | Propio |
| Botiquín | Una acción y una unidad | Hasta 95 de salud sobre el protagonista | Propio |

La ronda inicial del jugador dura 2,6 s. El básico impacta a los 0,42 s; la ráfaga, a los 0,42 y 0,90 s. La energía inicial es 100 y regenera inicialmente 3 por segundo cuando el mundo avanza. Los poderes no tienen recarga adicional.

Los recursos se consumen al iniciar la ejecución, no al encolar. Cancelar una orden pendiente conserva su recurso; interrumpir una acción iniciada no lo devuelve. Curar con salud completa también consume el recurso y la acción. El empuje, la descarga y la curación consumen energía.

F o «Cancelar combate» interrumpe la acción, vacía la cola y devuelve el movimiento libre; los enemigos continúan activos. La pausa congela movimiento, daño, rondas, estados y regeneración. La selección de objetivos y la cola se especifican en la [ficha de interfaz](../ui/interfaz-de-combate.md).

## Criterios observables

- [x] La pausa táctica congela el mundo y permite preparar órdenes.
- [x] La cola admite una acción actual y cuatro órdenes pendientes con destinatarios persistentes.
- [x] Las acciones explícitas se aproximan al objetivo; los bloqueos y objetivos inválidos no transfieren órdenes a otro.
- [x] El ataque automático conserva su destinatario y cambia solo cuando deja de ser válido.
- [x] La ráfaga resuelve dos impactos separados contra un único objetivo.
- [x] Los costes se cobran al ejecutar y respetan las reglas de cancelación.
- [x] Las reglas y la misión superaron la QA de v0.3.0 y se conservaron en v0.4.0.

## Referencias y procedencia

- [Referencia técnica histórica de combate](../../versions/0.3.0/COMBATE.md).
- [Diseño aprobado de v0.3.0](../../versions/0.3.0/DISENO_DEMO.md).
- [QA y resultado de v0.4.0](../../versions/0.4.0/QA_0_4_0.md).
- Entregas: [PR #14](https://github.com/Dioniss97/ShadowsOfKharuun/pull/14) y [PR #29](https://github.com/Dioniss97/ShadowsOfKharuun/pull/29).
- [Evidencia de gameplay y controles](../../../README.md).

## Variantes y relaciones

- **Pertenece a / forma parte de:** misión jugable para un solo jugador.
- **Piezas o elementos enlazados:** [Interfaz de combate](../ui/interfaz-de-combate.md).
- **Variantes:** no hay otro modo de combate aprobado para la demo; el acceso interno de duelo no es una modalidad publicada.
- **Otros mundos o contextos donde se usa:** no definidos.

## Rutas de producción

| Artefacto | Ruta en el repositorio | Estado |
|---|---|---|
| Reglas de combate | `scripts/combat_rules.gd`, `scripts/tactical_combat.gd`, `scripts/round_queue.gd` | Implementadas |
| Evidencia de regresión | `docs/versions/0.4.0/QA_0_4_0.md` | Conservada |

## Decisiones y cambios de diseño

La especificación amplia y sus decisiones históricas permanecen en los documentos inmutables de v0.3.0. Esta ficha registra el diseño vigente y el estado de conservación confirmado por la entrega v0.4.0. No añade sistemas ni altera el equilibrio aprobado.
