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
import 'package:flexiblebox/flexiblebox_extensions.dart'; // For convenient extension methods
```

Create a simple flex layout:

```dart
FlexBox(
  direction: FlexDirection.row,
  rowGap: 8.0.spacing,
  children: [
    FlexItem(
      flexGrow: 1.0,
      child: Container(
        color: Colors.red,
        height: 100,
        child: Center(child: Text('Flexible Item')),
      ),
    ),
    FlexItem(
      width: 100.0.size,
      child: Container(
        color: Colors.blue,
        height: 100,
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
  direction: FlexDirection.row,               // Layout direction
  wrap: FlexWrap.wrap,                        // Wrapping behavior
  alignItems: BoxAlignmentGeometry.start,     // Cross-axis alignment
  alignContent: BoxAlignmentContent.start,    // Content alignment (for wrapping)
  justifyContent: BoxAlignmentBase.start,     // Main-axis distribution
  rowGap: 8.0.spacing,                        // Spacing between items horizontally
  columnGap: 8.0.spacing,                     // Spacing between items vertically
  children: [                                 // Flex items
    FlexItem(child: Text('Item 1')),
    FlexItem(child: Text('Item 2')),
  ],
)
```

### FlexItem

Configures individual children within a FlexBox.

```dart
FlexItem(
  flexGrow: 1.0,                              // Growth factor
  flexShrink: 0.0,                            // Shrink factor
  width: 200.0.size,                          // Preferred width
  height: 100.0.size,                         // Preferred height
  alignSelf: BoxAlignmentGeometry.start,      // Individual alignment
  child: Container(
    color: Colors.blue,
    child: Center(child: Text('Flex Item')),
  ),
)
```

### AbsoluteItem

For absolutely positioned children within a FlexBox.

```dart
AbsoluteItem(
  left: 10.0.position,                         // Left offset from viewport edge
  top: 20.0.position,                          // Top offset from viewport edge
  right: 10.0.position,                        // Right offset from viewport edge
  bottom: 20.0.position,                       // Bottom offset from viewport edge
  width: 100.0.size,                           // Fixed width
  height: 50.0.size,                           // Fixed height
  child: Container(
    color: Colors.green,
    child: Center(child: Text('Absolute')),
  ),
)
```

### Sticky FlexItem

For sticky positioning within scrollable flex containers, use the `top`, `left`,
`bottom`, and `right` properties on FlexItem. These create sticky elements that
remain fixed relative to the viewport during scrolling. You must also set
`verticalOverflow` or `horizontalOverflow` to `LayoutOverflow.hidden` or
`LayoutOverflow.scroll` on the FlexBox.

```dart
// Wrap FlexBox in a SizedBox to constrain its size and enable scrolling
SizedBox(
  height: 300.0, // Fixed height to enable scrolling
  child: FlexBox(
    direction: FlexDirection.column,
    children: [
      FlexItem(
        height: 100.0.size,
        child: Container(
          color: Colors.blue,
          child: Center(child: Text('Normal Item')),
        ),
      ),
      // Sticky header that sticks to the top
      FlexItem(
        top: 0.0.position,    // Stick to top edge
        left: 0.0.position,   // Stick to left edge
        right: 0.0.position,  // Stick to right edge
        height: 50.0.size,
        child: Container(
          color: Colors.red,
          child: Center(child: Text('Sticky Header')),
        ),
      ),
      FlexItem(
        height: 200.0.size,
        child: Container(
          color: Colors.green,
          child: Center(child: Text('Content')),
        ),
      ),
      FlexItem(
        height: 200.0.size,
        child: Container(
          color: Colors.yellow,
          child: Center(child: Text('More Content')),
        ),
      ),
    ],
  ),
)
```

### Scrollable AbsoluteItem

AbsoluteItem positions elements relative to the viewport bounds, not content
bounds. This means `bottom: PositionUnit.fixed(10.0)` positions the element 10
units from the bottom of the viewport, not the content.

For scroll-aware positioning, use `PositionUnit.scrollOffset` to create elements
that move with scroll:

```dart
// Wrap FlexBox in a SizedBox to make it scrollable
SizedBox(
  height: 400.0, // Fixed height to enable scrolling
  child: FlexBox(
    direction: FlexDirection.column,
    children: [
      // Regular content
      FlexItem(
        height: 200.0.size,
        child: Container(
          color: Colors.blue,
          child: Center(child: Text('Content 1')),
        ),
      ),
      FlexItem(
        height: 200.0.size,
        child: Container(
          color: Colors.green,
          child: Center(child: Text('Content 2')),
        ),
      ),
      FlexItem(
        height: 200.0.size,
        child: Container(
          color: Colors.yellow,
          child: Center(child: Text('Content 3')),
        ),
      ),
      
      // Absolute positioned element that stays fixed in viewport
      AbsoluteItem(
        right: 20.0.position,                 // 20px from right viewport edge
        bottom: 20.0.position,                // 20px from bottom viewport edge
        width: 60.0.size,
        height: 60.0.size,
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
      
      // Element that follows scroll position
      AbsoluteItem(
        left: 10.0.position,
        top: PositionUnit.scrollOffset + 10.0.position, // Moves with scroll
        width: 40.0.size,
        height: 40.0.size,
        child: Container(
          color: Colors.red,
          child: Center(child: Text('Scroll\nIndicator')),
        ),
      ),
    ],
  ),
)
```

### Scrollbars

The `Scrollbars` widget provides scrollbar UI for scrollable FlexBox containers.
It automatically shows/hides scrollbars based on content overflow and supports
both vertical and horizontal scrolling.

#### Basic Usage

```dart
SizedBox(
  width: 400,
  height: 300,
  child: Scrollbars(
    child: FlexBox(
      direction: FlexDirection.column,
      children: [
        for (int i = 0; i < 20; i++)
          FlexItem(
            height: 80.size,
            child: Container(
              margin: EdgeInsets.all(8),
              color: Colors.primaries[i % Colors.primaries.length],
              child: Center(child: Text('Item $i')),
            ),
          ),
      ],
    ),
  ),
)
```

#### Customizing Scrollbar Appearance

You can customize the scrollbar appearance using `DefaultScrollbar`:

```dart
Scrollbars(
  verticalScrollbar: DefaultScrollbar(
    thumbDecoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.5),
      borderRadius: BorderRadius.circular(4),
    ),
    thumbActiveDecoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(4),
    ),
    minThumbLength: 48.0,
    margin: EdgeInsets.all(2),
  ),
  horizontalScrollbar: DefaultScrollbar(
    thumbDecoration: BoxDecoration(
      color: Colors.green.withOpacity(0.5),
      borderRadius: BorderRadius.circular(4),
    ),
  ),
  verticalScrollbarThickness: 12,
  horizontalScrollbarThickness: 12,
  child: FlexBox(
    children: [
      // Your content here
    ],
  ),
)
```

### Convenience Widgets

#### RowBox

Horizontal flex layout (equivalent to `FlexBox(direction: FlexDirection.row)`):

```dart
RowBox(
  alignItems: BoxAlignmentGeometry.center,
  justifyContent: BoxAlignmentBase.spaceBetween,
  rowGap: 8.0.spacing,
  children: [
    FlexItem(child: Text('Left')),
    FlexItem(child: Text('Center')),
    FlexItem(child: Text('Right')),
  ],
)
```

#### ColumnBox

Vertical flex layout (equivalent to `FlexBox(direction: FlexDirection.column)`):

```dart
ColumnBox(
  alignItems: BoxAlignmentGeometry.stretch,
  justifyContent: BoxAlignmentBase.start,
  columnGap: 12.0.spacing,
  children: [
    FlexItem(child: Text('Top')),
    FlexItem(child: Text('Middle')),
    FlexItem(child: Text('Bottom')),
  ],
)
```

## Extension Methods

The package provides convenient extension methods on `int` and `double` for
creating units:

```dart
import 'package:flexiblebox/flexiblebox_extensions.dart';

// Size units
100.size              // SizeUnit.fixed(100.0)
50.0.size             // SizeUnit.fixed(50.0)
0.5.relativeSize      // SizeUnit.viewportSize * 0.5 (50% of viewport)

// Position units
10.position           // PositionUnit.fixed(10.0)
20.0.position         // PositionUnit.fixed(20.0)
0.25.relativePosition // PositionUnit.viewportSize * 0.25 (25% of viewport)

// Spacing units
8.spacing             // SpacingUnit.fixed(8.0)
16.0.spacing          // SpacingUnit.fixed(16.0)
0.1.relativeSpacing   // SpacingUnit.viewportSize * 0.1 (10% of viewport)

// Percentage helper
50.percent            // 0.5 (useful for calculations)
```

These extensions make the code more concise and readable:

```dart
// Without extensions
FlexItem(
  width: SizeUnit.fixed(100.0),
  height: SizeUnit.fixed(50.0),
  child: MyWidget(),
)

// With extensions
FlexItem(
  width: 100.size,
  height: 50.size,
  child: MyWidget(),
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

- `100.size` or `SizeUnit.fixed(double)`: Fixed size
- `100.0.relativeSize` or `SizeUnit.viewportSize * 100.0.size`:
  Viewport-relative size
- `SizeUnit.minContent`: Minimum content size
- `SizeUnit.maxContent`: Maximum content size
- `SizeUnit.fitContent`: Fit content size
- `SizeUnit.viewportSize`: Viewport size

#### PositionUnit

- `10.position` or `PositionUnit.fixed(double)`: Fixed position
- `10.0.relativePosition` or `PositionUnit.viewportSize * 10.0.position`:
  Viewport-relative position
- `PositionUnit.zero`: Zero position (equivalent to `0.position`)
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

- `8.spacing` or `SpacingUnit.fixed(double)`: Fixed spacing
- `8.0.relativeSpacing` or `SpacingUnit.viewportSize * 8.0.spacing`:
  Viewport-based spacing
- `SpacingUnit.viewportSize`: Viewport-based spacing

### Math Operations

All unit types (`SizeUnit`, `SpacingUnit`, `PositionUnit`) support mathematical
operations:

```dart
// Basic arithmetic
SizeUnit combinedWidth = 100.size + 50.size;
PositionUnit offset = 200.position - 50.position;
SpacingUnit scaled = 10.spacing * 2.0; // Multiply by scalar

// Complex expressions (equivalent to CSS calc())
SizeUnit halfViewport = SizeUnit.viewportSize * 0.5; // 50% of viewport size
SizeUnit responsiveSize = 100.size + SizeUnit.viewportSize * 0.2; // 100px + 20% viewport
PositionUnit centered = PositionUnit.viewportSize * 0.5 - PositionUnit.childSize * 0.5; // Center child

// Negation
SizeUnit negative = -100.size;

// Constraints
PositionUnit clamped = 150.position.clamp(
  min: 0.position,
  max: 300.position,
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
