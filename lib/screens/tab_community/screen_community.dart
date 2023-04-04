import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_coming_soon.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_community/screen_community_competitions.dart';
import 'package:Investrend/screens/tab_community/screen_community_feed.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenCommunity extends StatefulWidget {
  const ScreenCommunity({Key key}) : super(key: key);
  @override
  _ScreenCommunityState createState() => _ScreenCommunityState();
}
enum TabsCommunity { Feed, Competitions }
class _ScreenCommunityState extends BaseStateWithTabs<ScreenCommunity> {
  String timeCreation = '-';
  int initialIndex = 0;
  VoidCallback menuChangeListener;
  List<String> tabs = ['comunity_tab_feed'.tr(), 'comunity_tab_competitions'.tr()];

  bool comingsoon = true;

  _ScreenCommunityState() : super('/community');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
  }


  @override
  Widget createAppBar(BuildContext context) {
    // TODO: implement createAppBar
    return null;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    initialIndex = context.read(mainMenuChangeNotifier).subTabTransaction;
    print('ScreenTransaction.didChangeDependencies : $initialIndex');
    if(menuChangeListener != null){
      context.read(mainMenuChangeNotifier).removeListener(menuChangeListener);
    }else {
    //if(menuChangeListener == null){
      menuChangeListener = (){
        if(!mounted
            || context == null
            || pTabController == null
        ){
          print('ScreenTransaction.menuChangeListener aborted, caused by widget mounted : '+mounted.toString());
          return;
        }
        Tabs mainTab = context.read(mainMenuChangeNotifier).mainTab;
        if(mainTab == Tabs.Community){
          int subTab = context.read(mainMenuChangeNotifier).subTabCommunity;
          int currentTab = pTabController.index;
          if(subTab != currentTab){
            pTabController.index = subTab;
          }
        }
      };
    }
    context.read(mainMenuChangeNotifier).addListener(menuChangeListener);
  }

  @override
  void dispose() {
    final container = ProviderContainer();
    if(menuChangeListener != null){
      container.read(mainMenuChangeNotifier).removeListener(menuChangeListener);
    }


    super.dispose();
  }
  @override
  Widget createBody(BuildContext context,double paddingBottom) {

    if(comingsoon){
      return ScreenComingSoon();
    }

    return TabBarView(
      controller: pTabController,
      children: List<Widget>.generate(
        tabs.length,
            (int index) {
          print(tabs[index]);
          if(index == 0){
            return ScreenCommunityFeed(0, pTabController);
          }
          if(index == 1){
            return ScreenCommunityCompetitions(1, pTabController);
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

  @override
  Widget createTabs(BuildContext context) {
    if(comingsoon){
      return null;
    }
    return new TabBar(
      labelPadding: InvestrendTheme.paddingTab, //EdgeInsets.symmetric(horizontal: 12.0),
      controller: pTabController,
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
    return comingsoon ? 0 : tabs.length;
  }

  @override
  void onActive() {
    // TODO: implement onActive
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  // Widget createComingSoonPage(BuildContext context){
  //   return Container(
  //     width: double.maxFinite,
  //     height: double.maxFinite,
  //     //color: Colors.indigoAccent,
  //     padding: EdgeInsets.all(40.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         FractionallySizedBox(
  //             widthFactor: 0.7,
  //             child: Image.asset('images/shoutout.png', )),
  //         Text('coming_soon_label'.tr(), style: InvestrendTheme.of(context).headline3,textAlign: TextAlign.center,),
  //         SizedBox(height: 8.0,),
  //         Text('coming_soon_info_label'.tr(), style: InvestrendTheme.of(context).small_w400_greyDarker,textAlign: TextAlign.center,)
  //       ],
  //     ),
  //   );
  // }
}



