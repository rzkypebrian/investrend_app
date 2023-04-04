  import 'dart:math';

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rows/row_orderbook_painter.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
//import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetOrderbook extends StatelessWidget {

  final int maxShowLevel;
  final String owner;
  final VoidCallback onRetry;

  const WidgetOrderbook(/*this._orderbookNotifier,*/ this.maxShowLevel, {this.onRetry,Key key, this.owner = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        print('WidgetOrderbook constrains ' + constraints.maxWidth.toString());
        return buildOrderbook(context, constraints.maxWidth, constraints.maxHeight);
      },
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr, )
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static const double middle_gap = 20.0;

  Widget buildOrderbook(BuildContext context, double widthWidget, double heightWidget) {
    double widthHalf = widthWidget / 2;
    double widthSection = (widthWidget - middle_gap) / 2;


    return Consumer(builder: (context, watch,child){
      final notifier = watch(orderBookChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }

      List<Widget> list = List.empty(growable: true);

      Widget headers = createHeader(context, widthSection);
      list.add(headers);

      StockSummary stockSummary = context.read(stockSummaryChangeNotifier).summary;

      int prev = stockSummary != null
          && stockSummary.prev != null
          && StringUtils.equalsIgnoreCase(stockSummary.code, notifier.orderbook.code)
          ? stockSummary.prev
          : 0;

      int close = stockSummary != null
          && stockSummary.close != null
          && StringUtils.equalsIgnoreCase(stockSummary.code, notifier.orderbook.code)
          ? stockSummary.close
          : 0;

      notifier.orderbook.generateDataForUI(maxShowLevel);
      int totalVolumeShowedBid = notifier.orderbook.totalVolumeShowedBid;
      int totalVolumeShowedOffer = notifier.orderbook.totalVolumeShowedOffer;

      double fontSize = InvestrendTheme.of(context).small_w400.fontSize;
      fontSize = useFontSize(context, fontSize, widthSection, notifier.orderbook);
      int count = min(maxShowLevel, notifier.orderbook.countBids());
      for (int index = 0; index < count; index++) {
        // double fractionBid = value.bidVol(index) / totalVolumeShowedBid;
        // double fractionOffer = value.offerVol(index) / totalVolumeShowedOffer;

        bool showBid = notifier.orderbook.bids.elementAt(index) > 0;
        bool showOffer = notifier.orderbook.offers.elementAt(index) > 0;

        // print('orderbook[$index] --> fractionBid : $fractionBid  fractionOffer --> $fractionOffer');
        // print('orderbook[$index] --> totalBid : ' + value.totalBid.toString() + '  bidVol --> ' + value.bidVol(index).toString());
        // print('orderbook[$index] --> totalOffer : ' + value.totalOffer.toString() + '  offerVol --> ' + value.offerVol(index).toString());


        // String bidQueue = InvestrendTheme.formatComma(value.bidsQueue.elementAt(index));
        // String bidLot = InvestrendTheme.formatComma(value.bidLot(index));
        // String bidPrice = InvestrendTheme.formatPrice(value.bids.elementAt(index));
        // Color bidColor = InvestrendTheme.priceTextColor(value.bids.elementAt(index), prev: prev);
        //
        // String offerQueue = InvestrendTheme.formatComma(value.offersQueue.elementAt(index));
        // String offerLot = InvestrendTheme.formatComma(value.offerLot(index));
        // String offerPrice = InvestrendTheme.formatPrice(value.offers.elementAt(index));
        // Color offerColor = InvestrendTheme.priceTextColor(value.offers.elementAt(index), prev: prev);


        String bidQueue = notifier.orderbook.bidsQueueText.elementAt(index);
        String bidLot = notifier.orderbook.bidsLotText.elementAt(index);
        String bidPrice = notifier.orderbook.bidsText.elementAt(index);
        Color bidColor = prev == 0 ? InvestrendTheme.of(context).blackAndWhiteText : InvestrendTheme.priceTextColor(notifier.orderbook.bids.elementAt(index), prev: prev);
        String offerQueue = notifier.orderbook.offersQueueText.elementAt(index);
        String offerLot = notifier.orderbook.offersLotText.elementAt(index);
        String offerPrice = notifier.orderbook.offersText.elementAt(index);
        Color offerColor = prev == 0 ? InvestrendTheme.of(context).blackAndWhiteText : InvestrendTheme.priceTextColor(notifier.orderbook.offers.elementAt(index), prev: prev);

        // String bidQueue = '100,000';
        // String bidLot = '1,000,000';
        // String bidPrice = '200,000';
        // Color bidColor = InvestrendTheme.priceTextColor(value.bids.elementAt(index), prev: prev);
        // String offerQueue = InvestrendTheme.formatComma(value.offersQueue.elementAt(index));
        // String offerLot = InvestrendTheme.formatComma(value.offerLot(index));
        // String offerPrice = '1,780';
        // Color offerColor = InvestrendTheme.priceTextColor(value.offers.elementAt(index), prev: prev);


        list.add(createRow(
            context,
            bidQueue,
            bidLot,
            bidPrice,
            bidColor,
            offerQueue,
            offerLot,
            offerPrice,
            offerColor,
            widthSection, fontSize));
      }
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: list,
      );

    });

  }

  double useFontSize(BuildContext context, double fontSize, double widthSection, OrderBook value, {int offset=0}){
    print('WidgetOrderbook[$owner].useFontSize try fontSize  : $fontSize  offset : $offset');
    TextStyle small_w400 = InvestrendTheme.of(context).small_w400.copyWith(fontSize: fontSize);
    TextStyle small_w500 = InvestrendTheme.of(context).small_w500.copyWith(fontSize: fontSize);
    const double font_step = 1.0;
    int count = min(maxShowLevel, value.countBids());
    for (int index = offset; index < count; index++) {

      // String bidQueue = '100,000';
      // String bidLot = '1,000,000';
      // String bidPrice = '200,000';
      //
      // String offerQueue = InvestrendTheme.formatComma(value.offersQueue.elementAt(index));
      // String offerLot = InvestrendTheme.formatComma(value.offerLot(index));
      // String offerPrice = '1,780';

      String bidQueue = value.bidsQueueText.elementAt(index);
      String bidLot = value.bidsLotText.elementAt(index);
      String bidPrice = value.bidsText.elementAt(index);

      String offerQueue = value.offersQueueText.elementAt(index);
      String offerLot = value.offersLotText.elementAt(index);
      String offerPrice = value.offersText.elementAt(index);



      // double widthSectionTextLeft = _textSize(bidQueue, small_w400).width + _textSize(bidLot, small_w400).width + _textSize(bidPrice, small_w500).width;
      // double widthSectionTextRight = _textSize(offerPrice, small_w500).width + _textSize(offerLot, small_w400).width + _textSize(offerQueue, small_w400).width;

      String leftText = bidQueue + bidLot + bidPrice;
      String righText = offerPrice + offerLot + offerQueue;
      double widthSectionTextLeft = _textSize(leftText, small_w400).width;
      double widthSectionTextRight = _textSize(righText, small_w500).width;

      bool reduceFontSize = widthSectionTextLeft > widthSection || widthSectionTextRight > widthSection;
      // print(' useFontSize widthSection  : $widthSection   widthSectionTextLeft : $widthSectionTextLeft   widthSectionTextRight : $widthSectionTextRight  reduceFontSize : $reduceFontSize');
      if(reduceFontSize){
        fontSize = useFontSize(context, fontSize - 2, widthSection, value, offset: index);
        //break;
        return fontSize;
      }
    }
    print('WidgetOrderbook[$owner].useFontSize Final fontSize  : $fontSize  offset : $offset');
    return fontSize;
  }
  Widget createHeader(BuildContext context, double widthSection) {
    return Row(
      children: [
        Container(
          width: widthSection,
          //color: Colors.yellow,
          child: Stack(
            children: [
              createHeaderLeft(context, ''),
              Positioned.fill(child: createHeaderLeft(context, 'Que')),
              Positioned.fill(child: createHeaderCenter(context, 'BLot')),
              Positioned.fill(child: createHeaderRight(context, 'Bid')),
            ],
          ),
        ),
        SizedBox(
          width: middle_gap,
        ),
        Container(
          //color: Colors.greenAccent,
          width: widthSection,
          child: Stack(
            children: [
              createHeaderLeft(context, ''),
              Positioned.fill(child: createHeaderLeft(context, 'Ask')),
              Positioned.fill(child: createHeaderCenter(context, 'ALot')),
              Positioned.fill(child: createHeaderRight(context, 'Que')),
            ],
          ),
        ),
      ],
    );
  }

  Widget createRow(BuildContext context,
      String bidQueue,
      String bidLot,
      String bidPrice,
      Color bidColor,
      String offerQueue,
      String offerLot,
      String offerPrice,
      Color offerColor,
      double widthSection,
      double fontSize) {
    return Row(
      children: [
        Container(
          width: widthSection,
          //color: Colors.yellow,
          child: Stack(
            children: [
              createLabelPrice(context, fontSize, '', TextAlign.right, bidColor),
              Positioned.fill(child: createLabelQueue(context, fontSize, bidQueue, TextAlign.left)),
              Positioned.fill(child: createLabelLot(context, fontSize, bidLot)),
              Positioned.fill(child: createLabelPrice(context, fontSize, bidPrice, TextAlign.right, bidColor)),
            ],
          ),
        ),
        SizedBox(
          width: middle_gap,
        ),
        Container(
          //color: Colors.greenAccent,
          width: widthSection,
          child: Stack(
            children: [
              createLabelPrice(context, fontSize, '', TextAlign.left, offerColor),
              Positioned.fill(child: createLabelPrice(context, fontSize, offerPrice, TextAlign.left, offerColor)),
              Positioned.fill(child: createLabelLot(context, fontSize, offerLot)),
              Positioned.fill(child: createLabelQueue(context, fontSize, offerQueue, TextAlign.right)),
            ],
          ),
        ),
      ],
    );
  }

  Widget createHeaderLeft(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme
            .of(context)
            .small_w500,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget createHeaderRight(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme
            .of(context)
            .small_w500,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget createHeaderCenter(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme
            .of(context)
            .small_w500,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createLabelQueue(BuildContext context, double fontSize, String text, TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme
            .of(context)
            .small_w400
            .copyWith(color: InvestrendTheme
            .of(context)
            .greyLighterTextColor, fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }

  Widget createLabelLot(BuildContext context, double fontSize, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme
            .of(context)
            .small_w400
            .copyWith(color: InvestrendTheme
            .of(context)
            .greyDarkerTextColor, fontSize: fontSize),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createLabelPrice(BuildContext context, double fontSize, String text, TextAlign textAlign, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme
            .of(context)
            .small_w500
            .copyWith(color: color, fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }


/*
  Widget getTableDataOrderbook(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _orderbookNotifier,
      builder: (context, OrderBook value, child) {
        if (_orderbookNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        const padding = 10.0;
        List<TableRow> list = List.empty(growable: true);

        TableRow header = TableRow(children: [
          ComponentCreator.tableCellLeftHeader(context, '#'),
          ComponentCreator.tableCellLeftHeader(context, 'Lot'),
          ComponentCreator.tableCellRightHeader(context, 'Bids', padding: padding),
          ComponentCreator.tableCellLeftHeader(context, 'Offers', padding: padding),
          ComponentCreator.tableCellRightHeader(context, 'Lot'),
          ComponentCreator.tableCellRightHeader(context, '#'),
        ]);
        list.add(header);

        StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
        int prev = _summaryNotifier != null && _summaryNotifier.value != null ? _summaryNotifier.value.prev : 0;

        //int maxShowLevel = 6;
        int totalVolumeShowedBid = 0;
        int totalVolumeShowedOffer = 0;
        for (int index = 0; index < maxShowLevel; index++) {
          totalVolumeShowedBid += value.bidVol(index);
          totalVolumeShowedOffer += value.offerVol(index);
        }
        for (int index = 0; index < maxShowLevel; index++) {
          double fractionBid = value.bidVol(index) / totalVolumeShowedBid;
          double fractionOffer = value.offerVol(index) / totalVolumeShowedOffer;

          bool showBid = value.bids.elementAt(index) > 0;
          bool showOffer = value.offers.elementAt(index) > 0;

          print('orderbook[$index] --> fractionBid : $fractionBid  fractionOffer --> $fractionOffer');
          print('orderbook[$index] --> totalBid : ' + value.totalBid.toString() + '  bidVol --> ' + value.bidVol(index).toString());
          print('orderbook[$index] --> totalOffer : ' + value.totalOffer.toString() + '  offerVol --> ' + value.offerVol(index).toString());
          TableRow row = TableRow(children: [
            cellBidQueue(context, value.bidsQueue.elementAt(index), () {
              InvestrendTheme.of(context).showSnackBar(context, 'Action show queue for : ' + value.bidsQueue.elementAt(index).toString());
            }),
            cellBidLot(context, value.bidLot(index), () {
              // show nothing
            }),
            cellBidPrice(context, value.bids.elementAt(index), prev, fractionBid, padding, () {
              InvestrendTheme.of(context).showSnackBar(context, 'Action show Bid for : ' + value.bids.elementAt(index).toString());
            }),
            cellOfferPrice(context, value.offers.elementAt(index), prev, fractionOffer, padding, () {
              InvestrendTheme.of(context).showSnackBar(context, 'Action show Offer for : ' + value.offers.elementAt(index).toString());
            }),
            cellOfferLot(context, value.offerLot(index), () {
              // show nothing
            }),
            cellOfferQueue(context, value.offersQueue.elementAt(index), () {
              InvestrendTheme.of(context).showSnackBar(context, 'Action show queue for : ' + value.offersQueue.elementAt(index).toString());
            }),
          ]);
          list.add(row);
        }

        TableRow total = TableRow(children: [
          SizedBox(width: 1),
          ComponentCreator.tableCellLeftHeader(context, InvestrendTheme.formatComma(totalVolumeShowedBid)),
          ComponentCreator.tableCellRightHeader(context, 'Total', padding: padding),
          ComponentCreator.tableCellLeftHeader(context, 'Total', padding: padding),
          ComponentCreator.tableCellRightHeader(context, InvestrendTheme.formatComma(totalVolumeShowedOffer)),
          SizedBox(width: 1),
        ]);
        list.add(total);

        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border: TableBorder.all(color: Colors.black),
          columnWidths: {
            0: FractionColumnWidth(.15),
            1: FractionColumnWidth(.16),
            2: FractionColumnWidth(.19),
            3: FractionColumnWidth(.19),
            4: FractionColumnWidth(.16),
            5: FractionColumnWidth(.15),
          },
          children: list,
        );
      },
    );
  }

  Widget cellOfferPrice(BuildContext context, int offerPrice, int prev, double fractionOffer, double padding, VoidCallback onTap) {
    Color textColor = InvestrendTheme.priceTextColor(offerPrice, prev: prev);
    Color backgroundColor = InvestrendTheme.priceBackgroundColor(offerPrice, prev: prev);
    if (offerPrice > 0) {
      return TableRowInkWell(
        onTap: onTap,
        child: ComponentCreator.tableCellLeftValue(
          context,
          InvestrendTheme.formatPrice(offerPrice),
          padding: padding,
          color: textColor,
          height: 2.0,
        ),
      );

      return TableRowInkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: padding,
                    top: 8.0,
                  ),
                  width: constraints.maxWidth * fractionOffer,
                  height: 20,
                  color: backgroundColor,
                ),
                ComponentCreator.tableCellLeftValue(
                  context,
                  InvestrendTheme.formatPrice(offerPrice),
                  padding: padding,
                  color: textColor,
                  height: 2.0,
                ),
              ],
            );
          },
        ),
      );
    } else {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
  }

  Widget cellOfferLot(BuildContext context, int offerLot, VoidCallback onTap) {
    if (offerLot > 0) {
      return TableRowInkWell(
        onTap: () {},
        child: ComponentCreator.tableCellRightValue(
          context,
          InvestrendTheme.formatComma(offerLot),
          fontWeight: FontWeight.w300,
          height: 2.0,
        ),
      );
    } else {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
  }

  Widget cellOfferQueue(BuildContext context, int offerQueue, VoidCallback onTap) {
    if (offerQueue > 0) {
      return TableRowInkWell(
        onTap: onTap,
        child: ComponentCreator.tableCellRightValue(
          context,
          InvestrendTheme.formatComma(offerQueue),
          fontWeight: FontWeight.w300,
          height: 2.0,
        ),
      );
    } else {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
  }

  Widget cellBidPrice(BuildContext context, int bidPrice, int prev, double fractionBid, double padding, VoidCallback onTap) {
    Color textColor = InvestrendTheme.priceTextColor(bidPrice, prev: prev);
    Color backgroundColor = InvestrendTheme.priceBackgroundColor(bidPrice, prev: prev);

    if (bidPrice > 0) {
      return TableRowInkWell(
        onTap: onTap,
        child: ComponentCreator.tableCellRightValue(
          context,
          InvestrendTheme.formatPrice(bidPrice),
          padding: padding,
          color: textColor,
          height: 2.0,
        ),
      );

      return TableRowInkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    right: padding,
                    top: 8.0,
                  ),
                  width: constraints.maxWidth * fractionBid,
                  height: 20,
                  color: backgroundColor,
                ),
                ComponentCreator.tableCellRightValue(
                  context,
                  InvestrendTheme.formatPrice(bidPrice),
                  padding: padding,
                  color: textColor,
                  height: 2.0,
                ),
              ],
            );
          },
        ),
      );
    } else {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
  }

  Widget cellBidLot(BuildContext context, int bidLot, VoidCallback onTap) {
    if (bidLot > 0) {
      return TableRowInkWell(
        onTap: onTap,
        child: ComponentCreator.tableCellLeftValue(
          context,
          InvestrendTheme.formatComma(bidLot),
          fontWeight: FontWeight.w300,
          height: 2.0,
        ),
      );
    } else {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
  }

  Widget cellBidQueue(BuildContext context, int bidQueue, VoidCallback onTap) {
    if (bidQueue > 0) {
      return TableRowInkWell(
        onTap: onTap,
        child: ComponentCreator.tableCellLeftValue(context, InvestrendTheme.formatComma(bidQueue), fontWeight: FontWeight.w300, height: 2.0),
      );
    } else {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
  }
  
   */
}
