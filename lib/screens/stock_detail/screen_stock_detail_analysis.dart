

import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/cards/card_local_foreign.dart';
import 'package:Investrend/component/cards/card_performance.dart';
import 'package:Investrend/component/charts/chart_dual_bar.dart';
import 'package:Investrend/component/charts/chart_single_bar.dart';
import 'package:Investrend/component/charts/year_value.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/stock_detail/screen_netbs_summary.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenStockDetailAnalysis extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;

  ScreenStockDetailAnalysis(this.tabIndex, this.tabController, {Key key, this.visibilityNotifier}) : super(key: key);

  @override
  _ScreenStockDetailAnalysisState createState() =>
      _ScreenStockDetailAnalysisState(tabIndex, tabController, visibilityNotifier: visibilityNotifier);
}

class _ScreenStockDetailAnalysisState extends BaseStateNoTabsWithParentTab<ScreenStockDetailAnalysis> {
  LocalForeignNotifier _foreignDomesticNotifier = LocalForeignNotifier(new ForeignDomestic('', '', '', '', 0, 0, 0, 0.0, 0, 0, 0, 0.0));
  ValueNotifier<int> _boardForeignDomesticNotifier = ValueNotifier<int>(0);
  PerformanceNotifier _performanceNotifier = PerformanceNotifier(new PerformanceData());

