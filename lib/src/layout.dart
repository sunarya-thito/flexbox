import 'dart:math';

import 'package:flexiblebox/src/basic.dart';

/// Data structure containing all layout properties for a child element.
///
/// LayoutData encapsulates sizing constraints, positioning information,
/// flex properties, and alignment settings that control how a child
/// is laid out within its parent container.
///
/// This class is immutable and used throughout the layout system to
/// communicate layout requirements between widgets and layout algorithms.
final class LayoutData {
  /// The layout behavior for this child (normal flow or absolute positioning).
  ///
  /// Determines how this child participates in the layout algorithm:
  /// - [LayoutBehavior.none]: Normal flow layout
  /// - [LayoutBehavior.absolute]: Absolute positioning (removed from flow)
  final LayoutBehavior behavior;

  /// The flex grow factor for flexible sizing.
  ///
  /// Determines how much this child should grow relative to its siblings
  /// when there is extra space in the main axis. A value of 0 means no growth.
  final double flexGrow;

  /// The flex shrink factor for flexible sizing.
  ///
  /// Determines how much this child should shrink relative to its siblings
  /// when there is insufficient space in the main axis. A value of 0 means no shrinkage.
  final double flexShrink;

  /// The paint order for controlling drawing sequence.
  ///
  /// Children with lower paint order values are drawn first (behind others).
  /// Useful for controlling visual layering, especially with overlapping elements.
  final int? paintOrder;

  /// The explicit width of this child.
  ///
  /// If specified, constrains the child's width to this value.
  /// Uses [SizeUnit] for responsive sizing.
  final SizeUnit? width;

  /// The explicit height of this child.
  ///
  /// If specified, constrains the child's height to this value.
  /// Uses [SizeUnit] for responsive sizing.
  final SizeUnit? height;

  /// The minimum width constraint.
  ///
  /// The child will not be sized smaller than this width, even if
  /// layout constraints would suggest otherwise.
  final SizeUnit? minWidth;

  /// The maximum width constraint.
  ///
  /// The child will not be sized larger than this width, even if
  /// layout constraints would allow it.
  final SizeUnit? maxWidth;

  /// The minimum height constraint.
  ///
  /// The child will not be sized smaller than this height, even if
  /// layout constraints would suggest otherwise.
  final SizeUnit? minHeight;

  /// The maximum height constraint.
  ///
  /// The child will not be sized larger than this height, even if
  /// layout constraints would allow it.
  final SizeUnit? maxHeight;

  /// The top offset for absolute positioning.
  ///
  /// Specifies the distance from the parent's top edge.
  /// Only used when [behavior] is [LayoutBehavior.absolute].
  final PositionUnit? top;

  /// The left offset for absolute positioning.
  ///
  /// Specifies the distance from the parent's left edge.
  /// Only used when [behavior] is [LayoutBehavior.absolute].
  final PositionUnit? left;

  /// The right offset for absolute positioning.
  ///
  /// Specifies the distance from the parent's right edge.
  /// Only used when [behavior] is [LayoutBehavior.absolute].
  final PositionUnit? right;

  /// The bottom offset for absolute positioning.
  ///
  /// Specifies the distance from the parent's bottom edge.
  /// Only used when [behavior] is [LayoutBehavior.absolute].
  final PositionUnit? bottom;

  /// The aspect ratio constraint (width/height).
  ///
  /// When specified, the child's dimensions will be adjusted to maintain
  /// this aspect ratio, potentially overriding explicit width/height values.
  final double? aspectRatio;

  /// The cross-axis alignment override for this specific child.
  ///
  /// If specified, overrides the parent's default cross-axis alignment
  /// for this individual child. If null, uses the parent's alignment.
  final BoxAlignmentGeometry? alignSelf;

  /// Creates layout data with the specified properties.
  ///
  /// Most parameters are optional and provide fine-grained control over
  /// layout behavior. The [behavior], [flexGrow], and [flexShrink] parameters
  /// are required as they have no sensible defaults.
  ///
  /// ## Example
  ///
  /// ```dart
  /// LayoutData(
  ///   behavior: LayoutBehavior.none,
  ///   flexGrow: 1.0,
  ///   flexShrink: 0.0,
  ///   width: SizeUnit.dp(100),
  ///   height: SizeUnit.dp(50),
  ///   alignSelf: BoxAlignmentGeometry.center,
  /// )
  /// ```
  LayoutData({
    required this.behavior,
    required this.flexGrow,
    required this.flexShrink,
    required this.paintOrder,
    required this.width,
    required this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    required this.top,
    required this.left,
    required this.right,
    required this.bottom,
    required this.aspectRatio,
    this.alignSelf,
  });

