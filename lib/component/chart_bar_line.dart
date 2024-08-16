// import 'package:Investrend/component/charts/year_value.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;

// class ChartBarLine extends StatelessWidget {
//   final List<charts.Series> seriesList;
//   final bool animate;

//   ChartBarLine(this.seriesList, {required this.animate});

//   factory ChartBarLine.withSampleData() {
//     return new ChartBarLine(
//       _createSampleData(),
//       // Disable animations for image tests.
//       animate: false,
//     );
//   }

//   static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';
//   @override
//   Widget build(BuildContext context) {
//     String languageCode = EasyLocalization.of(context)!.locale.languageCode;
//     return new charts.OrdinalComboChart(
//       seriesList,
//       animate: animate,
//       // Configure the default renderer as a bar renderer.
//       defaultRenderer: new charts.BarRendererConfig(
//         groupingType: charts.BarGroupingType.grouped,
//         cornerStrategy: charts.ConstCornerStrategy(4),
//         //symbolRenderer: charts.RectSymbolRenderer()
//       ),
//       primaryMeasureAxis: new charts.NumericAxisSpec(
//           tickFormatterSpec:
//               new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
//                   NumberFormat('#％')),
//           tickProviderSpec:
//               new charts.BasicNumericTickProviderSpec(desiredTickCount: 4)),

//       // primaryMeasureAxis: new charts.PercentAxisSpec(),
//       secondaryMeasureAxis: new charts.NumericAxisSpec(
//           tickFormatterSpec:
//               new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
//                   NumberFormat.compact(locale: languageCode /*'en_US'*/)),
//           tickProviderSpec: new charts.BasicNumericTickProviderSpec(
//             desiredTickCount: 4,
//           )),
//       // Custom renderer configuration for the line series. This will be used for
//       // any series that does not define a rendererIdKey.
//       customSeriesRenderers: [
//         new charts.LineRendererConfig(
//             includeLine: true,
//             includePoints: true,

//             //strokeWidthPx: 10,
//             radiusPx: 5,
//             // ID used to link series to this renderer.
//             customRendererId: 'customLine'),

//         // new charts.LineRendererConfig(
//         //
//         //     includeLine: true,
//         //     includePoints: true,
//         //
//         //     //strokeWidthPx: 10,
//         //     radiusPx: 5,
//         //     // ID used to link series to this renderer.
//         //     customRendererId: 'customLineConvoy'),
//       ],

//       behaviors: [
//         //new charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
//       ],
//     );
//   }

//   /// Create series list with multiple series
//   static List<charts.Series<YearValue, String>> _createSampleData() {
//     final desktopSalesData = [
//       new YearValue('2014', 10),
//       new YearValue('2015', 20),
//       new YearValue('2016', 30),
//       new YearValue('2017', 50),
//       new YearValue('2018', 5),
//       new YearValue('2019', 15),
//       new YearValue('2020', 80),
//       new YearValue('2021', 30),
//     ];

//     final tableSalesData = [
//       new YearValue('2014', 2000000),
//       new YearValue('2015', 9000000),
//       new YearValue('2016', 8000000),
//       new YearValue('2017', 3000000),
//       new YearValue('2018', 6000000),
//       new YearValue('2019', 2000000),
//       new YearValue('2020', 8000000),
//       new YearValue('2021', 10000000),
//     ];

//     final mobileSalesData = [
//       new YearValue('2014', 17),
//       new YearValue('2015', 28),
//       new YearValue('2016', 33),
//       new YearValue('2017', 55),
//       new YearValue('2018', 10),
//       new YearValue('2019', 20),
//       new YearValue('2020', 50),
//       new YearValue('2021', 20),
//     ];

//     // final convoySalesData = [
//     //   new OrdinalSales('2014', 10),
//     //   new OrdinalSales('2015', 20),
//     //   new OrdinalSales('2016', 30),
//     //   new OrdinalSales('2017', 50),
//     //   new OrdinalSales('2018', 5),
//     //   new OrdinalSales('2019', 15),
//     //   new OrdinalSales('2020', 30),
//     //   new OrdinalSales('2021', 80),
//     // ];

//     return [
//       new charts.Series<YearValue, String>(
//           id: 'Net Income',
//           colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
//           domainFn: (YearValue sales, _) => sales.year,
//           measureFn: (YearValue sales, _) => sales.value,
//           data: desktopSalesData),
//       new charts.Series<YearValue, String>(
//           id: 'Revenue',
//           colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
//           domainFn: (YearValue sales, _) => sales.year,
//           measureFn: (YearValue sales, _) => sales.value,
//           data: tableSalesData)
//         ..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
//       // Set the 'Los Angeles Revenue' series to use the secondary measure axis.
//       // All series that have this set will use the secondary measure axis.
//       // All other series will use the primary measure axis.
//       ,
//       new charts.Series<YearValue, String>(
//           id: 'Net Profit margin (NPM) ',
//           colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
//           domainFn: (YearValue sales, _) => sales.year,
//           measureFn: (YearValue sales, _) => sales.value,
//           data: mobileSalesData)
//         // Configure our custom line renderer for this series.
//         ..setAttribute(charts.rendererIdKey, 'customLine'),
//       // new charts.Series<OrdinalSales, String>(
//       //     id: 'Convoy ',
//       //     colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
//       //     domainFn: (OrdinalSales sales, _) => sales.year,
//       //     measureFn: (OrdinalSales sales, _) => sales.sales,
//       //     data: convoySalesData)
//       // // Configure our custom line renderer for this series.
//       //   ..setAttribute(charts.rendererIdKey, 'customLineConvoy'),
//     ];
//   }
// }


// /// Sample ordinal data type.


