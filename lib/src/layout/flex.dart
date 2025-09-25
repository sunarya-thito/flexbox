import 'dart:math';

import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';

enum FlexWrap {
  none,
  wrap,
  wrapReverse,
}

class FlexChildLayoutCache extends ChildLayoutCache {
  FlexLineLayoutCache? lineCache;

  double? mainBasisSize;
  double? mainFlexSize; // this also contains the basis size
  double? crossSize;
  double? maxMainSize;
  double? minMainSize;
  double? maxCrossSize;
  double? minCrossSize;
  bool frozen = false;
  bool frozenCross = false;
  double? baseline;
  bool? alignSelfNeedsBaseline;

  FlexChildLayoutCache();
}

class FlexLayout extends Layout {
  final FlexDirection direction;
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
    this.direction = FlexDirection.row,
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
  int lineCount = 0;

  FlexLineLayoutCache allocateNewLine() {
    assert(
      lastLine == null || lastLine!.debugChildCount > 0,
      'last line must have at least one child',
    );
    final line = FlexLineLayoutCache();
    line.lineIndex = lineCount;
    if (firstLine == null) {
      firstLine = line;
      lastLine = line;
    } else {
      lastLine!.nextLine = line;
      line.previousLine = lastLine;
      lastLine = line;
    }
    lineCount++;
    return line;
  }
}

class FlexLineLayoutCache {
  // for layout purposes
  int lineIndex = 0;
  double mainSize = 0.0;
  double crossSize = 0.0;
  double totalFlexGrow = 0.0;
  int itemCount = 0;
  double totalShrinkFactor = 0.0;
  double usedMainSpacing = 0.0;
  double mainSpacingStart = 0.0;
  double mainSpacingEnd = 0.0;
  double mainSpacing = 0.0;

  double biggestBaseline = 0.0;

  ChildLayout? firstChild;
  ChildLayout? lastChild;

  FlexLineLayoutCache? previousLine;
  FlexLineLayoutCache? nextLine;

