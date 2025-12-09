import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flexiblebox/src/scrollable.dart';
import 'package:flexiblebox/src/widgets/builder.dart';
import 'package:flexiblebox/src/widgets/fallback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// An interface for widgets that participate in custom layout algorithms.
///
/// LayoutItem defines the common properties that layout widgets use to control
/// their positioning, sizing, and behavior within a layout container. It provides
/// a standardized way for layout algorithms to access and manipulate widget
/// properties during the layout process.
///
/// This interface is implemented by widgets like [FlexItem] and [AbsoluteItem]
/// that need to communicate layout constraints and positioning information to
/// their parent layout containers.
abstract class LayoutItem implements Widget {
  /// The paint order for this item, controlling drawing order when overlapping.
  /// Lower values are painted first (behind), higher values are painted last (on top).
  int? get paintOrder;

  /// The preferred width of this item.
  SizeUnit? get width;

  /// The preferred height of this item.
  SizeUnit? get height;

  /// The minimum width constraint for this item.
  SizeUnit? get minWidth;

  /// The maximum width constraint for this item.
  SizeUnit? get maxWidth;

  /// The minimum height constraint for this item.
  SizeUnit? get minHeight;

  /// The maximum height constraint for this item.
  SizeUnit? get maxHeight;

  /// The aspect ratio constraint (width/height) for this item.
  double? get aspectRatio;

  /// The offset from the top edge of the parent container.
  PositionUnit? get top;

  /// The offset from the left edge of the parent container.
  PositionUnit? get left;

  /// The offset from the bottom edge of the parent container.
  PositionUnit? get bottom;

  /// The offset from the right edge of the parent container.
  PositionUnit? get right;
}

/// An interface for widgets that support absolute positioning within a layout container.
///
/// AbsoluteItem defines the contract for widgets that can be positioned absolutely
/// within their parent layout container. Absolute positioning removes the widget
/// from the normal document flow and places it at specific coordinates relative
/// to the parent's bounds.
///
/// This interface provides factory constructors for creating absolute positioned
/// widgets, either with a direct child widget or with a builder function that
/// receives layout information.
abstract class AbsoluteItem implements LayoutItem {
  /// Creates an absolutely positioned item with a direct child widget.
  ///
  /// The [child] parameter is required and specifies the widget to be positioned
  /// absolutely within its parent container.
  ///
  /// The [top], [left], [bottom], [right] parameters specify the position offsets
  /// from the parent's edges. You can use any combination of these to position
  /// the item. If both [top] and [bottom] are specified, the height is determined
  /// by the difference. The same applies to [left] and [right] for width.
  ///
  /// The [width] and [height] parameters specify the explicit size of the item.
  /// If null, the size is determined by content or positioning constraints.
  ///
  /// The [minWidth], [maxWidth], [minHeight], [maxHeight] parameters set size
  /// constraints for the item.
  ///
  /// The [aspectRatio] parameter maintains the width/height ratio if specified.
  ///
  /// The [paintOrder] parameter controls the painting order when items overlap.
  /// Lower values are painted first (behind), higher values are painted last (on top).
  ///
  /// ## Example
  ///
  /// ```dart
  /// AbsoluteItem(
  ///   top: PositionUnit.fixed(20),
  ///   left: PositionUnit.fixed(30),
  ///   width: SizeUnit.fixed(100),
  ///   height: SizeUnit.fixed(50),
  ///   child: Container(color: Colors.red),
  /// )
  /// ```
  const factory AbsoluteItem({
    Key? key,
    int? paintOrder,
    SizeUnit? width,
    SizeUnit? height,
    SizeUnit? minWidth,
    SizeUnit? maxWidth,
    SizeUnit? minHeight,
    SizeUnit? maxHeight,
    PositionUnit? top,
    PositionUnit? left,
    PositionUnit? bottom,
    PositionUnit? right,
    double? aspectRatio,
    required Widget child,
  }) = _DirectAbsoluteItem;

