import 'dart:math';

import 'package:flexiblebox/src/layout.dart';

/// Defines how an element establishes a positioning context for its absolutely positioned children.
///
/// This enum controls whether an element acts as a reference point for positioning
/// its absolutely positioned descendants. Similar to CSS positioning contexts, this
/// determines which parent an absolutely positioned child will be positioned relative to.
///
/// Used in conjunction with [LayoutBehavior.absolute] and position properties
/// (top, left, right, bottom) to establish the positioning hierarchy.
enum PositionType {
  /// Does not establish a positioning context (default).
  ///
  /// Absolutely positioned children will skip this element and position themselves
  /// relative to the nearest ancestor with [PositionType.relative].
  ///
  /// This is similar to CSS `position: static` where the element does not create
  /// a containing block for absolute positioning.
  none,

  /// Establishes a positioning context for absolutely positioned children.
  ///
  /// Absolutely positioned children will position themselves relative to this
  /// element's top-left corner (or edges based on their position properties).
  ///
  /// This is similar to CSS `position: relative` where the element creates a
  /// containing block for absolutely positioned descendants.
  relative,
}

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
/// - [BoxAlignmentDirectional] for directional (LTR/RTL aware) positioning
/// - [BoxAlignmentContentStretch] for stretching items to fill space
/// - [BoxAlignmentGeometryBaseline] for baseline-based alignment
abstract class BoxAlignmentGeometry {
  /// Creates a constant box alignment geometry.
  ///
  /// This is the base constructor for all alignment geometry types.
  const BoxAlignmentGeometry();

  /// Creates a directional alignment with the specified value.
  /// Values typically range from -1.0 (start) to 1.0 (end), with 0.0 being center.
  static const BoxAlignmentGeometry stretch = BoxAlignmentContentStretch();

  /// Aligns items to the start of the container (left for horizontal, top for vertical).
  static const BoxAlignmentGeometry start = BoxAlignmentDirectional.start;

  /// Centers items within the container.
  static const BoxAlignmentGeometry center = BoxAlignmentDirectional.center;

  /// Aligns items to the end of the container (right for horizontal, bottom for vertical).
  static const BoxAlignmentGeometry end = BoxAlignmentDirectional.end;

  /// Aligns items based on their baseline (typically for text alignment).
  static const BoxAlignmentGeometry baseline = BoxAlignmentGeometryBaseline();

  /// Creates a directional alignment with a custom value.
  /// The value represents the position along the alignment axis.
  const factory BoxAlignmentGeometry.directional(double value) =
      BoxAlignmentDirectional;

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
    required double childSize,
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
  static const BoxAlignmentBase start = BoxAlignmentDirectional.start;

  /// Centers items along the main axis.
  static const BoxAlignmentBase center = BoxAlignmentDirectional.center;

  /// Aligns items to the end of the main axis.
  static const BoxAlignmentBase end = BoxAlignmentDirectional.end;

  /// Distributes items with equal space between them, no space at the edges.
  static const BoxAlignmentBase spaceBetween = BoxAlignmentSpacing.between();

  /// Distributes items with equal space between and around them.
  static const BoxAlignmentBase spaceEvenly = BoxAlignmentSpacing.even();

  /// Distributes items with equal space around each item.
  static const BoxAlignmentBase spaceAround = BoxAlignmentSpacing.around();

  /// Creates symmetric spacing around items with a custom ratio.
  const factory BoxAlignmentBase.spaceAroundSymmetric(double ratio) =
      BoxAlignmentSpacing.aroundSymmetric;

  /// Creates custom spacing ratios for start and end.
  const factory BoxAlignmentBase.spaceAroundRatio(
    double startRatio,
    double endRatio,
  ) = BoxAlignmentSpacing;

  /// Creates a constant box alignment base.
  ///
  /// This is the base constructor for box alignment implementations.
  const BoxAlignmentBase();

  /// Creates a directional alignment with a custom value.
  const factory BoxAlignmentBase.directional(double value) =
      BoxAlignmentDirectional;

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
  static const BoxAlignmentContent stretch = BoxAlignmentContentStretch();

  /// Aligns items to the start of the cross-axis.
  static const BoxAlignmentContent start = BoxAlignmentDirectional.start;

  /// Centers items along the cross-axis.
  static const BoxAlignmentContent center = BoxAlignmentDirectional.center;

  /// Aligns items to the end of the cross-axis.
  static const BoxAlignmentContent end = BoxAlignmentDirectional.end;

  /// Distributes items with equal space between them, no space at the edges.
  static const BoxAlignmentContent spaceBetween = BoxAlignmentSpacing.between();

  /// Distributes items with equal space between and around them.
  static const BoxAlignmentContent spaceEvenly = BoxAlignmentSpacing.even();

  /// Distributes items with equal space around each item.
  static const BoxAlignmentContent spaceAround = BoxAlignmentSpacing.around();

  /// Creates symmetric spacing around items with a custom ratio.
  const factory BoxAlignmentContent.spaceAroundSymmetric(double ratio) =
      BoxAlignmentSpacing.aroundSymmetric;

  /// Creates custom spacing ratios for start and end.
  const factory BoxAlignmentContent.spaceAroundRatio(
    double startRatio,
    double endRatio,
  ) = BoxAlignmentSpacing;

  /// Creates a directional alignment with a custom value.
  const factory BoxAlignmentContent.directional(double value) =
      BoxAlignmentDirectional;

  /// Creates an absolute alignment with a custom value.
  const factory BoxAlignmentContent.absolute(double value) = BoxAlignment;

  /// Creates a constant box alignment content.
  ///
  /// This is the base constructor for content alignment implementations.
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

/// Stretch alignment that makes items fill available space.
///
/// [BoxAlignmentContentStretch] implements the "stretch" alignment behavior
/// where flex items expand to fill the cross-axis dimension of their container.
/// This is commonly used to make all items in a row have equal height, or
/// all items in a column have equal width.
///
/// Items are positioned at offset 0, and the stretching is handled by
/// adjusting their size rather than their position.
class BoxAlignmentContentStretch extends BoxAlignmentContent {
  /// Creates a stretch alignment instance.
  const BoxAlignmentContentStretch();

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

