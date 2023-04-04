

import 'package:Investrend/component/button_banner_open_account.dart';
import 'package:Investrend/component/cards/card_activity_rdn.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/component/widget_buying_power.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/screen_no_account.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenPortfolioCash extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  ScreenPortfolioCash(this.tabIndex, this.tabController, {Key key}) : super(key: key);

  @override
  _ScreenPortfolioCashState createState() => _ScreenPortfolioCashState(tabIndex, tabController);
}

class _ScreenPortfolioCashState extends BaseStateNoTabsWithParentTab<ScreenPortfolioCash> {
  CashPositionNotifier _cashNotifier = CashPositionNotifier(CashPosition.createBasic());
  MutasiNotifier _mutasiNotifier = MutasiNotifier(ResultMutasi());

  GroupedNotifier _groupedNotifier = GroupedNotifier(GroupedData());
  final ValueNotifier<bool> _accountNotifier = ValueNotifier<bool>(false);

  // GeneralPriceNotifier _idNotifier = GeneralPriceNotifier(new GeneralPriceData());

  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenPortfolioCashState(int tabIndex, TabController tabController)
      : super('/portfolio_cash', tabIndex, tabController, parentTabIndex: Tabs.Portfolio.index);

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Widget rdnBalance(BuildContext context, {double additionalPaddingLeftRight = 0.0}) {
    // int rdnBalance = 200000000;
    // int tradingLimit = 50000000;

    TextStyle support400 = InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    TextStyle reguler700 = InvestrendTheme.of(context).regular_w600_compact;

    double paddingLeftRight = /*additionalPaddingLeftRight +*/ InvestrendTheme.cardPaddingGeneral;
    return Padding(
      padding: EdgeInsets.only(left: paddingLeftRight, right: paddingLeftRight),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.4),
          1: FractionColumnWidth(.6),
        },
        children: [
          TableRow(
              children: [
            Container(
              //color: Colors.red,
              margin: EdgeInsets.only(bottom: InvestrendTheme.cardPaddingGeneral),
              child: Row(

                children: [
                  Text(
                    'cash_available_label'.tr(),
                    style: support400,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  //Icon(Icons.info_outline,size: 15.0,color: Theme.of(context).accentColor,),
                  TapableWidget(
                    onTap: (){

                      InvestrendTheme.of(context).showDialogTooltips(context, 'cash_available_label'.tr(), 'cash_available_info'.tr());
                    },
                    child: Image.asset(
                      'images/icons/information.png',
                      width: 10.0,
                      height: 10.0,
                    ),
                  ),
                  Text(
                    '',
                    style: reguler700,
                  ),
                ],
              ),
            ),
            Container(
              // color: Colors.green,
              child: ValueListenableBuilder(
                valueListenable: _cashNotifier,
                builder: (context, CashPosition data, child) {
                  Widget noWidget = _cashNotifier.currentState.getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                  if (noWidget != null) {
                    return Center(
                      child: noWidget,
                    );
                  }

                  return Text(
                    InvestrendTheme.formatMoneyDouble(data.availableCash, prefixRp: true),
                    style: reguler700,
                  );
                },
              ),
            ),


          ]),


          TableRow(children: [
            Row(
              children: [
                Text(
                  'credit_limit_label'.tr(),
                  style: support400,
                ),
                SizedBox(
                  width: 5.0,
                ),
                //Icon(Icons.info_outline,size: 15.0,color: Theme.of(context).accentColor,),

                TapableWidget(
                  onTap: (){
                    VoidCallback onPressedYes = (){
                      Navigator.of(context).pop();
                    };
                    InvestrendTheme.of(context).showDialogTooltips(context, 'credit_limit_label'.tr(), 'credit_limit_info'.tr(),);
                  },
                  child: Image.asset(
                    'images/icons/information.png',
                    width: 10.0,
                    height: 10.0,
                  ),
                ),
                Text(
                  '',
                  style: reguler700,
                ),
              ],
            ),
            ValueListenableBuilder(
              valueListenable: _cashNotifier,
              builder: (context, CashPosition data, child) {
                Widget noWidget = _cashNotifier.currentState.getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
                if (noWidget != null) {
                  return Center(
                    child: noWidget,
                  );
                }

                String tradingLimitText = InvestrendTheme.formatMoneyDouble(data.creditLimit, prefixRp: true) ;
                return Text(
                  tradingLimitText,
                  style: reguler700,
                );
              },
            ),

          ]),

        ],
      ),
    );
  }

  /*
  Widget historicalRDN(BuildContext context) {
    TextStyle small400 = InvestrendTheme.of(context).small_w400;
    TextStyle reguler400 = InvestrendTheme.of(context).regular_w700;
    return Padding(
      padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.3),
          1: FractionColumnWidth(.3),
          2: FractionColumnWidth(.4),
        },
        children: [
          TableRow(
              children: [
                Text('Tanggal', style: small400,),
                Text('Transaksi', style: small400,),
                Text('Nilai', style: small400,),
              ]
          ),
          TableRow(
            children: [
              ComponentCreator.divider(context,thickness: 1.5),
              ComponentCreator.divider(context,thickness: 1.5),
              ComponentCreator.divider(context,thickness: 1.5),
            ]
          ),
          TableRow(
              children: [
                Text(InvestrendTheme.formatMoney(rdnBalance, prefixRp: true),style: reguler700,),
                Text(InvestrendTheme.formatMoney(tradingLimit, prefixRp: true),style: reguler700,),
                Text(InvestrendTheme.formatMoney(tradingLimit, prefixRp: true),style: reguler700,),
              ]
          ),
        ],
      ),
    );
  }

  */

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate : ' + DateTime.now().toString() + "  active : $active  pullToRefresh : $pullToRefresh");

    final notifier = context.read(accountChangeNotifier);

    User user = context.read(dataHolderChangeNotifier).user;
    Account activeAccount = user.getAccount(notifier.index);
    if (activeAccount == null) {
      print(routeName + '  active Account is NULL');
      return false;
    }
    //updateAccountCashPosition(context);

    try {
      if (_cashNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_cashNotifier);
      }
      final result = await InvestrendTheme.tradingHttp.cashPosition(activeAccount.brokercode, activeAccount.accountcode, user.username,
          InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        DebugWriter.info(routeName + ' Future cash DATA : ' + result.toString());
        if (mounted) {
          _cashNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future cash NO DATA');
        setNotifierNoData(_cashNotifier);
      }
    } catch (error) {
      print(routeName + ' Future cash Error');
      print(error);
      setNotifierError(_cashNotifier, error.toString());
      handleNetworkError(context, error);
    }
    /*
    try {
      if (_mutasiNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_mutasiNotifier);
      }
      final result = await InvestrendTheme.tradingHttp.riwayatRDN(activeAccount.brokercode, activeAccount.accountcode, user.username,
          InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future riwayatRDN DATA : ' + result.toString());
        if (mounted) {
          _mutasiNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future riwayatRDN NO DATA');
        setNotifierNoData(_mutasiNotifier);
      }
    } catch (error) {
      print(routeName + ' Future riwayatRDN Error');
      print(error);
      setNotifierError(_mutasiNotifier, error.toString());
      handleNetworkError(context, error);
    }
    */
    try {
      if (_groupedNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_groupedNotifier);
      }
      final result = await InvestrendTheme.tradingHttp.riwayatRDN(activeAccount.brokercode, activeAccount.accountcode, user.username,
          InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future riwayatRDN DATA : ' + result.toString());
        if (mounted) {
          _groupedNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future riwayatRDN NO DATA');
        setNotifierNoData(_groupedNotifier);
      }
    } catch (error) {
      print(routeName + ' Future riwayatRDN Error');
      print(error);
      setNotifierError(_groupedNotifier, error.toString());
      handleNetworkError(context, error);
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    if (!active) {
      active = true;
      onActive();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    /*
    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (!hasAccount) {
      return ScreenNoAccount();
    }
    */
    List<Widget> preWidget = List.empty(growable: true);

    preWidget.add(Padding(
      padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: WidgetBuyingPower(),
    ));
    preWidget.add(SizedBox(
      height: 15.0,
    ));
    preWidget.add(rdnBalance(context, additionalPaddingLeftRight: InvestrendTheme.cardPaddingGeneral));
    preWidget.add(SizedBox(
      height: InvestrendTheme.cardPaddingVertical,
    ));
    preWidget.add(ComponentCreator.dividerCard(context));
    // preWidget.add(SizedBox(height: 10.0,));
    /*
    preWidget.add(CardCashMutationHistorical(
      _mutasiNotifier,
      onRetry: () => doUpdate(pullToRefresh: true),
    ));
    */
    preWidget.add(CardMutationHistorical(
      _groupedNotifier,
      onRetry: () => doUpdate(pullToRefresh: true),
    ));

    //preWidget.add(SizedBox(height: paddingBottom + 80,));
    preWidget.add(SizedBox(
      height: paddingBottom,
    ));
    // Widget postWidget = SizedBox(
    //   height: paddingBottom,
    // );

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ListView.builder(
          shrinkWrap: false,
          padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
          itemCount: preWidget.length,
          itemBuilder: (BuildContext context, int index) {
            return preWidget.elementAt(index);
          }),
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {


    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top:InvestrendTheme.cardPaddingPlusMargin, bottom: InvestrendTheme.cardPaddingPlusMargin),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.only(left:InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin),
              child: WidgetBuyingPower(),
            ),
            SizedBox(height: 15.0,),
            rdnBalance(context, additionalPaddingLeftRight: InvestrendTheme.cardPaddingPlusMargin),
            SizedBox(height: 15.0,),
            ComponentCreator.divider(context),
            SizedBox(height: 20.0,),
            //ComponentCreator.subtitle(context, 'Riwayat RDN'),
            //historicalRDN(context),
            Padding(
              padding: const EdgeInsets.only(left:InvestrendTheme.cardPaddingPlusMargin, right: InvestrendTheme.cardPaddingPlusMargin),
              child: CardActivityRDN(_rdnNotifier),
            ),


            // CardGeneralPrice('search_bond_yield_card_us_bond_title'.tr(), _usNotifier),
            // ComponentCreator.divider(context),
            // CardGeneralPrice('search_bond_yield_card_indonesia_bond_title'.tr(), _idNotifier),



            SizedBox(height: paddingBottom + 80,),
          ],
        ),
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName+' onActive');
    doUpdate();
  }

  @override
  void initState() {
    super.initState();
    /*
    Future.delayed(Duration(milliseconds: 500), () {
      doUpdate(pullToRefresh: true);
      ResultMutasi dataMutasi = ResultMutasi();
      dataMutasi.month = 'September';
      for (int i = 15; i > 1; i--) {
        dataMutasi.datas.add(Mutasi('$i/09', 'Rp 9.900.000,00', '1308/IVSTA/BC29103 9.900.000', 'Philmon Tanuri', 'BCA'));
      }
      _mutasiNotifier.setValue(dataMutasi);
    });
    */

  }

  VoidCallback _activeAccountChangedListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_activeAccountChangedListener != null) {
      context.read(accountChangeNotifier).removeListener(_activeAccountChangedListener);
    } else {
      _activeAccountChangedListener = () {
        if (mounted) {
          bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          if (hasAccount) {
            _accountNotifier.value = !_accountNotifier.value;
            doUpdate(pullToRefresh: true);
          }
        }
      };
    }
    context.read(accountChangeNotifier).addListener(_activeAccountChangedListener);
    /*
    context.read(accountChangeNotifier).addListener(() {
      if (mounted) {
        _accountNotifier.value = !_accountNotifier.value;
        doUpdate(pullToRefresh: true);
      }
    });
    */
    context.read(accountsInfosNotifier).addListener(() {
      if (mounted) {
        _accountNotifier.value = !_accountNotifier.value;
      }
    });
  }

  @override
  void dispose() {
    _cashNotifier.dispose();
    _mutasiNotifier.dispose();
    _accountNotifier.dispose();
    _groupedNotifier.dispose();
    final container = ProviderContainer();
    if (_activeAccountChangedListener != null) {
      container.read(accountChangeNotifier).removeListener(_activeAccountChangedListener);
    }

    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName+' onInactive');
  }
}
