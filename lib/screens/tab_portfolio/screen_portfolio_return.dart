import 'dart:math';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/cards/card_earning_pershare.dart';
import 'package:Investrend/component/cards/card_general_price.dart';
import 'package:Investrend/component/cards/card_label_value.dart';
import 'package:Investrend/component/cards/card_local_foreign.dart';
import 'package:Investrend/component/cards/card_performance.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rows/row_general_price.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_screen_tabs.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_portfolio/component/bottom_sheet_list.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_detail.dart';
import 'package:Investrend/screens/trade/screen_trade.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenPortfolioReturn extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  ScreenPortfolioReturn(this.tabIndex, this.tabController, {Key key}) : super(key: key);

  @override
  _ScreenPortfolioReturnState createState() => _ScreenPortfolioReturnState(tabIndex, tabController);
}

class _ScreenPortfolioReturnState extends BaseStateNoTabsWithParentTab<ScreenPortfolioReturn> {
  final ReturnNotifier _returnDataNotifier = ReturnNotifier(new ReturnData());

  final ValueNotifier _rangeNotifier = ValueNotifier<int>(0);

  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenPortfolioReturnState(int tabIndex, TabController tabController)
      : super('/portfolio_return', tabIndex, tabController, parentTabIndex: Tabs.Portfolio.index);

  // @override
  // bool get wantKeepAlive => true;

  List<String> _range_options = [
    'daily_label'.tr(),
    'weekly_label'.tr(),
    'monthly_label'.tr(),
    'annual_label'.tr(),
  ];

