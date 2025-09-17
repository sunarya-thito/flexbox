import 'dart:math';

import 'package:flexiblebox/flexiblebox.dart';
import 'package:flutter/widgets.dart';

mixin FlexChildData {
  bool get isAbsolute;

  // Resolved flex properties
  double flexBasis = 0.0;
  double? get flexGrow;
  double? get flexShrink;
  double? additionalFlexBasis;
  double crossFlexBasis = 0.0;
  double? additionalCrossFlexBasis;

  // constraint
  double? minMainSize;
  double? maxMainSize;
  double? minCrossSize;
  double? maxCrossSize;

  /// The total of the need for biggest main flex count
  /// which later be used to determine the total flex.
  double? biggestMainFlexCount;

  /// The total of the need for smallest main flex count
  /// which later be used to determine the total flex.
  double? smallestMainFlexCount;

  double getFlexBasis(bool mainAxis) => mainAxis ? flexBasis : crossFlexBasis;
  double? getAdditionalFlexBasis(bool mainAxis) =>
      mainAxis ? additionalFlexBasis : additionalCrossFlexBasis;
  double getFlexBasisWithAdditional(bool mainAxis) =>
      getFlexBasis(mainAxis) + (getAdditionalFlexBasis(mainAxis) ?? 0.0);

  // end of resolved flex properties

  // these fields must be set during [computeLayout]
  double? flexSize;
  double? crossFlexSize;
  // end of layout results

  /// Unless for reset purpose (on flex-shrink), this field should only be set
  /// by the BoxValue that computes the flex size.
  /// This can be set during [computeFlexBasis]
  /// when the flex basis it self already violates the min/max constraint,
  /// or during [computeFlex] when the new computed size (after flex grow/shrink)
  /// violates the min/max constraint.
  bool frozen = false;

  FlexChild? get nextFlexChild;
  FlexChild? get previousFlexChild;

  /// If flex wrap is enabled, this indicates the line number of this child.
  int? line;

  /// Returns true if it requires additional layout pass.
  bool computeFlexBasis({
    required FlexParent parent,
    required FlexChild child,
  });

  bool computeFlex({
    required FlexParent parent,
    required FlexChild child,
  });
  void computeAdditionalFlexBasis({
    required FlexParent parent,
    required FlexChild child,
  });
  bool computePostFlex({
    required FlexParent parent,
    required FlexChild child,
  });
  void computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  });
  double get computedMainSize =>
      flexBasis + (flexSize ?? 0.0) + (additionalFlexBasis ?? 0.0);
  double get computedCrossSize =>
      crossFlexBasis +
      (crossFlexSize ?? 0.0) +
      (additionalCrossFlexBasis ?? 0.0);
  double mainOffset = 0.0;
  double crossOffset = 0.0;

  void computePosition({
    required FlexParent parent,
    required FlexChild child,
    required double previousMainOffset,
  });

  void reset() {
    flexBasis = 0.0;
    flexSize = null;
    crossFlexBasis = 0.0;
    crossFlexSize = null;
    biggestMainFlexCount = null;
    smallestMainFlexCount = null;
    frozen = false;
    mainOffset = 0.0;
    crossOffset = 0.0;
  }
}

mixin FlexChild {
  FlexChildData get data;
  double computeIntrinsic(Axis direction, double extent, bool min);
  Size get size;
}

