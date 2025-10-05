# FlexibleBox Example

This example app demonstrates the core features of the FlexibleBox package.

## Features Demonstrated

### 1. Flex Direction

- **Row**: Horizontal layout of items
- **Column**: Vertical layout of items

### 2. Flex Grow

Shows how items with `flexGrow` expand to fill available space proportionally.

### 3. Flex Shrink

Shows how items with `flexShrink` compress when the container is too small.

### 4. Row Gap

Demonstrates horizontal spacing between flex items using `rowGap`.

### 5. Column Gap

Demonstrates vertical spacing between flex items using `columnGap`.

### 6. Sticky Items

Shows how items can be offset from their normal position using `top`, `left`,
`bottom`, and `right` properties on `FlexItem`.

### 7. Absolute Positioning

Demonstrates `AbsoluteItem` for positioning items absolutely within the flex
container, without affecting the layout of other items.

## Running the Example

```bash
flutter run
```

## Key Concepts

- **FlexBox**: The main container widget that implements flexbox layout
- **FlexItem**: Wraps children to specify flex properties (grow, shrink, size)
- **AbsoluteItem**: For absolute positioning within the flex container
- **SizeUnit**: Used to specify dimensions (fixed, percentage, etc.)
- **SpacingUnit**: Used to specify gaps between items
- **PositionUnit**: Used for positioning (top, left, right, bottom)
