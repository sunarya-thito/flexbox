import 'package:flexiblebox/flexiblebox.dart';
import 'package:flexiblebox/flexiblebox_extensions.dart';
import 'package:flutter/widgets.dart';

enum MathOperation { add, subtract, multiply, divide, modulo, floorDivide }

enum ValueUnit { fixed, viewportSize, contentSize, childSize, flex, ratio }

BoxValue _clampFunction(List<BoxValue> args) {
  if (args.length != 3) {
    throw ArgumentError('clamp requires exactly 3 arguments');
  }
  return args[0].clamp(min: args[1], max: args[2]);
}

BoxValue _absFunction(List<BoxValue> args) {
  if (args.length != 1) {
    throw ArgumentError('abs requires exactly 1 argument');
  }
  return args[0].abs();
}

BoxValue _minFunction(List<BoxValue> args) {
  if (args.length != 2) {
    throw ArgumentError('min requires exactly 2 arguments');
  }
  return BoxComputer(args[0], args[0], BoxComputer.min);
}

BoxValue _maxFunction(List<BoxValue> args) {
  if (args.length != 2) {
    throw ArgumentError('max requires exactly 2 arguments');
  }
  return BoxComputer(args[0], args[0], BoxComputer.max);
}

enum ValueFunction {
  clamp(3, _clampFunction),
  abs(1, _absFunction),
  min(2, _minFunction),
  max(2, _maxFunction);

  final int argumentCount;
  final BoxValue Function(List<BoxValue>) function;

  const ValueFunction(this.argumentCount, this.function);
}

class StringTokenizer {
  bool nextAlignCenterStart() {
    return nextString('alignCenterStart');
  }

  bool nextAlignCenterEnd() {
    return nextString('alignCenterEnd');
  }

  bool nextAlignStartCenter() {
    return nextString('alignStartCenter');
  }

  bool nextAlignStartEnd() {
    return nextString('alignStartEnd');
  }

  bool nextAlignEndStart() {
    return nextString('alignEndStart');
  }

  bool nextAlignEndCenter() {
    return nextString('alignEndCenter');
  }

  final String source;
  int position = 0;

  StringTokenizer(this.source);

  bool get hasMoreTokens => position < source.length;

  double? nextDouble() {
    final start = position;
    bool hasDecimal = false;
    if (position < source.length &&
        (source.codeUnitAt(position) == 45 ||
            source.codeUnitAt(position) == 43)) {
      // '-' or '+'
      position++;
    }
    while (position < source.length) {
      final codeUnit = source.codeUnitAt(position);
      if (isDigit(codeUnit)) {
        position++;
      } else if (codeUnit == 46 && !hasDecimal) {
        // '.'
        hasDecimal = true;
        position++;
      } else {
        break;
      }
    }
    if (start == position) {
      return null;
    }
    return double.parse(source.substring(start, position));
  }

  static bool isDigit(int codeUnit) {
    return codeUnit >= 48 && codeUnit <= 57; // '0' to '9'
  }

  void skipWhitespace() {
    while (position < source.length &&
        isWhitespace(source.codeUnitAt(position))) {
      position++;
    }
  }

  static bool isWhitespace(int codeUnit) {
    return codeUnit == 32 ||
        codeUnit == 9 ||
        codeUnit == 10 ||
        codeUnit == 13; // space, tab, LF, CR
  }

  bool nextString(String str) {
    if (source.startsWith(str, position)) {
      position += str.length;
      return true;
    }
    return false;
  }

  bool nextIntrinsic() {
    return nextString('intrinsic');
  }

  bool nextAlignCenter() {
    return nextString('alignCenter');
  }

  bool nextAlignStart() {
    return nextString('alignStart');
  }

  bool nextAlignEnd() {
    return nextString('alignEnd');
  }

  bool nextExpanding() {
    return nextString('expanding');
  }

  bool nextSmallestExpanding() {
    return nextString('smallestExpanding');
  }

  bool nextAbsolute() {
    return nextString('|');
  }

