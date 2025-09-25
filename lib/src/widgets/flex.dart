import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flexiblebox/src/layout/flex.dart';
import 'package:flexiblebox/src/rendering.dart';
import 'package:flexiblebox/src/widgets/widget.dart';
import 'package:flutter/widgets.dart';

/// A widget that configures flex properties for an individual child within a [FlexBox].
///
/// [FlexItem] is used to wrap children of a [FlexBox] to specify how each child
/// should behave within the flex layout. It provides control over sizing, positioning,
/// flex behavior, and alignment for each individual item.
///
/// This widget works by attaching [LayoutData] to the child's [ParentData], which
/// the flex layout algorithm uses to determine how to size and position each child.
///
/// Example usage:
/// ```dart
/// FlexBox(
///   direction: FlexDirection.row,
///   children: [
///     FlexItem(
///       flexGrow: 1.0,
///       child: Container(color: Colors.red),
///     ),
///     FlexItem(
///       width: SizeUnit.fixed(100),
///       child: Container(color: Colors.blue),
///     ),
///   ],
/// )
/// ```
class FlexItem extends ParentDataWidget<LayoutBoxParentData> {
  /// The order in which this item should be painted relative to its siblings.
  /// Lower values are painted first (behind), higher values are painted last (on top).
  /// Items with the same paint order are painted in document order.
  final int? paintOrder;

  /// The preferred width of this flex item.
  /// If null, the item will size itself based on its content and flex properties.
  final SizeUnit? width;

  /// The preferred height of this flex item.
  /// If null, the item will size itself based on its content and flex properties.
  final SizeUnit? height;

  /// The minimum width constraint for this flex item.
  /// The item will not be sized smaller than this value.
  final SizeUnit? minWidth;

  /// The maximum width constraint for this flex item.
  /// The item will not be sized larger than this value.
  final SizeUnit? maxWidth;

  /// The minimum height constraint for this flex item.
  /// The item will not be sized smaller than this value.
  final SizeUnit? minHeight;

  /// The maximum height constraint for this flex item.
  /// The item will not be sized larger than this value.
  final SizeUnit? maxHeight;

  /// The flex grow factor for this item.
  /// Determines how much this item should grow relative to its siblings when
  /// there is extra space available in the main axis.
  /// A value of 0 means the item will not grow. Default is 0.0.
  final double flexGrow;

  /// The flex shrink factor for this item.
  /// Determines how much this item should shrink relative to its siblings when
  /// there is insufficient space in the main axis.
  /// A value of 0 means the item will not shrink. Default is 0.0.
  final double flexShrink;

  /// The aspect ratio constraint for this item.
  /// If specified, the item's width and height will be constrained to maintain
  /// this aspect ratio (width/height). This is useful for responsive design.
  final double? aspectRatio;

  /// The offset from the top edge of the parent container.
  /// Used for absolute positioning within the flex container.
  final PositionUnit? top;

  /// The offset from the left edge of the parent container.
  /// Used for absolute positioning within the flex container.
  final PositionUnit? left;

  /// The offset from the bottom edge of the parent container.
  /// Used for absolute positioning within the flex container.
  final PositionUnit? bottom;

  /// The offset from the right edge of the parent container.
  /// Used for absolute positioning within the flex container.
  final PositionUnit? right;

  /// The cross-axis alignment for this specific item.
  /// Overrides the [FlexBox.alignItems] property for this individual child.
  /// If null, uses the parent's alignItems setting.
  final BoxAlignmentGeometry? alignSelf;

  /// Creates a flex item with the specified properties.
  ///
  /// The [child] parameter is required and specifies the widget to be laid out.
  /// All other parameters are optional and provide fine-grained control over
  /// how this specific child behaves within the flex layout.
  const FlexItem({
    super.key,
    this.paintOrder,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.flexGrow = 0.0,
    this.flexShrink = 0.0,
    this.aspectRatio,
    this.top,
    this.left,
    this.bottom,
    this.right,
    this.alignSelf,
    required super.child,
  });

  /// Applies the flex item configuration to the child's parent data.
  ///
  /// This method is called by the Flutter framework when the widget is inserted
  /// into the tree. It creates a [LayoutData] object with all the flex properties
  /// and attaches it to the child's [ParentData].
  ///
  /// The layout data includes sizing constraints, positioning offsets, flex factors,
  /// and alignment settings that the flex layout algorithm will use.
  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is LayoutBoxParentData);
    final parentData = renderObject.parentData as LayoutBoxParentData;
    final parent = renderObject.parent as RenderLayoutBox;
    parentData.debugKey = key;
    final newLayoutData = LayoutData(
      behavior: LayoutBehavior.none,
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
      alignSelf: alignSelf,
      aspectRatio: aspectRatio,
      flexGrow: flexGrow,
      flexShrink: flexShrink,
    );
    if (parentData.layoutData != newLayoutData) {
      parentData.layoutData = newLayoutData;
      parent.markNeedsLayout();
    }
  }

  /// The typical ancestor widget class for this widget.
  ///
  /// Used by Flutter's debugging tools to provide better error messages
  /// when this widget is used incorrectly.
  @override
  Type get debugTypicalAncestorWidgetClass => FlexBox;
}

