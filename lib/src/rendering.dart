import 'dart:math';

import 'package:flexiblebox/src/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FlexBoxParentData extends ContainerBoxParentData<RenderBox> {
  BoxPosition? top;
  BoxPosition? bottom;
  BoxPosition? left;
  BoxPosition? right;
  BoxSize? width;
  BoxSize? height;
  Alignment? alignment;
  BoxPositionType? horizontalPosition;
  BoxPositionType? verticalPosition;

  double cachedMainSize = 0;
  double cachedCrossSize = 0;
  double unconstrainedFlex = 0;

  int? zOrder;

  bool debugLayout = false;

  bool get isAbsolute {
    return top != null || bottom != null || left != null || right != null;
  }

  BoxConstraints get constraints {
    return BoxConstraints(
      minWidth: width?.min ?? 0.0,
      maxWidth: width?.max ?? double.infinity,
      minHeight: height?.min ?? 0.0,
      maxHeight: height?.max ?? double.infinity,
    );
  }

  BoxSize? getSize(Axis axis) {
    if (axis == Axis.horizontal) {
      return width;
    } else {
      return height;
    }
  }

  BoxPosition? getStartPosition(Axis axis) {
    if (axis == Axis.horizontal) {
      return left;
    } else {
      return top;
    }
  }

  BoxPosition? getEndPosition(Axis axis) {
    if (axis == Axis.horizontal) {
      return right;
    } else {
      return bottom;
    }
  }

  RenderBox? _nextSortedSibling;
  RenderBox? _previousSortedSibling;
}

class RenderFlexBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexBoxParentData>
    implements RenderAbstractViewport {
  Axis direction;
  double spacing;
  Alignment alignment;
  ViewportOffset horizontal;
  ViewportOffset vertical;
  AxisDirection verticalAxisDirection;
  AxisDirection horizontalAxisDirection;
  bool reverse;
  bool reversePaint;
  bool reverseOffsetX;
  bool reverseOffsetY;
  bool clipPaint;

  RenderFlexBox({
    required this.direction,
    required this.spacing,
    required this.alignment,
    required this.horizontal,
    required this.vertical,
    required this.verticalAxisDirection,
    required this.horizontalAxisDirection,
    required this.reversePaint,
    required this.clipPaint,
    required this.reverse,
    required this.reverseOffsetX,
    required this.reverseOffsetY,
  });

  RenderBox? _firstSortedChild;
  RenderBox? _lastSortedChild;

  RenderBox? get relativeFirstChild {
    return reverse ? lastChild : firstChild;
  }

  RenderBox? get relativeLastChild {
    return reverse ? firstChild : lastChild;
  }

  RenderBox? get relativeFirstPaintChild {
    return reversePaint ? relativeLastChild : relativeFirstChild;
  }

  RenderBox? get relativeLastPaintChild {
    return reversePaint ? relativeFirstChild : relativeLastChild;
  }

  RenderBox? get relativeFirstPaintSortedChild {
    return _firstSortedChild ?? relativeFirstPaintChild;
  }

  RenderBox? get relativeLastPaintSortedChild {
    return _lastSortedChild ?? relativeLastPaintChild;
  }

  RenderBox? relativeSortedNextChild(RenderBox child) {
    if (_firstSortedChild == null) {
      return relativeNextSibling(child);
    }
    final FlexBoxParentData parentData = child.parentData as FlexBoxParentData;
    return reverse
        ? parentData._previousSortedSibling
        : parentData._nextSortedSibling;
  }

  RenderBox? relativeSortedPreviousChild(RenderBox child) {
    if (_firstSortedChild == null) {
      return relativePreviousSibling(child);
    }
    final FlexBoxParentData parentData = child.parentData as FlexBoxParentData;
    return reverse
        ? parentData._nextSortedSibling
        : parentData._previousSortedSibling;
  }

  RenderBox? relativeNextPaintSortedChild(RenderBox child) {
    return reversePaint
        ? relativeSortedPreviousChild(child)
        : relativeSortedNextChild(child);
  }

  RenderBox? relativePreviousPaintSortedChild(RenderBox child) {
    return reversePaint
        ? relativeSortedNextChild(child)
        : relativeSortedPreviousChild(child);
  }

  RenderBox? relativeNextSibling(RenderBox child) {
    final FlexBoxParentData parentData = child.parentData as FlexBoxParentData;
    return reverse ? parentData.previousSibling : parentData.nextSibling;
  }

  RenderBox? relativePreviousSibling(RenderBox child) {
    final FlexBoxParentData parentData = child.parentData as FlexBoxParentData;
    return reverse ? parentData.nextSibling : parentData.previousSibling;
  }

  RenderBox? relativeNextPaintSibling(RenderBox child) {
    return reversePaint
        ? relativePreviousSibling(child)
        : relativeNextSibling(child);
  }

  RenderBox? relativePreviousPaintSibling(RenderBox child) {
    return reversePaint
        ? relativeNextSibling(child)
        : relativePreviousSibling(child);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    vertical.addListener(markNeedsLayout);
    horizontal.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    super.detach();
    vertical.removeListener(markNeedsLayout);
    horizontal.removeListener(markNeedsLayout);
  }

  @override
  void performResize() {
    super.performResize();
    horizontal.applyViewportDimension(size.width);
    vertical.applyViewportDimension(size.height);
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    // It is possible for one and not both axes to allow for implicit scrolling,
    // so handling is split between the options for allowed implicit scrolling.
    final bool allowHorizontal = horizontal.allowImplicitScrolling;
    final bool allowVertical = vertical.allowImplicitScrolling;
    AxisDirection? axisDirection;
    switch ((allowHorizontal, allowVertical)) {
      case (true, true):
        // Both allow implicit scrolling.
        break;
      case (false, true):
        // Only the vertical Axis allows implicit scrolling.
        axisDirection = verticalAxisDirection;
      case (true, false):
        // Only the horizontal Axis allows implicit scrolling.
        axisDirection = horizontalAxisDirection;
      case (false, false):
        // Neither axis allows for implicit scrolling.
        return super.showOnScreen(
          descendant: descendant,
          rect: rect,
          duration: duration,
          curve: curve,
        );
    }

    final Rect? newRect = showInViewport(
      descendant: descendant,
      viewport: this,
      axisDirection: axisDirection,
      rect: rect,
      duration: duration,
      curve: curve,
    );

    super.showOnScreen(rect: newRect, duration: duration, curve: curve);
  }

  static Rect? showInViewport({
    RenderObject? descendant,
    Rect? rect,
    required RenderFlexBox viewport,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    AxisDirection? axisDirection,
  }) {
    if (descendant == null) {
      return rect;
    }

    Rect? showVertical(Rect? rect) {
      return _showInViewportForAxisDirection(
        descendant: descendant,
        viewport: viewport,
        axis: Axis.vertical,
        rect: rect,
        duration: duration,
        curve: curve,
      );
    }

    Rect? showHorizontal(Rect? rect) {
      return _showInViewportForAxisDirection(
        descendant: descendant,
        viewport: viewport,
        axis: Axis.horizontal,
        rect: rect,
        duration: duration,
        curve: curve,
      );
    }

    switch (axisDirection) {
      case AxisDirection.left:
      case AxisDirection.right:
        return showHorizontal(rect);
      case AxisDirection.up:
      case AxisDirection.down:
        return showVertical(rect);
      case null:
        // Update rect after revealing in one axis before revealing in the next.
        rect = showHorizontal(rect) ?? rect;
        // We only return the final rect after both have been revealed.
        rect = showVertical(rect);
        if (rect == null) {
          // `descendant` is between leading and trailing edge and hence already
          //  fully shown on screen.
          assert(viewport.parent != null);
          final Matrix4 transform = descendant.getTransformTo(viewport.parent);
          return MatrixUtils.transformRect(
            transform,
            rect ?? descendant.paintBounds,
          );
        }
        return rect;
    }
  }

  static Rect? _showInViewportForAxisDirection({
    required RenderObject descendant,
    Rect? rect,
    required RenderFlexBox viewport,
    required Axis axis,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final ViewportOffset offset = switch (axis) {
      Axis.vertical => viewport.vertical,
      Axis.horizontal => viewport.horizontal,
    };

    final RevealedOffset leadingEdgeOffset = viewport.getOffsetToReveal(
      descendant,
      0.0,
      rect: rect,
      axis: axis,
    );
    final RevealedOffset trailingEdgeOffset = viewport.getOffsetToReveal(
      descendant,
      1.0,
      rect: rect,
      axis: axis,
    );
    final double currentOffset = offset.pixels;

    final RevealedOffset? targetOffset = RevealedOffset.clampOffset(
      leadingEdgeOffset: leadingEdgeOffset,
      trailingEdgeOffset: trailingEdgeOffset,
      currentOffset: currentOffset,
    );
    if (targetOffset == null) {
      // Already visible in this axis.
      return null;
    }

    offset.moveTo(targetOffset.offset, duration: duration, curve: curve);
    return targetOffset.rect;
  }

  void updateVerticalOffset(ViewportOffset offset) {
    if (vertical != offset) {
      if (attached) {
        vertical.removeListener(markNeedsLayout);
      }
      vertical = offset;
      if (attached) {
        vertical.addListener(markNeedsLayout);
      }
    }
  }

  void updateHorizontalOffset(ViewportOffset offset) {
    if (horizontal != offset) {
      if (attached) {
        horizontal.removeListener(markNeedsLayout);
      }
      horizontal = offset;
      if (attached) {
        horizontal.addListener(markNeedsLayout);
      }
    }
  }

  Offset get viewportOffset {
    return Offset(horizontal.pixels, vertical.pixels);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! FlexBoxParentData) {
      child.parentData = FlexBoxParentData();
    }
  }

  Axis get crossDirection {
    return direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
  }

  double _computeMaxIntrinsicMain(RenderBox child, double crossSize) {
    return direction == Axis.horizontal
        ? child.getMaxIntrinsicWidth(crossSize)
        : child.getMaxIntrinsicHeight(crossSize);
  }

  double _computeMaxIntrinsicCross(RenderBox child, double mainSize) {
    return direction == Axis.horizontal
        ? child.getMaxIntrinsicHeight(mainSize)
        : child.getMaxIntrinsicWidth(mainSize);
  }

  double _getMinCross(FlexBoxParentData layoutData) {
    return layoutData.getSize(crossDirection)?.min ?? 0.0;
  }

  double _getMaxCross(FlexBoxParentData layoutData) {
    return layoutData.getSize(crossDirection)?.max ?? double.infinity;
  }

  Size _createSize(double mainSize, double crossSize) {
    return direction == Axis.horizontal
        ? Size(mainSize, crossSize)
        : Size(crossSize, mainSize);
  }

  void _layoutChild(RenderBox child, Size size) {
    final parent = child.parentData as FlexBoxParentData;
    if (kDebugMode) {
      assert(
        !parent.debugLayout,
        'Child ${child.runtimeType} is already laid out. Details: ${parent.top}, ${parent.bottom}, ${parent.left}, ${parent.right}, ${parent.width}, ${parent.height}',
      );
      parent.debugLayout = true;
    }
    child.layout(BoxConstraints.tight(size), parentUsesSize: true);
  }

  @override
  void performLayout() {
    BoxConstraints constraints = this.constraints;
    constraints = BoxConstraints.tight(constraints.smallest);
    _firstSortedChild = null;
    _lastSortedChild = null;

    if (kDebugMode) {
      RenderBox? firstChild = relativeFirstChild;
      while (firstChild != null) {
        var layoutData = firstChild.parentData as FlexBoxParentData;
        layoutData.debugLayout = false;
        firstChild = relativeNextSibling(firstChild);
      }
    }
    var shouldSortChildren = false;
    var hasCrossFlex = false;
    var child = relativeFirstChild;
    var totalFlex = 0.0;
    var maxCrossFlex = 0.0;
    var totalFixedSize = 0.0;
    var totalAffectedChildren = 0;
    var biggestFlex = 0.0;
    var totalSize = direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    var crossSize = direction == Axis.horizontal
        ? constraints.maxHeight
        : constraints.maxWidth;
    var maxViewportCrossSize = crossSize;

    // First pass:
    // In this pass, we count all flexible children (i.e. how many are there and the total flex value).
    // If its an intrinsic size, we compute the maximum intrinsic size.
    // If its a fixed size, we add it to the total fixed size, and we lay it out immediately.
    // Unless its cross size is unconstrained or flexible, we skip it.

    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      layoutData.cachedMainSize = 0;
      layoutData.cachedCrossSize = 0;
      layoutData.unconstrainedFlex = 0;
      shouldSortChildren = shouldSortChildren || layoutData.zOrder != null;
      layoutData._nextSortedSibling = null;
      layoutData._previousSortedSibling = null;
      if (!layoutData.isAbsolute) {
        totalAffectedChildren++;
        var mainSizeConstraint = layoutData.getSize(direction);
        var crossSizeConstraint = layoutData.getSize(crossDirection);
        double mainChildSize;
        if (mainSizeConstraint is FixedSize) {
          mainChildSize = mainSizeConstraint.size;
        } else if (mainSizeConstraint is IntrinsicSize) {
          mainChildSize = _computeMaxIntrinsicMain(child, crossSize);
        } else if (mainSizeConstraint is RelativeSize) {
          mainChildSize = mainSizeConstraint.relative * totalSize;
        } else if (mainSizeConstraint is FlexSize) {
          totalFlex += mainSizeConstraint.flex;
          biggestFlex = max(biggestFlex, mainSizeConstraint.flex);
          child = relativeNextSibling(child);
          continue;
        } else if (mainSizeConstraint is RatioSize) {
          mainChildSize = 0;
          // skip this for now
        } else if (mainSizeConstraint is UnconstrainedSize) {
          totalAffectedChildren++;
          child = relativeNextSibling(child);
          continue;
        } else {
          throw ArgumentError(
            'Invalid main size constraint: $mainSizeConstraint',
          );
        }
        layoutData.cachedMainSize = mainChildSize;

        double crossChildSize;
        if (crossSizeConstraint is FixedSize) {
          crossChildSize = crossSizeConstraint.size;
          maxViewportCrossSize = max(maxViewportCrossSize, crossChildSize);
        } else if (crossSizeConstraint is IntrinsicSize) {
          crossChildSize = _computeMaxIntrinsicCross(child, totalSize);
          maxViewportCrossSize = max(maxViewportCrossSize, crossChildSize);
        } else if (crossSizeConstraint is RelativeSize) {
          crossChildSize = crossSizeConstraint.relative * crossSize;
          maxViewportCrossSize = max(maxViewportCrossSize, crossChildSize);
        } else if (crossSizeConstraint is FlexSize) {
          hasCrossFlex = true;
          maxCrossFlex = max(maxCrossFlex, crossSizeConstraint.flex);
          child = relativeNextSibling(child);
          continue;
        } else if (crossSizeConstraint is UnconstrainedSize) {
          hasCrossFlex = true;
          maxCrossFlex = max(maxCrossFlex, 1.0);
          child = relativeNextSibling(child);
          continue;
        } else if (crossSizeConstraint is RatioSize) {
          assert(
            mainChildSize is! RatioSize,
            'RatioSize cannot be used with RatioSize for main size',
          );
          crossChildSize = mainChildSize * crossSizeConstraint.ratio;
          // skip this for now
        } else {
          throw ArgumentError(
            'Invalid cross size constraint: $crossSizeConstraint',
          );
        }
        if (mainSizeConstraint is RatioSize) {
          var aspectRatio = mainSizeConstraint.ratio;
          mainChildSize = crossChildSize * aspectRatio;
          layoutData.cachedMainSize = mainChildSize;
        }
        var crossMin = _getMinCross(layoutData);
        var crossMax = _getMaxCross(layoutData);
        crossChildSize = _clampIgnoreSign(crossChildSize, crossMin, crossMax);
        layoutData.cachedCrossSize = crossChildSize;
        var childSize = _createSize(mainChildSize, crossChildSize);
        _layoutChild(child, childSize);
        totalFixedSize += mainChildSize;
      } else {
        double top;
        double left;
        double width;
        double height;
        var dataLeft = layoutData.left;
        var dataRight = layoutData.right;
        var dataTop = layoutData.top;
        var dataBottom = layoutData.bottom;
        var dataWidth = layoutData.width;
        var dataHeight = layoutData.height;
        if (dataWidth != null) {
          if (dataWidth is FixedSize) {
            width = dataWidth.size;
          } else if (dataWidth is RelativeSize) {
            width = dataWidth.relative * constraints.maxWidth;
          } else if (dataWidth is RatioSize) {
            assert(
              dataHeight is! RatioSize,
              'RatioSize cannot be used with RatioSize for height',
            );
            width = 0; // skip this for now
          } else {
            throw ArgumentError('Invalid width constraint: $dataWidth');
          }
        } else if (dataLeft != null && dataRight != null) {
          width =
              constraints.maxWidth -
              dataLeft.computePosition(constraints.maxWidth) -
              dataRight.computePosition(constraints.maxWidth);
        } else {
          width = child.computeMaxIntrinsicWidth(constraints.maxHeight);
        }
        if (dataHeight != null) {
          if (dataHeight is FixedSize) {
            height = dataHeight.size;
          } else if (dataHeight is RelativeSize) {
            height = dataHeight.relative * constraints.maxHeight;
          } else if (dataHeight is RatioSize) {
            assert(
              dataWidth is! RatioSize,
              'RatioSize cannot be used with RatioSize for width',
            );
            height = 0; // skip this for now
          } else {
            throw ArgumentError('Invalid height constraint: $dataHeight');
          }
        } else if (dataTop != null && dataBottom != null) {
          height =
              constraints.maxHeight -
              dataTop.computePosition(constraints.maxHeight) -
              dataBottom.computePosition(constraints.maxHeight);
        } else {
          height = child.computeMaxIntrinsicHeight(constraints.maxWidth);
        }
        if (dataWidth is RatioSize) {
          width = height * dataWidth.ratio;
        } else if (dataHeight is RatioSize) {
          height = width / dataHeight.ratio;
        }
        if (dataTop != null) {
          top = dataTop.computePosition(constraints.maxHeight);
        } else if (dataBottom != null) {
          top =
              constraints.maxHeight -
              height -
              dataBottom.computePosition(constraints.maxHeight);
        } else {
          top = 0.0;
        }
        if (dataLeft != null) {
          left = dataLeft.computePosition(constraints.maxWidth);
        } else if (dataRight != null) {
          left =
              constraints.maxWidth -
              width -
              dataRight.computePosition(constraints.maxWidth);
        } else {
          left = 0.0;
        }
        if (width.isNegative) {
          left -= width;
        }
        if (height.isNegative) {
          top -= height;
        }
        _layoutChild(
          child,
          _constrainIgnoreSign(Size(width, height), layoutData.constraints),
        );
        layoutData.offset = Offset(left, top);
      }
      child = relativeNextSibling(child);
    }

    // Second pass:
    // Convert UnconstrainedSize to FlexSize with the biggest flex value.
    // No layout is done in this pass, just conversion.

    child = relativeFirstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        var mainSizeConstraint = layoutData.getSize(direction);
        if (mainSizeConstraint is UnconstrainedSize) {
          layoutData.unconstrainedFlex = biggestFlex == 0 ? 1.0 : biggestFlex;
          totalFlex += biggestFlex;
          totalAffectedChildren++;
        }
      }
      child = relativeNextSibling(child);
    }

    // Third pass:
    // If there are any children with cross flex, we need to layout them.
    if (hasCrossFlex) {
      child = relativeFirstChild;
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (!layoutData.isAbsolute) {
          var crossSizeConstraint = layoutData.getSize(crossDirection);
          var mainSizeConstraint = layoutData.getSize(direction);
          if (crossSizeConstraint is FlexSize) {
            var flex = crossSizeConstraint.flex;
            var crossChildSize = (flex / maxCrossFlex) * maxViewportCrossSize;
            var minCross = _getMinCross(layoutData);
            var maxCross = _getMaxCross(layoutData);
            crossChildSize = _clampIgnoreSign(
              crossChildSize,
              minCross,
              maxCross,
            );
            var mainChildSize = layoutData.cachedMainSize;
            totalFixedSize += mainChildSize;
            if (mainSizeConstraint is FlexSize ||
                mainSizeConstraint is UnconstrainedSize) {
              // Lay out later
              layoutData.cachedCrossSize = crossChildSize;
            } else {
              var childSize = _createSize(mainChildSize, crossChildSize);
              _layoutChild(child, childSize);
            }
          } else if (crossSizeConstraint is UnconstrainedSize) {
            var crossChildSize = maxViewportCrossSize;
            var mainChildSize = layoutData.cachedMainSize;
            var minCross = _getMinCross(layoutData);
            var maxCross = _getMaxCross(layoutData);
            crossChildSize = _clampIgnoreSign(
              crossChildSize,
              minCross,
              maxCross,
            );
            totalFixedSize += mainChildSize;
            if (mainSizeConstraint is FlexSize ||
                mainSizeConstraint is UnconstrainedSize) {
              // Lay out later
              layoutData.cachedCrossSize = crossChildSize;
            } else {
              var childSize = _createSize(mainChildSize, crossChildSize);
              _layoutChild(child, childSize);
            }
          }
        }
        child = relativeNextSibling(child);
      }
    }

    var totalGap = totalAffectedChildren > 1
        ? spacing * (totalAffectedChildren - 1)
        : 0.0;
    var autoGap = false;
    var gap = spacing;
    if (totalGap.isInfinite) {
      gap = 0.0;
      totalGap = 0.0;
      autoGap = true;
    }

    var totalUsedMainSize = totalFixedSize + totalGap;
    var remainingSpace = totalSize - totalUsedMainSize;

    child = relativeFirstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        var mainSizeConstraint = layoutData.getSize(direction);
        if (mainSizeConstraint is FlexSize ||
            mainSizeConstraint is UnconstrainedSize) {
          // Main

          final mainFlex = layoutData.unconstrainedFlex > 0
              ? layoutData.unconstrainedFlex
              : biggestFlex;

          var mainChildSize = (mainFlex / totalFlex) * max(remainingSpace, 0);
          final minMain = mainSizeConstraint?.min ?? 0.0;
          final maxMain = mainSizeConstraint?.max ?? double.infinity;
          mainChildSize = _clampIgnoreSign(mainChildSize, minMain, maxMain);
          layoutData.cachedMainSize = mainChildSize;

          // Cross
          var crossChildConstraint = layoutData.getSize(crossDirection);
          double crossChildSize;
          if (crossChildConstraint is FixedSize) {
            crossChildSize = crossChildConstraint.size;
          } else if (crossChildConstraint is IntrinsicSize) {
            crossChildSize = _computeMaxIntrinsicCross(child, totalSize);
          } else if (crossChildConstraint is UnconstrainedSize) {
            crossChildSize = maxViewportCrossSize;
          } else if (crossChildConstraint is FlexSize) {
            crossChildSize = crossChildConstraint.flex * maxViewportCrossSize;
          } else if (crossChildConstraint is RelativeSize) {
            crossChildSize =
                crossChildConstraint.relative * maxViewportCrossSize;
          } else if (crossChildConstraint is RatioSize) {
            assert(
              mainSizeConstraint is! RatioSize,
              'RatioSize cannot be used with RatioSize for main size',
            );
            crossChildSize =
                layoutData.cachedMainSize * crossChildConstraint.ratio;
          } else {
            throw ArgumentError(
              'Invalid cross size constraint: $crossChildConstraint',
            );
          }
          var crossMin = _getMinCross(layoutData);
          var crossMax = _getMaxCross(layoutData);
          crossChildSize = _clampIgnoreSign(crossChildSize, crossMin, crossMax);
          layoutData.cachedCrossSize = crossChildSize;
          var childSize = _createSize(
            layoutData.cachedMainSize,
            crossChildSize,
          );
          _layoutChild(child, childSize);
        }
      }
      child = relativeNextSibling(child);
    }

    var usedMainSize = 0.0;
    var usedCrossSize = 0.0;
    child = relativeFirstChild;
    bool first = true;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        if (first) {
          usedMainSize += _getMain(child.size);
          first = false;
        } else {
          usedMainSize += _getMain(child.size) + gap;
        }
        usedCrossSize = max(usedCrossSize, _getCross(child.size));
      }
      child = relativeNextSibling(child);
    }

    if (autoGap) {
      double remainingSpace = totalSize - usedMainSize;
      if (remainingSpace > 0) {
        gap = remainingSpace / (totalAffectedChildren - 1);
        usedMainSize += gap * (totalAffectedChildren - 1);
      } else {
        gap = 0.0;
      }
    }

    // Content size
    final usedSize = _createSize(usedMainSize, usedCrossSize);
    // viewport size
    final viewportSize = constraints.biggest;

    double crossMaxSize = max(_getCross(usedSize), _getCross(viewportSize));
    double mainMaxSize = max(_getMain(usedSize), _getMain(viewportSize));

    double mainOffset = _alignValue(
      alignment: _mainAlignment,
      min: 0.0,
      max: mainMaxSize - usedMainSize,
    );

    double horizontalPixels = horizontal.pixels;
    double verticalPixels = vertical.pixels;

    Offset viewportOffset = Offset(horizontalPixels, verticalPixels);

    Offset relativeViewportOffset = Offset(
      reverseOffsetX && usedSize.width > viewportSize.width
          ? usedSize.width - viewportSize.width - horizontalPixels
          : horizontalPixels,
      reverseOffsetY && usedSize.height > viewportSize.height
          ? usedSize.height - viewportSize.height - verticalPixels
          : verticalPixels,
    );

    viewportOffset = relativeViewportOffset;

    child = relativeFirstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        double childCrossOffset = _alignValue(
          min: 0.0,
          max: crossMaxSize - _getCross(child.size),
          alignment: _crossAlignment,
        );
        layoutData.offset = _createOffset(mainOffset, childCrossOffset);
        mainOffset += _getMain(child.size) + gap;
      }

      var horizontalType = layoutData.horizontalPosition;
      var verticalType = layoutData.verticalPosition;

      if (reverseOffsetX) {
        switch (horizontalType) {
          case BoxPositionType.stickyStart:
            horizontalType = BoxPositionType.stickyEnd;
            break;
          case BoxPositionType.stickyEnd:
            horizontalType = BoxPositionType.stickyStart;
            break;
          default:
            break;
        }
      }
      if (reverseOffsetY) {
        switch (verticalType) {
          case BoxPositionType.stickyStart:
            verticalType = BoxPositionType.stickyEnd;
            break;
          case BoxPositionType.stickyEnd:
            verticalType = BoxPositionType.stickyStart;
            break;
          default:
            break;
        }
      }

      var horizontal = layoutData.offset.dx;
      var vertical = layoutData.offset.dy;
      if (horizontalType == BoxPositionType.fixed) {
        horizontal += viewportOffset.dx;
      } else if (horizontalType == BoxPositionType.sticky) {
        if (layoutData.right != null) {
          // right excess first
          double rightExcess = max(
            0,
            -((relativeViewportOffset.dx + constraints.maxWidth) -
                (horizontal + child.size.width)),
          );
          horizontal -= rightExcess;
          double leftExcess = max(0, relativeViewportOffset.dx - horizontal);
          horizontal += leftExcess;
        } else {
          double leftExcess = max(0, relativeViewportOffset.dx - horizontal);
          horizontal += leftExcess;
          double rightExcess = max(
            0,
            -((relativeViewportOffset.dx + constraints.maxWidth) -
                (horizontal + child.size.width)),
          );
          horizontal -= rightExcess;
        }
      } else if (horizontalType == BoxPositionType.stickyStart) {
        double leftExcess = max(0, relativeViewportOffset.dx - horizontal);
        horizontal += leftExcess;
      } else if (horizontalType == BoxPositionType.stickyEnd) {
        double rightExcess = max(
          0,
          -((relativeViewportOffset.dx + constraints.maxWidth) -
              (horizontal + child.size.width)),
        );
        horizontal -= rightExcess;
      }
      if (verticalType == BoxPositionType.fixed) {
        vertical += viewportOffset.dy;
      } else if (verticalType == BoxPositionType.sticky) {
        if (layoutData.bottom != null) {
          // bottom excess first
          double bottomExcess = max(
            0,
            -((relativeViewportOffset.dy + constraints.maxHeight) -
                (vertical + child.size.height)),
          );
          vertical -= bottomExcess;
          double topExcess = max(0, relativeViewportOffset.dy - vertical);
          vertical += topExcess;
        } else {
          double topExcess = max(0, relativeViewportOffset.dy - vertical);
          vertical += topExcess;
          double bottomExcess = max(
            0,
            -((relativeViewportOffset.dy + constraints.maxHeight) -
                (vertical + child.size.height)),
          );
          vertical -= bottomExcess;
        }
      } else if (verticalType == BoxPositionType.stickyStart) {
        double topExcess = max(0, relativeViewportOffset.dy - vertical);
        vertical += topExcess;
      } else if (verticalType == BoxPositionType.stickyEnd) {
        double bottomExcess = max(
          0,
          -((relativeViewportOffset.dy + constraints.maxHeight) -
              (vertical + child.size.height)),
        );
        vertical -= bottomExcess;
      }

      layoutData.offset = Offset(
        horizontal - relativeViewportOffset.dx,
        vertical - relativeViewportOffset.dy,
      );

      child = relativeNextSibling(child);
    }
    double viewportMinWidth = _getMain(constraints.smallest);
    double viewportMinHeight = _getCross(constraints.smallest);
    if (usedMainSize < viewportMinWidth) {
      usedMainSize = viewportMinWidth;
    }
    if (usedCrossSize < viewportMinHeight) {
      usedCrossSize = viewportMinHeight;
    }
    size = this.constraints.constrain(_createSize(usedMainSize, usedCrossSize));

    horizontal.applyViewportDimension(size.width);
    vertical.applyViewportDimension(size.height);

    horizontal.applyContentDimensions(
      0,
      (usedSize.width - size.width).clamp(0, double.infinity),
    );
    vertical.applyContentDimensions(
      0,
      (usedSize.height - size.height).clamp(0, double.infinity),
    );
    if (shouldSortChildren) {
      _sortChildren();
    }
  }

  void _sortChildren() {
    if (childCount <= 1) {
      _firstSortedChild = firstChild;
      _lastSortedChild = lastChild;
      if (firstChild != null) {
        final parentData = firstChild!.parentData as FlexBoxParentData;
        parentData._nextSortedSibling = null;
        parentData._previousSortedSibling = null;
      }
      return;
    }

    RenderBox? headOfListToSort;

    // Check if we should only consider visible children.
    if (clipPaint) {
      // Build a new linked list containing ONLY visible children.
      RenderBox? visibleHead;
      RenderBox? visibleTail;
      RenderBox? current = firstChild;

      while (current != null) {
        final parentData = current.parentData as FlexBoxParentData;
        // Clear any previous sorted links.
        parentData._nextSortedSibling = null;
        parentData._previousSortedSibling = null;

        // Add the child to our list only if it's visible.
        if (!_childOutOfViewport(current)) {
          if (visibleHead == null) {
            visibleHead = current;
            visibleTail = current;
          } else {
            (visibleTail!.parentData as FlexBoxParentData)._nextSortedSibling =
                current;
            visibleTail = current;
          }
        }
        current = parentData.nextSibling;
      }
      headOfListToSort = visibleHead;
    } else {
      // If not clipping, build the list with ALL children as before.
      RenderBox? current = firstChild;
      while (current != null) {
        final parentData = current.parentData as FlexBoxParentData;
        parentData._nextSortedSibling = parentData.nextSibling;
        current = parentData.nextSibling;
      }
      headOfListToSort = firstChild;
    }

    // If there are no children to sort (e.g., all were clipped), we're done.
    if (headOfListToSort == null) {
      _firstSortedChild = null;
      _lastSortedChild = null;
      return;
    }

    // 1. Sort the prepared list (which contains either all or only visible children).
    _firstSortedChild = _mergeSort(headOfListToSort);

    // 2. Traverse the now-sorted list to fix the backward links and find the tail.
    _lastSortedChild = null;
    RenderBox? prev;
    RenderBox? current = _firstSortedChild;
    while (current != null) {
      final parentData = current.parentData as FlexBoxParentData;
      parentData._previousSortedSibling = prev;
      if ((parentData._nextSortedSibling) == null) {
        _lastSortedChild = current;
      }
      prev = current;
      current = parentData._nextSortedSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = relativeFirstPaintSortedChild;
    while (child != null) {
      final childParentData = child.parentData as FlexBoxParentData;
      if (clipPaint &&
          _childOutOfViewport(child) &&
          _firstSortedChild == null) {
        child = relativeNextPaintSortedChild(child);
        continue;
      }
      context.paintChild(child, childParentData.offset + offset);
      child = relativeNextPaintSortedChild(child);
    }
  }

  bool _childOutOfViewport(RenderBox child) {
    final viewportSize = constraints.biggest;
    final layoutData = child.parentData as FlexBoxParentData;
    final childOffset = layoutData.offset;
    final childSize = child.size;
    final viewportBounds = Offset.zero & viewportSize;
    final childBounds = childOffset & childSize;
    return !viewportBounds.overlaps(childBounds);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = relativeLastPaintSortedChild;
    while (child != null) {
      final childParentData = child.parentData! as FlexBoxParentData;
      if (clipPaint &&
          _childOutOfViewport(child) &&
          _firstSortedChild == null) {
        child = relativePreviousPaintSortedChild(child);
        continue;
      }

      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = relativePreviousPaintSortedChild(child);
    }
    return false;
  }

  Offset _createOffset(double mainOffset, double crossOffset) {
    return direction == Axis.horizontal
        ? Offset(mainOffset, crossOffset)
        : Offset(crossOffset, mainOffset);
  }

  double _getMain(Size size) {
    return direction == Axis.horizontal ? size.width : size.height;
  }

  double _getCross(Size size) {
    return direction == Axis.horizontal ? size.height : size.width;
  }

  double get _mainAlignment {
    return direction == Axis.horizontal ? alignment.x : alignment.y;
  }

  double get _crossAlignment {
    return direction == Axis.horizontal ? alignment.y : alignment.x;
  }

  double _computeIntrinsicSize(
    double size,
    double Function(RenderBox item, double size) computeIntrinsicSize,
    double Function() computeCrossIntrinsicSize,
  ) {
    var totalSpacing = 0;
    RenderBox? child = firstChild;
    var totalSize = 0.0;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        var mainSizeConstraint = layoutData.getSize(direction);
        double childSize;
        if (mainSizeConstraint is FixedSize) {
          childSize = mainSizeConstraint.size;
        } else if (mainSizeConstraint is IntrinsicSize) {
          childSize = computeIntrinsicSize(child, size);
        } else if (mainSizeConstraint is UnconstrainedSize) {
          childSize = 0.0;
        } else if (mainSizeConstraint is RelativeSize) {
          childSize = 0.0;
        } else if (mainSizeConstraint is FlexSize) {
          childSize = 0.0;
          continue;
        } else if (mainSizeConstraint is RatioSize) {
          childSize = mainSizeConstraint.ratio * size;
        } else {
          throw ArgumentError(
            'Invalid main size constraint: $mainSizeConstraint',
          );
        }
        var minSize = mainSizeConstraint?.min ?? 0.0;
        var maxSize = mainSizeConstraint?.max ?? double.infinity;
        childSize = _clampIgnoreSign(childSize, minSize, maxSize);
        totalSize += childSize;
        totalSpacing++;
      }
      child = (child.parentData as FlexBoxParentData).nextSibling;
    }
    if (totalSpacing > 0) {
      totalSize += spacing * (totalSpacing - 1);
    }
    return totalSize;
  }

  double _computeCrossIntrinsicSize(
    double size,
    double Function(RenderBox item, double size) computeIntrinsicSize,
    double Function() computeCrossIntrinsicSize,
  ) {
    var totalSize = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        var crossSizeConstraint = layoutData.getSize(crossDirection);
        double childSize;
        if (crossSizeConstraint is FixedSize) {
          childSize = crossSizeConstraint.size;
        } else if (crossSizeConstraint is IntrinsicSize) {
          childSize = computeIntrinsicSize(child, size);
        } else if (crossSizeConstraint is UnconstrainedSize) {
          childSize = 0.0;
        } else if (crossSizeConstraint is RelativeSize) {
          childSize = 0.0;
        } else if (crossSizeConstraint is FlexSize) {
          childSize = 0.0;
          continue;
        } else if (crossSizeConstraint is RatioSize) {
          childSize = computeCrossIntrinsicSize() * crossSizeConstraint.ratio;
        } else {
          throw ArgumentError(
            'Invalid cross size constraint: $crossSizeConstraint',
          );
        }
        var minSize = crossSizeConstraint?.min ?? 0.0;
        var maxSize = crossSizeConstraint?.max ?? double.infinity;
        childSize = _clampIgnoreSign(childSize, minSize, maxSize);
        totalSize = max(totalSize, childSize);
      }
      child = (child.parentData as FlexBoxParentData).nextSibling;
    }
    return totalSize;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return direction == Axis.horizontal
        ? _computeIntrinsicSize(
            width,
            (item, size) => item.getMaxIntrinsicHeight(size),
            () => computeMaxIntrinsicWidth(double.infinity),
          )
        : _computeCrossIntrinsicSize(
            width,
            (item, size) => item.getMaxIntrinsicHeight(size),
            () => computeMaxIntrinsicWidth(double.infinity),
          );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return direction == Axis.horizontal
        ? _computeCrossIntrinsicSize(
            height,
            (item, size) => item.getMaxIntrinsicWidth(size),
            () => computeMaxIntrinsicHeight(double.infinity),
          )
        : _computeIntrinsicSize(
            height,
            (item, size) => item.getMaxIntrinsicWidth(size),
            () => computeMaxIntrinsicHeight(double.infinity),
          );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return direction == Axis.horizontal
        ? _computeIntrinsicSize(
            width,
            (item, size) => item.getMinIntrinsicHeight(size),
            () => computeMinIntrinsicWidth(double.infinity),
          )
        : _computeCrossIntrinsicSize(
            width,
            (item, size) => item.getMinIntrinsicHeight(size),
            () => computeMinIntrinsicWidth(double.infinity),
          );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return direction == Axis.horizontal
        ? _computeCrossIntrinsicSize(
            height,
            (item, size) => item.getMinIntrinsicWidth(size),
            () => computeMinIntrinsicHeight(double.infinity),
          )
        : _computeIntrinsicSize(
            height,
            (item, size) => item.getMinIntrinsicWidth(size),
            () => computeMinIntrinsicHeight(double.infinity),
          );
  }

  int _compareChildren(RenderBox a, RenderBox b) {
    final aParentData = a.parentData as FlexBoxParentData;
    final bParentData = b.parentData as FlexBoxParentData;

    final aZOrder = aParentData.zOrder ?? 0;
    final bZOrder = bParentData.zOrder ?? 0;

    if (aZOrder != bZOrder) {
      return aZOrder.compareTo(bZOrder);
    }
    return 0;
  }

  // In RenderFlexBox class

  // +++ NEW HELPER METHOD +++

  // +++ NEW HELPER METHOD +++
  /// Merges two sorted linked lists. This is a helper for the merge sort.
  RenderBox? _merge(RenderBox? a, RenderBox? b) {
    if (a == null) return b;
    if (b == null) return a;

    RenderBox? result;

    // The `<= 0` check ensures the sort is stable, meaning children that
    // are "equal" will maintain their original relative order.
    if (_compareChildren(a, b) <= 0) {
      result = a;
      (a.parentData as FlexBoxParentData)._nextSortedSibling = _merge(
        (a.parentData as FlexBoxParentData)._nextSortedSibling,
        b,
      );
    } else {
      result = b;
      (b.parentData as FlexBoxParentData)._nextSortedSibling = _merge(
        a,
        (b.parentData as FlexBoxParentData)._nextSortedSibling,
      );
    }
    return result;
  }

  RenderBox? _getMiddle(RenderBox? head) {
    if (head == null) return head;

    RenderBox? slow = head;
    RenderBox? fast = (head.parentData as FlexBoxParentData)._nextSortedSibling;

    while (fast != null) {
      fast = (fast.parentData as FlexBoxParentData)._nextSortedSibling;
      if (fast != null) {
        slow = (slow!.parentData as FlexBoxParentData)._nextSortedSibling;
        fast = (fast.parentData as FlexBoxParentData)._nextSortedSibling;
      }
    }
    return slow;
  }

  RenderBox? _mergeSort(RenderBox? head) {
    if (head == null ||
        (head.parentData as FlexBoxParentData)._nextSortedSibling == null) {
      return head;
    }

    RenderBox? middle = _getMiddle(head);
    RenderBox? nextOfMiddle =
        (middle!.parentData as FlexBoxParentData)._nextSortedSibling;

    // Split the list into two halves.
    (middle.parentData as FlexBoxParentData)._nextSortedSibling = null;

    RenderBox? left = _mergeSort(head);
    RenderBox? right = _mergeSort(nextOfMiddle);

    return _merge(left, right);
  }

  @override
  RevealedOffset getOffsetToReveal(
    RenderObject target,
    double alignment, {
    Rect? rect,
    Axis? axis,
  }) {
    axis ??= direction;

    final (double offset, AxisDirection axisDirection) = switch (axis) {
      Axis.vertical => (vertical.pixels, verticalAxisDirection),
      Axis.horizontal => (horizontal.pixels, horizontalAxisDirection),
    };

    rect ??= target.paintBounds;
    RenderObject child = target;
    while (child.parent != this) {
      child = child.parent!;
    }

    assert(child.parent == this);
    final RenderBox box = child as RenderBox;
    final Rect rectLocal = MatrixUtils.transformRect(
      target.getTransformTo(child),
      rect,
    );

    double leadingScrollOffset = offset;

    leadingScrollOffset += switch (axisDirection) {
      AxisDirection.up => child.size.height - rectLocal.bottom,
      AxisDirection.left => child.size.width - rectLocal.right,
      AxisDirection.right => rectLocal.left,
      AxisDirection.down => rectLocal.top,
    };

    // The scroll offset in the viewport to `rect`.
    final Offset paintOffset = (box.parentData as FlexBoxParentData)
        .offset; // This is the offset of the box within the viewport.
    leadingScrollOffset += switch (axisDirection) {
      AxisDirection.up => size.height - paintOffset.dy - box.size.height,
      AxisDirection.left => size.width - paintOffset.dx - box.size.width,
      AxisDirection.right => paintOffset.dx,
      AxisDirection.down => paintOffset.dy,
    };

    final Matrix4 transform = target.getTransformTo(this);
    Rect targetRect = MatrixUtils.transformRect(transform, rect);

    final double mainAxisExtentDifference = switch (axis) {
      Axis.horizontal => size.width - rectLocal.width,
      Axis.vertical => size.height - rectLocal.height,
    };

    final double targetOffset =
        leadingScrollOffset - mainAxisExtentDifference * alignment;

    final double offsetDifference = switch (axis) {
      Axis.horizontal => horizontal.pixels - targetOffset,
      Axis.vertical => vertical.pixels - targetOffset,
    };

    targetRect = switch (axisDirection) {
      AxisDirection.up => targetRect.translate(0.0, -offsetDifference),
      AxisDirection.down => targetRect.translate(0.0, offsetDifference),
      AxisDirection.left => targetRect.translate(-offsetDifference, 0.0),
      AxisDirection.right => targetRect.translate(offsetDifference, 0.0),
    };

    final RevealedOffset revealedOffset = RevealedOffset(
      offset: targetOffset,
      rect: targetRect,
    );
    return revealedOffset;
  }
}

double _clampIgnoreSign(double value, double min, double max) {
  if (value.isNegative) {
    return value < -max
        ? -max
        : value > -min
        ? -min
        : value;
  } else {
    return value < min
        ? min
        : value > max
        ? max
        : value;
  }
}

Size _constrainIgnoreSign(Size size, BoxConstraints? constraints) {
  if (constraints == null) {
    return size;
  }
  double minWidth = constraints.minWidth;
  double minHeight = constraints.minHeight;
  double maxWidth = constraints.maxWidth;
  double maxHeight = constraints.maxHeight;
  return Size(
    _clampIgnoreSign(size.width, minWidth, maxWidth),
    _clampIgnoreSign(size.height, minHeight, maxHeight),
  );
}

double _alignValue({
  required double min,
  required double max,
  required double alignment,
}) {
  final center = (min + max) / 2;
  final halfRange = (max - min) / 2;
  return center + (halfRange * alignment);
}
