// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_input_formatter.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

//import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetFastOrderBook extends StatefulWidget {
  //final OrderDataNotifier orderDataNotifier;
  final OrderType _orderType;
  final int maxShowLevel;
  final String owner;

  // final TradeCalculateNotifier calculateNotifier;

  const WidgetFastOrderBook(this._orderType, this.maxShowLevel,
      {Key? key,
      this.owner = '' /*, this.orderDataNotifier, this.calculateNotifier*/
      })
      : super(key: key);

  @override
  _WidgetFastOrderBookState createState() => _WidgetFastOrderBookState();

  static const double middle_gap = 20.0;
}

class _WidgetFastOrderBookState extends State<WidgetFastOrderBook> {
  List<TextEditingController> _controllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  List<FocusNode> _focusNodes = <FocusNode>[
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  //Map details = new Map();

  VoidCallback? listener;

  void _enableListener() {
    _controllers.forEach((controller) {
      controller.addListener(listener!);
    });
  }

  // ignore: unused_element
  void _disableListener() {
    _controllers.forEach((controller) {
      controller.removeListener(listener!);
    });
  }

  @override
  void initState() {
    super.initState();

    listener = () {
      calculateOrder();
    };
    _enableListener();
    // _controllers.forEach((controller) {
    //   controller.addListener(() {
    //     calculateOrder();
    //   });
    // });

    // if (widget.calculateNotifier != null) {
    //   widget.calculateNotifier.addListener(() {
    //     if (widget.calculateNotifier.canFastModeCalculate(widget._orderType)) {
    //       calculateOrder();
    //     }
    //   });
    // }
  }

  void calculateOrder() {
    OrderBook? ob = context.read(orderBookChangeNotifier).orderbook;
    bool isBuy = widget._orderType == OrderType.Buy;
    BuySell data =
        context.read(buySellChangeNotifier).getData(widget._orderType);
    data.clearFastPriceLot();

    for (int i = 0; i < _controllers.length; i++) {
      int price;
      if (isBuy) {
        price = ob!.countBids() > i ? ob.bids?.elementAt(i) : 0;
      } else {
        price = ob!.countOffers() > i ? ob.offers?.elementAt(i) : 0;
      }
      TextEditingController controller = _controllers.elementAt(i);
      if (controller.text.isNotEmpty) {
        int lot = Utils.safeInt(controller.text.replaceAll(',', ''));
        if (price > 0 && lot > 0) {
          data.addFastPriceLot(price, lot);
        }
      }
    }
    context.read(buySellChangeNotifier).mustNotifyListener();
    /*
    int value = 0;
    for (int i = 0; i < _controllers.length; i++) {
      int price;
      if (isBuy) {
        price = ob.bids.elementAt(i);
      } else {
        price = ob.offers.elementAt(i);
      }
      TextEditingController controller = _controllers.elementAt(i);
      if (controller.text.isNotEmpty) {

        details[price.toString()] = controller.text;
        details['$i'] = price.toString();

        int lot = Utils.safeInt(controller.text.replaceAll(',', ''));
        context.read(orderDataChangeNotifier).addPriceLot(price, lot);
        value += price * lot * 100;
      } else {
        details.remove(price.toString());
        details.remove('$i');
      }
    }
    context.read(orderDataChangeNotifier).update(value: value, orderType: widget._orderType, stock_code: ob.code);
    // }

    print(details);
     */
  }

  @override
  void dispose() {
    for (int i = 0; i < _controllers.length; i++) {
      TextEditingController controller = _controllers.elementAt(i);
      controller.dispose();
      FocusNode focusNode = _focusNodes.elementAt(i);
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        print('WidgetFastOrderBook [' +
            widget._orderType.routeName +
            '] constrains ' +
            constraints.maxWidth.toString());
        return buildOrderbook(
            context, constraints.maxWidth, constraints.maxHeight);
      },
    );
  }

