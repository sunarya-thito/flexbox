import 'package:flexiblebox/flexiblebox.dart';
import 'package:flexiblebox/flexiblebox_extensions.dart';
import 'package:flutter/material.dart';
import 'package:playground/code.dart';
import 'package:playground/config.dart';
import 'package:playground/value.dart';

mixin PropertyHolder implements ChangeNotifier {
  @override
  void notifyListeners();
}

class _Store<T> {
  final T value;

  _Store(this.value);
}

abstract interface class Property<T> {
  factory Property({
    required String name,
    required String description,
    required T defaultValue,
    required PropertyHolder owner,
  }) = SimpleProperty<T>;
  String get name;
  String get description;
  T get defaultValue;
  T get value;
  set value(T newValue);
  PropertyHolder get owner;
  Type get type => T;
  CompoundProperty<T> followedBy(Property<T> other);
  void reset();
}

class SimpleProperty<T> implements Property<T> {
  @override
  final String name;
  @override
  final String description;
  @override
  final T defaultValue;
  _Store<T>? _value;
  @override
  final PropertyHolder owner;

  @override
  Type get type => T;

  SimpleProperty({
    required this.name,
    required this.description,
    required this.defaultValue,
    required this.owner,
  }) {
    _value = _Store(defaultValue);
  }

  @override
  T get value {
    if (_value == null) {
      return defaultValue;
    }
    return _value!.value;
  }

  @override
  set value(T newValue) {
    if (_value == null || _value!.value != newValue) {
      _value = _Store(newValue);
      owner.notifyListeners();
    }
  }

  @override
  void reset() {
    if (_value != null) {
      _value = null;
      owner.notifyListeners();
    }
  }

  @override
  CompoundProperty<T> followedBy(Property<T> other) {
    return CompoundProperty<T>(properties: [this, other]);
  }
}

class _PropertyKey {
  final String name;
  final Type type;

  const _PropertyKey(this.name, this.type);

  @override
  bool operator ==(Object other) {
    if (other is! _PropertyKey) {
      return false;
    }
    return other.name == name && other.type == type;
  }

  @override
  int get hashCode => Object.hash(name, type);
}

class CompoundProperty<T> implements Property<T> {
  static Iterable<Property> ofAll(Iterable<Property> properties) sync* {
    final map = <_PropertyKey, List<Property>>{};
    for (final prop in properties) {
      final key = _PropertyKey(prop.name, prop.type);
      map.putIfAbsent(key, () => []).add(prop);
    }
    for (final entry in map.entries) {
      if (entry.value.length > 1) {
        Property prop = entry.value.first;
        for (final other in entry.value.skip(1)) {
          prop = prop.followedBy(other);
        }
        yield prop;
      }
    }
  }

  // all properties are the same name & type
  final Iterable<Property<T>> properties;

  CompoundProperty({
    required this.properties,
  }) : assert(properties.isNotEmpty);

  @override
  void reset() {
    for (final prop in properties) {
      prop.reset();
    }
  }

  @override
  Type get type => properties.first.type;

  @override
  String get name => properties.first.name;

  @override
  String get description => properties.first.description;

  @override
  T get defaultValue => properties.first.defaultValue;

  @override
  CompoundProperty<T> followedBy(Property<T> other) {
    return CompoundProperty<T>(
      properties: [...properties, other],
    );
  }

  @override
  T get value {
    T firstValue = properties.first.value;
    for (final prop in properties) {
      if (prop.value != firstValue) {
        return defaultValue;
      }
    }
    return firstValue;
  }

  @override
  set value(T newValue) {
    for (final prop in properties) {
      prop.value = newValue;
    }
  }

  @override
  PropertyHolder get owner => properties.first.owner;

  @override
  int get hashCode => Object.hashAll(properties);

  @override
  bool operator ==(Object other) {
    if (other is! CompoundProperty<T>) {
      return false;
    }
    if (other.properties.length != properties.length) {
      return false;
    }
    final it1 = properties.iterator;
    final it2 = other.properties.iterator;
    while (it1.moveNext() && it2.moveNext()) {
      if (it1.current != it2.current) {
        return false;
      }
    }
    return true;
  }
}

