import 'dart:math';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_input_formatter.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/error_codes.dart';
import 'dart:ui' as ui;

import 'package:reorderables/reorderables.dart';

class FastOrderbook extends StatefulWidget {
  final OrderbookNotifier notifier;
  final OrderType _orderType;
  final int maxShowLevel;
  final String owner;

  // final TradeCalculateNotifier calculateNotifier;

  const FastOrderbook(this.notifier, this._orderType, this.maxShowLevel,
      {Key key,
      this.owner = '' /*, this.orderDataNotifier, this.calculateNotifier*/
      })
      : super(key: key);

  @override
  _FastOrderbookState createState() => _FastOrderbookState();

  static const double middle_gap = 20.0;
}

class WrapperNotifierFast {
  int index;
  StringColorFontNotifier primaryOpenNotifier =
      StringColorFontNotifier(StringColorFont());
  StringColorFontNotifier primaryQueNotifier =
      StringColorFontNotifier(StringColorFont());
  StringColorFontNotifier primaryLotNotifier =
      StringColorFontNotifier(StringColorFont());
  StringColorFontNotifier primaryPriceNotifier =
      StringColorFontNotifier(StringColorFont());
  StringColorFontNotifier secondaryPriceNotifier =
      StringColorFontNotifier(StringColorFont());
  ValueNotifier<bool> show = ValueNotifier(false);
  ValueNotifier<Color> color = ValueNotifier(Colors.transparent);

  void dispose() {
    primaryOpenNotifier.dispose();
    primaryQueNotifier.dispose();
    primaryLotNotifier.dispose();
    primaryPriceNotifier.dispose();
    secondaryPriceNotifier.dispose();
    show.dispose();
  }
}

class _FastOrderbookState extends State<FastOrderbook> {
  double widthSection = 0.0;

  List<WrapperNotifierFast> _notifiers = <WrapperNotifierFast>[
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
    WrapperNotifierFast(),
  ];

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

  List<Key> keysRow = [
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

  VoidCallback listener;

  String lockedOpen = "";
  String lockedBid = "";

  void _enableListener() {
    _controllers.forEach((controller) {
      controller.addListener(listener);
    });
  }

  void _disableListener() {
    _controllers.forEach((controller) {
      controller.removeListener(listener);
    });
  }

  void onOrderbookReceive({String caller = 'event'}) {
    // orderbook event
    if (!mounted) {
      print(widget._orderType.routeName +
          ' Ignored Fast OrderBook  got event... mounted : $mounted  caller : $caller  ');
      return;
    }
    print(widget._orderType.routeName +
        ' Fast OrderBook  got event... caller : $caller');
    print('FastOrderbook [' +
        widget._orderType.routeName +
        '] widthSection : $widthSection  aaa');
    OrderbookData data = widget.notifier.value;

    StockSummary stockSummary =
        context.read(stockSummaryChangeNotifier).summary;
    int prev = stockSummary != null &&
            stockSummary.prev != null &&
            StringUtils.equalsIgnoreCase(stockSummary.code, data.orderbook.code)
        ? stockSummary.prev
        : 0;

    data.orderbook.generateDataForUI(widget.maxShowLevel);

    int totalVolumeShowedBid = data.orderbook.totalVolumeShowedBid;
    int totalVolumeShowedOffer = data.orderbook.totalVolumeShowedOffer;

    double fontSize = InvestrendTheme.of(context).small_w400.fontSize;
    fontSize = useFontSize(context, fontSize, widthSection, data.orderbook);
    print('FastOrderbook [' +
        widget._orderType.routeName +
        '] buildOrderbook  code : ' +
        data.orderbook.code +
        '  prev : $prev');

    bool isBuy = widget._orderType == OrderType.Buy;
    int count = min(widget.maxShowLevel, data.orderbook.countBids());

    for (int index = 0; index < count; index++) {
      int bid = data.orderbook.bids.elementAt(index);
      int offer = data.orderbook.offers.elementAt(index);

      bool showBid = bid > 0;
      bool showOffer = offer > 0;

      //DATA DARI LIST
      String bidQueue = data.orderbook.bidsQueueText.elementAt(index);
      String bidLot = data.orderbook.bidsLotText.elementAt(index);
      String bidPrice = data.orderbook.bidsText.elementAt(index);
      Color bidColor = prev == 0
          ? InvestrendTheme.of(context).blackAndWhiteText
          : InvestrendTheme.priceTextColor(bid, prev: prev);
      String offerQueue = data.orderbook.offersQueueText.elementAt(index);
      String offerLot = data.orderbook.offersLotText.elementAt(index);
      String offerPrice = data.orderbook.offersText.elementAt(index);
      Color offerColor = prev == 0
          ? InvestrendTheme.of(context).blackAndWhiteText
          : InvestrendTheme.priceTextColor(offer, prev: prev);

      WrapperNotifierFast notifier = _notifiers.elementAt(index);
      if (widget._orderType == OrderType.Buy) {
        OpenOrder openOrder = context.read(openOrderChangeNotifier).get(bid);
        String lotOpen = openOrder == null
            ? '20'
            : InvestrendTheme.formatValue(context, openOrder.lot);
        notifier.primaryPriceNotifier
            .setValue(bidPrice, fontSize: fontSize, newColor: bidColor);
        notifier.primaryLotNotifier.setValue(bidLot, fontSize: fontSize);
        notifier.primaryQueNotifier.setValue(bidQueue, fontSize: fontSize);
        notifier.primaryOpenNotifier.setValue(lotOpen, fontSize: fontSize);
        notifier.secondaryPriceNotifier
            .setValue(offerPrice, fontSize: fontSize, newColor: offerColor);
        notifier.show.value = showBid;
      } else {
        OpenOrder openOrder = context.read(openOrderChangeNotifier).get(offer);
        String lotOpen = openOrder == null
            ? '20'
            : InvestrendTheme.formatValue(context, openOrder.lot);
        notifier.primaryPriceNotifier
            .setValue(offerPrice, fontSize: fontSize, newColor: offerColor);
        notifier.primaryLotNotifier.setValue(offerLot, fontSize: fontSize);
        notifier.primaryQueNotifier.setValue(offerQueue, fontSize: fontSize);
        notifier.primaryOpenNotifier.setValue(lotOpen, fontSize: fontSize);
        notifier.secondaryPriceNotifier
            .setValue(bidPrice, fontSize: fontSize, newColor: bidColor);
        notifier.show.value = showOffer;
      }
    }

    //WidgetsBinding.instance.addPostFrameCallback((_) {
    reconcileOrderbook();
    //});
  }

  @override
  void initState() {
    super.initState();

    listener = () {
      calculateOrder();
    };
    _enableListener();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => onOrderbookReceive(caller: 'initState'),
    );
    widget.notifier.addListener(onOrderbookReceive);
  }

