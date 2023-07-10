import 'dart:async';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/trade/screen_trade_form.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenTradeSell extends StatefulWidget {
  final ValueNotifier<bool> _fastModeNotifier;
  final TabController _tabController;
  final OrderbookNotifier _orderbookNotifier;

  final ValueNotifier<bool> _updateDataNotifier;
  final bool _onlyFastOrder;
  final PriceLot initialPriceLot;
  final ValueNotifier<bool> keyboardNotifier;

  const ScreenTradeSell(this._fastModeNotifier, this._tabController, this._orderbookNotifier, this._updateDataNotifier, this._onlyFastOrder,
      {Key key, this.initialPriceLot, this.keyboardNotifier})
      : super(key: key);

  //const ScreenTradeSell( this._fastModeNotifier, this._tabController, this._orderbookNotifier, {Key key}) : super(key: key);
  @override
  _ScreenTradeSellState createState() =>
      _ScreenTradeSellState(_fastModeNotifier, _tabController, _orderbookNotifier, _updateDataNotifier, _onlyFastOrder,
          initialPriceLot: initialPriceLot, keyboardNotifier: keyboardNotifier);
}

class _ScreenTradeSellState extends BaseTradeState<ScreenTradeSell> //with AutomaticKeepAliveClientMixin<ScreenTradeSell>
{
  _ScreenTradeSellState(ValueNotifier<bool> fastModeNotifier, TabController tabController, OrderbookNotifier orderbookNotifier,
      ValueNotifier<bool> updateDataNotifier, bool onlyFastOrder,
      {PriceLot initialPriceLot, ValueNotifier<bool> keyboardNotifier})
      : super(
          OrderType.Sell,
          fastModeNotifier,
          tabController,
          orderbookNotifier,
          updateDataNotifier,
          onlyFastOrder,
          initialPriceLot: initialPriceLot,
          keyboardNotifier: keyboardNotifier,
        );

  @override
  Widget createTopInfo(BuildContext context) {
    // int jumlahLot = 2500;
    // double averagePrice = 1000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        columnWidths: {0: FractionColumnWidth(.3)},
        children: [
          TableRow(children: [
            Text(
              'trade_sell_label_total_lot'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
            Text(
              'trade_sell_label_average_price'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
          ]),
          TableRow(children: [
            Consumer(builder: (context, watch, child) {
              final lotAverage = watch(sellLotAvgChangeNotifier);
              return Text(
                  InvestrendTheme.formatComma(
                    lotAverage.lot,
                  ),
                  style: InvestrendTheme.of(context).regular_w600);
            }),
            // Text(
            //     InvestrendTheme.formatComma(
            //       jumlahLot,
            //     ),
            //     style: InvestrendTheme.of(context).regular_w700),

            Consumer(builder: (context, watch, child) {
              final lotAverage = watch(sellLotAvgChangeNotifier);
              return Text(
                InvestrendTheme.formatMoneyDouble(
                  lotAverage.averagePrice,
                  prefixRp: true,
                ),
                style: InvestrendTheme.of(context).regular_w600,
                //textAlign: TextAlign.end,
              );
            }),

            // Text(
            //   InvestrendTheme.formatMoneyDouble(
            //     averagePrice,
            //     prefixRp: true,
            //   ),
            //   style: InvestrendTheme.of(context).regular_w700,
            //   //textAlign: TextAlign.end,
            // ),
          ])
        ],
      ),
    );
  }

