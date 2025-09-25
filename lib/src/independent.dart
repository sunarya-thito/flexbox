import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';

class BoxParentData {
  LayoutOffset offset = LayoutOffset.zero;

  ChildLayoutCache? cache;

  Box? nextSibling;
  Box? previousSibling;

  LayoutData? layoutData;

  int? get paintOrder => layoutData!.paintOrder;

  Box? _nextSortedSibling;
  Box? _previousSortedSibling;

  Box? get nextSortedSibling => _nextSortedSibling ?? nextSibling;
  Box? get previousSortedSibling => _previousSortedSibling ?? previousSibling;
}

class Box with ParentLayout {
  @override
  LayoutTextDirection textDirection;
  LayoutOverflow horizontalOverflow;
  LayoutOverflow verticalOverflow;
  Layout boxLayout;
  @override
  LayoutTextBaseline? textBaseline;
  @override
  double scrollOffsetX;
  @override
  double scrollOffsetY;

  List<Box> _children;
  Box? _parent;

  LayoutSize? _contentSize;
  LayoutRect? _contentBounds;
  LayoutSize? _viewportSize; // a.k.a Box#size

  Box({
    required this.textDirection,
    required this.horizontalOverflow,
    required this.verticalOverflow,
    required this.boxLayout,
    this.textBaseline,
    this.scrollOffsetX = 0.0,
    this.scrollOffsetY = 0.0,
    required List<Box> children,
  }) : _children = children {
    _attachChildren(children);
  }

  void _attachChildren(List<Box> children) {}

  void attach(Box parent) {
    _parent = parent;
  }

  void detach(Box parent) {
    _parent = null;
  }

  void adoptChild(Box parent) {}

  void dropChild(Box parent) {}

  Box? _firstSortedChild;
  Box? _lastSortedChild;
  Box? _firstChild;
  Box? _lastChild;
  int _childCount = 0;
  LayoutConstraints? _constraints;

  Box? get firstChild => _firstChild;
  Box? get lastChild => _lastChild;
  Box? get firstSortedChild => _firstSortedChild ?? _firstChild;
  Box? get lastSortedChild => _lastSortedChild ?? _lastChild;
  int get childCount => _childCount;
  LayoutConstraints get constraints => _constraints!;

  BoxParentData parentData = BoxParentData();

  LayoutSize get size => _viewportSize!;
  set size(LayoutSize size) {
    this.size = size;
  }

  bool get hasSize => _viewportSize != null;

