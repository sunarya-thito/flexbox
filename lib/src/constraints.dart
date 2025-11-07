import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';

/// A [BoxConstraints] wrapper that carries additional typed data.
///
/// This class extends the standard Flutter [BoxConstraints] by adding a generic
/// data payload of type [T]. This allows constraints to carry context-specific
/// information (such as layout metadata, scroll state, or viewport information)
/// along with the standard size constraints.
///
/// The data is immutable and is passed through constraint operations, making it
/// available to child widgets during layout. This is useful for communicating
/// layout-specific information down the widget tree without using InheritedWidgets.
///
/// Example:
/// ```dart
/// final constraints = BoxConstraintsWithData(
///   data: LayoutInfo(viewport: size, scroll: offset),
///   minWidth: 0,
///   maxWidth: 400,
///   minHeight: 0,
///   maxHeight: 600,
/// );
/// ```
class BoxConstraintsWithData<T> implements BoxConstraints {
  /// The additional data payload attached to these constraints.
  ///
  /// This data is preserved through constraint operations and can be accessed
  /// by widgets during layout. The type [T] can be any data structure needed
  /// to communicate layout context.
  final T data;

  /// Creates box constraints with data and optional size bounds.
  ///
  /// All parameters except [data] have defaults that create maximally permissive
  /// constraints (0 to infinity for both width and height).
  ///
  /// Parameters:
  /// * [data] - The required data payload to attach
  /// * [minWidth] - Minimum width (default: 0.0)
  /// * [maxWidth] - Maximum width (default: double.infinity)
  /// * [minHeight] - Minimum height (default: 0.0)
  /// * [maxHeight] - Maximum height (default: double.infinity)
  const BoxConstraintsWithData({
    required this.data,
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
  });

  /// Creates tight constraints for the given [size] with attached [data].
  ///
  /// Tight constraints force the child to be exactly the specified size.
  /// Both minimum and maximum constraints are set to the size's dimensions.
  ///
  /// This is equivalent to `BoxConstraints.tight(size)` but with data attached.
  BoxConstraintsWithData.tight(Size size, {required this.data})
    : minWidth = size.width,
      maxWidth = size.width,
      minHeight = size.height,
      maxHeight = size.height;

  /// Creates tight constraints for specified dimensions with attached [data].
  ///
  /// If width or height is not specified, that dimension remains unconstrained
  /// (0 to infinity). When specified, both min and max are set to the same value,
  /// creating tight constraints for that dimension.
  ///
  /// This is equivalent to `BoxConstraints.tightFor()` but with data attached.
  const BoxConstraintsWithData.tightFor({
    double? width,
    double? height,
    required this.data,
  }) : minWidth = width ?? 0.0,
       maxWidth = width ?? double.infinity,
       minHeight = height ?? 0.0,
       maxHeight = height ?? double.infinity;

  /// Creates tight constraints for finite dimensions with attached [data].
  ///
  /// If width or height is finite (not double.infinity), creates tight constraints
  /// for that dimension. If infinite, that dimension remains unconstrained.
  ///
  /// This is useful when you want tight constraints only for dimensions that
  /// have been explicitly sized, while leaving others flexible.
  ///
  /// This is equivalent to `BoxConstraints.tightForFinite()` but with data attached.
  const BoxConstraintsWithData.tightForFinite({
    double width = double.infinity,
    double height = double.infinity,
    required this.data,
  }) : minWidth = width != double.infinity ? width : 0.0,
       maxWidth = width != double.infinity ? width : double.infinity,
       minHeight = height != double.infinity ? height : 0.0,
       maxHeight = height != double.infinity ? height : double.infinity;

  /// Creates loose constraints for the given [size] with attached [data].
  ///
  /// Loose constraints set minimum width and height to 0 while constraining
  /// maximum dimensions to the provided size. This allows children to be
  /// any size from zero up to the specified maximum.
  ///
  /// This is equivalent to `BoxConstraints.loose(size)` but with data attached.
  BoxConstraintsWithData.loose(Size size, {required this.data})
    : minWidth = 0.0,
      maxWidth = size.width,
      minHeight = 0.0,
      maxHeight = size.height;

