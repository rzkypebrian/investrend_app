import 'package:Investrend/utils/investrend_theme.dart';
import 'package:intl/intl.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartLine extends StatefulWidget {
  List<Line> chartData;
  int chipsRangeIndex;
  double minimumData;
  double maximumData;
  List<String> listChipRange;

  ChartLine({
    Key key,
    this.chartData,
    @required this.chipsRangeIndex,
    this.minimumData,
    this.maximumData,
    this.listChipRange,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ChartLineState();
  }
}

class _ChartLineState extends State<ChartLine> {
  CrosshairBehavior _crosshairBehavior;
  TrackballBehavior _trackballBehavior;
  final formatString = NumberFormat('#,###');
  final dateFormat = new DateFormat('yyyy-MM-dd');
  final timeFormat = new DateFormat('HH:mm');

  @override
  void initState() {
    _crosshairBehavior = CrosshairBehavior(
      activationMode: ActivationMode.singleTap,
      enable: true,
      lineDashArray: [4, 5],
    );
    _trackballBehavior = TrackballBehavior(
        markerSettings: TrackballMarkerSettings(
          markerVisibility: TrackballVisibilityMode.auto,
          shape: DataMarkerType.circle,
        ),
        lineWidth: 0,
        lineColor: Colors.black,
        enable: true,
        activationMode: ActivationMode.singleTap,
        builder: (context, trackballDetails) {
          return Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                    //     widget.chipsRangeIndex == 0
                    // ? timeFormat.format(DateTime.parse(args.text)).toString()
                    // : dateFormat.format(DateTime.parse(args.text)).toString();
                    width: double.infinity,
                    child: widget.chipsRangeIndex == 0
                        ? Text(
                            timeFormat.format(trackballDetails.point.x),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            dateFormat.format(trackballDetails.point.x),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )),
                Container(
                  padding: EdgeInsets.only(top: 15),
                  width: double.infinity,
                  child: Divider(
                    color: Colors.white,
                    endIndent: 10,
                    indent: 10,
                    thickness: 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: Text(
                    formatString.format(trackballDetails.point.y).toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          );
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle styleRight =
        InvestrendTheme.of(context).more_support_w400_compact.copyWith(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
            );
    TextStyle styleBottom =
        InvestrendTheme.of(context).more_support_w400_compact.copyWith(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
            );
    return SfCartesianChart(
      series: <ChartSeries>[
        LineSeries<Line, DateTime>(
            dataSource: widget.chartData,
            xValueMapper: (Line lineData, _) => lineData.time,
            yValueMapper: (Line lineData, _) => lineData.close,
            markerSettings: MarkerSettings(
              isVisible: true,
              width: 0,
              height: 0,
            )),
      ],
      margin: EdgeInsets.all(0),
      trackballBehavior: _trackballBehavior,
      crosshairBehavior: _crosshairBehavior,
      onCrosshairPositionChanging: (CrosshairRenderArgs args) {
        if (args.orientation == AxisOrientation.horizontal) {
          String value = args.value;
          args.text = widget.chipsRangeIndex == 0
              ? timeFormat.format(DateTime.parse(value))
              : dateFormat.format(DateTime.parse(value));
        }
      },
      plotAreaBorderWidth: 0,

      //label bawah
      primaryXAxis: CategoryAxis(
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          String value = widget.chipsRangeIndex == 0
              ? timeFormat.format(DateTime.parse(args.text)).toString()
              : dateFormat.format(DateTime.parse(args.text)).toString();

          return ChartAxisLabel(
            value,
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
        majorGridLines: MajorGridLines(
          width: 0,
        ),
        majorTickLines: MajorTickLines(
          width: 0,
        ),
      ),

      //label kanan
      primaryYAxis: NumericAxis(
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          return ChartAxisLabel(
            args.text,
            TextStyle(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
              fontSize: 12,
            ),
          );
        },
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
        labelStyle: TextStyle(
          color: InvestrendTheme.of(context).greyDarkerTextColor,
          fontSize: 12,
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