  int get debugChildCount {
    int count = 0;
    ChildLayout? child = firstChild;
    while (child != null && child != lastChild) {
      count++;
      child = child.nextSibling;
    }
    return count;
  }
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
  LayoutSize performLayout(LayoutConstraints constraints, [bool dry = false]) {
    // this method is called during dryLayout,
    // only do things that change the size of the parent here
    // only layout non-absolute children here
    // because absolute children do not affect the size of the parent
    double viewportWidth = constraints.maxWidth;
    double viewportHeight = constraints.maxHeight;
    bool avoidWrapping = false;
    if (viewportWidth.isInfinite) {
      viewportWidth = 0.0;
      if (layout.direction.axis == LayoutAxis.horizontal) {
        avoidWrapping = true;
      }
    }
    if (viewportHeight.isInfinite) {
      viewportHeight = 0.0;
      if (layout.direction.axis == LayoutAxis.vertical) {
        avoidWrapping = true;
      }
    }
    double viewportMainSize = switch (layout.direction.axis) {
      LayoutAxis.horizontal => viewportWidth,
      LayoutAxis.vertical => viewportHeight,
    };
    double viewportCrossSize = switch (layout.direction.axis) {
      LayoutAxis.horizontal => viewportHeight,
      LayoutAxis.vertical => viewportWidth,
    };
    // viewport size might be infinite
    FlexLayoutCache cache = FlexLayoutCache();
    if (!dry) {
      _cache = cache;
    }

    final mainSpacingStartUnit = switch (layout.direction.axis) {
      LayoutAxis.horizontal => layout.padding.left,
      LayoutAxis.vertical => layout.padding.top,
    };
    final mainSpacingEndUnit = switch (layout.direction.axis) {
      LayoutAxis.horizontal => layout.padding.right,
      LayoutAxis.vertical => layout.padding.bottom,
    };
    final crossSpacingStartUnit = switch (layout.direction.axis) {
      LayoutAxis.horizontal => layout.padding.top,
      LayoutAxis.vertical => layout.padding.left,
    };
    final crossSpacingEndUnit = switch (layout.direction.axis) {
      LayoutAxis.horizontal => layout.padding.bottom,
      LayoutAxis.vertical => layout.padding.right,
    };
    final mainSpacingUnit = switch (layout.direction.axis) {
      LayoutAxis.horizontal => layout.horizontalSpacing,
      LayoutAxis.vertical => layout.verticalSpacing,
    };
    final crossSpacingUnit = switch (layout.direction.axis) {
      LayoutAxis.horizontal => layout.verticalSpacing,
      LayoutAxis.vertical => layout.horizontalSpacing,
    };
    double mainSpacingStart = mainSpacingStartUnit.computeSpacing(
      parent: parent,
      axis: layout.direction.axis,
      maxSpace: viewportMainSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double mainSpacingEnd = mainSpacingEndUnit.computeSpacing(
      parent: parent,
      axis: layout.direction.axis,
      maxSpace: viewportMainSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double mainSpacing = mainSpacingUnit.computeSpacing(
      parent: parent,
      axis: layout.direction.axis,
      maxSpace: viewportMainSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double crossSpacingStart = crossSpacingStartUnit.computeSpacing(
      parent: parent,
      axis: switch (layout.direction.axis) {
        LayoutAxis.horizontal => LayoutAxis.vertical,
        LayoutAxis.vertical => LayoutAxis.horizontal,
      },
      maxSpace: viewportCrossSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double crossSpacingEnd = crossSpacingEndUnit.computeSpacing(
      parent: parent,
      axis: switch (layout.direction.axis) {
        LayoutAxis.horizontal => LayoutAxis.vertical,
        LayoutAxis.vertical => LayoutAxis.horizontal,
      },
      maxSpace: viewportCrossSize,
      availableSpace: 0.0,
      affectedCount: 0,
    );
    double crossSpacing = crossSpacingUnit.computeSpacing(
      parent: parent,
      axis: switch (layout.direction.axis) {
        LayoutAxis.horizontal => LayoutAxis.vertical,
        LayoutAxis.vertical => LayoutAxis.horizontal,
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

    FlexLineLayoutCache lineCache = cache.allocateNewLine();
    // double usedCrossSize = 0.0;
    double biggestCrossSize = 0.0;
    while (child != null) {
      final childCache = child.layoutCache as FlexChildLayoutCache;
      assert(childCache.lineCache == null);
      childCache.lineCache = lineCache;
      lineCache.firstChild ??= child;
      lineCache.lastChild = child;
      final data = child.layoutData;
      if (data.behavior == LayoutBehavior.absolute) {
        child = child.nextSibling;
        continue;
      }
      var mainSizeUnit = switch (layout.direction.axis) {
        LayoutAxis.horizontal => data.width,
        LayoutAxis.vertical => data.height,
      };
      var mainMaxSizeUnit = switch (layout.direction.axis) {
        LayoutAxis.horizontal => data.maxWidth,
        LayoutAxis.vertical => data.maxHeight,
      };
      var crossSizeUnit = switch (layout.direction.axis) {
        LayoutAxis.horizontal => data.height,
        LayoutAxis.vertical => data.width,
      };
      var crossMaxSizeUnit = switch (layout.direction.axis) {
        LayoutAxis.horizontal => data.maxHeight,
        LayoutAxis.vertical => data.maxWidth,
      };
      double? resolvedMainSize = mainSizeUnit?.computeSize(
        parent: parent,
        child: child,
        layoutHandle: this,
        axis: layout.direction.axis,
        contentSize: LayoutSize.zero,
        viewportSize: LayoutSize.zero,
      );
      double? resolvedCrossSize = crossSizeUnit?.computeSize(
        parent: parent,
        child: child,
        layoutHandle: this,
        axis: switch (layout.direction.axis) {
          LayoutAxis.horizontal => LayoutAxis.vertical,
          LayoutAxis.vertical => LayoutAxis.horizontal,
        },
        contentSize: LayoutSize.zero,
        viewportSize: LayoutSize.zero,
      );
      double? aspectRatio = data.aspectRatio;
      if (resolvedMainSize == null && resolvedCrossSize != null) {
        if (aspectRatio != null) {
          resolvedMainSize = resolvedCrossSize * aspectRatio;
        }
      } else if (resolvedMainSize != null && resolvedCrossSize == null) {
        if (aspectRatio != null) {
          resolvedCrossSize = resolvedMainSize / aspectRatio;
        }
      }
      // am i missing something? why would they both still be nullable
      final resolvedMaxMainSize = mainMaxSizeUnit?.computeSize(
        parent: parent,
        child: child,
        layoutHandle: this,
        axis: layout.direction.axis,
        contentSize: LayoutSize.zero,
        viewportSize: LayoutSize.zero,
      );
      final resolvedMaxCrossSize = crossMaxSizeUnit?.computeSize(
        parent: parent,
        child: child,
        layoutHandle: this,
        axis: switch (layout.direction.axis) {
          LayoutAxis.horizontal => LayoutAxis.vertical,
          LayoutAxis.vertical => LayoutAxis.horizontal,
        },
        contentSize: LayoutSize.zero,
        viewportSize: LayoutSize.zero,
      );
      final resolvedMinMainSize = switch (layout.direction.axis) {
        LayoutAxis.horizontal => data.minWidth?.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: layout.direction.axis,
          contentSize: LayoutSize.zero,
          viewportSize: LayoutSize.zero,
        ),
        LayoutAxis.vertical => data.minHeight?.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: layout.direction.axis,
          contentSize: LayoutSize.zero,
          viewportSize: LayoutSize.zero,
        ),
      };
      final resolvedMinCrossSize = switch (layout.direction.axis) {
        LayoutAxis.horizontal => data.minHeight?.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: LayoutAxis.vertical,
          contentSize: LayoutSize.zero,
          viewportSize: LayoutSize.zero,
        ),
        LayoutAxis.vertical => data.minWidth?.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: LayoutAxis.horizontal,
          contentSize: LayoutSize.zero,
          viewportSize: LayoutSize.zero,
        ),
      };
      // childCache.mainBasisSize = resolvedMainSize.clamp(
      //   resolvedMinMainSize,
      //   resolvedMaxMainSize,
      // );
      childCache.mainBasisSize = _clampNullableDouble(
        resolvedMainSize,
        resolvedMinMainSize,
        resolvedMaxMainSize,
      );
      childCache.mainFlexSize = childCache.mainBasisSize;
      childCache.crossSize = _clampNullableDouble(
        resolvedCrossSize,
        resolvedMinCrossSize,
        resolvedMaxCrossSize,
      );
      childCache.maxMainSize = resolvedMaxMainSize;
      childCache.minMainSize = resolvedMinMainSize;
      childCache.maxCrossSize = resolvedMaxCrossSize;
      childCache.minCrossSize = resolvedMinCrossSize;
      double newMainSize = lineCache.mainSize + (resolvedMainSize ?? 0.0);
      if (lineCache.itemCount > 0) {
        newMainSize += mainSpacing;
      }
      double usedMainSpace = newMainSize;
      // determine if this child can fit in the current line
      bool exceedsMaxItemsPerLine =
          layout.maxItemsPerLine != null &&
          lineCache.itemCount >= layout.maxItemsPerLine!;
      bool shouldFlexWrap =
          layout.wrap != FlexWrap.none &&
          usedMainSpace > viewportMainSize &&
          !avoidWrapping;
      bool exceedsMaxLines =
          layout.maxLines != null && lineCache.lineIndex >= layout.maxLines!;
      bool hasMinimumOneItem = lineCache.itemCount > 0;
      if ((shouldFlexWrap || exceedsMaxItemsPerLine) &&
          hasMinimumOneItem &&
          !exceedsMaxLines) {
        lineCache = cache.allocateNewLine();
        childCache.lineCache = lineCache;
        lineCache.firstChild = child;
        lineCache.lastChild = child;
        newMainSize = (resolvedMainSize ?? 0.0);
        // usedCrossSize += biggestCrossSize; // moved to the line-loop
        biggestCrossSize = (resolvedCrossSize ?? 0.0);
      } else if (resolvedCrossSize != null) {
        biggestCrossSize = max(biggestCrossSize, resolvedCrossSize);
      }
      lineCache.usedMainSpacing += lineCache.itemCount > 0 ? mainSpacing : 0.0;
      lineCache.mainSize = newMainSize;
      double childShrinkFactor = (resolvedMainSize ?? 0.0) * data.flexShrink;
      lineCache.totalShrinkFactor += childShrinkFactor;
      lineCache.totalFlexGrow += data.flexGrow;
      // note: cross size is determined by the biggest cross size in the line
      // but it needs to be done after we determine the cross shrink factor
      // lineCache.crossSize = max(
      //   lineCache.crossSize,
      //   resolvedCrossSize,
      // );
      lineCache.itemCount++;
      child = child.nextSibling;
    }

    lineCache.lastChild = null; // last line last child is the end

    // usedCrossSize += biggestCrossSize; // moved to the line-loop

    // baseline checking
    bool needsBaselineAlignment = layout.alignItems.needsBaseline(
      parent: parent,
      axis: switch (layout.direction.axis) {
        LayoutAxis.horizontal => LayoutAxis.vertical,
        LayoutAxis.vertical => LayoutAxis.horizontal,
      },
    );
    //

    double usedMainSize = 0.0;
    double usedCrossSize = 0.0;
    // check for flexes in the lines
    FlexLineLayoutCache? line = cache.firstLine;
    double stretchLineCrossSize = switch (layout.direction.axis) {
      LayoutAxis.horizontal => viewportHeight / cache.lineCount,
      LayoutAxis.vertical => viewportWidth / cache.lineCount,
    };
    while (line != null) {
      bool lineResolved = false;
      int resolveCount = 0;
      double? biggestBaseline;
      bool selfAlignNeedsBaseline = false;
      while (!lineResolved && resolveCount < 10) {
        lineResolved = true;
        double usedMainSpace = line.mainSize;
        double availableMainSpace = viewportMainSize - usedMainSpace;
        double biggestLineCrossSize = 0.0;
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
                parent.textBaseline ?? LayoutTextBaseline.alphabetic,
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
                axis: switch (layout.direction.axis) {
                  LayoutAxis.horizontal => LayoutAxis.vertical,
                  LayoutAxis.vertical => LayoutAxis.horizontal,
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
              double newSize = _addNullable(
                childCache.mainBasisSize,
                additionalSize,
              );
              if (childCache.maxMainSize != null &&
                  newSize > childCache.maxMainSize!) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment = _subtractNullable(
                  childCache.maxMainSize,
                  childCache.mainBasisSize,
                );
                childCache.mainBasisSize = childCache.maxMainSize;
                childCache.frozen = true;
                line.totalFlexGrow -= child.layoutData.flexGrow;
                line.mainSize += basisSizeAdjustment;
                lineResolved = false;
                availableMainSpace -= basisSizeAdjustment;
                // do not break here yet, lets finish the loop
                // and determine the other non-frozen items
                // whether they need to be frozen or not
              } else if (childCache.minMainSize != null &&
                  newSize < childCache.minMainSize!) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment = _subtractNullable(
                  childCache.minMainSize,
                  childCache.mainBasisSize,
                );
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
                      (childCache.mainBasisSize ?? 0.0) /
                      line.totalShrinkFactor);
              // shrinking also applies min/max constraints
              double newSize = _addNullable(
                childCache.mainBasisSize,
                shrinkSize,
              );
              if (childCache.minMainSize != null &&
                  newSize < childCache.minMainSize!) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment = _subtractNullable(
                  childCache.minMainSize,
                  childCache.mainBasisSize,
                );
                childCache.mainBasisSize = childCache.minMainSize;
                childCache.frozen = true;
                line.totalShrinkFactor -=
                    child.layoutData.flexShrink *
                    (childCache.mainBasisSize ?? 0.0);
                line.mainSize += basisSizeAdjustment;
                lineResolved = false;
                availableMainSpace -= basisSizeAdjustment;
                // do not break here yet, lets finish the loop
                // and determine the other non-frozen items
                // whether they need to be frozen or not
              } else if (childCache.maxMainSize != null &&
                  newSize > childCache.maxMainSize!) {
                // convert to non-flexible item
                // and mark as frozen
                double basisSizeAdjustment = _subtractNullable(
                  childCache.maxMainSize,
                  childCache.mainBasisSize,
                );
                childCache.mainBasisSize = childCache.maxMainSize;
                childCache.frozen = true;
                line.totalShrinkFactor -=
                    child.layoutData.flexShrink *
                    (childCache.mainBasisSize ?? 0.0);
                line.mainSize += basisSizeAdjustment;
                lineResolved = false;
                availableMainSpace -= basisSizeAdjustment;
              } else {
                childCache.mainFlexSize = newSize;
              }
            } else {
              childCache.mainFlexSize = childCache.mainBasisSize;
            }
          }

          if (childCache.crossSize != null) {
            biggestLineCrossSize = max(
              biggestLineCrossSize,
              childCache.crossSize!,
            );
          }
          child = child.nextSibling;
        }
        resolveCount++;
        if (lineResolved) {
          // line.crossSize = biggestLineCrossSize;
          double lineCrossSize = biggestLineCrossSize;
          line.crossSize = lineCrossSize;
        }
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
                  parent.textBaseline ?? LayoutTextBaseline.alphabetic,
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

