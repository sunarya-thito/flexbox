import 'package:flexiblebox/src/foundation.dart';
import 'package:flexiblebox/src/morph.dart';
import 'package:flexiblebox/src/rendering.dart';
import 'package:flexiblebox/src/scrollable.dart';
import 'package:flutter/foundation.dart';
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
  final bool clipPaint;
  final EdgeInsets padding;
  final TextDirection textDirection;
  final FlexSpacing spacingBehavior;

  const FixedFlexBox({
    super.key,
    required this.direction,
    required this.spacing,
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
    required this.spacingBehavior,
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
      padding: padding,
      textDirection: textDirection,
      spacingBehavior: spacingBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlexBox renderObject) {
    // bool needsRelayout = false;
    // bool needsReposition = false;
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
    if (renderObject.spacingBehavior != spacingBehavior) {
      renderObject.spacingBehavior = spacingBehavior;
      // spacing behavior change affects layout for non-absolute children,
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
  final double? min;
  final double? max;

  const FlexBoxSpacer({super.key, this.flex, this.min, this.max});

  @override
  Widget build(BuildContext context) {
    return DirectionalFlexBoxChild(
      mainSize: flex == null
          ? BoxSize.expanding(min: min, max: max)
          : BoxSize.flex(flex!, min: min, max: max),
      child: const SizedBox.shrink(),
    );
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
  final TextDirection? textDirection;
  final FlexSpacing spacingBehavior;

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
    this.textDirection,
    this.spacingBehavior = FlexSpacing.between,
  });

  @override
  Widget build(BuildContext context) {
    final textDirection =
        this.textDirection ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
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
            textDirection: textDirection,
            direction: direction,
            spacing: spacing,
            alignment: alignment.resolve(textDirection),
            reverse: reverse,
            horizontal: horizontal,
            vertical: vertical,
            verticalAxisDirection: verticalDetails.direction,
            horizontalAxisDirection: horizontalDetails.direction,
            reversePaint: reverse,
            clipPaint: clipBehavior != Clip.none,
            padding: padding?.resolve(textDirection) ?? EdgeInsets.zero,
            spacingBehavior: spacingBehavior,
            children: children,
          ),
        );
      },
    );
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return children
        .map((e) => e.toDiagnosticsNode(name: 'child'))
        .toList(growable: false);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('direction', direction));
    properties.add(DoubleProperty('spacing', spacing, defaultValue: 0.0));
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'alignment',
        alignment,
        defaultValue: Alignment.center,
      ),
    );
    properties.add(
      FlagProperty(
        'reverse',
        value: reverse,
        ifTrue: 'children in reverse order',
      ),
    );
    properties.add(
      FlagProperty(
        'reversePaint',
        value: reversePaint,
        ifTrue: 'paint children in reverse order',
      ),
    );
    properties.add(
      FlagProperty(
        'scrollHorizontalOverflow',
        value: scrollHorizontalOverflow,
        ifFalse: 'no horizontal scrolling when overflow',
      ),
    );
    properties.add(
      FlagProperty(
        'scrollVerticalOverflow',
        value: scrollVerticalOverflow,
        ifFalse: 'no vertical scrolling when overflow',
      ),
    );
    properties.add(
      DiagnosticsProperty<Clip>(
        'clipBehavior',
        clipBehavior,
        defaultValue: Clip.hardEdge,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        'padding',
        padding,
        defaultValue: null,
      ),
    );
    properties.add(IterableProperty<Widget>('children', children));
  }
}

class FlexBoxChild extends ParentDataWidget<FlexBoxParentData> {
  /// Forces the child to be positioned absolutely even
  /// if no position is specified (for this, [alignment] can
  /// be used to position the child within the parent).
  final bool absolute;

