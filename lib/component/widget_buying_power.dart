import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/screen_fund_out.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/screen_topup.dart';
import 'package:Investrend/screens/screen_topup_how_to.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WidgetBuyingPower extends StatefulWidget {
  final ValueNotifier<bool>? hideNotifier;
  const WidgetBuyingPower({this.hideNotifier, Key? key}) : super(key: key);

  @override
  _WidgetBuyingPowerState createState() =>
      _WidgetBuyingPowerState(hideNotifier: hideNotifier!);
}

class _WidgetBuyingPowerState extends State<WidgetBuyingPower> {
  final ValueNotifier<bool> _accountNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool>? hideNotifier;

  _WidgetBuyingPowerState({this.hideNotifier});

  @override
  void dispose() {
    _accountNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (hideNotifier != null) {
      hideNotifier?.addListener(() {
        _accountNotifier.value = !_accountNotifier.value;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read(accountChangeNotifier).addListener(() {
      if (mounted) {
        _accountNotifier.value = !_accountNotifier.value;
      }
    });
    context.read(accountsInfosNotifier).addListener(() {
      if (mounted) {
        _accountNotifier.value = !_accountNotifier.value;
      }
    });

    // context.read(accountsInfosNotifier).addListener(() {
    //   if(mounted){
    //     _accountNotifier.value = !_accountNotifier.value;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0.0,
      // minWidth: tileWidth,
      //height: tileHeight,
      color: Theme.of(context).colorScheme.secondary,
      splashColor: InvestrendTheme.of(context).tileSplashColor,
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
        side: BorderSide(
          color: InvestrendTheme.of(context).tileBackground!,
          width: 0.0,
        ),
      ),
      onPressed: () {
        InvestrendTheme.backToScreenMainAndShowTabScreen(
            context, Tabs.Portfolio, TabsPorftolio.Cash.index);
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'buying_power_label'.tr(),
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      ?.copyWith(
                          color: InvestrendTheme.of(context)
                              .textWhite /*Colors.white*/),
                ),
                SizedBox(
                  height: 10.0,
                ),
                ValueListenableBuilder(
                  valueListenable: _accountNotifier,
                  builder: (context, data, child) {
                    double buyingPower = 0.0;
                    Account? activeAccount = context
                        .read(dataHolderChangeNotifier)
                        .user
                        .getAccount(context.read(accountChangeNotifier).index);
                    if (activeAccount != null) {
                      AccountStockPosition? accountInfo = context
                          .read(accountsInfosNotifier)
                          .getInfo(activeAccount.accountcode);
                      if (accountInfo != null) {
                        buyingPower = accountInfo.outstandingLimit;
                        //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, 0/*cashPosition.rdnBalance*/);
                      }
                    }

                    String buyingPowerText = InvestrendTheme.formatMoneyDouble(
                        buyingPower,
                        prefixRp: true);
                    bool hidePortfolio =
                        hideNotifier != null ? hideNotifier!.value : false;
                    if (hidePortfolio) {
                      buyingPowerText = '* * * * * * *';
                    }
                    return AutoSizeText(
                      buyingPowerText,
                      minFontSize: 8.0,
                      maxLines: 1,
                      style: InvestrendTheme.of(context)
                          .regular_w600_compact
                          ?.copyWith(
                              color: InvestrendTheme.of(context)
                                  .textWhite /*Colors.white*/,
                              fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          getButtonIconVertical(
              context,
              'images/icons/plus_circle.png',
              'buying_power_top_up_label'.tr(),
              InvestrendTheme.of(context).textWhite /*Colors.white*/, () {
            // Navigator.push(
            //     context,
            //     CupertinoPageRoute(
            //       builder: (_) => ScreenTopUp(),
            //       settings: RouteSettings(name: '/topup'),
            //     ));

            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenTopUpHowTo(),
                  settings: RouteSettings(name: '/topup_how_to'),
                ));
          }),
          SizedBox(
            width: 10.0,
          ),
          getButtonIconVertical(
              context,
              'images/icons/arrow_circle.png',
              'buying_power_transfer_label'.tr(),
              InvestrendTheme.of(context).textWhite /*Colors.white*/, () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenFundOut(),
                  settings: RouteSettings(name: '/fund_out'),
                ));
          }),
        ],
      ),
    );
  }

  Widget buildOld(BuildContext context) {
    return Container(
      width: double.maxFinite,
      //height: 50,
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),

      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'buying_power_label'.tr(),
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      ?.copyWith(color: Colors.white),
                ),
                SizedBox(
                  height: 10.0,
                ),
                ValueListenableBuilder(
                  valueListenable: _accountNotifier,
                  builder: (context, data, child) {
                    double buyingPower = 0.0;
                    Account? activeAccount = context
                        .read(dataHolderChangeNotifier)
                        .user
                        .getAccount(context.read(accountChangeNotifier).index);
                    if (activeAccount != null) {
                      AccountStockPosition? accountInfo = context
                          .read(accountsInfosNotifier)
                          .getInfo(activeAccount.accountcode);
                      if (accountInfo != null) {
                        buyingPower = accountInfo.outstandingLimit;
                        //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, 0/*cashPosition.rdnBalance*/);
                      }
                    }

                    //   buyingPower = context.read(buyRdnBuyingPowerChangeNotifier).buyingPower;
                    // }
                    return Text(
                      InvestrendTheme.formatMoneyDouble(buyingPower,
                          prefixRp: true),
                      style: InvestrendTheme.of(context)
                          .regular_w600_compact
                          ?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                /*
                Consumer(builder: (context, watch, child) {
                  //final rdnBalance = watch(rdnBalanceStateProvider);
                  final value = watch(buyRdnBuyingPowerChangeNotifier);
                  return Text(
                    InvestrendTheme.formatMoneyDouble(value.buyingPower,prefixRp: true),
                    style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  );

                }),
                */
                /*
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    InvestrendTheme.formatMoney(buyingPower,prefixRp: true),
                    style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                */
              ],
            ),
          ),
          // Spacer(
          //   flex: 1,
          // ),
          SizedBox(
            width: 10.0,
          ),
          getButtonIconVertical(context, 'images/icons/plus_circle.png',
              'buying_power_top_up_label'.tr(), Colors.white, () {
            //final snackBar = SnackBar(content: Text('Action Top-Up'));
            //ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenTopUp(),
                  settings: RouteSettings(name: '/topup'),
                ));
          }),
          SizedBox(
            width: 10.0,
          ),
          getButtonIconVertical(context, 'images/icons/arrow_circle.png',
              'buying_power_transfer_label'.tr(), Colors.white, () {
            // final snackBar = SnackBar(content: Text('Action Transfer'));
            // ScaffoldMessenger.of(context).showSnackBar(snackBar);

            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenFundOut(),
                  settings: RouteSettings(name: '/fund_out'),
                ));
          }),
        ],
      ),
    );
  }

  Widget getButtonIconVertical(BuildContext context, String image, String text,
      Color? textColor, VoidCallback onPressed) {
    return SizedBox(
      width: 55,
      height: 55,
      child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
          child: InkWell(
            child: MaterialButton(
              padding: EdgeInsets.all(2.0),
              elevation: 0,
              highlightElevation: 0,
              focusElevation: 0,

              //visualDensity: VisualDensity.compact,
              //color: Theme.of(context).accentColor,
              //color: color,
              //textColor: Theme.of(context).primaryColor,
              textColor: textColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    image,
                    width: 20,
                    height: 20,
                  ),
                  // SizedBox(
                  //   height: 5.0,
                  // ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      style: InvestrendTheme.of(context)
                          .more_support_w400_compact
                          ?.copyWith(color: textColor),
                      //style: TextStyle(fontSize: 13.0, color: textColor, fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              onPressed: onPressed,
            ),
          )),
    );
  }
}