  /// Adjusts the size to the maximum of child size and content size.
  ///
  /// This ensures content stretching alignment fills available space.
  /// Returns the viewport size as the adjusted content size, effectively
  /// stretching the item to fill all available space along the axis.
  @override
  double? adjustSize({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
    required double contentSize,
    required double childSize,
  }) {
    return max(childSize, contentSize);
  }
}

/// Fixed-position box alignment that doesn't consider text direction.
///
/// [BoxAlignment] provides absolute alignment positioning where values
/// are interpreted consistently regardless of text direction (LTR/RTL).
/// For example, -1.0 always means left (horizontal) or top (vertical),
/// while 1.0 always means right or bottom.
///
/// Use this when you need consistent alignment that doesn't change based
/// on locale. For text-direction-aware alignment, use [BoxAlignmentDirectional].
///
/// See also:
///  * [BoxAlignmentDirectional], for text-direction-aware alignment
///  * [BoxAlignmentSpacing], for spacing-based alignment
class BoxAlignment extends BoxAlignmentBase {
  /// Aligns to the start (left/top) of the container.
  static const BoxAlignmentBase start = BoxAlignment(-1.0);

  /// Centers content within the container.
  static const BoxAlignmentBase center = BoxAlignment(0.0);

  /// Aligns to the end (right/bottom) of the container.
  static const BoxAlignmentBase end = BoxAlignment(1.0);

  /// Aligns items based on their text baseline.
  static const BoxAlignmentGeometry baseline = BoxAlignmentGeometryBaseline();

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

/// Baseline alignment for text-containing elements.
///
/// [BoxAlignmentGeometryBaseline] aligns items based on their text baseline,
/// which is essential for aligning text elements so that the text sits on the
/// same line regardless of font size or other styling differences.
///
/// This alignment type is commonly used in flex layouts containing text or
/// elements with text children to ensure visual alignment of the text baseline.
class BoxAlignmentGeometryBaseline extends BoxAlignmentGeometry {
  /// Creates a baseline alignment instance.
  const BoxAlignmentGeometryBaseline();

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

/// Text-direction-aware box alignment that adapts to locale.
///
/// [BoxAlignmentDirectional] provides alignment positioning that respects
/// the text direction (LTR/RTL) of the current locale. For example, 'start'
/// means left in LTR languages but right in RTL languages like Arabic or Hebrew.
///
/// This is the preferred alignment type when building internationalized UIs
/// that need to adapt to different reading directions. The alignment values
/// automatically flip for RTL contexts.
///
/// See also:
///  * [BoxAlignment], for fixed alignment that ignores text direction
///  * [BoxAlignmentSpacing], for spacing-based alignment
class BoxAlignmentDirectional extends BoxAlignmentBase {
  /// Aligns to the start of the container, respecting text direction.
  /// In LTR text, this is left/top; in RTL text, this is right/top.
  static const BoxAlignmentBase start = BoxAlignmentDirectional(-1.0);

  /// Centers content within the container.
  static const BoxAlignmentBase center = BoxAlignmentDirectional(0.0);

  /// Aligns to the end of the container, respecting text direction.
  /// In LTR text, this is right/bottom; in RTL text, this is left/bottom.
  static const BoxAlignmentBase end = BoxAlignmentDirectional(1.0);

  /// Aligns items based on their text baseline.
  static const BoxAlignmentGeometry baseline = BoxAlignmentGeometryBaseline();

  /// The alignment value, where -1.0 is start, 0.0 is center, and 1.0 is end.
  final double value;

  /// Creates a directional alignment with the specified value.
  ///
  /// Values typically range from -1.0 (start) to 1.0 (end), with 0.0 being center.
  /// Unlike [BoxAlignment], this considers the text direction of the parent.
  const BoxAlignmentDirectional(this.value);

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

/// Spacing-based box alignment for distributing items with gaps.
///
/// [BoxAlignmentSpacing] controls how items are distributed within a container
/// by specifying spacing ratios at the start and end. This enables layouts like
/// space-between, space-around, and space-evenly.
///
/// The [aroundStart] and [aroundEnd] values determine how much space is added
/// before the first item and after the last item relative to the space between items.
/// For example, space-around uses 0.5 for both, while space-evenly uses 1.0.
///
/// See also:
///  * [BoxAlignment], for fixed position alignment
///  * [BoxAlignmentDirectional], for text-direction-aware alignment
class BoxAlignmentSpacing extends BoxAlignmentBase {
  /// The spacing ratio at the start (before first item).
  final double aroundStart;

  /// The spacing ratio at the end (after last item).
  final double aroundEnd;

  /// Creates an even spacing alignment with custom start and end ratios.
  const BoxAlignmentSpacing(this.aroundStart, this.aroundEnd);

  /// Creates space-between alignment: equal space between items, no space at edges.
  const BoxAlignmentSpacing.between() : aroundStart = 0.0, aroundEnd = 0.0;

  /// Creates space-evenly alignment: equal space between and around all items.
  const BoxAlignmentSpacing.even() : aroundStart = 1.0, aroundEnd = 1.0;

  /// Creates space-around alignment: equal space around each item.
  const BoxAlignmentSpacing.around() : aroundStart = 0.5, aroundEnd = 0.5;

