import 'dart:async';

import 'package:Investrend/component/bottom_sheet/bottom_sheet_watchlist.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/serializeable.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_analysis.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_corporate_action.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_financials.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_key_statistic.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_news.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_overview.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_profiles.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenStockDetail extends StatefulWidget {
  const ScreenStockDetail({Key key}) : super(key: key);

  @override
  _ScreenStockDetailState createState() => _ScreenStockDetailState();
}

class _ScreenStockDetailState extends BaseStateWithTabs<ScreenStockDetail> {
  String timeCreation = '-';

  /* 2021-10-08 MOVING to Streaming
  static const Duration durationUpdate = Duration(milliseconds: 1000);
  Timer timer;
   */
  final ValueNotifier<int> _watchlistNotifier = ValueNotifier<int>(-1);

  Key testKey = UniqueKey();

  List<Key> keys = [
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
    UniqueKey(),
  ];

  List<String> tabs = [
    'stock_detail_tabs_overview_title'.tr(),
    'stock_detail_tabs_analysis_title'.tr(),
    'stock_detail_tabs_key_statistic_title'.tr(),
    'stock_detail_tabs_financials_title'.tr(),
    'stock_detail_tabs_profiles_title'.tr(),
    'stock_detail_tabs_corporate_action_title'.tr(),
    'stock_detail_tabs_news_title'.tr(),
  ];

  List<ValueNotifier<bool>> _visibilityNotifiers = [
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
  ];

  List<Stock> listStocks = List<Stock>.empty(growable: true);
  List<String> listPeoples = List<String>.empty(growable: true);

  _ScreenStockDetailState()
      : super('/stock_detail', notifyStockChange: true, screenAware: true);

  /* 2021-10-08 MOVING to Streaming
  void startTimer() {
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(durationUpdate, (timer) {
        // bool main_active = context.read(stockDetailScreenVisibilityChangeNotifier).isStockDetailActive();
        // if (main_active) {
        //context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
        doUpdate();
        // }
      });
    }
  }

  void stopTimer() {
    if (timer == null || !timer.isActive) {
      return;
    }
    timer.cancel();
    timer = null;
  }

   */

// harus set notifyStockChange = true saat constructor super class
  void onStockChanged(Stock newStock) {
    /* 2021-10-08 MOVING to Streaming
    context.read(stockSummaryChangeNotifier).setStock(newStock);
    doUpdate(pullToRefresh: true);
     */

    unsubscribe(context, 'onStockChanged');
    subscribe(context, newStock, 'onStockChanged');
    /*
    if(subscribeSummary != null){
      context.read(managerDatafeedNotifier).unsubscribe(subscribeSummary);
    }

    String codeBoard = newStock.code+'.'+newStock.defaultBoard;
    subscribeSummary = SubscribeAndHGET(DatafeedType.Summary.key+'.'+codeBoard, DatafeedType.Summary.collection, codeBoard,listener: (message){
      print('got : '+message.elementAt(1));
      print(message);
    }, validator: validatorSummary);

    context.read(managerDatafeedNotifier).subscribe(subscribeSummary);

     */
  }

  SubscribeAndHGET subscribeSummary;