  @override
  void performLayout() {
    bool needsSorting = false;
    LayoutHandle layoutHandle = boxLayout.createLayoutHandle(this);
    Box? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData;
      if (childParentData.paintOrder != null) {
        needsSorting = true;
      }
      childParentData.cache = layoutHandle.setupCache();
      child = childParentData.nextSibling;
    }
    final layoutConstraints = constraints;
    LayoutSize contentSize = layoutHandle.performLayout(layoutConstraints);
    final viewportSize = layoutConstraints.constrain(contentSize);
    _contentSize = contentSize;
    _contentBounds = layoutHandle.performPositioning(
      viewportSize,
      contentSize,
    );
    assert(contentSize.width.isFinite && contentSize.height.isFinite);
    size = viewportSize;
    if (needsSorting) {
      _sortChildren();
    }
  }

  bool _childOutOfViewport(Box child) {
    final childParentData = child.parentData;
    final childRect = childParentData.offset & child.size;
    return !childRect.overlaps(actualPaintBounds);
  }

  LayoutRect get actualPaintBounds {
    bool clipHorizontal = horizontalOverflow.clipContent;
    bool clipVertical = verticalOverflow.clipContent;
    LayoutRect contentBounds = _contentBounds!;
    return LayoutRect.fromLTWH(
      clipHorizontal ? 0.0 : contentBounds.left,
      clipVertical ? 0.0 : contentBounds.top,
      clipHorizontal ? size.width : contentBounds.width,
      clipVertical ? size.height : contentBounds.height,
    );
  }

  LayoutRect get paintBounds => LayoutOffset.zero & size;

  void _sortChildren() {
    _firstSortedChild = null;
    _lastSortedChild = null;
    if (childCount <= 1) {
      _firstSortedChild = firstChild;
      _lastSortedChild = lastChild;
      if (firstChild != null) {
        final parentData = firstChild!.parentData;
        parentData._nextSortedSibling = null;
        parentData._previousSortedSibling = null;
      }
      return;
    }

    Box? headOfListToSort;

    bool clipHorizontal = horizontalOverflow.clipContent;
    bool clipVertical = verticalOverflow.clipContent;

    // Check if we should only consider visible children.
    if (clipHorizontal || clipVertical) {
      // Build a new linked list containing ONLY visible children.
      Box? visibleHead;
      Box? visibleTail;
      Box? current = firstChild;

      while (current != null) {
        final parentData = current.parentData;
        // Clear any previous sorted links.
        parentData._nextSortedSibling = null;
        parentData._previousSortedSibling = null;

        // Add the child to our list only if it's visible.
        if (!_childOutOfViewport(current)) {
          if (visibleHead == null) {
            visibleHead = current;
            visibleTail = current;
          } else {
            (visibleTail!.parentData)._nextSortedSibling = current;
            visibleTail = current;
          }
        }
        current = parentData.nextSibling;
      }
      headOfListToSort = visibleHead;
    } else {
      // If not clipping, build the list with ALL children as before.
      Box? current = firstChild;
      while (current != null) {
        final parentData = current.parentData;
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
    Box? prev;
    Box? current = _firstSortedChild;
    while (current != null) {
      final parentData = current.parentData;
      parentData._previousSortedSibling = prev;
      if ((parentData._nextSortedSibling) == null) {
        _lastSortedChild = current;
      }
      prev = current;
      current = parentData._nextSortedSibling;
    }
  }

  int _compareChildren(Box a, Box b) {
    final aParentData = a.parentData;
    final bParentData = b.parentData;

    final aZOrder = aParentData.paintOrder ?? 0;
    final bZOrder = bParentData.paintOrder ?? 0;

    if (aZOrder != bZOrder) {
      return aZOrder.compareTo(bZOrder);
    }
    return 0;
  }

  /// Merges two sorted linked lists. This is a helper for the merge sort.
  Box? _merge(Box? a, Box? b) {
    if (a == null) return b;
    if (b == null) return a;

    Box? result;

    // The `<= 0` check ensures the sort is stable, meaning children that
    // are "equal" will maintain their original relative order.
    if (_compareChildren(a, b) <= 0) {
      result = a;
      (a.parentData)._nextSortedSibling = _merge(
        (a.parentData)._nextSortedSibling,
        b,
      );
    } else {
      result = b;
      (b.parentData)._nextSortedSibling = _merge(
        a,
        (b.parentData)._nextSortedSibling,
      );
    }
    return result;
  }

  Box? _getMiddle(Box? head) {
    if (head == null) return head;

    Box? slow = head;
    Box? fast = (head.parentData)._nextSortedSibling;

    while (fast != null) {
      fast = (fast.parentData)._nextSortedSibling;
      if (fast != null) {
        slow = (slow!.parentData)._nextSortedSibling;
        fast = (fast.parentData)._nextSortedSibling;
      }
    }
    return slow;
  }

  Box? _mergeSort(Box? head) {
    if (head == null || (head.parentData)._nextSortedSibling == null) {
      return head;
    }

    Box? middle = _getMiddle(head);
    Box? nextOfMiddle = (middle!.parentData)._nextSortedSibling;

    // Split the list into two halves.
    (middle.parentData)._nextSortedSibling = null;

    Box? left = _mergeSort(head);
    Box? right = _mergeSort(nextOfMiddle);

    return _merge(left, right);
  }

  @override
  LayoutSize get contentSize => _contentSize!;

  @override
  ChildLayout? get firstLayoutChild {
    final first = firstChild;
    return first == null ? null : BoxChildLayout(first);
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
  ChildLayout? get lastLayoutChild {
    final last = lastChild;
    return last == null ? null : BoxChildLayout(last);
  }

  @override
  LayoutSize get viewportSize => _viewportSize!;

  Box? get parent => _parent;

  LayoutPipelineOwner? _owner;
  LayoutPipelineOwner? get owner => _owner;

  bool? _isRelayoutBoundary;
  bool sizedByParent = false;
  bool _needsLayout = true;

  void markNeedsLayout() {
    if (_needsLayout) {
      return;
    }
    _needsLayout = true;
    if (owner case final LayoutPipelineOwner owner?
        when (_isRelayoutBoundary ?? false)) {
      owner._nodesNeedingLayout.add(this);
      owner.requestVisualUpdate();
    } else if (parent != null) {
      parent!.markNeedsLayout();
    }
  }

  void layout(LayoutConstraints constraints, {bool parentUsesSize = false}) {
    _isRelayoutBoundary =
        !parentUsesSize ||
        sizedByParent ||
        constraints.isTight ||
        parent == null;
    if (!_needsLayout && constraints == _constraints) {
      return;
    }
    _constraints = constraints;
    if (sizedByParent) {
      performResize();
    }
    performLayout();
    _needsLayout = false;
  }

  void performResize() {}

  LayoutSize getDryLayout(covariant LayoutConstraints constraints) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.performLayout(constraints, true);
  }

  double getMinIntrinsicHeight(double width) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMinIntrinsicHeight(width);
  }

  double getMaxIntrinsicHeight(double width) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMaxIntrinsicHeight(width);
  }

  double getMinIntrinsicWidth(double height) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMinIntrinsicWidth(height);
  }

  double getMaxIntrinsicWidth(double height) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMaxIntrinsicWidth(height);
  }

  double? getDistanceToBaseline(LayoutTextBaseline baseline) {}
}