/// A flexible box layout widget that implements the CSS Flexbox specification.
///
/// FlexBox provides a powerful and flexible way to arrange child widgets in
/// one or two dimensions. It supports all major flexbox features including
/// direction, wrapping, alignment, spacing, and responsive sizing.
///
/// ## Basic Usage
///
/// ```dart
/// FlexBox(
///   direction: FlexDirection.row,
///   children: [
///     FlexItem(child: Text('Item 1')),
///     FlexItem(child: Text('Item 2')),
///     FlexItem(child: Text('Item 3')),
///   ],
/// )
/// ```
///
/// ## Layout Direction
///
/// The [direction] property controls the primary axis of the layout:
/// - [FlexDirection.row]: Items flow horizontally (left to right)
/// - [FlexDirection.column]: Items flow vertically (top to bottom)
/// - [FlexDirection.rowReverse]: Items flow horizontally (right to left)
/// - [FlexDirection.columnReverse]: Items flow vertically (bottom to top)
///
/// ## Wrapping Behavior
///
/// The [wrap] property controls how items wrap to new lines:
/// - [FlexWrap.none]: Single line layout, items may overflow
/// - [FlexWrap.wrap]: Multi-line layout, items wrap to new lines
/// - [FlexWrap.wrapReverse]: Multi-line layout with reversed line order
///
/// ## Alignment and Justification
///
/// - [justifyContent]: Controls alignment along the main axis
/// - [alignItems]: Controls alignment along the cross axis for all items
/// - [alignContent]: Controls alignment of the entire flex container when wrapping
///
/// ## Spacing and Padding
///
/// - [padding]: Internal padding around the container
/// - [horizontalSpacing]: Space between items horizontally
/// - [verticalSpacing]: Space between items vertically
///
/// ## Responsive Design
///
/// Use [FlexItem] widgets as children to control individual item sizing:
///
/// ```dart
/// FlexBox(
///   children: [
///     FlexItem(flexGrow: 1, child: Text('Flexible')),
///     FlexItem(width: SizeUnit.viewportSize * 0.3, child: Text('Fixed')),
///   ],
/// )
/// ```
///
/// ## Scrolling and Overflow
///
/// Control overflow behavior with [horizontalOverflow] and [verticalOverflow]:
/// - [LayoutOverflow.hidden]: Clip content that exceeds bounds
/// - [LayoutOverflow.scroll]: Add scrollbars when content exceeds bounds
/// - [LayoutOverflow.visible]: Allow content to extend beyond bounds
///
/// ## RTL Support
///
/// The layout automatically respects the [textDirection] and handles RTL
/// languages correctly, reversing the flow direction when appropriate.
class FlexBox extends StatelessWidget {
  // flexbox specific properties
  /// The direction of the main axis for this flex container.
  ///
  /// Determines whether children are laid out horizontally (row) or vertically (column).
  /// Also controls the direction of flow, with reverse options available.
  ///
  /// Defaults to [FlexDirection.row] for horizontal layout.
  final FlexDirection direction;

  /// Controls how flex items wrap when they exceed the container's size.
  ///
  /// - [FlexWrap.none]: Items stay on a single line, potentially overflowing
  /// - [FlexWrap.wrap]: Items wrap to new lines as needed
  /// - [FlexWrap.wrapReverse]: Items wrap but lines are in reverse order
  ///
  /// Defaults to [FlexWrap.none].
  final FlexWrap wrap;

  /// The maximum number of items allowed per line when wrapping is enabled.
  ///
  /// When set, forces a line break after this many items, regardless of available space.
  /// Useful for creating grid-like layouts with consistent item counts per row.
  ///
  /// If null, items wrap based on available space only.
  final int? maxItemsPerLine;

  /// The maximum number of lines allowed when wrapping is enabled.
  ///
  /// When set, limits the total number of lines in the layout. Items that would
  /// exceed this limit are hidden or handled according to overflow settings.
  ///
  /// If null, unlimited lines are allowed.
  final int? maxLines;

