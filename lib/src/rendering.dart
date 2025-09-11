import 'dart:math';

import 'package:flexiblebox/src/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FlexBoxParentData extends ContainerBoxParentData<RenderBox> {
  bool absolute = false;
  BoxPosition? top;
  BoxPosition? bottom;
  BoxPosition? left;
  BoxPosition? right;
  BoxSize? width;
  BoxSize? height;
  BoxPositionType? horizontalPosition;
  BoxPositionType? verticalPosition;
  bool horizontalScrollAffected = true;
  bool verticalScrollAffected = true;
  bool horizontalRelativeToContent = false;
  bool verticalRelativeToContent = false;
  AlignmentGeometry? alignment;

  bool needsRelayout = true;

  // temporary storage during layout
  // will be cleared after layout
  double? resolvedMainSize;
  double? resolvedCrossSize;
  double? resolvedMainFlexSize;
  BoxSize? temporaryWidth;
  BoxSize? temporaryHeight;
  int? zOrder;

  bool debugLayout = false;

  bool get isAbsolute {
    return absolute ||
        top != null ||
        bottom != null ||
        left != null ||
        right != null;
  }

  BoxSize? getSize(Axis axis) {
    if (axis == Axis.horizontal) {
      return width ?? temporaryWidth;
    } else {
      return height ?? temporaryHeight;
    }
  }

  BoxSize setTemporarySize(Axis axis, BoxSize size) {
    if (axis == Axis.horizontal) {
      return temporaryWidth = size;
    } else {
      return temporaryHeight = size;
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

  bool isScrollAffected(Axis axis) {
    if (axis == Axis.horizontal) {
      return horizontalScrollAffected;
    } else {
      return verticalScrollAffected;
    }
  }

  bool isRelativeToContent(Axis axis) {
    if (axis == Axis.horizontal) {
      return horizontalRelativeToContent;
    } else {
      return verticalRelativeToContent;
    }
  }

  RenderBox? _nextSortedSibling;
  RenderBox? _previousSortedSibling;

  void setOffset(double mainOffset, double crossOffset, Axis direction) {
    switch (direction) {
      case Axis.horizontal:
        offset = Offset(mainOffset, crossOffset);
      case Axis.vertical:
        offset = Offset(crossOffset, mainOffset);
    }
  }
}

class _Store<T> {
  T value;
  _Store(this.value);
}

enum FlexBoxLayoutChange {
  none,
  nonAbsolute,
  absolute,
  both;

  operator |(FlexBoxLayoutChange other) {
    if (this == FlexBoxLayoutChange.both || other == FlexBoxLayoutChange.both) {
      return FlexBoxLayoutChange.both;
    }
    if (this == FlexBoxLayoutChange.none) {
      return other;
    }
    if (other == FlexBoxLayoutChange.none) {
      return this;
    }
    return FlexBoxLayoutChange.both;
  }

  bool get affectsNonAbsolute {
    return this == FlexBoxLayoutChange.nonAbsolute ||
        this == FlexBoxLayoutChange.both;
  }

  bool get affectsAbsolute {
    return this == FlexBoxLayoutChange.absolute ||
        this == FlexBoxLayoutChange.both;
  }
}

enum FlexBoxPositionChange {
  none,
  nonAbsolute,
  absolute,
  both;

  operator |(FlexBoxPositionChange other) {
    if (this == FlexBoxPositionChange.both ||
        other == FlexBoxPositionChange.both) {
      return FlexBoxPositionChange.both;
    }
    if (this == FlexBoxPositionChange.none) {
      return other;
    }
    if (other == FlexBoxPositionChange.none) {
      return this;
    }
    return FlexBoxPositionChange.both;
  }

  bool get affectsNonAbsolute {
    return this == FlexBoxPositionChange.nonAbsolute ||
        this == FlexBoxPositionChange.both;
  }

  bool get affectsAbsolute {
    return this == FlexBoxPositionChange.absolute ||
        this == FlexBoxPositionChange.both;
  }
}

class RenderFlexBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexBoxParentData>
    implements RenderAbstractViewport {
  static const maxComputePass = 10;
  Axis direction;
  // double spacing;
  BoxSize? spacing;
  BoxSize? spacingBefore;
  BoxSize? spacingAfter;
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
    required this.textDirection,
  });

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
      if (attached) {
        vertical.removeListener(_onScrollOffsetChanged);
      }
      vertical = offset;
      if (attached) {
        vertical.addListener(_onScrollOffsetChanged);
      }
    }
  }

  void updateHorizontalOffset(ViewportOffset offset) {
    if (horizontal != offset) {
      if (attached) {
        horizontal.removeListener(_onScrollOffsetChanged);
      }
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

  /// The size of the content inside the FlexBox.
  Size get contentSize {
    assert(hasSize, 'RenderFlexBox was not laid out');
    return _contentSize!;
  }

  /// The size of one flex unit.
  double get flexUnit {
    assert(hasSize, 'RenderFlexBox was not laid out');
    return _flexUnit!;
  }

  double get effectiveSpacing {
    assert(hasSize, 'RenderFlexBox was not laid out');
    return _spacing!;
  }

  @override
  void performLayout() {
    double maxMainViewportSize = _getMainMaxConstraints(constraints);
    double maxCrossViewportSize = _getCrossMaxConstraints(constraints);

    // accepts negative padding
    maxMainViewportSize = maxMainViewportSize;
    maxCrossViewportSize = maxCrossViewportSize;

    var layoutChange = this.layoutChange;
    if (_contentSize == null) {
      // force a full layout if it has never been laid out before
      layoutChange = FlexBoxLayoutChange.both;
    }

    if (layoutChange != FlexBoxLayoutChange.none) {
      var layoutChildren = _layoutChildren(
        maxViewportMainSize: maxMainViewportSize,
        maxViewportCrossSize: maxCrossViewportSize,
        layoutChild: ChildLayoutHelper.layoutChild,
        layoutChange: layoutChange,
      );

      // single relayout cannot happen if it has not fully laid out before
      if (layoutChange.affectsNonAbsolute) {
        // when single relayout is done, it does not check
        // every children, so it cannot be trusted to update
        // these values
        shouldSortChildren = layoutChildren.shouldSortChildren;
        _contentSize = _createSize(
          layoutChildren.mainContentSize,
          layoutChildren.crossContentSize,
        );
        _flexUnit = layoutChildren.flexUnit;
        _spacing = layoutChildren.spacing;
        _spacingBefore = layoutChildren.spacing;
      }
    }

    size = Size(
      constraints.constrainWidth(_contentSize!.width),
      constraints.constrainHeight(_contentSize!.height),
    );

    if (positionChange != FlexBoxPositionChange.none) {
      _positionsChildren(
        mainContentSize: _getMain(_contentSize!),
        crossContentSize: _getCross(_contentSize!),
        mainViewportSize: _getMain(size),
        crossViewportSize: _getCross(size),
        spacing: _spacing!,
        spacingBefore: _spacingBefore!,
        spacingAfter: _spacingAfter!,
        change: positionChange,
      );
    }

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
  }

  ({
    double mainContentSize,
    double crossContentSize,
    bool shouldSortChildren,
    double flexUnit, // <- i need this for personal reason 😘 (@sunarya-thito)
    // the spacing returned has the same behavior as empty unconstrained child
    // if the spacing from the flex box is empty,
    double spacing,
    double spacingBefore,
    double spacingAfter,
  })
  _layoutChildren({
    required double maxViewportMainSize,
    required double maxViewportCrossSize,
    ChildLayouter? layoutChild,
    required FlexBoxLayoutChange layoutChange,
  }) {
    if (childCount == 0) {
      return (
        mainContentSize: 0.0,
        crossContentSize: 0.0,
        shouldSortChildren: false,
        flexUnit: 0.0,
        spacing: 0.0,
        spacingBefore: 0.0,
        spacingAfter: 0.0,
      );
    }

    // pass-1: consensus pass (find out the total flex, biggest main flex, biggest cross flex, and dependencies)
    double? totalFlex;
    double? biggestMainFlex;
    double? biggestCrossFlex;

    Iterable<Key> dependsOn = Iterable.empty();

    void runConsensus({
      bool consensusForDependencies = true,
      bool consensusForCross = true,
    }) {
      biggestMainFlex = null;
      biggestCrossFlex = null;
      totalFlex = null;
      double? totalFlexBeforeDisaster;
      RenderBox? requiresBiggestFlex;
      RenderBox? child = firstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        final mainSize = data.getSize(direction);
        final crossSize = data.getSize(crossDirection);

        bool mainRequiresCross = false;
        bool crossRequiresMain = false;
        if (mainSize != null && data.resolvedMainSize == null) {
          final result = mainSize.computeTotalFlex(null);
          if (result?.isNaN == true) {
            // typically caused by ExpandingSize
            // consensusRequiresMainBiggestFlex = true;
            requiresBiggestFlex ??= child;
            totalFlexBeforeDisaster ??= totalFlex;
          } else {
            totalFlex = _addNullable(result, totalFlex);
            biggestMainFlex = _maxNulls(biggestMainFlex, result);
          }
          final mainDependencies = mainSize.dependencies;
          if (consensusForDependencies) {
            dependsOn = dependsOn.followedBy(mainDependencies);
          }
          mainRequiresCross = mainSize.needsCrossAxis;
        }
        if (crossSize != null && consensusForCross) {
          final result = crossSize.computeTotalFlex(null);
          if (result?.isNaN == true) {
            // typically caused by ExpandingSize
            // consensusRequiresCrossBiggestFlex = true;
            requiresBiggestFlex ??= child;
            totalFlexBeforeDisaster ??= totalFlex;
          } else {
            biggestCrossFlex = _maxNulls(biggestCrossFlex, result);
          }
          final crossDependencies = crossSize.dependencies;
          if (consensusForDependencies) {
            dependsOn = dependsOn.followedBy(crossDependencies);
          }
          crossRequiresMain = crossSize.needsCrossAxis;
        }

        if (mainRequiresCross && crossRequiresMain) {
          // circular dependency,
          // caused by RatioSize x RatioSize
          throw FlutterError.fromParts([
            ErrorSummary('Circular dependency detected'),
            ErrorDescription(
              'A child of FlexBox has a size that depends on both main axis and cross axis size.',
            ),
            ErrorHint(
              'This is not supported because it would cause an infinite loop during layout.',
            ),
          ]);
        }

        child = data.nextSibling;
      }

      // second consensus pass now that we have biggest flex
      // the one that requires biggest flex usually is ExpandingSize
      if (requiresBiggestFlex != null) {
        totalFlex = totalFlexBeforeDisaster;
      }
      while (requiresBiggestFlex != null) {
        final data = requiresBiggestFlex.parentData as FlexBoxParentData;

        final mainSize = data.getSize(direction);

        if (mainSize != null) {
          final result = mainSize.computeTotalFlex(biggestMainFlex);
          totalFlex = _addNullable(result, totalFlex);
        }

        requiresBiggestFlex = data.nextSibling;
      }
    }

    runConsensus();

    bool resolved = false;
    int passCount = 0;

    bool mainViewportSizeAvailable = maxViewportMainSize.isFinite;
    bool crossViewportSizeAvailable = maxViewportCrossSize.isFinite;

    bool shouldSortChildren = false;

    // these values reflect state from previous pass (and default if hasn't passed)
    double? crossContentSize;
    double? mainContentSize;
    // separate this to get easy remaining space for flexes
    double? mainFlexContentSize;
    double? flexFactor; // flex factor is space per flex unit
    //

    while (!resolved && passCount < maxComputePass) {
      bool desparateLayout = passCount >= maxComputePass - 1;
      print('------------------------------------------------------');
      print('PASS: $passCount (desparate: $desparateLayout)');

      if (flexFactor != null) {
        mainContentSize = null;
      }
      // the reason why we don't reset mainContentSize
      // when flexFactor is null is that
      // mainContentSize is required to determine
      // the remaining space for flexes
      // when flexFactor is null, it means
      // we have not yet determined the space per flex unit
      // so we need to keep the mainContentSize
      mainFlexContentSize = null;
      crossContentSize = null;
      // we set it to null because each pass
      // might recompute and layout from previous pass might change

      // state for current pass
      bool mainContentSizeReady = true;
      // if mainContentSizeReady is false, it means
      // at least one child cannot compute its main size
      // (except for child that has flex size)
      // this is typically caused by child with
      // RatioSize (has not gotten cross size yet)
      // RelativeSize (relative to content, and has not gotten content size yet)
      // IntrinsicSize (same as relative)
      bool mainFlexContentSizeReady = true;
      // if mainFlexContentSizeReady is false, it means
      // at least one child with flex size cannot compute its main size
      bool crossContentSizeReady = true;
      // these will be toggled to false
      // if one of the children is not ready
      bool absolutesReady = true;
      // if absolutesReady is false, it means
      // at least one absolute child cannot compute its size
      // mostly due to RelativeSize (relative to content, and has not gotten content size yet)
      bool recomputeFlexFactor = false;
      bool hasNewFlexes = false;
      //
      // the order usually goes like this:
      // 1. compute children that does not depend on content size
      // 2. some of the size are ready, compute children that depends on content size
      // 3. repeat number 2 until all children are resolved (except for when they depend on the flex size)
      // 4. compute flex size if any
      //    after this, main content size and main flex content size should be ready
      // 5. compute dependant cross sizes
      //    after this, cross content size should be ready
      // 6. both main content size (with flex size) and cross content size are ready, we are done 😘

      // only keys that are from dependsOn are stored here
      Map<Key, double> dependencies = {};

      RenderBox? child = firstChild;
      int childIndex = 0;

      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        print('child: ${childIndex++}');
        // reset
        if (passCount == 0) {
          data.resolvedMainSize = null;
          data.resolvedCrossSize = null;
        }

        bool shouldComputeMain = true;
        bool shouldComputeCross = true;

        // count
        BoxSize? mainSize = data.getSize(direction);
        BoxSize? crossSize = data.getSize(crossDirection);

        final mainContentRelative = data.isRelativeToContent(direction);
        final crossContentRelative = data.isRelativeToContent(crossDirection);

        // state for parent size availability
        // relative to what the child is relative to
        final mainParentSizeAvailable = mainContentRelative
            ? (mainContentSize != null && mainFlexContentSize != null)
            : mainViewportSizeAvailable;
        final crossParentSizeAvailable = crossContentRelative
            ? crossContentSize != null
            : crossViewportSizeAvailable;

        // the parent size it self
        final mainParentSize = mainContentRelative
            ? mainContentSize
            : maxViewportMainSize;
        final crossParentSize = crossContentRelative
            ? crossContentSize
            : maxViewportCrossSize;

        // if a child with non-null zOrder was found,
        // mark shouldSortChildren indicates at the end
        // if this, the flexbox should sort out the children
        if (data.zOrder != null) {
          shouldSortChildren = true;
        }

        // fill in defaults for main
        if (mainSize == null) {
          if (data.isAbsolute) {
            // if absolute, default will be taken from start and end positions
            // or intrinsic if both are not available
            final mainStart = data.getStartPosition(direction);
            final mainEnd = data.getEndPosition(direction);
            if (mainStart != null && mainEnd != null) {
              if (mainParentSizeAvailable) {
                data.setTemporarySize(
                  direction,
                  mainSize =
                      const BoxSize.relative(1.0) -
                      BoxSize.fixed(
                        mainStart.computePosition(mainParentSize!),
                      ) -
                      BoxSize.fixed(mainEnd.computePosition(mainParentSize)),
                );
              } else {
                // main size depends on parent size that is not available yet
                shouldComputeMain = false;
              }
            } else {
              data.setTemporarySize(
                direction,
                mainSize = const BoxSize.intrinsic(),
              );
            }
          } else {
            // non-absolute default to intrinsic
            data.setTemporarySize(
              direction,
              mainSize = const BoxSize.intrinsic(),
            );
          }
        }
        // fill in defaults for cross
        if (crossSize == null) {
          if (data.isAbsolute) {
            final crossStart = data.getStartPosition(crossDirection);
            final crossEnd = data.getEndPosition(crossDirection);
            if (crossStart != null && crossEnd != null) {
              if (crossParentSizeAvailable && crossParentSize != null) {
                data.setTemporarySize(
                  crossDirection,
                  crossSize =
                      const BoxSize.relative(1.0) -
                      BoxSize.fixed(
                        crossStart.computePosition(crossParentSize),
                      ) -
                      BoxSize.fixed(crossEnd.computePosition(crossParentSize)),
                );
              } else {
                // cross size depends on parent size that is not available yet
                shouldComputeCross = false;
              }
            } else {
              data.setTemporarySize(
                crossDirection,
                crossSize = BoxSize.intrinsic(),
              );
            }
          } else {
            data.setTemporarySize(
              crossDirection,
              crossSize = BoxSize.intrinsic(),
            );
          }
        }

        if (mainSize == null || crossSize == null) {
          // cannot resolve anything without size
          if (!data.isAbsolute) {
            if (mainSize == null) {
              mainContentSizeReady = false;
            }
            if (crossSize == null) {
              crossContentSizeReady = false;
            }
          }
          child = data.nextSibling;
          continue;
        }

        // requires flex factor means theres FlexSize or ExpandingSize in the calculation
        final mainInputs = mainSize.getRequiredInputs(
          mainAxis: true,
          crossRequiresSize: null,
        );
        final crossInputs = crossSize.getRequiredInputs(
          mainAxis: false,
          crossRequiresSize: null,
        );
        final mainSizeDependencies = mainSize.dependencies;
        final crossSizeDependencies = crossSize.dependencies;

        if (mainInputs.needsFlexFactor) {
          mainFlexContentSizeReady &= flexFactor != null;
          // needsFlexFactor does not prevent child from computing it size,
          // because if flexFactor is null, it will only try
          // to compute non-flex sizes first so that mainContentSize
          // become available to compute remaining space and flex factor
          // it will however mark that main flex content size is not ready
          // because it cannot compute flex size yet
        }

        // there is an issue where the dependencies
        // are from the main size itself. Preventing main
        // from being computed will also prevent
        // the dependencies from being resolved.
        // if (!_containsAllKeys(dependencies, mainSizeDependencies)) {
        //   shouldComputeMain = false;
        // }

        // if (!_containsAllKeys(dependencies, crossSizeDependencies)) {
        //   shouldComputeCross = false;
        // }

        if (mainInputs.needsMainAxisParentSize) {
          if (mainContentRelative) {
            throw FlutterError.fromParts([
              ErrorSummary(
                'Child with main axis size relative to content cannot be inside a FlexBox with main axis size relative to content.',
              ),
              ErrorDescription(
                'This is not supported because it would cause an infinite loop during layout.',
              ),
              ErrorHint(
                'Try setting the main axis size to be relative to viewport instead of content.',
              ),
            ]);
          }
          shouldComputeMain &= mainParentSizeAvailable;
        }

        if (crossInputs.needsMainAxisParentSize) {
          if (crossContentRelative) {
            throw FlutterError.fromParts([
              ErrorSummary(
                'Child with cross axis size relative to content cannot be inside a FlexBox with cross axis size relative to content.',
              ),
              ErrorDescription(
                'This is not supported because it would cause an infinite loop during layout.',
              ),
              ErrorHint(
                'Try setting the cross axis size to be relative to viewport instead of content.',
              ),
            ]);
          }
          shouldComputeCross &= crossParentSizeAvailable;
        }

        if (mainInputs.needsCrossAxisParentSize) {
          shouldComputeMain &= crossParentSizeAvailable;
        }

        if (crossInputs.needsCrossAxisParentSize) {
          shouldComputeCross &= mainParentSizeAvailable;
        }

        if (mainSize.needsCrossAxis) {
          shouldComputeMain &= data.resolvedCrossSize != null;
        }

        if (shouldComputeMain || hasNewFlexes) {
          final result = mainSize.computeSize(
            child: child,
            direction: direction,
            mainAxis: true,
            computeFlex: flexFactor != null,
            dependencies: dependencies,
            dependsOn: dependsOn,
            biggestFlex: biggestMainFlex,
            crossAxisParentSize: crossParentSize,
            crossAxisSize: data.resolvedCrossSize,
            flexFactor: flexFactor,
            mainAxisParentSize: mainParentSize,
          );
          if (result == null) {
            mainContentSizeReady = false;
          } else {
            if (result.recomputeFlex) {
              // when a size is marked to recompute flex,
              // it means that FlexSize or ExpandingSize
              // has been clamped and no longer contribute
              // to the flex size, so we need to recompute
              // the flex factor. To do this, we need to
              // convert the flex size to fixed size
              // so that in the next pass, the flex size
              // will not be counted towards the flex size
              recomputeFlexFactor = true;
              mainContentSize = _addNullable(
                mainContentSize,
                result.result + result.flexResult,
              );
              // when resolvedMainSize is not null,
              // the next pass will not reconsensus this
              // child again
              data.resolvedMainSize = result.result + result.flexResult;
            } else {
              mainFlexContentSize = _addNullable(
                mainFlexContentSize,
                result.flexResult,
              );
              mainContentSize = _addNullable(mainContentSize, result.result);
              data.resolvedMainSize = result.result;
              data.resolvedMainFlexSize = result.flexResult;
            }
          }
        } else {
          mainContentSizeReady = false;
        }

        if (crossSize.needsCrossAxis) {
          shouldComputeCross &= data.resolvedMainSize != null;
        }

        if (shouldComputeCross) {
          final result = crossSize.computeSize(
            child: child,
            direction: crossDirection,
            mainAxis: false,
            computeFlex: true,
            dependencies: dependencies,
            dependsOn: dependsOn,
            biggestFlex: biggestCrossFlex,
            crossAxisParentSize: crossParentSize,
            crossAxisSize: data.resolvedMainSize,
            flexFactor: null, // cross axis does not have flex factor
            mainAxisParentSize: mainParentSize,
          );
          if (result == null) {
            crossContentSizeReady = false;
          } else {
            crossContentSize = _maxNullable(
              crossContentSize,
              result.result,
            );
            // no need to separate flex size for cross axis
            // because cross axis does not have flex factor
            data.resolvedCrossSize = result.result + result.flexResult;
          }
        } else {
          crossContentSizeReady = false;
        }

        child = data.nextSibling;
      }

      if ((recomputeFlexFactor || flexFactor == null) && totalFlex != null) {
        if (recomputeFlexFactor) {
          // recompute flex factory only needs to be done
          // to the main axis
          runConsensus(
            consensusForDependencies: false,
            consensusForCross: false,
          );
        }
        assert(totalFlex != null);
        double remainingSpace = max(
          0.0,
          maxViewportMainSize - (mainContentSize ?? 0.0),
        );
        flexFactor = totalFlex! > 0 ? remainingSpace / totalFlex! : 0.0;
        hasNewFlexes = true;
      }

      recomputeFlexFactor = false;

      switch (layoutChange) {
        case FlexBoxLayoutChange.none:
          // should not happen
          resolved = true;
          break;
        case FlexBoxLayoutChange.nonAbsolute:
          resolved =
              mainContentSizeReady &&
              mainFlexContentSizeReady &&
              crossContentSizeReady;
          break;
        case FlexBoxLayoutChange.absolute:
          resolved = absolutesReady;
          break;
        case FlexBoxLayoutChange.both:
          resolved =
              mainContentSizeReady &&
              mainFlexContentSizeReady &&
              crossContentSizeReady &&
              absolutesReady;
          break;
      }
      print('-------------------------------');
      passCount++;
    }

    // layout
    if (layoutChild != null) {
      RenderBox? child = firstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        layoutChild(
          child,
          BoxConstraints.tightFor(
            width: direction == Axis.horizontal
                ? data.resolvedMainSize
                : data.resolvedCrossSize,
            height: direction == Axis.horizontal
                ? data.resolvedCrossSize
                : data.resolvedMainSize,
          ),
        );
        data.temporaryHeight = null;
        data.temporaryWidth = null;
        data.resolvedMainSize = null;
        data.resolvedMainFlexSize = null;
        data.resolvedCrossSize = null;
        child = data.nextSibling;
      }
    }

    return (
      mainContentSize: (mainContentSize ?? 0) + (mainFlexContentSize ?? 0),
      crossContentSize: crossContentSize ?? 0.0,
      shouldSortChildren: shouldSortChildren,
      flexUnit: flexFactor ?? 0.0,
      spacing: 0.0,
      spacingBefore: 0.0,
      spacingAfter: 0.0,
    );
  }

  void _positionsChildren({
    required double mainContentSize,
    required double crossContentSize,
    required double mainViewportSize,
    required double crossViewportSize,
    // we assume spacing has been resolved (not infinite)
    required double spacing,
    required double spacingBefore,
    required double spacingAfter,
    required FlexBoxPositionChange change,
  }) {
    assert(spacing.isFinite && spacingBefore.isFinite && spacingAfter.isFinite);
    if (childCount == 0) {
      return;
    }

    double mainAdditionalOffset = 0;
    double crossAdditionalOffset = 0;

    double mainScroll = direction == Axis.horizontal
        ? horizontal.pixels
        : vertical.pixels;
    double crossScroll = direction == Axis.horizontal
        ? vertical.pixels
        : horizontal.pixels;

    double mainAlignment = _getAlignMain(alignment);
    double crossAlignment = _getAlignCross(alignment);

    if (mainContentSize < mainViewportSize) {
      // we can align the children
      mainAdditionalOffset += _align(
        mainViewportSize - mainContentSize,
        mainAlignment,
      );
    }
    if (crossContentSize < crossViewportSize) {
      // we can align the children
      crossAdditionalOffset += _align(
        crossViewportSize - crossContentSize,
        crossAlignment,
      );
    }

    double mainOffset = 0;

    // these reverses are used for absolute children
    bool mainReverseText =
        textDirection == TextDirection.rtl && direction == Axis.horizontal;
    bool crossReverseText =
        textDirection == TextDirection.rtl && crossDirection == Axis.horizontal;

    // these reverses are used for non-absolute children
    bool reverseOffsetMain = false;
    bool reverseOffsetCross = false;

    switch ((textDirection, direction)) {
      case (TextDirection.ltr, Axis.horizontal):
        reverseOffsetMain = reverse;
        break;
      case (TextDirection.ltr, Axis.vertical):
        reverseOffsetMain = reverse;
        break;
      case (TextDirection.rtl, Axis.vertical):
        // main is Y axis, cross is X axis
        reverseOffsetCross = !reverse;
        break;
      case (TextDirection.rtl, Axis.horizontal):
        reverseOffsetMain = !reverse;
        break;
    }

    // double spacing = this.spacing;
    // if (spacing.isInfinite) {
    //   // attempt to evenly distribute the spacing
    //   // we need to get
    // }

    RenderBox? child = firstChild;
    // STOP KING 👑 do NOT use relativeFirstChild here
    // relativeFirstChild is used whether when reverse is true
    // (the order of the children is reversed)
    // although it was used in the legacy code to reverse the
    // order of positioning, it is not needed anymore (here) 🍷
    // because we will just handle it in the mainOffset calculation
    while (child != null) {
      final data = child.parentData as FlexBoxParentData;

      final isAbsolute = data.isAbsolute;

      if (change != FlexBoxPositionChange.both &&
          ((change.affectsAbsolute && !isAbsolute) ||
              (change.affectsNonAbsolute && isAbsolute))) {
        child = relativeNextSibling(child);
        continue;
      }

      Alignment? childAlignment = data.alignment?.resolve(textDirection);
      double? horizontalChildAlignment = childAlignment?.x;
      double? verticalChildAlignment = childAlignment?.y;

      double mainPosition = mainAdditionalOffset;
      double crossPosition = crossAdditionalOffset;

      BoxPositionType mainBoxPositionType =
          data.getPositionType(direction) ?? BoxPositionType.fixed;
      BoxPositionType crossBoxPositionType =
          data.getPositionType(crossDirection) ?? BoxPositionType.fixed;

      bool mainRelativeContent = data.isRelativeToContent(direction);
      bool crossRelativeContent = data.isRelativeToContent(crossDirection);

      if (data.isAbsolute) {
        BoxPosition? mainStart = direction == Axis.horizontal
            ? data.left
            : data.top;
        BoxPosition? mainEnd = direction == Axis.horizontal
            ? data.right
            : data.bottom;
        BoxPosition? crossStart = direction == Axis.horizontal
            ? data.top
            : data.left;
        BoxPosition? crossEnd = direction == Axis.horizontal
            ? data.bottom
            : data.right;

        double resolvedMainStart;
        double resolvedCrossStart;

        if (mainRelativeContent) {
          if (mainStart != null) {
            resolvedMainStart = mainStart.computePosition(mainContentSize);
          } else if (mainEnd != null) {
            resolvedMainStart =
                mainContentSize -
                mainEnd.computePosition(mainContentSize) -
                _getMain(child.size);
          } else {
            resolvedMainStart = 0;
          }
        } else {
          if (mainStart != null) {
            resolvedMainStart = mainStart.computePosition(mainViewportSize);
          } else if (mainEnd != null) {
            resolvedMainStart =
                mainViewportSize -
                mainEnd.computePosition(mainViewportSize) -
                _getMain(child.size);
          } else {
            resolvedMainStart = 0;
          }
        }

        if (crossRelativeContent) {
          if (crossStart != null) {
            resolvedCrossStart = crossStart.computePosition(crossContentSize);
          } else if (crossEnd != null) {
            resolvedCrossStart =
                crossContentSize -
                crossEnd.computePosition(crossContentSize) -
                _getCross(child.size);
          } else {
            resolvedCrossStart = 0;
          }
        } else {
          if (crossStart != null) {
            resolvedCrossStart = crossStart.computePosition(crossViewportSize);
          } else if (crossEnd != null) {
            resolvedCrossStart =
                crossViewportSize -
                crossEnd.computePosition(crossViewportSize) -
                _getCross(child.size);
          } else {
            throw FlutterError(
              'For absolute children with horizontalRelativeToContent=false, at least one of start or end position must be specified. Child: $child',
            );
          }
        }

        mainPosition += resolvedMainStart;
        crossPosition += resolvedCrossStart;
      } else {
        mainPosition += mainOffset;
        crossPosition += _align(
          crossContentSize - _getCross(child.size),
          crossAlignment,
        );
        mainOffset += _getMain(child.size);
      }

      if (data.isScrollAffected(direction)) {
        if (reverse && isAbsolute) {
          mainPosition -= mainContentSize - mainViewportSize - mainScroll;
        } else {
          mainPosition -= mainScroll;
        }
      }
      if (data.isScrollAffected(crossDirection)) {
        crossPosition -= crossScroll;
      }

      double mainVisibleBoundsStart = 0;
      double mainVisibleBoundsEnd = mainViewportSize;
      double crossVisibleBoundsStart = 0;
      double crossVisibleBoundsEnd = crossScroll + crossViewportSize;

      double mainExcessStart = mainPosition - mainVisibleBoundsStart;
      double mainExcessEnd =
          mainPosition - mainVisibleBoundsEnd + _getMain(child.size);
      double crossExcessStart = crossPosition - crossVisibleBoundsStart;
      double crossExcessEnd =
          crossPosition - crossVisibleBoundsEnd + _getCross(child.size);

      switch (mainBoxPositionType) {
        case BoxPositionType.stickyStart:
          if (mainExcessStart < 0) {
            mainPosition -= mainExcessStart;
          }
          break;
        case BoxPositionType.stickyEnd:
          if (mainExcessEnd > 0) {
            mainPosition -= mainExcessEnd;
          }
          break;
        case BoxPositionType.sticky:
          if (reverseOffsetMain) {
            if (mainExcessEnd > 0) {
              mainPosition -= mainExcessEnd;
            } else if (mainExcessStart < 0) {
              mainPosition -= mainExcessStart;
            }
          } else {
            if (mainExcessStart < 0) {
              mainPosition -= mainExcessStart;
            } else if (mainExcessEnd > 0) {
              mainPosition -= mainExcessEnd;
            }
          }
          break;
        default:
          break;
      }

      switch (crossBoxPositionType) {
        case BoxPositionType.stickyStart:
          if (crossExcessStart < 0) {
            crossPosition -= crossExcessStart;
          }
          break;
        case BoxPositionType.stickyEnd:
          if (crossExcessEnd > 0) {
            crossPosition -= crossExcessEnd;
          }
          break;
        case BoxPositionType.sticky:
          if (reverseOffsetCross) {
            if (crossExcessEnd > 0) {
              crossPosition -= crossExcessEnd;
            } else if (crossExcessStart < 0) {
              crossPosition -= crossExcessStart;
            }
          } else {
            if (crossExcessStart < 0) {
              crossPosition -= crossExcessStart;
            } else if (crossExcessEnd > 0) {
              crossPosition -= crossExcessEnd;
            }
          }
          break;
        default:
          break;
      }

      if (!isAbsolute) {
        switch ((mainRelativeContent, reverseOffsetMain)) {
          case (true, true):
            mainPosition =
                mainContentSize - mainPosition - _getMain(child.size);
            break;
          case (false, true):
            mainPosition =
                mainViewportSize - mainPosition - _getMain(child.size);
            break;
          default:
            break;
        }

        switch ((crossRelativeContent && !isAbsolute, reverseOffsetCross)) {
          case (true, true):
            crossPosition =
                crossContentSize - crossPosition - _getCross(child.size);
            break;
          case (false, true):
            crossPosition =
                crossViewportSize - crossPosition - _getCross(child.size);
            break;
          default:
            break;
        }
      }

      data.setOffset(mainPosition, crossPosition, direction);

      child = data.nextSibling;
    }
  }

  double _getAlignMain(Alignment alignment) {
    return direction == Axis.horizontal ? alignment.x : alignment.y;
  }

  double _getAlignCross(Alignment alignment) {
    return direction == Axis.horizontal ? alignment.y : alignment.x;
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
        BoxSize? mainSize = data.getSize(direction);
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
        BoxSize? crossSize = data.getSize(crossDirection);
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

double? _addNullable(double? a, double? b) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return a + b;
}

double? _addNull(double? a, double b) {
  if (a == null) return null;
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

bool _containsAllKeys(Map<Key, double> map, Iterable<Key> keys) {
  for (var key in keys) {
    if (!map.containsKey(key)) {
      return false;
    }
  }
  return true;
}