  void unsubscribe(BuildContext context, String caller) {
    if (subscribeSummary != null) {
      print(routeName + ' unsubscribe : ' + subscribeSummary.channel);
      context
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeSummary, routeName + '.' + caller);
      subscribeSummary = null;
    }
  }

  void subscribe(BuildContext context, Stock stock, String caller) {
    String codeBoard = stock.code + '.' + stock.defaultBoard;
    String channel = DatafeedType.Summary.key + '.' + codeBoard;

    context.read(stockSummaryChangeNotifier).setStock(stock);

    subscribeSummary =
        SubscribeAndHGET(channel, DatafeedType.Summary.collection, codeBoard,
            listener: (message) {
      print(routeName + ' got : ' + message.elementAt(1));
      print(message);
      if (mounted) {
        StockSummary stockSummary = StockSummary.fromStreaming(message);
        FundamentalCache cache =
            context.read(fundamentalCacheNotifier).getCache(stockSummary.code);
        stockSummary.updateCache(context, cache);
        context
            .read(stockSummaryChangeNotifier)
            .setData(stockSummary, check: true);
      }
    }, validator: validatorSummary);
    print(routeName + ' subscribe : $codeBoard');
    context
        .read(managerDatafeedNotifier)
        .subscribe(subscribeSummary, routeName + '.' + caller);
  }

  bool validatorSummary(List<String> data, String channel) {
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
      if (HEADER == 'III' && typeSummary == 'Q' && channel == channelData) {
        return true;
      }
    }
    return false;
  }

  /* 2021-10-08 MOVING to Streaming
  Future doUpdate({bool pullToRefresh = false}) async {
    bool main_active = context.read(stockDetailScreenVisibilityChangeNotifier).isStockDetailActive();
    if (!main_active) {
      print(routeName + '.doUpdate aborted, main_active : $main_active    isVisible : ' + isVisible().toString());
      return;
    }
    print(routeName +
        ' doUpdate performed main_active : $main_active    isVisible : ' +
        isVisible().toString() +
        '  ' +
        DateTime.now().toString());

    Stock stock = context.read(primaryStockChangeNotifier).stock;

    if (stock?.isValid()) {
      if (!StringUtils.equalsIgnoreCase(stock.code, context.read(stockSummaryChangeNotifier).summary.code)) {
        context.read(stockSummaryChangeNotifier).setStock(stock);
      }

      try {
        final stockSummary = await HttpSSI.fetchStockSummary(stock.code, stock.defaultBoard);
        if (stockSummary != null) {
          print(routeName + ' Future Summary DATA : ' + stockSummary.toString());
          //_summaryNotifier.setData(stockSummary);
          FundamentalCache cache = context.read(fundamentalCacheNotifier).getCache(stockSummary.code);
          stockSummary.updateCache(context, cache);

          context.read(stockSummaryChangeNotifier).setData(stockSummary);
        } else {
          print(routeName + ' Future Summary NO DATA');
        }
      } catch (errorSummary) {
        print(routeName + ' Future Summary Error');
        print(errorSummary);
      }
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }
  */
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    //_tabController = new TabController(vsync: this, length: tabs.length);
    // tabs = [
    //   'stock_detail_tabs_overview_title'.tr(),
    //   'stock_detail_tabs_analysis_title'.tr(),
    //   'stock_detail_tabs_key_statistic_title'.tr(),
    //   'stock_detail_tabs_financials_title'.tr(),
    //   'stock_detail_tabs_profiles_title'.tr(),
    //   'stock_detail_tabs_corporate_action_title'.tr(),
    //   'stock_detail_tabs_news_title'.tr(),
    // ];

    _watchlistNotifier.addListener(() {
      Watchlist active = context
          .read(watchlistChangeNotifier)
          .getWatchlist(_watchlistNotifier.value);
      if (active != null) {
        String code = context.read(primaryStockChangeNotifier).stock.code;
        if (active.count() < InvestrendTheme.MAX_STOCK_PER_WATCHLIST) {
          active.addStock(code);
          Watchlist.save(context.read(watchlistChangeNotifier).getAll())
              .then((value) {
            InvestrendTheme.of(context).showSnackBar(
                context,
                context.read(primaryStockChangeNotifier).stock.code +
                    'saved_in_label'.tr() +
                    active.name);
          });
        } else {
          String errorFull = 'error_add_to_watchlist_full'.tr();
          errorFull = errorFull.replaceFirst('#CODE#', code);
          errorFull = errorFull.replaceFirst(
              '#MAX#', InvestrendTheme.MAX_STOCK_PER_WATCHLIST.toString());
          errorFull = errorFull.replaceFirst('#WATCHLIST#', active.name);
          InvestrendTheme.of(context).showSnackBar(context, errorFull);
        }
      } else {
        print('ScreenStockDetail.cant find active watchlist ');
      }
    });

    /*
    pTabController.addListener(() {
      //_orderTypeNotifier.value = OrderType.values.elementAt(_tabController.index);
      runPostFrame(() {
        if (mounted) {
          FocusScope.of(context).requestFocus(new FocusNode());
          onActive();
        }
      });
      // if (mounted) {
      //   FocusScope.of(context).requestFocus(new FocusNode());
      // }
    });
    */
    _tabListener = () {
      runPostFrame(() {
        if (mounted) {
          FocusScope.of(context).requestFocus(new FocusNode());
          onActive();
        }
      });
    };
    pTabController.addListener(_tabListener);
  }

  VoidCallback _tabListener;

  @override
  int tabsLength() {
    return tabs.length;
  }

  //VoidCallback stockChangeListener;
  VoidCallback _childRefreshListener;
  VoidCallback _mainVisibilityListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('ScreenStockDetail.didChangeDependencies ');
    print('ScreenStockDetail.didChangeDependencies ' +
        context.read(dataHolderChangeNotifier).user.toString());

    /*
    pTabController.addListener(() {
      //_orderTypeNotifier.value = OrderType.values.elementAt(_tabController.index);
      runPostFrame(() {
        if (mounted) {
          FocusScope.of(context).requestFocus(new FocusNode());
          onActive();
        }
      });
      // if (mounted) {
      //   FocusScope.of(context).requestFocus(new FocusNode());
      // }
    });
    */

    if (_childRefreshListener != null) {
      context
          .read(stockDetailRefreshChangeNotifier)
          .removeListener(_childRefreshListener);
    } else {
      _childRefreshListener = () {
        if (mounted) {
          print(routeName +
              ' childRefreshListener triggered by : ' +
              context.read(stockDetailRefreshChangeNotifier).triggerByRoute);
          /* 2021-10-08 MOVING to Streaming
          doUpdate(pullToRefresh: true);
           */

          unsubscribe(context, '_childRefreshListener');
          Stock stock = context.read(primaryStockChangeNotifier).stock;
          subscribe(context, stock, '_childRefreshListener');
        }
      };
    }
    context
        .read(stockDetailRefreshChangeNotifier)
        .addListener(_childRefreshListener);

    if (_mainVisibilityListener != null) {
      context
          .read(stockDetailScreenVisibilityChangeNotifier)
          .removeListener(_mainVisibilityListener);
    } else {
      _mainVisibilityListener = () {
        if (mounted) {
          bool mainActive = context
              .read(stockDetailScreenVisibilityChangeNotifier)
              .isStockDetailActive();
          print(
              routeName + ' mainVisibilityListener main_active : $mainActive');
          if (mainActive) {
            /* 2021-10-08 MOVING to Streaming
            doUpdate(pullToRefresh: true);
             */
            unsubscribe(context, '_mainVisibilityListener');
            Stock stock = context.read(primaryStockChangeNotifier).stock;
            subscribe(context, stock, '_mainVisibilityListener');
          }
        }
      };
    }
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .addListener(_mainVisibilityListener);
  }

  // Future doUpdate({bool pullToRefresh = false}) async {
  //   print(routeName + '.doUpdate : ' + DateTime.now().toString());
  // }
  @override
  void dispose() {
    controller.dispose();
    _watchlistNotifier.dispose();
    if (_tabListener != null) {
      pTabController.removeListener(_tabListener);
    }

    /* 2021-10-08 MOVING to Streaming
    if (timer != null) timer.cancel();
    */
    final container = ProviderContainer();
    container
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActiveMain(false);
    if (_childRefreshListener != null) {
      container
          .read(stockDetailRefreshChangeNotifier)
          .removeListener(_childRefreshListener);
    }
    if (_mainVisibilityListener != null) {
      container
          .read(stockDetailScreenVisibilityChangeNotifier)
          .removeListener(_mainVisibilityListener);
    }
    for (int i = 0; i < _visibilityNotifiers.length; i++) {
      _visibilityNotifiers.elementAt(i).dispose();
    }

    if (subscribeSummary != null) {
      container
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeSummary, 'dispose');
    }

    super.dispose();
  }

  VoidCallback onSlideRename(int index) {
    Navigator.of(context).pop();
    Watchlist toRename =
        context.read(watchlistChangeNotifier).getWatchlist(index);
    print('onSlideRename [$index] : ' + toRename.name);
    controller.text = toRename.name;
    String title = 'rename_watchlist_title'.tr();
    String actionSave = 'button_save'.tr();
    String actionCancel = 'button_cancel'.tr();

    VoidCallback onPressedYes = () {
      if (StringUtils.isEmtpy(controller.text)) {
        InvestrendTheme.of(context)
            .showSnackBar(context, 'error_watchlist_name_empty'.tr());
        return;
      }
      print(controller.text);

      if (!StringUtils.equalsIgnoreCase(controller.text, toRename.name)) {
        Watchlist existing = context
            .read(watchlistChangeNotifier)
            .getWatchlistByName(controller.text);
        if (existing != null) {
          String error = 'error_watchlist_already_exist'.tr();
          error = error.replaceFirst('#NAME#', controller.text);
          InvestrendTheme.of(context).showSnackBar(context, error);
          return;
        }
      }

      Navigator.of(context).pop();

      toRename.name = controller.text;
      context.read(watchlistChangeNotifier).replaceWatchlist(index, toRename);
      Watchlist.save(context.read(watchlistChangeNotifier).getAll())
          .then((value) {
        showWatchlist(context);
      });
    };
    VoidCallback onPressedNo = () {
      Navigator.of(context).pop();
      showWatchlist(context);
    };
    InvestrendTheme.of(context).showDialogInputPlatform(
        context, controller, title,
        buttonYes: actionSave,
        buttonNo: actionCancel,
        onPressedYes: onPressedYes,
        onPressedNo: onPressedNo,
        maxInputLength: InvestrendTheme.MAX_WATCHLIST_NAME_CHARACTER);
  }

  Function onSlideDelete(int index) {
    //IntCallback onSlideDelete(int index){
    Navigator.of(context).pop();
    print('onSlideDelete');
    Watchlist toDelete =
        context.read(watchlistChangeNotifier).getWatchlist(index);
    String title = 'watchlist_info_title'.tr();

    String content =
        'confirmation_remove_label'.tr() + '\n\'' + toDelete.name + '\' ?';
    String actionSave = 'button_yes'.tr();
    String actionCancel = 'button_cancel'.tr();

    VoidCallback onPressedYes = () {
      Navigator.of(context).pop();
      context.read(watchlistChangeNotifier).removeWatchlist(index);
      Watchlist.save(context.read(watchlistChangeNotifier).getAll())
          .then((value) {
        _watchlistNotifier.value = 0;
        showWatchlist(context, onClickClose: true);
      });
    };

    VoidCallback onPressedNo = () {
      Navigator.of(context).pop();
      showWatchlist(context, onClickClose: true);
    };

    InvestrendTheme.of(context).showDialogPlatform(context, title, content,
        buttonYes: actionSave,
        buttonNo: actionCancel,
        onPressedYes: onPressedYes,
        onPressedNo: onPressedNo);
    /*
    if (Platform.isIOS) {
      // iOS-specific code
      showCupertinoDialog(
          context: context,
          builder: (_) =>
              CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  CupertinoDialogAction(
                    child: Text(action_save),
                    onPressed: () {
                      Navigator.of(context).pop();

                      context.read(watchlistChangeNotifier).removeWatchlist(index);
                      //_listWatchlist.add(Watchlist(controller.text));
                      Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                        _watchlistNotifier.value = 0;
                        showWatchlist(context, onClickClose: true);
                      });
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(action_cancel),
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showWatchlist(context, onClickClose: true);
                    },
                  ),
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    child: Text(action_save),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _watchlistNotifier.value = 0;
                      context.read(watchlistChangeNotifier).removeWatchlist(index);

                      Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                        showWatchlist(context, onClickClose: true);
                      });
                    },
                  ),
                  TextButton(
                    child: Text(action_cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showWatchlist(context, onClickClose: true);
                    },
                  ),
                ],
              ));
    }
    */
  }

  TextEditingController controller = TextEditingController();

  VoidCallback onTapCreate() {
    Navigator.of(context).pop();
    print('onTapCreate');
    controller.text = '';
    if (context.read(watchlistChangeNotifier).count() >=
        InvestrendTheme.MAX_WATCHLIST) {
      String errorFull = 'error_maximum_create_watchlist'.tr();
      errorFull = errorFull.replaceFirst(
          '#MAX#', InvestrendTheme.MAX_WATCHLIST.toString());
      InvestrendTheme.of(context).showSnackBar(context, errorFull);
    } else {
      String title = 'new_watchlist_title'.tr();
      String actionSave = 'button_save'.tr();
      String actionCancel = 'button_cancel'.tr();

      VoidCallback onPressedYes = () {
        if (StringUtils.isEmtpy(controller.text)) {
          InvestrendTheme.of(context)
              .showSnackBar(context, 'error_watchlist_name_empty'.tr());
          return;
        }
        print(controller.text);
        Watchlist existing = context
            .read(watchlistChangeNotifier)
            .getWatchlistByName(controller.text);
        if (existing != null) {
          String error = 'error_watchlist_already_exist'.tr();
          error = error.replaceFirst('#NAME#', controller.text);
          InvestrendTheme.of(context).showSnackBar(context, error);
          return;
        }
        Navigator.of(context).pop();

        Watchlist newWatchlist = Watchlist(controller.text);
        newWatchlist
            .addStock(context.read(primaryStockChangeNotifier).stock.code);
        context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);
        //_listWatchlist.add(Watchlist(controller.text));
        Watchlist.save(context.read(watchlistChangeNotifier).getAll())
            .then((value) {
          //showWatchlist(context);
          InvestrendTheme.of(context).showSnackBar(
              context,
              context.read(primaryStockChangeNotifier).stock.code +
                  'saved_in_label'.tr() +
                  controller.text);
        });
      };

      VoidCallback onPressedNo = () {
        Navigator.of(context).pop();
        showWatchlist(context, onClickClose: true);
      };

      InvestrendTheme.of(context).showDialogInputPlatform(
          context, controller, title,
          buttonYes: actionSave,
          buttonNo: actionCancel,
          onPressedYes: onPressedYes,
          onPressedNo: onPressedNo,
          maxInputLength: InvestrendTheme.MAX_WATCHLIST_NAME_CHARACTER);

      /*
      if (Platform.isIOS) {
        // iOS-specific code
        showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: Text(title),
              content: CupertinoTextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.name,
                style: TextStyle(color: InvestrendTheme.of(context).blackAndWhiteText),
                cursorColor: Theme.of(context).accentColor,
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(action_save),
                  onPressed: () {
                    if(StringUtils.isEmtpy(controller.text)){
                      InvestrendTheme.of(context).showSnackBar(context, 'error_watchlist_name_empty'.tr());
                      return;
                    }
                    print(controller.text);
                    Watchlist  existing = context.read(watchlistChangeNotifier).getWatchlistByName(controller.text);
                    if(existing != null){
                      String error = 'error_watchlist_already_exist'.tr();
                      error = error.replaceFirst('#NAME#', controller.text);
                      InvestrendTheme.of(context).showSnackBar(context, error);
                      return;
                    }
                    Navigator.of(context).pop();

                    Watchlist newWatchlist = Watchlist(controller.text);
                    newWatchlist.addStock(context.read(primaryStockChangeNotifier).stock.code);
                    context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);
                    //_listWatchlist.add(Watchlist(controller.text));
                    Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                      //showWatchlist(context);
                      InvestrendTheme.of(context)
                          .showSnackBar(context, context.read(primaryStockChangeNotifier).stock.code + 'saved_in_label'.tr() + controller.text);
                    });
                  },
                ),
                CupertinoDialogAction(
                  child: Text(action_cancel),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    showWatchlist(context, onClickClose: true);
                  },
                ),
              ],
            ));
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.name,
                style: TextStyle(color: InvestrendTheme.of(context).blackAndWhiteText),
                cursorColor: Theme.of(context).accentColor,
              ),
              actions: [
                TextButton(
                  child: Text(action_save),
                  onPressed: () {
                    if(StringUtils.isEmtpy(controller.text)){
                      InvestrendTheme.of(context).showSnackBar(context, 'error_watchlist_name_empty'.tr());
                      return;
                    }
                    print(controller.text);
                    Watchlist  existing = context.read(watchlistChangeNotifier).getWatchlistByName(controller.text);
                    if(existing != null){
                      String error = 'error_watchlist_already_exist'.tr();
                      error = error.replaceFirst('#NAME#', controller.text);
                      InvestrendTheme.of(context).showSnackBar(context, error);
                      return;
                    }
                    Navigator.of(context).pop();

                    Watchlist newWatchlist = Watchlist(controller.text);
                    newWatchlist.addStock(context.read(primaryStockChangeNotifier).stock.code);
                    context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);
                    Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                      InvestrendTheme.of(context)
                          .showSnackBar(context, context.read(primaryStockChangeNotifier).stock.code + 'saved_in_label'.tr() + controller.text);
                    });
                  },
                ),
                TextButton(
                  child: Text(action_cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showWatchlist(context, onClickClose: true);
                  },
                ),
              ],
            ));
      }
      */
    }
  }

  void showWatchlist(BuildContext context, {bool onClickClose = false}) {
    _watchlistNotifier.value = -1;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return WatchlistBottomSheet(
            _watchlistNotifier,
            context.read(watchlistChangeNotifier).getAll(),
            onTapCreate: onTapCreate,
            onClickClosed: onClickClose,
            onSlideDelete: onSlideDelete,
            onSlideRename: onSlideRename,
          );
        });
  }

  /*
  Widget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      elevation: 2.0,
      shadowColor: Theme.of(context).shadowColor,
      centerTitle: true,
      title: ValueListenableBuilder(
        valueListenable: InvestrendTheme.of(context).stockNotifier,
        builder: (context, Stock value, child) {
          if (InvestrendTheme.of(context).stockNotifier.invalid()) {
            return Center(child: CircularProgressIndicator());
          }
          return Text(
            value.code,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          );
        },
      ),
      // title: Text(
      //   (InvestrendTheme.of(context).stock != null ? InvestrendTheme.of(context).stock.code : '-'),
      //   style: Theme.of(context).appBarTheme.titleTextStyle,
      // ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        color: Theme.of(context).accentColor,
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Image.asset('images/icons/action_search.png', color: Theme.of(context).accentIconTheme.color),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            final result = InvestrendTheme.showFinderScreen(context);
            result.then((value) {
              if (value == null) {
                print('result finder = null');
              } else if (value is Stock) {
                print('result finder = ' + value.code);
                //InvestrendTheme.of(context).stock = value;
                //showStockDetail(context);
                InvestrendTheme.of(context).stockNotifier.setStock(value);
              } else if (value is People) {
                print('result finder = ' + value.name);
              }
            });
          },
        ),
        IconButton(
          icon: Image.asset('images/icons/action_bell_plus.png', color: Theme.of(context).accentIconTheme.color),
          onPressed: () {
            //
          },
        ),
      ],
    );
  }
  */
  Widget createTabs(BuildContext context) {
    return TabBar(
      labelPadding:
          InvestrendTheme.paddingTab, //EdgeInsets.symmetric(horizontal: 12.0),
      //indicatorSize: TabBarIndicatorSize.label,
      controller: pTabController,
      isScrollable: true,
      tabs: List<Widget>.generate(
        tabs.length,
        (int index) {
          print(tabs[index]);
          return new Tab(text: tabs[index]);
        },
      ),
    );
  }

  Widget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      //automaticallyImplyLeading: false,
      title: Consumer(builder: (context, watch, child) {
        final notifier = watch(primaryStockChangeNotifier);
        if (notifier.stock.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        return Text(
          notifier.stock.code,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        );
      }),

      actions: [
        AppBarActionIcon('images/icons/action_search.png', () {
          //FocusScope.of(context).requestFocus(new FocusNode());
          final result = InvestrendTheme.showFinderScreen(context);
          result.then((value) {
            if (value == null) {
              print('result finder = null');
            } else if (value is Stock) {
              print('result finder stock = ' + value.code);
              //InvestrendTheme.of(context).stock = value;
              //showStockDetail(context);
              //InvestrendTheme.of(context).stockNotifier.setStock(value);
              context.read(primaryStockChangeNotifier).setStock(value);
            } else if (value is People) {
              print('result finder people = ' + value.name);
            }
          }).whenComplete(() {
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted && !active) {
                print(routeName +
                    ' force onActive after whenComplete showFinder');
                onActive();
              }
            });
          });
        }),
        /*
        AppBarActionIcon('images/icons/action_bell_plus.png', () {
          FocusScope.of(context).requestFocus(new FocusNode());
          showWatchlist(context, onClickClose: true);
        }),
        */

        AppBarConnectionStatus(
          child: AppBarActionIcon('images/icons/action_bell_plus.png', () {
            FocusScope.of(context).requestFocus(new FocusNode());
            showWatchlist(context, onClickClose: true);
          }),
        ),
        /*
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Consumer(builder: (context, watch, child) {
                  final notifier = watch(managerDatafeedNotifier);
                  return Container(
                    // width: 5.0,
                    // height: 5.0,
                    //color: notifier.statusColor,
                    child: Icon(Icons.circle, color: notifier.statusColor, size: 10.0,),
                  );
                }),
              ),
            ),
            AppBarActionIcon('images/icons/action_bell_plus.png', () {
              FocusScope.of(context).requestFocus(new FocusNode());
              showWatchlist(context, onClickClose: true);
            }),
          ],
        ),
        */
      ],
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    return TabBarView(
      controller: pTabController,
      children: List<Widget>.generate(
        tabs.length,
        (int index) {
          print(tabs[index]);
          if (index == 0) {
            return ScreenStockDetailOverview(
              index,
              pTabController,
              key: keys.elementAt(index),
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 1) {
            return ScreenStockDetailAnalysis(
              index,
              pTabController,
              key: keys.elementAt(index),
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 2) {
            return ScreenStockDetailKeyStatistic(
              index,
              pTabController,
              key: keys.elementAt(index),
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 3) {
            return ScreenStockDetailFinancials(
              index,
              pTabController,
              key: keys.elementAt(index),
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 4) {
            return ScreenStockDetailProfiles(
              index,
              pTabController,
              key: keys.elementAt(index),
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 5) {
            return ScreenStockDetailCorporateAction(
              index,
              pTabController,
              key: keys.elementAt(index),
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 6) {
            return ScreenStockDetailNews(
              index,
              pTabController,
              key: keys.elementAt(index),
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          }
          return Container(
            child: Center(
              child: Text(tabs[index]),
            ),
          );
        },
      ),
    );
  }

  Widget build2(BuildContext context) {
    final Color background = Theme.of(context).colorScheme.background;
    final Color fill = InvestrendTheme.of(context).blackAndWhite;
    final List<Color> gradient = [
      background,
      background,
      fill,
      fill,
    ];
    final double fillPercent = 56.23; // fills 56.23% for container from bottom
    final double fillStop = (100 - fillPercent) / 100;
    final List<double> stops = [0.0, fillStop, fillStop, 1.0];

    print('viewPadding.top : ' +
        MediaQuery.of(context).viewPadding.top.toString());
    print('viewPadding.bottom : ' +
        MediaQuery.of(context).viewPadding.bottom.toString());
    print('viewPadding.left : ' +
        MediaQuery.of(context).viewPadding.left.toString());
    print('viewPadding.right : ' +
        MediaQuery.of(context).viewPadding.right.toString());

    double paddingBottomSheetBottom = 15.0;
    double heightBottomSheet = 75.0;
    if (MediaQuery.of(context).viewPadding.bottom > 0.0) {
      heightBottomSheet = 63.0;
      paddingBottomSheetBottom = 0.0;
    }
    paddingBottomSheetBottom += MediaQuery.of(context).viewPadding.bottom;

    heightBottomSheet += MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          stops: stops,
          end: Alignment.bottomCenter,
          begin: Alignment.topCenter,
        ),
      ),
      child: super.build(context),
    );

    /*
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          stops: stops,
          end: Alignment.bottomCenter,
          begin: Alignment.topCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: createAppBar(),
        body: DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: createTabs(),
            body: createBody(),
          ),
        ),
        bottomSheet: createBottomSheet(),
      ),
    );

    return DefaultTabController(
      length: tabs.length,
      child: Container(

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            stops: stops,
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
          ),
        ),

        //color: Theme.of(context).backgroundColor,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          //backgroundColor: Colors.purple,
          appBar: createAppBar(),
          body: createBody(),
          bottomSheet: createBottomSheet(context),
        ),
      ),
    );
    */
    /*
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _appBar(context),
      body: ComponentCreator.keyboardHider(context, createBody(context)),
      //bottomNavigationBar: bottomNavigationBar(context),
    );
    */
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              //color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*
                    ValueListenableBuilder(
                      valueListenable: InvestrendTheme.of(context).stockNotifier,
                      builder: (context, Stock value, child) {
                        if (InvestrendTheme.of(context).stockNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return Text(
                          value.code,
                          style: InvestrendTheme.of(context).small_w400,
                        );
                      },
                    ),
                    */
                    Consumer(builder: (context, watch, child) {
                      final notifier = watch(primaryStockChangeNotifier);
                      if (notifier.invalid()) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Text(
                        notifier.stock.code,
                        style: InvestrendTheme.of(context).small_w400,
                      );
                    }),
                    //SampleRiverpod(),

                    Consumer(builder: (context, watch, child) {
                      final notifier = watch(stockSummaryChangeNotifier);
                      if (notifier.invalid()) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Text(
                        InvestrendTheme.formatPrice(notifier.summary.close),
                        style: InvestrendTheme.of(context).medium_w600,
                      );
                    }),
                    /*
                    ValueListenableBuilder(
                      valueListenable: InvestrendTheme.of(context).summaryNotifier,
                      builder: (context, StockSummary value, child) {
                        if (InvestrendTheme.of(context).summaryNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return Text(
                          InvestrendTheme.formatPrice(value.close),
                          style: InvestrendTheme.of(context).medium_w700,
                        );
                      },
                    ),
                     */
                    /*
                    Text(
                      '1.760',
                      style: InvestrendTheme.of(context).regular_w700,
                    ),
                    */
                  ],
                ),
              ),
            ),
          ),
          // ComponentCreator.roundedButton(context, 'BELI', Theme.of(context).accentColor, Colors.white, Theme.of(context).accentColor, () {
          //
          // }, padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25.0, right: 25.0),),

          // ComponentCreator.roundedButtonSolid(context, 'BELI', Theme.of(context).accentColor, Colors.white, () {},
          //     padding: EdgeInsets.only(top: 15.0, bottom:15.0, left: 25.0, right: 25.0),
          //     border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0))),
          Hero(
            tag: 'button_buy',
            child: Padding(
              padding: const EdgeInsets.only(
                left: 18.0,
                right: 0,
              ),
              child: ButtonOrder(
                OrderType.Buy,
                () {
                  //InvestrendTheme.push(context, ScreenTrade(OrderType.Buy), ScreenTransition.SlideLeft,'/trade');

                  int close =
                      context.read(stockSummaryChangeNotifier).summary.close;

                  bool hasAccount = context
                          .read(dataHolderChangeNotifier)
                          .user
                          .accountSize() >
                      0;
                  InvestrendTheme.pushScreenTrade(context, hasAccount,
                      type: OrderType.Buy, initialPriceLot: PriceLot(close, 0));
                  /*
                  return Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ScreenTrade(OrderType.Buy, initialPriceLot: PriceLot(close, 0),),
                        settings: RouteSettings(name: '/trade'),
                      ));

                   */
                },
              ),
            ),
          ),
          // SizedBox(
          //   width: 18.0,
          // ),
          //ComponentCreator.roundedButton(context, 'JUAL', InvestrendTheme.sellColor, Colors.white, InvestrendTheme.sellColor, () {

          // }, padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25.0, right: 25.0),),
          Hero(
            tag: 'button_sell',
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
              child: ButtonOrder(OrderType.Sell, () {
                //InvestrendTheme.push(context, ScreenTrade(OrderType.Sell), ScreenTransition.SlideLeft,'/trade');
                int close =
                    context.read(stockSummaryChangeNotifier).summary.close;

                bool hasAccount =
                    context.read(dataHolderChangeNotifier).user.accountSize() >
                        0;
                InvestrendTheme.pushScreenTrade(context, hasAccount,
                    type: OrderType.Sell, initialPriceLot: PriceLot(close, 0));
                /*
                return Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ScreenTrade(OrderType.Sell,  initialPriceLot: PriceLot(close, 0)),
                      settings: RouteSettings(name: '/trade'),
                    ));

                 */
              }),
            ),
          ),
          // ComponentCreator.roundedButtonSolid(context, 'JUAL', InvestrendTheme.sellColor, Colors.white, () {},
          //     padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
          //     border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0))),
        ],
      ),
    );
  }

  @override
  void onActive() {
    // TODO: implement onActive

    context.read(stockDetailScreenVisibilityChangeNotifier).setActiveMain(true);
    /* 2021-10-08 MOVING to Streaming
    doUpdate();
     */

    unsubscribe(context, 'onActive');

    Stock stock = context.read(primaryStockChangeNotifier).stock;
    if (!StringUtils.equalsIgnoreCase(
        stock.code, context.read(stockSummaryChangeNotifier).summary.code)) {
      context.read(stockSummaryChangeNotifier).setStock(stock);
    }
    subscribe(context, stock, 'onActive');

    for (int i = 0; i < _visibilityNotifiers.length; i++) {
      ValueNotifier childNotifier = _visibilityNotifiers.elementAt(i);
      if (pTabController.index == i) {
        if (childNotifier != null) {
          childNotifier.value = true;
        }
      } else {
        if (childNotifier != null) {
          childNotifier.value = false;
        }
      }
    }

    /*
    Stock stock = context.read(primaryStockChangeNotifier).stock;
    if (stock == null || !stock.isValid()) {
      Stock stockDefault = InvestrendTheme.storedData.listStock.isEmpty ? null : InvestrendTheme.storedData.listStock.first;
      context.read(primaryStockChangeNotifier).setStock(stockDefault);
      stock = context.read(primaryStockChangeNotifier).stock;
    }
    context.read(subscriptionDatafeedChangeNotifier).subscribe('KQ.'+stock.code+'.'+stock.defaultBoard);
    */
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActiveMain(false);

    for (int i = 0; i < _visibilityNotifiers.length; i++) {
      ValueNotifier childNotifier = _visibilityNotifiers.elementAt(i);
      if (childNotifier != null) {
        childNotifier.value = false;
      }
    }

    unsubscribe(context, 'onInactive');
  }
