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

  double cachedMainSize = 0;
  double cachedCrossSize = 0;
  double unconstrainedFlex = 0;
  double mainFlex = 0; // Store the actual flex value from FlexSize
  bool isConstrainedByMinMax =
      false; // Track if this child is constrained by min/max

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

  /// Performs proper flex distribution with constraint handling and redistribution.
  /// This algorithm ensures that when flex children are constrained by min/max,
  /// the remaining space is properly redistributed among other flex children.
  void _performFlexDistribution(double availableSpace, double totalFlex) {
    if (totalFlex <= 0) {
      // No flex children, nothing to distribute
      return;
    }

    double remainingSpace = max(availableSpace, 0); // Use 0 if negative
    double remainingFlex = totalFlex;

    // Iterative algorithm to handle constraints and redistribution
    bool hasChanges = true;
    int maxIterations = 10; // Prevent infinite loops
    int iteration = 0;

    while (hasChanges && iteration < maxIterations) {
      hasChanges = false;
      iteration++;

      // Pass 1: Check for newly constrained children and update remaining values
      RenderBox? child = relativeFirstChild;
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (!layoutData.isAbsolute) {
          var mainSizeConstraint = layoutData.getSize(direction);
          if ((mainSizeConstraint is FlexSize ||
                  (mainSizeConstraint is UnconstrainedSize &&
                      layoutData.mainFlex > 0)) &&
              !layoutData.isConstrainedByMinMax) {
            double proposedSize = remainingFlex > 0
                ? (layoutData.mainFlex / remainingFlex) * max(remainingSpace, 0)
                : 0.0;

            final minMain = mainSizeConstraint is FlexSize
                ? mainSizeConstraint.min ?? 0.0
                : (mainSizeConstraint as UnconstrainedSize).min ?? 0.0;
            final maxMain = mainSizeConstraint is FlexSize
                ? mainSizeConstraint.max ?? double.infinity
                : (mainSizeConstraint as UnconstrainedSize).max ??
                      double.infinity;
            double constrainedSize = _clampIgnoreSign(
              proposedSize,
              minMain,
              maxMain,
            );

            // Check if this child became constrained
            if (constrainedSize != proposedSize) {
              layoutData.isConstrainedByMinMax = true;
              layoutData.cachedMainSize = constrainedSize;
              remainingSpace -= constrainedSize;
              remainingFlex -= layoutData.mainFlex;
              hasChanges = true;
            }
          }
        }
        child = relativeNextSibling(child);
      }
    }

    // Pass 2: Distribute remaining space among unconstrained children
    if (remainingFlex > 0) {
      RenderBox? child = relativeFirstChild;
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (!layoutData.isAbsolute) {
          var mainSizeConstraint = layoutData.getSize(direction);
          if ((mainSizeConstraint is FlexSize ||
                  (mainSizeConstraint is UnconstrainedSize &&
                      layoutData.mainFlex > 0)) &&
              !layoutData.isConstrainedByMinMax) {
            double finalSize =
                (layoutData.mainFlex / remainingFlex) * max(remainingSpace, 0);
            layoutData.cachedMainSize = finalSize;
          }
        }
        child = relativeNextSibling(child);
      }
    }
  }

  @override
  void performLayout() {
    BoxConstraints constraints = this.constraints;
    // If there are no children, set size and return early
    if (firstChild == null) {
      size = constraints.constrain(Size.zero);
      return;
    }
    // Count unconstrained children first (needed before constraint override)
    int unconstrainedCount = 0;
    RenderBox? unconstrainedChild = relativeFirstChild;
    int totalAffectedChildren = 0;
    while (unconstrainedChild != null) {
      var layoutData = unconstrainedChild.parentData as FlexBoxParentData;
      if (!layoutData.isAbsolute) {
        totalAffectedChildren++;
        var mainSizeConstraint = layoutData.getSize(direction);
        if (mainSizeConstraint is UnconstrainedSize) {
          unconstrainedCount++;
        }
      }
      unconstrainedChild = relativeNextSibling(unconstrainedChild);
    }
    bool onlyUnconstrained =
        (totalAffectedChildren == unconstrainedCount) && unconstrainedCount > 0;
    if (!onlyUnconstrained) {
      constraints = BoxConstraints.tight(constraints.smallest);
    }
    _firstSortedChild = null;
    _lastSortedChild = null;

    // Calculate viewport size early for positioning calculations
    final visibleViewportSize = constraints.biggest;

    if (kDebugMode) {
      RenderBox? firstChild = relativeFirstChild;
      while (firstChild != null) {
        var layoutData = firstChild.parentData as FlexBoxParentData;
        layoutData.debugLayout = false;
        firstChild = relativeNextSibling(firstChild);
      }
    }

    // Reset constraint flags for fresh layout
    RenderBox? resetChild = relativeFirstChild;
    while (resetChild != null) {
      var layoutData = resetChild.parentData as FlexBoxParentData;
      layoutData.isConstrainedByMinMax = false;
      resetChild = relativeNextSibling(resetChild);
    }

    var shouldSortChildren = false;
    var hasCrossFlex = false;
    var child = relativeFirstChild;
    var totalFlex = 0.0;
    var maxCrossFlex = 0.0;
    var totalFixedSize = 0.0;
    // Use totalAffectedChildren from pre-pass above
    var usedMainSize = 0.0;
    var biggestFlex = 0.0;
    var availableMainSize = direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    var availableCrossSize = direction == Axis.horizontal
        ? constraints.maxHeight
        : constraints.maxWidth;
    var maxContentCrossSize = availableCrossSize;

    // First pass:
    // In this pass, we count all flexible children (i.e. how many are there and the total flex value).
    // If its an intrinsic size, we compute the maximum intrinsic size.
    // If its a fixed size, we add it to the total fixed size, and we lay it out immediately.
    // Unless its cross size is unconstrained or flexible, we skip it.

    child = relativeFirstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      layoutData.cachedMainSize = 0;
      layoutData.cachedCrossSize = 0;
      layoutData.unconstrainedFlex = 0;
      layoutData.mainFlex = 0;
      shouldSortChildren = shouldSortChildren || layoutData.zOrder != null;
      layoutData._nextSortedSibling = null;
      layoutData._previousSortedSibling = null;
      if (!layoutData.isAbsolute) {
        var mainSizeConstraint = layoutData.getSize(direction);
        var crossSizeConstraint = layoutData.getSize(crossDirection);
        double mainChildSize;
        if (mainSizeConstraint is FixedSize) {
          mainChildSize = mainSizeConstraint.size;
        } else if (mainSizeConstraint is IntrinsicSize) {
          mainChildSize = _computeMaxIntrinsicMain(child, availableCrossSize);
        } else if (mainSizeConstraint is RelativeSize) {
          mainChildSize = mainSizeConstraint.relative * availableMainSize;
        } else if (mainSizeConstraint is FlexSize) {
          totalFlex += mainSizeConstraint.flex;
          biggestFlex = max(biggestFlex, mainSizeConstraint.flex);
          layoutData.mainFlex = mainSizeConstraint.flex; // Store the flex value
          child = relativeNextSibling(child);
          continue;
        } else if (mainSizeConstraint is RatioSize) {
          mainChildSize = 0;
          // skip this for now
        } else if (mainSizeConstraint is UnconstrainedSize) {
          child = relativeNextSibling(child);
          continue;
        } else {
          throw ArgumentError(
            'Invalid main size constraint: $mainSizeConstraint',
          );
        }

        // Clamp main size to respect min/max constraints (except for RatioSize which is handled later)
        if (mainSizeConstraint is! RatioSize) {
          var mainMin = _getMinMain(layoutData);
          var mainMax = _getMaxMain(layoutData);
          mainChildSize = _clampIgnoreSign(mainChildSize, mainMin, mainMax);
        }
        layoutData.cachedMainSize = mainChildSize;

        double crossChildSize;
        if (crossSizeConstraint is FixedSize) {
          crossChildSize = crossSizeConstraint.size;
          maxContentCrossSize = max(maxContentCrossSize, crossChildSize);
        } else if (crossSizeConstraint is IntrinsicSize) {
          crossChildSize = _computeMaxIntrinsicCross(child, availableMainSize);
          maxContentCrossSize = max(maxContentCrossSize, crossChildSize);
        } else if (crossSizeConstraint is RelativeSize) {
          crossChildSize = crossSizeConstraint.relative * availableCrossSize;
          maxContentCrossSize = max(maxContentCrossSize, crossChildSize);
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
          // Clamp the main size to respect min/max constraints
          var mainMin = _getMinMain(layoutData);
          var mainMax = _getMaxMain(layoutData);
          mainChildSize = _clampIgnoreSign(mainChildSize, mainMin, mainMax);
          layoutData.cachedMainSize = mainChildSize;
        }
        var crossMin = _getMinCross(layoutData);
        var crossMax = _getMaxCross(layoutData);
        crossChildSize = _clampIgnoreSign(crossChildSize, crossMin, crossMax);
        layoutData.cachedCrossSize = crossChildSize;
        var childSize = _createSize(mainChildSize, crossChildSize);
        _layoutChild(child, childSize);
        totalFixedSize += mainChildSize;
      }
      // Skip absolute children in first pass - they will be laid out later
      child = relativeNextSibling(child);
    }

    // Second pass:
    // Handle UnconstrainedSize children - they need special logic
    // If there are flex children, unconstrained acts as biggest flex
    // If no flex children, unconstrained fills remaining space

    // (Already counted unconstrainedCount and onlyUnconstrained above for constraint logic)

    // Handle unconstrained children: act as flex if flex children exist, fill remaining space if not, use intrinsic if only unconstrained
    // (Already determined onlyUnconstrained above; parentTightAndFinite logic not needed)
    child = relativeFirstChild;
    while (child != null) {
      var layoutData = child.parentData as FlexBoxParentData;
      // --- NEW LOGIC: Precompute unconstrained sizes in mixed scenarios and subtract from available space for flex ---
      double totalUnconstrainedMainSize = 0.0;
      child = relativeFirstChild;
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (!layoutData.isAbsolute) {
          var mainSizeConstraint = layoutData.getSize(direction);
          if (mainSizeConstraint is UnconstrainedSize) {
            if (onlyUnconstrained) {
              // Only unconstrained children: always use intrinsic size
              double unconstrainedMainSize = direction == Axis.horizontal
                  ? child.computeMaxIntrinsicWidth(double.infinity)
                  : child.computeMaxIntrinsicHeight(double.infinity);
              final minMain = mainSizeConstraint.min ?? 0.0;
              final maxMain = mainSizeConstraint.max ?? double.infinity;
              unconstrainedMainSize = _clampIgnoreSign(
                unconstrainedMainSize,
                minMain,
                maxMain,
              );
              layoutData.cachedMainSize = unconstrainedMainSize;
              usedMainSize += unconstrainedMainSize;

              // Handle cross size for UnconstrainedSize children
              var crossSizeConstraint = layoutData.getSize(crossDirection);
              double crossChildSize;
              if (crossSizeConstraint is FixedSize) {
                crossChildSize = crossSizeConstraint.size;
              } else if (crossSizeConstraint is IntrinsicSize) {
                crossChildSize = direction == Axis.horizontal
                    ? child.computeMaxIntrinsicHeight(double.infinity)
                    : child.computeMaxIntrinsicWidth(double.infinity);
              } else if (crossSizeConstraint is UnconstrainedSize) {
                // For cross-axis unconstrained, use intrinsic size
                crossChildSize = direction == Axis.horizontal
                    ? child.computeMaxIntrinsicHeight(double.infinity)
                    : child.computeMaxIntrinsicWidth(double.infinity);
              } else if (crossSizeConstraint is RelativeSize) {
                crossChildSize =
                    crossSizeConstraint.relative * maxContentCrossSize;
              } else if (crossSizeConstraint is FlexSize) {
                crossChildSize = maxContentCrossSize;
              } else if (crossSizeConstraint is RatioSize) {
                crossChildSize =
                    unconstrainedMainSize * crossSizeConstraint.ratio;
              } else {
                throw ArgumentError(
                  'Invalid cross size constraint: $crossSizeConstraint',
                );
              }
              var crossMin = _getMinCross(layoutData);
              var crossMax = _getMaxCross(layoutData);
              crossChildSize = _clampIgnoreSign(
                crossChildSize,
                crossMin,
                crossMax,
              );
              layoutData.cachedCrossSize = crossChildSize;
              maxContentCrossSize = max(maxContentCrossSize, crossChildSize);

              var childSize = _createSize(
                layoutData.cachedMainSize,
                crossChildSize,
              );
              _layoutChild(child, childSize);
            } else if (totalFlex > 0) {
              // If all non-absolute children are flex or unconstrained, unconstrained acts as flex
              int flexOrUnconstrainedCount = 0;
              RenderBox? checkChild = relativeFirstChild;
              while (checkChild != null) {
                var checkData = checkChild.parentData as FlexBoxParentData;
                if (!checkData.isAbsolute) {
                  var c = checkData.getSize(direction);
                  if (c is FlexSize || c is UnconstrainedSize) {
                    flexOrUnconstrainedCount++;
                  }
                }
                checkChild = relativeNextSibling(checkChild);
              }
              if (flexOrUnconstrainedCount == totalAffectedChildren) {
                // Only flex and unconstrained: unconstrained acts as flex
                layoutData.mainFlex = biggestFlex;
                totalFlex += biggestFlex;
                // Do not assign cachedMainSize here; let flex distribution handle it
              } else {
                // Mixed: unconstrained uses explicit/intrinsic size
                double unconstrainedMainSize = direction == Axis.horizontal
                    ? child.computeMaxIntrinsicWidth(double.infinity)
                    : child.computeMaxIntrinsicHeight(double.infinity);
                final minMain = mainSizeConstraint.min ?? 0.0;
                final maxMain = mainSizeConstraint.max ?? double.infinity;
                unconstrainedMainSize = _clampIgnoreSign(
                  unconstrainedMainSize,
                  minMain,
                  maxMain,
                );
                layoutData.cachedMainSize = unconstrainedMainSize;
                totalUnconstrainedMainSize += unconstrainedMainSize;

                // Cross size
                var crossSizeConstraint = layoutData.getSize(crossDirection);
                double crossChildSize;
                if (crossSizeConstraint is FixedSize) {
                  crossChildSize = crossSizeConstraint.size;
                } else if (crossSizeConstraint is IntrinsicSize) {
                  crossChildSize = direction == Axis.horizontal
                      ? child.computeMaxIntrinsicHeight(double.infinity)
                      : child.computeMaxIntrinsicWidth(double.infinity);
                } else if (crossSizeConstraint is UnconstrainedSize) {
                  crossChildSize = direction == Axis.horizontal
                      ? child.computeMaxIntrinsicHeight(double.infinity)
                      : child.computeMaxIntrinsicWidth(double.infinity);
                } else if (crossSizeConstraint is RelativeSize) {
                  crossChildSize =
                      crossSizeConstraint.relative * maxContentCrossSize;
                } else if (crossSizeConstraint is FlexSize) {
                  crossChildSize = maxContentCrossSize;
                } else if (crossSizeConstraint is RatioSize) {
                  crossChildSize =
                      unconstrainedMainSize * crossSizeConstraint.ratio;
                } else {
                  throw ArgumentError(
                    'Invalid cross size constraint: $crossSizeConstraint',
                  );
                }
                var crossMin = _getMinCross(layoutData);
                var crossMax = _getMaxCross(layoutData);
                crossChildSize = _clampIgnoreSign(
                  crossChildSize,
                  crossMin,
                  crossMax,
                );
                layoutData.cachedCrossSize = crossChildSize;
                maxContentCrossSize = max(maxContentCrossSize, crossChildSize);

                var childSize = _createSize(
                  layoutData.cachedMainSize,
                  crossChildSize,
                );
                _layoutChild(child, childSize);
              }
            } else if ((totalAffectedChildren - unconstrainedCount) > 0) {
              // There are other non-flex children (fixed, relative, intrinsic) and no flex children
              // Unconstrained fills remaining space
              var totalUsedMainSize =
                  totalFixedSize +
                  (totalAffectedChildren - unconstrainedCount) * spacing;
              var remainingSpace = availableMainSize - totalUsedMainSize;
              double unconstrainedMainSize = max(
                0.0,
                remainingSpace / unconstrainedCount,
              );
              final minMain = mainSizeConstraint.min ?? 0.0;
              final maxMain = mainSizeConstraint.max ?? double.infinity;
              unconstrainedMainSize = _clampIgnoreSign(
                unconstrainedMainSize,
                minMain,
                maxMain,
              );
              layoutData.cachedMainSize = unconstrainedMainSize;
              usedMainSize += unconstrainedMainSize;

              // Cross size for UnconstrainedSize children
              var crossSizeConstraint = layoutData.getSize(crossDirection);
              double crossChildSize;
              if (crossSizeConstraint is FixedSize) {
                crossChildSize = crossSizeConstraint.size;
              } else if (crossSizeConstraint is IntrinsicSize) {
                crossChildSize = direction == Axis.horizontal
                    ? child.computeMaxIntrinsicHeight(double.infinity)
                    : child.computeMaxIntrinsicWidth(double.infinity);
              } else if (crossSizeConstraint is UnconstrainedSize) {
                crossChildSize = direction == Axis.horizontal
                    ? child.computeMaxIntrinsicHeight(double.infinity)
                    : child.computeMaxIntrinsicWidth(double.infinity);
              } else if (crossSizeConstraint is RelativeSize) {
                crossChildSize =
                    crossSizeConstraint.relative * maxContentCrossSize;
              } else if (crossSizeConstraint is FlexSize) {
                crossChildSize = maxContentCrossSize;
              } else if (crossSizeConstraint is RatioSize) {
                crossChildSize =
                    unconstrainedMainSize * crossSizeConstraint.ratio;
              } else {
                throw ArgumentError(
                  'Invalid cross size constraint: $crossSizeConstraint',
                );
              }
              var crossMin = _getMinCross(layoutData);
              var crossMax = _getMaxCross(layoutData);
              crossChildSize = _clampIgnoreSign(
                crossChildSize,
                crossMin,
                crossMax,
              );
              layoutData.cachedCrossSize = crossChildSize;
              maxContentCrossSize = max(maxContentCrossSize, crossChildSize);

              var childSize = _createSize(
                layoutData.cachedMainSize,
                crossChildSize,
              );
              _layoutChild(child, childSize);
            }
          }
        }
        child = relativeNextSibling(child);
      }

      // If there are flex children, subtract totalUnconstrainedMainSize from availableMainSize before flex distribution
      double adjustedAvailableMainSize = availableMainSize;
      if (totalFlex > 0 && totalUnconstrainedMainSize > 0) {
        adjustedAvailableMainSize -= totalUnconstrainedMainSize;
      }
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (!layoutData.isAbsolute) {
          var mainSizeConstraint = layoutData.getSize(direction);
          if (mainSizeConstraint is FlexSize) {
            layoutData.mainFlex = mainSizeConstraint.flex;
            biggestFlex = max(biggestFlex, mainSizeConstraint.flex);
          }
        }
        child = relativeNextSibling(child);
      }

      // Fourth pass:
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
              var crossChildSize = (flex / maxCrossFlex) * maxContentCrossSize;
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
              var crossChildSize = maxContentCrossSize;
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

      // Perform proper flex distribution with constraint handling and redistribution
      // Use adjustedAvailableMainSize if flex children and unconstrained children coexist
      double flexRemainingSpace =
          adjustedAvailableMainSize -
          totalFixedSize -
          (totalAffectedChildren - unconstrainedCount) * spacing;
      _performFlexDistribution(flexRemainingSpace, totalFlex);

      child = relativeFirstChild;
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (!layoutData.isAbsolute) {
          var mainSizeConstraint = layoutData.getSize(direction);
          if (mainSizeConstraint is FlexSize ||
              (mainSizeConstraint is UnconstrainedSize &&
                  layoutData.mainFlex > 0)) {
            // Size is already computed by _performFlexDistribution and stored in cachedMainSize

            // Cross
            var crossChildConstraint = layoutData.getSize(crossDirection);
            double crossChildSize;
            if (crossChildConstraint is FixedSize) {
              crossChildSize = crossChildConstraint.size;
            } else if (crossChildConstraint is IntrinsicSize) {
              crossChildSize = _computeMaxIntrinsicCross(
                child,
                availableMainSize,
              );
            } else if (crossChildConstraint is UnconstrainedSize) {
              crossChildSize = maxContentCrossSize;
            } else if (crossChildConstraint is FlexSize) {
              crossChildSize = crossChildConstraint.flex * maxContentCrossSize;
            } else if (crossChildConstraint is RelativeSize) {
              crossChildSize =
                  crossChildConstraint.relative * maxContentCrossSize;
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
            crossChildSize = _clampIgnoreSign(
              crossChildSize,
              crossMin,
              crossMax,
            );
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
        double remainingSpace = availableMainSize - usedMainSize;
        if (remainingSpace > 0) {
          gap = remainingSpace / (totalAffectedChildren - 1);
          usedMainSize += gap * (totalAffectedChildren - 1);
        } else {
          gap = 0.0;
        }
      }

      // Content size - total area of all content
      final totalContentSize = _createSize(usedMainSize, usedCrossSize);

      double crossMaxSize = max(
        _getCross(totalContentSize),
        _getCross(visibleViewportSize),
      );
      double mainMaxSize = max(
        _getMain(totalContentSize),
        _getMain(visibleViewportSize),
      );

      double mainOffset = _alignValue(
        alignment: _mainAlignment,
        min: 0.0,
        max: mainMaxSize - usedMainSize,
      );

      double horizontalPixels = horizontal.pixels;
      double verticalPixels = vertical.pixels;

      Offset viewportOffset = Offset(horizontalPixels, verticalPixels);

      Offset relativeViewportOffset = Offset(
        reverseOffsetX && totalContentSize.width > visibleViewportSize.width
            ? totalContentSize.width -
                  visibleViewportSize.width -
                  horizontalPixels
            : horizontalPixels,
        reverseOffsetY && totalContentSize.height > visibleViewportSize.height
            ? totalContentSize.height -
                  visibleViewportSize.height -
                  verticalPixels
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

          // Only handle positioning for non-absolute children here
          // Absolute children positioning will be handled after they are laid out
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
              // right excess first
              double rightExcess = max(
                0,
                -((relativeViewportOffset.dx + constraints.maxWidth) -
                    (horizontal + child.size.width)),
              );
              horizontal -= rightExcess;
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
              horizontal += leftExcess;
            } else {
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
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
              // right excess first
              double rightExcess = max(
                0,
                -((relativeViewportOffset.dx + totalContentSize.width) -
                    (horizontal + child.size.width)),
              );
              horizontal -= rightExcess;
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
              horizontal += leftExcess;
            } else {
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
              horizontal += leftExcess;
              double rightExcess = max(
                0,
                -((relativeViewportOffset.dx + totalContentSize.width) -
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
              -((relativeViewportOffset.dx + totalContentSize.width) -
                  (horizontal + child.size.width)),
            );
            horizontal -= rightExcess;
          }
          if (verticalType == BoxPositionType.fixed) {
            vertical += viewportOffset.dy;
          } else if (verticalType == BoxPositionType.stickyViewport) {
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
              // bottom excess first
              double bottomExcess = max(
                0,
                -((relativeViewportOffset.dy + size.height) -
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
                -((relativeViewportOffset.dy + size.height) -
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
              -((relativeViewportOffset.dy + size.height) -
                  (vertical + child.size.height)),
            );
            vertical -= bottomExcess;
          }

          layoutData.offset = Offset(
            horizontal - relativeViewportOffset.dx,
            vertical - relativeViewportOffset.dy,
          );
        } // End of non-absolute children processing

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
      size = this.constraints.constrain(
        _createSize(usedMainSize, usedCrossSize),
      );

      horizontal.applyViewportDimension(size.width);
      vertical.applyViewportDimension(size.height);

      horizontal.applyContentDimensions(
        0,
        (totalContentSize.width - size.width).clamp(0, double.infinity),
      );
      vertical.applyContentDimensions(
        0,
        (totalContentSize.height - size.height).clamp(0, double.infinity),
      );

      // Layout absolute children after viewport size is established
      child = relativeFirstChild;
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (layoutData.isAbsolute) {
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

          // Determine which dimensions to use based on positioning type
          bool useContentForHorizontal =
              layoutData.horizontalPosition ==
                  BoxPositionType.relativeContent ||
              layoutData.horizontalPosition == BoxPositionType.stickyContent ||
              layoutData.horizontalPosition ==
                  BoxPositionType.stickyStartContent ||
              layoutData.horizontalPosition == BoxPositionType.stickyEndContent;
          bool useContentForVertical =
              layoutData.verticalPosition == BoxPositionType.relativeContent ||
              layoutData.verticalPosition == BoxPositionType.stickyContent ||
              layoutData.verticalPosition ==
                  BoxPositionType.stickyStartContent ||
              layoutData.verticalPosition == BoxPositionType.stickyEndContent;

          // For relativeContent: use the full scrollable content dimensions
          // For relativeViewport: use the visible viewport dimensions
          double referenceWidth = useContentForHorizontal
              ? totalContentSize
                    .width // Full scrollable content width
              : size.width; // Visible viewport width
          double referenceHeight = useContentForVertical
              ? totalContentSize
                    .height // Full scrollable content height
              : size.height; // Visible viewport height

          if (dataWidth != null) {
            if (dataWidth is FixedSize) {
              width = dataWidth.size;
            } else if (dataWidth is RelativeSize) {
              width = dataWidth.relative * referenceWidth;
            } else if (dataWidth is IntrinsicSize) {
              width = child.computeMaxIntrinsicWidth(double.infinity);
            } else if (dataWidth is UnconstrainedSize) {
              // For unconstrained size in absolute positioning, calculate remaining space
              if (dataLeft != null && dataRight != null) {
                // Both anchors specified - fill space between them
                width =
                    referenceWidth -
                    dataLeft.computePosition(referenceWidth) -
                    dataRight.computePosition(referenceWidth);
              } else if (dataLeft != null) {
                // Only left anchor - fill remaining space to right
                width =
                    referenceWidth - dataLeft.computePosition(referenceWidth);
              } else if (dataRight != null) {
                // Only right anchor - fill remaining space to left
                width =
                    referenceWidth - dataRight.computePosition(referenceWidth);
              } else {
                // No anchors - fill entire width
                width = referenceWidth;
              }
              // Apply min/max constraints
              final minWidth = dataWidth.min ?? 0.0;
              final maxWidth = dataWidth.max ?? double.infinity;
              width = _clampIgnoreSign(width, minWidth, maxWidth);
            } else if (dataWidth is RatioSize) {
              assert(
                dataHeight is! RatioSize,
                'RatioSize cannot be used with RatioSize for height',
              );
              width = 0; // skip this for now
            } else if (dataWidth is FlexSize) {
              // FlexSize constraints are handled in the flex distribution phase
              // Skip them here and they will be processed later
              width = 0; // Will be set during flex distribution
            } else {
              throw ArgumentError('Invalid width constraint: $dataWidth');
            }
          } else if (dataLeft != null && dataRight != null) {
            width =
                referenceWidth -
                dataLeft.computePosition(referenceWidth) -
                dataRight.computePosition(referenceWidth);
          } else {
            width = child.computeMaxIntrinsicWidth(constraints.maxHeight);
          }
          if (dataHeight != null) {
            if (dataHeight is FixedSize) {
              height = dataHeight.size;
            } else if (dataHeight is RelativeSize) {
              height = dataHeight.relative * referenceHeight;
            } else if (dataHeight is IntrinsicSize) {
              height = child.computeMaxIntrinsicHeight(double.infinity);
            } else if (dataHeight is UnconstrainedSize) {
              // For unconstrained size in absolute positioning, calculate remaining space
              if (dataTop != null && dataBottom != null) {
                // Both anchors specified - fill space between them
                height =
                    referenceHeight -
                    dataTop.computePosition(referenceHeight) -
                    dataBottom.computePosition(referenceHeight);
              } else if (dataTop != null) {
                // Only top anchor - fill remaining space to bottom
                height =
                    referenceHeight - dataTop.computePosition(referenceHeight);
              } else if (dataBottom != null) {
                // Only bottom anchor - fill remaining space to top
                height =
                    referenceHeight -
                    dataBottom.computePosition(referenceHeight);
              } else {
                // No anchors - fill entire height
                height = referenceHeight;
              }
              // Apply min/max constraints
              final minHeight = dataHeight.min ?? 0.0;
              final maxHeight = dataHeight.max ?? double.infinity;
              height = _clampIgnoreSign(height, minHeight, maxHeight);
            } else if (dataHeight is RatioSize) {
              assert(
                dataWidth is! RatioSize,
                'RatioSize cannot be used with RatioSize for width',
              );
              height = 0; // skip this for now
            } else if (dataHeight is FlexSize) {
              // FlexSize constraints are handled in the flex distribution phase
              // Skip them here and they will be processed later
              height = 0; // Will be set during flex distribution
            } else {
              throw ArgumentError('Invalid height constraint: $dataHeight');
            }
          } else if (dataTop != null && dataBottom != null) {
            height =
                referenceHeight -
                dataTop.computePosition(referenceHeight) -
                dataBottom.computePosition(referenceHeight);
          } else {
            height = child.computeMaxIntrinsicHeight(constraints.maxWidth);
          }
          if (dataWidth is RatioSize) {
            width = height * dataWidth.ratio;
          } else if (dataHeight is RatioSize) {
            height = width / dataHeight.ratio;
          }
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

      // Apply positioning for absolute children now that they are laid out
      child = relativeFirstChild;
      while (child != null) {
        var layoutData = child.parentData as FlexBoxParentData;
        if (layoutData.isAbsolute) {
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
              // right excess first
              double rightExcess = max(
                0,
                -((relativeViewportOffset.dx + constraints.maxWidth) -
                    (horizontal + child.size.width)),
              );
              horizontal -= rightExcess;
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
              horizontal += leftExcess;
            } else {
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
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
              // right excess first
              double rightExcess = max(
                0,
                -((relativeViewportOffset.dx + totalContentSize.width) -
                    (horizontal + child.size.width)),
              );
              horizontal -= rightExcess;
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
              horizontal += leftExcess;
            } else {
              double leftExcess = max(
                0,
                relativeViewportOffset.dx - horizontal,
              );
              horizontal += leftExcess;
              double rightExcess = max(
                0,
                -((relativeViewportOffset.dx + totalContentSize.width) -
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
              -((relativeViewportOffset.dx + totalContentSize.width) -
                  (horizontal + child.size.width)),
            );
            horizontal -= rightExcess;
          }
          if (verticalType == BoxPositionType.fixed) {
            vertical += viewportOffset.dy;
          } else if (verticalType == BoxPositionType.stickyViewport) {
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
              // bottom excess first
              double bottomExcess = max(
                0,
                -((relativeViewportOffset.dy + size.height) -
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
                -((relativeViewportOffset.dy + size.height) -
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
              -((relativeViewportOffset.dy + size.height) -
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

      if (shouldSortChildren) {
        _sortChildren();
      }
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
