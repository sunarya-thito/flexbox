import 'dart:math';

import 'package:flexiblebox/src/layout.dart';

/// Defines the direction in which children are laid out in a flex container.
///
/// The flex direction determines the primary axis along which flex items are placed.
/// It affects how items flow and wrap within the container. The direction can be
/// horizontal (row-based) or vertical (column-based), and can be reversed to change
/// the order of item placement.
///
/// Use this enum to control the main layout axis of a flex container. For example,
/// setting [direction] to [FlexDirection.row] will arrange children horizontally,
/// while [FlexDirection.column] arranges them vertically. Reverse directions
/// ([rowReverse], [columnReverse]) place items in the opposite order along the axis.
enum FlexDirection {
  /// Children are laid out horizontally from left to right.
  /// This is the default direction for most Western languages.
  row(LayoutAxis.horizontal, false),

  /// Children are laid out horizontally from right to left.
  /// Useful for right-to-left languages or when you want items in reverse order.
  rowReverse(LayoutAxis.horizontal, true),

  /// Children are laid out vertically from top to bottom.
  /// Commonly used for navigation menus or stacked content.
  column(LayoutAxis.vertical, false),

  /// Children are laid out vertically from bottom to top.
  /// Items are placed starting from the bottom of the container upwards.
  columnReverse(LayoutAxis.vertical, true);

  /// The layout axis (horizontal or vertical) associated with this direction.
  final LayoutAxis axis;

  /// Whether the direction is reversed (true) or normal (false).
  final bool reverse;

  const FlexDirection(this.axis, this.reverse);
}

/// Defines how flex items wrap within the flex container when they exceed the container's size.
///
/// Flex wrapping controls whether items that don't fit on a single line are moved to
/// additional lines. This is essential for responsive layouts where content needs to
/// adapt to different container sizes.
///
/// When wrapping is enabled, items are distributed across multiple lines based on
/// the [FlexDirection] and available space. The wrapping behavior can be normal
/// or reversed, affecting the order in which lines are filled.
enum FlexWrap {
  /// Items do not wrap. All items remain on a single line, potentially causing overflow.
  /// This is useful when you want to maintain a single-line layout regardless of content size.
  none,

  /// Items wrap to the next line when they don't fit on the current line.
  /// Lines are filled in the normal direction (top-to-bottom for columns, left-to-right for rows).
  wrap,

  /// Items wrap to the previous line when they don't fit.
  /// Lines are filled in reverse order (bottom-to-top for columns, right-to-left for rows).
  wrapReverse,
}

// supports baseline alignment and stretch alignment
// and fixed alignment (start center end)
/// Abstract base class for all alignment geometries in flexbox layouts.
///
/// This class defines the interface for positioning and sizing flex items within
/// their parent container. It supports various alignment modes including baseline
/// alignment (for text alignment), stretch alignment (to fill available space),
/// and fixed alignments (start, center, end).
///
/// Alignment geometries calculate the position and size adjustments needed to
/// place children correctly within the flex container. They work in conjunction
/// with the layout algorithm to determine final item positions.
///
/// Subclasses implement specific alignment behaviors:
/// - [BoxAlignment] for absolute positioning
/// - [DirectionalBoxAlignment] for directional (LTR/RTL aware) positioning
/// - [_StretchBoxAlignment] for stretching items to fill space
/// - [_BaselineBoxAlignment] for baseline-based alignment
abstract class BoxAlignmentGeometry {
  const BoxAlignmentGeometry();

  /// Creates a directional alignment with the specified value.
  /// Values typically range from -1.0 (start) to 1.0 (end), with 0.0 being center.
  static const BoxAlignmentGeometry stretch = _StretchBoxAlignment();

  /// Aligns items to the start of the container (left for horizontal, top for vertical).
  static const BoxAlignmentGeometry start = DirectionalBoxAlignment.start;

  /// Centers items within the container.
  static const BoxAlignmentGeometry center = DirectionalBoxAlignment.center;

  /// Aligns items to the end of the container (right for horizontal, bottom for vertical).
  static const BoxAlignmentGeometry end = DirectionalBoxAlignment.end;

  /// Aligns items based on their baseline (typically for text alignment).
  static const BoxAlignmentGeometry baseline = _BaselineBoxAlignment();

  /// Creates a directional alignment with a custom value.
  /// The value represents the position along the alignment axis.
  const factory BoxAlignmentGeometry.directional(double value) =
      DirectionalBoxAlignment;

  /// Creates an absolute alignment with a custom value.
  /// The value represents the absolute position regardless of text direction.
  const factory BoxAlignmentGeometry.absolute(double value) = BoxAlignment;

  /// Calculates the alignment position for a child within its parent container.
  ///
  /// This method determines where along the alignment axis the child should be positioned.
  /// The calculation considers the parent's layout properties, the axis being aligned,
  /// viewport size, content size, and baseline information.
  ///
  /// Parameters:
  /// - [parent]: The parent layout containing alignment context
  /// - [axis]: The axis along which alignment is being calculated
  /// - [viewportSize]: The size of the viewport/container
  /// - [contentSize]: The natural size of the content being aligned
  /// - [maxBaseline]: The maximum baseline value among siblings (for baseline alignment)
  /// - [childBaseline]: The baseline value of the current child
  ///
  /// Returns the position offset from the start of the alignment axis.
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  });

  /// Optionally adjusts the size of the child during alignment.
  ///
  /// Some alignment modes (like stretch) may modify the child's size to fill
  /// available space. This method returns the adjusted size, or null if no
  /// size adjustment is needed.
  ///
  /// Parameters:
  /// - [parent]: The parent layout context
  /// - [axis]: The axis along which sizing is being considered
  /// - [viewportSize]: The available viewport size
  /// - [contentSize]: The child's natural content size
  ///
  /// Returns the adjusted size, or null to use the natural size.
  double? adjustSize({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
  }) => null;

  /// Determines if this alignment requires baseline information.
  ///
  /// Baseline alignment needs additional information about text baselines
  /// to properly align items. This method indicates whether the layout
  /// system should collect baseline data for children.
  ///
  /// Returns true if baseline information is needed for this alignment.
  bool needsBaseline({
    required ParentLayout parent,
    required LayoutAxis axis,
  });
}