  /// Creates symmetric space-around with a custom ratio.
  const BoxAlignmentSpacing.aroundSymmetric(double ratio)
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

/// Controls overflow behavior and scrollability of a layout container.
///
/// [LayoutOverflow] defines how a container handles content that exceeds its bounds.
/// It combines three boolean flags to control visibility, clipping, and scrolling:
/// - [allowOverflow]: Whether content can overflow without being clipped
/// - [clipContent]: Whether overflowing content is clipped (hidden)
/// - [allowScrolling]: Whether the container can scroll to reveal overflowed content
///
/// Common patterns:
/// - [visible]: No clipping, no scrolling (content may overflow visibly)
/// - [scroll]: Clipped and scrollable (standard scrolling behavior)
/// - [hidden]: Clipped but not scrollable (content is hidden)
/// - [scrollX]/[scrollY]: Scrolling in one direction only
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
  /// Creates a calculated size unit by combining two size units with an operation.
  ///
  /// Performs mathematical operations (addition, subtraction, multiplication, division)
  /// on two size units to create a composite sizing strategy. This is equivalent to
  /// CSS calc() function.
  ///
  /// Example: `SizeUnit.calc(fixed(100), percentage(50), calculationAdd)`
  /// creates a size that is 100px + 50% of the container.
  const factory SizeUnit.calc(
    SizeUnit a,
    SizeUnit b,
    CalculationOperation operation,
  ) = SizeCalculated;

  /// Linearly interpolates between two size units.
  ///
  /// This creates a smooth transition between different sizing strategies,
  /// useful for animations or responsive design.
  static SizeUnit lerp(SizeUnit a, SizeUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * SizeFixed(1.0 - t) + b * SizeFixed(t);
  }

  /// A size of zero.
  static const SizeUnit zero = SizeFixed(0);

  /// Creates a fixed size with the specified value.
  const factory SizeUnit.fixed(double value) = SizeFixed;

  /// Sizes to the minimum content size (shrink-wrapped).
  static const SizeUnit minContent = SizeMinContent();

  /// Sizes to the maximum content size (expand to fit).
  static const SizeUnit maxContent = SizeMaxContent();

  /// Sizes to fit the content with constraints.
  static const SizeUnit fitContent = SizeFitContent();

  /// Sizes to match the viewport size.
  static const SizeUnit viewportSize = SizeViewport();

  /// Creates a const size unit.
  ///
  /// This is the base constructor for all size unit implementations.
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

  /// Converts the size unit to a code string representation.
  ///
  /// Returns a string that represents this size unit in code form,
  /// useful for debugging and serialization.
  String toCodeString();
}

/// Abstract base class for position units used in element positioning.
///
/// [PositionUnit] defines units that calculate position offsets for elements
/// within a layout container. Unlike size units which determine dimensions,
/// position units specify where elements should be placed along an axis.
///
/// Position units can reference various layout properties:
/// - Fixed pixel offsets
/// - Viewport and content dimensions
/// - Scroll positions and overflow amounts
/// - Child element sizes
/// - Cross-axis positions
///
/// Position units support mathematical operations and can be combined to create
/// complex positioning expressions similar to CSS calc().
///
/// Common uses include:
/// - Absolute positioning of elements
/// - Sticky positioning relative to scroll
/// - Centering based on element or viewport size
/// - Scroll-aware animations
///
/// Example:
/// ```dart
/// // Center an element: 50% viewport - 50% child size
/// final centered = PositionUnit.viewportSize * 0.5 - PositionUnit.childSize() * 0.5;
///
/// // Position 20px from viewport end
/// final offset = PositionUnit.viewportSize - PositionUnit.fixed(20);
/// ```
abstract class PositionUnit {
  /// Creates a calculated position unit combining two position units with an operation.
  ///
  /// This factory allows creating position units that perform calculations
  /// (addition, subtraction, multiplication, division) between two position units.
  const factory PositionUnit.calc(
    PositionUnit a,
    PositionUnit b,
    CalculationOperation operation,
  ) = PositionCalculated;

  /// Linearly interpolates between two position units.
  ///
  /// Returns [a] when [t] is 0.0, [b] when [t] is 1.0, and a blend of both
  /// for values between 0.0 and 1.0.
  static PositionUnit lerp(PositionUnit a, PositionUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * PositionFixed(1.0 - t) + b * PositionFixed(t);
  }

  /// A position unit with value zero.
  static const PositionUnit zero = PositionFixed(0);

  /// A position unit representing the full viewport size along the axis.
  static const PositionUnit viewportSize = PositionViewportSize();

  /// A position unit representing the total content size along the axis.
  static const PositionUnit contentSize = PositionContentSize();

  /// A position unit representing the scroll offset (also called boxOffset).
  ///
  /// Returns the current scroll position along the axis. This is an alias
  /// that can be referenced as 'boxOffset' in expressions.
  static const PositionUnit boxOffset = PositionOffset();

  /// A position unit representing the current scroll offset.
  static const PositionUnit scrollOffset = PositionScroll();

  /// A position unit representing the amount content overflows the viewport.
  static const PositionUnit contentOverflow = PositionOverflow();

  /// A position unit representing the amount content underflows the viewport.
  static const PositionUnit contentUnderflow = PositionUnderflow();

  /// A position unit representing where the viewport starts in content coordinates.
  ///
  /// This is equal to the scroll offset - it represents the position where the
  /// visible viewport begins relative to the total content. For example, if
  /// scrolled 100px down, the viewport start bound is 100.
  static const PositionUnit viewportStartBound = PositionScroll();

  /// A position unit representing where the viewport ends in content coordinates.
  ///
  /// This is calculated as contentSize + scrollOffset, representing the position
  /// where the visible viewport ends relative to the total content.
  static const PositionUnit viewportEndBound = PositionViewportEndBound();

  /// Creates a fixed position unit with the specified pixel value.
  const factory PositionUnit.fixed(double value) = PositionFixed;

  /// Creates a position unit that uses the cross-axis value of another position unit.
  ///
  /// The cross-axis is perpendicular to the current axis: if positioning on the
  /// horizontal axis, this evaluates the position on the vertical axis, and vice versa.
  /// This allows coordinating positions across both dimensions.
  const factory PositionUnit.cross(PositionUnit position) = PositionCross;

  /// Creates a position unit based on a child element's size.
  ///
  /// The optional [key] parameter can reference a specific child element.
  const factory PositionUnit.childSize([Object? key]) = PositionChildSize;

