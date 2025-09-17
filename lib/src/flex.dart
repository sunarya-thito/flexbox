import 'dart:math';

import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flutter/material.dart';

final class FlexWrap {
  static const FlexWrap nowrap = FlexWrap._(0.0);
  static const FlexWrap wrap = FlexWrap._(1.0);

  static FlexWrap lerp(FlexWrap a, FlexWrap b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return FlexWrap._(a.value * (1.0 - t) + b.value * t);
  }

  final double value;
  const FlexWrap._(this.value);
}

class FlexChildLayoutCache extends ChildLayoutCache {
  // cache
  double mainFlexSize = 0.0;
  double line = 0.0;

  FlexChildLayoutCache();

  double lineDifference(double line) {
    return line - this.line;
  }
}

class FlexLayout extends Layout {
  static FlexLayout lerp(FlexLayout a, FlexLayout b, double t) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;
    return FlexLayout(
      direction: LayoutDirection.lerp(a.direction, b.direction, t),
      wrap: FlexWrap.lerp(a.wrap, b.wrap, t),
      leftSpacing: SpacingUnit.lerp(a.leftSpacing, b.leftSpacing, t),
      topSpacing: SpacingUnit.lerp(a.topSpacing, b.topSpacing, t),
      rightSpacing: SpacingUnit.lerp(a.rightSpacing, b.rightSpacing, t),
      bottomSpacing: SpacingUnit.lerp(a.bottomSpacing, b.bottomSpacing, t),
      horizontalSpacing: SpacingUnit.lerp(
        a.horizontalSpacing,
        b.horizontalSpacing,
        t,
      ),
      verticalSpacing: SpacingUnit.lerp(
        a.verticalSpacing,
        b.verticalSpacing,
        t,
      ),
    );
  }

  final LayoutDirection direction;
  final FlexWrap wrap;
  final SpacingUnit leftSpacing;
  final SpacingUnit topSpacing;
  final SpacingUnit rightSpacing;
  final SpacingUnit bottomSpacing;
  final SpacingUnit horizontalSpacing;
  final SpacingUnit verticalSpacing;

  FlexLayout({
    this.direction = LayoutDirection.horizontal,
    this.wrap = FlexWrap.nowrap,
    this.leftSpacing = SpacingUnit.zero,
    this.topSpacing = SpacingUnit.zero,
    this.rightSpacing = SpacingUnit.zero,
    this.bottomSpacing = SpacingUnit.zero,
    this.horizontalSpacing = SpacingUnit.zero,
    this.verticalSpacing = SpacingUnit.zero,
  });

  @override
  LayoutHandle createLayoutHandle(ParentLayout parent) {
    return FlexLayoutHandle(this, parent);
  }
}

class FlexLayoutCache {
  final Map<double, FlexLineLayoutCache> caches = {};

  FlexLineLayoutCache getCacheForLine(double line) {
    return caches.putIfAbsent(line, () => FlexLineLayoutCache());
  }

  double getCrossSizesUntilLine(double line) {
    double size = 0.0;
    for (final entry in caches.entries) {
      if (entry.key < line) {
        size += entry.value.crossContentSize;
      }
    }
    return size;
  }
}

class FlexLineLayoutCache {
  double mainContentSize = 0.0;
  double crossContentSize = 0.0;
  double totalFlexGrow = 0.0;
  double shrinkFactor = 0.0;
  double affectedChildren = 0.0;
}

class FlexLayoutHandle extends LayoutHandle<FlexLayout> {
  FlexLayoutHandle(super.layout, super.parent);

  double? _horizontalSpacing;
  double? _verticalSpacing;

  FlexLayoutCache? _cache;

  FlexLayoutCache get cache {
    assert(
      _cache != null,
      'cache is only available after layout (not dry layout)',
    );
    return _cache!;
  }

  double get horizontalSpacing {
    assert(
      _horizontalSpacing != null,
      'horizontalSpacing is only available after layout (not dry layout)',
    );
    return _horizontalSpacing!;
  }

  double get verticalSpacing {
    assert(
      _verticalSpacing != null,
      'verticalSpacing is only available after layout (not dry layout)',
    );
    return _verticalSpacing!;
  }