  Size _textSize(String text, TextStyle? style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  List<Key> keysOffer = [
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
  ];
  List<Key> keysBid = [
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
  ];

  Widget buildOrderbook(
      BuildContext context, double widthWidget, double heightWidget) {
    double widthHalf = widthWidget / 2;
    double widthSection = (widthWidget - WidgetFastOrderBook.middle_gap) / 2;

    return Consumer(builder: (context, watch, child) {
      final notifier = watch(orderBookChangeNotifier);
      if (notifier.invalid()) {
        //details.clear();
        return Center(child: CircularProgressIndicator());
      }

      List<Widget> list = List.empty(growable: true);

      Widget headers = widget._orderType == OrderType.Buy
          ? createHeaderBuy(context, widthSection)
          : createHeaderSell(context, widthSection);
      list.add(headers);

      StockSummary? stockSummary =
          context.read(stockSummaryChangeNotifier).summary;
      int? prev = stockSummary != null &&
              stockSummary.prev != null &&
              StringUtils.equalsIgnoreCase(
                  stockSummary.code!, notifier.orderbook?.code)
          ? stockSummary.prev
          : 0;

      // if (!StringUtils.equalsIgnoreCase(details['code'], notifier.orderbook.code) ||
      //     !StringUtils.equalsIgnoreCase(details['board'], notifier.orderbook.board)) {
      //   details.clear();
      // }

      // details['code'] = notifier.orderbook.code;
      // details['board'] = notifier.orderbook.board;

      notifier.orderbook?.generateDataForUI(widget.maxShowLevel);

      int? totalVolumeShowedBid = notifier.orderbook?.totalVolumeShowedBid;
      int? totalVolumeShowedOffer = notifier.orderbook?.totalVolumeShowedOffer;

      double? fontSize = InvestrendTheme.of(context).small_w400?.fontSize!;
      fontSize =
          useFontSize(context, fontSize, widthSection, notifier.orderbook);
      print('WidgetFastOrderBook [' +
          widget._orderType.routeName +
          '] buildOrderbook  code : ' +
          notifier.orderbook!.code! +
          '  prev : $prev');

      bool isBuy = widget._orderType == OrderType.Buy;
      int count = min(widget.maxShowLevel, notifier.orderbook!.countBids());

      for (int index = 0; index < count; index++) {
        // double fractionBid = value.bidVol(index) / totalVolumeShowedBid;
        // double fractionOffer = value.offerVol(index) / totalVolumeShowedOffer;

        bool showBid = notifier.orderbook?.bids?.elementAt(index) > 0;
        bool showOffer = notifier.orderbook?.offers?.elementAt(index) > 0;

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

        int bid = notifier.orderbook?.bids?.elementAt(index);
        int offer = notifier.orderbook?.offers?.elementAt(index);
        //Key key = isBuy ? keysBid.elementAt(index) : keysOffer.elementAt(index);

        String bidQueue = notifier.orderbook?.bidsQueueText?.elementAt(index);
        String bidLot = notifier.orderbook?.bidsLotText?.elementAt(index);
        String bidPrice = notifier.orderbook?.bidsText?.elementAt(index);
        //Color bidColor = prev == 0 ? InvestrendTheme.of(context).blackAndWhiteText : InvestrendTheme.priceTextColor(bid, prev: prev, caller: widget._orderType.routeName+'[Bid]');
        Color? bidColor = prev == 0
            ? InvestrendTheme.of(context).blackAndWhiteText
            : InvestrendTheme.priceTextColor(bid, prev: prev!);
        String offerQueue =
            notifier.orderbook?.offersQueueText?.elementAt(index);
        String offerLot = notifier.orderbook?.offersLotText?.elementAt(index);
        String offerPrice = notifier.orderbook?.offersText?.elementAt(index);
        //Color offerColor = prev == 0 ? InvestrendTheme.of(context).blackAndWhiteText : InvestrendTheme.priceTextColor(offer, prev: prev, caller: widget._orderType.routeName+'[Offer]');
        Color? offerColor = prev == 0
            ? InvestrendTheme.of(context).blackAndWhiteText
            : InvestrendTheme.priceTextColor(offer, prev: prev!);

        // String bidQueue = '100,000';
        // String bidLot = '1,000,000';
        // String bidPrice = '200,000';
        // Color bidColor = InvestrendTheme.priceTextColor(value.bids.elementAt(index), prev: prev);
        // String offerQueue = InvestrendTheme.formatComma(value.offersQueue.elementAt(index));
        // String offerLot = InvestrendTheme.formatComma(value.offerLot(index));
        // String offerPrice = '1,780';
        // Color offerColor = InvestrendTheme.priceTextColor(value.offers.elementAt(index), prev: prev);

        FocusNode focusNode = _focusNodes.elementAt(index);
        int nextIndex = (index + 1);
        FocusNode? nextFocusNode =
            (nextIndex < count) ? _focusNodes.elementAt(nextIndex) : null;

        TextEditingController controller = _controllers.elementAt(index);
        if (widget._orderType == OrderType.Buy) {
          OpenOrder? openOrder = context.read(openOrderChangeNotifier).get(bid);
          list.add(createRowBuy(
              context,
              bidQueue,
              bidLot,
              bidPrice,
              bidColor!,
              offerQueue,
              offerLot,
              offerPrice,
              offerColor!,
              widthSection,
              fontSize,
              _controllers.elementAt(index),
              showBid,
              keysBid.elementAt(index),
              openOrder!,
              focusNode: focusNode,
              nextFocusNode: nextFocusNode));
        } else {
          OpenOrder? openOrder =
              context.read(openOrderChangeNotifier).get(offer);
          list.add(createRowSell(
              context,
              bidQueue,
              bidLot,
              bidPrice,
              bidColor!,
              offerQueue,
              offerLot,
              offerPrice,
              offerColor!,
              widthSection,
              fontSize,
              _controllers.elementAt(index),
              showOffer,
              keysOffer.elementAt(index),
              openOrder!,
              focusNode: focusNode,
              nextFocusNode: nextFocusNode));
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        reconcileOrderbook();
      });
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: list,
      );
    });
  }

