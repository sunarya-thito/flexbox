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
  /// Converts Flutter's [EdgeInsetsGeometry] to the flexbox [EdgeSpacingGeometry] equivalent.
  ///
  /// This conversion enables seamless integration between Flutter's standard edge insets
  /// and the flexbox library's spacing system. The method handles both absolute
  /// ([EdgeInsets]) and directional ([EdgeInsetsDirectional]) insets.
  ///
  /// For [EdgeInsets], converts to [EdgeSpacing] preserving left, top, right, and bottom values.
  /// For [EdgeInsetsDirectional], converts to [EdgeSpacingDirectional] preserving start, top, end, and bottom values.
  ///
  /// Throws [UnimplementedError] if the edge insets type is not supported.
  ///
  /// Example:
  /// ```dart
  /// final padding = EdgeInsets.all(8.0);
  /// final flexSpacing = padding.asEdgeSpacing; // EdgeSpacing with 8.0 spacing on all sides
  /// ```
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
  /// Converts Flutter's [EdgeInsetsDirectional] to the flexbox [EdgeSpacingDirectional] equivalent.
  ///
  /// This conversion preserves the directional nature of the insets, maintaining
  /// text-direction awareness (start/end instead of left/right). The resulting
  /// [EdgeSpacingDirectional] will respond appropriately to text direction changes.
  ///
  /// All four sides (start, top, end, bottom) are converted to fixed spacing units
  /// with their corresponding pixel values.
  ///
  /// Example:
  /// ```dart
  /// final padding = EdgeInsetsDirectional.only(start: 16.0, end: 8.0);
  /// final flexSpacing = padding.asEdgeSpacing; // EdgeSpacingDirectional with start: 16.0, end: 8.0
  /// ```
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
  /// Converts Flutter's [EdgeInsets] to the flexbox [EdgeSpacing] equivalent.
  ///
  /// This conversion transforms absolute edge insets (left, top, right, bottom)
  /// into the flexbox library's spacing system. The resulting [EdgeSpacing]
  /// maintains the same pixel values for all four sides.
  ///
  /// This is useful for applying Flutter-style padding or margins to flexbox
  /// layout containers while preserving exact spacing values.
  ///
  /// Example:
  /// ```dart
  /// final padding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);
  /// final flexSpacing = padding.asEdgeSpacing; // EdgeSpacing with h: 20.0, v: 10.0
  /// ```
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
  /// Converts Flutter's [MainAxisAlignment] to the flexbox [BoxAlignmentContent] equivalent.
  ///
  /// This conversion maps Flutter's main axis alignment values to the flexbox
  /// library's content alignment system, enabling familiar Flutter alignment
  /// semantics in flexbox layouts.
  ///
  /// Mapping:
  /// - [MainAxisAlignment.start] → [BoxAlignmentContent.start]
  /// - [MainAxisAlignment.end] → [BoxAlignmentContent.end]
  /// - [MainAxisAlignment.center] → [BoxAlignmentContent.center]
  /// - [MainAxisAlignment.spaceBetween] → [BoxAlignmentContent.spaceBetween]
  /// - [MainAxisAlignment.spaceAround] → [BoxAlignmentContent.spaceAround]
  /// - [MainAxisAlignment.spaceEvenly] → [BoxAlignmentContent.spaceEvenly]
  ///
  /// Example:
  /// ```dart
  /// final alignment = MainAxisAlignment.spaceBetween;
  /// final flexAlignment = alignment.asBoxAlignment; // BoxAlignmentContent.spaceBetween
  /// ```
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
  /// Converts Flutter's [CrossAxisAlignment] to the flexbox [BoxAlignmentGeometry] equivalent.
  ///
  /// This conversion maps Flutter's cross axis alignment values to the flexbox
  /// library's alignment geometry system, maintaining consistent alignment behavior
  /// between Flutter and flexbox layouts.
  ///
  /// Mapping:
  /// - [CrossAxisAlignment.start] → [BoxAlignmentGeometry.start]
  /// - [CrossAxisAlignment.end] → [BoxAlignmentGeometry.end]
  /// - [CrossAxisAlignment.center] → [BoxAlignmentGeometry.center]
  /// - [CrossAxisAlignment.stretch] → [BoxAlignmentGeometry.stretch]
  /// - [CrossAxisAlignment.baseline] → [BoxAlignmentGeometry.baseline]
  ///
  /// Example:
  /// ```dart
  /// final alignment = CrossAxisAlignment.center;
  /// final flexAlignment = alignment.asBoxAlignment; // BoxAlignmentGeometry.center
  /// ```
  BoxAlignmentGeometry get asBoxAlignment => switch (this) {
    CrossAxisAlignment.start => BoxAlignmentGeometry.start,
    CrossAxisAlignment.end => BoxAlignmentGeometry.end,
    CrossAxisAlignment.center => BoxAlignmentGeometry.center,
    CrossAxisAlignment.stretch => BoxAlignmentGeometry.stretch,
    CrossAxisAlignment.baseline => BoxAlignmentGeometry.baseline,
  };
}