  FlexTarget? nextFlexTarget() {
    if (nextString('content')) {
      return FlexTarget.content;
    } else if (nextString('child')) {
      return FlexTarget.child;
    } else if (nextString('viewport')) {
      return FlexTarget.viewport;
    } else if (nextString('line')) {
      return FlexTarget.line;
    }
    return null;
  }

  MathOperation? nextMathOperation() {
    if (nextString('+')) {
      return MathOperation.add;
    } else if (nextString('-')) {
      return MathOperation.subtract;
    } else if (nextString('*')) {
      return MathOperation.multiply;
    } else if (nextString('/')) {
      return MathOperation.divide;
    }
    return null;
  }

  ValueUnit? nextValueUnit() {
    if (nextString('px')) {
      return ValueUnit.fixed;
    } else if (nextString('viewportSize')) {
      return ValueUnit.viewportSize;
    } else if (nextString('contentSize')) {
      return ValueUnit.contentSize;
    } else if (nextString('childSize')) {
      return ValueUnit.childSize;
    } else if (nextString('flex')) {
      return ValueUnit.flex;
    } else if (nextString('ratio')) {
      return ValueUnit.ratio;
    }
    return null;
  }

  bool nextOpenParen() {
    return nextString('(');
  }

  bool nextCloseParen() {
    return nextString(')');
  }

  String nextWord() {
    final start = position;
    while (position < source.length &&
        !isWhitespace(source.codeUnitAt(position)) &&
        source.codeUnitAt(position) != 41) {
      // ')' character
      position++;
    }
    return source.substring(start, position);
  }

  bool nextHashtag() {
    return nextString('#');
  }

  // Operator precedence: +, - (lowest), *, /, %, ~/ (middle), parentheses (highest)
  BoxValue? nextBoxValue({bool fallbackFixed = true}) {
    final start = position;
    skipWhitespace();
    BoxValue? value = _parseAddSub(fallbackFixed: fallbackFixed);
    if (value == null) {
      position = start;
    }
    return value;
  }

  BoxValue? _parseAddSub({bool fallbackFixed = true}) {
    skipWhitespace();
    BoxValue? left = _parseMulDiv(fallbackFixed: fallbackFixed);
    if (left == null) return null;
    skipWhitespace();
    while (true) {
      final opStart = position;
      MathOperation? op = nextMathOperation();
      if (op == MathOperation.add || op == MathOperation.subtract) {
        skipWhitespace();
        BoxValue? right = _parseMulDiv(fallbackFixed: fallbackFixed);
        if (right == null) {
          position = opStart;
          break;
        }
        if (op == MathOperation.add) {
          left = left! + right;
        } else {
          left = left! - right;
        }
        skipWhitespace();
      } else {
        position = opStart;
        break;
      }
    }
    return left;
  }

  BoxValue? _parseMulDiv({bool fallbackFixed = true}) {
    skipWhitespace();
    BoxValue? left = _parseUnary(fallbackFixed: fallbackFixed);
    if (left == null) return null;
    skipWhitespace();
    while (true) {
      final opStart = position;
      MathOperation? op = nextMathOperation();
      if (op == MathOperation.multiply || op == MathOperation.divide) {
        skipWhitespace();
        // Try to parse as BoxValue first
        BoxValue? rightBox = _parseUnary(fallbackFixed: false);
        if (rightBox != null) {
          // If rightBox is a BoxValue, extract left to double and do (double op BoxValue)
          double leftValue = extractSingleValue(left!);
          switch (op) {
            case MathOperation.multiply:
              left = PrimitiveBoxComputer(
                rightBox,
                leftValue,
                PrimitiveBoxComputer.multiplication,
                reverse: true,
              );
              break;
            case MathOperation.divide:
              left = PrimitiveBoxComputer(
                rightBox,
                leftValue,
                PrimitiveBoxComputer.division,
                reverse: true,
              );
              break;
            default:
              break;
          }
          skipWhitespace();
        } else {
          // Fallback: try to parse as number
          double? rightNum = nextDouble();
          if (rightNum == null) {
            position = opStart;
            break;
          }
          switch (op) {
            case MathOperation.multiply:
              left = PrimitiveBoxComputer(
                left!,
                rightNum,
                PrimitiveBoxComputer.multiplication,
              );
              break;
            case MathOperation.divide:
              left = PrimitiveBoxComputer(
                left!,
                rightNum,
                PrimitiveBoxComputer.division,
              );
              break;
            default:
              break;
          }
          skipWhitespace();
        }
        continue;
      } else {
        position = opStart;
        break;
      }
    }
    return left;
  }

