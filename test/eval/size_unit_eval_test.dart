import 'package:flexiblebox/flexiblebox_dart.dart';
import 'package:flexiblebox/src/eval/eval.dart';
import 'package:test/test.dart';

void main() {
  group('SizeUnit toCodeString', () {
    test('fixed size converts to string', () {
      final unit = SizeUnit.fixed(100);
      expect(unit.toCodeString(), '100.0px');
    });

    test('viewport size converts to string', () {
      final unit = SizeUnit.viewportSize;
      expect(unit.toCodeString(), 'viewportSize');
    });

    test('minContent converts to string', () {
      final unit = SizeUnit.minContent;
      expect(unit.toCodeString(), 'minContent');
    });

    test('maxContent converts to string', () {
      final unit = SizeUnit.maxContent;
      expect(unit.toCodeString(), 'maxContent');
    });

    test('fitContent converts to string', () {
      final unit = SizeUnit.fitContent;
      expect(unit.toCodeString(), 'fitContent');
    });

    test('calculated size (addition) converts to string', () {
      final unit = SizeUnit.fixed(50) + SizeUnit.fixed(30);
      expect(unit.toCodeString(), '(50.0px + 30.0px)');
    });

    test('calculated size (subtraction) converts to string', () {
      final unit = SizeUnit.viewportSize - SizeUnit.fixed(20);
      expect(unit.toCodeString(), '(viewportSize - 20.0px)');
    });

    test('calculated size (multiplication) converts to string', () {
      final unit = SizeUnit.viewportSize * 0.5;
      expect(unit.toCodeString(), '(viewportSize * 0.5px)');
    });

    test('calculated size (division) converts to string', () {
      final unit = SizeUnit.fixed(100) / SizeUnit.fixed(2);
      expect(unit.toCodeString(), '(100.0px / 2.0px)');
    });

    test('complex calculated size converts to string', () {
      final unit = (SizeUnit.viewportSize * 0.5) + SizeUnit.fixed(20);
      expect(unit.toCodeString(), '((viewportSize * 0.5px) + 20.0px)');
    });
  });

  group('SizeUnit evaluate from toCodeString', () {
    test('evaluates fixed size from toCodeString', () {
      final original = SizeUnit.fixed(100);
      final str = original.toCodeString();
      final evaluated = evaluateSizeUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates viewport size from toCodeString', () {
      final original = SizeUnit.viewportSize;
      final str = original.toCodeString();
      final evaluated = evaluateSizeUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates minContent from toCodeString', () {
      final original = SizeUnit.minContent;
      final str = original.toCodeString();
      final evaluated = evaluateSizeUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates calculated size from toCodeString', () {
      final original = SizeUnit.fixed(50) + SizeUnit.fixed(30);
      final str = original.toCodeString();
      final evaluated = evaluateSizeUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });

    test('evaluates complex expression from toCodeString', () {
      final original = (SizeUnit.viewportSize * 0.5) + SizeUnit.fixed(20);
      final str = original.toCodeString();
      final evaluated = evaluateSizeUnit(str);
      expect(evaluated.toCodeString(), original.toCodeString());
    });
  });

  group('SizeUnit evaluate from normal strings', () {
    test('evaluates fixed pixel value', () {
      final unit = evaluateSizeUnit('100px');
      expect(unit.toCodeString(), SizeUnit.fixed(100).toCodeString());
    });

    test('evaluates fixed value without px', () {
      final unit = evaluateSizeUnit('100');
      expect(unit.toCodeString(), SizeUnit.fixed(100).toCodeString());
    });

    test('evaluates percentage', () {
      final unit = evaluateSizeUnit('50%');
      expect(unit.toCodeString(), (SizeUnit.viewportSize * 0.5).toCodeString());
    });

    test('evaluates viewportSize', () {
      final unit = evaluateSizeUnit('viewportSize');
      expect(unit.toCodeString(), SizeUnit.viewportSize.toCodeString());
    });

    test('evaluates minContent', () {
      final unit = evaluateSizeUnit('minContent');
      expect(unit.toCodeString(), SizeUnit.minContent.toCodeString());
    });

    test('evaluates maxContent', () {
      final unit = evaluateSizeUnit('maxContent');
      expect(unit.toCodeString(), SizeUnit.maxContent.toCodeString());
    });

    test('evaluates fitContent', () {
      final unit = evaluateSizeUnit('fitContent');
      expect(unit.toCodeString(), SizeUnit.fitContent.toCodeString());
    });

    test('evaluates addition expression', () {
      final unit = evaluateSizeUnit('100px + 50px');
      expect(
        unit.toCodeString(),
        (SizeUnit.fixed(100) + SizeUnit.fixed(50)).toCodeString(),
      );
    });

    test('evaluates subtraction expression', () {
      final unit = evaluateSizeUnit('viewportSize - 20px');
      expect(
        unit.toCodeString(),
        (SizeUnit.viewportSize - SizeUnit.fixed(20)).toCodeString(),
      );
    });

    test('evaluates multiplication expression', () {
      final unit = evaluateSizeUnit('viewportSize * 0.5');
      expect(unit.toCodeString(), (SizeUnit.viewportSize * 0.5).toCodeString());
    });

    test('evaluates division expression', () {
      final unit = evaluateSizeUnit('100px / 2');
      expect(
        unit.toCodeString(),
        (SizeUnit.fixed(100) / SizeUnit.fixed(2)).toCodeString(),
      );
    });

    test('evaluates complex expression', () {
      final unit = evaluateSizeUnit('(viewportSize * 0.5) + 20px');
      expect(
        unit.toCodeString(),
        ((SizeUnit.viewportSize * 0.5) + SizeUnit.fixed(20)).toCodeString(),
      );
    });

    test('evaluates parenthesized expression', () {
      final unit = evaluateSizeUnit('(100px + 50px) * 2');
      expect(
        unit.toCodeString(),
        ((SizeUnit.fixed(100) + SizeUnit.fixed(50)) * 2.0).toCodeString(),
      );
    });

    test('respects operator precedence', () {
      final unit = evaluateSizeUnit('100px + 50px * 2');
      expect(
        unit.toCodeString(),
        (SizeUnit.fixed(100) + (SizeUnit.fixed(50) * 2.0)).toCodeString(),
      );
    });

    test('evaluates negative values', () {
      final unit = evaluateSizeUnit('-50px');
      expect(
        unit.toCodeString(),
        (SizeUnit.fixed(0) - SizeUnit.fixed(50)).toCodeString(),
      );
    });

    test('evaluates decimal values', () {
      final unit = evaluateSizeUnit('12.5px');
      expect(unit.toCodeString(), SizeUnit.fixed(12.5).toCodeString());
    });
  });
}