mixin FlexParent {
  FlexChild? firstFlexChild;
  Axis get direction;
  Axis get crossDirection =>
      direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
  Axis getDirection(bool mainAxis) => mainAxis ? direction : crossDirection;

  /// Number of absolute children in the main axis.
  /// This value is available after [computeFlexLayout] is called.
  double absoluteChildCount = 0;

  /// Content size of all non-absolute children in the main axis.
  /// This value is available after [computeFlexLayout] is called.
  double contentMainSize = 0.0;
  List<double>? wrapContentMainSizes = [];

  /// Content size of all non-absolute children in the cross axis.
  /// This value is available after [computeFlexLayout] is called.
  double contentCrossSize = 0.0;
  List<double>? wrapContentCrossSizes;

  double getContentSize(bool mainAxis) =>
      mainAxis ? contentMainSize : contentCrossSize;

  double getLineContentSize(bool mainAxis, [int? line]) => mainAxis
      ? wrapContentMainSizes![line ?? 0]
      : wrapContentCrossSizes![line ?? 0];

  /// The size per flex unit in the main axis.
  /// This value is available after [computeFlexLayout] is called.
  List<double> mainFlexFactors = [];

  /// Flex factor is the size per flex unit.
  double getFlexFactor([int? line]) => mainFlexFactors[line ?? 0];

  /// The total flex grow value in the main axis.
  /// This value is available after [computeFlexLayout] is called.
  List<double?> shrinkFactors = [];
  double? getShrinkFactor([int? line]) => shrinkFactors[line ?? 0];

  /// The size of the viewport in the main axis.
  double get viewportMainSize;

  /// The size of the viewport in the cross axis.
  double get viewportCrossSize;

  bool get enableWrap;

  /// Whether the main axis is reversed.
  /// When reversed, the first child will be placed at the end of the main axis,
  /// and the last child will be placed at the start of the main axis.
  /// This only applies to non-absolute children.
  bool get reverseMainAxis;

  /// Whether the cross axis is reversed.
  /// When reversed, the first line will be placed at the end of the cross axis,
  /// and the last line will be placed at the start of the cross axis.
  /// This only applies to non-absolute children.
  bool get reverseCrossAxis;

  int get childCount;
  void computeFlexLayout({
    FlexChild? spacingStart,
    FlexChild? spacing,
    FlexChild? spacingEnd,
    // TODO: add run spacing
    FlexChild? runSpacingStart,
    FlexChild? runSpacing,
    FlexChild? runSpacingEnd,
  }) {
    if (childCount == 0) {
      contentMainSize = 0.0;
      contentCrossSize = 0.0;
      absoluteChildCount = 0;
      return;
    }
    // flex-wrap sizes
    // where 0 is the base line
    //
    // these are the same as mainContentSize and crossContentSize
    List<double> usedMainSizes = [];
    List<double> usedCrossSizes = [];
    //
    List<double> mainFlexFactors = [];
    List<double> shrinkFactors = [];

    wrapContentMainSizes = usedMainSizes;
    wrapContentCrossSizes = usedCrossSizes;
    this.shrinkFactors = shrinkFactors;
    this.mainFlexFactors = mainFlexFactors;

    /// resolve flex factor for a specific line.
    /// If [line] is null, it means run for all lines
    /// that has not been wrapped yet.
    /// If a line-wrap happens, this method should be called
    /// for the previous/wrapped line first, following
    /// a recomputation of its flex sizes (if needed),
    /// after that,
    void resolveFlexFactors([
      int? line,
      FlexChild? firstChild,
      bool forward = true,
    ]) {
      FlexChild? child = firstChild ?? firstFlexChild;

      double? usedMainSize;
      double? usedCrossSize;
      double? totalMainFlexGrow;
      int absoluteChildCount = 0;
      double? shrinkFactor;
      bool computeAdditionalFlexBasis = false;
      while (child != null) {
        final data = child.data;
        if (data.line != line) {
          child = data.nextFlexChild;
          continue;
        }
        data.reset();
        if (data.isAbsolute) {
          absoluteChildCount++;
          // absolute children MUST NOT
          // contribute to flex grow/shrink
          // or flex basis. We will layout them in the [computeLayout],
          // after knowing the content size.
          child = data.nextFlexChild;
          continue;
        }
        final result = data.computeFlexBasis(parent: this, child: child);
        computeAdditionalFlexBasis |= result;
        totalMainFlexGrow = _addNullableDouble(
          totalMainFlexGrow,
          data.flexGrow,
        );
        usedMainSize = _addNullableDouble(usedMainSize, data.flexBasis);
        usedCrossSize = _maxNullableDouble(
          usedCrossSize,
          data.crossFlexBasis,
        );
        double childShrinkFactor =
            data.flexShrink != null && data.flexShrink! > 0
            ? data.flexBasis * data.flexShrink!
            : 0.0;
        shrinkFactor = _addNullableDouble(shrinkFactor, childShrinkFactor);
        if (forward) {
          child = data.nextFlexChild;
        } else {
          child = data.previousFlexChild;
        }
      }
      // resolve flex for spacing
      // note: spacing does not have cross-axis properties
      void resolveSpacing(FlexChild? spacing, [int count = 1]) {
        if (spacing != null) {
          final data = spacing.data;
          data.reset();
          final result = data.computeFlexBasis(parent: this, child: spacing);
          computeAdditionalFlexBasis |= result;
          double? flexGrow = data.flexGrow != null
              ? data.flexGrow! * count
              : null;
          totalMainFlexGrow = _addNullableDouble(totalMainFlexGrow, flexGrow);
          usedMainSize = _addNullableDouble(
            usedMainSize,
            data.flexBasis * count,
          );
          double? spacingShrinkFactor =
              data.flexShrink != null && data.flexShrink! > 0
              ? data.flexBasis * data.flexShrink!
              : 0.0;
          shrinkFactor = _addNullableDouble(
            shrinkFactor,
            spacingShrinkFactor * count,
          );
        }
      }

      resolveSpacing(spacingStart);
      resolveSpacing(spacing, absoluteChildCount - 1);
      resolveSpacing(spacingEnd);

      line ??= usedMainSizes.length - 1; // if line is null, use the last line
      usedMainSize ??= 0.0;
      usedCrossSize ??= 0.0;
      usedMainSizes.ensureAndSet(line, usedMainSize!);
      usedCrossSizes.ensureAndSet(line, usedCrossSize);

      // we run additional flex basis computation here
      if (computeAdditionalFlexBasis) {
        child = firstChild ?? firstFlexChild;
        while (child != null) {
          final data = child.data;
          if (data.line != line) {
            child = data.nextFlexChild;
            continue;
          }
          if (data.isAbsolute) {
            child = data.nextFlexChild;
            continue;
          }
          data.computeAdditionalFlexBasis(
            parent: this,
            child: child,
          );
          usedMainSize = _addNullableDouble(
            usedMainSize,
            data.additionalFlexBasis,
          );
          if (data.additionalCrossFlexBasis != null) {
            usedCrossSize = _maxNullableDouble(
              usedCrossSize,
              data.crossFlexBasis + data.additionalCrossFlexBasis!,
            );
          }
          child = data.nextFlexChild;
        }

        void resolveAdditionalSpacing(FlexChild? spacing, [int count = 1]) {
          if (spacing != null) {
            final data = spacing.data;
            data.computeAdditionalFlexBasis(
              parent: this,
              child: spacing,
            );
            usedMainSize = _addNullableDouble(
              usedMainSize,
              data.additionalFlexBasis != null
                  ? data.additionalFlexBasis! * count
                  : null,
            );
          }
        }

        resolveAdditionalSpacing(spacingStart);
        resolveAdditionalSpacing(spacing, absoluteChildCount - 1);
        resolveAdditionalSpacing(spacingEnd);
      }

      totalMainFlexGrow ??= 0.0;
      double mainRemainingSize = (viewportMainSize - usedMainSize!).clamp(
        0.0,
        double.infinity,
      );
      double flexFactor = totalMainFlexGrow! > 0
          ? mainRemainingSize / totalMainFlexGrow!
          : 0.0;
      mainFlexFactors.ensureAndSet(line, flexFactor);
      shrinkFactors.ensureAndSet(line, shrinkFactor ?? 0.0);
    }

    // first resolve flex factors for base line (null)
    resolveFlexFactors();

    void performLayout([int? line]) {
      bool hasNotResolved = true;
      int passCount = 0;
      bool computePostLayout = false;
      while (hasNotResolved && passCount < maxPassCount) {
        hasNotResolved = false;
        double usedMainSize = usedMainSizes[line ?? 0]; // all the flex basis
        double usedCrossSize =
            usedCrossSizes[line ?? 0]; // max of cross flex basis
        double usedMainFlexSize = 0;
        double usedCrossFlexSize = usedCrossSize;
        computePostLayout = false;
        FlexChild? child = firstFlexChild;
        while (child != null) {
          final data = child.data;

          if (data.line != line) {
            child = data.nextFlexChild;
            continue;
          }

          if (data.frozen) {
            child = data.nextFlexChild;
            continue;
          }

          bool needsAnotherPass = data.computeFlex(
            parent: this,
            child: child,
          );

          if (needsAnotherPass) {
            hasNotResolved = true;
          } else {
            double totalMainSize =
                usedMainSize + usedMainFlexSize + (data.flexSize ?? 0.0);
            if (enableWrap && totalMainSize > viewportMainSize) {
              assert(
                line == null,
                'Wrapping should be done in the line that has not been wrapped yet',
              );
              line = usedMainSizes.length - 1;
              // start from previous because current child
              // already exceed the viewport size
              FlexChild? wrapChild = child.data.previousFlexChild;
              // assign line to this child and all previous children until
              // we reach a child that already has line assigned
              while (wrapChild != null) {
                final wrapData = wrapChild.data;
                if (wrapData.line != null) {
                  // already wrapped, stop here
                  break;
                }
                wrapData.line ??= line;
                wrapChild = wrapData.previousFlexChild;
              }
              // re resolve flex factor for the current line
              // starting from the child before the child that
              // exceeds the viewport size, and goes backwards
              // until we reach a child that already has line assigned
              resolveFlexFactors(
                line,
                child.data.previousFlexChild,
                false,
              );
              // then resolve flex factor for the next line
              // starting from the child that exceeds the viewport size
              // and goes forward until the end (should be until the end)
              resolveFlexFactors(line + 1, child, true);
              // re-perform layout for the current line
              // then perform layout for the new line
              performLayout();
              // the new line's children does not have line assigned yet
              // so we set the param to null to indicate that we want to perform layout
              // for all children that has not been wrapped yet
              hasNotResolved = true;
              break;
            } else {
              usedMainFlexSize += data.flexSize ?? 0.0;
              // need to update cross flex size here
              // to ensure the final cross size is correct
              usedCrossFlexSize = max(
                usedCrossFlexSize,
                data.crossFlexSize ?? 0.0,
              );
            }
            final postFlexResult = data.computePostFlex(
              parent: this,
              child: child,
            );
            computePostLayout |= postFlexResult;
          }

          child = data.nextFlexChild;
        }

        if (!hasNotResolved) {
          // update the used sizes when everything is resolved
          usedMainSizes[line ?? 0] = usedMainSize + usedMainFlexSize;
          usedCrossSizes[line ?? 0] = max(usedCrossSize, usedCrossFlexSize);
        }

        passCount++;
      }

      if (computePostLayout) {
        FlexChild? child = firstFlexChild;
        while (child != null) {
          final data = child.data;
          if (data.line != line) {
            child = data.nextFlexChild;
            continue;
          }
          if (data.isAbsolute) {
            child = data.nextFlexChild;
            continue;
          }
          data.computePostLayout(parent: this, child: child);
          child = data.nextFlexChild;
        }
      }
    }

    // perform layout for base line (null)
    performLayout();
  }
}

