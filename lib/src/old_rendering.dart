import 'dart:math';

import 'package:flexiblebox/src/old_flex.dart';
import 'package:flexiblebox/src/old_foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

double _clampNullable(double value, double? min, double? max) {
  if (min != null && value < min) {
    return min;
  }
  if (max != null && value > max) {
    return max;
  }
  return value;
}

class FlexBoxParentData extends ContainerBoxParentData<RenderBox>
    with FlexChildData {
  bool absolute = false;
  AlignmentGeometry? alignment;
  BoxValue? top;
  BoxValue? bottom;
  BoxValue? left;
  BoxValue? right;
  BoxValue? width;
  BoxValue? height;
  BoxValue? minWidth;
  BoxValue? maxWidth;
  BoxValue? minHeight;
  BoxValue? maxHeight;
  BoxPositionType? horizontalPosition;
  BoxPositionType? verticalPosition;
  bool horizontalScrollAffected = true;
  bool verticalScrollAffected = true;
  int? zOrder;
  @override
  double? flexGrow;
  @override
  double? flexShrink;
  @override
  bool get isAbsolute {
    return absolute ||
        top != null ||
        bottom != null ||
        left != null ||
        right != null;
  }

  RenderBox? _nextSortedSibling;
  RenderBox? _previousSortedSibling;

  @override
  bool computeFlex({
    required FlexParent parent,
    required FlexChild child,
  }) {
    double contentSize = parent.getLineContentSize(true, line);
    double viewportSize = parent.viewportMainSize;
    double overflow = contentSize - viewportSize;
    bool hasFlex = false;
    if (overflow > 0) {
      // shrinkage!
      double? flexShrink = this.flexShrink;
      if (flexShrink != null) {
        double? shrinkFactor = parent.getShrinkFactor(line);
        assert(shrinkFactor != null);
        double shrinkAmount =
            (contentSize * flexShrink / shrinkFactor!) * overflow;
        flexSize = -shrinkAmount;
        hasFlex = true;
      }
    } else {
      double? flexGrow = this.flexGrow;
      if (flexGrow != null) {
        double flexFactor = parent.getFlexFactor(line);
        double growAmount = (contentSize / flexFactor) * flexGrow;
        flexSize = growAmount;
        hasFlex = true;
      }
    }
    double newMainContentSize = computedMainSize;
    double clamped = _clampNullable(
      newMainContentSize,
      minMainSize,
      maxMainSize,
    );
    if (clamped != newMainContentSize && hasFlex) {
      // clamped and turned into fixed size
      // request for flex recompute
      frozen = true;
      return true;
    }
    return false;
  }

  @override
  void computePosition({
    required FlexParent parent,
    required FlexChild child,
    required double previousMainOffset,
  }) {
    // TODO: implement computePosition
  }

  @override
  FlexChild? get nextFlexChild {
    final nextSibling = this.nextSibling;
    if (nextSibling == null) {
      return null;
    }
    return RenderBoxFlexChild(nextSibling);
  }

  @override
  FlexChild? get previousFlexChild {
    final previousSibling = this.previousSibling;
    if (previousSibling == null) {
      return null;
    }
    return RenderBoxFlexChild(previousSibling);
  }

  BoxValue? getSize(Axis axis) {
    switch (axis) {
      case Axis.horizontal:
        return width;
      case Axis.vertical:
        return height;
    }
  }

  @override
  bool computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
  }) {
    bool computeAdditionalFlexBasis = false;
    final mainResult = getSize(
      parent.direction,
    )?.computeFlexBasis(parent: parent, child: child, mainAxis: true);
    if (mainResult != null) {
      computeAdditionalFlexBasis |= mainResult.computeAdditionalFlexBasis;
      if (mainResult.result != null) {
        flexBasis = mainResult.result!;
      }
    }
    final crossResult = getSize(
      parent.crossDirection,
    )?.computeFlexBasis(parent: parent, child: child, mainAxis: false);
    if (crossResult != null) {
      computeAdditionalFlexBasis |= crossResult.computeAdditionalFlexBasis;
      if (crossResult.result != null) {
        crossFlexBasis = crossResult.result!;
      }
    }
    return computeAdditionalFlexBasis;
  }

  @override
  void computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final mainResult = getSize(
      parent.direction,
    )?.computeAdditionalFlexBasis(parent: parent, child: child, mainAxis: true);
    if (mainResult != null) {
      additionalFlexBasis = mainResult;
    }
    final crossResult = getSize(parent.crossDirection)
        ?.computeAdditionalFlexBasis(
          parent: parent,
          child: child,
          mainAxis: false,
        );
    if (crossResult != null) {
      additionalCrossFlexBasis = crossResult;
    }
  }

  @override
  bool computePostFlex({required FlexParent parent, required FlexChild child}) {
    final crossResult = getSize(
      parent.crossDirection,
    )?.computePostFlex(parent: parent, child: child);
    if (crossResult != null) {
      if (crossResult.result != null) {
        additionalCrossFlexBasis =
            (additionalCrossFlexBasis ?? 0.0) + crossResult.result!;
      }
      return crossResult.computePostLayout;
    }
    return false;
  }

  @override
  void computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  }) {
    final crossResult = getSize(
      parent.crossDirection,
    )?.computePostLayout(parent: parent, child: child);
    if (crossResult != null) {
      additionalCrossFlexBasis =
          (additionalCrossFlexBasis ?? 0.0) + crossResult;
    }
  }
}