class FlexBoxController with ChangeNotifier implements PropertyHolder {
  bool multiSelect = false;
  late final Property<Axis> direction = Property<Axis>(
    name: 'direction',
    description: 'The direction of the flexbox layout.',
    defaultValue: Axis.horizontal,
    owner: this,
  );
  late final Property<BoxValue?> spacing = Property<BoxValue?>(
    name: 'spacing',
    description: 'The spacing between children.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxValue?> spacingStart = Property<BoxValue?>(
    name: 'spacingStart',
    description: 'The spacing before the first child.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxValue?> spacingEnd = Property<BoxValue?>(
    name: 'spacingEnd',
    description: 'The spacing after the last child.',
    defaultValue: null,
    owner: this,
  );
  late final Property<AlignmentGeometry> alignment =
      Property<AlignmentGeometry>(
        name: 'alignment',
        description: 'The alignment of the children.',
        defaultValue: AlignmentGeometry.center,
        owner: this,
      );
  // late final Property<List<FlexItemController>> _children =
  //     Property<List<FlexItemController>>(
  //       name: 'children',
  //       description: 'The children of the flexbox.',
  //       defaultValue: [],
  //       owner: this,
  //     );
  List<FlexItemController> _children = [];
  late final Property<int> _visibleChildCount = Property<int>(
    name: 'visibleChildCount',
    description: 'The number of visible children.',
    defaultValue: 0,
    owner: this,
  );
  late final Property<bool> scrollHorizontal = Property<bool>(
    name: 'scrollHorizontal',
    description: 'Whether the flexbox is scrollable horizontally.',
    defaultValue: false,
    owner: this,
  );
  late final Property<bool> scrollVertical = Property<bool>(
    name: 'scrollVertical',
    description: 'Whether the flexbox is scrollable vertically.',
    defaultValue: false,
    owner: this,
  );
  late final Property<Clip> clipBehavior = Property<Clip>(
    name: 'clipBehavior',
    description: 'The clip behavior of the flexbox.',
    defaultValue: Clip.hardEdge,
    owner: this,
  );
  late final Property<EdgeInsetsGeometry> padding =
      Property<EdgeInsetsGeometry>(
        name: 'padding',
        description: 'The padding of the flexbox.',
        defaultValue: EdgeInsets.zero,
        owner: this,
      );
  late final Property<bool> reverse = Property<bool>(
    name: 'reverse',
    description: 'Whether the flexbox is reversed.',
    defaultValue: false,
    owner: this,
  );
  late final Property<bool> reversePaint = Property<bool>(
    name: 'reversePaint',
    description: 'Whether the flexbox is reversed in paint order.',
    defaultValue: false,
    owner: this,
  );
  late final Property<TextDirection> textDirection = Property<TextDirection>(
    name: 'textDirection',
    description: 'The text direction of the flexbox.',
    defaultValue: TextDirection.ltr,
    owner: this,
  );
  late final Property<double?> width = Property<double?>(
    name: 'width',
    description: 'The width of the flexbox.',
    defaultValue: null,
    owner: this,
  );
  late final Property<double?> height = Property<double?>(
    name: 'height',
    description: 'The height of the flexbox.',
    defaultValue: null,
    owner: this,
  );

  static const maxCachedChildren = 50;
  List<FlexItemController> get children => _children;

  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController selectionHorizontalScrollController =
      ScrollController();
  final ScrollController selectionVerticalScrollController = ScrollController();

  FlexBoxController() {
    horizontalScrollController.addListener(() {
      selectionHorizontalScrollController.jumpTo(
        horizontalScrollController.offset,
      );
      notifyListeners();
    });
    verticalScrollController.addListener(() {
      selectionVerticalScrollController.jumpTo(
        verticalScrollController.offset,
      );
      notifyListeners();
    });
    addListener(() {
      if (preventUpdate) {
        return;
      }
      updateChildrenCount(_visibleChildCount.value);
    });
  }

  bool preventUpdate = false;