  Future doUpdateAccount({bool pullToRefresh = false}) async {
    if (!isActiveAndMounted()) {
      print(orderType.routeName +
          '.doUpdateAccount Aborted : ' +
          DateTime.now().toString() +
          "  active : $active  mounted : $mounted pullToRefresh : $pullToRefresh");
      return false;
    }
    print(orderType.routeName +
        '.doUpdateAccount : ' +
        DateTime.now().toString() +
        "  active : $active  mounted : $mounted  pullToRefresh : $pullToRefresh");
    onProgressAccount = true;

    Stock stock = context.read(primaryStockChangeNotifier).stock;
    int selected = context.read(accountChangeNotifier).index;
    //Account account = InvestrendTheme.of(context).user.getAccount(selected);
    Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
      //String text = 'No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      String errorNoAccount = 'error_no_account_selected'.tr();
      String text = '$errorNoAccount. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      InvestrendTheme.of(context).showSnackBar(context, text);
      onProgressAccount = false;
      return false;
    } else {
      try {
        print(orderType.routeName + ' try stockPosition');
        final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
            account.brokercode,
            account.accountcode,
            //InvestrendTheme.of(context).user.username,
            context.read(dataHolderChangeNotifier).user.username,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        DebugWriter.information(orderType.routeName +
            ' Got stockPosition ' +
            stockPosition.accountcode +
            '   stockList.size : ' +
            stockPosition.stockListSize().toString());
        if (!mounted) {
          onProgressAccount = false;
          return false;
        }
        StockPositionDetail detail = stockPosition.getStockPositionDetailByCode(stock?.code);
        if (detail != null) {
          context.read(sellLotAvgChangeNotifier).update(detail.netBalance.toInt(), detail.avgPrice);
        } else {
          context.read(sellLotAvgChangeNotifier).update(0, 0.0);
        }
      } catch (e) {
        DebugWriter.information(orderType.routeName + ' stockPosition Exception : ' + e.toString());
        if (!mounted) {
          onProgressAccount = false;
          return false;
        }
        if (e is TradingHttpException) {
          if (e.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            onProgressAccount = false;
            return false;
          } else if (e.isErrorTrading()) {
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            onProgressAccount = false;
            return false;
          } else {
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel = networkErrorLabel.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
            onProgressAccount = false;
            return false;
          }
        } else {
          InvestrendTheme.of(context).showSnackBar(context, e.toString());
        }
      }
    }
    onProgressAccount = false;
    return true;
  }
