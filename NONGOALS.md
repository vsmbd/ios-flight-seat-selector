# NONGOALS (FlightSeatSelector)

This repo is a reference app. The goal is to demonstrate engineering judgment and measurability, not to ship a commercial seat-selection product.

---

## 1) Not an airline-grade seat map product

- No requirement to support every real airline configuration or cabin topology.
- No commitment to full accessibility polish across all edge cases.
- No advanced merchandising, offers, loyalty tiers, or payment flows.

---

## 2) Not a pixel-perfect design showcase

- UI polish is “good enough to review,” not a design system.
- No extensive animation library or “marketing-grade” transitions by default.
- Avoid spending weeks on visual perfection that does not improve the signal.

---

## 3) Not an exhaustive framework demo

Even if the broader ecosystem exists, this app should not become a dumping ground.
- Do not integrate every platform abstraction “because it exists”.
- Prefer a small set of high-impact integrations:
  - telemetry
  - concurrency discipline
  - rendering boundary

---

## 4) Not a benchmarking contest without context

- The point is not “Metal beats CALayer”.
- The point is:
  - define constraints
  - measure honestly
  - explain tradeoffs
If Metal is added, it must be for a clear demonstration goal, not vanity.

---

## 5) Not a complex backend project

- The app may export events to external systems, but:
  - it does not own backend reliability
  - it does not implement a full ingestion platform
- Any proxy/sink should be minimal, documented, and optional.

---

## 6) Not maximum feature breadth

Avoid scope creep:
- seat assignment for multi-leg itineraries
- seat holds across sessions
- full offline caching strategy
- multi-language localization
These can be future expansions, but they are not required to meet the reference-app goals.