  void updateChildrenCount(int count) {
    // allocate more children if needed
    // but if we have too many, we dont deallocate
    // we simply keep them for later use
    // unless we have too many (that exceeds maxCachedChildren)
    // maxCachedChildren is not the max number of children
    // it is the max number of cached children
    int length = _children.length;
    if (length < count) {
      List<FlexItemController> newChildren = List.generate(count, (index) {
        if (index < length) {
          final old = _children[index];
          old._selected = false;
          return old;
        }
        final newChild = FlexItemController(this);
        preventUpdate = true;
        newChild.mainSize.value = 100.px;
        newChild.crossSize.value = 100.px;
        preventUpdate = false;
        return newChild;
      });
      _children = newChildren;
    } else if (length > count) {
      if (length > maxCachedChildren) {
        _children = _children.sublist(0, maxCachedChildren);
      }
    }
  }

  void select(FlexItemController? item) {
    for (final child in _children.sublist(0, _visibleChildCount.value)) {
      child.selected = child == item;
    }
    notifyListeners();
  }

  bool get hasSelection {
    for (final child in _children.sublist(0, _visibleChildCount.value)) {
      if (child.selected) {
        return true;
      }
    }
    return false;
  }

  Iterable<Property> get selectedProperties sync* {
    if (hasSelection) {
      final selected = selectedItems.toList();
      if (selected.length == 1) {
        yield* selected.first.allProperties;
      } else {
        yield* CompoundProperty.ofAll(
          selected.expand((e) => e.allProperties),
        );
      }
    } else {
      yield* allProperties;
    }
  }

  final GlobalKey selectionContainerKey = GlobalKey();
  final GlobalKey containerKey = GlobalKey();

