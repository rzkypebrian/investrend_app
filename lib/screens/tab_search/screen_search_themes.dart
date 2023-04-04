
import 'package:Investrend/component/cards/card_stock_themes.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class ScreenSearchThemes extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;
  ScreenSearchThemes(this.tabIndex, this.tabController, {Key key, this.visibilityNotifier}) : super(key: key);

  @override
  _ScreenSearchThemesState createState() => _ScreenSearchThemesState(tabIndex, tabController, visibilityNotifier: visibilityNotifier);
}

class _ScreenSearchThemesState extends BaseStateNoTabsWithParentTab<ScreenSearchThemes> {
  StockThemeNotifier _themeNotifier = StockThemeNotifier(new StockThemesData());

  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenSearchThemesState(int tabIndex, TabController tabController, {ValueNotifier<bool> visibilityNotifier})
      : super('/search_theme', tabIndex, tabController, parentTabIndex: Tabs.Search.index, visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    if(pullToRefresh || _themeNotifier.value.isEmpty()){
      //_themeNotifier.setLoading();
      setNotifierLoading(_themeNotifier);
    }

    Future<List<StockThemes>> themes = InvestrendTheme.datafeedHttp.fetchThemes();
    themes.then((value) {
      StockThemesData dataTheme = StockThemesData();
      if(value != null){
        value.forEach((theme) {
          dataTheme.datas.add(theme);
        });
        if(mounted){
          _themeNotifier.setValue(dataTheme);
        }
      }else{
        setNotifierNoData(_themeNotifier);
      }

    }).onError((error, stackTrace) {
      //_themeNotifier.setError(message: error.toString());
      setNotifierError(_themeNotifier, error);
    });
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    if(!active){
      active = true;
      //onActive();
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = List.empty(growable: true);
    childs.add(CardStockThemes('', _themeNotifier, onRetry: (){
      doUpdate(pullToRefresh: true);
    },));
    childs.add(SizedBox(height: paddingBottom + 80));

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.only(top: InvestrendTheme.cardPadding),
        shrinkWrap: false,
        children: childs,
      ),
    );
  }
  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          CardStockThemes('', _themeNotifier),
          SizedBox(
            height: paddingBottom + 80,
          ),
        ],
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
      doUpdate(pullToRefresh: true);
    });
    /*
    Future.delayed(Duration(milliseconds: 500), () {
      StockThemesData dataTheme = StockThemesData();
      dataTheme.datas.add(HomeThemes('Digital Bank', 'Disrupting the financial sector at crazy valuations',
          'https://www.investrend.co.id/mobile/assets/themes/background_1.png'));
      dataTheme.datas.add(HomeThemes('Creative Economy', 'Companies recognaized for their creative contributions to indonesia',
          'https://www.investrend.co.id/mobile/assets/themes/background_2.png'));
      dataTheme.datas.add(HomeThemes('Work from Home', 'Companies that are making social distancing possible',
          'https://www.investrend.co.id/mobile/assets/themes/background_3.png'));
      dataTheme.datas.add(HomeThemes('Focus on Diversity', 'Companies with the most diverse and inclusive composition',
          'https://www.investrend.co.id/mobile/assets/themes/background_4.png'));
      dataTheme.datas.add(HomeThemes(
          'Sports and Beyond', 'Companies in the bussiness of sports', 'https://www.investrend.co.id/mobile/assets/themes/background_5.png'));
      dataTheme.datas.add(HomeThemes('Digital Bank', 'Disrupting the financial sector at crazy valuations',
          'https://www.investrend.co.id/mobile/assets/themes/background_1.png'));
      dataTheme.datas.add(HomeThemes('Creative Economy', 'Companies recognaized for their creative contributions to indonesia',
          'https://www.investrend.co.id/mobile/assets/themes/background_2.png'));
      dataTheme.datas.add(HomeThemes('Work from Home', 'Companies that are making social distancing possible',
          'https://www.investrend.co.id/mobile/assets/themes/background_3.png'));

      _themeNotifier.setValue(dataTheme);
    });

     */
  }

  @override
  void dispose() {
    _themeNotifier.dispose();

    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
  }
}