  /// Creates a constrained position unit that clamps values between min and max.
  ///
  /// The [position] is evaluated and then constrained to be within the optional
  /// [min] and [max] bounds.
  const factory PositionUnit.constrained({
    required PositionUnit position,
    PositionUnit min,
    PositionUnit max,
  }) = PositionConstraint;

  /// Creates a const position unit.
  ///
  /// This is the base constructor for all position unit implementations.
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

  /// Converts the position unit to a code string representation.
  ///
  /// Returns a string that represents this position unit in code form,
  /// useful for debugging and serialization.
  String toCodeString();
}

/// Defines a mathematical operation for combining two numeric values.
///
/// Used with calculated size and position units to specify how values
/// should be combined. Common operations include addition, subtraction,
/// multiplication, and division.
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
class SizeCalculated extends SizeUnit {
  /// The first operand in the calculation.
  final SizeUnit first;

  /// The second operand in the calculation.
  final SizeUnit second;

  /// The mathematical operation to perform.
  final CalculationOperation operation;

  /// Creates a calculated size unit with the specified operands and operation.
  const SizeCalculated(this.first, this.second, this.operation);

  @override
  String toCodeString() {
    final op = operation == calculationAdd
        ? '+'
        : operation == calculationSubtract
        ? '-'
        : operation == calculationMultiply
        ? '*'
        : '/';
    return '(${first.toCodeString()} $op ${second.toCodeString()})';
  }

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
/// Similar to [SizeCalculated], this allows creating complex positioning
/// expressions by combining different position units with mathematical operations.
/// For example, you could position an element at the center of the viewport
/// plus an offset.
class PositionCalculated implements PositionUnit {
  /// The first operand in the calculation.
  final PositionUnit first;

  /// The second operand in the calculation.
  final PositionUnit second;

  /// The mathematical operation to perform.
  final CalculationOperation operation;

  /// Creates a calculated position unit from two operands and an operation.
  ///
  /// The [first] and [second] position units are evaluated, then combined
  /// using the specified [operation].
  const PositionCalculated(this.first, this.second, this.operation);

  @override
  String toCodeString() {
    final op = operation == calculationAdd
        ? '+'
        : operation == calculationSubtract
        ? '-'
        : operation == calculationMultiply
        ? '*'
        : '/';
    return '(${first.toCodeString()} $op ${second.toCodeString()})';
  }

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
class PositionFixed implements PositionUnit {
  /// The fixed position value.
  final double value;

  /// Creates a fixed position unit with the specified [value].
  const PositionFixed(this.value);

  @override
  String toCodeString() => '${value}px';

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

/// A position unit that represents the full viewport size along an axis.
///
/// This position unit returns the width of the viewport for horizontal positioning
/// and the height for vertical positioning. It's useful for positioning elements
/// relative to viewport dimensions.
class PositionViewportSize implements PositionUnit {
  /// Creates a viewport size position unit.
  const PositionViewportSize();

  @override
  String toCodeString() => 'viewportSize';

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

/// A position unit that represents the total content size along an axis.
///
/// This position unit returns the width of the content for horizontal positioning
/// and the height for vertical positioning. It's useful for positioning elements
/// relative to the total size of scrollable content.
class PositionContentSize implements PositionUnit {
  /// Creates a content size position unit.
  const PositionContentSize();

  @override
  String toCodeString() => 'contentSize';

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

/// A position unit that represents the size of a child element.
///
/// This position unit returns the size of a child element along the specified axis.
/// If a [key] is provided, it references a specific child; otherwise, it uses
/// the current child being positioned. This is useful for positioning elements
/// relative to the size of other elements in the layout.
class PositionChildSize implements PositionUnit {
  /// Optional key to reference a specific child element.
  final Object? key;

  /// Creates a child size position unit.
  ///
  /// If [key] is null, uses the size of the current child being positioned.
  /// If [key] is provided, looks up the child with that key.
  const PositionChildSize([this.key]);

  @override
  String toCodeString() {
    if (key == null) {
      return 'childSize';
    }
    if (key is String) {
      return 'childSize("$key")';
    }
    return 'childSize(#$key)';
  }

  @override
  double computePosition({
    required ParentLayout parent,
    required ChildLayout child,
    required LayoutAxis direction,
  }) {
    if (key == null) {
      return switch (direction) {
        LayoutAxis.horizontal => child.size.width,
        LayoutAxis.vertical => child.size.height,
      };
    }
    ChildLayout? otherChild = parent.findChildByKey(key!);
    if (otherChild == null) {
      return 0.0;
    }
    return switch (direction) {
      LayoutAxis.horizontal => otherChild.size.width,
      LayoutAxis.vertical => otherChild.size.height,
    };
  }
}

/// A position unit representing the scroll offset position (named 'boxOffset' in expressions).
///
/// This position unit returns the current scroll offset along the specified axis.
/// It's functionally identical to [PositionScroll] but named 'boxOffset' when
/// serialized to code strings. Used for positioning elements relative to scroll position.
class PositionOffset implements PositionUnit {
  /// Creates a box offset position unit.
  const PositionOffset();

  @override
  String toCodeString() => 'boxOffset';

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

/// A position unit that represents the current scroll offset.
///
/// This position unit returns the scroll offset along the specified axis.
/// For horizontal scrolling, it returns the X scroll offset; for vertical
/// scrolling, it returns the Y scroll offset. This is useful for creating
/// scroll-based animations or positioning.
class PositionScroll implements PositionUnit {
  /// Creates a scroll offset position unit.
  const PositionScroll();

  @override
  String toCodeString() => 'scrollOffset';

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

/// A position unit that represents the amount content overflows the viewport.
///
/// This position unit returns the positive difference between content size
/// and viewport size. It returns 0 if the content fits within the viewport.
/// This is useful for scroll indicators or overflow-aware positioning.
class PositionOverflow implements PositionUnit {
  /// Creates a content overflow position unit.
  const PositionOverflow();