  @override
  int get hashCode => Object.hash(
    flexGrow,
    flexShrink,
    paintOrder,
    width,
    height,
    top,
    left,
    right,
    bottom,
    aspectRatio,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LayoutData &&
        other.flexGrow == flexGrow &&
        other.flexShrink == flexShrink &&
        other.paintOrder == paintOrder &&
        other.width == width &&
        other.height == height &&
        other.top == top &&
        other.left == left &&
        other.right == right &&
        other.bottom == bottom &&
        other.aspectRatio == aspectRatio;
  }
}

/// Defines how a child element participates in the layout algorithm.
///
/// This enum controls whether a child follows normal document flow
/// or is positioned absolutely (removed from the flow).
enum LayoutBehavior {
  /// Normal flow layout - the child participates in the layout algorithm
  /// and is positioned according to the container's layout rules.
  none,

  /// Absolute positioning - the child is removed from the normal flow
  /// and positioned using explicit coordinates relative to its parent.
  absolute,
}

/// Represents the axis along which layout occurs.
///
/// Used to distinguish between horizontal and vertical layout directions
/// in various layout calculations and algorithms.
enum LayoutAxis {
  /// Horizontal axis (left to right or right to left).
  horizontal,

  /// Vertical axis (top to bottom or bottom to top).
  vertical,
}

/// Represents a two-dimensional size with width and height.
///
/// This class is used throughout the layout system to represent
/// the dimensions of elements and containers.
class LayoutSize {
  /// A size with zero width and height.
  static const LayoutSize zero = LayoutSize(0.0, 0.0);

  /// The width component of this size.
  final double width;

  /// The height component of this size.
  final double height;

  /// Creates a size with the specified width and height.
  const LayoutSize(this.width, this.height);
}

/// Represents a two-dimensional offset with x and y coordinates.
///
/// Used for positioning elements within the layout coordinate system.
class LayoutOffset {
  /// An offset with zero x and y coordinates.
  static const LayoutOffset zero = LayoutOffset(0.0, 0.0);

  /// The x-coordinate (horizontal offset).
  final double dx;

  /// The y-coordinate (vertical offset).
  final double dy;

  /// Creates an offset with the specified coordinates.
  const LayoutOffset(this.dx, this.dy);

  /// Creates a rectangle by combining this offset with a size.
  ///
  /// The resulting rectangle has this offset as its top-left corner
  /// and extends by the given size.
  LayoutRect operator &(LayoutSize size) {
    return LayoutRect.fromLTWH(dx, dy, size.width, size.height);
  }
}

/// Represents a rectangle with position and size.
///
/// Used to define the bounds of layout elements and perform
/// geometric calculations like expanding to include child bounds.
class LayoutRect {
  /// A rectangle with zero position and size.
  static const LayoutRect zero = LayoutRect.fromLTWH(0.0, 0.0, 0.0, 0.0);

  /// Creates a rectangle from left, top, width, and height.
  const LayoutRect.fromLTWH(this.left, this.top, this.width, this.height);

  /// Creates a rectangle from left, top, right, and bottom coordinates.
  ///
  /// The width and height are calculated as right - left and bottom - top.
  const LayoutRect.fromLTRB(this.left, this.top, double right, double bottom)
    : width = right - left,
      height = bottom - top;

  /// The left edge coordinate.
  final double left;

  /// The top edge coordinate.
  final double top;

  /// The width of the rectangle.
  final double width;

  /// The height of the rectangle.
  final double height;

  /// The right edge coordinate (calculated as left + width).
  double get right => left + width;

  /// The bottom edge coordinate (calculated as top + height).
  double get bottom => top + height;

  /// Expands this rectangle to include the bounds of another rectangle.
  ///
  /// Returns a new rectangle that encompasses both this rectangle
  /// and the [childBounds] rectangle.
  LayoutRect expandToInclude(LayoutRect childBounds) {
    return LayoutRect.fromLTRB(
      min(left, childBounds.left),
      min(top, childBounds.top),
      max(right, childBounds.right),
      max(bottom, childBounds.bottom),
    );
  }

