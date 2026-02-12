# Architecture - Decomposed Rendering System

## Overview

The rendering system is decomposed into specialized layers, each knowing only what it needs to operate. Shared context is passed via `RenderingContext` struct.

## Component Hierarchy

```
AircraftCabinView (Coordinator)
├── Data Models
│   └── CabinLayout (seats, amenities, fuselage geometry)
├── Shared Resources
│   ├── ProgressAnimator (single shared instance)
│   └── SpatialIndex (for hit testing)
├── Transform State
│   ├── currentScale
│   └── currentTranslation
└── Sublayers (each handles own rendering)
    ├── FuselageLayer (knows: fuselage geometry, bounds)
    └── SeatLayer[] (each knows: own seat data only)
```

## Key Components

### 1. `RenderingContext.swift` - Shared Context

**Purpose:** Minimal shared state for coordinate transformation

**Contains:**
- `CabinBounds` - Physical dimensions
- `viewSize` - Current view size
- `scale` - Zoom level
- `translation` - Pan offset

**Methods:**
- `toViewCoordinates()` - Transform cabin → screen
- `toCabinCoordinates()` - Transform screen → cabin
- `makeTransform()` - Create CGAffineTransform for path rendering

**Key Principle:** Only coordinate/transform info, no business logic

---

### 2. `AircraftCabinView.swift` - Coordinator

**Role:** Lightweight skeleton that coordinates sublayers

**Responsibilities:**
- ✅ Hold data models (CabinLayout)
- ✅ Manage shared ProgressAnimator
- ✅ Track transform state (scale, translation)
- ✅ Handle gestures (tap, pan, pinch)
- ✅ Create RenderingContext
- ✅ Pass context to sublayers
- ❌ Does NOT render anything directly

**Key Method:**
```swift
private func updateRendering() {
    // Create context with current state
    let context = RenderingContext(
        bounds: layout.bounds,
        viewSize: bounds.size,
        scale: currentScale,
        translation: currentTranslation
    )
    
    // Pass to sublayers - they handle their own rendering
    fuselageLayer.updatePath(context: context)
    seatLayer.updatePosition(context: context)
}
```

---

### 3. `FuselageLayer.swift` - Fuselage Rendering

**Role:** Dedicated layer for aircraft outline

**Knows:**
- `FuselageGeometry` - Shape data (width, length, nose/tail)
- `CabinBounds` - Physical dimensions

**Does NOT Know:**
- Seats
- Amenities
- View size
- Transform state (receives via context)

**Key Method:**
```swift
func updatePath(context: RenderingContext) {
    // Generate path in cabin coordinates
    let cabinPath = geometry.path(bounds: cabinBounds)
    
    // Transform using context
    let transform = context.makeTransform(
        fuselageWidth: geometry.width,
        fuselageLength: geometry.length
    )
    
    // Apply and render
    path = transformedPath
}
```

---

### 4. `SeatLayer.swift` - Seat Rendering

**Role:** Render single seat

**Knows:**
- `CabinLayout.SeatDefinition` - Own seat data (row, column, status)
- Own geometry (width, depth, position)

**Does NOT Know:**
- Other seats
- Fuselage
- View size
- Transform state (receives via context)

**Key Methods:**
```swift
func updatePosition(context: RenderingContext) {
    // Transform own position
    let viewPoint = context.toViewCoordinates(seat.geometry.center)
    position = viewPoint
    
    // Scale properties based on zoom
    lineWidth = max(0.5, min(2.0, 1.0 / context.scale))
    labelLayer.fontSize = 14 * context.scale
}

func updateSeat(_ newSeat: CabinLayout.SeatDefinition) {
    // Update own data
    seat = newSeat
    updateAppearance(animated: false)
}
```

---

## Information Flow

### On Layout Change (zoom, pan, resize)