  @override
  String toCodeString() => 'contentOverflow';

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

/// A position unit that represents the amount of empty space when content is smaller than viewport.
///
/// This position unit returns the positive difference between viewport size
/// and content size. It returns 0 if the content exceeds or matches the viewport.
/// This is useful for centering content or positioning elements when there's extra space.
class PositionUnderflow implements PositionUnit {
  /// Creates a content underflow position unit.
  const PositionUnderflow();

  @override
  String toCodeString() => 'contentUnderflow';

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

/// A position unit that represents the end boundary of the viewport.
///
/// This position unit calculates where the viewport ends in the content coordinate
/// space by adding the content size and scroll offset. It's useful for positioning
/// elements relative to the visible end of scrollable content.
class PositionViewportEndBound implements PositionUnit {
  /// Creates a viewport end bound position unit.
  const PositionViewportEndBound();

  @override
  String toCodeString() => 'viewportEndBound';

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

/// A position unit that evaluates another position unit on the cross axis.
///
/// This position unit takes a position unit and evaluates it on the perpendicular
/// axis. For example, if used in horizontal positioning, it evaluates the wrapped
/// unit in the vertical direction, and vice versa. This is useful for coordinating
/// positions across both axes.
class PositionCross implements PositionUnit {
  /// The position unit to evaluate on the cross axis.
  final PositionUnit position;

  /// Creates a cross-axis position unit.
  const PositionCross(this.position);

  @override
  String toCodeString() => 'cross(${position.toCodeString()})';

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

/// A position unit that constrains another position unit between minimum and maximum bounds.
///
/// This position unit evaluates a base position and then clamps the result to be
/// within specified min and max bounds. This is useful for ensuring positions
/// stay within valid ranges or creating bounded positioning behaviors.
class PositionConstraint implements PositionUnit {
  /// The base position to constrain.
  final PositionUnit position;

  /// The minimum allowed position value.
  final PositionUnit min;

  /// The maximum allowed position value.
  final PositionUnit max;

  /// Creates a constrained position unit.
  ///
  /// The [position] is required. If [min] or [max] are not provided, they default
  /// to negative and positive infinity respectively, effectively having no constraint.
  const PositionConstraint({
    required this.position,
    this.min = const PositionFixed(double.negativeInfinity),
    this.max = const PositionFixed(double.infinity),
  });

  @override
  String toCodeString() {
    if (min is PositionFixed &&
        (min as PositionFixed).value == double.negativeInfinity &&
        max is PositionFixed &&
        (max as PositionFixed).value == double.infinity) {
      return position.toCodeString();
    }
    return 'clamp(${position.toCodeString()}, min: ${min.toCodeString()}, max: ${max.toCodeString()})';
  }

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

/// A size unit that constrains another size unit between minimum and maximum bounds.
///
/// This size unit evaluates a base size and then clamps the result to be
/// within specified min and max bounds. This is useful for ensuring sizes
/// stay within valid ranges or creating bounded sizing behaviors.
class SizeConstraint extends SizeUnit {
  /// The base size to constrain.
  final SizeUnit size;

  /// The minimum allowed size.
  final SizeUnit min;

  /// The maximum allowed size.
  final SizeUnit max;

  /// Creates a constrained size unit.
  ///
  /// The [size] is required. If [min] or [max] are not provided, they default
  /// to 0 and infinity respectively.
  const SizeConstraint({
    required this.size,
    this.min = const SizeFixed(0),
    this.max = const SizeFixed(double.infinity),
  });

  @override
  String toCodeString() {
    if (min is SizeFixed &&
        (min as SizeFixed).value == 0 &&
        max is SizeFixed &&
        (max as SizeFixed).value == double.infinity) {
      return size.toCodeString();
    }
    return 'clamp(${size.toCodeString()}, min: ${min.toCodeString()}, max: ${max.toCodeString()})';
  }

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
class SizeFixed extends SizeUnit {
  /// The fixed size value.
  final double value;

  /// Creates a fixed size unit with the specified [value].
  const SizeFixed(this.value);

  @override
  String toCodeString() => '${value}px';

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
class SizeViewport extends SizeUnit {
  /// Creates a viewport-sized size unit.
  const SizeViewport();

  @override
  String toCodeString() => 'viewportSize';

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

/// A size unit that sizes to the minimum intrinsic size of the content.
///
/// This size unit evaluates the minimum width or height that the child needs
/// based on its content, without allowing it to shrink smaller than necessary.
/// It's useful for creating content-driven layouts where elements should be
/// as small as possible while still displaying their content properly.
class SizeMinContent extends SizeUnit {
  /// Creates a min-content size unit.
  const SizeMinContent();

  @override
  String toCodeString() => 'minContent';

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

/// A size unit that sizes to the maximum intrinsic size of the content.
///
/// This size unit evaluates the maximum width or height that the child needs
/// based on its content, allowing it to expand as much as needed. It's useful
/// for creating content-driven layouts where elements should be as large as
/// their content requires.
class SizeMaxContent extends SizeUnit {
  /// Creates a max-content size unit.
  const SizeMaxContent();

  @override
  String toCodeString() => 'maxContent';

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

/// A size unit that fits the content within the available space.
///
/// This size unit calculates a size that fits the content optimally within
/// the available space, balancing between min-content and max-content behavior.
/// It's useful for responsive sizing where elements should adapt to both their
/// content and available space.
class SizeFitContent extends SizeUnit {
  /// Creates a fit-content size unit.
  const SizeFitContent();

  @override
  String toCodeString() => 'fitContent';

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

/// Abstract base class for edge spacing geometry with directional awareness.
///
/// Defines spacing for the edges of an element that can be resolved to
/// absolute values based on text direction (LTR/RTL).
abstract class EdgeSpacingGeometry {
  /// The spacing from the top edge.
  final SpacingUnit top;

  /// The spacing from the bottom edge.
  final SpacingUnit bottom;