  /// Creates an absolutely positioned item with a builder function.
  ///
  /// The [builder] parameter is required and provides a function that constructs
  /// the child widget dynamically. The builder receives the [BuildContext] and
  /// a [LayoutBox] containing layout information.
  ///
  /// The [top], [left], [bottom], [right] parameters specify the position offsets
  /// from the parent's edges. You can use any combination of these to position
  /// the item. If both [top] and [bottom] are specified, the height is determined
  /// by the difference. The same applies to [left] and [right] for width.
  ///
  /// The [width] and [height] parameters specify the explicit size of the item.
  /// If null, the size is determined by content or positioning constraints.
  ///
  /// The [minWidth], [maxWidth], [minHeight], [maxHeight] parameters set size
  /// constraints for the item.
  ///
  /// The [aspectRatio] parameter maintains the width/height ratio if specified.
  ///
  /// The [paintOrder] parameter controls the painting order when items overlap.
  /// Lower values are painted first (behind), higher values are painted last (on top).
  ///
  /// ## Example
  ///
  /// ```dart
  /// AbsoluteItem.builder(
  ///   top: PositionUnit.fixed(20),
  ///   left: PositionUnit.fixed(30),
  ///   width: SizeUnit.fixed(100),
  ///   height: SizeUnit.fixed(50),
  ///   builder: (context, layoutBox) {
  ///     return Container(
  ///       color: Colors.red,
  ///       child: Text('Position: ${layoutBox.offset}'),
  ///     );
  ///   },
  /// )
  /// ```
  const factory AbsoluteItem.builder({
    Key? key,
    int? paintOrder,
    SizeUnit? width,
    SizeUnit? height,
    SizeUnit? minWidth,
    SizeUnit? maxWidth,
    SizeUnit? minHeight,
    SizeUnit? maxHeight,
    PositionUnit? top,
    PositionUnit? left,
    PositionUnit? bottom,
    PositionUnit? right,
    double? aspectRatio,
    required Widget Function(BuildContext context, LayoutBox box) builder,
  }) = _BuilderAbsoluteItem;
}

