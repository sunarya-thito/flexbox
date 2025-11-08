library;

import 'package:flexiblebox/flexiblebox_flutter.dart';
import 'package:flutter/widgets.dart';

/// Extension methods on [double] for convenient conversion to flexbox units.
///
/// This extension provides convenient getters to convert double values into
/// various flexbox unit types such as [SizeUnit], [PositionUnit], and [SpacingUnit].
/// It also provides utilities for percentage calculations and relative sizing.
///
/// Example:
/// ```dart
/// final size = 100.0.size;  // Creates SizeUnit.fixed(100.0)
/// final position = 50.0.position;  // Creates PositionUnit.fixed(50.0)
/// final spacing = 10.0.spacing;  // Creates SpacingUnit.fixed(10.0)
/// ```
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

/// Extension methods on [int] for convenient conversion to flexbox units.
///
/// This extension provides convenient getters to convert integer values into
/// various flexbox unit types such as [SizeUnit], [PositionUnit], and [SpacingUnit].
/// It also provides utilities for percentage calculations and relative sizing.
///
/// Example:
/// ```dart
/// final size = 100.size;  // Creates SizeUnit.fixed(100.0)
/// final position = 50.position;  // Creates PositionUnit.fixed(50.0)
/// final spacing = 10.spacing;  // Creates SpacingUnit.fixed(10.0)
/// ```
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

