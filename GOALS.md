# GOALS (FlightSeatSelector)

These goals define what “done” means for the **reference app**. The bar here is not product completeness; it is *clarity, measurability, and reviewer impact*.

---

## 1) Be a credible Principal/Staff signal

- Demonstrate an opinionated architecture with **clean boundaries**:
  - domain logic
  - state management
  - rendering and hit-testing
  - interaction handling
  - telemetry / instrumentation
- Make tradeoffs explicit:
  - why UIKit/CALayer (vs SwiftUI/Metal) for this reference
  - why a particular state model
  - what is intentionally kept simple
- Keep the codebase reviewable in ~30–45 minutes:
  - obvious entry points
  - minimal magic
  - documented invariants

---

## 2) Prove interaction performance under load

- Smooth pan/zoom/selection in a dense seat map.
- Stable performance on older devices / older iOS targets (where feasible).
- Rendering pipeline minimizes:
  - view/layer churn
  - repeated layout work
  - per-frame allocations
- Provide a stress mode for repeatable load testing:
  - synthetic seat maps at multiple sizes
  - controlled “worst-case” scenarios

Success criteria:
- measurable spans for layout/apply/render
- ability to demonstrate performance improvements with before/after traces

---

## 3) First-class observability (not just logs)

- Emit structured events via `EventDispatch.default` and the `Event` protocol (see [CONVENTIONS.md](CONVENTIONS.md)) for:
  - user inputs
  - domain decisions
  - rendering spans
  - threading/queue context
- Correlate cause → effect via checkpoints and event metadata (eventId, checkpoint, taskId).
- No in-app event viewer; observability is Grafana-based (events flow to ClickHouse; reviewer uses dashboards).

Success criteria:
- a reviewer can reconstruct a bug/perf issue from events in Grafana

---

## 4) Deterministic, testable behavior

- State updates are explicit and centralized (avoid “random” side effects).
- Seat selection rules are unit-testable without UI.
- Layout primitives and hit-testing logic can be tested with deterministic inputs.

Success criteria:
- core rules covered by unit tests
- layout/hit-testing has targeted tests or golden snapshots

---

## 5) Be a portfolio-ready artifact

- Fast onboarding:
  - README explains the narrative and how to run
  - demo script included
- Clear “what to look at” pointers:
  - where state lives
  - where rendering happens
  - where events are emitted
- Optional integration docs for:
  - ClickHouse sink + proxy
  - Grafana dashboard

Success criteria:
- someone unfamiliar can run and “get it” in under 10 minutes

---

## Conventions (technical alignment)

See **[CONVENTIONS.md](CONVENTIONS.md)** for: EventDispatch + Event protocol, enum-based events with MonotonicNanostamp & Checkpoint, GCD-only (no Swift concurrency), CheckpointedResult (no throws), Grafana-only observability, seat data (bundled JSON + optional open-source by manufacturer/model).