// does not support baseline or stretch,
// usually used for main-axis alignment
/// Abstract base class for alignment geometries that don't support baseline or stretch.
///
/// This class is specifically designed for main-axis alignment in flex containers.
/// Unlike [BoxAlignmentGeometry], it cannot handle baseline alignment (which requires
/// text baseline information) or stretch alignment (which modifies child sizes).
///
/// Main-axis alignment controls how flex items are distributed along the primary
/// layout axis (horizontal for rows, vertical for columns). It includes fixed
/// alignments (start, center, end) and spacing alignments (space-between, space-evenly, etc.).
///
/// Use this class when you need to align items along the main axis without
/// baseline considerations or size stretching.
abstract class BoxAlignmentBase extends BoxAlignmentContent {
  /// Aligns items to the start of the main axis.
  static const BoxAlignmentBase start = DirectionalBoxAlignment.start;

  /// Centers items along the main axis.
  static const BoxAlignmentBase center = DirectionalBoxAlignment.center;

  /// Aligns items to the end of the main axis.
  static const BoxAlignmentBase end = DirectionalBoxAlignment.end;

  /// Distributes items with equal space between them, no space at the edges.
  static const BoxAlignmentBase spaceBetween = _EvenSpacingAlignment.between();

  /// Distributes items with equal space between and around them.
  static const BoxAlignmentBase spaceEvenly = _EvenSpacingAlignment.even();

  /// Distributes items with equal space around each item.
  static const BoxAlignmentBase spaceAround = _EvenSpacingAlignment.around();

  /// Creates symmetric spacing around items with a custom ratio.
  const factory BoxAlignmentBase.spaceAroundSymmetric(double ratio) =
      _EvenSpacingAlignment.aroundSymmetric;

  /// Creates custom spacing ratios for start and end.
  const factory BoxAlignmentBase.spaceAroundRatio(
    double startRatio,
    double endRatio,
  ) = _EvenSpacingAlignment;

  const BoxAlignmentBase();

  /// Creates a directional alignment with a custom value.
  const factory BoxAlignmentBase.directional(double value) =
      DirectionalBoxAlignment;

  /// Creates an absolute alignment with a custom value.
  const factory BoxAlignmentBase.absolute(double value) = BoxAlignment;

  /// This alignment never requires baseline information since it doesn't support baseline alignment.
  @override
  bool needsBaseline({required ParentLayout parent, required LayoutAxis axis}) {
    return false;
  }
}

// does not support baseline, but supports stretch and also fixed alignment
// usually used for cross-axis alignment (specifically in align-content)
/// Abstract base class for alignment geometries that support stretch and fixed alignments but not baseline.
///
/// This class is designed for cross-axis alignment in flex containers, particularly
/// for the `align-content` property which controls how multiple lines of flex items
/// are aligned within the container. Unlike [BoxAlignmentGeometry], it cannot handle
/// baseline alignment but supports stretch alignment and all fixed alignments.
///
/// Cross-axis alignment controls how flex items are positioned perpendicular to the
/// main layout axis. For horizontal flex containers, this affects vertical positioning.
/// For vertical containers, it affects horizontal positioning.
///
/// The stretch alignment allows items to expand to fill available space, while
/// fixed alignments (start, center, end) position items at specific locations.
/// Spacing alignments distribute space between and around items.
abstract class BoxAlignmentContent extends BoxAlignmentGeometry {
  /// Stretches items to fill the available cross-axis space.
  static const BoxAlignmentContent stretch = _StretchBoxAlignment();

  /// Aligns items to the start of the cross-axis.
  static const BoxAlignmentContent start = DirectionalBoxAlignment.start;

  /// Centers items along the cross-axis.
  static const BoxAlignmentContent center = DirectionalBoxAlignment.center;

  /// Aligns items to the end of the cross-axis.
  static const BoxAlignmentContent end = DirectionalBoxAlignment.end;

  /// Distributes items with equal space between them, no space at the edges.
  static const BoxAlignmentContent spaceBetween =
      _EvenSpacingAlignment.between();

  /// Distributes items with equal space between and around them.
  static const BoxAlignmentContent spaceEvenly = _EvenSpacingAlignment.even();

  /// Distributes items with equal space around each item.
  static const BoxAlignmentContent spaceAround = _EvenSpacingAlignment.around();

  /// Creates symmetric spacing around items with a custom ratio.
  const factory BoxAlignmentContent.spaceAroundSymmetric(double ratio) =
      _EvenSpacingAlignment.aroundSymmetric;

  /// Creates custom spacing ratios for start and end.
  const factory BoxAlignmentContent.spaceAroundRatio(
    double startRatio,
    double endRatio,
  ) = _EvenSpacingAlignment;

  /// Creates a directional alignment with a custom value.
  const factory BoxAlignmentContent.directional(double value) =
      DirectionalBoxAlignment;

  /// Creates an absolute alignment with a custom value.
  const factory BoxAlignmentContent.absolute(double value) = BoxAlignment;

  const BoxAlignmentContent();

  /// Adjusts spacing between items when distributing space.
  ///
  /// This method is called when alignment requires distributing additional space
  /// between items (like space-between, space-around, etc.). It calculates how
  /// much extra spacing should be added at the start, between items, and at the end.
  ///
  /// Parameters:
  /// - [parent]: The parent layout context
  /// - [axis]: The axis along which spacing is being adjusted
  /// - [viewportSize]: The total available size
  /// - [contentSize]: The combined size of all content
  /// - [startSpacing]: Existing spacing at the start
  /// - [spacing]: Existing spacing between items
  /// - [endSpacing]: Existing spacing at the end
  /// - [affectedCount]: Number of items affected by spacing
  ///
  /// Returns a record with additional spacing values, or null if no adjustment needed.
  ({
    double additionalStartSpacing,
    double additionalSpacing,
    double additionalEndSpacing,
  })?
  adjustSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double startSpacing,
    required double spacing,
    required double endSpacing,
    required int affectedCount,
  }) => null;
}

class _StretchBoxAlignment extends BoxAlignmentContent {
  const _StretchBoxAlignment();