/// A widget that positions its child absolutely within a layout container.
///
/// AbsoluteItem allows you to position a child widget at specific coordinates
/// relative to its parent's bounds, similar to CSS absolute positioning.
/// The child is removed from the normal document flow and positioned using
/// the [top], [left], [bottom], and [right] properties.
///
/// ## Usage
///
/// ```dart
/// LayoutBoxWidget(
///   children: [
///     AbsoluteItem(
///       top: PositionUnit.fixed(20),
///       left: PositionUnit.fixed(30),
///       width: SizeUnit.fixed(100),
///       height: SizeUnit.fixed(50),
///       child: Container(color: Colors.red),
///     ),
///   ],
/// )
/// ```
///
/// ## Positioning
///
/// The positioning properties work similarly to CSS:
/// - [top]: Distance from the parent's top edge
/// - [left]: Distance from the parent's left edge
/// - [bottom]: Distance from the parent's bottom edge
/// - [right]: Distance from the parent's right edge
///
/// You can use any combination of these properties. If both [top] and [bottom]
/// are specified, the height is determined by the difference. The same applies
/// to [left] and [right] for width.
///
/// ## Sizing
///
/// - [width] and [height]: Explicit dimensions
/// - [minWidth], [maxWidth], [minHeight], [maxHeight]: Size constraints
/// - [aspectRatio]: Maintains width/height ratio
///
/// ## Paint Order
///
/// The [paintOrder] property controls the drawing order when multiple
/// absolutely positioned items overlap. Lower values are painted first.
class _DirectAbsoluteItem extends ParentDataWidget<LayoutBoxParentData>
    implements AbsoluteItem {
  /// The paint order for this absolutely positioned item.
  ///
  /// Items with lower paint order values are drawn behind items with higher values.
  /// Useful for controlling layering when items overlap.
  @override
  final int? paintOrder;

  /// The width of the absolutely positioned item.
  ///
  /// If null, the width is determined by the content or positioning constraints.
  @override
  final SizeUnit? width;

  /// The height of the absolutely positioned item.
  ///
  /// If null, the height is determined by the content or positioning constraints.
  @override
  final SizeUnit? height;

  /// The minimum width constraint for this item.
  ///
  /// The item will not shrink below this width, even if positioning would suggest otherwise.
  @override
  final SizeUnit? minWidth;

  /// The maximum width constraint for this item.
  ///
  /// The item will not grow beyond this width, even if positioning would allow it.
  @override
  final SizeUnit? maxWidth;

  /// The minimum height constraint for this item.
  ///
  /// The item will not shrink below this height, even if positioning would suggest otherwise.
  @override
  final SizeUnit? minHeight;

  /// The maximum height constraint for this item.
  ///
  /// The item will not grow beyond this height, even if positioning would allow it.
  @override
  final SizeUnit? maxHeight;

  /// The offset from the top edge of the parent container.
  ///
  /// Positions the item relative to the parent's top boundary.
  @override
  final PositionUnit? top;

  /// The offset from the left edge of the parent container.
  ///
  /// Positions the item relative to the parent's left boundary.
  @override
  final PositionUnit? left;

  /// The offset from the bottom edge of the parent container.
  ///
  /// Positions the item relative to the parent's bottom boundary.
  @override
  final PositionUnit? bottom;

  /// The offset from the right edge of the parent container.
  ///
  /// Positions the item relative to the parent's right boundary.
  @override
  final PositionUnit? right;

  /// The aspect ratio constraint (width/height) for this item.
  ///
  /// When specified, the item's dimensions will be adjusted to maintain
  /// this aspect ratio, potentially overriding explicit width/height values.
  @override
  final double? aspectRatio;

  final bool needLayoutBox;

  final Key? layoutKey;

  /// Creates an absolutely positioned item with the specified properties.
  ///
  /// The [child] parameter is required and specifies the widget to be positioned.
  /// All positioning and sizing properties are optional and provide fine-grained
  /// control over how this item is placed within its parent container.
  ///
  /// ## Example
  ///
  /// ```dart
  /// AbsoluteItem(
  ///   top: PositionUnit.fixed(10),
  ///   left: PositionUnit.fixed(20),
  ///   width: SizeUnit.fixed(200),
  ///   height: SizeUnit.fixed(100),
  ///   paintOrder: 1,
  ///   child: Text('Absolutely positioned'),
  /// )
  /// ```
  ///
  /// Creates a DirectAbsoluteItem with the specified properties.
  ///
  /// The [child] parameter is required and specifies the widget to be positioned
  /// absolutely within its parent container.
  ///
  /// The [paintOrder] parameter controls the painting order when items overlap.
  /// Lower values are painted first.
  ///
  /// The [width] and [height] parameters specify the explicit size of the item.
  /// If null, the size is determined by content or positioning constraints.
  ///
  /// The [minWidth], [maxWidth], [minHeight], [maxHeight] parameters set size
  /// constraints for the item.
  ///
  /// The [top], [left], [bottom], [right] parameters specify the position offsets
  /// from the parent's edges.
  ///
  /// The [aspectRatio] parameter maintains the width/height ratio if specified.
  ///
  /// The [needLayoutBox] parameter determines if the child needs access to
  /// layout box information.
  const _DirectAbsoluteItem({
    super.key,
    this.paintOrder,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.top,
    this.left,
    this.bottom,
    this.right,
    this.aspectRatio,
    this.needLayoutBox = false,
    this.layoutKey,
    required super.child,
  });

  /// Applies the absolute positioning configuration to the child's parent data.
  ///
  /// This method is called by the Flutter framework when the widget is inserted
  /// into the tree. It creates a [LayoutData] object with [LayoutBehavior.absolute]
  /// and attaches it to the child's [ParentData].
  ///
  /// The layout data includes positioning offsets, sizing constraints, and
  /// paint order that the layout algorithm will use for absolute positioning.
  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is LayoutBoxParentData);
    final parentData = renderObject.parentData as LayoutBoxParentData;
    final parent = renderObject.parent as RenderLayoutBox;
    parentData.debugKey = key;
    var width = this.width;
    var height = this.height;
    if (width == null) {
      if ((left == null && right != null) || (left != null && right == null)) {
        width = SizeUnit.fitContent;
      }
    }
    if (height == null) {
      if ((top == null && bottom != null) || (top != null && bottom == null)) {
        height = SizeUnit.fitContent;
      }
    }
    final newLayoutData = LayoutData(
      behavior: LayoutBehavior.absolute,
      position: PositionType.none,
      paintOrder: paintOrder,
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      aspectRatio: aspectRatio,
      flexGrow: 0.0,
      flexShrink: 0.0,
      key: layoutKey ?? key,
    );
    if (parentData.layoutData != newLayoutData) {
      parentData.layoutData = newLayoutData;
      parent.markNeedsLayout();
    }
    if (parentData.needLayoutBox != needLayoutBox) {
      parentData.needLayoutBox = needLayoutBox;
      parent.markNeedsLayout();
    }
  }

  /// The typical ancestor widget class for this widget.
  ///
  /// Used by Flutter's debugging tools to provide better error messages
  /// when this widget is used incorrectly (not within a LayoutBox).
  @override
  Type get debugTypicalAncestorWidgetClass => LayoutBoxWidget;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('paintOrder', paintOrder));
    properties.add(DiagnosticsProperty<SizeUnit>('width', width));
    properties.add(DiagnosticsProperty<SizeUnit>('height', height));
    properties.add(DiagnosticsProperty<SizeUnit>('minWidth', minWidth));
    properties.add(DiagnosticsProperty<SizeUnit>('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty<SizeUnit>('minHeight', minHeight));
    properties.add(DiagnosticsProperty<SizeUnit>('maxHeight', maxHeight));
    properties.add(DiagnosticsProperty<PositionUnit>('top', top));
    properties.add(DiagnosticsProperty<PositionUnit>('left', left));
    properties.add(DiagnosticsProperty<PositionUnit>('bottom', bottom));
    properties.add(DiagnosticsProperty<PositionUnit>('right', right));
    properties.add(DoubleProperty('aspectRatio', aspectRatio));
    properties.add(DiagnosticsProperty<Key>('layoutKey', layoutKey));
  }
}

