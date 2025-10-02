# FlexibleBox

[![pub package](https://img.shields.io/pub/v/flexiblebox.svg)](https://pub.dev/packages/flexiblebox)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD--3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://img.shields.io/github/actions/workflow/status/sunarya-thito/flexbox/test.yml?branch=master)](https://github.com/sunarya-thito/flexbox/actions)

A Flutter package that brings CSS Flexbox layout capabilities to your Flutter
applications. Create responsive, flexible layouts with ease using familiar
flexbox concepts.

## Features

- Complete Flexbox Implementation: Full CSS flexbox specification support
- Flexible Sizing: Support for flex grow, shrink, and basis properties
- Advanced Alignment: Cross-axis and main-axis alignment options
- Wrapping Support: Multi-line flex layouts with wrap and wrap-reverse
- RTL Support: Right-to-left language support
- Absolute Positioning: Position items absolutely within flex containers
- Scrolling: Built-in scrollable flex containers
- Sticky Positioning: Sticky items within flex layouts
- Convenience Widgets: RowBox and ColumnBox for common use cases
- Custom Spacing: Flexible spacing and padding systems

## Installation

Add the package using Flutter CLI:

```bash
flutter pub add flexiblebox
```

## Demo

View the interactive demo:
[https://sunarya-thito.github.io/flexbox](https://sunarya-thito.github.io/flexbox)

## Quick Start

Import the package:

```dart
import 'package:flexiblebox/flexiblebox_flutter.dart';
```

Create a simple flex layout:

```dart
FlexBox(
  direction: FlexDirection.row,
  children: [
    FlexItem(
      flexGrow: 1.0,
      child: Container(
        color: Colors.red,
        child: Center(child: Text('Flexible Item')),
      ),
    ),
    FlexItem(
      width: SizeUnit.fixed(100.0),
      child: Container(
        color: Colors.blue,
        child: Center(child: Text('Fixed Width')),
      ),
    ),
  ],
)
```

## Core Components

### FlexBox

The main flex container widget that implements the flexbox layout algorithm.

```dart
FlexBox(
  direction: FlexDirection.row,        // Layout direction
  wrap: FlexWrap.wrap,                 // Wrapping behavior
  alignItems: BoxAlignmentGeometry.start,    // Cross-axis alignment
  alignContent: BoxAlignmentContent.start,   // Content alignment (for wrapping)
  justifyContent: BoxAlignmentBase.start, // Main-axis distribution
  rowGap: SpacingUnit.fixed(8.0),      // Horizontal spacing between items
  columnGap: SpacingUnit.fixed(8.0),   // Vertical spacing between items
  children: [...],                     // Flex items
)
```

### FlexItem

Configures individual children within a FlexBox.

```dart
FlexItem(
  flexGrow: 1.0,                       // Growth factor
  flexShrink: 0.0,                     // Shrink factor
  width: SizeUnit.fixed(200.0),         // Preferred width
  height: SizeUnit.fixed(100.0),        // Preferred height
  alignSelf: BoxAlignmentGeometry.start,     // Individual alignment
  child: YourWidget(),
)
```

### AbsoluteItem

For absolutely positioned children within a FlexBox.

```dart
AbsoluteItem(
  left: PositionUnit.fixed(10.0),      // Left offset
  top: PositionUnit.fixed(20.0),       // Top offset
  right: PositionUnit.fixed(10.0),     // Right offset
  bottom: PositionUnit.fixed(20.0),    // Bottom offset
  width: SizeUnit.fixed(100.0),        // Fixed width
  height: SizeUnit.fixed(50.0),        // Fixed height
  child: YourWidget(),
)
```

### Sticky FlexItem

For sticky positioning within scrollable flex containers, use the `top`, `left`,
`bottom`, and `right` properties on FlexItem. These create sticky elements that
remain fixed relative to the viewport during scrolling.

```dart
FlexBox(
  direction: FlexDirection.column,
  // Make the container scrollable
  height: SizeUnit.fixed(300.0), // Fixed height to enable scrolling
  children: [
    FlexItem(
      height: SizeUnit.fixed(100.0),
      child: Container(
        color: Colors.blue,
        child: Center(child: Text('Normal Item')),
      ),
    ),
    // Sticky header that sticks to the top
    FlexItem(
      top: PositionUnit.fixed(0.0),    // Stick to top edge
      left: PositionUnit.fixed(0.0),   // Stick to left edge
      right: PositionUnit.fixed(0.0),  // Stick to right edge
      height: SizeUnit.fixed(50.0),
      child: Container(
        color: Colors.red,
        child: Center(child: Text('Sticky Header')),
      ),
    ),
    FlexItem(
      height: SizeUnit.fixed(200.0),
      child: Container(
        color: Colors.green,
        child: Center(child: Text('Content')),
      ),
    ),
    FlexItem(
      height: SizeUnit.fixed(200.0),
      child: Container(
        color: Colors.yellow,
        child: Center(child: Text('More Content')),
      ),
    ),
  ],
)
```

### Scrollable AbsoluteItem

AbsoluteItem positions elements relative to the viewport bounds, not content
bounds. This means `bottom: PositionUnit.fixed(10.0)` positions the element 10
units from the bottom of the viewport, not the content.

For scroll-aware positioning, use `PositionUnit.scrollOffset` to create elements
that move with scroll:

```dart
FlexBox(
  direction: FlexDirection.column,
  height: SizeUnit.fixed(400.0), // Fixed height to enable scrolling
  verticalOverflow: LayoutOverflow.scroll,
  children: [
    // Regular content
    FlexItem(
      height: SizeUnit.fixed(200.0),
      child: Container(color: Colors.blue, child: Center(child: Text('Content 1'))),
    ),
    FlexItem(
      height: SizeUnit.fixed(200.0),
      child: Container(color: Colors.green, child: Center(child: Text('Content 2'))),
    ),
    FlexItem(
      height: SizeUnit.fixed(200.0),
      child: Container(color: Colors.yellow, child: Center(child: Text('Content 3'))),
    ),
    
    // Absolute positioned element that moves with scroll
    AbsoluteItem(
      right: PositionUnit.fixed(20.0),      // 20px from right viewport edge
      bottom: PositionUnit.fixed(20.0),     // 20px from bottom viewport edge
      width: SizeUnit.fixed(60.0),
      height: SizeUnit.fixed(60.0),
      child: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    ),
    
    // Element that follows scroll position
    AbsoluteItem(
      left: PositionUnit.fixed(10.0),
      top: PositionUnit.scrollOffset + PositionUnit.fixed(10.0), // Moves with scroll
      width: SizeUnit.fixed(40.0),
      height: SizeUnit.fixed(40.0),
      child: Container(
        color: Colors.red,
        child: Center(child: Text('Scroll\nIndicator')),
      ),
    ),
  ],
)
```

### Convenience Widgets

#### RowBox

Horizontal flex layout (equivalent to `FlexBox(direction: FlexDirection.row)`):

```dart
RowBox(
  alignItems: BoxAlignmentGeometry.center,
  justifyContent: BoxAlignmentBase.spaceBetween,
  children: [
    Text('Left'),
    Text('Center'),
    Text('Right'),
  ],
)
```

#### ColumnBox

Vertical flex layout (equivalent to `FlexBox(direction: FlexDirection.column)`):

```dart
ColumnBox(
  alignItems: BoxAlignmentGeometry.stretch,
  justifyContent: BoxAlignmentBase.start,
  columnGap: SpacingUnit.fixed(12.0),
  children: [
    Text('Top'),
    Text('Middle'),
    Text('Bottom'),
  ],
)
```

## Layout Properties

### Direction

- `FlexDirection.row`: Left to right (default)
- `FlexDirection.rowReverse`: Right to left
- `FlexDirection.column`: Top to bottom
- `FlexDirection.columnReverse`: Bottom to top

### Wrapping

- `FlexWrap.none`: No wrapping (default)
- `FlexWrap.wrap`: Wrap to next line
- `FlexWrap.wrapReverse`: Wrap to previous line

### Alignment

#### Main Axis (justifyContent)

- `BoxAlignmentBase.start`: Items at the start
- `BoxAlignmentBase.center`: Items centered
- `BoxAlignmentBase.end`: Items at the end
- `BoxAlignmentBase.spaceBetween`: Space between items
- `BoxAlignmentBase.spaceAround`: Space around items
- `BoxAlignmentBase.spaceEvenly`: Equal space distribution

#### Cross Axis (alignItems)

- `BoxAlignmentGeometry.start`: Items at cross start
- `BoxAlignmentGeometry.center`: Items centered
- `BoxAlignmentGeometry.end`: Items at cross end
- `BoxAlignmentGeometry.stretch`: Items stretch to fill
- `BoxAlignmentGeometry.baseline`: Items aligned by baseline

#### Content Alignment (alignContent)

- `BoxAlignmentContent.start`: Lines at container start
- `BoxAlignmentContent.center`: Lines centered in container
- `BoxAlignmentContent.end`: Lines at container end
- `BoxAlignmentContent.stretch`: Lines stretch to fill container
- `BoxAlignmentContent.spaceBetween`: Space between lines
- `BoxAlignmentContent.spaceAround`: Space around lines
- `BoxAlignmentContent.spaceEvenly`: Equal space distribution

### Sizing Units

#### SizeUnit

- `SizeUnit.fixed(double)`: Fixed size
- `SizeUnit.minContent`: Minimum content size
- `SizeUnit.maxContent`: Maximum content size
- `SizeUnit.fitContent`: Fit content size
- `SizeUnit.viewportSize`: Viewport size

#### PositionUnit

- `PositionUnit.fixed(double)`: Fixed position
- `PositionUnit.zero`: Zero position (equivalent to fixed(0.0))
- `PositionUnit.viewportSize`: Full viewport size along the axis
- `PositionUnit.contentSize`: Total content size along the axis
- `PositionUnit.childSize`: Size of the positioned child element
- `PositionUnit.boxOffset`: Offset from the box's natural position
- `PositionUnit.scrollOffset`: Current scroll offset
- `PositionUnit.contentOverflow`: Amount content overflows the viewport
- `PositionUnit.contentUnderflow`: Amount content underflows the viewport
- `PositionUnit.viewportStartBound`: Start boundary of the viewport
- `PositionUnit.viewportEndBound`: End boundary of the viewport
- `PositionUnit.cross(PositionUnit)`: Convert passed PositionUnit to cross axis
- `PositionUnit.constrained({required PositionUnit position, PositionUnit min, PositionUnit max})`:
  Position constrained within min/max bounds

#### SpacingUnit

- `SpacingUnit.fixed(double)`: Fixed spacing
- `SpacingUnit.viewportSize`: Viewport-based spacing

### Math Operations

All unit types (`SizeUnit`, `SpacingUnit`, `PositionUnit`) support mathematical
operations:

```dart
// Basic arithmetic
SizeUnit combinedWidth = SizeUnit.fixed(100.0) + SizeUnit.fixed(50.0);
PositionUnit offset = PositionUnit.fixed(200.0) - PositionUnit.fixed(50.0);
SpacingUnit scaled = SpacingUnit.fixed(10.0) * SpacingUnit.fixed(2.0);

// Complex expressions (equivalent to CSS calc())
SizeUnit halfViewport = SizeUnit.viewportSize * 0.5; // 50% of viewport size
SizeUnit responsiveSize = SizeUnit.fixed(100.0) + SizeUnit.viewportSize * 0.2; // 100px + 20% viewport
PositionUnit centered = PositionUnit.viewportSize * 0.5 - PositionUnit.childSize * 0.5; // Center child

// Negation
SizeUnit negative = -SizeUnit.fixed(100.0);

// Constraints
PositionUnit clamped = PositionUnit.fixed(150.0).clamp(
  min: PositionUnit.fixed(0.0),
  max: PositionUnit.fixed(300.0),
);
```

## API Reference

For detailed API documentation, visit the
[API Reference](https://pub.dev/documentation/flexiblebox/latest/).

Key classes:

- [FlexBox](https://pub.dev/documentation/flexiblebox/latest/flexiblebox_flutter/FlexBox-class.html)
- [FlexItem](https://pub.dev/documentation/flexiblebox/latest/flexiblebox_flutter/FlexItem-class.html)
- [RowBox](https://pub.dev/documentation/flexiblebox/latest/flexiblebox_flutter/RowBox-class.html)
- [ColumnBox](https://pub.dev/documentation/flexiblebox/latest/flexiblebox_flutter/ColumnBox-class.html)
- [AbsoluteItem](https://pub.dev/documentation/flexiblebox/latest/flexiblebox_flutter/AbsoluteItem-class.html)

## Testing

The package includes comprehensive test coverage. Run tests with:

```bash
flutter test
```

View the interactive demo:

```bash
cd demo
flutter run
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md)
for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the BSD-3-Clause license - see the
[LICENSE](LICENSE) file for details.

---

Made with ❤️ for the Flutter community