      ({
        double additionalEndSpacing,
        double additionalSpacing,
        double additionalStartSpacing,
      })?
      spacingAdjustment = layout.justifyContent.adjustSpacing(
        parent: parent,
        axis: layout.direction.axis,
        viewportSize: viewportMainSize,
        contentSize: line.mainSize,
        startSpacing: mainSpacingStart,
        endSpacing: mainSpacingEnd,
        spacing: mainSpacing,
        affectedCount: line.itemCount,
      );

      if (spacingAdjustment != null) {
        mainSpacingStart += spacingAdjustment.additionalStartSpacing;
        mainSpacingEnd += spacingAdjustment.additionalEndSpacing;
        mainSpacing += spacingAdjustment.additionalSpacing;
        usedMainSize += spacingAdjustment.additionalStartSpacing;
        usedMainSize += spacingAdjustment.additionalEndSpacing;
        if (line.itemCount > 1) {
          usedMainSize +=
              (line.itemCount - 1) * spacingAdjustment.additionalSpacing;
        }
      }

      line.mainSpacing = mainSpacing;
      line.mainSpacingStart = mainSpacingStart;
      line.mainSpacingEnd = mainSpacingEnd;

      // recompute cross spacing if needed
      double? adjustedCrossSize = layout.alignItems.adjustSize(
        parent: parent,
        axis: switch (layout.direction.axis) {
          LayoutAxis.horizontal => LayoutAxis.vertical,
          LayoutAxis.vertical => LayoutAxis.horizontal,
        },
        viewportSize: switch (layout.direction.axis) {
          LayoutAxis.horizontal => viewportHeight,
          LayoutAxis.vertical => viewportWidth,
        },
        contentSize: stretchLineCrossSize,
      );