/// A builder variant of [AbsoluteItem] that allows dynamic child construction.
///
/// BuilderAbsoluteItem provides the same absolute positioning capabilities as
/// [_DirectAbsoluteItem], but instead of taking a pre-built child widget, it
/// accepts a builder function that receives layout information at build time.
///
/// This is useful when the positioned content needs access to layout bounds,
/// scroll positions, or other dynamic layout state that may change during
/// the widget's lifetime.
///
/// ## Usage
///
/// ```dart
/// BuilderAbsoluteItem(
///   top: PositionUnit.fixed(20),
///   left: PositionUnit.fixed(30),
///   width: SizeUnit.fixed(100),
///   height: SizeUnit.fixed(50),
///   builder: (context, layoutBox) {
///     return Container(
///       color: Colors.red,
///       child: Text('Position: ${layoutBox.offset}'),
///     );
///   },
/// )
/// ```
class _BuilderAbsoluteItem extends StatelessWidget implements AbsoluteItem {
  @override
  final int? paintOrder;
  @override
  final SizeUnit? width;
  @override
  final SizeUnit? height;
  @override
  final SizeUnit? minWidth;
  @override
  final SizeUnit? maxWidth;
  @override
  final SizeUnit? minHeight;
  @override
  final SizeUnit? maxHeight;
  @override
  final PositionUnit? top;
  @override
  final PositionUnit? left;
  @override
  final PositionUnit? bottom;
  @override
  final PositionUnit? right;
  @override
  final double? aspectRatio;

  final Widget Function(BuildContext context, LayoutBox box) builder;

  /// Creates an absolutely positioned item with a builder function.
  ///
  /// The [builder] parameter is required and provides a function that constructs
  /// the child widget dynamically. All positioning and sizing properties are
  /// optional and provide fine-grained control over how this item is placed
  /// within its parent container.
  ///
  /// ## Example
  ///
  /// ```dart
  /// BuilderAbsoluteItem(
  ///   top: PositionUnit.fixed(10),
  ///   left: PositionUnit.fixed(20),
  ///   width: SizeUnit.fixed(200),
  ///   height: SizeUnit.fixed(100),
  ///   builder: (context, layoutBox) {
  ///     return Text('Position: ${layoutBox.offset}');
  ///   },
  /// )
  /// ```
  const _BuilderAbsoluteItem({
    super.key,
    this.paintOrder,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.top,
    this.left,
    this.bottom,
    this.right,
    this.aspectRatio,
    required this.builder,
  });

  /// Builds the widget tree for this builder absolute item.
  ///
  /// This method creates a [_DirectAbsoluteItem] widget with the same properties,
  /// but uses the [builder] function to construct the child widget dynamically.
  /// The builder is called with the current [BuildContext] and a [LayoutBox]
  /// providing access to layout information.
  ///
  /// Returns the constructed [_DirectAbsoluteItem] widget.
  @override
  Widget build(BuildContext context) {
    return _DirectAbsoluteItem(
      paintOrder: paintOrder,
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      aspectRatio: aspectRatio,
      needLayoutBox: true,
      layoutKey: key,
      child: FallbackWidget(child: LayoutBoxBuilder(builder: builder)),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<dynamic>.has('builder', builder));
    properties.add(IntProperty('paintOrder', paintOrder));
    properties.add(DiagnosticsProperty<SizeUnit>('width', width));
    properties.add(DiagnosticsProperty<SizeUnit>('height', height));
    properties.add(DiagnosticsProperty<SizeUnit>('minWidth', minWidth));
    properties.add(DiagnosticsProperty<SizeUnit>('maxWidth', maxWidth));
    properties.add(DiagnosticsProperty<SizeUnit>('minHeight', minHeight));
    properties.add(DiagnosticsProperty<SizeUnit>('maxHeight', maxHeight));
    properties.add(DiagnosticsProperty<PositionUnit>('top', top));
    properties.add(DiagnosticsProperty<PositionUnit>('left', left));
    properties.add(DiagnosticsProperty<PositionUnit>('bottom', bottom));
    properties.add(DiagnosticsProperty<PositionUnit>('right', right));
    properties.add(DoubleProperty('aspectRatio', aspectRatio));
  }
}