  /// Self alignment of the child within its allocated space.
  /// If its absolute but anchors are not specified,
  /// the alignment will be used to position the child
  /// within the parent. But if anchors are specified,
  /// the alignment will be used to position the child
  /// based on the anchor positions. But it will not
  /// have any effect if start and end anchors are both specified.
  final AlignmentGeometry? alignment;
  final BoxPosition? top;
  final BoxPosition? bottom;
  final BoxPosition? left;
  final BoxPosition? right;
  final BoxSize? width;
  final BoxSize? height;
  final BoxPositionType? horizontalPosition;
  final BoxPositionType? verticalPosition;
  final int? zOrder;
  final bool horizontalScrollAffected;
  final bool verticalScrollAffected;
  final bool horizontalContentRelative;
  final bool verticalContentRelative;

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
    this.horizontalScrollAffected = true,
    this.verticalScrollAffected = true,
    this.horizontalContentRelative = false,
    this.verticalContentRelative = false,
    this.absolute = false,
    this.alignment,
    required super.child,
  });

  bool get isAbsolute {
    return top != null || bottom != null || left != null || right != null;
  }

  @override
  void applyParentData(covariant RenderBox renderObject) {
    if (renderObject.parentData is! FlexBoxParentData) {
      throw ArgumentError('RenderObject must be a FlexBox');
    }
    var parentData = renderObject.parentData as FlexBoxParentData;
    bool needsResort = false;
    FlexBoxLayoutChange layoutChange = FlexBoxLayoutChange.none;
    FlexBoxPositionChange positionChange = FlexBoxPositionChange.none;
    if (absolute != parentData.absolute) {
      parentData.absolute = absolute;
      if (isAbsolute != parentData.isAbsolute) {
        // the child is switching from absolute to non-absolute or vice versa
        // therefore we need a full relayout
        layoutChange |= FlexBoxLayoutChange.both;
        // any layout change for non-absolute children
        // affects the position of all children
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (parentData.top != top) {
      parentData.top = top;
      if (isAbsolute != parentData.isAbsolute) {
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
      parentData.bottom = bottom;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.left != left) {
      parentData.left = left;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.right != right) {
      parentData.right = right;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.horizontalRelativeToContent != horizontalContentRelative) {
      parentData.horizontalRelativeToContent = horizontalContentRelative;
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        // if it was or is relative
        if (width != parentData.width &&
            (width is RelativeSize || parentData.width is RelativeSize)) {
          // this changes both
          layoutChange |= FlexBoxLayoutChange.both;
          positionChange |= FlexBoxPositionChange.both;
        }
        // else, it has no effect on non-absolute children
      }
    }
    if (parentData.verticalRelativeToContent != verticalContentRelative) {
      parentData.verticalRelativeToContent = verticalContentRelative;
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        if (height != parentData.height &&
            (height is RelativeSize || parentData.height is RelativeSize)) {
          layoutChange |= FlexBoxLayoutChange.both;
          positionChange |= FlexBoxPositionChange.both;
        }
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
    if (alignment != parentData.alignment) {
      parentData.alignment = alignment;
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

    final parent = renderObject.parent as RenderFlexBox;
    if (needsResort) {
      parent.needsResort = true;
      parent.markNeedsPaint();
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxPosition>('top', top, ifNull: ''));
    properties.add(
      DiagnosticsProperty<BoxPosition>('bottom', bottom, ifNull: ''),
    );
    properties.add(DiagnosticsProperty<BoxPosition>('left', left, ifNull: ''));
    properties.add(
      DiagnosticsProperty<BoxPosition>('right', right, ifNull: ''),
    );
    properties.add(DiagnosticsProperty<BoxSize>('width', width, ifNull: ''));
    properties.add(DiagnosticsProperty<BoxSize>('height', height, ifNull: ''));
    properties.add(
      DiagnosticsProperty<BoxPositionType>(
        'horizontalPosition',
        horizontalPosition,
        ifNull: '',
      ),
    );
    properties.add(
      DiagnosticsProperty<BoxPositionType>(
        'verticalPosition',
        verticalPosition,
        ifNull: '',
      ),
    );
    properties.add(IntProperty('zOrder', zOrder, ifNull: ''));
    properties.add(
      FlagProperty(
        'horizontalScrollAffected',
        value: horizontalScrollAffected,
        ifFalse: 'not affected by horizontal scroll',
      ),
    );
    properties.add(
      FlagProperty(
        'verticalScrollAffected',
        value: verticalScrollAffected,
        ifFalse: 'not affected by vertical scroll',
      ),
    );
    properties.add(
      FlagProperty(
        'horizontalContentRelative',
        value: horizontalContentRelative,
        ifFalse: 'not relative to content',
      ),
    );
    properties.add(
      FlagProperty(
        'verticalContentRelative',
        value: verticalContentRelative,
        ifFalse: 'not relative to content',
      ),
    );
  }
}

class DirectionalFlexBoxChild extends ParentDataWidget<FlexBoxParentData> {
  final bool absolute;
  final AlignmentGeometry? alignment;
  final BoxPosition? mainStart;
  final BoxPosition? mainEnd;
  final BoxPosition? crossStart;
  final BoxPosition? crossEnd;
  final BoxSize? mainSize;
  final BoxSize? crossSize;
  final BoxPositionType? mainPosition;
  final BoxPositionType? crossPosition;
  final int? zOrder;
  final bool mainScrollAffected;
  final bool crossScrollAffected;
  final bool mainContentRelative;
  final bool crossContentRelative;
  const DirectionalFlexBoxChild({
    super.key,
    this.mainStart,
    this.mainEnd,
    this.crossStart,
    this.crossEnd,
    this.mainSize,
    this.crossSize,
    this.mainPosition,
    this.crossPosition,
    this.zOrder,
    this.mainScrollAffected = true,
    this.crossScrollAffected = true,
    this.mainContentRelative = false,
    this.crossContentRelative = false,
    this.absolute = false,
    this.alignment,
    required super.child,
  });

  bool get isAbsolute {
    return mainStart != null ||
        mainEnd != null ||
        crossStart != null ||
        crossEnd != null;
  }

  @override
  void applyParentData(covariant RenderBox renderObject) {
    if (renderObject.parentData is! FlexBoxParentData) {
      throw ArgumentError('RenderObject must be a FlexBox');
    }
    var parentData = renderObject.parentData as FlexBoxParentData;
    bool needsResort = false;
    FlexBoxLayoutChange layoutChange = FlexBoxLayoutChange.none;
    FlexBoxPositionChange positionChange = FlexBoxPositionChange.none;
    final direction = (renderObject.parent as RenderFlexBox).direction;

    // Map main/cross axis to actual fields
    BoxPosition? top, bottom, left, right;
    BoxSize? width, height;
    BoxPositionType? horizontalPosition, verticalPosition;
    bool horizontalScrollAffected = true;
    bool verticalScrollAffected = true;
    bool horizontalContentRelative = false;
    bool verticalContentRelative = false;

    if (direction == Axis.horizontal) {
      left = mainStart;
      right = mainEnd;
      width = mainSize;
      horizontalPosition = mainPosition;
      horizontalScrollAffected = mainScrollAffected;
      horizontalContentRelative = mainContentRelative;
      top = crossStart;
      bottom = crossEnd;
      height = crossSize;
      verticalPosition = crossPosition;
      verticalScrollAffected = crossScrollAffected;
      verticalContentRelative = crossContentRelative;
    } else {
      top = mainStart;
      bottom = mainEnd;
      height = mainSize;
      verticalPosition = mainPosition;
      verticalScrollAffected = mainScrollAffected;
      verticalContentRelative = mainContentRelative;
      left = crossStart;
      right = crossEnd;
      width = crossSize;
      horizontalPosition = crossPosition;
      horizontalScrollAffected = crossScrollAffected;
      horizontalContentRelative = crossContentRelative;
    }

    if (absolute != parentData.absolute) {
      parentData.absolute = absolute;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      }
    }
    if (parentData.top != top) {
      parentData.top = top;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.bottom != bottom) {
      parentData.bottom = bottom;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.left != left) {
      parentData.left = left;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.right != right) {
      parentData.right = right;
      if (isAbsolute != parentData.isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.both;
        positionChange |= FlexBoxPositionChange.both;
      } else if (isAbsolute && parentData.isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      }
    }
    if (parentData.horizontalRelativeToContent != horizontalContentRelative) {
      parentData.horizontalRelativeToContent = horizontalContentRelative;
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        if (width != parentData.width &&
            (width is RelativeSize || parentData.width is RelativeSize)) {
          layoutChange |= FlexBoxLayoutChange.both;
          positionChange |= FlexBoxPositionChange.both;
        }
      }
    }
    if (parentData.verticalRelativeToContent != verticalContentRelative) {
      parentData.verticalRelativeToContent = verticalContentRelative;
      if (isAbsolute) {
        positionChange |= FlexBoxPositionChange.absolute;
      } else {
        if (height != parentData.height &&
            (height is RelativeSize || parentData.height is RelativeSize)) {
          layoutChange |= FlexBoxLayoutChange.both;
          positionChange |= FlexBoxPositionChange.both;
        }
      }
    }
    if (parentData.width != width) {
      parentData.width = width;
      if (isAbsolute) {
        layoutChange |= FlexBoxLayoutChange.absolute;
      } else {
        layoutChange |= FlexBoxLayoutChange.both;
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
    if (parentData.horizontalPosition != horizontalPosition) {
      parentData.horizontalPosition = horizontalPosition;
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
    if (alignment != parentData.alignment) {
      parentData.alignment = alignment;
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

    final parent = renderObject.parent as RenderFlexBox;
    if (needsResort) {
      parent.needsResort = true;
      parent.markNeedsPaint();
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
