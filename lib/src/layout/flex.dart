import 'dart:math';

import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';
import 'package:flexiblebox/src/rendering.dart';
import 'package:flutter/material.dart';

// final class FlexWrap {
//   static const FlexWrap nowrap = FlexWrap._(0.0);
//   static const FlexWrap wrap = FlexWrap._(1.0);

//   static FlexWrap lerp(FlexWrap a, FlexWrap b, double t) {
//     if (t <= 0.0) return a;
//     if (t >= 1.0) return b;
//     return FlexWrap._(a.value * (1.0 - t) + b.value * t);
//   }

//   final double value;
//   const FlexWrap._(this.value);
// }

enum FlexWrap {
  none,
  wrap,
  wrapReverse,
}

class FlexChildLayoutCache extends ChildLayoutCache {
  FlexLineLayoutCache? lineCache;

  double mainBasisSize = 0.0;
  double mainFlexSize = 0.0; // this also contains the basis size
  double crossSize = 0.0;
  double maxMainSize = 0.0;
  double minMainSize = 0.0;
  double maxCrossSize = 0.0;
  double minCrossSize = 0.0;
  bool frozen = false;
  bool frozenCross = false;
  double? baseline;
  bool? alignSelfNeedsBaseline;

  FlexChildLayoutCache();
}

class FlexLayout extends Layout {
  final Axis direction;
  final FlexWrap wrap;
  final int? maxItemsPerLine;
  final int? maxLines;
  final EdgeSpacing padding;
  final SpacingUnit horizontalSpacing;
  final SpacingUnit verticalSpacing;

  /// Cross-axis alignment for all items in the line
  // note: has baseline alignment and stretch alignment
  final BoxAlignmentGeometry alignItems;

  /// Cross-axis alignment for all lines
  // has stretch alignment, but no baseline alignment
  final BoxAlignmentContent alignContent;

  /// Main-axis alignment for all items in the line
  // note: does not have baseline alignment and stretch alignment
  final BoxAlignmentBase justifyContent;

  const FlexLayout({
    this.direction = Axis.horizontal,
    this.wrap = FlexWrap.none,
    this.padding = EdgeSpacing.zero,
    this.horizontalSpacing = SpacingUnit.zero,
    this.verticalSpacing = SpacingUnit.zero,
    this.maxItemsPerLine,
    this.maxLines,
    this.alignItems = BoxAlignment.start,
    this.alignContent = BoxAlignment.start,
    this.justifyContent = BoxAlignment.start,
  });

  @override
  LayoutHandle createLayoutHandle(ParentLayout parent) {
    return FlexLayoutHandle(this, parent);
  }
}

class FlexLayoutCache {
  FlexLineLayoutCache? firstLine;
  FlexLineLayoutCache? lastLine;
  double crossStartSpacing = 0.0;
  double crossEndSpacing = 0.0;
  double crossSpacing = 0.0;

  FlexLineLayoutCache allocateNewLine() {
    final line = FlexLineLayoutCache();
    if (firstLine == null) {
      firstLine = line;
      lastLine = line;
    } else {
      lastLine!.nextLine = line;
      line.previousLine = lastLine;
      lastLine = line;
    }
    return line;
  }
}

class FlexLineLayoutCache {
  // for layout purposes
  int lineIndex = 0;
  double mainSize = 0.0;
  double crossSize = 0.0;
  double totalFlexGrow = 0.0;
  double biggestCrossFlexGrow = 0.0;
  int itemCount = 0;
  double totalShrinkFactor = 0.0;
  double biggestCrossFlexShrinkFactor = 0.0;
  double usedMainSpacing = 0.0;
  double mainSpacingStart = 0.0;
  double mainSpacingEnd = 0.0;
  double mainSpacing = 0.0;

  double biggestBaseline = 0.0;

  ChildLayout? firstChild;
  ChildLayout? lastChild;

  FlexLineLayoutCache? previousLine;
  FlexLineLayoutCache? nextLine;
}

class FlexLayoutHandle extends LayoutHandle<FlexLayout> {
  FlexLayoutHandle(super.layout, super.parent);

  FlexLayoutCache? _cache;

  FlexLayoutCache get cache {
    assert(
      _cache != null,
      'cache is only available after layout (not dry layout)',
    );
    return _cache!;
  }