      if (adjustedCrossSize != null) {
        line.crossSize = adjustedCrossSize;
      }

      usedMainSize = max(usedMainSize, line.mainSize);
      usedCrossSize += line.crossSize;
      line = line.nextLine;
    }

    if (cache.lineCount > 1) {
      usedCrossSize +=
          crossSpacingStart +
          crossSpacingEnd +
          (cache.lineCount - 1) * crossSpacing;
    } else {
      usedCrossSize += crossSpacingStart + crossSpacingEnd;
    }

    ({
      double additionalEndSpacing,
      double additionalSpacing,
      double additionalStartSpacing,
    })?
    spacingAdjustment = layout.alignContent.adjustSpacing(
      parent: parent,
      axis: layout.direction.axis,
      viewportSize: viewportCrossSize,
      contentSize: usedCrossSize,
      startSpacing: crossSpacingStart,
      endSpacing: crossSpacingEnd,
      spacing: crossSpacing,
      affectedCount: cache.lineCount,
    );

    if (spacingAdjustment != null) {
      crossSpacingStart += spacingAdjustment.additionalStartSpacing;
      crossSpacingEnd += spacingAdjustment.additionalEndSpacing;
      crossSpacing += spacingAdjustment.additionalSpacing;
      usedCrossSize += spacingAdjustment.additionalStartSpacing;
      usedCrossSize += spacingAdjustment.additionalEndSpacing;
      if (cache.lineCount > 1) {
        usedCrossSize +=
            (cache.lineCount - 1) * spacingAdjustment.additionalSpacing;
      }
    }

    cache.crossStartSpacing = crossSpacingStart;
    cache.crossEndSpacing = crossSpacingEnd;
    cache.crossSpacing = crossSpacing;

    return switch (layout.direction.axis) {
      LayoutAxis.horizontal => LayoutSize(
        usedMainSize + mainSpacingStart + mainSpacingEnd,
        usedCrossSize,
      ),
      LayoutAxis.vertical => LayoutSize(
        usedCrossSize,
        usedMainSize + mainSpacingStart + mainSpacingEnd,
      ),
    };
  }

  void debugPrintLines() {
    // print out the line info
    // [hash1, hash2, hash3][hash4, hash5][hash6]
    List<String> lineHashes = [];
    FlexLineLayoutCache? line = cache.firstLine;
    while (line != null) {
      List<String> childHashes = [];
      ChildLayout? child = line.firstChild;
      while (child != null && child != line.lastChild) {
        childHashes.add(child.debugKey.toString());
        child = child.nextSibling;
      }
      lineHashes.add('[${childHashes.join(', ')}]');
      line = line.nextLine;
    }
    // ignore: avoid_print
    print('lines: ${lineHashes.join()}');
  }

  @override
  LayoutRect performPositioning(
    LayoutSize viewportSize,
    LayoutSize contentSize,
  ) {
    // this method is not called during dryLayout!
    // so this method can only do something that does not change the
    // size of the parent!
    // here we positions children, align then, and re-adjust their size (stretch alignment)
    // here we also define the size of absolute children
    // and to finalize things out, we call child.layout here

    LayoutRect bounds = LayoutRect.zero;

    double viewportMainSize = switch (layout.direction.axis) {
      LayoutAxis.horizontal => viewportSize.width,
      LayoutAxis.vertical => viewportSize.height,
    };
    double viewportCrossSize = switch (layout.direction.axis) {
      LayoutAxis.horizontal => viewportSize.height,
      LayoutAxis.vertical => viewportSize.width,
    };
    double contentMainSize = switch (layout.direction.axis) {
      LayoutAxis.horizontal => contentSize.width,
      LayoutAxis.vertical => contentSize.height,
    };
    double contentCrossSize = switch (layout.direction.axis) {
      LayoutAxis.horizontal => contentSize.height,
      LayoutAxis.vertical => contentSize.width,
    };

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
          direction: LayoutAxis.vertical,
        );
      }
      if (data.left != null) {
        leftOffset = data.left!.computePosition(
          parent: parent,
          child: child,
          direction: LayoutAxis.horizontal,
        );
      }
      if (data.right != null) {
        rightOffset = data.right!.computePosition(
          parent: parent,
          child: child,
          direction: LayoutAxis.horizontal,
        );
      }
      if (data.bottom != null) {
        bottomOffset = data.bottom!.computePosition(
          parent: parent,
          child: child,
          direction: LayoutAxis.vertical,
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
        availableHeight = viewportSize.height - topOffset - bottomOffset;
      }
      if (leftOffset != null && rightOffset != null) {
        availableWidth = viewportSize.width - leftOffset - rightOffset;
      }

      if (data.maxWidth != null) {
        maxWidth = data.maxWidth!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: LayoutAxis.horizontal,
          contentSize: availableWidth != null && availableHeight != null
              ? LayoutSize(availableWidth, availableHeight)
              : viewportSize,
          viewportSize: viewportSize,
        );
      }
      if (data.maxHeight != null) {
        maxHeight = data.maxHeight!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: LayoutAxis.vertical,
          contentSize: availableWidth != null && availableHeight != null
              ? LayoutSize(availableWidth, availableHeight)
              : viewportSize,
          viewportSize: viewportSize,
        );
      }
      if (data.minWidth != null) {
        minWidth = data.minWidth!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: LayoutAxis.horizontal,
          contentSize: availableWidth != null && availableHeight != null
              ? LayoutSize(availableWidth, availableHeight)
              : viewportSize,
          viewportSize: viewportSize,
        );
      }
      if (data.minHeight != null) {
        minHeight = data.minHeight!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: LayoutAxis.vertical,
          contentSize: availableWidth != null && availableHeight != null
              ? LayoutSize(availableWidth, availableHeight)
              : viewportSize,
          viewportSize: viewportSize,
        );
      }

      double? preferredWidth;
      double? preferredHeight;
      if (data.width != null) {
        preferredWidth = data.width!.computeSize(
          parent: parent,
          child: child,
          layoutHandle: this,
          axis: LayoutAxis.horizontal,
          contentSize: availableWidth != null && availableHeight != null
              ? LayoutSize(availableWidth, availableHeight)
              : viewportSize,
          viewportSize: viewportSize,
        );
        preferredWidth = _clampNullableDouble(
          preferredWidth,
          minWidth,
          maxWidth,
        );
      } else if (availableWidth != null) {
        preferredWidth = _clampNullableDouble(
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
          axis: LayoutAxis.vertical,
          contentSize: availableWidth != null && availableHeight != null
              ? LayoutSize(availableWidth, availableHeight)
              : viewportSize,
          viewportSize: viewportSize,
        );
        preferredHeight = _clampNullableDouble(
          preferredHeight,
          minHeight,
          maxHeight,
        );
      } else if (availableHeight != null) {
        preferredHeight = _clampNullableDouble(
          availableHeight,
          minHeight,
          maxHeight,
        );
      }

      // handle aspect ratio
      if (aspectRatio != null) {
        if (preferredWidth != null && preferredHeight == null) {
          preferredHeight = preferredWidth / aspectRatio;
          preferredHeight = _clampNullableDouble(
            preferredHeight,
            minHeight,
            maxHeight,
          );
        } else if (preferredHeight != null && preferredWidth == null) {
          preferredWidth = preferredHeight * aspectRatio;
          preferredWidth = _clampNullableDouble(
            preferredWidth,
            minWidth,
            maxWidth,
          );
        }
      }

      // use preferred size to layout the children
      child.layout(
        LayoutConstraints.tightFor(
          width: preferredWidth ?? 0.0,
          height: preferredHeight ?? 0.0,
        ),
      );

      switch (parent.textDirection) {
        case LayoutTextDirection.ltr:
          child.offset = LayoutOffset(
            leftOffset ??
                (rightOffset != null
                    ? viewportSize.width - rightOffset - child.size.width
                    : 0.0),
            topOffset ??
                (bottomOffset != null
                    ? viewportSize.height - bottomOffset - child.size.height
                    : 0.0),
          );
        case LayoutTextDirection.rtl:
          child.offset = LayoutOffset(
            rightOffset != null
                ? viewportSize.width - rightOffset - child.size.width
                : (leftOffset ?? 0.0),
            topOffset ??
                (bottomOffset != null
                    ? viewportSize.height - bottomOffset - child.size.height
                    : 0.0),
          );
      }

      LayoutRect childBounds = child.offset & child.size;
      bounds = bounds.expandToInclude(childBounds);

      child = child.nextSibling;
    }

    // positions non-absolute children
    bool reverseWrap = layout.wrap == FlexWrap.wrapReverse;

    bool reverseMain = false;
    bool reverseCross = false;
    if (layout.direction.reverse) {
      reverseMain = !reverseMain;
    }
    if (layout.direction.axis == LayoutAxis.horizontal &&
        parent.textDirection == LayoutTextDirection.rtl) {
      reverseMain = !reverseMain;
    }
    if (reverseWrap) {
      reverseCross = !reverseCross;
    }
    if (layout.direction.axis == LayoutAxis.vertical &&
        parent.textDirection == LayoutTextDirection.rtl) {
      reverseCross = !reverseCross;
    }

    double crossContentOffset = reverseCross
        ? contentCrossSize - cache.crossEndSpacing
        : cache.crossStartSpacing;
    final alignItemsNeedsBaseline = layout.alignItems.needsBaseline(
      parent: parent,
      axis: switch (layout.direction.axis) {
        LayoutAxis.horizontal => LayoutAxis.vertical,
        LayoutAxis.vertical => LayoutAxis.horizontal,
      },
    );
    bool isWrapped = cache.lineCount > 1;
    if (isWrapped) {
      double alignContent = layout.alignContent.align(
        parent: parent,
        axis: switch (layout.direction.axis) {
          LayoutAxis.horizontal => LayoutAxis.vertical,
          LayoutAxis.vertical => LayoutAxis.horizontal,
        },
        viewportSize: viewportCrossSize,
        contentSize: contentCrossSize,
        // align content does not need baseline
        maxBaseline: 0.0,
        childBaseline: 0.0,
      );
      crossContentOffset += alignContent;
    }
    FlexLineLayoutCache? line = cache.firstLine;
    while (line != null) {
      double mainLineOffset = reverseMain
          ? contentMainSize - line.mainSpacingEnd
          : line.mainSpacingStart;

      final justifyContent = layout.justifyContent.align(
        parent: parent,
        axis: layout.direction.axis,
        viewportSize: viewportMainSize,
        contentSize: line.mainSize,
        // justify content does not need baseline
        maxBaseline: 0.0,
        childBaseline: 0.0,
      );

      mainLineOffset += justifyContent;

      if (reverseCross) {
        // subtract right away
        crossContentOffset -= line.crossSize;
        if (line != cache.firstLine) {
          crossContentOffset -= cache.crossSpacing;
        }
      }

      ChildLayout? child = line.firstChild;
      int childIndex = 0;
      while (child != null && child != line.lastChild) {
        // handled separately
        if (child.layoutData.behavior == LayoutBehavior.absolute) {
          child = child.nextSibling;
          continue;
        }

        final childCache = child.layoutCache as FlexChildLayoutCache;

        if (reverseMain) {
          // subtract right away
          mainLineOffset -= childCache.mainFlexSize ?? 0.0;
        } else {
          if (childIndex > 0) {
            mainLineOffset += line.mainSpacing;
          }
        }

        double mainOffset = mainLineOffset;
        double crossOffset = crossContentOffset;

        bool? alignSelfNeedsBaseline = childCache.alignSelfNeedsBaseline;
        // note:
        // alignSelf - acts as override to alignItems
        // alignItems - aligns all items in the line
        // alignContent - aligns all lines in the container

        double? alignSelf = child.layoutData.alignSelf?.align(
          parent: parent,
          axis: switch (layout.direction.axis) {
            LayoutAxis.horizontal => LayoutAxis.vertical,
            LayoutAxis.vertical => LayoutAxis.horizontal,
          },
          viewportSize: isWrapped
              ? line.crossSize
              : max(contentCrossSize, viewportCrossSize),
          contentSize: childCache.crossSize ?? 0.0,
          // align self does not need baseline
          maxBaseline: line.biggestBaseline,
          childBaseline: alignSelfNeedsBaseline == true
              ? childCache.baseline! // should be non-null here
              // because we computed it earlier
              : 0.0,
        );

        alignSelf ??= layout.alignItems.align(
          parent: parent,
          axis: switch (layout.direction.axis) {
            LayoutAxis.horizontal => LayoutAxis.vertical,
            LayoutAxis.vertical => LayoutAxis.horizontal,
          },
          viewportSize: isWrapped
              ? line.crossSize
              : max(contentCrossSize, viewportCrossSize),
          contentSize: childCache.crossSize ?? 0.0,
          maxBaseline: line.biggestBaseline,
          childBaseline: alignItemsNeedsBaseline
              ? childCache.baseline! // should be non-null here
              // because we computed it earlier
              : 0.0,
        );

        if (childCache.crossSize == null) {
          double? adjustCrossSize;

          if (isWrapped) {
            adjustCrossSize = child.layoutData.alignSelf?.adjustSize(
              parent: parent,
              axis: switch (layout.direction.axis) {
                LayoutAxis.horizontal => LayoutAxis.vertical,
                LayoutAxis.vertical => LayoutAxis.horizontal,
              },
              viewportSize: max(contentCrossSize, viewportCrossSize),
              contentSize: line.crossSize,
            );

            adjustCrossSize ??= layout.alignItems.adjustSize(
              parent: parent,
              axis: switch (layout.direction.axis) {
                LayoutAxis.horizontal => LayoutAxis.vertical,
                LayoutAxis.vertical => LayoutAxis.horizontal,
              },
              viewportSize: max(contentCrossSize, viewportCrossSize),
              contentSize: line.crossSize,
            );
          } else {
            adjustCrossSize = layout.alignItems.adjustSize(
              parent: parent,
              axis: switch (layout.direction.axis) {
                LayoutAxis.horizontal => LayoutAxis.vertical,
                LayoutAxis.vertical => LayoutAxis.horizontal,
              },
              viewportSize: max(contentCrossSize, viewportCrossSize),
              contentSize: contentCrossSize,
            );
          }

          if (adjustCrossSize != null) {
            childCache.crossSize = adjustCrossSize;
          }
        }

        double dx = switch (layout.direction.axis) {
          LayoutAxis.horizontal => mainOffset,
          LayoutAxis.vertical => crossOffset + alignSelf,
        };
        double dy = switch (layout.direction.axis) {
          LayoutAxis.horizontal => crossOffset + alignSelf,
          LayoutAxis.vertical => mainOffset,
        };

        // apply scroll offset
        dx -= parent.scrollOffsetX;
        dy -= parent.scrollOffsetY;

        // apply sticky adjustment
        LayoutRect contentRect = LayoutRect.fromLTWH(
          dx,
          dy,
          childCache.mainFlexSize ?? 0.0,
          childCache.crossSize ?? 0.0,
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
            direction: LayoutAxis.vertical,
          );
        } else {
          topBound = double.negativeInfinity;
        }
        if (child.layoutData.left != null) {
          leftBound = child.layoutData.left!.computePosition(
            parent: parent,
            child: child,
            direction: LayoutAxis.horizontal,
          );
        } else {
          leftBound = double.negativeInfinity;
        }
        if (child.layoutData.right != null) {
          rightBound =
              viewportSize.width -
              child.layoutData.right!.computePosition(
                parent: parent,
                child: child,
                direction: LayoutAxis.horizontal,
              );
        } else {
          rightBound = double.infinity;
        }
        if (child.layoutData.bottom != null) {
          bottomBound =
              viewportSize.height -
              child.layoutData.bottom!.computePosition(
                parent: parent,
                child: child,
                direction: LayoutAxis.vertical,
              );
        } else {
          bottomBound = double.infinity;
        }
        LayoutRect limitBounds = LayoutRect.fromLTRB(
          leftBound,
          topBound,
          rightBound,
          bottomBound,
        );
        LayoutOffset boundOffset = _limitRectToBounds(contentRect, limitBounds);
        dx = boundOffset.dx;
        dy = boundOffset.dy;

        child.offset = LayoutOffset(dx, dy);

        child.layout(
          switch (layout.direction.axis) {
            LayoutAxis.horizontal => LayoutConstraints.tightFor(
              width: childCache.mainFlexSize ?? 0.0,
              height: childCache.crossSize ?? 0.0,
            ),
            LayoutAxis.vertical => LayoutConstraints.tightFor(
              width: childCache.crossSize ?? 0.0,
              height: childCache.mainFlexSize ?? 0.0,
            ),
          },
        );

        LayoutRect childBounds = child.offset & child.size;
        bounds = bounds.expandToInclude(childBounds);

        if (!reverseMain) {
          mainLineOffset += childCache.mainFlexSize ?? 0.0;
        } else {
          if (childIndex > 0) {
            mainLineOffset -= line.mainSpacing;
          }
        }

        child.clearCache();

        child = child.nextSibling;
        childIndex++;
      }

      if (!reverseCross) {
        if (line == cache.firstLine) {
          crossContentOffset += cache.crossSpacing;
        }
        crossContentOffset += line.crossSize;
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

LayoutOffset _limitRectToBounds(LayoutRect content, LayoutRect bounds) {
  // used to determine sticky position, so that it does not exceed the bounds
  double newLeft = content.left;
  double newTop = content.top;
  if (content.left < bounds.left) {
    newLeft = bounds.left;
  }
  if (content.top < bounds.top) {
    newTop = bounds.top;
  }
  if (content.right > bounds.right) {
    newLeft = bounds.right - content.width;
  }
  if (content.bottom > bounds.bottom) {
    newTop = bounds.bottom - content.height;
  }
  return LayoutOffset(newLeft, newTop);
}

double _addNullable(double? a, double? b) {
  a ??= 0.0;
  b ??= 0.0;
  return a + b;
}

double _subtractNullable(double? a, double? b) {
  a ??= 0.0;
  b ??= 0.0;
  return a - b;
}

double? _clampNullableDouble(double? value, double? min, double? max) {
  if (value == null) return null;
  if (min != null && value < min) {
    return min;
  }
  if (max != null && value > max) {
    return max;
  }
  return value;
}
