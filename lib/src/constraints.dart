import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';

class BoxConstraintsWithData<T> implements BoxConstraints {
  final T data;

  const BoxConstraintsWithData({
    required this.data,
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
  });

  BoxConstraintsWithData.tight(Size size, {required this.data})
    : minWidth = size.width,
      maxWidth = size.width,
      minHeight = size.height,
      maxHeight = size.height;

  const BoxConstraintsWithData.tightFor({
    double? width,
    double? height,
    required this.data,
  }) : minWidth = width ?? 0.0,
       maxWidth = width ?? double.infinity,
       minHeight = height ?? 0.0,
       maxHeight = height ?? double.infinity;

  const BoxConstraintsWithData.tightForFinite({
    double width = double.infinity,
    double height = double.infinity,
    required this.data,
  }) : minWidth = width != double.infinity ? width : 0.0,
       maxWidth = width != double.infinity ? width : double.infinity,
       minHeight = height != double.infinity ? height : 0.0,
       maxHeight = height != double.infinity ? height : double.infinity;

  BoxConstraintsWithData.loose(Size size, {required this.data})
    : minWidth = 0.0,
      maxWidth = size.width,
      minHeight = 0.0,
      maxHeight = size.height;

  const BoxConstraintsWithData.expand({
    double? width,
    double? height,
    required this.data,
  }) : minWidth = width ?? double.infinity,
       maxWidth = width ?? double.infinity,
       minHeight = height ?? double.infinity,
       maxHeight = height ?? double.infinity;

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

  BoxConstraintsWithData.fromConstraints(
    BoxConstraints constraints, {
    required this.data,
  }) : minWidth = constraints.minWidth,
       maxWidth = constraints.maxWidth,
       minHeight = constraints.minHeight,
       maxHeight = constraints.maxHeight;
}
