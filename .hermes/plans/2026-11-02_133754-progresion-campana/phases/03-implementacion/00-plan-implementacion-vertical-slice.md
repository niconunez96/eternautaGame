# Vertical slice Chalet — Plan de implementación

> **For Hermes:** Use `spec-drive-development` to implement this plan task-by-task.

**Goal:** reemplazar la arena prototipo por el vertical slice jugable «Chalet → fabricar traje → primera salida a la nevada», sin combate ni movimientos sobrehumanos.

**Architecture:** `Main` conserva la coordinación de escena y delega la progresión pura a `ChaletProgression`. Un `Chalet` autorado reúne la geometría y los interactuables reutilizables: tres materiales, una mesa de fabricación y dos salidas. El jugador sólo conserva caminar, salto humano único e interacción contextual; los componentes informan a `Main`, que actualiza HUD y transición de slice.

**Tech stack:** Godot 4.6, GDScript, GUT, Godot QA Pro headless, Make.

---

## Alcance y contratos cerrados

- Estados observables: `encerrado`, `componente_obtenido`, `materiales_completos`, `traje_equipado`, `exterior_iniciado`.
- Materiales fijos: `lona`, `sellado_guantes`, `mascara_filtro`; se recogen en orden libre y no hay inventario o recetas genéricas.
- La fabricación sólo equipa el traje con los tres materiales y mantiene ambas salidas bloqueadas hasta entonces.
- `VN` finaliza con `Vicente López norte`; `VS` finaliza con `Vicente López sur`.
- Fuera de alcance: enemigo, combate, salud/respawn, checkpoint, radio, mapa completo, doble salto, dash, wall-jump y contenido posterior al umbral.

## Task 1: Progresión pura y retirada de movilidad heredada

**Objective:** establecer primero el contrato testeable del slice y dejar al jugador con movilidad humana básica.

**Files:**
- Create: `scripts/app/chalet_progression.gd`
- Create: `tests/unit/test_chalet_progression.gd`
- Modify: `tests/unit/test_player_motion.gd`
- Modify: `scripts/player/player_motion_rules.gd`
- Modify: `scripts/player/player_controller.gd`
- Modify: `project.godot`

**Step 1 — RED:** crear `test_chalet_progression.gd` con casos para estado inicial, tres materiales idempotentes, seis permutaciones, fabricación rechazada con 0/1/2, fabricación exitosa con 3 y ambas salidas antes/después del traje. En `test_player_motion.gd`, reemplazar pruebas de dash/doble salto por un salto humano y rechazo del segundo salto aéreo; verificar `InputMap.has_action("dash") == false`.

**Step 2 — verificar RED:** ejecutar los dos archivos GUT y confirmar fallos por clase/properties aún ausentes y contratos heredados.

**Step 3 — GREEN:** implementar `ChaletProgression` como `RefCounted` con constantes de estados/materiales, `collect_material`, `can_craft`, `craft_suit`, `can_exit`, `take_exit`, `selected_exit` y `zone_title`. Simplificar reglas y controlador: eliminar dash, doble salto, ataque, salud/daño/respawn y sus flags; conservar gravedad, coyote-time, aceleración, desplazamiento y un salto. Eliminar sólo el action `dash` de `project.godot` y mantener `interact`.

**Step 4 — verificar GREEN:** volver a ejecutar ambos archivos y comprobar que el segundo salto es rechazado y `dash` no existe.

## Task 2: Interactuables y Chalet autorado

**Objective:** reemplazar el loop de arena por componentes que expresen materiales, fabricación y dos salidas físicas.

**Files:**
- Create: `scenes/world/chalet.tscn`
- Create: `scenes/world/suit_material.tscn`
- Create: `scripts/world/suit_material.gd`
- Create: `scenes/world/fabrication_station.tscn`
- Create: `scripts/world/fabrication_station.gd`
- Create: `scenes/world/suit_exit.tscn`
- Create: `scripts/world/suit_exit.gd`
- Modify: `scenes/app/main.tscn`
- Modify: `scripts/app/main.gd`
- Modify: `scenes/ui/hud.tscn`
- Modify: `scripts/ui/hud.gd`
- Modify: `scenes/player/player.tscn`

**Step 1 — RED:** reemplazar `tests/integration/test_main_scene.gd` por contratos de composición y progresión: tres materiales, mesa/Favalli, `ExitVN`, `ExitVS`, HUD de estado/objetivo; ausencia explícita de enemigo, recompensa de doble salto, obstacle, radio y objetivo de combate. Agregar casos de salida sin traje, mesa habilitada sólo con el tercer material, fabricación visible y ambos cierres con título distinto.

**Step 2 — verificar RED:** ejecutar la integración aislada y confirmar fallos antes de agregar los nodos/componentes.

