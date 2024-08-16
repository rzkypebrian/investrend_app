// ignore_for_file: unnecessary_null_comparison

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/button_outlined_rounded.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/screen_no_account.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction_historical.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction_intraday.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenTransaction extends StatefulWidget {
  const ScreenTransaction({Key? key}) : super(key: key);

  @override
  _ScreenTransactionState createState() => _ScreenTransactionState();
}

enum TabsTransaction { Intraday, Historical }

class _ScreenTransactionState extends BaseStateWithTabs<
    ScreenTransaction> //with SingleTickerProviderStateMixin
{
  String timeCreation = '-';
  List<String> tabs = [
    'transaction_tabs_intraday_title'.tr(),
    'transaction_tabs_historical_title'.tr()
  ];

  _ScreenTransactionState() : super("/transaction", null, null);

  //TabController _tabController;
  @override
  void initState() {
    super.initState();
    //_tabController = new TabController(vsync: this, length: tabs.length);
    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    final container = ProviderContainer();
    initialIndex = container.read(mainMenuChangeNotifier).subTabTransaction;
    print('ScreenTransaction.didChangeDependencies : $initialIndex');
    pTabController?.addListener(() {});
    pTabController?.index = 0;
  }

  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  Widget createAppBar3(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(InvestrendTheme.appBarTabHeight),
      child: Row(
        children: [
          new TabBar(
            isScrollable: true,
            tabs: List<Widget>.generate(
              tabs.length,
              (int index) {
                print(tabs[index]);
                return new Tab(text: tabs[index]);
              },
            ),
          ),
          Spacer(
            flex: 1,
          ),
          OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) {
                  final Color colors = states.contains(MaterialState.pressed)
                      ? Colors.transparent
                      : Colors.transparent;
                  return colors;
                }),
                visualDensity: VisualDensity.comfortable,
                padding: MaterialStateProperty.all(EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  //side: BorderSide(color: Colors.red)
                )),
                side: MaterialStateProperty.resolveWith<BorderSide>(
                    (Set<MaterialState> states) {
                  final Color colors = states.contains(MaterialState.pressed)
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.secondary;
                  return BorderSide(color: colors, width: 1.0);
                }),
              ),
              child: Text(
                'transaction_button_fast_order'.tr(),
                style: InvestrendTheme.of(context)
                    .small_w400_compact
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () {}),
          SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }

  Widget createAppBar2() {
    return PreferredSize(
      preferredSize: Size.fromHeight(InvestrendTheme.appBarTabHeight),
      child: Row(
        children: [
          new TabBar(
            isScrollable: true,
            tabs: List<Widget>.generate(
              tabs.length,
              (int index) {
                print(tabs[index]);
                return new Tab(text: tabs[index]);
              },
            ),
          ),
          Spacer(
            flex: 1,
          ),
          OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) {
                  final Color colors = states.contains(MaterialState.pressed)
                      ? Colors.transparent
                      : Colors.transparent;
                  return colors;
                }),
                visualDensity: VisualDensity.comfortable,
                padding: MaterialStateProperty.all(EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  //side: BorderSide(color: Colors.red)
                )),
                side: MaterialStateProperty.resolveWith<BorderSide>(
                    (Set<MaterialState> states) {
                  final Color colors = states.contains(MaterialState.pressed)
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.secondary;
                  return BorderSide(color: colors, width: 1.0);
                }),
              ),
              child: Text(
                'transaction_button_fast_order'.tr(),
              ),
              onPressed: () {}),
          // ComponentCreator.roundedButtonHollow(
          //     context,
          //     'transaction_button_fast_order'.tr(),
          //     Theme.of(context).backgroundColor,
          //     Theme.of(context).accentColor, () {
          //   // pressed
          //   final snackBar = SnackBar(
          //       content:
          //       Text('Action ' + 'friends_contact_button_follow'.tr()));
          //
          //   // Find the ScaffoldMessenger in the widget tree
          //   // and use it to show a SnackBar.
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // }, borderWidth: 0.5),
          SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    return TabBarView(
      controller: pTabController,
      children: List<Widget>.generate(
        tabs.length,
        (int index) {
          print(tabs[index]);
          bool hasAccount =
              context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          if (!hasAccount) {
            return ScreenNoAccount();
          }
          if (index == 0) {
            return ScreenTransactionIntraday(0, pTabController);
          } else {
            return ScreenTransactionHistorical(1, pTabController);
          }
          /*
          return Container(
            child: Center(
              child: Text(tabs[index]),
            ),
          );
          */
        },
      ),
    );
  }

  int? initialIndex = 0;

  /*
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: createAppBar(),
        body: createBody(),
      ),
    );
  }
  */

  VoidCallback? menuChangeListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialIndex = context.read(mainMenuChangeNotifier).subTabTransaction;
    print('ScreenTransaction.didChangeDependencies : $initialIndex');

    if (menuChangeListener != null) {
      context.read(mainMenuChangeNotifier).removeListener(menuChangeListener!);
    } else {
      //if (menuChangeListener == null) {
      menuChangeListener = () {
        if (!mounted ||
            context == null
            //|| DefaultTabController.of(context) == null
            ||
            pTabController == null) {
          print(
              'ScreenTransaction.menuChangeListener aborted, caused by widget mounted : ' +
                  mounted.toString());
          return;
        }
        Tabs mainTab = context.read(mainMenuChangeNotifier).mainTab;
        if (mainTab == Tabs.Transaction) {
          int? subTab = context.read(mainMenuChangeNotifier).subTabTransaction;
          /*
          int currentTab = DefaultTabController.of(context).index;
          if(subTab != currentTab){
            DefaultTabController.of(context).animateTo(subTab);
          }
          */
          int? currentTab = pTabController?.index;
          if (subTab != currentTab) {
            pTabController?.index = subTab!;
          }
        }
      };
    }
    context.read(mainMenuChangeNotifier).addListener(menuChangeListener!);
  }

  @override
  void dispose() {
    final container = ProviderContainer();
    //context.read(mainMenuChangeNotifier).removeListener(menuChangeListener);
    if (menuChangeListener != null) {
      container
          .read(mainMenuChangeNotifier)
          .removeListener(menuChangeListener!);
    }

    //_tabController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget createTabs(BuildContext context) {
    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (!hasAccount) {
      return TabBar(
        labelPadding: InvestrendTheme
            .paddingTab, //EdgeInsets.symmetric(horizontal: 12.0),
        isScrollable: true,
        controller: pTabController,
        tabs: List<Widget>.generate(
          tabs.length,
          (int index) {
            print(tabs[index]);
            return new Tab(text: tabs[index]);
          },
        ),
      );
    }
    return PreferredSize(
      preferredSize: Size.fromHeight(InvestrendTheme.appBarTabHeight),
      child: Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
        child: Row(
          children: [
            new TabBar(
              labelPadding: InvestrendTheme
                  .paddingTab, //EdgeInsets.symmetric(horizontal: 12.0),
              isScrollable: true,
              controller: pTabController,
              tabs: List<Widget>.generate(
                tabs.length,
                (int index) {
                  print(tabs[index]);
                  return new Tab(text: tabs[index]);
                },
              ),
            ),
            Spacer(
              flex: 1,
            ),
            ButtonOutlinedRounded(
              'transaction_button_order'.tr(),
              onPressed: () {
                final result = InvestrendTheme.showFinderScreen(context,
                    showStockOnly: true);
                result.then((value) {
                  if (value == null) {
                    print('result finder = null');
                  } else if (value is Stock) {
                    print('result finder = ' + value.code!);
                    //InvestrendTheme.of(context).stockNotifier.setStock(value);

                    context.read(primaryStockChangeNotifier).setStock(value);

                    //InvestrendTheme.of(context).showStockDetail(context);

                    bool hasAccount = context
                            .read(dataHolderChangeNotifier)
                            .user
                            .accountSize() >
                        0;
                    InvestrendTheme.pushScreenTrade(context, hasAccount,
                        type: OrderType.Buy);

                    /*
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ScreenTrade(
                            OrderType.Buy,
                          ),
                          settings: RouteSettings(name: '/trade')
                        ));
                    */
                  } else if (value is People) {
                    print('result finder = ' + value.name!);
                  }
                });

                // return Navigator.push(context, CupertinoPageRoute(
                //   builder: (_) => ScreenTrade(OrderType.Buy,onlyFastOrder: true,), settings: RouteSettings(name: '/trade'),));
              },
            ),
            SizedBox(
              width: InvestrendTheme.cardPaddingGeneral,
            ),
          ],
        ),
      ),
    );
  }

  @override
  int tabsLength() {
    return tabs.length;
  }

  @override
  void onActive() {}

  @override
  void onInactive() {}
}
