import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';

/// Parent data for children in the independent layout system.
///
/// [BoxParentData] stores layout-specific information for each child in
/// the independent box layout system. It maintains positioning, caching,
/// and sibling relationships needed for layout calculations.
class BoxParentData {
  /// The position offset of this child relative to its parent.
  LayoutOffset offset = LayoutOffset.zero;

  /// Cached layout information from previous layout passes.
  ///
  /// Used to optimize relayout by reusing calculations when constraints haven't changed.
  ChildLayoutCache? cache;

  /// Reference to the next sibling box in document order.
  Box? nextSibling;

  /// Reference to the previous sibling box in document order.
  Box? previousSibling;

  /// Layout-specific data defining how this child should be laid out.
  ///
  /// Includes flex properties, sizing constraints, alignment, and positioning information.
  LayoutData? layoutData;

  /// The paint order of this child relative to siblings.
  ///
  /// Lower values are painted first (behind), higher values painted last (on top).
  int? get paintOrder => layoutData!.paintOrder;

  Box? _nextSortedSibling;
  Box? _previousSortedSibling;

  /// Returns the next sibling in paint order, or document order if not sorted.
  Box? get nextSortedSibling => _nextSortedSibling ?? nextSibling;

  /// Returns the previous sibling in paint order, or document order if not sorted.
  Box? get previousSortedSibling => _previousSortedSibling ?? previousSibling;
}

/// A layout container in the independent layout system.
///
/// [Box] represents a node in the layout tree that can contain children
/// and participate in layout calculations. It implements [ParentLayout]
/// and provides the foundation for building layout hierarchies independent
/// of Flutter's widget system. Boxes manage their children, handle layout
/// constraints, and coordinate positioning and sizing.
class Box with ParentLayout {
  @override
  LayoutTextDirection textDirection;

  /// How content should be handled when it overflows horizontally.
  ///
  /// Determines whether horizontal overflow should be visible, hidden,
  /// clipped, or scrollable.
  LayoutOverflow horizontalOverflow;

  /// How content should be handled when it overflows vertically.
  ///
  /// Determines whether vertical overflow should be visible, hidden,
  /// clipped, or scrollable.
  LayoutOverflow verticalOverflow;

  /// The layout algorithm used to position children of this box.
  ///
  /// Defines how child boxes are arranged (e.g., flex layout, absolute positioning).
  Layout boxLayout;

  @override
  LayoutTextBaseline? textBaseline;
  @override
  double scrollOffsetX;
  @override
  double scrollOffsetY;

  late List<Box> _children;
  Box? _parent;

  /// Optional debug key for identifying this box during debugging.
  ///
  /// Useful for tracking specific boxes through layout calculations
  /// and troubleshooting layout issues.
  Object? debugKey;

  LayoutSize? _contentSize;
  LayoutRect? _contentBounds;
  LayoutSize? _viewportSize; // a.k.a Box#size

  /// Creates a box with the specified layout configuration.
  ///
  /// All parameters are required to define the box's initial state and behavior.
  Box({
    required this.textDirection,
    required this.horizontalOverflow,
    required this.verticalOverflow,
    required this.boxLayout,
    LayoutData? layoutData,
    this.textBaseline,
    this.scrollOffsetX = 0.0,
    this.scrollOffsetY = 0.0,
    List<Box>? children,
    this.debugKey,
  }) {
    parentData.layoutData = layoutData;
    if (children != null) {
      _attachChildren(children);
    } else {
      _children = [];
      _childCount = 0;
      _firstChild = null;
      _lastChild = null;
    }
  }

  void _attachChildren(List<Box> children) {
    for (final child in children) {
      assert(child._parent == null, 'Child is already attached to a parent.');
      child._parent = this;
    }
    _children = children;
    _childCount = children.length;
    _firstChild = children.isNotEmpty ? children.first : null;
    _lastChild = children.isNotEmpty ? children.last : null;
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final parentData = child.parentData;
      parentData.previousSibling = i > 0 ? children[i - 1] : null;
      parentData.nextSibling = i < children.length - 1 ? children[i + 1] : null;
    }

    Set<Box> visited = {};
    int? previous;
    for (
      var child = firstChild;
      child != null;
      child = child.parentData.nextSibling
    ) {
      assert(!visited.contains(child), 'Cycle detected in child list.');
      int current = child.debugKey as int;
      assert(
        previous == null || previous < current,
        'Children are not in the expected order. Previous: $previous, Current: $current',
      );
      visited.add(child);
      previous = current;
    }

