import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A widget that provides two-dimensional scrolling capabilities.
///
/// [ScrollableClient] wraps Flutter's [TwoDimensionalScrollable] to provide
/// a convenient interface for creating scrollable areas with both horizontal
/// and vertical scrolling. It supports primary scroll controllers, diagonal
/// drag behavior, keyboard dismissal, and various scrolling configurations.
///
/// This widget is typically used as a building block for creating custom
/// scrollable containers that need more control over scrolling behavior
/// than standard Flutter scroll widgets provide.
class ScrollableClient extends StatelessWidget {
  /// Whether this scrollable should use the primary scroll controller.
  ///
  /// When true, this scrollable uses the primary scroll controller from the
  /// enclosing [PrimaryScrollController]. If null, inherits based on context
  /// and whether a controller is explicitly provided.
  final bool? primary;
  
  /// The main scrolling axis (vertical or horizontal).
  ///
  /// Determines which axis is considered the primary scrolling direction.
  /// This affects which [ScrollableDetails] (vertical or horizontal) is
  /// associated with the primary scroll controller when [primary] is true.
  final Axis mainAxis;
  
  /// Configuration for vertical scrolling behavior.
  ///
  /// Includes the scroll controller, physics, clip behavior, and other
  /// vertical scrolling parameters. Must be configured for [Axis.vertical].
  final ScrollableDetails verticalDetails;
  
  /// Configuration for horizontal scrolling behavior.
  ///
  /// Includes the scroll controller, physics, clip behavior, and other
  /// horizontal scrolling parameters. Must be configured for [Axis.horizontal].
  final ScrollableDetails horizontalDetails;
  
  /// Builder function that creates the two-dimensional viewport.
  ///
  /// Called with the current build context and two [ScrollableState] objects
  /// (for vertical and horizontal scrolling) to build the scrollable viewport.
  final TwoDimensionalViewportBuilder builder;
  
  /// Optional child widget passed to the builder.
  ///
  /// Can be used to pass static content or configuration through to the viewport builder.
  final Widget? child;
  
  /// How diagonal drag gestures should be handled.
  ///
  /// Determines whether diagonal drags should scroll in both directions,
  /// only in one direction, or be ignored. See [DiagonalDragBehavior] for options.
  final DiagonalDragBehavior diagonalDragBehavior;
  
  /// How drag gestures should begin.
  ///
  /// Controls whether drags start immediately on down or wait for a sufficient
  /// drag distance. See [DragStartBehavior] for options.
  final DragStartBehavior dragStartBehavior;
  
  /// How the keyboard should be dismissed when scrolling.
  ///
  /// Determines whether scrolling dismisses the on-screen keyboard automatically,
  /// manually, or never. See [ScrollViewKeyboardDismissBehavior] for options.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  
  /// How hit testing should be performed on this widget.
  ///
  /// Controls whether this widget should absorb pointers during hit testing.
  /// See [HitTestBehavior] for options.
  final HitTestBehavior hitTestBehavior;

  /// Creates a two-dimensional scrollable widget.
  ///
  /// The [builder] parameter is required to construct the viewport. The [mainAxis]
  /// determines which scrolling direction is considered primary for controller
  /// inheritance purposes.
  ///
  /// Example:
  /// ```dart
  /// ScrollableClient(
  ///   mainAxis: Axis.vertical,
  ///   verticalDetails: ScrollableDetails.vertical(
  ///     controller: myVerticalController,
  ///   ),
  ///   builder: (context, vertical, horizontal) {
  ///     return MyCustomViewport(vertical: vertical, horizontal: horizontal);
  ///   },
  /// )
  /// ```
  const ScrollableClient({
    super.key,
    this.primary,
    this.mainAxis = Axis.vertical,
    this.verticalDetails = const ScrollableDetails.vertical(),
    this.horizontalDetails = const ScrollableDetails.horizontal(),
    required this.builder,
    this.child,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      axisDirectionToAxis(verticalDetails.direction) == Axis.vertical,
      'ScrollableClient.verticalDetails are not Axis.vertical.',
    );
    assert(
      axisDirectionToAxis(horizontalDetails.direction) == Axis.horizontal,
      'ScrollableClient.horizontalDetails are not Axis.horizontal.',
    );

    ScrollableDetails mainAxisDetails = switch (mainAxis) {
      Axis.vertical => verticalDetails,
      Axis.horizontal => horizontalDetails,
    };

    final bool effectivePrimary =
        primary ??
        mainAxisDetails.controller == null &&
            PrimaryScrollController.shouldInherit(context, mainAxis);

    if (effectivePrimary) {
      // Using PrimaryScrollController for mainAxis.
      assert(
        mainAxisDetails.controller == null,
        'ScrollableClient.primary was explicitly set to true, but a '
        'ScrollController was provided in the ScrollableDetails of the '
        'ScrollableClient.mainAxis.',
      );
      mainAxisDetails = mainAxisDetails.copyWith(
        controller: PrimaryScrollController.of(context),
      );
    }

    final TwoDimensionalScrollable scrollable = TwoDimensionalScrollable(
      horizontalDetails: switch (mainAxis) {
        Axis.horizontal => mainAxisDetails,
        Axis.vertical => horizontalDetails,
      },
      verticalDetails: switch (mainAxis) {
        Axis.vertical => mainAxisDetails,
        Axis.horizontal => verticalDetails,
      },
      diagonalDragBehavior: diagonalDragBehavior,
      viewportBuilder: builder,
      dragStartBehavior: dragStartBehavior,
      hitTestBehavior: hitTestBehavior,
    );

    final Widget scrollableResult = effectivePrimary
        // Further descendant ScrollViews will not inherit the same PrimaryScrollController
        ? PrimaryScrollController.none(child: scrollable)
        : scrollable;

    if (keyboardDismissBehavior == ScrollViewKeyboardDismissBehavior.onDrag) {
      return NotificationListener<ScrollUpdateNotification>(
        child: scrollableResult,
        onNotification: (ScrollUpdateNotification notification) {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (notification.dragDetails != null &&
              !currentScope.hasPrimaryFocus &&
              currentScope.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          return false;
        },
      );
    }
    return scrollableResult;
  }
}