  /// For stretch alignment, items are positioned at the start (offset 0).
  /// The stretching is handled by [adjustSize] rather than position offset.
  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return 0.0;
  }

  /// Stretch alignment doesn't require baseline information.
  @override
  bool needsBaseline({required ParentLayout parent, required LayoutAxis axis}) {
    return false;
  }

  /// Stretches the content to fill the entire viewport size.
  ///
  /// This method returns the viewport size as the adjusted content size,
  /// effectively stretching the item to fill all available space along the axis.
  @override
  double? adjustSize({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
  }) {
    return contentSize;
  }
}

class BoxAlignment extends BoxAlignmentBase {
  /// Aligns to the start (left/top) of the container.
  static const BoxAlignmentBase start = BoxAlignment(-1.0);

  /// Centers content within the container.
  static const BoxAlignmentBase center = BoxAlignment(0.0);

  /// Aligns to the end (right/bottom) of the container.
  static const BoxAlignmentBase end = BoxAlignment(1.0);

  /// Aligns items based on their text baseline.
  static const BoxAlignmentGeometry baseline = _BaselineBoxAlignment();

  /// The alignment value, where -1.0 is start, 0.0 is center, and 1.0 is end.
  final double value;

  /// Creates an absolute alignment with the specified value.
  ///
  /// Values typically range from -1.0 (start) to 1.0 (end), with 0.0 being center.
  /// This alignment is absolute and doesn't consider text direction.
  const BoxAlignment(this.value);

  /// Calculates the alignment position based on the value.
  ///
  /// The position is calculated as: center + center * value
  /// Where center is (viewportSize - contentSize) / 2
  /// This creates a linear interpolation between start (-1.0) and end (1.0).
  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    double center = (viewportSize - contentSize) / 2.0;
    return center + center * value;
  }
}

class _BaselineBoxAlignment extends BoxAlignmentGeometry {
  const _BaselineBoxAlignment();

  /// Aligns the child so its baseline matches the maximum baseline.
  ///
  /// This calculates the offset needed to align the child's baseline
  /// with the tallest baseline among all children in the container.
  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return maxBaseline - childBaseline;
  }

  /// Baseline alignment requires baseline information to function.
  @override
  bool needsBaseline({required ParentLayout parent, required LayoutAxis axis}) {
    return true;
  }
}

class DirectionalBoxAlignment extends BoxAlignmentBase {
  /// Aligns to the start of the container, respecting text direction.
  /// In LTR text, this is left/top; in RTL text, this is right/top.
  static const BoxAlignmentBase start = DirectionalBoxAlignment(-1.0);

  /// Centers content within the container.
  static const BoxAlignmentBase center = DirectionalBoxAlignment(0.0);

  /// Aligns to the end of the container, respecting text direction.
  /// In LTR text, this is right/bottom; in RTL text, this is left/bottom.
  static const BoxAlignmentBase end = DirectionalBoxAlignment(1.0);

  /// Aligns items based on their text baseline.
  static const BoxAlignmentGeometry baseline = _BaselineBoxAlignment();

  /// The alignment value, where -1.0 is start, 0.0 is center, and 1.0 is end.
  final double value;

  /// Creates a directional alignment with the specified value.
  ///
  /// Values typically range from -1.0 (start) to 1.0 (end), with 0.0 being center.
  /// Unlike [BoxAlignment], this considers the text direction of the parent.
  const DirectionalBoxAlignment(this.value);

  /// Calculates the alignment position based on the value and text direction.
  ///
  /// For LTR text direction: center + center * value
  /// For RTL text direction: center - center * value
  ///
  /// This ensures that "start" always aligns to the reading direction start,
  /// and "end" always aligns to the reading direction end.
  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    double center = (viewportSize - contentSize) / 2.0;
    double value = switch ((axis, parent.textDirection)) {
      // LayoutTextDirection.ltr => this.value,
      // LayoutTextDirection.rtl => -this.value,
      (LayoutAxis.horizontal, LayoutTextDirection.ltr) => this.value,
      (LayoutAxis.horizontal, LayoutTextDirection.rtl) => -this.value,
      (LayoutAxis.vertical, _) => this.value,
    };
    return center + center * value;
  }
}

class _EvenSpacingAlignment extends BoxAlignmentBase {
  /// The spacing ratio at the start (before first item).
  final double aroundStart;

  /// The spacing ratio at the end (after last item).
  final double aroundEnd;

  /// Creates an even spacing alignment with custom start and end ratios.
  const _EvenSpacingAlignment(this.aroundStart, this.aroundEnd);

  /// Creates space-between alignment: equal space between items, no space at edges.
  const _EvenSpacingAlignment.between() : aroundStart = 0.0, aroundEnd = 0.0;

  /// Creates space-evenly alignment: equal space between and around all items.
  const _EvenSpacingAlignment.even() : aroundStart = 1.0, aroundEnd = 1.0;

  /// Creates space-around alignment: equal space around each item.
  const _EvenSpacingAlignment.around() : aroundStart = 0.5, aroundEnd = 0.5;

  /// Creates symmetric space-around with a custom ratio.
  const _EvenSpacingAlignment.aroundSymmetric(double ratio)
    : aroundStart = ratio,
      aroundEnd = ratio;

  /// Even spacing alignments position items at their natural positions (offset 0).
  /// The spacing adjustments are handled by [adjustSpacing].
  @override
  double align({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double maxBaseline,
    required double childBaseline,
  }) {
    return 0.0;
  }