  /// The internal padding applied to the flex container.
  ///
  /// Adds space between the container's edges and its content. Uses
  /// [EdgeSpacingGeometry] for flexible, responsive padding values.
  ///
  /// Defaults to [EdgeSpacing.zero] (no padding).
  final EdgeSpacingGeometry padding;

  /// The horizontal spacing between adjacent flex items.
  ///
  /// Applied between items in the main axis direction. Uses [SpacingUnit]
  /// for responsive spacing that adapts to container size.
  ///
  /// Defaults to [SpacingUnit.zero].
  final SpacingUnit horizontalSpacing;

  /// The vertical spacing between adjacent flex items.
  ///
  /// Applied between items in the cross axis direction. Uses [SpacingUnit]
  /// for responsive spacing that adapts to container size.
  ///
  /// Defaults to [SpacingUnit.zero].
  final SpacingUnit verticalSpacing;

  /// The default cross-axis alignment for all child items.
  ///
  /// Controls how items are positioned along the cross axis when they don't
  /// fill the available space. Individual items can override this with [FlexItem.alignSelf].
  ///
  /// Common values: [BoxAlignmentGeometry.start], [BoxAlignmentGeometry.center],
  /// [BoxAlignmentGeometry.end], [BoxAlignmentGeometry.stretch].
  ///
  /// Defaults to [BoxAlignmentGeometry.start].
  final BoxAlignmentGeometry alignItems;

  /// The alignment of the flex container's lines when wrapping is enabled.
  ///
  /// Controls how multiple lines are distributed along the cross axis when
  /// there is extra space. Only applies when [wrap] is not [FlexWrap.none].
  ///
  /// Common values: [BoxAlignmentContent.start], [BoxAlignmentContent.center],
  /// [BoxAlignmentContent.end], [BoxAlignmentContent.spaceBetween].
  ///
  /// Defaults to [BoxAlignmentContent.start].
  final BoxAlignmentContent alignContent;

  /// The main-axis alignment for all child items.
  ///
  /// Controls how items are distributed along the main axis when there is
  /// extra space available.
  ///
  /// Common values: [BoxAlignmentBase.start], [BoxAlignmentBase.center],
  /// [BoxAlignmentBase.end], [BoxAlignmentBase.spaceBetween], [BoxAlignmentBase.spaceAround].
  ///
  /// Defaults to [BoxAlignmentBase.start].
  final BoxAlignmentBase justifyContent;

  // general properties
  /// The text direction for resolving directional properties.
  ///
  /// If null, uses the ambient [Directionality] from the widget tree.
  /// Affects how directional alignments (start/end) are interpreted,
  /// especially important for RTL (right-to-left) languages.
  final TextDirection? textDirection;

  /// Whether to reverse the paint order of children.
  ///
  /// When true, children are painted in reverse order, which can affect
  /// layering and visual stacking. Useful for certain animation effects
  /// or when you need to control which elements appear on top.
  ///
  /// Defaults to false.
  final bool reversePaint;

  /// Controller for vertical scrolling when vertical overflow is enabled.
  ///
  /// Allows programmatic control of vertical scroll position and listening
  /// to scroll events. Only used when [verticalOverflow] is [LayoutOverflow.scroll].
  final ScrollController? verticalController;

  /// Controller for horizontal scrolling when horizontal overflow is enabled.
  ///
  /// Allows programmatic control of horizontal scroll position and listening
  /// to scroll events. Only used when [horizontalOverflow] is [LayoutOverflow.scroll].
  final ScrollController? horizontalController;

  /// How to handle content that exceeds the horizontal bounds.
  ///
  /// - [LayoutOverflow.hidden]: Clip overflowing content
  /// - [LayoutOverflow.scroll]: Add horizontal scrollbar
  /// - [LayoutOverflow.visible]: Allow content to extend beyond bounds
  ///
  /// Defaults to [LayoutOverflow.hidden].
  final LayoutOverflow horizontalOverflow;

  /// How to handle content that exceeds the vertical bounds.
  ///
  /// - [LayoutOverflow.hidden]: Clip overflowing content
  /// - [LayoutOverflow.scroll]: Add vertical scrollbar
  /// - [LayoutOverflow.visible]: Allow content to extend beyond bounds
  ///
  /// Defaults to [LayoutOverflow.hidden].
  final LayoutOverflow verticalOverflow;

  /// Controls how diagonal drag gestures are interpreted.
  ///
  /// Determines whether diagonal drags should be treated as horizontal,
  /// vertical, or both directions simultaneously.
  ///
  /// Defaults to [DiagonalDragBehavior.free].
  final DiagonalDragBehavior diagonalDragBehavior;