  @override
  String toString() {
    return 'LayoutRect($left, $top, $right, $bottom)';
  }
}

/// Defines text baseline types for alignment calculations.
///
/// Used when aligning text elements by their baseline rather than
/// their geometric bounds.
enum LayoutTextBaseline {
  /// Alphabetic baseline - the baseline used for alphabetic characters.
  alphabetic,

  /// Ideographic baseline - the baseline used for ideographic characters.
  ideographic,
}

/// Defines text direction for layout calculations.
///
/// Affects how directional alignments (start/end) are interpreted
/// and how layout flows in RTL languages.
enum LayoutTextDirection {
  /// Left-to-right text direction.
  ltr,

  /// Right-to-left text direction.
  rtl,
}

/// Defines the size constraints for layout calculations.
///
/// LayoutConstraints specify the minimum and maximum allowable
/// dimensions for an element during layout. The layout algorithm
/// must respect these constraints when determining final sizes.
class LayoutConstraints {
  /// The minimum allowed width.
  ///
  /// Elements will not be sized smaller than this width.
  final double minWidth;

  /// The maximum allowed width.
  ///
  /// Elements will not be sized larger than this width.
  /// Use [double.infinity] for no upper limit.
  final double maxWidth;

  /// The minimum allowed height.
  ///
  /// Elements will not be sized smaller than this height.
  final double minHeight;

  /// The maximum allowed height.
  ///
  /// Elements will not be sized larger than this height.
  /// Use [double.infinity] for no upper limit.
  final double maxHeight;

  /// Creates constraints with the specified bounds.
  ///
  /// All parameters default to reasonable values for unconstrained layout.
  const LayoutConstraints({
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
  });

  /// Creates tight constraints for a specific width and/or height.
  ///
  /// When width is specified, minWidth = maxWidth = width.
  /// When height is specified, minHeight = maxHeight = height.
  /// Unspecified dimensions remain unconstrained.
  const LayoutConstraints.tightFor({
    double? width,
    double? height,
  }) : minWidth = width ?? 0.0,
       maxWidth = width ?? double.infinity,
       minHeight = height ?? 0.0,
       maxHeight = height ?? double.infinity;

  /// Creates tight constraints that exactly match the given size.
  ///
  /// Both min and max constraints are set to the size's dimensions,
  /// forcing the element to be exactly that size.
  LayoutConstraints.tight(LayoutSize size)
    : minWidth = size.width,
      maxWidth = size.width,
      minHeight = size.height,
      maxHeight = size.height;

  /// The largest size that satisfies these constraints.
  LayoutSize get biggest => LayoutSize(maxWidth, maxHeight);

  /// The smallest size that satisfies these constraints.
  LayoutSize get smallest => LayoutSize(minWidth, minHeight);

  /// Constrains a size to fit within these constraints.
  ///
  /// Returns a new size where width and height are clamped to
  /// the min/max bounds of these constraints.
  LayoutSize constrain(LayoutSize size) {
    final width = size.width.clamp(minWidth, maxWidth);
    final height = size.height.clamp(minHeight, maxHeight);
    return LayoutSize(width, height);
  }
}

/// Cache for storing computed layout sizes to avoid redundant calculations.
///
/// This mixin provides caching for expensive layout operations like
/// intrinsic size calculations and dry layouts. The cache stores
/// previously computed sizes to improve performance.
abstract class ChildLayoutCache {
  /// Cached size when the child is sized to fit its content.
  ///
  /// Stores the result of measuring the child with unconstrained dimensions.
  LayoutSize? cachedFitContentSize;

  /// Cached size when the child uses auto-sizing behavior.
  ///
  /// Stores the result of measuring the child according to its auto-sizing rules.
  LayoutSize? cachedAutoSize;
}

