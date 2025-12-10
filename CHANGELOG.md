## 1.0.4
- **NEW**: Added toString and equality check on basic types

## 1.0.3
- **NEW**: Added `debugFillProperties` override to all widgets to provide
  better debugging experience

## 1.0.2

- **NEW**: Added `SizeUnit.relative(double percentage)` to create size units
  relative to the parent's size (Alternative to using `SizeUnit.calculated` for
  common relative sizing scenarios)
- **NEW**: Added `PositionUnit.relative(double factor)` to create position units
  relative to the parent's size for easier relative positioning within
  containers (Alternative to using `PositionUnit.calculated` for common relative
  positioning scenarios)
- **NEW**: Added `SpacingUnit.relative(double percentage)` to create spacing
  units relative to the parent's size (Alternative to using
  `SpacingUnit.calculated` for common relative spacing scenarios)

## 1.0.1

- **FIX**: Corrected flex shrink algorithm to properly handle size constraints
  - Fixed issue where flex shrink calculations were incorrectly constrained
    during initial basis size calculation instead of after flex adjustments
  - Removed premature clamping of `mainBasisSize` and `crossSize` with min/max
    constraints, allowing the flex algorithm to work correctly
  - Fixed `adjustMainSize` calculation to accumulate actual size changes rather
    than intended changes, preventing incorrect flex distribution
  - Ensures flex shrink respects min/max constraints at the correct stage of
    layout
- **DOCS**: Improved README.md formatting for widget extension documentation
  - Added proper section headers for better organization and readability
  - Improved line wrapping in widget extension descriptions
- **NEW**: Added comprehensive `WidgetExtension` providing fluent API for widget
  configuration in flexbox layouts:
  - Sizing methods: `.width()`, `.height()`, `.sized()`, `.minWidth()`,
    `.maxWidth()`, `.minHeight()`, `.maxHeight()`, `.minSized()`, `.maxSized()`,
    `.constrained()`, `.aspectRatio()`
  - Flex behavior: `.flexGrow()`, `.flexShrink()`
  - Positioning: `.top()`, `.left()`, `.bottom()`, `.right()`, `.positioned()`,
    `.position()`
  - Alignment: `.selfAligned()`
  - Layout control: `.paintOrder()`, `.key()`, `.id()`, `.asFlexItem`,
    `.asAbsoluteItem`
  - All methods support method chaining for declarative widget configuration
  - Automatically wraps widgets in `FlexItem` or `AbsoluteItem` as needed
  - Optimizes wrapper nesting when multiple extensions are chained
- **BREAKING**: Renamed internal classes to public API with consistent naming
  conventions:
  - Alignment classes:
    - `DirectionalBoxAlignment` → `BoxAlignmentDirectional`
    - `_EvenSpacingAlignment` → `BoxAlignmentSpacing`
    - `_StretchBoxAlignment` → `BoxAlignmentContentStretch`
    - `_BaselineBoxAlignment` → `BoxAlignmentGeometryBaseline`
  - Size unit classes:
    - `_CalculatedSize` → `SizeCalculated`
    - `_ConstrainedSize` → `SizeConstraint`
    - `_FixedSize` → `SizeFixed`
    - `_SizeViewportSizeReference` → `SizeViewport`
    - `_MinContent` → `SizeMinContent`
    - `_MaxContent` → `SizeMaxContent`
    - `_FitContent` → `SizeFitContent`
  - Position unit classes:
    - `_CalculatedPosition` → `PositionCalculated`
    - `_FixedPosition` → `PositionFixed`
    - `_ViewportSizeReference` → `PositionViewportSize`
    - `_ContentSizeReference` → `PositionContentSize`
    - `_ChildSizeReference` → `PositionChildSize`
    - `_BoxOffset` → `PositionOffset`
    - `_ScrollOffset` → `PositionScroll`
    - `_ContentOverflow` → `PositionOverflow`
    - `_ContentUnderflow` → `PositionUnderflow`
    - `_ViewportEndBound` → `PositionViewportEndBound`
    - `_CrossPosition` → `PositionCross`
    - `_ConstrainedPosition` → `PositionConstraint`
  - Spacing unit classes:
    - `DirectionalEdgeSpacing` → `EdgeSpacingDirectional`
    - `_FixedSpacing` → `SpacingFixed`
    - `_SpacingViewportSizeReference` → `SpacingViewport`
    - `_CalculatedSpacing` → `SpacingCalculated`
    - `_ConstrainedSpacing` → `SpacingConstraint`
    - `_ChildSizeSpacing` → `SpacingChildSize`
- Added `flexiblebox_eval.dart` library export for evaluation system access
- Added comprehensive documentation to all public classes, methods, and
  properties across the entire codebase
- Added documentation to extension methods in `flexiblebox_extensions.dart` and
  `flexiblebox_flutter.dart`
- Fixed README.md code block formatting inconsistencies

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
