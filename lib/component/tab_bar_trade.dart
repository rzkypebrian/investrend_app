import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';


class TabBarTrade extends StatefulWidget implements PreferredSizeWidget {
  final double indicatorWeight;
  List<Widget> tabs;
  TabController tabController;

  TabBarTrade(this.tabs, this.tabController, {Key key, this.indicatorWeight = 2.0,}) : super(key: key);

  @override
  _TabBarTradeState createState() => _TabBarTradeState();
  @override
  Size get preferredSize {

    // for (final Widget item in tabs) {
    //   if (item is Tab) {
    //     final Tab tab = item;
    //     if ((tab.text != null || tab.child != null) && tab.icon != null)
    //       return Size.fromHeight(_kTextAndIconTabHeight + indicatorWeight);
    //   }
    // }
    //return Size.fromHeight(_kTabHeight + indicatorWeight);
    return Size.fromHeight(InvestrendTheme.appBarTabHeight);

  }
}

class _TabBarTradeState extends State<TabBarTrade> with SingleTickerProviderStateMixin {
  ValueNotifier _indexNotifier;


  @override
  void initState() {
    super.initState();

    _indexNotifier = ValueNotifier<int>(0);

    widget.tabController.addListener(() {
      print('changed tab :'+widget.tabController.index.toString());
      _indexNotifier.value = widget.tabController.index;
      // setState(() {
      //
      // });
    });
  }

  @override
  void dispose() {
    //_tabController.dispose();
    _indexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _indexNotifier,
        builder: (context, value, child) {
          return createTabs(context);
        });

    //return createTabs(context);
  }

  Widget createTabs(BuildContext context) {


    bool isBuy = widget.tabController.index == OrderType.Buy.index;
    Color color = isBuy ? Theme.of(context).accentColor : InvestrendTheme.sellColor;
    Color borderColor = isBuy ? Theme.of(context).accentColor : InvestrendTheme.sellColor;
    print('isBuy : $isBuy');
    print('tabController : '+(widget.tabController == null ? 'NULL' : 'ADA'));
    print('tabs : '+(widget.tabs == null ? 'NULL' : 'ADA'));

    // return ValueListenableBuilder(
    //   valueListenable: _indexNotifier,
    //   builder: (context, value, child) {
    //     return TabBar(
    //       controller: widget.tabController,
    //       labelColor: color,
    //       indicator: BoxDecoration(
    //         borderRadius: BorderRadius.circular(8.0),
    //         border: Border.all(
    //           color: borderColor,
    //           width: 2.0,
    //         ),
    //       ),
    //       isScrollable: true,
    //       tabs: widget.tabs,
    //     );
    //   },
    // );
    double padding = 0.0;

    return TabBar(
      controller: widget.tabController,
      labelColor: color,
      labelStyle: Theme.of(context).tabBarTheme.labelStyle.copyWith(height: null,),
      unselectedLabelStyle: Theme.of(context).tabBarTheme.labelStyle.copyWith(height: null,),
      indicatorPadding: EdgeInsets.only( top: padding, bottom: padding,),
      labelPadding: EdgeInsets.only( top: padding, bottom: 4.0, left: 15.0, right: 15.0),

      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      isScrollable: true,
        tabs: widget.tabs,
    );
  }
}