/// Interface for child elements that participate in layout.
///
/// ChildLayout defines the contract that all layout participants must implement.
/// It provides methods for layout calculation, sizing, positioning, and cache management.
/// Layout algorithms use this interface to interact with children uniformly.
mixin ChildLayout {
  /// Debug key for identifying this child in debug output.
  ///
  /// Used by debugging tools to provide meaningful identifiers
  /// when inspecting the layout tree.
  Object? get debugKey => null;

  /// Performs the actual layout of this child within the given constraints.
  ///
  /// This method calculates and sets the child's size and position based on
  /// the provided constraints and the child's layout data. After calling this,
  /// the child's [size] and [offset] properties will be valid.
  void layout(LayoutConstraints constraints);

  /// Performs a dry layout without modifying the child's state.
  ///
  /// Returns the size the child would have if laid out with the given constraints,
  /// but doesn't actually position or size the child. Useful for measuring
  /// and calculating layouts without side effects.
  LayoutSize dryLayout(LayoutConstraints constraints);

  /// Returns the maximum intrinsic width of this child at the given height.
  ///
  /// The intrinsic width is the natural width the child would prefer,
  /// independent of external constraints. This is used for layout algorithms
  /// that need to know the child's preferred dimensions.
  double getMaxIntrinsicWidth(double height);

  /// Returns the maximum intrinsic height of this child at the given width.
  ///
  /// The intrinsic height is the natural height the child would prefer,
  /// independent of external constraints.
  double getMaxIntrinsicHeight(double width);

  /// Returns the minimum intrinsic width of this child at the given height.
  ///
  /// The minimum intrinsic width is the smallest width the child can
  /// reasonably have while still being functional.
  double getMinIntrinsicWidth(double height);

  /// Returns the minimum intrinsic height of this child at the given width.
  ///
  /// The minimum intrinsic height is the smallest height the child can
  /// reasonably have while still being functional.
  double getMinIntrinsicHeight(double width);

  /// The current size of this child after layout.
  ///
  /// Only valid after [layout] has been called. Represents the final
  /// dimensions assigned to this child.
  LayoutSize get size;

  /// The current offset (position) of this child after layout.
  ///
  /// Only valid after [layout] has been called. Represents the final
  /// position assigned to this child relative to its parent.
  LayoutOffset get offset;

  /// Sets the offset (position) of this child.
  ///
  /// Used by layout algorithms to position the child after sizing.
  set offset(LayoutOffset value);

  /// The cache for storing computed layout results.
  ///
  /// Provides access to cached sizes and measurements to avoid
  /// redundant calculations.
  ChildLayoutCache get layoutCache;

  /// The layout data containing this child's layout properties.
  ///
  /// Includes sizing constraints, flex properties, positioning,
  /// and alignment information.
  LayoutData get layoutData;

  /// The next sibling in the layout tree.
  ///
  /// Used for traversing the child list during layout calculations.
  ChildLayout? get nextSibling;

  /// The previous sibling in the layout tree.
  ///
  /// Used for traversing the child list during layout calculations.
  ChildLayout? get previousSibling;

  /// Returns the distance from the top of this child to the specified baseline.
  ///
  /// Used for text alignment when children contain text elements.
  /// Returns the distance from the child's top edge to the baseline.
  double getDistanceToBaseline(LayoutTextBaseline baseline);

  /// Clears all cached layout calculations.
  ///
  /// Forces the child to recalculate its layout on the next layout pass.
  /// Used when layout-affecting properties change.
  void clearCache();
}

/// A delegate that performs dry layout operations on behalf of a child.
///
/// ChildLayoutDryDelegate wraps an existing [ChildLayout] and provides
/// the same interface, but performs operations without side effects.
/// It's used for measuring layouts without actually positioning elements.
///
/// This class is particularly useful for:
/// - Calculating intrinsic sizes
/// - Measuring layouts for scrolling calculations
/// - Performing "what-if" layout scenarios
class ChildLayoutDryDelegate with ChildLayout {
  /// Creates a forward-linked chain of dry layout delegates.
  ///
  /// Starting from [firstChild], creates a linked list of delegates
  /// that can perform dry layout operations. Returns the first delegate
  /// in the chain, or null if [firstChild] is null.
  static ChildLayoutDryDelegate? forwardCopy(
    ChildLayout? firstChild,
    LayoutHandle<Layout> layoutHandle,
  ) {
    ChildLayoutDryDelegate? first;
    ChildLayoutDryDelegate? last;
    ChildLayout? child = firstChild;
    while (child != null) {
      final delegate = ChildLayoutDryDelegate(child, layoutHandle.setupCache());
      if (first == null) {
        first = delegate;
        last = delegate;
      } else {
        last!.nextSibling = delegate;
        delegate.previousSibling = last;
        last = delegate;
      }
      child = child.nextSibling;
    }
    return first;
  }