/*
  Widget createBottomSheet2(){
    return Container(
      padding:  EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: paddingBottomSheetBottom),
      width: double.maxFinite,

      height: heightBottomSheet,
      //color: Theme.of(context).backgroundColor,
      color: InvestrendTheme.of(context).blackAndWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WIKA',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  '1.760',
                  style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // ComponentCreator.roundedButton(context, 'BELI', Theme.of(context).accentColor, Colors.white, Theme.of(context).accentColor, () {
          //
          // }, padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25.0, right: 25.0),),

          // ComponentCreator.roundedButtonSolid(context, 'BELI', Theme.of(context).accentColor, Colors.white, () {},
          //     padding: EdgeInsets.only(top: 15.0, bottom:15.0, left: 25.0, right: 25.0),
          //     border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0))),
          ButtonOrder('BELI', OrderType.Buy, (){

          }),
          SizedBox(
            width: 10.0,
          ),
          //ComponentCreator.roundedButton(context, 'JUAL', InvestrendTheme.sellColor, Colors.white, InvestrendTheme.sellColor, () {

          // }, padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25.0, right: 25.0),),
          ButtonOrder('JUAL', OrderType.Sell, (){

          }),
          // ComponentCreator.roundedButtonSolid(context, 'JUAL', InvestrendTheme.sellColor, Colors.white, () {},
          //     padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
          //     border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0))),
        ],
      ),
    );
  }

   */