  @override
  Size performLayout(BoxConstraints constraints, [bool dry = false]) {
    // this method is called during dryLayout,
    // only do things that change the size of the parent here
    // only layout non-absolute children here
    // because absolute children do not affect the size of the parent
    double viewportWidth = constraints.maxWidth;
    double viewportHeight = constraints.maxHeight;
    bool avoidWrapping = false;
    if (viewportWidth.isInfinite) {
      viewportWidth = 0.0;
      if (layout.direction == Axis.horizontal) {
        avoidWrapping = true;
      }
    }
    if (viewportHeight.isInfinite) {
      viewportHeight = 0.0;
      if (layout.direction == Axis.vertical) {
        avoidWrapping = true;
      }
    }
    double viewportMainSize = switch (layout.direction) {
      Axis.horizontal => viewportWidth,
      Axis.vertical => viewportHeight,
    };
    double viewportCrossSize = switch (layout.direction) {
      Axis.horizontal => viewportHeight,
      Axis.vertical => viewportWidth,
    };
    // viewport size might be infinite
    FlexLayoutCache cache = FlexLayoutCache();
    if (!dry) {
      _cache = cache;
    }

    final mainSpacingStartUnit = switch (layout.direction) {
      Axis.horizontal => layout.padding.left,
      Axis.vertical => layout.padding.top,
    };
    final mainSpacingEndUnit = switch (layout.direction) {
      Axis.horizontal => layout.padding.right,
      Axis.vertical => layout.padding.bottom,
    };
    final crossSpacingStartUnit = switch (layout.direction) {
      Axis.horizontal => layout.padding.top,
      Axis.vertical => layout.padding.left,
    };
    final crossSpacingEndUnit = switch (layout.direction) {
      Axis.horizontal => layout.padding.bottom,
      Axis.vertical => layout.padding.right,
    };
    final mainSpacingUnit = switch (layout.direction) {
      Axis.horizontal => layout.horizontalSpacing,
      Axis.vertical => layout.verticalSpacing,
    };
    final crossSpacingUnit = switch (layout.direction) {
      Axis.horizontal => layout.verticalSpacing,
      Axis.vertical => layout.horizontalSpacing,
    };
    double mainSpacingStart = mainSpacingStartUnit.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: viewportMainSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double mainSpacingEnd = mainSpacingEndUnit.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: viewportMainSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double mainSpacing = mainSpacingUnit.computeSpacing(
      parent: parent,
      axis: layout.direction,
      maxSpace: viewportMainSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double crossSpacingStart = crossSpacingStartUnit.computeSpacing(
      parent: parent,
      axis: switch (layout.direction) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
      },
      maxSpace: viewportCrossSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double crossSpacingEnd = crossSpacingEndUnit.computeSpacing(
      parent: parent,
      axis: switch (layout.direction) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
      },
      maxSpace: viewportCrossSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double crossSpacing = crossSpacingUnit.computeSpacing(
      parent: parent,
      axis: switch (layout.direction) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
      },
      maxSpace: viewportCrossSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );

    // reduce viewport size by padding
    viewportMainSize = max(
      viewportMainSize - mainSpacingStart - mainSpacingEnd,
      0.0,
    );
    viewportCrossSize = max(
      viewportCrossSize - crossSpacingStart - crossSpacingEnd,
      0.0,
    );

    ChildLayout? child = dry
        ? parent.getFirstDryLayout(this)
        : parent.firstLayoutChild;

    // first pass: measure flex-basis, total flex-grow, total shrink factor,
    // and determine line breaks

    int lineIndex = 0;
    FlexLineLayoutCache lineCache = cache.allocateNewLine();
    double biggestCrossFlexGrow = 0.0;
    double biggestCrossFlexShrinkFactor = 0.0;
    double totalCrossFlexShrinkFactor = 0.0;
    double totalCrossFlexGrow = 0.0;
    double usedCrossSize = 0.0;
    double biggestCrossSize = 0.0;
    while (child != null) {
      final childCache = child.layoutCache as FlexChildLayoutCache;
      assert(childCache.lineCache == null);
      childCache.lineCache = lineCache;
      lineCache.lineIndex = lineIndex;
      lineCache.firstChild ??= child;
      lineCache.lastChild = child;
      final data = child.layoutData;
      if (data.behavior == LayoutBehavior.absolute) {
        child = child.nextSibling;
        continue;
      }
      var mainSizeUnit = switch (layout.direction) {
        Axis.horizontal => data.width,
        Axis.vertical => data.height,
      };
      var mainMaxSizeUnit = switch (layout.direction) {
        Axis.horizontal => data.maxWidth,
        Axis.vertical => data.maxHeight,
      };
      var crossSizeUnit = switch (layout.direction) {
        Axis.horizontal => data.height,
        Axis.vertical => data.width,
      };
      var crossMaxSizeUnit = switch (layout.direction) {
        Axis.horizontal => data.maxHeight,
        Axis.vertical => data.maxWidth,
      };
      double? resolvedMainSize = mainSizeUnit?.computeSize(
        parent: parent,
        child: child,
        layoutHandle: this,
        axis: layout.direction,
        contentSize: Size.zero,
        viewportSize: Size.zero,
      );
      double? resolvedCrossSize = crossSizeUnit?.computeSize(
        parent: parent,
        child: child,
        layoutHandle: this,
        axis: switch (layout.direction) {
          Axis.horizontal => Axis.vertical,
          Axis.vertical => Axis.horizontal,
        },
        contentSize: Size.zero,
        viewportSize: Size.zero,
      );
      double? aspectRatio = data.aspectRatio;
      if (resolvedMainSize == null && resolvedCrossSize == null) {
        Size dryLayout = child.dryLayout(BoxConstraints());
        resolvedMainSize = switch (layout.direction) {
          Axis.horizontal => dryLayout.width,
          Axis.vertical => dryLayout.height,
        };
        resolvedCrossSize = switch (layout.direction) {
          Axis.horizontal => dryLayout.height,
          Axis.vertical => dryLayout.width,
        };
      } else if (resolvedMainSize == null && resolvedCrossSize != null) {
        if (aspectRatio != null) {
          resolvedMainSize = resolvedCrossSize * aspectRatio;
        } else {
          // auto size on main axis, but we cannot layout the child yet
          // due to incoming size adjustment from flexing
          // what we can do is to get the intrinsic size of the child
          resolvedMainSize = switch (layout.direction) {
            Axis.horizontal => child.getMaxIntrinsicWidth(viewportHeight),
            Axis.vertical => child.getMaxIntrinsicHeight(viewportWidth),
          };
        }
      } else if (resolvedMainSize != null && resolvedCrossSize == null) {
        if (aspectRatio != null) {
          resolvedCrossSize = resolvedMainSize / aspectRatio;
        } else {
          // auto size on cross axis, but we cannot layout the child yet
          // due to incoming size adjustment from flexing
          // what we can do is to get the intrinsic size of the child
          resolvedCrossSize = switch (layout.direction) {
            Axis.horizontal => child.getMaxIntrinsicHeight(viewportWidth),
            Axis.vertical => child.getMaxIntrinsicWidth(viewportHeight),
          };
        }
      }
      // am i missing something? why would they both still be nullable
      resolvedMainSize ??= 0.0;
      resolvedCrossSize ??= 0.0;
      final resolvedMaxMainSize =
          mainMaxSizeUnit?.computeSize(
            parent: parent,
            child: child,
            layoutHandle: this,
            axis: layout.direction,
            contentSize: Size.zero,
            viewportSize: Size.zero,
          ) ??
          double.infinity;
      final resolvedMaxCrossSize =
          crossMaxSizeUnit?.computeSize(
            parent: parent,
            child: child,
            layoutHandle: this,
            axis: switch (layout.direction) {
              Axis.horizontal => Axis.vertical,
              Axis.vertical => Axis.horizontal,
            },
            contentSize: Size.zero,
            viewportSize: Size.zero,
          ) ??
          double.infinity;
      final resolvedMinMainSize = switch (layout.direction) {
        Axis.horizontal =>
          data.minWidth?.computeSize(
                parent: parent,
                child: child,
                layoutHandle: this,
                axis: layout.direction,
                contentSize: Size.zero,
                viewportSize: Size.zero,
              ) ??
              0.0,
        Axis.vertical =>
          data.minHeight?.computeSize(
                parent: parent,
                child: child,
                layoutHandle: this,
                axis: layout.direction,
                contentSize: Size.zero,
                viewportSize: Size.zero,
              ) ??
              0.0,
      };
      final resolvedMinCrossSize = switch (layout.direction) {
        Axis.horizontal =>
          data.minHeight?.computeSize(
                parent: parent,
                child: child,
                layoutHandle: this,
                axis: Axis.vertical,
                contentSize: Size.zero,
                viewportSize: Size.zero,
              ) ??
              0.0,
        Axis.vertical =>
          data.minWidth?.computeSize(
                parent: parent,
                child: child,
                layoutHandle: this,
                axis: Axis.horizontal,
                contentSize: Size.zero,
                viewportSize: Size.zero,
              ) ??
              0.0,
      };
      childCache.mainBasisSize = resolvedMainSize.clamp(
        resolvedMinMainSize,
        resolvedMaxMainSize,
      );
      childCache.mainFlexSize = childCache.mainBasisSize;
      childCache.crossSize = resolvedCrossSize.clamp(
        resolvedMinCrossSize,
        resolvedMaxCrossSize,
      );
      childCache.maxMainSize = resolvedMaxMainSize;
      childCache.minMainSize = resolvedMinMainSize;
      childCache.maxCrossSize = resolvedMaxCrossSize;
      childCache.minCrossSize = resolvedMinCrossSize;
      double newMainSize = lineCache.mainSize + resolvedMainSize;
      if (lineCache.itemCount > 0) {
        newMainSize += mainSpacing;
      }
      double usedMainSpace = newMainSize;
      // determine if this child can fit in the current line
      if (
      // wrap when item count is larger than the max items per line
      (layout.maxItemsPerLine != null &&
              lineCache.itemCount < layout.maxItemsPerLine!) &&
          // however, ignore if the total line exceeds the max lines allowed
          (layout.maxLines == null || lineIndex < layout.maxLines!) &&
          // if wrapping is enabled, and the item does not fit in the line
          (layout.wrap != FlexWrap.none && usedMainSpace > viewportMainSize) &&
          // and there is at least one item in the line
          // in case the item itself is larger than the viewport
          lineCache.itemCount > 0 &&
          // and we are not avoiding wrapping due to infinite space
          !avoidWrapping) {
        // need to wrap due to max items per line
        lineIndex++;
        // step back the previous line last child
        lineCache.lastChild = child.previousSibling;
        //
        lineCache = cache.allocateNewLine();
        childCache.lineCache = lineCache;
        lineCache.lineIndex = lineIndex;
        lineCache.firstChild = child;
        lineCache.lastChild = child;
        newMainSize = resolvedMainSize;
        totalCrossFlexGrow += biggestCrossFlexGrow;
        totalCrossFlexShrinkFactor += biggestCrossFlexShrinkFactor;
        biggestCrossFlexGrow = data.crossFlexGrow;
        biggestCrossFlexShrinkFactor = data.crossFlexShrink * resolvedCrossSize;
        usedCrossSize += biggestCrossSize;
        biggestCrossSize = resolvedCrossSize;
      } else {
        biggestCrossFlexGrow = max(biggestCrossFlexGrow, data.crossFlexGrow);
        biggestCrossFlexShrinkFactor = max(
          biggestCrossFlexShrinkFactor,
          data.crossFlexShrink * resolvedCrossSize,
        );
        biggestCrossSize = max(biggestCrossSize, resolvedCrossSize);
      }
      lineCache.usedMainSpacing += lineCache.itemCount > 0 ? mainSpacing : 0.0;
      lineCache.mainSize = newMainSize;
      double childShrinkFactor = resolvedMainSize * data.flexShrink;
      lineCache.totalShrinkFactor += childShrinkFactor;
      lineCache.totalFlexGrow += data.flexGrow;
      // lineCache.crossSize = max(lineCache.crossSize, resolvedCrossSize);
      if (child.layoutData.crossFlexShrink <= 0.0) {
        lineCache.crossSize = max(
          lineCache.crossSize,
          resolvedCrossSize,
        );
      }
      lineCache.biggestCrossFlexGrow = max(
        lineCache.biggestCrossFlexGrow,
        data.crossFlexGrow,
      );
      double childCrossShrinkFactor = resolvedCrossSize * data.crossFlexShrink;
      lineCache.biggestCrossFlexShrinkFactor = max(
        lineCache.biggestCrossFlexShrinkFactor,
        childCrossShrinkFactor,
      );
      lineCache.itemCount++;
      child = child.nextSibling;
    }

    totalCrossFlexGrow += biggestCrossFlexGrow;
    totalCrossFlexShrinkFactor += biggestCrossFlexShrinkFactor;
    usedCrossSize += biggestCrossSize;

    // baseline checking
    bool needsBaselineAlignment = layout.alignItems.needsBaseline(
      parent: parent,
      axis: switch (layout.direction) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
      },
    );
    //

