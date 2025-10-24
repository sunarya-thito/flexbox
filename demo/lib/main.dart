import 'package:demo/cases/case_absolute.dart';
import 'package:demo/cases/case_align_items_center_row_flex_grow.dart';
import 'package:demo/cases/case_align_items_stretch_column.dart';
import 'package:demo/cases/case_align_self_row.dart';
import 'package:demo/cases/case_builder.dart';
import 'package:demo/cases/case_column.dart';
import 'package:demo/cases/case_column_reverse.dart';
import 'package:demo/cases/case_flex_wrap_column.dart';
import 'package:demo/cases/case_flex_wrap_column_reverse.dart';
import 'package:demo/cases/case_flex_wrap_reverse_column.dart';
import 'package:demo/cases/case_flex_wrap_reverse_column_reverse.dart';
import 'package:demo/cases/case_flex_wrap_reverse_row_reverse.dart';
import 'package:demo/cases/case_flex_wrap_row_reverse.dart';
import 'package:demo/cases/case_index_finder.dart';
import 'package:demo/cases/case_items_start.dart';
import 'package:demo/cases/case_position_type.dart';
import 'package:demo/cases/case_rotated.dart';
import 'package:demo/cases/case_row_reverse.dart';
import 'package:demo/cases/case_rtl_column.dart';
import 'package:demo/cases/case_rtl_column_reverse.dart';
import 'package:demo/cases/case_rtl_row.dart';
import 'package:demo/cases/case_rtl_row_reverse.dart';
import 'package:demo/cases/case_rtl_wrap.dart';
import 'package:demo/cases/case_rtl_wrap_column.dart';
import 'package:demo/cases/case_rtl_wrap_column_reverse.dart';
import 'package:demo/cases/case_rtl_wrap_reverse.dart';
import 'package:demo/cases/case_rtl_wrap_reverse_column.dart';
import 'package:demo/cases/case_rtl_wrap_reverse_column_reverse.dart';
import 'package:demo/cases/case_scrollable.dart';
import 'package:demo/cases/case_scrollable_absolute.dart';
import 'package:demo/cases/case_scrollable_sticky.dart';
import 'package:demo/cases/case_scrollable_unclipped.dart';
import 'package:demo/cases/case_simple.dart';
import 'package:demo/cases/case_justify_start.dart';
import 'package:demo/cases/case_flex_grow.dart';
import 'package:demo/cases/case_flex_shrink.dart';
import 'package:demo/cases/case_flex_wrap.dart';
import 'package:demo/cases/case_flex_wrap_reverse.dart';
import 'package:demo/cases/case_spacing_around.dart';
import 'package:demo/cases/case_spacing_between.dart';
import 'package:demo/cases/case_spacing_evenly.dart';
import 'package:demo/cases/case_wrap_content_between.dart';
import 'package:demo/cases/case_wrap_items_center.dart';
import 'package:demo/cases/case_wrap_content_center.dart';
import 'package:demo/cases/case_padded.dart';
import 'package:demo/cases/case_spacing.dart';
import 'package:demo/cases/case_items_center.dart';
import 'package:demo/cases/case_items_end.dart';
import 'package:demo/cases/case_items_stretch.dart';
import 'package:demo/cases/case_justify_center.dart';
import 'package:demo/cases/case_justify_end.dart';
import 'package:demo/cases/case_wrap_content_start.dart';
import 'package:demo/cases/case_wrap_items_end.dart';
import 'package:demo/cases/case_wrap_items_start.dart';
import 'package:demo/demo.dart';
import 'package:flutter/material.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:demo/cases/case_column_gap_column.dart';
import 'package:demo/cases/case_column_gap_row.dart';
import 'package:demo/cases/case_gaps_column_flex_grow.dart';
import 'package:demo/cases/case_gaps_column_flex_shrink.dart';
import 'package:demo/cases/case_gaps_column_reverse.dart';
import 'package:demo/cases/case_gaps_column_wrap.dart';
import 'package:demo/cases/case_gaps_column_wrap_reverse.dart';
import 'package:demo/cases/case_gaps_row_flex_grow.dart';
import 'package:demo/cases/case_gaps_row_flex_shrink.dart';
import 'package:demo/cases/case_gaps_row_reverse.dart';
import 'package:demo/cases/case_gaps_row_wrap.dart';
import 'package:demo/cases/case_gaps_row_wrap_reverse.dart';
import 'package:demo/cases/case_gaps_rtl_column.dart';
import 'package:demo/cases/case_gaps_rtl_row.dart';
import 'package:demo/cases/case_gaps_rtl_row_wrap.dart';
import 'package:demo/cases/case_row_gap_column.dart';
import 'package:demo/cases/case_row_gap_row.dart';
import 'package:demo/cases/case_flex_grow_constrained_height.dart';
import 'package:demo/cases/case_flex_grow_constrained_width.dart';
import 'package:demo/cases/case_flex_shrink_constrained_height.dart';
import 'package:demo/cases/case_flex_shrink_constrained_width.dart';
import 'package:demo/cases/case_flex_grow_unconstrained.dart';
import 'package:demo/cases/case_flex_shrink_unconstrained.dart';
import 'package:demo/cases/case_flex_wrap_column_reverse_unconstrained.dart';
import 'package:demo/cases/case_flex_wrap_column_unconstrained.dart';
import 'package:demo/cases/case_flex_wrap_reverse_column_reverse_unconstrained.dart';
import 'package:demo/cases/case_flex_wrap_reverse_column_unconstrained.dart';
import 'package:demo/cases/case_flex_wrap_reverse_unconstrained.dart';
import 'package:demo/cases/case_flex_wrap_row_reverse_unconstrained.dart';
import 'package:demo/cases/case_flex_wrap_unconstrained.dart';
import 'package:demo/cases/case_gaps_column_flex_grow_unconstrained.dart';
import 'package:demo/cases/case_gaps_column_flex_shrink_unconstrained.dart';
import 'package:demo/cases/case_gaps_column_reverse_unconstrained.dart';
import 'package:demo/cases/case_gaps_column_wrap_reverse_unconstrained.dart';
import 'package:demo/cases/case_gaps_column_wrap_unconstrained.dart';
import 'package:demo/cases/case_gaps_row_flex_grow_unconstrained.dart';
import 'package:demo/cases/case_gaps_row_flex_shrink_unconstrained.dart';
import 'package:demo/cases/case_gaps_row_reverse_unconstrained.dart';
import 'package:demo/cases/case_gaps_row_wrap_reverse_unconstrained.dart';
import 'package:demo/cases/case_gaps_row_wrap_unconstrained.dart';
import 'package:demo/cases/case_gaps_rtl_column_unconstrained.dart';
import 'package:demo/cases/case_gaps_rtl_row_unconstrained.dart';
import 'package:demo/cases/case_gaps_rtl_row_wrap_unconstrained.dart';
import 'package:demo/cases/case_justify_content_space_between_row.dart';
import 'package:demo/cases/case_overflow_column.dart';
import 'package:demo/cases/case_overflow_large_content.dart';
import 'package:demo/cases/case_overflow_row.dart';
import 'package:demo/cases/case_rtl_wrap_column_reverse_unconstrained.dart';
import 'package:demo/cases/case_rtl_wrap_column_unconstrained.dart';
import 'package:demo/cases/case_rtl_wrap_reverse_column_reverse_unconstrained.dart';
import 'package:demo/cases/case_rtl_wrap_reverse_column_unconstrained.dart';
import 'package:demo/cases/case_rtl_wrap_reverse_unconstrained.dart';
import 'package:demo/cases/case_rtl_wrap_unconstrained.dart';