  /// The list of child widgets to layout.
  ///
  /// Each child should typically be wrapped in a [FlexItem] widget to
  /// control its flex behavior. Regular widgets work but won't have
  /// flex-specific properties.
  final List<Widget> children;

  /// How to clip the content when it overflows the bounds.
  ///
  /// Controls the visual clipping behavior. [Clip.hardEdge] provides
  /// the best performance but may show sharp edges.
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// The text baseline to use for aligning text within the layout.
  ///
  /// Used when items contain text and need to be aligned by their
  /// text baseline rather than their geometric bounds.
  final TextBaseline? textBaseline;

  /// The border radius applied to the container's background and clipping.
  ///
  /// Creates rounded corners on the flex container. The radius affects
  /// both the background decoration and content clipping.
  final BorderRadiusGeometry? borderRadius;

  /// Creates a flexible box layout container with the specified properties.
  ///
  /// The [children] parameter accepts a list of widgets to layout. For best results,
  /// wrap each child in a [FlexItem] widget to control its flex behavior.
  ///
  /// ## Example
  ///
  /// ```dart
  /// FlexBox(
  ///   direction: FlexDirection.row,
  ///   wrap: FlexWrap.wrap,
  ///   alignItems: BoxAlignmentGeometry.center,
  ///   justifyContent: BoxAlignmentBase.spaceBetween,
  ///   padding: EdgeSpacing.all(SizeUnit.dp(16)),
  ///   horizontalSpacing: SpacingUnit.dp(8),
  ///   verticalSpacing: SpacingUnit.dp(8),
  ///   children: [
  ///     FlexItem(child: Text('Item 1')),
  ///     FlexItem(child: Text('Item 2')),
  ///     FlexItem(child: Text('Item 3')),
  ///   ],
  /// )
  /// ```
  ///
  /// All parameters are optional except [children], which defaults to an empty list.
  /// The layout will automatically adapt to the provided configuration.
  const FlexBox({
    super.key,
    this.direction = FlexDirection.row,
    this.wrap = FlexWrap.none,
    this.maxItemsPerLine,
    this.maxLines,
    this.padding = EdgeSpacing.zero,
    this.horizontalSpacing = SpacingUnit.zero,
    this.verticalSpacing = SpacingUnit.zero,
    this.alignItems = BoxAlignmentGeometry.start,
    this.alignContent = BoxAlignmentContent.start,
    this.justifyContent = BoxAlignmentBase.start,
    this.textDirection,
    this.reversePaint = false,
    this.verticalController,
    this.horizontalController,
    this.diagonalDragBehavior = DiagonalDragBehavior.free,
    this.horizontalOverflow = LayoutOverflow.hidden,
    this.verticalOverflow = LayoutOverflow.hidden,
    this.textBaseline,
    this.clipBehavior = Clip.hardEdge,
    this.borderRadius,
    this.children = const [],
  });

  /// Builds the widget tree for this flex container.
  ///
  /// This method creates a [LayoutBox] widget configured with the flex layout
  /// properties. It resolves the text direction from the ambient [Directionality]
  /// if not explicitly provided, and constructs a [FlexLayout] object with
  /// all the flex-specific configuration.
  ///
  /// The build process:
  /// 1. Resolves the text direction for RTL support
  /// 2. Creates a [FlexLayout] with all flex properties
  /// 3. Wraps everything in a [LayoutBox] for rendering
  ///
  /// The resulting widget tree handles all the complex flexbox layout calculations
  /// and provides scrolling, overflow handling, and visual styling.
  @override
  Widget build(BuildContext context) {
    final resolvedTextDirection =
        textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;
    return LayoutBox(
      textDirection: resolvedTextDirection,
      reversePaint: reversePaint,
      horizontalController: horizontalController,
      verticalController: verticalController,
      horizontalOverflow: horizontalOverflow,
      verticalOverflow: verticalOverflow,
      diagonalDragBehavior: diagonalDragBehavior,
      mainScrollDirection: direction.axis == LayoutAxis.horizontal
          ? Axis.vertical
          : Axis.horizontal,
      textBaseline: textBaseline,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      layout: FlexLayout(
        direction: direction,
        wrap: wrap,
        maxItemsPerLine: maxItemsPerLine,
        maxLines: maxLines,
        padding: padding.resolve(
          layoutTextDirectionFromTextDirection(resolvedTextDirection),
        ),
        horizontalSpacing: horizontalSpacing,
        verticalSpacing: verticalSpacing,
        alignItems: alignItems,
        alignContent: alignContent,
        justifyContent: justifyContent,
      ),
      children: children,
    );
  }
}