  /// Calculates additional spacing to distribute remaining space evenly.
  ///
  /// This method distributes any remaining space in the viewport after accounting
  /// for content size and minimum spacings. The distribution depends on the
  /// spacing type:
  ///
  /// - space-between: distributes space only between items (aroundStart=0, aroundEnd=0)
  /// - space-around: distributes space around each item (aroundStart=0.5, aroundEnd=0.5)
  /// - space-evenly: distributes space evenly between and at edges (aroundStart=1, aroundEnd=1)
  ///
  /// The calculation:
  /// 1. Calculate remaining space: viewportSize - contentSize
  /// 2. Calculate total flex units: (items-1) + aroundStart + aroundEnd
  /// 3. Divide remaining space by total flex units to get flexUnit
  /// 4. Return additional spacing: start=edgeRatio, between=1.0, end=edgeRatio
  @override
  ({
    double additionalStartSpacing,
    double additionalSpacing,
    double additionalEndSpacing,
  })?
  adjustSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double startSpacing,
    required double spacing,
    required double endSpacing,
    required int affectedCount,
  }) {
    if (affectedCount <= 1) {
      return null;
    }
    // initial startSpacing, spacing, and endSpacing acts as minimum values
    // startSpacing and endSpacing are obtained from padding
    // spacing is obtained from the horizontalSpacing/verticalSpacing
    // note that viewportSize is already reduced by padding
    // and contentSize already contains the spacing between items
    double remainingSpace = max(0.0, viewportSize - contentSize);
    double totalFlex = (affectedCount - 1).toDouble() + aroundStart + aroundEnd;
    if (totalFlex <= 0.0) {
      return null;
    }
    double flexUnit = remainingSpace / totalFlex;
    return (
      additionalStartSpacing: flexUnit * aroundStart,
      additionalSpacing: flexUnit,
      additionalEndSpacing: flexUnit * aroundEnd,
    );
  }
}

final class LayoutOverflow {
  /// Content does not scroll and is not clipped.
  ///
  /// The container will expand to accommodate all content, and content
  /// may overflow the container boundaries without being hidden.
  static const LayoutOverflow visible = LayoutOverflow(false, false, false);

  /// Content scrolls and is clipped.
  ///
  /// Content that exceeds the container size will be clipped (hidden),
  /// and the container becomes scrollable to access overflowed content.
  /// This is the most common behavior for scrollable content.
  static const LayoutOverflow hidden = LayoutOverflow(true, true, false);

  /// Content scrolls and is clipped, with reversed scroll direction.
  ///
  /// Similar to [hidden], but the scroll direction is reversed.
  static const LayoutOverflow hiddenReverse = LayoutOverflow(true, true, true);

  /// Content scrolls but is not clipped.
  ///
  /// The container becomes scrollable, but overflowed content remains
  /// visible outside the container boundaries. This can be useful for
  /// creating custom scrolling effects.
  static const LayoutOverflow scroll = LayoutOverflow(true, false, false);

  /// Content scrolls but is not clipped, with reversed scroll direction.
  ///
  /// Similar to [scroll], but the scroll direction is reversed.
  static const LayoutOverflow scrollReverse = LayoutOverflow(true, false, true);

  /// Content does not scroll but is clipped.
  ///
  /// Content that exceeds the container size is clipped and hidden,
  /// but the container does not provide scrolling to access it.
  /// This effectively hides any overflow without scrollbars.
  static const LayoutOverflow clip = LayoutOverflow(false, true, false);

  /// Whether the content can be scrolled within the container.
  final bool scrollable;

  /// Whether content that exceeds the container bounds should be clipped (hidden).
  final bool clipContent;

  /// Whether the scroll direction is reversed.
  final bool reverse;

  /// Creates a layout overflow configuration.
  ///
  /// The combination of [scrollable] and [clipContent] determines how
  /// overflow is handled:
  /// - scrollable=false, clipContent=false: Content is always visible (visible)
  /// - scrollable=true, clipContent=true: Content scrolls and is clipped (hidden)
  /// - scrollable=true, clipContent=false: Content scrolls but remains visible (scroll)
  /// - scrollable=false, clipContent=true: Content is clipped but not scrollable (clip)
  const LayoutOverflow(this.scrollable, this.clipContent, this.reverse);

  @override
  String toString() {
    return 'LayoutOverflow(scrollable: $scrollable, clip: $clipContent, reverse: $reverse)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LayoutOverflow) return false;
    return scrollable == other.scrollable &&
        clipContent == other.clipContent &&
        reverse == other.reverse;
  }

  @override
  int get hashCode => Object.hash(scrollable, clipContent, reverse);
}

// Units:
// Size Unit: computed after the viewport size has been reduced by the padding
// Spacing Unit: computed before the size unit to add additional flex-basis and after the size unit
// Position Unit: computed after inset, size, and spacing has been resolved

/// Abstract base class for size units used in flexbox layouts.
///
/// Size units define how the size of an element is calculated relative to
/// its content, container, or other layout constraints. They provide a
/// flexible way to specify dimensions that can adapt to different contexts.
///
/// Size units are computed after the viewport size has been reduced by padding,
/// giving them access to the actual available space for content.
///
/// Common size units include:
/// - Fixed sizes ([fixed])
/// - Content-based sizes ([minContent], [maxContent], [fitContent])
/// - Viewport-relative sizes ([viewportSize])
abstract class SizeUnit {
  /// Linearly interpolates between two size units.
  ///
  /// This creates a smooth transition between different sizing strategies,
  /// useful for animations or responsive design.
  static SizeUnit lerp(SizeUnit a, SizeUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * _FixedSize(1.0 - t) + b * _FixedSize(t);
  }

  /// A size of zero.
  static const SizeUnit zero = _FixedSize(0);

  /// Creates a fixed size with the specified value.
  const factory SizeUnit.fixed(double value) = _FixedSize;

  /// Sizes to the minimum content size (shrink-wrapped).
  static const SizeUnit minContent = _MinContent();

  /// Sizes to the maximum content size (expand to fit).
  static const SizeUnit maxContent = _MaxContent();

  /// Sizes to fit the content with constraints.
  static const SizeUnit fitContent = _FitContent();

  /// Sizes to match the viewport size.
  static const SizeUnit viewportSize = _SizeViewportSizeReference();

  const SizeUnit();

  /// Computes the actual size value for this unit.
  ///
  /// The calculation considers the parent layout context, child properties,
  /// layout axis, content size, and viewport constraints to determine
  /// the final size.
  ///
  /// Parameters:
  /// - [parent]: The parent layout providing context and constraints
  /// - [child]: The child element being sized
  /// - [layoutHandle]: Handle for layout operations
  /// - [axis]: The axis along which sizing is calculated
  /// - [contentSize]: The natural size of the content
  /// - [viewportSize]: The available viewport size
  ///
  /// Returns the computed size value.
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  });
}