  /// Creates a backward-linked chain of dry layout delegates.
  ///
  /// Starting from [lastChild], creates a linked list of delegates
  /// in reverse order. Returns the last delegate in the chain,
  /// or null if [lastChild] is null.
  static ChildLayoutDryDelegate? backwardCopy(
    ChildLayout? lastChild,
    LayoutHandle<Layout> layoutHandle,
  ) {
    ChildLayoutDryDelegate? first;
    ChildLayoutDryDelegate? last;
    ChildLayout? child = lastChild;
    while (child != null) {
      final delegate = ChildLayoutDryDelegate(child, layoutHandle.setupCache());
      if (last == null) {
        last = delegate;
        first = delegate;
      } else {
        first!.previousSibling = delegate;
        delegate.nextSibling = first;
        first = delegate;
      }
      child = child.previousSibling;
    }
    return last;
  }

  /// The actual child layout being delegated to.
  final ChildLayout child;

  /// The cache to use for this dry layout operation.
  @override
  final ChildLayoutCache layoutCache;

  /// Creates a dry layout delegate for the given child.
  ChildLayoutDryDelegate(this.child, this.layoutCache);

  /// Clears the cache (no-op for dry delegates).
  ///
  /// Dry layout operations don't modify the child's actual cache,
  /// so this method does nothing.
  @override
  void clearCache() {
    // do nothing, the child cache is automatically cleared
    // when the dry layout is performed
  }

  /// Throws an exception - offset is not supported in dry layout.
  ///
  /// Dry layout operations don't set positions, so accessing offset
  /// is not meaningful.
  @override
  LayoutOffset get offset {
    throw Exception('offset is not supported in dry delegate');
  }

  /// Throws an exception - setting offset is not supported in dry layout.
  @override
  set offset(LayoutOffset value) {
    throw Exception('offset is not supported in dry delegate');
  }

  /// Performs a dry layout on the child.
  @override
  LayoutSize dryLayout(LayoutConstraints constraints) {
    return child.dryLayout(constraints);
  }

  /// Gets the distance to baseline from the child.
  @override
  double getDistanceToBaseline(LayoutTextBaseline baseline) {
    return child.getDistanceToBaseline(baseline);
  }

  /// Gets the maximum intrinsic height from the child.
  @override
  double getMaxIntrinsicHeight(double width) {
    return child.getMaxIntrinsicHeight(width);
  }

  /// Gets the maximum intrinsic width from the child.
  @override
  double getMaxIntrinsicWidth(double height) {
    return child.getMaxIntrinsicWidth(height);
  }

  /// Gets the minimum intrinsic height from the child.
  @override
  double getMinIntrinsicHeight(double width) {
    return child.getMinIntrinsicHeight(width);
  }

  /// Gets the minimum intrinsic width from the child.
  @override
  double getMinIntrinsicWidth(double height) {
    return child.getMinIntrinsicWidth(height);
  }

  /// Throws an exception - actual layout is not supported in dry operations.
  ///
  /// Dry delegates only perform measurements, not actual layout.
  @override
  void layout(LayoutConstraints constraints) {
    throw Exception('layout is not supported in dry delegate');
  }

  /// Returns the child's layout data.
  @override
  LayoutData get layoutData => child.layoutData;

  /// The next sibling in the dry layout chain.
  @override
  ChildLayout? nextSibling;

  /// The previous sibling in the dry layout chain.
  @override
  ChildLayout? previousSibling;

  /// Throws an exception - size is not available in dry layout.
  ///
  /// Dry layout doesn't set the child's actual size.
  @override
  LayoutSize get size {
    throw Exception('size is not supported in dry delegate');
  }
}

