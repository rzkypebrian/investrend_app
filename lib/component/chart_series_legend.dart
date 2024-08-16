import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

enum LegendShape { Box, Line }

class ChartSeriesLegend extends StatelessWidget {
  final String text_0;
  final Color color_0;
  final LegendShape shape_0;

  final String text_1;
  final Color color_1;
  final LegendShape shape_1;

  final String text_2;
  final Color color_2;
  final LegendShape shape_2;

  final String text_3;
  final Color color_3;
  final LegendShape shape_3;

  const ChartSeriesLegend({
    this.text_0 = ' ',
    this.color_0 = Colors.transparent,
    this.text_1 = ' ',
    this.color_1 = Colors.transparent,
    this.text_2 = ' ',
    this.color_2 = Colors.transparent,
    this.text_3 = ' ',
    this.color_3 = Colors.transparent,
    Key? key,
    this.shape_0 = LegendShape.Box,
    this.shape_1 = LegendShape.Box,
    this.shape_2 = LegendShape.Box,
    this.shape_3 = LegendShape.Box,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      //defaultVerticalAlignment: TableCellVerticalAlignment.,
      //border: TableBorder.all(color: Colors.black),

      columnWidths: {
        0: FractionColumnWidth(.4),
        1: FractionColumnWidth(.4),
      },
      children: [
        TableRow(children: [
          symbol(context, color_0, text_0, shape_0),
          symbol(context, color_1, text_1, shape_1),
        ]),
        TableRow(children: [
          symbol(context, color_2, text_2, shape_2),
          symbol(context, color_3, text_3, shape_3),
        ]),
      ],
    );
  }

  Widget symbol(
      BuildContext context, Color color, String text, LegendShape shape) {
    if (shape == LegendShape.Box) {
      return symbolBox(context, color, text);
    } else {
      return symbolLine(context, color, text);
    }
  }

  Widget symbolBox(BuildContext context, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(
                text,
                style: InvestrendTheme.of(context)
                    .more_support_w400_compact
                    ?.copyWith(
                        color: InvestrendTheme.of(context).greyDarkerTextColor),
              ))
        ],
      ),
    );
  }

  Widget symbolLine(BuildContext context, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8.0,
            height: 1.0,
            margin: EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(
                text,
                style: InvestrendTheme.of(context)
                    .more_support_w400_compact
                    ?.copyWith(
                        color: InvestrendTheme.of(context).greyDarkerTextColor),
              ))
        ],
      ),
    );
  }
}
