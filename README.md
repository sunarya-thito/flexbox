# 📦 FlexibleBox for Flutter

[![pub package](https://img.shields.io/pub/v/flexbox.svg)](https://pub.dev/packages/flexbox)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)

**Build stunning, flexible layouts with ease!**

FlexibleBox brings advanced 2D layout capabilities to Flutter with intuitive
APIs for per-child sizing, positioning, sticky elements, bidirectional
scrolling, and smooth morphing transitions.

---

## ✨ Features

🎯 **Flexible 2D Layouts** - Create horizontal or vertical flows with precise
spacing and alignment\
📏 **Per-Child Control** - Absolute, relative, and flex-based sizing for each
child widget\
📌 **Sticky Positioning** - Keep elements visible with scroll-aware anchoring\
🔄 **Bidirectional Scrolling** - Smooth scrolling in both directions\
🎨 **Z-Order Control** - Layer widgets with custom stacking order\
🌊 **Morph Animations** - Seamless transitions between widget states

## 📋 Table of Contents

- [🚀 Quick Start](#-quick-start)
- [📦 Installation](#-installation)
- [🔧 Requirements](#-requirements)
- [📚 Examples](#-examples)
- [📖 API Reference](#-api-reference)
- [🎯 Advanced Usage](#-advanced-usage)
- [📜 License](#-license)

## 📦 Installation

Add FlexBox to your `pubspec.yaml`:

```yaml
dependencies:
    flexbox: ^0.0.1
```

Then import it in your Dart files:

```dart
import 'package:flexbox/flexbox.dart';
```

## 🔧 Requirements

- **Dart** `>= 3.9.0`
- **Flutter** `>= 1.17.0`

## 🚀 Quick Start

### Basic Row/Column Layout

Create simple horizontal or vertical layouts with built-in spacing and
alignment:

```dart
FlexBox(
  direction: Axis.horizontal, // or Axis.vertical
  spacing: 8,
  alignment: Alignment.center,
  children: [
    FlexBoxChild(
      width: const BoxSize.fixed(80),
      height: const BoxSize.fixed(40),
      child: Container(color: Colors.blue),
    ),
    FlexBoxChild(
      width: const BoxSize.fixed(120),
      height: const BoxSize.fixed(40),
      child: Container(color: Colors.green),
    ),
  ],
)
```

### Advanced Per-Child Control

Wrap children with `FlexBoxChild` to unlock powerful sizing and positioning
options:

```dart
FlexBox(
  direction: Axis.horizontal,
  spacing: 12, // or double.infinity for flexible/even gap
  padding: const EdgeInsets.all(8),
  children: [
    // Fixed width, intrinsic height
    FlexBoxChild(
      width: const BoxSize.fixed(120),
      height: const BoxSize.intrinsic(),
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(8), 
          child: Text('Fixed 120'),
        ),
      ),
    ),
    
    // Relative sizing (50% of parent)
    FlexBoxChild(
      width: const BoxSize.relative(0.5),
      height: const BoxSize.relative(0.5),
      child: Container(color: Colors.orange),
    ),
    
    // Sticky positioned element
    FlexBoxChild(
      left: const BoxPosition.fixed(0),
      top: const BoxPosition.fixed(0),
      horizontalPosition: BoxPositionType.stickyStart,
      verticalPosition: BoxPositionType.stickyStart,
      zOrder: 10, // Paint on top
      child: const Chip(label: Text('Sticky')),
    ),
  ],
)
```

## 📚 Examples

### 📌 Sticky Header

Create headers that stick to the top while content scrolls beneath:

```dart
FlexBox(
  direction: Axis.vertical,
  children: [
    // Sticky header
    const FlexBoxChild(
      height: BoxSize.fixed(48),
      width: BoxSize.unconstrained(),
      verticalPosition: BoxPositionType.stickyStart,
      horizontalPosition: BoxPositionType.stickyStart,
      zOrder: 10,
      child: Material(
        elevation: 2,
        child: ListTile(title: Text('Sticky Header')),
      ),
    ),
    
    // Scrollable content
    for (var i = 0; i < 30; i++)
      FlexBoxChild(
        child: ListTile(title: Text('Row #$i')),
      ),
  ],
)
```

### 📏 Flexible Card Layout

Mix fixed and flexible sizing for responsive designs:

```dart
FlexBox(
  spacing: 12,
  children: const [
    FlexBoxChild(
      width: BoxSize.fixed(120), 
      child: Placeholder(),
    ),
    FlexBoxChild(
      width: BoxSize.flex(1), // Takes remaining space
      child: Placeholder(),
    ),
  ],
)
```

## 📖 API Reference

### 🏗️ FlexBox

The main container widget that provides 2D layout capabilities with optional
scrolling.

#### Properties

| Property                   | Type                 | Description                                               |
| -------------------------- | -------------------- | --------------------------------------------------------- |
| `direction`                | `Axis`               | Layout direction: `horizontal` (default) or `vertical`    |
| `spacing`                  | `double`             | Gap between children widgets                              |
| `alignment`                | `AlignmentGeometry`  | How to align children within the container                |
| `children`                 | `List<Widget>`       | Child widgets to layout                                   |
| `padding`                  | `EdgeInsetsGeometry` | Internal padding around children                          |
| `reverse`                  | `bool`               | Reverse the main-axis logical order                       |
| `scrollHorizontalOverflow` | `bool`               | Enable horizontal scrolling on overflow (default: `true`) |
| `scrollVerticalOverflow`   | `bool`               | Enable vertical scrolling on overflow (default: `true`)   |
| `clipBehavior`             | `Clip`               | Clipping behavior (default: `hardEdge`)                   |
| `horizontalController`     | `ScrollController?`  | Optional horizontal scroll controller                     |
| `verticalController`       | `ScrollController?`  | Optional vertical scroll controller                       |

> **Note:** Both axes can scroll independently when overflow occurs.

### 🎯 FlexBoxChild

Wrapper widget that enables advanced per-child layout control within a
`FlexBox`.

#### Properties

| Property                                 | Type              | Description                                 |
| ---------------------------------------- | ----------------- | ------------------------------------------- |
| `width`, `height`                        | `BoxSize`         | Size constraints for the child              |
| `top`, `bottom`, `left`, `right`         | `BoxPosition`     | Edge positioning offsets                    |
| `horizontalPosition`, `verticalPosition` | `BoxPositionType` | Positioning behavior per axis               |
| `zOrder`                                 | `int`             | Stacking order (higher values paint on top) |

> **Tip:** Combine any properties! When edge positions are provided, the child
> becomes absolutely/relatively positioned based on `BoxPositionType`.

### 📏 BoxSize

Defines how a child should be sized along an axis.

```dart
// Fixed size with optional constraints
BoxSize.fixed(double size, {double? min, double? max})

// Size based on child's intrinsic dimensions  
BoxSize.intrinsic({double? min, double? max})

// No size constraints (use child's natural size)
BoxSize.unconstrained({double? min, double? max})

// Size proportional to the other axis
BoxSize.ratio(double ratio, {double? min, double? max})

// Size as fraction of parent (0.0 to 1.0)
BoxSize.relative(double relative, {double? min, double? max})

// Share remaining space with other flex children
BoxSize.flex(double flex, {double? min, double? max})
```

### 📍 BoxPosition

Defines offset positioning from container edges.

```dart
// Fixed pixel offset
BoxPosition.fixed(double px)

// Offset as fraction of parent size (0.0 to 1.0) 
BoxPosition.relative(double fraction)

// Participate in distributing remaining space
BoxPosition.flex(double flex)
```

### 🎮 BoxPositionType

Controls how positioned children respond to scrolling.

| Type          | Description                                |
| ------------- | ------------------------------------------ |
| `fixed`       | Not affected by scrolling                  |
| `relative`    | Scrolls with content                       |
| `sticky`      | Scrolls until viewport edge, then clamps   |
| `stickyStart` | Sticks to start edge of parent's main axis |
| `stickyEnd`   | Sticks to end edge of parent's main axis   |

## 🎯 Advanced Usage

### 🌊 Morphing Widgets

Create smooth transitions between different widget states using the morph
system.

#### Components

| Widget                | Description                                                   |
| --------------------- | ------------------------------------------------------------- |
| `Morph`               | Container that interpolates between child states (0.0 to 1.0) |
| `Morphed`             | Marks a widget subtree as morphable with a unique tag         |
| `MorphedDecoratedBox` | Special DecoratedBox that morphs decorations and geometry     |

```dart
Morph(
  interpolation: 0.5, // 0.0 to 1.0
  children: [...], // Multiple states to interpolate between
)
```

> **Pro Tip:** Use matching `tag` values in `Morphed` widgets to pair elements
> across different states.

#### Example: Shape Morphing

```dart
class MorphDemo extends StatefulWidget {
  const MorphDemo({super.key});
  
  @override
  State<MorphDemo> createState() => _MorphDemoState();
}

class _MorphDemoState extends State<MorphDemo> {
  double t = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: t, 
          onChanged: (v) => setState(() => t = v),
        ),
        Morph(
          interpolation: t,
          children: const [
            // State 1: Blue rounded rectangle
            Center(
              child: Morphed(
                tag: 'shape',
                child: MorphedDecoratedBox(
                  tag: 'shape',
                  decoration: BoxDecoration(
                    color: Colors.blue, 
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: SizedBox(width: 80, height: 80),
                ),
              ),
            ),
            
            // State 2: Red circle
            Center(
              child: Morphed(
                tag: 'shape',
                child: MorphedDecoratedBox(
                  tag: 'shape',
                  decoration: BoxDecoration(
                    color: Colors.red, 
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 140, height: 140),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 📱 Scrolling Behavior

FlexBox provides intelligent scrolling with sensible defaults:

- **Overflow Scrolling**: Automatically enabled when content exceeds container
  bounds
- **Independent Control**: Use `horizontalController` and `verticalController`
  for precise scroll management
- **Smart Defaults**: Keyboard dismissal and diagonal drag behaviors work out of
  the box

```dart
FlexBox(
  // Disable scrolling on specific axes if needed
  scrollHorizontalOverflow: false,
  scrollVerticalOverflow: true,
  
  // Custom scroll controllers
  horizontalController: myHorizontalController,
  verticalController: myVerticalController,
  
  children: [...],
)
```

---

## 📜 License

This project is licensed under the **BSD 3-Clause License**. See
[`LICENSE`](LICENSE) for details.

---

<div align="center">

**Made with ❤️ for the Flutter community**

[📖 Documentation](https://pub.dev/packages/flexbox) •
[🐛 Issues](https://github.com/sunarya-thito/flexbox/issues) •

</div>