  void reconcileOrderbook() {
    print(widget._orderType.routeName + '.reconcileOrderbook');
    OrderBook? ob = context.read(orderBookChangeNotifier).orderbook;
    bool isBuy = widget._orderType == OrderType.Buy;
    BuySell data =
        context.read(buySellChangeNotifier).getData(widget._orderType);
    List<int> listValid = List.empty(growable: true);
    int count = min(widget.maxShowLevel, ob!.countBids());
    for (int i = 0; i < count; i++) {
      int price = isBuy ? ob.bids?.elementAt(i) : ob.offers?.elementAt(i);
      TextEditingController controller = _controllers.elementAt(i);
      bool show = price > 0;
      if (show) {
        PriceLot? savedPriceLot = data.getFastPriceLot(price);
        controller.removeListener(listener!);
        if (savedPriceLot != null) {
          controller.text = savedPriceLot.lot.toString();
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length));

          listValid.add(price);
        } else {
          //controller.removeListener(listener);
          controller.text = '';
          //controller.addListener(listener);
        }
        controller.addListener(listener!);
      }
    }
    List<int> listInvalid = List.empty(growable: true);
    data.listFastPriceLot?.forEach((priceLot) {
      bool valid = listValid.contains(priceLot.price);
      if (!valid) {
        listInvalid.add(priceLot.price);
      }
    });
    listInvalid.forEach((invalidPrice) {
      data.removeFastPriceLot(invalidPrice);
    });
    listInvalid.clear();
    listValid.clear();
    context.read(buySellChangeNotifier).mustNotifyListener();

    /*
    OrderBook orderbook = context.read(orderBookChangeNotifier).orderbook;
    for (int index = 0; index < widget.maxShowLevel; index++) {
      bool showBid = orderbook.bids.elementAt(index) > 0;
      bool showOffer = orderbook.offers.elementAt(index) > 0;

      int bid = orderbook.bids.elementAt(index);
      int offer = orderbook.offers.elementAt(index);

      TextEditingController controller = _controllers.elementAt(index);
      if (widget._orderType == OrderType.Buy) {
        if (showBid) {
          String price = bid.toString();
          String lot = details[price];
          String priceIndex = details['$index'];
          if (StringUtils.equalsIgnoreCase(priceIndex, price)) {
            controller.text = lot;
            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          } else {
            controller.text = '';
          }
        } else {
          controller.text = '';
        }
      } else {
        if (showOffer) {
          String price = offer.toString();
          String lot = details[price];
          String priceIndex = details['$index'];
          if (StringUtils.equalsIgnoreCase(priceIndex, price)) {
            controller.text = lot;
            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          } else {
            controller.text = '';
          }
        } else {
          controller.text = '';
        }
      }

      // list.add(
      //     createRow(context, bidQueue, bidLot, bidPrice, bidColor, offerQueue, offerLot, offerPrice, offerColor, widthSection, fontSize));
    }
     */
  }

  double? useFontSize(BuildContext context, double? fontSize,
      double widthSection, OrderBook? value,
      {int offset = 0}) {
    print('WidgetFastOrderBook[' +
        widget.owner +
        '].useFontSize Try fontSize  : $fontSize  offset : $offset');
    TextStyle? smallW400 =
        InvestrendTheme.of(context).small_w400?.copyWith(fontSize: fontSize);
    TextStyle? smallW500 =
        InvestrendTheme.of(context).small_w500?.copyWith(fontSize: fontSize);
    const double font_step = 1.0;
    double widthCell = widthSection / 3;
    int count = min(widget.maxShowLevel, value!.countBids());
    for (int index = offset; index < count; index++) {
      // String bidQueue = '100,000';
      // String bidLot = '1,000,000';
      // String bidPrice = '200,000';
      //
      // String offerQueue = InvestrendTheme.formatComma(value.offersQueue.elementAt(index));
      // String offerLot = InvestrendTheme.formatComma(value.offerLot(index));
      // String offerPrice = '1,780';

      String bidQueue = value.bidsQueueText?.elementAt(index);
      String bidLot = value.bidsLotText?.elementAt(index);
      String bidPrice = value.bidsText?.elementAt(index);

      String offerQueue = value.offersQueueText?.elementAt(index);
      String offerLot = value.offersLotText?.elementAt(index);
      String offerPrice = value.offersText?.elementAt(index);

      if (widget._orderType == OrderType.Buy) {
        String leftText = bidQueue + bidLot + bidPrice;
        double widthSectionTextLeft = _textSize(leftText, smallW400).width;

        // double widthSectionTextLeft =
        //     _textSize(bidQueue, small_w400).width + _textSize(bidLot, small_w400).width + _textSize(bidPrice, small_w500).width;
        double widthOffer = _textSize(offerPrice, smallW500).width;

        //bool reduceFontSize = widthSectionTextLeft > widthSection || widthOffer > (widthSection / 3);
        bool reduceFontSize =
            widthSectionTextLeft > widthSection || widthOffer > widthCell;
        // print(
        //     ' useFontSize widthSection  : $widthSection   widthSectionTextLeft : $widthSectionTextLeft   widthOffer : $widthOffer  reduceFontSize : $reduceFontSize');
        if (reduceFontSize) {
          fontSize = useFontSize(
              context, fontSize! - font_step, widthSection, value,
              offset: index);
          //break;
          return fontSize;
        }
      } else {
        String rightText = offerPrice + offerLot + offerQueue;
        double widthSectionTextRight = _textSize(rightText, smallW500).width;

        // double widthSectionTextRight =
        //     _textSize(offerPrice, small_w500).width + _textSize(offerLot, small_w400).width + _textSize(offerQueue, small_w400).width;

        double widthBid = _textSize(bidPrice, smallW500).width;

        //bool reduceFontSize = widthSectionTextRight > widthSection || widthBid > (widthSection / 3);
        bool reduceFontSize =
            widthSectionTextRight > widthSection || widthBid > widthCell;
        // print(
        //     ' useFontSize widthSection  : $widthSection   widthSectionTextRight : $widthSectionTextRight   widthBid : $widthBid  reduceFontSize : $reduceFontSize');
        if (reduceFontSize) {
          fontSize = useFontSize(
              context, fontSize! - font_step, widthSection, value,
              offset: index);
          //break;
          return fontSize;
        }
      }
    }
    print('WidgetFastOrderBook[' +
        widget.owner +
        '].useFontSize Final fontSize  : $fontSize  offset : $offset');
    return fontSize;
  }

  Widget createHeaderSell(BuildContext context, double widthSection) {
    return Row(
      children: [
        SizedBox(
            width: widthSection / 3, child: createHeaderRight(context, 'Bid')),
        SizedBox(
          width: WidgetFastOrderBook.middle_gap,
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
        SizedBox(
            width: widthSection / 3, child: createHeaderRight(context, 'Open')),
        SizedBox(
            width: widthSection / 3, child: createHeaderRight(context, 'Lot')),
      ],
    );
  }

  Widget createHeaderBuy(BuildContext context, double widthSection) {
    return Row(
      children: [
        SizedBox(
            width: widthSection / 3, child: createHeaderLeft(context, 'Lot')),
        SizedBox(
            width: widthSection / 3, child: createHeaderLeft(context, 'Open')),
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
          width: WidgetFastOrderBook.middle_gap,
        ),
        SizedBox(
            width: widthSection / 3, child: createHeaderLeft(context, 'Ask')),
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
      double fontSize) {
    return Row(
      children: [
        Container(
          width: widthSection,
          //color: Colors.yellow,
          child: Stack(
            children: [
              createHeaderLeft(context, ''),
              Positioned.fill(
                  child: createLabelQueue(
                      context, fontSize, bidQueue, TextAlign.left)),
              Positioned.fill(child: createLabelLot(context, fontSize, bidLot)),
              Positioned.fill(
                  child: createLabelPrice(
                      context, fontSize, bidPrice, TextAlign.right, bidColor)),
            ],
          ),
        ),
        SizedBox(
          width: WidgetFastOrderBook.middle_gap,
        ),
        Container(
          //color: Colors.greenAccent,
          width: widthSection,
          child: Stack(
            children: [
              createHeaderLeft(context, ''),
              Positioned.fill(
                  child: createLabelPrice(
                      context, fontSize, offerPrice, TextAlign.left, bidColor)),
              Positioned.fill(
                  child: createLabelLot(context, fontSize, offerLot)),
              Positioned.fill(
                  child: createLabelQueue(
                      context, fontSize, offerQueue, TextAlign.right)),
            ],
          ),
        ),
      ],
    );
  }

  Widget createRowSell(
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
      double? fontSize,
      TextEditingController controller,
      bool showOffer,
      Key key,
      OpenOrder? openOrder,
      {FocusNode? focusNode,
      FocusNode? nextFocusNode}) {
    int open = (openOrder != null ? openOrder.lot : 0);
    //String openString = InvestrendTheme.formatComma(open);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widthSection / 3,
          child: createLabelPrice(
              context, fontSize, bidPrice, TextAlign.right, bidColor),
        ),
        SizedBox(
          width: (WidgetFastOrderBook.middle_gap / 2) - 0.5,
        ),
        Container(
          width: 1.0,
          //height: 25.0,
          color: Theme.of(context).dividerColor,
          child: createLabelPrice(
              context, fontSize, '', TextAlign.right, offerColor),
        ),
        SizedBox(
          width: (WidgetFastOrderBook.middle_gap / 2) - 0.5,
        ),
        Container(
          width: widthSection,
          //color: Colors.yellow,
          child: Stack(
            children: [
              createLabelPrice(
                  context, fontSize, '', TextAlign.right, bidColor),
              Positioned.fill(
                  child: createLabelPrice(
                      context, fontSize, offerPrice, TextAlign.left, offerColor,
                      key: key)),
              Positioned.fill(
                  child: createLabelLot(context, fontSize, offerLot)),
              Positioned.fill(
                  child: createLabelQueue(
                      context, fontSize, offerQueue, TextAlign.right)),
            ],
          ),
        ),
        SizedBox(
          width: widthSection / 3,
          child: createLabelOpen(
              context, fontSize, open, TextAlign.right, showOffer),
        ),
        SizedBox(
          width: widthSection / 3,
          child: Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding),
            child: showOffer
                ? AutoSizeTextField(
                    controller: controller,
                    //onSubmitted: (_) => context.nextEditableTextFocus(),
                    onSubmitted: (_) {
                      if (nextFocusNode != null) {
                        nextFocusNode.requestFocus();
                      } else {
                        context.nextEditableTextFocus();
                      }
                    },
                    inputFormatters: [
                      PriceFormatter(),
                    ],
                    maxLines: 1,
                    style: InvestrendTheme.of(context).small_w400?.copyWith(
                        color: InvestrendTheme.of(context).greyDarkerTextColor,
                        fontSize: fontSize),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0)),
                      focusColor: Theme.of(context).colorScheme.secondary,
                      prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                      hintStyle: InvestrendTheme.of(context).inputHintStyle,
                      helperStyle: InvestrendTheme.of(context).inputHelperStyle,
                      errorStyle: InvestrendTheme.of(context).inputErrorStyle,
                      fillColor: Colors.grey,
                      contentPadding: EdgeInsets.all(0.0),
                    ),
                    textAlign: TextAlign.right,
                  )
                : SizedBox(
                    height: 1,
                  ),
          ),
        ),
      ],
    );
  }

  Widget createRowBuy(
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
      double? fontSize,
      TextEditingController controller,
      bool showBid,
      Key key,
      OpenOrder? openOrder,
      {FocusNode? focusNode,
      FocusNode? nextFocusNode}) {
    int open = (openOrder != null ? openOrder.lot : 0);
    //String openString = InvestrendTheme.formatComma(open);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widthSection / 3,
          child: Padding(
            padding: const EdgeInsets.only(right: InvestrendTheme.cardPadding),
            child: showBid
                ? AutoSizeTextField(
                    controller: controller,
                    // focusNode: focusNode,
                    onSubmitted: (_) => context.nextEditableTextFocus(),
                    // onSubmitted: (_) {
                    //   if (nextFocusNode != null) {
                    //     nextFocusNode.requestFocus();
                    //   } else {
                    //     context.nextEditableTextFocus();
                    //   }
                    // },
                    inputFormatters: [
                      PriceFormatter(),
                    ],
                    maxLines: 1,
                    style: InvestrendTheme.of(context).small_w400?.copyWith(
                        color: InvestrendTheme.of(context).greyDarkerTextColor,
                        fontSize: fontSize),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 1.0)),
                      focusColor: Theme.of(context).colorScheme.secondary,
                      prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                      hintStyle: InvestrendTheme.of(context).inputHintStyle,
                      helperStyle: InvestrendTheme.of(context).inputHelperStyle,
                      errorStyle: InvestrendTheme.of(context).inputErrorStyle,
                      fillColor: Colors.grey,
                      contentPadding: EdgeInsets.all(0.0),
                    ),
                    textAlign: TextAlign.left,
                  )
                : SizedBox(
                    height: 1,
                  ),
          ),
        ),
        SizedBox(
          width: widthSection / 3,
          child:
              createLabelOpen(context, fontSize, open, TextAlign.left, showBid),
        ),
        Container(
          width: widthSection,
          //color: Colors.yellow,
          child: Stack(
            children: [
              createLabelPrice(
                  context, fontSize, '', TextAlign.right, bidColor),
              Positioned.fill(
                  child: createLabelQueue(
                      context, fontSize, bidQueue, TextAlign.left)),
              Positioned.fill(child: createLabelLot(context, fontSize, bidLot)),
              Positioned.fill(
                  child: createLabelPrice(
                      context, fontSize, bidPrice, TextAlign.right, bidColor,
                      key: key)),
            ],
          ),
        ),
        SizedBox(
          width: (WidgetFastOrderBook.middle_gap / 2) - 0.5,
        ),
        Container(
          width: 1.0,
          //height: 25.0,
          color: Theme.of(context).dividerColor,
          child: createLabelPrice(
              context, fontSize, '', TextAlign.right, bidColor),
        ),
        SizedBox(
          width: (WidgetFastOrderBook.middle_gap / 2) - 0.5,
        ),
        SizedBox(
          width: widthSection / 3,
          child: createLabelPrice(
              context, fontSize, offerPrice, TextAlign.left, offerColor),
        ),
      ],
    );
  }

  Widget createHeaderLeft(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w500,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget createHeaderRight(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w500,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget createHeaderCenter(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w500,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createLabelQueue(BuildContext context, double? fontSize, String text,
      TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400?.copyWith(
            color: InvestrendTheme.of(context).greyLighterTextColor,
            fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }

  Widget createLabelLot(BuildContext context, double? fontSize, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400?.copyWith(
            color: InvestrendTheme.of(context).greyDarkerTextColor,
            fontSize: fontSize),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createLabelOpen(BuildContext context, double? fontSize, int lot,
      TextAlign textAlign, bool show) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: show
          ? RichText(
              textAlign: textAlign,
              text: TextSpan(
                text: InvestrendTheme.formatComma(lot),
                style: InvestrendTheme.of(context).small_w400?.copyWith(
                    color: InvestrendTheme.of(context).greyDarkerTextColor,
                    fontSize: fontSize),
                children: <TextSpan>[
                  TextSpan(
                    text: lot > 0 ? '*' : '',
                    style: InvestrendTheme.of(context)
                        .small_w400
                        ?.copyWith(color: Colors.red, fontSize: fontSize),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: 1,
            ),
    );
  }

  Widget createLabelPrice(BuildContext context, double? fontSize, String text,
      TextAlign textAlign, Color color,
      {Key? key}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        key: key,
        style: InvestrendTheme.of(context)
            .small_w500
            ?.copyWith(color: color, fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }
}
