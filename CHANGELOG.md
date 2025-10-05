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
