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

  /// Adds a single child to this parent box.
  ///
  /// The child is appended to the end of the children list and the layout
  /// is marked as needing an update.
  void addChild(Box child) {
    _attachChildren([..._children, child]);
    markNeedsLayout();
  }

  /// Adds multiple children to this parent box.
  ///
  /// All children are appended to the end of the children list and the layout
  /// is marked as needing an update.
  void addChildren(List<Box> children) {
    _attachChildren([..._children, ...children]);
    markNeedsLayout();
  }

  /// Attaches this box and all its children to the given layout pipeline owner.
  ///
  /// This establishes the connection to the layout system for this subtree.
  /// Any existing attachment is detached first.
  void attach(LayoutPipelineOwner owner) {
    detach();
    assert(_owner == null);
    _owner = owner;
    for (final child in _children) {
      child.attach(owner);
    }
  }

  /// Detaches this box and all its children from the layout pipeline.
  ///
  /// This breaks the connection to the layout system for this subtree.
  void detach() {
    assert(_owner != null);
    _owner = null;
    for (final child in _children) {
      child.detach();
    }
  }

  /// Removes a specific child from this parent box.
  ///
  /// If the child is not found, this method does nothing. Otherwise, the child
  /// is removed, its parent references are cleared, and layout is marked for update.
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

  /// The first child in the natural children list.
  Box? get firstChild => _firstChild;
  
  /// The last child in the natural children list.
  Box? get lastChild => _lastChild;
  
  /// The first child in the sorted children list, or the first natural child if no sorting.
  Box? get firstSortedChild => _firstSortedChild ?? _firstChild;
  
  /// The last child in the sorted children list, or the last natural child if no sorting.
  Box? get lastSortedChild => _lastSortedChild ?? _lastChild;
  
  /// The total number of children in this parent box.
  int get childCount => _childCount;
  
  /// The layout constraints applied to this box.
  LayoutConstraints get constraints => _constraints!;

  /// Parent data for this box, storing sibling relationships.
  BoxParentData parentData = BoxParentData();

  /// The computed size of this box.
  LayoutSize get size => _viewportSize!;
  
  /// Sets the size of this box.
  set size(LayoutSize size) {
    _viewportSize = size;
  }

  /// Returns true if this box has been sized.
  bool get hasSize => _viewportSize != null;

  /// Performs the layout calculation for this box and its children.
  ///
  /// This method computes the positions and sizes of all children based on
  /// the layout algorithm and constraints.
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

  /// The actual paint bounds considering clipping from overflow settings.
  ///
  /// This may be smaller than [paintBounds] if overflow clipping is enabled.
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

  /// The paint bounds of this box from its origin to its size.
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

  /// The parent box of this box, or null if this is the root.
  Box? get parent => _parent;

  LayoutPipelineOwner? _owner;
  
  /// The layout pipeline owner managing this box's layout lifecycle.
  LayoutPipelineOwner? get owner => _owner;

  bool? _isRelayoutBoundary;
  
  /// Whether this box determines its own size without input from children.
  ///
  /// When true, this box is sized before laying out children.
  bool sizedByParent = false;
  
  bool _needsLayout = true;

  /// Marks this box as needing layout.
  ///
  /// This propagates up the tree until reaching a relayout boundary or the root.
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

  /// Lays out this box with the given constraints.
  ///
  /// The [parentUsesSize] parameter indicates whether the parent's layout depends
  /// on this box's size. This affects relayout boundary determination.
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

  /// Computes the size of this box based on its constraints.
  ///
  /// This is called only when [sizedByParent] is true, before [performLayout].
  void performResize() {}

  /// Computes the size this box would have under the given constraints without performing actual layout.
  ///
  /// This is used for intrinsic sizing calculations.
  LayoutSize getDryLayout(covariant LayoutConstraints constraints) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.performLayout(constraints, true);
  }

  /// Computes the minimum height this box could have for the given width.
  ///
  /// Used for intrinsic sizing calculations.
  double getMinIntrinsicHeight(double width) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMinIntrinsicHeight(width);
  }

  /// Computes the maximum height this box could have for the given width.
  ///
  /// Used for intrinsic sizing calculations.
  double getMaxIntrinsicHeight(double width) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMaxIntrinsicHeight(width);
  }

  /// Computes the minimum width this box could have for the given height.
  ///
  /// Used for intrinsic sizing calculations.
  double getMinIntrinsicWidth(double height) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMinIntrinsicWidth(height);
  }

  /// Computes the maximum width this box could have for the given height.
  ///
  /// Used for intrinsic sizing calculations.
  double getMaxIntrinsicWidth(double height) {
    final layoutHandle = boxLayout.createLayoutHandle(this);
    return layoutHandle.computeMaxIntrinsicWidth(height);
  }

  /// Calculates the distance from the top of the box to its baseline.
  ///
  /// Returns the offset to the specified text baseline, or null if this box
  /// doesn't have a baseline. The calculation considers the layout's main axis
  /// to determine which baseline computation method to use.
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

  /// Computes the distance to the highest baseline among all children.
  ///
  /// Iterates through all children to find the one with the highest baseline
  /// position (closest to the top). This is used for horizontal layouts
  /// where all items should align to the same baseline.
  ///
  /// Returns null if no child has a baseline.
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

  /// Computes the distance to the first child's baseline.
  ///
  /// Returns the baseline offset of the first child that has a baseline.
  /// This is used for vertical layouts where the baseline of the container
  /// is defined by its first child.
  ///
  /// Returns null if no child has a baseline.
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
  /// Callback invoked when the layout system needs a visual update.
  ///
  /// This callback should trigger a repaint or redraw of the UI when layout
  /// changes occur that affect visual appearance.
  final void Function()? onNeedVisualUpdate;

  /// Creates a layout pipeline owner with an optional update callback.
  LayoutPipelineOwner({this.onNeedVisualUpdate});

  /// Requests a visual update from the rendering system.
  ///
  /// Invokes the [onNeedVisualUpdate] callback if provided, signaling
  /// that the layout has changed and the UI needs to be redrawn.
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
  /// The box object this layout adapter wraps.
  final Box box;
  
  /// Creates a child layout adapter for the given box.
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

/// Represents a baseline offset value with optional null state.
///
/// [LayoutBaselineOffset] wraps a nullable double to represent baseline positions.
/// The null value ([noBaseline]) indicates that no baseline is available.
/// This extension type provides convenience methods for baseline calculations
/// like adding offsets and finding minimum values.
extension type const LayoutBaselineOffset(double? offset) {
  /// Constant representing the absence of a baseline.
  static const LayoutBaselineOffset noBaseline = LayoutBaselineOffset(null);

  /// Adds an offset to this baseline position.
  ///
  /// If this baseline is null ([noBaseline]), returns null.
  /// Otherwise, adds the offset to the baseline position.
  LayoutBaselineOffset operator +(double offset) {
    final double? value = this.offset;
    return LayoutBaselineOffset(value == null ? null : value + offset);
  }

  /// Returns the minimum baseline offset between this and another.
  ///
  /// When comparing two baselines:
  /// - If both have values, returns the one with the smaller offset
  /// - If one is null, returns the non-null one
  /// - If both are null, returns null
  LayoutBaselineOffset minOf(LayoutBaselineOffset other) {
    return switch ((this, other)) {
      (final double lhs?, final double rhs?) => lhs >= rhs ? other : this,
      (final double lhs?, null) => LayoutBaselineOffset(lhs),
      (null, final LayoutBaselineOffset rhs) => rhs,
    };
  }
}
