import 'dart:math';

import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';

/// Cache for storing computed layout values for individual flex children.
///
/// FlexChildLayoutCache extends the base [ChildLayoutCache] with flex-specific
/// caching for basis sizes, flex calculations, cross-axis sizing, and baseline
/// alignment. This cache is used to avoid redundant calculations during
/// the complex flex layout algorithm.
class FlexChildLayoutCache extends ChildLayoutCache {
  /// Cache for the flex line this child belongs to.
  ///
  /// Used to coordinate layout between children in the same flex line.
  FlexLineLayoutCache? lineCache;

  /// The main-axis basis size for this child.
  ///
  /// Represents the initial size before flex grow/shrink calculations.
  double? mainBasisSize;

  /// The final main-axis size after flex calculations.
  ///
  /// Includes both the basis size and any flex grow/shrink adjustments.
  double? mainFlexSize;

  /// The cross-axis size for this child.
  ///
  /// Determined during cross-axis alignment and sizing calculations.
  double? crossSize;

  /// Maximum main-axis size constraint for this child.
  double? maxMainSize;

  /// Minimum main-axis size constraint for this child.
  double? minMainSize;

  /// Maximum cross-axis size constraint for this child.
  double? maxCrossSize;

  /// Minimum cross-axis size constraint for this child.
  double? minCrossSize;

  /// Whether this child's main-axis size is frozen (cannot be changed).
  ///
  /// Used during the flex algorithm to prevent infinite loops.
  bool frozen = false;

  /// Whether this child's cross-axis size is frozen.
  bool frozenCross = false;

  /// The baseline position for this child (if applicable).
  ///
  /// Used for baseline alignment in flex lines.
  double? baseline;

  /// Whether this child's alignSelf setting requires baseline calculation.
  bool? alignSelfNeedsBaseline;

  /// Creates a new cache for a flex child.
  FlexChildLayoutCache();
}

/// A layout algorithm implementing the CSS Flexbox specification.
///
/// FlexLayout provides a complete implementation of the flexbox layout model,
/// supporting all major flexbox features including direction, wrapping,
/// alignment, spacing, and flexible sizing. It follows the CSS Flexbox
/// specification closely while being optimized for Flutter's layout system.
///
/// ## Key Features
///
/// - **Direction**: Row, column, and reverse variants
/// - **Wrapping**: Single line or multi-line with wrap/nowrap options
/// - **Alignment**: Main-axis (justify-content), cross-axis (align-items), and line alignment (align-content)
/// - **Flexible Sizing**: Flex grow and shrink with basis sizing
/// - **Spacing**: Configurable gaps between items and padding
/// - **RTL Support**: Automatic handling of right-to-left text directions
///
/// ## Usage
///
/// FlexLayout is typically used through [FlexBox] widget, but can be used
/// directly with [LayoutBox] for custom implementations:
///
/// ```dart
/// LayoutBox(
///   layout: FlexLayout(
///     direction: FlexDirection.row,
///     wrap: FlexWrap.wrap,
///     alignItems: BoxAlignment.center,
///     justifyContent: BoxAlignment.spaceBetween,
///   ),
///   children: [/* flex items */],
/// )
/// ```
class FlexLayout extends Layout {
  /// The direction of the main axis for this flex layout.
  ///
  /// Determines whether children flow horizontally (row) or vertically (column).
  /// Also controls the direction of flow with reverse options.
  final FlexDirection direction;

  /// Controls how flex items wrap when they exceed the container's size.
  ///
  /// - [FlexWrap.none]: Single line layout
  /// - [FlexWrap.wrap]: Multi-line layout with normal line order
  /// - [FlexWrap.wrapReverse]: Multi-line layout with reversed line order
  final FlexWrap wrap;

  /// The maximum number of items allowed per line when wrapping is enabled.
  ///
  /// When set, forces line breaks after this many items, regardless of space.
  /// Useful for creating grid-like layouts with consistent item counts per row.
  final int? maxItemsPerLine;

  /// The maximum number of lines allowed when wrapping is enabled.
  ///
  /// Limits the total number of lines in the layout. Items exceeding this
  /// limit may be hidden or handled according to overflow settings.
  final int? maxLines;

  /// The padding applied inside the flex container.
  ///
  /// Adds space between the container's edges and the flex content.
  /// Uses [EdgeSpacing] for responsive padding values.
  final EdgeSpacing padding;

  /// The horizontal spacing between adjacent flex items.
  ///
  /// Applied between items in the main axis direction when flowing horizontally,
  /// or between lines when flowing vertically and wrapping.
  final SpacingUnit horizontalSpacing;

  /// The vertical spacing between adjacent flex items.
  ///
  /// Applied between items in the main axis direction when flowing vertically,
  /// or between lines when flowing horizontally and wrapping.
  final SpacingUnit verticalSpacing;

  /// The default cross-axis alignment for all items.
  ///
  /// Controls how items are positioned along the cross axis when they don't
  /// fill the available space. Individual items can override this with their
  /// alignSelf property. Supports baseline alignment for text elements.
  final BoxAlignmentGeometry alignItems;

  /// The cross-axis alignment for flex lines when wrapping is enabled.
  ///
  /// Controls how multiple lines are distributed along the cross axis when
  /// there is extra space. Only applies when [wrap] is not [FlexWrap.none].
  /// Does not support baseline alignment (unlike [alignItems]).
  final BoxAlignmentContent alignContent;

  /// The main-axis alignment for items within each flex line.
  ///
  /// Controls how items are distributed along the main axis within their line.
  /// Does not support baseline or stretch alignment (unlike [alignItems]).
  final BoxAlignmentBase justifyContent;

  /// Creates a flex layout with the specified configuration.
  ///
  /// All parameters are optional with sensible defaults for a basic horizontal layout.
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