/*
  final OrderType orderType = OrderType.Sell;
  final fieldPriceController = TextEditingController();
  final fieldLotController = TextEditingController();
  static const Duration durationUpdate = Duration(milliseconds: 5000);
  final ValueNotifier<int> valueOrderNotifier = ValueNotifier<int>(0);
  //ChangeNotifier recalculateNotifier = ChangeNotifier();
  //ValueNotifier valueOrderNotifier = ValueNotifier<int>(0);
  final TradeCalculateNotifier calculateNotifier = TradeCalculateNotifier(OrderType.Sell);
  Timer timer;
  bool active = false;

  @override
  bool get wantKeepAlive => true;

  void onActive() {
    print('202104-27 onActive ScreenTradeSell fastMode : ' + widget._fastModeNotifier.value.toString());
    active = true;

    WidgetsBinding.instance.addPostFrameCallback((_){
      calculateNotifier.updateActive(active);

      // if(isFastMode()){
      //   recalculateNotifier.notifyListeners();
      // }else{
      //   calculateOrder();
      // }
    });
    if (timer != null && timer.isActive) {
      return;
    }
    if(isFastMode()){
      // tidak perlu actifin timer
      _stopTimer();
      return;
    }
    _startTimer();
  }

  void _startTimer() {
    print('ScreenTradeSell._startTimer');
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(durationUpdate, (timer) {
        if (active) {
          doUpdate();
        }
      });
    }
  }

  void _stopTimer() {
    print('ScreenTradeSell._startTimer');
    if (timer != null && timer.isActive) {
      timer.cancel();
    }
  }

  void onInactive() {
    active = false;
    calculateNotifier.updateActive(active);
    print('202104-27 onInactive ScreenTradeSell');
    _stopTimer();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    timer.cancel();
    calculateNotifier.dispose();
    valueOrderNotifier.dispose();
    fieldPriceController.dispose();
    fieldLotController.dispose();
    //recalculateNotifier.dispose();
    //valueOrderNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('ScreenTradeSell.initState');
    final container = ProviderContainer();
    container.read(primaryStockChangeNotifier).addListener(() {
      final container = ProviderContainer();
      Stock stock = container.read(primaryStockChangeNotifier).stock;
      OrderBook orderBook = container.read(orderBookChangeNotifier).orderbook;
      bool changed = stock == null || orderBook == null || StringUtils.equalsIgnoreCase(stock.code, orderBook.code);
      if(changed){
        if(isFastMode()){
          context.read(orderDataChangeNotifier).clearPriceLot();
        }else{
          // fieldPriceController.text = '';
          // fieldLotController.text = '';
        }


        doUpdate();
      }
    });

    widget._fastModeNotifier.addListener(() {
      calculateNotifier.updateMode(widget._fastModeNotifier.value);
      context.read(orderDataChangeNotifier).update(fastMode: isFastMode());
      if (widget._fastModeNotifier.value) {
        //recalculateNotifier.notifyListeners();
        _stopTimer();
      } else {
        //calculateOrder();
        _startTimer();
      }
      setState(() {});
    });
    widget._tabController.addListener(() {
      bool _active = widget._tabController.index == orderType.index;
      if (active) {
        if (_active) {
        } else {
          onInactive();
        }
      } else {
        if (_active) {
          onActive();
        } else {}
      }
    });
    fieldPriceController.addListener(calculateOrder);
    fieldLotController.addListener(calculateOrder);
    calculateNotifier.addListener(() {
      //if(calculateNotifier.canNormalModeCalculate(orderType)){
        calculateOrder();
      //}
    });
  }

  void calculateOrder() {
    // if(!active){
    //   print('calculateOrder SELL  aborted, caused screen active : $active');
    //   return;
    // }
    // if(isFastMode()){
    //   print('calculateOrder SELL  aborted, caused screen FastMode');
    //   return;
    // }
    String scrappedPrice = fieldPriceController.text.replaceAll(',', '');
    int price = Utils.safeInt(scrappedPrice);

    String scrappedLot = fieldLotController.text.replaceAll(',', '');
    int lot = Utils.safeInt(scrappedLot);

    int value = price * lot * 100;

    //String valueText = InvestrendTheme.formatComma(value);
    print('calculateOrder SELL  Price : ' + fieldPriceController.text + '   Lot : ' + fieldLotController.text + '  value : $value');
    //valueOrderNotifier.value = value;

    // widget._orderDataNotifier.value.orderType = 'trade_tabs_sell_title'.tr();
    // widget._orderDataNotifier.value.lot = lot;
    // widget._orderDataNotifier.value.price = price;
    // widget._orderDataNotifier.notifyListeners();
    valueOrderNotifier.value = value;
    //widget._orderDataNotifier.update(orderType: 'trade_tabs_sell_title'.tr(), lot: lot, price: price, value: value);
    bool notifyParent = calculateNotifier.canNormalModeCalculate(orderType);
    print('calculateOrder SELL notifyParent : $notifyParent  '+calculateNotifier.toString() );
    if(notifyParent){
      context.read(orderDataChangeNotifier).update(orderType: orderType, lot: lot, price: price, value: value);
    }
  }
  VoidCallback codeChangeListener;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ScreenTradeSell didChangeDependencies  fastMode : '+widget._fastModeNotifier.value.toString());
    //Stock stock = InvestrendTheme.of(context).stock;
    //Stock stock = InvestrendTheme.of(context).stockNotifier.value;
    if (widget._fastModeNotifier.value) {
      return;
    } else {
      _startTimer();
    }
    // if (timer == null || !timer.isActive) {
    //   timer = Timer.periodic(durationUpdate, (timer) {
    //     if (active) {
    //       doUpdate();
    //     }
    //   });
    // }
  }

  Future doUpdate() async {
    print('ScreenTradeSell.doUpdate : ' + DateTime.now().toString());
    if (!active) {
      return;
    }
    //Stock stock = InvestrendTheme.of(context).stockNotifier.value;
    Stock stock = context.read(primaryStockChangeNotifier).stock;

    if (stock == null || !stock.isValid()) {
      // stock = InvestrendTheme.storedData.listStock.isEmpty ? null : InvestrendTheme.storedData.listStock.first;
      // InvestrendTheme.of(context).stockNotifier.setStock(stock);
      //
      // context.read(primaryStockChangeNotifier).setStock(stock);

      Stock stockDefault = InvestrendTheme.storedData.listStock.isEmpty ? null : InvestrendTheme.storedData.listStock.first;
      //InvestrendTheme.of(context).stockNotifier.setStock(stock);
      context.read(primaryStockChangeNotifier).setStock(stockDefault);
      stock = context.read(primaryStockChangeNotifier).stock;
    }
    // widget._orderDataNotifier.value.stock_code = stock.code;
    // widget._orderDataNotifier.value.stock_name = stock.name;
    //widget._orderDataNotifier.notifyListeners();
    //widget._orderDataNotifier.update(stock_code: stock.code, stock_name: stock.name);

    //context.read(orderDataChangeNotifier).update(stock_code: stock.code,stock_name: stock.name);
    context.read(orderDataChangeNotifier).update(
        stock_code: stock.code,
        stock_name: stock.name,
        accountType: 'Reguler',
        accountName: 'Ackerman',
        orderType: orderType,
        tradingLimitUsage: 0,
        fastMode: isFastMode());

    context.read(stockSummaryChangeNotifier).setStock(stock);
    context.read(orderBookChangeNotifier).setStock(stock);
    context.read(tradeBookChangeNotifier).setStock(stock);
    /*
    StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
    bool stockChanged = stock != null && stock != _summaryNotifier.stock;
    if (stockChanged) {
      print('ScreenTradeSell.stockChanged : ' + stockChanged.toString());
      _summaryNotifier.setStock(stock);
      _summaryNotifier.setData(null);
    }

    OrderBookNotifier _orderbookNotifier = InvestrendTheme.of(context).orderbookNotifier;
    stockChanged = stock != null && stock != _orderbookNotifier.stock;
    if (stockChanged) {
      _orderbookNotifier.setStock(stock);
      _orderbookNotifier.setData(null);
    }

    TradeBookNotifier _tradebookNotifier = InvestrendTheme.of(context).tradebookNotifier;
    stockChanged = stock != null && stock != _tradebookNotifier.stock;
    if (stockChanged) {
      _tradebookNotifier.setStock(stock);
      _tradebookNotifier.setData(null);
    }
     */

    final stockSummary = await HttpSSI.fetchStockSummary(stock.code, stock.defaultBoard);
    if (stockSummary != null) {
      print('ScreenTradeSell Future Summary DATA : ' + stockSummary.toString());
      //_summaryNotifier.setData(stockSummary);
      context.read(stockSummaryChangeNotifier).setData(stockSummary);
    } else {
      print('ScreenTradeSell Future Summary NO DATA');
    }
    final orderbook = await HttpSSI.fetchOrderBook(stock.code, stock.defaultBoard);
    if (orderbook != null) {
      print('ScreenTradeSell Future Orderbook DATA : ' + orderbook.toString());
      //InvestrendTheme.of(context).orderbookNotifier.setData(orderbook);
      //orderbook.generateDataForUI(10,context: context);
      context.read(orderBookChangeNotifier).setData(orderbook);
    } else {
      print('ScreenTradeSell Future Orderbook NO DATA');
    }

    final tradebook = await HttpSSI.fetchTradeBook(stock.code, stock.defaultBoard);
    if (tradebook != null) {
      print('ScreenTradeSell Future Tradebook DATA : ' + tradebook.toString());
      //InvestrendTheme.of(context).tradebookNotifier.setData(tradebook);
      context.read(tradeBookChangeNotifier).setData(tradebook);
    } else {
      print('ScreenTradeSell Future Tradebook NO DATA');
    }
  }

  Widget _normalMode() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5.0,
          ),
          //createMoneyInfo(context),
          createStockInfo(context),
          createFormSell(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingPlusMargin,
                right: InvestrendTheme.cardPaddingPlusMargin,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitle(context, 'Order Book'),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingPlusMargin,
                right: InvestrendTheme.cardPaddingPlusMargin,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            //color: Colors.yellow,
            //child: WidgetOrderbook(InvestrendTheme.of(context).orderbookNotifier, 10),
            child: WidgetOrderbook(
              10,
              owner: 'ScreenTradeSell',
            ),
          ),
          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingPlusMargin,
                right: InvestrendTheme.cardPaddingPlusMargin,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitle(context, 'Transactions'),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingPlusMargin,
                right: InvestrendTheme.cardPaddingPlusMargin,
                top: InvestrendTheme.cardPadding,
                bottom: InvestrendTheme.cardPadding),
            //child: WidgetTradebook(InvestrendTheme.of(context).tradebookNotifier),
            child: WidgetTradebook(),
          ),
          SizedBox(
            height: 90.0,
          ),
        ],
      ),
    );
  }
  Future onRefresh() async{
    //context.read(orderDataChangeNotifier).update(stock_code: stock.code,stock_name: stock.name);
    // Stock stock = context
    //     .read(primaryStockChangeNotifier)
    //     .stock;
    // final orderbook = await HttpSSI.fetchOrderBook(stock.code, stock.defaultBoard);
    // if (orderbook != null) {
    //   print('ScreenTradeBuy Future Orderbook DATA : ' + orderbook.toString());
    //   //InvestrendTheme.of(context).orderbookNotifier.setData(orderbook);
    //   context.read(orderBookChangeNotifier).setData(orderbook);
    // } else {
    //   print('ScreenTradeBuy Future Orderbook NO DATA');
    // }
    // return orderbook;
    return 0;
    //return doUpdate(pullToRefresh: true);
  }
  Widget _fastMode() {
    return RefreshIndicator(
      onRefresh: doUpdate,
      child: ListView(
        shrinkWrap: true,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5.0,
          ),
          //createMoneyInfo(context),
          createStockInfo(context),
          ComponentCreator.divider(context),
          createFastSell(context),

          SizedBox(
            height: 90.0,
          ),
        ],
      ),
    );
    /*
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 5.0,
        ),
        //createMoneyInfo(context),
        createStockInfo(context),
        ComponentCreator.divider(context),
        createFastSell(context),

        SizedBox(
          height: 90.0,
        ),
      ],
    );
     */
  }

  bool isFastMode() {
    return widget._fastModeNotifier.value;
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(isFastMode()) != widget.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenAware(
      routeName: '/trade_sell',
      onActive: onActive,
      onInactive: onInactive,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 800),
        firstChild: _normalMode(),
        secondChild: _fastMode(),
        crossFadeState: widget._fastModeNotifier.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstCurve: Curves.easeOut,
        secondCurve: Curves.easeIn,
      ),
    );
  }

  Widget createFastSell(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Color(0xFFE0E0E0),
                  height: 2.0,
                  width: 60,
                ),
                Container(
                  color: InvestrendTheme.sellColor,
                  height: 2.0,
                  width: 60,
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            WidgetFastOrderBook(
              OrderType.Sell,
              10,
              owner: 'ScreenTradeSell',
              calculateNotifier: calculateNotifier,
            ),
          ],
        ));
  }

  Widget createFormSell(BuildContext context) {
    double iconSize = 20.0;

    return Container(
      margin: EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
      padding: EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
      //height: 225,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: InvestrendTheme.sellColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            //color: Colors.blue,
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            child: Table(
              columnWidths: {
                0: FractionColumnWidth(.5),
                1: FractionColumnWidth(.1),
                2: FractionColumnWidth(.3),
                3: FractionColumnWidth(.1),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Text('Tipe Order Jual', style: InvestrendTheme.of(context).small_w500.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(
                      width: 2,
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      child: Text(
                        'Normal',
                        style: InvestrendTheme.of(context).small_w400,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    IconButton(
                        icon: Image.asset(
                          'images/icons/arrow_down.png',
                          height: iconSize,
                          width: iconSize,
                        ),
                        onPressed: () {}),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Harga', style: InvestrendTheme.of(context).small_w500.copyWith(fontWeight: FontWeight.w700)),
                    IconButton(
                        icon: Image.asset(
                          'images/icons/minus.png',
                          height: iconSize,
                          width: iconSize,
                        ),
                        onPressed: () {}),
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      child: TextField(
                        controller: fieldPriceController,
                        inputFormatters: [
                          PriceFormatter(),
                        ],
                        maxLines: 1,
                        style: InvestrendTheme.of(context).regular_w700.copyWith(height: null),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 1.0)),
                          focusColor: Theme.of(context).accentColor,
                          prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                          hintStyle: InvestrendTheme.of(context).inputHintStyle,
                          helperStyle: InvestrendTheme.of(context).inputHelperStyle,
                          errorStyle: InvestrendTheme.of(context).inputErrorStyle,
                          fillColor: Colors.grey,
                          contentPadding: EdgeInsets.all(0.0),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    IconButton(
                        icon: Image.asset(
                          'images/icons/plus.png',
                          height: iconSize,
                          width: iconSize,
                        ),
                        onPressed: () {}),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Lot', style: InvestrendTheme.of(context).small_w500.copyWith(fontWeight: FontWeight.w700)),
                    IconButton(
                        icon: Image.asset(
                          'images/icons/minus.png',
                          height: iconSize,
                          width: iconSize,
                        ),
                        onPressed: () {}),
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      child: TextField(
                        controller: fieldLotController,
                        inputFormatters: [
                          PriceFormatter(),
                        ],
                        maxLines: 1,
                        style: InvestrendTheme.of(context).regular_w700.copyWith(height: null),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 1.0)),
                          focusColor: Theme.of(context).accentColor,
                          prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                          hintStyle: InvestrendTheme.of(context).inputHintStyle,
                          helperStyle: InvestrendTheme.of(context).inputHelperStyle,
                          errorStyle: InvestrendTheme.of(context).inputErrorStyle,
                          fillColor: Colors.grey,
                          contentPadding: EdgeInsets.all(0.0),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    IconButton(
                        icon: Image.asset(
                          'images/icons/plus.png',
                          height: iconSize,
                          width: iconSize,
                        ),
                        onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '25%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '50%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '75%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    child: Text(
                      '100%',
                      style: InvestrendTheme.of(context).support_w400,
                    )),
              ],
            ),
          ),
          ComponentCreator.divider(context),
          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            child: Row(
              children: [
                Text(
                  'Total',
                  style: InvestrendTheme.of(context).small_w700,
                ),
                Expanded(
                  flex: 1,
                  child: ValueListenableBuilder(
                    valueListenable: valueOrderNotifier,
                    builder: (context, int value, child) {
                      String totalValueText = InvestrendTheme.formatMoney(value, prefixRp: true);
                      return Text(
                        totalValueText,
                        style: InvestrendTheme.of(context).regular_w700,
                        textAlign: TextAlign.end,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: InvestrendTheme.cardMargin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createStockInfo(BuildContext context) {
    int jumlahLot = 2500;
    double averagePrice = 1000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        columnWidths: {0: FractionColumnWidth(.3)},
        children: [
          TableRow(children: [
            Text(
              'trade_sell_label_total_lot'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
            Text(
              'trade_sell_label_average_price'.tr(),
              style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
          ]),
          TableRow(children: [
            Text(
                InvestrendTheme.formatComma(
                  jumlahLot,
                ),
                style: InvestrendTheme.of(context).regular_w700),
            Text(
              InvestrendTheme.formatMoneyDouble(
                averagePrice,
                prefixRp: true,
              ),
              style: InvestrendTheme.of(context).regular_w700,
              //textAlign: TextAlign.end,
            ),
          ])
        ],
      ),
    );
  }

   */

}
