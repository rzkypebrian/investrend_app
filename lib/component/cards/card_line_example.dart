// //import 'dart:math';

// //import 'package:Investrend/component/component_creator.dart';
// import 'package:Investrend/component/chart_candlestick.dart';
// import 'package:Investrend/objects/class_value_notifier.dart';
// import 'package:Investrend/objects/data_object.dart';
// import 'package:Investrend/utils/callbacks.dart';
// import 'package:Investrend/utils/investrend_theme.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'dart:ui' as ui;

// class CardChart extends StatefulWidget {
//   final ChartNotifier dataNotifier;
//   final ChartOhlcvNotifier ohlcvDataNotifier;
//   NumberFormat numberFormatRight;
//   final ValueNotifier<int> rangeNotifier;
//   //final StringCallback callbackRange;
//   final RangeCallback callbackRange;
//   final VoidCallback onRetry;

//   CardChart(this.dataNotifier, this.rangeNotifier,
//       {this.callbackRange,
//       Key key,
//       this.onRetry,
//       this.numberFormatRight,
//       this.ohlcvDataNotifier})
//       : super(key: key);

//   @override
//   _CardChartState createState() => _CardChartState();
// }

// class _CardChartState extends State<CardChart> {
//   bool candleChart = true;
//   List<String> _listChipRange = <String>[
//     '1D',
//     '1W',
//     '1M',
//     '3M',
//     '6M',
//     '1Y',
//     '5Y',
//     'All'
//   ];
//   //int _selectedRange = 0;
//   Key keyRange = UniqueKey();

//   //int _selectedMarket = 0;
//   final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       //color: Colors.lightBlueAccent,
//       margin: EdgeInsets.zero,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _chipsRange(context),
//           ValueListenableBuilder(
//             valueListenable: widget.dataNotifier,
//             builder: (context, ChartLineData data, child) {
//               Widget noWidget = widget.dataNotifier.currentState
//                   .getNoWidget(onRetry: widget.onRetry);
//               if (noWidget != null) {
//                 return Container(
//                   width: double.maxFinite,
//                   height: 220,
//                   child: Center(child: noWidget),
//                 );
//               }
//               return CustomPaint(
//                 size: Size(double.maxFinite, 220),
//                 painter: ChartPainter(context, data, widget.numberFormatRight),
//               );

//               // return Placeholder(
//               //   fallbackWidth: double.maxFinite,
//               //   fallbackHeight: 220.0,
//               // );
//             },
//           )
//           // : ValueListenableBuilder(
//           //     valueListenable: widget.ohlcvDataNotifier,
//           //     builder: (context, ChartOhlcvData data, child) {
//           //       debugPrint("MASUK SINI OHLCV $data");
//           //       return CandlestickChart(
//           //         chartData: data.datas,
//           //       );
//           //     })
//         ],
//       ),
//     );
//   }

//   LineChartData mainData(LineChartBarData lineData, ChartLineData data) {
//     return LineChartData(
//       gridData: FlGridData(
//         show: false,
//         drawVerticalLine: true,

//         // getDrawingHorizontalLine: (value) {
//         //   return FlLine(
//         //     //color: const Color(0xff37434d),
//         //     color: Colors.deepOrange,
//         //     strokeWidth: 1,
//         //   );
//         // },
//         // getDrawingVerticalLine: (value) {
//         //   return FlLine(
//         //     color: const Color(0xff37434d),
//         //     strokeWidth: 1,
//         //   );
//         // },
//       ),
//       titlesData: FlTitlesData(
//         show: true,
//         bottomTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 22,
//           getTextStyles: (value) => InvestrendTheme.of(context)
//               .support_w400_compact
//               .copyWith(color: Colors.purple),
//           getTitles: (value) {
//             print('getTitles $value   spots : ' +
//                 lineData.spots.length.toString());
//             switch (value.toInt()) {
//               case 2:
//                 return 'MAR';
//               case 5:
//                 return 'JUN';
//               case 8:
//                 return 'SEP';
//             }
//             return '';
//           },
//           margin: 8,
//         ),
//         leftTitles: SideTitles(showTitles: false),
//         rightTitles: SideTitles(
//           showTitles: true,
//           getTextStyles: (value) => InvestrendTheme.of(context)
//               .support_w400_compact
//               .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
//           getTitles: (value) {
//             if (value == data.minValue) {
//               return InvestrendTheme.formatPriceDouble(data.minValue,
//                   showDecimal: false);
//             }
//             if (value == data.maxValue) {
//               return InvestrendTheme.formatPriceDouble(data.maxValue,
//                   showDecimal: false);
//             }