class LayoutPipelineOwner {
  List<Box> _nodesNeedingLayout = [];
  void requestVisualUpdate() {}
}

class BoxChildLayout with ChildLayout {
  final Box box;
  BoxChildLayout(this.box);

  @override
  LayoutOffset get offset => box.parentData.offset;

  @override
  set offset(LayoutOffset offset) {
    box.parentData.offset = offset;
  }

  @override
  void clearCache() {
    box.parentData.cache = null;
  }

  @override
  LayoutSize dryLayout(LayoutConstraints constraints) {
    return box.getDryLayout(constraints);
  }

  @override
  double getDistanceToBaseline(LayoutTextBaseline baseline) {
    return box.getDistanceToBaseline(baseline) ?? size.height;
  }

  @override
  double getMaxIntrinsicHeight(double width) {
    return box.getMaxIntrinsicHeight(width);
  }

  @override
  double getMaxIntrinsicWidth(double height) {
    return box.getMaxIntrinsicWidth(height);
  }

  @override
  double getMinIntrinsicHeight(double width) {
    return box.getMinIntrinsicHeight(width);
  }

  @override
  double getMinIntrinsicWidth(double height) {
    return box.getMinIntrinsicWidth(height);
  }

  @override
  void layout(LayoutConstraints constraints) {
    box.layout(constraints, parentUsesSize: true);
  }

  @override
  ChildLayoutCache get layoutCache => box.parentData.cache!;

  @override
  LayoutData get layoutData => box.parentData.layoutData!;

  @override
  ChildLayout? get nextSibling {
    final next = box.parentData.nextSibling;
    return next == null ? null : BoxChildLayout(next);
  }

  @override
  ChildLayout? get previousSibling {
    final previous = box.parentData.previousSibling;
    return previous == null ? null : BoxChildLayout(previous);
  }

  @override
  LayoutSize get size => box.size;
}