abstract class PositionUnit {
  static PositionUnit lerp(PositionUnit a, PositionUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * _FixedPosition(1.0 - t) + b * _FixedPosition(t);
  }

  static const PositionUnit zero = _FixedPosition(0);
  static const PositionUnit viewportSize = _ViewportSizeReference();
  static const PositionUnit contentSize = _ContentSizeReference();
  static const PositionUnit childSize = _ChildSizeReference();
  static const PositionUnit boxOffset = _BoxOffset();
  static const PositionUnit scrollOffset = _ScrollOffset();
  static const PositionUnit contentOverflow = _ContentOverflow();
  static const PositionUnit contentUnderflow = _ContentUnderflow();
  static const PositionUnit viewportStartBound = _ScrollOffset();
  static const PositionUnit viewportEndBound = _ViewportEndBound();
  const factory PositionUnit.fixed(double value) = _FixedPosition;
  const factory PositionUnit.cross(PositionUnit position) = _CrossPosition;
  const factory PositionUnit.constrained({
    required PositionUnit position,
    PositionUnit min,
    PositionUnit max,
  }) = _ConstrainedPosition;

  const PositionUnit();

  /// Computes the actual position value for this unit.
  ///
  /// Position units are computed after inset, size, and spacing have been resolved,
  /// allowing them to reference final layout values.
  ///
  /// Parameters:
  /// - [parent]: The parent layout context
  /// - [child]: The child element being positioned
  /// - [direction]: The layout direction (main or cross axis)
  ///
  /// Returns the computed position offset.
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  });
}

typedef CalculationOperation = double Function(double a, double b);

/// Adds two values: a + b
double calculationAdd(double a, double b) => a + b;

/// Subtracts the second value from the first: a - b
double calculationSubtract(double a, double b) => a - b;

/// Multiplies two values: a * b
double calculationMultiply(double a, double b) => a * b;

/// Divides the first value by the second: a / b
double calculationDivide(double a, double b) => a / b;

/// A size unit that performs calculations between two other size units.
///
/// This allows creating complex sizing expressions by combining different
/// size units with mathematical operations. For example, you could create
/// a size that is the sum of a fixed size and a percentage of viewport size.
///
/// The calculation is performed by first computing both operand sizes,
/// then applying the operation to get the final result.
class _CalculatedSize extends SizeUnit {
  /// The first operand in the calculation.
  final SizeUnit first;

  /// The second operand in the calculation.
  final SizeUnit second;

  /// The mathematical operation to perform.
  final CalculationOperation operation;

  const _CalculatedSize({
    required this.first,
    required this.second,
    required this.operation,
  });

  /// Computes the size by calculating both operands and applying the operation.
  ///
  /// First computes the size of both [first] and [second] operands using
  /// the same layout context, then applies the [operation] to combine them.
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    double first = this.first.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double second = this.second.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    return operation(first, second);
  }
}

/// A position unit that performs calculations between two other position units.
///
/// Similar to [_CalculatedSize], this allows creating complex positioning
/// expressions by combining different position units with mathematical operations.
/// For example, you could position an element at the center of the viewport
/// plus an offset.
class _CalculatedPosition implements PositionUnit {
  /// The first operand in the calculation.
  final PositionUnit first;

  /// The second operand in the calculation.
  final PositionUnit second;

  /// The mathematical operation to perform.
  final CalculationOperation operation;

  const _CalculatedPosition({
    required this.first,
    required this.second,
    required this.operation,
  });

  /// Computes the position by calculating both operands and applying the operation.
  ///
  /// First computes the position of both [first] and [second] operands using
  /// the same layout context, then applies the [operation] to combine them.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    double first = this.first.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    double second = this.second.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    return operation(first, second);
  }
}

/// A position unit that represents a fixed, unchanging offset value.
///
/// This is the simplest position unit - it always returns the same value
/// regardless of layout context, viewport size, or content dimensions.
class _FixedPosition implements PositionUnit {
  /// The fixed position value.
  final double value;

  const _FixedPosition(this.value);

  /// Returns the fixed position value.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return value;
  }
}

class _ViewportSizeReference implements PositionUnit {
  const _ViewportSizeReference();

  /// Returns the size of the viewport along the specified axis.
  ///
  /// For horizontal axis, returns viewport width.
  /// For vertical axis, returns viewport height.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.viewportSize.width,
      LayoutAxis.vertical => parent.viewportSize.height,
    };
  }
}

class _ContentSizeReference implements PositionUnit {
  const _ContentSizeReference();

  /// Returns the size of the content along the specified axis.
  ///
  /// For horizontal axis, returns content width.
  /// For vertical axis, returns content height.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.contentSize.width,
      LayoutAxis.vertical => parent.contentSize.height,
    };
  }
}

class _ChildSizeReference implements PositionUnit {
  const _ChildSizeReference();

  /// Returns the size of the child element along the specified axis.
  ///
  /// For horizontal axis, returns child width.
  /// For vertical axis, returns child height.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => child.size.width,
      LayoutAxis.vertical => child.size.height,
    };
  }
}

class _BoxOffset implements PositionUnit {
  const _BoxOffset();

  /// Returns the current scroll offset of the parent along the specified axis.
  ///
  /// For horizontal axis, returns the X scroll offset.
  /// For vertical axis, returns the Y scroll offset.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.scrollOffsetX,
      LayoutAxis.vertical => parent.scrollOffsetY,
    };
  }
}

class _ScrollOffset implements PositionUnit {
  const _ScrollOffset();

  /// Returns the current scroll offset of the parent along the specified axis.
  ///
  /// For horizontal axis, returns the X scroll offset.
  /// For vertical axis, returns the Y scroll offset.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.scrollOffsetX,
      LayoutAxis.vertical => parent.scrollOffsetY,
    };
  }
}

class _ContentOverflow implements PositionUnit {
  const _ContentOverflow();

