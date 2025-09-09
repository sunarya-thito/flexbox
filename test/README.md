# FlexBox Test Suite

This directory contains a comprehensive test suite for the FlexBox package, organized into multiple focused test files to ensure maintainability and readability.

## Test Files Overview

### 1. `basic_layout_test.dart` (589 lines)
**Purpose**: Tests fundamental FlexBox layout functionality
**Coverage**:
- Basic FlexBox rendering with different directions (horizontal/vertical)
- Fixed, unconstrained, and flex sizing behaviors
- Mixed sizing scenarios and edge cases
- Empty containers and single/multiple children layouts
- Nested FlexBox structures

**Test Groups**:
- Basic Layout Tests (12 test cases)

### 2. `positioning_types_test.dart` (408 lines)
**Purpose**: Tests all positioning types and their behaviors
**Coverage**:
- Relative, fixed, and relativeViewport positioning
- Left, right, top, bottom positioning
- Mixed positioning types
- Percentage-based relative positioning
- Multiple positioning types coexisting

**Test Groups**:
- Positioning Types Tests (11 test cases)

### 3. `sticky_positioning_test.dart` (472 lines)
**Purpose**: Tests sticky positioning behaviors and viewport sticky variants
**Coverage**:
- Basic sticky positioning with scrolling
- StickyStart and StickyEnd positioning
- StickyViewport, StickyStartViewport, StickyEndViewport positioning
- Mixed sticky positioning types
- Horizontal and vertical sticky independence

**Test Groups**:
- Sticky Positioning Tests (9 test cases)

### 4. `viewport_positioning_test.dart` (521 lines)
**Purpose**: Tests viewport-anchored positioning behaviors
**Coverage**:
- RelativeViewport positioning vs regular relative positioning
- Viewport positioning with percentage values
- Viewport positioning with scrolling behavior
- Mixed viewport and regular positioning types
- Viewport positioning with constraints and sizing
- Edge cases and layout consistency

**Test Groups**:
- Viewport Positioning Tests (8 test cases)

### 5. `edge_cases_test.dart` (594 lines)
**Purpose**: Tests edge cases, constraints, and stress scenarios
**Coverage**:
- Empty FlexBox and single child scenarios
- Large numbers of children
- Extremely small and large dimensions
- Negative positioning values
- Positioning beyond container bounds
- Complex nested structures
- zOrder property behavior
- Flex positioning with zero values
- Ratio sizing with extreme ratios
- Unconstrained sizing in tight constraints
- Mixed positioning and sizing edge cases
- Intrinsic sizing behavior

**Test Groups**:
- Edge Cases and Constraints Tests (14 test cases)

### 6. `sizing_behaviors_test.dart` (590 lines)
**Purpose**: Tests comprehensive sizing behaviors and combinations
**Coverage**:
- Fixed sizing with constraint overrides
- Unconstrained sizing with min/max constraints
- Flex sizing: single flex, proportional distribution, vertical flex
- Ratio sizing: aspect ratios, different references, constraints
- Intrinsic sizing: text content, constraints
- Mixed sizing scenarios: all types together, nested structures

**Test Groups**:
- Fixed Sizing (2 test cases)
- Unconstrained Sizing (2 test cases)
- Flex Sizing (4 test cases)
- Ratio Sizing (3 test cases)
- Intrinsic Sizing (2 test cases)
- Mixed Sizing Scenarios (3 test cases)

## Test Coverage Summary

**Total Test Files**: 6
**Total Test Cases**: 63
**Total Lines of Code**: ~3,174

### Positioning Coverage
- ✅ BoxPositionType.relative
- ✅ BoxPositionType.fixed
- ✅ BoxPositionType.relativeViewport
- ✅ BoxPositionType.sticky
- ✅ BoxPositionType.stickyStart
- ✅ BoxPositionType.stickyEnd
- ✅ BoxPositionType.stickyViewport
- ✅ BoxPositionType.stickyStartViewport
- ✅ BoxPositionType.stickyEndViewport

### Sizing Coverage
- ✅ BoxSize.fixed()
- ✅ BoxSize.unconstrained()
- ✅ BoxSize.flex()
- ✅ BoxSize.ratio()
- ✅ BoxSize.intrinsic()

### Position Value Coverage
- ✅ BoxPosition.fixed()
- ✅ BoxPosition.relative()
- ✅ BoxPosition.flex()

### Layout Direction Coverage
- ✅ Axis.horizontal
- ✅ Axis.vertical

### Special Scenarios Coverage
- ✅ Empty containers
- ✅ Single child layouts
- ✅ Multiple children layouts
- ✅ Nested FlexBox structures
- ✅ Scrollable content
- ✅ Viewport interactions
- ✅ Edge cases and stress testing
- ✅ Constraint interactions
- ✅ Mixed positioning/sizing combinations

## Running Tests

To run all tests:
```bash
flutter test
```

To run specific test files:
```bash
flutter test test/basic_layout_test.dart
flutter test test/positioning_types_test.dart
flutter test test/sticky_positioning_test.dart
flutter test test/viewport_positioning_test.dart
flutter test test/edge_cases_test.dart
flutter test test/sizing_behaviors_test.dart
```

To run tests with coverage:
```bash
flutter test --coverage
```

## Notes

- All test files are kept under 600 lines for maintainability
- Tests use MaterialApp wrappers for proper Flutter testing context
- Tests include both positive and negative test cases
- Each test group focuses on specific functionality areas
- Tests validate both positioning and sizing behaviors
- Edge cases and error conditions are thoroughly tested