  /// Creates an edge spacing geometry with optional top and bottom spacing.
  ///
  /// Defaults to zero spacing if not specified.
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
class EdgeSpacingDirectional extends EdgeSpacingGeometry {
  /// The spacing from the start edge (left in LTR, right in RTL).
  final SpacingUnit start;

  /// The spacing from the end edge (right in LTR, left in RTL).
  final SpacingUnit end;

  /// Creates a DirectionalEdgeSpacing with individual directional values.
  const EdgeSpacingDirectional.only({
    this.start = SpacingUnit.zero,
    super.top,
    this.end = SpacingUnit.zero,
    super.bottom,
  }) : super();

  /// Creates a DirectionalEdgeSpacing with the same value for all edges.
  const EdgeSpacingDirectional.all(SpacingUnit value)
    : this.only(
        start: value,
        end: value,
        top: value,
        bottom: value,
      );

  /// Creates a DirectionalEdgeSpacing with symmetric horizontal and vertical values.
  const EdgeSpacingDirectional.symmetric({
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

/// Abstract base class for spacing units used in margins, padding, and gaps.
///
/// [SpacingUnit] defines units that calculate spacing values (margins, padding,
/// gaps) for elements within a layout container. Spacing units determine the
/// whitespace around and between elements.
///
/// Spacing units can reference various layout properties:
/// - Fixed pixel values
/// - Viewport dimensions
/// - Child element sizes
/// - Constrained values with min/max bounds
///
/// Spacing units support mathematical operations and can be combined to create
/// dynamic spacing expressions that respond to layout context.
///
/// Common uses include:
/// - Fixed padding/margins (e.g., 8px, 16px)
/// - Responsive spacing based on viewport size
/// - Gaps between flex items
/// - Dynamic padding based on content
///
/// Spacing is computed during layout after size constraints are known but
/// before final positioning, allowing spacing to adapt to available space.
///
/// Example:
/// ```dart
/// // Fixed spacing
/// final padding = SpacingUnit.fixed(16.0);
///
/// // Responsive spacing: 5% of viewport
/// final gap = SpacingUnit.viewportSize * 0.05;
///
/// // Constrained spacing with min/max
/// final adaptive = SpacingUnit.constrained(
///   spacing: SpacingUnit.viewportSize * 0.02,
///   min: SpacingUnit.fixed(8.0),
///   max: SpacingUnit.fixed(32.0),
/// );
/// ```
abstract class SpacingUnit {
  /// Creates a calculated spacing unit combining two spacing units with an operation.
  ///
  /// This factory allows creating spacing units that perform calculations
  /// (addition, subtraction, multiplication, division) between two spacing units.
  const factory SpacingUnit.calc(
    SpacingUnit a,
    SpacingUnit b,
    CalculationOperation operation,
  ) = SpacingCalculated;

  /// Linearly interpolates between two spacing units.
  ///
  /// Creates smooth transitions between different spacing strategies,
  /// useful for animations and responsive spacing.
  static SpacingUnit lerp(SpacingUnit a, SpacingUnit b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return a * SpacingFixed(1.0 - t) + b * SpacingFixed(t);
  }

  /// Zero spacing.
  static const SpacingUnit zero = SpacingFixed(0);

  /// Spacing equal to the viewport size along the axis.
  static const SpacingUnit viewportSize = SpacingViewport();

  /// Creates a fixed spacing with the specified value.
  const factory SpacingUnit.fixed(double value) = SpacingFixed;

  /// Creates a constrained spacing with min/max bounds.
  const factory SpacingUnit.constrained({
    required SpacingUnit spacing,
    SpacingUnit min,
    SpacingUnit max,
  }) = SpacingConstraint;

  /// Creates a spacing unit based on a child element's size.
  ///
  /// The optional [key] parameter can reference a specific child element.
  const factory SpacingUnit.childSize([Object? key]) = SpacingChildSize;

  /// Creates a const spacing unit.
  ///
  /// This is the base constructor for all spacing unit implementations.
  const SpacingUnit();

  /// Computes the actual spacing value.
  ///
  /// Spacing units are computed during layout to determine margins, padding,
  /// or gaps between elements. The calculation considers the parent layout context,
  /// the axis direction, and the available viewport size.
  ///
  /// Parameters:
  /// - [parent]: The parent layout providing context
  /// - [axis]: The axis along which spacing is calculated ([LayoutAxis.horizontal] or [LayoutAxis.vertical])
  /// - [viewportSize]: The size of the viewport along the specified axis
  ///
  /// Returns the computed spacing value in pixels.
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
  });

  /// Returns a code string representation of this spacing unit.
  String toCodeString();
}

/// A spacing unit that represents a fixed, unchanging spacing value.
///
/// This is the simplest spacing unit - it always returns the same value
/// regardless of layout context or available space.
class SpacingFixed implements SpacingUnit {
  /// The fixed spacing value.
  final double value;

  /// Creates a fixed spacing unit with the specified [value].
  const SpacingFixed(this.value);

  @override
  String toCodeString() => '${value}px';

  /// Returns the fixed spacing value.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
  }) {
    return value;
  }
}

/// A spacing unit that matches the viewport size along the specified axis.
///
/// Returns the viewport width for horizontal axis, viewport height for vertical axis.
class SpacingViewport implements SpacingUnit {
  /// Creates a viewport-sized spacing unit.
  const SpacingViewport();

  @override
  String toCodeString() => 'viewportSize';

  /// Returns the viewport size along the axis.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
  }) {
    return viewportSize;
  }
}

/// A spacing unit that performs calculations between two other spacing units.
///
/// Similar to [SizeCalculated] and [PositionCalculated], this allows creating
/// complex spacing expressions by combining different spacing units with
/// mathematical operations.
class SpacingCalculated implements SpacingUnit {
  /// The first operand in the calculation.
  final SpacingUnit first;

  /// The second operand in the calculation.
  final SpacingUnit second;

  /// The mathematical operation to perform.
  final CalculationOperation operation;

