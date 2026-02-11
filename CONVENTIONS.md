# CONVENTIONS (FlightSeatSelector)

Technical decisions that align this reference app with the rest of the workspace. Follow these so the codebase stays consistent and reviewable.

---

## 1) Observability: ecosystem-aligned

- **Event system**: Use `EventDispatch.default` and the `Event` protocol. Do not introduce a separate event or logging pipeline.
- **Event types**: Do not introduce new event *kinds* or schemas outside the ecosystem. App-specific events (e.g. seat map gestures, selection) must:
  - Conform to `Event` (Encodable, Sendable, `kind: String`).
  - Use enum-based naming with associated `MonotonicNanostamp` and `Checkpoint` (or `EventInfo`) as in `HTTPProcessingEvent`, `MeasuredBlockEvent`, etc.
  - Be sunk via `EventDispatch.default.sink(_:checkpoint:extra:)` with a valid `Checkpoint`.
- **Viewer**: No in-app debug views or event timeline UI. Observability is purely Grafana-based (events flow to ClickHouse via the existing Telme/ingestion pipeline).

---

## 2) Concurrency and error handling

- **Concurrency**: Use GCD only. No Swift concurrency (async/await, actors, Task).
- **Errors**: No `throws` or `rethrows`. Use `CheckpointedResult<Success, Failure>` (or a typealias) for operations that can fail. Failure carries `ErrorInfo` (entity, checkpoint, timestamp) for correlation.

---

## 3) Seat map data

- **Primary**: JSON files bundled with the app (e.g. cabin layout, seat inventory, rules).
- **Additional**: Prefer open-source or public seating data by manufacturer + model where useful (e.g. [stoshipdb seatdata.json](https://github.com/wkrick/stoshipdb/blob/afaa76b39de52762104eff5712313fa6b568eede/src/assets/seatdata.json), [AeroLOPA](https://aerolopa.com/) for reference). No commitment to a single external schema; normalize to the app’s domain model.

---

## Summary table

| Area           | Decision                                              |
|----------------|--------------------------------------------------------|
| Event dispatch | `EventDispatch.default` + `Event` protocol             |
| Event shape    | Enum cases + `MonotonicNanostamp`; conform to `Event` |
| Observability  | Grafana only; no in-app event viewer                  |
| Concurrency    | GCD only; no Swift concurrency                        |
| Errors         | `CheckpointedResult`; no throws/rethrows              |
| Seat data      | Bundled JSON + optional open-source by aircraft type |