/// A viewport widget that manages the rendering of layout children with scrolling support.
///
/// LayoutBoxViewport is responsible for creating and managing a [RenderLayoutBox]
/// that handles the actual layout calculations and rendering. It provides the
/// connection between the widget layer and the render object layer, managing
/// scrolling offsets, text direction, and layout configuration.
///
/// This widget is typically not used directly but is created internally by
/// [LayoutBoxWidget] to handle the scrolling and viewport logic.
class LayoutBoxViewport extends MultiChildRenderObjectWidget {
  /// The text direction for resolving directional layout properties.
  ///
  /// Affects how start/end alignments are interpreted and how scrolling
  /// directions are determined.
  final TextDirection textDirection;

  /// Whether to reverse the paint order of children.
  ///
  /// When true, children are painted in reverse order, affecting visual layering.
  final bool reversePaint;

  /// The primary scrolling axis for this viewport.
  ///
  /// Determines which direction is considered the "main" scroll direction
  /// for certain layout calculations and optimizations.
  final Axis mainScrollDirection;

  /// The horizontal scroll offset for this viewport.
  ///
  /// Controls the horizontal scroll position and provides scrolling functionality.
  final ViewportOffset horizontal;

  /// The vertical scroll offset for this viewport.
  ///
  /// Controls the vertical scroll position and provides scrolling functionality.
  final ViewportOffset vertical;

  /// The direction of the horizontal axis.
  ///
  /// Determines whether horizontal scrolling moves left/right or right/left.
  final AxisDirection horizontalAxisDirection;

  /// The direction of the vertical axis.
  ///
  /// Determines whether vertical scrolling moves up/down or down/up.
  final AxisDirection verticalAxisDirection;

  /// The layout algorithm to use for positioning children.
  ///
  /// Defines how children are measured, positioned, and sized within the viewport.
  final Layout layout;

  /// How to handle content that exceeds horizontal bounds.
  ///
  /// Controls clipping, scrolling, or visibility of overflowing horizontal content.
  final LayoutOverflow horizontalOverflow;

  /// How to handle content that exceeds vertical bounds.
  ///
  /// Controls clipping, scrolling, or visibility of overflowing vertical content.
  final LayoutOverflow verticalOverflow;

  /// The text baseline to use for text alignment within the layout.
  ///
  /// Used when children contain text that should be aligned by baseline.
  final TextBaseline? textBaseline;

  /// The border radius applied to the viewport's background and clipping.
  ///
  /// Creates rounded corners that affect both visual appearance and content clipping.
  final BorderRadius borderRadius;

  /// How to clip content that extends beyond the viewport bounds.
  ///
  /// Controls the visual clipping behavior for performance and appearance.
  final Clip clipBehavior;

  /// Creates a layout viewport with the specified configuration.
  ///
  /// This constructor is typically called internally by [LayoutBoxWidget] and
  /// requires all parameters to be properly configured for the layout to work.
  ///
  /// The [children] parameter specifies the widgets to be laid out within
  /// this viewport. The layout algorithm defined by [layout] will position them.
  const LayoutBoxViewport({
    super.key,
    required this.textDirection,
    required this.reversePaint,
    required this.mainScrollDirection,
    required this.horizontal,
    required this.vertical,
    required this.horizontalAxisDirection,
    required this.verticalAxisDirection,
    required this.layout,
    required this.horizontalOverflow,
    required this.verticalOverflow,
    required this.textBaseline,
    required this.borderRadius,
    required this.clipBehavior,
    required super.children,
  });