  // Widget buildSelection() {
  //   return ListenableBuilder(
  //     key: selectionContainerKey,
  //     listenable: this,
  //     builder: (context, _) {
  //       return Container(
  //         width: width.value,
  //         height: height.value,
  //         decoration: BoxDecoration(
  //           border: Border.all(
  //             color: !hasSelection ? Colors.blue : Colors.transparent,
  //             width: 4,
  //             strokeAlign: BorderSide.strokeAlignOutside,
  //           ),
  //         ),
  //         child: FlexBox(
  //           horizontalController: selectionHorizontalScrollController,
  //           verticalController: selectionVerticalScrollController,
  //           direction: direction.value,
  //           spacing: spacing.value,
  //           spacingStart: spacingStart.value,
  //           spacingEnd: spacingEnd.value,
  //           alignment: alignment.value,
  //           scrollHorizontal: scrollHorizontal.value,
  //           scrollVertical: scrollVertical.value,
  //           clipBehavior: Clip.none,
  //           padding: padding.value,
  //           reverse: reverse.value,
  //           reversePaint: reversePaint.value,
  //           textDirection: textDirection.value,
  //           children: List.generate(_visibleChildCount.value, (index) {
  //             return _children[index].buildSelection(index);
  //           }),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget build() {
    return ListenableBuilder(
      key: containerKey,
      listenable: this,
      builder: (context, _) {
        return GestureDetector(
          onTap: () {
            select(null);
          },
          child: Container(
            width: width.value,
            height: height.value,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                FlexBox(
                  horizontalController: horizontalScrollController,
                  verticalController: verticalScrollController,
                  direction: direction.value,
                  spacing: spacing.value,
                  spacingStart: spacingStart.value,
                  spacingEnd: spacingEnd.value,
                  alignment: alignment.value,
                  scrollHorizontal: scrollHorizontal.value,
                  scrollVertical: scrollVertical.value,
                  clipBehavior: clipBehavior.value,
                  padding: padding.value,
                  reverse: reverse.value,
                  reversePaint: reversePaint.value,
                  textDirection: textDirection.value,
                  children: List.generate(_visibleChildCount.value, (index) {
                    return _children[index].build(index);
                  }),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: !hasSelection
                              ? Colors.blue
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void applyConfiguration(FlexBoxConfiguration config) {
    width.value = config.width;
    height.value = config.height;
    direction.value = config.direction;
    spacing.value = config.spacing;
    spacingStart.value = config.spacingStart;
    spacingEnd.value = config.spacingEnd;
    alignment.value = config.alignment;
    scrollHorizontal.value = config.scrollHorizontal;
    scrollVertical.value = config.scrollVertical;
    clipBehavior.value = config.clipBehavior;
    padding.value = config.padding;
    reverse.value = config.reverse;
    reversePaint.value = config.reversePaint;
    textDirection.value = config.textDirection;
    _visibleChildCount.value = config.children.length;
    _children = config.children.map((e) {
      final item = FlexItemController(this);
      item.applyConfiguration(e);
      return item;
    }).toList();
  }

  FlexBoxConfiguration toConfiguration() {
    return FlexBoxConfiguration(
      width: width.value,
      height: height.value,
      direction: direction.value,
      spacing: spacing.value,
      spacingStart: spacingStart.value,
      spacingEnd: spacingEnd.value,
      alignment: alignment.value,
      scrollHorizontal: scrollHorizontal.value,
      scrollVertical: scrollVertical.value,
      clipBehavior: clipBehavior.value,
      padding: padding.value,
      reverse: reverse.value,
      reversePaint: reversePaint.value,
      textDirection: textDirection.value,
      children: List.generate(_visibleChildCount.value, (index) {
        return _children[index].toConfiguration();
      }),
    );
  }

  Iterable<Property> get allProperties sync* {
    yield _visibleChildCount;
    yield width;
    yield height;
    yield direction;
    yield spacing;
    yield spacingStart;
    yield spacingEnd;
    yield alignment;
    yield scrollHorizontal;
    yield scrollVertical;
    yield clipBehavior;
    yield padding;
    yield reverse;
    yield reversePaint;
    yield textDirection;
  }

  Iterable<FlexItemController> get selectedItems sync* {
    for (final item in _children.sublist(0, _visibleChildCount.value)) {
      if (item.selected) {
        yield item;
      }
    }
  }

  Code buildCode() {
    return Code('FlexBox').thenBracketParentheses([
      if (direction.value != Axis.horizontal)
        Code('direction: ').concat(
          Code.enumValue('Axis', direction.value.name),
        ),
      if (spacing.value != null)
        Code(
          'spacing: ',
        ).concat(Code.boxValue(spacing.value!)),
      if (spacingStart.value != null)
        Code(
          'spacingStart: ',
        ).concat(Code.boxValue(spacingStart.value!)),
      if (spacingEnd.value != null)
        Code(
          'spacingEnd: ',
        ).concat(Code.boxValue(spacingEnd.value!)),
      if (alignment.value != AlignmentGeometry.center)
        Code(
          'alignment: ',
        ).concat(Code.alignment(alignment.value)),
      if (scrollHorizontal.value) Code('scrollHorizontal: true,'),
      if (scrollVertical.value) Code('scrollVertical: true,'),
      if (clipBehavior.value != Clip.hardEdge)
        Code(
          'clipBehavior: ',
        ).concat(Code.enumValue('Clip', clipBehavior.value.name)),
      if (padding.value != EdgeInsets.zero)
        Code(
          'padding: ',
        ).concat(Code.edgeInsets(padding.value)),
      if (reverse.value) Code('reverse: true,'),
      if (reversePaint.value) Code('reversePaint: true,'),
      if (textDirection.value != TextDirection.ltr)
        Code('textDirection: ').concat(
          Code.enumValue('TextDirection', textDirection.value.name),
        ),
      if (_visibleChildCount.value > 0)
        Code('children: ').thenBracketSquare(
          List.generate(_visibleChildCount.value, (index) {
            return children[index].buildCode(index);
          }),
        ),
    ]);
  }
}

class FlexItemController implements PropertyHolder {
  final FlexBoxController parent;

  FlexItemController(this.parent);

  @override
  void notifyListeners() {
    parent.notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    parent.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    parent.removeListener(listener);
  }

  @override
  bool get hasListeners => parent.hasListeners;

  @override
  void dispose() {
    // do nothing, parent owns the lifecycle
  }

  bool _selected = false;
  bool get selected => _selected;
  set selected(bool value) {
    if (_selected != value) {
      _selected = value;
      notifyListeners();
    }
  }

  late final Property<bool> absolute = Property<bool>(
    name: 'absolute',
    description:
        'Whether the item is positioned absolutely. Overriden when mainStart, mainEnd, crossStart or crossEnd is set.',
    defaultValue: false,
    owner: this,
  );
  late final Property<BoxValue?> mainStart = Property<BoxValue?>(
    name: 'mainStart',
    description: 'The main axis start position of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxValue?> mainEnd = Property<BoxValue?>(
    name: 'mainEnd',
    description: 'The main axis end position of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxValue?> crossStart = Property<BoxValue?>(
    name: 'crossStart',
    description: 'The cross axis start position of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxValue?> crossEnd = Property<BoxValue?>(
    name: 'crossEnd',
    description: 'The cross axis end position of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxValue?> mainSize = Property<BoxValue?>(
    name: 'mainSize',
    description: 'The main axis size of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxValue?> crossSize = Property<BoxValue?>(
    name: 'crossSize',
    description: 'The cross axis size of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxPositionType> mainPosition = Property<BoxPositionType>(
    name: 'mainPosition',
    description: 'The main axis position type of the item.',
    defaultValue: BoxPositionType.fixed,
    owner: this,
  );
  late final Property<BoxPositionType> crossPosition =
      Property<BoxPositionType>(
        name: 'crossPosition',
        description: 'The cross axis position type of the item.',
        defaultValue: BoxPositionType.fixed,
        owner: this,
      );
  late final Property<int?> zOrder = Property<int?>(
    name: 'zOrder',
    description: 'The z-order of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<bool> mainScrollAffected = Property<bool>(
    name: 'mainScrollAffected',
    description: 'Whether the item is affected by main axis scrolling.',
    defaultValue: true,
    owner: this,
  );
  late final Property<bool> crossScrollAffected = Property<bool>(
    name: 'crossScrollAffected',
    description: 'Whether the item is affected by cross axis scrolling.',
    defaultValue: true,
    owner: this,
  );
  late final Property<Color?> color = Property<Color?>(
    name: 'color',
    description: 'The background color of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<bool> showLabel = Property<bool>(
    name: 'showLabel',
    description: 'Whether to show the label of the item.',
    defaultValue: true,
    owner: this,
  );
  late final Property<String?> label = Property<String?>(
    name: 'label',
    description: 'The label of the item.',
    defaultValue: null,
    owner: this,
  );
  late final Property<BoxShape> shape = Property<BoxShape>(
    name: 'shape',
    description: 'The shape of the item.',
    defaultValue: BoxShape.rectangle,
    owner: this,
  );

  // Widget buildSelection(int index) {
  //   // build the same item, but without decoration except the selection border
  //   return DirectionalFlexItem(
  //     absolute: absolute.value,
  //     mainStart: mainStart.value,
  //     mainEnd: mainEnd.value,
  //     crossStart: crossStart.value,
  //     crossEnd: crossEnd.value,
  //     mainSize: mainSize.value,
  //     crossSize: crossSize.value,
  //     mainPosition: mainPosition.value,
  //     crossPosition: crossPosition.value,
  //     zOrder: zOrder.value,
  //     mainScrollAffected: mainScrollAffected.value,
  //     crossScrollAffected: crossScrollAffected.value,
  //     child: SizedBox(
  //       width: 100,
  //       height: 100,
  //       child: LayoutBuilder(
  //         builder: (context, constraints) {
  //           return Container(
  //             decoration: BoxDecoration(
  //               border: Border.all(
  //                 color: selected ? Colors.blue : Colors.transparent,
  //                 width: 4,
  //                 strokeAlign: BorderSide.strokeAlignOutside,
  //               ),
  //             ),
  //             child: Opacity(
  //               opacity: 0,
  //               child: showLabel.value
  //                   ? Text(
  //                       label.value ??
  //                           'Item ${index + 1}\n(${optimalDoubleString(constraints.maxWidth)} x ${optimalDoubleString(constraints.maxHeight)})',
  //                       textAlign: TextAlign.center,
  //                     )
  //                   : null,
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget build(int index) {
    return DirectionalFlexItem(
      absolute: absolute.value,
      mainStart: mainStart.value,
      mainEnd: mainEnd.value,
      crossStart: crossStart.value,
      crossEnd: crossEnd.value,
      mainSize: mainSize.value,
      crossSize: crossSize.value,
      mainPosition: mainPosition.value,
      crossPosition: crossPosition.value,
      zOrder: zOrder.value,
      mainScrollAffected: mainScrollAffected.value,
      crossScrollAffected: crossScrollAffected.value,
      child: GestureDetector(
        onTap: () {
          if (parent.multiSelect) {
            selected = !selected;
            parent.notifyListeners();
          } else {
            parent.select(this);
          }
        },
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          color.value ??
                          Colors.primaries[index % Colors.primaries.length],
                      shape: shape.value,
                    ),
                    alignment: Alignment.center,
                    child: showLabel.value
                        ? Text(
                            label.value ??
                                'Item ${index + 1}\n(${optimalDoubleString(constraints.maxWidth)} x ${optimalDoubleString(constraints.maxHeight)})',
                            textAlign: TextAlign.center,
                          )
                        : null,
                  );
                },
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? Colors.blue : Colors.transparent,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void applyConfiguration(FlexItemConfiguration config) {
    absolute.value = config.absolute;
    mainStart.value = config.mainStart;
    mainEnd.value = config.mainEnd;
    crossStart.value = config.crossStart;
    crossEnd.value = config.crossEnd;
    mainSize.value = config.mainSize;
    crossSize.value = config.crossSize;
    mainPosition.value = config.mainPosition;
    crossPosition.value = config.crossPosition;
    zOrder.value = config.zOrder;
    mainScrollAffected.value = config.mainScrollAffected;
    crossScrollAffected.value = config.crossScrollAffected;
  }

  FlexItemConfiguration toConfiguration() {
    return FlexItemConfiguration(
      absolute: absolute.value,
      mainStart: mainStart.value,
      mainEnd: mainEnd.value,
      crossStart: crossStart.value,
      crossEnd: crossEnd.value,
      mainSize: mainSize.value,
      crossSize: crossSize.value,
      mainPosition: mainPosition.value,
      crossPosition: crossPosition.value,
      zOrder: zOrder.value,
      mainScrollAffected: mainScrollAffected.value,
      crossScrollAffected: crossScrollAffected.value,
    );
  }

  Iterable<Property> get allProperties sync* {
    yield absolute;
    yield mainStart;
    yield mainEnd;
    yield crossStart;
    yield crossEnd;
    yield mainSize;
    yield crossSize;
    yield mainPosition;
    yield crossPosition;
    yield zOrder;
    yield mainScrollAffected;
    yield crossScrollAffected;
    yield color;
    yield showLabel;
    yield label;
    yield shape;
  }

  Code buildCode(int index) {
    return Code('DirectionalFlexItem').thenBracketParentheses(
      [
        if (absolute.value) Code('absolute: true,'),
        if (mainStart.value != null)
          Code(
            'mainStart: ',
          ).concat(Code.boxValue(mainStart.value!)),
        if (mainEnd.value != null)
          Code(
            'mainEnd: ',
          ).concat(Code.boxValue(mainEnd.value!)),
        if (crossStart.value != null)
          Code(
            'crossStart: ',
          ).concat(Code.boxValue(crossStart.value!)),
        if (crossEnd.value != null)
          Code(
            'crossEnd: ',
          ).concat(Code.boxValue(crossEnd.value!)),
        if (mainSize.value != null)
          Code(
            'mainSize: ',
          ).concat(Code.boxValue(mainSize.value!)),
        if (crossSize.value != null)
          Code(
            'crossSize: ',
          ).concat(Code.boxValue(crossSize.value!)),
        if (mainPosition.value != BoxPositionType.fixed)
          Code('mainPosition: ').concat(
            Code.enumValue('BoxPositionType', mainPosition.value.name),
          ),
        if (crossPosition.value != BoxPositionType.fixed)
          Code('crossPosition: ').concat(
            Code.enumValue('BoxPositionType', crossPosition.value.name),
          ),
        if (zOrder.value != null) Code('zOrder: ${zOrder.value}'),
        if (!mainScrollAffected.value) Code('mainScrollAffected: false'),
        if (!crossScrollAffected.value) Code('crossScrollAffected: false'),
        Code('child: Container').thenBracketParentheses([
          if (color.value != null)
            Code('decoration: BoxDecoration').thenBracketParentheses([
              Code('color: ').concat(Code.color(color.value!)),
              if (shape.value != BoxShape.rectangle)
                Code('shape: ').concat(
                  Code.enumValue('BoxShape', shape.value.name),
                ),
            ]),
          if (showLabel.value) Code('alignment: Alignment.center'),
          if (showLabel.value)
            Code('child: ').concat(
              Code('Text(\'${label.value ?? 'Item ${index + 1}'}\')'),
            ),
        ]),
      ],
    );
  }
}
