import 'package:flexbox/src/foundation.dart';
import 'package:flexbox/src/morph.dart';
import 'package:flexbox/src/rendering.dart';
import 'package:flexbox/src/scrollable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class FixedFlexBox extends MultiChildRenderObjectWidget {
  final Axis direction;
  final double spacing;
  final Alignment alignment;
  final ViewportOffset horizontal;
  final ViewportOffset vertical;
  final AxisDirection verticalAxisDirection;
  final AxisDirection horizontalAxisDirection;
  final bool reverse;
  final bool reversePaint;
  final bool reverseOffsetX;
  final bool reverseOffsetY;
  final bool clipPaint;

  const FixedFlexBox({
    super.key,
    required this.direction,
    this.spacing = 0.0,
    required this.alignment,
    required this.horizontal,
    required this.vertical,
    required this.verticalAxisDirection,
    required this.horizontalAxisDirection,
    required super.children,
    required this.reverse,
    required this.reversePaint,
    required this.clipPaint,
    required this.reverseOffsetX,
    required this.reverseOffsetY,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlexBox(
      direction: direction,
      spacing: spacing,
      alignment: alignment,
      reverse: reverse,
      horizontal: horizontal,
      vertical: vertical,
      verticalAxisDirection: verticalAxisDirection,
      horizontalAxisDirection: horizontalAxisDirection,
      reversePaint: reversePaint,
      clipPaint: clipPaint,
      reverseOffsetX: reverseOffsetX,
      reverseOffsetY: reverseOffsetY,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlexBox renderObject) {
    bool changed = false;
    if (renderObject.direction != direction) {
      renderObject.direction = direction;
      changed = true;
    }
    if (renderObject.spacing != spacing) {
      renderObject.spacing = spacing;
      changed = true;
    }
    if (renderObject.alignment != alignment) {
      renderObject.alignment = alignment;
      changed = true;
    }
    if (renderObject.reverse != reverse) {
      renderObject.reverse = reverse;
      changed = true;
    }
    if (renderObject.horizontal != horizontal) {
      renderObject.updateHorizontalOffset(horizontal);
      changed = true;
    }
    if (renderObject.vertical != vertical) {
      renderObject.updateVerticalOffset(vertical);
      changed = true;
    }
    if (renderObject.verticalAxisDirection != verticalAxisDirection) {
      renderObject.verticalAxisDirection = verticalAxisDirection;
      changed = true;
    }
    if (renderObject.horizontalAxisDirection != horizontalAxisDirection) {
      renderObject.horizontalAxisDirection = horizontalAxisDirection;
      changed = true;
    }
    if (renderObject.reversePaint != reversePaint) {
      renderObject.reversePaint = reversePaint;
      renderObject.markNeedsPaint();
    }
    if (renderObject.clipPaint != clipPaint) {
      renderObject.clipPaint = clipPaint;
      changed = true;
    }
    if (renderObject.reverseOffsetX != reverseOffsetX) {
      renderObject.reverseOffsetX = reverseOffsetX;
      changed = true;
    }
    if (changed) {
      renderObject.markNeedsLayout();
    }
  }
}

class FlexBox extends StatelessWidget {
  final Axis direction;
  final double spacing;
  final AlignmentGeometry alignment;
  final List<Widget> children;
  final bool scrollHorizontalOverflow;
  final bool scrollVerticalOverflow;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final bool reversePaint;
  final ScrollController? horizontalController;
  final ScrollController? verticalController;

  const FlexBox({
    super.key,
    this.direction = Axis.horizontal,
    this.spacing = 0.0,
    this.alignment = Alignment.center,
    this.reverse = false,
    this.children = const [],
    this.scrollHorizontalOverflow = true,
    this.scrollVerticalOverflow = true,
    this.clipBehavior = Clip.hardEdge,
    this.padding,
    this.reversePaint = false,
    this.horizontalController,
    this.verticalController,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    var reverse = this.reverse;
    var reversePaint = this.reversePaint;
    if (textDirection != TextDirection.ltr && direction == Axis.horizontal) {
      reverse = !reverse; // Reverse if text direction is RTL
      reversePaint = !reversePaint; // Reverse paint order for RTL
    }
    final verticalDetails = ScrollableDetails.vertical(
      controller: verticalController,
      reverse: reverse && direction == Axis.vertical,
      physics: scrollVerticalOverflow
          ? null
          : const NeverScrollableScrollPhysics(),
    );
    final horizontalDetails = ScrollableDetails.horizontal(
      reverse: textDirection == TextDirection.rtl,
      controller: horizontalController,
      physics: scrollHorizontalOverflow
          ? null
          : const NeverScrollableScrollPhysics(),
    );
    return ScrollableClient(
      clipBehavior: clipBehavior,
      diagonalDragBehavior: DiagonalDragBehavior.free,
      verticalDetails: verticalDetails,
      horizontalDetails: horizontalDetails,
      builder: (context, vertical, horizontal) {
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: FixedFlexBox(
            direction: direction,
            spacing: spacing,
            alignment: alignment.resolve(textDirection),
            reverse: reverse,
            horizontal: horizontal,
            vertical: vertical,
            verticalAxisDirection: verticalDetails.direction,
            horizontalAxisDirection: horizontalDetails.direction,
            reversePaint: reverse,
            clipPaint:
                false, // Do not set to true, might cause issues with morphing
            reverseOffsetX: textDirection == TextDirection.rtl,
            reverseOffsetY: reverse && direction == Axis.vertical,
            children: children,
          ),
        );
      },
    );
  }
}

class FlexBoxChild extends ParentDataWidget<FlexBoxParentData> {
  final BoxPosition? top;
  final BoxPosition? bottom;
  final BoxPosition? left;
  final BoxPosition? right;
  final BoxSize? width;
  final BoxSize? height;
  final BoxPositionType? horizontalPosition;
  final BoxPositionType? verticalPosition;
  final int? zOrder;

  const FlexBoxChild({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.width,
    this.height,
    this.horizontalPosition,
    this.verticalPosition,
    this.zOrder,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! FlexBoxParentData) {
      throw ArgumentError('RenderObject must be a FlexBox');
    }
    var parentData = renderObject.parentData as FlexBoxParentData;
    bool needsLayout = false;
    if (parentData.top != top) {
      parentData.top = top;
      needsLayout = true;
    }
    if (parentData.bottom != bottom) {
      parentData.bottom = bottom;
      needsLayout = true;
    }
    if (parentData.left != left) {
      parentData.left = left;
      needsLayout = true;
    }
    if (parentData.right != right) {
      parentData.right = right;
      needsLayout = true;
    }
    if (parentData.width != width) {
      parentData.width = width;
      needsLayout = true;
    }
    if (parentData.height != height) {
      parentData.height = height;
      needsLayout = true;
    }
    if (parentData.horizontalPosition != horizontalPosition) {
      parentData.horizontalPosition = horizontalPosition;
      needsLayout = true;
    }
    if (parentData.verticalPosition != verticalPosition) {
      parentData.verticalPosition = verticalPosition;
      needsLayout = true;
    }
    if (parentData.zOrder != zOrder) {
      parentData.zOrder = zOrder;
      needsLayout = true;
    }
    if (needsLayout) {
      final parent = renderObject.parent as RenderFlexBox;
      parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => FlexBox;
}

class Morphed extends SingleChildRenderObjectWidget {
  final Object tag;

  const Morphed({super.key, required this.tag, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMorphed(tag, debugKey: key);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderMorphed renderObject,
  ) {
    if (renderObject.tag != tag) {
      renderObject.tag = tag;
      renderObject.clearMorphs();
      renderObject.markNeedsLayout();
    }
  }
}

class Morph extends MultiChildRenderObjectWidget {
  final double interpolation;
  const Morph({super.key, super.children = const [], this.interpolation = 0.0});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMorph(interpolation: interpolation, debugKey: key);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderMorph renderObject,
  ) {
    if (renderObject.interpolation != interpolation) {
      renderObject.interpolation = interpolation;
      renderObject.markNeedsLayout();
    }
  }
}

class MorphedDecoratedBox extends SingleChildRenderObjectWidget {
  final Decoration decoration;
  final Clip clipBehavior;
  final Object tag;

  const MorphedDecoratedBox({
    super.key,
    required this.decoration,
    this.clipBehavior = Clip.hardEdge,
    required this.tag,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMorphedDecoratedBox(
      debugKey: key,
      tag: tag,
      decoration: decoration,
      clipBehavior: clipBehavior,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderMorphedDecoratedBox renderObject,
  ) {
    final textDirection = Directionality.of(context);
    bool changed = false;
    if (renderObject.textDirection != textDirection) {
      renderObject.textDirection = textDirection;
      changed = true;
    }
    if (renderObject.tag != tag) {
      renderObject.tag = tag;
      renderObject.clearMorphs();
      changed = true;
    }
    if (renderObject.decoration != decoration) {
      renderObject.decoration = decoration;
      changed = true;
    }
    if (renderObject.clipBehavior != clipBehavior) {
      renderObject.clipBehavior = clipBehavior;
      changed = true;
    }
    if (changed) {
      renderObject.markNeedsLayout();
    }
  }
}