const maxPassCount = 10;

extension _FlexLineDoubleExtensions on List<double> {
  void ensureAndSet(int index, double value) {
    while (length <= index) {
      add(0.0);
    }
    this[index] = value;
  }
}

double? _addNullableDouble(double? a, double? b) {
  if (a == null && b == null) {
    return null;
  } else {
    return (a ?? 0.0) + (b ?? 0.0);
  }
}

double? _maxNullableDouble(double? a, double? b) {
  if (a == null && b == null) {
    return null;
  } else if (a == null) {
    return b;
  } else if (b == null) {
    return a;
  } else {
    return a > b ? a : b;
  }
}

double? _minNullableDouble(double? a, double? b) {
  if (a == null && b == null) {
    return null;
  } else if (a == null) {
    return b;
  } else if (b == null) {
    return a;
  } else {
    return a < b ? a : b;
  }
}

class RenderBoxFlexChild with FlexChild {
  final RenderBox renderBox;

  RenderBoxFlexChild(this.renderBox);

  @override
  double computeIntrinsic(Axis direction, double extent, bool min) {
    return switch ((direction, min)) {
      (Axis.horizontal, true) => renderBox.getMinIntrinsicWidth(extent),
      (Axis.horizontal, false) => renderBox.getMaxIntrinsicWidth(extent),
      (Axis.vertical, true) => renderBox.getMinIntrinsicHeight(extent),
      (Axis.vertical, false) => renderBox.getMaxIntrinsicHeight(extent),
    };
  }