//             switch (value.toInt()) {
//               case 1:
//                 return data.minValue.toString();
//               case 3:
//                 return '30k';
//               case 5:
//                 return '50k';
//             }
//             return '';
//           },
//           reservedSize: 28,
//           margin: 12,
//         ),
//       ),
//       borderData: FlBorderData(
//           show: false,
//           border: Border.all(color: const Color(0xff37434d), width: 1)),
//       minX: 0,
//       maxX: lineData.spots.length?.toDouble(),
//       minY: data.minValue,
//       maxY: data.maxValue,
//       lineBarsData: [
//         lineData
//         /*
//         LineChartBarData(
//           spots: [
//             FlSpot(0, 3),
//             FlSpot(2.6, 2),
//             FlSpot(4.9, 5),
//             FlSpot(6.8, 3.1),
//             FlSpot(8, 4),
//             FlSpot(9.5, 3),
//             FlSpot(11, 4),
//           ],
//           isCurved: false,
//           colors: gradientColors,
//           barWidth: 5,
//           isStrokeCapRound: true,
//           dotData: FlDotData(
//             show: false,
//           ),
//           belowBarData: BarAreaData(
//             show: true,
//             colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
//           ),
//         ),

//          */
//       ],
//     );
//   }

//   List<Color> gradientColors = [
//     const Color(0xff23b6e6),
//     const Color(0xff02d39a),
//   ];

//   Widget _chipsRange(BuildContext context) {
//     double marginPadding =
//         InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
//     // double marginPadding = 0;
//     return Container(
//       //color: Colors.green,
//       margin: EdgeInsets.only(bottom: marginPadding),
//       width: double.maxFinite,
//       height: 30.0,

//       decoration: BoxDecoration(
//         //color: Colors.green,
//         color: InvestrendTheme.of(context).tileBackground,
//         border: Border.all(
//           color: InvestrendTheme.of(context).chipBorder,
//           width: 1.0,
//         ),
//         borderRadius: BorderRadius.circular(2.0),

