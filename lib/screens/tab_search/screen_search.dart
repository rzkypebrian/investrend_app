import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/tab_search/screen_search_bond_yield.dart';
import 'package:Investrend/screens/tab_search/screen_search_commodities.dart';
import 'package:Investrend/screens/tab_search/screen_search_cryptocurrency.dart';
import 'package:Investrend/screens/tab_search/screen_search_currency.dart';
import 'package:Investrend/screens/tab_search/screen_search_global.dart';
import 'package:Investrend/screens/tab_search/screen_search_market.dart';
import 'package:Investrend/screens/tab_search/screen_search_movers.dart';
import 'package:Investrend/screens/tab_search/screen_search_themes.dart';
import 'package:Investrend/screens/tab_search/screen_search_watchlist.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ScreenSearch extends StatefulWidget {
  final BaseValueNotifier<bool> visibilityNotifier;
  const ScreenSearch({Key key, this.visibilityNotifier}) : super(key: key);

  @override
  _ScreenSearchState createState() =>
      _ScreenSearchState(visibilityNotifier: visibilityNotifier);
}

class _ScreenSearchState extends BaseStateWithTabs<ScreenSearch>
//with SingleTickerProviderStateMixin
{
  String timeCreation = '-';

  _ScreenSearchState({BaseValueNotifier<bool> visibilityNotifier})
      : super('/search',
            screenAware: false, visibilityNotifier: visibilityNotifier);
  //TabController _tabController;

  //Key testKey = UniqueKey();
  @override
  void initState() {
    super.initState();
    print(routeName + '.initState ');
    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    //_tabController = new TabController(vsync: this, length: tabs.length);
    pTabController.addListener(_tabListener);

    if (visibilityNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        onActive();
      });
    }
  }

  void _tabListener() {
    print(routeName +
        ' pTabController onChange : ' +
        pTabController.index.toString());
    runPostFrame(() {
      if (mounted && context != null) {
        FocusScope.of(context).requestFocus(new FocusNode());
        onActive();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print(routeName + '.didChangeDependencies ');

    // pTabController.addListener(() {
    //   print(routeName+' pTabController onChange : '+pTabController.index.toString());
    //   if (mounted && context !=null) {
    //
    //     FocusScope.of(context).requestFocus(new FocusNode());
    //     //onActive();
    //   }
    // });
  }

  @override
  void dispose() {
    //_tabController.dispose();
    print(routeName + '.dispose ');
    for (int i = 0; i < _visibilityNotifiers.length; i++) {
      _visibilityNotifiers.elementAt(i).dispose();
    }
    pTabController.removeListener(_tabListener);

    super.dispose();
  }

  List<String> tabs = [
    'search_tabs_market_title'.tr(),
    'search_tabs_global_title'.tr(),
    'search_tabs_watchlist_title'.tr(),
    'search_tabs_movers_title'.tr(),
    'search_tabs_themes_title'.tr(),
    'search_tabs_currency_title'.tr(),
    'search_tabs_cryptocurrency_title'.tr(),
    'search_tabs_commodities_title'.tr(),
    'search_tabs_bond_title'.tr(),
  ];

  List<ValueNotifier<bool>> _visibilityNotifiers = [
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
    ValueNotifier<bool>(false),
  ];

  Widget createAppBar(BuildContext context) {
    return null;
  }

  /*
  Widget createAppBar(BuildContext context){

    return new TabBar(
      isScrollable: true,
      controller: _tabController,
      tabs: List<Widget>.generate(
        tabs.length,
            (int index) {
          print(tabs[index]);
          return new Tab(text: tabs[index]);
        },
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
          if (index == 0) {
            return ScreenSearchMarket(
              0,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 1) {
            return ScreenSearchGlobal(
              1,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 2) {
            return ScreenSearchWatchlist(
              2,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 3) {
            return ScreenSearchMovers(
              3,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 4) {
            return ScreenSearchThemes(
              4,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 5) {
            return ScreenSearchCurrency(
              5,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 6) {
            return ScreenSearchCryptocurrency(
              6,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 7) {
            return ScreenSearchCommodities(
              7,
              pTabController,
              visibilityNotifier: _visibilityNotifiers.elementAt(index),
            );
          } else if (index == 8) {
            return ScreenSearchBondYield(
              8,
              pTabController,
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

  Widget getChip(BuildContext context, String text, bool selected,
      ValueChanged<bool> onSelected) {
    return ChoiceChip(
      label: Text(
        text,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
            fontSize: 12.0,
            color: selected
                ? InvestrendTheme.of(context).textWhite /*Colors.white*/
                : InvestrendTheme.of(context).blackAndWhiteText),
      ),
      //padding: EdgeInsets.zero,
      visualDensity: VisualDensity.comfortable,
      selected: selected,
      backgroundColor: InvestrendTheme.of(context).tileBackground,
      selectedColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        //side: BorderSide(color: Theme.of(context).accentColor),
      ),
      onSelected: onSelected,
    );
  }

  @override
  Widget createTabs(BuildContext context) {
    return TabBar(
      controller: pTabController,
      labelPadding: InvestrendTheme.paddingTab,
      //indicatorSize: TabBarIndicatorSize.label,
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
  void onActive() {
    // TODO: implement onActive
    print(routeName +
        '  onActive pTabController.index : ' +
        pTabController.index.toString() +
        '  value : ' +
        _visibilityNotifiers.elementAt(pTabController.index).value.toString());
    for (int i = 0; i < _visibilityNotifiers.length; i++) {
      ValueNotifier childNotifier = _visibilityNotifiers.elementAt(i);
      if (childNotifier != null) {
        if (pTabController.index == i) {
          childNotifier.value = true;
        } else {
          childNotifier.value = false;
        }
        print('childNotifier[$i] = ' + childNotifier.value.toString());
      } else {
        print('childNotifier[$i] = NULL');
      }
    }
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
    print(routeName +
        '  onInactive pTabController.index : ' +
        pTabController.index.toString() +
        '  value : ' +
        _visibilityNotifiers.elementAt(pTabController.index).value.toString());
    for (int i = 0; i < _visibilityNotifiers.length; i++) {
      ValueNotifier childNotifier = _visibilityNotifiers.elementAt(i);
      if (childNotifier != null) {
        childNotifier.value = false;
      }
    }
  }
}
