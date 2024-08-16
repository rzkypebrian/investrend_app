// ignore_for_file: non_constant_identifier_names

import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/cards/card_label_value.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenStockDetailCorporateAction extends StatefulWidget {
  final TabController? tabController;
  final int tabIndex;
  final ValueNotifier<bool>? visibilityNotifier;
  ScreenStockDetailCorporateAction(this.tabIndex, this.tabController,
      {Key? key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenStockDetailCorporateActionState createState() =>
      _ScreenStockDetailCorporateActionState(tabIndex, tabController!,
          visibilityNotifier: visibilityNotifier);
}

class _ScreenStockDetailCorporateActionState
    extends BaseStateNoTabsWithParentTab<ScreenStockDetailCorporateAction> {
  ValueNotifier<int>? _caTypeNotifier = ValueNotifier<int>(0);
  CorporateActionNotifier? _dataNotifier =
      CorporateActionNotifier(CorporateActionData());

  _ScreenStockDetailCorporateActionState(
      int tabIndex, TabController tabController,
      {ValueNotifier<bool>? visibilityNotifier})
      : super('/stock_detail_corporate_actions', tabIndex, tabController,
            notifyStockChange: true, visibilityNotifier: visibilityNotifier);

  List<String> _corporate_action_options_others = [
    'corporate_action_dividend'.tr(),
    'corporate_action_right_issue'.tr(),
    'corporate_action_rups'.tr(),
    'corporate_action_stock_split'.tr(),
  ];

  List<String> _types_others = [
    'DIVIDEND',
    'RIGHT_ISSUE',
    'RUPS',
    'STOCK_SPLIT'
  ];

  List<String> _corporate_action_options = [
    'corporate_action_dividend'.tr(),
    'corporate_action_right_issue'.tr(),
    'corporate_action_rups'.tr(),
    'corporate_action_stock_split'.tr(),
  ];

  List<String> _types = ['DIVIDEND', 'RIGHT_ISSUE', 'RUPS', 'STOCK_SPLIT'];

  List<String> _corporate_action_warrant_options = [
    'corporate_action_warrant'.tr(),
  ];

  List<String> _types_warrant = [
    'WARRANT',
  ];

  @override
  void onStockChanged(Stock? newStock) {
    super.onStockChanged(newStock);
    if (newStock != null) {
      if (newStock.isWarrant()) {
        _types = _types_warrant;
        _corporate_action_options = _corporate_action_warrant_options;
        _caTypeNotifier?.value = 0;
      } else {
        _types = _types_others;
        _corporate_action_options = _corporate_action_options_others;
      }
    }
    setState(() {
      doUpdate(pullToRefresh: true);
    });
  }

  // @override
  // bool get wantKeepAlive => true;

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  Widget _title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ComponentCreator.subtitle(context, 'segment_label'.tr()),
          ButtonDropdown(
            _caTypeNotifier,
            _corporate_action_options,
            clickAndClose: true,
          ),
          /*
          ValueListenableBuilder(
            valueListenable: _caTypeNotifier,
            builder: (context, index, child) {
              String activeCA = _corporate_action_options.elementAt(index);

              return MaterialButton(
                  elevation: 0.0,
                  visualDensity: VisualDensity.comfortable,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: InvestrendTheme.of(context).tileBackground,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        activeCA,
                        style: InvestrendTheme.of(context).more_support_w400_compact,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onPressed: () {
                    //InvestrendTheme.of(context).showSnackBar(context, 'Action choose Market');

                    showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                        ),
                        //backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return CorporateActionBottomSheet(_caTypeNotifier, _corporate_action_options);
                        });
                  });
            },
          ),
          */
        ],
      ),
    );
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString());
    if (!active) {
      print(routeName + '.doUpdate aborted active : $active');
      return;
    }
    Stock? stock = context.read(primaryStockChangeNotifier).stock;
    if (stock == null || !stock.isValid()) {
      Stock? stockDefault = InvestrendTheme.storedData!.listStock!.isEmpty
          ? null
          : InvestrendTheme.storedData?.listStock?.first;
      context.read(primaryStockChangeNotifier).setStock(stockDefault!);
      stock = context.read(primaryStockChangeNotifier).stock;
    }

    String type = _types.elementAt(_caTypeNotifier!.value);

    String? code = stock != null ? stock.code : "";
    if (!StringUtils.isEmtpy(code)) {
      setNotifierLoading(_dataNotifier);
      try {
        final CorporateActionData? result =
            await InvestrendTheme.datafeedHttp.fetchCorporateAction(code, type);
        if (result != null && !result.isEmpty()) {
          if (mounted) {
            Stock? stockNow = context.read(primaryStockChangeNotifier).stock;
            String typeNow = _types.elementAt(_caTypeNotifier!.value);
            if (StringUtils.equalsIgnoreCase(result.code!, stockNow?.code) &&
                StringUtils.equalsIgnoreCase(result.type!, typeNow)) {
              print('Got CorporateActionData : ' + result.toString());
              _dataNotifier?.setValue(result);
            } else {
              print('Got CorporateActionData : IGNORED  result.code : ' +
                  result.code! +
                  '  stock_now : ' +
                  stockNow!.code! +
                  '  result.type : ' +
                  result.type! +
                  '  type_now : $typeNow');
            }
          } else {
            print('ignored CorporateActionData, mounted : $mounted');
          }
        } else {
          setNotifierNoData(_dataNotifier);
        }
      } catch (error) {
        print('CorporateActionData : ' + error.toString());
        setNotifierError(_dataNotifier, error);
      }
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    if (!active) {
      active = true;
      //onActive();
      context
          .read(stockDetailScreenVisibilityChangeNotifier)
          .setActive(tabIndex, true);
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  void constructData(
      BuildContext context, CorporateActionData result, List<Widget> list) {
    LabelValueData? datas;
    String? year = '--';

    for (var ca in result.datas!) {
      if (!StringUtils.equalsIgnoreCase(ca.year, year)) {
        if (datas != null) {
          list.add(CardLabelValue(
            year,
            datas,
            paddingTop: 10.0,
          ));
        }
        year = ca.year;
        datas = new LabelValueData();
      }
      if (ca is Dividend) {
        datas!.datas
            ?.add(LabelValue('ca_dividend_total_value'.tr(), ca.totalValue));
        datas.datas?.add(LabelValue('ca_dividend_price'.tr(), ca.price));
        datas.datas?.add(LabelValue('ca_dividend_cum_date'.tr(), ca.cumDate));
        datas.datas?.add(LabelValue('ca_dividend_ex_date'.tr(), ca.exDate));
        datas.datas?.add(
            LabelValue('ca_dividend_recording_date'.tr(), ca.recordingDate));
        datas.datas
            ?.add(LabelValue('ca_dividend_payment_date'.tr(), ca.paymentDate));
        datas.datas?.add(LabelValueDivider());
      } else if (ca is RightIssue) {
        datas!.datas?.add(LabelValue(
            'ca_right_issue_ratio'.tr(),
            ca.ratio1! +
                ' : ' +
                ca.ratio2! +
                ' (' +
                ca.ratioPercentage! +
                ')'));
        datas.datas?.add(LabelValue('ca_right_issue_price'.tr(), ca.price));
        datas.datas
            ?.add(LabelValue('ca_right_issue_cum_date'.tr(), ca.cumDate));
        datas.datas?.add(LabelValue('ca_right_issue_ex_date'.tr(), ca.exDate));
        datas.datas?.add(
            LabelValue('ca_right_issue_recording_date'.tr(), ca.recordingDate));
        datas.datas?.add(
            LabelValue('ca_right_issue_trading_start'.tr(), ca.tradingStart));
        datas.datas
            ?.add(LabelValue('ca_right_issue_trading_end'.tr(), ca.tradingEnd));
        datas.datas?.add(LabelValue(
            'ca_right_issue_subscription_date'.tr(), ca.subscriptionDate));
        datas.datas?.add(LabelValueDivider());
      } else if (ca is RUPS) {
        datas!.datas?.add(
            ContentPlaceInfo(ca.type!, ca.dateTime!, ca.address!, ca.city!));
        datas.datas?.add(LabelValueDivider());
      } else if (ca is StockSplit) {
        datas?.datas?.add(LabelValue(
            'ca_stock_split_ratio'.tr(),
            ca.ratio1! +
                ' : ' +
                ca.ratio2! +
                ' (' +
                ca.ratioPercentage! +
                ')'));
        datas?.datas
            ?.add(LabelValue('ca_stock_split_cum_date'.tr(), ca.cumDate));
        datas?.datas?.add(LabelValue('ca_stock_split_ex_date'.tr(), ca.exDate));
        datas?.datas?.add(
            LabelValue('ca_stock_split_recording_date'.tr(), ca.recordingDate));
        datas?.datas?.add(
            LabelValue('ca_stock_split_trading_date'.tr(), ca.tradingDate));
        datas?.datas?.add(LabelValueDivider());
      } else if (ca is Warrant) {
        datas!.datas?.add(LabelValue(
            'ca_warrant_ratio'.tr(), ca.ratio1! + ' : ' + ca.ratio2!));
        datas.datas?.add(LabelValue('ca_warrant_price'.tr(), ca.price));
        if (ca.isValidData(ca.tradingStart!)) {
          datas.datas?.add(
              LabelValue('ca_warrant_trading_start'.tr(), ca.tradingStart));
        }
        if (ca.isValidData(ca.tradingEnd!)) {
          datas.datas
              ?.add(LabelValue('ca_warrant_trading_end'.tr(), ca.tradingEnd));
        }
        if (ca.isValidData(ca.maturityDate!)) {
          datas.datas?.add(
              LabelValue('ca_warrant_maturity_date'.tr(), ca.maturityDate));
        }
        if (ca.isValidData(ca.exDate!)) {
          datas.datas?.add(LabelValue('ca_warrant_ex_date'.tr(), ca.exDate));
        }
        if (ca.isValidData(ca.cumDate!)) {
          datas.datas?.add(LabelValue('ca_warrant_cum_date'.tr(), ca.cumDate));
        }
        if (ca.isValidData(ca.recordingDate!)) {
          datas.datas?.add(
              LabelValue('ca_warrant_recording_date'.tr(), ca.recordingDate));
        }
        if (ca.isValidData(ca.subscriptionDate!)) {
          datas.datas?.add(LabelValue(
              'ca_warrant_subscription_date'.tr(), ca.subscriptionDate));
        }
        if (ca.isValidData(ca.description!)) {
          datas.datas
              ?.add(LabelValue('ca_warrant_description'.tr(), ca.description));
        }

        datas.datas?.add(LabelValueDivider());
      }
    }

    if (datas != null && datas.count() > 0) {
      list.add(CardLabelValue(
        year,
        datas,
        paddingTop: 10.0,
      ));
    }

    //return list;
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      _title(context),
      SizedBox(
        height: 10.0,
      ),
      ValueListenableBuilder(
        valueListenable: _dataNotifier!,
        builder: (context, data, child) {
          List<Widget> list = List.empty(growable: true);
          Widget? noWidget =
              _dataNotifier?.currentState.getNoWidget(onRetry: () {
            doUpdate(pullToRefresh: true);
          });
          if (noWidget != null) {
            list.add(Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
              child: noWidget,
            ));
          } else {
            constructData(context, data as CorporateActionData, list);
          }

          return Column(
            children: list,
          );
        },
      ),
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
          _title(context),
          ValueListenableBuilder(
            valueListenable: _caTypeNotifier,
            builder: (context, index, child) {
              List<Widget> list = List.empty(growable: true);
              String year = '';
              LabelValueData datas = null;
              if(index == 0){
                dividend.forEach((ca) {
                  if(!StringUtils.equalsIgnoreCase(ca.year, year)){
                      if(datas != null){
                        list.add(CardLabelValue(year,datas));
                      }
                      year = ca.year;
                      datas = new LabelValueData();
                  }
                  datas.datas.add(LabelValue('ca_dividend_total_value'.tr(), InvestrendTheme.formatPrice(ca.totalValue)));
                  datas.datas.add(LabelValue('ca_dividend_price'.tr(), InvestrendTheme.formatPrice(ca.price)));
                  datas.datas.add(LabelValue('ca_dividend_cum_date'.tr(), ca.cumDate));
                  datas.datas.add(LabelValue('ca_dividend_ex_date'.tr(), ca.exDate));
                  datas.datas.add(LabelValue('ca_dividend_recording_date'.tr(), ca.recordingDate));
                  datas.datas.add(LabelValue('ca_dividend_payment_date'.tr(), ca.paymentDate));
                  datas.datas.add(LabelValueDivider());
                });
              }else if(index == 1){
                righIssue.forEach((ca) {
                  if(!StringUtils.equalsIgnoreCase(ca.year, year)){
                    if(datas != null){
                      list.add(CardLabelValue(year,datas));
                    }
                    year = ca.year;
                    datas = new LabelValueData();
                  }

                  datas.datas.add(LabelValue('ca_right_issue_ratio'.tr(), InvestrendTheme.formatComma(ca.ratio1)+' : '+InvestrendTheme.formatComma(ca.ratio2)+' ('+InvestrendTheme.formatPercent(ca.ratioPercentage)+')'));
                  datas.datas.add(LabelValue('ca_right_issue_price'.tr(), InvestrendTheme.formatPrice(ca.price)));
                  datas.datas.add(LabelValue('ca_right_issue_cum_date'.tr(), ca.cumDate));
                  datas.datas.add(LabelValue('ca_right_issue_ex_date'.tr(), ca.exDate));
                  datas.datas.add(LabelValue('ca_right_issue_recording_date'.tr(), ca.recordingDate));
                  datas.datas.add(LabelValue('ca_right_issue_trading_start'.tr(), ca.tradingStart));
                  datas.datas.add(LabelValue('ca_right_issue_trading_end'.tr(), ca.tradingEnd));
                  datas.datas.add(LabelValue('ca_right_issue_subscription_date'.tr(), ca.subscriptionDate));
                  datas.datas.add(LabelValueDivider());


                });
              }else if(index == 2){
                rups.forEach((ca) {
                  if(!StringUtils.equalsIgnoreCase(ca.year, year)){
                    if(datas != null){
                      list.add(CardLabelValue(year,datas));
                    }
                    year = ca.year;
                    datas = new LabelValueData();
                  }

                  datas.datas.add(ContentPlaceInfo(ca.type, ca.dateTime, ca.address, ca.city));
                  datas.datas.add(LabelValueDivider());


                });
              }else if(index == 3){
                stockSplits.forEach((ca) {
                  if(!StringUtils.equalsIgnoreCase(ca.year, year)){
                    if(datas != null){
                      list.add(CardLabelValue(year,datas));
                    }
                    year = ca.year;
                    datas = new LabelValueData();
                  }

                  datas.datas.add(LabelValue('ca_stock_split_ratio'.tr(), InvestrendTheme.formatComma(ca.ratio1)+' : '+InvestrendTheme.formatComma(ca.ratio2)+' ('+InvestrendTheme.formatPercent(ca.ratioPercentage)+')'));
                  datas.datas.add(LabelValue('ca_stock_split_cum_date'.tr(), ca.cumDate));
                  datas.datas.add(LabelValue('ca_stock_split_ex_date'.tr(), ca.exDate));
                  datas.datas.add(LabelValue('ca_stock_split_recording_date'.tr(), ca.recordingDate));
                  datas.datas.add(LabelValue('ca_stock_split_trading_date'.tr(), ca.tradingDate));
                  datas.datas.add(LabelValueDivider());

                });
              }
              if(datas.count() > 0 ){
                list.add(CardLabelValue(year,datas));
              }
              return Column(
                children: list,
              );
            },
          ),
          // CardLabelValueNotifier('card_history_title'.tr(), _historyNotifier),
          // ComponentCreator.divider(context),
          // CardLabelValueNotifier('card_shareholders_composition_title'.tr(), _shareHolderCompositionNotifier),
          // ComponentCreator.divider(context),
          // CardLabelValueNotifier('card_board_of_commisioners_title'.tr(), _boardOfCommisionersNotifier),
          //ComponentCreator.divider(context),

          SizedBox(
            height: paddingBottom + 80,
          ),
        ],
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName + ' onActive');
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, true);
    doUpdate();
  }

  /*
  List<CADividend> dividend = [
    CADividend(250000000000, 50955, '16 Jun 2020', '17 Jun 2020', '18 Jun 2020', '9 Jul 2020', '2020'),
    CADividend(250000000000, 50955, '16 Jun 2019', '17 Jun 2019', '18 Jun 2019', '9 Jul 2019', '2019'),
    CADividend(250000000000, 50955, '16 Jun 2018', '16 Jun 2018', '18 Jun 2018', '9 Jul 2018', '2018'),
    CADividend(250000000000, 50955, '16 Jul 2017', '16 Jul 2017', '18 Jul 2017', '9 Aug 2017', '2017'),
    CADividend(250000000000, 50955, '16 Jun 2017', '16 Jun 2017', '18 Jun 2017', '9 Jul 2017', '2017'),
    CADividend(250000000000, 50955, '16 Jun 2016', '16 Jun 2016', '18 Jun 2016', '9 Jul 2016', '2016'),
  ];

  List<CARightIssue> righIssue = [
    CARightIssue(36690, 8000, 0.45, 1200, '10 Nov 2020', '11 Nov 2020', '15 Nov 2020', '17 Nov 2020', '23 Nov 2020', '23 Nov 2020', '2020'),
    CARightIssue(36690, 8000, 0.45, 1200, '10 Nov 2019', '11 Nov 2019', '15 Nov 2019', '17 Nov 2019', '23 Nov 2019', '23 Nov 2019', '2019'),
    CARightIssue(36690, 8000, 0.45, 1200, '10 Nov 2018', '11 Nov 2018', '15 Nov 2018', '17 Nov 2018', '23 Nov 2018', '23 Nov 2018', '2018'),
    CARightIssue(36690, 8000, 0.45, 1200, '10 Nov 2017', '11 Nov 2017', '15 Nov 2017', '17 Nov 2017', '23 Nov 2017', '23 Nov 2017', '2017'),
  ];

  List<CARups> rups = [
    CARups('RUPST', '08 Jun 2020 - 10:00 WIB', 'Best Western Premier The Hive,\nLantai 3 Jl. D.I Panjaitan Kav. 3-4,', 'Jakarta Timur, Indonesia','2020'),
    CARups('RUPST', '30 Apr 2019 - 10:00 WIB', 'Grand On Thamrin Ballroom Hotel Pullman,\nJl. M. H. Thamrin Kav. 59,', 'Jakarta Pusat, Indonesia','2019'),
    CARups('RUPSLB', '25 Mei 2019 - 09:00 WIB', 'WIKA Tower 2, Rg. Serbaguna Lt. 17,\nJl. D.I. Panjaitan Kav. 9-10,', 'Jakarta Timur, Indonesia','2019'),
    CARups('RUPSLB', '25 Apr 2019 - 09:00 WIB', 'WIKA Tower 2, Rg. Serbaguna Lt. 17,\nJl. D.I. Panjaitan Kav. 9-10,', 'Jakarta Timur, Indonesia','2019'),
    CARups('RUPSLB', '25 Mar 2019 - 09:00 WIB', 'WIKA Tower 2, Rg. Serbaguna Lt. 17,\nJl. D.I. Panjaitan Kav. 9-10,', 'Jakarta Timur, Indonesia','2019'),
    CARups('RUPSLB', '25 Feb 2019 - 09:00 WIB', 'WIKA Tower 2, Rg. Serbaguna Lt. 17,\nJl. D.I. Panjaitan Kav. 9-10,', 'Jakarta Timur, Indonesia','2019'),
    CARups('RUPSLB', '25 Jan 2019 - 09:00 WIB', 'WIKA Tower 2, Rg. Serbaguna Lt. 17,\nJl. D.I. Panjaitan Kav. 9-10,', 'Jakarta Timur, Indonesia','2019'),
  ];

  List<CAStockSplit> stockSplits = [
    CAStockSplit(1, 5, 20.0,  '30 Dec 2020', '02 Jan 2020', '03 Jan 2020', '02 Jan 2020', '2020'),
    CAStockSplit(1, 5, 20.0,  '30 Dec 2019', '02 Jan 2019', '03 Jan 2019', '02 Jan 2019', '2019'),
    CAStockSplit(1, 5, 20.0,  '30 Dec 2018', '02 Aug 2018', '03 Aug 2018', '02 Aug 2018', '2018'),
    CAStockSplit(1, 5, 20.0,  '30 Jul 2018', '02 Jan 2018', '03 Jan 2018', '02 Jan 2018', '2018'),
    CAStockSplit(1, 5, 20.0,  '30 Dec 2017', '02 Jan 2017', '03 Jan 2017', '02 Jan 2017', '2017'),
  ];
  */
  @override
  void initState() {
    super.initState();

    _caTypeNotifier?.addListener(() {
      _dataNotifier?.setValue(null);
      doUpdate(pullToRefresh: true);
    });
    /*
    Future.delayed(Duration(milliseconds: 500), () {
      LabelValueData dataDividend = new LabelValueData();
      dataDividend.datas.add(LabelValue('ca_dividend_total_value'.tr(), '28 Oct 2007'));
      dataDividend.datas.add(LabelValue('ca_dividend_price'.tr(), '11 Oct 2007'));
      dataDividend.datas.add(LabelValue('ca_dividend_cum_date'.tr(), '100'));
      dataDividend.datas.add(LabelValue('ca_dividend_ex_date'.tr(), '420'));
      dataDividend.datas.add(LabelValue('ca_dividend_recording_date'.tr(), '1,85 B'));
      dataDividend.datas.add(LabelValue('ca_dividend_payment_date'.tr(), '775,43 B'));
      dataDividend.datas.add(LabelValueDivider());

      //_historyNotifier.setValue(dataHistory);

      LabelValueData dataRightIssue = new LabelValueData();
      dataDividend.datas.add(LabelValue('ca_right_issue_ratio'.tr(), '28 Oct 2007'));
      dataDividend.datas.add(LabelValue('ca_right_issue_price'.tr(), '11 Oct 2007'));
      dataDividend.datas.add(LabelValue('ca_right_issue_ex_date'.tr(), '100'));
      dataDividend.datas.add(LabelValue('ca_right_issue_recording_date'.tr(), '420'));
      dataDividend.datas.add(LabelValue('ca_right_issue_trading_start'.tr(), '1,85 B'));
      dataDividend.datas.add(LabelValue('ca_right_issue_subscription_date'.tr(), '775,43 B'));
      dataDividend.datas.add(LabelValueDivider());

    });

     */
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Stock? newStock = context.read(primaryStockChangeNotifier).stock;
    if (newStock != null) {
      if (newStock.isWarrant()) {
        _types = _types_warrant;
        _corporate_action_options = _corporate_action_warrant_options;
      } else {
        _types = _types_others;
        _corporate_action_options = _corporate_action_options_others;
      }
    }
  }

  @override
  void dispose() {
    _caTypeNotifier?.dispose();
    _dataNotifier?.dispose();
    final container = ProviderContainer();
    container
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);
    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
    context
        .read(stockDetailScreenVisibilityChangeNotifier)
        .setActive(tabIndex, false);
  }
}
/*
class CorporateActionBottomSheet extends StatelessWidget {
  final ValueNotifier caTypeNotifier;
  final List<String> corporate_action_options;

  const CorporateActionBottomSheet(this.caTypeNotifier, this.corporate_action_options, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    double contentHeight = padding + 44.0 + (44.0 * corporate_action_options.length) + padding;

    //if (contentHeight > minHeight) {
    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);
    //}

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        padding: EdgeInsets.all(padding),
        // color: Colors.yellow,
        width: double.maxFinite,
        child: ValueListenableBuilder(
          valueListenable: caTypeNotifier,
          builder: (context, selectedIndex, child) {
            List<Widget> list = List.empty(growable: true);
            list.add(Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(Icons.clear),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ));
            int count = corporate_action_options.length;
            for (int i = 0; i < count; i++) {
              String ca = corporate_action_options.elementAt(i);
              list.add(createRow(context, ca, selectedIndex == i, i));
            }
            return Column(
              children: list,
            );

          },
        ),
      ),
    );
  }

  Widget createRow(BuildContext context, String label, bool selected, int index) {
    TextStyle style = InvestrendTheme.of(context).regular_w400_compact;
    //Color colorText = style.color;
    Color colorIcon = Colors.transparent;

    if (selected) {
      style = InvestrendTheme.of(context).regular_w700_compact.copyWith(color: Theme.of(context).accentColor);
      //colorText = Theme.of(context).accentColor;
      colorIcon = Theme.of(context).accentColor;
    }

    return SizedBox(
      height: 44.0,
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.0,
              height: 20.0,
            ),
            Expanded(
                flex: 1,
                child: Text(
                  label,
                  style: style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
                  textAlign: TextAlign.center,
                )),
            (selected
                ? Image.asset(
                    'images/icons/check.png',
                    color: colorIcon,
                    width: 20.0,
                    height: 20.0,
                  )
                : SizedBox(
                    width: 20.0,
                    height: 20.0,
                  )),
          ],
        ),
        onPressed: () {
          // setState(() {
          //   selectedIndex = index;
          // });
          //context.read(marketChangeNotifier).setIndex(index);
          caTypeNotifier.value = index;
        },
      ),
    );
  }
}
*/