    double usedMainSize = 0.0;
    // check for flexes in the lines
    FlexLineLayoutCache? line = cache.firstLine;
    lineIndex = 0;
    while (line != null) {
      bool lineResolved = false;
      int resolveCount = 0;
      double? biggestBaseline;
      bool selfAlignNeedsBaseline = false;
      while (!lineResolved && resolveCount < 10) {
        lineResolved = true;
        double usedMainSpace = line.mainSize;
        double availableMainSpace = viewportMainSize - usedMainSpace;
        double availableCrossSpace = viewportCrossSize - usedCrossSize;
        ChildLayout? child = line.firstChild;
        ChildLayout? lastChild = line.lastChild;
        while (child != null && child != lastChild) {
          if (child.layoutData.behavior == LayoutBehavior.absolute) {
            child = child.nextSibling;
            continue;
          }
          final childCache = child.layoutCache as FlexChildLayoutCache;

          if (needsBaselineAlignment) {
            double? cachedBaseline = childCache.baseline;
            if (cachedBaseline == null) {
              double baseline = child.getDistanceToBaseline(
                parent.textBaseline ?? TextBaseline.alphabetic,
              );
              childCache.baseline = cachedBaseline = baseline;
            }
            if (cachedBaseline.isFinite) {
              biggestBaseline ??= 0.0;
              biggestBaseline = max(biggestBaseline, cachedBaseline);
            }
          } else if (child.layoutData.alignSelf != null) {
            // check for self-alignment that needs baseline
            bool? cached = childCache.alignSelfNeedsBaseline;
            if (cached == null) {
              bool needsBaseline = child.layoutData.alignSelf!.needsBaseline(
                parent: parent,
                axis: switch (layout.direction) {
                  Axis.horizontal => Axis.vertical,
                  Axis.vertical => Axis.horizontal,
                },
              );
              childCache.alignSelfNeedsBaseline = cached = needsBaseline;
            }
            selfAlignNeedsBaseline = selfAlignNeedsBaseline || cached;
          }

          if (!childCache.frozen) {
            if (availableMainSpace > 0.0 && line.totalFlexGrow > 0.0) {
              double additionalSize =
                  availableMainSpace *
                  (child.layoutData.flexGrow / line.totalFlexGrow);
              double newSize = childCache.mainBasisSize + additionalSize;
              if (newSize > childCache.maxMainSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.maxMainSize - childCache.mainBasisSize;
                childCache.mainBasisSize = childCache.maxMainSize;
                childCache.frozen = true;
                line.totalFlexGrow -= child.layoutData.flexGrow;
                line.mainSize += basisSizeAdjustment;
                lineResolved = false;
                availableMainSpace -= basisSizeAdjustment;
                // do not break here yet, lets finish the loop
                // and determine the other non-frozen items
                // whether they need to be frozen or not
              } else if (newSize < childCache.minMainSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.minMainSize - childCache.mainBasisSize;
                childCache.mainBasisSize = childCache.minMainSize;
                childCache.frozen = true;
                line.totalFlexGrow -= child.layoutData.flexGrow;
                line.mainSize += basisSizeAdjustment;
                lineResolved = false;
                availableMainSpace -= basisSizeAdjustment;
              } else {
                childCache.mainFlexSize = newSize;
              }
            } else if (availableMainSpace < 0.0 &&
                line.totalShrinkFactor > 0.0) {
              double shrinkSize =
                  availableMainSpace *
                  (child.layoutData.flexShrink *
                      childCache.mainBasisSize /
                      line.totalShrinkFactor);
              // shrinking also applies min/max constraints
              double newSize = childCache.mainBasisSize + shrinkSize;
              if (newSize < childCache.minMainSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.minMainSize - childCache.mainBasisSize;
                childCache.mainBasisSize = childCache.minMainSize;
                childCache.frozen = true;
                line.totalShrinkFactor -=
                    child.layoutData.flexShrink * childCache.mainBasisSize;
                line.mainSize += basisSizeAdjustment;
                lineResolved = false;
                availableMainSpace -= basisSizeAdjustment;
                // do not break here yet, lets finish the loop
                // and determine the other non-frozen items
                // whether they need to be frozen or not
              } else if (newSize > childCache.maxMainSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.maxMainSize - childCache.mainBasisSize;
                childCache.mainBasisSize = childCache.maxMainSize;
                childCache.frozen = true;
                line.totalShrinkFactor -=
                    child.layoutData.flexShrink * childCache.mainBasisSize;
                line.mainSize += basisSizeAdjustment;
                lineResolved = false;
                availableMainSpace -= basisSizeAdjustment;
              } else {
                childCache.mainFlexSize = newSize;
              }
            }
          }

          if (!childCache.frozenCross) {
            if (childCache.crossSize.isInfinite) {
              // expand, follow the biggest cross size in the line
              childCache.crossSize = line.crossSize;
            } else if (availableCrossSpace > 0.0 && totalCrossFlexGrow > 0.0) {
              double additionalSize =
                  availableCrossSpace *
                  (child.layoutData.crossFlexGrow / totalCrossFlexGrow);
              double newSize = childCache.crossSize + additionalSize;
              if (newSize > childCache.maxCrossSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.maxCrossSize - childCache.crossSize;
                childCache.crossSize = childCache.maxCrossSize;
                childCache.frozenCross = true;
                totalCrossFlexGrow -= child.layoutData.crossFlexGrow;
                usedCrossSize += basisSizeAdjustment;
                lineResolved = false;
                availableCrossSpace -= basisSizeAdjustment;
                // do not break here yet, lets finish the loop
                // and determine the other non-frozen items
                // whether they need to be frozen or not
              } else if (newSize < childCache.minCrossSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.minCrossSize - childCache.crossSize;
                childCache.crossSize = childCache.minCrossSize;
                childCache.frozenCross = true;
                totalCrossFlexGrow -= child.layoutData.crossFlexGrow;
                usedCrossSize += basisSizeAdjustment;
                lineResolved = false;
                availableCrossSpace -= basisSizeAdjustment;
              } else {
                childCache.crossSize = newSize;
              }
            } else if (availableCrossSpace < 0.0 &&
                totalCrossFlexShrinkFactor > 0.0) {
              double shrinkSize =
                  availableCrossSpace *
                  (child.layoutData.crossFlexShrink *
                      childCache.crossSize /
                      totalCrossFlexShrinkFactor);
              // shrinking also applies min/max constraints
              double newSize = childCache.crossSize + shrinkSize;
              if (newSize < childCache.minCrossSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.minCrossSize - childCache.crossSize;
                childCache.crossSize = childCache.minCrossSize;
                childCache.frozenCross = true;
                totalCrossFlexShrinkFactor -=
                    child.layoutData.crossFlexShrink * childCache.crossSize;
                usedCrossSize += basisSizeAdjustment;
                lineResolved = false;
                availableCrossSpace -= basisSizeAdjustment;
                // do not break here yet, lets finish the loop
                // and determine the other non-frozen items
                // whether they need to be frozen or not
              } else if (newSize > childCache.maxCrossSize) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment =
                    childCache.maxCrossSize - childCache.crossSize;
                childCache.crossSize = childCache.maxCrossSize;
                childCache.frozenCross = true;
                totalCrossFlexShrinkFactor -=
                    child.layoutData.crossFlexShrink * childCache.crossSize;
                usedCrossSize += basisSizeAdjustment;
                lineResolved = false;
                availableCrossSpace -= basisSizeAdjustment;
              } else {
                childCache.crossSize = newSize;
              }
            }
          }
          child = child.nextSibling;
        }
        resolveCount++;
      }

