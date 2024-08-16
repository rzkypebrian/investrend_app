/*
import 'package:Investrend/component/chart_series_legend.dart';
import 'package:Investrend/component/charts/chart_color.dart';
import 'package:Investrend/component/charts/year_value.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartDualBar extends StatelessWidget {
  final List<YearValue> data_bar_1;
  final List<YearValue> data_bar_2;


  final String title_bar_1;
  final String title_bar_2;


  final Color color_bar_1;
  final Color color_bar_2;


  final bool animate;

  const ChartDualBar(this.data_bar_1, this.data_bar_2,  this.title_bar_1, this.title_bar_2,  this.color_bar_1,
      this.color_bar_2,
      {Key key, this.animate = false})
      : super(key: key);

  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  @override
  Widget build(BuildContext context) {
    String languageCode = EasyLocalization.of(context).locale.languageCode;
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: new charts.OrdinalComboChart(
            _createData(),
            animate: animate,
            // Configure the default renderer as a bar renderer.
            defaultRenderer: new charts.BarRendererConfig(
              groupingType: charts.BarGroupingType.grouped,
              cornerStrategy: charts.ConstCornerStrategy(4),
              //symbolRenderer: charts.RectSymbolRenderer()
            ),
            primaryMeasureAxis: new charts.NumericAxisSpec(
                tickFormatterSpec: new charts.BasicNumericTickFormatterSpec.fromNumberFormat(NumberFormat('#％')),
                tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 4)),

            // primaryMeasureAxis: new charts.PercentAxisSpec(),
            secondaryMeasureAxis: new charts.NumericAxisSpec(
                tickFormatterSpec: new charts.BasicNumericTickFormatterSpec.fromNumberFormat(NumberFormat.compact(locale: languageCode/*'en_US'*/)),
                tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                  desiredTickCount: 4,
                )),
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
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        ChartSeriesLegend(
          text_0: title_bar_1,
          color_0: color_bar_1,
          text_1: title_bar_2,
          color_1: color_bar_2,

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
          colorFn: (_, __) => ChartColor(color_bar_1).shadeDefault,
          domainFn: (YearValue sales, _) => sales.year,
          measureFn: (YearValue sales, _) => sales.value,
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
      // new charts.Series<YearValue, String>(
      //     id: title_line,
      //     //colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      //     colorFn: (_, __) => ChartColor(color_line).shadeDefault,
      //     domainFn: (YearValue sales, _) => sales.year,
      //     measureFn: (YearValue sales, _) => sales.value,
      //     data: data_line)
      //   // Configure our custom line renderer for this series.
      //   ..setAttribute(charts.rendererIdKey, 'customLine'),

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
*/