/// Interface for parent elements that manage child layout.
///
/// ParentLayout defines the contract that layout containers must implement
/// to work with the layout system. It provides access to children, viewport
/// information, and scrolling state.
mixin ParentLayout {
  /// The text baseline to use for layout calculations.
  ///
  /// Used for baseline alignment of text elements within the layout.
  LayoutTextBaseline? get textBaseline;

  /// The first child in the layout tree.
  ///
  /// Used as the starting point for layout traversals.
  ChildLayout? get firstLayoutChild;

  /// The last child in the layout tree.
  ///
  /// Used as the ending point for layout traversals.
  ChildLayout? get lastLayoutChild;

  /// The text direction for this layout.
  ///
  /// Affects how directional alignments and layout flow are interpreted.
  LayoutTextDirection get textDirection;

  /// The total size of all content within this layout.
  ///
  /// Represents the size needed to contain all children without scrolling.
  LayoutSize get contentSize;

  /// The size of the visible viewport.
  ///
  /// Represents the area available for displaying content.
  LayoutSize get viewportSize;

  /// The current horizontal scroll offset.
  ///
  /// Indicates how much the content is scrolled horizontally.
  double get scrollOffsetX;

  /// The current vertical scroll offset.
  ///
  /// Indicates how much the content is scrolled vertically.
  double get scrollOffsetY;

  /// Creates a dry layout chain starting from the first child.
  ///
  /// Returns a [ChildLayoutDryDelegate] chain for performing
  /// measurement-only layout operations.
  ChildLayout? getFirstDryLayout(LayoutHandle layoutHandle);

  /// Creates a dry layout chain starting from the last child.
  ///
  /// Returns a [ChildLayoutDryDelegate] chain in reverse order
  /// for performing measurement-only layout operations.
  ChildLayout? getLastDryLayout(LayoutHandle layoutHandle);
}

/// Abstract base class for layout algorithms.
///
/// Layout defines the interface that all layout implementations must follow.
/// Each layout algorithm (like flexbox, grid, etc.) extends this class
/// and implements the specific positioning and sizing logic.
abstract class Layout {
  /// Creates a layout algorithm instance.
  const Layout();

  /// Creates a layout handle for performing layout operations.
  ///
  /// The handle encapsulates the layout algorithm and provides
  /// methods for performing layout calculations on a parent container.
  LayoutHandle<Layout> createLayoutHandle(ParentLayout parent);
}

/// Handle for performing layout operations with a specific algorithm.
///
/// LayoutHandle manages the execution of a layout algorithm on a parent container.
/// It provides methods for layout calculation, positioning, and intrinsic size
/// computation. Each layout algorithm has its own handle implementation.
abstract class LayoutHandle<T extends Layout> {
  /// The layout algorithm this handle implements.
  final T layout;

  /// The parent container this handle is laying out.
  final ParentLayout parent;

  /// Creates a layout handle for the given layout and parent.
  LayoutHandle(this.layout, this.parent);

  /// Creates a cache for storing layout computation results.
  ///
  /// Returns a fresh cache instance for use during layout operations.
  ChildLayoutCache setupCache();

  /// Performs the layout calculation for all children.
  ///
  /// Returns the total size needed for the layout. When [dry] is true,
  /// performs measurement without modifying child positions or sizes.
  LayoutSize performLayout(LayoutConstraints constraints, [bool dry = false]);

  /// Calculates the positioning rectangle for the content within the viewport.
  ///
  /// Given the viewport size and content size, returns the rectangle
  /// that defines how the content should be positioned (for scrolling, etc.).
  LayoutRect performPositioning(
    LayoutSize viewportSize,
    LayoutSize contentSize,
  );

  /// Computes the minimum intrinsic width at the given height.
  ///
  /// Performs a dry layout to determine the smallest width the layout
  /// can reasonably have while respecting the height constraint.
  double computeMinIntrinsicWidth(double height) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: height,
      ),
      true,
    );
    return dryLayout.width;
  }

  /// Computes the maximum intrinsic width at the given height.
  ///
  /// Performs a dry layout to determine the preferred width the layout
  /// would have with unconstrained width but constrained height.
  double computeMaxIntrinsicWidth(double height) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: height,
      ),
      true,
    );
    return dryLayout.width;
  }

  /// Computes the minimum intrinsic height at the given width.
  ///
  /// Performs a dry layout to determine the smallest height the layout
  /// can reasonably have while respecting the width constraint.
  double computeMinIntrinsicHeight(double width) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: width,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      true,
    );
    return dryLayout.height;
  }

  /// Computes the maximum intrinsic height at the given width.
  ///
  /// Performs a dry layout to determine the preferred height the layout
  /// would have with unconstrained height but constrained width.
  double computeMaxIntrinsicHeight(double width) {
    LayoutSize dryLayout = performLayout(
      LayoutConstraints(
        minWidth: 0,
        maxWidth: width,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      true,
    );
    return dryLayout.height;
  }
}
