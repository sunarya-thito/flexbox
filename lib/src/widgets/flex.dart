import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flexiblebox/src/layout/flex.dart';
import 'package:flexiblebox/src/rendering.dart';
import 'package:flexiblebox/src/widgets/widget.dart';
import 'package:flutter/widgets.dart';

class FlexItem extends ParentDataWidget<LayoutBoxParentData> {
  final int? paintOrder;
  final SizeUnit? width;
  final SizeUnit? height;
  final SizeUnit? minWidth;
  final SizeUnit? maxWidth;
  final SizeUnit? minHeight;
  final SizeUnit? maxHeight;
  final double flexGrow;
  final double flexShrink;
  final double? aspectRatio;
  final PositionUnit? top;
  final PositionUnit? left;
  final PositionUnit? bottom;
  final PositionUnit? right;
  final BoxAlignmentGeometry? alignSelf;

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

  @override
  Type get debugTypicalAncestorWidgetClass => FlexBox;
}

class FlexBox extends StatelessWidget {
  // flexbox specific properties
  final FlexDirection direction;
  final FlexWrap wrap;
  final int? maxItemsPerLine;
  final int? maxLines;
  final EdgeSpacingGeometry padding;
  final SpacingUnit horizontalSpacing;
  final SpacingUnit verticalSpacing;
  final BoxAlignmentGeometry alignItems;
  final BoxAlignmentContent alignContent;
  final BoxAlignmentBase justifyContent;

  // general properties
  final TextDirection? textDirection;
  final bool reversePaint;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;
  final LayoutOverflow horizontalOverflow;
  final LayoutOverflow verticalOverflow;
  final DiagonalDragBehavior diagonalDragBehavior;
  final List<Widget> children;
  final Clip clipBehavior;
  final TextBaseline? textBaseline;
  final BorderRadiusGeometry? borderRadius;

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
