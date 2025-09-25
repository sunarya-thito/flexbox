# FlexibleBox

[![pub package](https://img.shields.io/pub/v/flexiblebox.svg)](https://pub.dev/packages/flexiblebox)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package that brings CSS Flexbox layout capabilities to your Flutter
applications. Create responsive, flexible layouts with ease using familiar
flexbox concepts.

## Features

- Complete Flexbox Implementation: Full CSS flexbox specification support
- Responsive Design: Automatic layout adaptation to different screen sizes
- Flexible Sizing: Support for flex grow, shrink, and basis properties
- Advanced Alignment: Cross-axis and main-axis alignment options
- Wrapping Support: Multi-line flex layouts with wrap and wrap-reverse
- RTL Support: Right-to-left language support
- Absolute Positioning: Position items absolutely within flex containers
- Scrolling: Built-in scrollable flex containers
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

### Convenience Widgets

#### RowBox

Horizontal flex layout (equivalent to `FlexBox(direction: FlexDirection.row)`):

```dart
RowBox(
  alignItems: BoxAlignmentGeometry.center,
  justifyContent: BoxAlignmentBase.spaceBetween,
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
  columnGap: SpacingUnit.fixed(12.0),
  children: [
    FlexItem(child: Text('Top')),
    FlexItem(child: Text('Middle')),
    FlexItem(child: Text('Bottom')),
  ],
)
```

## Advanced Examples

### Responsive Card Layout

```dart
FlexBox(
  direction: FlexDirection.row,
  wrap: FlexWrap.wrap,
  alignItems: BoxAlignmentGeometry.start,
  rowGap: SpacingUnit.fixed(16.0),
  columnGap: SpacingUnit.fixed(16.0),
  children: [
    FlexItem(
      flexGrow: 1.0,
      minWidth: SizeUnit.fixed(280.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card Title', style: Theme.of(context).textTheme.headline6),
              SizedBox(height: 8.0),
              Text('Card content goes here...'),
            ],
          ),
        ),
      ),
    ),
    // More cards...
  ],
)
```

### Holy Grail Layout

```dart
ColumnBox(
  children: [
    FlexItem(
      height: SizeUnit.fixed(64.0),
      child: AppBar(title: Text('Header')),
    ),
    FlexItem(
      flexGrow: 1.0,
      child: FlexBox(
        direction: FlexDirection.row,
        children: [
          FlexItem(
            width: SizeUnit.fixed(200.0),
            child: Sidebar(),
          ),
          FlexItem(
            flexGrow: 1.0,
            child: MainContent(),
          ),
          FlexItem(
            width: SizeUnit.fixed(200.0),
            child: RightPanel(),
          ),
        ],
      ),
    ),
    FlexItem(
      height: SizeUnit.fixed(64.0),
      child: Footer(),
    ),
  ],
)
```

### Scrollable Content

```dart
ScrollableFlexBox(
  direction: FlexDirection.column,
  verticalController: ScrollController(),
  children: List.generate(
    50,
    (index) => FlexItem(
      height: SizeUnit.fixed(60.0),
      child: ListTile(title: Text('Item $index')),
    ),
  ),
)
```

### Absolute Positioning

```dart
FlexBox(
  direction: FlexDirection.row,
  children: [
    FlexItem(
      flexGrow: 1.0,
      child: Container(color: Colors.grey),
    ),
    AbsoluteItem(
      top: PositionUnit.fixed(20.0),
      right: PositionUnit.fixed(20.0),
      width: SizeUnit.fixed(100.0),
      height: SizeUnit.fixed(100.0),
      paintOrder: 1,
      child: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    ),
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

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

---

Made with ❤️ for the Flutter community</content>