  Widget _options(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        children: [
          Row(
            children: [
              OutlinedButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 10.0,
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        'button_filter'.tr(),
                        style: InvestrendTheme.of(context).more_support_w400_compact,
                      ),
                    ],
                  )),
              Spacer(
                flex: 1,
              ),
              ValueListenableBuilder(
                valueListenable: _rangeNotifier,
                builder: (context, index, child) {
                  String activeCA = _range_options.elementAt(index);

                  return MaterialButton(
                      elevation: 0.0,
                      //visualDensity: VisualDensity.comfortable,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: InvestrendTheme.of(context).tileBackground,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            activeCA,
                            style: InvestrendTheme.of(context)
                                .more_support_w400_compact
                                .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
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
                              return ListBottomSheet(_rangeNotifier, _range_options);
                            });
                      });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = List.empty(growable: true);
    childs.add(
      _options(context),
    );
    childs.add(ValueListenableBuilder(
      valueListenable: _returnDataNotifier,
      builder: (context, ReturnData data, child) {
        if (_returnDataNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        return tableReturn(context, data);
      },
    ));
    childs.add(SizedBox(height: paddingBottom));
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
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
    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingPlusMargin, bottom: InvestrendTheme.cardPaddingPlusMargin),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            _options(context),
            // SizedBox(
            //   height: 8.0,
            // ),
            ValueListenableBuilder(
              valueListenable: _returnDataNotifier,
              builder: (context, ReturnData data, child) {
                if (_returnDataNotifier.invalid()) {
                  return Center(child: CircularProgressIndicator());
                }
                return tableReturn(context, data);
              },
            ),

            SizedBox(
              height: paddingBottom + 80,
            ),
          ],
        ),
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName + ' onActive');
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      ReturnData dataMovers = ReturnData();
      dataMovers.datas.add(Return('28/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Return('27/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Return('26/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Return('25/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Return('24/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Return('23/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Return('22/01/2021', 3000000, 1.96));
      dataMovers.datas.add(Return('21/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Return('20/01/2021', -3000000, -1.96));
      dataMovers.datas.add(Return('19/01/2021', 3000000, 1.96));
      _returnDataNotifier.setValue(dataMovers);
    });
  }

  @override
  void dispose() {
    _returnDataNotifier.dispose();
    _rangeNotifier.dispose();

    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
  }

  Widget tableReturn(BuildContext context, ReturnData data) {
    TextStyle small500 = InvestrendTheme.of(context).small_w500;
    TextStyle small400 = InvestrendTheme.of(context).small_w400;
    TextStyle smallLighter400 = small400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor);
    TextStyle smallDarker400 = small400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle reguler700 = InvestrendTheme.of(context).regular_w600;

    const double paddingTopBottom = 15.0;
    const double paddingHeaderTopBottom = 10.0;
    List<TableRow> list = List.empty(growable: true);
    list.add(TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        child: Text('date_label'.tr(), style: small500),
      ),
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        child: Text('value_label'.tr(), style: small500, textAlign: TextAlign.left),
      ),
      Padding(
        padding: const EdgeInsets.only(top: paddingHeaderTopBottom, bottom: paddingHeaderTopBottom),
        child: Text(
          'yield_percent_label'.tr(),
          style: small500,
          textAlign: TextAlign.right,
        ),
      ),
    ]));

    list.add(TableRow(children: [
      ComponentCreator.divider(context, thickness: 1.5),
      ComponentCreator.divider(context, thickness: 1.5),
      ComponentCreator.divider(context, thickness: 1.5),
    ]));
    // list.add(TableRow(children: [
    //   SizedBox(height: paddingTopBottom,),
    //   SizedBox(height: paddingTopBottom,),
    //   SizedBox(height: paddingTopBottom,),
    // ]));

    if (data.count() > 0) {
      bool first = true;
      data.datas.forEach((rdn) {
        if (!first) {
          list.add(TableRow(children: [
            ComponentCreator.divider(context),
            ComponentCreator.divider(context),
            ComponentCreator.divider(context),
          ]));
        }
        first = false;
        GestureTapCallback onTap = () {
          print('onTap rdn : ' + rdn.date);

          int beginning_asset_value = 3000000000;
          int deposit = 0;
          int withdraw = 0;
          int change = 30000000;
          int end_asset_value = 3030000000;
          int gain_loss = 30000000;
          double yield = 1.00;
          List<LabelValueColor> listLVC = [
            LabelValueColor(
              'portfolio_detail_beginning_asset_value_label'.tr(),
              InvestrendTheme.formatMoney(beginning_asset_value, prefixRp: true),
            ),
            LabelValueColor(
              'portfolio_detail_deposit_label'.tr(),
              deposit == 0 ? 'N/A' : InvestrendTheme.formatMoney(deposit),
            ),
            LabelValueColor(
              'portfolio_detail_withdraw_label'.tr(),
              withdraw == 0 ? 'N/A' : InvestrendTheme.formatMoney(withdraw),
            ),
            LabelValueColor('portfolio_detail_change_label'.tr(), InvestrendTheme.formatMoney(change, prefixRp: true, prefixPlus: true)),
            LabelValueColor('portfolio_detail_end_asset_value_label'.tr(), InvestrendTheme.formatMoney(end_asset_value)),
            LabelValueColor('portfolio_detail_gain_loss_label'.tr(), InvestrendTheme.formatMoney(gain_loss, prefixPlus: true, prefixRp: true),
                color: InvestrendTheme.priceTextColor(30000000)),
            LabelValueColor(
              'portfolio_detail_yield_label'.tr(),
              InvestrendTheme.formatPercent(yield),
            ),
          ];
          /*
          InvestrendTheme.push(context, ScreenPortfolioDetail('portfolio_detail_return_title'.tr(), rdn.value, rdn.date, listLVC),
              ScreenTransition.SlideUp, '/portfolio_detail');
          */
        };

        Color colorValue = InvestrendTheme.priceTextColor(rdn.value);
        list.add(TableRow(children: [
          TableRowInkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
              child: Text(rdn.date, style: smallDarker400),
            ),
          ),
          TableRowInkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
              child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    InvestrendTheme.formatMoney(rdn.value, prefixRp: true),
                    style: reguler700.copyWith(color: colorValue),
                    textAlign: TextAlign.left,
                  )),
            ),
          ),
          TableRowInkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: paddingTopBottom, bottom: paddingTopBottom),
              child: Text(
                InvestrendTheme.formatPercentChange(rdn.yield, sufixPercent: false),
                style: smallLighter400,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ]));
      });
    }

    return Padding(
      padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.30),
          1: FractionColumnWidth(.45),
          2: FractionColumnWidth(.25),
        },
        children: list,
      ),
    );
  }
}
