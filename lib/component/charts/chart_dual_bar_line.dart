/*
import 'package:Investrend/component/chart_series_legend.dart';
// import 'package:Investrend/component/charts/chart_color.dart';
import 'package:Investrend/component/charts/year_value.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartDualBarLine extends StatelessWidget {
  final List<YearValue> data_bar_1;
  final List<YearValue> data_bar_2;
  final List<YearValue> data_line;

  final String title_bar_1;
  final String title_bar_2;
  final String title_line;

  final Color color_bar_1;
  final Color color_bar_2;
  final Color color_line;

  final bool animate;
  final double max_value;
  final double min_value;

  const ChartDualBarLine(
      this.data_bar_1,
      this.data_bar_2,
      this.data_line,
      this.title_bar_1,
      this.title_bar_2,
      this.title_line,
      this.color_bar_1,
      this.color_bar_2,
      this.color_line,
      {required Key key,
      this.animate = false,
      this.max_value = 0.0,
      this.min_value = 0.0})
      : super(key: key);

  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  @override
  Widget build(BuildContext context) {
    String? languageCode = EasyLocalization.of(context)?.locale.languageCode;

    // if(min_value < 0.0 && max_value > 0.0){
    //   min_value = max_value * -1;
    // }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              new charts.OrdinalComboChart(
                _createData(),
                animate: animate,
                // Configure the default renderer as a bar renderer.
                defaultRenderer: new charts.BarRendererConfig(
                  groupingType: charts.BarGroupingType.grouped,
                  cornerStrategy: charts.ConstCornerStrategy(4),
                  //symbolRenderer: charts.RectSymbolRenderer()
                ),
                primaryMeasureAxis: new charts.NumericAxisSpec(
                  tickFormatterSpec:
                      new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
                          NumberFormat('#％')),
                  tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                      desiredTickCount: 4),
                  // tickProviderSpec: new charts.StaticNumericTickProviderSpec(
                  //   <charts.TickSpec<num>>[
                  //     charts.TickSpec<num>(min_value),
                  //     charts.TickSpec<num>((max_value - min_value) / 2),
                  //     charts.TickSpec<num>(max_value),
                  //   ],
                  // ),
                ),

                // primaryMeasureAxis: new charts.PercentAxisSpec(),
                secondaryMeasureAxis: new charts.NumericAxisSpec(
                  tickFormatterSpec: new charts
                      .BasicNumericTickFormatterSpec.fromNumberFormat(
                      NumberFormat.compact(locale: languageCode /*'en_US'*/)),
                  tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                    desiredTickCount: 4,
                  ),
                  //showAxisLine: true,
                  // tickProviderSpec: new charts.StaticNumericTickProviderSpec(
                  //   <charts.TickSpec<num>>[
                  //     charts.TickSpec<num>(min_value),
                  //     charts.TickSpec<num>((max_value - min_value) *1),
                  //     charts.TickSpec<num>((max_value - min_value) *3),
                  //     charts.TickSpec<num>(max_value),
                  //   ],
                  // ),
                ),

                // Custom renderer configuration for the line series. This will be used for
                // any series that does not define a rendererIdKey.
                customSeriesRenderers: [
                  new charts.LineRendererConfig(
                      includeLine: true,
                      includePoints: true,
                      //strokeWidthPx: 10,
                      radiusPx: 3,
                      strokeWidthPx: 1.0,
                      // ID used to link series to this renderer.
                      customRendererId: 'customLine'),

                  // new charts.LineRendererConfig(
                  //
                  //     includeLine: true,
                  //     includePoints: true,
                  //
                  //     //strokeWidthPx: 10,
                  //     radiusPx: 5,
                  //     // ID used to link series to this renderer.
                  //     customRendererId: 'customLineConvoy'),
                ],

                behaviors: [
                  //new charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
                  // charts.LinePointHighlighter(
                  //     symbolRenderer: CustomCircleSymbolRenderer()
                  // ),
                  // new charts.LinePointHighlighter(
                  //     showHorizontalFollowLine:
                  //     charts.LinePointHighlighterFollowLineType.all,
                  //     // showVerticalFollowLine:
                  //     // charts.LinePointHighlighterFollowLineType.nearest
                  // ),
                  // // Optional - By default, select nearest is configured to trigger
                  // // with tap so that a user can have pan/zoom behavior and line point
                  // // highlighter. Changing the trigger to tap and drag allows the
                  // // highlighter to follow the dragging gesture but it is not
                  // // recommended to be used when pan/zoom behavior is enabled.
                  // new charts.SelectNearest(eventTrigger: charts.SelectionTrigger.tapAndDrag)
                ],
                // selectionModels: [
                //
                // ],
              ),
              Container(
                width: 8.0,
                height: 1.0,
                decoration: BoxDecoration(
                  color: color_line,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        ChartSeriesLegend(
          text_0: title_bar_1,
          color_0: color_bar_1,
          text_1: title_line,
          color_1: color_line,
          shape_1: LegendShape.Line,
          text_2: title_bar_2,
          color_2: color_bar_2,
        ),
      ],
    );
  }

  List<charts.Series<YearValue, String>> _createData() {
    // final desktopSalesData = [
    //   new YearValue('2014', 10),
    //   new YearValue('2015', 20),
    //   new YearValue('2016', 30),
    //   new YearValue('2017', 50),
    //   new YearValue('2018', 5),
    //   new YearValue('2019', 15),
    //   new YearValue('2020', 80),
    //   new YearValue('2021', 30),
    // ];

    // final tableSalesData = [
    //   new YearValue('2014', 2000000),
    //   new YearValue('2015', 9000000),
    //   new YearValue('2016', 8000000),
    //   new YearValue('2017', 3000000),
    //   new YearValue('2018', 6000000),
    //   new YearValue('2019', 2000000),
    //   new YearValue('2020', 8000000),
    //   new YearValue('2021', 10000000),
    // ];

    // final mobileSalesData = [
    //   new YearValue('2014', 17),
    //   new YearValue('2015', 28),
    //   new YearValue('2016', 33),
    //   new YearValue('2017', 55),
    //   new YearValue('2018', 10),
    //   new YearValue('2019', 20),
    //   new YearValue('2020', 50),
    //   new YearValue('2021', 20),
    // ];

    // final convoySalesData = [
    //   new OrdinalSales('2014', 10),
    //   new OrdinalSales('2015', 20),
    //   new OrdinalSales('2016', 30),
    //   new OrdinalSales('2017', 50),
    //   new OrdinalSales('2018', 5),
    //   new OrdinalSales('2019', 15),
    //   new OrdinalSales('2020', 30),
    //   new OrdinalSales('2021', 80),
    // ];

    return [
      new charts.Series<YearValue, String>(
          id: title_bar_1,
          //colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
          //colorFn: (_, __) => ChartColorPurple().shadeDefault,
          // colorFn: (_, __) => ChartColor(color_bar_1).shadeDefault,
          colorFn: (_, __) =>,
          domainFn: (YearValue sales, _) => sales.year,
          measureFn: (YearValue sales, _) => sales.value,
          // measureLowerBoundFn: (YearValue sales, _) => sales.value,
          // measureUpperBoundFn: (YearValue sales, _) => sales.value,
          data: data_bar_1)
        ..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId),
      new charts.Series<YearValue, String>(
          id: title_bar_2,
          //colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          colorFn: (_, __) => ChartColor(color_bar_2).shadeDefault,
          domainFn: (YearValue sales, _) => sales.year,
          measureFn: (YearValue sales, _) => sales.value,
          data: data_bar_2)
        ..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
      // Set the 'Los Angeles Revenue' series to use the secondary measure axis.
      // All series that have this set will use the secondary measure axis.
      // All other series will use the primary measure axis.
      ,
      new charts.Series<YearValue, String>(
          id: title_line,
          //colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          colorFn: (_, __) => ChartColor(color_line).shadeDefault,
          domainFn: (YearValue sales, _) => sales.year,
          measureFn: (YearValue sales, _) => sales.value,
          data: data_line)
        // Configure our custom line renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customLine'),

      // new charts.Series<OrdinalSales, String>(
      //     id: 'Convoy ',
      //     colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
      //     domainFn: (OrdinalSales sales, _) => sales.year,
      //     measureFn: (OrdinalSales sales, _) => sales.sales,
      //     data: convoySalesData)
      // // Configure our custom line renderer for this series.
      //   ..setAttribute(charts.rendererIdKey, 'customLineConvoy'),
    ];
  }
}
// class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
//
//   @override
//   void paint(charts.ChartCanvas canvas, Rectangle<num> bounds, {List<int> dashPattern, Color fillColor, Color strokeColor, double strokeWidthPx}) {
//     super.paint(canvas, bounds, dashPattern: dashPattern, fillColor: charts.Color.black, strokeColor: charts.Color.white, strokeWidthPx: strokeWidthPx);
//     canvas.drawRect(
//         Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10, bounds.height + 10),
//         fill: charts.Color.white
//     );
//     var textStyle = style.TextStyle();
//     textStyle.color = charts.Color.white;
//     textStyle.fontSize = 15;
//     canvas.drawText(
//         TextElement("1", style: textStyle),
//         (bounds.left).round(),
//         (bounds.top - 28).round()
//     );
//   }
// }
*/  