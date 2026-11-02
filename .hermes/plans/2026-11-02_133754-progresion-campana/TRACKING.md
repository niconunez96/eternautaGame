# Seguimiento — progresión de campaña

| Fase | Estado | Artefacto |
|---|---|---|
| Diseño de campaña | Acordado | `00-plan.md` |
| Diagrama de nodos del mapa | Acordado | `phases/01-mapa/01-diagrama-nodos.md` |
| Diseño del vertical slice | Acordado | `phases/02-vertical-slice/01-diseno-vertical-slice.md` |
| Implementación Godot | Implementado y verificado localmente | `phases/03-implementacion/00-plan-implementacion-vertical-slice.md` |

## Convenciones

- Las decisiones de diseño se agregan al final de `00-plan.md` o en una nota de fase.
- No se implementa una habilidad, arma o jefe antes de validar su función de exploración, narrativa y mapa.
- Los cambios al prototipo deben quedar en una fase de implementación con pruebas asociadas.

## Verificación local

- `make verify`: 10 tests unitarios, 3 de integración y los recorridos QA de `VN` y `VS` en verde.