  // _localForeignNotifier = LocalForeignNotifier(new LocalForeignData());
  // _performanceNotifier = PerformanceNotifier(new PerformanceData());
  List<String> _listChipRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'CR'];
  List<bool> _listChipRangeEnabled = <bool>[true, true, true, true, false, false, false, true];

  //List<String> _movers_ranges = <String>['INTRADAY', '1_WEEK', '1_MONTH', '3_MONTH', '6_MONTH', '1_YEAR', 'CUSTOM'];
  ChartTopBrokerNotifier _topBuyerNotifier = ChartTopBrokerNotifier(DataChartTopBroker.createBasic());
  ChartTopBrokerNotifier _topSellerNotifier = ChartTopBrokerNotifier(DataChartTopBroker.createBasic());
  ChartTopBrokerNetNotifier _topNetBuyerNotifier = ChartTopBrokerNetNotifier(DataChartTopBrokerNet.createBasic());
  ChartTopBrokerNetNotifier _topNetSellerNotifier = ChartTopBrokerNetNotifier(DataChartTopBrokerNet.createBasic());
  // final ValueNotifier<bool> _customRangeNotifier = ValueNotifier(false);
  // final ValueNotifier<String> _customFromNotifier = ValueNotifier<String>('From');
  // final ValueNotifier<String> _customToNotifier = ValueNotifier<String>('To');
  final ValueNotifier<String> _lastDataDateNotifier = ValueNotifier<String>('');
  //final ValueNotifier<int> _rangeTopBrokerNotifier = ValueNotifier<int>(0);
  final RangeNotifier _rangeTopBrokerNotifier = RangeNotifier(Range.createBasic());
  final RangeNotifier _rangeForeignDomesticNotifier = RangeNotifier(Range.createBasic());
  final ValueNotifier<int> marketNotifier = ValueNotifier<int>(0);
  List<String> _market_options = [
    'card_local_foreign_button_all_market'.tr(),
    'card_local_foreign_button_rg_market'.tr(),
  ];

  _ScreenStockDetailAnalysisState(int tabIndex, TabController tabController, {ValueNotifier<bool> visibilityNotifier})
      : super('/stock_detail_analysis', tabIndex, tabController, notifyStockChange: true, visibilityNotifier: visibilityNotifier);

  @override
  void onStockChanged(Stock newStock) {
    super.onStockChanged(newStock);
    doUpdate(pullToRefresh: true);
  } // @override
  // bool get wantKeepAlive => true;

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString());
    if (!active) {
      print(routeName + '.doUpdate aborted active : $active');
      return;
    }

    Stock stock = context.read(primaryStockChangeNotifier).stock;
    if (stock == null || !stock.isValid()) {
      Stock stockDefault = InvestrendTheme.storedData.listStock.isEmpty ? null : InvestrendTheme.storedData.listStock.first;
      context.read(primaryStockChangeNotifier).setStock(stockDefault);
      stock = context.read(primaryStockChangeNotifier).stock;
    }

    context.read(stockSummaryChangeNotifier).setStock(stock);
    context.read(orderBookChangeNotifier).setStock(stock);
    context.read(tradeBookChangeNotifier).setStock(stock);

    try {
      String board = _boardForeignDomesticNotifier.value == 0 ? '*' : 'RG';
      if(_rangeForeignDomesticNotifier.value.index == 0){
        final stockFD = await InvestrendTheme.datafeedHttp.fetchStockFD(stock.code, board);
        if (stockFD != null) {
          if (mounted) {
            _foreignDomesticNotifier.setValue(stockFD);
          }
        } else {
          setNotifierNoData(_foreignDomesticNotifier);
        }
      }else{
        MyRange range  = _rangeForeignDomesticNotifier.getRange();
        if(range.valid()){
          final stockFD = await InvestrendTheme.datafeedHttp.fetchStockFDHistorical(stock.code, board, range.from, range.to);
          if (stockFD != null) {
            if (mounted) {
              _foreignDomesticNotifier.setValue(stockFD);
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
      final performanceData = await InvestrendTheme.datafeedHttp.fetchPerformance('STOCK', stock.code);
      if (performanceData != null) {
        if (mounted) {
          _performanceNotifier.setValue(performanceData);
        }
      } else {
        setNotifierNoData(_performanceNotifier);
      }
    } catch (error) {
      setNotifierError(_performanceNotifier, error);
    }

    String lastDate = '';
    try {
      String board = marketNotifier.value == 0 ? '*' : 'RG';
      //MyRange range = getRange();
      MyRange range = _rangeTopBrokerNotifier.getRange();
      // String from = '2021-12-09';
      // String to = '2021-12-09';
      final stockTopBroker = await InvestrendTheme.datafeedHttp.fetchStockTopBroker(stock.code, board, range.from, range.to);

      if (stockTopBroker != null) {
        lastDate = stockTopBroker.last_date;
        if (mounted) {

          if (stockTopBroker.topBuyer.isEmpty) {
            _topBuyerNotifier.setNoData();
          } else {
            DataChartTopBroker buyer = DataChartTopBroker.createBasic();
            stockTopBroker.topBuyer.forEach((b) {
              buyer.buyData.add(YearValue(b.BrokerCode, b.BValue));
              buyer.sellData.add(YearValue(b.BrokerCode, b.SValue));
            });
            _topBuyerNotifier.setValue(buyer);
          }

          if (stockTopBroker.topSeller.isEmpty) {
            _topSellerNotifier.setNoData();
          } else {
            DataChartTopBroker seller = DataChartTopBroker.createBasic();
            stockTopBroker.topSeller.forEach((b) {
              seller.buyData.add(YearValue(b.BrokerCode, b.BValue));
              seller.sellData.add(YearValue(b.BrokerCode, b.SValue));
            });
            _topSellerNotifier.setValue(seller);
          }

          if (stockTopBroker.topNetBuyer.isEmpty) {
            _topNetBuyerNotifier.setNoData();
          } else {
            DataChartTopBrokerNet net = DataChartTopBrokerNet.createBasic();
            stockTopBroker.topNetBuyer.forEach((b) {
              if (b.NValue > 0) {
                net.netData.add(YearValue(b.BrokerCode, b.NValue));
              }
            });
            _topNetBuyerNotifier.setValue(net);
          }

          if (stockTopBroker.topNetSeller.isEmpty) {
            _topNetSellerNotifier.setNoData();
          } else {
            DataChartTopBrokerNet net = DataChartTopBrokerNet.createBasic();
            stockTopBroker.topNetSeller.forEach((b) {
              if (b.NValue > 0) {
                net.netData.add(YearValue(b.BrokerCode, b.NValue));
              }
            });
            _topNetSellerNotifier.setValue(net);
          }


        }
      } else {
        setNotifierNoData(_topBuyerNotifier);
        setNotifierNoData(_topSellerNotifier);

      }
    } catch (error) {
      setNotifierError(_topBuyerNotifier, error);
      setNotifierError(_topSellerNotifier, error);
    }
    if(mounted){
      _lastDataDateNotifier.value = lastDate;
    }

    /*
    try{
      final stockSummary = await HttpSSI.fetchStockSummary(stock.code, stock.defaultBoard);
      if (stockSummary != null) {
        print(routeName + ' Future Summary DATA : ' + stockSummary.toString());
        //_summaryNotifier.setData(stockSummary);
        context.read(stockSummaryChangeNotifier).setData(stockSummary);
      } else {
        print(routeName + ' Future Summary NO DATA');
      }
    }catch(errorSummary){
      print(routeName + ' Future Summary Error');
      print(errorSummary);
    }
    */
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    if (!active) {
      active = true;
      //onActive();
      context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  Widget _titleTopBrokerTransaction(BuildContext context) {
    //double paddingMargin = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return Padding(
      padding: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingVertical,
          top: InvestrendTheme.cardPaddingVertical),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ComponentCreator.subtitle(
              context,
              'top_broker_transaction_title'.tr(),
            ),
          ),
          ButtonDropdown(marketNotifier, _market_options),
        ],
      ),
    );
  }

  Widget _infoTopBrokerTransaction(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _lastDataDateNotifier,
      builder: (context, String date, child) {
        if (StringUtils.isEmtpy(date)) {
          return SizedBox(
            width: 1.0,
            height: 0.0,
          );
        }

        //String info = 'last_data_date_info_label'.tr();
        //info = info.replaceAll('#DATE#', date);

        String displayTime = date;
        if( !StringUtils.isEmtpy(date)){
          String infoTime = 'last_data_date_info_label'.tr();

          DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
          //DateFormat timeFormatter = DateFormat('HH:mm:ss');
          DateFormat dateParser = DateFormat('yyyy-MM-dd');
          DateTime dateTime = dateParser.parseUtc(date);
          print('dateTime : '+dateTime.toString());
          print('stock_top_broker.last_date : '+date);
          String formatedDate = dateFormatter.format(dateTime);
          //String formatedTime = timeFormatter.format(dateTime);
          infoTime = infoTime.replaceAll('#DATE#', formatedDate);
          //infoTime = infoTime.replaceAll('#TIME#', formatedTime);
          displayTime = infoTime;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, /*top: InvestrendTheme.cardPaddingGeneral, */ /*bottom: InvestrendTheme.cardPaddingVertical*/ bottom: InvestrendTheme.cardPaddingGeneral),
                child: Text(
                  displayTime,
                  style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
                        fontWeight: FontWeight.w500,
                        color: InvestrendTheme.of(context).greyDarkerTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Stock stock = context.read(primaryStockChangeNotifier).stock;
                    //String board = marketNotifier.value == 0 ? '*' : 'RG';
                    MyRange range = _rangeTopBrokerNotifier.getRange();
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ScreenNetBuySellSummary(stock.code, marketNotifier.value, init_data_by: 'value', init_type: '*', init_range: range, ),
                          settings: RouteSettings(name: '/netbs_summary'),
                        ));
                  },
                  child: Text(
                    "button_show_more".tr() ,
                    textAlign: TextAlign.end,
                    style: InvestrendTheme.of(context)
                        .small_w600
                        .copyWith(color: InvestrendTheme.of(context).investrendPurple/*, fontWeight: FontWeight.bold*/),
                  ),
                ),
              ),
            ),
            SizedBox(height: InvestrendTheme.cardPaddingVertical,),
          ],
        );
      },
    );
  }

  

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      CardLocalForeign(_foreignDomesticNotifier, _boardForeignDomesticNotifier,_rangeForeignDomesticNotifier),
      // SizedBox(height: 16.0,),
      // SizedBox(height: 16.0,),
      ComponentCreator.divider(context, thickness: 2.0),
      // SizedBox(height: 16.0,),
      CardPerformance(_performanceNotifier),

      ComponentCreator.divider(context, thickness: 2.0),
      /*
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: ComponentCreator.subtitle(context, 'top_broker_transaction_title'.tr()),
      ),
      */
      _titleTopBrokerTransaction(context),
      ChipsRangeCustom(_rangeTopBrokerNotifier, paddingLeftRight: InvestrendTheme.cardPaddingGeneral, paddingBottom: InvestrendTheme.cardPaddingVertical,),
      /*
      ChipsRange(_listChipRange, _rangeTopBrokerNotifier, paddingLeftRight: InvestrendTheme.cardPaddingGeneral, enable: _listChipRangeEnabled,),
      ValueListenableBuilder(
          valueListenable: _customRangeNotifier,
          builder: (context, value, child) {
            if (value) {
              return Container(
                //color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: _customFromNotifier,
                        builder: (context, value, child) {
                          return TextButton(
                              onPressed: () {
                                selectFrom(context);
                              },
                              child: Text(value));
                        }),
                    Text(
                      ' - ',
                      style: InvestrendTheme.of(context).small_w500_compact_greyDarker,
                    ),
                    ValueListenableBuilder(
                        valueListenable: _customToNotifier,
                        builder: (context, value, child) {
                          return TextButton(
                              onPressed: () {
                                selectTo(context);
                              },
                              child: Text(value));
                        }),
                  ],
                ),
              );
            } else {
              return SizedBox(
                width: 1.0,
                height: InvestrendTheme.cardPaddingVertical,
              );
            }
          }),
      //SizedBox(height: 8.0),
      */
      Padding(
        padding: const  EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          //top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Text(
          'top_buyer_title'.tr(),
          style: InvestrendTheme.of(context).small_w600_compact_greyDarker,
        ),
      ),

      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          //bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _topBuyerNotifier,
              builder: (context, DataChartTopBroker value, child) {
                Widget noWidget = _topBuyerNotifier.currentState.getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }
                return ChartDualBar(
                  value.buyData,
                  value.sellData,
                  'buy_value_label'.tr(),
                  'sell_value_label'.tr(),
                  Theme.of(context).colorScheme.secondary,
                  InvestrendTheme.redText,
                  animate: true,
                );
              }),
        ),
      ),

      // SizedBox(height: 10.0),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
        ),
        child: ComponentCreator.divider(context),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        //child: ComponentCreator.subtitle(context, 'top_seller_title'.tr()),
        child: Text(
          'top_seller_title'.tr(),
          style: InvestrendTheme.of(context).small_w600_compact_greyDarker,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          //bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _topSellerNotifier,
              builder: (context, DataChartTopBroker value, child) {
                Widget noWidget = _topSellerNotifier.currentState.getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }
                return ChartDualBar(
                  value.buyData,
                  value.sellData,
                  'buy_value_label'.tr(),
                  'sell_value_label'.tr(),
                  Theme.of(context).colorScheme.secondary,
                  InvestrendTheme.redText,
                  animate: true,
                );
              }),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
        ),
        child: ComponentCreator.divider(context),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        //child: ComponentCreator.subtitle(context, 'top_seller_title'.tr()),
        child: Text(
          'top_net_buyer_title'.tr(),
          style: InvestrendTheme.of(context).small_w600_compact_greyDarker,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          //bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _topNetBuyerNotifier,
              builder: (context, DataChartTopBrokerNet value, child) {
                Widget noWidget = _topNetBuyerNotifier.currentState.getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }
                return ChartSingleBar(
                  value.netData,
                  'net_buy_value_label'.tr(),
                  Theme.of(context).colorScheme.secondary,
                  animate: true,
                );
              }),
        ),
      ),

      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
        ),
        child: ComponentCreator.divider(context),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
        ),
        //child: ComponentCreator.subtitle(context, 'top_seller_title'.tr()),
        child: Text(
          'top_net_seller_title'.tr(),
          style: InvestrendTheme.of(context).small_w600_compact_greyDarker,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          //bottom: InvestrendTheme.cardPaddingVertical,
        ),
        child: Container(
          width: double.maxFinite,
          height: 300.0,
          //child: ChartBarLine.withSampleData(),
          child: ValueListenableBuilder(
              valueListenable: _topNetSellerNotifier,
              builder: (context, DataChartTopBrokerNet value, child) {
                Widget noWidget = _topNetSellerNotifier.currentState.getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(child: noWidget);
                }
                return ChartSingleBar(
                  value.netData,
                  'net_sell_value_label'.tr(),
                  InvestrendTheme.redText,
                  animate: true,
                );
              }),
        ),
      ),

      _infoTopBrokerTransaction(context),
      // SizedBox(height: 10.0),
      ComponentCreator.divider(context,thickness: 2.0),

      SizedBox(
        height: paddingBottom + 80,
      ),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ListView(
        controller: pScrollController,
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
        children: [
          CardLocalForeign(_localForeignNotifier),
          SizedBox(height: 16.0,),
          SizedBox(height: 16.0,),
          ComponentCreator.divider(context),
          SizedBox(height: 16.0,),
          CardPerformance(_performanceNotifier),
          SizedBox(height: paddingBottom + 80,),
        ],
      ),
    );
  }
  */

  @override
  void onActive() {
    //print(routeName+' onActive');
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate();
    // });

    // runPostFrame(doUpdate);
    context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    doUpdate(pullToRefresh: true);
  }

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _boardForeignDomesticNotifier.addListener(() {
      doUpdate();
    });

    _rangeTopBrokerNotifier.addListener(() {
      doUpdate();
      /*
      if (_rangeTopBrokerNotifier.value == 7) {
        // Custom Range
        _customRangeNotifier.value = true;
      } else {
        _customRangeNotifier.value = false;
        doUpdate();
      }

       */
    });
    _rangeForeignDomesticNotifier.addListener(() {
      print(routeName+'._rangeForeignDomesticNotifier event   '+_rangeForeignDomesticNotifier.value.toString());
      doUpdate();
    });
    marketNotifier.addListener(() {
      doUpdate();
    });
  }
  /*
  void selectFrom(BuildContext context) {
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2021, 9, 1), maxTime: DateTime.now(), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      _customFromNotifier.value = _dateFormat.format(date);
      if (customRangeIsValid()) {
        doUpdate();
      }
    }, currentTime: DateTime.now());
  }

  void selectTo(BuildContext context) {
    DatePicker.showDatePicker(context, showTitleActions: true, minTime: DateTime(2021, 9, 1), maxTime: DateTime.now(), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      _customToNotifier.value = _dateFormat.format(date);
      if (customRangeIsValid()) {
        doUpdate();
      }
    }, currentTime: DateTime.now());
  }

  bool customRangeIsValid() {
    return !StringUtils.equalsIgnoreCase(_customFromNotifier.value, 'From') && !StringUtils.equalsIgnoreCase(_customToNotifier.value, 'To');
  }


  MyRange getRange() {
    DateTime from;
    DateTime to;
    //widget.callbackRange(_listChipRange[_selectedRange]);
    //  0      1    2     3      4     5    6      7
    //['1D', '1W', '1M', '3M', '6M', '1Y', '5Y', 'All'];
    if (_rangeTopBrokerNotifier.value == 0) {
      MyRange range = MyRange();
      range.from = 'LD';
      range.to = 'LD';
      return range;
    } else if (_rangeTopBrokerNotifier.value == 7) {
      MyRange range = MyRange();
      range.from = StringUtils.equalsIgnoreCase(_customFromNotifier.value, 'From') ? '' : _customFromNotifier.value;
      range.to = StringUtils.equalsIgnoreCase(_customToNotifier.value, 'To') ? '' : _customToNotifier.value;
      return range;
    }
    switch (_rangeTopBrokerNotifier.value) {
      case 0:
        {
          to = DateTime.now();
          from = DateTime.now();
        }
        break;
      case 1:
        {
          to = DateTime.now();
          from = DateTime.now().add(Duration(days: -7)); // - week
        }
        break;
      case 2:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 1, to.day); // - 1 month
        }
        break;
      case 3:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 3, to.day); // - 3 month
        }
        break;
      case 4:
        {
          to = DateTime.now();
          from = new DateTime(to.year, to.month - 6, to.day); // - 6 month
        }
        break;
      case 5:
        {
          to = DateTime.now();
          from = new DateTime(to.year - 1, to.month, to.day); // - 1 year
        }
        break;
      case 6:
        {
          to = DateTime.now();
          from = new DateTime(to.year - 5, to.month, to.day); // - 5 year
        }
        break;
      case 7:
        {
          to = DateTime.now();
          from = new DateTime(1945, 8, 17); // Custom Range - di atas
        }
        break;
    }
    MyRange range = MyRange();
    range.from = from == null ? '' : _dateFormat.format(from);
    range.to = to == null ? '' : _dateFormat.format(to);
    return range;
  }
  */
  void onSummaryChanged() {
    bool notMounted = !mounted;
    if (notMounted) {
      print(routeName + ' stockSummaryChangeNotifier aborted -->  notMounted : $notMounted');
      return;
    }

    bool contexIsNull = context == null;
    if (contexIsNull) {
      print(routeName + ' stockSummaryChangeNotifier aborted -->  contexIsNull : $contexIsNull');
      return;
    }

    print(routeName + ' stockSummaryChangeNotifier called');

    //_foreignDomesticNotifier.setValue(null);

    // StockSummary summary = context.read(stockSummaryChangeNotifier).summary;
    // PerformanceData pd = PerformanceData();
    // pd.intraday_change = summary.change;
    // pd.intraday_percent_change = summary.percentChange;
    // pd.year_1_percent_change = summary.returnYTD;
    // pd.year_1_change = summary.returnYTD;
    //
    // pd.month_1_percent_change = summary.returnMTD;
    // pd.month_1_change = summary.returnMTD;
    // _performanceNotifier.setValue(pd);
  }

  // bool listenerAdded = false;
  // VoidCallback summaryListener = VoidCallback(){
  //   print(routeName+' summaryListener called');
  // };
  //VoidCallback stockChangeListener;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // if(listenerAdded){
    //   context.read(stockSummaryChangeNotifier).removeListener(summaryListener);
    // }
    //context.read(stockSummaryChangeNotifier).addListener(onSummaryChanged);

    // if (stockChangeListener != null) {
    //   context.read(primaryStockChangeNotifier).removeListener(stockChangeListener);
    // }
    //
    // // if (stockChangeListener == null) {
    // stockChangeListener = () {
    //   if (!mounted) {
    //     print(routeName + '.stockChangeListener aborted, caused by widget mounted : ' + mounted.toString());
    //     return;
    //   }
    //   print(routeName + '.stockChangeListener mounted : $mounted');
    //   if (active) {
    //     doUpdate(pullToRefresh: true);
    //   }
    // };
    // context.read(primaryStockChangeNotifier).addListener(stockChangeListener);
  }

  @override
  void dispose() {
    _boardForeignDomesticNotifier.dispose();
    _foreignDomesticNotifier.dispose();
    _performanceNotifier.dispose();
    _topBuyerNotifier.dispose();
    _topSellerNotifier.dispose();
    _topNetBuyerNotifier.dispose();
    _topNetSellerNotifier.dispose();
    _rangeTopBrokerNotifier.dispose();
    marketNotifier.dispose();
    _lastDataDateNotifier.dispose();
    // _customRangeNotifier.dispose();
    _rangeForeignDomesticNotifier.dispose();
    final container = ProviderContainer();
    container.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, false);
    // if(stockChangeListener != null){
    //   container.read(primaryStockChangeNotifier).removeListener(stockChangeListener);
    // }

    super.dispose();
  }

  @override
  void onInactive() {
    context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, false);
    //print(routeName+' onInactive');
  }
}

class MyRange {
  String from = '';
  String to = '';
  int index = 0;
  bool valid(){
    return !StringUtils.isEmtpy(from) && !StringUtils.isEmtpy(to);
  }
}