/*
  Widget createBody(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          toolbarHeight: InvestrendTheme.of(context).appBarTabHeight,
          // backgroundColor: Colors.green,
          backgroundColor: Theme.of(context).backgroundColor,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            // color: Colors.yellow,
            child: new TabBar(
              //indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              tabs: List<Widget>.generate(
                tabs.length,
                (int index) {
                  print(tabs[index]);
                  return new Tab(text: tabs[index]);
                },
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: List<Widget>.generate(
            tabs.length,
            (int index) {
              String tab_title = tabs[index];
              //if(StringUtils.equalsIgnoreCase(tab_title, 'stock_detail_tabs_overview_title'.tr())){
              if (index == 0) {
                return ScreenStockDetailOverview();
              }

              return Container(
                child: Center(
                  child: Text(tabs[index]),
                ),
              );
            },
          ),
        ),
        //bottomNavigationBar: ,
        bottomSheet: Container(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 15.0),
          width: double.maxFinite,
          height: 100.0,
          color: Theme.of(context).backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WIKA',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      '1.760',
                      style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ComponentCreator.roundedButtonSolid(context, 'BELI', Theme.of(context).accentColor, Colors.white, () {},
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                  border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
              SizedBox(
                width: 10.0,
              ),
              ComponentCreator.roundedButtonSolid(context, 'JUAL', InvestrendTheme.sellColor, Colors.white, () {},
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                  border: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
            ],
          ),
        ),
      ),
    );
  }

   */
}

class SampleRiverpod extends ConsumerWidget {
  final key = UniqueKey();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final notifier = watch(primaryStockChangeNotifier);
    return Row(
      children: [
        Text(
          notifier.stock.code,
          style: InvestrendTheme.of(context).small_w400,
        ),
        Text(
          DateTime.now().toString(),
          key: key,
        ),
      ],
    );
  }
}
