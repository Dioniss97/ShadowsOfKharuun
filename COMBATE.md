# Primera iteración: duelo táctico

Alcance: pasos 1–3 del plan. Corregir arma, colisiones y sincronización; probar selección, rondas, cola y pausa en un duelo dentro del patio actual. La misión original continúa disponible como referencia. Blender, compañero, ampliación de mapa y equilibrio final de toda la misión corresponden a iteraciones posteriores.

## Reglas propuestas para Kharuun

- Combate en tiempo real con pausa. Cada combatiente tiene su propio reloj; no hay alternancia global entre jugador y enemigo.
- Una acción activa y hasta cuatro órdenes pendientes. Las órdenes conservan su objetivo al encolarse; cambiar de selección afecta a las nuevas órdenes.
- La ronda del jugador dura 2,6 s como ajuste inicial propio. El golpe se resuelve a los 0,42 s de comenzar la animación y solo una vez. La ronda restante representa recuperación.
- Ataque básico automático al vaciarse la cola si el jugador sigue enfrentado a un objetivo vivo. Sin objetivo, el personaje espera.
- Espacio pausa y permite seleccionar, encolar o cancelar. Escape abre el menú de pausa. Reanudar un menú no elimina una pausa táctica anterior.
- Clic izquierdo selecciona un enemigo y comienza el enfrentamiento; Tab cambia selección. Botón derecho mantenido gira la cámara. 3 encola ataque, 1 empuje, 2 descarga, 4 defensa. F se retira y cancela órdenes; WASD interrumpe el enfrentamiento para moverse manualmente.
- Fuera de alcance, una orden acerca al personaje físicamente. Si hay un obstáculo persistente, se cancela con explicación en pantalla. Objetivos muertos se descartan; no se sustituye silenciosamente su objetivo por otro.
- El coste y cooldown de un poder se consumen al comenzar su acción. La energía no se consume al pulsar para encolarlo. Defensa aumenta temporalmente la defensa y reduce el daño; el enemigo conserva su ritmo.
- Acierto: 1d20 + ataque frente a defensa. 1 siempre falla; 20 es crítico. Esta estructura toma como referencia KOTOR; valores, duración y efectos son decisiones de este prototipo.
- Movimiento y daño se ejecutan en física, independientes del renderizado. Pausa congela movimiento, rondas, cooldowns y estados.
- Personajes sólidos, frente local -Z y hoja orientada hacia ese frente. La locomoción no cambia la orientación durante el golpe.

## Verificación

Comprobar orden, límite y cancelación de cola; autoataque; objetivos independientes; daño diferido y único; alcance al impactar; defensa; pausa y órdenes durante ella; muerte de objetivo; retirada; colisiones y rampa; victoria y reinicio del duelo. Inspeccionar capturas frontal y lateral del arma. Repetir el recorrido original para detectar regresiones y jugar el duelo con un bot que use la misma cola y reglas.

Fuentes: [manual oficial de KOTOR, páginas 28–31](https://cdn.steamstatic.com/steam/apps/32370/manuals/KOTORI_Manual.pdf#page=15) y [manual oficial de KOTOR II, páginas 20–21](https://cdn.akamai.steamstatic.com/steam/apps/208580/manuals/KOTORII_Manual.pdf#page=11).