  /// Creates a calculated spacing unit from two operands and an operation.
  ///
  /// The [first] and [second] spacing units are evaluated, then combined
  /// using the specified [operation].
  const SpacingCalculated(this.first, this.second, this.operation);

  @override
  String toCodeString() {
    final op = operation == calculationAdd
        ? '+'
        : operation == calculationSubtract
        ? '-'
        : operation == calculationMultiply
        ? '*'
        : '/';
    return '(${first.toCodeString()} $op ${second.toCodeString()})';
  }

  /// Computes the spacing by calculating both operands and applying the operation.
  ///
  /// First computes the spacing of both [first] and [second] operands using
  /// the same layout context, then applies the [operation] to combine them.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
  }) {
    double first = this.first.computeSpacing(
      parent: parent,
      axis: axis,
      viewportSize: viewportSize,
    );
    double second = this.second.computeSpacing(
      parent: parent,
      axis: axis,
      viewportSize: viewportSize,
    );
    return operation(first, second);
  }
}

/// A spacing unit that constrains another spacing unit within min/max bounds.
///
/// This allows limiting spacing values to prevent them from becoming too small
/// or too large, while still allowing dynamic calculation of the base spacing.
class SpacingConstraint implements SpacingUnit {
  /// The base spacing to constrain.
  final SpacingUnit spacing;

  /// The minimum allowed spacing.
  final SpacingUnit min;

  /// The maximum allowed spacing.
  final SpacingUnit max;

  /// Creates a constrained spacing unit with optional min and max bounds.
  ///
  /// The computed [spacing] value will be clamped between [min] and [max].
  /// Defaults to no minimum (0) and no maximum (infinity).
  const SpacingConstraint({
    required this.spacing,
    this.min = const SpacingFixed(0),
    this.max = const SpacingFixed(double.infinity),
  });

  @override
  String toCodeString() {
    if (min is SpacingFixed &&
        (min as SpacingFixed).value == 0 &&
        max is SpacingFixed &&
        (max as SpacingFixed).value == double.infinity) {
      return spacing.toCodeString();
    }
    return 'clamp(${spacing.toCodeString()}, min: ${min.toCodeString()}, max: ${max.toCodeString()})';
  }

  /// Computes the spacing and clamps it between min and max bounds.
  ///
  /// First computes the base spacing, then computes the min and max bounds,
  /// and finally clamps the result to ensure it stays within the allowed range.
  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
  }) {
    double val = spacing.computeSpacing(
      parent: parent,
      axis: axis,
      viewportSize: viewportSize,
    );
    double minVal = min.computeSpacing(
      parent: parent,
      axis: axis,
      viewportSize: viewportSize,
    );
    double maxVal = max.computeSpacing(
      parent: parent,
      axis: axis,
      viewportSize: viewportSize,
    );
    return val.clamp(minVal, maxVal);
  }
}

/// A spacing unit that references the size of a child element.
///
/// This allows spacing to be based on the dimensions of another child
/// in the layout, identified by an optional key.
class SpacingChildSize implements SpacingUnit {
  /// Optional key to identify which child to reference.
  final Object? key;

  /// Creates a child-size-based spacing unit.
  ///
  /// If [key] is provided, references a specific child element.
  /// If [key] is null, references the default child.
  const SpacingChildSize([this.key]);

  @override
  String toCodeString() {
    if (key == null) {
      return 'childSize';
    }
    if (key is String) {
      return 'childSize("$key")';
    }
    return 'childSize(#$key)';
  }

  @override
  double computeSpacing({
    required ParentLayout parent,
    required LayoutAxis axis,
    required double viewportSize,
  }) {
    ChildLayout? otherChild = parent.findChildByKey(key!);
    if (otherChild == null) {
      return 0.0;
    }
    return switch (axis) {
      LayoutAxis.horizontal => otherChild.size.width,
      LayoutAxis.vertical => otherChild.size.height,
    };
  }
}

/// Extension providing arithmetic operators for position units.
///
/// Adds convenient operator overloads for combining position units using
/// mathematical operations. These operators create calculated position units
/// that evaluate to the combined result at layout time.
///
/// Example: `PositionUnit.zero + PositionUnit.fixed(10)` creates a position
/// that is 10 pixels from the reference point.
extension PositionUnitExtension on PositionUnit {
  /// Adds two position units together.
  PositionUnit operator +(PositionUnit other) {
    return PositionCalculated(
      this,
      other,
      calculationAdd,
    );
  }

  /// Subtracts one position unit from another.
  PositionUnit operator -(PositionUnit other) {
    return PositionCalculated(
      this,
      other,
      calculationSubtract,
    );
  }

  /// Multiplies two position units.
  PositionUnit operator *(Object other) {
    if (other is PositionUnit) {
      return PositionCalculated(
        this,
        other,
        calculationMultiply,
      );
    }
    if (other is double) {
      return PositionCalculated(
        this,
        PositionUnit.fixed(other),
        calculationMultiply,
      );
    }
    throw ArgumentError('Cannot multiply PositionUnit by $other');
  }

  /// Multiplies a position unit by a scalar.
  PositionUnit times(double other) {
    return PositionCalculated(
      this,
      PositionUnit.fixed(other),
      calculationMultiply,
    );
  }

  /// Divides one position unit by another.
  PositionUnit operator /(PositionUnit other) {
    return PositionCalculated(
      this,
      other,
      calculationDivide,
    );
  }

  /// Negates this position unit (equivalent to 0 - this).
  PositionUnit operator -() {
    return PositionCalculated(
      const PositionFixed(0),
      this,
      calculationSubtract,
    );
  }

  /// Constrains this position unit within the specified min and max bounds.
  PositionUnit clamp({
    PositionUnit min = const PositionFixed(double.negativeInfinity),
    PositionUnit max = const PositionFixed(double.infinity),
  }) {
    return PositionConstraint(
      position: this,
      min: min,
      max: max,
    );
  }
}

/// Extension methods on [SizeUnit] to provide arithmetic operations.
///
/// These operators allow combining size units using mathematical operations,
/// creating calculated size units that evaluate dynamically.
extension SizeUnitExtension on SizeUnit {
  /// Adds two size units together.
  SizeUnit operator +(SizeUnit other) {
    return SizeCalculated(
      this,
      other,
      calculationAdd,
    );
  }