final testCases = [
  CasePositionType(),

  // Row Examples
  CaseSimple(), // Row example
  CaseRowReverse(),
  CaseRTLRow(),
  CaseRTLRowReverse(),

  // Column Examples
  CaseColumn(),
  CaseColumnReverse(),
  CaseRTLColumn(),
  CaseRTLColumnReverse(),

  // Flex Properties
  CaseFlexGrow(),
  CaseFlexShrink(),

  // Constrained Flex
  CaseFlexGrowConstrainedWidth(),
  CaseFlexGrowConstrainedHeight(),
  CaseFlexShrinkConstrainedWidth(),
  CaseFlexShrinkConstrainedHeight(),

  // Unconstrained Flex
  CaseFlexGrowUnconstrained(),
  CaseFlexShrinkUnconstrained(),

  // Flex Wrap
  CaseFlexWrap(),
  CaseFlexWrapReverse(),
  CaseFlexWrapRowReverse(),
  CaseFlexWrapColumn(),
  CaseFlexWrapColumnReverse(),
  CaseFlexWrapReverseColumn(),
  CaseFlexWrapReverseColumnReverse(),
  CaseFlexWrapReverseRowReverse(),

  // Unconstrained Flex Wrap
  CaseFlexWrapUnconstrained(),
  CaseFlexWrapReverseUnconstrained(),
  CaseFlexWrapRowReverseUnconstrained(),
  CaseFlexWrapColumnUnconstrained(),
  CaseFlexWrapColumnReverseUnconstrained(),
  CaseFlexWrapReverseColumnUnconstrained(),
  CaseFlexWrapReverseColumnReverseUnconstrained(),

  // RTL Wrap
  CaseRTLWrap(),
  CaseRTLWrapReverse(),
  CaseRTLWrapColumn(),
  CaseRTLWrapColumnReverse(),
  CaseRTLWrapReverseColumn(),
  CaseRTLWrapReverseColumnReverse(),

  // Unconstrained RTL Wrap
  CaseRTLWrapUnconstrained(),
  CaseRTLWrapReverseUnconstrained(),
  CaseRTLWrapColumnUnconstrained(),
  CaseRTLWrapColumnReverseUnconstrained(),
  CaseRTLWrapReverseColumnUnconstrained(),
  CaseRTLWrapReverseColumnReverseUnconstrained(),

  // Alignment - Items
  // CaseItemsBaseline(),
  CaseItemsCenter(),
  CaseItemsEnd(),
  CaseItemsStart(),
  CaseItemsStretch(),

  // Additional Alignment Cases
  CaseAlignItemsStretchColumn(),
  CaseJustifyContentSpaceBetweenRow(),
  CaseAlignSelfRow(),
  CaseAlignItemsCenterRowFlexGrow(),

  // Alignment - Justify
  CaseJustifyCenter(),
  CaseJustifyEnd(),
  CaseJustifyStart(),

  // Spacing
  CaseSpacing(),
  CaseSpacingAround(),
  CaseSpacingBetween(),
  CaseSpacingEvenly(),

  // Gaps
  CaseRowGapRow(),
  CaseColumnGapRow(),
  CaseRowGapColumn(),
  CaseColumnGapColumn(),
  CaseGapsRowReverse(),
  CaseGapsColumnReverse(),
  CaseGapsRowWrap(),
  CaseGapsColumnWrap(),
  CaseGapsRowWrapReverse(),
  CaseGapsColumnWrapReverse(),
  CaseGapsColumnFlexGrow(),
  CaseGapsRowFlexGrow(),
  CaseGapsRowFlexShrink(),
  CaseGapsColumnFlexShrink(),
  CaseGapsRTLRow(),
  CaseGapsRTLColumn(),
  CaseGapsRTLRowWrap(),

  // Unconstrained Gaps
  CaseGapsRowReverseUnconstrained(),
  CaseGapsColumnReverseUnconstrained(),
  CaseGapsRowWrapUnconstrained(),
  CaseGapsColumnWrapUnconstrained(),
  CaseGapsRowWrapReverseUnconstrained(),
  CaseGapsColumnWrapReverseUnconstrained(),
  CaseGapsColumnFlexGrowUnconstrained(),
  CaseGapsRowFlexGrowUnconstrained(),
  CaseGapsRowFlexShrinkUnconstrained(),
  CaseGapsColumnFlexShrinkUnconstrained(),
  CaseGapsRTLRowUnconstrained(),
  CaseGapsRTLColumnUnconstrained(),
  CaseGapsRTLRowWrapUnconstrained(),

  // Padding
  CasePadded(),

  // Absolute Position
  CaseAbsolute(),

  // Overflow
  CaseOverflowRow(),
  CaseOverflowColumn(),
  CaseOverflowLargeContent(),

  // Scrollable
  CaseScrollable(),
  CaseScrollableSticky(),
  CaseUnclippedScrollable(),
  CaseScrollableAbsolute(),

  // Wrap Content
  CaseWrapContentBetween(),
  CaseWrapContentCenter(),
  CaseWrapContentStart(),

  // Wrap Items
  CaseWrapItemsCenter(),
  CaseWrapItemsEnd(),
  CaseWrapItemsStart(),

  // Tools
  CaseIndexFinder(),
  CaseBuilder(),
  CaseRotated(),
];
late HighlighterTheme darkHighlighterTheme;
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Highlighter.initialize(['dart']);
  darkHighlighterTheme = await HighlighterTheme.loadDarkTheme();
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: DemoApp(
          testCases: testCases,
        ),
      ),
    ),
  );
}