  /// Creates the render object that will perform the actual layout and painting.
  ///
  /// Returns a [RenderLayoutBox] configured with all the viewport properties.
  /// This render object handles the complex layout calculations and rendering logic.
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayoutBox(
      layoutTextDirection: textDirection,
      reversePaint: reversePaint,
      mainScrollDirection: mainScrollDirection,
      horizontal: horizontal,
      vertical: vertical,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalAxisDirection: verticalAxisDirection,
      boxLayout: layout,
      horizontalOverflow: horizontalOverflow,
      verticalOverflow: verticalOverflow,
      layoutTextBaseline: textBaseline,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
    );
  }

  /// Updates the render object when widget properties change.
  ///
  /// This method efficiently updates only the properties that have changed,
  /// minimizing unnecessary layout or paint operations. It tracks whether
  /// a full layout or just a repaint is needed based on which properties changed.
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderLayoutBox renderObject,
  ) {
    bool needsPaint = false;
    bool needsLayout = false;
    if (renderObject.layoutTextDirection != textDirection) {
      renderObject.layoutTextDirection = textDirection;
      needsLayout = true;
    }
    if (renderObject.reversePaint != reversePaint) {
      renderObject.reversePaint = reversePaint;
      needsPaint = true;
    }
    if (renderObject.mainScrollDirection != mainScrollDirection) {
      renderObject.mainScrollDirection = mainScrollDirection;
      needsLayout = true;
    }
    if (renderObject.horizontal != horizontal) {
      renderObject.updateHorizontalOffset(horizontal);
      needsLayout = true;
    }
    if (renderObject.vertical != vertical) {
      renderObject.updateVerticalOffset(vertical);
      needsLayout = true;
    }
    if (renderObject.horizontalAxisDirection != horizontalAxisDirection) {
      renderObject.horizontalAxisDirection = horizontalAxisDirection;
      needsLayout = true;
    }
    if (renderObject.verticalAxisDirection != verticalAxisDirection) {
      renderObject.verticalAxisDirection = verticalAxisDirection;
      needsLayout = true;
    }
    if (renderObject.boxLayout != layout) {
      renderObject.boxLayout = layout;
      needsLayout = true;
    }
    if (renderObject.horizontalOverflow != horizontalOverflow) {
      renderObject.horizontalOverflow = horizontalOverflow;
      needsPaint = true;
    }
    if (renderObject.verticalOverflow != verticalOverflow) {
      renderObject.verticalOverflow = verticalOverflow;
      needsPaint = true;
    }
    if (renderObject.layoutTextBaseline != textBaseline) {
      renderObject.layoutTextBaseline = textBaseline;
      needsLayout = true;
    }
    if (renderObject.borderRadius != borderRadius) {
      renderObject.borderRadius = borderRadius;
      needsPaint = true;
    }
    if (renderObject.clipBehavior != clipBehavior) {
      renderObject.clipBehavior = clipBehavior;
      needsPaint = true;
    }
    if (needsLayout) {
      renderObject.markNeedsLayout();
    } else if (needsPaint) {
      renderObject.markNeedsPaint();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection));
    properties.add(DiagnosticsProperty<bool>('reversePaint', reversePaint));
    properties.add(
      EnumProperty<Axis>('mainScrollDirection', mainScrollDirection),
    );
    properties.add(
      DiagnosticsProperty<ViewportOffset>('horizontal', horizontal),
    );
    properties.add(DiagnosticsProperty<ViewportOffset>('vertical', vertical));
    properties.add(
      EnumProperty<AxisDirection>(
        'horizontalAxisDirection',
        horizontalAxisDirection,
      ),
    );
    properties.add(
      EnumProperty<AxisDirection>(
        'verticalAxisDirection',
        verticalAxisDirection,
      ),
    );
    properties.add(DiagnosticsProperty<Layout>('layout', layout));
    properties.add(
      DiagnosticsProperty<LayoutOverflow>(
        'horizontalOverflow',
        horizontalOverflow,
      ),
    );
    properties.add(
      DiagnosticsProperty<LayoutOverflow>('verticalOverflow', verticalOverflow),
    );
    properties.add(
      DiagnosticsProperty<TextBaseline>('textBaseline', textBaseline),
    );
    properties.add(
      DiagnosticsProperty<BorderRadiusGeometry>('borderRadius', borderRadius),
    );
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior));
  }
}