  /// Creates a layout handle for performing flex layout operations.
  ///
  /// Returns a [FlexLayoutHandle] that encapsulates the flex algorithm
  /// and provides methods for laying out children according to flex rules.
  @override
  LayoutHandle createLayoutHandle(ParentLayout parent) {
    return FlexLayoutHandle(this, parent);
  }
}

/// Cache for storing computed layout values for an entire flex layout.
///
/// FlexLayoutCache manages caching for the complete flex layout operation,
/// including line management, spacing calculations, and line distribution.
/// This cache is reused across layout passes to improve performance.
class FlexLayoutCache {
  /// The first flex line in the layout.
  FlexLineLayoutCache? firstLine;

  /// The last flex line in the layout.
  FlexLineLayoutCache? lastLine;

  /// Spacing before the first line in the cross axis.
  double crossStartSpacing = 0.0;

  /// Spacing after the last line in the cross axis.
  double crossEndSpacing = 0.0;

  /// Spacing between lines in the cross axis.
  double crossSpacing = 0.0;

  /// The total number of lines in the layout.
  int lineCount = 0;

  /// Allocates and returns a new flex line cache.
  ///
  /// Creates a new line, assigns it an index, and links it into the line chain.
  /// Ensures that the previous line (if any) has at least one child.
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

/// Cache for storing computed layout values for a single flex line.
///
/// FlexLineLayoutCache manages caching for individual lines within a flex layout.
/// Each line contains multiple children and has its own sizing and alignment calculations.
/// This cache tracks the line's dimensions, flex factors, and child count.
class FlexLineLayoutCache {
  /// The index of this line within the layout (0-based).
  int lineIndex = 0;

  /// The total main-axis size of this line.
  double mainSize = 0.0;

  /// The total cross-axis size of this line.
  double crossSize = 0.0;

  /// The sum of all flexGrow factors for children in this line.
  double totalFlexGrow = 0.0;

  /// The number of children in this line.
  int itemCount = 0;

  /// The sum of all flexShrink factors for children in this line.
  double totalShrinkFactor = 0.0;

  /// The amount of main-axis spacing used between items in this line.
  double usedMainSpacing = 0.0;

  /// Spacing before the first item in the main axis.
  double mainSpacingStart = 0.0;

  /// Spacing after the last item in the main axis.
  double mainSpacingEnd = 0.0;

  /// Spacing between items in the main axis.
  double mainSpacing = 0.0;

  /// The largest baseline value among children that need baseline alignment.
  double biggestBaseline = 0.0;

  /// The first child in this line.
  ChildLayout? firstChild;

  /// The last child in this line.
  ChildLayout? lastChild;

  /// The previous line in the layout.
  FlexLineLayoutCache? previousLine;

  /// The next line in the layout.
  FlexLineLayoutCache? nextLine;

  /// Returns the number of children in this line for debugging purposes.
  ///
  /// Traverses the child linked list to count items. Only used in assertions.
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

/// Handle for performing flex layout operations.
///
/// FlexLayoutHandle implements the complete CSS Flexbox layout algorithm.
/// It manages the complex multi-pass layout process including:
///
/// 1. **Line Breaking**: Distributing children into flex lines
/// 2. **Main Axis Sizing**: Calculating sizes along the main axis with flex grow/shrink
/// 3. **Cross Axis Sizing**: Calculating sizes along the cross axis
/// 4. **Alignment**: Positioning items within lines and lines within the container
/// 5. **Spacing**: Applying gaps between items and padding
///
/// The algorithm follows the CSS Flexbox specification closely, with optimizations
/// for Flutter's layout system and support for RTL text directions.
class FlexLayoutHandle extends LayoutHandle<FlexLayout> {
  /// Creates a flex layout handle for the given layout and parent.
  FlexLayoutHandle(super.layout, super.parent);

  /// The layout cache for this flex operation.
  ///
  /// Only available after a full layout pass (not dry layout).
  /// Contains cached values for lines, spacing, and sizing calculations.
  FlexLayoutCache? _cache;

  FlexLayoutCache get cache {
    assert(
      _cache != null,
      'cache is only available after layout (not dry layout)',
    );
    return _cache!;
  }

  /// Performs the complete flex layout algorithm.
  ///
  /// This method implements the multi-pass CSS Flexbox layout algorithm:
  ///
  /// 1. **Initialization**: Sets up viewport constraints and spacing calculations
  /// 2. **Line Breaking**: Distributes children into flex lines based on wrapping rules
  /// 3. **Main Axis Sizing**: Calculates flex grow/shrink for each line
  /// 4. **Cross Axis Sizing**: Determines cross-axis sizes and alignment
  /// 5. **Positioning**: Places children and lines within the container
  ///
  /// When [dry] is true, performs measurement without modifying child positions.
  /// Absolute-positioned children are handled separately and don't affect sizing.
  ///
  /// Returns the total size needed for the layout content.
  @override
  LayoutSize performLayout(LayoutConstraints constraints, [bool dry = false]) {
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

  /// Calculates the positioning rectangle for content within the viewport.
  ///
  /// This method determines how the flex content should be positioned within
  /// the available viewport space, taking into account scrolling offsets and
  /// content size. It handles the final positioning phase of flex layout.
  ///
  /// The returned rectangle defines the bounds of the visible content area
  /// and is used for scrolling calculations and viewport management.
  @override
  LayoutRect performPositioning(
    LayoutSize viewportSize,
    LayoutSize contentSize,
  ) {
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

  /// Creates a new cache instance for flex child layout operations.
  ///
  /// Returns a [FlexChildLayoutCache] configured for storing flex-specific
  /// layout calculations including basis sizes, flex factors, and alignment data.
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
