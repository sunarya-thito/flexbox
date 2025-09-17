library;

import 'package:flexiblebox/flexiblebox.dart';

const alignCenter = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.center,
  anchor: BoxAlignmentGeometry.center,
);
const alignCenterStart = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.center,
  anchor: BoxAlignmentGeometry.start,
);
const alignCenterEnd = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.center,
  anchor: BoxAlignmentGeometry.end,
);
const alignStart = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.start,
  anchor: BoxAlignmentGeometry.start,
);
const alignStartCenter = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.start,
  anchor: BoxAlignmentGeometry.center,
);
const alignStartEnd = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.start,
  anchor: BoxAlignmentGeometry.end,
);
const alignEnd = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.end,
  anchor: BoxAlignmentGeometry.end,
);
const alignEndCenter = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.end,
  anchor: BoxAlignmentGeometry.center,
);
const alignEndStart = BoxValue.aligned(
  alignment: BoxAlignmentGeometry.end,
  anchor: BoxAlignmentGeometry.start,
);
const intrinsicSize = BoxValue.intrinsic();
const expandingSize = BoxValue.expanding();
const smallestExpandingSize = BoxValue.expanding(
  expansion: FlexExpansion.smallest,
);

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
