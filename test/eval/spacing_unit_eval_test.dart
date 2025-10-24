import 'package:flexiblebox/flexiblebox_dart.dart';
import 'package:flexiblebox/src/eval/eval.dart';
import 'package:test/test.dart';

void main() {
  group('SpacingUnit toCodeString', () {
    test('fixed spacing converts to string', () {
      final unit = SpacingUnit.fixed(100);
      expect(unit.toCodeString(), '100.0px');
    });

    test('viewport size converts to string', () {
      final unit = SpacingUnit.viewportSize;
      expect(unit.toCodeString(), 'viewportSize');
    });

    test('calculated spacing (addition) converts to string', () {
      final unit = SpacingUnit.fixed(50) + SpacingUnit.fixed(30);
      expect(unit.toCodeString(), '(50.0px + 30.0px)');
    });

    test('calculated spacing (subtraction) converts to string', () {
      final unit = SpacingUnit.viewportSize - SpacingUnit.fixed(20);
      expect(unit.toCodeString(), '(viewportSize - 20.0px)');
    });

    test('calculated spacing (multiplication) converts to string', () {
      final unit = SpacingUnit.viewportSize * 0.5;
      expect(unit.toCodeString(), '(viewportSize * 0.5px)');
    });

    test('calculated spacing (division) converts to string', () {
      final unit = SpacingUnit.fixed(100) / SpacingUnit.fixed(2);
      expect(unit.toCodeString(), '(100.0px / 2.0px)');
    });

    test('complex calculated spacing converts to string', () {
      final unit = (SpacingUnit.viewportSize * 0.5) + SpacingUnit.fixed(20);
      expect(unit.toCodeString(), '((viewportSize * 0.5px) + 20.0px)');
    });

    test('childSize without key converts to string', () {
      final unit = SpacingUnit.childSize();
      expect(unit.toCodeString(), 'childSize');
    });

    test('childSize with string key converts to string', () {
      final unit = SpacingUnit.childSize('myKey');
      expect(unit.toCodeString(), 'childSize("myKey")');
    });

    test('childSize with symbol key converts to string', () {
      final unit = SpacingUnit.childSize(#mySymbol);
      expect(unit.toCodeString(), 'childSize(#Symbol("mySymbol"))');
    });
  });

  group('SpacingUnit evaluate from toCodeString', () {
    test('evaluates fixed spacing from toCodeString', () {
      final original = SpacingUnit.fixed(100);
      final str = original.toCodeString();
      final evaluated = evaluateSpacingUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates viewport size from toCodeString', () {
      final original = SpacingUnit.viewportSize;
      final str = original.toCodeString();
      final evaluated = evaluateSpacingUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates calculated spacing from toCodeString', () {
      final original = SpacingUnit.fixed(50) + SpacingUnit.fixed(30);
      final str = original.toCodeString();
      final evaluated = evaluateSpacingUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates complex expression from toCodeString', () {
      final original = (SpacingUnit.viewportSize * 0.5) + SpacingUnit.fixed(20);
      final str = original.toCodeString();
      final evaluated = evaluateSpacingUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates childSize from toCodeString', () {
      final original = SpacingUnit.childSize('test');
      final str = original.toCodeString();
      final evaluated = evaluateSpacingUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });
  });

  group('SpacingUnit evaluate from normal strings', () {
    test('evaluates fixed pixel value', () {
      final unit = evaluateSpacingUnit('100px');
      expect(unit.toCodeString(), SpacingUnit.fixed(100).toCodeString());
    });

    test('evaluates fixed value without px', () {
      final unit = evaluateSpacingUnit('100');
      expect(unit.toCodeString(), SpacingUnit.fixed(100).toCodeString());
    });

    test('evaluates percentage', () {
      final unit = evaluateSpacingUnit('50%');
      expect(
        unit.toCodeString(),
        (SpacingUnit.viewportSize * 0.5).toCodeString(),
      );
    });

    test('evaluates viewportSize', () {
      final unit = evaluateSpacingUnit('viewportSize');
      expect(unit.toCodeString(), SpacingUnit.viewportSize.toCodeString());
    });

    test('evaluates addition expression', () {
      final unit = evaluateSpacingUnit('100px + 50px');
      expect(
        unit.toCodeString(),
        (SpacingUnit.fixed(100) + SpacingUnit.fixed(50)).toCodeString(),
      );
    });

    test('evaluates subtraction expression', () {
      final unit = evaluateSpacingUnit('viewportSize - 20px');
      expect(
        unit.toCodeString(),
        (SpacingUnit.viewportSize - SpacingUnit.fixed(20)).toCodeString(),
      );
    });

    test('evaluates multiplication expression', () {
      final unit = evaluateSpacingUnit('viewportSize * 0.5');
      expect(
        unit.toCodeString(),
        (SpacingUnit.viewportSize * 0.5).toCodeString(),
      );
    });

    test('evaluates division expression', () {
      final unit = evaluateSpacingUnit('100px / 2');
      expect(
        unit.toCodeString(),
        (SpacingUnit.fixed(100) / SpacingUnit.fixed(2)).toCodeString(),
      );
    });

    test('evaluates complex expression', () {
      final unit = evaluateSpacingUnit('(viewportSize * 0.5) + 20px');
      expect(
        unit.toCodeString(),
        ((SpacingUnit.viewportSize * 0.5) + SpacingUnit.fixed(20))
            .toCodeString(),
      );
    });

    test('evaluates parenthesized expression', () {
      final unit = evaluateSpacingUnit('(100px + 50px) * 2');
      expect(
        unit.toCodeString(),
        ((SpacingUnit.fixed(100) + SpacingUnit.fixed(50)) * 2.0).toCodeString(),
      );
    });

    test('respects operator precedence', () {
      final unit = evaluateSpacingUnit('100px + 50px * 2');
      expect(
        unit.toCodeString(),
        (SpacingUnit.fixed(100) + (SpacingUnit.fixed(50) * 2.0)).toCodeString(),
      );
    });

    test('evaluates childSize without argument', () {
      final unit = evaluateSpacingUnit('childSize');
      expect(unit.toCodeString(), SpacingUnit.childSize().toCodeString());
    });

    test('evaluates childSize with string argument', () {
      final unit = evaluateSpacingUnit('childSize("test")');
      expect(unit.toCodeString(), SpacingUnit.childSize('test').toCodeString());
    });

    test('evaluates childSize with symbol argument', () {
      final unit = evaluateSpacingUnit('childSize(#test)');
      expect(unit.toCodeString(), SpacingUnit.childSize(#test).toCodeString());
    });

    test('evaluates negative values', () {
      final unit = evaluateSpacingUnit('-50px');
      expect(
        unit.toCodeString(),
        (SpacingUnit.fixed(0) - SpacingUnit.fixed(50)).toCodeString(),
      );
    });

    test('evaluates decimal values', () {
      final unit = evaluateSpacingUnit('12.5px');
      expect(unit.toCodeString(), SpacingUnit.fixed(12.5).toCodeString());
    });
  });
}
