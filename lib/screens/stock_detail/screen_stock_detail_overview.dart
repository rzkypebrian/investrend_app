import 'dart:async';

import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/bottom_sheet/bottom_sheet_related_stock.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/cards/card_chart.dart';
import 'package:Investrend/component/cards/card_news.dart';
import 'package:Investrend/component/cards/card_ohlcv_chart.dart';
import 'package:Investrend/component/cards/card_orderbook.dart';
import 'package:Investrend/component/cards/card_rating.dart';
import 'package:Investrend/component/trade_done.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rating_slider.dart';
import 'package:Investrend/component/sort_and_filter_popup.dart';
import 'package:Investrend/component/widget_price.dart';
import 'package:Investrend/component/widget_returns.dart';
import 'package:Investrend/component/widget_tradebook.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/group_style.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_detail_list.dart';
import 'package:Investrend/screens/screen_settings.dart';
import 'package:Investrend/screens/stock_detail/screen_order_queue.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_detail.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:reorderables/reorderables.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:Investrend/component/card_data_with_filter.dart';

class ScreenStockDetailOverview extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;

  ScreenStockDetailOverview(this.tabIndex, this.tabController,
      {Key key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenStockDetailOverviewState createState() =>
      _ScreenStockDetailOverviewState(tabIndex, tabController,
          visibilityNotifier: visibilityNotifier);
}

//final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
//class _ScreenStockDetailOverviewState extends State<ScreenStockDetailOverview>
class _ScreenStockDetailOverviewState extends BaseStateNoTabsWithParentTab<
    ScreenStockDetailOverview> //with AutomaticKeepAliveClientMixin<ScreenStockDetailOverview> //    with RouteAware
{
  Key keyChart = UniqueKey();
  Key keyNews = UniqueKey();
  ResearchRankNotifier _researchRankNotifier =
      ResearchRankNotifier(ResearchRank.createBasic());
  ValueNotifier<int> thinksNotifier = ValueNotifier<int>(1);
  ValueNotifier<double> thinksSliderNotifier = ValueNotifier<double>(1.0);
  ChartNotifier _chartNotifier = ChartNotifier(ChartLineData());
  ChartOhlcvNotifier _chartOhlcvNotifier = ChartOhlcvNotifier(ChartOhlcvData());
  ValueNotifier<int> _chartRangeNotifier = ValueNotifier<int>(0);
  OrderbookNotifier _orderbookNotifier = OrderbookNotifier(OrderbookData());
  ChangeNotifier onDoUpdate = ChangeNotifier();
  ValueNotifier<bool> animateSpecialNotationNotifier =
      ValueNotifier<bool>(true);
  YourPositionNotifer _yourPositionNotifer =
      YourPositionNotifer(YourPosition());

  String _selectedChartFrom = '';
  String _selectedChartTo = '';
  DateTime lastChartUpdate;
  DateTime lastPositionUpdate;
  int maxPositionSeconds = 10;
  bool showOptionRelated = false;
  GroupStyle groupStyle = GroupStyle();
  bool candleChart = true;
  bool checkedValue = true;

  //update filter and orderable
  List<LabelValueColor> listLeft;
  List<SortAndFilterModel> listOverview = [
    SortAndFilterModel(
      name: "Previous",
      status: true,
    ),
    SortAndFilterModel(
      name: "Turnover",
      status: true,
    ),
    SortAndFilterModel(
      name: "Open",
      status: true,
    ),
    SortAndFilterModel(
      name: "Lot",
      status: true,
    ),
    SortAndFilterModel(
      name: "Low",
      status: true,
    ),
    SortAndFilterModel(
      name: "Market Cap",
      status: true,
    ),
    SortAndFilterModel(
      name: "High",
      status: true,
    ),
    SortAndFilterModel(
      name: "P/E",
      status: true,
    ),
    SortAndFilterModel(
      name: "VWAP",
      status: true,
    ),
    SortAndFilterModel(
      name: "YTD (%)",
      status: true,
    ),
    SortAndFilterModel(
      name: "IEP",
      status: true,
    ),
    SortAndFilterModel(
      name: "IEV (Lot)",
      status: true,
    ),
  ];
  ValueNotifier<List<String>> listOverViewNotifier =
      ValueNotifier<List<String>>([]);

  ValueNotifier<bool> showMoreTradeBookNotifier = ValueNotifier<bool>(true);

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  //ValueNotifier<int> _chartRangeNotifier = ValueNotifier(0);
  //String selectedChartRange = 0;

  //StockSummaryNotifier _summaryNotifier = StockSummaryNotifier(null, null);
  //OrderBookNotifier _orderbookNotifier = OrderBookNotifier(null, null);
  //Future<List<HomeNews>> news;
  static const Duration durationUpdate = Duration(milliseconds: 1000);

  //int _selectedChart = 0;
  //int _selectedDomesticForeign = 0;
  //List<String> _listChipRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];

  // @override
  // bool get wantKeepAlive => true;
  // bool active = false;

  _ScreenStockDetailOverviewState(int tabIndex, TabController tabController,
      {ValueNotifier<bool> visibilityNotifier})
      : super('/stock_detail_overview', tabIndex, tabController,
            notifyStockChange: true, visibilityNotifier: visibilityNotifier);

  void onActive() {
    //print(routeName + ' onActive');
    //startTimer();
    showMoreTradeBookNotifier.value = true;
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, true);
    attentionCodes = context.read(remark2Notifier).getSpecialNotationCodes(
        context.read(primaryStockChangeNotifier).stock.code);
    notation = context.read(remark2Notifier).getSpecialNotation(
        context.read(primaryStockChangeNotifier).stock.code);
    status = context.read(remark2Notifier).getSpecialNotationStatus(
        context.read(primaryStockChangeNotifier).stock.code);
    suspendStock = context.read(suspendedStockNotifier).getSuspended(
        context.read(primaryStockChangeNotifier).stock.code,
        context.read(primaryStockChangeNotifier).stock.defaultBoard);
    if (suspendStock != null) {
      status = StockInformationStatus.Suspended;
    }
    corporateAction = context
        .read(corporateActionEventNotifier)
        .getEvent(context.read(primaryStockChangeNotifier).stock.code);
    corporateActionColor = CorporateActionEvent.getColor(corporateAction);
    doUpdate(pullToRefresh: true);
    startTimer();

    unsubscribe(context, 'onActive');
    Stock stock = context.read(primaryStockChangeNotifier).stock;
    subscribe(context, stock, 'onActive');

    // runPostFrame((){
    //   doUpdate();
    //   startTimer();
    // });

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate();
    //   startTimer();
    // });
  }

  void startTimer() {
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(durationUpdate, (timer) {
        if (active) {
          /* 2021-10-08 MOVING to Streaming
          penyebab kepanggil subscribe and unsubscribe terus
          context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
           */
          doUpdate();
        }
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

  void onInactive() {
    //print(routeName + ' onInactive');
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);
    stopTimer();
    unsubscribe(context, 'onInactive');
  }

  //unsubscribe(context);
  // Stock stock = context.read(primaryStockChangeNotifier).stock;
  // subscribe(context, stock);
  //Future<List<IndexSummary>> indexSummarys;
  Timer timer;

  // bool active = true;

  @override
  void initState() {
    super.initState();

    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    print(routeName + '.initState');

    //listenerOnStockChanged = onStockChanged;
    //_rebuildSectors();
    //news = HttpSSI.fetchNews();

    // Future.delayed(Duration(milliseconds: 500),(){
    //
    //   ChartLineData lineData = new ChartLineData();
    //   //lineData.addOhlcv(new Line(close, prev, date, time))
    //
    //   _chartNotifier.setValue(lineData);
    //
    //
    // });

    // scroll to Overview and OrderBook

    Future.delayed(Duration(milliseconds: 1000), () {
      int autoScroll = context
          .read(propertiesNotifier)
          .properties
          .getInt(ROUTE_SETTINGS, PROP_SELECTED_AUTO_SCROLL, 0);
      if (autoScroll == 1) {
        itemScrollController.scrollTo(
            index: 5,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOutCubic);
      }
    });
  }

  // harus set notifyStockChange = true saat constructor super class
  void onStockChanged(Stock newStock) {
    super.onStockChanged(newStock);
    // ini dipertanyakan, dipindahin  ke StockDetail aja di parent nya
    //context.read(stockSummaryChangeNotifier).setData(null);

    _orderbookNotifier.setValue(null);
    _researchRankNotifier.setValue(null);
    _yourPositionNotifer.setValue(null);
    _chartNotifier.setValue(null);
    _chartOhlcvNotifier.setValue(null);
    lastChartUpdate = null;
    lastPositionUpdate = null;

    if (newStock != null && newStock.isValid()) {
      unsubscribe(context, 'onStockChanged');
      //Stock stock = context.read(primaryStockChangeNotifier).stock;
      subscribe(context, newStock, 'onStockChanged');

      List<Stock> relatedStock =
          InvestrendTheme.storedData.getRelatedStock(newStock.code);
      showOptionRelated = relatedStock != null && relatedStock.length > 1;

      attentionCodes =
          context.read(remark2Notifier).getSpecialNotationCodes(newStock.code);
      notation =
          context.read(remark2Notifier).getSpecialNotation(newStock.code);
      status =
          context.read(remark2Notifier).getSpecialNotationStatus(newStock.code);
      suspendStock = context
          .read(suspendedStockNotifier)
          .getSuspended(newStock.code, newStock.defaultBoard);
      if (suspendStock != null) {
        status = StockInformationStatus.Suspended;
      }
      // if(notation != null && notation.isNotEmpty && suspendStock != null){
      animateSpecialNotationNotifier.value = true;
      // }

      corporateAction =
          context.read(corporateActionEventNotifier).getEvent(newStock.code);
      corporateActionColor = CorporateActionEvent.getColor(corporateAction);
      doUpdate(pullToRefresh: true);

      if (groupStyle != null) {
        groupStyle.reset();
      }
    } else {
      showOptionRelated = false;
    }
  }

  //VoidCallback stockChangeListener;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ScreenStockDetailOverview.didChangeDependencies');
    /*
    if (stockChangeListener != null) {
      context.read(primaryStockChangeNotifier).removeListener(stockChangeListener);
    }

    // if (stockChangeListener == null) {
      stockChangeListener = () {
        if (!mounted) {
          print(routeName + '.stockChangeListener aborted, caused by widget mounted : ' + mounted.toString());
          return;
        }
        String newCode = context.read(primaryStockChangeNotifier).stock.code;
        bool isChanged = !StringUtils.equalsIgnoreCase(newCode, _orderbookNotifier.value.orderbook.code);
        if(isChanged){

          context.read(stockSummaryChangeNotifier).setData(null);

          _orderbookNotifier.setValue(null);
          _researchRankNotifier.setValue(null);
          _yourPositionNotifer.setValue(null);
          lastChartUpdate = null;
          lastPositionUpdate = null;


        }
        notation = context.read(remark2Notifier).getSpecialNotation(newCode);

        print(routeName + '.stockChangeListener mounted : $mounted');
        // if (active) {
          //lastChartUpdate = null;
          doUpdate(pullToRefresh: true);
        // }
      };
      context.read(primaryStockChangeNotifier).addListener(stockChangeListener);
    // }
    */
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(durationUpdate, (timer) {
        if (active) {
          doUpdate();
        }
      });
    }
    // if(active){
    //   unsubscribe(context);
    //   Stock stock = context.read(primaryStockChangeNotifier).stock;
    //   subscribe(context, stock);
    // }
  }

  @override
  void dispose() {
    print('ScreenStockDetailOverview.dispose');
    onDoUpdate.dispose();
    _yourPositionNotifer.dispose();
    _chartRangeNotifier.dispose();
    _orderbookNotifier.dispose();
    showMoreTradeBookNotifier.dispose();
    animateSpecialNotationNotifier.dispose();
    //final container = ProviderContainer();
    //container.read(primaryStockChangeNotifier).removeListener(stockChangeListener);
    _chartNotifier.dispose();
    _chartOhlcvNotifier.dispose();
    if (timer != null) timer.cancel();

    final container = ProviderContainer();
    container
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);
    if (subscribeOrderbook != null) {
      container
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeOrderbook, 'dispose');
    }
    super.dispose();
  }

  Widget accelerationLabel(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final notifier = watch(primaryStockChangeNotifier);
        if (notifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        if (notifier.stock.isAccelerationBoard()) {
          return Container(
            margin: const EdgeInsets.only(
              top: InvestrendTheme.cardPadding,
            ),
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
            width: double.maxFinite,
            color: InvestrendTheme.of(context).accelerationBackground,
            // color: InvestrendTheme.accelerationBackground,
            child: Text(
              'stock_detail_overview_card_detail_special_notation'.tr(),
              style: InvestrendTheme.of(context).support_w400_compact.copyWith(
                  color: InvestrendTheme.of(context).accelerationTextColor),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return SizedBox(
            width: 1.0,
            height: 1.0,
          );
        }
      },
    );
    /*
    return ValueListenableBuilder(
      valueListenable: InvestrendTheme.of(context).stockNotifier,
      builder: (context, Stock value, child) {
        if (InvestrendTheme.of(context).stockNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        if (value.isAccelerationBoard()) {
          return Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
            width: double.maxFinite,
            color: InvestrendTheme.of(context).tileBackground,
            child: Text(
              'stock_detail_overview_card_detail_special_notation'.tr(),
              style: Theme.of(context).textTheme.caption.copyWith(color: InvestrendTheme.of(context).investrendPurple),
            ),
          );
        } else {
          return SizedBox(
            width: 1.0,
            height: 1.0,
          );
        }
      },
    );
     */
  }

  /*
  @override
  Widget build(BuildContext context) {
    return ScreenAware(
      routeName: '/stock_detail_overview',
      onActive: onActive,
      onInactive: onInactive,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            createCardDetailStock(context),
            specialNotationLabel(context),
            //ComponentCreator.divider(context),
            //getTableData(context),
            createCardOverview(context),
            ComponentCreator.divider(context),
            createCardPosition(context),
            ComponentCreator.divider(context),
            createCardOrderbook(context),
            ComponentCreator.divider(context),
            createCardComunity(context),
            ComponentCreator.divider(context),
            // ValueListenableBuilder(
            //   valueListenable: thinksNotifier,
            //   builder: (context, int value, child) {
            //     return createCardThinks(context, value);
            //   },
            // ),
            //createCardThinks(context),
            CardRating(1.3),
            ComponentCreator.divider(context),
            createCardNews(context),

            SizedBox(
              height: 80.0,
            )
          ],
        ),
      ),
    );

  }
  */

  Widget createCardOverviewNew(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(stockSummaryChangeNotifier);
      if (notifier.invalid()) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return CardDataWithFilter<LabelValueColor>(
          margin: EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              //top: InvestrendTheme.cardPaddingVertical,
              bottom: 10.0),
          title: 'stock_detail_overview_card_overview_title'.tr(),
          data: [
            CardDataWithFilterModel<LabelValueColor>(
              name: 'Previous',
              data: LabelValueColor(
                'Previous',
                InvestrendTheme.formatPrice(notifier.summary.prev),
                color: InvestrendTheme.yellowText,
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'Turnover',
              data: LabelValueColor(
                'Turnover',
                InvestrendTheme.formatValue(context, notifier.summary.value),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'Open',
              data: LabelValueColor(
                'Open',
                InvestrendTheme.formatPrice(notifier.summary.open),
                color: notifier.summary.openColor(),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'Lot',
              data: LabelValueColor(
                'Lot',
                InvestrendTheme.formatValue(
                    context, notifier.summary.volume ~/ 100),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'Low',
              data: LabelValueColor(
                'Low',
                InvestrendTheme.formatPrice(notifier.summary.low),
                color: notifier.summary.lowColor(),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'Market Cap',
              data: LabelValueColor(
                'Market Cap',
                InvestrendTheme.formatValue(
                    context, notifier.summary.marketCap),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'High',
              data: LabelValueColor(
                'High',
                InvestrendTheme.formatPrice(notifier.summary.hi),
                color: notifier.summary.hiColor(),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'P/E',
              data: LabelValueColor('P/E', notifier.summary.PE),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'VWAP',
              data: LabelValueColor(
                'VWAP' /*'Avg. Price'*/,
                InvestrendTheme.formatPrice(
                  notifier.summary.averagePrice.toInt(),
                ),
                color: notifier.summary.averagePriceColor(),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'YTD (%)',
              data: LabelValueColor(
                'YTD (%)',
                InvestrendTheme.formatPercentChange(notifier.summary.returnYTD),
                color:
                    InvestrendTheme.changeTextColor(notifier.summary.returnYTD),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'IEP',
              data: LabelValueColor(
                'IEP',
                notifier.summary.iep == 0
                    ? '-'
                    : InvestrendTheme.formatPrice(
                        notifier.summary.iep.toInt(),
                      ),
              ),
            ),
            CardDataWithFilterModel<LabelValueColor>(
              name: 'IEV (Lot)',
              data: LabelValueColor(
                'IEV (Lot)',
                notifier.summary.iev == 0
                    ? '-'
                    : InvestrendTheme.formatComma(notifier.summary.iev ~/ 100),
              ),
            ),
          ],

          /*
          listLeft.add();
          listLeft.add();

          listLeft.add();
          listLeft.add();

          listLeft.add();
          listLeft.add();

          listLeft.add();
          listLeft.add();

          listLeft.add();
          listLeft.add();
          listLeft.add();
          listLeft.add();
          */
        );
      }
    });
  }

  Widget createCardOverview(BuildContext context) {
    return Container(
      // color: Colors.blue,
      margin: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          //top: InvestrendTheme.cardPaddingVertical,
          bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ComponentCreator.subtitleNoButtonMore(
                context,
                'stock_detail_overview_card_overview_title'.tr(),
              ),
              /*
              Container(
                child: FilterPageTest(
                  needsLongPressDraggable: false,
                  listOverview: listOverview,
                ),
              ),
              */

              IconButton(
                onPressed: () {
                  debugPrint("TEST ICON -- - -  - - - -- -  - - -");
                  SortAndFilterPopUp(listOverview).show(
                    context: context,
                    onChanged: (data) {
                      setState(
                        () {
                          listOverview = data;
                        },
                      );
                    },
                  );
                },
                icon: Icon(Icons.filter_list_alt),
              ),
            ],
          ),
          getTableDataOverviewNew(context),
        ],
      ),
    );
  }

  Widget createCardPosition(BuildContext context) {
    // int jumlahLot = 275;
    // double averagePrice = 1000.0;
    // int marketValue = 48224000;
    // double percentPortfolio = 11.23;
    //
    // int todayReturnValue = 0;
    // double todayReturnPercentage = 0.0;
    // int totalReturnValue = 0;
    // double totalReturnPercentage = 0.0;

    return Container(
      margin: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: 10.0),
      child: Column(
        children: [
          // SizedBox(
          //   height: 10.0,
          // ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ComponentCreator.subtitle(
                context,
                'stock_detail_overview_card_position_title'.tr(),
              ),
              //Icon(Icons.info_outline),
              Image.asset(
                'images/icons/information.png',
                height: 13.0,
                width: 13.0,
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          ValueListenableBuilder<YourPosition>(
              valueListenable: _yourPositionNotifer,
              builder: (context, value, child) {
                Widget noWigdet =
                    _yourPositionNotifer.currentState.getNoWidget(onRetry: () {
                  doUpdate(pullToRefresh: true);
                });
                if (noWigdet != null &&
                    (_yourPositionNotifer.currentState.isLoading() ||
                        _yourPositionNotifer.currentState.isError())) {
                  return Container(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.width * 0.8,
                      child: Center(child: noWigdet));
                }
                return getTableDataPosition1(
                    context,
                    value.jumlahLot,
                    value.averagePrice,
                    value.marketValue,
                    value.percentPortfolio);
              }),
          //getTableDataPosition1(context, jumlahLot, averagePrice, marketValue, percentPortfolio),
          //getTableDataPosition2(context),
          //WidgetReturns(3288000, 12.0, 20824000, 76.11),
          //WidgetReturns(todayReturnValue, todayReturnPercentage, totalReturnValue, totalReturnPercentage),
          ValueListenableBuilder<YourPosition>(
              valueListenable: _yourPositionNotifer,
              builder: (context, value, child) {
                Widget noWigdet =
                    _yourPositionNotifer.currentState.getNoWidget(onRetry: () {
                  doUpdate(pullToRefresh: true);
                });
                if (noWigdet != null &&
                    (_yourPositionNotifer.currentState.isLoading() ||
                        _yourPositionNotifer.currentState.isError())) {
                  return SizedBox(
                    width: 1.0,
                  );
                }
                return WidgetReturns(
                  value.todayReturnValue,
                  value.todayReturnPercentage,
                  value.totalReturnValue.truncate(),
                  value.totalReturnPercentage,
                  groupStyle: groupStyle,
                );
              }),
        ],
      ),
    );
  }

  Widget createCardPositionNew(BuildContext context) {
    return ValueListenableBuilder<YourPosition>(
      valueListenable: _yourPositionNotifer,
      builder: (context, value, child) {
        if (_yourPositionNotifer.currentState.isNoData() ||
            _yourPositionNotifer.currentState.isLoading()) {
          return SizedBox(
            width: 1.0,
          );
        }

        Widget noWigdet = _yourPositionNotifer.currentState.getNoWidget(
          onRetry: () {
            doUpdate(pullToRefresh: true);
          },
        );

        List<Widget> childs = [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ComponentCreator.subtitle(
                context,
                'stock_detail_overview_card_position_title'.tr(),
              ),
              //Icon(Icons.info_outline),
              Image.asset(
                'images/icons/information.png',
                height: 13.0,
                width: 13.0,
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ];
        if (noWigdet != null) {
          childs.add(noWigdet);
        } else {
          childs.add(
            getTableDataPosition1(
              context,
              value.jumlahLot,
              value.averagePrice,
              value.marketValue,
              value.percentPortfolio,
            ),
          );
          childs.add(
            WidgetReturns(
              value.todayReturnValue,
              value.todayReturnPercentage,
              value.totalReturnValue.truncate(),
              value.totalReturnPercentage,
              groupStyle: groupStyle,
            ),
          );
        }
        childs.add(
          SizedBox(
            height: 10.0,
          ),
        );
        childs.add(
          ComponentCreator.divider(context),
        );

        return Container(
          margin: const EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral,
            top: InvestrendTheme.cardPaddingVertical,
            //bottom: 10.0,
          ),
          child: Column(
            children: childs,
          ),
        );
      },
    );
  }

  Widget createCardComunity(BuildContext context) {
    const List<String> owners_avatar = <String>[
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
      'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiJinli8IBVIpd5Un3l2uUuMb9iIXihrGobg&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
      'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiJinli8IBVIpd5Un3l2uUuMb9iIXihrGobg&usqp=CAU',
    ];
    const List<String> owners_name = <String>[
      'Putrxi',
      'Philmon',
      'Richy',
      'Stella',
      'Watson',
      'Auri',
      'Putri',
      'Philmon',
      'Richy',
      'Stella',
      'Watson',
      'Auri',
    ];
    if (owners_name.isEmpty) {
      return Text(
        'stock_detail_overview_card_community_text_none'.tr(),
        style: InvestrendTheme.of(context).textLabelStyle,
      );
    }
    String twoName = owners_name.sublist(0, 2).join(',');
    int leftSize = owners_name.length - 2;
    String and = 'stock_detail_overview_card_community_text_and'.tr();
    String owned = 'stock_detail_overview_card_community_text_owned'.tr();
    String text = twoName + ' $and ' + leftSize.toString() + ' $owned';
    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentCreator.subtitle(
              context,
              'stock_detail_overview_card_community_title'.tr(),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                SizedBox(
                  width: 10.0,
                ),
                AvatarListCompetition(
                  size: 25,
                  participants_avatar: owners_avatar,
                  total_participant: owners_avatar.length,
                  showCountingNumber: false,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Container(
                  height: 40.0,
                  width: 1.0,
                  color: Theme.of(context).dividerColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: Container(
                    width: double.maxFinite,
                    child: Text(text,
                        style: InvestrendTheme.of(context).textLabelStyle,
                        maxLines: 2,
                        softWrap: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /*
  Widget createCardOrderbook(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentCreator.subtitle(
              context,
              'stock_detail_overview_card_orderbook_title'.tr(),
            ),
            SizedBox(
              height: 10.0,
            ),
            // getTableDataOrderbookSimple(context),
            // SizedBox(
            //   height: 20.0,
            // ),
            //getTableDataOrderbook(context),
            //WidgetOrderbook(InvestrendTheme.of(context).orderbookNotifier, 6),
            WidgetOrderbook(
              6,
              owner: 'StockDetailOverview',
            ),

            SizedBox(
              height: 10.0,
            ),
            //WidgetOrderbook(InvestrendTheme.orderbookNotifier, 6),

            // CustomPaint(
            //   size: Size(300, 100),
            //   painter: RichyPainter('Test'),
            // ),
          ],
        ),
      ),
    );
  }
  */
  static final Color grayPointColor = Color(0xFFD0D0D0);

  Widget createCardThinks(BuildContext context) {
    //int currentProgress = 4;

    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        //padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding),
        child: LayoutBuilder(builder: (context, constrains) {
          print(
              'createCardThinks constrains ' + constrains.maxWidth.toString());
          const int gridCount = 5;
          double availableWidth = constrains.maxWidth;
          print('createCardThinksavailableWidth $availableWidth');
          double tileWidth = availableWidth / gridCount;
          print('createCardThinks tileWidth $tileWidth');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  int newValue = thinksNotifier.value + 1;
                  if (newValue > 5) {
                    newValue = 1;
                  }
                  thinksNotifier.value = newValue;
                },
                child: ComponentCreator.subtitle(
                  context,
                  'stock_detail_overview_card_expert_title'.tr(),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              //getTableDataOrderbook(context),
              ComponentCreator.roundedContainer(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: InvestrendTheme.of(context)
                                  .tileSmallRoundedRadius *
                              2,
                          right: InvestrendTheme.of(context)
                                  .tileSmallRoundedRadius *
                              2),
                      child: Text(
                        'Rating',
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color:
                                InvestrendTheme.of(context).blackAndWhiteText,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: InvestrendTheme.of(context)
                                  .tileSmallRoundedRadius *
                              2,
                          right: InvestrendTheme.of(context)
                                  .tileSmallRoundedRadius *
                              2),
                      child: Text(
                        'What Wall St. analysts suggest for this stock',
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RatingSlider(1.3),
                    SizedBox(
                      height: 10,
                    ),
                    /*
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       left: InvestrendTheme.of(context).tileSmallRoundedRadius,
                        //       right: InvestrendTheme.of(context).tileSmallRoundedRadius),
                        //   child: Divider(
                        //     thickness: 2.0,
                        //   ),
                        // ),
                        Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 4.0, bottom: 4.0),
                          width: double.maxFinite,
                          height: 2.0,
                          //color: Theme.of(context).dividerColor,
                          color: grayPointColor,
                        ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.end,
                        //   children: [
                        //     point(context, 1, 5, currentProgress == 1, tileWidth),
                        //     point(context, 2, 5, currentProgress == 2, tileWidth),
                        //     point(context, 3, 5, currentProgress == 3, tileWidth),
                        //     point(context, 4, 5, currentProgress == 4, tileWidth),
                        //     point(context, 5, 5, currentProgress == 5, tileWidth),
                        //   ],
                        // ),
                        ValueListenableBuilder(
                          valueListenable: thinksNotifier,
                          builder: (context, int currentProgress, child) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                point(context, 1, 5, currentProgress == 1, tileWidth),
                                point(context, 2, 5, currentProgress == 2, tileWidth),
                                point(context, 3, 5, currentProgress == 3, tileWidth),
                                point(context, 4, 5, currentProgress == 4, tileWidth),
                                point(context, 5, 5, currentProgress == 5, tileWidth),
                              ],
                            );
                          },
                        ),
                      ],
                    ),


                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        pointText(context, 1, 5, 'Strong\nBuy', tileWidth),
                        pointText(context, 2, 5, 'Buy', tileWidth),
                        pointText(context, 3, 5, 'Hold', tileWidth),
                        pointText(context, 4, 5, 'Sell', tileWidth),
                        pointText(context, 5, 5, 'Strong\nSell', tileWidth),
                      ],
                    ),

                     */
                  ],
                ),
                noPadding: true,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget pointText(BuildContext context, int progress, int length, String text,
      double tileWidth) {
    bool first = progress == 1;
    bool last = progress == length;
    print('point  $progress / $length  first : ' +
        first.toString() +
        "  last : " +
        last.toString());
    if (first) {
      return Container(
        padding: EdgeInsets.only(left: 20.0),
        // color: Colors.red,
        width: tileWidth,
        //height: 20.0,
        child: AutoSizeText(
          text,
          maxLines: 2,
          textAlign: TextAlign.left,
          style: InvestrendTheme.of(context).small_w400.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
      );
    } else if (last) {
      return Container(
        padding: EdgeInsets.only(right: 20.0),
        // color: Colors.green,
        width: tileWidth,
        //height: 20.0,
        child: AutoSizeText(
          text,
          maxLines: 2,
          textAlign: TextAlign.right,
          style: InvestrendTheme.of(context).small_w400.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
      );
    } else {
      return Container(
        // color: Colors.orange,
        width: tileWidth,
        //height: 20.0,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: InvestrendTheme.of(context).small_w400.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
      );
    }
  }

  Widget point(BuildContext context, int progress, int length, bool active,
      double tileWidth) {
    bool first = progress == 1;
    bool last = progress == length;
    print('point  $progress / $length  first : ' +
        first.toString() +
        "  last : " +
        last.toString());
    if (first) {
      if (active) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 10.0),
          // color: Colors.red,
          width: tileWidth,
          //height: 20.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(alignment: Alignment.center, children: [
                Image.asset(
                  'images/icons/point_purple.png',
                  width: 30.0,
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    progress.toString(),
                    style: Theme.of(context).textTheme.caption.copyWith(
                        color: InvestrendTheme.of(context)
                            .textWhite /*Colors.white*/),
                  ),
                )
              ]),
              SizedBox(
                height: 2.0,
              ),
              Image.asset(
                'images/icons/dot_purple.png',
                width: 10.0,
                height: 10.0,
              ),
            ],
          ),
        );
      } else {
        return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20.0),
          // color: Colors.red,
          width: tileWidth,
          //height: 20.0,
          child: Image.asset(
            'images/icons/dot_gray.png',
            width: 10.0,
            height: 10.0,
            //color: Theme.of(context).dividerColor,
            color: grayPointColor,
          ),
        );
      }
    } else if (last) {
      if (active) {
        return Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 10.0),
          // color: Colors.green,
          width: tileWidth,
          //height: 20.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(alignment: Alignment.center, children: [
                Image.asset(
                  'images/icons/point_purple.png',
                  width: 30.0,
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    progress.toString(),
                    style: Theme.of(context).textTheme.caption.copyWith(
                        color: InvestrendTheme.of(context)
                            .textWhite /*Colors.white*/),
                  ),
                )
              ]),
              SizedBox(
                height: 2.0,
              ),
              Image.asset(
                'images/icons/dot_purple.png',
                width: 10.0,
                height: 10.0,
              ),
            ],
          ),
        );
      } else {
        return Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.0),
          // color: Colors.green,
          width: tileWidth,
          //height: 20.0,
          child: Image.asset(
            'images/icons/dot_gray.png',
            width: 10.0,
            height: 10.0,
            //color: Theme.of(context).dividerColor,
            color: grayPointColor,
          ),
        );
      }
    } else {
      if (active) {
        return Container(
          alignment: Alignment.center,
          // color: Colors.blue,
          width: tileWidth,
          //height: 20.0,
          child: Column(
            children: [
              Stack(alignment: Alignment.center, children: [
                Image.asset(
                  'images/icons/point_purple.png',
                  width: 30.0,
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    progress.toString(),
                    style: Theme.of(context).textTheme.caption.copyWith(
                        color: InvestrendTheme.of(context)
                            .textWhite /*Colors.white*/),
                  ),
                )
              ]),
              SizedBox(
                height: 2.0,
              ),
              Image.asset(
                'images/icons/dot_purple.png',
                width: 10.0,
                height: 10.0,
              ),
            ],
          ),
        );
      } else {
        return Container(
          alignment: Alignment.center,
          // color: Colors.blue,
          width: tileWidth,
          //height: 20.0,
          child: Image.asset(
            'images/icons/dot_gray.png',
            width: 10.0,
            height: 10.0,
            //color: Theme.of(context).dividerColor,
            color: grayPointColor,
          ),
        );
      }
    }
  }

  void onPressedButtonStockRelated() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return BottomSheetRelatedStock(onDoUpdate);
        });
  }

  void onPressedButtonImportantInformation(BuildContext context,
      List<Remark2Mapping> notation, SuspendStock suspendStock) {
    List<Widget> childs = List.empty(growable: true);
    int count = notation == null ? 0 : notation.length;
    animateSpecialNotationNotifier.value = false;
    double height = 0;
    if (suspendStock != null) {
      String infoSuspend = 'suspended_time_info'.tr();

      DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
      DateFormat dateParser = DateFormat('yyyy-MM-dd');
      DateTime dateTime = dateParser.parseUtc(suspendStock.date);
      print('dateTime : ' + dateTime.toString());
      //print('indexSummary.date : '+data.date+' '+data.time);
      String formatedDate = dateFormatter.format(dateTime);
      //String formatedTime = timeFormatter.format(dateTime);
      //infoSuspend = infoSuspend.replaceAll('#BOARD#', suspendStock.board);
      infoSuspend = infoSuspend.replaceAll('#DATE#', formatedDate);
      infoSuspend = infoSuspend.replaceAll('#TIME#', suspendStock.time);
      //displayTime = infoTime;
      height += 25.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          'Suspended ' + suspendStock.board,
          style: InvestrendTheme.of(context).small_w600,
        ),
      ));

      height += 50.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: RichText(
          text: TextSpan(
              text: '•  ',
              style: InvestrendTheme.of(context).small_w600,
              children: [
                TextSpan(
                  text: infoSuspend,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
        ),
      ));
    }
    bool titleSpecialNotation = true;
    for (int i = 0; i < count; i++) {
      /* SEBELUM AUDIT
      Remark2Mapping remark2 = notation.elementAt(i);
      if(remark2 != null){
        if(remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(remark2.value, style: InvestrendTheme.of(context).small_w600,),
          ));
        }else {
          if(titleSpecialNotation){
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('bottom_sheet_alert_title'.tr(), style: InvestrendTheme.of(context).small_w600,),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      }
      */
      Remark2Mapping remark2 = notation.elementAt(i);
      if (remark2 != null) {
        if (remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              remark2.code + ' : ' + remark2.value,
              style: InvestrendTheme.of(context).small_w600,
            ),
          ));
        } else {
          if (titleSpecialNotation) {
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                'bottom_sheet_alert_title'.tr(),
                style: InvestrendTheme.of(context).small_w600,
              ),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(
                  text: /*remark2.code + " : "*/ '•  ',
                  style: InvestrendTheme.of(context).small_w600,
                  children: [
                    TextSpan(
                      text: remark2.code,
                      style: InvestrendTheme.of(context).small_w600,
                    ),
                    TextSpan(
                      text: ' : ' + remark2.value,
                      style: InvestrendTheme.of(context).small_w400,
                    )
                  ]),
            ),
          ));
        }
      }
    }
    if (childs.isNotEmpty) {
      //showAlert(context, childs, childsHeight: (childs.length * 40).toDouble(), title: ' ');

      showAlert(context, childs, childsHeight: height, title: ' ');
    }
    /*
    if(suspendStock != null){
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: RichText(
          text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
            TextSpan(
              text: 'Suspended on board '+suspendStock.board+' at '+suspendStock.date+' '+suspendStock.time,
              style: InvestrendTheme.of(context).small_w400,
            )
          ]),
        ),
      ));
    }
    if (notation != null && notation.isNotEmpty) {
      notation.forEach((remark2) {
        if (remark2 != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      });
    }
    if(childs.isNotEmpty){
      showAlert(context, childs, childsHeight: (childs.length * 40).toDouble());
    }
     */
  }

  void onPressedButtonCorporateAction() {
    print('onPressedButtonCorporateAction : ' + corporateAction.toString());

    List<Widget> childs = List.empty(growable: true);
    if (corporateAction != null && corporateAction.isNotEmpty) {
      corporateAction.forEach((ca) {
        if (ca != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ca.getInformationWidget(context),
          ));
        }
      });

      showAlert(context, childs,
          childsHeight: (childs.length * 50).toDouble(),
          title: 'Corporate Action');
    }
  }

  String attentionCodes;
  List<Remark2Mapping> notation = List.empty(growable: true);
  StockInformationStatus status;
  SuspendStock suspendStock;
  List<CorporateActionEvent> corporateAction = List.empty(growable: true);
  Color corporateActionColor = Colors.black;

  Widget createCardDetailStock(BuildContext context) {
    //double marginPadding = InvestrendTheme.cardMargin + InvestrendTheme.cardPadding;

    return Container(
      // color: Colors.red,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(builder: (context, watch, child) {
            final notifier = watch(stockSummaryChangeNotifier);
            if (notifier.invalid()) {
              return Center(child: CircularProgressIndicator());
            }

            VoidCallback onImportantInformation;
            if (notation.isNotEmpty || suspendStock != null) {
              onImportantInformation = () =>
                  onPressedButtonImportantInformation(
                      context, notation, suspendStock);
            }
            TextStyle styleAttention = InvestrendTheme.of(context).headline3;
            Size textSize = UIHelper.textSize('ABCD', styleAttention);
            String attentionCodes = context
                .read(remark2Notifier)
                .getSpecialNotationCodes(notifier.stock.code);

            return Container(
              margin: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral,
                  top: InvestrendTheme.cardPadding),
              child: WidgetPrice(
                notifier.stock.code,
                notifier.stock.name,
                notifier.summary.close.toDouble(),
                notifier.summary.change.toDouble(),
                notifier.summary.percentChange,
                false,
                heroTag: 'trade_code',
                onPressedButtonBoard:
                    showOptionRelated ? onPressedButtonStockRelated : null,
                onPressedButtonCorporateAction:
                    (corporateAction == null || corporateAction.isEmpty)
                        ? null
                        : onPressedButtonCorporateAction,
                corporateActionColor: corporateActionColor,
                //onPressedButtonSpecialNotation: notation.isEmpty ? null : () => onPressedButtonSpecialNotation(context, notation),
                onPressedButtonImportantInformation: onImportantInformation,
                stockInformationStatus: status,
                attentionCodes: attentionCodes,
                animateSpecialNotationNotifier: animateSpecialNotationNotifier,
              ),
            );
          }),
          SizedBox(
            height: 10.0,
          ),
          Consumer(builder: (context, watch, child) {
            final notifier = watch(primaryStockChangeNotifier);
            if (notifier.invalid()) {
              return Center(child: CircularProgressIndicator());
            }

            List<String> list = List.empty(growable: true);
            if (!StringUtils.isEmtpy(notifier.stock.sectorName)) {
              list.add(notifier.stock.sectorName);
            }

            if (!list.contains(notifier.stock.subSectorDescription) &&
                !StringUtils.isEmtpy(notifier.stock.subSectorDescription)) {
              list.add(notifier.stock.subSectorDescription);
            }
            return Container(
              margin: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral,
                  top: InvestrendTheme.cardPadding),
              width: double.maxFinite,
              height: 36.0,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: List<Widget>.generate(list.length, (int index) {
                  String text = list.elementAt(index);
                  if (index > 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      //child: ComponentCreator.chip(context, list.elementAt(index)),
                      child: ActionChip(
                          label: Text(text),
                          onPressed: () {
                            showRelatedStockByInfo(context, text);
                          }),
                    );
                  } else {
                    //return ComponentCreator.chip(context, list.elementAt(index));
                    return ActionChip(
                        label: Text(text),
                        onPressed: () {
                          showRelatedStockByInfo(context, text);
                        });
                  }
                }),
              ),
            );

            /*
            return Wrap(
              spacing: 10.0,
              children: List<Widget>.generate(list.length, (int index) {
                return ComponentCreator.chip(context, list.elementAt(index));
              }),
            );
            */
          }),

          SizedBox(
            height: 10.0,
          ),

          Container(
            margin: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding),
            height: 40,
            width: 40,
            child: Center(
              child: Switch(
                value: candleChart,
                onChanged: (value) {
                  setState(() {
                    candleChart = value;
                    print("candleChart value $value");
                  });
                },
                activeTrackColor: Colors.blue,
                activeColor: Colors.white,
                inactiveTrackColor: Colors.blue,
                inactiveThumbColor: Colors.white,
              ),
            ),
          ),
          candleChart == true
              ? Container(
                  margin: const EdgeInsets.only(
                      left: InvestrendTheme.cardPaddingGeneral,
                      right: InvestrendTheme.cardPaddingGeneral,
                      top: InvestrendTheme.cardPadding),
                  child: CardChart(
                    _chartNotifier,
                    _chartRangeNotifier,
                    key: keyChart,
                    ohlcvDataNotifier: _chartOhlcvNotifier,
                    onRetry: () {
                      requestChart();
                    },
                    callbackRange: (index, from, to) {
                      bool isChanged = !StringUtils.equalsIgnoreCase(
                              from, _selectedChartFrom) ||
                          !StringUtils.equalsIgnoreCase(to, _selectedChartTo);
                      print(routeName +
                          ' chart callbackRange index : $index   $from , $to  isChanged : $isChanged');

                      if (isChanged) {
                        lastChartUpdate = null;
                      }
                      _selectedChartFrom = from;
                      _selectedChartTo = to;
                      //doUpdate();
                      requestChart();
                    },
                  ),
                )
              : CardOhlcvChart(
                  _chartOhlcvNotifier,
                  _chartRangeNotifier,
                  onRetry: () {
                    requestCandleChart();
                  },
                  rangeCallback: (index, from, to) {
                    bool isChanged =
                        !StringUtils.equalsIgnoreCase(to, _selectedChartTo);
                    print(routeName +
                        ' chart ohlcvCandle : $from, $to isChanged : $isChanged');
                    if (isChanged) {
                      lastChartUpdate = null;
                    }
                    _selectedChartFrom = from;
                    _selectedChartTo = to;
                    requestCandleChart();
                  },
                  listRangeEnabled: [
                    false,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                    true,
                  ],
                ),

          /*
          chartRangeChips(context),
          SizedBox(
            height: InvestrendTheme.cardMargin,
          ),
          // chart
          Placeholder(
            fallbackWidth: double.maxFinite,
            fallbackHeight: 220.0,
          ),
          SizedBox(
            height: 20.0,
          ),
          */
          // ComponentCreator.divider(context),
          // SizedBox(
          //   height: 20.0,
          // ),
        ],
      ),
    );
  }

  void showRelatedStockByInfo(BuildContext context, String info) {
    List<Stock> members = List.empty(growable: true);
    SectorObject sector;
    for (Stock stock in InvestrendTheme.storedData.listStock) {
      if (stock != null) {
        bool matched =
            info == stock.sectorName || info == stock.subSectorDescription;

        print('matched : $matched  for  info : ' +
            info +
            '   ' +
            stock.code +
            ' sectorName : ' +
            stock.sectorName +
            '  subSectorDescription : ' +
            stock.subSectorDescription);
        if (matched) {
          members.add(stock);
          if (sector == null) {
            sector = SectorObject(stock.sectorText, 0, '', 0.0);
          }
        }
      }
    }
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ScreenListDetail(
            members,
            title: info,
            icon: sector.getIconAssetPath(context),
            color: sector.getColor(context),
          ),
          settings: RouteSettings(name: '/list_detail'),
        ));
  }

  //final NumberFormat formatterNumber = NumberFormat("#,##0.##", "id");
  /*
  Widget progressPerformance(BuildContext context, String label, double change, double percentChange) {
    double progressValue = percentChange.abs() / 100;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyText1,

                //textAlign: TextAlign.start,
              ),
            ),
            width: 65.0,
          ),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
            flex: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                minHeight: 12.0,
                value: progressValue,
                valueColor: new AlwaysStoppedAnimation<Color>(InvestrendTheme.priceTextColor(change)),
                backgroundColor: InvestrendTheme.of(context).tileBackground,
              ),
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          SizedBox(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                //formatterNumber.format(value) + '%',
                InvestrendTheme.formatPercentChange(percentChange),
                style: Theme.of(context).textTheme.bodyText1.copyWith(color: InvestrendTheme.priceTextColor(change)),
                textAlign: TextAlign.end,
              ),
            ),
            width: 65,
          ),
        ],
      ),
    );
  }

  Widget createCardPerformance(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentCreator.subtitle(
              context,
              'search_market_card_performance_title'.tr(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                  valueListenable: _summaryNotifier,
                  builder: (context, value, child) {
                    if (_summaryNotifier.invalid()) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return progressPerformance(context, '1 Day', _summaryNotifier.value.change, _summaryNotifier.value.percentChange);
                  },
                ),
                progressPerformance(context, '1 Week', 0, 0),
                progressPerformance(context, '1 Mo', 0, 0),
                progressPerformance(context, '3 Mo', 0, 0),
                progressPerformance(context, '6 Mo', 0, 0),
                //progressPerformance(context, '1 Year',10, -1.09),
                ValueListenableBuilder(
                  valueListenable: _summaryNotifier,
                  builder: (context, value, child) {
                    if (_summaryNotifier.invalid()) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return progressPerformance(context, '1 Year', _summaryNotifier.value.return52W, _summaryNotifier.value.return52W);
                  },
                ),
                progressPerformance(context, '5 Year', 0, 0),
              ],
            ),
          ],
        ),
      ),
    );
  }
  */
  /*
  Widget chartRangeChips(BuildContext context) {
    return Container(
      //color: Colors.green,
      width: double.maxFinite,
      //margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      //margin: EdgeInsets.all(10.0),
      //padding: EdgeInsets.only(left: 10.0, right: 10.0),
      height: 30.0,

      decoration: BoxDecoration(
        //color: Colors.green,
        color: InvestrendTheme.of(context).tileBackground,
        border: Border.all(
          color: InvestrendTheme.of(context).chipBorder,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(2.0),

        //color: Colors.green,
      ),

      child: Row(
        children: List<Widget>.generate(
          _listChipRange.length,
          (int index) {
            //print(_listChipRange[index]);
            bool selected = _selectedChart == index;
            return Expanded(
              flex: 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedChart = index;
                    });
                  },
                  child: Container(
                    color: selected ? Theme.of(context).accentColor : Colors.transparent,
                    child: Center(
                        child: Text(
                      _listChipRange[index],
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 12.0, color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText),
                    )),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  */
  /*
  Widget domesticForeignRangeChips(BuildContext context) {
    return Container(
      //color: Colors.green,
      width: double.maxFinite,
      //margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      //margin: EdgeInsets.all(10.0),
      //padding: EdgeInsets.only(left: 10.0, right: 10.0),
      height: 30.0,

      decoration: BoxDecoration(
        //color: Colors.green,
        color: InvestrendTheme.of(context).tileBackground,
        border: Border.all(
          color: InvestrendTheme.of(context).chipBorder,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(2.0),

        //color: Colors.green,
      ),

      child: Row(
        children: List<Widget>.generate(
          _listChipRange.length,
          (int index) {
            //print(_listChipRange[index]);
            bool selected = _selectedDomesticForeign == index;
            return Expanded(
              flex: 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDomesticForeign = index;
                    });
                  },
                  child: Container(
                    color: selected ? Theme.of(context).accentColor : Colors.transparent,
                    child: Center(
                        child: Text(
                      _listChipRange[index],
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 12.0, color: selected ? Colors.white : InvestrendTheme.of(context).blackAndWhiteText),
                    )),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  */
  /*
  Widget tileSector(BuildContext context, SectorObject sector, bool first, double width) {
    double left = first ? 0 : 8.0;
    //double right = end ? 0 : 0.0;
    String percentText;
    Color percentChangeTextColor;
    Color percentChangeBackgroundColor;

    percentText = InvestrendTheme.formatPercentChange(sector.percentChange);
    percentChangeTextColor = InvestrendTheme.priceTextColor(sector.percentChange);
    percentChangeBackgroundColor = InvestrendTheme.priceBackgroundColor(sector.percentChange);

    return SizedBox(
      width: width,
      child: MaterialButton(
        elevation: 0.0,
        minWidth: 50.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground,
            width: 0.0,
          ),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sector.code,
                style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sector.member_count.toString() + ' Emiten',
                style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
            Icon(
              Icons.extension,
              color: Theme.of(context).accentColor,
            ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
              decoration: BoxDecoration(
                color: percentChangeBackgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  percentText,
                  style: TextStyle(color: percentChangeTextColor),
                ),
              ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }
  */

  // @override
  // void didPush() {
  //   // Route was pushed onto navigator and is now topmost route.
  //   print('didPush' );
  // }

  // @override
  // void didPopNext() {
  //   // Covering route was popped off the navigator.
  //   print('didPopNext');
  // }
  /*
  void _rebuildSectors() {
    listSectors.clear();
    if (InvestrendTheme.storedData.listIndex.isNotEmpty) {
      InvestrendTheme.storedData.listIndex.forEach((index) {
        if (index != null && index.isSector) {
          listSectors.add(SectorObject(index.code, index.listMembers.length, '/images/icons/action_bell.png', 0.0));
        }
      });
    }
  }
  */

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString());
    if (!active) {
      print(routeName + '.doUpdate aborted active : $active');
      return false;
    }
    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if (!isForeground) {
        print(routeName +
            ' doUpdate ignored isForeground : $isForeground  isVisible : ' +
            isVisible().toString());
        return false;
      }
    }
    Stock stock = context.read(primaryStockChangeNotifier).stock;
    if (stock == null) {
      print(routeName + '.doUpdate aborted stock is NULL');
      return false;
    }
    // if (stock == null || !stock.isValid()) {
    //   Stock stockDefault = InvestrendTheme.storedData.listStock.isEmpty ? null : InvestrendTheme.storedData.listStock.first;
    //   context.read(primaryStockChangeNotifier).setStock(stockDefault);
    //   stock = context.read(primaryStockChangeNotifier).stock;
    // }
    if (pullToRefresh) {
      setNotifierLoading(_researchRankNotifier);
      try {
        final researchRank =
            await InvestrendTheme.datafeedHttp.fetchResearchRank(stock?.code);
        if (researchRank != null) {
          if (mounted) {
            print('Got researchRank : ' + researchRank.toString());
            _researchRankNotifier.setValue(researchRank);
          } else {
            print('ignored researchRank, mounted : $mounted');
          }
        } else {
          setNotifierNoData(_researchRankNotifier);
        }
      } catch (error) {
        setNotifierError(_researchRankNotifier, error);
      }
    }

    if (!mounted) {
      return false;
    }
    /* 2021-10-08 MOVING to Streaming
    context.read(orderBookChangeNotifier).setStock(stock);
     */
    context.read(tradeBookChangeNotifier).setStock(stock);
    //context.read(stockSummaryChangeNotifier).setStock(stock);

    /*
    StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
    bool stockChanged = stock != null && stock != _summaryNotifier.stock;
    if (stockChanged) {
      print('ScreenStockDetailOverview.stockChanged : ' + stockChanged.toString());
      _summaryNotifier.setStock(stock);
      _summaryNotifier.setData(null);
      InvestrendTheme.of(context).orderbookNotifier.setStock(stock);
      InvestrendTheme.of(context).orderbookNotifier.setData(null);
    }
    */
    /*
    var stockSummary;
    try{
      stockSummary = await HttpSSI.fetchStockSummary(stock.code, stock.defaultBoard);
      if (stockSummary != null) {
        print(routeName + ' Future Summary DATA : ' + stockSummary.toString());
        //_summaryNotifier.setData(stockSummary);
        context.read(stockSummaryChangeNotifier).setData(stockSummary);
      } else {
        print(routeName + ' Future Summary NO DATA');
      }
    }catch(error){
      print(routeName + ' Future Summary Error');
      print(error);
    }
     */
    onDoUpdate.notifyListeners();

    StockSummary stockSummary =
        context.read(stockSummaryChangeNotifier).summary;

    bool isIntradayChart = StringUtils.isEmtpy(_selectedChartFrom) ||
        StringUtils.isEmtpy(_selectedChartTo);

    bool canRequestChart = true;
    if (isIntradayChart && (stockSummary == null || stockSummary.prev <= 0)) {
      canRequestChart = false;
    }

    if (canRequestChart) {
      int inSeconds = lastChartUpdate == null
          ? -1
          : DateTime.now().difference(lastChartUpdate).inSeconds;
      bool chartAllowedRefresh =
          lastChartUpdate == null || (isIntradayChart && inSeconds > 10);
      if (chartAllowedRefresh || pullToRefresh) {
        lastChartUpdate = DateTime.now();
        if (_chartNotifier.value.isEmpty() || pullToRefresh) {
          setNotifierLoading(_chartNotifier);
        }

        print(routeName +
            ' Requesting chartCandle update at ' +
            lastChartUpdate.toString());

        try {
          final chartCandle = await InvestrendTheme.datafeedHttp
              .fetchChartOhlcv(stock.code, false,
                  from: _selectedChartFrom, to: _selectedChartTo);
          if (chartCandle != null &&
              chartCandle.isValidResponse(
                  stock.code, _selectedChartFrom, _selectedChartTo)) {
            bool intraday = _chartRangeNotifier.value == 0;
            if (stockSummary != null && intraday) {
              chartCandle.setPrev(stockSummary.prev.toDouble());
            }
            chartCandle.normalize(middlePrev: intraday);

            print(routeName +
                ' Future chartLine DATA : ' +
                chartCandle.toString() +
                '  intraday : $intraday');
            if (chartCandle != null) {
              if (mounted) {
                _chartOhlcvNotifier.setValue(chartCandle);
              }
            } else {
              setNotifierNoData(_chartOhlcvNotifier);
            }
          } else {
            print(routeName + ' Future chartCandle NOT VALID');
          }
        } catch (errorChart) {
          print(routeName + ' Future chartCandle Error');
          print(errorChart);
          setNotifierError(_chartOhlcvNotifier, errorChart);
        }

        print(routeName +
            ' Requesting chartLine update  at ' +
            lastChartUpdate.toString());
        try {
          final chartLine = await InvestrendTheme.datafeedHttp.fetchChartLine(
              stock.code, false,
              from: _selectedChartFrom, to: _selectedChartTo);
          if (chartLine != null &&
              chartLine.isValidResponse(
                  stock.code, _selectedChartFrom, _selectedChartTo)) {
            bool intraday = _chartRangeNotifier.value == 0;
            if (stockSummary != null && intraday) {
              //chartLine.setPrev(stockSummary.prev.toDouble(), middlePrev: intraday);
              chartLine.setPrev(stockSummary.prev.toDouble());
            }
            // harus di normalise
            chartLine.normalize(middlePrev: intraday);

            print(routeName +
                ' Future chartLine DATA : ' +
                chartLine.toString() +
                '  intraday : $intraday');
            if (chartLine != null) {
              if (mounted) {
                _chartNotifier.setValue(chartLine);
              }
            } else {
              setNotifierNoData(_chartNotifier);
            }
          } else {
            print(routeName + ' Future chartLine NOT VALID');
          }
        } catch (errorChart) {
          print(routeName + ' Future chartLine Error');
          print(errorChart);
          setNotifierError(_chartNotifier, errorChart);
        }
      } else {
        print(routeName +
            ' Skip chartLine update ' +
            lastChartUpdate.toString() +
            '  inSeconds : $inSeconds  isIntradayChart : $isIntradayChart');
      }
    } else {
      if (_chartNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_chartNotifier);
      }
      print(routeName +
          ' Skip chartLine update  waiting for summary and prev  isIntradayChart : $isIntradayChart');
    }

    /* 2021-10-08 MOVING to Streaming
    if (_orderbookNotifier.value.isEmpty()) {
      setNotifierLoading(_orderbookNotifier);
    }

    try {
      final orderbook = await HttpSSI.fetchOrderBook(stock.code, stock.defaultBoard);
      if (orderbook != null) {
        print(routeName + ' Future Orderbook DATA : ' + orderbook.toString());
        //InvestrendTheme.of(context).orderbookNotifier.setData(orderbook);
        if (mounted) {
          orderbook.generateDataForUI(10, context: context);

          context.read(orderBookChangeNotifier).setData(orderbook);

          OrderbookData orderbookData = OrderbookData();
          orderbookData.orderbook = orderbook;
          orderbookData.prev = stockSummary != null ? stockSummary.prev : 0;
          orderbookData.close = stockSummary != null ? stockSummary.close : 0;
          _orderbookNotifier.setValue(orderbookData);
        }
      } else {
        print(routeName + ' Future Orderbook NO DATA');
        setNotifierNoData(_orderbookNotifier);
      }
    } catch (errorOrderBook) {
      print(routeName + ' Future Orderbook Error');
      print(errorOrderBook);
      setNotifierError(_orderbookNotifier, errorOrderBook);
    }
     */

    int gapPosition = lastPositionUpdate == null
        ? maxPositionSeconds
        : DateTime.now().difference(lastPositionUpdate).inSeconds;
    if (gapPosition >= maxPositionSeconds) {
      lastPositionUpdate = DateTime.now();
      int selected = context.read(accountChangeNotifier).index;
      Account account =
          context.read(dataHolderChangeNotifier).user.getAccount(selected);
      if (account != null) {
        if (_yourPositionNotifer.value.isEmpty() || pullToRefresh) {
          setNotifierLoading(_yourPositionNotifer);
        }
        try {
          print(routeName + ' try stockPosition');
          final stockPosition = await InvestrendTheme.tradingHttp
              .stock_position(
                  account.brokercode,
                  account.accountcode,
                  context.read(dataHolderChangeNotifier).user.username,
                  InvestrendTheme.of(context).applicationPlatform,
                  InvestrendTheme.of(context).applicationVersion);
          DebugWriter.information(routeName +
              ' Got stockPosition ' +
              stockPosition.accountcode +
              '   stockList.size : ' +
              stockPosition.stockListSize().toString());
          print(stockPosition.toString());

          StockPositionDetail detail =
              stockPosition.getStockPositionDetailByCode(stock.code);
          if (mounted) {
            YourPosition your = YourPosition();
            if (detail != null) {
              //context.read(sellLotAvgChangeNotifier).update(detail.netBalance.toInt(), detail.avgPrice);
              your.code = detail.stockCode;
              your.jumlahLot = detail.netBalance;
              your.averagePrice = detail.avgPrice;
              your.marketValue = detail.marketVal;

              // belum diisi
              /*
              if(stockPosition.totalMarket > 0){
                your.percentPortfolio = (detail.marketVal / stockPosition.totalMarket) * 100; // nanti di ganti ama yg punya emil
              }else{
                your.percentPortfolio = 0;
              }
              */
              your.percentPortfolio = detail.portfolioPct;

              your.todayReturnValue = detail.todayGL.toInt();
              your.todayReturnPercentage = detail.todayGLPct;

              your.totalReturnValue = detail.stockGL;
              your.totalReturnPercentage = detail.stockGLPct;
              _yourPositionNotifer.setValue(your);
            } else {
              //your.code = stock.code;
              _yourPositionNotifer.setValue(your);
            }
            //_yourPositionNotifer.setValue(your);
          }
        } catch (e) {
          DebugWriter.information(
              routeName + ' stockPosition Exception : ' + e.toString());
          setNotifierError(_yourPositionNotifer, e);
          handleNetworkError(context, e);
        }
      } else {
        setNotifierNoData(_yourPositionNotifer);
      }
    } else {
      DebugWriter.information(
          routeName + ' stockPosition skip gapPosition : $gapPosition');
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  void requestCandleChart() async {
    lastChartUpdate = DateTime.now();
    print(routeName +
        'Requesting chartCandle update at ' +
        lastChartUpdate.toString());
    setNotifierLoading(_chartOhlcvNotifier);
    try {
      Stock stock = context.read(stockSummaryChangeNotifier).stock;
      StockSummary stockSummary =
          context.read(stockSummaryChangeNotifier).summary;
      final chartCandle = await InvestrendTheme.datafeedHttp.fetchChartOhlcv(
          stock.code, false,
          from: _selectedChartFrom, to: _selectedChartTo);
      if (chartCandle != null &&
          chartCandle.isValidResponse(
              stock.code, _selectedChartFrom, _selectedChartTo)) {
        bool intraday = _chartRangeNotifier.value == 0;
        if (stockSummary != null && intraday) {
          chartCandle.setPrev(stockSummary.prev.toDouble());
        }

        chartCandle.normalize(middlePrev: intraday);
        print(routeName +
            ' Future chartCandle DATA : ' +
            chartCandle.toString() +
            ' intraday : $intraday');

        if (chartCandle != null) {
          if (mounted) {
            _chartOhlcvNotifier.setValue(chartCandle);
          }
        } else {
          setNotifierNoData(_chartOhlcvNotifier);
        }
      } else {
        print(routeName + ' Future chartCandle NOT VALID');
      }
    } catch (errorChart) {
      print(routeName + ' Future chartCandle Error');
      print(errorChart);
      setNotifierError(_chartOhlcvNotifier, errorChart);
    }
  }

  void requestChart() async {
    lastChartUpdate = DateTime.now();
    print(routeName +
        ' Requesting chartLine update  at ' +
        lastChartUpdate.toString());
    setNotifierLoading(_chartNotifier);
    try {
      Stock stock = context.read(stockSummaryChangeNotifier).stock;
      StockSummary stockSummary =
          context.read(stockSummaryChangeNotifier).summary;
      final chartLine = await InvestrendTheme.datafeedHttp.fetchChartLine(
          stock.code, false,
          from: _selectedChartFrom, to: _selectedChartTo);
      if (chartLine != null &&
          chartLine.isValidResponse(
              stock.code, _selectedChartFrom, _selectedChartTo)) {
        bool intraday = _chartRangeNotifier.value == 0;
        if (stockSummary != null && intraday) {
          chartLine.setPrev(stockSummary.prev.toDouble());
        }
        // harus di normalise
        chartLine.normalize(middlePrev: intraday);
        print(routeName +
            ' Future chartLine DATA : ' +
            chartLine.toString() +
            '  intraday : $intraday');

        if (chartLine != null) {
          if (mounted) {
            _chartNotifier.setValue(chartLine);
          }
        } else {
          setNotifierNoData(_chartNotifier);
        }
      } else {
        print(routeName + ' Future chartLine NOT VALID');
      }
    } catch (errorChart) {
      print(routeName + ' Future chartLine Error');
      print(errorChart);
      setNotifierError(_chartNotifier, errorChart);
    }
  }

/*
  List<SectorObject> listSectors = List<SectorObject>.empty(growable: true);

  // List<SectorObject> listSectors = <SectorObject>[
  //   SectorObject('Agriculture', 25, '/images/icons/action_bell.png', 0.14),
  //   SectorObject('Mining', 21, '/images/icons/action_bell.png', 10.14),
  //   SectorObject('Consumer', 25, '/images/icons/action_bell.png', -0.14),
  //   SectorObject('Property', 18, '/images/icons/action_bell.png', -10.14),
  //   SectorObject('Finance', 7, '/images/icons/action_bell.png', 0.14),
  //   SectorObject('Infrastructure', 663, '/images/icons/action_bell.png', -8.14),
  //   SectorObject('Constructor', 11, '/images/icons/action_bell.png', 0.14),
  //   SectorObject('Market', 398, '/images/icons/action_bell.png', 28.14),
  // ];

  Widget gridWorldIndices(BuildContext context, List<SectorObject> list) {
    List<Widget> widgets = List<Widget>.empty(growable: true);

    int countData = list.length;
    for (int i = 0; i < countData; i++) {
      int iPlus = i + 1;
      if (iPlus < countData) {
        widgets.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //tileWorlIndices(context, list[i], true),
            SizedBox(
              width: InvestrendTheme.cardMargin,
            ),
            //tileWorlIndices(context, list[iPlus], false)
          ],
        ));
        i = iPlus;
      } else {
        widgets.add(Row(
          children: [
            //tileWorlIndices(context, list[i], true),
            SizedBox(
              width: InvestrendTheme.cardMargin,
            ),
            Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ),
          ],
        ));
      }
      widgets.add(SizedBox(
        height: InvestrendTheme.cardMargin,
      ));
    }
    print('richy widgets size : ' + widgets.length.toString());

    return Column(
      children: widgets,
    );
  }
  */
/*
  Widget gridSectors(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 3;
      double availableWidth = constrains.maxWidth - (InvestrendTheme.cardMargin * 2);
      print('availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      print('tileWidth $tileWidth');
      List<Widget> columns = List<Widget>.empty(growable: true);

      int countData = listSectors.length;
      for (int i = 0; i < countData; i++) {
        int iPlus2 = i + 2;
        int iPlus1 = i + 1;

        List<Widget> rows = List<Widget>.empty(growable: true);
        for (int x = 0; x < 3; x++) {
          int index = x + i;
          if (x > 0) {
            rows.add(SizedBox(
              width: InvestrendTheme.cardMargin,
            ));
          }
          if (index < countData) {
            rows.add(tileSector(
              context,
              listSectors[index],
              true,
              tileWidth,
            ));
          } else {
            rows.add(Expanded(
              flex: 1,
              child: Center(child: Text(' ')),
            ));
          }
        }
        columns.add(Row(
          children: rows,
        ));
        columns.add(SizedBox(
          height: InvestrendTheme.cardMargin,
        ));
        i += 2;
      }

      return Column(
        children: columns,
      );
    });
  }
  */
/*
  Widget createCardSector(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentCreator.subtitle(
              context,
              'search_market_card_sector_title'.tr(),
            ),
            SizedBox(
              height: InvestrendTheme.cardMargin,
            ),
            /*
            FutureBuilder<List<IndexSummary>>(
              future: indexSummarys,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print('snapshot.data.length = '+snapshot.data.length.toString());
                  //return Text(snapshot.data.length.toString(), style: Theme.of(context).textTheme.bodyText2,);
                  if (snapshot.data.length > 0) {

                    snapshot.data.forEach((indexSummary) {
                      if(indexSummary != null){
                        print(indexSummary.toString());
                        int countSector = listSectors.length;
                        for(int i = 0; i <countSector; i++){
                          SectorObject sector = listSectors.elementAt(i);
                          if(StringUtils.equalsIgnoreCase(indexSummary.code, sector.code)){
                            sector.percentChange = indexSummary.percentChange;
                            break;
                          }
                        }
                      }

                    });

                    return gridSectors(context);


                    //return gridWorldIndices(context, snapshot.data);
                  } else {
                    return Center(
                        child: Text(
                          'No Data',
                          style: Theme.of(context).textTheme.bodyText2,
                        ));
                  }
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("${snapshot.error}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Theme.of(context).errorColor)));
                }

                // By default, show a loading spinner.
                return Center(child: CircularProgressIndicator());
                //return listSectors.length > 0 ? gridSectors(context) : Center(child: CircularProgressIndicator());
              },
            ),
            */
            listSectors.length > 0 ? gridSectors(context) : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
  */
/*
  Widget createCardLocalForeign(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ComponentCreator.subtitle(
                    context,
                    'search_market_card_domestic_foreign_title'.tr(),
                  ),
                ),
                MaterialButton(
                    elevation: 0.0,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: InvestrendTheme.of(context).tileBackground,
                    child: Row(
                      children: [
                        Text(
                          'All Market',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onPressed: () {
                      InvestrendTheme.of(context).showSnackBar(context, 'Action choose Market');
                    }),
              ],
            ),
            SizedBox(
              height: InvestrendTheme.cardMargin,
            ),
            domesticForeignRangeChips(context),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        '',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'Local',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'Foreign',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'Buy',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _summaryNotifier,
                      builder: (context, value, child) {
                        if (_summaryNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_summaryNotifier.value.domesticBuyerValue),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _summaryNotifier,
                      builder: (context, value, child) {
                        if (_summaryNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_summaryNotifier.value.foreignBuyerValue),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
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
            Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              color: InvestrendTheme.of(context).tileBackground,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        'Sell',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _summaryNotifier,
                      builder: (context, value, child) {
                        if (_summaryNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_summaryNotifier.value.domesticSellerValue),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _summaryNotifier,
                      builder: (context, value, child) {
                        if (_summaryNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_summaryNotifier.value.foreignSellerValue),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal),
                          alignment: Alignment.centerRight,
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
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Net',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _summaryNotifier,
                      builder: (context, value, child) {
                        if (_summaryNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        int netDomestic = _summaryNotifier.value.domesticBuyerValue - _summaryNotifier.value.domesticSellerValue;
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(netDomestic),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.normal,
                                color: InvestrendTheme.priceTextColor(netDomestic.toDouble()),
                              ),
                          alignment: Alignment.centerRight,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _summaryNotifier,
                      builder: (context, value, child) {
                        if (_summaryNotifier.invalid()) {
                          return Center(child: CircularProgressIndicator());
                        }
                        int netForeign = _summaryNotifier.value.foreignBuyerValue - _summaryNotifier.value.foreignSellerValue;
                        return ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(netForeign),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.normal,
                                color: InvestrendTheme.priceTextColor(netForeign.toDouble()),
                              ),
                          alignment: Alignment.centerRight,
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
            Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              color: InvestrendTheme.of(context).tileBackground,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(
                        '% Turnover',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: ComponentCreator.textFit(
                        context,
                        '83%',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        alignment: Alignment.centerRight,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                  Expanded(
                      flex: 1,
                      child: ComponentCreator.textFit(
                        context,
                        '17%',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                        alignment: Alignment.centerRight,
                      )),
                  SizedBox(
                    width: InvestrendTheme.cardMargin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   */

  Widget tableCellLabel(BuildContext context, String text) {
    TextStyle style = InvestrendTheme.of(context)
        .small_w400_compact
        .copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: ComponentCreator.textFit(
        context,
        text,
        alignment: Alignment.centerLeft,
        style: style,
      ),
    );
  }

  Widget tableCellValue(BuildContext context, String text, {Color color}) {
    TextStyle style = InvestrendTheme.of(context).regular_w600_compact;
    if (color != null) {
      style = style.copyWith(color: color);
    }
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: ComponentCreator.textFit(
        context,
        text,
        alignment: Alignment.centerLeft,
        style: style,
      ),
    );
  }

  Widget getTableDataPosition1(BuildContext context, double jumlahLot,
      double averagePrice, double marketValue, double percentPortfolio) {
    // int jumlahLot = 275;
    // double averagePrice = 1000.0;
    // int marketValue = 48224000;
    // double percentPortfolio = 11.23;

    TableRow row0 = TableRow(children: [
      tableCellLabel(
          context, 'stock_detail_overview_card_position_lot_quantity'.tr()),
      tableCellLabel(
        context,
        'stock_detail_overview_card_position_average_price'.tr(),
      ),
    ]);
    TableRow row1 = TableRow(children: [
      tableCellValue(
          context, InvestrendTheme.formatComma(jumlahLot.truncate())),
      tableCellValue(
        context,
        InvestrendTheme.formatMoneyDouble(averagePrice, prefixRp: true),
      ),
    ]);
    TableRow row2 = TableRow(children: [
      tableCellLabel(
          context, 'stock_detail_overview_card_position_market_value'.tr()),
      tableCellLabel(
        context,
        'stock_detail_overview_card_position_percent_portfolio'.tr(),
      ),
    ]);
    TableRow row3 = TableRow(children: [
      tableCellValue(
          context, InvestrendTheme.formatComma(marketValue.truncate())),
      tableCellValue(
        context,
        InvestrendTheme.formatPriceDouble(percentPortfolio),
      ),
    ]);
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //border: TableBorder.all(color: Colors.black),
      columnWidths: {0: FractionColumnWidth(.5)},
      children: [
        row0,
        row1,
        row2,
        row3,
      ],
    );
  }

  Widget getTableDataPosition2(BuildContext context) {
    int todayReturnValue = 3288000;
    double todayReturnPercentage = 12.0;

    int totalReturnValue = 20824000;
    double totalReturnPercentage = 76.11;

    String todayValue = InvestrendTheme.formatMoney(todayReturnValue,
        prefixPlus: true, prefixRp: true);
    String totalValue = InvestrendTheme.formatMoney(totalReturnValue,
        prefixPlus: true, prefixRp: true);
    String todayPercentage = ' (' +
        InvestrendTheme.formatPercentChange(todayReturnPercentage,
            sufixPercent: true) +
        ')';
    String totalPercentage = ' (' +
        InvestrendTheme.formatPercentChange(totalReturnPercentage,
            sufixPercent: true) +
        ')';
    Color colorToday = InvestrendTheme.priceTextColor(todayReturnValue);
    Color colorTotal = InvestrendTheme.priceTextColor(totalReturnValue);

    TableRow row0 = TableRow(children: [
      tableCellLabel(
          context, 'stock_detail_overview_card_position_todays_return'.tr()),
      FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            tableCellValue(context, todayValue, color: colorToday),
            tableCellLabel(context, todayPercentage),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    ]);
    TableRow row1 = TableRow(children: [
      tableCellLabel(
        context,
        'stock_detail_overview_card_position_total_return'.tr(),
      ),
      FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            tableCellValue(context, totalValue, color: colorTotal),
            tableCellLabel(context, totalPercentage),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    ]);
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //border: TableBorder.all(color: Colors.black),
      columnWidths: {0: FractionColumnWidth(.4)},
      children: [
        row0,
        row1,
      ],
    );
  }

  Widget tableCellRight(BuildContext context, String text,
      {double padding = 0.0, Color color}) {
    TextStyle textStyle;
    if (color == null) {
      textStyle = InvestrendTheme.of(context).small_w400_compact;
    } else {
      textStyle =
          InvestrendTheme.of(context).small_w400_compact.copyWith(color: color);
    }
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget tableCellLeftSupport(BuildContext context, String text,
      {double padding = 0.0}) {
    return Padding(
      padding: EdgeInsets.only(left: padding, top: 10.0, bottom: 10.0),
      child: Text(
        text,
        maxLines: 1,
        style: InvestrendTheme.of(context).textLabelStyle,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget getTableDataOverview(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(stockSummaryChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }
      const padding = 15.0;
      TableRow row0 = TableRow(children: [
        tableCellLeftSupport(context, 'Previous'),
        tableCellRight(
            context, InvestrendTheme.formatPrice(notifier.summary.prev),
            color: InvestrendTheme.yellowText, padding: padding),
        tableCellLeftSupport(context, 'Turnover', padding: padding),
        tableCellRight(
          context,
          InvestrendTheme.formatValue(context, notifier.summary.value),
        ),
      ]);

      TableRow row1 = TableRow(children: [
        tableCellLeftSupport(context, 'Open'),
        tableCellRight(
            context, InvestrendTheme.formatPrice(notifier.summary.open),
            color: InvestrendTheme.priceTextColor(notifier.summary.open,
                prev: notifier.summary.prev),
            padding: padding),
        tableCellLeftSupport(context, 'Vol (Shares)', padding: padding),
        tableCellRight(
          context,
          InvestrendTheme.formatValue(context, notifier.summary.volume),
        ),
      ]);
      TableRow row2 = TableRow(children: [
        tableCellLeftSupport(context, 'Low'),
        tableCellRight(
            context, InvestrendTheme.formatPrice(notifier.summary.low),
            color: InvestrendTheme.priceTextColor(notifier.summary.low,
                prev: notifier.summary.prev),
            padding: padding),
        tableCellLeftSupport(context, 'Market Cap', padding: padding),
        tableCellRight(
          context,
          InvestrendTheme.formatValue(context, notifier.summary.marketCap),
        ),
      ]);

      TableRow row3 = TableRow(children: [
        tableCellLeftSupport(context, 'High'),
        tableCellRight(
            context, InvestrendTheme.formatPrice(notifier.summary.hi),
            color: InvestrendTheme.priceTextColor(notifier.summary.hi,
                prev: notifier.summary.prev),
            padding: padding),
        //tableCellLeftSupport(context, 'PER', padding: padding),
        tableCellLeftSupport(context, 'P/E', padding: padding),
        tableCellRight(
          context,
          notifier.summary.PE,
        ),
      ]);
      TableRow row4 = TableRow(children: [
        tableCellLeftSupport(context, 'Avg. Price'),
        tableCellRight(context,
            InvestrendTheme.formatPrice(notifier.summary.averagePrice.toInt()),
            color: InvestrendTheme.priceTextColor(
                notifier.summary.averagePrice.toInt(),
                prev: notifier.summary.prev),
            padding: padding),
        tableCellLeftSupport(context, 'YTD (%)', padding: padding),
        tableCellRight(context,
            InvestrendTheme.formatPercentChange(notifier.summary.returnYTD),
            color: InvestrendTheme.changeTextColor(notifier.summary.returnYTD)),
      ]);
      return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        //border: TableBorder.all(color: Colors.black),
        //columnWidths: {0: FractionColumnWidth(.2)},
        columnWidths: {
          0: FractionColumnWidth(.25),
          1: FractionColumnWidth(.25),
          2: FractionColumnWidth(.25),
          3: FractionColumnWidth(.25),
        },

        children: [
          row0,
          row1,
          row2,
          row3,
          row4,
        ],
      );
    });

    /*
    StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
    return ValueListenableBuilder(
      valueListenable: _summaryNotifier,
      builder: (context, StockSummary value, child) {
        if (_summaryNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        const padding = 15.0;
        TableRow row0 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'Previous'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(value.prev), color: InvestrendTheme.yellowText, padding: padding),
          ComponentCreator.tableCellLeft(context, 'Turnover', padding: padding),
          ComponentCreator.tableCellRight(
            context,
            '????',
          ),
        ]);

        TableRow row1 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'Open'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(value.open),
              color: InvestrendTheme.priceTextColor(value.open, prev: value.prev), padding: padding),
          ComponentCreator.tableCellLeft(context, 'Vol (Shares)', padding: padding),
          ComponentCreator.tableCellRight(
            context,
            InvestrendTheme.formatValue(value.volume),
          ),
        ]);
        TableRow row2 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'Low'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(value.low),
              color: InvestrendTheme.priceTextColor(value.low, prev: value.prev), padding: padding),
          ComponentCreator.tableCellLeft(context, 'Market Cap', padding: padding),
          ComponentCreator.tableCellRight(
            context,
            InvestrendTheme.formatValue(value.marketCap),
          ),
        ]);

        TableRow row3 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'High'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(value.hi),
              color: InvestrendTheme.priceTextColor(value.hi, prev: value.prev), padding: padding),
          ComponentCreator.tableCellLeft(context, 'PER', padding: padding),
          ComponentCreator.tableCellRight(
            context,
            '????',
          ),
        ]);
        TableRow row4 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'Avg. Price'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(value.averagePrice.toInt()),
              color: InvestrendTheme.priceTextColor(value.averagePrice.toInt(), prev: value.prev), padding: padding),
          ComponentCreator.tableCellLeft(context, 'YTD (%)', padding: padding),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPercentChange(value.returnYTD),
              color: InvestrendTheme.changeTextColor(value.returnYTD)),
        ]);
        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border: TableBorder.all(color: Colors.black),
          columnWidths: {0: FractionColumnWidth(.2)},
          children: [
            row0,
            row1,
            row2,
            row3,
            row4,
          ],
        );
      },
    );
    */
  }

  Widget rowOverview(
      BuildContext context,
      AutoSizeGroup groupLabel,
      AutoSizeGroup groupValue,
      String labelLeft,
      Widget valueLeft,
      String labelRight,
      Widget valueRight) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  labelLeft,
                  maxLines: 1,
                  style: InvestrendTheme.of(context).textLabelStyle,
                  textAlign: TextAlign.left,
                ),
                Spacer(
                  flex: 1,
                ),
                valueLeft,
              ],
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  labelRight,
                  maxLines: 1,
                  style: InvestrendTheme.of(context).textLabelStyle,
                  textAlign: TextAlign.left,
                ),
                Spacer(
                  flex: 1,
                ),
                valueRight,
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getTableDataOverviewNew(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(stockSummaryChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }
      //const padding = 15.0;

      return LayoutBuilder(builder: (context, constraints) {
        double marginSection = 25.0;
        //double marginContent = 10.0;
        double maxWidthSection =
            ((constraints.maxWidth - marginSection) / 2); // - marginContent;

        TextStyle labelStyle = InvestrendTheme.of(context).textLabelStyle;
        TextStyle valueStyle = InvestrendTheme.of(context).small_w400_compact;

        List<LabelValueColor> listLeft = List.empty(growable: true);

        listLeft.add(LabelValueColor(
            'Previous', InvestrendTheme.formatPrice(notifier.summary.prev),
            color: InvestrendTheme.yellowText));
        listLeft.add(LabelValueColor('Turnover',
            InvestrendTheme.formatValue(context, notifier.summary.value)));

        listLeft.add(LabelValueColor(
            'Open', InvestrendTheme.formatPrice(notifier.summary.open),
            color: notifier.summary.openColor()));
        listLeft.add(LabelValueColor(
            'Lot',
            InvestrendTheme.formatValue(
                context, notifier.summary.volume ~/ 100)));

        listLeft.add(LabelValueColor(
            'Low', InvestrendTheme.formatPrice(notifier.summary.low),
            color: notifier.summary.lowColor()));
        listLeft.add(LabelValueColor('Market Cap',
            InvestrendTheme.formatValue(context, notifier.summary.marketCap)));

        listLeft.add(LabelValueColor(
            'High', InvestrendTheme.formatPrice(notifier.summary.hi),
            color: notifier.summary.hiColor()));
        listLeft.add(LabelValueColor('P/E', notifier.summary.PE));

        listLeft.add(LabelValueColor('VWAP' /*'Avg. Price'*/,
            InvestrendTheme.formatPrice(notifier.summary.averagePrice.toInt()),
            color: notifier.summary.averagePriceColor()));
        listLeft.add(LabelValueColor('YTD (%)',
            InvestrendTheme.formatPercentChange(notifier.summary.returnYTD),
            color:
                InvestrendTheme.changeTextColor(notifier.summary.returnYTD)));
        listLeft.add(LabelValueColor(
            'IEP',
            notifier.summary.iep == 0
                ? '-'
                : InvestrendTheme.formatPrice(notifier.summary.iep.toInt())));
        listLeft.add(LabelValueColor(
            'IEV (Lot)',
            notifier.summary.iev == 0
                ? '-'
                : InvestrendTheme.formatComma(notifier.summary.iev ~/ 100)));

        int count = listLeft.length;
        List<LabelValueColor> filtered = [];
        List<TextStyle> styles = [labelStyle, valueStyle];
        for (int i = 0; i < count; i++) {
          LabelValueColor leftLVC = listLeft.elementAt(i);
          // LabelValueColor rightLVC = listRight.elementAt(i);
          styles = UIHelper.calculateFontSizes(
              context, styles, maxWidthSection, [leftLVC.label, leftLVC.value]);
          // styles = UIHelper.calculateFontSizes(context, styles, maxWidthSection,
          //     [rightLVC.label, rightLVC.value]);
          //
        }

        // listOverview.where((e) => e.status == true).toList().forEach((f) {
        //   filtered.add(listLeft.where((g) => g.label == f.name).first);
        // });

        listOverview.where((e) => e.status == true).toList().forEach((f) {
          listLeft.forEach((d) {
            if (d.label == f.name) {
              filtered.add(d);
            }
          });
        });

        labelStyle = styles.elementAt(0);
        valueStyle = styles.elementAt(1);

        List<Widget> childs = List.empty(growable: true);

        childs.add(
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 22,
            children: List.generate(
              filtered.length,
              (index) {
                {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: maxWidthSection,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          filtered[index].label,
                          maxLines: 1,
                          style: labelStyle,
                          textAlign: TextAlign.left,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Text(
                          filtered[index].value,
                          maxLines: 1,
                          style: filtered[index].color == null
                              ? valueStyle
                              : valueStyle.copyWith(
                                  color: filtered[index].color),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        );

        if (!StringUtils.isEmtpy(notifier.summary.tradeDate) &&
            !StringUtils.isEmtpy(notifier.summary.tradeTime)) {
          /*
          String displayTime = notifier.summary.tradeDate +' '+notifier.summary.tradeTime;

          String infoTime = 'last_data_date_info_label'.tr();

          DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy HH:mm:ss', 'id');
          //DateFormat timeFormatter = DateFormat('HH:mm:ss');
          DateFormat dateParser = DateFormat('yyyy-MM-dd HH:mm:ss');
          DateTime dateTime = dateParser.parseUtc(displayTime);
          print('dateTime : '+dateTime.toString());
          print('stock_summary.last_date : '+displayTime);
          String formatedDate = dateFormatter.format(dateTime);
          //String formatedTime = timeFormatter.format(dateTime);
          */
          String displayTime =
              notifier.summary.tradeDate + ' ' + notifier.summary.tradeTime;
          String infoTime = 'last_data_date_info_label'.tr();

          String formatedDate = Utils.formatLastDataUpdate(
              notifier.summary.tradeDate, notifier.summary.tradeTime);
          infoTime = infoTime.replaceAll('#DATE#', formatedDate);
          //infoTime = infoTime.replaceAll('#TIME#', formatedTime);
          displayTime = infoTime;

          childs.add(Center(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral,
                  top: InvestrendTheme.cardPaddingGeneral,
                  bottom: InvestrendTheme.cardPaddingGeneral),
              child: Text(
                displayTime,
                style: InvestrendTheme.of(context)
                    .more_support_w400_compact
                    .copyWith(
                      fontWeight: FontWeight.w500,
                      color: InvestrendTheme.of(context).greyDarkerTextColor,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ));
        }

        return Column(
          children: childs,
        );
      });
    });
  }

  Widget getTableDataOrderbook(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(orderBookChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }
      const padding = 10.0;
      List<TableRow> list = List.empty(growable: true);

      TableRow header = TableRow(children: [
        ComponentCreator.tableCellLeftHeader(context, '#'),
        ComponentCreator.tableCellLeftHeader(context, 'Lot'),
        ComponentCreator.tableCellRightHeader(context, 'Bids',
            padding: padding),
        ComponentCreator.tableCellLeftHeader(context, 'Offers',
            padding: padding),
        ComponentCreator.tableCellRightHeader(context, 'Lot'),
        ComponentCreator.tableCellRightHeader(context, '#'),
      ]);
      list.add(header);

      StockSummary stockSummary =
          context.read(stockSummaryChangeNotifier).summary;
      int prev = stockSummary != null && stockSummary.prev != null
          ? stockSummary.prev
          : 0;

      // StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
      // int prev = _summaryNotifier != null && _summaryNotifier.value != null ? _summaryNotifier.value.prev : 0;

      int maxShowLevel = 6;
      int totalVolumeShowedBid = 0;
      int totalVolumeShowedOffer = 0;
      for (int index = 0; index < maxShowLevel; index++) {
        totalVolumeShowedBid += notifier.orderbook.bidVol(index);
        totalVolumeShowedOffer += notifier.orderbook.offerVol(index);
      }
      for (int index = 0; index < maxShowLevel; index++) {
        double fractionBid =
            notifier.orderbook.bidVol(index) / totalVolumeShowedBid;
        double fractionOffer =
            notifier.orderbook.offerVol(index) / totalVolumeShowedOffer;

        bool showBid = notifier.orderbook.bids.elementAt(index) > 0;
        bool showOffer = notifier.orderbook.offers.elementAt(index) > 0;

        print(
            'orderbook[$index] --> fractionBid : $fractionBid  fractionOffer --> $fractionOffer');
        print('orderbook[$index] --> totalBid : ' +
            notifier.orderbook.totalBid.toString() +
            '  bidVol --> ' +
            notifier.orderbook.bidVol(index).toString());
        print('orderbook[$index] --> totalOffer : ' +
            notifier.orderbook.totalOffer.toString() +
            '  offerVol --> ' +
            notifier.orderbook.offerVol(index).toString());
        TableRow row = TableRow(children: [
          cellBidQueue(context, notifier.orderbook.bidsQueue.elementAt(index),
              () {
            InvestrendTheme.of(context).showSnackBar(
                context,
                'Action show queue for : ' +
                    notifier.orderbook.bidsQueue.elementAt(index).toString());
          }),
          cellBidLot(context, notifier.orderbook.bidLot(index), () {
            // show nothing
          }),
          cellBidPrice(context, notifier.orderbook.bids.elementAt(index), prev,
              fractionBid, padding, () {
            InvestrendTheme.of(context).showSnackBar(
                context,
                'Action show Bid for : ' +
                    notifier.orderbook.bids.elementAt(index).toString());
          }),
          cellOfferPrice(context, notifier.orderbook.offers.elementAt(index),
              prev, fractionOffer, padding, () {
            InvestrendTheme.of(context).showSnackBar(
                context,
                'Action show Offer for : ' +
                    notifier.orderbook.offers.elementAt(index).toString());
          }),
          cellOfferLot(context, notifier.orderbook.offerLot(index), () {
            // show nothing
          }),
          cellOfferQueue(
              context, notifier.orderbook.offersQueue.elementAt(index), () {
            InvestrendTheme.of(context).showSnackBar(
                context,
                'Action show queue for : ' +
                    notifier.orderbook.offersQueue.elementAt(index).toString());
          }),
        ]);
        list.add(row);
      }

      TableRow total = TableRow(children: [
        SizedBox(width: 1),
        ComponentCreator.tableCellLeftHeader(
            context, InvestrendTheme.formatComma(totalVolumeShowedBid)),
        ComponentCreator.tableCellRightHeader(context, 'Total',
            padding: padding),
        ComponentCreator.tableCellLeftHeader(context, 'Total',
            padding: padding),
        ComponentCreator.tableCellRightHeader(
            context, InvestrendTheme.formatComma(totalVolumeShowedOffer)),
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
    });
    /*
    return ValueListenableBuilder(
      valueListenable: InvestrendTheme.of(context).orderbookNotifier,
      builder: (context, OrderBook value, child) {
        if (InvestrendTheme.of(context).orderbookNotifier.invalid()) {
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

        int maxShowLevel = 6;
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
    */
  }

  Widget cellOfferPrice(BuildContext context, int offerPrice, int prev,
      double fractionOffer, double padding, VoidCallback onTap) {
    Color textColor = InvestrendTheme.priceTextColor(offerPrice, prev: prev);
    Color backgroundColor =
        InvestrendTheme.priceBackgroundColor(offerPrice, prev: prev);
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
      /*
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
      */
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

  Widget cellOfferQueue(
      BuildContext context, int offerQueue, VoidCallback onTap) {
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

  Widget cellBidPrice(BuildContext context, int bidPrice, int prev,
      double fractionBid, double padding, VoidCallback onTap) {
    Color textColor = InvestrendTheme.priceTextColor(bidPrice, prev: prev);
    Color backgroundColor =
        InvestrendTheme.priceBackgroundColor(bidPrice, prev: prev);

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
      /*
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
      */
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
        child: ComponentCreator.tableCellLeftValue(
            context, InvestrendTheme.formatComma(bidQueue),
            fontWeight: FontWeight.w300, height: 2.0),
      );
    } else {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
  }

  Widget getTableDataOrderbookSimple(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(orderBookChangeNotifier);
      if (notifier.invalid()) {
        return Center(child: CircularProgressIndicator());
      }
      const padding = 10.0;
      List<TableRow> list = List.empty(growable: true);

      TableRow header = TableRow(children: [
        //ComponentCreator.tableCellLeftHeader(context, '#Q'),
        ComponentCreator.tableCellLeftHeader(context, 'Lot'),
        ComponentCreator.tableCellRightHeader(context, 'Bids',
            padding: padding),
        ComponentCreator.tableCellLeftHeader(context, 'Offers',
            padding: padding),
        ComponentCreator.tableCellRightHeader(context, 'Lot'),
        //ComponentCreator.tableCellRightHeader(context, '#Q'),
      ]);
      list.add(header);

      StockSummary stockSummary =
          context.read(stockSummaryChangeNotifier).summary;
      int prev = stockSummary != null && stockSummary.prev != null
          ? stockSummary.prev
          : 0;

      // StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
      // int prev = _summaryNotifier != null && _summaryNotifier.value != null ? _summaryNotifier.value.prev : 0;

      int maxShowLevel = 6;
      int totalVolumeShowedBid = 0;
      int totalVolumeShowedOffer = 0;
      for (int index = 0; index < maxShowLevel; index++) {
        totalVolumeShowedBid += notifier.orderbook.bidVol(index);
        totalVolumeShowedOffer += notifier.orderbook.offerVol(index);
      }
      for (int index = 0; index < maxShowLevel; index++) {
        // double fractionBid = value.bidVol(index) / value.totalBid;
        // double fractionOffer = value.offerVol(index) / value.totalOffer;

        double fractionBid =
            notifier.orderbook.bidVol(index) / totalVolumeShowedBid;
        double fractionOffer =
            notifier.orderbook.offerVol(index) / totalVolumeShowedOffer;

        print(
            'orderbook[$index] --> fractionBid : $fractionBid  fractionOffer --> $fractionOffer');
        print('orderbook[$index] --> totalBid : ' +
            notifier.orderbook.totalBid.toString() +
            '  bidVol --> ' +
            notifier.orderbook.bidVol(index).toString());
        print('orderbook[$index] --> totalOffer : ' +
            notifier.orderbook.totalOffer.toString() +
            '  offerVol --> ' +
            notifier.orderbook.offerVol(index).toString());
        TableRow row = TableRow(children: [
          // cellBidQueue(context, value.bidsQueue.elementAt(index), () {
          //   InvestrendTheme.of(context).showSnackBar(context, 'Action show queue for : ' + value.bidsQueue.elementAt(index).toString());
          // }),
          cellBidLot(context, notifier.orderbook.bidLot(index), () {
            // show nothing
          }),
          cellBidPrice(context, notifier.orderbook.bids.elementAt(index), prev,
              fractionBid, padding, () {
            InvestrendTheme.of(context).showSnackBar(
                context,
                'Action show Bid for : ' +
                    notifier.orderbook.bids.elementAt(index).toString());
          }),
          cellOfferPrice(context, notifier.orderbook.offers.elementAt(index),
              prev, fractionOffer, padding, () {
            InvestrendTheme.of(context).showSnackBar(
                context,
                'Action show Offer for : ' +
                    notifier.orderbook.offers.elementAt(index).toString());
          }),
          cellOfferLot(context, notifier.orderbook.offerLot(index), () {
            // show nothing
          }),
          // cellOfferQueue(context, value.offersQueue.elementAt(index), () {
          //   InvestrendTheme.of(context).showSnackBar(context, 'Action show queue for : ' + value.offersQueue.elementAt(index).toString());
          // }),
        ]);
        list.add(row);
      }

      return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border: TableBorder.all(color: Colors.black),
          columnWidths: {
            0: FractionColumnWidth(.22),
            1: FractionColumnWidth(.28),
            2: FractionColumnWidth(.28),
            3: FractionColumnWidth(.22),
            // 4: FractionColumnWidth(.16),
            // 5: FractionColumnWidth(.15),
          },
          children: list);
    });
    /*
    return ValueListenableBuilder(
      valueListenable: InvestrendTheme.of(context).orderbookNotifier,
      builder: (context, OrderBook value, child) {
        if (InvestrendTheme.of(context).orderbookNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        const padding = 10.0;
        List<TableRow> list = List.empty(growable: true);

        TableRow header = TableRow(children: [
          //ComponentCreator.tableCellLeftHeader(context, '#Q'),
          ComponentCreator.tableCellLeftHeader(context, 'Lot'),
          ComponentCreator.tableCellRightHeader(context, 'Bids', padding: padding),
          ComponentCreator.tableCellLeftHeader(context, 'Offers', padding: padding),
          ComponentCreator.tableCellRightHeader(context, 'Lot'),
          //ComponentCreator.tableCellRightHeader(context, '#Q'),
        ]);
        list.add(header);
        StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
        int prev = _summaryNotifier != null && _summaryNotifier.value != null ? _summaryNotifier.value.prev : 0;

        int maxShowLevel = 6;
        int totalVolumeShowedBid = 0;
        int totalVolumeShowedOffer = 0;
        for (int index = 0; index < maxShowLevel; index++) {
          totalVolumeShowedBid += value.bidVol(index);
          totalVolumeShowedOffer += value.offerVol(index);
        }
        for (int index = 0; index < maxShowLevel; index++) {
          // double fractionBid = value.bidVol(index) / value.totalBid;
          // double fractionOffer = value.offerVol(index) / value.totalOffer;

          double fractionBid = value.bidVol(index) / totalVolumeShowedBid;
          double fractionOffer = value.offerVol(index) / totalVolumeShowedOffer;

          print('orderbook[$index] --> fractionBid : $fractionBid  fractionOffer --> $fractionOffer');
          print('orderbook[$index] --> totalBid : ' + value.totalBid.toString() + '  bidVol --> ' + value.bidVol(index).toString());
          print('orderbook[$index] --> totalOffer : ' + value.totalOffer.toString() + '  offerVol --> ' + value.offerVol(index).toString());
          TableRow row = TableRow(children: [
            // cellBidQueue(context, value.bidsQueue.elementAt(index), () {
            //   InvestrendTheme.of(context).showSnackBar(context, 'Action show queue for : ' + value.bidsQueue.elementAt(index).toString());
            // }),
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
            // cellOfferQueue(context, value.offersQueue.elementAt(index), () {
            //   InvestrendTheme.of(context).showSnackBar(context, 'Action show queue for : ' + value.offersQueue.elementAt(index).toString());
            // }),
          ]);
          list.add(row);
        }

        return Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            //border: TableBorder.all(color: Colors.black),
            columnWidths: {
              0: FractionColumnWidth(.22),
              1: FractionColumnWidth(.28),
              2: FractionColumnWidth(.28),
              3: FractionColumnWidth(.22),
              // 4: FractionColumnWidth(.16),
              // 5: FractionColumnWidth(.15),
            },
            children: list);
      },
    );
    */
  }

  Widget bidPrice(BuildContext context, int price, int prev, double padding,
      double fraction) {
    Color textColor = InvestrendTheme.priceTextColor(price, prev: prev);
    Color backgroundColor =
        InvestrendTheme.priceBackgroundColor(price, prev: prev);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              margin: EdgeInsets.only(right: padding),
              width: constraints.maxWidth * fraction,
              height: 20,
              color: backgroundColor,
            ),
            ComponentCreator.tableCellRightValue(
                context, InvestrendTheme.formatPrice(price),
                padding: padding, color: textColor),
          ],
        );
      },
    );
  }

  Widget offerPrice(BuildContext context, int price, int prev, double padding,
      double fraction) {
    Color textColor = InvestrendTheme.priceTextColor(price, prev: prev);
    Color backgroundColor =
        InvestrendTheme.priceBackgroundColor(price, prev: prev);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              margin: EdgeInsets.only(left: padding),
              width: constraints.maxWidth * fraction,
              height: 20,
              color: backgroundColor,
            ),
            ComponentCreator.tableCellLeftValue(
                context, InvestrendTheme.formatPrice(price),
                padding: padding, color: textColor),
          ],
        );
      },
    );
    /*
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        FractionallySizedBox(
          child: Container(
            height: 20.0,
            color: backgroundColor,
          ),
          widthFactor: fraction,
        ),

        ComponentCreator.tableCellLeftValue(context, InvestrendTheme.formatPrice(price), padding: padding, color: textColor),
      ],
    );

     */
  }

  /*
  Widget createCardNews(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentCreator.subtitleButtonMore(
              context,
              'stock_detail_overview_card_news_title'.tr(),
              () {
                InvestrendTheme.of(context).showSnackBar(context, "Action Related News More");
              },
            ),
            // tileNews(context, listNews[0]),
            // tileNews(context, listNews[1]),
            // tileNews(context, listNews[2]),

            FutureBuilder<List<HomeNews>>(
              future: news,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //return Text(snapshot.data.length.toString(), style: Theme.of(context).textTheme.bodyText2,);
                  if (snapshot.data.length > 0) {
                    List<Widget> list = List.empty(growable: true);
                    int maxCount = snapshot.data.length > 3 ? 3 : snapshot.data.length;
                    for (int i = 0; i < maxCount; i++) {
                      //list.add(tileNews(context, snapshot.data[i]));
                      list.add(ComponentCreator.tileNews(
                        context,
                        snapshot.data[i],
                        commentClick: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'commentClick');
                        },
                        likeClick: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'likeClick');
                        },
                        shareClick: () {
                          InvestrendTheme.of(context).showSnackBar(context, 'shareClick');
                        },
                      ));
                    }

                    return Column(
                      children: list,
                    );
                    //return gridWorldIndices(context, snapshot.data);
                  } else {
                    return Center(
                        child: Text(
                      'No Data',
                      style: Theme.of(context).textTheme.bodyText2,
                    ));
                  }
                } else if (snapshot.hasError) {
                  return Center(
                      child: Column(
                    children: [
                      Text("${snapshot.error}",
                          maxLines: 10, style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).errorColor)),
                      OutlinedButton(
                          onPressed: () {
                            news = HttpSSI.fetchNews();
                          },
                          child: Text('button_retry'.tr())),
                    ],
                  ));
                }

                // By default, show a loading spinner.
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
  */
  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future onRefresh() {
    context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    if (!active) {
      active = true;
      //onActive();
      context
          .read(stockDetailScreenVisibilityChangeNotifier)
          .setActive(tabIndex, true);
      attentionCodes = context.read(remark2Notifier).getSpecialNotationCodes(
          context.read(primaryStockChangeNotifier).stock.code);
      notation = context.read(remark2Notifier).getSpecialNotation(
          context.read(primaryStockChangeNotifier).stock.code);
      status = context.read(remark2Notifier).getSpecialNotationStatus(
          context.read(primaryStockChangeNotifier).stock.code);
      suspendStock = context.read(suspendedStockNotifier).getSuspended(
          context.read(primaryStockChangeNotifier).stock.code,
          context.read(primaryStockChangeNotifier).stock.defaultBoard);
      if (suspendStock != null) {
        status = StockInformationStatus.Suspended;
      }
      corporateAction = context
          .read(corporateActionEventNotifier)
          .getEvent(context.read(primaryStockChangeNotifier).stock.code);
      corporateActionColor = CorporateActionEvent.getColor(corporateAction);
      //doUpdate(pullToRefresh: true);
      startTimer();

      unsubscribe(context, 'onRefresh');
      Stock stock = context.read(primaryStockChangeNotifier).stock;
      subscribe(context, stock, 'onRefresh');
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  void onTapOrderbook(TypeOrderbook type, TypeField field, PriceLotQueue data) {
    print('onTapOrderbook  ' +
        type.text +
        '  ' +
        field.text +
        '  ' +
        data.toString());
    if (field == TypeField.Price) {
      bool hasAccount =
          context.read(dataHolderChangeNotifier).user.accountSize() > 0;
      InvestrendTheme.pushScreenTrade(context, hasAccount,
          type: OrderType.Buy, initialPriceLot: PriceLot(data.price, 0));
      /*
      OrderType orderType = OrderType.Buy;
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ScreenTrade(OrderType.Buy, initialPriceLot: PriceLot(value, 0),),
            settings: RouteSettings(name: '/trade'),
          ));

       */
    } else if (field == TypeField.Queue) {
      if (data.queue > 0) {
        Stock stock = context.read(primaryStockChangeNotifier).stock;
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenOrderQueue(
                  stock.code, stock.defaultBoard, type.text, data.price),
              settings: RouteSettings(name: '/order_queue'),
            ));
      }
    }
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      createCardDetailStock(context),
      accelerationLabel(context),
      createCardOverview(context),
      ComponentCreator.divider(context),
      // createCardPosition(context),
      // ComponentCreator.divider(context),
      createCardPositionNew(context),

      CardOrderbook(
        _orderbookNotifier,
        10,
        owner: routeName,
        onTap: onTapOrderbook,
      ),
      ComponentCreator.divider(context),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          //bottom: InvestrendTheme.cardPaddingGeneral
        ),
        child: Row(
          children: [
            Expanded(
              child: ComponentCreator.subtitle(
                context,
                'trade_title_trade_book'.tr(),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => TradeDone(),
                      settings: RouteSettings(name: '/trade_done_page'),
                    ));
              },
              child: Text(
                'portfolio_detail_detail_label'.tr(),
                textAlign: TextAlign.end,
                style: InvestrendTheme.of(context).small_w600.copyWith(
                      color: InvestrendTheme.of(context).investrendPurple,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            )
          ],
        ),
      ),
      WidgetTradebook(
        maxShowLine: 5,
        showMoreNotifier: showMoreTradeBookNotifier,
      ),
      SizedBox(
        height: InvestrendTheme.cardPaddingVertical,
      ),
      ComponentCreator.divider(context),
      /* di HIDE dulu, belum munculin sosmed untuk test launch
      createCardComunity(context),
      ComponentCreator.divider(context),
      */
      CardRating(
        _researchRankNotifier,
        onRetry: () {
          doUpdate(pullToRefresh: true);
        },
      ),
      ComponentCreator.divider(context),
      CardNews(
        'stock_detail_overview_card_news_title'.tr(),
        showAllNews: false,
        key: keyNews,
      ),
      SizedBox(
        height: 80.0 + paddingBottom,
      )
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      /*
      child: ListView(
        controller: pScrollController,
        shrinkWrap: false,
        children: childs,
      ),
      */
      child: ScrollablePositionedList.builder(
        itemCount: childs.length,
        itemBuilder: (context, index) => childs.elementAt(index),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
      ),
    );
  }

  SubscribeAndHGET subscribeOrderbook;
  SubscribeAndHGET subscribeTradebook;

  void unsubscribe(BuildContext context, String caller) {
    if (subscribeOrderbook != null) {
      print(routeName + ' unsubscribe : ' + subscribeOrderbook.channel);
      context
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeOrderbook, routeName + '.' + caller);
      subscribeOrderbook = null;
    }
    if (subscribeTradebook != null) {
      print(
          routeName + ' unsubscribe Tradebook : ' + subscribeTradebook.channel);
      context
          .read(managerDatafeedNotifier)
          .unsubscribe(subscribeTradebook, routeName + '.' + caller);
      subscribeTradebook = null;
    }
  }

  void subscribe(BuildContext context, Stock stock, String caller) {
    String codeBoard = stock.code + '.' + stock.defaultBoard;
    String channel = DatafeedType.Orderbook.key + '.' + codeBoard;
    context.read(orderBookChangeNotifier).setStock(stock);
    subscribeOrderbook =
        SubscribeAndHGET(channel, DatafeedType.Orderbook.collection, codeBoard,
            listener: (message) {
      print(routeName + ' got : ' + message.elementAt(1));
      print(message);

      OrderBook orderbook = OrderBook.fromStreaming(message);
      if (mounted) {
        print('got orderbook --> ' + orderbook.toString());
        orderbook.generateDataForUI(10, context: context);

        context.read(orderBookChangeNotifier).setData(orderbook);
        StockSummary stockSummary =
            context.read(stockSummaryChangeNotifier).summary;
        OrderbookData orderbookData = OrderbookData();
        orderbookData.orderbook = orderbook;
        orderbookData.prev = stockSummary != null ? stockSummary.prev : 0;
        orderbookData.close = stockSummary != null ? stockSummary.close : 0;
        orderbookData.averagePrice =
            stockSummary != null ? stockSummary.averagePrice : 0;
        _orderbookNotifier.setValue(orderbookData);

        print('got orderbook --> notify');
      }
    }, validator: validatorOrderbook);
    print(routeName + ' subscribe : $codeBoard');
    context
        .read(managerDatafeedNotifier)
        .subscribe(subscribeOrderbook, routeName + '.' + caller);

    String channelTradebook = DatafeedType.Tradebook.key + '.' + codeBoard;
    context.read(tradeBookChangeNotifier).setStock(stock);
    subscribeTradebook = SubscribeAndHGET(
        channelTradebook, DatafeedType.Tradebook.collection, codeBoard,
        listener: (message) {
      print(routeName + ' got : ' + message.elementAt(1));
      print(message);

      TradeBook tradebook = TradeBook.fromStreaming(message);
      if (mounted) {
        print('got tradebook --> ' + tradebook.toString());
        context.read(tradeBookChangeNotifier).setData(tradebook);
        print('got tradebook --> notify');
      }
    }, validator: validatorTradebook);
    print(routeName + ' subscribe Tradebook : $codeBoard');
    context
        .read(managerDatafeedNotifier)
        .subscribe(subscribeTradebook, routeName + '.' + caller);
  }

  bool validatorOrderbook(List<String> data, String channel) {
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

  bool validatorTradebook(List<String> data, String channel) {
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

/*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          createCardDetailStock(context),
          specialNotationLabel(context),
          //ComponentCreator.divider(context),
          //getTableData(context),
          createCardOverview(context),
          ComponentCreator.divider(context),
          createCardPosition(context),
          ComponentCreator.divider(context),
          //createCardOrderbook(context),
          CardOrderbook(_orderbookNotifier, 6, owner: routeName,),
          ComponentCreator.divider(context),
          createCardComunity(context),
          ComponentCreator.divider(context),
          // ValueListenableBuilder(
          //   valueListenable: thinksNotifier,
          //   builder: (context, int value, child) {
          //     return createCardThinks(context, value);
          //   },
          // ),
          //createCardThinks(context),
          CardRating(1.3),
          ComponentCreator.divider(context),
          //createCardNews(context),
          CardNews(
            'stock_detail_overview_card_news_title'.tr(),
          ),

          SizedBox(
            height: 80.0 + paddingBottom,
          )
        ],
      ),
    );
  }
  */
}

class RichyPainter extends CustomPainter {
  String text;

  RichyPainter(this.text) : super();

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(RichyPainter oldDelegate) {
    return text != null &&
        oldDelegate != null &&
        oldDelegate.text != null &&
        !StringUtils.equalsIgnoreCase(text, oldDelegate.text);
  }
}