/*
class WidgetBuyingPower extends StatelessWidget {
  //final int buyingPower;
  const WidgetBuyingPower(/*this.buyingPower, */{Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      //height: 50,
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),


      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'buying_power_label'.tr(),
                  style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: Colors.white),
                ),
                SizedBox(
                  height: 10.0,
                ),

                Consumer(builder: (context, watch, child) {
                  //final rdnBalance = watch(rdnBalanceStateProvider);
                  final value = watch(buyRdnBuyingPowerChangeNotifier);
                  return Text(
                    InvestrendTheme.formatMoneyDouble(value.buyingPower,prefixRp: true),
                    style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  );

                }),
                /*
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    InvestrendTheme.formatMoney(buyingPower,prefixRp: true),
                    style: InvestrendTheme.of(context).regular_w700_compact.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                */
              ],
            ),
          ),
          // Spacer(
          //   flex: 1,
          // ),
          SizedBox(
            width: 10.0,
          ),
          getButtonIconVertical(context, 'images/icons/plus_circle.png', 'buying_power_top_up_label'.tr(), Colors.white, () {
            //final snackBar = SnackBar(content: Text('Action Top-Up'));
            //ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.push(context, CupertinoPageRoute(
              builder: (_) => ScreenTopUp(), settings: RouteSettings(name: '/topup'),));
          }),
          SizedBox(
            width: 10.0,
          ),
          getButtonIconVertical(context, 'images/icons/arrow_circle.png', 'buying_power_transfer_label'.tr(), Colors.white, () {
            final snackBar = SnackBar(content: Text('Action Transfer'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }),
        ],
      ),
    );
  }
  Widget getButtonIconVertical(BuildContext context, String image, String text, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: 55,
      height: 55,
      child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
          child: InkWell(
            child: MaterialButton(
              padding: EdgeInsets.all(2.0),
              elevation: 0,
              highlightElevation: 0,
              focusElevation: 0,

              //visualDensity: VisualDensity.compact,
              //color: Theme.of(context).accentColor,
              //color: color,
              //textColor: Theme.of(context).primaryColor,
              textColor: textColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    image,
                    width: 20,
                    height: 20,
                  ),
                  // SizedBox(
                  //   height: 5.0,
                  // ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: textColor),
                      //style: TextStyle(fontSize: 13.0, color: textColor, fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              onPressed: onPressed,
            ),
          )),
    );
  }
}
*/