  BoxValue? _parseUnary({bool fallbackFixed = true}) {
    skipWhitespace();
    final start = position;
    bool negate = nextString('-');
    skipWhitespace();
    BoxValue? value = _parsePrimary(fallbackFixed: fallbackFixed);
    if (value == null) {
      position = start;
      return null;
    }
    if (negate) {
      value = -value;
    }
    return value;
  }

  BoxValue? _parsePrimary({bool fallbackFixed = true}) {
    final start = position;
    skipWhitespace();
    // ValueFunction support (clamp, abs, min, max)
    for (final func in ValueFunction.values) {
      final funcName = func.name;
      if (source.startsWith(funcName, position)) {
        position += funcName.length;
        skipWhitespace();
        if (!nextOpenParen()) {
          position = start;
          return null;
        }
        skipWhitespace();
        List<BoxValue> args = [];
        for (int i = 0; i < func.argumentCount; i++) {
          final arg = nextBoxValue(fallbackFixed: fallbackFixed);
          if (arg == null) {
            position = start;
            return null;
          }
          args.add(arg);
          skipWhitespace();
          if (i < func.argumentCount - 1) {
            if (source.codeUnitAt(position) == 44) {
              // ','
              position++;
              skipWhitespace();
            } else {
              position = start;
              return null;
            }
          }
        }
        if (!nextCloseParen()) {
          position = start;
          return null;
        }
        BoxValue boxValue = func.function(args);
        return boxValue;
      }
    }

    if (nextOpenParen()) {
      skipWhitespace();
      final innerValue = nextBoxValue(fallbackFixed: fallbackFixed);
      skipWhitespace();
      if (!nextCloseParen()) {
        // Invalid format, revert to original position
        position = start;
        return null;
      }
      return innerValue;
    }
    if (nextIntrinsic()) {
      return intrinsicSize;
    }
    // Check longer align* names first to avoid shadowing
    if (nextAlignCenterStart()) {
      return alignCenterStart;
    }
    if (nextAlignCenterEnd()) {
      return alignCenterEnd;
    }
    if (nextAlignStartCenter()) {
      return alignStartCenter;
    }
    if (nextAlignStartEnd()) {
      return alignStartEnd;
    }
    if (nextAlignEndStart()) {
      return alignEndStart;
    }
    if (nextAlignEndCenter()) {
      return alignEndCenter;
    }
    if (nextAlignCenter()) {
      return alignCenter;
    }
    if (nextAlignStart()) {
      return alignStart;
    }
    if (nextAlignEnd()) {
      return alignEnd;
    }
    if (nextExpanding()) {
      return expandingSize;
    }
    if (nextSmallestExpanding()) {
      return smallestExpandingSize;
    }
    if (nextHashtag()) {
      final key = nextWord();
      BoxValue linkedValue = LinkedValue(ValueKey(key));
      skipWhitespace();
      if (nextOpenParen()) {
        skipWhitespace();
        FlexTarget? target = nextFlexTarget();
        if (target != null) {
          skipWhitespace();
        }
        if (nextHashtag()) {
          final innerKey = nextWord();
          linkedValue = LinkedValue(ValueKey(key), key: ValueKey(innerKey));
        }
        skipWhitespace();
        if (!nextCloseParen()) {
          position = start;
          return null;
        }
      }
      return linkedValue;
    }
    double? value = nextDouble();
    if (value == null) {
      // Invalid format, revert to original position
      position = start;
      return null;
    }
    bool isPercent = false;
    skipWhitespace();
    if (position < source.length && source.codeUnitAt(position) == 37) {
      // '%'
      isPercent = true;
      position++;
      skipWhitespace();
    }
    ValueUnit? unit = nextValueUnit();
    BoxValue boxValue;
    if (unit == null) {
      // Fallback: treat as FixedValue (px) if no unit is specified
      if (fallbackFixed) {
        boxValue = FixedValue(value);
      } else {
        // Invalid format, revert to original position
        position = start;
        return null;
      }
    } else {
      boxValue = switch (unit) {
        ValueUnit.fixed => FixedValue(value),
        ValueUnit.viewportSize => RelativeValue(
          isPercent ? value / 100.0 : value,
        ),
        ValueUnit.contentSize => RelativeValue(
          isPercent ? value / 100.0 : value,
          target: FlexTarget.content,
        ),
        ValueUnit.childSize => RelativeValue(
          isPercent ? value / 100.0 : value,
          target: FlexTarget.child,
        ),
        ValueUnit.flex => FlexSize(value),
        ValueUnit.ratio => RatioSize(value),
      };
    }
    skipWhitespace();
    if (nextOpenParen()) {
      skipWhitespace();
      FlexTarget? target = nextFlexTarget();
      if (target != null) {
        boxValue = boxValue.withTarget(target);
        skipWhitespace();
      }
      if (nextHashtag()) {
        final key = nextWord();
        skipWhitespace();
        if (!nextCloseParen()) {
          // Invalid format, revert to original position
          position = start;
          return null;
        }
        boxValue = boxValue.withKey(ValueKey(key));
      } else {
        if (!nextCloseParen()) {
          // Invalid format, revert to original position
          position = start;
          return null;
        }
      }
    }
    return boxValue;
  }
}