  @override
  Size performLayout(BoxConstraints constraints, [bool dry = false]) {
    FlexLayoutCache cache = FlexLayoutCache();
    if (!dry) {
      _cache = cache;
    }

    bool needsPostSizeComputation = false;

    // count the spacing-basis first
    double topSpacing = layout.topSpacing.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: 0.0,
      availableSpace: 0.0,
      affectedCount: 0.0,
    );
    double leftSpacing = layout.leftSpacing.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: 0.0,
      availableSpace: 0.0,
      affectedCount: 0.0,
    );
    double bottomSpacing = layout.bottomSpacing.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: 0.0,
      availableSpace: 0.0,
      affectedCount: 0.0,
    );
    double rightSpacing = layout.rightSpacing.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: 0.0,
      availableSpace: 0.0,
      affectedCount: 0.0,
    );
    double horizontalSpacing = layout.horizontalSpacing.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: 0.0,
      availableSpace: 0.0,
      affectedCount: 0.0,
    );
    double verticalSpacing = layout.verticalSpacing.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: 0.0,
      availableSpace: 0.0,
      affectedCount: 0.0,
    );
    double mainSpacingStart = layout.direction.lerpDoubleValue(
      leftSpacing,
      topSpacing,
    );
    double mainSpacingEnd = layout.direction.lerpDoubleValue(
      rightSpacing,
      bottomSpacing,
    );
    double crossSpacingStart = (~layout.direction).lerpDoubleValue(
      topSpacing,
      leftSpacing,
    );
    double crossSpacingEnd = (~layout.direction).lerpDoubleValue(
      bottomSpacing,
      rightSpacing,
    );
    double mainSpacing = layout.direction.lerpDoubleValue(
      horizontalSpacing,
      verticalSpacing,
    );
    double crossSpacing = (~layout.direction).lerpDoubleValue(
      verticalSpacing,
      horizontalSpacing,
    );

    void resolveLineFlexFactors([
      double line = 0,
      ChildLayout? firstChild,
      bool forward = true,
    ]) {
      double mainSize = 0.0;
      double crossSize = 0.0;
      double totalFlexGrow = 0.0;
      double affectedChildren = 0.0;
      double shrinkFactor = 0.0;

      ChildLayout? child = dry
          ? (forward ? parent.firstDryLayout : parent.lastDryLayout)
          : (forward ? parent.firstLayoutChild : parent.lastLayoutChild);

      while (child != null) {
        final childCache = child.layoutCache as FlexChildLayoutCache;
        final data = child.layoutData;
        double lineDistance = childCache.lineDifference(line);
        if (lineDistance < 0 || lineDistance > 1) {
          child = forward ? child.nextSibling : child.previousSibling;
          continue;
        }
        double affection = data.behavior.value;
        final mainSizeUnit = layout.direction.getMainSizeUnit(
          data.width,
          data.height,
        );
        final crossSizeUnit = layout.direction.getCrossSizeUnit(
          data.width,
          data.height,
        );
        needsPostSizeComputation |= mainSizeUnit.needsPostAdjustment;
        needsPostSizeComputation |= crossSizeUnit.needsPostAdjustment;
        final resolvedMainSize = mainSizeUnit.computeSize(
          parent: parent,
          child: child,
          constraints: constraints,
          axis: layout.direction,
          contentSize: Size.zero,
          viewportSize: Size.zero,
        );
        final resolvedCrossSize = crossSizeUnit.computeSize(
          parent: parent,
          child: child,
          constraints: constraints,
          axis: ~layout.direction,
          contentSize: Size.zero,
          viewportSize: Size.zero,
        );
        mainSize += resolvedMainSize * affection;
        crossSize = max(crossSize, resolvedCrossSize * affection);
        double childShrinkFactor = resolvedMainSize * data.flexShrink;
        shrinkFactor += childShrinkFactor * affection;
        totalFlexGrow += data.flexGrow * affection;
        affectedChildren += affection;
        child = forward ? child.nextSibling : child.previousSibling;
      }
    }
  }

  @override
  void performPositioning(Size size) {
    verticalOffset = 0.0;
    horizontalOffset = 0.0;
    ChildLayout? child = parent.firstLayoutChild;
    while (child != null) {
      final data = child.layoutData;
      double dx = data.dx.computePosition(
        parent: parent,
        child: child,
        direction: layout.direction,
      );
      double dy = data.dy.computePosition(
        parent: parent,
        child: child,
        direction: ~layout.direction,
      );
      double offsetX = data.horizontalOffset.computePosition(
        parent: parent,
        child: child,
        direction: layout.direction,
      );
      double offsetY = data.verticalOffset.computePosition(
        parent: parent,
        child: child,
        direction: ~layout.direction,
      );
      child.layoutCache.offsetX = dx;
      child.layoutCache.offsetY = dy;
      horizontalOffset += offsetX;
      verticalOffset += offsetY;
      child = child.nextSibling;
    }
  }

  @override
  ChildLayoutCache setupCache() {
    return FlexChildLayoutCache();
  }
}