```
User Gesture
    ↓
AircraftCabinView.handlePinch/handlePan
    ↓
Update: currentScale / currentTranslation
    ↓
setNeedsLayout()
    ↓
layoutSubviews()
    ↓
updateRendering()
    ↓
Create RenderingContext (bounds, viewSize, scale, translation)
    ↓
┌─────────────────────┬─────────────────────┐
↓                     ↓                     ↓
fuselageLayer         seatLayer[0]          seatLayer[N]
.updatePath(context)  .updatePosition()     .updatePosition()
```

### On Data Change (seat selection)

```
User Tap
    ↓
AircraftCabinView.handleTap
    ↓
Find seat via SpatialIndex
    ↓
Update: selectedSeatId
    ↓
seatLayer.updateSeat(newSeatData)
    ↓
SeatLayer updates own appearance
```

---

## Design Principles

### 1. Separation of Concerns

**Each layer knows only what it needs:**
- `FuselageLayer` - fuselage geometry only
- `SeatLayer` - own seat data only
- `AircraftCabinView` - coordinates, doesn't render

### 2. Context Passing (not Dependency Injection)

**Layers don't store references to coordinator:**
```swift
// ❌ BAD: Layer holds reference to coordinator
class SeatLayer {
    weak var coordinator: AircraftCabinView?
    func update() {
        let pos = coordinator?.toViewCoords(...)
    }
}

// ✅ GOOD: Layer receives context when needed
class SeatLayer {
    func updatePosition(context: RenderingContext) {
        let pos = context.toViewCoordinates(...)
    }
}
```

### 3. Shared Resources at Top Level

**Single instances managed by coordinator:**
- `ProgressAnimator` - one for all animations
- `SpatialIndex` - one for all hit testing
- `CabinLayout` - single source of truth

### 4. Layers Handle Own Rendering

**Coordinator doesn't draw:**
```swift
// ❌ BAD: Coordinator renders everything
func updateRendering() {
    drawFuselage(context)
    for seat in seats { drawSeat(seat, context) }
}

// ✅ GOOD: Layers render themselves
func updateRendering() {
    let context = makeContext()
    fuselageLayer.updatePath(context: context)
    seatLayer.updatePosition(context: context)
}
```

---

## Benefits

### 1. Testability
```swift
// Test FuselageLayer in isolation
func testFuselageRendering() {
    let geometry = FuselageGeometry.a320
    let layer = FuselageLayer(geometry: geometry, bounds: .a320)
    let context = RenderingContext(...)
    layer.updatePath(context: context)
    // Assert path properties
}
```

### 2. Maintainability
- Change fuselage rendering → only touch `FuselageLayer.swift`
- Change seat rendering → only touch `SeatLayer.swift`
- Change coordinate system → only touch `RenderingContext.swift`

### 3. Performance
- Layers can optimize own rendering
- No unnecessary coupling
- Clear update boundaries

### 4. Extensibility
```swift
// Add new layer type (e.g., AmenityLayer)
class AmenityLayer: CAShapeLayer {
    func updatePosition(context: RenderingContext) {
        // Knows only about own amenity
    }
}

// Coordinator adds it
amenityLayer.updatePosition(context: context)
```

---

## File Structure

```
Rendering/
├── RenderingContext.swift       (Shared context)
├── AircraftCabinView.swift      (Coordinator)
├── FuselageLayer.swift          (Fuselage rendering)
├── SeatLayer.swift              (Seat rendering)
├── CabinGeometry.swift          (Coordinate system)
├── CabinLayout.swift            (Data models)
└── ColorCompatibility.swift     (iOS 12+ colors)
```

---

## Key Takeaways

1. **Coordinator pattern:** `AircraftCabinView` orchestrates, doesn't render
2. **Context passing:** Shared state via `RenderingContext`, not stored references
3. **Minimal knowledge:** Each layer knows only its domain
4. **Single responsibility:** Each component has one clear purpose
5. **Testable:** Components can be tested in isolation

**Result:** Clean, maintainable, testable rendering architecture.
