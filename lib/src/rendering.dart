import 'dart:math';

import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flexiblebox/src/widgets/builder.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Parent data for children of [RenderLayoutBox].
///
/// This class extends Flutter's [ContainerBoxParentData] to include
/// layout-specific information needed by the flexbox layout system.
/// It stores layout data, caching information, and paint ordering
/// for each child in a layout container.
class LayoutBoxParentData extends ContainerBoxParentData<RenderBox> {
  Key? debugKey;
  ChildLayoutCache? cache;

  LayoutData? layoutData;

  bool needLayoutBox = false;

  int? get paintOrder => layoutData!.paintOrder;

  RenderBox? _nextSortedSibling;
  RenderBox? _previousSortedSibling;
}

/// Render object for flexbox layout containers.
///
/// [RenderLayoutBox] is the core render object that implements the flexbox layout
/// algorithm. It manages child positioning, scrolling, overflow handling, and
/// integrates with Flutter's rendering pipeline. This render object supports
/// complex layout scenarios including scrolling in both directions, custom
/// layout algorithms, and viewport management.
///
/// It implements [RenderAbstractViewport] to provide scrolling capabilities
/// and works with various layout algorithms through the [Layout] interface.
class RenderLayoutBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LayoutBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LayoutBoxParentData>,
        ParentLayout
    implements RenderAbstractViewport {
  static RenderLayoutBox? find(BuildContext context) {
    RenderObject? renderObject = context.findRenderObject();
    return _findInDescendants(renderObject);
  }

  static RenderLayoutBox? _findInDescendants(RenderObject? renderObject) {
    if (renderObject is RenderLayoutBox) {
      return renderObject;
    }
    RenderLayoutBox? result;
    renderObject?.visitChildren((child) {
      if (result != null) {
        return;
      }
      result = _findInDescendants(child);
    });
    return result;
  }

  @override
  LayoutTextDirection get textDirection =>
      layoutTextDirectionFromTextDirection(layoutTextDirection);
  bool reversePaint;
  Axis mainScrollDirection;
  ViewportOffset horizontal;
  ViewportOffset vertical;
  AxisDirection horizontalAxisDirection;
  AxisDirection verticalAxisDirection;
  LayoutOverflow horizontalOverflow;
  LayoutOverflow verticalOverflow;
  Layout boxLayout;
  @override
  LayoutTextBaseline? get textBaseline => layoutTextBaseline == null
      ? null
      : layoutTextBaselineFromTextBaseline(layoutTextBaseline!);
  BorderRadius borderRadius;
  Clip clipBehavior;
  TextDirection layoutTextDirection;
  TextBaseline? layoutTextBaseline;
  RenderLayoutBox({
    required this.boxLayout,
    required this.layoutTextDirection,
    required this.reversePaint,
    required this.horizontal,
    required this.vertical,
    required this.horizontalAxisDirection,
    required this.verticalAxisDirection,
    required this.mainScrollDirection,
    required this.horizontalOverflow,
    required this.verticalOverflow,
    required this.layoutTextBaseline,
    required this.borderRadius,
    required this.clipBehavior,
  });

  int indexOfNearestChildAtOffset(Offset localOffset) {
    final layoutHandle = _layoutHandle;
    assert(
      layoutHandle != null,
      'LayoutBox must be laid out before calling indexOfNearestChildAtOffset',
    );
    if (layoutHandle == null) {
      return -1;
    }
    return layoutHandle.indexOfNearestChildAtOffset(
      layoutOffsetFromOffset(localOffset),
    );
  }

  LayoutHandle? _layoutHandle;

  LayoutSize? _contentSize;

  // bounds including absolute positioned children
  LayoutRect? _contentBounds;

  @override
  LayoutSize get contentSize {
    assert(
      _contentSize != null,
      'contentSize is not available before layout. Call layout first.',
    );
    return _contentSize!;
  }

  Rect get contentBounds {
    assert(
      _contentBounds != null,
      'contentBounds is not available before layout. Call layout first.',
    );
    return rectFromLayoutRect(_contentBounds!);
  }

  @override
  LayoutSize get viewportSize => layoutSizeFromSize(size);

  @override
  double get scrollOffsetX => horizontalOverflow.reverse
      ? contentSize.width - viewportSize.width - horizontal.pixels
      : horizontal.pixels;

  @override
  double get scrollOffsetY => verticalOverflow.reverse
      ? contentSize.height - viewportSize.height - vertical.pixels
      : vertical.pixels;

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
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return switch (mainScrollDirection) {
      Axis.horizontal => defaultComputeDistanceToHighestActualBaseline(
        baseline,
      ),
      Axis.vertical => defaultComputeDistanceToFirstActualBaseline(baseline),
    };
  }

  @override
  void performResize() {
    super.performResize();
    horizontal.applyViewportDimension(size.width);
    vertical.applyViewportDimension(size.height);
  }

  void _onScrollOffsetChanged() {
    markNeedsLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Rect paintBounds = actualPaintBounds ?? contentBounds;
    layer = context.pushClipRRect(
      needsCompositing,
      offset,
      paintBounds,
      borderRadius.toRRect(paintBounds),
      (PaintingContext context, Offset offset) {
        RenderBox? child = sortedFirstPaintChild;
        while (child != null) {
          assert(
            child.parentData is LayoutBoxParentData,
            'Expected child.parentData ($child) to be a LayoutBoxParentData but got ${child.parentData.runtimeType}',
          );
          final childParentData = child.parentData as LayoutBoxParentData;
          final childOffset = childParentData.offset;
          final childBounds = childOffset & child.size;
          // no need to bother painting children that are out of the paint bounds
          if (paintBounds.overlaps(childBounds)) {
            context.paintChild(child, childOffset + offset);
          }
          child = sortedNextPaintSibling(child);
        }
      },
      clipBehavior: clipBehavior,
      oldLayer: layer as ClipRRectLayer?,
    );
  }

  Rect? get actualPaintBounds {
    bool clipHorizontal = horizontalOverflow.clipContent;
    bool clipVertical = verticalOverflow.clipContent;
    if (!clipHorizontal && !clipVertical) {
      return null;
    }
    Rect contentBounds = this.contentBounds;
    return Rect.fromLTWH(
      clipHorizontal ? 0.0 : contentBounds.left,
      clipVertical ? 0.0 : contentBounds.top,
      clipHorizontal ? size.width : contentBounds.width,
      clipVertical ? size.height : contentBounds.height,
    );
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

  RenderBox? get sortedFirstPaintChild {
    return reversePaint
        ? (_lastSortedChild ?? lastChild)
        : (_firstSortedChild ?? firstChild);
  }

  RenderBox? get sortedLastPaintChild {
    return reversePaint
        ? (_firstSortedChild ?? firstChild)
        : (_lastSortedChild ?? lastChild);
  }

  bool get isSorted => _firstSortedChild != null && _lastSortedChild != null;

  RenderBox? sortedNextPaintSibling(RenderBox child) {
    final childParentData = child.parentData as LayoutBoxParentData;
    if (isSorted) {
      return reversePaint
          ? childParentData._previousSortedSibling
          : childParentData._nextSortedSibling;
    }
    return reversePaint
        ? childParentData.previousSibling
        : childParentData.nextSibling;
  }

  RenderBox? sortedPreviousPaintSibling(RenderBox child) {
    final childParentData = child.parentData as LayoutBoxParentData;
    if (isSorted) {
      return reversePaint
          ? childParentData._nextSortedSibling
          : childParentData._previousSortedSibling;
    }
    return reversePaint
        ? childParentData.nextSibling
        : childParentData.previousSibling;
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! LayoutBoxParentData) {
      child.parentData = LayoutBoxParentData();
    }
  }

  @override
  void performLayout() {
    _firstSortedChild = null;
    _lastSortedChild = null;
    bool needsSorting = false;
    LayoutHandle layoutHandle = boxLayout.createLayoutHandle(this);
    _layoutHandle = layoutHandle;
    RenderBox? child = firstChild;
    int childIndex = 0;
    while (child != null) {
      final childParentData = child.parentData as LayoutBoxParentData;
      if (childParentData.paintOrder != null) {
        needsSorting = true;
      }
      final cache = childParentData.cache = layoutHandle.setupCache();
      cache.index = childIndex;
      childIndex++;
      childParentData._nextSortedSibling = null;
      childParentData._previousSortedSibling = null;
      child = childParentData.nextSibling;
    }
    final layoutConstraints = layoutConstraintsFromBoxConstraints(
      constraints,
    );
    LayoutSize contentSize = layoutHandle.performLayout(layoutConstraints);
    final viewportSize = layoutConstraints.constrain(contentSize);
    _contentSize = contentSize;
    size = sizeFromLayoutSize(viewportSize);
    _contentBounds = layoutHandle.performPositioning(
      viewportSize,
      contentSize,
    );
    assert(contentSize.width.isFinite && contentSize.height.isFinite);
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
    final childParentData = child.parentData as LayoutBoxParentData;
    final childRect = childParentData.offset & child.size;
    return !childRect.overlaps(visibleContentBounds.outerRect);
  }

  void _sortChildren() {
    _firstSortedChild = null;
    _lastSortedChild = null;
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

    bool clipHorizontal = horizontalOverflow.clipContent;
    bool clipVertical = verticalOverflow.clipContent;

    // Check if we should only consider visible children.
    if (clipHorizontal || clipVertical) {
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

  RRect get visibleContentBounds {
    return borderRadius.toRRect(actualPaintBounds ?? paintBounds);
  }

  void printDebugSortedChildren() {
    // print out like this: [debugKey, debugKey, ...]
    List<String> keys = [];
    RenderBox? child = sortedFirstPaintChild;
    while (child != null) {
      keys.add(child.toString());
      child = sortedNextPaintSibling(child);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!visibleContentBounds.contains(position)) {
      return false;
    }
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    bool clipHorizontal = horizontalOverflow.clipContent;
    bool clipVertical = verticalOverflow.clipContent;
    RenderBox? child = sortedLastPaintChild;
    while (child != null) {
      final childParentData = child.parentData! as LayoutBoxParentData;
      if ((clipHorizontal || clipVertical) &&
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
  ChildLayout? getFirstDryLayout(LayoutHandle<Layout> layoutHandle) {
    return ChildLayoutDryDelegate.forwardCopy(firstLayoutChild, layoutHandle);
  }

  @override
  ChildLayout? getLastDryLayout(LayoutHandle<Layout> layoutHandle) {
    return ChildLayoutDryDelegate.backwardCopy(lastLayoutChild, layoutHandle);
  }

  @override
  ChildLayout? get firstLayoutChild {
    RenderBox? child = firstChild;
    if (child != null) {
      return RenderBoxChildLayout(child, this);
    }
    return null;
  }

  @override
  ChildLayout? get lastLayoutChild {
    RenderBox? child = lastChild;
    if (child != null) {
      return RenderBoxChildLayout(child, this);
    }
    return null;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    if (constraints.isTight) {
      return constraints.smallest;
    }
    final layoutHandle = boxLayout.createLayoutHandle(this);
    Size size = sizeFromLayoutSize(
      layoutHandle.performLayout(
        layoutConstraintsFromBoxConstraints(constraints),
        true,
      ),
    );
    return constraints.constrain(size);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMaxIntrinsicHeight(width);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMaxIntrinsicWidth(height);
  }
}

/// Adapter that makes a [RenderBox] compatible with the flexbox layout system.
///
/// [RenderBoxChildLayout] implements the [ChildLayout] interface for Flutter's
/// [RenderBox] objects, allowing them to participate in flexbox layouts.
/// It provides the bridge between Flutter's rendering system and the
/// flexbox layout algorithm, handling layout calculations, caching, and
/// positioning for individual render box children.
class RenderBoxChildLayout with ChildLayout {
  final RenderLayoutBox parent;
  final RenderBox renderBox;

  RenderBoxChildLayout(this.renderBox, this.parent);

  @override
  Object? get debugKey {
    final debugKey = (renderBox.parentData as LayoutBoxParentData).debugKey;
    if (debugKey is ValueKey) {
      return debugKey.value;
    }
    return debugKey;
  }

  @override
  void clearCache() {
    (renderBox.parentData as LayoutBoxParentData).cache = null;
  }

  @override
  LayoutSize get size => layoutSizeFromSize(renderBox.size);

  @override
  LayoutOffset get offset => layoutOffsetFromOffset(
    (renderBox.parentData as LayoutBoxParentData).offset,
  );

  @override
  double getDistanceToBaseline(LayoutTextBaseline baseline) {
    return renderBox.getDistanceToBaseline(
          textBaselineFromLayoutTextBaseline(baseline),
        ) ??
        size.height;
  }

  @override
  ChildLayout? get nextSibling {
    final parentData = renderBox.parentData as LayoutBoxParentData;
    final next = parentData.nextSibling;
    if (next != null) {
      return RenderBoxChildLayout(next, parent);
    }
    return null;
  }

  @override
  ChildLayout? get previousSibling {
    final parentData = renderBox.parentData as LayoutBoxParentData;
    final previous = parentData.previousSibling;
    if (previous != null) {
      return RenderBoxChildLayout(previous, parent);
    }
    return null;
  }

  @override
  double getMaxIntrinsicHeight(double width) {
    return renderBox.getMaxIntrinsicHeight(width);
  }

  @override
  double getMaxIntrinsicWidth(double height) {
    return renderBox.getMaxIntrinsicWidth(height);
  }

  @override
  double getMinIntrinsicHeight(double width) {
    return renderBox.getMinIntrinsicHeight(width);
  }

  @override
  double getMinIntrinsicWidth(double height) {
    return renderBox.getMinIntrinsicWidth(height);
  }

  @override
  LayoutSize dryLayout(LayoutConstraints constraints) {
    return layoutSizeFromSize(
      renderBox.getDryLayout(
        boxConstraintsFromLayoutConstraints(constraints),
      ),
    );
  }

  @override
  void layout(
    LayoutOffset offset,
    LayoutSize size,
    OverflowBounds overflowBounds,
  ) {
    double maxScrollX = parent.contentSize.width - parent.viewportSize.width;
    double maxScrollY = parent.contentSize.height - parent.viewportSize.height;
    maxScrollX = max(0.0, maxScrollX);
    maxScrollY = max(0.0, maxScrollY);
    (renderBox.parentData as LayoutBoxParentData).offset =
        offsetFromLayoutOffset(offset);
    renderBox.layout(
      (renderBox.parentData as LayoutBoxParentData).needLayoutBox
          ? WrappedLayoutConstraints(
              size: sizeFromLayoutSize(size),
              offset: offsetFromLayoutOffset(offset),
              scrollX: parent.scrollOffsetX,
              scrollY: parent.scrollOffsetY,
              maxScrollX: maxScrollX,
              maxScrollY: maxScrollY,
              contentSize: sizeFromLayoutSize(parent.contentSize),
              viewportSize: sizeFromLayoutSize(parent.viewportSize),
              horizontalUserScrollDirection: parent.horizontalAxisDirection,
              verticalUserScrollDirection: parent.verticalAxisDirection,
              overflowBounds: overflowBounds,
            )
          : BoxConstraints.tight(
              sizeFromLayoutSize(size),
            ),
      parentUsesSize: true,
    );
  }

  @override
  int get hashCode => renderBox.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is RenderBoxChildLayout) {
      return other.renderBox == renderBox;
    }
    return false;
  }

  @override
  ChildLayoutCache get layoutCache =>
      (renderBox.parentData as LayoutBoxParentData).cache!;

  @override
  LayoutData get layoutData =>
      (renderBox.parentData as LayoutBoxParentData).layoutData!;
}

LayoutSize layoutSizeFromSize(Size size) {
  return LayoutSize(size.width, size.height);
}

Size sizeFromLayoutSize(LayoutSize size) {
  return Size(size.width, size.height);
}

LayoutOffset layoutOffsetFromOffset(Offset offset) {
  return LayoutOffset(offset.dx, offset.dy);
}

Offset offsetFromLayoutOffset(LayoutOffset offset) {
  return Offset(offset.dx, offset.dy);
}

LayoutRect layoutRectFromRect(Rect rect) {
  return LayoutRect.fromLTRB(
    rect.left,
    rect.top,
    rect.right,
    rect.bottom,
  );
}

Rect rectFromLayoutRect(LayoutRect rect) {
  return Rect.fromLTRB(
    rect.left,
    rect.top,
    rect.right,
    rect.bottom,
  );
}

LayoutTextBaseline layoutTextBaselineFromTextBaseline(TextBaseline baseline) {
  return switch (baseline) {
    TextBaseline.alphabetic => LayoutTextBaseline.alphabetic,
    TextBaseline.ideographic => LayoutTextBaseline.ideographic,
  };
}

TextBaseline textBaselineFromLayoutTextBaseline(
  LayoutTextBaseline baseline,
) {
  return switch (baseline) {
    LayoutTextBaseline.alphabetic => TextBaseline.alphabetic,
    LayoutTextBaseline.ideographic => TextBaseline.ideographic,
  };
}

LayoutTextDirection layoutTextDirectionFromTextDirection(
  TextDirection direction,
) {
  return switch (direction) {
    TextDirection.ltr => LayoutTextDirection.ltr,
    TextDirection.rtl => LayoutTextDirection.rtl,
  };
}

TextDirection textDirectionFromLayoutTextDirection(
  LayoutTextDirection direction,
) {
  return switch (direction) {
    LayoutTextDirection.ltr => TextDirection.ltr,
    LayoutTextDirection.rtl => TextDirection.rtl,
  };
}

LayoutConstraints layoutConstraintsFromBoxConstraints(
  BoxConstraints constraints,
) {
  return LayoutConstraints(
    minWidth: constraints.minWidth,
    maxWidth: constraints.maxWidth,
    minHeight: constraints.minHeight,
    maxHeight: constraints.maxHeight,
  );
}

BoxConstraints boxConstraintsFromLayoutConstraints(
  LayoutConstraints constraints,
) {
  return BoxConstraints(
    minWidth: constraints.minWidth,
    maxWidth: constraints.maxWidth,
    minHeight: constraints.minHeight,
    maxHeight: constraints.maxHeight,
  );
}

LayoutAxis layoutAxisFromAxis(Axis axis) {
  return switch (axis) {
    Axis.horizontal => LayoutAxis.horizontal,
    Axis.vertical => LayoutAxis.vertical,
  };
}

Axis axisFromLayoutAxis(LayoutAxis axis) {
  return switch (axis) {
    LayoutAxis.horizontal => Axis.horizontal,
    LayoutAxis.vertical => Axis.vertical,
  };
}