//         //color: Colors.green,
//       ),
//       child: ValueListenableBuilder<int>(
//           valueListenable: widget.rangeNotifier,
//           builder: (context, value, child) {
//             return Row(
//               children: List<Widget>.generate(
//                 _listChipRange.length,
//                 (int index) {
//                   //print(_listChipRange[index]);
//                   bool selected = value == index;
//                   return Expanded(
//                     flex: 1,
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () {
//                           widget.rangeNotifier.value = index;
//                           executeCallback(index);
//                         },
//                         child: Container(
//                           color: selected
//                               ? Theme.of(context).accentColor
//                               : Colors.transparent,
//                           child: Center(
//                               child: Text(
//                             _listChipRange[index],
//                             style: InvestrendTheme.of(context)
//                                 .more_support_w400_compact
//                                 .copyWith(
//                                     color: selected
//                                         ? InvestrendTheme.of(context)
//                                             .textWhite /*Colors.white*/ : InvestrendTheme
//                                                 .of(context)
//                                             .blackAndWhiteText),
//                           )),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           }),
//       /*
//       child: Row(
//         children: List<Widget>.generate(
//           _listChipRange.length,
//           (int index) {
//             //print(_listChipRange[index]);
//             bool selected = _selectedRange == index;
//             return Expanded(
//               flex: 1,
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       _selectedRange = index;
//                       if (widget.callbackRange != null) {
//                         DateTime from;
//                         DateTime to;
//                         //widget.callbackRange(_listChipRange[_selectedRange]);
//                         //  0      1    2     3      4     5    6      7
//                         //['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];

//                         switch (_selectedRange) {
//                           case 0:
//                             {}
//                             break;
//                           case 1:
//                             {
//                               to = DateTime.now();
//                               from = DateTime.now().add(Duration(days: -7)); // - week
//                             }
//                             break;
//                           case 2:
//                             {
//                               to = DateTime.now();
//                               from = new DateTime(to.year, to.month - 1, to.day); // - 1 month
//                             }
//                             break;
//                           case 3:
//                             {
//                               to = DateTime.now();
//                               from = new DateTime(to.year, to.month - 3, to.day); // - 3 month
//                             }
//                             break;
//                           case 4:
//                             {
//                               to = DateTime.now();
//                               from = new DateTime(to.year, to.month - 6, to.day); // - 6 month
//                             }
//                             break;
//                           case 5:
//                             {
//                               to = DateTime.now();
//                               from = new DateTime(to.year - 1, to.month, to.day); // - 1 year
//                             }
//                             break;
//                           case 6:
//                             {
//                               to = DateTime.now();
//                               from = new DateTime(to.year - 5, to.month, to.day); // - 5 year
//                             }
//                             break;
//                           case 7:
//                             {
//                               to = DateTime.now();
//                               from = new DateTime(1945, 8, 17); // all
//                             }
//                             break;
//                         }

//                         String fromText = from == null ? '' : _dateFormat.format(from);
//                         String toText = to == null ? '' : _dateFormat.format(to);

//                         //fromText = _dateFormat.format(from);
//                         //toText = _dateFormat.format(to);

//                         widget.callbackRange(fromText, toText);
//                       }
//                     });
//                   },
//                   child: Container(
//                     color: selected ? Theme.of(context).accentColor : Colors.transparent,
//                     child: Center(
//                         child: Text(
//                       _listChipRange[index],
//                       style: InvestrendTheme.of(context)
//                           .more_support_w400_compact
//                           .copyWith(color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText),
//                     )),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       */
//     );
//   }

//   void executeCallback(int index) {
//     if (widget.callbackRange != null) {
//       DateTime from;
//       DateTime to;
//       //widget.callbackRange(_listChipRange[_selectedRange]);
//       //  0      1    2     3      4     5    6      7
//       //['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];

//       switch (index) {
//         case 0:
//           {}
//           break;
//         case 1:
//           {
//             to = DateTime.now();
//             from = DateTime.now().add(Duration(days: -7)); // - week
//           }
//           break;
//         case 2:
//           {
//             to = DateTime.now();
//             from = new DateTime(to.year, to.month - 1, to.day); // - 1 month
//           }
//           break;
//         case 3:
//           {
//             to = DateTime.now();
//             from = new DateTime(to.year, to.month - 3, to.day); // - 3 month
//           }
//           break;
//         case 4:
//           {
//             to = DateTime.now();
//             from = new DateTime(to.year, to.month - 6, to.day); // - 6 month
//           }
//           break;
//         case 5:
//           {
//             to = DateTime.now();
//             from = new DateTime(to.year - 1, to.month, to.day); // - 1 year
//           }
//           break;
//         case 6:
//           {
//             to = DateTime.now();
//             from = new DateTime(to.year - 5, to.month, to.day); // - 5 year
//           }
//           break;
//         case 7:
//           {
//             to = DateTime.now();
//             from = new DateTime(1945, 8, 17); // all
//           }
//           break;
//       }

//       String fromText = from == null ? '' : _dateFormat.format(from);
//       String toText = to == null ? '' : _dateFormat.format(to);

//       //fromText = _dateFormat.format(from);
//       //toText = _dateFormat.format(to);

//       widget.callbackRange(widget.rangeNotifier.value, fromText, toText);
//     }
//   }
// }

// class ChartPainter extends CustomPainter {
//   BuildContext context;
//   ChartLineData data;
//   NumberFormat numberFormatRight;
//   ChartPainter(this.context, this.data, this.numberFormatRight);

//   List<Offset> list = List.empty(growable: true);

//   Size getRightLabelSize(double maxValue, TextStyle style) {
//     String label = '';
//     int count = maxValue.toString().length;
//     for (int i = 0; i < count; i++) {
//       if (i == 0) {
//         label = '8';
//       } else {
//         label = label + '8';
//       }
//     }
//     return _textSize(label, style);
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     // TODO: implement paint
//     Paint paint = Paint()
//       ..color = Colors.blueAccent
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.0;
//     paint.strokeCap = StrokeCap.round;
//     paint.strokeJoin = StrokeJoin.round;
//     paint.isAntiAlias = true;

//     // canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
//     // canvas.drawLine(Offset(rightChart,0), Offset(rightChart, size.height), paint);

//     TextStyle styleRight = InvestrendTheme.of(context)
//         .more_support_w400_compact
//         .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
//     TextStyle styleBottom = InvestrendTheme.of(context)
//         .more_support_w400_compact
//         .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);

//     double last = 0.0;
//     int points = data.count();
//     if (points > 0) {
//       //Size rightLabelSize = getRightLabelSize(numberFormatRight == null ? data.maxValue : numberFormatRight.format(data.maxValue), styleRight);
//       Size rightLabelSize;
//       Size bottomLabelSize = _textSize('2021-00-00', styleBottom);

//       double gap = (data.maxValue - data.minValue) / 4;
//       double gapMiddle = (data.maxValue - data.minValue) / 2;

//       List<double> rightValue = [
//         data.maxValue,
//         data.maxValue - gap,
//         data.maxValue - gapMiddle,
//         data.minValue + gap,
//         data.minValue,
//       ];

//       double rightWidthLabel = 0;
//       rightValue.forEach((value) {
//         Size size = _textSize(' ' + formatRightLabel(value), styleRight);
//         if (rightLabelSize == null) {
//           rightLabelSize = size;
//           rightWidthLabel = size.width;
//         } else {
//           if (rightWidthLabel < size.width) {
//             rightWidthLabel = size.width;
//             rightLabelSize = size;
//           }
//         }

//         //rightWidthLabel = max(rightWidthLabel, size.width);
//       });

//       double left = 0;
//       double top = (rightLabelSize.height / 2);
//       double width = size.width - rightLabelSize.width;
//       double height = size.height -
//           (bottomLabelSize.height * 2) -
//           (rightLabelSize.height / 2);
//       Rect rectChart = Rect.fromLTWH(left, top, width, height);

//       if (data.maxValue == data.minValue) {
//         data.maxValue = data.maxValue * 2;
//       }
//       double verticalGap = data.maxValue - data.minValue;

//       // double cellX = (size.width - rightLabelSize.width) / points;
//       // double cellY = size.height / verticalGap;
//       double cellX = rectChart.width / points;
//       double cellY = rectChart.height / verticalGap;

//       // middle line START
//       paint.color = InvestrendTheme.of(context).greyLighterTextColor;
//       double yTextMidlle = (rectChart.top + rectChart.height) -
//           (cellY * ((data.maxValue - gapMiddle) - data.minValue)) -
//           (rightLabelSize.height / 2);
//       paint.strokeWidth = 0.5;
//       _drawDashedLine(canvas, paint, rectChart.left, rectChart.right,
//           rectChart.top + (rectChart.height / 2));
//       // middle line END

//       paint.strokeWidth = 1.0;
//       paint.color = InvestrendTheme.changeTextColor(data.last().close,
//           prev: data.prevValue);
//       //Offset from;

//       //Offset from = Offset(rectChart.left , (rectChart.top + rectChart.height) - (cellY * (data.prevValue - data.minValue)));

//       Offset from;
//       if (data.prevValue > 0) {
//         from = Offset(
//             rectChart.left,
//             (rectChart.top + rectChart.height) -
//                 (cellY * (data.prevValue - data.minValue)));
//       }
//       int leftLabelBottom = 0;
//       int centerLabelBottom = (points * 0.5).toInt();
//       int rightLabelBottom = points - 1;
//       double widthSegment = rectChart.width / 3;
//       bool insuficientPoint = points < 3;
//       bool onlyOneData = points == 1;
//       for (var i = 0; i <= points; i++) {
//         Line line = data.elemetAt(i);
//         if (line != null) {
//           last = line.close;
//           //Offset p = Offset(rectChart.left + (cellX * i), (rectChart.top + rectChart.height) - (cellY * (line.close - data.minValue)));
//           Offset p = Offset(
//               rectChart.left + (cellX * (i + 1)),
//               (rectChart.top + rectChart.height) -
//                   (cellY * (line.close - data.minValue)));
//           if (from == null) {
//             from = p;
//           } else {
//             canvas.drawLine(from, p, paint);
//             from = p;
//           }

//           bool isLeftLabelBottom = i == leftLabelBottom;
//           bool isCenterLabelBottom = i == centerLabelBottom;
//           bool isRightLabelBottom = i == rightLabelBottom;
//           //if( i == leftLabelBottom || i == centerLabelBottom || i == rightLabelBottom){

//           if (isLeftLabelBottom || isCenterLabelBottom || isRightLabelBottom) {
//             TextAlign textAlign = TextAlign.center;
//             if (insuficientPoint) {
//               textAlign = TextAlign.right;
//             } else {
//               if (isLeftLabelBottom) {
//                 textAlign = TextAlign.left;
//               } else if (isRightLabelBottom) {
//                 textAlign = TextAlign.right;
//               }
//             }

//             //final textPainter  = TextPainter(textDirection: ui.TextDirection.ltr, textAlign: TextAlign.center, maxLines: 1);
//             final textPainter = TextPainter(
//                 textDirection: ui.TextDirection.ltr,
//                 textAlign: textAlign,
//                 maxLines: 1);
//             final textSpan = TextSpan(
//               text: line.time,
//               style: styleBottom,
//             );
//             textPainter.text = textSpan;
//             textPainter.layout(
//               minWidth: 0,
//               maxWidth: rectChart.width / 3,
//             );

//             double xText = rectChart.left;
//             if (insuficientPoint) {
//               if (i == 0 && !onlyOneData) {
//                 xText = p.dx - (textPainter.size.width / 2);
//               } else {
//                 xText = p.dx - textPainter.size.width;
//               }
//             } else {
//               if (i == leftLabelBottom) {
//                 //xText += (widthSegment * 1) - (widthSegment/2) - (textPainter.size.width / 2);

//                 //xText += (widthSegment * 1) - (widthSegment/2) - (textPainter.size.width / 2);
//                 // if(onlyOneData){
//                 //   xText += (widthSegment * 1) -  textPainter.size.width;
//                 // }
//               } else if (i == centerLabelBottom) {
//                 xText += (widthSegment * 2) -
//                     (widthSegment / 2) -
//                     (textPainter.size.width / 2);
//               } else if (i == rightLabelBottom) {
//                 //xText += (widthSegment * 3) - (widthSegment/2) - (textPainter.size.width / 2);
//                 xText += rectChart.right - textPainter.size.width;
//               }
//             }

//             double yText = rectChart.bottom +
//                 textPainter.size.height; // (rectChart.top + rectChart.height) -
//             textPainter.paint(canvas, Offset(xText, yText));
//           }
//         }
//       }
//       final textPainter = TextPainter(
//           textDirection: ui.TextDirection.ltr,
//           textAlign: TextAlign.center,
//           maxLines: 1);

//       rightValue.forEach((value) {
//         final textSpan = TextSpan(
//           text: formatRightLabel(value),
//           style: styleRight,
//         );

//         textPainter.text = textSpan;
//         //textPainter.width = size.width - rightChart;
//         textPainter.layout(
//           minWidth: 0,
//           maxWidth: rightLabelSize.width,
//         );

//         double xText = size.width - textPainter.width;
//         double yText = (rectChart.top + rectChart.height) -
//             (cellY * (value - data.minValue)) -
//             (rightLabelSize.height / 2);
//         textPainter.paint(canvas, Offset(xText, yText));
//       });
//     }
//   }

//   String formatRightLabel(double value) {
//     if (numberFormatRight == null) {
//       return InvestrendTheme.formatPrice(value.truncate());
//     } else {
//       return numberFormatRight.format(value);
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     ChartPainter oldPainter = (oldDelegate as ChartPainter);

//     bool nullChanged = oldPainter.data == null || data == null;
//     if (nullChanged) {
//       print('shouldRepaint caused --> nullChanged : $nullChanged');
//       return nullChanged;
//     }
//     bool dataSizeChanged = oldPainter.data.count() != data.count();
//     if (dataSizeChanged) {
//       print('shouldRepaint caused --> dataSizeChanged : $dataSizeChanged');
//       return dataSizeChanged;
//     }
//     bool lastDataChanged = oldPainter.data.count() > 0 &&
//         data.count() > 0 &&
//         data.last().close != oldPainter.data.last().close;
//     if (lastDataChanged) {
//       print('shouldRepaint caused --> lastDataChanged : $lastDataChanged');
//       return lastDataChanged;
//     }
//     return false;
//   }

//   Size _textSize(String text, TextStyle style) {
//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(text: text, style: style),
//       maxLines: 1,
//       textDirection: ui.TextDirection.ltr,
//     )..layout(minWidth: 0, maxWidth: double.infinity);
//     return textPainter.size;
//   }

//   void _drawDashedLine(
//       Canvas canvas, Paint paint, double startX, double endX, double y) {
//     // Chage to your preferred size
//     const int dashWidth = 4;
//     const int dashSpace = 4;

//     // Start to draw from left size.
//     // Of course, you can change it to match your requirement.
//     // double startX = start.dx;
//     // double y = start.dx;

//     // Repeat drawing until we reach the right edge.
//     // In our example, size.with = 300 (from the SizedBox)
//     while ((startX + dashWidth) < endX) {
//       // Draw a small line.
//       canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);

//       // Update the starting X
//       startX += dashWidth + dashSpace;
//     }

//     double gap = endX - startX;
//     if (gap > 0) {
//       canvas.drawLine(Offset(startX, y), Offset(startX + gap, y), paint);
//     }
//   }
// }
