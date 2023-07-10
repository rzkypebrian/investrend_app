
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class CandlestickChart extends StatefulWidget {
  List<Ohlcv> chartData;
  ChartOhlcvData data;
  double minimumData;
  double maximumData;
  DateTime time;

  CandlestickChart({
    Key key,
    this.chartData,
    this.minimumData,
    this.maximumData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CandlestickChartState();
  }
}

class _CandlestickChartState extends State<CandlestickChart> {
  CrosshairBehavior _crosshairBehavior;
  TrackballBehavior _trackballBehavior;
  final dateFormat = new DateFormat('yyyy-MM-dd');
  final formatString = NumberFormat('#,###');

  @override
  void initState() {
    _crosshairBehavior = CrosshairBehavior(
      activationMode: ActivationMode.singleTap,
      enable: true,
      lineDashArray: [4, 5],
    );
    _trackballBehavior = TrackballBehavior(
        lineWidth: 0,
        lineColor: Colors.black,
        enable: true,
        activationMode: ActivationMode.singleTap,
        builder: (context, trackballDetails) {
          return Container(
            width: 140,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    dateFormat.format(trackballDetails.point.x),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      margin: EdgeInsets.only(
                        left: 10,
                      ),
                      decoration: BoxDecoration(
                        color: trackballDetails.point.open >
                                trackballDetails.point.close
                            ? Colors.red
                            : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Stack(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Text(
                                "High : ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatString
                                    .format(trackballDetails.point.high),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          child: Row(
                            children: [
                              Text(
                                "Low : ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatString.format(trackballDetails.point.low),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Row(
                            children: [
                              Text(
                                "Open : ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatString
                                    .format(trackballDetails.point.open),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 45),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.all(0),
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  "Close : ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                formatString
                                    .format(trackballDetails.point.close),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TextStyle styleRight =
    //     InvestrendTheme.of(context).more_support_w400_compact.copyWith(
    //           color: InvestrendTheme.of(context).greyDarkerTextColor,
    //         );
    TextStyle styleBottom =
        InvestrendTheme.of(context).more_support_w400_compact.copyWith(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
            );

    return SfCartesianChart(
      margin: EdgeInsets.zero,
      crosshairBehavior: _crosshairBehavior,
      onCrosshairPositionChanging: (CrosshairRenderArgs args) {
        if (args.orientation == AxisOrientation.horizontal) {
          String value = args.value;
          args.text = dateFormat.format(DateTime.parse(value));
        }
      },
      enableAxisAnimation: true,
      trackballBehavior: _trackballBehavior,
      series: <CandleSeries>[
        CandleSeries<Ohlcv, DateTime>(
          animationDuration: 0,
          bearColor: Colors.red,
          bullColor: Colors.green,
          enableSolidCandles: true,
          dataSource: widget.chartData,
          xValueMapper: (Ohlcv sales, _) => sales.time,
          lowValueMapper: (Ohlcv sales, _) => sales.low,
          highValueMapper: (Ohlcv sales, _) => sales.hi,
          openValueMapper: (Ohlcv sales, _) => sales.open,
          closeValueMapper: (Ohlcv sales, _) => sales.close,
        ),
      ],
      plotAreaBorderWidth: 0,

      //label bawah
      primaryXAxis: CategoryAxis(
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          String value =
              dateFormat.format(DateTime.parse(args.text)).toString();
          return ChartAxisLabel(
            value,
            // styleBottom,
            TextStyle(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
              fontSize: 12,
            ),
          );
        },
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        axisLine: AxisLine(
          width: 0,
        ),
        // labelStyle: InvestrendTheme.of(context)
        //     .more_support_w400_compact
        //     .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
        majorGridLines: MajorGridLines(
          width: 0,
        ),
        majorTickLines: MajorTickLines(
          width: 0,
        ),
        // dateFormat: dateFormat,
      ),
      //  double gap = (data.maxValue - data.minValue) / 4;
      //     double gapMiddle = (data.maxValue - data.minValue) / 2;

      //     List<double> rightValue = [
      //       data.maxValue,
      //       data.maxValue - gap,
      //       data.maxValue - gapMiddle,
      //       data.minValue + gap,
      //       data.minValue,
      //     ];

      //label kanan
      primaryYAxis: NumericAxis(
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          return ChartAxisLabel(
            args.text,
            // styleRight,
            TextStyle(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
              fontSize: 12,
            ),
          );
        },
        rangePadding: ChartRangePadding.additional,
        minimum: widget.minimumData,
        maximum: widget.maximumData,
        axisLine: AxisLine(
          width: 0,
        ),
        opposedPosition: true,
        majorGridLines: MajorGridLines(
          width: 0,
          color: Colors.grey.shade600,
        ),
        numberFormat: formatString,
        majorTickLines: MajorTickLines(
          width: 0,
        ),
        minorTickLines: MinorTickLines(
          width: 0,
        ),
      ),
    );
  }
}
