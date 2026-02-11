# FlightSeatSelector

A reference iOS app that demonstrates **interaction-heavy, performance-sensitive UI** and **first-class observability** (structured events + metrics) in a way that is easy to review in an interview or code walk-through.

This repo is intentionally a *reference application*, not a product. The purpose is to validate architectural decisions in the surrounding ecosystem (platform layer, telemetry pipeline, concurrency discipline, and UI rendering choices).

---

## What this app showcases

### 1) Complex UI with real interaction pressure
- High-density seat map rendering (rows/columns, spacing, legends).
- Zoom + pan, selection, multi-seat rules, and “stateful” UI transitions.
- Deterministic state updates (avoid accidental UI drift).
- Smooth interaction on older devices and older OS versions where possible.

### 2) Opinionated system design signals
- Clear boundaries between **domain**, **rendering**, **input**, and **instrumentation**.
- Explicit concurrency and background work segregation (no hidden work on main).
- Structured events for “why did this happen?” debugging, not just logs.

### 3) Observability pipeline (Grafana-based)
- Structured event stream via `EventDispatch.default` and the `Event` protocol (aligned with the rest of the workspace):
  - UI interactions (tap, drag, zoom, select/deselect)
  - Performance checkpoints (layout, render, diff/apply, frame pacing signals)
  - Domain decisions (rule evaluation, conflicts, pricing outcomes)
- No in-app debug views or event timeline UI. Events flow to ClickHouse via the existing Telme/ingestion pipeline; dashboards are in Grafana.

---

## Audience

- **Hiring managers / reviewers**: quick proof that the platform layer is not theoretical.
- **Engineers**: an example of how to build complex UIKit interactions without turning the codebase into a state mess.
- **Future-you**: a stable “demo app” you can evolve while keeping it reviewable.

---

## Core features

### Seat map rendering
- Seat grid with categories (e.g., available, selected, blocked, premium).
- Labels for rows, aisles, and sections.
- Legend and contextual UI (price, restrictions, information).

### Interactions
- Tap to select / deselect.
- Pan around the map.
- Pinch to zoom (with bounds, snapping, and hit-testing that remains correct).
- Optional “rubber-band” / clamped scrolling.

### Rules and constraints (examples)
- Cannot select blocked seats.
- Limit selection count.
- Optional adjacency rules (e.g., avoid leaving single empty seat, group constraints).
- Seat-type restrictions (e.g., exit row rules).

### Performance focus
- Render pipeline designed to minimize:
  - view churn
  - over-layout
  - excessive allocations per gesture frame
- Instrumented checkpoints so you can *prove* what improved.

### Observability
- Structured events emitted for:
  - “what user did”
  - “what we decided”
  - “how long it took”
  - “what thread/queue it happened on”
- Optional export to external sinks for dashboards and incident-style analysis.

---

## Conventions

Technical alignment with the rest of the workspace (EventDispatch, GCD, CheckpointedResult, Grafana-only observability, seat data sources) is documented in **[CONVENTIONS.md](CONVENTIONS.md)**. Follow it for consistency.

---

## Architecture overview

> This is the mental model: **Domain → ViewModel/State → Renderer → Interaction → Domain**, with instrumentation everywhere.

### High-level flow
1. **Domain** provides seat inventory, pricing, and selection rules.
2. **State** (single source of truth) holds current viewport, zoom, and selected seats.
3. **Renderer** maps state to a minimal set of drawing primitives (or views/layers).
4. **Interaction** updates state through explicit actions (tap, pan, pinch).
5. **Instrumentation** emits events at each step, so you can reconstruct timelines.

### Suggested module boundaries
- `Domain`
  - `Seat`, `SeatId`, `SeatStatus`, `CabinSection`, pricing metadata
  - selection rules and validators
- `State`
  - immutable-ish state model
  - action reducer (or explicit action handlers)
- `Rendering`
  - seat layout computation
  - hit-testing
  - view/layer composition
- `UI`
  - UIKit view controllers and gesture handling
- `Telemetry`
  - event emission, checkpoints, sink configuration

---

## Rendering approach (implementation options)

This app can support multiple renderers so you can compare tradeoffs:

- **CALayer-backed** renderer (recommended baseline)
  - Stable performance, good control, works well on older iOS.
- **UIView** renderer (debug/reference)
  - Easier to read, slower at scale.
- (Optional) **Metal** renderer
  - Not required for v1; only useful if you deliberately want a GPU-heavy demonstration.

The *reference-app goal* is to make the render pipeline measurable and comparable, not to chase “maximum graphics tech”.

---

## Observability model

### Event types (examples)
- `ui.gesture.pan.started / changed / ended`
- `ui.gesture.pinch.started / changed / ended`
- `ui.seat.tap`
- `domain.selection.accepted / rejected`
- `render.layout.started / completed`
- `render.apply.started / completed`
- `perf.frame.hitch` (if you detect hitches)
- `perf.checkpoint` (timed spans around critical paths)

### Minimal event fields (recommended)
- timestamp (monotonic + wall clock)
- thread / queue label
- session id
- screen / component id
- action id (correlate cause → effects)
- payload (small, structured)

### Where events go
- Events are sunk via `EventDispatch.default`; Telme batches them and sends to registered record sinks (e.g. ClickHouse HTTP proxy). Observability is Grafana-based only—no in-app event viewer.

---

## Build & run

### Requirements
- Xcode (any modern version that still supports your minimum iOS target).
- Minimum iOS target: set based on your goals (commonly iOS 12+ for “older device” proof).

### Steps
1. Clone the repo.
2. Open `FlightSeatSelector.xcodeproj` (or `.xcworkspace` if using SPM + dependencies).
3. Select a simulator/device.
4. Build and run.

### Configuration
- Seat map data: mostly JSON files bundled with the app; optionally use open-source or public seating data by manufacturer + model (see [CONVENTIONS.md](CONVENTIONS.md)). Stress testing can use generated layouts at runtime.
- Telemetry: uses the workspace Telme pipeline; sinks (e.g. ClickHouse) are configured at app startup.

---

## Demo script (90 seconds)

If you’re using this for interviews, keep it tight:
1. Open seat map → show smooth pan + pinch.
2. Select seats quickly → show rule rejections clearly.
3. Trigger a “stress case” (dense layout) → show stable performance.
4. Show Grafana dashboard populated from ClickHouse (correlated events, spans, session).

---

## Roadmap (reference-app oriented)

- [ ] Multiple renderers (UIView vs CALayer) behind a toggle
- [ ] Stress test mode (10k+ seats synthetic)
- [ ] Deterministic replay (feed recorded gestures/actions)
- [ ] Snapshot tests for layout primitives
- [ ] Frame pacing instrumentation and hitch detection
- [ ] Export/import event traces for debugging sessions

---

## Contributing

This is a reference app. Changes should preserve:
- readability
- measurability
- a clear narrative for reviewers

If you add a feature, add:
- an event
- a measurable checkpoint
- a short note in the README about what it demonstrates

---

## License

Choose a license that matches your portfolio strategy (MIT/Apache-2.0 are typical). If you haven’t decided yet, leave this as “TBD” and add the license later.
