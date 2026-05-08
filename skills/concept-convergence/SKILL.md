---
name: concept-convergence
description: Use when code has parallel or semantically similar representations of the same data, state, or intent. Find unnecessary translation layers, choose one canonical model, and collapse adapters around it.
---

# Concept Convergence

Use this when the code keeps converting between `A` and `B` that mean almost the same thing.

## Workflow

1. List the overlapping shapes.
2. Separate real differences from accidental ones.
3. Define one canonical model `C`.
4. Move pure logic to `C`.
5. Replace reinterpretation code with direct consumers of `C`.
6. Delete mirrors, snapshots, and compatibility shims.

## Heuristics

- Prefer one model per concept, not one per layer.
- Keep UI/TUI types out of domain models.
- If two types mostly differ by naming or wrapper fields, merge them.
- Keep conversions only at real boundaries: IO, rendering, persistence, protocol.

## Validation

- Search for old type names and conversion helpers.
- Check that fewer fields are copied across layers.
- Re-run focused tests around the boundary you changed.
