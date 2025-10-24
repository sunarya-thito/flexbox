import 'package:flexiblebox/flexiblebox_dart.dart';
import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flexiblebox/src/constraints.dart';
import 'package:flutter/widgets.dart';

// hidden from public API
// an always tight BoxConstraints with extra layout information
/// A wrapper that combines [BoxConstraints] with additional layout information.
///
/// [WrappedLayoutConstraints] implements [BoxConstraints] while providing
/// access to layout-specific data such as scroll offsets, content size,
/// and viewport information. This allows widgets that need both constraint
/// information and layout context to access all necessary data in a single object.
///
/// This class is typically used internally by the layout system and is not
/// part of the public API.
class LayoutBoxImpl with LayoutBox implements RelativePositioning {
  @override
  final Size size;
  @override
  final Offset offset;
  @override
  final double scrollX;
  @override
  final double scrollY;
  @override
  final double maxScrollX;
  @override
  final double maxScrollY;
  @override
  final Size contentSize;
  @override
  final Size viewportSize;
  @override
  final AxisDirection horizontalUserScrollDirection;
  @override
  final AxisDirection verticalUserScrollDirection;
  @override
  final OverflowBounds overflowBounds;
  @override
  final ParentRect relativeRect;

  LayoutBoxImpl({
    required this.size,
    required this.offset,
    required this.scrollX,
    required this.scrollY,
    required this.maxScrollX,
    required this.maxScrollY,
    required this.contentSize,
    required this.viewportSize,
    required this.horizontalUserScrollDirection,
    required this.verticalUserScrollDirection,
    required this.overflowBounds,
    required this.relativeRect,
  });

  @override
  int get hashCode => Object.hash(
    size,
    offset,
    scrollX,
    scrollY,
    maxScrollX,
    maxScrollY,
    contentSize,
    viewportSize,
    horizontalUserScrollDirection,
    verticalUserScrollDirection,
    overflowBounds,
    relativeRect,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LayoutBoxImpl &&
        other.size == size &&
        other.offset == offset &&
        other.scrollX == scrollX &&
        other.scrollY == scrollY &&
        other.maxScrollX == maxScrollX &&
        other.maxScrollY == maxScrollY &&
        other.contentSize == contentSize &&
        other.viewportSize == viewportSize &&
        other.horizontalUserScrollDirection == horizontalUserScrollDirection &&
        other.verticalUserScrollDirection == verticalUserScrollDirection &&
        other.overflowBounds == overflowBounds &&
        other.relativeRect == relativeRect;
  }
}

/// A mixin that provides access to layout and scrolling information for builder widgets.
///
/// LayoutBox mixin offers a comprehensive set of properties and convenience getters
/// that provide information about the current layout state, scrolling position,
/// and viewport bounds. It's used by builder variants of layout widgets like
/// [BuilderFlexItem] and [_BuilderAbsoluteItem] to access dynamic layout information.
///
/// This mixin provides both raw layout data and computed convenience properties
/// for common layout calculations, making it easier to create responsive widgets
/// that adapt to their layout context.
///
/// ## Key Properties
///
/// - [size]: The current size of the widget
/// - [offset]: The current offset position relative to the viewport
/// - [scrollX], [scrollY]: Current scroll positions
/// - [contentSize]: Total size of the scrollable content
/// - [viewportSize]: Size of the visible viewport
///
/// A mixin that provides access to layout box information and convenience methods.
///
/// LayoutBox is used by layout widgets to expose information about their current
/// layout state, including size, offset, scroll positions, and viewport bounds.
/// This information is essential for widgets that need to adapt their content
/// based on layout constraints or user interactions.
///
/// The mixin provides direct access to core layout properties like [size] and [offset],
/// as well as computed properties for scroll positions, content bounds, and viewport
/// dimensions. It supports both scrolling and non-scrolling layouts.
///
/// ## Convenience Getters
///
/// The mixin also provides convenience getters like [width], [height], [offsetX],
/// [offsetY] for easier access to common properties.
mixin LayoutBox implements RelativePositioning {
  /// The size of this layout box.
  Size get size;

  /// The offset of this layout box relative to its parent.
  Offset get offset;

  /// The horizontal offset (x-coordinate) of this layout box.
  double get offsetX => offset.dx;

  /// The vertical offset (y-coordinate) of this layout box.
  double get offsetY => offset.dy;

  /// The width of this layout box.
  double get width => size.width;

  /// The height of this layout box.
  double get height => size.height;

  /// The current horizontal scroll offset.
  double get scrollX;

  /// The current vertical scroll offset.
  double get scrollY;

  /// The maximum possible horizontal scroll offset.
  double get maxScrollX;

  /// The maximum possible vertical scroll offset.
  double get maxScrollY;

  /// The size of the content within this layout box.
  Size get contentSize;

  /// The size of the viewport for this layout box.
  Size get viewportSize;

  /// The bounding rectangle of this child within its parent.
  Rect get childBounds => offset & size;

  /// The bounding rectangle of the viewport.
  Rect get viewportBounds => Offset.zero & viewportSize;

  /// The bounding rectangle of the content, adjusted for scroll position.
  Rect get contentBounds => Offset(-scrollX, -scrollY) & contentSize;

  /// The width of the content.
  double get contentWidth => contentSize.width;

  /// The height of the content.
  double get contentHeight => contentSize.height;

  /// The width of the viewport.
  double get viewportWidth => viewportSize.width;

  /// The height of the viewport.
  double get viewportHeight => viewportSize.height;

  /// The direction of horizontal user scrolling.
  AxisDirection get horizontalUserScrollDirection;

  /// The direction of vertical user scrolling.
  AxisDirection get verticalUserScrollDirection;

  /// The bounds of content that overflows the viewport.
  OverflowBounds get overflowBounds;
}

typedef LayoutBoxWidgetBuilder =
    Widget Function(
      BuildContext context,
      LayoutBox box,
    );

/// A builder widget that provides access to layout box information.
///
/// [LayoutBoxBuilder] allows widgets to access the current layout context
/// including viewport size, scroll offsets, and content bounds. It wraps
/// Flutter's [LayoutBuilder] but provides a [LayoutBox] object instead of
/// basic [BoxConstraints], giving access to additional layout-specific data.
///
/// This widget must be used within a layout container that provides
/// [LayoutBox] constraints, such as [LayoutBoxWidget] or [FlexBox].
class LayoutBoxBuilder extends StatelessWidget {
  /// The builder function that constructs the widget tree.
  ///
  /// This function is called with the current [BuildContext] and a [LayoutBox]
  /// instance providing access to layout information.
  final LayoutBoxWidgetBuilder builder;

  /// Creates a LayoutBoxBuilder widget.
  ///
  /// The [builder] parameter is required and specifies the function that will
  /// be called to build the widget tree with access to layout box information.
  const LayoutBoxBuilder({super.key, required this.builder});

  /// Builds the widget tree using the provided builder function.
  ///
  /// This method wraps Flutter's [LayoutBuilder] and asserts that the constraints
  /// are of type [LayoutBox]. It then calls the [builder] function with the
  /// [LayoutBox] instance.
  ///
  /// Returns the widget constructed by the [builder] function.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints is BoxConstraintsWithData<LayoutBox>,
          'LayoutBoxBuilder can only be used inside a LayoutBox, '
          'but got ${constraints.runtimeType}.',
        );
        final box = (constraints as BoxConstraintsWithData<LayoutBox>).data;
        return builder(context, box);
      },
    );
  }
}