    markNeedsLayout();
  }

  void addChild(Box child) {
    _attachChildren([..._children, child]);
    markNeedsLayout();
  }

  void addChildren(List<Box> children) {
    _attachChildren([..._children, ...children]);
    markNeedsLayout();
  }

  void attach(LayoutPipelineOwner owner) {
    detach();
    assert(_owner == null);
    _owner = owner;
    for (final child in _children) {
      child.attach(owner);
    }
  }

  void detach() {
    assert(_owner != null);
    _owner = null;
    for (final child in _children) {
      child.detach();
    }
  }

  void removeChild(Box child) {
    final index = _children.indexOf(child);
    if (index == -1) return;
    final newChildren = List<Box>.from(_children)..removeAt(index);
    _attachChildren(newChildren);
    child._parent = null;
    child.parentData.nextSibling = null;
    child.parentData.previousSibling = null;
    markNeedsLayout();
  }

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
    _viewportSize = size;
  }

  bool get hasSize => _viewportSize != null;

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
    LayoutSize contentSize = layoutHandle.performLayout(
      layoutConstraints,
    );
    final viewportSize = layoutConstraints.constrain(contentSize);
    _contentSize = contentSize;
    assert(() {
      bool hasCache = true;
      Box? child = firstChild;
      while (child != null) {
        if (child.parentData.cache == null) {
          hasCache = false;
          break;
        }
        child = child.parentData.nextSibling;
      }
      return hasCache;
    }(), 'Not all children have layout cache after layout.');
    _contentBounds = layoutHandle.performPositioning(
      viewportSize,
      contentSize,
      ParentRect.zero,
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

  double? getDistanceToBaseline(LayoutTextBaseline baseline) {
    return switch (boxLayout.mainAxis) {
      LayoutAxis.horizontal => defaultComputeDistanceToHighestActualBaseline(
        baseline,
      ),
      LayoutAxis.vertical => defaultComputeDistanceToFirstActualBaseline(
        baseline,
      ),
    };
  }

  double? defaultComputeDistanceToHighestActualBaseline(
    LayoutTextBaseline baseline,
  ) {
    LayoutBaselineOffset minBaseline = LayoutBaselineOffset.noBaseline;
    Box? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData;
      final LayoutBaselineOffset candidate =
          LayoutBaselineOffset(child.getDistanceToBaseline(baseline)) +
          childParentData.offset.dy;
      minBaseline = minBaseline.minOf(candidate);
      child = childParentData.nextSibling;
    }
    return minBaseline.offset;
  }

  double? defaultComputeDistanceToFirstActualBaseline(
    LayoutTextBaseline baseline,
  ) {
    Box? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData;
      final double? result = child.getDistanceToBaseline(baseline);
      if (result != null) {
        return result + childParentData.offset.dy;
      }
      child = childParentData.nextSibling;
    }
    return null;
  }

  @override
  ChildLayout? findChildByKey(Object key) {
    Box? child = firstChild;
    while (child != null) {
      if (child.parentData.layoutData?.key == key) {
        return BoxChildLayout(child);
      }
      child = child.parentData.nextSibling;
    }
    return null;
  }
}

/// Manages the layout pipeline for the independent layout system.
///
/// [LayoutPipelineOwner] coordinates layout operations across the layout tree,
/// handling layout scheduling, constraint propagation, and visual updates.
/// It maintains a queue of nodes that need layout and orchestrates the
/// layout process to ensure all constraints are properly resolved.
class LayoutPipelineOwner {
  final List<Box> _nodesNeedingLayout = [];
  final void Function()? onNeedVisualUpdate;

  LayoutPipelineOwner({this.onNeedVisualUpdate});

  void requestVisualUpdate() {
    onNeedVisualUpdate?.call();
  }
}

/// Adapter that makes a [Box] compatible with the layout system.
///
/// [BoxChildLayout] implements the [ChildLayout] interface for [Box] objects,
/// allowing boxes to participate as children in layout calculations.
/// It provides the bridge between the box-based layout system and the
/// generic layout algorithm interface.
class BoxChildLayout with ChildLayout {
  final Box box;
  BoxChildLayout(this.box);

  @override
  Object? get debugKey => box.debugKey;

  @override
  LayoutOffset get offset => box.parentData.offset;

  @override
  void clearCache() {
    // assert(false, 'Clearing cache on child layout is not supported.');
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
  void layout(
    LayoutRect parentOffset,
    LayoutOffset offset,
    LayoutSize size,
    OverflowBounds overflowBounds, {
    LayoutOffset? revealOffset,
  }) {
    box.parentData.offset = offset;
    assert(size.width.isFinite && size.height.isFinite);
    if (box.size != size) {
      box.size = size;
    }
  }

  @override
  ChildLayoutCache get layoutCache {
    assert(
      box.parentData.cache != null,
      'Layout cache is not set. Did you forget to call setupCache()?',
    );
    return box.parentData.cache!;
  }

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

extension type const LayoutBaselineOffset(double? offset) {
  static const LayoutBaselineOffset noBaseline = LayoutBaselineOffset(null);

  LayoutBaselineOffset operator +(double offset) {
    final double? value = this.offset;
    return LayoutBaselineOffset(value == null ? null : value + offset);
  }

  LayoutBaselineOffset minOf(LayoutBaselineOffset other) {
    return switch ((this, other)) {
      (final double lhs?, final double rhs?) => lhs >= rhs ? other : this,
      (final double lhs?, null) => LayoutBaselineOffset(lhs),
      (null, final LayoutBaselineOffset rhs) => rhs,
    };
  }
}