  /// Returns the amount by which content overflows the viewport.
  ///
  /// This is the positive difference between content size and viewport size.
  /// Returns 0 if content fits within the viewport.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return max(
      0.0,
      switch (direction) {
        LayoutAxis.horizontal =>
          parent.contentSize.width - parent.viewportSize.width,
        LayoutAxis.vertical =>
          parent.contentSize.height - parent.viewportSize.height,
      },
    );
  }
}

class _ContentUnderflow implements PositionUnit {
  const _ContentUnderflow();

  /// Returns the amount of empty space when content is smaller than viewport.
  ///
  /// This is the positive difference between viewport size and content size.
  /// Returns 0 if content fills or overflows the viewport.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return max(
      0.0,
      switch (direction) {
        LayoutAxis.horizontal =>
          parent.viewportSize.width - parent.contentSize.width,
        LayoutAxis.vertical =>
          parent.viewportSize.height - parent.contentSize.height,
      },
    );
  }
}

class _ViewportEndBound implements PositionUnit {
  const _ViewportEndBound();

  /// Returns the position of the viewport's end bound relative to content.
  ///
  /// This calculates: contentSize + scrollOffset
  /// It represents where the viewport ends in the content coordinate space.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return switch (direction) {
      LayoutAxis.horizontal => parent.contentSize.width + parent.scrollOffsetX,
      LayoutAxis.vertical => parent.contentSize.height + parent.scrollOffsetY,
    };
  }
}

class _CrossPosition implements PositionUnit {
  /// The position unit to evaluate on the cross axis.
  final PositionUnit position;

  const _CrossPosition(this.position);

  /// Computes the position by evaluating the wrapped unit on the cross axis.
  ///
  /// If the current direction is horizontal, it evaluates on the vertical axis.
  /// If the current direction is vertical, it evaluates on the horizontal axis.
  /// This allows referencing positions from the perpendicular axis.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    return position.computePosition(
      parent: parent,
      child: child,
      direction: switch (direction) {
        LayoutAxis.horizontal => LayoutAxis.vertical,
        LayoutAxis.vertical => LayoutAxis.horizontal,
      },
    );
  }
}

class _ConstrainedPosition implements PositionUnit {
  /// The base position to constrain.
  final PositionUnit position;

  /// The minimum allowed position value.
  final PositionUnit min;

  /// The maximum allowed position value.
  final PositionUnit max;

  const _ConstrainedPosition({
    required this.position,
    this.min = const _FixedPosition(double.negativeInfinity),
    this.max = const _FixedPosition(double.infinity),
  });

  /// Computes the position and clamps it between min and max bounds.
  ///
  /// First computes the base position, then computes the min and max bounds,
  /// and finally clamps the result to ensure it stays within the allowed range.
  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    double pos = position.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    double minPos = min.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    double maxPos = max.computePosition(
      parent: parent,
      child: child,
      direction: direction,
    );
    return pos.clamp(minPos, maxPos);
  }
}

class _ConstrainedSize extends SizeUnit {
  /// The base size to constrain.
  final SizeUnit size;

  /// The minimum allowed size.
  final SizeUnit min;

  /// The maximum allowed size.
  final SizeUnit max;

  const _ConstrainedSize({
    required this.size,
    this.min = const _FixedSize(0),
    this.max = const _FixedSize(double.infinity),
  });

  /// Computes the size and clamps it between min and max bounds.
  ///
  /// First computes the base size, then computes the min and max bounds,
  /// and finally clamps the result to ensure it stays within the allowed range.
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    double sz = size.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double minSz = min.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    double maxSz = max.computeSize(
      parent: parent,
      child: child,
      layoutHandle: layoutHandle,
      axis: axis,
      contentSize: contentSize,
      viewportSize: viewportSize,
    );
    return sz.clamp(minSz, maxSz);
  }
}

/// A size unit that represents a fixed, unchanging size value.
///
/// This is the simplest size unit - it always returns the same value
/// regardless of layout context, content, or viewport dimensions.
class _FixedSize extends SizeUnit {
  /// The fixed size value.
  final double value;

  const _FixedSize(this.value);

  /// Returns the fixed size value.
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    return value;
  }
}

/// A size unit that matches the viewport size along the specified axis.
///
/// Returns the viewport width for horizontal axis, viewport height for vertical axis.
/// If the viewport size is infinite (during intrinsic sizing), returns 0.0.
class _SizeViewportSizeReference extends SizeUnit {
  const _SizeViewportSizeReference();

  /// Returns the viewport size along the axis, or 0.0 if infinite.
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    double result = switch (axis) {
      LayoutAxis.horizontal => viewportSize.width,
      LayoutAxis.vertical => viewportSize.height,
    };
    // if result is infinite, it might be coming from intrinsic sizing
    return result.isFinite ? result : 0.0;
  }
}

class _MinContent extends SizeUnit {
  const _MinContent();

  /// Returns the minimum intrinsic size of the child along the specified axis.
  ///
  /// This sizes the element to its minimum possible width/height based on
  /// its content, without allowing it to shrink smaller than necessary.
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    return switch (axis) {
      LayoutAxis.horizontal => child.getMinIntrinsicWidth(viewportSize.height),
      LayoutAxis.vertical => child.getMinIntrinsicHeight(viewportSize.width),
    };
  }
}

class _MaxContent extends SizeUnit {
  const _MaxContent();

  /// Returns the maximum intrinsic size of the child along the specified axis.
  ///
  /// This sizes the element to its maximum possible width/height based on
  /// its content, allowing it to expand as much as needed.
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    return switch (axis) {
      LayoutAxis.horizontal => child.getMaxIntrinsicWidth(viewportSize.height),
      LayoutAxis.vertical => child.getMaxIntrinsicHeight(viewportSize.width),
    };
  }
}

class _FitContent extends SizeUnit {
  const _FitContent();

  /// Returns the size that fits the child's content exactly.
  ///
  /// This performs a dry layout of the child with no constraints to determine
  /// its natural size, then returns the width or height along the specified axis.
  /// The result is cached to avoid repeated layout calculations.
  @override
  double computeSize({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutHandle layoutHandle,
    required LayoutAxis axis,
    required LayoutSize contentSize,
    required LayoutSize viewportSize,
  }) {
    LayoutSize? cachedSize = child.layoutCache.cachedFitContentSize;
    if (cachedSize == null) {
      cachedSize = child.dryLayout(LayoutConstraints());
      child.layoutCache.cachedFitContentSize = cachedSize;
    }
    return switch (axis) {
      LayoutAxis.horizontal => cachedSize.width,
      LayoutAxis.vertical => cachedSize.height,
    };
  }
}

