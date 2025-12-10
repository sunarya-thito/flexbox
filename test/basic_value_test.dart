import 'package:flutter_test/flutter_test.dart';
import 'package:flexiblebox/src/basic.dart';
import 'package:flexiblebox/src/layout.dart';

// Mock implementations for CalculationOperation if needed, but we can use constants
// actually CalculationOperation is likely a typedef double Function(double, double).
// We'll rely on the constants defined in basic.dart or layout.dart if available, or just mock functions.

double mockAdd(double a, double b) => a + b;
double mockSub(double a, double b) => a - b;

void main() {
  group('SizeUnit Overrides', () {
    test('SizeFixed', () {
      const a = SizeFixed(10.0);
      const b = SizeFixed(10.0);
      const c = SizeFixed(20.0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('10.0'));
    });

    test('SizeViewport', () {
      const a = SizeViewport();
      const b = SizeViewport();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('SizeViewport'));
    });

    test('SizeMinContent', () {
      const a = SizeMinContent();
      const b = SizeMinContent();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('SizeMinContent'));
    });

    test('SizeMaxContent', () {
      const a = SizeMaxContent();
      const b = SizeMaxContent();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('SizeMaxContent'));
    });

    test('SizeFitContent', () {
      const a = SizeFitContent();
      const b = SizeFitContent();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('SizeFitContent'));
    });

    test('SizeRelative', () {
      const a = SizeRelative(0.5);
      const b = SizeRelative(0.5);
      const c = SizeRelative(0.8);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('0.5'));
    });

    test('SizeCalculated', () {
      const a = SizeCalculated(SizeFixed(10), SizeFixed(20), calculationAdd);
      const b = SizeCalculated(SizeFixed(10), SizeFixed(20), calculationAdd);
      const c = SizeCalculated(
        SizeFixed(10),
        SizeFixed(20),
        calculationSubtract,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('SizeCalculated'));
    });

    test('SizeConstraint', () {
      const a = SizeConstraint(
        size: SizeFixed(100),
        min: SizeFixed(10),
        max: SizeFixed(200),
      );
      const b = SizeConstraint(
        size: SizeFixed(100),
        min: SizeFixed(10),
        max: SizeFixed(200),
      );
      const c = SizeConstraint(
        size: SizeFixed(100),
        min: SizeFixed(20),
        max: SizeFixed(200),
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('SizeConstraint'));
    });
  });

  group('PositionUnit Overrides', () {
    test('PositionFixed', () {
      const a = PositionFixed(10.0);
      const b = PositionFixed(10.0);
      const c = PositionFixed(20.0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('10.0'));
    });

    test('PositionViewportSize', () {
      const a = PositionViewportSize();
      const b = PositionViewportSize();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('PositionViewportSize'));
    });

    test('PositionCalculated', () {
      const a = PositionCalculated(
        PositionFixed(10),
        PositionFixed(20),
        calculationAdd,
      );
      const b = PositionCalculated(
        PositionFixed(10),
        PositionFixed(20),
        calculationAdd,
      );
      const c = PositionCalculated(
        PositionFixed(10),
        PositionFixed(20),
        calculationSubtract,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('PositionCalculated'));
    });

    test('PositionRelative', () {
      const a = PositionRelative(0.5);
      const b = PositionRelative(0.5);
      const c = PositionRelative(0.2);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('0.5'));
    });
  });

  group('SpacingUnit Overrides', () {
    test('SpacingFixed', () {
      const a = SpacingFixed(10.0);
      const b = SpacingFixed(10.0);
      const c = SpacingFixed(20.0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('10.0'));
    });

    test('SpacingViewport', () {
      const a = SpacingViewport();
      const b = SpacingViewport();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('SpacingViewport'));
    });

    test('SpacingRelative', () {
      const a = SpacingRelative(0.5);
      const b = SpacingRelative(0.5);
      const c = SpacingRelative(0.2);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('0.5'));
    });
  });

  group('EdgeSpacing Overrides', () {
    test('EdgeSpacing', () {
      const a = EdgeSpacing.all(SpacingFixed(10));
      const b = EdgeSpacing.all(SpacingFixed(10));
      const c = EdgeSpacing.all(SpacingFixed(20));

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('EdgeSpacing'));
    });

    test('EdgeSpacingDirectional', () {
      const a = EdgeSpacingDirectional.all(SpacingFixed(10));
      const b = EdgeSpacingDirectional.all(SpacingFixed(10));
      const c = EdgeSpacingDirectional.all(SpacingFixed(20));

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('EdgeSpacingDirectional'));
    });
  });

  group('BoxAlignment Overrides', () {
    test('BoxAlignment', () {
      const a = BoxAlignment(0.5);
      const b = BoxAlignment(0.5);
      const c = BoxAlignment(0.0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('0.5'));
    });

    test('BoxAlignmentDirectional', () {
      const a = BoxAlignmentDirectional(0.5);
      const b = BoxAlignmentDirectional(0.5);
      const c = BoxAlignmentDirectional(0.0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('0.5'));
    });

    test('BoxAlignmentSpacing', () {
      const a = BoxAlignmentSpacing(0.5, 0.5);
      const b = BoxAlignmentSpacing(0.5, 0.5);
      const c = BoxAlignmentSpacing.between();

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('BoxAlignmentSpacing'));
    });

    test('BoxAlignmentContentStretch', () {
      const a = BoxAlignmentContentStretch();
      const b = BoxAlignmentContentStretch();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('BoxAlignmentContentStretch'));
    });

    test('BoxAlignmentGeometryBaseline', () {
      const a = BoxAlignmentGeometryBaseline();
      const b = BoxAlignmentGeometryBaseline();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('BoxAlignmentGeometryBaseline'));
    });
  });
}
