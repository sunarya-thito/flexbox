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
  BoxSize? width = BoxSize.intrinsic();
  BoxSize? height = BoxSize.intrinsic();
  BoxPositionType? horizontalPosition;
  BoxPositionType? verticalPosition;
  bool horizontalScrollAffected = true;
  bool verticalScrollAffected = true;
  bool horizontalRelativeToContent = false;
  bool verticalRelativeToContent = false;
  AlignmentGeometry? alignment;

  bool needsRelayout = true;

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
    return absolute ||
        top != null ||
        bottom != null ||
        left != null ||
        right != null;
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
  Axis direction;
  double spacing;
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
  FlexSpacing spacingBehavior;

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
    required this.padding,
    required this.textDirection,
    required this.spacingBehavior,
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
      // because the we handle the size of the children here
      layoutChange: FlexBoxLayoutChange.nonAbsolute,
    );
    return _createSize(
      constraints.constrainWidth(result.mainContentSize),
      constraints.constrainHeight(result.crossContentSize),
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

  double _maxNullable(double? a, double b) {
    if (a == null) return b;
    return max(a, b);
  }

  ({
    double mainContentSize,
    double crossContentSize,
    bool shouldSortChildren,
    double flexUnit,
    // the spacing returned has the same behavior as empty unconstrained child
    double spacing,
  })
  _layoutChildren({
    required double maxViewportMainSize,
    required double maxViewportCrossSize,
    ChildLayouter? layoutChild,
    required FlexBoxLayoutChange layoutChange,
  }) {
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
        is on the cross size, it acts like relativeSize, which depends
        on the max cross size. BUT if the spaceRemaining is infinite,
        we resolve flex
      - relativeSize
        Similar to RelativeSize, but depends on the content size instead of
        the viewport size. WARNING: This only applies to cross axis, not main axis.
        Applying this to main axis would create a circular dependency.
        This also means that relativeSize depends on the max cross size.
        Different from RelativeSize, which depends on the viewport size.
        This cannot be resolved until the max cross size is resolved.
    */

    if (childCount == 0) {
      return (
        mainContentSize: 0.0,
        crossContentSize: 0.0,
        shouldSortChildren: false,
        flexUnit: 0.0,
        spacing: 0.0,
      );
    }

    if (true) {
      // use the new sizing option
      bool resolved = false;
      int resolveCount = 0;
      bool flexFactorAvailable = false;
      bool mainContentSizeAvailable = false;
      bool crossContentSizeAvailable = false;
      bool mainViewportSizeAvailable = maxViewportMainSize.isFinite;
      bool crossViewportSizeAvailable = maxViewportCrossSize.isFinite;
      bool minimalMainContentSizeAvailable = false;

      double mainContentSize = 0.0;
      // separate this to get easy remaining space for flexes
      double mainFlexContentSize = 0.0;
      double? crossContentSize;
      double? biggestMainFlex;
      double? biggestCrossFlex;
      double totalFlex = 0.0;
      double spacePerFlex = 0.0;

      bool recomputeMainFlex = false;
      // there is no such thing as recomputeCrossFlex
      // because cross flex factor takes the biggest cross flex
      // instead of total cross flex

      bool shouldSortChildren = false;

      const maxResolveCount = 10;

      while (!resolved && resolveCount < maxResolveCount) {
        bool desparateLayout = resolveCount >= maxResolveCount - 1;
        print('PASS: $resolveCount (desparate: $desparateLayout)');

        bool fullyResolvedMain = true;
        bool fullyResolvedCross = true;
        bool fullyResolvedAbsolute = true;

        // resolvedMinimalMain indicates that all children
        // that computes main axis has been resolved (except flex)
        bool fullyResolvedMinimalMain = true;

        bool hasFlex = false;

        bool shouldRecomputeFlex = false;

        RenderBox? child = firstChild;

        while (child != null) {
          final data = child.parentData as FlexBoxParentData;
          // reset
          if (resolveCount == 0) {
            data.resolvedMainSize = null;
            data.resolvedCrossSize = null;
          }

          // count
          BoxSize? mainSize = data.getSize(direction);
          BoxSize? crossSize = data.getSize(crossDirection);

          final mainContentRelative = data.isRelativeToContent(direction);
          final crossContentRelative = data.isRelativeToContent(crossDirection);

          bool readyToResolveMain = true;
          bool readyToResolveCross = true;

          final mainParentSizeAvailable = mainContentRelative
              ? mainContentSizeAvailable
              : mainViewportSizeAvailable;
          final crossParentSizeAvailable = crossContentRelative
              ? crossContentSizeAvailable
              : crossViewportSizeAvailable;
          final mainParentSize = mainContentRelative
              ? mainContentSize
              : maxViewportMainSize;
          final crossParentSize = crossContentRelative
              ? crossContentSize
              : maxViewportCrossSize;

          if (data.zOrder != null) {
            shouldSortChildren = true;
          }

          if (mainSize == null) {
            if (data.isAbsolute) {
              final mainStart = data.getStartPosition(direction);
              final mainEnd = data.getEndPosition(direction);
              if (mainStart != null && mainEnd != null) {
                if (mainParentSizeAvailable) {
                  mainSize =
                      const BoxSize.relative(1.0) -
                      BoxSize.fixed(mainStart.computePosition(mainParentSize)) -
                      BoxSize.fixed(mainEnd.computePosition(mainParentSize));
                } else {
                  readyToResolveMain = false;
                }
              } else {
                mainSize = const BoxSize.intrinsic();
              }
            } else {
              mainSize = const BoxSize.intrinsic();
            }
          }

          if (crossSize == null) {
            if (data.isAbsolute) {
              final crossStart = data.getStartPosition(crossDirection);
              final crossEnd = data.getEndPosition(crossDirection);
              if (crossStart != null && crossEnd != null) {
                if (crossParentSizeAvailable && crossParentSize != null) {
                  crossSize =
                      BoxSize.relative(1.0) -
                      BoxSize.fixed(
                        crossStart.computePosition(crossParentSize),
                      ) -
                      BoxSize.fixed(crossEnd.computePosition(crossParentSize));
                } else {
                  readyToResolveCross = false;
                }
              } else {
                crossSize = BoxSize.intrinsic();
              }
            } else {
              crossSize = BoxSize.intrinsic();
            }
          }

          bool mainRequiresFlexFactor =
              mainSize?.requiresFlexFactor(true) == true;
          bool crossRequiresFlexFactor =
              crossSize?.requiresFlexFactor(false) == true;

          if (mainRequiresFlexFactor) {
            // if it has flex, wait until flex factor become available
            // flex factor become available after a consensus of
            // flex sizes are resolved
            readyToResolveMain &= flexFactorAvailable;
            hasFlex = true;
          }

          if (mainSize?.requiresMainAxisParentSize(true) == true) {
            bool canResolve = mainContentRelative
                ? mainContentSizeAvailable
                : mainViewportSizeAvailable;
            readyToResolveMain &= canResolve;
            fullyResolvedMinimalMain &= canResolve;
          }

          if (mainSize?.requiresCrossAxisParentSize(true) == true) {
            bool canResolve = crossContentRelative
                ? crossContentSizeAvailable
                : crossViewportSizeAvailable;
            readyToResolveMain &= canResolve;
            fullyResolvedMinimalMain &= canResolve;
          }

          bool crossRequiresCrossAxisSize =
              crossSize?.requiresCrossAxisSize(false, true) == true;

          if (mainSize?.requiresCrossAxisSize(
                false,
                crossRequiresCrossAxisSize,
              ) ==
              true) {
            readyToResolveMain &= data.resolvedCrossSize != null;
          }

          // check for cross requirements
          if (crossRequiresFlexFactor) {
            readyToResolveCross &= flexFactorAvailable;
          }

          if (crossSize?.requiresMainAxisParentSize(false) == true) {
            readyToResolveCross &= mainContentRelative
                ? mainContentSizeAvailable
                : mainViewportSizeAvailable;
          }

          if (crossSize?.requiresCrossAxisParentSize(false) == true) {
            readyToResolveCross &= crossContentRelative
                ? crossContentSizeAvailable
                : crossViewportSizeAvailable;
          }

          if (crossRequiresCrossAxisSize) {
            readyToResolveCross &= data.resolvedMainSize != null;
          }

          // Compute cross first
          if ((readyToResolveCross && data.resolvedCrossSize == null) ||
              desparateLayout) {
            final result = crossSize?.computeSize(
              child: child,
              direction: crossDirection,
              mainAxis: false,
              computeFlex: true,
              biggestFlex: biggestCrossFlex,
              crossAxisSize: data.resolvedMainSize,
              mainAxisParentSize: mainContentRelative
                  ? (mainContentSizeAvailable ? mainContentSize : null)
                  : (mainViewportSizeAvailable ? maxViewportMainSize : null),
              crossAxisParentSize: crossContentRelative
                  ? (crossContentSizeAvailable ? crossContentSize : null)
                  : (crossViewportSizeAvailable ? maxViewportCrossSize : null),
              flexFactor: flexFactorAvailable ? spacePerFlex : null,
            );
            if (result != null) {
              data.resolvedCrossSize = result.result;
            }
          }

          if ((readyToResolveMain && data.resolvedMainSize == null) ||
              desparateLayout) {
            final result = mainSize?.computeSize(
              child: child,
              direction: direction,
              mainAxis: true,
              // do not compute flex until at least theres
              // content size available
              computeFlex: minimalMainContentSizeAvailable,
              biggestFlex: biggestMainFlex,
              crossAxisSize: data.resolvedCrossSize,
              mainAxisParentSize: mainContentRelative
                  ? (mainContentSizeAvailable ? mainContentSize : null)
                  : (mainViewportSizeAvailable ? maxViewportMainSize : null),
              crossAxisParentSize: crossContentRelative
                  ? (crossContentSizeAvailable ? crossContentSize : null)
                  : (crossViewportSizeAvailable ? maxViewportCrossSize : null),
              flexFactor: flexFactorAvailable ? spacePerFlex : null,
            );
            if (result != null) {
              data.resolvedMainSize = result.result;
              if (result.recomputeFlex) {
                // clamping flex size/unconstrained size
                // would affect the space per flex
                // we need to recalculate flex sizes
                if (mainRequiresFlexFactor) {
                  shouldRecomputeFlex = true;
                  double? selfTotalFlex = mainSize?.computeTotalFlex(
                    biggestMainFlex,
                  );
                  assert(selfTotalFlex != null);
                  totalFlex -= selfTotalFlex!;
                  fullyResolvedMain = false;
                }
              }
            }
          }

          double? mainTotalFlex = mainSize?.computeTotalFlex(
            biggestMainFlex,
          );
          double? crossTotalFlex = crossSize?.computeTotalFlex(
            biggestCrossFlex,
          );

          if (resolveCount == 0) {
            // only set total flex on the first pass
            if (mainTotalFlex != null) {
              totalFlex += mainTotalFlex;
            }
            if (crossTotalFlex != null) {
              biggestCrossFlex = _maxNullable(biggestCrossFlex, crossTotalFlex);
            }
          }

          if (!data.isAbsolute) {
            if (data.resolvedMainSize == null) {
              fullyResolvedMain = false;
            } else {
              mainContentSize = mainContentSize == null
                  ? data.resolvedMainSize!
                  : mainContentSize + data.resolvedMainSize!;
            }
            if (data.resolvedCrossSize == null) {
              fullyResolvedCross = false;
            } else {
              crossContentSize = _maxNullable(
                crossContentSize,
                data.resolvedCrossSize!,
              );
            }
          }

          child = data.nextSibling;
        }

        if (resolveCount > 0 &&
            minimalMainContentSizeAvailable &&
            (!flexFactorAvailable || shouldRecomputeFlex)) {
          double remainingSpace = max(
            0.0,
            maxViewportMainSize - mainContentSize,
          );
          spacePerFlex = totalFlex > 0 ? remainingSpace / totalFlex : 0.0;
          print(
            'New space per flex: $spacePerFlex = ($maxViewportMainSize - $mainContentSize)=($remainingSpace) / $totalFlex',
          );
          flexFactorAvailable = true;
          recomputeMainFlex = false;
        }

        if (shouldRecomputeFlex) {
          recomputeMainFlex = true;
        }

        if (fullyResolvedMinimalMain) {
          minimalMainContentSizeAvailable = true;
        }
        // fully resolved main and flex has been resolved
        if (fullyResolvedMain && (!hasFlex || flexFactorAvailable)) {
          mainContentSizeAvailable = true;
        }

        if (recomputeMainFlex) {
          // requires another pass
          fullyResolvedMain = false;
        }

        if (fullyResolvedCross) {
          crossContentSizeAvailable = true;
        }

        switch (layoutChange) {
          case FlexBoxLayoutChange.none:
            // should not happen
            resolved = true;
            break;
          case FlexBoxLayoutChange.nonAbsolute:
            resolved = fullyResolvedMain && fullyResolvedCross;
            break;
          case FlexBoxLayoutChange.absolute:
            resolved = fullyResolvedAbsolute;
            break;
          case FlexBoxLayoutChange.both:
            resolved =
                fullyResolvedMain &&
                fullyResolvedCross &&
                fullyResolvedAbsolute;
            break;
        }
        if (resolved) {
          print(
            'Resolved in $resolveCount passes $fullyResolvedMain $fullyResolvedCross',
          );
        } else {
          print('Not resolved in $resolveCount passes');
        }
        resolveCount++;
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
          child = data.nextSibling;
        }
      }

      print(
        'content: $mainContentSize x $crossContentSize ${layoutChange.name} $maxViewportMainSize x $maxViewportCrossSize in $resolveCount passes',
      );

      return (
        mainContentSize: mainContentSize + mainFlexContentSize,
        crossContentSize: crossContentSize ?? 0.0,
        shouldSortChildren: shouldSortChildren,
        flexUnit: spacePerFlex,
        spacing: 0.0,
      );
    }

    double mainContentSize = 0.0;
    double? crossContentSize;

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

    bool shouldSortChildren = false;

    double? spacePerFlex;

    if (layoutChange.affectsNonAbsolute) {
      RenderBox? firstFlexibleChild;

      // First pass
      RenderBox? child = relativeFirstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        // reset resolved sizes
        data.resolvedMainSize = null;
        data.resolvedCrossSize = null;

        if (data.zOrder != null) {
          shouldSortChildren = true;
        }

        // skip absolute children
        if (data.isAbsolute) {
          _firstAbsoluteChild ??= _Store(child);
          absoluteCount++;
          child = relativeNextSibling(child);
          continue;
        }

        _firstNonAbsoluteChild ??= _Store(child);

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
            //   relativeSize (need max content cross size),
            //   FlexSize (need max content cross size)
            switch (crossSize) {
              case FlexSize():
                maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
              // case ContentRelativeSize():
              case ExpandingSize():
                crossDependedCount++;
                break;
              case FixedSize():
                data.resolvedCrossSize = _clamp(
                  crossSize.size,
                  crossSize.min,
                  crossSize.max,
                );
                crossContentSize = _maxNullable(
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
                crossContentSize = _maxNullable(
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
                crossContentSize = _maxNullable(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RelativeSize():
                if (data.isRelativeToContent(crossDirection)) {
                  // cannot resolve relative size on cross axis
                  // because it depends on content size,
                  crossDependedCount++;
                } else {
                  if (maxViewportCrossSize.isFinite) {
                    data.resolvedCrossSize = _clamp(
                      maxViewportCrossSize * crossSize.relative,
                      crossSize.min,
                      crossSize.max,
                    );
                    crossContentSize = _maxNullable(
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
                    crossContentSize = _maxNullable(
                      crossContentSize,
                      data.resolvedCrossSize!,
                    );
                  }
                }
                break;
            }
            break;
          case IntrinsicSize():
            // handles: FixedSize, RelativeSize, Ratio, Intrinsic
            // impossible to handle: UnconstrainedSize (need max content cross size),
            //  relativeSize (need max content cross size),
            //  FlexSize (need max content cross size)
            switch (crossSize) {
              case FlexSize():
                maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
              // case ContentRelativeSize():
              case ExpandingSize():
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
                crossContentSize = _maxNullable(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RelativeSize():
                if (data.isRelativeToContent(crossDirection)) {
                  // cannot resolve relative size on cross axis
                  // because it depends on content size,
                  crossDependedCount++;
                } else {
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
                    crossContentSize = _maxNullable(
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
                    crossContentSize = _maxNullable(
                      crossContentSize,
                      data.resolvedCrossSize!,
                    );
                  }
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
                crossContentSize = _maxNullable(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
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
                crossContentSize = _maxNullable(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
            }
            break;
          case RelativeSize():
            if (data.isRelativeToContent(direction)) {
              throw FlutterError(
                'RelativeSize that is relative to content cannot be used on the main axis. It can only be used on the cross axis.',
              );
            }
            if (maxViewportMainSize.isFinite) {
              // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
              // impossible to handle: UnconstrainedSize (need max content cross size),
              //   relativeSize (need max content cross size),
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
                // case ContentRelativeSize():
                case ExpandingSize():
                  crossDependedCount++;
                  break;
                case FixedSize():
                  data.resolvedCrossSize = _clamp(
                    crossSize.size,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = _maxNullable(
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
                  crossContentSize = _maxNullable(
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
                  crossContentSize = _maxNullable(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
                case RelativeSize():
                  if (data.isRelativeToContent(crossDirection)) {
                    // relative to content size, cannot be resolved yet
                    // because content size is not known yet
                    crossDependedCount++;
                  } else {
                    if (maxViewportCrossSize.isFinite) {
                      data.resolvedCrossSize = _clamp(
                        maxViewportCrossSize * crossSize.relative,
                        crossSize.min,
                        crossSize.max,
                      );
                      crossContentSize = _maxNullable(
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
                      crossContentSize = _maxNullable(
                        crossContentSize,
                        data.resolvedCrossSize!,
                      );
                    }
                  }
                  break;
              }
            } else {
              // relative size needs viewport size to be finite
              // so as a safe fallback, we resolve it to 0.
              // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
              // impossible to handle: UnconstrainedSize (need max content cross size),
              //   relativeSize (need max content cross size),
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
                // case ContentRelativeSize():
                case ExpandingSize():
                  crossDependedCount++;
                  break;
                case FixedSize():
                  data.resolvedCrossSize = _clamp(
                    crossSize.size,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = _maxNullable(
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
                  crossContentSize = _maxNullable(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
                case RelativeSize():
                  if (data.isRelativeToContent(crossDirection)) {
                    // relative to content size, cannot be resolved yet
                    // because content size is not known yet
                    crossDependedCount++;
                  } else {
                    if (maxViewportCrossSize.isFinite) {
                      data.resolvedCrossSize = _clamp(
                        maxViewportCrossSize * crossSize.relative,
                        crossSize.min,
                        crossSize.max,
                      );
                      crossContentSize = _maxNullable(
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
                      crossContentSize = _maxNullable(
                        crossContentSize,
                        data.resolvedCrossSize!,
                      );
                    }
                  }
                  break;
                case RatioSize():
                  // ratio simply resolves to 0
                  data.resolvedCrossSize = _clamp(
                    0.0,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = _maxNullable(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
              }
            }
            break;
          case FlexSize():
            if (spaceRemaining.isInfinite) {
              // flex requires space to resolve, but since spaceRemaining is infinite,
              // we cannot resolve flex. Flex always requires space to resolve.
              // A safe fallback is done by treating flex as zero or intrinsic depending on the option
              // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
              // impossible to handle: UnconstrainedSize (need max content cross size),
              //   relativeSize (need max content cross size),
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
                // case ContentRelativeSize():
                case ExpandingSize():
                  crossDependedCount++;
                  break;
                case FixedSize():
                  data.resolvedCrossSize = _clamp(
                    crossSize.size,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = _maxNullable(
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
                  crossContentSize = _maxNullable(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
                case RelativeSize():
                  if (data.isRelativeToContent(crossDirection)) {
                    // relative to content size, cannot be resolved yet
                    // because content size is not known yet
                    crossDependedCount++;
                  } else {
                    if (maxViewportCrossSize.isFinite) {
                      data.resolvedCrossSize = _clamp(
                        maxViewportCrossSize * crossSize.relative,
                        crossSize.min,
                        crossSize.max,
                      );
                      crossContentSize = _maxNullable(
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
                      crossContentSize = _maxNullable(
                        crossContentSize,
                        data.resolvedCrossSize!,
                      );
                    }
                  }
                  break;
                case RatioSize():
                  // ratio simply resolves to 0
                  data.resolvedCrossSize = _clamp(
                    0.0,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = _maxNullable(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
              }
            } else {
              // only record flex values for now
              // handles: FixedSize, RelativeSize
              // impossible to handle: UnconstrainedSize (need max content cross size),
              //   relativeSize (need max content cross size),
              //   IntrinsicSize (need cross axis size), RatioSize (need cross axis size),
              //   FlexSize (need max content cross size),
              if (biggestMainFlex == null || mainSize.flex > biggestMainFlex) {
                biggestMainFlex = mainSize.flex;
              }
              totalMainFlex += mainSize.flex;
              unresolvedFlexCount++;
              firstFlexibleChild ??= child;
              // resolve cross axis if possible
              switch (crossSize) {
                case FlexSize():
                  maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
                // case ContentRelativeSize():
                case ExpandingSize():
                  crossDependedCount++;
                  break;
                case FixedSize():
                  data.resolvedCrossSize = _clamp(
                    crossSize.size,
                    crossSize.min,
                    crossSize.max,
                  );
                  crossContentSize = _maxNullable(
                    crossContentSize,
                    data.resolvedCrossSize!,
                  );
                  break;
                case RelativeSize():
                  if (data.isRelativeToContent(crossDirection)) {
                    // relative to content size, cannot be resolved yet
                    // because content size is not known yet
                    crossDependedCount++;
                  } else {
                    if (maxViewportCrossSize.isFinite) {
                      data.resolvedCrossSize = _clamp(
                        maxViewportCrossSize * crossSize.relative,
                        crossSize.min,
                        crossSize.max,
                      );
                      crossContentSize = _maxNullable(
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
                      crossContentSize = _maxNullable(
                        crossContentSize,
                        data.resolvedCrossSize!,
                      );
                    }
                  }
                  break;
              }
              // do not resolve IntrinsicSize for now, because
              // it requires main axis size to be resolved
            }
            break;
          case ExpandingSize():
            // only record unconstrained count for now
            unresolvedUnconstrainedCount++;
            firstFlexibleChild ??= child;
            break;
          case RatioSize():
            // handles: FixedSize, RelativeSize, IntrinsicSize, RatioSize
            // impossible to handle: UnconstrainedSize (need max content cross size),
            //   relativeSize (need max content cross size),
            //   FlexSize (need max content cross size)
            switch (crossSize) {
              case FlexSize():
                maxCrossFlex = _maxNullable(maxCrossFlex, crossSize.flex);
              // case ContentRelativeSize():
              case ExpandingSize():
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
                crossContentSize = _maxNullable(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
              case RatioSize():
                // both main and cross depends on each other
                throw FlutterError(
                  'RatioSize cannot be used on both main and cross axis at the same time. It can only be used on one axis.',
                );
              case RelativeSize():
                if (data.isRelativeToContent(crossDirection)) {
                  // relative to content size, cannot be resolved yet
                  // because content size is not known yet
                  crossDependedCount++;
                } else {
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
                    crossContentSize = _maxNullable(
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
                    crossContentSize = _maxNullable(
                      crossContentSize,
                      data.resolvedCrossSize!,
                    );
                  }
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
                crossContentSize = _maxNullable(
                  crossContentSize,
                  data.resolvedCrossSize!,
                );
                break;
            }
            break;
        }
        child = relativeNextSibling(child);
      }

      spaceRemaining -= mainContentSize;

      int gapCount = childCount - absoluteCount - 1;
      bool expandingSpacing = spacing.isInfinite;
      if (gapCount > 0) {
        if (!expandingSpacing) {
          // takes the exact amount of spacing
          // from the remaining space
          mainContentSize += gapCount * spacing;
          spaceRemaining -= gapCount * spacing;
        }
      }

      if (spacingBehavior != FlexSpacing.between) {
        // there is spacing at the edges
        // and if the spacing is expanding,
        // it forces
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
      // - Size(relative, *) * NOT ALLOWED
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
      // - Size(*, relative)

      bool shouldResolveFlex =
          spaceRemaining.isFinite &&
          (unresolvedFlexCount > 0 || unresolvedUnconstrainedCount > 0);
      // The reason canResolveFlex is false could be:
      // 1. main RatioSize is not yet solved

      // at this point, main RatioSize depends on each other (with cross FlexSize, UnconstrainedSize, relativeSize)
      // for the next phase, we prioritize resolving main FlexSize, and UnconstrainedSize first
      // so that we can have a resolved max cross content size to resolve main RatioSize and cross relativeSize

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
          spacePerFlex = totalMainFlex > 0
              ? spaceRemaining / totalMainFlex
              : 0.0;
          child = firstFlexibleChild;
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
                // - relativeSize (need max content cross size) * we don't do this here just yet
                // - FlexSize (need max content cross size) * we don't do this here just yet
                // - RatioSize (need cross axis size)
                switch (crossSize) {
                  case IntrinsicSize():
                    if (data.resolvedMainSize != null) {
                      data.resolvedCrossSize = _clamp(
                        _computeMaxIntrinsicCross(
                          child,
                          data.resolvedMainSize!,
                        ),
                        crossSize.min,
                        crossSize.max,
                      );
                      crossContentSize = _maxNullable(
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
                    crossContentSize = _maxNullable(
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
              case ExpandingSize():
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
                        _computeMaxIntrinsicCross(
                          child,
                          data.resolvedMainSize!,
                        ),
                        crossSize.min,
                        crossSize.max,
                      );
                      crossContentSize = _maxNullable(
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
                    crossContentSize = _maxNullable(
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
      assert(() {
        RenderBox? child = relativeFirstChild;
        while (child != null) {
          final data = child.parentData as FlexBoxParentData;
          final mainSize = data.getSize(direction);
          final crossSize = data.getSize(crossDirection);
          // make sure all main axis are resolved except for relativeSize
          if (!data.isAbsolute &&
              !(mainSize is RelativeSize &&
                  data.isRelativeToContent(direction)) &&
              data.resolvedMainSize == null) {
            throw FlutterError(
              'Main axis size is not resolved for a non-absolute child. '
              'This is likely a bug. Please report it to the package maintainer. '
              'Child: $child, MainSize: $mainSize, CrossSize: $crossSize',
            );
          }
          // make sure all cross axis are resolved except for relativeSize, FlexSize, UnconstrainedSize

          if (!data.isAbsolute &&
              !(crossSize is RelativeSize &&
                  data.isRelativeToContent(crossDirection)) &&
              crossSize is! FlexSize &&
              crossSize is! ExpandingSize &&
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
    // - Size(*, relative)
    // now cross content size is resolved.

    bool shouldResolveCross = crossDependedCount > 0;

    // the next phase requires viewport size to be finite
    // so for that, when the viewport size is infinite,
    // we refer them to the content size instead.
    if (maxViewportMainSize.isInfinite) {
      maxViewportMainSize = mainContentSize;
    }
    if (maxViewportCrossSize.isInfinite) {
      // maxViewportCrossSize = crossContentSize;
      if (crossContentSize == null) {
        // if crossContentSize is still null, it means all children
        // are either UnconstrainedSize, FlexSize, or relativeSize
        // in this case, we set it to 0
        maxViewportCrossSize = 0.0;
        crossContentSize = 0.0;
      } else {
        maxViewportCrossSize = crossContentSize;
      }
    } else {
      crossContentSize ??= maxViewportCrossSize;
    }

    // Third Phase
    // now we resolve cross axis that depends on max cross content size
    // we can also lay out the absolute children
    if (shouldResolveCross ||
        absoluteCount > 0 ||
        layoutChange == FlexBoxLayoutChange.absolute) {
      maxCrossFlex ??= 1.0;
      double crossSpacePerFlex = maxCrossFlex > 0
          ? crossContentSize / maxCrossFlex
          : 0.0;
      RenderBox? child;
      if (layoutChange == FlexBoxLayoutChange.absolute) {
        final firstAbsolute = _firstAbsoluteChild;
        if (firstAbsolute == null) {
          child = relativeFirstChild;
        } else {
          child = firstAbsolute.value;
        }
      } else {
        child = relativeFirstChild;
      }
      // note: no need to set for _firstAbsoluteChild here,
      // because it is already set in the first phase
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        if (data.isAbsolute) {
          _firstAbsoluteChild ??= _Store(child);
          // reset resolved sizes and positions
          data.resolvedMainStart = data.resolvedMainEnd =
              data.resolvedCrossStart = data.resolvedCrossEnd = null;

          assert(
            data.resolvedMainSize == null && data.resolvedCrossSize == null,
            'Absolute children should not have resolved sizes. Child: $child',
          );
          final mainSize = data.getSize(direction);
          final crossSize = data.getSize(crossDirection);
          double maxMainSize;
          double maxCrossSize;
          if (data.isRelativeToContent(direction)) {
            maxMainSize = mainContentSize;
          } else {
            maxMainSize = maxViewportMainSize;
          }
          if (data.isRelativeToContent(crossDirection)) {
            maxCrossSize = crossContentSize;
          } else {
            maxCrossSize = maxViewportCrossSize;
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
            case ExpandingSize():
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
              if (data.isRelativeToContent(direction)) {
                // useless
                data.resolvedMainSize = _clamp(
                  mainSize.relative * mainContentSize,
                  mainSize.min,
                  mainSize.max,
                );
              } else {
                data.resolvedMainSize = _clamp(
                  maxMainSize * mainSize.relative,
                  mainSize.min,
                  mainSize.max,
                );
              }
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
                  if (data.isRelativeToContent(crossDirection)) {
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
                  } else {
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
                  }
                  break;
                case ExpandingSize():
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
                  if (data.isRelativeToContent(crossDirection)) {
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
                  } else {
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
                  }
                  break;
                case ExpandingSize():
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
              }
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
                if (data.isRelativeToContent(crossDirection)) {
                  data.resolvedCrossSize = _clamp(
                    crossContentSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                } else {
                  data.resolvedCrossSize = _clamp(
                    maxCrossSize * crossSize.relative,
                    crossSize.min,
                    crossSize.max,
                  );
                }
                break;
              case FlexSize():
                throw FlutterError(
                  'FlexSize cannot be used for absolute children. Child: $child',
                );
              case ExpandingSize():
                data.resolvedCrossSize = _clamp(
                  maxCrossSize - usedCross,
                  crossSize.min,
                  crossSize.max,
                );
                break;
              case IntrinsicSize():
              case RatioSize():
                throw FlutterError(
                  'IntrinsicSize and RatioSize should have been handled above. Child: $child',
                );
            }
          }
        } else {
          if (!layoutChange.affectsAbsolute) {
            child = relativeNextSibling(child);
            continue;
          }
          final crossSize = data.getSize(crossDirection);
          switch (crossSize) {
            case ExpandingSize():
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
            case RelativeSize():
              if (data.isRelativeToContent(crossDirection)) {
                assert(
                  data.resolvedCrossSize == null,
                  'Cross size should not be resolved yet for relative to content size',
                );
                data.resolvedCrossSize = _clamp(
                  crossContentSize * crossSize.relative,
                  crossSize.min,
                  crossSize.max,
                );
              }
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
        // layoutChild(
        //   child,
        //   BoxConstraints.tightFor(
        //     width: direction == Axis.horizontal ? resolvedMain : resolvedCross,
        //     height: direction == Axis.horizontal ? resolvedCross : resolvedMain,
        //   ),
        // );
        data.resolvedMainSize = data.resolvedCrossSize = null;
        child = relativeNextSibling(child);
      }
    } else {
      // layout all children
      RenderBox? child = relativeFirstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        if (!data.isAbsolute) {
          double? resolvedMain = data.resolvedMainSize;
          double? resolvedCross = data.resolvedCrossSize;
          assert(
            resolvedMain != null && resolvedCross != null,
            'Resolved sizes should not be null at this point for size (${data.getSize(direction)}, ${data.getSize(crossDirection)})',
          );
          // layoutChild(
          //   child,
          //   BoxConstraints.tightFor(
          //     width: direction == Axis.horizontal
          //         ? resolvedMain
          //         : resolvedCross,
          //     height: direction == Axis.horizontal
          //         ? resolvedCross
          //         : resolvedMain,
          //   ),
          // );
        }
        data.resolvedMainSize = data.resolvedCrossSize = null;
        child = relativeNextSibling(child);
      }
    }

    // make sure all children has been laid out
    assert(() {
      RenderBox? child = relativeFirstChild;
      while (child != null) {
        final data = child.parentData as FlexBoxParentData;
        if (!child.hasSize) {
          if (!data.isAbsolute &&
              layoutChange == FlexBoxLayoutChange.absolute) {
            child = relativeNextSibling(child);
            continue;
          }
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
      shouldSortChildren: shouldSortChildren,
      flexUnit: spacePerFlex ?? 0.0,
      spacing: spacing,
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
    required double spacing,
    required FlexBoxPositionChange change,
  }) {
    if (childCount == 0) {
      return;
    }

    print(
      'mainViewportSize: $mainViewportSize, crossViewportSize: $crossViewportSize',
    );

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

    double spacing = this.spacing;
    if (spacing.isInfinite) {
      // attempt to evenly distribute the spacing
      // we need to get
    }

    RenderBox? child = firstChild; // do NOT use relativeFirstChild here
    // we handle reverse here
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

      // if (reverseOffsetMain) {
      //   // swap excess start and end
      //   final temp = mainExcessStart;
      //   mainExcessStart = mainExcessEnd;
      //   mainExcessEnd = temp;
      // }

      // if (reverseOffsetCross) {
      //   // swap excess start and end
      //   final temp = crossExcessStart;
      //   crossExcessStart = crossExcessEnd;
      //   crossExcessEnd = temp;
      // }

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
        } else if (mainSizeConstraint is ExpandingSize) {
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
        } else if (crossSizeConstraint is ExpandingSize) {
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
