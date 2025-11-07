library;

import 'package:flexiblebox/src/basic.dart';
import 'package:flutter/widgets.dart';

export 'src/basic.dart';
export 'src/widgets/flex.dart';
export 'src/widgets/widget.dart';
export 'src/rendering.dart';
export 'src/widgets/rotated.dart';
export 'src/widgets/scrollbar.dart';

/// Extension methods for converting Flutter's [EdgeInsetsGeometry] to flexbox [EdgeSpacingGeometry].
///
/// This extension provides a convenient way to convert Flutter's built-in edge insets
/// to the flexbox library's spacing system, allowing seamless integration between
/// Flutter widgets and flexbox layouts.
extension EdgeInsetsGeometryExtension on EdgeInsetsGeometry {
  EdgeSpacingGeometry get asEdgeSpacing => switch (this) {
    EdgeInsets edgeInsets => EdgeSpacing.only(
      left: SpacingUnit.fixed(edgeInsets.left),
      top: SpacingUnit.fixed(edgeInsets.top),
      right: SpacingUnit.fixed(edgeInsets.right),
      bottom: SpacingUnit.fixed(edgeInsets.bottom),
    ),
    EdgeInsetsDirectional edgeInsetsDirectional => EdgeSpacingDirectional.only(
      start: SpacingUnit.fixed(edgeInsetsDirectional.start),
      top: SpacingUnit.fixed(edgeInsetsDirectional.top),
      end: SpacingUnit.fixed(edgeInsetsDirectional.end),
      bottom: SpacingUnit.fixed(edgeInsetsDirectional.bottom),
    ),
    _ => throw UnimplementedError(
      'EdgeInsetsGeometry type $runtimeType is not supported',
    ),
  };
}

/// Extension methods for converting Flutter's [EdgeInsetsDirectional] to flexbox [EdgeSpacingDirectional].
///
/// This extension provides a convenient way to convert directional edge insets
/// to the flexbox library's directional spacing system, preserving text-direction awareness.
extension EdgeInsetsDirectionalExtension on EdgeInsetsDirectional {
  EdgeSpacingDirectional get asEdgeSpacing => EdgeSpacingDirectional.only(
    start: SpacingUnit.fixed(start),
    top: SpacingUnit.fixed(top),
    end: SpacingUnit.fixed(end),
    bottom: SpacingUnit.fixed(bottom),
  );
}

/// Extension methods for converting Flutter's [EdgeInsets] to flexbox [EdgeSpacing].
///
/// This extension provides a convenient way to convert absolute edge insets
/// to the flexbox library's spacing system for use in layout containers.
extension EdgeInsetsExtension on EdgeInsets {
  EdgeSpacing get asEdgeSpacing => EdgeSpacing.only(
    left: SpacingUnit.fixed(left),
    top: SpacingUnit.fixed(top),
    right: SpacingUnit.fixed(right),
    bottom: SpacingUnit.fixed(bottom),
  );
}

/// Extension methods for converting Flutter's [MainAxisAlignment] to flexbox [BoxAlignmentContent].
///
/// This extension allows Flutter's main axis alignment values to be used directly
/// with flexbox layouts, providing a familiar API for developers migrating from
/// Flutter's built-in layout widgets.
extension MainAxisAlignmentExtension on MainAxisAlignment {
  BoxAlignmentContent get asBoxAlignment => switch (this) {
    MainAxisAlignment.start => BoxAlignmentContent.start,
    MainAxisAlignment.end => BoxAlignmentContent.end,
    MainAxisAlignment.center => BoxAlignmentContent.center,
    MainAxisAlignment.spaceBetween => BoxAlignmentContent.spaceBetween,
    MainAxisAlignment.spaceAround => BoxAlignmentContent.spaceAround,
    MainAxisAlignment.spaceEvenly => BoxAlignmentContent.spaceEvenly,
  };
}

/// Extension methods for converting Flutter's [CrossAxisAlignment] to flexbox [BoxAlignmentGeometry].
///
/// This extension enables Flutter's cross axis alignment values to be used seamlessly
/// with flexbox layouts, maintaining API consistency for Flutter developers.
extension CrossAxisAlignmentExtension on CrossAxisAlignment {
  BoxAlignmentGeometry get asBoxAlignment => switch (this) {
    CrossAxisAlignment.start => BoxAlignmentGeometry.start,
    CrossAxisAlignment.end => BoxAlignmentGeometry.end,
    CrossAxisAlignment.center => BoxAlignmentGeometry.center,
    CrossAxisAlignment.stretch => BoxAlignmentGeometry.stretch,
    CrossAxisAlignment.baseline => BoxAlignmentGeometry.baseline,
  };
}