/// A flexible layout container that supports scrolling and custom layout algorithms.
///
/// LayoutBox is a fundamental building block for creating custom layouts in Flutter.
/// It provides scrolling capabilities, overflow handling, and integrates with custom
/// layout algorithms through the [Layout] interface.
///
/// ## Basic Usage
///
/// ```dart
/// LayoutBoxWidget(
///   layout: FlexLayout(
///     direction: FlexDirection.row,
///     alignItems: BoxAlignmentGeometry.center,
///   ),
///   children: [
///     Text('Item 1'),
///     Text('Item 2'),
///   ],
/// )
/// ```
///
/// ## Scrolling
///
/// LayoutBox automatically provides scrolling when content overflows:
/// - [horizontalOverflow] and [verticalOverflow] control scroll behavior
/// - [horizontalController] and [verticalController] allow programmatic scrolling
/// - [diagonalDragBehavior] controls how diagonal gestures are interpreted
///
/// ## Layout Algorithms
///
/// The [layout] property defines how children are positioned and sized.
/// Built-in layouts include [FlexLayout] for flexbox behavior, but custom
/// layouts can be implemented by extending the [Layout] class.
///
/// ## Text Direction
///
/// The [textDirection] property affects directional alignments and scrolling.
/// If null, it uses the ambient [Directionality] from the widget tree.
class LayoutBoxWidget extends StatefulWidget {
  /// The text direction for resolving directional layout properties.
  ///
  /// If null, uses the ambient [Directionality] from the widget tree.
  /// Affects how start/end alignments are interpreted.
  final TextDirection? textDirection;

  /// Whether to reverse the paint order of children.
  ///
  /// When true, children are painted in reverse order, affecting visual layering.
  /// Useful for certain animation effects or controlling element stacking.
  final bool reversePaint;

  /// The layout algorithm to use for positioning and sizing children.
  ///
  /// Defines the rules for how children are measured, positioned, and constrained.
  /// Common implementations include [FlexLayout] for flexbox behavior.
  final Layout layout;

  /// Controller for vertical scrolling.
  ///
  /// Allows programmatic control of vertical scroll position and listening
  /// to scroll events. Only effective when [verticalOverflow] enables scrolling.
  final ScrollController? verticalController;

  /// Controller for horizontal scrolling.
  ///
  /// Allows programmatic control of horizontal scroll position and listening
  /// to scroll events. Only effective when [horizontalOverflow] enables scrolling.
  final ScrollController? horizontalController;

  /// How to handle content that exceeds horizontal bounds.
  ///
  /// - [LayoutOverflow.hidden]: Clip overflowing content
  /// - [LayoutOverflow.scroll]: Add horizontal scrollbar
  /// - [LayoutOverflow.visible]: Allow content to extend beyond bounds
  final LayoutOverflow horizontalOverflow;

  /// How to handle content that exceeds vertical bounds.
  ///
  /// - [LayoutOverflow.hidden]: Clip overflowing content
  /// - [LayoutOverflow.scroll]: Add vertical scrollbar
  /// - [LayoutOverflow.visible]: Allow content to extend beyond bounds
  final LayoutOverflow verticalOverflow;

  /// Controls how diagonal drag gestures are interpreted.
  ///
  /// Determines whether diagonal drags should be treated as horizontal,
  /// vertical, or both directions simultaneously.
  final DiagonalDragBehavior diagonalDragBehavior;

  /// The primary scrolling axis for layout optimizations.
  ///
  /// Affects certain layout calculations and scroll behavior optimizations.
  /// Defaults to [Axis.vertical].
  final Axis mainScrollDirection;

  /// The list of child widgets to layout.
  ///
  /// Children can be regular widgets or layout-specific widgets like
  /// [FlexItem] or [AbsoluteItem] depending on the layout algorithm used.
  final List<Widget> children;

  /// The text baseline to use for text alignment.
  ///
  /// Used when children contain text that should be aligned by baseline
  /// rather than geometric bounds.
  final TextBaseline? textBaseline;

  /// The border radius applied to the container's background and clipping.
  ///
  /// Creates rounded corners that affect both visual appearance and
  /// content clipping behavior.
  final BorderRadiusGeometry? borderRadius;

  /// How to clip content that extends beyond the container bounds.
  ///
  /// Controls the visual clipping behavior. [Clip.hardEdge] provides
  /// the best performance but may show sharp edges.
  final Clip clipBehavior;

  /// Whether to reverse the horizontal scroll direction.
  ///
  /// When true, horizontal scrolling is reversed: scrolling right moves content
  /// left, and vice versa. This can be useful for right-to-left layouts or
  /// when implementing custom scroll behaviors.
  ///
  /// Defaults to false for standard left-to-right scrolling.
  final bool reverseHorizontalScroll;

  /// Whether to reverse the vertical scroll direction.
  ///
  /// When true, vertical scrolling is reversed: scrolling down moves content
  /// up, and vice versa. This can be useful for implementing custom scroll
  /// behaviors or inverted lists.
  ///
  /// Defaults to false for standard top-to-bottom scrolling.
  final bool reverseVerticalScroll;