  /// Creates expanding constraints with optional dimension limits and attached [data].
  ///
  /// Expanding constraints force the child to fill the available space. Both
  /// minimum and maximum constraints are set to infinity (or the specified
  /// dimensions if provided), causing the child to be as large as possible.
  ///
  /// This is equivalent to `BoxConstraints.expand()` but with data attached.
  const BoxConstraintsWithData.expand({
    double? width,
    double? height,
    required this.data,
  }) : minWidth = width ?? double.infinity,
       maxWidth = width ?? double.infinity,
       minHeight = height ?? double.infinity,
       maxHeight = height ?? double.infinity;

  /// Creates box constraints from view constraints with attached [data].
  ///
  /// Converts Flutter's [ViewConstraints] (used in platform views) to
  /// [BoxConstraintsWithData], preserving all size bounds while attaching
  /// the specified data payload.
  ///
  /// This is useful for bridging platform view constraints with the flexbox
  /// layout system's data-carrying constraints.
  BoxConstraintsWithData.fromViewConstraints(
    ViewConstraints constraints, {
    required this.data,
  }) : minWidth = constraints.minWidth,
       maxWidth = constraints.maxWidth,
       minHeight = constraints.minHeight,
       maxHeight = constraints.maxHeight;

  @override
  final double minWidth;

  @override
  final double maxWidth;

  @override
  final double minHeight;

  @override
  final double maxHeight;

  @override
  BoxConstraintsWithData copyWith({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    T? data,
  }) {
    return BoxConstraintsWithData(
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      data: data ?? this.data,
    );
  }

  @override
  BoxConstraintsWithData deflate(EdgeInsetsGeometry edges) {
    assert(debugAssertIsValid());
    final double horizontal = edges.horizontal;
    final double vertical = edges.vertical;
    final double deflatedMinWidth = max(0.0, minWidth - horizontal);
    final double deflatedMinHeight = max(0.0, minHeight - vertical);
    return BoxConstraintsWithData(
      data: data,
      minWidth: deflatedMinWidth,
      maxWidth: max(deflatedMinWidth, maxWidth - horizontal),
      minHeight: deflatedMinHeight,
      maxHeight: max(deflatedMinHeight, maxHeight - vertical),
    );
  }

  @override
  BoxConstraintsWithData loosen() {
    assert(debugAssertIsValid());
    return BoxConstraintsWithData(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      data: data,
    );
  }

  @override
  BoxConstraintsWithData enforce(BoxConstraints constraints) {
    return BoxConstraintsWithData(
      data: data,
      minWidth: clampDouble(
        minWidth,
        constraints.minWidth,
        constraints.maxWidth,
      ),
      maxWidth: clampDouble(
        maxWidth,
        constraints.minWidth,
        constraints.maxWidth,
      ),
      minHeight: clampDouble(
        minHeight,
        constraints.minHeight,
        constraints.maxHeight,
      ),
      maxHeight: clampDouble(
        maxHeight,
        constraints.minHeight,
        constraints.maxHeight,
      ),
    );
  }

  @override
  BoxConstraintsWithData tighten({double? width, double? height}) {
    return BoxConstraintsWithData(
      data: data,
      minWidth: width == null
          ? minWidth
          : clampDouble(width, minWidth, maxWidth),
      maxWidth: width == null
          ? maxWidth
          : clampDouble(width, minWidth, maxWidth),
      minHeight: height == null
          ? minHeight
          : clampDouble(height, minHeight, maxHeight),
      maxHeight: height == null
          ? maxHeight
          : clampDouble(height, minHeight, maxHeight),
    );
  }

  @override
  BoxConstraintsWithData get flipped {
    return BoxConstraintsWithData(
      minWidth: minHeight,
      maxWidth: maxHeight,
      minHeight: minWidth,
      maxHeight: maxWidth,
      data: data,
    );
  }

  @override
  BoxConstraintsWithData widthConstraints() => BoxConstraintsWithData(
    minWidth: minWidth,
    maxWidth: maxWidth,
    data: data,
  );

  @override
  BoxConstraintsWithData heightConstraints() => BoxConstraintsWithData(
    minHeight: minHeight,
    maxHeight: maxHeight,
    data: data,
  );

