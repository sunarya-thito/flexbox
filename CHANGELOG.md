## 1.0.0

- Added `Scrollbars` widget with customizable scrollbar UI for FlexBox
  containers
- Added `PositionType` enum (none, relative) for controlling positioning
  behavior
- Added `toCodeString()` methods to all unit types (SizeUnit, PositionUnit,
  SpacingUnit) for serialization
- Added evaluation system to parse layout units from string expressions
- Added `BoxConstraintsWithData<T>` for passing typed data through constraints
- Added `SpacingUnit.childSize()` to reference child dimensions in spacing
  calculations
- Updated `SpacingUnit.computeSpacing()` to require parent parameter
- Changed calculated unit constructors to use positional parameters (breaking
  change)
- Added `position` and `alignSelf` parameters to FlexItem

## 0.0.9

- Fixed an issue where AbsoluteItem with unspecified width or height would not
  default to `fit-content` if only one of the positioning properties (left/right
  or top/bottom) is set.

## 0.0.8

- No longer skips invisible children during layout to prevent issues with
  `LayoutBuilder` and widget tests.

## 0.0.7

- Added `package:flexiblebox/flexiblebox_extensions.dart` with extension methods
  for `int` and `double` to create `SizeUnit`, `PositionUnit`, and `SpacingUnit`
  more easily.
- Added `PositionUnit.childSize([Object? key])` to reference the size of another
  child by its key, or the current child if no key is provided.

## 0.0.6

- Added fallback intrinsic and dry layout size to LayoutBoxBuilder
  (AbsoluteItem.builder and FlexItem.builder).
- Sticky item now respects layout padding.
- Fixed Scrollable.ensureVisible issue with sticky items.
- AbsoluteItem now fallback to width: fit-content and height: fit-content if
  width, left, and right (or height, top, and bottom) are not specified.
- Fixed Scrollable.ensureVisible alignment issue with sticky items and viewport
  padding.
- LayoutBox now skips invisible children during layout.

## 0.0.5

- Added `RotatedWidget` to rotate its child by a given angle in degrees.
- Fixed alignment issues in `FlexLayout` when using `alignSelf: stretch`.

## 0.0.4

- Added `indexOfNearestChildAtOffset` method to `LayoutBox` and `FlexLayout` to
  find the index of the child nearest to a given offset.
- Fixed StackOverflowError when `paintOrder` is not null
- Added `LayoutBoxBuilder` to `FlexItem` and `AbsoluteItem` for more
  customization of the layout box.

## 0.0.3

- Fixed incorrect LICENSE file reference in README.md

## 0.0.2

- Fully reworked the package structure and API.

## 0.0.1

- Initial release
