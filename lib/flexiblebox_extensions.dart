library;

import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

extension DoubleExtension on double {
  /// Converts a [double] value to a [SizeUnit.fixed] instance.
  ///
  /// This extension method provides a convenient way to create fixed size units
  /// directly from double values, enhancing code readability and reducing boilerplate.
  SizeUnit get size => SizeUnit.fixed(this);
  SizeUnit get relativeSize => SizeUnit.viewportSize * size;
  double get percent => this / 100;
  PositionUnit get position => PositionUnit.fixed(this);
  PositionUnit get relativePosition => PositionUnit.viewportSize * position;
  // PositionUnit get relativeChildPosition => PositionUnit.childSize() * position;
  PositionUnit relativeChildPosition([Key? key]) =>
      PositionUnit.childSize(key) * position;
  PositionUnit get relativeContentPosition =>
      PositionUnit.contentSize * position;
  SpacingUnit get spacing => SpacingUnit.fixed(this);
  SpacingUnit get relativeSpacing => SpacingUnit.viewportSize * spacing;
}

extension IntExtension on int {
  /// Converts an [int] value to a [SizeUnit.fixed] instance.
  ///
  /// This extension method provides a convenient way to create fixed size units
  /// directly from integer values, enhancing code readability and reducing boilerplate.
  SizeUnit get size => SizeUnit.fixed(toDouble());
  SizeUnit get relativeSize => SizeUnit.viewportSize * size;
  double get percent => toDouble() / 100;
  PositionUnit get position => PositionUnit.fixed(toDouble());
  PositionUnit get relativePosition => PositionUnit.viewportSize * position;
  PositionUnit relativeChildPosition([Key? key]) =>
      PositionUnit.childSize(key) * position;
  PositionUnit get relativeContentPosition =>
      PositionUnit.contentSize * position;
  SpacingUnit get spacing => SpacingUnit.fixed(toDouble());
  SpacingUnit get relativeSpacing => SpacingUnit.viewportSize * spacing;
}
