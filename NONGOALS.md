# NONGOALS (FlightSeatSelector)

This repo is a focused reference app. It is intentionally not trying to be a production airline booking product.

## 1) Not a full airline seat commerce experience

- No requirement to support every real airline configuration or cabin topology.
- No pricing, upsell, checkout, loyalty, or ancillary purchase flows.
- No seat reservation lifecycle (holds, ticketing, backend confirmation).

## 2) Not multi-aircraft catalog completeness

- No requirement to support all aircraft families or cabin variants.
- Current support for one aircraft model is acceptable unless scope is intentionally expanded.
- No requirement for dynamic aircraft data ingestion in this phase.

## 3) Not a new rendering-tech showcase

- No requirement to add SwiftUI/Metal just to increase technology surface area.
- No renderer bake-off in this repository unless there is a concrete evaluation goal.
- Keep implementation readable over framework novelty.

## 4) Not a full observability platform

- No in-app dashboard, timeline, or debug console.
- No ownership of ingestion pipeline reliability from this app.
- No attempt to define ecosystem-wide telemetry schemas from here.

## 5) Not broad product hardening

- No commitment yet to exhaustive accessibility, localization, and offline support.
- No persistence requirements for seat selection across launches.
- No test matrix targeting all iOS/device permutations at this stage.
