import 'package:Investrend/component/cards/card_competitions.dart';
import 'package:Investrend/component/cards/card_profiles.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenCommunityCompetitions extends StatefulWidget {

  final TabController tabController;
  final int tabIndex;
  ScreenCommunityCompetitions(this.tabIndex, this.tabController,  {Key key}) : super( key: key);

  @override
  _ScreenCommunityCompetitionsState createState() => _ScreenCommunityCompetitionsState(tabIndex, tabController);

}

class _ScreenCommunityCompetitionsState extends BaseStateNoTabsWithParentTab<ScreenCommunityCompetitions> {

  _ScreenCommunityCompetitionsState(int tabIndex, TabController tabController) : super('/community_competitions', tabIndex, tabController,parentTabIndex: Tabs.Community.index);


  @override
  Widget createAppBar(BuildContext context) {

    return null;
  }
  List<HomeProfiles> listProfiles = <HomeProfiles>[
    HomeProfiles('Belvin Tannadi', 'Owner @belvinvvip, komunitas saham retail terbesar di indonesia',
        'https://www.investrend.co.id/mobile/assets/profiles/profile_1.png'),
    HomeProfiles('Lo Kheng Hong', 'Lo Kheng Hong sebagai investor saham disebut sebut sebagai Warren Buffet-nya Indonesia.',
        'https://www.investrend.co.id/mobile/assets/profiles/profile_2.png'),
  ];

  List<HomeCompetition> listCompetition = <HomeCompetition>[
    HomeCompetition('Kompetisi Keren', 4, 12, 'https://www.investrend.co.id/mobile/assets/competition/background_1.png', <String>[
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
      'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiJinli8IBVIpd5Un3l2uUuMb9iIXihrGobg&usqp=CAU',
    ]),
    HomeCompetition('Best of the Best', 3, 15, 'https://www.investrend.co.id/mobile/assets/competition/background_2.png', <String>[
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU',
      'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU',
    ]),
  ];



  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    if(!active){
      active = true;
      onActive();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      CardCompetitions('Kompetisi Kamu', listCompetition),
      CardCompetitions('Open for Registration', listCompetition),
      CardCompetitions('Ongoing', listCompetition),
      CardProfiles('Featured Profiles', listProfiles),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ListView(
        //padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
        shrinkWrap: false,
        children: childs,
      ),
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    // TODO: implement createBody
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Text('Community'),
            CardCompetitions('Kompetisi Kamu', listCompetition),
            CardCompetitions('Open for Registration', listCompetition),
            CardCompetitions('Ongoing', listCompetition),
            CardProfiles('Featured Profiles', listProfiles),

            /*
            Expanded(
              flex: 1,
              child: ListView.builder(
                  shrinkWrap: false,
                  padding: const EdgeInsets.all(8),
                  itemCount: 20,
                  itemBuilder: (BuildContext context, int index) {
                    return tileHistorical(context);
                    // return Container(
                    //   height: 50,
                    //   color: Colors.amber[colorCodes[index]],
                    //   child: Center(child: Text('Entry ${entries[index]}')),
                    // );
                  }),
            ),
            */
          ],
        ),
      ),
    );
  }
  */
  @override
  void onActive() {
    // TODO: implement onActive
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}