abstract class EdgeSpacingGeometry {
  /// The spacing from the top edge.
  final SpacingUnit top;

  /// The spacing from the bottom edge.
  final SpacingUnit bottom;

  const EdgeSpacingGeometry({
    this.top = SpacingUnit.zero,
    this.bottom = SpacingUnit.zero,
  });

  /// Resolves directional spacing (start/end) to absolute spacing (left/right)
  /// based on the text direction.
  EdgeSpacing resolve(LayoutTextDirection direction);
}

/// Defines spacing values for all four edges of a rectangle.
///
/// This class represents absolute spacing from each edge (left, top, right, bottom).
/// The spacing values are resolved to actual pixel values during layout.
///
/// Use this for spacing that doesn't depend on text direction, or when you
/// need explicit control over left/right spacing (like padding or margins).
class EdgeSpacing extends EdgeSpacingGeometry {
  /// Zero spacing for all edges.
  static const EdgeSpacing zero = EdgeSpacing.all(SpacingUnit.zero);

  /// The spacing from the left edge.
  final SpacingUnit left;

  /// The spacing from the right edge.
  final SpacingUnit right;

  /// Creates an EdgeSpacing with individual edge values.
  const EdgeSpacing.only({
    this.left = SpacingUnit.zero,
    this.right = SpacingUnit.zero,
    super.top,
    super.bottom,
  }) : super();

  /// Creates an EdgeSpacing with the same value for all edges.
  const EdgeSpacing.all(SpacingUnit value)
    : left = value,
      right = value,
      super(
        top: value,
        bottom: value,
      );

  /// Creates an EdgeSpacing with symmetric horizontal and vertical values.
  const EdgeSpacing.symmetric({
    SpacingUnit horizontal = SpacingUnit.zero,
    SpacingUnit vertical = SpacingUnit.zero,
  }) : left = horizontal,
       right = horizontal,
       super(
         top: vertical,
         bottom: vertical,
       );

  /// Linearly interpolates between two EdgeSpacing instances.
  static EdgeSpacing lerp(EdgeSpacing a, EdgeSpacing b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return EdgeSpacing.only(
      left: SpacingUnit.lerp(a.left, b.left, t),
      top: SpacingUnit.lerp(a.top, b.top, t),
      right: SpacingUnit.lerp(a.right, b.right, t),
      bottom: SpacingUnit.lerp(a.bottom, b.bottom, t),
    );
  }

  /// Returns this EdgeSpacing as-is since it's already absolute.
  @override
  EdgeSpacing resolve(LayoutTextDirection direction) {
    return this;
  }
}

/// Defines directional spacing values for the edges of a rectangle.
///
/// This class uses start/end instead of left/right, making it text-direction aware.
/// The spacing automatically adapts based on whether the text direction is LTR or RTL.
///
/// Use this for spacing that should respect text direction, such as margins or padding
/// that need to align with reading direction.
class DirectionalEdgeSpacing extends EdgeSpacingGeometry {
  /// The spacing from the start edge (left in LTR, right in RTL).
  final SpacingUnit start;

  /// The spacing from the end edge (right in LTR, left in RTL).
  final SpacingUnit end;

  /// Creates a DirectionalEdgeSpacing with individual directional values.
  const DirectionalEdgeSpacing.only({
    this.start = SpacingUnit.zero,
    super.top,
    this.end = SpacingUnit.zero,
    super.bottom,
  }) : super();

  /// Creates a DirectionalEdgeSpacing with the same value for all edges.
  const DirectionalEdgeSpacing.all(SpacingUnit value)
    : this.only(
        start: value,
        end: value,
        top: value,
        bottom: value,
      );

  /// Creates a DirectionalEdgeSpacing with symmetric horizontal and vertical values.
  const DirectionalEdgeSpacing.symmetric({
    SpacingUnit horizontal = SpacingUnit.zero,
    SpacingUnit vertical = SpacingUnit.zero,
  }) : this.only(
         start: horizontal,
         end: horizontal,
         top: vertical,
         bottom: vertical,
       );

  /// Resolves directional spacing to absolute spacing based on text direction.
  ///
  /// In LTR text: start = left, end = right
  /// In RTL text: start = right, end = left
  @override
  EdgeSpacing resolve(LayoutTextDirection direction) {
    if (direction == LayoutTextDirection.ltr) {
      return EdgeSpacing.only(
        left: start,
        top: top,
        right: end,
        bottom: bottom,
      );
    } else {
      return EdgeSpacing.only(
        left: end,
        top: top,
        right: start,
        bottom: bottom,
      );
    }
  }
}

abstract class SpacingUnit {
  /// Linearly interpolates between two spacing units.
  ///
  /// Creates smooth transitions between different spacing strategies,
  /// useful for animations and responsive spacing.
  static SpacingUnit lerp(SpacingUnit a, SpacingUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * _FixedSpacing(1.0 - t) + b * _FixedSpacing(t);
  }

  /// Zero spacing.
  static const SpacingUnit zero = _FixedSpacing(0);

  /// Spacing equal to the viewport size along the axis.
  static const SpacingUnit viewportSize = _SpacingViewportSizeReference();

  /// Creates a fixed spacing with the specified value.
  const factory SpacingUnit.fixed(double value) = _FixedSpacing;

  /// Creates a constrained spacing with min/max bounds.
  const factory SpacingUnit.constrained({
    required SpacingUnit spacing,
    SpacingUnit min,
    SpacingUnit max,
  }) = _ConstrainedSpacing;

  /// Creates a calculated spacing using two operands and an operation.
  const factory SpacingUnit.computed({
    required SpacingUnit first,
    required SpacingUnit second,
    required CalculationOperation operation,
  }) = _CalculatedSpacing;

