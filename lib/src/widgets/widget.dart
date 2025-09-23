import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flexiblebox/src/rendering.dart';
import 'package:flexiblebox/src/scrollable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class AbsoluteItem extends ParentDataWidget<LayoutBoxParentData> {
  final int? paintOrder;
  final SizeUnit? width;
  final SizeUnit? height;
  final SizeUnit? minWidth;
  final SizeUnit? maxWidth;
  final SizeUnit? minHeight;
  final SizeUnit? maxHeight;
  final PositionUnit? top;
  final PositionUnit? left;
  final PositionUnit? bottom;
  final PositionUnit? right;
  final double? aspectRatio;

  const AbsoluteItem({
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
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is LayoutBoxParentData);
    final parentData = renderObject.parentData as LayoutBoxParentData;
    final parent = renderObject.parent as RenderLayoutBox;
    final newLayoutData = LayoutData(
      behavior: LayoutBehavior.absolute,
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
      crossFlexGrow: 0.0,
      crossFlexShrink: 0.0,
      flexGrow: 0.0,
      flexShrink: 0.0,
    );
    if (parentData.layoutData != newLayoutData) {
      parentData.layoutData = newLayoutData;
      parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => LayoutBox;
}

class LayoutBoxViewport extends MultiChildRenderObjectWidget {
  final TextDirection textDirection;
  final bool reversePaint;
  final Axis mainScrollDirection;
  final ViewportOffset horizontal;
  final ViewportOffset vertical;
  final AxisDirection horizontalAxisDirection;
  final AxisDirection verticalAxisDirection;
  final Layout layout;
  final LayoutOverflow horizontalOverflow;
  final LayoutOverflow verticalOverflow;
  final TextBaseline? textBaseline;
  final BorderRadius borderRadius;
  final Clip clipBehavior;

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

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayoutBox(
      textDirection: textDirection,
      reversePaint: reversePaint,
      mainScrollDirection: mainScrollDirection,
      horizontal: horizontal,
      vertical: vertical,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalAxisDirection: verticalAxisDirection,
      boxLayout: layout,
      horizontalOverflow: horizontalOverflow,
      verticalOverflow: verticalOverflow,
      textBaseline: textBaseline,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderLayoutBox renderObject,
  ) {
    bool needsPaint = false;
    bool needsLayout = false;
    if (renderObject.textDirection != textDirection) {
      renderObject.textDirection = textDirection;
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
      renderObject.horizontal = horizontal;
      needsLayout = true;
    }
    if (renderObject.vertical != vertical) {
      renderObject.vertical = vertical;
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
    if (renderObject.textBaseline != textBaseline) {
      renderObject.textBaseline = textBaseline;
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
}

class LayoutBox extends StatelessWidget {
  final TextDirection? textDirection;
  final bool reversePaint;
  final Layout layout;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;
  final LayoutOverflow horizontalOverflow;
  final LayoutOverflow verticalOverflow;
  final DiagonalDragBehavior diagonalDragBehavior;
  final Axis mainScrollDirection;
  final List<Widget> children;
  final TextBaseline? textBaseline;
  final BorderRadiusGeometry? borderRadius;
  final Clip clipBehavior;
  const LayoutBox({
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
    required this.layout,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection =
        this.textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final horizontalDetails = ScrollableDetails.horizontal(
      controller: horizontalController,
    );
    final verticalDetails = ScrollableDetails.vertical(
      controller: verticalController,
    );
    final resolvedBorderRadius =
        borderRadius?.resolve(textDirection) ?? BorderRadius.zero;
    return ScrollableClient(
      diagonalDragBehavior: diagonalDragBehavior,
      horizontalDetails: horizontalDetails,
      verticalDetails: verticalDetails,
      builder: (context, verticalPosition, horizontalPosition) {
        return LayoutBoxViewport(
          textDirection: textDirection,
          reversePaint: reversePaint,
          mainScrollDirection: mainScrollDirection,
          horizontal: horizontalPosition,
          vertical: verticalPosition,
          horizontalAxisDirection: horizontalDetails.direction,
          verticalAxisDirection: verticalDetails.direction,
          layout: layout,
          horizontalOverflow: horizontalOverflow,
          verticalOverflow: verticalOverflow,
          textBaseline: textBaseline,
          borderRadius: resolvedBorderRadius,
          clipBehavior: clipBehavior,
          children: children,
        );
      },
    );
  }
}
