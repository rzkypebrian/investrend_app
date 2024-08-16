// ignore_for_file: unused_local_variable, unused_field, unnecessary_null_comparison, must_call_super, non_constant_identifier_names

import 'dart:async';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/cards/card_orderbook.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/fast_orderbook.dart';
import 'package:Investrend/component/widget_tradebook.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/screen_aware.dart';
import 'package:Investrend/screens/stock_detail/screen_order_queue.dart';
import 'package:Investrend/screens/tab_portfolio/component/bottom_sheet_list.dart';
import 'package:Investrend/screens/trade/component/percent_button.dart';
import 'package:Investrend/screens/trade/trade_component.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

abstract class BaseTradeState<T extends StatefulWidget>
    extends VisibilityAwareState
    with AutomaticKeepAliveClientMixin<StatefulWidget> {
  final OrderType orderType;
  final ValueNotifier<bool> fastModeNotifier;
  final OrderbookNotifier orderbookNotifier;
  final TabController tabController;
  final ValueNotifier<bool> updateDataNotifier;
  final bool onlyFastOrder;
  final PriceLot? initialPriceLot;
  final ValueNotifier<bool>? keyboardNotifier;
  BaseTradeState(this.orderType, this.fastModeNotifier, this.tabController,
      this.orderbookNotifier, this.updateDataNotifier, this.onlyFastOrder,
      {this.initialPriceLot, this.keyboardNotifier});

  Key _fastKey = UniqueKey();
  Key _normalKey = UniqueKey();
  bool _active = false;
  Timer? _timer;
  Timer? _timerAccount;
  FocusNode? focusNodePrice;
  FocusNode? focusNodeLot;
  FocusNode? focusNodeSplitLoop;
  FastOrderbook? _fastOrderbook;
  final fieldPriceController = TextEditingController();
  final fieldLotController = TextEditingController();
  final fieldSplitLoopController = TextEditingController();
  final ValueNotifier<int> valueOrderNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> predefineLotNotifier = ValueNotifier<int>(0);
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollControllerFast = ScrollController();
  //OrderbookNotifier _orderbookNotifier = OrderbookNotifier(OrderbookData());

  //OrderbookNotifier _orderbookNotifier = OrderbookNotifier(OrderbookData());

  ValueNotifier<double>? animatePaddingNotifier;
  //Key fastKey = UniqueKey();
  Key? fastKey;
  static const Duration _durationUpdate = Duration(milliseconds: 2000);
  static const Duration _durationUpdateAccount = Duration(milliseconds: 5000);

  final ValueNotifier _orderTypeNotifier = ValueNotifier<int>(0);
  //final ValueNotifier<double> rdnBalanceNotifier = ValueNotifier<double>(0);
  // static const Duration _durationUpdate = Duration(seconds: 60);

  final ValueNotifier<String> predefineLotSourceNotifier =
      ValueNotifier<String>('cash_available_label'.tr());
  VoidCallback? resetPredefineLot;
  List<String> _order_options = [
    'Normal',
    'Loop',
    'Split',
  ];

  ValueNotifier<bool> acceptRemoveNotifier = ValueNotifier<bool>(false);

  void onVisibilityChanged(WidgetVisibility visibility) {
    switch (visibility) {
      case WidgetVisibility.VISIBLE:
        // Like Android's Activity.onResume()
        print('*** ScreenVisibility.VISIBLE: ${orderType.routeName}');
        onActive(caller: 'onVisibilityChanged.VISIBLE');
        break;
      case WidgetVisibility.INVISIBLE:
        // Like Android's Activity.onPause()
        print('*** ScreenVisibility.INVISIBLE: ${orderType.routeName}');
        onInactive(caller: 'onVisibilityChanged.INVISIBLE');
        break;
      case WidgetVisibility.GONE:
        // Like Android's Activity.onDestroy()
        print(
            '*** ScreenVisibility.GONE: ${orderType.routeName}   mounted : $mounted');
        // if(mounted)
        // onInactive(caller: 'onVisibilityChanged.GONE');
        break;
    }

    super.onVisibilityChanged(visibility);
  }

  SubscribeAndHGET? subscribeSummary;
  SubscribeAndHGET? subscribeOrderbook;
  SubscribeAndHGET? subscribeTradebook;
  void unsubscribe(BuildContext context, String caller) {
    if (subscribeSummary != null) {
      print(orderType.routeName +
          ' unsubscribe Summary : ' +
          subscribeSummary!.channel!);
      context
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeSummary!, orderType.routeName + '.' + caller);
      subscribeSummary = null;
    }

    if (subscribeOrderbook != null) {
      print(orderType.routeName +
          ' unsubscribe Orderbook : ' +
          subscribeOrderbook!.channel!);
      context
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeOrderbook!, orderType.routeName + '.' + caller);
      subscribeOrderbook = null;
    }

    if (subscribeTradebook != null) {
      print(orderType.routeName +
          ' unsubscribe Tradebook : ' +
          subscribeTradebook!.channel!);
      context
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeTradebook!, orderType.routeName + '.' + caller);
      subscribeTradebook = null;
    }
  }

  void subscribe(BuildContext context, Stock? stock, String caller) {
    String codeBoard = stock!.code! + '.' + stock.defaultBoard;

    String channelSummary = DatafeedType.Summary.key + '.' + codeBoard;
    context.read(stockSummaryChangeNotifier).setStock(stock);
    subscribeSummary = SubscribeAndHGET(
        channelSummary, DatafeedType.Summary.collection, codeBoard,
        listener: (message) {
      print(channelSummary + ' got : ' + message.elementAt(1));
      print(message);
      if (mounted) {
        StockSummary? stockSummary = StockSummary.fromStreaming(message);
        FundamentalCache? cache =
            context.read(fundamentalCacheNotifier).getCache(stockSummary.code);
        stockSummary.updateCache(context, cache);
        context
            .read(stockSummaryChangeNotifier)
            .setData(stockSummary, check: true);
      }
      return '';
    }, validator: validatorSummary);
    print(orderType.routeName + ' subscribe Summary : $codeBoard');
    context
        .read(managerDatafeedNotifier)
        .subscribe(subscribeSummary!, orderType.routeName + '.' + caller);

    String channelOrderbook = DatafeedType.Orderbook.key + '.' + codeBoard;
    context.read(orderBookChangeNotifier).setStock(stock);
    subscribeOrderbook = SubscribeAndHGET(
        channelOrderbook, DatafeedType.Orderbook.collection, codeBoard,
        listener: (message) {
      print(orderType.routeName + ' got : ' + message.elementAt(1));
      print(message);

      OrderBook orderbook = OrderBook.fromStreaming(message);
      if (mounted) {
        DebugWriter.info('got orderbook --> ' + orderbook.toString());
        orderbook.generateDataForUI(10, context: context);

        context.read(orderBookChangeNotifier).setData(orderbook);
        StockSummary? stockSummary =
            context.read(stockSummaryChangeNotifier).summary;
        OrderbookData orderbookData = OrderbookData();
        orderbookData.orderbook = orderbook;
        orderbookData.prev = stockSummary != null ? stockSummary.prev : 0;
        orderbookData.close = stockSummary != null ? stockSummary.close : 0;
        orderbookData.averagePrice =
            stockSummary != null ? stockSummary.averagePrice : 0;
        orderbookNotifier.setValue(orderbookData);
        print('got orderbook --> notify');
      }
      return '';
    }, validator: validatorOrderbook);
    print(orderType.routeName + ' subscribe Orderbook : $codeBoard');
    context
        .read(managerDatafeedNotifier)
        .subscribe(subscribeOrderbook, orderType.routeName + '.' + caller);

    String channelTradebook = DatafeedType.Tradebook.key + '.' + codeBoard;
    context.read(tradeBookChangeNotifier).setStock(stock);
    subscribeTradebook = SubscribeAndHGET(
        channelTradebook, DatafeedType.Tradebook.collection, codeBoard,
        listener: (message) {
      print(orderType.routeName + ' got : ' + message.elementAt(1));
      print(message);

      TradeBook tradebook = TradeBook.fromStreaming(message);
      if (mounted) {
        DebugWriter.info('got tradebook --> ' + tradebook.toString());
        // orderbook.generateDataForUI(10, context: context);
        //
        // context.read(orderBookChangeNotifier).setData(orderbook);
        // StockSummary stockSummary = context.read(stockSummaryChangeNotifier).summary;
        // OrderbookData orderbookData = OrderbookData();
        // orderbookData.orderbook = orderbook;
        // orderbookData.prev = stockSummary != null ? stockSummary.prev : 0;
        // orderbookData.close = stockSummary != null ? stockSummary.close : 0;
        // orderbookNotifier.setValue(orderbookData);
        context.read(tradeBookChangeNotifier).setData(tradebook);
        print('got tradebook --> notify');
      }
      return '';
    }, validator: validatorTradebook);
    print(orderType.routeName + ' subscribe Tradebook : $codeBoard');
    context
        .read(managerDatafeedNotifier)
        .subscribe(subscribeTradebook, orderType.routeName + '.' + caller);
  }

  bool validatorOrderbook(List<String>? data, String channel) {
    //List<String> data = message.split('|');
    if (data != null &&
        data.length >
            5 /* && data.first == 'III' && data.elementAt(1) == 'Q'*/) {
      final String HEADER = data[0];
      final String type = data[1];
      final String start = data[2];
      final String end = data[3];
      final String stockCode = data[4];
      final String boardCode = data[5];

      String codeBoard = stockCode + '.' + boardCode;
      String channelData = DatafeedType.Orderbook.key + '.' + codeBoard;
      if (HEADER == 'III' &&
          type == DatafeedType.Orderbook.type &&
          channel == channelData) {
        return true;
      }
    }
    return false;
  }

  bool validatorTradebook(List<String>? data, String channel) {
    //List<String> data = message.split('|');
    if (data != null &&
        data.length >
            5 /* && data.first == 'III' && data.elementAt(1) == 'Q'*/) {
      final String HEADER = data[0];
      final String type = data[1];
      final String start = data[2];
      final String end = data[3];
      final String stockCode = data[4];
      final String boardCode = data[5];

      String codeBoard = stockCode + '.' + boardCode;
      String channelData = DatafeedType.Tradebook.key + '.' + codeBoard;
      if (HEADER == 'III' &&
          type == DatafeedType.Tradebook.type &&
          channel == channelData) {
        return true;
      }
    }
    return false;
  }

  bool validatorSummary(List<String>? data, String channel) {
    //List<String> data = message.split('|');
    if (data != null &&
        data.length >
            5 /* && data.first == 'III' && data.elementAt(1) == 'Q'*/) {
      final String HEADER = data[0];
      final String typeSummary = data[1];
      final String start = data[2];
      final String end = data[3];
      final String stockCode = data[4];
      final String boardCode = data[5];
      String codeBoard = stockCode + '.' + boardCode;
      String channelData = DatafeedType.Summary.key + '.' + codeBoard;
      if (HEADER == 'III' &&
          typeSummary == DatafeedType.Summary.type &&
          channel == channelData) {
        return true;
      }
    }
    return false;
  }

  @override
  bool get wantKeepAlive => true;

  void onActive({String caller = ''}) {
    if (!isCurrentTab()) {
      print(orderType.routeName +
          '.onActive [aborted] _active : $_active  caller : $caller --> caused by not not on current Tab.');
      return;
    }
    _active = true;
    //final container = ProviderContainer();
    //container.read(pageChangeNotifier).onActive(orderType.routeName);
    print(
        orderType.routeName + '.onActive _active : $_active  caller : $caller');
    //_startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read(buySellChangeNotifier).mustNotifyListener();
        context.read(pageChangeNotifier).onActive(orderType.routeName);

        doUpdate(pullToRefresh: true);
        doUpdateAccount(pullToRefresh: true);
        _startTimer();

        unsubscribe(context, 'onActive');
        Stock? stock = context.read(primaryStockChangeNotifier).stock;
        subscribe(context, stock, 'onActive');
      }

      // if(paddingHeight > 1){
      //   paddingHeight = 1;
      //   setState(() {
      //
      //   });
      // }
    });
  }

  void onInactive({String caller = ''}) {
    _active = false;
    //final container = ProviderContainer();
    context.read(pageChangeNotifier).onInactive(orderType.routeName);

    print(orderType.routeName +
        '.onInactive _active : $_active  caller : $caller');
    _stopTimer();

    unsubscribe(context, 'onInactive');
  }
  //VoidCallback _pageListener;

  double offsetScroll = 0.0;
  VoidCallback? keyboardEvent() {
    print(orderType.routeName +
        ' keyboardEvent  mounted : $mounted  keyboardNotifier : ' +
        (keyboardNotifier != null ? 'listening' : 'null'));
    if (mounted && keyboardNotifier != null) {
      print(orderType.routeName +
          ' keyboardEvent  show : ' +
          keyboardNotifier!.value.toString() +
          '  scrollController.offset : ' +
          scrollController.offset.toString() +
          '  scrollControllerFast.offset : ' +
          scrollControllerFast.offset.toString());
      if (keyboardNotifier!.value) {
        offsetScroll = scrollControllerFast.offset;

        Future.delayed(Duration(milliseconds: 1000), () {
          if (isFastMode()) {
            print(orderType.routeName +
                ' keyboardEvent  show : ' +
                keyboardNotifier!.value.toString() +
                '  offsetScroll : ' +
                offsetScroll.toString() +
                '  scrollControllerFast.offset : ' +
                scrollControllerFast.offset.toString());
            if (offsetScroll != scrollControllerFast.offset) {
              scrollControllerFast.animateTo(scrollControllerFast.offset + 40,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic);
            }
          } else {
            //scrollController.animateTo(scrollController.offset + 90, duration: Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
          }
        });
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    resetPredefineLot = () {
      print('resetPredefineLot on text : ' + fieldLotController.text);
      if (predefineLotNotifier.value != 0) {
        predefineLotNotifier.value = 0;
      }
    };

    print('initialPriceLot --> ' +
        (initialPriceLot != null ? initialPriceLot.toString() : 'NONE'));

    if (keyboardNotifier != null) {
      keyboardNotifier?.addListener(keyboardEvent);
    }

    scrollControllerFast.addListener(() {
      print('keyboardEvent scrollControllerFast : ' +
          scrollControllerFast.offset.toString() +
          ' ' +
          scrollControllerFast.position.pixels.toString());
    });

    scrollController.addListener(() {
      print('keyboardEvent scrollController : ' +
          scrollController.offset.toString() +
          ' ' +
          scrollController.position.pixels.toString());
    });
    fastKey = Key(orderType.routeName + '_FAST');
    fieldLotController.addListener(resetPredefineLot!);
    fieldLotController.addListener(calculateOrder);

    fieldPriceController.addListener(calculateOrder);

    fieldSplitLoopController.addListener(calculateOrder);
    print(orderType.routeName + '.initState');

    focusNodePrice = FocusNode();
    focusNodeLot = FocusNode();
    focusNodeSplitLoop = FocusNode();

    Timer(new Duration(milliseconds: 300), () {
      //paddingHeight = 1;
      if (initialPriceLot != null) {
        if (initialPriceLot!.price > 0) {
          fieldPriceController.text =
              InvestrendTheme.formatComma(initialPriceLot?.price);
        }
        if (initialPriceLot!.lot > 0) {
          fieldLotController.text =
              InvestrendTheme.formatComma(initialPriceLot?.lot);
        }
      }
      setState(() {});
    });
    predefineLotSourceNotifier.addListener(() {
      print(orderType.routeName +
          '.predefineLotSourceNotifier changed ' +
          predefineLotSourceNotifier.value.toString());
      if (predefineLotNotifier.value != 0) {
        fieldLotController.text = '';
      }
      //resetPredefineLot();
    });

    _orderTypeNotifier.addListener(() {
      print(orderType.routeName +
          '._orderTypeNotifier changed ' +
          _orderTypeNotifier.value.toString());
      calculateOrder(caller: '_orderTypeNotifier');
    });

    updateDataNotifier.addListener(() {
      print(orderType.routeName +
          '.updateDataNotifier triggered --> mounted : $mounted');
      if (mounted) {
        calculateOrder(caller: 'updateDataNotifier');
      }
    });
    // final container = ProviderContainer();
    // container.read(primaryStockChangeNotifier).addListener(stockChangeListener);

    tabController.addListener(() {
      bool isActive = tabController.index == orderType.index;

      print(orderType.routeName +
          '.tabController changed : ' +
          tabController.index.toString() +
          "  is_active : $isActive   _active : $_active");
      if (_active) {
        if (isActive) {
        } else {
          onInactive();
        }
      } else {
        if (isActive) {
          onActive();
        } else {}
      }
    });

    fastModeNotifier.addListener(() {
      //calculateNotifier.updateMode(fastModeNotifier.value);
      //context.read(orderDataChangeNotifier).update(fastMode: isFastMode());
      print(orderType.routeName +
          '.fastModeNotifier  _active ' +
          _active.toString() +
          '  fastMode : ' +
          isFastMode().toString());
      context.read(buySellChangeNotifier).setFastMode(isFastMode());
      context.read(buySellChangeNotifier).mustNotifyListener();

      // Future.delayed(Duration(milliseconds: 700),(){
      //   context.read(buySellChangeNotifier).setFastMode(isFastMode());
      //   context.read(buySellChangeNotifier).mustNotifyListener();
      // });

      // if (isFastMode()) {
      //   _stopTimer();
      // } else {
      //   _startTimer();
      // }
      setState(() {});
    });
    _startTimer();

    _fastOrderbook = FastOrderbook(
      orderbookNotifier,
      orderType,
      10,
      owner: orderType.routeName,
      key: fastKey,
      //calculateNotifier: null,
    );

    // double height = MediaQuery.of(context).size.height;
    // double paddingHeight = height * 0.5;
    // animatePaddingNotifier = ValueNotifier<double>(paddingHeight);
    //
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if (animatePaddingNotifier.value > 1.0) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       animatePaddingNotifier.value = 1.0;
    //     });
    //   }
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //bool keyboardShowed = MediaQuery.of(context).viewInsets.bottom > 0;
    print(orderType.routeName +
        '.didChangeDependencies  _active ' +
        _active.toString() +
        '  fastMode : ' +
        isFastMode().toString());
    //Stock stock = InvestrendTheme.of(context).stock;

    /* ASLI 2021-10-13
    double height = MediaQuery.of(context).size.height;
    double paddingHeight = height * 0.5;
    animatePaddingNotifier = ValueNotifier<double>(paddingHeight);
    */

    Stock? stock = context.read(primaryStockChangeNotifier).stock;
    if (stockChangeListener != null) {
      context
          .read(primaryStockChangeNotifier)
          .removeListener(stockChangeListener!);
      stockChangeListener = null;
    }
    /*
    if(_pageListener != null){
      context.read(pageChangeNotifier).removeListener(_pageListener);
    }

    _pageListener = (){
      //final container = ProviderContainer();
      if(!mounted){
        print(orderType.routeName+' _pageListener ignored, mounted : $mounted');
        return;
      }
      bool isCurrentActive = context.read(pageChangeNotifier).isCurrentActive(orderType.routeName);
      print(orderType.routeName+' _pageListener executed, mounted : $mounted  isCurrentActive : $isCurrentActive');
      if(isCurrentActive){
        if(!_active){
          onActive(caller: '_pageListener');
        }
      }else{
        if(_active){
          onInactive(caller: '_pageListener');
        }
      }
    };
    //final container = ProviderContainer();
    context.read(pageChangeNotifier).addListener(_pageListener);
    */
    // load froms existing
    // OrderBook currentOrderbook = context.read(orderBookChangeNotifier).orderbook;
    // if(currentOrderbook != null
    //     && (currentOrderbook.countBids() > 0 || currentOrderbook.countOffers() > 0)
    //     && StringUtils.equalsIgnoreCase(currentOrderbook.code, stock.code) ){
    //   OrderbookData orderbookData = OrderbookData();
    //   orderbookData.orderbook = context.read(orderBookChangeNotifier).orderbook;
    //   orderbookData.prev = context.read(stockSummaryChangeNotifier).summary?.prev;
    //   _orderbookNotifier.setValue(orderbookData);
    // }

    // if (stockChangeListener == null) {
    stockChangeListener = () {
      if (!mounted) {
        print(orderType.routeName +
            '.stockChangeListener aborted, caused by widget mounted : ' +
            mounted.toString());
        return;
      }

      print(orderType.routeName + '.stockChangeListener ' + mounted.toString());

      //final container = ProviderContainer();
      Stock? stock = context.read(primaryStockChangeNotifier).stock;
      BuySell data = context.read(buySellChangeNotifier).getData(orderType);
      //String existingCode = context.read(buySellChangeNotifier).getData(orderType).stock_code;
      bool isChanged =
          !StringUtils.equalsIgnoreCase(stock?.code, data.stock_code);
      print(orderType.routeName +
          '.stockChangeListener newCode : ' +
          stock!.code! +
          '  existingCode : ' +
          data.stock_code! +
          '  isChanged : $isChanged');

      //context.read(buySellChangeNotifier).setStock(stock.code, stock.name);
      data.setStock(stock.code, stock.name);
      if (isChanged) {
        fieldPriceController.text = '';
        fieldLotController.text = '';
        fieldSplitLoopController.text = '';
        _orderTypeNotifier.value = 0;
        context.read(buySellChangeNotifier).mustNotifyListener();
        context.read(sellLotAvgChangeNotifier).update(0, 0);

        orderbookNotifier.setValue(null);

        //_orderbookNotifier.setValue(null);
      }

      unsubscribe(context, 'onStockChanged');
      //Stock stock = context.read(primaryStockChangeNotifier).stock;
      subscribe(context, stock, 'onStockChanged');

      //bool isChanged = !StringUtils.equalsIgnoreCase(context.read(primaryStockChangeNotifier).stock.code, _orderbookNotifier.value.orderbook.code);
      //if(isChanged){
      //_orderbookNotifier.setValue(null);
      //}
      if (_active) {
        doUpdate();
        doUpdateAccount();
      }
    };
    // }

    if (clearChangeListener != null) {
      context
          .read(clearOrderChangeNotifier)
          .removeListener(clearChangeListener!);
      clearChangeListener = null;
    }
    // if (clearChangeListener == null) {
    clearChangeListener = () {
      if (!mounted) {
        print(orderType.routeName +
            '.clearChangeListener aborted, caused by widget mounted : ' +
            mounted.toString());
        return;
      }
      BuySell data = context.read(buySellChangeNotifier).getData(orderType);
      data.clearOrderOnly();
      fieldPriceController.text = '';
      fieldLotController.text = '';
      fieldSplitLoopController.text = '';
      _orderTypeNotifier.value = 0;
      context.read(buySellChangeNotifier).mustNotifyListener();
    };
    // }

    context.read(primaryStockChangeNotifier).addListener(stockChangeListener!);
    context.read(clearOrderChangeNotifier).addListener(clearChangeListener!);
    context
        .read(buySellChangeNotifier)
        .getData(orderType)
        .setStock(stock?.code, stock?.name);

    // if (widget._fastModeNotifier.value) {
    //
    //   return;
    // } else {
    //   _startTimer();
    // }

    if (animatePaddingNotifier == null) {
      double height = MediaQuery.of(context).size.height;
      double paddingHeight = height * 0.5;
      animatePaddingNotifier = ValueNotifier<double>(paddingHeight);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (animatePaddingNotifier!.value > 1.0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            animatePaddingNotifier!.value = 1.0;
          });
        }
      });
    }
  }

  VoidCallback? stockChangeListener;
  VoidCallback? clearChangeListener;

  @override
  void dispose() {
    print(orderType.routeName + '.dispose');
    if (keyboardNotifier != null) {
      keyboardNotifier?.removeListener(keyboardEvent);
    }
    final container = ProviderContainer();
    container
        .read(primaryStockChangeNotifier)
        .removeListener(stockChangeListener!);
    container
        .read(clearOrderChangeNotifier)
        .removeListener(clearChangeListener!);
    /*
    if(_pageListener!=null){
      //final container = ProviderContainer();
      container.read(pageChangeNotifier).removeListener(_pageListener);
    }

     */
    if (subscribeSummary != null) {
      container
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeSummary, 'dispose');
    }
    if (subscribeOrderbook != null) {
      container
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeOrderbook, 'dispose');
    }
    if (subscribeTradebook != null) {
      container
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeTradebook, 'dispose');
    }

    _timer?.cancel();
    _timerAccount?.cancel();
    //_stopTimer();
    //calculateNotifier.dispose();
    focusNodeLot?.dispose();
    focusNodePrice?.dispose();
    predefineLotNotifier.dispose();
    valueOrderNotifier.dispose();
    fieldPriceController.dispose();
    fieldLotController.dispose();
    scrollController.dispose();
    scrollControllerFast.dispose();
    animatePaddingNotifier?.dispose();
    _orderTypeNotifier.dispose();
    focusNodeSplitLoop?.dispose();
    predefineLotSourceNotifier.dispose();
    //_orderbookNotifier.dispose();

    super.dispose();
  }

  void _startTimer() {
    if (!InvestrendTheme.DEBUG) {
      if (_timer == null || !_timer!.isActive) {
        print(orderType.routeName + '._startTimer _timer');
        _timer = Timer.periodic(_durationUpdate, (timer) {
          print(orderType.routeName +
              ' _timer.tick : ' +
              _timer!.tick.toString());
          if (_active) {
            if (onProgress) {
              print(orderType.routeName +
                  ' timer aborted caused by onProgress : $onProgress');
            } else {
              doUpdate();
            }
          }
        });
      }

      if (_timerAccount == null || !_timerAccount!.isActive) {
        print(orderType.routeName + '._startTimer _timerAccount');
        _timerAccount = Timer.periodic(_durationUpdateAccount, (timer) {
          print(orderType.routeName +
              ' _timerAccount.tick : ' +
              _timerAccount!.tick.toString());
          if (_active) {
            if (onProgressAccount) {
              print(orderType.routeName +
                  ' timer aborted caused by onProgressAccount : $onProgressAccount');
            } else {
              doUpdateAccount();
            }
          }
        });
      }
    }
  }

  void _stopTimer() {
    print(orderType.routeName + '._stopTimer _timer');
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }

    print(orderType.routeName + '._stopTimer _timerAccount');
    if (_timerAccount != null && _timerAccount!.isActive) {
      _timerAccount?.cancel();
    }
  }

  bool onProgressAccount = false;
  Future doUpdateAccount({bool pullToRefresh = false}) async {
    onProgressAccount = false;
    return true;
  }
  /*
  Future doUpdateAccount({bool pullToRefresh = false}) async {
    if (!_active || !mounted) {
      print(orderType.routeName + '.doUpdateAccount Aborted : ' + DateTime.now().toString() + "  _active : $_active  mounted : $mounted pullToRefresh : $pullToRefresh");
      return false;
    }
    print(orderType.routeName + '.doUpdateAccount : ' + DateTime.now().toString() + "  _active : $_active  mounted : $mounted  pullToRefresh : $pullToRefresh");
    onProgressAccount = true;

    Stock stock = context.read(primaryStockChangeNotifier).stock;
    int selected = context.read(accountChangeNotifier).index;
    //Account account = InvestrendTheme.of(context).user.getAccount(selected);
    Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
      String text = 'No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      InvestrendTheme.of(context).showSnackBar(context, text);
      onProgressAccount = false;
      return false;
    } else {

      try {
        print(orderType.routeName+' try stockPosition');
        final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
            account.brokercode,
            account.accountcode,
            //InvestrendTheme.of(context).user.username,
            context.read(dataHolderChangeNotifier).user.username,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        DebugWriter.info(orderType.routeName+' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
        if(!mounted){
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
        DebugWriter.info(orderType.routeName+' stockPosition Exception : ' + e.toString());
        if(!mounted){
          onProgressAccount = false;
          return false;
        }
        if(e is TradingHttpException){
          if(e.isUnauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            onProgressAccount = false;
            return false;
          }else if(e.isErrorTrading()){
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            onProgressAccount = false;
            return false;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            onProgressAccount = false;
            return false;
          }
        }else{
          InvestrendTheme.of(context).showSnackBar(context, e.toString());
        }
      }

      List<String> listAccountCode = List.empty(growable: true);
      // InvestrendTheme.of(context).user.accounts.forEach((account) {
      //   listAccountCode.add(account.accountcode);
      // });
      context.read(dataHolderChangeNotifier).user.accounts.forEach((account) {
        listAccountCode.add(account.accountcode);
      });

      print(orderType.routeName+' try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp.accountStockPosition('' /*account.brokercode*/, listAccountCode, context.read(dataHolderChangeNotifier).user.username, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((value) {
        DebugWriter.info(orderType.routeName+' Got accountStockPosition  accountStockPosition.size : ' + value.length.toString());
        if(!mounted){
          print(orderType.routeName+' accountStockPosition ignored.  mounted : $mounted');
          onProgressAccount = false;
          return false;
        }
        AccountStockPosition first = (value != null && value.length > 0) ?  value.first : null;
        if(first != null && first.ignoreThis()){
          // ignore in aja
          print(orderType.routeName+' accountStockPosition ignored.  message : '+first.message);
        }else {
          context.read(accountsInfosNotifier).updateList(value);
          Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
          if(activeAccount != null){
            AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
            if(accountInfo != null){
              //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.rdnBalance);
              context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.cashBalance);
            }
          }
        }

      }).onError((e, stackTrace) {
        DebugWriter.info(orderType.routeName+' accountStockPosition Exception : ' + e.toString());
        if(!mounted){
          onProgressAccount = false;
          return false;
        }
        if(e is TradingHttpException){
          if(e.isUnauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            onProgressAccount = false;
            return false;
          }else if(e.isErrorTrading()){
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            onProgressAccount = false;
            return false;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            onProgressAccount = false;
            return false;
          }
        }else{
          InvestrendTheme.of(context).showSnackBar(context, e.toString());
        }

      });


    }

  }
  */

  bool isActiveAndMounted() {
    return _active && mounted;
  }

  bool get active => _active;
  bool onProgress = false;
  Future doUpdate({bool pullToRefresh = false}) async {
    if (!_active || !mounted) {
      print(orderType.routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  _active : $_active  mounted : $mounted pullToRefresh : $pullToRefresh");
      return false;
    }
    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if (!isForeground) {
        print(orderType.routeName +
            ' doUpdate ignored isForeground : $isForeground  isVisible : ' +
            isVisible().toString());
        return false;
      }
    }
    print(orderType.routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  _active : $_active  mounted : $mounted  pullToRefresh : $pullToRefresh");

    onProgress = true;
    Stock? stock = context.read(primaryStockChangeNotifier).stock;

    if (stock == null || !stock.isValid()) {
      Stock? stockDefault = InvestrendTheme.storedData!.listStock!.isEmpty
          ? null
          : InvestrendTheme.storedData?.listStock?.first;
      context.read(primaryStockChangeNotifier).setStock(stockDefault);
      stock = context.read(primaryStockChangeNotifier).stock;
    }
    print('doUpdate : ' + stock!.code!);

    //context.read(stockSummaryChangeNotifier).setStock(stock);
    //context.read(orderBookChangeNotifier).setStock(stock);
    //context.read(tradeBookChangeNotifier).setStock(stock);

    if (!mounted) {
      onProgress = false;
      return false;
    }
    /*
    try {
      print('try Summary');
      final stockSummary = await HttpSSI.fetchStockSummary(stock.code, stock.defaultBoard);
      if(!mounted){
        onProgress = false;
        return false;
      }
      if (stockSummary != null) {
        print(orderType.routeName + ' Future Summary DATA : ' + stockSummary.code + '  prev : ' + stockSummary.prev.toString());
        //_summaryNotifier.setData(stockSummary);
        context.read(stockSummaryChangeNotifier).setData(stockSummary);
      } else {
        print(orderType.routeName + ' Future Summary NO DATA');
      }
    } catch (e) {
      DebugWriter.info('Summary Exception : ' + e.toString());
    }

    try {
      print('try Orderbook');
      final orderbook = await HttpSSI.fetchOrderBook(stock.code, stock.defaultBoard);
      if(!mounted){
        onProgress = false;
        return false;
      }
      if (orderbook != null) {
        print(orderType.routeName + ' Future Orderbook DATA : ' + orderbook.code);
        //InvestrendTheme.of(context).orderbookNotifier.setData(orderbook);
        context.read(orderBookChangeNotifier).setData(orderbook);
        //orderbook.generateDataForUI(10);
        OrderbookData orderbookData = OrderbookData();
        orderbookData.orderbook = orderbook;
        orderbookData.prev = context.read(stockSummaryChangeNotifier).summary != null ? context.read(stockSummaryChangeNotifier).summary.prev : 0;
        orderbookData.close = context.read(stockSummaryChangeNotifier).summary != null ? context.read(stockSummaryChangeNotifier).summary.close : 0;
        orderbookNotifier.setValue(orderbookData);
      } else {
        print(orderType.routeName + ' Future Orderbook NO DATA');
      }
    } catch (e) {
      DebugWriter.info('Orderbook Exception : ' + e.toString());
    }

    try {
      print('try Tradebook');
      final tradebook = await HttpSSI.fetchTradeBook(stock.code, stock.defaultBoard);
      if(!mounted){
        onProgress = false;
        return false;
      }
      if (tradebook != null) {
        print(orderType.routeName + ' Future Tradebook DATA : ' + tradebook.code);
        //InvestrendTheme.of(context).tradebookNotifier.setData(tradebook);
        context.read(tradeBookChangeNotifier).setData(tradebook);
      } else {
        print(orderType.routeName + ' Future Tradebook NO DATA');
      }
    } catch (e) {
      DebugWriter.info('Tradebook Exception : ' + e.toString());
    }
  */
    int selected = context.read(accountChangeNotifier).index;
    //Account account = InvestrendTheme.of(context).user.getAccount(selected);
    Account? account =
        context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
      //String text = 'No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      String errorNoAccount = 'error_no_account_selected'.tr();
      String text = '$errorNoAccount. accountSize : ' +
          context.read(dataHolderChangeNotifier).user.accountSize().toString();
      InvestrendTheme.of(context).showSnackBar(context, text);
      onProgress = false;
      return false;
    } else {
      try {
        print('try openOrder');
        final openOrder = await InvestrendTheme.tradingHttp.openOrder(
            account.brokercode,
            account.accountcode,
            //InvestrendTheme.of(context).user.username,
            context.read(dataHolderChangeNotifier).user.username,
            stock.code,
            orderType.shortSymbol,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        DebugWriter.information(
            'Got openOrder : ' + openOrder.length.toString());
        if (!mounted) {
          onProgress = false;
          return false;
        }
        context.read(openOrderChangeNotifier).update(openOrder);
      } catch (e) {
        DebugWriter.information('openOrder Exception : ' + e.toString());
        if (!mounted) {
          onProgress = false;
          return false;
        }
        if (e is TradingHttpException) {
          if (e.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            onProgress = false;
            return false;
          } else if (e.isErrorTrading()) {
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            onProgress = false;
            return;
          } else {
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel =
                networkErrorLabel.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context)
                .showSnackBar(context, networkErrorLabel);
            onProgress = false;
            return false;
          }
        } else {
          //InvestrendTheme.of(context).showSnackBar(context, e.toString());
          String errorText = Utils.removeServerAddress(e.toString());
          InvestrendTheme.of(context).showSnackBar(context, errorText);
        }
      }
      /*
      try {
        print(orderType.routeName+' try stockPosition');
        final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
            account.brokercode,
            account.accountcode,
            //InvestrendTheme.of(context).user.username,
            context.read(dataHolderChangeNotifier).user.username,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        DebugWriter.info(orderType.routeName+' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
        if(!mounted){
          onProgress = false;
          return false;
        }
        StockPositionDetail detail = stockPosition.getStockPositionDetailByCode(stock.code);
        if (detail != null) {
          context.read(sellLotAvgChangeNotifier).update(detail.netBalance.toInt(), detail.avgPrice);
        } else {
          context.read(sellLotAvgChangeNotifier).update(0, 0.0);
        }
      } catch (e) {
        DebugWriter.info(orderType.routeName+' stockPosition Exception : ' + e.toString());
        if(!mounted){
          onProgress = false;
          return false;
        }
        if(e is TradingHttpException){
          if(e.isUnauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            onProgress = false;
            return false;
          }else if(e.isErrorTrading()){
            InvestrendTheme.of(context).showSnackBar(context, e.message());
            onProgress = false;
            return false;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", e.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            onProgress = false;
            return false;
          }
        }else{
          InvestrendTheme.of(context).showSnackBar(context, e.toString());
        }
      }

      */
    }

    onProgress = false;
    print(orderType.routeName +
        '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  bool isFastMode() {
    return fastModeNotifier.value;
  }

  bool isCurrentTab() {
    return tabController.index == orderType.index;
  }

  // Widget getTextField(TextEditingController controller, Color colorForm, FocusNode focusNode) {
  //   return TextField(
  //     focusNode: focusNode,
  //     controller: controller,
  //     inputFormatters: [
  //       PriceFormatter(),
  //     ],
  //     // onSubmitted: (){
  //     //
  //     // },
  //     maxLines: 1,
  //     style: InvestrendTheme.of(context).regular_w700.copyWith(height: null),
  //     textInputAction: TextInputAction.next,
  //     keyboardType: TextInputType.number,
  //     cursorColor: colorForm,
  //     decoration: InputDecoration(
  //       border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
  //       focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorForm, width: 1.0)),
  //       focusColor: colorForm,
  //       prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
  //       hintStyle: InvestrendTheme.of(context).inputHintStyle,
  //       helperStyle: InvestrendTheme.of(context).inputHelperStyle,
  //       errorStyle: InvestrendTheme.of(context).inputErrorStyle,
  //       fillColor: Colors.grey,
  //       contentPadding: EdgeInsets.all(0.0),
  //     ),
  //     textAlign: TextAlign.end,
  //   );
  // }

  Widget createTopInfo(BuildContext context);

  void predefineLot(int percentage) {
    fieldLotController.removeListener(resetPredefineLot!);
    predefineLotNotifier.value = percentage;

    if (orderType.isBuyOrAmendBuy()) {
      print('predefineLot ' +
          orderType.text +
          '  $percentage %   availableMoney : belum');
      int price = Utils.safeInt(fieldPriceController.text.replaceAll(',', ''));
      double buyingPower =
          context.read(buyRdnBuyingPowerChangeNotifier).buyingPower;
      double? feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
      double cashAvailable =
          context.read(buyRdnBuyingPowerChangeNotifier).cashAvailable;

      Account? activeAccount = context
          .read(dataHolderChangeNotifier)
          .user
          .getAccount(context.read(accountChangeNotifier).index);
      if (activeAccount != null) {
        feeBuy = activeAccount.commission;
      }
      // buyingPower = 10000000;
      // feeBuy = 0;

      if (price <= 0) {
        InvestrendTheme.of(context)
            .showSnackBar(context, 'predefine_price_error_text'.tr());
        focusNodePrice?.requestFocus();
        predefineLotNotifier.value = 0;
        return;
      }

      double usedValue = 0.0;
      if (StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value,
          'trade_buy_label_buying_power'.tr())) {
        usedValue = buyingPower;
      } else if (StringUtils.equalsIgnoreCase(
          predefineLotSourceNotifier.value, 'cash_available_label'.tr())) {
        usedValue = cashAvailable;
      }
      if (buyingPower <= 0 &&
          StringUtils.equalsIgnoreCase(predefineLotSourceNotifier.value,
              'trade_buy_label_buying_power'.tr())) {
        String error = 'predefine_data_error_text'.tr();
        error = error.replaceFirst("#VALUE#", predefineLotSourceNotifier.value);
        InvestrendTheme.of(context).showSnackBar(
            context,
            //'Please wait for buyingPower first.'
            error);
        focusNodePrice?.requestFocus();
        predefineLotNotifier.value = 0;
        return;
      }

      if (cashAvailable <= 0 &&
          StringUtils.equalsIgnoreCase(
              predefineLotSourceNotifier.value, 'cash_available_label'.tr())) {
        String error = 'predefine_data_error_text'.tr();
        error = error.replaceFirst("#VALUE#", predefineLotSourceNotifier.value);
        InvestrendTheme.of(context).showSnackBar(
            context,
            //'Please wait for buyingPower first.'
            error);
        focusNodePrice?.requestFocus();
        predefineLotNotifier.value = 0;
        return;
      }

      //int loop = _orderTypeNotifier.value == 1 ? fieldSplitLoopController.text

      if (price > 0 && usedValue > 0) {
        String scrappedLoop = fieldSplitLoopController.text.replaceAll(',', '');
        int loop =
            _orderTypeNotifier.value == 1 ? Utils.safeInt(scrappedLoop) : 1;

        //print('predefineLot ' + orderType.text + '  buyingPower : $buyingPower  price : $price  feeBuy : $feeBuy');
        print('predefineLot ' +
            orderType.text +
            '  usedValue : $usedValue  price : $price  feeBuy : $feeBuy');

        //int lot = ( (buyingPower * (percentage / 100)) / ( price * 100 * loop * (1.0 + (feeBuy / 100)) ) ).toInt();
        int lot = (usedValue * (percentage / 100)) ~/
            (price * 100 * loop * (1.0 + (feeBuy! / 100)));

        //int lot = ((buyingPower / price * 100) / feeBuy).toInt();
        //int value = price * lot * fee;
        //lot = value / price / fee
        print('predefineLot ' + orderType.text + '  result lot : $lot');
        fieldLotController.text = InvestrendTheme.formatComma(lot);
        focusNodeLot?.unfocus();
      } else {
        InvestrendTheme.of(context)
            .showSnackBar(context, 'predefine_price_error_text'.tr());
        focusNodePrice?.requestFocus();
        predefineLotNotifier.value = 0;
      }
    } else {
      int availableLot = context.read(sellLotAvgChangeNotifier).lot;

      print('predefineLot ' +
          orderType.text +
          '  $percentage %   availableLot : $availableLot');
      int lot = 0;
      if (availableLot > 0 && percentage > 0) {
        if (percentage == 100) {
          lot = availableLot;
        } else {
          lot = ((percentage / 100) * availableLot).toInt();
        }
      }
      print('predefineLot ' + orderType.text + '  result lot : $lot');
      fieldLotController.text = InvestrendTheme.formatComma(lot);
      focusNodeLot?.unfocus();
    }

    fieldLotController.addListener(resetPredefineLot!);
  }

  // Widget minusButton(double iconSize, VoidCallback onPressed) {
  //   return IconButton(
  //       icon: Image.asset(
  //         'images/icons/minus.png',
  //         height: iconSize,
  //         width: iconSize,
  //       ),
  //       onPressed: onPressed);
  // }
  // Widget plusButton(double iconSize, VoidCallback onPressed) {
  //   return IconButton(
  //     icon: Image.asset(
  //       'images/icons/plus.png',
  //       height: iconSize,
  //       width: iconSize,
  //     ),
  //     onPressed: onPressed,
  //   );
  // }

  Widget createForm(BuildContext context) {
    double iconSize = 20.0;

    String labelType;
    Color colorForm;
    if (orderType == OrderType.Buy) {
      labelType = 'trade_buy_type_order_label'.tr();
      colorForm = InvestrendTheme.buyColor;
    } else {
      labelType = 'trade_sell_type_order_label'.tr();
      colorForm = InvestrendTheme.sellColor;
    }
    const double paddingLeftRight = 16.0;

    return Container(
      margin: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical),
      padding: EdgeInsets.only(
          top: InvestrendTheme.cardPadding,
          bottom: InvestrendTheme.cardPadding),
      //height: 225,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: colorForm,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            //color: Colors.blue,
            //padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            padding: const EdgeInsets.only(
                left: paddingLeftRight, right: paddingLeftRight),
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
                    Text(labelType,
                        style: InvestrendTheme.of(context)
                            .small_w500
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 2,
                      height: 2,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _orderTypeNotifier,
                      builder: (context, index, child) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: InvestrendTheme.cardPadding,
                              right: InvestrendTheme.cardPadding),
                          child: Text(
                            _order_options.elementAt(index as int),
                            style: InvestrendTheme.of(context).small_w400,
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                    ),

                    /*
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      child: Text(
                        'Normal',
                        style: InvestrendTheme.of(context).small_w400,
                        textAlign: TextAlign.end,
                      ),
                    ),
                     */
                    IconButton(
                        icon: Image.asset(
                          'images/icons/arrow_down.png',
                          height: iconSize,
                          width: iconSize,
                        ),
                        onPressed: () {
                          if (InvestrendTheme.LOOP_SPLIT) {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(24.0),
                                      topRight: Radius.circular(24.0)),
                                ),
                                //backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return ListBottomSheet(
                                      _orderTypeNotifier, _order_options);
                                });
                          }
                        }),
                  ],
                ),
                TableRow(
                  children: [
                    Text('trade_form_price_label'.tr(),
                        style: InvestrendTheme.of(context)
                            .small_w500
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    TradeComponentCreator.minusButton(iconSize, () {
                      addOrSubstractPriceTick(-1);
                    }),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: InvestrendTheme.cardPadding,
                          right: InvestrendTheme.cardPadding),
                      //child: getTextField(fieldPriceController, colorForm, focusNodePrice),
                      child: TradeComponentCreator.textField(context,
                          fieldPriceController, colorForm, focusNodePrice,
                          nextFocusNode: focusNodeLot),
                    ),
                    TradeComponentCreator.plusButton(iconSize, () {
                      addOrSubstractPriceTick(1);
                    }),
                  ],
                ),
                TableRow(
                  children: [
                    Text('trade_form_lot_label'.tr(),
                        style: InvestrendTheme.of(context)
                            .small_w500
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    TradeComponentCreator.minusButton(iconSize, () {
                      addOrSubstractLot(-1);
                    }),
                    ValueListenableBuilder(
                      valueListenable: _orderTypeNotifier,
                      builder: (context, index, child) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: InvestrendTheme.cardPadding,
                                right: InvestrendTheme.cardPadding),
                            //child: getTextField(fieldLotController, colorForm, focusNodeLot),
                            child: TradeComponentCreator.textField(
                              context,
                              fieldLotController,
                              colorForm,
                              focusNodeLot,
                            ),
                          );
                        } else {
                          return Padding(
                              padding: const EdgeInsets.only(
                                  left: InvestrendTheme.cardPadding,
                                  right: InvestrendTheme.cardPadding),
                              //child: getTextField(fieldLotController, colorForm, focusNodeLot),
                              child: TradeComponentCreator.textField(context,
                                  fieldLotController, colorForm, focusNodeLot,
                                  nextFocusNode: focusNodeSplitLoop));
                        }
                      },
                    ),
                    /*
                    Padding(
                      padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
                      //child: getTextField(fieldLotController, colorForm, focusNodeLot),
                      child: TradeComponentCreator.textField(context,fieldLotController, colorForm, focusNodeLot, nextFocusNode: (_orderTypeNotifier.value == 0 ? null : focusNodeSplitLoop)),
                    ),
                    */
                    TradeComponentCreator.plusButton(iconSize, () {
                      addOrSubstractLot(1);
                    }),
                  ],
                ),
                TableRow(
                  children: [
                    //ButtonDropdown(_orderTypeNotifier, _order_options),
                    ValueListenableBuilder(
                      valueListenable: _orderTypeNotifier,
                      builder: (context, index, child) {
                        if (index == 0) {
                          return SizedBox(
                            height: 1,
                          );
                        } else {
                          return Text(_order_options.elementAt(index as int),
                              style: InvestrendTheme.of(context)
                                  .small_w500
                                  ?.copyWith(fontWeight: FontWeight.w600));
                        }
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _orderTypeNotifier,
                      builder: (context, index, child) {
                        if (index == 0) {
                          return SizedBox(
                            height: 1,
                          );
                        } else {
                          return TradeComponentCreator.minusButton(iconSize,
                              () {
                            addOrSubstractSplitLoop(-1);
                          });
                        }
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _orderTypeNotifier,
                      builder: (context, index, child) {
                        if (index == 0) {
                          return SizedBox(
                            height: 1,
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: InvestrendTheme.cardPadding,
                                right: InvestrendTheme.cardPadding),
                            //child: getTextField(fieldLotController, colorForm, focusNodeLot),
                            child: TradeComponentCreator.textField(
                                context,
                                fieldSplitLoopController,
                                colorForm,
                                focusNodeSplitLoop),
                          );
                        }
                      },
                    ),

                    ValueListenableBuilder(
                      valueListenable: _orderTypeNotifier,
                      builder: (context, index, child) {
                        if (index == 0) {
                          return SizedBox(
                            height: 1,
                          );
                        } else {
                          return TradeComponentCreator.plusButton(iconSize, () {
                            addOrSubstractSplitLoop(1);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: predefineLotNotifier,
            builder: (context, int value, child) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPadding,
                    right: InvestrendTheme.cardPadding,
                    bottom: InvestrendTheme.cardPadding),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PercentButton(
                          5,
                          value,
                          onPressed: () {
                            predefineLot(5);
                          },
                        ),
                        PercentButton(
                          10,
                          value,
                          onPressed: () {
                            predefineLot(10);
                          },
                        ),
                        PercentButton(
                          25,
                          value,
                          onPressed: () {
                            predefineLot(25);
                          },
                        ),
                        PercentButton(
                          50,
                          value,
                          onPressed: () {
                            predefineLot(50);
                          },
                        ),
                        PercentButton(
                          75,
                          value,
                          onPressed: () {
                            predefineLot(75);
                          },
                        ),
                        PercentButton(
                          100,
                          value,
                          onPressed: () {
                            predefineLot(100);
                          },
                        ),
                        // predefineButton(5),
                        // predefineButton(10),
                        // predefineButton(25),
                        // predefineButton(50),
                        // predefineButton(75),
                        // predefineButton(100),
                      ],
                    ),
                    (value > 0 && orderType == OrderType.Buy)
                        ? ValueListenableBuilder(
                            valueListenable: predefineLotSourceNotifier,
                            builder: (context, valueSource, child) {
                              //#PERCENT#% of your #VALUE#
                              String text = 'predefine_lot_by_text'.tr();
                              text = text.replaceFirst(
                                  "#VALUE#", valueSource as String);
                              text = text.replaceFirst(
                                  "#PERCENT#", value.toString());
                              //AlignmentGeometry textAlign = StringUtils.equalsIgnoreCase(valueSource, 'trade_buy_label_buying_power'.tr()) ? Alignment.centerLeft : Alignment.centerRight;
                              return Text(
                                text,
                                style: InvestrendTheme.of(context)
                                    .support_w500_compact
                                    ?.copyWith(
                                        color: InvestrendTheme.of(context)
                                            .investrendPurpleText),
                              );
                            },
                          )
                        : SizedBox(
                            width: 1.0,
                          ),
                  ],
                ),
              );
            },
          ),

          /*
          Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      predefineLot(5);
                    },
                    child: Text(
                      '5%',
                      style: InvestrendTheme
                          .of(context)
                          .support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      predefineLot(10);
                    },
                    child: Text(
                      '10%',
                      style: InvestrendTheme
                          .of(context)
                          .support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      predefineLot(25);
                    },
                    child: Text(
                      '25%',
                      style: InvestrendTheme
                          .of(context)
                          .support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      predefineLot(50);
                    },
                    child: Text(
                      '50%',
                      style: InvestrendTheme
                          .of(context)
                          .support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      predefineLot(75);
                    },
                    child: Text(
                      '75%',
                      style: InvestrendTheme
                          .of(context)
                          .support_w400,
                    )),
                TextButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      predefineLot(100);
                    },
                    child: Text(
                      '100%',
                      style: InvestrendTheme
                          .of(context)
                          .support_w400,
                    )),
              ],
            ),
          ),
          */
          ComponentCreator.divider(context),
          Padding(
            //padding: const EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
            padding: const EdgeInsets.only(
                left: paddingLeftRight,
                right: paddingLeftRight,
                top: paddingLeftRight,
                bottom: InvestrendTheme.cardPadding),
            child: Row(
              children: [
                Text(
                  'trade_form_total_label'.tr(),
                  style: InvestrendTheme.of(context).small_w600_compact,
                ),
                Expanded(
                  flex: 1,
                  child: ValueListenableBuilder(
                    valueListenable: valueOrderNotifier,
                    builder: (context, int value, child) {
                      String totalValueText =
                          InvestrendTheme.formatMoney(value, prefixRp: true);
                      return Text(
                        totalValueText,
                        style: InvestrendTheme.of(context).regular_w600_compact,
                        textAlign: TextAlign.end,
                      );
                    },
                  ),
                ),
                // SizedBox(
                //   width: InvestrendTheme.cardMargin,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget predefineButton(int percentValue) {
  //   Color color = InvestrendTheme.of(context).support_w400.color;
  //   if (percentValue == predefineLotNotifier.value) {
  //     color = Theme.of(context).accentColor;
  //   }
  //   return TextButton(
  //       style: ButtonStyle(visualDensity: VisualDensity.compact),
  //       onPressed: () {
  //         predefineLot(percentValue);
  //       },
  //       child: Text(
  //         '$percentValue%',
  //         style: InvestrendTheme.of(context).support_w700.copyWith(color: color),
  //       ));
  // }

  void addOrSubstractLot(int step) {
    String lottext = fieldLotController.text;

    lottext = lottext.replaceAll(',', '');
    int lot = Utils.safeInt(lottext);
    lot += step;
    if (lot < 0) {
      lot = 0;
    }
    // fieldLotController.removeListener(resetPredefineLot);
    fieldLotController.text = lot.toString();
    //focusNodeLot.requestFocus();
    focusNodeLot?.unfocus();
    // if (predefineLotNotifier.value != 0) {
    //   predefineLotNotifier.value = 0;
    // }
    // fieldLotController.addListener(resetPredefineLot);
  }

  void addOrSubstractSplitLoop(int step) {
    String splitlooptext = fieldSplitLoopController.text;

    splitlooptext = splitlooptext.replaceAll(',', '');
    int splitLoop = Utils.safeInt(splitlooptext);
    splitLoop += step;
    if (splitLoop < 1) {
      splitLoop = 1;
    }
    fieldSplitLoopController.text = splitLoop.toString();
    //focusNodeLot.requestFocus();
    focusNodeSplitLoop?.unfocus();
  }

  int priceTickUp(int price) {
    int tick = 1;
    if (price >= 5000) {
      tick = 25;
    } else if (price >= 2000) {
      tick = 10;
    } else if (price >= 500) {
      tick = 5;
    } else if (price >= 200) {
      tick = 2;
    } else {
      tick = 1;
    }
    return tick;
  }

  int priceTickDown(int price) {
    int tick = 1;
    if (price > 5000) {
      tick = 25;
    } else if (price > 2000) {
      tick = 10;
    } else if (price > 500) {
      tick = 5;
    } else if (price > 200) {
      tick = 2;
    } else {
      tick = 1;
    }
    return tick;
  }

  void addOrSubstractPriceTick(int addSubtick) {
    String pricetext = fieldPriceController.text;
    pricetext = pricetext.replaceAll(',', '');
    int price = Utils.safeInt(pricetext);
    int newPrice = price;
    int tick = addSubtick > 0 ? priceTickUp(price) : priceTickDown(price);
    int precised = price % tick;
    print(
        'addOrSubstractPriceTick addSubtick $addSubtick   price : $price  tick : $tick  precised : $precised');
    if (precised == 0) {
      int tickPrice = tick * addSubtick;
      newPrice += tickPrice;
    } else {
      int hasilBagi = (price ~/ tick);
      newPrice = hasilBagi * tick;
      if (addSubtick > 0) {
        newPrice = newPrice + tick;
      }
    }
    print(
        'addOrSubstractPriceTick addSubtick $addSubtick   price : $price  newPrice : $newPrice');
    if (newPrice < 0) {
      newPrice = 0;
      fieldPriceController.text = newPrice.toString();
    } else {
      fieldPriceController.text = InvestrendTheme.formatComma(newPrice);
    }

    //focusNodePrice.requestFocus();
    focusNodePrice?.unfocus();
  }

  Widget accelerationLabel(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(primaryStockChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }
      if (notifier.stock!.isAccelerationBoard()) {
        return Container(
          margin: const EdgeInsets.only(
            top: InvestrendTheme.cardPadding,
          ),
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
          width: double.maxFinite,
          color: InvestrendTheme.of(context).accelerationBackground,
          child: Text(
            'stock_detail_overview_card_detail_special_notation'.tr(),
            style: InvestrendTheme.of(context).support_w400_compact?.copyWith(
                color: InvestrendTheme.of(context).accelerationTextColor),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        return SizedBox(
          width: 1.0,
          //height: 1.0,
        );
      }
    });
  }

  //double paddingHeight = 200.0;
  bool animatePadding = true;

  Widget _normalMode() {
    /*
    double height = MediaQuery.of(context).size.height;
    double paddingHeight = 1;
    if (animatePadding) {
      paddingHeight = height * 0.5;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          animatePadding = false;
        });
      });
    }
    */

    /* ASLI 2021-10-13
    if (animatePaddingNotifier.value > 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        animatePaddingNotifier.value = 1.0;
      });
    }
    */

    return RefreshIndicator(
      key: _normalKey,
      color: InvestrendTheme.of(context).textWhite,
      //backgroundColor: orderType.color,
      backgroundColor: Theme.of(context)
          .colorScheme
          .secondary, // putri minta warna disamain ama buy
      onRefresh: onRefresh,
      child: ListView(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          createTopInfo(context),

          accelerationLabel(context),

          createForm(context),
          SizedBox(
            height: 1.0,
          ),
          ComponentCreator.divider(context),
          // SizedBox(
          //   height: InvestrendTheme.cardMargin,
          // ),
          ValueListenableBuilder(
            valueListenable: animatePaddingNotifier!,
            builder: (context, value, child) {
              return AnimatedPadding(
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.only(top: value as double),
                  duration: Duration(milliseconds: 500));
            },
          ),

          CardOrderbook(
            orderbookNotifier,
            10,
            owner: orderType.routeName,
            onTap: onTapOrderbook,
          ),

          ComponentCreator.divider(context),
          // SizedBox(
          //   height: InvestrendTheme.cardMargin,
          // ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingVertical,
                bottom: InvestrendTheme.cardPaddingGeneral),
            child: ComponentCreator.subtitle(
                context, 'trade_title_trade_book'.tr()),
          ),

          WidgetTradebook(),
          SizedBox(
            height: 90.0,
          ),
        ],
      ),
    );
    /*
    return SingleChildScrollView(
      key: _normalKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          createTopInfo(context),

          createForm(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          ValueListenableBuilder(
            valueListenable: animatePaddingNotifier,
            builder: (context, value, child) {
              return AnimatedPadding(curve: Curves.easeIn, padding: EdgeInsets.only(top: value), duration: Duration(milliseconds: 500));
            },
          ),

          CardOrderbook(orderbookNotifier, 10,owner: orderType.routeName, onTap: onTapOrderbook,),

          ComponentCreator.divider(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingGeneral,
                bottom: InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitle(context, 'trade_title_trade_book'.tr()),
          ),

          WidgetTradebook(),
          SizedBox(
            height: 120.0,
          ),
        ],
      ),
    );

     */
  }

  Future onRefresh() {
    unsubscribe(context, 'onRefresh');
    Stock? stock = context.read(primaryStockChangeNotifier).stock;
    subscribe(context, stock, 'onRefresh');

    doUpdateAccount(pullToRefresh: true);
    return doUpdate(pullToRefresh: true);
  }

  Widget _fastMode() {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: orderType.color,
      onRefresh: onRefresh,
      child: ListView(
        controller: scrollControllerFast,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        //crossAxisAlignment: CrossAxisAlignment.start,
        //padding: EdgeInsets.only(bottom: 200),
        children: [
          // SizedBox(
          //   height: 5.0,
          // ),
          //createMoneyInfo(context),
          createTopInfo(context),
          ComponentCreator.divider(context),
          createFastOrder(context),
          SizedBox(
            height: 90.0,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.transparent,
              child: DragTarget<WrapperNotifierFast>(
                onMove: (data) {
                  acceptRemoveNotifier.value = true;
                },
                onLeave: (data) {
                  acceptRemoveNotifier.value = false;
                },
                onAccept: (data) {
                  data.primaryOpenNotifier.value?.value = "0";
                  acceptRemoveNotifier.value = false;
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  data.primaryOpenNotifier.notifyListeners();
                },
                builder: (context, wrapperNotifier, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: acceptRemoveNotifier,
                    builder: (context, condition, child) {
                      return Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: condition == true
                              ? Colors.red
                              : Colors.transparent,
                          border: Border.all(
                            color: Colors.black,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIndicator(Color color) {
    return Container(
      color: color,
      height: 2.0,
      width: 60,
    );
  }

  Widget createFastOrder(BuildContext context) {
    Color colorForm = orderType.color;

    Color inactiveColor = Color(0xFFE0E0E0);

    List<Widget> indicators;
    if (orderType == OrderType.Buy) {
      //colorForm = InvestrendTheme.buyColor;
      indicators = [getIndicator(colorForm), getIndicator(inactiveColor)];
    } else {
      //colorForm = InvestrendTheme.sellColor;
      indicators = [getIndicator(inactiveColor), getIndicator(colorForm)];
    }
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: indicators,
            ),
            SizedBox(
              height: 10.0,
            ),
            /*
            FastOrderbook(
              orderbookNotifier,
              orderType,
              10,
              owner: orderType.routeName,
              key: fastKey,
              //calculateNotifier: null,
            ),
            */
            _fastOrderbook as Widget,
          ],
        ));
  }

  void onTapOrderbook(TypeOrderbook type, TypeField field, PriceLotQueue data) {
    print('onTapOrderbook  ' +
        type.text +
        '  ' +
        field.text +
        '  ' +
        data.toString());
    if (field == TypeField.Price) {
      OrderType orderType = OrderType.Buy;
      fieldPriceController.text = InvestrendTheme.formatComma(data.price);
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuint);
    } else if (field == TypeField.Queue) {
      if (data.queue > 0) {
        Stock? stock = context.read(primaryStockChangeNotifier).stock;
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenOrderQueue(
                  stock?.code, stock?.defaultBoard, type.text, data.price),
              settings: RouteSettings(name: '/order_queue'),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;
    if (onlyFastOrder) {
      bodyWidget = _fastMode();
    } else {
      bodyWidget = AnimatedCrossFade(
        duration: const Duration(milliseconds: 800),
        firstChild: _normalMode(),
        secondChild: _fastMode(),
        crossFadeState: fastModeNotifier.value
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstCurve: Curves.easeOut,
        secondCurve: Curves.easeIn,
      );
    }

    return ScreenAware(
      routeName: orderType.routeName,
      onActive: onActive,
      onInactive: onInactive,
      child: bodyWidget,
    );
    /*
    return ScreenAware(
      routeName: orderType.routeName,
      onActive: onActive,
      onInactive: onInactive,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 800),
        firstChild: _normalMode(),
        secondChild: _fastMode(),
        crossFadeState: fastModeNotifier.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstCurve: Curves.easeOut,
        secondCurve: Curves.easeIn,
      ),
    );
     */
  }

  void calculateOrder({String caller = ''}) {
    print(orderType.routeName + '.calculateOrder  caller : $caller');
    //fieldLotController.removeListener(resetPredefineLot);
    String scrappedPrice = fieldPriceController.text.replaceAll(',', '');
    int price = Utils.safeInt(scrappedPrice);

    String scrappedLot = fieldLotController.text.replaceAll(',', '');
    int lot = Utils.safeInt(scrappedLot);

    int transactionCounter = 1;
    if (_orderTypeNotifier.value > 0) {
      String scrappedLoop = fieldSplitLoopController.text.replaceAll(',', '');
      transactionCounter = Utils.safeInt(scrappedLoop);
      if (transactionCounter < 1) {
        transactionCounter = 1;
        fieldSplitLoopController.removeListener(calculateOrder);
        fieldSplitLoopController.text = transactionCounter.toString();
        fieldSplitLoopController.selection =
            TextSelection(baseOffset: 1, extentOffset: 1);
        fieldSplitLoopController.addListener(calculateOrder);
      }
    }

    int value = price * lot * 100;
    //int totalLot = lot;
    if (_orderTypeNotifier.value == TransactionType.Loop.index) {
      value = value * transactionCounter;
      //totalLot = totalLot * transactionCounter;
    } else {
      // batasin lot kalo sell, cuma kalo Loop ga dibatasin.
      if (orderType.isSellOrAmendSell()) {
        final lotAverage = context.read(sellLotAvgChangeNotifier);
        if (lot > lotAverage.lot) {
          fieldLotController.text = InvestrendTheme.formatComma(lotAverage.lot);
          fieldLotController.selection = TextSelection(
              baseOffset: fieldLotController.text.length,
              extentOffset: fieldLotController.text.length);
          lot = lotAverage.lot;
          value = price * lot * 100;
        }
      }
    }

    double? feeBuy = context.read(dataHolderChangeNotifier).user.feepct;
    Account? activeAccount = context
        .read(dataHolderChangeNotifier)
        .user
        .getAccount(context.read(accountChangeNotifier).index);
    if (activeAccount != null) {
      feeBuy = activeAccount.commission;
    }
    if (orderType.isBuyOrAmendBuy() && feeBuy! > 0) {
      value = (value * (1.0 + (feeBuy / 100))).toInt();
    }

    print(orderType.routeName +
        '.calculateOrder Price : ' +
        fieldPriceController.text +
        '   Lot : ' +
        fieldLotController.text +
        '   Loop/Split : ' +
        fieldSplitLoopController.text +
        '  value : $value');

    valueOrderNotifier.value = value;

    BuySell data = context.read(buySellChangeNotifier).getData(orderType);
    // if(_orderTypeNotifier.value == 0 ){
    //   data.setNormalPriceLot(price, lot);
    // }else{
    TransactionType active =
        TransactionType.values.elementAt(_orderTypeNotifier.value);
    //data.setNormalPriceLot(price, lot, transactionType: active, transactionCounter: transactionCounter);
    data.setNormalPriceLot(price, lot,
        transactionType: active,
        transactionCounter: transactionCounter,
        totalValue: value);
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read(buySellChangeNotifier).mustNotifyListener();
    });

    // bool notifyParent = calculateNotifier.canNormalModeCalculate(orderType);
    // print('calculateOrder BUY notifyParent : $notifyParent  ' + calculateNotifier.toString());
    // if (notifyParent) {
    //   context.read(orderDataChangeNotifier).update(orderType: orderType, lot: lot, price: price, value: value);
    // }
    //fieldLotController.addListener(resetPredefineLot);
  }
}
//
// class ScreenTradeForm extends StatefulWidget {
//   final OrderType orderType;
//   final ValueNotifier<bool> _fastModeNotifier;
//   final TabController _tabController;
//
//   const ScreenTradeForm(this.orderType, this._fastModeNotifier, this._tabController, {Key key}) : super(key: key);
//
//   @override
//   _ScreenTradeFormState createState() => _ScreenTradeFormState(orderType,_fastModeNotifier,_tabController);
// }
//
//
// class _ScreenTradeFormState extends BaseTradeState<ScreenTradeForm> {
//
//   _ScreenTradeFormState(OrderType orderType, ValueNotifier<bool> fastModeNotifier, TabController tabController) : super(orderType, fastModeNotifier, tabController);
//   Key fastKey = UniqueKey();
//   Key normalKey = UniqueKey();
//   bool active = false;
//
//   void onActive() {
//
//   }
//   void onInactive() {
//
//   }
//
//   VoidCallback stockChangeListener;
//
//   @override
//   void initState() {
//     super.initState();
//     stockChangeListener = (){
//
//     };
//     final container = ProviderContainer();
//     container.read(primaryStockChangeNotifier).addListener(stockChangeListener);
//   }
//   @override
//   void dispose() {
//     final container = ProviderContainer();
//     container.read(primaryStockChangeNotifier).removeListener(stockChangeListener);
//
//     super.dispose();
//   }
//
//   Widget _normalMode(){
//
//   }
//   Widget _fastMode(){
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return ScreenAware(
//       routeName: orderType.routeName,
//       onActive: onActive,
//       onInactive: onInactive,
//       child: AnimatedCrossFade(
//         duration: const Duration(milliseconds: 800),
//         firstChild: _normalMode(),
//         secondChild: _fastMode(),
//         crossFadeState: fastModeNotifier.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//         firstCurve: Curves.easeOut,
//         secondCurve: Curves.easeIn,
//       ),
//     );
//   }
// }
