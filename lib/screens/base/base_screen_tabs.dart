import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/tab_bar_trade.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
/*
class ScreenTrade extends StatefulWidget {
  const ScreenTrade({Key key}) : super(key: key);

  @override
  _ScreenTradeState createState() => _ScreenTradeState();
}


class _ScreenTradeState extends BaseStateWithTabs<ScreenTrade> {
// class _ScreenTradeState extends State<ScreenTrade> {
  String timeCreation = '-';
  List<String> tabs = [
    'Tab 1',
    'Tab 2',
  ];
  @override
  void initState() {
    super.initState();
    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
  
  }
  int tabsLength() {
    return tabs.length;
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  Widget createAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      elevation: 2.0,
      shadowColor: Theme.of(context).shadowColor,
      centerTitle: true,
      //automaticallyImplyLeading: false,
      //toolbarHeight: 0.0,
      title: AppBarTitleText('TRADE'),
      actions: [

      ],
    );
  }

  Widget createTabs(BuildContext context){
    return TabBar(
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

  Widget createBody(BuildContext context) {
    return TabBarView(
      children: List<Widget>.generate(
        tabs.length,
        (int index) {
          print(tabs[index]);
          return Container(
            child: Center(
              child: Text(tabs[index]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: createTabs(context),
          body: createBody(context),
        ),
      ),
    );
  }

}
*/