  @override
  Size get size => renderBox.size;

  @override
  FlexChildData get data => renderBox.parentData as FlexChildData;
}

class SpacingFlexChild with FlexChild {
  @override
  final FlexChildData data = SpacingFlexChildData();

  final BoxValue value;
  final Axis direction;

  SpacingFlexChild({required this.value, required this.direction});

  @override
  double computeIntrinsic(Axis direction, double extent, bool min) {
    return 0.0;
  }

  @override
  Size get size => switch (direction) {
    Axis.horizontal => Size(data.computedMainSize, data.computedCrossSize),
    Axis.vertical => Size(data.computedCrossSize, data.computedMainSize),
  };
}

class SpacingFlexChildData with FlexChildData {
  @override
  bool computeFlex({
    required FlexParent parent,
    required covariant SpacingFlexChild child,
  }) {
    // it has no flex
    return true;
  }

  @override
  void computePosition({
    required FlexParent parent,
    required FlexChild child,
    required double previousMainOffset,
  }) {
    // do nothing
  }

  @override
  bool get isAbsolute => false;

  @override
  FlexChild? get nextFlexChild => null;

  @override
  void computeFlexBasis({
    required FlexParent parent,
    required covariant SpacingFlexChild child,
  }) {}

  @override
  FlexChild? get previousFlexChild => null;

  @override
  void computeAdditionalFlexBasis({
    required FlexParent parent,
    required covariant SpacingFlexChild child,
  }) {
    final data = child.data;
    data.additionalFlexBasis = child.value.computeAdditionalFlexBasis(
      parent: parent,
      child: child,
      mainAxis: true,
    );
    data.additionalCrossFlexBasis = child.value.computeAdditionalFlexBasis(
      parent: parent,
      child: child,
      mainAxis: false,
    );
  }

  @override
  bool computePostFlex({required FlexParent parent, required FlexChild child}) {
    // TODO: implement computePostFlex
    throw UnimplementedError();
  }

  @override
  void computePostLayout({
    required FlexParent parent,
    required FlexChild child,
  }) {
    // TODO: implement computePostLayout
  }

  @override
  double? get flexGrow => null;

  @override
  double? get flexShrink => null;
}