/// Extension methods on [Widget] for convenient flexbox layout configuration.
///
/// This extension provides a fluent, chainable API for configuring widget properties
/// in flexbox layouts. Instead of wrapping widgets in multiple layout widgets,
/// you can use these extension methods to declaratively define sizing, positioning,
/// alignment, and flex behavior.
///
/// The extension methods wrap widgets in [FlexItem] or [AbsoluteItem] internally,
/// managing the configuration efficiently through a wrapper mechanism that avoids
/// unnecessary nesting when methods are chained.
///
/// Example:
/// ```dart
/// Container(color: Colors.blue)
///   .width(100.size)
///   .height(50.size)
///   .flexGrow(1)
///   .selfAligned(BoxAlignment.center)
/// ```
extension WidgetExtension on Widget {
  /// Sets the paint order for this widget within its parent container.
  ///
  /// Paint order determines the z-index stacking order of children. Widgets with
  /// higher paint order values are painted later (appear on top).
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Background').paintOrder(0),
  /// Text('Foreground').paintOrder(10),
  /// ```
  Widget paintOrder(int paintOrder, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      paintOrder: () => paintOrder,
    );
  }

  /// Sets the width of this widget using a [SizeUnit].
  ///
  /// The width can be specified as a fixed pixel value, percentage of parent,
  /// viewport-relative size, or other [SizeUnit] types.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Fixed').width(100.size),
  /// Text('Relative').width(0.5.relativeSize),
  /// ```
  Widget width(SizeUnit width, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      width: () => width,
    );
  }

  /// Sets the height of this widget using a [SizeUnit].
  ///
  /// The height can be specified as a fixed pixel value, percentage of parent,
  /// viewport-relative size, or other [SizeUnit] types.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Fixed').height(50.size),
  /// Text('Relative').height(0.3.relativeSize),
  /// ```
  Widget height(SizeUnit height, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      height: () => height,
    );
  }

  /// Sets the minimum width constraint for this widget using a [SizeUnit].
  ///
  /// The widget will not shrink below this width, even if the parent container
  /// or flex shrinking would normally make it smaller.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Content').minWidth(100.size),
  /// ```
  Widget minWidth(SizeUnit minWidth, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      minWidth: () => minWidth,
    );
  }

  /// Sets the maximum width constraint for this widget using a [SizeUnit].
  ///
  /// The widget will not grow beyond this width, even if the parent container
  /// or flex growing would normally make it larger.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Long content that wraps').maxWidth(200.size),
  /// ```
  Widget maxWidth(SizeUnit maxWidth, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      maxWidth: () => maxWidth,
    );
  }

  /// Sets the minimum height constraint for this widget using a [SizeUnit].
  ///
  /// The widget will not shrink below this height, even if the parent container
  /// or flex shrinking would normally make it smaller.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Container().minHeight(50.size),
  /// ```
  Widget minHeight(SizeUnit minHeight, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      minHeight: () => minHeight,
    );
  }

  /// Sets the maximum height constraint for this widget using a [SizeUnit].
  ///
  /// The widget will not grow beyond this height, even if the parent container
  /// or flex growing would normally make it larger.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// ScrollableContent().maxHeight(300.size),
  /// ```
  Widget maxHeight(SizeUnit maxHeight, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      maxHeight: () => maxHeight,
    );
  }

  /// Sets the flex grow factor for this widget within a flex container.
  ///
  /// The flex grow factor determines how much of the remaining space in the
  /// flex container should be assigned to this widget. A value of 1 means the
  /// widget will take its proportional share of extra space.
  ///
  /// This wraps the widget in a [FlexItem] with the specified grow factor.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Container().flexGrow(1),  // Takes 1 part of remaining space
  /// Container().flexGrow(2),  // Takes 2 parts of remaining space
  /// ```
  Widget flexGrow(double flexGrow, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      childType: () => FlexItem,
      flexGrow: () => flexGrow,
    );
  }

  /// Sets the flex shrink factor for this widget within a flex container.
  ///
  /// The flex shrink factor determines how much the widget should shrink
  /// relative to other flex items when there is insufficient space. A value
  /// of 1 means the widget will shrink proportionally with others.
  ///
  /// This wraps the widget in a [FlexItem] with the specified shrink factor.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Container().flexShrink(1),  // Shrinks normally
  /// Container().flexShrink(0),  // Does not shrink
  /// ```
  Widget flexShrink(double flexShrink, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      childType: () => FlexItem,
      flexShrink: () => flexShrink,
    );
  }

  /// Sets the aspect ratio constraint for this widget.
  ///
  /// The aspect ratio is defined as width / height. When set, one dimension
  /// will be automatically calculated based on the other to maintain the ratio.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Image(...).aspectRatio(16 / 9),  // 16:9 aspect ratio
  /// Container().aspectRatio(1.0),     // Square
  /// ```
  Widget aspectRatio(double aspectRatio, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      aspectRatio: () => aspectRatio,
    );
  }

  /// Sets the distance from the top edge of the parent container.
  ///
  /// This positions the widget at a specific offset from the top edge using
  /// a [PositionUnit]. Can be used with absolute or relative positioning.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Header').top(10.position),
  /// Text('Centered').top(0.5.relativePosition),
  /// ```
  Widget top(PositionUnit top, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      top: () => top,
    );
  }

  /// Sets the distance from the left edge of the parent container.
  ///
  /// This positions the widget at a specific offset from the left edge using
  /// a [PositionUnit]. Can be used with absolute or relative positioning.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Left aligned').left(20.position),
  /// Text('Quarter from left').left(0.25.relativePosition),
  /// ```
  Widget left(PositionUnit left, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      left: () => left,
    );
  }

  /// Sets the distance from the bottom edge of the parent container.
  ///
  /// This positions the widget at a specific offset from the bottom edge using
  /// a [PositionUnit]. Can be used with absolute or relative positioning.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Footer').bottom(10.position),
  /// Text('Above bottom').bottom(0.1.relativePosition),
  /// ```
  Widget bottom(PositionUnit bottom, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      bottom: () => bottom,
    );
  }

  /// Sets the distance from the right edge of the parent container.
  ///
  /// This positions the widget at a specific offset from the right edge using
  /// a [PositionUnit]. Can be used with absolute or relative positioning.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Text('Right aligned').right(20.position),
  /// Text('Quarter from right').right(0.25.relativePosition),
  /// ```
  Widget right(PositionUnit right, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      right: () => right,
    );
  }

  /// Positions the widget using multiple edge offsets simultaneously.
  ///
  /// This is a convenience method that allows setting top, left, bottom, and right
  /// positions in a single call. Any combination of edges can be specified.
  ///
  /// Example:
  /// ```dart
  /// Container().positioned(
  ///   top: 10.position,
  ///   left: 20.position,
  /// ),
  /// Container().positioned(
  ///   bottom: 0.position,
  ///   right: 0.position,
  /// ),
  /// ```
  Widget positioned({
    PositionUnit? top,
    PositionUnit? left,
    PositionUnit? bottom,
    PositionUnit? right,
    Key? key,
  }) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      top: top != null ? () => top : null,
      left: left != null ? () => left : null,
      bottom: bottom != null ? () => bottom : null,
      right: right != null ? () => right : null,
    );
  }

  /// Sets both width and height dimensions simultaneously.
  ///
  /// This is a convenience method that allows setting both dimensions in a
  /// single call. Either or both dimensions can be specified.
  ///
  /// Example:
  /// ```dart
  /// Container().sized(
  ///   width: 100.size,
  ///   height: 50.size,
  /// ),
  /// Container().sized(width: 200.size),  // Only width
  /// ```
  Widget sized({
    SizeUnit? width,
    SizeUnit? height,
    Key? key,
  }) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      width: width != null ? () => width : null,
      height: height != null ? () => height : null,
    );
  }

  /// Sets minimum width and height constraints simultaneously.
  ///
  /// This is a convenience method for setting minimum size constraints. The
  /// widget will not shrink below these dimensions. Either or both constraints
  /// can be specified.
  ///
  /// Example:
  /// ```dart
  /// Container().minSized(
  ///   minWidth: 100.size,
  ///   minHeight: 50.size,
  /// ),
  /// ```
  Widget minSized({
    SizeUnit? minWidth,
    SizeUnit? minHeight,
    Key? key,
  }) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      minWidth: minWidth != null ? () => minWidth : null,
      minHeight: minHeight != null ? () => minHeight : null,
    );
  }

  /// Sets maximum width and height constraints simultaneously.
  ///
  /// This is a convenience method for setting maximum size constraints. The
  /// widget will not grow beyond these dimensions. Either or both constraints
  /// can be specified.
  ///
  /// Example:
  /// ```dart
  /// Container().maxSized(
  ///   maxWidth: 300.size,
  ///   maxHeight: 200.size,
  /// ),
  /// ```
  Widget maxSized({
    SizeUnit? maxWidth,
    SizeUnit? maxHeight,
    Key? key,
  }) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      maxWidth: maxWidth != null ? () => maxWidth : null,
      maxHeight: maxHeight != null ? () => maxHeight : null,
    );
  }

  /// Sets comprehensive size constraints including both minimum and maximum bounds.
  ///
  /// This is a convenience method that combines all size constraint options in
  /// a single call. Any combination of minimum and maximum width/height can be
  /// specified to create a constrained size box.
  ///
  /// Example:
  /// ```dart
  /// Container().constrained(
  ///   minWidth: 100.size,
  ///   maxWidth: 300.size,
  ///   minHeight: 50.size,
  ///   maxHeight: 200.size,
  /// ),
  /// ```
  Widget constrained({
    SizeUnit? minWidth,
    SizeUnit? maxWidth,
    SizeUnit? minHeight,
    SizeUnit? maxHeight,
    Key? key,
  }) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      minWidth: minWidth != null ? () => minWidth : null,
      maxWidth: maxWidth != null ? () => maxWidth : null,
      minHeight: minHeight != null ? () => minHeight : null,
      maxHeight: maxHeight != null ? () => maxHeight : null,
    );
  }

  /// Sets the alignment of this widget within its parent flex container.
  ///
  /// This overrides the parent's `alignItems` property for this specific child,
  /// allowing individual control over alignment. Common values include
  /// [BoxAlignment.start], [BoxAlignment.center], [BoxAlignment.end], and
  /// [BoxAlignment.stretch].
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// Container().selfAligned(BoxAlignment.center),
  /// Container().selfAligned(BoxAlignment.stretch),
  /// ```
  Widget selfAligned(BoxAlignmentGeometry alignSelf, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      alignSelf: () => alignSelf,
    );
  }

  /// Sets the position type for this widget to control positioning context.
  ///
  /// Determines whether this widget establishes a positioning context for its
  /// absolutely positioned children (when used with [AbsoluteItem]).
  ///
  /// - [PositionType.none] (default): Does not establish a positioning context.
  ///   Absolutely positioned children will skip this element and position themselves
  ///   relative to the nearest ancestor with [PositionType.relative].
  ///
  /// - [PositionType.relative]: Establishes a positioning context. Absolutely
  ///   positioned children will position themselves relative to this element's edges.
  ///
  /// This is similar to CSS positioning where `position: static` doesn't create a
  /// containing block, while `position: relative` does.
  ///
  /// The optional [key] parameter assigns a key to the wrapped widget.
  ///
  /// Example:
  /// ```dart
  /// // Create a positioning context for absolutely positioned children
  /// Container()
  ///   .position(PositionType.relative)
  ///   .width(200.size)
  ///   .height(200.size),
  /// ```
  Widget position(PositionType position, [Key? key]) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: key != null ? () => key : null,
      position: () => position,
    );
  }

  /// Assigns a [Key] to this widget.
  ///
  /// Keys are used to preserve state when widgets move around in the tree.
  /// This method provides a fluent way to assign a key to a widget.
  ///
  /// Example:
  /// ```dart
  /// Container().key(GlobalKey()),
  /// Text('Hello').key(UniqueKey()),
  /// ```
  Widget key(Key key) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: () => key,
    );
  }

  /// Assigns a [ValueKey] to this widget using the provided value.
  ///
  /// This is a convenience method for creating and assigning a [ValueKey].
  /// Value keys are useful for identifying widgets based on their data values.
  ///
  /// Example:
  /// ```dart
  /// Container().id('unique-id'),
  /// ListTile(title: Text(item.name)).id(item.id),
  /// ```
  Widget id(Object valueKey) {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      key: () => ValueKey(valueKey),
    );
  }

  /// Explicitly wraps this widget as a [FlexItem].
  ///
  /// This is useful when you want to ensure the widget participates in flex
  /// layout but haven't applied any other flex-specific properties yet. Most
  /// of the time this is not needed as other methods like [flexGrow] and
  /// [flexShrink] automatically wrap in a [FlexItem].
  ///
  /// Example:
  /// ```dart
  /// Container().asFlexItem,
  /// ```
  Widget get asFlexItem {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      childType: () => FlexItem,
    );
  }

  /// Explicitly wraps this widget as an [AbsoluteItem].
  ///
  /// This removes the widget from the normal flex flow and allows absolute
  /// positioning within the parent container. The widget can then be positioned
  /// using [top], [left], [bottom], and [right] methods.
  ///
  /// Example:
  /// ```dart
  /// Container()
  ///   .asAbsoluteItem
  ///   .positioned(top: 10.position, left: 10.position),
  /// ```
  Widget get asAbsoluteItem {
    return _WidgetWrapper._wrapOrCopyWith(
      child: this,
      childType: () => AbsoluteItem,
    );
  }
}