  /// Computes the actual spacing value.
  ///
  /// Spacing units are computed during layout to determine margins, padding,
  /// or gaps between elements. The calculation considers available space,
  /// maximum allowed space, and the number of affected elements.
  ///
  /// Parameters:
  /// - [parent]: The parent layout context
  /// - [axis]: The axis along which spacing is calculated
  /// - [maxSpace]: The maximum allowed spacing
  /// - [availableSpace]: The total available space for distribution
  /// - [affectedCount]: Number of elements affected by this spacing
  ///
  /// Returns the computed spacing value.
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  });
}

/// A spacing unit that represents a fixed, unchanging spacing value.
///
/// This is the simplest spacing unit - it always returns the same value
/// regardless of layout context or available space.
class _FixedSpacing implements SpacingUnit {
  /// The fixed spacing value.
  final double value;

  const _FixedSpacing(this.value);

  /// Returns the fixed spacing value.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    return value;
  }
}

/// A spacing unit that matches the viewport size along the specified axis.
///
/// Returns the viewport width for horizontal axis, viewport height for vertical axis.
class _SpacingViewportSizeReference implements SpacingUnit {
  const _SpacingViewportSizeReference();

  /// Returns the viewport size along the axis.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    return switch (axis) {
      LayoutAxis.horizontal => parent.viewportSize.width,
      LayoutAxis.vertical => parent.viewportSize.height,
    };
  }
}

/// A spacing unit that performs calculations between two other spacing units.
///
/// Similar to [_CalculatedSize] and [_CalculatedPosition], this allows creating
/// complex spacing expressions by combining different spacing units with
/// mathematical operations.
class _CalculatedSpacing implements SpacingUnit {
  /// The first operand in the calculation.
  final SpacingUnit first;

  /// The second operand in the calculation.
  final SpacingUnit second;

  /// The mathematical operation to perform.
  final CalculationOperation operation;

  const _CalculatedSpacing({
    required this.first,
    required this.second,
    required this.operation,
  });

  /// Computes the spacing by calculating both operands and applying the operation.
  ///
  /// First computes the spacing of both [first] and [second] operands using
  /// the same layout context, then applies the [operation] to combine them.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    double first = this.first.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    double second = this.second.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    return operation(first, second);
  }
}

/// A spacing unit that constrains another spacing unit within min/max bounds.
///
/// This allows limiting spacing values to prevent them from becoming too small
/// or too large, while still allowing dynamic calculation of the base spacing.
class _ConstrainedSpacing implements SpacingUnit {
  /// The base spacing to constrain.
  final SpacingUnit spacing;

  /// The minimum allowed spacing.
  final SpacingUnit min;

  /// The maximum allowed spacing.
  final SpacingUnit max;

  const _ConstrainedSpacing({
    required this.spacing,
    this.min = const _FixedSpacing(0),
    this.max = const _FixedSpacing(double.infinity),
  });

  /// Computes the spacing and clamps it between min and max bounds.
  ///
  /// First computes the base spacing, then computes the min and max bounds,
  /// and finally clamps the result to ensure it stays within the allowed range.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double maxSpace,
    required double availableSpace,
    required int affectedCount,
  }) {
    double sz = spacing.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    double minSz = min.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    double maxSz = max.computeSpacing(
      parent: parent,
      axis: axis,
      maxSpace: maxSpace,
      availableSpace: availableSpace,
      affectedCount: affectedCount,
    );
    return sz.clamp(minSz, maxSz);
  }
}

extension PositionUnitExtension on PositionUnit {
  /// Adds two position units together.
  PositionUnit operator +(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  /// Subtracts one position unit from another.
  PositionUnit operator -(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  /// Multiplies two position units.
  PositionUnit operator *(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  /// Divides one position unit by another.
  PositionUnit operator /(PositionUnit other) {
    return _CalculatedPosition(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  /// Negates this position unit (equivalent to 0 - this).
  PositionUnit operator -() {
    return _CalculatedPosition(
      first: const _FixedPosition(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  /// Constrains this position unit within the specified min and max bounds.
  PositionUnit clamp({
    PositionUnit min = const _FixedPosition(double.negativeInfinity),
    PositionUnit max = const _FixedPosition(double.infinity),
  }) {
    return _ConstrainedPosition(
      position: this,
      min: min,
      max: max,
    );
  }
}

extension SizeUnitExtension on SizeUnit {
  /// Adds two size units together.
  SizeUnit operator +(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  /// Subtracts one size unit from another.
  SizeUnit operator -(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  /// Multiplies two size units.
  SizeUnit operator *(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  /// Divides one size unit by another.
  SizeUnit operator /(SizeUnit other) {
    return _CalculatedSize(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  /// Negates this size unit (equivalent to 0 - this).
  SizeUnit operator -() {
    return _CalculatedSize(
      first: const _FixedSize(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  /// Constrains this size unit within the specified min and max bounds.
  SizeUnit clamp({
    SizeUnit min = const _FixedSize(0),
    SizeUnit max = const _FixedSize(double.infinity),
  }) {
    return _ConstrainedSize(
      size: this,
      min: min,
      max: max,
    );
  }
}

extension SpacingUnitExtension on SpacingUnit {
  /// Adds two spacing units together.
  SpacingUnit operator +(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationAdd,
    );
  }

  /// Subtracts one spacing unit from another.
  SpacingUnit operator -(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationSubtract,
    );
  }

  /// Multiplies two spacing units.
  SpacingUnit operator *(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationMultiply,
    );
  }

  /// Divides one spacing unit by another.
  SpacingUnit operator /(SpacingUnit other) {
    return _CalculatedSpacing(
      first: this,
      second: other,
      operation: calculationDivide,
    );
  }

  /// Negates this spacing unit (equivalent to 0 - this).
  SpacingUnit operator -() {
    return _CalculatedSpacing(
      first: const _FixedSpacing(0),
      second: this,
      operation: calculationSubtract,
    );
  }

  /// Constrains this spacing unit within the specified min and max bounds.
  SpacingUnit clamp({
    SpacingUnit min = const _FixedSpacing(0),
    SpacingUnit max = const _FixedSpacing(double.infinity),
  }) {
    return _ConstrainedSpacing(
      spacing: this,
      min: min,
      max: max,
    );
  }
}
