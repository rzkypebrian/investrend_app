import 'dart:math';

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

enum TypeOrderbook { Bid, Offer }
enum TypeField { Price, Lot, Queue }

extension TypeOrderbookExtension on TypeOrderbook {
  String get text {
    switch (this) {
      case TypeOrderbook.Bid:
        return 'Bid';
      case TypeOrderbook.Offer:
        return 'Offer';
      default:
        return '#unknown_type_orderbook';
    }
  }
}

extension TypeFieldExtension on TypeField {
  String get text {
    switch (this) {
      case TypeField.Price:
        return 'Price';
      case TypeField.Lot:
        return 'Lot';
      case TypeField.Queue:
        return 'Queue';
      default:
        return '#unknown_type_field';
    }
  }
}

typedef OrderbookCallback = Function(TypeOrderbook type, TypeField field, PriceLotQueue data);

class CardOrderbook extends StatelessWidget {
  final int maxShowLevel;
  final String owner;

  //final String title;
  final OrderbookNotifier notifier;
  final OrderbookCallback onTap;
  final VoidCallback onRetry;

  const CardOrderbook(/*this.title, */ this.notifier, this.maxShowLevel, {this.onRetry, Key key, this.owner = '', this.onTap}) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      // color: Colors.lightBlueAccent,
      margin: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical,
          top: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   height: InvestrendTheme.cardPaddingGeneral,
          // ),
          ComponentCreator.subtitle(context, 'card_order_book_title'.tr()),
          SizedBox(
            height: InvestrendTheme.cardPaddingVertical,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              print('CardOrderbook constrains ' + constraints.maxWidth.toString());
              return buildOrderbook(context, constraints.maxWidth, constraints.maxHeight);
            },
          )
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       print('CardOrderbook constrains ' + constraints.maxWidth.toString());
  //       return buildOrderbook(context, constraints.maxWidth, constraints.maxHeight);
  //     },
  //   );
  // }
  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static const double middle_gap = 20.0;

  Widget buildOrderbook(BuildContext context, double widthWidget, double heightWidget) {
    double widthHalf = widthWidget / 2;
    double widthSection = (widthWidget - middle_gap) / 2;

    return ValueListenableBuilder(
      valueListenable: this.notifier,
      builder: (context, OrderbookData data, child) {
        // if (notifier.invalid()) {
        //   return Center(child: CircularProgressIndicator());
        // }

        List<Widget> list = List.empty(growable: true);

        Widget headers = createHeader(context, widthSection);
        list.add(headers);

        print('stateText orderbook -->'+notifier.currentState.stateText);
        Widget noWidget = notifier.currentState.getNoWidget(onRetry: onRetry);
        if (noWidget != null) {

          double height = UIHelper.textSize('Pj', InvestrendTheme.of(context).small_w400).height + 10;
          height = height * 10;
          list.add(Container(width: double.maxFinite, height: height, child: Center(child: noWidget)));
          return Column(
            children: list,
          );
        }

        // StockSummary stockSummary = context.read(stockSummaryChangeNotifier).summary;
        //
        // int prev = stockSummary != null
        //     && stockSummary.prev != null
        //     && StringUtils.equalsIgnoreCase(stockSummary.code, data.orderbook.code)
        //     ? stockSummary.prev
        //     : 0;
        print('data.orderbook -->'+data.orderbook.toString());

        data.orderbook.generateDataForUI(maxShowLevel);

        int totalVolumeShowedBid = data.orderbook.totalVolumeShowedBid;
        int totalVolumeShowedOffer = data.orderbook.totalVolumeShowedOffer;

        double fontSize = InvestrendTheme.of(context).small_w400.fontSize;
        fontSize = useFontSize(context, fontSize, widthSection, data.orderbook);
        int count = min(maxShowLevel, data.orderbook.countBids());
        for (int index = 0; index < count; index++) {
          // double fractionBid = value.bidVol(index) / totalVolumeShowedBid;
          // double fractionOffer = value.offerVol(index) / totalVolumeShowedOffer;

          bool showBid = data.orderbook.bids.elementAt(index) > 0;
          bool showOffer = data.orderbook.offers.elementAt(index) > 0;

          bool bidIsClosePrice = false;
          bool offerIsClosePrice = false;

          String bidQueue = data.orderbook.bidsQueueText.elementAt(index);
          String bidLot = data.orderbook.bidsLotText.elementAt(index);
          String bidPrice = data.orderbook.bidsText.elementAt(index);
          Color bidColor = data.prev == 0
              ? InvestrendTheme.of(context).blackAndWhiteText
              : InvestrendTheme.priceTextColor(data.orderbook.bids.elementAt(index), prev: data.prev);
          String offerQueue = data.orderbook.offersQueueText.elementAt(index);
          String offerLot = data.orderbook.offersLotText.elementAt(index);
          String offerPrice = data.orderbook.offersText.elementAt(index);
          Color offerColor = data.prev == 0
              ? InvestrendTheme.of(context).blackAndWhiteText
              : InvestrendTheme.priceTextColor(data.orderbook.offers.elementAt(index), prev: data.prev);
          bool canTap = showBid || showOffer;
          if (canTap) {
            List<int> bidsInfo;
            if (showBid) {
              bidIsClosePrice = data.orderbook.bids.elementAt(index) == data.close;
              bidsInfo = [
                data.orderbook.bids.elementAt(index),
                data.orderbook.bidsLot.elementAt(index),
                data.orderbook.bidsQueue.elementAt(index)
              ];
            }

            List<int> offersInfo;
            if (showOffer) {
              offerIsClosePrice = data.orderbook.offers.elementAt(index) == data.close;
              offersInfo = [
                data.orderbook.offers.elementAt(index),
                data.orderbook.offersLot.elementAt(index),
                data.orderbook.offersQueue.elementAt(index)
              ];
            }
            list.add(createRow(
                context, bidQueue, bidLot, bidPrice, bidColor, offerQueue, offerLot, offerPrice, offerColor, widthSection, fontSize,
                onTap: onTap, bidsInfo: bidsInfo, offersInfo: offersInfo, highlightBid: bidIsClosePrice, highlightOffer: offerIsClosePrice));
          } else {
            list.add(
                createRow(context, bidQueue, bidLot, bidPrice, bidColor, offerQueue, offerLot, offerPrice, offerColor, widthSection, fontSize));
          }
        }
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: list,
        );
      },
    );

    /*
    return Consumer(builder: (context, watch,child){
      final notifier = watch(orderBookChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }



    });
    */
  }

  double useFontSize(BuildContext context, double fontSize, double widthSection, OrderBook value, {int offset = 0}) {
    print('WidgetOrderbook[$owner].useFontSize try fontSize  : $fontSize  offset : $offset');
    TextStyle small_w400 = InvestrendTheme.of(context).small_w400.copyWith(fontSize: fontSize);
    TextStyle small_w500 = InvestrendTheme.of(context).small_w500.copyWith(fontSize: fontSize);
    const double font_step = 1.0;
    int count = min(maxShowLevel, value.countBids());
    print('WidgetOrderbook[$owner].useFontSize count  : $count');
    for (int index = offset; index < count; index++) {
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
      if (reduceFontSize) {
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

  Widget createRow(
    BuildContext context,
    String bidQueue,
    String bidLot,
    String bidPrice,
    Color bidColor,
    String offerQueue,
    String offerLot,
    String offerPrice,
    Color offerColor,
    double widthSection,
    double fontSize, {
    OrderbookCallback onTap,
    List<int> bidsInfo,
    List<int> offersInfo,
    bool highlightBid = false,
    bool highlightOffer = false,
  }) {
    print('orderbook createRow  bidPrice : $bidPrice  offerPrice : $offerPrice');
    return Row(
      children: [
        Container(
          width: widthSection,
          //color: Colors.yellow,
          child: Stack(
            //fit: StackFit.expand,
            children: [
              createLabelPrice(context, fontSize, '', TextAlign.right, bidColor),
              Positioned.fill(child: createLabelQueue(context, fontSize, bidQueue, TextAlign.left)),
              Positioned.fill(child: createLabelLot(context, fontSize, bidLot)),
              Positioned.fill(child: createLabelPrice(context, fontSize, bidPrice, TextAlign.right, bidColor, highlight: highlightBid)),
              Positioned.fill(
                child: Row(
                  children: [
                    tapableEpandedArea(context, () {
                      if (bidsInfo != null && onTap != null) {

                        PriceLotQueue data = PriceLotQueue(bidsInfo.elementAt(TypeField.Price.index), bidsInfo.elementAt(TypeField.Lot.index), bidsInfo.elementAt(TypeField.Queue.index));
                        //onTap(TypeOrderbook.Bid, TypeField.Queue, bidsInfo.elementAt(TypeField.Queue.index));
                        onTap(TypeOrderbook.Bid, TypeField.Queue, data);
                      }
                    }, color: null),
                    tapableEpandedArea(context, () {
                      if (bidsInfo != null && onTap != null) {
                        //onTap(TypeOrderbook.Bid, TypeField.Lot, bidsInfo.elementAt(TypeField.Lot.index));
                        PriceLotQueue data = PriceLotQueue(bidsInfo.elementAt(TypeField.Price.index), bidsInfo.elementAt(TypeField.Lot.index), bidsInfo.elementAt(TypeField.Queue.index));
                        onTap(TypeOrderbook.Bid, TypeField.Lot, data);
                      }
                    }, color: null),
                    tapableEpandedArea(context, () {
                      if (bidsInfo != null && onTap != null) {
                        //onTap(TypeOrderbook.Bid, TypeField.Price, bidsInfo.elementAt(TypeField.Price.index));
                        PriceLotQueue data = PriceLotQueue(bidsInfo.elementAt(TypeField.Price.index), bidsInfo.elementAt(TypeField.Lot.index), bidsInfo.elementAt(TypeField.Queue.index));
                        onTap(TypeOrderbook.Bid, TypeField.Price, data);
                      }
                    }, color: null),
                  ],
                ),
              )
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
              Positioned.fill(child: createLabelPrice(context, fontSize, offerPrice, TextAlign.left, offerColor, highlight: highlightOffer)),
              Positioned.fill(child: createLabelLot(context, fontSize, offerLot)),
              Positioned.fill(child: createLabelQueue(context, fontSize, offerQueue, TextAlign.right)),
              Positioned.fill(
                child: Row(
                  children: [
                    tapableEpandedArea(context, () {
                      if (offersInfo != null && onTap != null) {
                        //onTap(TypeOrderbook.Offer, TypeField.Price, offersInfo.elementAt(TypeField.Price.index));
                        PriceLotQueue data = PriceLotQueue(offersInfo.elementAt(TypeField.Price.index), offersInfo.elementAt(TypeField.Lot.index), offersInfo.elementAt(TypeField.Queue.index));
                        onTap(TypeOrderbook.Offer, TypeField.Price, data);
                      }
                    }, color: null),
                    tapableEpandedArea(context, () {
                      if (offersInfo != null && onTap != null) {
                        //onTap(TypeOrderbook.Offer, TypeField.Lot, offersInfo.elementAt(TypeField.Lot.index));
                        PriceLotQueue data = PriceLotQueue(offersInfo.elementAt(TypeField.Price.index), offersInfo.elementAt(TypeField.Lot.index), offersInfo.elementAt(TypeField.Queue.index));
                        onTap(TypeOrderbook.Offer, TypeField.Lot, data);
                      }
                    }, color: null),
                    tapableEpandedArea(context, () {
                      if (offersInfo != null && onTap != null) {
                        //onTap(TypeOrderbook.Offer, TypeField.Queue, offersInfo.elementAt(TypeField.Queue.index));
                        PriceLotQueue data = PriceLotQueue(offersInfo.elementAt(TypeField.Price.index), offersInfo.elementAt(TypeField.Lot.index), offersInfo.elementAt(TypeField.Queue.index));
                        onTap(TypeOrderbook.Offer, TypeField.Queue, data);
                      }
                    }, color: null),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget tapableEpandedArea(BuildContext context, VoidCallback onTap, {Color color}) {
    return Expanded(
        flex: 1,
        child: TapableWidget(
          onTap: onTap,
          child: Container(
            color: color,
          ),
        ));
  }

  Widget createHeaderLeft(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(/*top: 5.0,*/ bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w500_compact,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget createHeaderRight(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(/*top: 5.0,*/ bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w500_compact,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget createHeaderCenter(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(/*top: 5.0,*/ bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w500_compact,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createLabelQueue(BuildContext context, double fontSize, String text, TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor, fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }

  Widget createLabelLot(BuildContext context, double fontSize, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor, fontSize: fontSize),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createLabelPrice(BuildContext context, double fontSize, String text, TextAlign textAlign, Color color, {bool highlight = false}) {

    // TextStyle style = InvestrendTheme.of(context).small_w500.copyWith(
    //       color: color,
    //       fontSize: fontSize,
    //       decoration: highlight ? TextDecoration.underline : null,
    //       decorationColor: highlight ? Theme.of(context).accentColor : null,
    //     );
    TextStyle style;
    if(highlight){
      text = ' $text ';
      style = InvestrendTheme
          .of(context)
          .small_w500
          .copyWith(color: Theme.of(context).primaryColor, fontSize: fontSize, backgroundColor: color,);
    }else{
      style = InvestrendTheme
          .of(context)
          .small_w500
          .copyWith(color: color, fontSize: fontSize);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