      if (!needsBaselineAlignment && selfAlignNeedsBaseline) {
        // content does not need baseline alignment
        // but apparently some of the items need it
        // so we need to check the baselines anyway
        // and since needsBaselineAlignment is false,
        // we have not computed the baselines yet
        ChildLayout? child = line.firstChild;
        ChildLayout? lastChild = line.lastChild;
        while (child != null && child != lastChild) {
          if (child.layoutData.behavior == LayoutBehavior.absolute) {
            child = child.nextSibling;
            continue;
          }
          final childCache = child.layoutCache as FlexChildLayoutCache;

          if (child.layoutData.alignSelf != null) {
            // check for self-alignment that needs baseline
            bool? cached = childCache.alignSelfNeedsBaseline;
            if (cached == true) {
              double? cachedBaseline = childCache.baseline;
              if (cachedBaseline == null) {
                double baseline = child.getDistanceToBaseline(
                  parent.textBaseline ?? TextBaseline.alphabetic,
                );
                childCache.baseline = cachedBaseline = baseline;
              }
              if (cachedBaseline.isFinite) {
                biggestBaseline ??= 0.0;
                biggestBaseline = max(biggestBaseline, cachedBaseline);
              }
            }
          }

          child = child.nextSibling;
        }
      }

      // fallback of the baseline is the biggest cross size in the line
      line.biggestBaseline = biggestBaseline ?? line.crossSize;

