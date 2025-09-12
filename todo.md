# TODO-List

These are planned features for this package:

- [ ] FlexWrap (Not planned at the moment) What needs to be changed:
  - Flex recomputation if the line exceeds the main viewport size
  - Main axis wont become scrollable
  - There is going to be totalFlex per line, mainContentSize per line,
    mainFlexContentSize per line, flexFactor per line, line index (stored) in
    the FlexBoxParentData
  - Then there is going to be crossSpacing, crossSpacingStart, and
    crossSpacingEnd 💀
  - There is also going to be contentRelative, viewportRelative, and line
    relative
  - Main concern is how the wrap should behave against flex children:
    - If in a line is all flex, then there is no possibility the line will wrap
      into another line (care for min constraint here)
    - If in a line is just one giant box that exceeds the viewport size then the
      line is ignored and will not be wrapped into the next line
- [ ] (WIP) ExpandingSize in absolute children makes the children takes the
      remaining size (relative to content or to viewport)
- [ ] (WIP) If no anchor is present and children is absolute, children will use
      alignment as positioning (default to top left)
- [ ] (WIP) If content size + spacing exceeds the viewport size and scrolling is
      disabled, it should align the children based on the flex box alignment
- [ ] (WIP) ExpandingSize currently does not work in spacing
- [ ] (WIP) Make contentRelative option per size not per children, on a note
      that contentRelative ExpandingSize on main axis should still not be
      allowed
- [ ] (WIP) Remove error for content relative on non-absolute children
- [ ] (WIP) Implement flex fit
- [ ] (WIP) Int extension

Note:

- Multiply spacing size by the amount of children - 1