**Step 3 — GREEN:**
- Crear los `Area2D` reutilizables. `SuitMaterial` emite `collected(material_id)` una sola vez; `FabricationStation` emite solicitud/éxito sólo cuando `Main` confirme `can_craft`; `SuitExit` emite una solicitud por `exit_id` y no completa sin permiso.
- Construir `Chalet` con colisiones/visuales placeholder para estar, cocina, pasillo, cuarto de herramientas, escalera/altillo y dos umbrales. Las tres rutas deben ser transitables por caminar/salto único/agacharse o interactuar; no crear un hueco que requiera habilidades removidas.
- `Main` instancia `Chalet`, jugador y HUD, conecta señales y mantiene `progression`, `slice_state`, `suit_equipped`, `selected_exit` y `zone_title` como estado inspectable por QA. Un input `interact` debe accionar el interactuable cercano mediante una selección contextual única.
- Reemplazar HUD por `StatusLabel`, `ObjectiveLabel`, `SliceStateLabel` y controles correctos; no mostrar salud, checkpoint, habilidad ni ataque.

**Step 4 — verificar GREEN:** ejecutar integración aislada; confirmar estados, bloqueos y ambos títulos.

## Task 3: QA jugable de ambas rutas

**Objective:** probar dos partidas nuevas completas sin depender de dash, doble salto ni combate.

**Files:**
- Delete: `tests/qa/smoke.json`
- Create: `tests/qa/chalet_vn.json`
- Create: `tests/qa/chalet_vs.json`
- Modify: `Makefile`

**Step 1 — RED:** cambiar `Makefile` para que `qa` ejecute ambos JSON de Chalet, cada uno con informe JSON/JUnit propio. Crear los escenarios con aserciones para salida bloqueada inicial, materiales completos, fabricación, estado de traje y cierre según ruta.

**Step 2 — verificar RED:** correr `make qa`; debe fallar hasta que los componentes y su recorrido sean realizables con inputs reales.

**Step 3 — GREEN:** ajustar posiciones/colisiones y secuencias de input de las rutas para que cada escenario use una sola pulsación de salto como máximo por obstáculo aéreo y no nombre `dash`, `attack` ni un segundo salto aéreo.

**Step 4 — verificar GREEN:** ejecutar `make qa` y comprobar dos reportes exitosos, uno `VN` y otro `VS`.

## Task 4: Limpieza del prototipo y documentación

**Objective:** retirar contratos que contradicen el slice y dejar el repositorio coherente.

**Files:**
- Delete: `scenes/world/basic_enemy.tscn`
- Delete: `scripts/world/basic_enemy.gd`
- Delete: `scenes/world/checkpoint.tscn`
- Delete: `scripts/world/checkpoint.gd`
- Delete: `scenes/world/double_jump_reward.tscn`
- Delete: `scripts/world/double_jump_reward.gd`
- Delete: `scenes/world/exit_objective.tscn`
- Delete: `scripts/world/exit_objective.gd`
- Delete: `scripts/world/traversal_obstacle.gd`
- Delete: `scenes/world/test_arena.tscn`
- Delete: `scripts/player/player_health.gd`
- Delete: `tests/unit/test_player_health.gd`
- Modify: `README.md`
- Modify: `.hermes/plans/2026-11-02_133754-progresion-campana/TRACKING.md`

**Step 1 — RED:** buscar las referencias de prototipo retirado (`double_jump`, `dash`, `BasicEnemy`, `Checkpoint`, `TraversalObstacle`, `ExitObjective`, `attack`) y dejar que las referencias obsoletas causen el fallo esperado de import/test cuando corresponda.

**Step 2 — GREEN:** eliminar componentes y `.uid` asociados, quitar referencias, actualizar README con controles y QA del Chalet, y actualizar tracking a `Implementación Godot → En revisión`.

**Step 3 — verificar:** ejecutar `git diff --check`, `make verify`, `make export-linux-debug`, y búsquedas de referencias obsoletas fuera de `addons/` e historial/artefactos de diseño.

## Revisión y cierre

1. Revisión de especificación: confirmar uno por uno los siete criterios de aceptación del diseño y exclusiones.
2. Revisión de calidad: confirmar que no existe inventario/crafting genérico, habilidades latentes ni escena de arena construida en código.
3. Validaciones finales desde este worktree: `make verify`, `make export-linux-debug`, `git diff --check`, `git status --short`.
4. Commitear hitos coherentes en `feat/first-vertical-slice`; no hacer merge directo.

## Riesgos y decisiones

- El QA actual sólo puede enviar inputs/esperas/aserciones: el estado de progresión queda intencionalmente inspectable en `Main`.
- `interact` existe en InputMap pero hoy no tiene consumidor; el slice debe resolverlo sin reintroducir `attack`.
- Las interacciones deben ser deterministas para GUT/QA y no depender de diálogo, audio ni timing visual.
- El arte final, audio, NPC sofisticados y visual QA con capturas quedan fuera de este hito.
