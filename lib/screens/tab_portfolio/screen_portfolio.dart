import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/screen_no_account.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_cash.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_realized.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_stocks.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_summary.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenPortfolio extends StatefulWidget {
  const ScreenPortfolio({Key? key}) : super(key: key);

  @override
  _ScreenPortfolioState createState() => _ScreenPortfolioState();
}

enum TabsPorftolio { Stocks, Cash, Realized, Summary /*, Return*/ }

class _ScreenPortfolioState extends BaseStateWithTabs<ScreenPortfolio>
/* keep alive tabs
    with AutomaticKeepAliveClientMixin<ScreenPortfolio>
    */
{
  String timeCreation = '-';
  List<String> tabs = [
    'portfolio_tabs_stocks_title'.tr(),
    'portfolio_tabs_cash_title'.tr(),
    'portfolio_tabs_Realized_title'.tr(),
    'portfolio_tabs_summary_title'.tr()
    //'portfolio_tabs_return_title'.tr(),
  ];

  _ScreenPortfolioState() : super('/portfolio', null, null);

  /* keep alive tabs
  @override
  bool get wantKeepAlive => true;
  */

  @override
  void initState() {
    super.initState();

    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());

    // final container = ProviderContainer();
    // initialIndex = container.read(mainMenuChangeNotifier).subTabPortfolio;
    // print(routeName+'.initState : $initialIndex');
    pTabController?.addListener(() {
      if (mounted) {
        context
            .read(mainMenuChangeNotifier)
            .setActive(Tabs.Portfolio, pTabController?.index, silently: true);
      }
    });
    pTabController?.index = 0;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initialIndex = context.read(mainMenuChangeNotifier).subTabPortfolio;
      print(routeName + '.initState PostFrameCallback : $initialIndex');
      if (pTabController?.index != initialIndex) {
        pTabController?.index = initialIndex!;
      }
    });
  }

  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
    /*
    return PreferredSize(
      preferredSize:
      Size.fromHeight(InvestrendTheme.appBarTabHeight),
      child: new TabBar(
        isScrollable: true,
        tabs: List<Widget>.generate(
          tabs.length,
              (int index) {
            print(tabs[index]);
            return new Tab(text: tabs[index]);
          },
        ),
      ),
    );
     */
  }

  /*
  Widget createAppBar2(){
    return PreferredSize(
      preferredSize: Size.fromHeight(InvestrendTheme.of(context)
          .appBarTabHeight), // here the desired height
      child: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          child: new TabBar(
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
    );
  }
   */
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

          if (index == TabsPorftolio.Stocks.index) {
            return ScreenPortfolioStocks(index, pTabController);
          }
          if (index == TabsPorftolio.Cash.index) {
            return ScreenPortfolioCash(index, pTabController);
          }
          /*
          if(index == TabsPorftolio.Return.index){
            return ScreenPortfolioReturn(index, pTabController);
          }
          */
          if (index == TabsPorftolio.Realized.index) {
            return ScreenPortfolioRealized(index, pTabController);
          }
          if (index == TabsPorftolio.Summary.index) {
            return ScreenPortfolioSummary(index, pTabController);
          }

          // if(index == 2){
          //   return ScreenPortfolioRealized(2, pTabController);
          // }
          // if(index == 3){
          //   return ScreenPortfolioSummary(3, pTabController);
          // }

          return Container(
            child: Center(
              child: Text(tabs[index]),
            ),
          );
        },
      ),
    );
  }
  /*
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: createAppBar(),
        body: createBody(),
      ),
    );

  }
  */

  @override
  PreferredSizeWidget createTabs(BuildContext context) {
    return TabBar(
      controller: pTabController,
      //indicatorSize: TabBarIndicatorSize.label,
      labelPadding:
          InvestrendTheme.paddingTab, //EdgeInsets.symmetric(horizontal: 12.0),
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

  @override
  int tabsLength() {
    return tabs.length;
  }

  @override
  void onActive() {}

  @override
  void onInactive() {}

  @override
  void dispose() {
    final container = ProviderContainer();
    if (menuChangeListener != null) {
      container
          .read(mainMenuChangeNotifier)
          .removeListener(menuChangeListener!);
    }
    super.dispose();
  }

  int? initialIndex = 0;
  VoidCallback? menuChangeListener;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialIndex = context.read(mainMenuChangeNotifier).subTabPortfolio;
    print(routeName +
        '.didChangeDependencies  initialIndex : $initialIndex  pTabController.index : ' +
        pTabController!.index.toString());

    if (menuChangeListener != null) {
      context.read(mainMenuChangeNotifier).removeListener(menuChangeListener!);
    } else {
      //if (menuChangeListener == null) {
      menuChangeListener = () {
        if (!mounted ||
            // ignore: unnecessary_null_comparison
            context == null
            //|| DefaultTabController.of(context) == null
            ||
            pTabController == null) {
          print(routeName +
              '.menuChangeListener aborted, caused by widget mounted : ' +
              mounted.toString());
          return;
        }

        Tabs mainTab = context.read(mainMenuChangeNotifier).mainTab;
        if (mainTab == Tabs.Portfolio) {
          int? subTab = context.read(mainMenuChangeNotifier).subTabPortfolio;
          int? currentTab = pTabController?.index;
          print(routeName +
              '.menuChangeListener Tabs.Portfolio  show subTab : $subTab  currentTab : $currentTab');
          if (subTab != currentTab) {
            pTabController?.index = subTab!;
          }
        }
      };
    }
    context.read(mainMenuChangeNotifier).addListener(menuChangeListener!);
  }
}
