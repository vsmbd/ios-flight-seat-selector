# GOALS (FlightSeatSelector)

These goals track what this repository should optimize for at its current maturity: clear structure, predictable behavior, and measurable rendering/interactions without pretending to be a full airline product.

## 1) Keep the app narrow and reviewable

- Maintain a small, understandable code surface centered on one aircraft flow.
- Keep domain and UI responsibilities separated (`Domain` vs `UI` folders).
- Preserve obvious entry points (`AppDelegate`, `SceneDelegate`, list screen, cabin screen).

Success criteria:
- a new engineer can run the app and trace seat selection flow in under 15 minutes

## 2) Ensure reliable seat-map interaction

- Keep pinch/zoom + pan behavior stable across repeated layout passes.
- Keep seat hit-testing deterministic for taps inside cabin content.
- Preserve single-selection semantics (new selection clears previous selection).

Success criteria:
- no ambiguous seat picks for repeated taps on the same point
- no broken zoom/scroll state after rotation or layout changes

## 3) Preserve rendering clarity and performance baseline

- Continue using the current CALayer-based composition for seat/armrest/cabin rendering.
- Avoid unnecessary layer churn during updates.
- Keep geometry-to-screen mapping explicit and testable.

Success criteria:
- interaction remains visually smooth on simulator and representative devices
- layout updates are localized to changed bounds/content values

## 4) Keep telemetry integration practical

- Maintain startup sink registration path in app bootstrap.
- Keep telemetry optional at runtime (app still functions without a valid endpoint).
- Ensure session/device baseline metadata remains attached when sink is enabled.

Success criteria:
- app launches and runs whether sink setup succeeds or not
- telemetry wiring can be verified from startup path without tracing unrelated modules

## 5) Document what exists now (not planned architecture)

- Keep README, goals, and non-goals aligned to implemented behavior.
- Avoid documenting modules/patterns that are not currently in the codebase.
- Update docs when behavior changes materially (selection model, supported aircraft, telemetry setup).

Success criteria:
- no stale references to removed docs or non-existent systems
