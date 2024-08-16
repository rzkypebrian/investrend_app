// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'dart:async';

import 'package:Investrend/component/cards/card_broker_rank.dart';
import 'package:Investrend/component/cards/card_chart.dart';
import 'package:Investrend/component/cards/card_local_foreign.dart';
import 'package:Investrend/component/cards/card_ohlcv_chart.dart';
import 'package:Investrend/component/cards/card_performance.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/sort_and_filter_popup.dart';
import 'package:Investrend/component/widget_price.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_detail_list.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail_analysis.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_detail.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenSearchMarket extends StatefulWidget {
  // @override
  // _ScreenSearchMarketState createState() => _ScreenSearchMarketState();

  final TabController? tabController;
  final int tabIndex;
  final ValueNotifier<bool>? visibilityNotifier;
  ScreenSearchMarket(this.tabIndex, this.tabController,
      {Key? key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenSearchMarketState createState() =>
      _ScreenSearchMarketState(tabIndex, tabController,
          visibilityNotifier: visibilityNotifier);
}

//final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
//class _ScreenSearchMarketState extends State<ScreenSearchMarket> with AutomaticKeepAliveClientMixin<ScreenSearchMarket> //    with RouteAware
class _ScreenSearchMarketState extends BaseStateNoTabsWithParentTab<
    ScreenSearchMarket> //    with RouteAware
{
  static const Duration durationUpdate = Duration(milliseconds: 1000);
  IndexSummaryNotifier? _compositeNotifier;
  LocalForeignNotifier? _foreignDomesticNotifier;
  ValueNotifier<int> _boardForeignDomesticNotifier = ValueNotifier<int>(0);
  RangeNotifier _rangeForeignDomesticNotifier =
      RangeNotifier(Range.createBasic());
  PerformanceNotifier? _performanceNotifier;
  ChartNotifier _chartNotifier = ChartNotifier(ChartLineData());
  ChartOhlcvNotifier _chartOhlcvNotifier = ChartOhlcvNotifier(ChartOhlcvData());
  ValueNotifier<int> _chartRangeNotifier = ValueNotifier<int>(0);
  String _selectedChartFrom = '';
  String _selectedChartTo = '';
  DateTime? lastChartUpdate;
  bool candleChart = true;

  List<SortAndFilterModel> listIHSGOverview = [
    SortAndFilterModel(
      name: "Open",
      status: true,
    ),
    SortAndFilterModel(
      name: "Value",
      status: true,
    ),
    SortAndFilterModel(
      name: "Low",
      status: true,
    ),
    SortAndFilterModel(
      name: "Vol (Shares)",
      status: true,
    ),
    SortAndFilterModel(
      name: "High",
      status: true,
    ),
    SortAndFilterModel(
      name: "Frequency (x)",
      status: true,
    ),
  ];

  // bool active = false;
  // int _selectedChart = 0;
  // int _selectedDomesticForeign = 0;
  // List<String> _listChipRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];

  _ScreenSearchMarketState(int tabIndex, TabController? tabController,
      {ValueNotifier<bool>? visibilityNotifier})
      : super('/search_market', tabIndex, tabController,
            parentTabIndex: Tabs.Search.index,
            visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;
  void startTimer() {
    print(routeName + '._startTimer');
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(durationUpdate, (timer) {
        print(routeName + ' timer.tick : ' + timer.tick.toString());
        if (active) {
          if (onProgress) {
            print(routeName +
                ' timer aborted caused by onProgress : $onProgress');
          } else {
            doUpdate();
          }
        }
      });
    }
  }

  void stopTimer() {
    if (timer == null || !timer!.isActive) {
      return;
    }
    timer?.cancel();
    timer = null;
  }

  void onActive() {
    doUpdate();
    startTimer();
  }

  void onInactive() {
    stopTimer();
  }

  Future onRefresh() {
    if (!active) {
      active = true;
      startTimer();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = List.empty(growable: true);
    childs.add(createCardDetailIhsg(context));
    childs.add(ComponentCreator.dividerCard(context));
    //childs.add(ComponentCreator.divider(context));
    childs.add(CardPerformance(_performanceNotifier));
    childs.add(ComponentCreator.dividerCard(context));
    childs.add(CardLocalForeign(_foreignDomesticNotifier,
        _boardForeignDomesticNotifier, _rangeForeignDomesticNotifier));
    // childs.add(SizedBox(
    //   height: 10.0,
    // ));
    childs.add(ComponentCreator.dividerCard(context));
    //brokerrank
    childs.add(CardBrokerRank());
    childs.add(ComponentCreator.dividerCard(context));
    childs.add(createCardSector(context));
    childs.add(SizedBox(
      height: paddingBottom + 80,
    ));

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ListView(
        shrinkWrap: false,
        children: childs,
      ),
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //CardGeneralPrice('search_global_card_index_future_title'.tr(), _futuresNotifier),
          //ComponentCreator.divider(context),
          // CardLabelValueNotifier('card_shareholders_composition_title'.tr(), _shareHolderCompositionNotifier),
          // ComponentCreator.divider(context),
          // CardLabelValueNotifier('card_board_of_commisioners_title'.tr(), _boardOfCommisionersNotifier),
          //ComponentCreator.divider(context),

          //createCardDetailIhsg2(context),
          createCardDetailIhsg(context),
          ComponentCreator.divider(context),
          ComponentCreator.divider(context),
          //createCardPerformance(context),
          CardPerformance(_performanceNotifier),
          ComponentCreator.divider(context),

          //createCardLocalForeign(context),
          CardLocalForeign(_localForeignNotifier),
          SizedBox(height: 10.0,),
          ComponentCreator.divider(context),
          createCardSector(context),

          SizedBox(height: paddingBottom + 80,),
        ],
      ),
    );
  }
  */
  /*
  @override
  Widget build(BuildContext context) {
    return ScreenAware(
      routeName: '/search_market',
      onActive: onActive,
      onInactive: onInactive,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //createCardDetailIhsg2(context),
            createCardDetailIhsg(context),
            ComponentCreator.divider(context),
            ComponentCreator.divider(context),
            //createCardPerformance(context),
            CardPerformance(_performanceNotifier),
            ComponentCreator.divider(context),

            //createCardLocalForeign(context),
            CardLocalForeign(_localForeignNotifier),
            SizedBox(height: 10.0,),
            ComponentCreator.divider(context),
            createCardSector(context),

          ],
        ),
      ),
    );

  }
  */
  /*
  Widget createCardDetailIhsgOld(BuildContext context) {
    return Card(
      color: Colors.red,
      margin: const EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder( valueListenable: _compositeNotifier, builder: (context, value, child) {
                  if (_compositeNotifier.invalid()) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Container(
                    color: Colors.purple,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.blue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color:Colors.yellow,
                                child: Text(
                                  'IHSG',
                                  style: InvestrendTheme.of(context).headline3,
                                ),
                              ),
                              // SizedBox(
                              //   height: 4.0,
                              // ),
                              Container(
                                color: Colors.yellow,
                                child: Text(
                                  _compositeNotifier.index.name,
                                  maxLines: 2,
                                  style: InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.blue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.starCt,
                            children: [
                              Row(
                                children: [
                                  //InvestrendTheme.getChangeIcon(_compositeNotifier.value.change),
                                  InvestrendTheme.getChangeImage(_compositeNotifier.value.change),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  // Icon(
                                  //   Icons.arrow_drop_up,
                                  //   color: InvestrendTheme.greenText,
                                  // ),
                                  Text(
                                    InvestrendTheme.formatPriceDouble(_compositeNotifier.value.last),
                                    style: InvestrendTheme.of(context)
                                        .headline3
                                        .copyWith(color: InvestrendTheme.changeTextColor(_compositeNotifier.value.change)),
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   height: 4.0,
                              // ),
                              Text(
                                InvestrendTheme.formatChange(_compositeNotifier.value.change) +
                                    ' (' +
                                    InvestrendTheme.formatPercentChange(_compositeNotifier.value.percentChange) +
                                    ')',
                                style: InvestrendTheme.of(context).regular_w400.copyWith(
                                    color: InvestrendTheme.changeTextColor(_compositeNotifier.value.change)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

            SizedBox(
              height: 20.0,
            ),
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

            getTableData(context),
            /*
            ComponentCreator.divider(context),
            SizedBox(
              height: 20.0,
            ),
            ValueListenableBuilder(
              valueListenable: _compositeNotifier,
              builder: (context, value, child) {
                if (_compositeNotifier.invalid()) {
                  return Center(child: CircularProgressIndicator());
                }
                return getTableData(context);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Low',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'High',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Vol (Shares)',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatPriceDouble(_compositeNotifier.value.open, showDecimal: false),
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatPriceDouble(_compositeNotifier.value.low, showDecimal: false),
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatPriceDouble(_compositeNotifier.value.hi, showDecimal: false),
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_compositeNotifier.value.volume),
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Turnover (IDR)',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Frequency (x)',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Value',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Time',
                          style: InvestrendTheme.of(context).textLabelStyle,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ComponentCreator.textFit(
                          context,
                          '???',
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatComma(_compositeNotifier.value.freq),
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        //ComponentCreator.textFit(context, _compositeNotifier.value.time),
                        ComponentCreator.textFit(
                          context,
                          InvestrendTheme.formatValue(_compositeNotifier.value.value),
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        ComponentCreator.textFit(
                          context,
                          _compositeNotifier.value.time,
                          style: InvestrendTheme.of(context).textValueStyle,
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                  ],
                );

              },
            ),

             */
          ],
        ),
      ),
    );
  }
  */
  Widget createCardDetailIhsg(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: 10.0),
            child: ValueListenableBuilder(
                valueListenable: _compositeNotifier!,
                builder: (context, value, child) {
                  if (_compositeNotifier!.invalid()) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return WidgetPrice(
                      'IHSG',
                      _compositeNotifier?.index?.name,
                      _compositeNotifier?.value?.last,
                      _compositeNotifier?.value?.change,
                      _compositeNotifier?.value?.percentChange,
                      true);
                }),
          ),
          // SizedBox(
          //   height: 20.0,
          // ),
          Container(
            margin: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: 10.0),
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
                    top: InvestrendTheme.cardPadding,
                  ),
                  child: CardChart(
                    _chartNotifier,
                    _chartRangeNotifier,
                    onRetry: () {
                      requestChart();
                    },
                    callbackRange: (index, from, to) {
                      //print('detail Ihsg chart callbackRange : $from , $to');
                      bool isChanged = !StringUtils.equalsIgnoreCase(
                              from, _selectedChartFrom) ||
                          !StringUtils.equalsIgnoreCase(to, _selectedChartTo);
                      print(routeName +
                          ' chart callbackRange : $from , $to  isChanged : $isChanged');

                      if (isChanged) {
                        lastChartUpdate = null;
                      }
                      _selectedChartFrom = from;
                      _selectedChartTo = to;
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
                    bool isChanged = !StringUtils.equalsIgnoreCase(
                            from, _selectedChartFrom) ||
                        !StringUtils.equalsIgnoreCase(to, _selectedChartTo);
                    print(routeName +
                        ' chart ohlcvCandle : $from , $to  isChanged : $isChanged');

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

          */

          SizedBox(
            height: 20.0,
          ),
          Container(
            margin: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ComponentCreator.subtitle(
                    context, 'search_market_card_overview_title'.tr()),
                IconButton(
                  onPressed: () {
                    SortAndFilterPopUp(listIHSGOverview)
                        .show(context: context, onChanged: (data) {});
                  },
                  icon: Icon(Icons.filter_list_alt),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
          //   child: ComponentCreator.subtitle(context, 'search_market_card_overview_title'.tr()),
          // ),

          SizedBox(
            height: 8.0,
          ),
          //getTableData(context),
          Container(
            margin: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPadding,
                bottom: 10.0),
            child: getTableDataNew(context),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
          //   child: getTableData(context),
          // ),
        ],
      ),
    );
  }

  //final NumberFormat formatterNumber = NumberFormat("#,##0.##", "id");

  Widget tableCellLeft(BuildContext context, String text,
      {double padding = 0.0}) {
    return Padding(
      padding: EdgeInsets.only(
        left: padding, /*top: 10.0, bottom: 10.0*/
      ),
      child: Text(
        text,
        maxLines: 1,
        style: InvestrendTheme.of(context).textLabelStyle,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget tableCellRightExpanded(BuildContext context, String text,
      {double padding = 0.0, Color? color}) {
    TextStyle? textStyle;
    if (color == null) {
      textStyle = InvestrendTheme.of(context).small_w400_compact;
    } else {
      textStyle = InvestrendTheme.of(context)
          .small_w400_compact
          ?.copyWith(color: color);
    }
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(
          right: padding, /* top: 10.0, bottom: 10.0*/
        ),
        child: Text(
          text,
          maxLines: 1,
          style: textStyle,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget getTableData(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _compositeNotifier!,
      builder: (context, value, child) {
        if (_compositeNotifier!.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        const padding = 15.0;

        TableRow row0 = TableRow(children: [
          Row(
            children: [
              tableCellLeft(context, 'Open'),
              tableCellRightExpanded(
                  context,
                  InvestrendTheme.formatPriceDouble(
                      _compositeNotifier?.value?.open,
                      showDecimal: false),
                  color: InvestrendTheme.changeTextColor(
                      _compositeNotifier?.value?.open,
                      prev: _compositeNotifier?.value?.prev),
                  padding: padding),
            ],
          ),
          Row(
            children: [
              tableCellLeft(context, 'Value', padding: padding),
              tableCellRightExpanded(
                context,
                InvestrendTheme.formatValue(
                    context, _compositeNotifier?.value?.value),
              ),
            ],
          ),
        ]);

        TableRow row1 = TableRow(children: [
          Row(
            children: [
              tableCellLeft(context, 'Low'),
              tableCellRightExpanded(
                  context,
                  InvestrendTheme.formatPriceDouble(
                      _compositeNotifier?.value?.low,
                      showDecimal: false),
                  color: InvestrendTheme.changeTextColor(
                      _compositeNotifier?.value?.low,
                      prev: _compositeNotifier?.value?.prev),
                  padding: padding),
            ],
          ),
          Row(
            children: [
              tableCellLeft(context, 'Vol (Shares)', padding: padding),
              tableCellRightExpanded(
                context,
                InvestrendTheme.formatValue(
                    context, _compositeNotifier?.value?.volume),
              ),
            ],
          ),
        ]);
        TableRow row2 = TableRow(children: [
          Row(
            children: [
              tableCellLeft(context, 'High'),
              tableCellRightExpanded(
                  context,
                  InvestrendTheme.formatPriceDouble(
                      _compositeNotifier?.value?.hi,
                      showDecimal: false),
                  color: InvestrendTheme.changeTextColor(
                      _compositeNotifier?.value?.hi,
                      prev: _compositeNotifier?.value?.prev),
                  padding: padding),
            ],
          ),
          Row(
            children: [
              tableCellLeft(context, 'Frequency (x)', padding: padding),
              tableCellRightExpanded(
                context,
                InvestrendTheme.formatComma(_compositeNotifier?.value?.freq),
              ),
            ],
          ),
        ]);

        // TableRow row3 = TableRow(children: [
        //   ComponentCreator.tableCellLeft(context, 'High'),
        //   ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(_summaryNotifier.value.hi), color: InvestrendTheme.priceTextColor(_summaryNotifier.value.hi, prev: _summaryNotifier.value.prev), padding: padding),
        //   ComponentCreator.tableCellLeft(context, 'PER', padding: padding),
        //   ComponentCreator.tableCellRight(context, '????', ),
        // ]);
        // TableRow row4 = TableRow(children: [
        //   ComponentCreator.tableCellLeft(context, 'Avg. Price'),
        //   ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(_summaryNotifier.value.averagePrice.toInt()), color: InvestrendTheme.priceTextColor(_summaryNotifier.value.averagePrice.toInt(), prev: _summaryNotifier.value.prev), padding: padding),
        //   ComponentCreator.tableCellLeft(context, 'YTD (%)', padding: padding),
        //   ComponentCreator.tableCellRight(context, InvestrendTheme.formatPercentChange(_summaryNotifier.value.returnYTD), color: InvestrendTheme.changeTextColor(_summaryNotifier.value.returnYTD) ),
        // ]);
        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border: TableBorder.all(color: Colors.black),
          columnWidths: {
            0: FractionColumnWidth(.4),
            1: FractionColumnWidth(.6),
          },
          children: [
            createSpacer(context),
            row0,
            createSpacer(context),
            row1,
            createSpacer(context),
            row2,
            createSpacer(context),
            // row3,
            // row4,
          ],
        );
      },
    );
  }

  Widget getTableDataNew(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _compositeNotifier!,
      builder: (context, value, child) {
        if (_compositeNotifier!.invalid()) {
          return Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(builder: (context, constraints) {
          double marginSection = 25.0;

          //double maxWidthSection = ((constraints.maxWidth - marginSection) / 2);// - marginContent;
          double availableWidth = (constraints.maxWidth - marginSection);
          double widthLeftSection = availableWidth * 0.4;
          double widthRightSection = availableWidth - widthLeftSection;

          TextStyle? labelStyle = InvestrendTheme.of(context).textLabelStyle;
          TextStyle? valueStyle =
              InvestrendTheme.of(context).small_w400_compact;

          List<LabelValueColor> listLeft = List.empty(growable: true);
          List<LabelValueColor> listRight = List.empty(growable: true);

          listLeft.add(LabelValueColor(
              'Open',
              InvestrendTheme.formatPriceDouble(_compositeNotifier?.value?.open,
                  showDecimal: false),
              color: _compositeNotifier?.value?.openColor()));
          listRight.add(LabelValueColor(
            'Value',
            InvestrendTheme.formatValue(
                context, _compositeNotifier?.value?.value),
          ));

          listLeft.add(LabelValueColor(
              'Low',
              InvestrendTheme.formatPriceDouble(_compositeNotifier?.value?.low,
                  showDecimal: false),
              color: _compositeNotifier?.value?.lowColor()));
          listRight.add(LabelValueColor(
              'Vol (Shares)',
              InvestrendTheme.formatValue(
                  context, _compositeNotifier?.value?.volume)));

          listLeft.add(LabelValueColor(
              'High',
              InvestrendTheme.formatPriceDouble(_compositeNotifier?.value?.hi,
                  showDecimal: false),
              color: _compositeNotifier?.value?.hiColor()));
          listRight.add(LabelValueColor('Frequency (x)',
              InvestrendTheme.formatComma(_compositeNotifier?.value?.freq)));

          int count = listLeft.length;

          List<TextStyle?>? styles = [labelStyle, valueStyle];
          for (int i = 0; i < count; i++) {
            LabelValueColor leftLVC = listLeft.elementAt(i);
            LabelValueColor rightLVC = listRight.elementAt(i);
            styles = UIHelper.calculateFontSizes(context, styles,
                widthLeftSection, [leftLVC.label, leftLVC.value]);
            styles = UIHelper.calculateFontSizes(context, styles,
                widthRightSection, [rightLVC.label, rightLVC.value]);
          }
          labelStyle = styles?.elementAt(0);
          valueStyle = styles?.elementAt(1);

          List<Widget> childs = List.empty(growable: true);
          for (int i = 0; i < count; i++) {
            LabelValueColor leftLVC = listLeft.elementAt(i);
            LabelValueColor rightLVC = listRight.elementAt(i);
            childs.add(Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // color: Colors.yellow,
                    width: widthLeftSection,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          leftLVC.label,
                          maxLines: 1,
                          style: labelStyle,
                          textAlign: TextAlign.left,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Text(
                          leftLVC.value,
                          maxLines: 1,
                          style: leftLVC.color == null
                              ? valueStyle
                              : valueStyle?.copyWith(color: leftLVC.color),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: marginSection,
                  ),
                  Container(
                    // color: Colors.orange,
                    width: widthRightSection,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          rightLVC.label,
                          maxLines: 1,
                          style: labelStyle,
                          textAlign: TextAlign.left,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Text(
                          rightLVC.value,
                          maxLines: 1,
                          style: rightLVC.color == null
                              ? valueStyle
                              : valueStyle?.copyWith(color: rightLVC.color),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
          }
          if (!StringUtils.isEmtpy(_compositeNotifier?.value?.date) &&
              !StringUtils.isEmtpy(_compositeNotifier?.value?.time)) {
            /*
                DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy HH:mm:ss', 'id');
                //DateFormat timeFormatter = DateFormat('HH:mm:ss');
                DateFormat dateParser = DateFormat('yyyy-MM-dd HH:mm:ss');
                DateTime dateTime = dateParser.parseUtc(displayTime);
                print('dateTime : '+dateTime.toString());
                print('stock_summary.last_date : '+displayTime);
                String formatedDate = dateFormatter.format(dateTime);
                //String formatedTime = timeFormatter.format(dateTime);
                */
            String displayTime = _compositeNotifier!.value!.date! +
                ' ' +
                _compositeNotifier!.value!.time!;
            String infoTime = 'last_data_date_info_label'.tr();

            String? formatedDate = Utils.formatLastDataUpdate(
                _compositeNotifier?.value?.date,
                _compositeNotifier?.value?.time);
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
                      ?.copyWith(
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
      },
    );
  }

  TableRow createSpacer(BuildContext context) {
    return TableRow(
      children: [
        SizedBox(
          height: InvestrendTheme.cardPaddingVertical,
        ),
        SizedBox(
          height: InvestrendTheme.cardPaddingVertical,
        )
      ],
    );
  }

  /*
  Widget getTableDataOld(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _compositeNotifier,
      builder: (context, value, child) {
        if (_compositeNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        const padding = 15.0;
        TableRow row0 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'Open'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPriceDouble(_compositeNotifier.value.open, showDecimal: false),
              color: InvestrendTheme.changeTextColor(_compositeNotifier.value.open, prev: _compositeNotifier.value.prev), padding: padding),
          ComponentCreator.tableCellLeft(context, 'Turnover (IDR)', padding: padding),
          ComponentCreator.tableCellRight(
            context,
            '????',
          ),
        ]);

        TableRow row1 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'Low'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPriceDouble(_compositeNotifier.value.low, showDecimal: false),
              color: InvestrendTheme.changeTextColor(_compositeNotifier.value.low, prev: _compositeNotifier.value.prev), padding: padding),
          ComponentCreator.tableCellLeft(context, 'Vol (Shares)', padding: padding),
          ComponentCreator.tableCellRight(
            context,
            InvestrendTheme.formatValue(_compositeNotifier.value.volume),
          ),
        ]);
        TableRow row2 = TableRow(children: [
          ComponentCreator.tableCellLeft(context, 'High'),
          ComponentCreator.tableCellRight(context, InvestrendTheme.formatPriceDouble(_compositeNotifier.value.hi, showDecimal: false),
              color: InvestrendTheme.changeTextColor(_compositeNotifier.value.hi, prev: _compositeNotifier.value.prev), padding: padding),
          ComponentCreator.tableCellLeft(context, 'Frequency (x)', padding: padding),
          ComponentCreator.tableCellRight(
            context,
            InvestrendTheme.formatComma(_compositeNotifier.value.freq),
          ),
        ]);

        // TableRow row3 = TableRow(children: [
        //   ComponentCreator.tableCellLeft(context, 'High'),
        //   ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(_summaryNotifier.value.hi), color: InvestrendTheme.priceTextColor(_summaryNotifier.value.hi, prev: _summaryNotifier.value.prev), padding: padding),
        //   ComponentCreator.tableCellLeft(context, 'PER', padding: padding),
        //   ComponentCreator.tableCellRight(context, '????', ),
        // ]);
        // TableRow row4 = TableRow(children: [
        //   ComponentCreator.tableCellLeft(context, 'Avg. Price'),
        //   ComponentCreator.tableCellRight(context, InvestrendTheme.formatPrice(_summaryNotifier.value.averagePrice.toInt()), color: InvestrendTheme.priceTextColor(_summaryNotifier.value.averagePrice.toInt(), prev: _summaryNotifier.value.prev), padding: padding),
        //   ComponentCreator.tableCellLeft(context, 'YTD (%)', padding: padding),
        //   ComponentCreator.tableCellRight(context, InvestrendTheme.formatPercentChange(_summaryNotifier.value.returnYTD), color: InvestrendTheme.changeTextColor(_summaryNotifier.value.returnYTD) ),
        // ]);
        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border: TableBorder.all(color: Colors.black),
          columnWidths: {0: FractionColumnWidth(.2)},
          children: [
            row0,
            row1,
            row2,
            // row3,
            // row4,
          ],
        );
      },
    );
  }
  */

  Widget progressPerformance(BuildContext context, String? label,
      double? change, double? percentChange) {
    double progressValue = percentChange!.abs() / 100;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label!,
                style: Theme.of(context).textTheme.bodyLarge,

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
                valueColor: new AlwaysStoppedAnimation<Color>(
                    InvestrendTheme.changeTextColor(change)),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: InvestrendTheme.changeTextColor(change)),
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
                  valueListenable: _compositeNotifier!,
                  builder: (context, value, child) {
                    if (_compositeNotifier!.invalid()) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return progressPerformance(
                        context,
                        '1 Day',
                        _compositeNotifier?.value?.change,
                        _compositeNotifier?.value?.percentChange);
                  },
                ),
                progressPerformance(context, '1 Week', 0, 0),
                progressPerformance(context, '1 Mo', 0, 0),
                progressPerformance(context, '3 Mo', 0, 0),
                progressPerformance(context, '6 Mo', 0, 0),
                //progressPerformance(context, '1 Year',10, -1.09),
                ValueListenableBuilder(
                  valueListenable: _compositeNotifier!,
                  builder: (context, value, child) {
                    if (_compositeNotifier!.invalid()) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return progressPerformance(
                        context,
                        '1 Year',
                        _compositeNotifier?.value?.return52W,
                        _compositeNotifier?.value?.return52W);
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
  Widget getSectorIcon(BuildContext context, String sector_code) {
    String path = getSectorIconAssetPath(context, sector_code);
    if(StringUtils.isEmtpy(path)){
      return Image.asset(
        path,
        width: 20.0,
        height: 20.0,
      );
    }else{
      return Icon(
        Icons.help_outline,
        size: 20.0,
      );
    }
    /*
    if (StringUtils.equalsIgnoreCase(sector_code, 'IDXENERGY')) {
      return Image.asset(
        'images/icons/sector_energy.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXBASIC')) {
      return Image.asset(
        'images/icons/sector_basic.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXINDUST')) {
      return Image.asset(
        'images/icons/sector_industrial.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXNONCYC')) {
      return Image.asset(
        'images/icons/sector_non_cyclic.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXCYCLIC')) {
      return Image.asset(
        'images/icons/sector_cyclic.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXHEALTH')) {
      return Image.asset(
        'images/icons/sector_healthcare.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXFINANCE')) {
      return Image.asset(
        'images/icons/sector_financials.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXPROPERT')) {
      return Image.asset(
        'images/icons/sector_property.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXTECHNO')) {
      return Image.asset(
        'images/icons/sector_technology.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXINFRA')) {
      return Image.asset(
        'images/icons/sector_infrastructure.png',
        width: 20.0,
        height: 20.0,
      );
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXTRANS')) {
      return Image.asset(
        'images/icons/sector_transportation.png',
        width: 20.0,
        height: 20.0,
      );
    }
    return Icon(
      Icons.help_outline,
      size: 20.0,
    );
     */
  }
  String getSectorIconAssetPath(BuildContext context, String sector_code) {
    if (StringUtils.equalsIgnoreCase(sector_code, 'IDXENERGY')) {
      return 'images/icons/sector_energy.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXBASIC')) {
      return 'images/icons/sector_basic.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXINDUST')) {
      return  'images/icons/sector_industrial.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXNONCYC')) {
      return  'images/icons/sector_non_cyclic.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXCYCLIC')) {
      return 'images/icons/sector_cyclic.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXHEALTH')) {
      return 'images/icons/sector_healthcare.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXFINANCE')) {
      return 'images/icons/sector_financials.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXPROPERT')) {
      return 'images/icons/sector_property.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXTECHNO')) {
      return 'images/icons/sector_technology.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXINFRA')) {
      return 'images/icons/sector_infrastructure.png';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXTRANS')) {
      return 'images/icons/sector_transportation.png';
    }
    return '';
  }

  String getSectorAlias(BuildContext context, String sector_code) {
    if (StringUtils.equalsIgnoreCase(sector_code, 'IDXENERGY')) {
      return 'Energy';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXBASIC')) {
      return 'Basic'; // Basic Materials
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXINDUST')) {
      return 'Industrials';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXNONCYC')) {
      return 'Non-Cyclicals'; // Consumer Non-Cyclicals
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXCYCLIC')) {
      return 'Cyclicals'; // Consumer Cyclicals
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXHEALTH')) {
      return 'Healthcare';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXFINANCE')) {
      return 'Financials';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXPROPERT')) {
      return 'Properties'; // Properties & Real Estate
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXTECHNO')) {
      return 'Technology';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXINFRA')) {
      return 'Infrastructures';
    } else if (StringUtils.equalsIgnoreCase(sector_code, 'IDXTRANS')) {
      return 'Transportation'; // Transportation & Logistics
    }
    return sector_code;
  }
  */

  Widget tileSector(
      BuildContext context, SectorObject sector, bool first, double width) {
    double left = first ? 0 : 8.0;
    //double right = end ? 0 : 0.0;
    String percentText;
    Color percentChangeTextColor;
    Color percentChangeBackgroundColor;

    percentText = InvestrendTheme.formatPercentChange(sector.percentChange);
    percentChangeTextColor =
        InvestrendTheme.changeTextColor(sector.percentChange);
    percentChangeBackgroundColor =
        InvestrendTheme.priceBackgroundColorDouble(sector.percentChange);
    /*
    if (sector.percentChange > 0) {
      percentText = '+' + formatterNumber.format(sector.percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.greenText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).greenBackground;
    } else if (sector.percentChange < 0) {
      percentText = formatterNumber.format(sector.percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.redText;
      percentChangeBackgroundColor = InvestrendTheme.of(context).redBackground;
    } else {
      percentText = formatterNumber.format(sector.percentChange) + '%';
      percentChangeTextColor = InvestrendTheme.of(context).yellowText;
      percentChangeBackgroundColor =
          InvestrendTheme.of(context).yellowBackground;
    }
     */
    return SizedBox(
      width: width,
      child: MaterialButton(
        elevation: 0.0,
        minWidth: 50.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sector.getAlias(context)!,
                //style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
                style: InvestrendTheme.of(context).small_w600,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sector.member_count.toString() + ' Emiten',
                //style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.w300),
                style: InvestrendTheme.of(context).support_w400?.copyWith(
                    color: InvestrendTheme.of(context).greyDarkerTextColor),
              ),
            ),
            sector.getIcon(context),
            // Icon(
            //   Icons.extension,
            //   color: Theme.of(context).accentColor,
            // ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: percentChangeBackgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  percentText,
                  //style: TextStyle(color: percentChangeTextColor),
                  style: InvestrendTheme.of(context)
                      .support_w600
                      ?.copyWith(color: percentChangeTextColor),
                ),
              ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }

  Widget tileSectorNew(BuildContext context, SectorObject sector, bool first,
      double width, AutoSizeGroup groupCode) {
    double left = first ? 0 : 8.0;
    String percentText;
    Color percentChangeTextColor;
    Color percentChangeBackgroundColor;

    percentText = InvestrendTheme.formatPercentChange(sector.percentChange);
    percentChangeTextColor =
        InvestrendTheme.changeTextColor(sector.percentChange);
    percentChangeBackgroundColor =
        InvestrendTheme.priceBackgroundColorDouble(sector.percentChange);

    String? codeAliased = sector.getAlias(context);
    return SizedBox(
      width: width,
      child: MaterialButton(
        elevation: 0.0,
        minWidth: 50.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Column(
          children: [
            AutoSizeText(
              codeAliased!, //getSectorAlias(context, sector.code),
              //style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
              style: InvestrendTheme.of(context).small_w600,
              maxLines: 1,
              minFontSize: 8.0,
              group: groupCode,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                //sector.member_count.toString() + ' Emiten',
                sector.member_count.toString() + ' ' + 'emiten_label'.tr(),

                //style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.w300),
                style: InvestrendTheme.of(context).support_w400?.copyWith(
                    color: InvestrendTheme.of(context).greyDarkerTextColor),
              ),
            ),
            sector.getIcon(context),
            // Icon(
            //   Icons.extension,
            //   color: Theme.of(context).accentColor,
            // ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: percentChangeBackgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  percentText,
                  //style: TextStyle(color: percentChangeTextColor),
                  style: InvestrendTheme.of(context)
                      .support_w600
                      ?.copyWith(color: percentChangeTextColor),
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          List<Stock>? members = List.empty(growable: true);
          for (Stock? stock in InvestrendTheme.storedData!.listStock!) {
            if (stock != null) {
              //stock --> "sectorText": "IDXNONCYC",
              // sector --> "sector": "IDXENERGY"
              bool matched = stock.sectorText == sector.code;
              print('matched : $matched  for  stock.sectorText : ' +
                  stock.sectorText! +
                  '   sector.code : ' +
                  sector.code!);
              if (matched) {
                members.add(stock);
              }
            }
          }
          Index? indexSector;
          /*
          for (final index in InvestrendTheme.storedData.listIndex) {
            if (index != null && index.code == sector.code) {
              indexSector = index;
              break;
            }
          }

           */
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ScreenListDetail(
                  members,
                  title: codeAliased,
                  icon: sector.getIconAssetPath(context),
                  color: sector.getColor(context),
                  indexSector: indexSector,
                ),
                settings: RouteSettings(name: '/list_detail'),
              ));
        },
      ),
    );
  }

  Future<List<IndexSummary>>? indexSummarys;
  Timer? timer;

  // bool active = true;
  @override
  void initState() {
    super.initState();
    print('202104-27 initState');
    _foreignDomesticNotifier = LocalForeignNotifier(
        new ForeignDomestic('', '', '', '', 0, 0, 0, 0.0, 0, 0, 0, 0.0));
    _performanceNotifier = PerformanceNotifier(new PerformanceData());
    _rebuildSectors();
    Index? composite;
    for (final Index? index in InvestrendTheme.storedData!.listIndex!) {
      if (index != null && index.isComposite) {
        composite = index;
        break;
      }
    }
    _boardForeignDomesticNotifier.addListener(() {
      doUpdate();
    });
    _rangeForeignDomesticNotifier.addListener(() {
      print(routeName +
          '._rangeForeignDomesticNotifier event   ' +
          _rangeForeignDomesticNotifier.value.toString());
      doUpdate();
    });
    _compositeNotifier = IndexSummaryNotifier(null, composite);
    // if (timer == null || !timer.isActive) {
    //   timer = Timer.periodic(durationUpdate, (timer) {
    //     doUpdate();
    //   });
    // }

    //doUpdate();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   routeObserver.subscribe(this, ModalRoute.of(context));
  // }
  @override
  void dispose() {
    _chartRangeNotifier.dispose();
    _compositeNotifier?.dispose();
    _foreignDomesticNotifier?.dispose();
    _performanceNotifier?.dispose();
    _chartNotifier.dispose();
    _chartOhlcvNotifier.dispose();
    _boardForeignDomesticNotifier.dispose();
    _rangeForeignDomesticNotifier.dispose();
    //routeObserver.unsubscribe(this);
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

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

  void _rebuildSectors() {
    listSectors.clear();
    if (InvestrendTheme.storedData!.listIndex!.isNotEmpty) {
      InvestrendTheme.storedData?.listIndex?.forEach((Index? index) {
        if (index != null && index.isSector) {
          listSectors
              .add(SectorObject(index.code, index.listMembers.length, '', 0.0));
          //listSectors.add(SectorObject(index.name, index.listMembers.length, '/images/icons/action_bell.png', 0.0));
        }
      });
    }
  }

  bool onProgress = false;
  Future doUpdate({bool pullToRefresh = false}) async {
    if (!active) {
      print(routeName + '.doUpdate ignored because active : $active');
      return;
    }
    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if (!isForeground) {
        print(routeName +
            ' doUpdate ignored isForeground : $isForeground  isVisible : ' +
            isVisible().toString());
        return;
      }
    }
    print('ScreenSearchMarket.doUpdate : ' + DateTime.now().toString());

    onProgress = true;

    List<String> listCode = List<String>.empty(growable: true);

    //listSectors.clear();
    if (InvestrendTheme.storedData!.listIndex!.isNotEmpty) {
      InvestrendTheme.storedData?.listIndex?.forEach((Index? index) {
        if (index != null && (index.isSector || index.isComposite)) {
          //listSectors.add(SectorObject(index.code, index.listMembers.length, '/images/icons/action_bell.png', 0.0));
          listCode.add(index.code!);
        }
      });
    }
    print('doUpdate listCode.size : ' + listCode.length.toString());
    //indexSummarys = HttpSSI.fetchIndices(listCode);

    try {
      String board = _boardForeignDomesticNotifier.value == 0 ? '*' : 'RG';
      if (_rangeForeignDomesticNotifier.value?.index == 0) {
        final compositeFD =
            await InvestrendTheme.datafeedHttp.fetchCompositeFD(board);
        if (compositeFD != null) {
          if (mounted) {
            _foreignDomesticNotifier?.setValue(compositeFD);
          }
        } else {
          setNotifierNoData(_foreignDomesticNotifier);
        }
      } else {
        MyRange range = _rangeForeignDomesticNotifier.getRange();
        if (range.valid()) {
          final stockFD = await InvestrendTheme.datafeedHttp
              .fetchCompositeFDHistorical(board, range.from, range.to);
          if (stockFD != null) {
            if (mounted) {
              _foreignDomesticNotifier?.setValue(stockFD);
            }
          } else {
            setNotifierNoData(_foreignDomesticNotifier);
          }
        }
      }
    } catch (error) {
      setNotifierError(_foreignDomesticNotifier, error);
    }
    try {
      final PerformanceData? performanceData = await InvestrendTheme
          .datafeedHttp
          .fetchPerformance('INDEX', 'COMPOSITE');
      if (performanceData != null) {
        if (mounted) {
          _performanceNotifier?.setValue(performanceData);
        }
      } else {
        setNotifierNoData(_performanceNotifier);
      }
    } catch (error) {
      setNotifierError(_performanceNotifier, error);
    }

    try {
      final List<IndexSummary?>? indexSummarys =
          await InvestrendTheme.datafeedHttp.fetchIndices(listCode);
      if (indexSummarys!.length > 0) {
        print('Future DATA : ' + indexSummarys.length.toString());
        indexSummarys.forEach((indexSummary) {
          if (indexSummary != null) {
            //print(indexSummary.toString());
            int countSector = listSectors.length;
            for (int i = 0; i < countSector; i++) {
              SectorObject sector = listSectors.elementAt(i);
              if (StringUtils.equalsIgnoreCase(
                  indexSummary.code, sector.code)) {
                sector.percentChange = indexSummary.percentChange;
                break;
              }
            }

            if (StringUtils.equalsIgnoreCase(indexSummary.code, 'COMPOSITE')) {
              if (mounted) {
                _compositeNotifier?.setData(indexSummary);
              }

              // PerformanceData newPD = PerformanceData();
              // newPD.intraday_change = indexSummary.change;
              // newPD.intraday_percent_change = indexSummary.percentChange;
              // newPD.year_1_percent_change = indexSummary.return52W;
              // newPD.year_1_percent_change = indexSummary.return52W;
              //
              // _performanceNotifier.setValue(newPD);

              /*
              LocalForeignData newLFD = LocalForeignData();
              newLFD.domesticBuy = indexSummary.domesticBuyerValue;
              newLFD.foreignBuy = indexSummary.foreignBuyerValue;

              newLFD.domesticSell = indexSummary.domesticSellerValue;
              newLFD.foreignSell = indexSummary.foreignSellerValue;

              newLFD.domescticNet = indexSummary.domesticBuyerValue - indexSummary.domesticSellerValue;
              newLFD.foreignNet = indexSummary.foreignBuyerValue - indexSummary.foreignSellerValue;

              newLFD.domesticTurnover = 0;
              newLFD.foreignTurnover = 0;

              //yyyy-MM-dd hh:mm:ss
              //String infoTime = 'Data terakhir diupdate Senin, 03/05/2021 pada pukul 18:00';

              if( !StringUtils.isEmtpy(indexSummary.time) && !StringUtils.isEmtpy(indexSummary.date)){
                String infoTime = 'card_local_foreign_time_info'.tr();

                DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
                DateFormat timeFormatter = DateFormat('HH:mm:ss');
                DateFormat dateParser = DateFormat('yyyy-MM-dd hh:mm:ss');
                DateTime dateTime = dateParser.parseUtc(indexSummary.date+' '+indexSummary.time);
                print('dateTime : '+dateTime.toString());
                print('indexSummary.date : '+indexSummary.date+' '+indexSummary.time);
                String formatedDate = dateFormatter.format(dateTime);
                String formatedTime = timeFormatter.format(dateTime);
                infoTime = infoTime.replaceAll('#DATE#', formatedDate);
                infoTime = infoTime.replaceAll('#TIME#', formatedTime);
                newLFD.time = infoTime;
              }else{
                newLFD.time = '';
              }
              //newLFD.time = 'Data terakhir diupdate Senin, 03/05/2021 pada pukul 18:00';
              _localForeignNotifier.setValue(newLFD);
              */
            }
          }
        });
      } else {
        print('Future NO DATA');
      }
    } catch (error) {}

    bool isIntradayChart = StringUtils.isEmtpy(_selectedChartFrom) ||
        StringUtils.isEmtpy(_selectedChartTo);

    int? inSeconds = lastChartUpdate == null
        ? -1
        : DateTime.now().difference(lastChartUpdate!).inSeconds;

    if (lastChartUpdate == null || (isIntradayChart && inSeconds > 10)) {
      lastChartUpdate = DateTime.now();
      print('Requesting chartCandle update  at ' + lastChartUpdate.toString());

      final ChartOhlcvData chartCandle = await InvestrendTheme.datafeedHttp
          .fetchChartOhlcv('COMPOSITE', true,
              from: _selectedChartFrom, to: _selectedChartTo);
      if (chartCandle != null &&
          chartCandle.isValidResponse(
              'COMPOSITE', _selectedChartFrom, _selectedChartTo)) {
        bool intraday = _chartRangeNotifier.value == 0;
        if (_compositeNotifier?.value != null && intraday) {
          chartCandle.setPrev(_compositeNotifier?.value?.prev);
        }

        chartCandle.normalize(middlePrev: intraday);
        print('Future chartCandle DATA : ' + chartCandle.toString());

        if (mounted) {
          _chartOhlcvNotifier.setValue(chartCandle);
        }
      } else {
        print('Future chartCandle NO DATA');
      }
    } else {
      print('Skip chartCandle update ' +
          lastChartUpdate.toString() +
          '  inSeconds : $inSeconds  isIntradayChart : $isIntradayChart');
    }

    if (lastChartUpdate == null || (isIntradayChart && inSeconds > 10)) {
      lastChartUpdate = DateTime.now();

      print('Requesting chartLine update  at ' + lastChartUpdate.toString());

      final ChartLineData? chartLine = await InvestrendTheme.datafeedHttp
          .fetchChartLine('COMPOSITE', true,
              from: _selectedChartFrom, to: _selectedChartTo);
      if (chartLine != null &&
          chartLine.isValidResponse(
              'COMPOSITE', _selectedChartFrom, _selectedChartTo)) {
        // if (_compositeNotifier.value != null) {
        //   chartLine.setPrev(_compositeNotifier.value.prev);
        // }

        bool intraday = _chartRangeNotifier.value == 0;
        if (_compositeNotifier?.value != null && intraday) {
          //chartLine.setPrev(_compositeNotifier.value.prev, middlePrev: intraday);
          chartLine.setPrev(_compositeNotifier?.value?.prev);
        }
        // harus di normalise
        chartLine.normalize(middlePrev: intraday);

        print('Future chartLine DATA : ' + chartLine.toString());
        //_summaryNotifier.setData(stockSummary);
        //context.read(stockSummaryChangeNotifier).setData(stockSummary);
        if (mounted) {
          _chartNotifier.setValue(chartLine);
        }
      } else {
        print('Future chartLine NO DATA');
      }
    } else {
      print('Skip chartLine update ' +
          lastChartUpdate.toString() +
          '  inSeconds : $inSeconds  isIntradayChart : $isIntradayChart');
    }

    onProgress = false;
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  void requestCandleChart() async {
    if (!active) {
      print(routeName + '.requestChart ignored because active : $active');
      return;
    }

    lastChartUpdate = DateTime.now();
    print('Requesting chartCandle update  at ' + lastChartUpdate.toString());

    setNotifierLoading(_chartOhlcvNotifier);

    try {
      final ChartOhlcvData? chartCandle = await InvestrendTheme.datafeedHttp
          .fetchChartOhlcv('COMPOSITE', true,
              from: _selectedChartFrom, to: _selectedChartTo);
      if (chartCandle != null &&
          chartCandle.isValidResponse(
              'COMPOSITE', _selectedChartFrom, _selectedChartTo)) {
        bool intraday = _chartRangeNotifier.value == 0;
        if (_compositeNotifier?.value != null && intraday) {
          chartCandle.setPrev(_compositeNotifier?.value?.prev);
        }
        chartCandle.normalize(middlePrev: intraday);
        print('Future chartCandle DATA : ' + chartCandle.toString());
        if (chartCandle != null) {
          if (mounted) {
            _chartOhlcvNotifier.setValue(chartCandle);
          }
        } else {
          setNotifierNoData(_chartNotifier);
        }
      } else {
        print('Future chartCandle NO DATA');
      }
    } catch (error) {
      print(error);
      setNotifierError(_chartOhlcvNotifier, error);
    }
  }

  void requestChart() async {
    if (!active) {
      print(routeName + '.requestChart ignored because active : $active');
      return;
    }
    // bool isIntradayChart = StringUtils.isEmtpy(_selectedChartFrom) || StringUtils.isEmtpy(_selectedChartTo);
    //
    // int inSeconds = lastChartUpdate == null ? -1 : DateTime.now().difference(lastChartUpdate).inSeconds;
    //
    // if (lastChartUpdate == null || (isIntradayChart && inSeconds > 10)) {
    lastChartUpdate = DateTime.now();
    print('Requesting chartLine update  at ' + lastChartUpdate.toString());

    setNotifierLoading(_chartNotifier);

    try {
      final ChartLineData? chartLine = await InvestrendTheme.datafeedHttp
          .fetchChartLine('COMPOSITE', true,
              from: _selectedChartFrom, to: _selectedChartTo);
      if (chartLine != null &&
          chartLine.isValidResponse(
              'COMPOSITE', _selectedChartFrom, _selectedChartTo)) {
        bool intraday = _chartRangeNotifier.value == 0;
        if (_compositeNotifier?.value != null && intraday) {
          //chartLine.setPrev(_compositeNotifier.value.prev, middlePrev: intraday);
          chartLine.setPrev(_compositeNotifier?.value?.prev);
        }
        // harus di normalise
        chartLine.normalize(middlePrev: intraday);

        print('Future chartLine DATA : ' + chartLine.toString());
        if (chartLine != null) {
          if (mounted) {
            _chartNotifier.setValue(chartLine);
          }
        } else {
          setNotifierNoData(_chartNotifier);
        }
      } else {
        print('Future chartLine NO DATA');
      }
    } catch (error) {
      print(error);
      setNotifierError(_chartNotifier, error);
    }

    // } else {
    //   print('Skip chartLine update ' + lastChartUpdate.toString() + '  inSeconds : $inSeconds  isIntradayChart : $isIntradayChart');
    // }
  }

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

  AutoSizeGroup groupCode = AutoSizeGroup();
  Widget gridSectors(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      const int gridCount = 3;
      double availableWidth =
          constrains.maxWidth - (InvestrendTheme.cardMargin * 2);
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
            rows.add(tileSectorNew(
                context, listSectors[index], true, tileWidth, groupCode));
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

  Widget createCardSector(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
      margin: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   height: InvestrendTheme.cardPaddingGeneral,
          // ),
          ComponentCreator.subtitleNoButtonMore(
            context,
            'search_market_card_sector_title'.tr(),
          ),
          // SizedBox(
          //   height: InvestrendTheme.cardPaddingGeneral,
          // ),

          listSectors.length > 0
              ? gridSectors(context)
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }
}