      // recompute spacing if needed
      if (mainSpacingUnit.needsPostAdjustment ||
          mainSpacingStartUnit.needsPostAdjustment ||
          mainSpacingEndUnit.needsPostAdjustment) {
        double availableSpace = max(
          viewportMainSize - line.mainSize,
          0.0,
        );
        line.mainSpacingStart = mainSpacingStartUnit.computeSpacing(
          parent: parent,
          axis: layout.direction,
          maxSpace: viewportMainSize,
          availableSpace: availableSpace,
          affectedCount: line.itemCount,
        );
        line.mainSpacingEnd = mainSpacingEndUnit.computeSpacing(
          parent: parent,
          axis: layout.direction,
          maxSpace: viewportMainSize,
          availableSpace: availableSpace,
          affectedCount: line.itemCount,
        );
        line.mainSpacing = mainSpacingUnit.computeSpacing(
          parent: parent,
          axis: layout.direction,
          maxSpace: viewportMainSize,
          availableSpace: availableSpace,
          affectedCount: line.itemCount - 1,
        );
      } else {
        line.mainSpacingStart = mainSpacingStart;
        line.mainSpacingEnd = mainSpacingEnd;
        line.mainSpacing = mainSpacing;
      }

      // recompute cross spacing if needed

      usedMainSize = max(usedMainSize, line.mainSize);
      line = line.nextLine;
      lineIndex++;
    }

    if (crossSpacingUnit.needsPostAdjustment ||
        crossSpacingStartUnit.needsPostAdjustment ||
        crossSpacingEndUnit.needsPostAdjustment) {
      double availableSpace = max(
        viewportCrossSize - usedCrossSize,
        0.0,
      );
      crossSpacingStart = crossSpacingStartUnit.computeSpacing(
        parent: parent,
        axis: switch (layout.direction) {
          Axis.horizontal => Axis.vertical,
          Axis.vertical => Axis.horizontal,
        },
        maxSpace: viewportCrossSize,
        availableSpace: availableSpace,
        affectedCount: lineIndex + 1,
      );
      crossSpacingEnd = crossSpacingEndUnit.computeSpacing(
        parent: parent,
        axis: switch (layout.direction) {
          Axis.horizontal => Axis.vertical,
          Axis.vertical => Axis.horizontal,
        },
        maxSpace: viewportCrossSize,
        availableSpace: availableSpace,
        affectedCount: lineIndex + 1,
      );
      crossSpacing = crossSpacingUnit.computeSpacing(
        parent: parent,
        axis: switch (layout.direction) {
          Axis.horizontal => Axis.vertical,
          Axis.vertical => Axis.horizontal,
        },
        maxSpace: viewportCrossSize,
        availableSpace: availableSpace,
        affectedCount: lineIndex,
      );
    }

    cache.crossStartSpacing = crossSpacingStart;
    cache.crossEndSpacing = crossSpacingEnd;
    cache.crossSpacing = crossSpacing;

    if (lineIndex > 1) {
      usedCrossSize +=
          crossSpacingStart + crossSpacingEnd + (lineIndex - 1) * crossSpacing;
    } else {
      usedCrossSize += crossSpacingStart + crossSpacingEnd;
    }

    return switch (layout.direction) {
      Axis.horizontal => Size(
        usedMainSize,
        usedCrossSize,
      ),
      Axis.vertical => Size(
        usedCrossSize,
        usedMainSize,
      ),
    };
  }

  @override
  Rect performPositioning(BoxConstraints constraints, Size size) {
    // this method is not called during dryLayout!
    // so this method can only do something that does not change the
    // size of the parent!
    // here we positions children, align then, and re-adjust their size (stretch alignment)
    // here we also define the size of absolute children
    // and to finalize things out, we call child.layout here

    Rect bounds = Rect.zero;

    // layout absolute children
    ChildLayout? child = parent.firstLayoutChild;
    // note: absolute children don't use content size ([size])
    // instead it uses the constraints, so padding or any spacing
    // does not affect the absolute children
    while (child != null) {
      final data = child.layoutData;
      if (data.behavior != LayoutBehavior.absolute) {
        child = child.nextSibling;
        continue;
      }

      double? topOffset;
      double? leftOffset;
      double? rightOffset;
      double? bottomOffset;

      if (data.top != null) {
        topOffset = data.top!.computePosition(
          parent: parent,
          child: child,
          direction: Axis.vertical,
        );
      }
      if (data.left != null) {
        leftOffset = data.left!.computePosition(
          parent: parent,
          child: child,
          direction: Axis.horizontal,
        );
      }
      if (data.right != null) {
        rightOffset = data.right!.computePosition(
          parent: parent,
          child: child,
          direction: Axis.horizontal,
        );
      }
      if (data.bottom != null) {
        bottomOffset = data.bottom!.computePosition(
          parent: parent,
          child: child,
          direction: Axis.vertical,
        );
      }

      double? maxWidth;
      double? maxHeight;
      double? minWidth;
      double? minHeight;

      double? availableWidth;
      double? availableHeight;

      double? aspectRatio = data.aspectRatio;

      if (topOffset != null && bottomOffset != null) {
        availableHeight = constraints.maxHeight - topOffset - bottomOffset;
      }
      if (leftOffset != null && rightOffset != null) {
        availableWidth = constraints.maxWidth - leftOffset - rightOffset;
      }

      if (data.maxWidth != null) {
        maxWidth = data.maxWidth!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: Axis.horizontal,
          contentSize: availableWidth != null && availableHeight != null
              ? Size(availableWidth, availableHeight)
              : constraints.biggest,
          viewportSize: constraints.biggest,
        );
      }
      if (data.maxHeight != null) {
        maxHeight = data.maxHeight!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: Axis.vertical,
          contentSize: availableWidth != null && availableHeight != null
              ? Size(availableWidth, availableHeight)
              : constraints.biggest,
          viewportSize: constraints.biggest,
        );
      }
      if (data.minWidth != null) {
        minWidth = data.minWidth!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: Axis.horizontal,
          contentSize: availableWidth != null && availableHeight != null
              ? Size(availableWidth, availableHeight)
              : constraints.biggest,
          viewportSize: constraints.biggest,
        );
      }
      if (data.minHeight != null) {
        minHeight = data.minHeight!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: Axis.vertical,
          contentSize: availableWidth != null && availableHeight != null
              ? Size(availableWidth, availableHeight)
              : constraints.biggest,
          viewportSize: constraints.biggest,
        );
      }

      double? preferredWidth;
      double? preferredHeight;
      if (data.width != null) {
        preferredWidth = data.width!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: Axis.horizontal,
          contentSize: availableWidth != null && availableHeight != null
              ? Size(availableWidth, availableHeight)
              : constraints.biggest,
          viewportSize: constraints.biggest,
        );
        preferredWidth = _clampNullable(
          preferredWidth,
          minWidth,
          maxWidth,
        );
      } else if (availableWidth != null) {
        preferredWidth = _clampNullable(
          availableWidth,
          minWidth,
          maxWidth,
        );
      }
      if (data.height != null) {
        preferredHeight = data.height!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: Axis.vertical,
          contentSize: availableWidth != null && availableHeight != null
              ? Size(availableWidth, availableHeight)
              : constraints.biggest,
          viewportSize: constraints.biggest,
        );
        preferredHeight = _clampNullable(
          preferredHeight,
          minHeight,
          maxHeight,
        );
      } else if (availableHeight != null) {
        preferredHeight = _clampNullable(
          availableHeight,
          minHeight,
          maxHeight,
        );
      }

      // handle aspect ratio
      if (aspectRatio != null) {
        if (preferredWidth != null && preferredHeight == null) {
          preferredHeight = preferredWidth / aspectRatio;
          preferredHeight = _clampNullable(
            preferredHeight,
            minHeight,
            maxHeight,
          );
        } else if (preferredHeight != null && preferredWidth == null) {
          preferredWidth = preferredHeight * aspectRatio;
          preferredWidth = _clampNullable(
            preferredWidth,
            minWidth,
            maxWidth,
          );
        }
      }

      // use preferred size to layout the children
      child.layout(
        BoxConstraints.tightFor(
          width: preferredWidth ?? 0.0,
          height: preferredHeight ?? 0.0,
        ),
      );

      switch (parent.textDirection) {
        case TextDirection.ltr:
          child.offset = Offset(
            leftOffset ??
                (rightOffset != null
                    ? constraints.maxWidth - rightOffset - child.size.width
                    : 0.0),
            topOffset ??
                (bottomOffset != null
                    ? constraints.maxHeight - bottomOffset - child.size.height
                    : 0.0),
          );
        case TextDirection.rtl:
          child.offset = Offset(
            rightOffset != null
                ? constraints.maxWidth - rightOffset - child.size.width
                : (leftOffset ?? 0.0),
            topOffset ??
                (bottomOffset != null
                    ? constraints.maxHeight - bottomOffset - child.size.height
                    : 0.0),
          );
      }

      Rect childBounds = child.offset & child.size;
      bounds = bounds.expandToInclude(childBounds);

      child = child.nextSibling;
    }

    // positions non-absolute children
    double mainViewportSize = switch (layout.direction) {
      Axis.horizontal => constraints.maxWidth,
      Axis.vertical => constraints.maxHeight,
    };
    double crossViewportSize = switch (layout.direction) {
      Axis.horizontal => constraints.maxHeight,
      Axis.vertical => constraints.maxWidth,
    };
    double crossContentOffset = cache.crossStartSpacing;
    final alignItemsNeedsBaseline = layout.alignItems.needsBaseline(
      parent: parent,
      axis: switch (layout.direction) {
        Axis.horizontal => Axis.vertical,
        Axis.vertical => Axis.horizontal,
      },
    );
    FlexLineLayoutCache? line = cache.firstLine;
    while (line != null) {
      double mainLineOffset = line.mainSpacingStart;

      final justifyContent = layout.justifyContent.align(
        parent: parent,
        axis: layout.direction,
        viewportSize: mainViewportSize,
        contentSize: line.mainSize,
        // justify content does not need baseline
        maxBaseline: 0.0,
        childBaseline: 0.0,
      );

      mainLineOffset += justifyContent;

      ChildLayout? child = line.firstChild;
      int childIndex = 0;
      while (child != null && child != line.lastChild) {
        // handled separately
        if (child.layoutData.behavior == LayoutBehavior.absolute) {
          child = child.nextSibling;
          continue;
        }

        // add spacing
        if (childIndex > 0) {
          mainLineOffset += line.mainSpacing;
        }

        final childCache = child.layoutCache as FlexChildLayoutCache;
        double mainOffset = mainLineOffset;
        double crossOffset = crossContentOffset;

        final alignContent = layout.alignContent.align(
          parent: parent,
          axis: switch (layout.direction) {
            Axis.horizontal => Axis.vertical,
            Axis.vertical => Axis.horizontal,
          },
          viewportSize: crossViewportSize,
          contentSize: line.crossSize,
          // no baseline needed
          maxBaseline: 0.0,
          childBaseline: 0.0,
        );

        bool? alignSelfNeedsBaseline = childCache.alignSelfNeedsBaseline;

        double? alignSelf = child.layoutData.alignSelf?.align(
          parent: parent,
          axis: switch (layout.direction) {
            Axis.horizontal => Axis.vertical,
            Axis.vertical => Axis.horizontal,
          },
          viewportSize: line.crossSize,
          contentSize: childCache.crossSize,
          // align self does not need baseline
          maxBaseline: line.biggestBaseline,
          childBaseline: alignSelfNeedsBaseline == true
              ? childCache.baseline! // should be non-null here
              // because we computed it earlier
              : 0.0,
        );

        alignSelf ??= layout.alignItems.align(
          parent: parent,
          axis: switch (layout.direction) {
            Axis.horizontal => Axis.vertical,
            Axis.vertical => Axis.horizontal,
          },
          viewportSize: line.crossSize,
          contentSize: childCache.crossSize,
          maxBaseline: line.biggestBaseline,
          childBaseline: alignItemsNeedsBaseline
              ? childCache.baseline! // should be non-null here
              // because we computed it earlier
              : 0.0,
        );

        crossOffset += alignContent;

        double dx = switch (layout.direction) {
          Axis.horizontal => mainOffset,
          Axis.vertical => crossOffset + alignSelf,
        };
        double dy = switch (layout.direction) {
          Axis.horizontal => crossOffset + alignSelf,
          Axis.vertical => mainOffset,
        };

        // apply scroll offset
        dx -= parent.scrollOffsetX;
        dy -= parent.scrollOffsetY;

        // apply sticky adjustment
        Rect contentRect = Rect.fromLTWH(
          dx,
          dy,
          childCache.mainFlexSize,
          childCache.crossSize,
        );
        // the bounds rely on the top/left/right/bottom position defined
        // in the layout data, otherwise it uses the parent content bounds
        // note: these bounds are relative to the viewport size ([constraints])
        double? topBound;
        double? leftBound;
        double? rightBound;
        double? bottomBound;
        if (child.layoutData.top != null) {
          topBound = child.layoutData.top!.computePosition(
            parent: parent,
            child: child,
            direction: Axis.vertical,
          );
        } else {
          topBound = -parent.scrollOffsetY;
        }
        if (child.layoutData.left != null) {
          leftBound = child.layoutData.left!.computePosition(
            parent: parent,
            child: child,
            direction: Axis.horizontal,
          );
        } else {
          leftBound = -parent.scrollOffsetX;
        }
        if (child.layoutData.right != null) {
          rightBound = child.layoutData.right!.computePosition(
            parent: parent,
            child: child,
            direction: Axis.horizontal,
          );
        } else {
          rightBound = size.width - parent.scrollOffsetX;
        }
        if (child.layoutData.bottom != null) {
          bottomBound = child.layoutData.bottom!.computePosition(
            parent: parent,
            child: child,
            direction: Axis.vertical,
          );
        } else {
          bottomBound = size.height - parent.scrollOffsetY;
        }
        Rect bounds = Rect.fromLTRB(
          leftBound,
          topBound,
          rightBound,
          bottomBound,
        );
        Rect limitedRect = _limitRectToBounds(contentRect, bounds);
        dx = limitedRect.left;
        dy = limitedRect.top;

        child.offset = Offset(dx, dy);

        child.layout(
          switch (layout.direction) {
            Axis.horizontal => BoxConstraints.tightFor(
              width: childCache.mainFlexSize,
              height: childCache.crossSize,
            ),
            Axis.vertical => BoxConstraints.tightFor(
              width: childCache.crossSize,
              height: childCache.mainFlexSize,
            ),
          },
        );

        Rect childBounds = child.offset & child.size;
        bounds = bounds.expandToInclude(childBounds);

        mainLineOffset += childCache.mainFlexSize;

        child = child.nextSibling;
        childIndex++;
      }

      line = line.nextLine;
    }
    return bounds;
  }

  @override
  ChildLayoutCache setupCache() {
    return FlexChildLayoutCache();
  }
}

double _clampNullable(double value, double? min, double? max) {
  if (min != null && value < min) {
    return min;
  }
  if (max != null && value > max) {
    return max;
  }
  return value;
}

Rect _limitRectToBounds(Rect content, Rect bounds) {
  // used to determine sticky position, so that it does not exceed the bounds
  // this does not change the size of the content
  double left = content.left;
  double top = content.top;
  double right = content.right;
  double bottom = content.bottom;
  if (content.left < bounds.left) {
    left = bounds.left;
    right = left + content.width;
  }
  if (content.right > bounds.right) {
    right = bounds.right;
    left = right - content.width;
  }
  if (content.top < bounds.top) {
    top = bounds.top;
    bottom = top + content.height;
  }
  if (content.bottom > bounds.bottom) {
    bottom = bounds.bottom;
    top = bottom - content.height;
  }
  return Rect.fromLTRB(left, top, right, bottom);
}