String boxValueToString(BoxValue value) {
  // Helper to determine if a BoxValue is a BoxComputer (expression)
  bool isExpr(BoxValue v) => v is BoxComputer;

  // Helper to get precedence: higher number = higher precedence
  int precedence(BoxValue v) {
    if (v is BoxComputer) {
      if (identical(v.operation, BoxComputer.addition) ||
          identical(v.operation, BoxComputer.subtraction)) {
        return 1;
      } else if (identical(v.operation, BoxComputer.min) ||
          identical(v.operation, BoxComputer.max)) {
        return 0; // treat min/max as lowest precedence
      }
    }
    return 2; // literals and others
  }

  String getKeyString(LocalKey? key) {
    if (key == null) return '';
    if (key is ValueKey) {
      return ' (#${key.value})';
    }
    return ' (${key.toString()})';
  }

  // Handle BoxComputer (for min, max, addition, subtraction)
  if (value is BoxComputer) {
    String op;
    if (identical(value.operation, BoxComputer.addition)) {
      op = '+';
    } else if (identical(value.operation, BoxComputer.subtraction)) {
      op = '-';
    } else if (identical(value.operation, BoxComputer.min)) {
      op = 'min';
    } else if (identical(value.operation, BoxComputer.max)) {
      op = 'max';
    } else {
      op = 'compute';
    }
    // min/max always use function style
    if (op == 'min' || op == 'max') {
      return '$op(${boxValueToString(value.first)}, ${boxValueToString(value.second)})';
    }
    // For + and -, only parenthesize if child is lower precedence
    String leftStr =
        isExpr(value.first) && precedence(value.first) < precedence(value)
        ? '(${boxValueToString(value.first)})'
        : boxValueToString(value.first);
    String rightStr =
        isExpr(value.second) && precedence(value.second) < precedence(value)
        ? '(${boxValueToString(value.second)})'
        : boxValueToString(value.second);
    return '$leftStr $op $rightStr';
  }

  // Handle LinkedValue
  if (value is LinkedValue) {
    String targetStr = value.targetKey is ValueKey
        ? (value.targetKey as ValueKey).value
        : value.targetKey.toString();
    return '#$targetStr${getKeyString(value.key)}';
  }

  // Do not handle modulo or floor division in stringification
  // Handle FixedValue
  if (value is FixedValue) {
    String str = '${optimalDoubleString(value.value)} px';
    String suffix = '';
    if (value.key != null) {
      if (value.target != FlexTarget.viewport) {
        suffix += value.target.name + '#';
      } else {
        suffix += '#';
      }
      if (value.key is ValueKey) {
        suffix += (value.key as ValueKey).value;
      } else {
        suffix += value.key.toString();
      }
    } else if (value.target != FlexTarget.viewport) {
      suffix += value.target.name;
    }
    if (suffix.isNotEmpty) {
      str += ' ($suffix)';
    }
    return str;
  }
  // Handle RelativeValue
  if (value is RelativeValue) {
    String base = value.target == FlexTarget.viewport
        ? 'viewportSize'
        : value.target == FlexTarget.content
        ? 'contentSize'
        : value.target == FlexTarget.child
        ? 'childSize'
        : 'viewportSize';
    if ((value.relative * 100).roundToDouble() == value.relative * 100 &&
        value.relative <= 1.0 &&
        value.relative >= 0.0) {
      // If value is a percent
      return '${optimalDoubleString(value.relative * 100)}% $base${getKeyString(value.key)}';
    }
    return '${optimalDoubleString(value.relative)} $base${getKeyString(value.key)}';
  }
  // Handle FlexSize
  if (value is FlexSize) {
    return '${optimalDoubleString(value.flex)} flex${getKeyString(value.key)}';
  }
  // Handle RatioSize
  if (value is RatioSize) {
    return '${optimalDoubleString(value.ratio)} ratio${getKeyString(value.key)}';
  }
  // Handle special constants
  if (identical(value, intrinsicSize)) {
    return 'intrinsic${getKeyString(value.key)}';
  }
  if (identical(value, alignCenter)) {
    return 'alignCenter${getKeyString(value.key)}';
  }
  if (identical(value, alignStart)) {
    return 'alignStart${getKeyString(value.key)}';
  }
  if (identical(value, alignEnd)) {
    return 'alignEnd${getKeyString(value.key)}';
  }
  if (identical(value, alignCenterStart)) {
    return 'alignCenterStart${getKeyString(value.key)}';
  }
  if (identical(value, alignCenterEnd)) {
    return 'alignCenterEnd${getKeyString(value.key)}';
  }
  if (identical(value, alignStartCenter)) {
    return 'alignStartCenter${getKeyString(value.key)}';
  }
  if (identical(value, alignStartEnd)) {
    return 'alignStartEnd${getKeyString(value.key)}';
  }
  if (identical(value, alignEndStart)) {
    return 'alignEndStart${getKeyString(value.key)}';
  }
  if (identical(value, alignEndCenter)) {
    return 'alignEndCenter${getKeyString(value.key)}';
  }
  if (identical(value, expandingSize)) {
    return 'expanding${getKeyString(value.key)}';
  }
  if (identical(value, smallestExpandingSize)) {
    return 'smallestExpanding${getKeyString(value.key)}';
  }
  // Fallback to toString
  return value.toString();
}

double extractSingleValue(BoxValue value) {
  if (value is FixedValue) {
    return value.value;
  }
  if (value is RelativeValue) {
    return value.relative;
  }
  if (value is FlexSize) {
    return value.flex;
  }
  if (value is RatioSize) {
    return value.ratio;
  }
  if (value is PrimitiveBoxComputer) {
    final left = extractSingleValue(value.original);
    return value.operation(left, value.operand);
  }
  if (value is BoxComputer) {
    final left = extractSingleValue(value.first);
    final right = extractSingleValue(value.second);
    return value.operation(left, right);
  }
  throw ArgumentError('Cannot extract single value from $value');
}

String optimalDoubleString(double value) {
  if (value.floor() == value) {
    return value.toStringAsFixed(0);
  } else {
    return value.toString();
  }
}