class _Store<T> {
  T value;
  _Store(this.value);
}

class RenderFlexBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexBoxParentData>,
        FlexParent
    implements RenderAbstractViewport {
  static const maxComputePass = 5;
  @override
  Axis direction;
  BoxValue? spacing;
  BoxValue? spacingBefore;
  BoxValue? spacingAfter;
  Alignment alignment;
  ViewportOffset horizontal;
  ViewportOffset vertical;
  AxisDirection verticalAxisDirection;
  AxisDirection horizontalAxisDirection;
  bool reverse;
  bool reversePaint;
  bool clipPaint;
  EdgeInsets padding;
  TextDirection textDirection;
  BoxFit fit;

  RenderFlexBox({
    required this.direction,
    required this.spacing,
    required this.spacingBefore,
    required this.spacingAfter,
    required this.alignment,
    required this.horizontal,
    required this.vertical,
    required this.verticalAxisDirection,
    required this.horizontalAxisDirection,
    required this.reversePaint,
    required this.clipPaint,
    required this.reverse,
    required this.padding,
    required this.fit,
    required this.textDirection,
  });

  @override
  bool get enableWrap => throw UnimplementedError();

  @override
  double get viewportMainSize => throw UnimplementedError();

  @override
  double get viewportCrossSize => throw UnimplementedError();

  FlexBoxLayoutChange layoutChange = FlexBoxLayoutChange.both;
  FlexBoxPositionChange positionChange = FlexBoxPositionChange.both;
  bool needsResort = true;

  RenderBox? _firstSortedChild;
  RenderBox? _lastSortedChild;

  void clearSortedChildren() {
    _firstSortedChild = null;
    _lastSortedChild = null;
  }

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
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    if (hasSize && constraints != this.constraints) {
      // force a full relayout if constraints changed
      layoutChange = FlexBoxLayoutChange.both;
      positionChange = FlexBoxPositionChange.both;
    }
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final maxViewportMainSize = _getMainMaxConstraints(constraints);
    final maxViewportCrossSize = _getCrossMaxConstraints(constraints);
    final result = _layoutChildren(
      maxViewportMainSize: maxViewportMainSize,
      maxViewportCrossSize: maxViewportCrossSize,
      // we don't need to layout or getDryLayout the children
      // because the we handle the size of the children here,
      // also we only need to layout non-absolute children
      // because absolute children does not affect the size of the flexbox
      layoutChange: FlexBoxLayoutChange.nonAbsolute,
    );
    double width;
    double height;
    switch (direction) {
      case Axis.horizontal:
        width = result.mainContentSize;
        height = result.crossContentSize;
        break;
      case Axis.vertical:
        width = result.crossContentSize;
        height = result.mainContentSize;
        break;
    }
    return Size(
      constraints.constrainWidth(width),
      constraints.constrainHeight(height),
    );
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    vertical.addListener(_onScrollOffsetChanged);
    horizontal.addListener(_onScrollOffsetChanged);
  }

  @override
  void detach() {
    super.detach();
    vertical.removeListener(_onScrollOffsetChanged);
    horizontal.removeListener(_onScrollOffsetChanged);
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
      vertical.removeListener(_onScrollOffsetChanged);
      vertical = offset;
      if (attached) {
        vertical.addListener(_onScrollOffsetChanged);
      }
    }
  }

  void updateHorizontalOffset(ViewportOffset offset) {
    if (horizontal != offset) {
      horizontal.removeListener(_onScrollOffsetChanged);
      horizontal = offset;
      if (attached) {
        horizontal.addListener(_onScrollOffsetChanged);
      }
    }
  }

  void _onScrollOffsetChanged() {
    positionChange |= FlexBoxPositionChange.both;
    markNeedsLayout();
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

  Size _createSize(double mainSize, double crossSize) {
    return direction == Axis.horizontal
        ? Size(mainSize, crossSize)
        : Size(crossSize, mainSize);
  }

  double _getMainMaxConstraints(BoxConstraints constraints) {
    return direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
  }

  double _getCrossMaxConstraints(BoxConstraints constraints) {
    return direction == Axis.horizontal
        ? constraints.maxHeight
        : constraints.maxWidth;
  }

  Size? _contentSize;
  double? _flexUnit;
  bool? shouldSortChildren;
  double? _spacing;
  double? _spacingBefore;
  double? _spacingAfter;
  _Store<RenderBox?>? _firstAbsoluteChild;
  _Store<RenderBox?>? _firstNonAbsoluteChild;
  Map<Key, double>? _dependencies;

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    _firstAbsoluteChild = null;
    _firstNonAbsoluteChild = null;
    layoutChange |= FlexBoxLayoutChange.both;
    positionChange |= FlexBoxPositionChange.both;
    needsResort = true;
  }

  void _resetAbsoluteChildPointer(RenderObject child) {
    if (_firstAbsoluteChild != null &&
        identical(_firstAbsoluteChild!.value, child)) {
      _firstAbsoluteChild = null;
    }
  }

  void _resetNonAbsoluteChildPointer(RenderObject child) {
    if (_firstNonAbsoluteChild != null &&
        identical(_firstNonAbsoluteChild!.value, child)) {
      _firstNonAbsoluteChild = null;
    }
  }

  @override
  void dropChild(RenderObject child) {
    _resetAbsoluteChildPointer(child);
    _resetNonAbsoluteChildPointer(child);
    layoutChange |= FlexBoxLayoutChange.both;
    positionChange |= FlexBoxPositionChange.both;
    needsResort = true;
    super.dropChild(child);
  }

  @override
  void performLayout() {
    DateTime start = DateTime.now();
    double maxMainViewportSize = _getMainMaxConstraints(constraints);
    double maxCrossViewportSize = _getCrossMaxConstraints(constraints);
    horizontal.applyViewportDimension(size.width);
    vertical.applyViewportDimension(size.height);
    horizontal.applyContentDimensions(
      0.0,
      max(0.0, _contentSize!.width - size.width),
    );
    vertical.applyContentDimensions(
      0.0,
      max(0.0, _contentSize!.height - size.height),
    );
    // shouldSortChildren indicates
    // that at least one child has zOrder set
    if (shouldSortChildren!) {
      if (needsResort) {
        _sortChildren();
      }
    } else {
      clearSortedChildren();
    }

    layoutChange = FlexBoxLayoutChange.none;
    positionChange = FlexBoxPositionChange.none;
    needsResort = false;
    Duration elapsed = DateTime.now().difference(start);
    print('took ${elapsed.inMilliseconds}ms');
  }

  double _align(double value, double alignment) {
    // alignment is between -1.0 and 1.0
    // but also expect the alignment to go beyond that
    final center = value / 2;
    return center + alignment * center;
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
    final padding = this.padding;
    final paddedViewportBounds = Rect.fromLTWH(
      viewportBounds.left - padding.left,
      viewportBounds.top - padding.top,
      viewportBounds.width + padding.horizontal,
      viewportBounds.height + padding.vertical,
    );
    return !paddedViewportBounds.overlaps(childBounds);
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

  double _getMain(Size size) {
    return direction == Axis.horizontal ? size.width : size.height;
  }

  double _getCross(Size size) {
    return direction == Axis.horizontal ? size.height : size.width;
  }

  double _computeIntrinsicSize(double size, bool computeMax) {
    double totalSize = 0.0;
    Map<Key, double> dependencies = {};
    bool resolved = false;
    int iteration = 0;
    while (!resolved && iteration < maxComputePass) {
      bool desparate = iteration == maxComputePass - 1;
      bool dependenciesResolved = true;
      RenderBox? child = firstChild;
      totalSize = 0.0;
      final spacing = this.spacing;
      final spacingBefore = this.spacingBefore;
      final spacingAfter = this.spacingAfter;
      if (spacing != null) {
        final resolvedSpacing = spacing.computeIntrinsicSize(
          child: null,
          direction: direction,
          extent: size,
          dependencies: dependencies,
          computeMax: computeMax,
        );
        if (resolvedSpacing == null && !desparate) {
          dependenciesResolved = false;
        } else {
          totalSize += resolvedSpacing ?? 0.0;
        }
      }
      if (spacingBefore != null) {
        final resolvedSpacingBefore = spacingBefore.computeIntrinsicSize(
          child: null,
          direction: direction,
          extent: size,
          dependencies: dependencies,
          computeMax: computeMax,
        );
        if (resolvedSpacingBefore == null && !desparate) {
          dependenciesResolved = false;
        } else {
          totalSize += resolvedSpacingBefore ?? 0.0;
        }
      }
      if (spacingAfter != null) {
        final resolvedSpacingAfter = spacingAfter.computeIntrinsicSize(
          child: null,
          direction: direction,
          extent: size,
          dependencies: dependencies,
          computeMax: computeMax,
        );
        if (resolvedSpacingAfter == null && !desparate) {
          dependenciesResolved = false;
        } else {
          totalSize += resolvedSpacingAfter ?? 0.0;
        }
      }
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        BoxValue? mainSize = data.getSize(direction);
        if (mainSize != null) {
          double? result = mainSize.computeIntrinsicSize(
            child: child,
            direction: direction,
            extent: size,
            dependencies: dependencies,
            computeMax: computeMax,
          );
          if (result == null && !desparate) {
            dependenciesResolved = false;
          } else {
            totalSize += result ?? 0.0;
          }
        }
        child = data.nextSibling;
      }
      if (dependenciesResolved) {
        resolved = true;
      }
      iteration++;
    }
    return totalSize;
  }

  double _computeCrossIntrinsicSize(double size, bool computeMax) {
    double maxSize = 0.0;
    Map<Key, double> dependencies = {};
    bool resolved = false;
    int iteration = 0;
    while (!resolved && iteration < maxComputePass) {
      // no need to compute spacing for cross size
      // spacing only affects main size
      bool desparate = iteration == maxComputePass - 1;
      bool dependenciesResolved = true;
      RenderBox? child = firstChild;
      maxSize = 0.0;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        BoxValue? crossSize = data.getSize(crossDirection);
        if (crossSize != null) {
          double? result = crossSize.computeIntrinsicSize(
            child: child,
            direction: crossDirection,
            extent: size,
            dependencies: dependencies,
            computeMax: computeMax,
          );
          if (result == null && !desparate) {
            dependenciesResolved = false;
          } else {
            maxSize = max(maxSize, result ?? 0.0);
          }
        }
        child = data.nextSibling;
      }
      if (dependenciesResolved) {
        resolved = true;
      }
      iteration++;
    }
    return maxSize;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return direction == Axis.horizontal
        ? _computeCrossIntrinsicSize(width, true)
        : _computeIntrinsicSize(width, true);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return direction == Axis.horizontal
        ? _computeIntrinsicSize(height, true)
        : _computeCrossIntrinsicSize(height, true);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return direction == Axis.horizontal
        ? _computeCrossIntrinsicSize(width, false)
        : _computeIntrinsicSize(width, false);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return direction == Axis.horizontal
        ? _computeIntrinsicSize(height, false)
        : _computeCrossIntrinsicSize(height, false);
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

  @override
  bool get reverseCrossAxis => throw UnimplementedError();

  @override
  bool get reverseMainAxis => throw UnimplementedError();
}

double? _addNullable(double? a, double? b) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    assert(b?.isNaN == false);
    return b;
  }
  if (b == null) {
    assert(a.isNaN == false);
    return a;
  }
  assert(!a.isNaN && !b.isNaN);
  return a + b;
}

double _maxNullable(double? a, double b) {
  if (a == null) return b;
  return max(a, b);
}

double? _maxNulls(double? a, double? b) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return max(a, b);
}

double? _minNulls(double? a, double? b) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return min(a, b);
}

bool _containsAllKeys(Map<Key, double> map, Iterable<Key> keys) {
  for (var key in keys) {
    if (!map.containsKey(key)) {
      return false;
    }
  }
  return true;
}
