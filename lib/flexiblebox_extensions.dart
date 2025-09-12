library;

import 'package:flexiblebox/flexiblebox.dart';

export 'flexiblebox.dart';

const alignCenter = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.center,
  anchor: BoxAlignmentGeometry.center,
);
const alignStart = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.start,
  anchor: BoxAlignmentGeometry.start,
);
const alignEnd = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.end,
  anchor: BoxAlignmentGeometry.end,
);
const intrinsicSize = BoxValue.intrinsic();
const expandingSize = BoxValue.expanding();

// We separate extensions to double and num
// for better performance
extension DoubleExtensions on double {
  FixedValue get px => FixedValue(this);
  RelativeValue get viewportSize => RelativeValue(this);
  RelativeValue get contentSize =>
      RelativeValue(this, target: FlexTarget.content);
  RelativeValue get childSize => RelativeValue(this, target: FlexTarget.child);
  FlexSize get flex => FlexSize(this);
  RatioSize get ratio => RatioSize(this);
  double get percent => this / 100;
}

extension NumberExtensions on num {
  FixedValue get px => FixedValue(toDouble());
  RelativeValue get viewportSize => RelativeValue(toDouble());
  RelativeValue get contentSize =>
      RelativeValue(toDouble(), target: FlexTarget.content);
  RelativeValue get childSize =>
      RelativeValue(toDouble(), target: FlexTarget.child);
  FlexSize get flex => FlexSize(toDouble());
  RatioSize get ratio => RatioSize(toDouble());
  double get percent => toDouble() / 100;
}
