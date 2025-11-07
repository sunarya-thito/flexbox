library;

import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

extension DoubleExtension on double {
  /// Converts a [double] value to a [SizeUnit.fixed] instance.
  ///
  /// This extension method provides a convenient way to create fixed size units
  /// directly from double values, enhancing code readability and reducing boilerplate.
  SizeUnit get size => SizeUnit.fixed(this);

  /// Converts a [double] value to a viewport-relative [SizeUnit].
  ///
  /// Creates a size unit that is proportional to the viewport size. For example,
  /// `0.5.relativeSize` creates a size that is 50% of the viewport dimension.
  ///
  /// This is equivalent to `SizeUnit.viewportSize * this.size`.
  SizeUnit get relativeSize => SizeUnit.viewportSize * size;

  /// Converts a [double] value to a percentage (0.0 to 1.0).
  ///
  /// Divides the value by 100 to convert from percentage notation to a decimal.
  /// For example, `50.0.percent` returns `0.5`.
  ///
  /// Useful for calculations requiring percentage values in decimal form.
  double get percent => this / 100;

  /// Converts a [double] value to a fixed [PositionUnit].
  ///
  /// Creates a position unit with an absolute pixel value. This is useful for
  /// positioning elements at fixed offsets from container edges.
  PositionUnit get position => PositionUnit.fixed(this);

  /// Converts a [double] value to a viewport-relative [PositionUnit].
  ///
  /// Creates a position unit that is proportional to the viewport size. For example,
  /// `0.25.relativePosition` creates a position that is 25% of the viewport dimension.
  ///
  /// This is equivalent to `PositionUnit.viewportSize * this.position`.
  PositionUnit get relativePosition => PositionUnit.viewportSize * position;

  // PositionUnit get relativeChildPosition => PositionUnit.childSize() * position;
  /// Converts a [double] value to a child-size-relative [PositionUnit].
  ///
  /// Creates a position unit that is proportional to a child element's size.
  /// For example, `0.5.relativeChildPosition()` creates a position that is 50%
  /// of the child's dimension along the relevant axis.
  ///
  /// The optional [key] parameter can be used to reference a specific child
  /// element when multiple children are present.
  ///
  /// This is equivalent to `PositionUnit.childSize(key) * this.position`.
  PositionUnit relativeChildPosition([Key? key]) =>
      PositionUnit.childSize(key) * position;

  /// Converts a [double] value to a content-size-relative [PositionUnit].
  ///
  /// Creates a position unit that is proportional to the total content size.
  /// For example, `0.5.relativeContentPosition` creates a position that is 50%
  /// of the content's dimension along the relevant axis.
  ///
  /// This is equivalent to `PositionUnit.contentSize * this.position`.
  PositionUnit get relativeContentPosition =>
      PositionUnit.contentSize * position;

  /// Converts a [double] value to a fixed [SpacingUnit].
  ///
  /// Creates a spacing unit with an absolute pixel value. This is useful for
  /// defining gaps and padding with fixed sizes.
  SpacingUnit get spacing => SpacingUnit.fixed(this);

  /// Converts a [double] value to a viewport-relative [SpacingUnit].
  ///
  /// Creates a spacing unit that is proportional to the viewport size. For example,
  /// `0.1.relativeSpacing` creates spacing that is 10% of the viewport dimension.
  ///
  /// This is equivalent to `SpacingUnit.viewportSize * this.spacing`.
  SpacingUnit get relativeSpacing => SpacingUnit.viewportSize * spacing;
}

extension IntExtension on int {
  /// Converts an [int] value to a [SizeUnit.fixed] instance.
  ///
  /// This extension method provides a convenient way to create fixed size units
  /// directly from integer values, enhancing code readability and reducing boilerplate.
  SizeUnit get size => SizeUnit.fixed(toDouble());

  /// Converts an [int] value to a viewport-relative [SizeUnit].
  ///
  /// Creates a size unit that is proportional to the viewport size. For example,
  /// `1.relativeSize` creates a size equal to the full viewport dimension.
  ///
  /// This is equivalent to `SizeUnit.viewportSize * this.size`.
  SizeUnit get relativeSize => SizeUnit.viewportSize * size;

  /// Converts an [int] value to a percentage (0.0 to 1.0).
  ///
  /// Divides the value by 100 to convert from percentage notation to a decimal.
  /// For example, `50.percent` returns `0.5`.
  ///
  /// Useful for calculations requiring percentage values in decimal form.
  double get percent => toDouble() / 100;

  /// Converts an [int] value to a fixed [PositionUnit].
  ///
  /// Creates a position unit with an absolute pixel value. This is useful for
  /// positioning elements at fixed offsets from container edges.
  PositionUnit get position => PositionUnit.fixed(toDouble());

  /// Converts an [int] value to a viewport-relative [PositionUnit].
  ///
  /// Creates a position unit that is proportional to the viewport size. For example,
  /// `1.relativePosition` creates a position equal to the full viewport dimension.
  ///
  /// This is equivalent to `PositionUnit.viewportSize * this.position`.
  PositionUnit get relativePosition => PositionUnit.viewportSize * position;

  /// Converts an [int] value to a child-size-relative [PositionUnit].
  ///
  /// Creates a position unit that is proportional to a child element's size.
  /// For example, `1.relativeChildPosition()` creates a position equal to
  /// the child's full dimension along the relevant axis.
  ///
  /// The optional [key] parameter can be used to reference a specific child
  /// element when multiple children are present.
  ///
  /// This is equivalent to `PositionUnit.childSize(key) * this.position`.
  PositionUnit relativeChildPosition([Key? key]) =>
      PositionUnit.childSize(key) * position;

  /// Converts an [int] value to a content-size-relative [PositionUnit].
  ///
  /// Creates a position unit that is proportional to the total content size.
  /// For example, `1.relativeContentPosition` creates a position equal to
  /// the content's full dimension along the relevant axis.
  ///
  /// This is equivalent to `PositionUnit.contentSize * this.position`.
  PositionUnit get relativeContentPosition =>
      PositionUnit.contentSize * position;

  /// Converts an [int] value to a fixed [SpacingUnit].
  ///
  /// Creates a spacing unit with an absolute pixel value. This is useful for
  /// defining gaps and padding with fixed sizes.
  SpacingUnit get spacing => SpacingUnit.fixed(toDouble());

  /// Converts an [int] value to a viewport-relative [SpacingUnit].
  ///
  /// Creates a spacing unit that is proportional to the viewport size. For example,
  /// `1.relativeSpacing` creates spacing equal to the full viewport dimension.
  ///
  /// This is equivalent to `SpacingUnit.viewportSize * this.spacing`.
  SpacingUnit get relativeSpacing => SpacingUnit.viewportSize * spacing;
}
