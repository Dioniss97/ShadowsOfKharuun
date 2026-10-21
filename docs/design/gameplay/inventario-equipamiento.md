# Inventario y equipamiento

**Tipo:** sistema de juego.
**Estado de diseño:** aprobada para el ciclo mínimo autorizado; interfaz visual sujeta a revisión.
**Issues:** [alcance #34](https://github.com/Dioniss97/ShadowsOfKharuun/issues/34), [#37](https://github.com/Dioniss97/ShadowsOfKharuun/issues/37), [QA #38](https://github.com/Dioniss97/ShadowsOfKharuun/issues/38).

## Reglas

La partida empieza sin uniforme equipado y con un primer conjunto disponible para probar el flujo. Equipar un uniforme sustituye la apariencia corporal completa y su calzado. Retirarlo restaura automáticamente la ropa base. Los objetos de cabeza quedan fuera del uniforme; esta entrega no produce uno.

La primera prueba cambia apariencia y conserva estadísticas y reglas de combate. Se mantiene un modelo de inventario único por personaje/partida; nueva partida y reinicio recrean el estado inicial. No existe persistencia entre sesiones en este alcance.

Abrir el inventario pausa gameplay, reloj y combate. Cerrarlo restaura la pausa táctica previa. I abre/cierra, ESC cierra. Durante menú, diálogo o final de partida no se abre. El panel captura sus entradas para evitar que un clic equipe y ataque simultáneamente.

## Criterios observables

Equipar/retirar por botones reales sincroniza modelo, inventario y vista previa. Un ID ajeno al inventario se rechaza. Reabrir el panel conserva el estado actual de la partida. Reiniciar vuelve al estado base. Las pausas y diálogos de la misión siguen funcionando.

## Producción

- Estado: scripts/wardrobe.gd.
- Integración: scripts/player.gd y scripts/main.gd.
- [Interfaz de inventario](../ui/inventario.md).
- Prueba real de entradas y escenas: tests/wardrobe_runner.gd.
