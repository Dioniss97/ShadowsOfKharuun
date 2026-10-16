# Historial de entregas

Las versiones identifican entregas jugables verificadas mediante etiquetas Git inmutables. Las dos primeras etiquetas se asignaron el 12 de octubre de 2026 a sus commits originales, sin reescribir el historial. Política y rutina en [ORGANIZACION.md](ORGANIZACION.md).

## 0.4.0-rc1 — 2026-10-16, candidata local

Pendiente de aceptación humana de presentación dentro del nivel, decisión Q04-06 y entrega por PR/tag. La versión estable publicada sigue siendo `v0.3.0`.

- Vigía del Umbral original tras ocho iteraciones artísticas: escultura encapuchada vertical, mangas continuas, puños de piedra con dedos juntos, vibrohoja ceremonial y estola plana oscura con Código Sith inglés en runas rojo mate.
- Fuente Blender editable, generador/exportador específicos, materiales propios horneados en nueve mapas PBR e incrustados en un GLB de tres materiales. Sith AF incorporada con atribución/licencia.
- Dos instancias del mismo GLB en la demo, mirando al patio y conservando posiciones, rotaciones y colisiones. Retirados los ojos emisivos y la luz propia de la figura provisional.
- Corregidos la repisa interior de capucha, el pellizco palmar superior, la pérdida de pigmento de glifos y las motas triangulares de color horneado.
- Comparación real antes/después en cinco vistas de Godot a 1280×720; 49 formas físicas conservadas, regresiones de 213 casos headless y 238 GPU sin fallos. Reglas de misión/combate conservadas.
- Evidencia y aceptación en [QA_0_4_0.md](QA_0_4_0.md); límites, causas y decisiones reutilizables en [APRENDIZAJES_0_4_0.md](APRENDIZAJES_0_4_0.md).

## 0.3.0 — 2026-10-14

Etiqueta: [v0.3.0](https://github.com/Dioniss97/ShadowsOfKharuun/tree/v0.3.0). QA humana aprobada por el usuario: «Apruebo el QA de la 0.3.0». Candidata aceptada: RC2 (`f8ada97`). PR #14 integrada en `main` (`1304678`), 21 issues y milestone cerrados; el cierre solo actualiza versión, textos y documentación.

### Añadido y corregido

- Una única misión del templo con combate táctico: rondas independientes, pausa inicial por encuentro, acción actual y cuatro órdenes pendientes. Cada orden conserva su destinatario; el básico posterior usa el último objetivo ofensivo ejecutado y espera quieto fuera del alcance cuerpo a cuerpo.
- Básico y ráfaga con dos intentos de impacto; empuje, descarga, curación propia y tres botiquines. Gesto de la mano izquierda y efectos diferenciados; consumo al ejecutar incluso con salud llena, sin recargas adicionales ni orden Defensa.
- Falta de recursos D31: retirar la orden impagable y las pendientes del mismo recurso; la siguiente válida ocupa esa oportunidad. Solo si no queda ninguna se pierde la ronda, con básico automático en la siguiente. Poderes inasequibles desactivados y botiquín agotado sin icono.
- A/D gira continuamente al personaje; W+A/D conduce en curvas/círculos y S retrocede sin invertir el frente. RMB conserva la órbita al soltar quieto/pausado y retorna suave al desplazarse. F cancela combate y libera movimiento, con enemigos que siguen persiguiendo.
- Cursor y retícula contextuales: seleccionar con primer clic; segundo clic en hostil encola básico, neutral permite voz. Acólitos neutrales rotan tres frases.
- Vida/nombre solo del seleccionado, también neutral. Tarjeta ofensiva compacta sobre el enemigo solo en combate. Menú inferior izquierdo con poderes personales primero y consumibles después, huecos futuros desactivados; cola de iconos, acción actual y Cancelar compactos, con destinos en tooltip; retrato y recursos pequeños.
- Primera conversación automática del guardián; segunda por clic tras los acólitos, con combate o paso pacífico. Diálogos congelan tiempo y recursos, sin regalos entre encuentros. Ambas rutas abren el templo y requieren reclamar el mismo núcleo con ratón/mano y aproximación física. Reinicio completo después de morir.
- Ayuda breve omitible, avisos contextuales y lanzadores unificados; duelo conservado como prueba interna.

### Verificación y organización

213 comprobaciones lógicas y 238 con GPU, sin fallos; las 238 incluyen 25 capturas reales de 1280×720. Suite parcial adicional de UI/interacción: 72 comprobaciones sin fallos y seis capturas de 1920×1080. Bot normal: victoria en 98,15 s simulados, 203/340 salud y 33 acciones, sin teletransporte ni daño directo. Evidencia automática de RC2 y aprobación humana separadas en [RESULTADO.md](RESULTADO.md).

Diseño D01–D36 (D27 sustituida por D33), criterios DEMO-01–13/B1–B8 y guía de QA conservados en Markdown/Git. Repo privado, PR #14 y milestone con 21 issues. Engram mantiene lectura exclusiva de `shadowsofkharuun`; sus memorias ajenas se conservan y las escrituras de agente esperan el registro del host. El proyecto se detiene después de esta entrega hasta que el usuario defina 0.4.

## 0.2.0 — 2026-10-12

Etiqueta: `v0.2.0`. Commit de entrega: `f516f41`.

### Añadido

- Duelo táctico separado con selección de objetivo, rondas independientes, una acción actual y cuatro órdenes pendientes.
- Ataque básico automático, aproximación física, pausa táctica con preparación de órdenes y controles de cancelación/retirada.
- Empuje, descarga y acción Defensa; energía, recargas y cálculo de acierto/crítico.
- Pruebas del duelo y cuatro capturas reales; la misión original permanece disponible.

### Corregido

- Espada orientada hacia delante y animación con contacto diferido.
- Colisiones sólidas entre protagonista y enemigos.
- Ataques enemigos limitados por visibilidad; empuje cancela su impacto preparado.
- Selección al comenzar pausado, colocación inicial de cuerpos e interacción de botones y teclado.

### Verificación y límites

56 comprobaciones tácticas sin ventana y 60 con GPU; regresión original de 34/43 comprobaciones; partidas normales del bot completadas. Evidencia en [RESULTADO.md](RESULTADO.md).

El combate táctico solo se aplica al duelo. La misión del templo mantiene su combate de acción. Personajes procedurales y Godot portátil; sin modelos Blender ni exportación independiente del motor.

## 0.1.0 — 2026-10-12

Etiqueta: `v0.1.0`. Commit de entrega verificada: `138d459`; implementación inicial: `5262e15`.

### Añadido

- Asalto al templo: menú, exploración, diálogo con tres respuestas, tres acólitos, guardián, victoria y derrota.
- Movimiento, cámara, pausa, habilidades, HUD, colisiones y rampa del templo.
- Mundo, personajes y efectos procedurales; textos en español y TTS de Windows cuando hay voz disponible.
- Lanzador `PLAY.bat`, pruebas funcionales, capturas con GPU y bot de partida normal.

### Verificación histórica

La entrega registró 33 comprobaciones sin ventana y 42 con GPU, ocho capturas reales y una victoria del bot. Estos resultados pertenecen a esta versión; los informes locales de prueba se sobrescriben al ejecutar nuevas pruebas. El informe histórico está conservado en `RESULTADO.md` dentro del commit `138d459`.