class _WidgetWrapper extends StatelessWidget {
  static Widget _wrapOrCopyWith({
    ValueGetter<Key?>? key,
    required Widget child,
    ValueGetter<Type>? childType,
    ValueGetter<int?>? paintOrder,
    ValueGetter<SizeUnit?>? width,
    ValueGetter<SizeUnit?>? height,
    ValueGetter<SizeUnit?>? minWidth,
    ValueGetter<SizeUnit?>? maxWidth,
    ValueGetter<SizeUnit?>? minHeight,
    ValueGetter<SizeUnit?>? maxHeight,
    ValueGetter<double>? flexGrow,
    ValueGetter<double>? flexShrink,
    ValueGetter<double?>? aspectRatio,
    ValueGetter<PositionUnit?>? top,
    ValueGetter<PositionUnit?>? left,
    ValueGetter<PositionUnit?>? bottom,
    ValueGetter<PositionUnit?>? right,
    ValueGetter<BoxAlignmentGeometry?>? alignSelf,
    ValueGetter<PositionType?>? position,
  }) {
    if (child is _WidgetWrapper) {
      return child.copyWith(
        key: key,
        childType: childType,
        paintOrder: paintOrder,
        width: width,
        height: height,
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
        flexGrow: flexGrow,
        flexShrink: flexShrink,
        aspectRatio: aspectRatio,
        top: top,
        left: left,
        bottom: bottom,
        right: right,
        alignSelf: alignSelf,
        position: position,
      );
    } else {
      return _WidgetWrapper(
        key: key != null ? key() : null,
        childType: childType != null ? childType() : FlexItem,
        paintOrder: paintOrder != null ? paintOrder() : null,
        width: width != null ? width() : null,
        height: height != null ? height() : null,
        minWidth: minWidth != null ? minWidth() : null,
        maxWidth: maxWidth != null ? maxWidth() : null,
        minHeight: minHeight != null ? minHeight() : null,
        maxHeight: maxHeight != null ? maxHeight() : null,
        flexGrow: flexGrow != null ? flexGrow() : 0,
        flexShrink: flexShrink != null ? flexShrink() : 0,
        aspectRatio: aspectRatio != null ? aspectRatio() : null,
        top: top != null ? top() : null,
        left: left != null ? left() : null,
        bottom: bottom != null ? bottom() : null,
        right: right != null ? right() : null,
        alignSelf: alignSelf != null ? alignSelf() : null,
        position: position != null ? position() : null,
        child: child,
      );
    }
  }