  void calculateOrder() {
    OrderBook ob = context.read(orderBookChangeNotifier).orderbook;
    bool isBuy = widget._orderType == OrderType.Buy;
    BuySell data =
        context.read(buySellChangeNotifier).getData(widget._orderType);
    data.clearFastPriceLot();
    int value = 0;
    for (int i = 0; i < _controllers.length; i++) {
      int price;
      if (isBuy) {
        price = ob.countBids() > i ? ob.bids.elementAt(i) : 0;
      } else {
        price = ob.countOffers() > i ? ob.offers.elementAt(i) : 0;
      }
      TextEditingController controller = _controllers.elementAt(i);
      if (controller.text.isNotEmpty) {
        int lot = Utils.safeInt(controller.text.replaceAll(',', ''));
        if (price > 0 && lot > 0) {
          bool added = data.addFastPriceLot(price, lot);
          if (added) {
            value += price * lot * 100;
          }
        }
      }
    }

    if (data.orderType.isBuyOrAmendBuy()) {
      double feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
      Account activeAccount = context
          .read(dataHolderChangeNotifier)
          .user
          .getAccount(context.read(accountChangeNotifier).index);
      if (activeAccount != null) {
        feeBuy = activeAccount.commission;
      }
      if (feeBuy > 0) {
        value = (value * (1.0 + (feeBuy / 100))).toInt();
      }
    }
    data.fastTotalValue = value;
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
    print(widget._orderType.routeName + ' FastOrder dispose');
    widget.notifier.removeListener(onOrderbookReceive);

    for (int i = 0; i < _controllers.length; i++) {
      TextEditingController controller = _controllers.elementAt(i);
      FocusNode focusNode = _focusNodes.elementAt(i);

      WrapperNotifierFast _wrapper = _notifiers.elementAt(i);
      // StringColorFontNotifier _priceListener = _priceListeners.elementAt(i);
      // StringColorFontNotifier _lotListener = _lotsListeners.elementAt(i);
      // StringColorFontNotifier _queueListener = _queueListeners.elementAt(i);
      // IntColorFontNotifier _openListener = _openListeners.elementAt(i);

      controller.dispose();
      focusNode.dispose();
      _wrapper.dispose();
      // _priceListener.dispose();
      // _lotListener.dispose();
      // _queueListener.dispose();
      // _openListener.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        print('FastOrderbook [' +
            widget._orderType.routeName +
            '] constrains ' +
            constraints.maxWidth.toString() +
            '  aaa');

        return buildOrderbookStatic(
            context, constraints.maxWidth, constraints.maxHeight);
      },
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  final int maxOrderBook = 10;

