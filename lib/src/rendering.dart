import 'dart:math';
import 'dart:ui';

import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

final class LayoutBehavior {
  static const LayoutBehavior none = LayoutBehavior._(1.0);
  static const LayoutBehavior absolute = LayoutBehavior._(0.0);
  static LayoutBehavior lerp(LayoutBehavior a, LayoutBehavior b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return LayoutBehavior._(a.value * (1.0 - t) + b.value * t);
  }

  final double value;

  const LayoutBehavior._(this.value);
}

// note: these values must NOT be null in order to lerp
// see how we handle absolute children with non-null top, left, right, and bottom
final class LayoutData {
  final LayoutBehavior behavior;
  final double flexGrow;
  final double flexShrink;
  final double paintOrder;
  final SizeUnit width;
  final SizeUnit height;
  // by default, top, left, right, and bottom has value of 0
  // it acts like a padding (to the viewport) for absolute children
  // for a case like only anchor to bottom and right, we handle
  // that in alignment, and make sure width and height is set to
  // max-content/min-content/fit-content
  final PositionUnit top;
  final PositionUnit left;
  final PositionUnit right;
  final PositionUnit bottom;
  final Alignment alignment;
  final AspectRatioUnit aspectRatio;

  LayoutData({
    required this.behavior,
    required this.flexGrow,
    required this.flexShrink,
    required this.paintOrder,
    required this.width,
    required this.height,
    required this.top,
    required this.left,
    required this.right,
    required this.bottom,
    required this.alignment,
    required this.aspectRatio,
  });

  static LayoutData lerp(LayoutData a, LayoutData b, double t) {
    if (identical(a, b)) return a;
    if (t <= 0) return a;
    if (t >= 1) return b;
    return LayoutData(
      behavior: LayoutBehavior.lerp(a.behavior, b.behavior, t),
      flexGrow: lerpDouble(a.flexGrow, b.flexGrow, t)!,
      flexShrink: lerpDouble(a.flexShrink, b.flexShrink, t)!,
      paintOrder: lerpDouble(a.paintOrder, b.paintOrder, t)!,
      width: SizeUnit.lerp(a.width, b.width, t),
      height: SizeUnit.lerp(a.height, b.height, t),
      top: PositionUnit.lerp(a.top, b.top, t),
      left: PositionUnit.lerp(a.left, b.left, t),
      right: PositionUnit.lerp(a.right, b.right, t),
      bottom: PositionUnit.lerp(a.bottom, b.bottom, t),
      alignment: Alignment.lerp(a.alignment, b.alignment, t)!,
      aspectRatio: AspectRatioUnit.lerp(a.aspectRatio, b.aspectRatio, t),
    );
  }

  @override
  int get hashCode => Object.hash(
    flexGrow,
    flexShrink,
    paintOrder,
    width,
    height,
    top,
    left,
    right,
    bottom,
    alignment,
    aspectRatio,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LayoutData &&
        other.flexGrow == flexGrow &&
        other.flexShrink == flexShrink &&
        other.paintOrder == paintOrder &&
        other.width == width &&
        other.height == height &&
        other.top == top &&
        other.left == left &&
        other.right == right &&
        other.bottom == bottom &&
        other.alignment == alignment &&
        other.aspectRatio == aspectRatio;
  }
}

class LayoutBoxParentData extends ContainerBoxParentData<RenderBox> {
  ChildLayoutCache? cache;

  LayoutData? layoutData;

  double get paintOrder => layoutData!.paintOrder;

  RenderBox? _nextSortedSibling;
  RenderBox? _previousSortedSibling;
}

class RenderLayoutBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LayoutBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LayoutBoxParentData>,
        ParentLayout
    implements RenderAbstractViewport {
  bool clipPaint;
  @override
  TextDirection textDirection;
  bool reversePaint;
  Axis mainScrollDirection;
  ViewportOffset horizontal;
  ViewportOffset vertical;
  AxisDirection horizontalAxisDirection;
  AxisDirection verticalAxisDirection;
  EdgeInsets viewportExpand;
  late LayoutHandle layoutHandle;
  RenderLayoutBox({
    required Layout layout,
    required this.clipPaint,
    required this.textDirection,
    required this.reversePaint,
    required this.horizontal,
    required this.vertical,
    required this.horizontalAxisDirection,
    required this.verticalAxisDirection,
    required this.viewportExpand,
    required this.mainScrollDirection,
  }) {
    layoutHandle = layout.createLayoutHandle(this);
  }

  Size? _contentSize;

  @override
  Size get contentSize {
    assert(
      _contentSize != null,
      'contentSize is not available before layout. Call layout first.',
    );
    return _contentSize!;
  }

  @override
  Size get viewportSize => size;

  @override
  double get scrollOffsetX => horizontal.pixels;

  @override
  double get scrollOffsetY => vertical.pixels;

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    _firstSortedChild = null;
    _lastSortedChild = null;
  }

  @override
  void dropChild(RenderObject child) {
    _firstSortedChild = null;
    _lastSortedChild = null;
    super.dropChild(child);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    horizontal.addListener(_onScrollOffsetChanged);
    vertical.addListener(_onScrollOffsetChanged);
  }

  @override
  void detach() {
    horizontal.removeListener(_onScrollOffsetChanged);
    vertical.removeListener(_onScrollOffsetChanged);
    super.detach();
  }

  @override
  void performResize() {
    super.performResize();
    horizontal.applyViewportDimension(size.width);
    vertical.applyViewportDimension(size.height);
  }

  void _onScrollOffsetChanged() {
    markNeedsPaint();
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
    required RenderLayoutBox viewport,
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
    required RenderLayoutBox viewport,
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

  Offset get viewportOffset {
    return Offset(horizontal.pixels, vertical.pixels);
  }

  RenderBox? _firstSortedChild;
  RenderBox? _lastSortedChild;

  RenderBox? get relativeFirstPaintChild {
    return reversePaint ? lastChild : firstChild;
  }

  RenderBox? get relativeLastPaintChild {
    return reversePaint ? firstChild : lastChild;
  }

  RenderBox? get sortedFirstPaintChild {
    return _firstSortedChild ??= relativeFirstPaintChild;
  }

  RenderBox? get sortedLastPaintChild {
    return _lastSortedChild ??= relativeLastPaintChild;
  }

  RenderBox? relativeNextPaintSibling(RenderBox child) {
    final childParentData = child.parentData as LayoutBoxParentData;
    return reversePaint
        ? childParentData.previousSibling
        : childParentData.nextSibling;
  }

  RenderBox? relativePreviousPaintSibling(RenderBox child) {
    final childParentData = child.parentData as LayoutBoxParentData;
    return reversePaint
        ? childParentData.nextSibling
        : childParentData.previousSibling;
  }

  RenderBox? sortedNextPaintSibling(RenderBox child) {
    final childParentData = child.parentData as LayoutBoxParentData;
    return childParentData._nextSortedSibling ??= relativeNextPaintSibling(
      child,
    );
  }

  RenderBox? sortedPreviousPaintSibling(RenderBox child) {
    final childParentData = child.parentData as LayoutBoxParentData;
    return childParentData._previousSortedSibling ??=
        relativePreviousPaintSibling(child);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! LayoutBoxParentData) {
      child.parentData = LayoutBoxParentData();
    }
  }

  @override
  void performLayout() {
    bool needsSorting = false;
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as LayoutBoxParentData;
      if (childParentData.paintOrder != 0.0) {
        needsSorting = true;
      }
      childParentData.cache = layoutHandle.setupCache();
      child = childParentData.nextSibling;
    }
    Size contentSize = layoutHandle.performLayout(constraints);
    _contentSize = contentSize;
    layoutHandle.performPositioning(contentSize);
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as LayoutBoxParentData;
      final cache = childParentData.cache!;
      childParentData.offset = Offset(
        cache.offsetX,
        cache.offsetY,
      );
      childParentData.cache = null;
      child = childParentData.nextSibling;
    }
    assert(contentSize.width.isFinite && contentSize.height.isFinite);
    size = constraints.constrain(contentSize);
    horizontal.applyViewportDimension(size.width);
    vertical.applyViewportDimension(size.height);
    horizontal.applyContentDimensions(
      0.0,
      max(0.0, contentSize.width - size.width),
    );
    vertical.applyContentDimensions(
      0.0,
      max(0.0, contentSize.height - size.height),
    );
    if (needsSorting) {
      _sortChildren();
    }
  }

  bool _childOutOfViewport(RenderBox child) {
    final viewportSize = constraints.biggest;
    final layoutData = child.parentData as LayoutBoxParentData;
    final childOffset = layoutData.offset;
    final childSize = child.size;
    final viewportBounds = Offset.zero & viewportSize;
    final childBounds = childOffset & childSize;
    final padding = viewportExpand;
    final paddedViewportBounds = Rect.fromLTWH(
      viewportBounds.left - padding.left,
      viewportBounds.top - padding.top,
      viewportBounds.width + padding.horizontal,
      viewportBounds.height + padding.vertical,
    );
    return !paddedViewportBounds.overlaps(childBounds);
  }

  void _sortChildren() {
    if (childCount <= 1) {
      _firstSortedChild = firstChild;
      _lastSortedChild = lastChild;
      if (firstChild != null) {
        final parentData = firstChild!.parentData as LayoutBoxParentData;
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
        final parentData = current.parentData as LayoutBoxParentData;
        // Clear any previous sorted links.
        parentData._nextSortedSibling = null;
        parentData._previousSortedSibling = null;

        // Add the child to our list only if it's visible.
        if (!_childOutOfViewport(current)) {
          if (visibleHead == null) {
            visibleHead = current;
            visibleTail = current;
          } else {
            (visibleTail!.parentData as LayoutBoxParentData)
                    ._nextSortedSibling =
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
        final parentData = current.parentData as LayoutBoxParentData;
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
      final parentData = current.parentData as LayoutBoxParentData;
      parentData._previousSortedSibling = prev;
      if ((parentData._nextSortedSibling) == null) {
        _lastSortedChild = current;
      }
      prev = current;
      current = parentData._nextSortedSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = sortedLastPaintChild;
    while (child != null) {
      final childParentData = child.parentData! as LayoutBoxParentData;
      if (clipPaint &&
          _childOutOfViewport(child) &&
          _firstSortedChild == null) {
        child = sortedPreviousPaintSibling(child);
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
      child = sortedPreviousPaintSibling(child);
    }
    return false;
  }

  int _compareChildren(RenderBox a, RenderBox b) {
    final aParentData = a.parentData as LayoutBoxParentData;
    final bParentData = b.parentData as LayoutBoxParentData;

    final aZOrder = aParentData.paintOrder ?? 0;
    final bZOrder = bParentData.paintOrder ?? 0;

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
      (a.parentData as LayoutBoxParentData)._nextSortedSibling = _merge(
        (a.parentData as LayoutBoxParentData)._nextSortedSibling,
        b,
      );
    } else {
      result = b;
      (b.parentData as LayoutBoxParentData)._nextSortedSibling = _merge(
        a,
        (b.parentData as LayoutBoxParentData)._nextSortedSibling,
      );
    }
    return result;
  }

  RenderBox? _getMiddle(RenderBox? head) {
    if (head == null) return head;

    RenderBox? slow = head;
    RenderBox? fast =
        (head.parentData as LayoutBoxParentData)._nextSortedSibling;

    while (fast != null) {
      fast = (fast.parentData as LayoutBoxParentData)._nextSortedSibling;
      if (fast != null) {
        slow = (slow!.parentData as LayoutBoxParentData)._nextSortedSibling;
        fast = (fast.parentData as LayoutBoxParentData)._nextSortedSibling;
      }
    }
    return slow;
  }

  RenderBox? _mergeSort(RenderBox? head) {
    if (head == null ||
        (head.parentData as LayoutBoxParentData)._nextSortedSibling == null) {
      return head;
    }

    RenderBox? middle = _getMiddle(head);
    RenderBox? nextOfMiddle =
        (middle!.parentData as LayoutBoxParentData)._nextSortedSibling;

    // Split the list into two halves.
    (middle.parentData as LayoutBoxParentData)._nextSortedSibling = null;

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
    axis ??= mainScrollDirection;

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
    final Offset paintOffset = (box.parentData as LayoutBoxParentData)
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
  ChildLayout? get firstDryLayout {
    RenderBox? child = firstChild;
    RenderBoxChildDryLayout? first;
    RenderBoxChildDryLayout? last;
    while (child != null) {
      final childLayout = RenderBoxChildDryLayout(
        child,
        layoutHandle.setupCache(),
      );
      if (first == null) {
        first = childLayout;
        last = childLayout;
      } else {
        last!.nextSibling = childLayout;
        childLayout.previousSibling = last;
        last = childLayout;
      }
      child = (child.parentData as LayoutBoxParentData).nextSibling;
    }
    return first;
  }

  @override
  ChildLayout? get lastDryLayout {
    RenderBox? child = lastChild;
    RenderBoxChildDryLayout? first;
    RenderBoxChildDryLayout? last;
    while (child != null) {
      final childLayout = RenderBoxChildDryLayout(
        child,
        layoutHandle.setupCache(),
      );
      if (first == null) {
        first = childLayout;
        last = childLayout;
      } else {
        first.previousSibling = childLayout;
        childLayout.nextSibling = first;
        first = childLayout;
      }
      child = (child.parentData as LayoutBoxParentData).previousSibling;
    }
    return last;
  }

  @override
  ChildLayout? get firstLayoutChild {
    RenderBox? child = firstChild;
    if (child != null) {
      return RenderBoxChildLayout(child);
    }
    return null;
  }

  @override
  ChildLayout? get lastLayoutChild {
    RenderBox? child = lastChild;
    if (child != null) {
      return RenderBoxChildLayout(child);
    }
    return null;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return layoutHandle.performLayout(constraints, true);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return layoutHandle.computeMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return layoutHandle.computeMaxIntrinsicHeight(width);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return layoutHandle.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return layoutHandle.computeMaxIntrinsicWidth(height);
  }
}

class RenderBoxChildLayout with ChildLayout {
  final RenderBox renderBox;
  RenderBoxChildLayout(this.renderBox);

  @override
  Size get size => renderBox.size;

  @override
  ChildLayout? get nextSibling {
    final parentData = renderBox.parentData as LayoutBoxParentData;
    final next = parentData.nextSibling;
    if (next != null) {
      return RenderBoxChildLayout(next);
    }
    return null;
  }

  @override
  ChildLayout? get previousSibling {
    final parentData = renderBox.parentData as LayoutBoxParentData;
    final previous = parentData.previousSibling;
    if (previous != null) {
      return RenderBoxChildLayout(previous);
    }
    return null;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return renderBox.getMaxIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return renderBox.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return renderBox.getMinIntrinsicHeight(width);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return renderBox.getMinIntrinsicWidth(height);
  }

  @override
  Size dryLayout(BoxConstraints constraints) {
    return renderBox.getDryLayout(constraints);
  }

  @override
  void layout(BoxConstraints constraints) {
    renderBox.layout(constraints, parentUsesSize: true);
  }

  @override
  ChildLayoutCache get layoutCache =>
      (renderBox.parentData as LayoutBoxParentData).cache!;

  @override
  LayoutData get layoutData =>
      (renderBox.parentData as LayoutBoxParentData).layoutData!;
}

class RenderBoxChildDryLayout with ChildLayout {
  final RenderBox renderBox;
  @override
  final ChildLayoutCache layoutCache;
  @override
  late ChildLayout? nextSibling;
  @override
  late ChildLayout? previousSibling;
  RenderBoxChildDryLayout(this.renderBox, this.layoutCache);
  @override
  Size get size => throw FlutterError(
    'size is not available in dry layout. ',
  );

  @override
  double computeMaxIntrinsicHeight(double width) {
    return renderBox.getMaxIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return renderBox.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return renderBox.getMinIntrinsicHeight(width);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return renderBox.getMinIntrinsicWidth(height);
  }

  @override
  Size dryLayout(BoxConstraints constraints) {
    return renderBox.getDryLayout(constraints);
  }

  @override
  void layout(BoxConstraints constraints) {}

  @override
  LayoutData get layoutData =>
      (renderBox.parentData as LayoutBoxParentData).layoutData!;
}
