# FlightSeatSelector

`FlightSeatSelector` is a UIKit reference app for rendering and interacting with an aircraft seat map using a CALayer-heavy drawing pipeline.

The current implementation is intentionally focused and narrow: one supported aircraft (`Airbus A320`), single-seat selection, pan/zoom navigation, and optional telemetry sink setup at app launch.

## Current scope

- iOS app with `AppDelegate` + `SceneDelegate` startup flow.
- Root screen lists supported aircraft from `Aircraft.supported`.
- Cabin screen renders one aircraft layout with custom layers.
- Tap selection supports a single selected seat at a time.
- Pinch-to-zoom and scroll/pan are handled by `UIScrollView`.
- App startup can configure a Telme record sink to an HTTP endpoint.

## Project structure

- `FlightSeatSelector/FlightSeatSelector/Domain`
  - aircraft model, geometry, cabin layout, and seat identifier types
- `FlightSeatSelector/FlightSeatSelector/UI`
  - view controllers and rendering layers for cabin layout
- `FlightSeatSelector/FlightSeatSelector/AppDelegate.swift`
  - app bootstrap and telemetry sink registration

## Interaction behavior

- From the aircraft list, selecting a row pushes the cabin screen.
- Seat taps are hit-tested in `AircraftLayoutLayer`.
- Selecting a seat marks it as selected and clears the previous selection.
- Taps outside seat bounds are ignored.
- Zoom range is clamped (`0.5 ... 10.0`).

## Telemetry behavior (as implemented)

- The app initializes Telme and may register a `ClickHouseTelmeSink` when the configured endpoint URL is valid.
- Session/device baseline metadata is attached during sink configuration.
- UI interactions are wrapped with checkpointed/measured helpers where used by the view hierarchy.
- There is no in-app observability dashboard.

## Build and run

1. Open `FlightSeatSelector/FlightSeatSelector.xcodeproj` in Xcode.
2. Select a simulator or device.
3. Build and run.
4. On launch, choose an aircraft and interact with the seat map.

## Known limitations

- Supported aircraft catalog currently contains only `A320`.
- Seat states are presentation-focused (`available` vs `selected`) and do not include booking/business rules.
- No persistence of selected seat across app relaunch.
- Telemetry endpoint is hardcoded in app bootstrap and intended for development/testing.

## Related docs

- Goals: `GOALS.md`
- Non-goals: `NONGOALS.md`