  Widget buildOrderbookNew(
      BuildContext context, double widthWidget, double heightWidget) {
    double widthHalf = widthWidget / 2;
    double widthSection = (widthWidget - FastOrderbook.middle_gap) / 2;

    List<Widget> list = List.empty(growable: true);
    for (int i = 0; i < maxOrderBook; i++) {}
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: list,
    );
  }

  Widget buildOrderbook(
      BuildContext context, double widthWidget, double heightWidget) {
    double widthHalf = widthWidget / 2;
    double widthSection = (widthWidget - FastOrderbook.middle_gap) / 2;

    return ValueListenableBuilder(
        valueListenable: widget.notifier,
        builder: (context, OrderbookData data, child) {
          if (widget.notifier.invalid()) {
            return Center(child: CircularProgressIndicator());
          }

          List<Widget> list = List.empty(growable: true);

          Widget headers = widget._orderType == OrderType.Buy
              ? createHeaderBuy(context, widthSection)
              : createHeaderSell(context, widthSection);
          list.add(headers);

          StockSummary stockSummary =
              context.read(stockSummaryChangeNotifier).summary;
          int prev = stockSummary != null &&
                  stockSummary.prev != null &&
                  StringUtils.equalsIgnoreCase(
                      stockSummary.code, data.orderbook.code)
              ? stockSummary.prev
              : 0;

          // if (!StringUtils.equalsIgnoreCase(details['code'], notifier.orderbook.code) ||
          //     !StringUtils.equalsIgnoreCase(details['board'], notifier.orderbook.board)) {
          //   details.clear();
          // }

          // details['code'] = notifier.orderbook.code;
          // details['board'] = notifier.orderbook.board;

          data.orderbook.generateDataForUI(widget.maxShowLevel);

          int totalVolumeShowedBid = data.orderbook.totalVolumeShowedBid;
          int totalVolumeShowedOffer = data.orderbook.totalVolumeShowedOffer;

          double fontSize = InvestrendTheme.of(context).small_w400.fontSize;
          fontSize =
              useFontSize(context, fontSize, widthSection, data.orderbook);
          print('FastOrderbook [' +
              widget._orderType.routeName +
              '] buildOrderbook  code : ' +
              data.orderbook.code +
              '  prev : $prev');

          bool isBuy = widget._orderType == OrderType.Buy;
          int count = min(widget.maxShowLevel, data.orderbook.countBids());

          for (int index = 0; index < count; index++) {
            // double fractionBid = value.bidVol(index) / totalVolumeShowedBid;
            // double fractionOffer = value.offerVol(index) / totalVolumeShowedOffer;

            bool showBid = data.orderbook.bids.elementAt(index) > 0;
            bool showOffer = data.orderbook.offers.elementAt(index) > 0;

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

            int bid = data.orderbook.bids.elementAt(index);
            int offer = data.orderbook.offers.elementAt(index);
            //Key key = isBuy ? keysBid.elementAt(index) : keysOffer.elementAt(index);

            String bidQueue = data.orderbook.bidsQueueText.elementAt(index);
            String bidLot = data.orderbook.bidsLotText.elementAt(index);
            String bidPrice = data.orderbook.bidsText.elementAt(index);
            //Color bidColor = prev == 0 ? InvestrendTheme.of(context).blackAndWhiteText : InvestrendTheme.priceTextColor(bid, prev: prev, caller: widget._orderType.routeName+'[Bid]');
            Color bidColor = prev == 0
                ? InvestrendTheme.of(context).blackAndWhiteText
                : InvestrendTheme.priceTextColor(bid, prev: prev);
            String offerQueue = data.orderbook.offersQueueText.elementAt(index);
            String offerLot = data.orderbook.offersLotText.elementAt(index);
            String offerPrice = data.orderbook.offersText.elementAt(index);
            //Color offerColor = prev == 0 ? InvestrendTheme.of(context).blackAndWhiteText : InvestrendTheme.priceTextColor(offer, prev: prev, caller: widget._orderType.routeName+'[Offer]');
            Color offerColor = prev == 0
                ? InvestrendTheme.of(context).blackAndWhiteText
                : InvestrendTheme.priceTextColor(offer, prev: prev);

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
            FocusNode nextFocusNode =
                (nextIndex < count) ? _focusNodes.elementAt(nextIndex) : null;
            TextEditingController controller = _controllers.elementAt(index);
            if (widget._orderType == OrderType.Buy) {
              OpenOrder openOrder =
                  context.read(openOrderChangeNotifier).get(bid);
              list.add(createRowBuy(
                  context,
                  bidQueue,
                  bidLot,
                  bidPrice,
                  bidColor,
                  offerQueue,
                  offerLot,
                  offerPrice,
                  offerColor,
                  widthSection,
                  fontSize,
                  _controllers.elementAt(index),
                  showBid,
                  keysBid.elementAt(index),
                  openOrder,
                  focusNode: focusNode,
                  nextFocusNode: nextFocusNode));
            } else {
              OpenOrder openOrder =
                  context.read(openOrderChangeNotifier).get(offer);
              list.add(createRowSell(
                  context,
                  bidQueue,
                  bidLot,
                  bidPrice,
                  bidColor,
                  offerQueue,
                  offerLot,
                  offerPrice,
                  offerColor,
                  widthSection,
                  fontSize,
                  _controllers.elementAt(index),
                  showOffer,
                  keysOffer.elementAt(index),
                  openOrder,
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

  //perubahan
  Widget buildOrderbookStatic(
      BuildContext context, double widthWidget, double heightWidget) {
    //double widthHalf = widthWidget / 2;
    widthSection = (widthWidget - FastOrderbook.middle_gap) / 2;

    List<Widget> list = List.empty(growable: true);

    Widget headers = widget._orderType == OrderType.Buy
        ? createHeaderBuy(context, widthSection)
        : createHeaderSell(context, widthSection);
    list.add(headers);

    int count = min(widget.maxShowLevel, 10);

    for (int index = 0; index < count; index++) {
      FocusNode focusNode = _focusNodes.elementAt(index);
      int nextIndex = (index + 1);
      FocusNode nextFocusNode =
          (nextIndex < count) ? _focusNodes.elementAt(nextIndex) : null;
      TextEditingController controller = _controllers.elementAt(index);
      if (widget._orderType == OrderType.Buy) {
        //OpenOrder openOrder = context.read(openOrderChangeNotifier).get(bid);
        _notifiers.elementAt(index).index = index;
        list.add(
          LongPressDraggable<WrapperNotifierFast>(
            data: _notifiers.elementAt(index),
            feedbackOffset: Offset(50, -10),
            onDragStarted: () {
              lockedOpen =
                  _notifiers.elementAt(index).primaryOpenNotifier.value.value;
              lockedBid =
                  _notifiers.elementAt(index).primaryPriceNotifier.value.value;
            },
            feedback: Padding(
              padding: const EdgeInsets.only(
                left: 50,
              ),
              child: Container(
                child: createRowBuyStatic(
                  context,
                  widthSection,
                  _controllers.elementAt(index),
                  keysBid.elementAt(index),
                  _notifiers.elementAt(index),
                  focusNode: focusNode,
                  nextFocusNode: nextFocusNode,
                  onDrag: true,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                height: 50,
                width: MediaQuery.of(context).size.width / 3,
              ),
            ),
            child: DragTarget<WrapperNotifierFast>(
              onMove: (data) {
                _notifiers.elementAt(index).color.value =
                    InvestrendTheme.of(context).oddColor;
              },
              onLeave: (data) {
                _notifiers.elementAt(index).color.value = Colors.transparent;
              },
              onAccept: (data) {
                _notifiers.elementAt(index).color.value = Colors.transparent;

                if (_notifiers.elementAt(index).primaryPriceNotifier.value ==
                    data.primaryPriceNotifier.value) {
                  return;
                }

                String dragedValue = lockedOpen == "" ? "0" : lockedOpen;

                String targetdValue =
                    _notifiers[index].primaryOpenNotifier.value.value == ""
                        ? "0"
                        : _notifiers[index].primaryOpenNotifier.value.value;

                if (int.parse(dragedValue) > 0) {
                  var obj = _notifiers
                      .where((e) =>
                          e.primaryPriceNotifier.value.value == lockedBid)
                      .first;

                  if (obj != null) {
                    obj.primaryOpenNotifier.value.value =
                        (int.parse(dragedValue) - 1).toString();
                  }

                  data.primaryOpenNotifier.notifyListeners();

                  _notifiers[index].primaryOpenNotifier.value.value =
                      (int.parse(targetdValue) + 1).toString();
                  _notifiers[index].primaryOpenNotifier.notifyListeners();
                }
              },
              builder: (BuildContext context, List<Object> candidateData,
                  List<dynamic> rejectedData) {
                return Container(
                  color: _notifiers.elementAt(index).color.value,
                  child: createRowBuyStatic(
                    context,
                    widthSection,
                    _controllers.elementAt(index),
                    keysBid.elementAt(index),
                    _notifiers.elementAt(index),
                    focusNode: focusNode,
                    nextFocusNode: nextFocusNode,
                  ),
                );
              },
            ),
          ),
        );
      } else {
        _notifiers.elementAt(index).index = index;
        list.add(
          LongPressDraggable<WrapperNotifierFast>(
            data: _notifiers.elementAt(index),
            feedbackOffset: Offset(50, -10),
            onDragStarted: () {
              lockedOpen =
                  _notifiers.elementAt(index).primaryOpenNotifier.value.value;
              lockedBid = _notifiers
                  .elementAt(index)
                  .secondaryPriceNotifier
                  .value
                  .value;
            },
            feedback: Padding(
              padding: const EdgeInsets.only(
                left: 200,
              ),
              child: Container(
                child: createRowSellStatic(
                  context,
                  widthSection,
                  _controllers.elementAt(index),
                  keysOffer.elementAt(index),
                  _notifiers.elementAt(index),
                  focusNode: focusNode,
                  nextFocusNode: nextFocusNode,
                  onDrag: true,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                height: 50,
                width: MediaQuery.of(context).size.width / 3,
              ),
            ),
            child: DragTarget<WrapperNotifierFast>(
              onMove: (data) {
                _notifiers.elementAt(index).color.value =
                    InvestrendTheme.of(context).oddColor;
              },
              onLeave: (data) {
                _notifiers.elementAt(index).color.value = Colors.transparent;
              },
              onAccept: (data) {
                _notifiers.elementAt(index).color.value = Colors.transparent;

                if (_notifiers.elementAt(index).secondaryPriceNotifier.value ==
                    data.secondaryPriceNotifier.value) {
                  return;
                }

                String dragedValue = lockedOpen == "" ? "0" : lockedOpen;
                String targetdValue =
                    _notifiers[index].primaryOpenNotifier.value.value == ""
                        ? "0"
                        : _notifiers[index].primaryOpenNotifier.value.value;

                if (int.parse(dragedValue) > 0) {
                  var obj = _notifiers
                      .where((e) =>
                          e.secondaryPriceNotifier.value.value == lockedBid)
                      .first;

                  if (obj != null) {
                    obj.primaryOpenNotifier.value.value =
                        (int.parse(dragedValue) - 1).toString();
                  }

                  data.primaryOpenNotifier.notifyListeners();

                  _notifiers[index].primaryOpenNotifier.value.value =
                      (int.parse(targetdValue) + 1).toString();
                  _notifiers[index].primaryOpenNotifier.notifyListeners();
                }
              },
              builder: (BuildContext context, List<Object> candidateData,
                  List<dynamic> rejectedData) {
                return Container(
                  color: _notifiers.elementAt(index).color.value,
                  child: createRowSellStatic(
                      context,
                      widthSection,
                      _controllers.elementAt(index),
                      keysOffer.elementAt(index),
                      _notifiers.elementAt(index),
                      focusNode: focusNode,
                      nextFocusNode: nextFocusNode),
                );
              },
            ),
          ),
        );
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: list,
    );
  }

  void reconcileOrderbook() {
    print(widget._orderType.routeName + '.reconcileOrderbook');
    OrderBook ob = context.read(orderBookChangeNotifier).orderbook;
    bool isBuy = widget._orderType == OrderType.Buy;
    BuySell data =
        context.read(buySellChangeNotifier).getData(widget._orderType);
    List<int> listValid = List.empty(growable: true);
    int count = min(widget.maxShowLevel, ob.countBids());
    for (int i = 0; i < count; i++) {
      int price = isBuy ? ob.bids.elementAt(i) : ob.offers.elementAt(i);
      TextEditingController controller = _controllers.elementAt(i);
      bool show = price > 0;
      if (show) {
        PriceLot savedPriceLot = data.getFastPriceLot(price);

        if (savedPriceLot != null) {
          // controller.text = savedPriceLot.lot.toString();
          // controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          String newText = InvestrendTheme.formatComma(savedPriceLot.lot);
          if (!StringUtils.equalsIgnoreCase(controller.text, newText)) {
            controller.removeListener(listener);
            controller.text = newText;
            controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length));
            controller.addListener(listener);
          }
          listValid.add(price);
        } else {
          //controller.removeListener(listener);
          if (!StringUtils.isEmtpy(controller.text)) {
            controller.removeListener(listener);
            controller.text = '';
            controller.addListener(listener);
          }
          //controller.text = '';
          //controller.addListener(listener);
        }
      }
    }
    List<int> listInvalid = List.empty(growable: true);
    int value = 0;
    data.listFastPriceLot.forEach((priceLot) {
      bool valid = listValid.contains(priceLot.price);
      if (!valid) {
        listInvalid.add(priceLot.price);
      } else {
        value += priceLot.calculateValue();
      }
    });

    listInvalid.forEach((invalidPrice) {
      data.removeFastPriceLot(invalidPrice);
    });
    listInvalid.clear();
    listValid.clear();

    if (data.orderType.isBuyOrAmendBuy()) {
      double feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
      Account activeAccount = context
          .read(dataHolderChangeNotifier)
          .user
          .getAccount(context.read(accountChangeNotifier).index);
      if (activeAccount != null) {
        feeBuy = activeAccount.commission;
      }
      if (feeBuy > 0) {
        value = (value * (1.0 + (feeBuy / 100))).toInt();
      }
    }
    data.fastTotalValue = value;
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

  double useFontSize(BuildContext context, double fontSize, double widthSection,
      OrderBook value,
      {int offset = 0}) {
    print('FastOrderbook[' +
        widget.owner +
        '].useFontSize Try fontSize  : $fontSize  offset : $offset');
    TextStyle smallW400 =
        InvestrendTheme.of(context).small_w400.copyWith(fontSize: fontSize);
    TextStyle smallW500 =
        InvestrendTheme.of(context).small_w500.copyWith(fontSize: fontSize);
    const double font_step = 1.0;
    double widthCell = widthSection / 3;
    int count = min(widget.maxShowLevel, value.countBids());
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
              context, fontSize - font_step, widthSection, value,
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
              context, fontSize - font_step, widthSection, value,
              offset: index);
          //break;
          return fontSize;
        }
      }
    }
    print('FastOrderbook[' +
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
          width: FastOrderbook.middle_gap,
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
          width: FastOrderbook.middle_gap,
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
          width: FastOrderbook.middle_gap,
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
                    context, fontSize, offerQueue, TextAlign.right),
              ),
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
      double fontSize,
      TextEditingController controller,
      bool showOffer,
      Key key,
      OpenOrder openOrder,
      {FocusNode focusNode,
      FocusNode nextFocusNode,
      Key keyRow}) {
    int open = (openOrder != null ? openOrder.lot : 0);
    //String openString = InvestrendTheme.formatComma(open);
    return Row(
      key: keyRow,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widthSection / 3,
          child: createLabelPrice(
              context, fontSize, bidPrice, TextAlign.right, bidColor),
        ),
        SizedBox(
          width: (FastOrderbook.middle_gap / 2) - 0.5,
        ),
        Container(
          width: 1.0,
          //height: 25.0,
          color: Theme.of(context).dividerColor,
          child: createLabelPrice(
              context, fontSize, '', TextAlign.right, offerColor),
        ),
        SizedBox(
          width: (FastOrderbook.middle_gap / 2) - 0.5,
        ),
        Container(
          width: widthSection,
          //color: Colors.yellow,
          child: Stack(
            children: [
              createLabelPrice(
                  context, fontSize, '', TextAlign.right, bidColor),
              Positioned.fill(
                  child: createLabelPrice(context, fontSize, offerPrice,
                      TextAlign.left, offerColor /*, key: key*/)),
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
                ? TextField(
                    key: key,
                    controller: controller,
                    //onSubmitted: (_) => context.nextEditableTextFocus(),
                    focusNode: focusNode,
                    onSubmitted: (_) {
                      print('onSubmitted');
                      if (nextFocusNode != null) {
                        print('onSubmitted nextFocusNode.requestFocus');
                        nextFocusNode.requestFocus();
                      } else {
                        print('onSubmitted nextEditableTextFocus');
                        context.nextEditableTextFocus();
                      }
                    },
                    inputFormatters: [
                      PriceFormatter(),
                    ],
                    maxLines: 1,
                    style: InvestrendTheme.of(context).small_w400.copyWith(
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

//perubahan
  Widget createRowSellStatic(
    BuildContext context,
    double widthSection,
    TextEditingController controller,
    Key key,
    WrapperNotifierFast notifier, {
    FocusNode focusNode,
    FocusNode nextFocusNode,
    Key keyRow,
    bool onDrag = false,
  }) {
    return Row(
      key: keyRow,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: widthSection / 3,
                child: ValueListenableBuilder(
                  valueListenable: notifier.secondaryPriceNotifier,
                  builder: (context, StringColorFont data, child) {
                    return createLabelPrice(context, data.fontSize, data.value,
                        TextAlign.right, data.color);
                  },
                ),
              ),
        onDrag == true
            ? ValueListenableBuilder(
                valueListenable: notifier.primaryPriceNotifier,
                builder: (context, StringColorFont data, child) {
                  return createLabelPrice(context, data.fontSize, data.value,
                      TextAlign.left, data.color /*, key: key*/);
                },
              )
            : SizedBox(),
        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: (FastOrderbook.middle_gap / 2) - 0.5,
              ),
        onDrag == true
            ? SizedBox()
            : Container(
                width: 1.0,
                //height: 25.0,
                color: Theme.of(context).dividerColor,
                child: createLabelPrice(
                    context,
                    InvestrendTheme.of(context).small_w500.fontSize,
                    '',
                    TextAlign.right,
                    InvestrendTheme.sellTextColor),
              ),
        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: (FastOrderbook.middle_gap / 2) - 0.5,
              ),
        onDrag == true
            ? SizedBox()
            : Container(
                width: widthSection,
                //color: Colors.yellow,
                child: Stack(
                  children: [
                    createLabelPrice(
                        context,
                        InvestrendTheme.of(context).small_w500.fontSize,
                        '',
                        TextAlign.right,
                        InvestrendTheme.sellTextColor),
                    Positioned.fill(
                      //child: createLabelPrice(context, fontSize, offerPrice, TextAlign.left, offerColor /*, key: key*/),
                      child: ValueListenableBuilder(
                        valueListenable: notifier.primaryPriceNotifier,
                        builder: (context, StringColorFont data, child) {
                          return createLabelPrice(
                              context,
                              data.fontSize,
                              data.value,
                              TextAlign.left,
                              data.color /*, key: key*/);
                        },
                      ),
                    ),
                    Positioned.fill(
                      //child: createLabelLot(context, fontSize, offerLot),
                      child: ValueListenableBuilder(
                        valueListenable: notifier.primaryLotNotifier,
                        builder: (context, StringColorFont data, child) {
                          return createLabelLot(
                              context, data.fontSize, data.value);
                        },
                      ),
                    ),
                    Positioned.fill(
                      //child: createLabelQueue(context, fontSize, offerQueue, TextAlign.right),
                      child: ValueListenableBuilder(
                        valueListenable: notifier.primaryQueNotifier,
                        builder: (context, StringColorFont data, child) {
                          return createLabelQueue(context, data.fontSize,
                              data.value, TextAlign.right);
                        },
                      ),
                    ),
                  ],
                ),
              ),
        SizedBox(
          width: widthSection / 3,
          child: Builder(
            builder: (builder) {
              if (onDrag) {
                return createLabelOpenStatic(
                  context,
                  notifier.primaryOpenNotifier.value.fontSize,
                  notifier.primaryOpenNotifier.value.value,
                  TextAlign.right,
                );
              } else {
                return ValueListenableBuilder(
                  valueListenable: notifier.primaryOpenNotifier,
                  builder: (context, StringColorFont data, child) {
                    return createLabelOpenStatic(
                        context, data.fontSize, data.value, TextAlign.right);
                  },
                );
              }
            },
          ),
        ),
        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: widthSection / 3,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: InvestrendTheme.cardPadding),
                  child: ValueListenableBuilder(
                      valueListenable: notifier.show,
                      builder: (context, bool show, child) {
                        if (!show) {
                          return SizedBox(
                            width: 1.0,
                          );
                        }
                        if (onDrag) {
                          return Material(child: Text(controller.text));
                        }
                        return AutoSizeTextField(
                          key: key,
                          controller: controller,
                          //onSubmitted: (_) => context.nextEditableTextFocus(),
                          focusNode: focusNode,
                          onSubmitted: (_) {
                            print('onSubmitted');
                            focusNode.unfocus();
                            // if (nextFocusNode != null) {
                            //   print('onSubmitted nextFocusNode.requestFocus');
                            //   nextFocusNode.requestFocus();
                            // } else {
                            //   print('onSubmitted nextEditableTextFocus');
                            //   context.nextEditableTextFocus();
                            // }
                          },
                          inputFormatters: [
                            PriceFormatter(),
                          ],
                          maxLines: 1,
                          style: InvestrendTheme.of(context)
                              .small_w400
                              .copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyDarkerTextColor,
                                  fontSize: InvestrendTheme.of(context)
                                      .small_w400
                                      .fontSize),
                          textInputAction: TextInputAction.done,
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
                            prefixStyle:
                                InvestrendTheme.of(context).inputPrefixStyle,
                            hintStyle:
                                InvestrendTheme.of(context).inputHintStyle,
                            helperStyle:
                                InvestrendTheme.of(context).inputHelperStyle,
                            errorStyle:
                                InvestrendTheme.of(context).inputErrorStyle,
                            fillColor: Colors.grey,
                            contentPadding: EdgeInsets.all(0.0),
                          ),
                          textAlign: TextAlign.right,
                        );
                      }),
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
      double fontSize,
      TextEditingController controller,
      bool showBid,
      Key key,
      OpenOrder openOrder,
      {FocusNode focusNode,
      FocusNode nextFocusNode,
      Key keyRow}) {
    int open = (openOrder != null ? openOrder.lot : 0);
    //String openString = InvestrendTheme.formatComma(open);
    return Row(
      key: keyRow,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widthSection / 3,
          child: Padding(
            padding: const EdgeInsets.only(right: InvestrendTheme.cardPadding),
            child: showBid
                ? TextField(
                    controller: controller,
                    key: key,

                    //onSubmitted: (_) => context.nextEditableTextFocus(),
                    focusNode: focusNode,
                    onSubmitted: (_) {
                      print('onSubmitted');
                      if (nextFocusNode != null) {
                        print('onSubmitted nextFocusNode.requestFocus');
                        nextFocusNode.requestFocus();
                      } else {
                        print('onSubmitted nextEditableTextFocus');
                        context.nextEditableTextFocus();
                      }
                    },
                    inputFormatters: [
                      PriceFormatter(),
                    ],
                    maxLines: 1,
                    style: InvestrendTheme.of(context).small_w400.copyWith(
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
                  child: createLabelPrice(context, fontSize, bidPrice,
                      TextAlign.right, bidColor /*, key: key*/)),
            ],
          ),
        ),
        SizedBox(
          width: (FastOrderbook.middle_gap / 2) - 0.5,
        ),
        Container(
          width: 1.0,
          //height: 25.0,
          color: Theme.of(context).dividerColor,
          child: createLabelPrice(
              context, fontSize, '', TextAlign.right, bidColor),
        ),
        SizedBox(
          width: (FastOrderbook.middle_gap / 2) - 0.5,
        ),
        SizedBox(
          width: widthSection / 3,
          child: createLabelPrice(
              context, fontSize, offerPrice, TextAlign.left, offerColor),
        ),
      ],
    );
  }

  //perubahan
  Widget createRowBuyStatic(
    BuildContext context,
    double widthSection,
    TextEditingController controller,
    Key key,
    WrapperNotifierFast notifier, {
    FocusNode focusNode,
    FocusNode nextFocusNode,
    Key keyRow,
    bool onDrag = false,
  }) {
    return Row(
      key: keyRow,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: widthSection / 3,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: InvestrendTheme.cardPadding),
                  child: ValueListenableBuilder(
                    valueListenable: notifier.show,
                    builder: (context, bool show, child) {
                      if (!show) {
                        return SizedBox(
                          width: 1.0,
                        );
                      }
                      if (onDrag) {
                        return Material(child: Text(controller.text));
                      }
                      return AutoSizeTextField(
                        controller: controller,
                        key: key,
                        //onSubmitted: (_) => context.nextEditableTextFocus(),
                        focusNode: focusNode,
                        onSubmitted: (_) {
                          print('onSubmitted');
                          focusNode.unfocus();
                          // if (nextFocusNode != null) {
                          //   print('onSubmitted nextFocusNode.requestFocus');
                          //   nextFocusNode.requestFocus();
                          // } else {
                          //   print('onSubmitted nextEditableTextFocus');
                          //   context.nextEditableTextFocus();
                          // }
                        },
                        inputFormatters: [
                          PriceFormatter(),
                        ],
                        maxLines: 1,
                        style: InvestrendTheme.of(context).small_w400.copyWith(
                            color:
                                InvestrendTheme.of(context).greyDarkerTextColor,
                            fontSize: InvestrendTheme.of(context)
                                .small_w400
                                .fontSize),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.0),
                          ),
                          focusColor: Theme.of(context).colorScheme.secondary,
                          prefixStyle:
                              InvestrendTheme.of(context).inputPrefixStyle,
                          hintStyle: InvestrendTheme.of(context).inputHintStyle,
                          helperStyle:
                              InvestrendTheme.of(context).inputHelperStyle,
                          errorStyle:
                              InvestrendTheme.of(context).inputErrorStyle,
                          fillColor: Colors.grey,
                          contentPadding: EdgeInsets.all(0.0),
                        ),
                        textAlign: TextAlign.left,
                      );
                    },
                  ),
                ),
              ),
        SizedBox(
          width: widthSection / 3,
          child: Builder(
            builder: (builder) {
              if (onDrag) {
                return createLabelOpenStatic(
                  context,
                  notifier.primaryOpenNotifier.value.fontSize,
                  notifier.primaryOpenNotifier.value.value,
                  TextAlign.left,
                );
              } else {
                return ValueListenableBuilder(
                  valueListenable: notifier.primaryOpenNotifier,
                  builder: (context, StringColorFont data, child) {
                    return createLabelOpenStatic(
                        context, data.fontSize, data.value, TextAlign.left);
                  },
                );
              }
            },
          ),
        ),

        onDrag == true
            ? SizedBox()
            : Container(
                width: widthSection,
                //color: Colors.yellow,
                child: Stack(
                  children: [
                    createLabelPrice(
                      context,
                      InvestrendTheme.of(context).small_w500.fontSize,
                      '',
                      TextAlign.right,
                      InvestrendTheme.buyTextColor,
                    ),
                    Positioned.fill(
                      child: ValueListenableBuilder(
                        valueListenable: notifier.primaryQueNotifier,
                        builder: (context, StringColorFont data, child) {
                          return createLabelQueueStatic(context, data.fontSize,
                              data.value, TextAlign.left);
                        },
                      ),
                    ),

                    //Blot
                    Positioned.fill(
                      child: ValueListenableBuilder(
                        valueListenable: notifier.primaryLotNotifier,
                        builder: (context, StringColorFont data, child) {
                          return createLabelLotStatic(
                            context,
                            data.fontSize,
                            data.value,
                          );
                        },
                      ),
                    ),

                    //Bid
                    Positioned.fill(
                      child: ValueListenableBuilder(
                        valueListenable: notifier.primaryPriceNotifier,
                        builder: (context, StringColorFont data, child) {
                          return createLabelPriceStatic(
                            context,
                            data.fontSize,
                            data.value,
                            TextAlign.right,
                            data.color, /*, key: key*/
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        onDrag == true
            ? ValueListenableBuilder(
                valueListenable: notifier.primaryPriceNotifier,
                builder: (context, StringColorFont data, child) {
                  return createLabelPriceStatic(
                    context,
                    data.fontSize,
                    data.value,
                    TextAlign.right,
                    data.color, /*key: key*/
                  );
                },
              )
            : SizedBox(),

        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: (FastOrderbook.middle_gap / 2) - 0.5,
              ),
        onDrag == true
            ? SizedBox()
            : Container(
                width: 1.0,
                //height: 25.0,
                color: Theme.of(context).dividerColor,
                child: createLabelPriceStatic(
                  context,
                  InvestrendTheme.of(context).small_w500.fontSize,
                  '',
                  TextAlign.right,
                  InvestrendTheme.buyTextColor,
                ),
              ),
        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: (FastOrderbook.middle_gap / 2) - 0.5,
              ),

        //Ask
        onDrag == true
            ? SizedBox()
            : SizedBox(
                width: widthSection / 3,
                child: ValueListenableBuilder(
                  valueListenable: notifier.secondaryPriceNotifier,
                  builder: (context, StringColorFont data, child) {
                    return createLabelPriceStatic(
                      context,
                      data.fontSize,
                      data.value,
                      TextAlign.left,
                      data.color,
                    );
                  },
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
        style: InvestrendTheme.of(context).small_w500,
        textAlign: TextAlign.left,
      ),
    );
  }

  //header bid
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

  //header blot
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

  Widget createLabelQueue(
      BuildContext context, double fontSize, String text, TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400.copyWith(
            color: InvestrendTheme.of(context).greyLighterTextColor,
            fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }

  //Que
  Widget createLabelQueueStatic(
      BuildContext context, double fontSize, String text, TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400.copyWith(
            color: InvestrendTheme.of(context).greyLighterTextColor,
            fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }

  Widget createLabelLot(BuildContext context, double fontSize, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400.copyWith(
            color: InvestrendTheme.of(context).greyDarkerTextColor,
            fontSize: fontSize),
        textAlign: TextAlign.center,
      ),
    );
  }

  //BLot
  Widget createLabelLotStatic(
      BuildContext context, double fontSize, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        style: InvestrendTheme.of(context).small_w400.copyWith(
            color: InvestrendTheme.of(context).greyDarkerTextColor,
            fontSize: fontSize),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createLabelOpen(BuildContext context, double fontSize, int lot,
      TextAlign textAlign, bool show) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: show
          ? RichText(
              textAlign: textAlign,
              text: TextSpan(
                text: InvestrendTheme.formatComma(lot),
                style: InvestrendTheme.of(context).small_w400.copyWith(
                    color: InvestrendTheme.of(context).greyDarkerTextColor,
                    fontSize: fontSize),
                children: <TextSpan>[
                  TextSpan(
                    text: lot > 0 ? '*' : '',
                    style: InvestrendTheme.of(context)
                        .small_w400
                        .copyWith(color: Colors.red, fontSize: fontSize),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: 1,
            ),
    );
  }

  //Open
  Widget createLabelOpenStatic(BuildContext context, double fontSize,
      String openText, TextAlign textAlign) {
    bool empty = StringUtils.isEmtpy(openText) ||
        StringUtils.equalsIgnoreCase(openText, '0');
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: RichText(
        textAlign: textAlign,
        text: TextSpan(
          text: openText,
          style: InvestrendTheme.of(context).small_w400.copyWith(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
              fontSize: fontSize),
          children: <TextSpan>[
            TextSpan(
              text: !empty ? '*' : '',
              style: InvestrendTheme.of(context)
                  .small_w400
                  .copyWith(color: Colors.red, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget createLabelOpenNew(
      BuildContext context, double fontSize, int openLot, TextAlign textAlign) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: RichText(
        textAlign: textAlign,
        text: TextSpan(
          text: InvestrendTheme.formatComma(openLot),
          style: InvestrendTheme.of(context).small_w400.copyWith(
              color: InvestrendTheme.of(context).greyDarkerTextColor,
              fontSize: fontSize),
          children: <TextSpan>[
            TextSpan(
              text: openLot > 0 ? '*' : '',
              style: InvestrendTheme.of(context)
                  .small_w400
                  .copyWith(color: Colors.red, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget createLabelPrice(BuildContext context, double fontSize, String text,
      TextAlign textAlign, Color color,
      {Key key}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        key: key,
        style: InvestrendTheme.of(context)
            .small_w500
            .copyWith(color: color, fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }

  //Bid dan Ask
  Widget createLabelPriceStatic(BuildContext context, double fontSize,
      String text, TextAlign textAlign, Color color,
      {Key key}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        text,
        key: key,
        style: InvestrendTheme.of(context)
            .small_w500
            .copyWith(color: color, fontSize: fontSize),
        textAlign: textAlign,
      ),
    );
  }

  Widget createTextField(
      BuildContext context,
      Key fieldKey,
      double fontSize,
      TextEditingController controller,
      FocusNode focusNode,
      TextAlign textAlign,
      {FocusNode nextFocusNode}) {
    return AutoSizeTextField(
      controller: controller,
      key: fieldKey,
      //onSubmitted: (_) => context.nextEditableTextFocus(),
      focusNode: focusNode,
      onSubmitted: (_) {
        print('onSubmitted');
        if (nextFocusNode != null) {
          print('onSubmitted nextFocusNode.requestFocus');
          nextFocusNode.requestFocus();
        } else {
          print('onSubmitted nextEditableTextFocus');
          context.nextEditableTextFocus();
        }
      },
      inputFormatters: [
        PriceFormatter(),
      ],
      maxLines: 1,
      style: InvestrendTheme.of(context).small_w400.copyWith(
          color: InvestrendTheme.of(context).greyDarkerTextColor,
          fontSize: InvestrendTheme.of(context).small_w400.fontSize),
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        isDense: true,
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0)),
        focusColor: Theme.of(context).colorScheme.secondary,
        prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
        hintStyle: InvestrendTheme.of(context).inputHintStyle,
        helperStyle: InvestrendTheme.of(context).inputHelperStyle,
        errorStyle: InvestrendTheme.of(context).inputErrorStyle,
        fillColor: Colors.grey,
        contentPadding: EdgeInsets.all(0.0),
      ),
      textAlign: TextAlign.left,
    );
  }
}
