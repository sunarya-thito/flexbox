import 'package:flexiblebox/src/old_foundation.dart';
import 'package:flexiblebox/src/old_rendering.dart';
import 'package:flexiblebox/src/scrollable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class FlexBoxViewport extends MultiChildRenderObjectWidget {
  final FlexDirection direction;
  final BoxValue? columnGap;
  final BoxValue? rowGap;
  final FlexItemAlignment alignItems;
  final FlexJustifyContent justifyContent;
  final FlexContentAlignment alignContent;
  final ViewportOffset horizontal;
  final ViewportOffset vertical;
  final AxisDirection verticalAxisDirection;
  final AxisDirection horizontalAxisDirection;
  final bool reverse;
  final bool reversePaint;
  final bool clipPaint;
  final EdgeInsets padding;
  final TextDirection textDirection;
  final BoxFit fit;

  const FlexBoxViewport({
    super.key,
    required this.direction,
    required this.spacing,
    required this.spacingBefore,
    required this.spacingAfter,
    required this.alignment,
    required this.horizontal,
    required this.vertical,
    required this.verticalAxisDirection,
    required this.horizontalAxisDirection,
    required super.children,
    required this.reverse,
    required this.reversePaint,
    required this.clipPaint,
    required this.padding,
    required this.textDirection,
    required this.fit,
    required this.runSpacing,
    required this.runSpacingBefore,
    required this.runSpacingAfter,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlexBox(
      direction: direction,
      spacing: spacing,
      spacingBefore: spacingBefore,
      spacingAfter: spacingAfter,
      alignment: alignment,
      reverse: reverse,
      horizontal: horizontal,
      vertical: vertical,
      verticalAxisDirection: verticalAxisDirection,
      horizontalAxisDirection: horizontalAxisDirection,
      reversePaint: reversePaint,
      clipPaint: clipPaint,
      padding: padding,
      textDirection: textDirection,
      fit: fit,
      runSpacing: runSpacing,
      runSpacingBefore: runSpacingBefore,
      runSpacingAfter: runSpacingAfter,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlexBox renderObject) {
    FlexBoxLayoutChange layoutChange = FlexBoxLayoutChange.none;
    FlexBoxPositionChange positionChange = FlexBoxPositionChange.none;
    if (renderObject.direction != direction) {
      renderObject.direction = direction;

      // direction change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it affects the position of all children
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.spacing != spacing) {
      renderObject.spacing = spacing;
      // spacing change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it affects the position of all children
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.spacingBefore != spacingBefore) {
      renderObject.spacingBefore = spacingBefore;
      // spacing change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it affects the position of all children
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.spacingAfter != spacingAfter) {
      renderObject.spacingAfter = spacingAfter;
      // spacing change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it affects the position of all children
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.alignment != alignment) {
      renderObject.alignment = alignment;
      // alignment change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it does NOT affect the position of absolute children
      positionChange |= FlexBoxPositionChange.nonAbsolute;
    }
    if (renderObject.reverse != reverse) {
      renderObject.reverse = reverse;
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.horizontal != horizontal) {
      renderObject.updateHorizontalOffset(horizontal);
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.vertical != vertical) {
      renderObject.updateVerticalOffset(vertical);
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.verticalAxisDirection != verticalAxisDirection) {
      renderObject.verticalAxisDirection = verticalAxisDirection;
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.horizontalAxisDirection != horizontalAxisDirection) {
      renderObject.horizontalAxisDirection = horizontalAxisDirection;
      // needsRelayout = true;
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.reversePaint != reversePaint) {
      renderObject.reversePaint = reversePaint;
      renderObject.markNeedsPaint();
    }
    if (renderObject.clipPaint != clipPaint) {
      renderObject.clipPaint = clipPaint;
      renderObject.markNeedsPaint();
    }
    if (renderObject.padding != padding) {
      renderObject.padding = padding;
      layoutChange |= FlexBoxLayoutChange.both;
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.textDirection != textDirection) {
      renderObject.textDirection = textDirection;
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.fit != fit) {
      renderObject.fit = fit;
      // ignoring FlexBoxLayoutChange.none because fit only affects
      // how the child is painted within its allocated space
      renderObject.markNeedsLayout();
    }
    if (renderObject.runSpacing != runSpacing) {
      renderObject.runSpacing = runSpacing;
      // run spacing change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it affects the position of all children
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.runSpacingBefore != runSpacingBefore) {
      renderObject.runSpacingBefore = runSpacingBefore;
      // run spacing change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it affects the position of all children
      positionChange |= FlexBoxPositionChange.both;
    }
    if (renderObject.runSpacingAfter != runSpacingAfter) {
      renderObject.runSpacingAfter = runSpacingAfter;
      // run spacing change affects layout for non-absolute children,
      // it does not affect absolute children layout
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      // but it affects the position of all children
      positionChange |= FlexBoxPositionChange.both;
    }
    if (positionChange != FlexBoxPositionChange.none ||
        layoutChange != FlexBoxLayoutChange.none) {
      renderObject.positionChange |= positionChange;
      renderObject.layoutChange |= layoutChange;
      renderObject.markNeedsLayout();
    }
  }
}

class FlexBoxSpacer extends StatelessWidget {
  final double? flex;
  final BoxValue? min;
  final BoxValue? max;

  const FlexBoxSpacer({super.key, this.flex, this.min, this.max});

  @override
  Widget build(BuildContext context) {
    return DirectionalFlexItem(
      mainSize: (flex == null ? BoxValue.expanding() : BoxValue.flex(flex!))
          .clamp(min: min, max: max),
      child: const SizedBox.shrink(),
    );
  }
}

class FlexBox extends StatelessWidget {
  final FlexDirection direction;
  final BoxValue? rowGap;
  final BoxValue? columnGap;
  final List<Widget> children;
  final bool scrollHorizontal;
  final bool scrollVertical;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? padding;
  final ScrollController? horizontalController;
  final ScrollController? verticalController;
  final TextDirection? textDirection;
  final BoxFit fit;

  const FlexBox({
    super.key,
    this.direction = Axis.horizontal,
    this.spacing,
    this.spacingStart,
    this.spacingEnd,
    this.runSpacing,
    this.runSpacingStart,
    this.runSpacingEnd,
    this.alignment = Alignment.center,
    this.reverse = false,
    this.scrollHorizontal = true,
    this.scrollVertical = true,
    this.clipBehavior = Clip.hardEdge,
    this.padding,
    this.reversePaint = false,
    this.horizontalController,
    this.verticalController,
    this.textDirection,
    this.fit = BoxFit.none,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final textDirection =
        this.textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    var spacingStart = this.spacingStart;
    var spacingEnd = this.spacingEnd;
    switch ((textDirection, direction)) {
      case (TextDirection.rtl, Axis.horizontal):
        // swap start and end
        final temp = spacingStart;
        spacingStart = spacingEnd;
        spacingEnd = temp;
        break;
      default:
        // no change
        break;
    }
    var reverse = this.reverse;
    var reversePaint = this.reversePaint;
    if (textDirection != TextDirection.ltr && direction == Axis.horizontal) {
      reverse = !reverse; // Reverse if text direction is RTL
      reversePaint = !reversePaint; // Reverse paint order for RTL
    }
    final verticalDetails = ScrollableDetails.vertical(
      controller: verticalController,
      reverse: reverse && direction == Axis.vertical,
      physics: scrollVertical ? null : const NeverScrollableScrollPhysics(),
    );
    final horizontalDetails = ScrollableDetails.horizontal(
      reverse: textDirection == TextDirection.rtl,
      controller: horizontalController,
      physics: scrollHorizontal ? null : const NeverScrollableScrollPhysics(),
    );
    return ScrollableClient(
      clipBehavior: clipBehavior,
      diagonalDragBehavior: DiagonalDragBehavior.free,
      verticalDetails: verticalDetails,
      horizontalDetails: horizontalDetails,
      builder: (context, vertical, horizontal) {
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: FlexBoxViewport(
            textDirection: textDirection,
            direction: direction,
            spacing: spacing,
            spacingBefore: spacingStart,
            spacingAfter: spacingEnd,
            alignment: alignment.resolve(textDirection),
            reverse: reverse,
            horizontal: horizontal,
            vertical: vertical,
            verticalAxisDirection: verticalDetails.direction,
            horizontalAxisDirection: horizontalDetails.direction,
            reversePaint: reverse,
            clipPaint: clipBehavior != Clip.none,
            fit: fit,
            runSpacing: runSpacing,
            runSpacingBefore: runSpacingStart,
            runSpacingAfter: runSpacingEnd,
            padding: padding?.resolve(textDirection) ?? EdgeInsets.zero,
            children: children,
          ),
        );
      },
    );
  }
}

class FlexItem extends ParentDataWidget<FlexBoxParentData> {
  /// Forces the child to be positioned absolutely even
  /// if no position is specified (for this, [alignment] can
  /// be used to position the child within the parent).
  final bool absolute;

  final BoxValue? top;
  final BoxValue? bottom;
  final BoxValue? left;
  final BoxValue? right;
  final BoxValue? width;
  final BoxValue? height;
  final BoxPositionType? horizontalPosition;
  final BoxPositionType? verticalPosition;
  final int? zOrder;
  final bool horizontalScrollAffected;
  final bool verticalScrollAffected;
  final BoxValue? minWidth;
  final BoxValue? maxWidth;
  final BoxValue? minHeight;
  final BoxValue? maxHeight;
  final double? grow;
  final double? shrink;

  const FlexItem({
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
    this.horizontalScrollAffected = true,
    this.verticalScrollAffected = true,
    this.absolute = false,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignment,
    this.grow,
    this.shrink,
    required super.child,
  }) : assert(grow == null || grow >= 0, 'grow must be non-negative'),
       assert(shrink == null || shrink >= 0, 'shrink must be non-negative'),
       // assert that if grow or shrink is specified, it must be non-absolute
       assert(
         !(absolute ||
                 top != null ||
                 bottom != null ||
                 left != null ||
                 right != null) ||
             (grow == null && shrink == null),
         'grow and shrink can only be specified for non-absolute children',
       );

  bool get isAbsolute {
    return top != null ||
        bottom != null ||
        left != null ||
        right != null ||
        absolute;
  }

  @override
  void applyParentData(covariant RenderBox renderObject) {
    assert(top == null || top!.isPosition, 'top must be a position value');
    assert(
      bottom == null || bottom!.isPosition,
      'bottom must be a position value',
    );
    assert(left == null || left!.isPosition, 'left must be a position value');
    assert(
      right == null || right!.isPosition,
      'right must be a position value',
    );
    assert(width == null || width!.isSize, 'width must be a size value');
    assert(height == null || height!.isSize, 'height must be a size value');
    if (renderObject.parentData is! FlexBoxParentData) {
      throw ArgumentError('RenderObject must be a FlexBox');
    }
    var parentData = renderObject.parentData as FlexBoxParentData;
    bool needsResort = false;
    FlexBoxLayoutChange layoutChange = FlexBoxLayoutChange.none;
    FlexBoxPositionChange positionChange = FlexBoxPositionChange.none;
    if (absolute != parentData.absolute) {
      bool wasAbsolute = parentData.isAbsolute;
      parentData.absolute = absolute;
      if (isAbsolute != wasAbsolute) {
        // the child is switching from absolute to non-absolute or vice versa
        // therefore we need a full relayout
        layoutChange |= FlexBoxLayoutChange.both;
        // any layout change for non-absolute children
        // affects the position of all children
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (parentData.top != top) {
      bool wasAbsolute = parentData.isAbsolute;
      parentData.top = top;
      if (isAbsolute != wasAbsolute) {
        // the child is switching from absolute to non-absolute or vice versa
        // therefore we need a full relayout
        layoutChange |= FlexBoxLayoutChange.both;
        // any layout change for non-absolute children
        // affects the position of all children
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.bottom != bottom) {
      bool wasAbsolute = parentData.isAbsolute;
      parentData.bottom = bottom;
      if (isAbsolute != wasAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && wasAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.left != left) {
      bool wasAbsolute = parentData.isAbsolute;
      parentData.left = left;
      if (isAbsolute != wasAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && wasAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.right != right) {
      bool wasAbsolute = parentData.isAbsolute;
      parentData.right = right;
      if (isAbsolute != wasAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && wasAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.width != width) {
      parentData.width = width;
      if (isAbsolute) {
        // any width change on absolute children
        // will not affect the layout of non-absolute children
        layoutChange |= FlexBoxLayoutChange.absolute;
      } else {
        // any size change on non-absolute children
        // will affect the layout of other non-absolute children
        // therefore we need a full relayout
        layoutChange |= FlexBoxLayoutChange.both;
        // and also requires repositioning of both children
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (parentData.height != height) {
      parentData.height = height;
      if (isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.absolute;
      } else {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (minWidth != null) {
      parentData.minWidth = minWidth;
      if (isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.absolute;
      } else {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (maxWidth != null) {
      parentData.maxWidth = maxWidth;
      if (isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.absolute;
      } else {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (minHeight != null) {
      parentData.minHeight = minHeight;
      if (isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.absolute;
      } else {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (maxHeight != null) {
      parentData.maxHeight = maxHeight;
      if (isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.absolute;
      } else {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (parentData.horizontalPosition != horizontalPosition) {
      parentData.horizontalPosition = horizontalPosition;
      // positioining type only affects its own position
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        positionChange |= FlexBoxPositionChange.nonAbsolute;
      }
    }
    if (parentData.verticalPosition != verticalPosition) {
      parentData.verticalPosition = verticalPosition;
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        positionChange |= FlexBoxPositionChange.nonAbsolute;
      }
    }
    if (parentData.zOrder != zOrder) {
      parentData.zOrder = zOrder;
      needsResort = true;
    }
    if (parentData.horizontalScrollAffected != horizontalScrollAffected) {
      parentData.horizontalScrollAffected = horizontalScrollAffected;
      // only affects its own position
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        positionChange |= FlexBoxPositionChange.nonAbsolute;
      }
    }
    if (parentData.verticalScrollAffected != verticalScrollAffected) {
      parentData.verticalScrollAffected = verticalScrollAffected;
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        positionChange |= FlexBoxPositionChange.nonAbsolute;
      }
    }
    if (parentData.alignment != alignment) {
      parentData.alignment = alignment;
      // alignment only affects its own position
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        positionChange |= FlexBoxPositionChange.nonAbsolute;
      }
    }
    if (parentData.flexGrow != grow) {
      parentData.flexGrow = grow;
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      positionChange |= FlexBoxPositionChange.nonAbsolute;
    }
    if (parentData.flexShrink != shrink) {
      parentData.flexShrink = shrink;
      layoutChange |= FlexBoxLayoutChange.nonAbsolute;
      positionChange |= FlexBoxPositionChange.nonAbsolute;
    }

    final parent = renderObject.parent as RenderFlexBox;
    if (needsResort) {
      parent.needsResort = true;
      parent.markNeedsLayout();
    }
    if (positionChange != FlexBoxPositionChange.none ||
        layoutChange != FlexBoxLayoutChange.none) {
      parent.positionChange |= positionChange;
      parent.layoutChange |= layoutChange;
      parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => FlexBox;
}