  final Type childType;
  final int? paintOrder;
  final SizeUnit? width;
  final SizeUnit? height;
  final SizeUnit? minWidth;
  final SizeUnit? maxWidth;
  final SizeUnit? minHeight;
  final SizeUnit? maxHeight;
  final double flexGrow;
  final double flexShrink;
  final double? aspectRatio;
  final PositionUnit? top;
  final PositionUnit? left;
  final PositionUnit? bottom;
  final PositionUnit? right;
  final BoxAlignmentGeometry? alignSelf;
  final PositionType? position;
  final Widget child;

  const _WidgetWrapper({
    super.key,
    required this.childType,
    this.paintOrder,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.flexGrow = 0,
    this.flexShrink = 0,
    this.aspectRatio,
    this.top,
    this.left,
    this.bottom,
    this.right,
    this.alignSelf,
    this.position,
    required this.child,
  });

  _WidgetWrapper copyWith({
    ValueGetter<Key?>? key,
    ValueGetter<Type>? childType,
    ValueGetter<int?>? paintOrder,
    ValueGetter<SizeUnit?>? width,
    ValueGetter<SizeUnit?>? height,
    ValueGetter<SizeUnit?>? minWidth,
    ValueGetter<SizeUnit?>? maxWidth,
    ValueGetter<SizeUnit?>? minHeight,
    ValueGetter<SizeUnit?>? maxHeight,
    ValueGetter<double>? flexGrow,
    ValueGetter<double>? flexShrink,
    ValueGetter<double?>? aspectRatio,
    ValueGetter<PositionUnit?>? top,
    ValueGetter<PositionUnit?>? left,
    ValueGetter<PositionUnit?>? bottom,
    ValueGetter<PositionUnit?>? right,
    ValueGetter<BoxAlignmentGeometry?>? alignSelf,
    ValueGetter<PositionType?>? position,
    ValueGetter<Widget>? child,
  }) {
    return _WidgetWrapper(
      key: key != null ? key() : this.key,
      childType: childType != null ? childType() : this.childType,
      paintOrder: paintOrder != null ? paintOrder() : this.paintOrder,
      width: width != null ? width() : this.width,
      height: height != null ? height() : this.height,
      minWidth: minWidth != null ? minWidth() : this.minWidth,
      maxWidth: maxWidth != null ? maxWidth() : this.maxWidth,
      minHeight: minHeight != null ? minHeight() : this.minHeight,
      maxHeight: maxHeight != null ? maxHeight() : this.maxHeight,
      flexGrow: flexGrow != null ? flexGrow() : this.flexGrow,
      flexShrink: flexShrink != null ? flexShrink() : this.flexShrink,
      aspectRatio: aspectRatio != null ? aspectRatio() : this.aspectRatio,
      top: top != null ? top() : this.top,
      left: left != null ? left() : this.left,
      bottom: bottom != null ? bottom() : this.bottom,
      right: right != null ? right() : this.right,
      alignSelf: alignSelf != null ? alignSelf() : this.alignSelf,
      position: position != null ? position() : this.position,
      child: child != null ? child() : this.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (childType) {
      case const (FlexItem):
        return FlexItem(
          key: key,
          paintOrder: paintOrder,
          width: width,
          height: height,
          minWidth: minWidth,
          maxWidth: maxWidth,
          minHeight: minHeight,
          maxHeight: maxHeight,
          flexGrow: flexGrow,
          flexShrink: flexShrink,
          aspectRatio: aspectRatio,
          alignSelf: alignSelf,
          position: position,
          top: top,
          left: left,
          bottom: bottom,
          right: right,
          child: child,
        );
      case const (AbsoluteItem):
        return AbsoluteItem(
          key: key,
          paintOrder: paintOrder,
          width: width,
          height: height,
          minWidth: minWidth,
          maxWidth: maxWidth,
          minHeight: minHeight,
          maxHeight: maxHeight,
          aspectRatio: aspectRatio,
          top: top,
          left: left,
          bottom: bottom,
          right: right,
          child: child,
        );
      default:
        return child;
    }
  }
}
