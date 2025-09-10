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
  BoxSize? width = BoxSize.intrinsic();
  BoxSize? height = BoxSize.intrinsic();
  Alignment? alignment;
  BoxPositionType? horizontalPosition;
  BoxPositionType? verticalPosition;

  // double cachedMainSize = 0;
  // double cachedCrossSize = 0;
  // double unconstrainedFlex = 0;
  // double mainFlex = 0; // Store the actual flex value from FlexSize
  // bool isConstrainedByMinMax =
  //     false; // Track if this child is constrained by min/max

  double? resolvedMainSize;
  double? resolvedCrossSize;
  double? resolvedMainStart;
  double? resolvedCrossStart;
  double? resolvedMainEnd;
  double? resolvedCrossEnd;

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

  BoxPositionType? getPositionType(Axis axis) {
    if (axis == Axis.horizontal) {
      return horizontalPosition;
    } else {
      return verticalPosition;
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

  double _getMinMain(FlexBoxParentData layoutData) {
    return layoutData.getSize(direction)?.min ?? 0.0;
  }

  double _getMaxMain(FlexBoxParentData layoutData) {
    return layoutData.getSize(direction)?.max ?? double.infinity;
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
    _layoutChildren();
    _positionsChildren();
  }

  double _maxNullable(double? a, double b) {
    if (a == null) return b;
    return max(a, b);
  }

  ({double mainContentSize, double crossContentSize}) _layoutChildren() {
    /*
    Note:
    - Absolute children does not affect size
    - BoxSizes are (7):
      - IntrinsicSize
        Intrinsic depends on cross axis size, so if cross axis size
        is not resolved, resolve it in the next pass until cross
        axis size is resolved.
      - FixedSize (does not have min/max)
        Fixed size can be resolved immediately
      - UnconstrainedSize
        Unconstrained size acts as the biggest flex, if there are flex
        children (flex: 1, and flex: 2), then the unconstrained size
        has flex: 2, but if there are no flex children, then unconstrained
        size has flex: 1. But if constrained is on the cross axis, then
        the unconstrained size resolves to the max cross size, which means
        UnconstrainedSize can be resolved immediately if the max cross size
        is done resolved.
      - RatioSize
        Ratio depends on cross axis size
      - RelativeSize
        Relative can be resolved immediately if the parent size is known
      - FlexSize
        Flex size depends on available space after fixed and unconstrained
        sizes are resolved, and also depends on min/max constraints. If flex
        is on the cross size, it acts like RelativeContentSize, which depends
        on the max cross size. BUT if the spaceRemaining is infinite,
        we resolve flex
      - RelativeContentSize
        Similar to RelativeSize, but depends on the content size instead of
        the viewport size. WARNING: This only applies to cross axis, not main axis.
        Applying this to main axis would create a circular dependency.
        This also means that RelativeContentSize depends on the max cross size.
        Different from RelativeSize, which depends on the viewport size.
        This cannot be resolved until the max cross size is resolved.
    */

    BoxConstraints constraints = this.constraints;
    if (childCount == 0) {
      return (mainContentSize: 0.0, crossContentSize: 0.0);
    }

    double maxViewportMainSize = _getMain(constraints.biggest);
    double maxViewportCrossSize = _getCross(constraints.biggest);

    double mainContentSize = 0.0;
    double crossContentSize = 0.0;

    double? biggestMainFlex;
    double totalMainFlex = 0.0;
    double? maxCrossFlex = 0.0;

    double spaceRemaining = maxViewportMainSize;
    double spacing = this.spacing;

    // a little bit of note: if one of the axis size is 0,
    // you might think we should not resolve the other axis or just set it to 0,
    // but its wrong. You need to resolve the other axis because
    // the children might need it. For example,
    // FlexBox(
    //   FlexBoxChild(
    //     size: 0,
    //     child: Stack(
    //       children: [
    //         Positioned(
    //           left: 0, bottom: 0, width: 100, height: 100,
    //           child: Container(color: Colors.red),
    //         ),
    //       ],
    //     )
    //   )
    // )
    // without the other axis, the positioned child inside the stack
    // would have trouble positioning it to the bottom.

    // int resolvedMainAxisCount = 0;
    int absoluteCount = 0;
    int unresolvedFlexCount = 0;
    int unresolvedUnconstrainedCount = 0;
    int crossDependedCount = 0;

    bool hasFlexIntrinsicFallback = false;
    bool hasRelativeIntrinsicFallback = false;

    // First pass
    RenderBox? child = relativeFirstChild;
    while (child != null) {
      final data = child.parentData as FlexBoxParentData;
      // reset resolved sizes
      data.resolvedMainSize = null;
      data.resolvedCrossSize = null;

      // skip absolute children
      if (data.isAbsolute) {
        absoluteCount++;
        child = relativeNextSibling(child);
        continue;
      }

      final mainSize = data.getSize(direction);
      final crossSize = data.getSize(crossDirection);
      switch (mainSize) {
        case FixedSize():
          data.resolvedMainSize = _clamp(
            mainSize.size,
            mainSize.min,
            mainSize.max,
          );
          mainContentSize += data.resolvedMainSize!;
          // resolvedMainAxisCount++;
          // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
          // impossible to handle: UnconstrainedSize (need max content cross size),
          //   RelativeContentSize (need max content cross size),
          //   FlexSize (need max content cross size)
          switch (crossSize) {
            case FlexSize():
              maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
            case RelativeContentSize():
            case UnconstrainedSize():
              crossDependedCount++;
              break;
            case FixedSize():
              data.resolvedCrossSize = _clamp(
                crossSize.size,
                crossSize.min,
                crossSize.max,
              );
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
            case IntrinsicSize():
              data.resolvedCrossSize = _clamp(
                _computeMaxIntrinsicCross(child, data.resolvedMainSize!),
                crossSize.min,
                crossSize.max,
              );
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
            case RatioSize():
              data.resolvedCrossSize = _clamp(
                data.resolvedMainSize! * crossSize.ratio,
                crossSize.min,
                crossSize.max,
              );
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
            case RelativeSize():
              if (maxViewportCrossSize.isFinite) {
                data.resolvedCrossSize = _clamp(
                  maxViewportCrossSize * crossSize.relative,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
              } else {
                // cannot resolve relative size on cross axis
                // because max cross size is infinite, so as a
                // safe fallback, we resolve it to 0
                data.resolvedCrossSize = _clamp(
                  0.0,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
              }
              break;
          }
          break;
        case IntrinsicSize():
          // handles: FixedSize, RelativeSize, Ratio, Intrinsic
          // impossible to handle: UnconstrainedSize (need max content cross size),
          //  RelativeContentSize (need max content cross size),
          //  FlexSize (need max content cross size)
          switch (crossSize) {
            case FlexSize():
              maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
            case RelativeContentSize():
            case UnconstrainedSize():
              crossDependedCount++;
              break;
            case FixedSize():
              data.resolvedCrossSize = _clamp(
                crossSize.size,
                crossSize.min,
                crossSize.max,
              );
              data.resolvedMainSize = _clamp(
                _computeMaxIntrinsicMain(child, data.resolvedCrossSize!),
                mainSize.min,
                mainSize.max,
              );
              mainContentSize += data.resolvedMainSize!;
              // resolvedMainAxisCount++;
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
            case RelativeSize():
              if (maxViewportCrossSize.isFinite) {
                data.resolvedCrossSize = _clamp(
                  maxViewportCrossSize * crossSize.relative,
                  crossSize.min,
                  crossSize.max,
                );
                data.resolvedMainSize = _clamp(
                  _computeMaxIntrinsicMain(child, data.resolvedCrossSize!),
                  mainSize.min,
                  mainSize.max,
                );
                mainContentSize += data.resolvedMainSize!;
                // resolvedMainAxisCount++;
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
              } else {
                // cannot resolve relative size on cross axis
                // because max cross size is infinite, so as a
                // safe fallback, we resolve it to 0
                data.resolvedCrossSize = _clamp(
                  0.0,
                  crossSize.min,
                  crossSize.max,
                );
                data.resolvedMainSize = _clamp(
                  _computeMaxIntrinsicMain(child, data.resolvedCrossSize!),
                  mainSize.min,
                  mainSize.max,
                );
                mainContentSize += data.resolvedMainSize!;
                // resolvedMainAxisCount++;
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
              }
              break;
            case RatioSize():
              // since both depends on each other, we resolve
              // Intrinsic by using double.infinite for its cross size
              data.resolvedMainSize = _clamp(
                _computeMaxIntrinsicMain(child, double.infinity),
                mainSize.min,
                mainSize.max,
              );
              data.resolvedCrossSize = _clamp(
                data.resolvedMainSize! * crossSize.ratio,
                crossSize.min,
                crossSize.max,
              );
              mainContentSize += data.resolvedMainSize!;
              // resolvedMainAxisCount++;
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
            case IntrinsicSize():
              // both main and cross depends on each other
              // we resolve Intrinsic by using double.infinite for its cross size
              data.resolvedMainSize = _clamp(
                _computeMaxIntrinsicMain(child, double.infinity),
                mainSize.min,
                mainSize.max,
              );
              data.resolvedCrossSize = _clamp(
                _computeMaxIntrinsicCross(child, double.infinity),
                crossSize.min,
                crossSize.max,
              );
              mainContentSize += data.resolvedMainSize!;
              // resolvedMainAxisCount++;
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
          }
          break;
        case RelativeSize():
          if (maxViewportMainSize.isFinite) {
            // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
            // impossible to handle: UnconstrainedSize (need max content cross size),
            //   RelativeContentSize (need max content cross size),
            //   FlexSize (need max content cross size)
            data.resolvedMainSize = _clamp(
              maxViewportMainSize * mainSize.relative,
              mainSize.min,
              mainSize.max,
            );
            mainContentSize += data.resolvedMainSize!;
            // resolvedMainAxisCount++;
            switch (crossSize) {
              case FlexSize():
                maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
              case RelativeContentSize():
              case UnconstrainedSize():
                crossDependedCount++;
                break;
              case FixedSize():
                data.resolvedCrossSize = _clamp(
                  crossSize.size,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case IntrinsicSize():
                data.resolvedCrossSize = _clamp(
                  _computeMaxIntrinsicCross(child, data.resolvedMainSize!),
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RatioSize():
                data.resolvedCrossSize = _clamp(
                  data.resolvedMainSize! * crossSize.ratio,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RelativeSize():
                if (maxViewportCrossSize.isFinite) {
                  data.resolvedCrossSize = _clamp(
                    maxViewportCrossSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                } else {
                  // cannot resolve relative size on cross axis
                  // because max cross size is infinite, so as a
                  // safe fallback, we resolve it to 0
                  data.resolvedCrossSize = _clamp(
                    0.0,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                }
                break;
            }
          } else {
            // relative size needs viewport size to be finite
            // so as a safe fallback, we resolve it to 0.
            // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
            // impossible to handle: UnconstrainedSize (need max content cross size),
            //   RelativeContentSize (need max content cross size),
            //   FlexSize (need max content cross size)
            // data.resolvedMainSize = _clamp(0.0, mainSize.min, mainSize.max);
            if (mainSize.intrinsicFallback) {
              // data.resolvedMainSize = _clamp(
              //   _computeMaxIntrinsicMain(child, double.infinity),
              //   mainSize.min,
              //   mainSize.max,
              // );
              hasFlexIntrinsicFallback = true;
              continue;
            } else {
              data.resolvedMainSize = _clamp(0.0, mainSize.min, mainSize.max);
            }
            mainContentSize += data.resolvedMainSize!;
            // resolvedMainAxisCount++;
            switch (crossSize) {
              case FlexSize():
                maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
              case RelativeContentSize():
              case UnconstrainedSize():
                crossDependedCount++;
                break;
              case FixedSize():
                data.resolvedCrossSize = _clamp(
                  crossSize.size,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case IntrinsicSize():
                data.resolvedCrossSize = _clamp(
                  _computeMaxIntrinsicCross(child, double.infinity),
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RelativeSize():
                if (maxViewportCrossSize.isFinite) {
                  data.resolvedCrossSize = _clamp(
                    maxViewportCrossSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                } else {
                  // cannot resolve relative size on cross axis
                  // because max cross size is infinite, so as a
                  // safe fallback, we resolve it to 0
                  data.resolvedCrossSize = _clamp(
                    0.0,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                }
                break;
              case RatioSize():
                // ratio simply resolves to 0
                data.resolvedCrossSize = _clamp(
                  0.0,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
            }
          }
          break;
        case RelativeContentSize():
          // throw flutter error
          throw FlutterError(
            'RelativeContentSize cannot be used on the main axis. It can only be used on the cross axis.',
          );
        case FlexSize():
          if (spaceRemaining.isInfinite) {
            // flex requires space to resolve, but since spaceRemaining is infinite,
            // we cannot resolve flex. Flex always requires space to resolve.
            // A safe fallback is done by treating flex as zero or intrinsic depending on the option
            // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
            // impossible to handle: UnconstrainedSize (need max content cross size),
            //   RelativeContentSize (need max content cross size),
            //   FlexSize (need max content cross size)
            // data.resolvedMainSize = _clamp(0.0, mainSize.min, mainSize.max);
            if (mainSize.intrinsicFallback) {
              // data.resolvedMainSize = _clamp(
              //   _computeMaxIntrinsicMain(child, double.infinity),
              //   mainSize.min,
              //   mainSize.max,
              // );
              hasFlexIntrinsicFallback = true;
              continue;
            } else {
              data.resolvedMainSize = _clamp(0.0, mainSize.min, mainSize.max);
            }
            mainContentSize += data.resolvedMainSize!;
            // resolvedMainAxisCount++;
            switch (crossSize) {
              case FlexSize():
                maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
              case RelativeContentSize():
              case UnconstrainedSize():
                crossDependedCount++;
                break;
              case FixedSize():
                data.resolvedCrossSize = _clamp(
                  crossSize.size,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case IntrinsicSize():
                data.resolvedCrossSize = _clamp(
                  _computeMaxIntrinsicCross(child, double.infinity),
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RelativeSize():
                if (maxViewportCrossSize.isFinite) {
                  data.resolvedCrossSize = _clamp(
                    maxViewportCrossSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                } else {
                  // cannot resolve relative size on cross axis
                  // because max cross size is infinite, so as a
                  // safe fallback, we resolve it to 0
                  data.resolvedCrossSize = _clamp(
                    0.0,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                }
                break;
              case RatioSize():
                // ratio simply resolves to 0
                data.resolvedCrossSize = _clamp(
                  0.0,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
            }
          } else {
            // only record flex values for now
            // handles: FixedSize, RelativeSize
            // impossible to handle: UnconstrainedSize (need max content cross size),
            //   RelativeContentSize (need max content cross size),
            //   IntrinsicSize (need cross axis size), RatioSize (need cross axis size),
            //   FlexSize (need max content cross size),
            if (biggestMainFlex == null || mainSize.flex > biggestMainFlex) {
              biggestMainFlex = mainSize.flex;
            }
            totalMainFlex += mainSize.flex;
            unresolvedFlexCount++;
            // resolve cross axis if possible
            switch (crossSize) {
              case FlexSize():
                maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
              case RelativeContentSize():
              case UnconstrainedSize():
                crossDependedCount++;
                break;
              case FixedSize():
                data.resolvedCrossSize = _clamp(
                  crossSize.size,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RelativeSize():
                if (maxViewportCrossSize.isFinite) {
                  data.resolvedCrossSize = _clamp(
                    maxViewportCrossSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                } else {
                  // cannot resolve relative size on cross axis
                  // because max cross size is infinite, so as a
                  // safe fallback, we resolve it to 0
                  data.resolvedCrossSize = _clamp(
                    0.0,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                }
                break;
            }
            // do not resolve IntrinsicSize for now, because
            // it requires main axis size to be resolved
          }
          break;
        case UnconstrainedSize():
          // only record unconstrained count for now
          unresolvedUnconstrainedCount++;
          break;
        case RatioSize():
          // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
          // impossible to handle: UnconstrainedSize (need max content cross size),
          //   RelativeContentSize (need max content cross size),
          //   FlexSize (need max content cross size)
          switch (crossSize) {
            case FlexSize():
              maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
            case RelativeContentSize():
            case UnconstrainedSize():
              crossDependedCount++;
              break;
            case FixedSize():
              data.resolvedCrossSize = _clamp(
                crossSize.size,
                crossSize.min,
                crossSize.max,
              );
              data.resolvedMainSize = _clamp(
                data.resolvedCrossSize! * mainSize.ratio,
                mainSize.min,
                mainSize.max,
              );
              mainContentSize += data.resolvedMainSize!;
              // resolvedMainAxisCount++;
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
            case RatioSize():
              // both main and cross depends on each other
              throw FlutterError(
                'RatioSize cannot be used on both main and cross axis at the same time. It can only be used on one axis.',
              );
            case RelativeSize():
              if (maxViewportCrossSize.isFinite) {
                data.resolvedCrossSize = _clamp(
                  maxViewportCrossSize * crossSize.relative,
                  crossSize.min,
                  crossSize.max,
                );
                data.resolvedMainSize = _clamp(
                  data.resolvedCrossSize! * mainSize.ratio,
                  mainSize.min,
                  mainSize.max,
                );
                mainContentSize += data.resolvedMainSize!;
                // resolvedMainAxisCount++;
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
              } else {
                // infinite max cross size, cannot resolve
                // so, as a safe fallback, we resolve both
                // as 0/intrinsic
                if (crossSize.intrinsicFallback) {
                  data.resolvedCrossSize = _clamp(
                    _computeMaxIntrinsicCross(child, double.infinity),
                    crossSize.min,
                    crossSize.max,
                  );
                } else {
                  data.resolvedCrossSize = _clamp(
                    0.0,
                    crossSize.min,
                    crossSize.max,
                  );
                }
                data.resolvedMainSize = _clamp(
                  data.resolvedCrossSize! * mainSize.ratio,
                  mainSize.min,
                  mainSize.max,
                );
                mainContentSize += data.resolvedMainSize!;
                // resolvedMainAxisCount++;
                crossContentSize = max(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
              }
              break;
            case IntrinsicSize():
              // since both depends on each other, we resolve
              data.resolvedMainSize = _clamp(
                _computeMaxIntrinsicMain(child, double.infinity),
                mainSize.min,
                mainSize.max,
              );
              data.resolvedCrossSize = _clamp(
                data.resolvedMainSize! * mainSize.ratio,
                crossSize.min,
                crossSize.max,
              );
              mainContentSize += data.resolvedMainSize!;
              // resolvedMainAxisCount++;
              crossContentSize = max(crossContentSize, data.resolvedCrossSize!);
              break;
          }
          break;
      }
      child = relativeNextSibling(child);
    }

    int gapCount = childCount - absoluteCount - 1;
    if (gapCount > 0) {
      if (spacing.isFinite) {
        mainContentSize += gapCount * spacing;
        spaceRemaining -= gapCount * spacing;
      } else {
        spaceRemaining = 0.0; // it eats the whole thing
        // flex will also fallback to intrinsic/0
      }
    }

    // At this point, these children have been laid out:
    // - Size(Fixed, Fixed)
    // - Size(Fixed, Intrinsic)
    // - Size(Fixed, Ratio)
    // - Size(Fixed, Relative) * CARE FOR INFINITE CROSS SIZE
    // - Size(Intrinsic, Fixed)
    // - Size(Intrinsic, Relative) * CARE FOR INFINITE CROSS SIZE
    // - Size(Intrinsic, Intrinsic)
    // - Size(Intrinsic, Ratio)
    // - Size(Relative, Fixed) * CASE FOR INFINITE MAIN SIZE
    // - Size(Relative, Intrinsic) * CARE FOR INFINITE MAIN SIZE
    // - Size(Relative, Ratio) * CARE FOR INFINITE MAIN SIZE
    // - Size(Relative, Relative) * CARE FOR INFINITE SIZES
    // - Size(RelativeContent, *) * NOT ALLOWED
    // - Size(Flex (infinite, treat as 0 Fixed), Fixed)
    // - Size(Flex (infinite), Intrinsic)
    // - Size(Flex (infinite), Relative) * CARE FOR INFINITE CROSS SIZE
    // - Size(Flex (infinite), Ratio)
    // - Size(Ratio, Fixed)
    // - Size(Ratio, Relative) * CARE FOR INFINITE CROSS SIZE
    // - Size(Ratio, Intrinsic)
    // - Size(Ratio, Ratio) * NOT ALLOWED
    // mainContentSize now the sum size of all fixeds
    // crossContentSize is now the max of fixed, intrinsic, and ratio
    // not yet solved:
    // - Size(Unconstrained, *)
    // - Size(Flex, *) (if spaceRemaining is finite)
    // - Size(*, Unconstrained)
    // - Size(*, Flex)
    // - Size(*, RelativeContent)

    bool shouldResolveFlex =
        spaceRemaining.isFinite &&
        (unresolvedFlexCount > 0 || unresolvedUnconstrainedCount > 0);
    // The reason canResolveFlex is false could be:
    // 1. main RatioSize is not yet solved

    // at this point, main RatioSize depends on each other (with cross FlexSize, UnconstrainedSize, RelativeContentSize)
    // for the next phase, we prioritize resolving main FlexSize, and UnconstrainedSize first
    // so that we can have a resolved max cross content size to resolve main RatioSize and cross RelativeContentSize

    // Second Phase
    if (shouldResolveFlex) {
      biggestMainFlex ??= 1.0;
      totalMainFlex += biggestMainFlex * unresolvedUnconstrainedCount;
      bool keepResolving = true;
      int resolvePassCount = 0;
      int totalFlexChildren =
          unresolvedFlexCount + unresolvedUnconstrainedCount;
      while (keepResolving && resolvePassCount < 10) {
        keepResolving = false;
        double spacePerFlex = totalMainFlex > 0
            ? spaceRemaining / totalMainFlex
            : 0.0;
        child = relativeFirstChild;
        while (child != null) {
          final data = child.parentData as FlexBoxParentData;
          if (data.isAbsolute) {
            child = relativeNextSibling(child);
            continue;
          }
          final mainSize = data.getSize(direction);
          final crossSize = data.getSize(crossDirection);
          switch (mainSize) {
            case FlexSize():
              if (data.resolvedMainSize != null) {
                // already resolved on a previous pass
                child = relativeNextSibling(child);
                continue;
              }
              double proposedSize = spacePerFlex * mainSize.flex;
              data.resolvedMainSize = _clamp(
                proposedSize,
                mainSize.min,
                mainSize.max,
              );
              mainContentSize += data.resolvedMainSize!;
              // resolvedMainAxisCount++;
              bool wasConstrained = proposedSize != data.resolvedMainSize;
              // already handled previously:
              // FixedSize, RelativeSize
              // not yet handled:
              // - IntrinsicSize (need cross axis size)
              // - UnconstrainedSize (need max content cross size) * we don't do this here just yet
              // - RelativeContentSize (need max content cross size) * we don't do this here just yet
              // - FlexSize (need max content cross size) * we don't do this here just yet
              // - RatioSize (need cross axis size)
              switch (crossSize) {
                case IntrinsicSize():
                  if (data.resolvedMainSize != null) {
                    data.resolvedCrossSize = _clamp(
                      _computeMaxIntrinsicCross(child, data.resolvedMainSize!),
                      crossSize.min,
                      crossSize.max,
                    );
                    crossContentSize = max(
                      crossContentSize,
                      data.resolvedCrossSize!,
                    );
                  }
                  break;
                case RatioSize():
                  data.resolvedCrossSize = _clamp(
                    data.resolvedMainSize! * crossSize.ratio,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
              }
              if (wasConstrained && totalFlexChildren > 1) {
                // the resolved main size does not reflect the actual
                // flex size, therefore recalculation is needed.
                // This happens when a flex child has min/max constraints
                // and it affects other flex children.
                totalMainFlex -= mainSize.flex;
                spaceRemaining -= data.resolvedMainSize!;
                totalFlexChildren--;
                keepResolving = true;
              }
              break;
            case UnconstrainedSize():
              if (data.resolvedMainSize != null) {
                // already resolved on a previous pass
                child = relativeNextSibling(child);
                continue;
              }
              // unconstrained size acts as the biggest flex
              double proposedSize = spacePerFlex * biggestMainFlex;
              data.resolvedMainSize = _clamp(
                proposedSize,
                mainSize.min,
                mainSize.max,
              );
              bool wasConstrained = proposedSize != data.resolvedMainSize;
              mainContentSize += data.resolvedMainSize!;
              // resolvedMainAxisCount++;
              switch (crossSize) {
                case IntrinsicSize():
                  if (data.resolvedMainSize != null) {
                    data.resolvedCrossSize = _clamp(
                      _computeMaxIntrinsicCross(child, data.resolvedMainSize!),
                      crossSize.min,
                      crossSize.max,
                    );
                    crossContentSize = max(
                      crossContentSize,
                      data.resolvedCrossSize!,
                    );
                  }
                  break;
                case RatioSize():
                  data.resolvedCrossSize = _clamp(
                    data.resolvedMainSize! * crossSize.ratio,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = max(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
              }
              if (wasConstrained && totalFlexChildren > 1) {
                // the resolved main size does not reflect the actual
                // flex size, therefore recalculation is needed.
                // This happens when a flex child has min/max constraints
                // and it affects other flex children.
                totalMainFlex -= biggestMainFlex;
                spaceRemaining -= data.resolvedMainSize!;
                totalFlexChildren--;
                keepResolving = true;
              }
              break;
          }
          if (keepResolving) {
            // force restart from the beginning
            // due to recalculation of flex units
            break;
          }
          child = relativeNextSibling(child);
        }
        resolvePassCount++;
      }
    }

    // At this point, these children have been laid out:
    // - Size(Flex (finite), Fixed)
    // - Size(Flex (finite), Relative) * CARE FOR INFINITE CROSS SIZE
    // - Size(Flex (finite), Intrinsic)
    // - Size(Flex (finite), Ratio)
    // - Size(Unconstrained, Fixed)
    // - Size(Unconstrained, Relative) * CARE FOR INFINITE CROSS SIZE
    // - Size(Unconstrained, Intrinsic)
    // - Size(Unconstrained, Ratio)
    // not yet solved:
    // - Size(*, Unconstrained)
    // - Size(*, Flex)
    // - Size(*, RelativeContent)
    // now cross content size is resolved.

    assert(() {
      RenderBox? child = relativeFirstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        final mainSize = data.getSize(direction);
        final crossSize = data.getSize(crossDirection);
        // make sure all main axis are resolved except for RelativeContentSize
        if (!data.isAbsolute &&
            mainSize is! RelativeContentSize &&
            data.resolvedMainSize == null) {
          throw FlutterError(
            'Main axis size is not resolved for a non-absolute child. '
            'This is likely a bug. Please report it to the package maintainer. '
            'Child: $child, MainSize: $mainSize, CrossSize: $crossSize',
          );
        }
        // make sure all cross axis are resolved except for RelativeContentSize, FlexSize, UnconstrainedSize

        if (!data.isAbsolute &&
            crossSize is! RelativeContentSize &&
            crossSize is! FlexSize &&
            crossSize is! UnconstrainedSize &&
            data.resolvedCrossSize == null) {
          throw FlutterError(
            'Cross axis size is not resolved for a non-absolute child. '
            'This is likely a bug. Please report it to the package maintainer. '
            'Child: $child, MainSize: $mainSize, CrossSize: $crossSize',
          );
        }
        child = relativeNextSibling(child);
      }
      return true;
    }(), 'Conditions does not meet expectations');

    bool shouldResolveCross = crossDependedCount > 0;

    // the next phase requires viewport size to be finite
    // so for that, when the viewport size is infinite,
    // we refer them to the content size instead.
    if (maxViewportMainSize.isInfinite) {
      maxViewportMainSize = mainContentSize;
    }
    if (maxViewportCrossSize.isInfinite) {
      maxViewportCrossSize = crossContentSize;
    }

    // Third Phase
    // now we resolve cross axis that depends on max cross content size
    // we can also lay out the absolute children
    if (shouldResolveCross || absoluteCount > 0) {
      maxCrossFlex ??= 1.0;
      double crossSpacePerFlex = maxCrossFlex > 0
          ? crossContentSize / maxCrossFlex
          : 0.0;
      child = relativeFirstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        if (data.isAbsolute) {
          // reset resolved sizes and positions
          data.resolvedMainStart = data.resolvedMainEnd =
              data.resolvedCrossStart = data.resolvedCrossEnd = null;

          assert(
            data.resolvedMainSize == null && data.resolvedCrossSize == null,
            'Absolute children should not have resolved sizes. Child: $child',
          );
          final mainSize = data.getSize(direction);
          final crossSize = data.getSize(crossDirection);
          final mainType =
              data.getPositionType(direction) ??
              BoxPositionType.relativeViewport;
          final crossType =
              data.getPositionType(crossDirection) ??
              BoxPositionType.relativeViewport;
          double maxMainSize;
          double maxCrossSize;
          switch (mainType) {
            case BoxPositionType.fixed:
            case BoxPositionType.relativeViewport:
            case BoxPositionType.stickyStartViewport:
            case BoxPositionType.stickyEndViewport:
            case BoxPositionType.stickyViewport:
              maxMainSize = maxViewportMainSize;
              break;
            case BoxPositionType.relativeContent:
            case BoxPositionType.stickyStartContent:
            case BoxPositionType.stickyEndContent:
            case BoxPositionType.stickyContent:
              maxMainSize = mainContentSize;
              break;
          }
          switch (crossType) {
            case BoxPositionType.fixed:
            case BoxPositionType.relativeViewport:
            case BoxPositionType.stickyStartViewport:
            case BoxPositionType.stickyEndViewport:
            case BoxPositionType.stickyViewport:
              maxCrossSize = maxViewportCrossSize;
              break;
            case BoxPositionType.relativeContent:
            case BoxPositionType.stickyStartContent:
            case BoxPositionType.stickyEndContent:
            case BoxPositionType.stickyContent:
              maxCrossSize = crossContentSize;
              break;
          }
          BoxPosition? mainStart = data.getStartPosition(direction);
          BoxPosition? crossStart = data.getStartPosition(crossDirection);
          BoxPosition? mainEnd = data.getEndPosition(direction);
          BoxPosition? crossEnd = data.getEndPosition(crossDirection);
          // resolve positions
          double mainFixedStart =
              (data.resolvedMainStart = mainStart?.computePosition(
                maxMainSize,
              )) ??
              0;
          double mainFixedEnd =
              (data.resolvedMainEnd = mainEnd?.computePosition(maxMainSize)) ??
              0;
          double crossFixedStart =
              (data.resolvedCrossStart = crossStart?.computePosition(
                maxCrossSize,
              )) ??
              0;
          double crossFixedEnd =
              (data.resolvedCrossEnd = crossEnd?.computePosition(
                maxCrossSize,
              )) ??
              0;
          double usedMain = mainFixedStart + mainFixedEnd;
          double usedCross = crossFixedStart + crossFixedEnd;
          // resolve size
          switch (mainSize) {
            case UnconstrainedSize():
              data.resolvedMainSize = _clamp(
                maxMainSize - usedMain,
                mainSize.min,
                mainSize.max,
              );
              break;
            case FixedSize():
              data.resolvedMainSize = _clamp(
                mainSize.size,
                mainSize.min,
                mainSize.max,
              );
              break;
            case FlexSize():
              throw FlutterError(
                'FlexSize cannot be used for absolute children. Child: $child',
              );
            case RelativeSize():
              data.resolvedMainSize = _clamp(
                maxMainSize * mainSize.relative,
                mainSize.min,
                mainSize.max,
              );
              break;
            case IntrinsicSize():
              switch (crossSize) {
                case IntrinsicSize():
                  // need each other to work, so we use double.infinity instead
                  data.resolvedMainSize = _clamp(
                    _computeMaxIntrinsicMain(child, double.infinity),
                    mainSize.min,
                    mainSize.max,
                  );
                  data.resolvedCrossSize = _clamp(
                    _computeMaxIntrinsicCross(child, data.resolvedMainSize!),
                    crossSize.min,
                    crossSize.max,
                  );
                  break;
                case RatioSize():
                  // need each other to work, so we use double.infinity instead
                  data.resolvedMainSize = _clamp(
                    _computeMaxIntrinsicMain(child, double.infinity),
                    mainSize.min,
                    mainSize.max,
                  );
                  data.resolvedCrossSize = _clamp(
                    data.resolvedMainSize! * crossSize.ratio,
                    crossSize.min,
                    crossSize.max,
                  );
                  break;
                case FixedSize():
                  data.resolvedCrossSize = _clamp(
                    crossSize.size,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    _computeMaxIntrinsicMain(child, data.resolvedCrossSize!),
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
                case RelativeSize():
                  data.resolvedCrossSize = _clamp(
                    maxCrossSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    _computeMaxIntrinsicMain(child, data.resolvedCrossSize!),
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
                case UnconstrainedSize():
                  data.resolvedCrossSize = _clamp(
                    maxCrossSize - usedCross,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    _computeMaxIntrinsicMain(child, data.resolvedCrossSize!),
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
                case FlexSize():
                  throw FlutterError(
                    'FlexSize cannot be used for absolute children. Child: $child',
                  );
                case RelativeContentSize():
                  // this is basically useless if the box position type it self
                  // set to content-relative type
                  data.resolvedCrossSize = _clamp(
                    crossContentSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    _computeMaxIntrinsicMain(child, data.resolvedCrossSize!),
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
              }
              break;
            case RatioSize():
              switch (crossSize) {
                case IntrinsicSize():
                  // need each other to work, so we use double.infinity instead
                  data.resolvedCrossSize = _clamp(
                    _computeMaxIntrinsicCross(child, double.infinity),
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    data.resolvedCrossSize! * mainSize.ratio,
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
                case RatioSize():
                  // both main and cross depends on each other
                  throw FlutterError(
                    'RatioSize cannot be used on both main and cross axis at the same time. It can only be used on one axis. Child: $child',
                  );
                case FixedSize():
                  data.resolvedCrossSize = _clamp(
                    crossSize.size,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    data.resolvedCrossSize! * mainSize.ratio,
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
                case RelativeSize():
                  data.resolvedCrossSize = _clamp(
                    maxCrossSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    data.resolvedCrossSize! * mainSize.ratio,
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
                case UnconstrainedSize():
                  data.resolvedCrossSize = _clamp(
                    maxCrossSize - usedCross,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    data.resolvedCrossSize! * mainSize.ratio,
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
                case FlexSize():
                  throw FlutterError(
                    'FlexSize cannot be used for absolute children. Child: $child',
                  );
                case RelativeContentSize():
                  // this is basically useless if the box position type it self
                  // set to content-relative type
                  data.resolvedCrossSize = _clamp(
                    crossContentSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                  data.resolvedMainSize = _clamp(
                    data.resolvedCrossSize! * mainSize.ratio,
                    mainSize.min,
                    mainSize.max,
                  );
                  break;
              }
              break;
            case RelativeContentSize():
              // useless
              data.resolvedMainSize = _clamp(
                mainSize.relative * mainContentSize,
                mainSize.min,
                mainSize.max,
              );
              break;
          }

          // resolve cross sizing
          if (data.resolvedCrossSize == null) {
            switch (crossSize) {
              case FixedSize():
                data.resolvedCrossSize = _clamp(
                  crossSize.size,
                  crossSize.min,
                  crossSize.max,
                );
                break;
              case RelativeSize():
                data.resolvedCrossSize = _clamp(
                  maxCrossSize * crossSize.relative,
                  crossSize.min,
                  crossSize.max,
                );
                break;
              // case IntrinsicSize():
              //   assert(
              //     data.resolvedMainSize != null,
              //     'Main size should be resolved when cross size is IntrinsicSize',
              //   );
              //   data.resolvedCrossSize = _clamp(
              //     _computeMaxIntrinsicCross(child, data.resolvedMainSize!),
              //     crossSize.min,
              //     crossSize.max,
              //   );
              //   break;
              case RelativeContentSize():
                data.resolvedCrossSize = _clamp(
                  crossContentSize * crossSize.relative,
                  crossSize.min,
                  crossSize.max,
                );
                break;
              case FlexSize():
                throw FlutterError(
                  'FlexSize cannot be used for absolute children. Child: $child',
                );
              case UnconstrainedSize():
                data.resolvedCrossSize = _clamp(
                  maxCrossSize - usedCross,
                  crossSize.min,
                  crossSize.max,
                );
                break;
              // case RatioSize():
              //   assert(
              //     data.resolvedMainSize != null,
              //     'Main size should be resolved when cross size is RatioSize',
              //   );
              //   data.resolvedCrossSize = _clamp(
              //     data.resolvedMainSize! * crossSize.ratio,
              //     crossSize.min,
              //     crossSize.max,
              //   );
              //   break;
              case IntrinsicSize():
              case RatioSize():
                throw FlutterError(
                  'IntrinsicSize and RatioSize should have been handled above. Child: $child',
                );
            }
          }
        } else {
          final crossSize = data.getSize(crossDirection);
          switch (crossSize) {
            case UnconstrainedSize():
              data.resolvedCrossSize = _clamp(
                crossContentSize,
                crossSize.min,
                crossSize.max,
              );
              break;
            case FlexSize():
              data.resolvedCrossSize = _clamp(
                crossSpacePerFlex * crossSize.flex,
                crossSize.min,
                crossSize.max,
              );
              break;
            case RelativeContentSize():
              data.resolvedCrossSize = _clamp(
                crossContentSize * crossSize.relative,
                crossSize.min,
                crossSize.max,
              );
              break;
          }
        }

        // finally layout the children
        double? resolvedMain = data.resolvedMainSize;
        double? resolvedCross = data.resolvedCrossSize;
        assert(
          resolvedMain != null && resolvedCross != null,
          'Resolved sizes should not be null at this point for size (${data.getSize(direction)}, ${data.getSize(crossDirection)})',
        );
        child.layout(
          BoxConstraints.tightFor(
            width: direction == Axis.horizontal ? resolvedMain : resolvedCross,
            height: direction == Axis.horizontal ? resolvedCross : resolvedMain,
          ),
        );

        child = relativeNextSibling(child);
      }
    }

    // make sure all children has been laid out
    assert(() {
      RenderBox? child = relativeFirstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        if (!child.hasSize) {
          throw FlutterError(
            'Child has not been laid out. This is likely a bug. Please report it to the package maintainer. Child: $child, isAbsolute: ${data.isAbsolute}, mainSize: ${data.getSize(direction)}, crossSize: ${data.getSize(crossDirection)}',
          );
        }
        child = relativeNextSibling(child);
      }
      return true;
    }(), 'Conditions does not meet expectations');

    return (
      mainContentSize: mainContentSize,
      crossContentSize: crossContentSize,
    );
  }

  double _clamp(double value, double? lower, double? upper) {
    lower ??= double.negativeInfinity;
    upper ??= double.infinity;
    return _clampIgnoreSign(value, lower, upper);
  }

  void _positionsChildren({
    required double mainContentSize,
    required double crossContentSize,
    required double mainViewportSize,
    required double crossViewportSize,
  }) {
    if (childCount == 0) {
      return;
    }
    // Positions all non-absolute and absolute children, similar to _performLayout
    final BoxConstraints constraints = this.constraints;
    // Calculate viewport and content sizes
    final visibleViewportSize = constraints.biggest;
    double usedMainSize = 0.0;
    double usedCrossSize = 0.0;
    double mainOffset = 0.0;
    double crossMaxSize = 0.0;
    double gap = spacing;
    int totalAffectedChildren = 0;
    RenderBox? child = relativeFirstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        totalAffectedChildren++;
        usedMainSize += _getMain(child.size);
        usedCrossSize = max(usedCrossSize, _getCross(child.size));
      }
      child = relativeNextSibling(child);
    }
    if (totalAffectedChildren > 1) {
      usedMainSize += spacing * (totalAffectedChildren - 1);
    }
    crossMaxSize = max(usedCrossSize, _getCross(visibleViewportSize));
    double mainAlign = _alignValue(
      alignment: _mainAlignment,
      min: 0.0,
      max: max(_getMain(visibleViewportSize) - usedMainSize, 0.0),
    );
    double horizontalPixels = horizontal.pixels;
    double verticalPixels = vertical.pixels;
    Offset viewportOffset = Offset(horizontalPixels, verticalPixels);
    Offset relativeViewportOffset = Offset(
      reverseOffsetX && usedMainSize > visibleViewportSize.width
          ? usedMainSize - visibleViewportSize.width - horizontalPixels
          : horizontalPixels,
      reverseOffsetY && usedCrossSize > visibleViewportSize.height
          ? usedCrossSize - visibleViewportSize.height - verticalPixels
          : verticalPixels,
    );
    viewportOffset = relativeViewportOffset;

    // Position non-absolute children
    child = relativeFirstChild;
    mainOffset = mainAlign;
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

        // Handle sticky/fixed/relative positioning for non-absolute children
        var horizontalType = layoutData.horizontalPosition;
        var verticalType = layoutData.verticalPosition;

        if (reverseOffsetX) {
          switch (horizontalType) {
            case BoxPositionType.stickyStartViewport:
              horizontalType = BoxPositionType.stickyEndViewport;
              break;
            case BoxPositionType.stickyEndViewport:
              horizontalType = BoxPositionType.stickyStartViewport;
              break;
            case BoxPositionType.stickyStartContent:
              horizontalType = BoxPositionType.stickyEndContent;
              break;
            case BoxPositionType.stickyEndContent:
              horizontalType = BoxPositionType.stickyStartContent;
              break;
            default:
              break;
          }
        }
        if (reverseOffsetY) {
          switch (verticalType) {
            case BoxPositionType.stickyStartViewport:
              verticalType = BoxPositionType.stickyEndViewport;
              break;
            case BoxPositionType.stickyEndViewport:
              verticalType = BoxPositionType.stickyStartViewport;
              break;
            case BoxPositionType.stickyStartContent:
              verticalType = BoxPositionType.stickyEndContent;
              break;
            case BoxPositionType.stickyEndContent:
              verticalType = BoxPositionType.stickyStartContent;
              break;
            default:
              break;
          }
        }

        var horizontal = layoutData.offset.dx;
        var vertical = layoutData.offset.dy;
        if (horizontalType == BoxPositionType.fixed) {
          horizontal += viewportOffset.dx;
        } else if (horizontalType == BoxPositionType.stickyViewport) {
          if (layoutData.right != null) {
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
        } else if (horizontalType == BoxPositionType.stickyStartViewport) {
          double leftExcess = max(0, relativeViewportOffset.dx - horizontal);
          horizontal += leftExcess;
        } else if (horizontalType == BoxPositionType.stickyEndViewport) {
          double rightExcess = max(
            0,
            -((relativeViewportOffset.dx + constraints.maxWidth) -
                (horizontal + child.size.width)),
          );
          horizontal -= rightExcess;
        } else if (horizontalType == BoxPositionType.stickyContent) {
          if (layoutData.right != null) {
            double rightExcess = max(
              0,
              -((relativeViewportOffset.dx + usedMainSize) -
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
              -((relativeViewportOffset.dx + usedMainSize) -
                  (horizontal + child.size.width)),
            );
            horizontal -= rightExcess;
          }
        } else if (horizontalType == BoxPositionType.stickyStartContent) {
          double leftExcess = max(0, relativeViewportOffset.dx - horizontal);
          horizontal += leftExcess;
        } else if (horizontalType == BoxPositionType.stickyEndContent) {
          double rightExcess = max(
            0,
            -((relativeViewportOffset.dx + usedMainSize) -
                (horizontal + child.size.width)),
          );
          horizontal -= rightExcess;
        }
        if (verticalType == BoxPositionType.fixed) {
          vertical += viewportOffset.dy;
        } else if (verticalType == BoxPositionType.stickyViewport) {
          if (layoutData.bottom != null) {
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
        } else if (verticalType == BoxPositionType.stickyStartViewport) {
          double topExcess = max(0, relativeViewportOffset.dy - vertical);
          vertical += topExcess;
        } else if (verticalType == BoxPositionType.stickyEndViewport) {
          double bottomExcess = max(
            0,
            -((relativeViewportOffset.dy + constraints.maxHeight) -
                (vertical + child.size.height)),
          );
          vertical -= bottomExcess;
        } else if (verticalType == BoxPositionType.stickyContent) {
          if (layoutData.bottom != null) {
            double bottomExcess = max(
              0,
              -((relativeViewportOffset.dy + usedCrossSize) -
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
              -((relativeViewportOffset.dy + usedCrossSize) -
                  (vertical + child.size.height)),
            );
            vertical -= bottomExcess;
          }
        } else if (verticalType == BoxPositionType.stickyStartContent) {
          double topExcess = max(0, relativeViewportOffset.dy - vertical);
          vertical += topExcess;
        } else if (verticalType == BoxPositionType.stickyEndContent) {
          double bottomExcess = max(
            0,
            -((relativeViewportOffset.dy + usedCrossSize) -
                (vertical + child.size.height)),
          );
          vertical -= bottomExcess;
        }
        layoutData.offset = Offset(
          horizontal - relativeViewportOffset.dx,
          vertical - relativeViewportOffset.dy,
        );
      }
      child = relativeNextSibling(child);
    }

    // Position absolute children
    child = relativeFirstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      if (layoutData.isAbsolute) {
        double top;
        double left;
        double width = child.size.width;
        double height = child.size.height;
        var dataLeft = layoutData.left;
        var dataRight = layoutData.right;
        var dataTop = layoutData.top;
        var dataBottom = layoutData.bottom;
        // For absolute children, use content or viewport as reference
        bool useContentForHorizontal =
            layoutData.horizontalPosition == BoxPositionType.relativeContent ||
            layoutData.horizontalPosition == BoxPositionType.stickyContent ||
            layoutData.horizontalPosition ==
                BoxPositionType.stickyStartContent ||
            layoutData.horizontalPosition == BoxPositionType.stickyEndContent;
        bool useContentForVertical =
            layoutData.verticalPosition == BoxPositionType.relativeContent ||
            layoutData.verticalPosition == BoxPositionType.stickyContent ||
            layoutData.verticalPosition == BoxPositionType.stickyStartContent ||
            layoutData.verticalPosition == BoxPositionType.stickyEndContent;
        double referenceWidth = useContentForHorizontal
            ? usedMainSize
            : visibleViewportSize.width;
        double referenceHeight = useContentForVertical
            ? usedCrossSize
            : visibleViewportSize.height;
        if (dataTop != null) {
          top = dataTop.computePosition(referenceHeight);
        } else if (dataBottom != null) {
          top =
              referenceHeight -
              height -
              dataBottom.computePosition(referenceHeight);
        } else {
          top = 0.0;
        }
        if (dataLeft != null) {
          left = dataLeft.computePosition(referenceWidth);
        } else if (dataRight != null) {
          left =
              referenceWidth -
              width -
              dataRight.computePosition(referenceWidth);
        } else {
          left = 0.0;
        }
        layoutData.offset = Offset(left, top);

        // Apply sticky/fixed/relative logic for absolute children
        var horizontalType = layoutData.horizontalPosition;
        var verticalType = layoutData.verticalPosition;
        if (reverseOffsetX) {
          switch (horizontalType) {
            case BoxPositionType.stickyStartViewport:
              horizontalType = BoxPositionType.stickyEndViewport;
              break;
            case BoxPositionType.stickyEndViewport:
              horizontalType = BoxPositionType.stickyStartViewport;
              break;
            case BoxPositionType.stickyStartContent:
              horizontalType = BoxPositionType.stickyEndContent;
              break;
            case BoxPositionType.stickyEndContent:
              horizontalType = BoxPositionType.stickyStartContent;
              break;
            default:
              break;
          }
        }
        if (reverseOffsetY) {
          switch (verticalType) {
            case BoxPositionType.stickyStartViewport:
              verticalType = BoxPositionType.stickyEndViewport;
              break;
            case BoxPositionType.stickyEndViewport:
              verticalType = BoxPositionType.stickyStartViewport;
              break;
            case BoxPositionType.stickyStartContent:
              verticalType = BoxPositionType.stickyEndContent;
              break;
            case BoxPositionType.stickyEndContent:
              verticalType = BoxPositionType.stickyStartContent;
              break;
            default:
              break;
          }
        }
        var horizontal = layoutData.offset.dx;
        var vertical = layoutData.offset.dy;
        if (horizontalType == BoxPositionType.fixed) {
          horizontal += viewportOffset.dx;
        } else if (horizontalType == BoxPositionType.stickyViewport) {
          if (layoutData.right != null) {
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
        } else if (horizontalType == BoxPositionType.stickyStartViewport) {
          double leftExcess = max(0, relativeViewportOffset.dx - horizontal);
          horizontal += leftExcess;
        } else if (horizontalType == BoxPositionType.stickyEndViewport) {
          double rightExcess = max(
            0,
            -((relativeViewportOffset.dx + constraints.maxWidth) -
                (horizontal + child.size.width)),
          );
          horizontal -= rightExcess;
        } else if (horizontalType == BoxPositionType.stickyContent) {
          if (layoutData.right != null) {
            double rightExcess = max(
              0,
              -((relativeViewportOffset.dx + usedMainSize) -
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
              -((relativeViewportOffset.dx + usedMainSize) -
                  (horizontal + child.size.width)),
            );
            horizontal -= rightExcess;
          }
        } else if (horizontalType == BoxPositionType.stickyStartContent) {
          double leftExcess = max(0, relativeViewportOffset.dx - horizontal);
          horizontal += leftExcess;
        } else if (horizontalType == BoxPositionType.stickyEndContent) {
          double rightExcess = max(
            0,
            -((relativeViewportOffset.dx + usedMainSize) -
                (horizontal + child.size.width)),
          );
          horizontal -= rightExcess;
        }
        if (verticalType == BoxPositionType.fixed) {
          vertical += viewportOffset.dy;
        } else if (verticalType == BoxPositionType.stickyViewport) {
          if (layoutData.bottom != null) {
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
        } else if (verticalType == BoxPositionType.stickyStartViewport) {
          double topExcess = max(0, relativeViewportOffset.dy - vertical);
          vertical += topExcess;
        } else if (verticalType == BoxPositionType.stickyEndViewport) {
          double bottomExcess = max(
            0,
            -((relativeViewportOffset.dy + constraints.maxHeight) -
                (vertical + child.size.height)),
          );
          vertical -= bottomExcess;
        } else if (verticalType == BoxPositionType.stickyContent) {
          if (layoutData.bottom != null) {
            double bottomExcess = max(
              0,
              -((relativeViewportOffset.dy + usedCrossSize) -
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
              -((relativeViewportOffset.dy + usedCrossSize) -
                  (vertical + child.size.height)),
            );
            vertical -= bottomExcess;
          }
        } else if (verticalType == BoxPositionType.stickyStartContent) {
          double topExcess = max(0, relativeViewportOffset.dy - vertical);
          vertical += topExcess;
        } else if (verticalType == BoxPositionType.stickyEndContent) {
          double bottomExcess = max(
            0,
            -((relativeViewportOffset.dy + usedCrossSize) -
                (vertical + child.size.height)),
          );
          vertical -= bottomExcess;
        }
        layoutData.offset = Offset(
          horizontal - relativeViewportOffset.dx,
          vertical - relativeViewportOffset.dy,
        );
      }
      child = relativeNextSibling(child);
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
          // Skip FlexSize children in main-axis intrinsic computation
          child = (child.parentData as FlexBoxParentData).nextSibling;
          continue;
        } else if (mainSizeConstraint is RatioSize) {
          // For ratio sizing in main direction, we need the cross axis size
          // If the cross-axis size is infinite (unconstrained), we can't compute the ratio
          // so we skip ratio children in main-axis intrinsic computation to avoid infinity
          if (size.isInfinite) {
            childSize =
                0.0; // Skip ratio sizing when cross-axis is unconstrained
          } else {
            childSize = mainSizeConstraint.ratio * size;
          }
        } else {
          throw ArgumentError(
            'Invalid main size constraint: $mainSizeConstraint',
          );
        }
        // Note: Don't apply min/max clamping during intrinsic computation
        // Min/max constraints are applied during actual layout
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
          // Skip FlexSize children in cross-axis intrinsic computation
          child = (child.parentData as FlexBoxParentData).nextSibling;
          continue;
        } else if (crossSizeConstraint is RatioSize) {
          // For ratio sizing in cross direction, we need the main axis size
          // If the main-axis size is infinite (unconstrained), we can't compute the ratio
          // so we skip ratio children in cross-axis intrinsic computation to avoid infinity
          if (size.isInfinite) {
            childSize =
                0.0; // Skip ratio sizing when main-axis is unconstrained
          } else {
            childSize = size * crossSizeConstraint.ratio;
          }
        } else {
          throw ArgumentError(
            'Invalid cross size constraint: $crossSizeConstraint',
          );
        }
        // Note: Don't apply min/max clamping during intrinsic computation
        // Min/max constraints are applied during actual layout
        totalSize = max(totalSize, childSize);
      }
      child = (child.parentData as FlexBoxParentData).nextSibling;
    }
    return totalSize;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return direction == Axis.horizontal
        ? _computeCrossIntrinsicSize(
            width,
            (item, size) => item.getMaxIntrinsicHeight(size),
          )
        : _computeIntrinsicSize(
            width,
            (item, size) => item.getMaxIntrinsicHeight(size),
          );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return direction == Axis.horizontal
        ? _computeIntrinsicSize(
            height,
            (item, size) => item.getMaxIntrinsicWidth(size),
          )
        : _computeCrossIntrinsicSize(
            height,
            (item, size) => item.getMaxIntrinsicWidth(size),
          );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return direction == Axis.horizontal
        ? _computeCrossIntrinsicSize(
            width,
            (item, size) => item.getMinIntrinsicHeight(size),
          )
        : _computeIntrinsicSize(
            width,
            (item, size) => item.getMinIntrinsicHeight(size),
          );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return direction == Axis.horizontal
        ? _computeIntrinsicSize(
            height,
            (item, size) => item.getMinIntrinsicWidth(size),
          )
        : _computeCrossIntrinsicSize(
            height,
            (item, size) => item.getMinIntrinsicWidth(size),
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

class FlexLayoutResult {
  final bool needSorting;
  final double mainContentSize;
  final double crossContentSize;
  final double mainViewportSize;
  final double crossViewportSize;

  FlexLayoutResult({
    required this.needSorting,
    required this.mainContentSize,
    required this.crossContentSize,
    required this.mainViewportSize,
    required this.crossViewportSize,
  });
}