  @override
  double constrainWidth([double width = double.infinity]) {
    assert(debugAssertIsValid());
    return clampDouble(width, minWidth, maxWidth);
  }

  @override
  double constrainHeight([double height = double.infinity]) {
    assert(debugAssertIsValid());
    return clampDouble(height, minHeight, maxHeight);
  }

  @override
  Size constrain(Size size) {
    Size result = Size(
      constrainWidth(size.width),
      constrainHeight(size.height),
    );
    return result;
  }

  @override
  Size constrainDimensions(double width, double height) {
    return Size(constrainWidth(width), constrainHeight(height));
  }

  @override
  Size constrainSizeAndAttemptToPreserveAspectRatio(Size size) {
    if (isTight) {
      Size result = smallest;
      return result;
    }

    if (size.isEmpty) {
      return constrain(size);
    }

    double width = size.width;
    double height = size.height;
    final double aspectRatio = width / height;

    if (width > maxWidth) {
      width = maxWidth;
      height = width / aspectRatio;
    }

    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }

    if (width < minWidth) {
      width = minWidth;
      height = width / aspectRatio;
    }

    if (height < minHeight) {
      height = minHeight;
      width = height * aspectRatio;
    }

    Size result = Size(constrainWidth(width), constrainHeight(height));
    return result;
  }

  @override
  Size get biggest => Size(constrainWidth(), constrainHeight());

  @override
  Size get smallest => Size(constrainWidth(0.0), constrainHeight(0.0));

  @override
  bool get hasTightWidth => minWidth >= maxWidth;

  @override
  bool get hasTightHeight => minHeight >= maxHeight;

  @override
  bool get isTight => hasTightWidth && hasTightHeight;

  @override
  bool get hasBoundedWidth => maxWidth < double.infinity;

  @override
  bool get hasBoundedHeight => maxHeight < double.infinity;

  @override
  bool get hasInfiniteWidth => minWidth >= double.infinity;

  @override
  bool get hasInfiniteHeight => minHeight >= double.infinity;

  @override
  bool isSatisfiedBy(Size size) {
    assert(debugAssertIsValid());
    return (minWidth <= size.width) &&
        (size.width <= maxWidth) &&
        (minHeight <= size.height) &&
        (size.height <= maxHeight);
  }

  @override
  BoxConstraintsWithData operator *(double factor) {
    return BoxConstraintsWithData(
      data: data,
      minWidth: minWidth * factor,
      maxWidth: maxWidth * factor,
      minHeight: minHeight * factor,
      maxHeight: maxHeight * factor,
    );
  }

  @override
  BoxConstraintsWithData operator /(double factor) {
    return BoxConstraintsWithData(
      minWidth: minWidth / factor,
      maxWidth: maxWidth / factor,
      minHeight: minHeight / factor,
      maxHeight: maxHeight / factor,
      data: data,
    );
  }

  @override
  BoxConstraintsWithData operator ~/(double factor) {
    return BoxConstraintsWithData(
      minWidth: (minWidth ~/ factor).toDouble(),
      maxWidth: (maxWidth ~/ factor).toDouble(),
      minHeight: (minHeight ~/ factor).toDouble(),
      maxHeight: (maxHeight ~/ factor).toDouble(),
      data: data,
    );
  }

  @override
  BoxConstraintsWithData operator %(double value) {
    return BoxConstraintsWithData(
      minWidth: minWidth % value,
      maxWidth: maxWidth % value,
      minHeight: minHeight % value,
      maxHeight: maxHeight % value,
      data: data,
    );
  }

  /// Linearly interpolates between two [BoxConstraintsWithData] objects.
  ///
  /// Returns a new constraints object with values interpolated between [a] and [b]
  /// based on the interpolation factor [t]. When [t] is 0.0, returns [a]; when [t]
  /// is 1.0, returns [b]; values between 0.0 and 1.0 produce proportional blends.
  ///
  /// This method handles null values gracefully:
  /// - If both are null, returns null
  /// - If [a] is null, treats it as zero constraints scaled by [t]
  /// - If [b] is null, treats it as zero constraints scaled by (1-t)
  /// - If identical, returns [a] directly
  ///
  /// The data payload is taken from the non-null constraints or [b] if both exist.
  ///
  /// This is equivalent to `BoxConstraints.lerp()` but preserves the data payload.
  static BoxConstraintsWithData? lerp(
    BoxConstraintsWithData? a,
    BoxConstraintsWithData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b! * t;
    }
    if (b == null) {
      return a * (1.0 - t);
    }
    assert(a.debugAssertIsValid());
    assert(b.debugAssertIsValid());
    assert(
      (a.minWidth.isFinite && b.minWidth.isFinite) ||
          (a.minWidth == double.infinity && b.minWidth == double.infinity),
      'Cannot interpolate between finite constraints and unbounded constraints.',
    );
    assert(
      (a.maxWidth.isFinite && b.maxWidth.isFinite) ||
          (a.maxWidth == double.infinity && b.maxWidth == double.infinity),
      'Cannot interpolate between finite constraints and unbounded constraints.',
    );
    assert(
      (a.minHeight.isFinite && b.minHeight.isFinite) ||
          (a.minHeight == double.infinity && b.minHeight == double.infinity),
      'Cannot interpolate between finite constraints and unbounded constraints.',
    );
    assert(
      (a.maxHeight.isFinite && b.maxHeight.isFinite) ||
          (a.maxHeight == double.infinity && b.maxHeight == double.infinity),
      'Cannot interpolate between finite constraints and unbounded constraints.',
    );
    return BoxConstraintsWithData(
      minWidth: a.minWidth.isFinite
          ? lerpDouble(a.minWidth, b.minWidth, t)!
          : double.infinity,
      maxWidth: a.maxWidth.isFinite
          ? lerpDouble(a.maxWidth, b.maxWidth, t)!
          : double.infinity,
      minHeight: a.minHeight.isFinite
          ? lerpDouble(a.minHeight, b.minHeight, t)!
          : double.infinity,
      maxHeight: a.maxHeight.isFinite
          ? lerpDouble(a.maxHeight, b.maxHeight, t)!
          : double.infinity,
      data: t < 0.5 ? a.data : b.data,
    );
  }

  @override
  bool get isNormalized {
    return minWidth >= 0.0 &&
        minWidth <= maxWidth &&
        minHeight >= 0.0 &&
        minHeight <= maxHeight;
  }

  @override
  bool debugAssertIsValid({
    bool isAppliedConstraint = false,
    InformationCollector? informationCollector,
  }) {
    assert(() {
      void throwError(DiagnosticsNode message) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          message,
          if (informationCollector != null) ...informationCollector(),
          DiagnosticsProperty<BoxConstraintsWithData>(
            'The offending constraints were',
            this,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
        ]);
      }

      if (minWidth.isNaN ||
          maxWidth.isNaN ||
          minHeight.isNaN ||
          maxHeight.isNaN) {
        final List<String> affectedFieldsList = <String>[
          if (minWidth.isNaN) 'minWidth',
          if (maxWidth.isNaN) 'maxWidth',
          if (minHeight.isNaN) 'minHeight',
          if (maxHeight.isNaN) 'maxHeight',
        ];
        assert(affectedFieldsList.isNotEmpty);
        if (affectedFieldsList.length > 1) {
          affectedFieldsList.add('and ${affectedFieldsList.removeLast()}');
        }
        final String whichFields = switch (affectedFieldsList.length) {
          1 => affectedFieldsList.single,
          2 => affectedFieldsList.join(' '),
          _ => affectedFieldsList.join(', '),
        };
        throwError(
          ErrorSummary(
            'BoxConstraintsWithData has ${affectedFieldsList.length == 1 ? 'a NaN value' : 'NaN values'} in $whichFields.',
          ),
        );
      }
      if (minWidth < 0.0 && minHeight < 0.0) {
        throwError(
          ErrorSummary(
            'BoxConstraintsWithData has both a negative minimum width and a negative minimum height.',
          ),
        );
      }
      if (minWidth < 0.0) {
        throwError(
          ErrorSummary('BoxConstraintsWithData has a negative minimum width.'),
        );
      }
      if (minHeight < 0.0) {
        throwError(
          ErrorSummary('BoxConstraintsWithData has a negative minimum height.'),
        );
      }
      if (maxWidth < minWidth && maxHeight < minHeight) {
        throwError(
          ErrorSummary(
            'BoxConstraintsWithData has both width and height constraints non-normalized.',
          ),
        );
      }
      if (maxWidth < minWidth) {
        throwError(
          ErrorSummary(
            'BoxConstraintsWithData has non-normalized width constraints.',
          ),
        );
      }
      if (maxHeight < minHeight) {
        throwError(
          ErrorSummary(
            'BoxConstraintsWithData has non-normalized height constraints.',
          ),
        );
      }
      if (isAppliedConstraint) {
        if (minWidth.isInfinite && minHeight.isInfinite) {
          throwError(
            ErrorSummary(
              'BoxConstraintsWithData forces an infinite width and infinite height.',
            ),
          );
        }
        if (minWidth.isInfinite) {
          throwError(
            ErrorSummary('BoxConstraintsWithData forces an infinite width.'),
          );
        }
        if (minHeight.isInfinite) {
          throwError(
            ErrorSummary('BoxConstraintsWithData forces an infinite height.'),
          );
        }
      }
      assert(isNormalized);
      return true;
    }());
    return isNormalized;
  }

  @override
  BoxConstraintsWithData normalize() {
    if (isNormalized) {
      return this;
    }
    final double minWidth = this.minWidth >= 0.0 ? this.minWidth : 0.0;
    final double minHeight = this.minHeight >= 0.0 ? this.minHeight : 0.0;
    return BoxConstraintsWithData(
      minWidth: minWidth,
      maxWidth: minWidth > maxWidth ? minWidth : maxWidth,
      minHeight: minHeight,
      maxHeight: minHeight > maxHeight ? minHeight : maxHeight,
      data: data,
    );
  }

  @override
  bool operator ==(Object other) {
    assert(debugAssertIsValid());
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    assert(other is BoxConstraintsWithData && other.debugAssertIsValid());
    return other is BoxConstraintsWithData &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight &&
        other.data == data;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return Object.hash(minWidth, maxWidth, minHeight, maxHeight, data);
  }

  @override
  String toString() {
    String annotation = isNormalized ? '' : '; NOT NORMALIZED';
    annotation += '; data=$data';
    if (minWidth == double.infinity && minHeight == double.infinity) {
      return 'BoxConstraintsWithData(biggest$annotation)';
    }
    if (minWidth == 0 &&
        maxWidth == double.infinity &&
        minHeight == 0 &&
        maxHeight == double.infinity) {
      return 'BoxConstraintsWithData(unconstrained$annotation)';
    }
    String describe(double min, double max, String dim) {
      if (min == max) {
        return '$dim=${min.toStringAsFixed(1)}';
      }
      return '${min.toStringAsFixed(1)}<=$dim<=${max.toStringAsFixed(1)}';
    }

    final String width = describe(minWidth, maxWidth, 'w');
    final String height = describe(minHeight, maxHeight, 'h');

    return 'BoxConstraintsWithData($width, $height$annotation)';
  }

  /// Creates box constraints from standard [BoxConstraints] with attached [data].
  ///
  /// This constructor wraps existing Flutter [BoxConstraints] with a data payload,
  /// converting standard constraints into data-carrying constraints. All size bounds
  /// (minWidth, maxWidth, minHeight, maxHeight) are copied from the provided constraints.
  ///
  /// This is useful for adapting standard Flutter constraints to work with the
  /// flexbox layout system that requires additional context data.
  ///
  /// Example:
  /// ```dart
  /// final flutterConstraints = BoxConstraints.tight(Size(100, 50));
  /// final dataConstraints = BoxConstraintsWithData.fromConstraints(
  ///   flutterConstraints,
  ///   data: myLayoutData,
  /// );
  /// ```
  BoxConstraintsWithData.fromConstraints(
    BoxConstraints constraints, {
    required this.data,
  }) : minWidth = constraints.minWidth,
       maxWidth = constraints.maxWidth,
       minHeight = constraints.minHeight,
       maxHeight = constraints.maxHeight;
}