  /// Creates a layout container with the specified properties.
  ///
  /// The [layout] and [children] parameters are required. The layout defines
  /// how children are positioned, while children specifies the widgets to arrange.
  ///
  /// ## Example
  ///
  /// ```dart
  /// LayoutBoxWidget(
  ///   layout: FlexLayout(direction: FlexDirection.row),
  ///   horizontalOverflow: LayoutOverflow.scroll,
  ///   verticalOverflow: LayoutOverflow.hidden,
  ///   children: [Text('Child 1'), Text('Child 2')],
  /// )
  /// ```
  ///
  /// Most other parameters have sensible defaults and can be customized
  /// based on specific layout requirements.
  const LayoutBoxWidget({
    super.key,
    this.textDirection,
    this.reversePaint = false,
    this.horizontalOverflow = LayoutOverflow.visible,
    this.verticalOverflow = LayoutOverflow.visible,
    this.horizontalController,
    this.verticalController,
    this.diagonalDragBehavior = DiagonalDragBehavior.free,
    this.mainScrollDirection = Axis.vertical,
    this.textBaseline,
    this.borderRadius,
    this.clipBehavior = Clip.hardEdge,
    this.reverseHorizontalScroll = false,
    this.reverseVerticalScroll = false,
    required this.layout,
    required this.children,
  });

  @override
  State<LayoutBoxWidget> createState() => _LayoutBoxWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<TextDirection>(
        'textDirection',
        textDirection,
        defaultValue: null,
      ),
    );
    properties.add(DiagnosticsProperty<bool>('reversePaint', reversePaint));
    properties.add(DiagnosticsProperty<Layout>('layout', layout));
    properties.add(
      DiagnosticsProperty<ScrollController>(
        'verticalController',
        verticalController,
      ),
    );
    properties.add(
      DiagnosticsProperty<ScrollController>(
        'horizontalController',
        horizontalController,
      ),
    );
    properties.add(
      DiagnosticsProperty<LayoutOverflow>(
        'horizontalOverflow',
        horizontalOverflow,
      ),
    );
    properties.add(
      DiagnosticsProperty<LayoutOverflow>('verticalOverflow', verticalOverflow),
    );
    properties.add(
      DiagnosticsProperty<DiagonalDragBehavior>(
        'diagonalDragBehavior',
        diagonalDragBehavior,
      ),
    );
    properties.add(
      EnumProperty<Axis>('mainScrollDirection', mainScrollDirection),
    );
    properties.add(
      DiagnosticsProperty<TextBaseline>('textBaseline', textBaseline),
    );
    properties.add(
      DiagnosticsProperty<BorderRadiusGeometry>('borderRadius', borderRadius),
    );
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior));
    properties.add(
      DiagnosticsProperty<bool>(
        'reverseHorizontalScroll',
        reverseHorizontalScroll,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'reverseVerticalScroll',
        reverseVerticalScroll,
      ),
    );
  }
}

class _LayoutBoxWidgetState extends State<LayoutBoxWidget> {
  @override
  Widget build(BuildContext context) {
    final textDirection =
        widget.textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final horizontalDetails = ScrollableDetails.horizontal(
      controller: widget.horizontalController,
      reverse: widget.reverseHorizontalScroll,
      physics: !widget.horizontalOverflow.scrollable
          ? const NeverScrollableScrollPhysics()
          : null,
    );
    final verticalDetails = ScrollableDetails.vertical(
      controller: widget.verticalController,
      reverse: widget.reverseVerticalScroll,
      physics: !widget.verticalOverflow.scrollable
          ? const NeverScrollableScrollPhysics()
          : null,
    );
    final resolvedBorderRadius =
        widget.borderRadius?.resolve(textDirection) ?? BorderRadius.zero;
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        return false; // continue to propagate
      },
      child: ScrollableClient(
        diagonalDragBehavior: widget.diagonalDragBehavior,
        horizontalDetails: horizontalDetails,
        verticalDetails: verticalDetails,
        builder: (context, verticalPosition, horizontalPosition) {
          return LayoutBoxViewport(
            textDirection: textDirection,
            reversePaint: widget.reversePaint,
            mainScrollDirection: widget.mainScrollDirection,
            horizontal: horizontalPosition,
            vertical: verticalPosition,
            horizontalAxisDirection: horizontalDetails.direction,
            verticalAxisDirection: verticalDetails.direction,
            layout: widget.layout,
            horizontalOverflow: widget.horizontalOverflow,
            verticalOverflow: widget.verticalOverflow,
            textBaseline: widget.textBaseline,
            borderRadius: resolvedBorderRadius,
            clipBehavior: widget.clipBehavior,
            children: widget.children,
          );
        },
      ),
    );
  }
}