  /// Subtracts one size unit from another.
  SizeUnit operator -(SizeUnit other) {
    return SizeCalculated(
      this,
      other,
      calculationSubtract,
    );
  }

  /// Multiplies two size units.
  SizeUnit operator *(Object other) {
    if (other is SizeUnit) {
      return SizeCalculated(
        this,
        other,
        calculationMultiply,
      );
    }
    if (other is double) {
      return SizeCalculated(
        this,
        SizeUnit.fixed(other),
        calculationMultiply,
      );
    }
    throw ArgumentError('Cannot multiply SizeUnit by $other');
  }

  /// Divides one size unit by another.
  SizeUnit operator /(SizeUnit other) {
    return SizeCalculated(
      this,
      other,
      calculationDivide,
    );
  }

  /// Negates this size unit (equivalent to 0 - this).
  SizeUnit operator -() {
    return SizeCalculated(
      const SizeFixed(0),
      this,
      calculationSubtract,
    );
  }

  /// Constrains this size unit within the specified min and max bounds.
  SizeUnit clamp({
    SizeUnit min = const SizeFixed(0),
    SizeUnit max = const SizeFixed(double.infinity),
  }) {
    return SizeConstraint(
      size: this,
      min: min,
      max: max,
    );
  }
}

/// Extension methods on [SpacingUnit] to provide arithmetic operations.
///
/// These operators allow combining spacing units using mathematical operations,
/// creating calculated spacing units that evaluate dynamically.
extension SpacingUnitExtension on SpacingUnit {
  /// Adds two spacing units together.
  SpacingUnit operator +(SpacingUnit other) {
    return SpacingCalculated(
      this,
      other,
      calculationAdd,
    );
  }

  /// Subtracts one spacing unit from another.
  SpacingUnit operator -(SpacingUnit other) {
    return SpacingCalculated(
      this,
      other,
      calculationSubtract,
    );
  }

  /// Multiplies two spacing units.
  SpacingUnit operator *(Object other) {
    if (other is SpacingUnit) {
      return SpacingCalculated(
        this,
        other,
        calculationMultiply,
      );
    }
    if (other is double) {
      return SpacingCalculated(
        this,
        SpacingUnit.fixed(other),
        calculationMultiply,
      );
    }
    throw ArgumentError('Cannot multiply SpacingUnit by $other');
  }

  /// Divides one spacing unit by another.
  SpacingUnit operator /(SpacingUnit other) {
    return SpacingCalculated(
      this,
      other,
      calculationDivide,
    );
  }

  /// Negates this spacing unit (equivalent to 0 - this).
  SpacingUnit operator -() {
    return SpacingCalculated(
      const SpacingFixed(0),
      this,
      calculationSubtract,
    );
  }

  /// Constrains this spacing unit within the specified min and max bounds.
  SpacingUnit clamp({
    SpacingUnit min = const SpacingFixed(0),
    SpacingUnit max = const SpacingFixed(double.infinity),
  }) {
    return SpacingConstraint(
      spacing: this,
      min: min,
      max: max,
    );
  }
}

/// Represents the bounds of content that overflows beyond the viewport edges.
///
/// OverflowBounds describes how much content extends beyond each edge of the
/// viewport in a layout container. This is used to determine scrolling needs
/// and handle overflow behavior.
///
/// Positive values indicate content extending beyond the viewport:
/// - [top]: Content above the viewport top edge
/// - [bottom]: Content below the viewport bottom edge
/// - [left]: Content to the left of the viewport left edge
/// - [right]: Content to the right of the viewport right edge
///
/// A value of 0 indicates no overflow in that direction.
class OverflowBounds {
  /// The amount of content overflowing above the viewport top edge.
  ///
  /// A positive value indicates how many pixels of content are above the viewport.
  final double top;

  /// The amount of content overflowing below the viewport bottom edge.
  ///
  /// A positive value indicates how many pixels of content are below the viewport.
  final double bottom;

  /// The amount of content overflowing to the left of the viewport left edge.
  ///
  /// A positive value indicates how many pixels of content are to the left of the viewport.
  final double left;

  /// The amount of content overflowing to the right of the viewport right edge.
  ///
  /// A positive value indicates how many pixels of content are to the right of the viewport.
  final double right;

  /// A constant representing no overflow in any direction.
  static const OverflowBounds zero = OverflowBounds(
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  );

  /// Creates an OverflowBounds with the specified overflow amounts.
  ///
  /// All parameters default to 0 if not specified, indicating no overflow.
  const OverflowBounds({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  /// Returns the hash code for this OverflowBounds.
  @override
  int get hashCode => Object.hash(top, bottom, left, right);

  /// Compares this OverflowBounds with another object for equality.
  ///
  /// Returns true if [other] is an OverflowBounds with identical overflow values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OverflowBounds &&
        other.top == top &&
        other.bottom == bottom &&
        other.left == left &&
        other.right == right;
  }

  /// Returns a string representation of this OverflowBounds.
  @override
  String toString() {
    return 'OverflowBounds(top: $top, bottom: $bottom, left: $left, right: $right)';
  }

  /// Returns true if there is overflow in any direction.
  bool get hasOverflow => top > 0 || bottom > 0 || left > 0 || right > 0;

  /// Returns true if there is overflow above the viewport.
  bool get hasTopOverflow => top > 0;

  /// Returns true if there is overflow below the viewport.
  bool get hasBottomOverflow => bottom > 0;

  /// Returns true if there is overflow to the left of the viewport.
  bool get hasLeftOverflow => left > 0;

  /// Returns true if there is overflow to the right of the viewport.
  bool get hasRightOverflow => right > 0;
}
