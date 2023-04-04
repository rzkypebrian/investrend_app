
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/group_title.dart';
import 'package:Investrend/component/rows/row_general_price.dart';
import 'package:Investrend/component/text_button_retry.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:flutter/material.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenSearchGlobal extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;
  ScreenSearchGlobal(this.tabIndex, this.tabController,  {Key key, this.visibilityNotifier}) : super( key: key);

  @override
  _ScreenSearchGlobalState createState() => _ScreenSearchGlobalState(tabIndex, tabController, visibilityNotifier: visibilityNotifier);

}

class _ScreenSearchGlobalState extends BaseStateNoTabsWithParentTab<ScreenSearchGlobal>

{
  GroupedNotifier _groupedNotifier = GroupedNotifier(GroupedData());
  // GeneralPriceNotifier _futuresNotifier = GeneralPriceNotifier(new GeneralPriceData());
  // GeneralPriceNotifier _indexAsiaNotifier = GeneralPriceNotifier(new GeneralPriceData());
  // GeneralPriceNotifier _indexEuropeNotifier = GeneralPriceNotifier(new GeneralPriceData());
  // GeneralPriceNotifier _indexAmericaNotifier = GeneralPriceNotifier(new GeneralPriceData());
  
  
  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenSearchGlobalState(int tabIndex, TabController tabController,{ValueNotifier<bool> visibilityNotifier}) : super('/search_global', tabIndex, tabController,parentTabIndex: Tabs.Search.index, visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;




  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName+'.doUpdate '+DateTime.now().toString());
    if(_groupedNotifier.value.isEmpty() || pullToRefresh) {
      setNotifierLoading(_groupedNotifier);
    }
    try {
      final groupedData = await InvestrendTheme.datafeedHttp.fetchGlobal();
      if(groupedData != null){
        if(mounted) {
          _groupedNotifier.setValue(groupedData);
        }else{
          print('ignored global data, mounted : $mounted');
        }
      }else{
        setNotifierNoData(_groupedNotifier);
      }
    } catch (error) {
      setNotifierError(_groupedNotifier, error.toString());
    }
    print(routeName+'.doUpdate finished. pullToRefresh : $pullToRefresh');

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
    /*
    List<Widget> childs = List.empty(growable: true);
    childs.add(CardGeneralPrice('search_global_card_index_future_title'.tr(), _futuresNotifier));
    childs.add(ComponentCreator.divider(context));
    childs.add(CardGeneralPrice('search_global_card_asia_title'.tr(), _indexAsiaNotifier));
    childs.add(ComponentCreator.divider(context));
    childs.add(CardGeneralPrice('search_global_card_europe_title'.tr(), _indexEuropeNotifier));
    childs.add(ComponentCreator.divider(context));
    childs.add(CardGeneralPrice('search_global_card_america_title'.tr(), _indexAmericaNotifier));
    childs.add(ComponentCreator.divider(context));
    childs.add(SizedBox(height: paddingBottom + 80,));

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Theme
          .of(context)
          .accentColor,
      onRefresh: onRefresh,
      child:ListView(
        shrinkWrap: false,
        children: childs,
      ),
    );
    */

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme
          .of(context)
          .accentColor,
      onRefresh: onRefresh,
      child:ValueListenableBuilder<GroupedData>(
          valueListenable: _groupedNotifier,
          builder: (context, value, child) {

            /*
            if (_groupedNotifier.invalid()) {
              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.width - 80.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }
            */

            /*
            Widget noWidget;
            if(_groupedNotifier.currentState.notFinished()){
              if (_groupedNotifier.currentState.isError()) {
                noWidget = TextButtonRetry(
                  onPressed: () {
                    doUpdate(pullToRefresh: true);
                  },
                );
              } else if (_groupedNotifier.currentState.isLoading()) {
                noWidget = CircularProgressIndicator();
              } else if (_groupedNotifier.currentState.isNoData()) {
                noWidget = EmptyLabel();
              }
            }
            */
            Widget noWidget = _groupedNotifier.currentState.getNoWidget(onRetry: () {
              doUpdate(pullToRefresh: true);
            });
            if(noWidget != null){
              return ListView(
                children: [
                  Padding(
                    //padding: EdgeInsets.only(top: MediaQuery.of(context).size.width - 80.0),
                    padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
                    child: Center(child: noWidget),
                  ),
                ],
              );
            }



            print('value.datasSize : '+value.datasSize().toString());
            return ListView.separated(
                shrinkWrap: false,
                padding: const EdgeInsets.only(left:InvestrendTheme.cardPaddingGeneral , right:InvestrendTheme.cardPaddingGeneral),
                itemCount: value.datasSize(),
                separatorBuilder: (context, index) {
                  StringIndex holder = value.elementAt(index);
                  print('index : $index  '+holder.toString());
                  if(holder.number < 0){
                    return Divider(thickness: 1.0, color: Colors.transparent, );
                  }else{
                    // bool last = holder.number == (value.map[holder.text].length - 1);
                    // if(last){
                    //   return Divider(thickness: 1.0, color: Colors.transparent, );
                    // }else{
                    return ComponentCreator.divider(context);
                    // }

                  }
                },
                itemBuilder: (BuildContext context, int index) {
                  StringIndex holder = value.elementAt(index);
                  print('index : $index  '+holder.toString());
                  if(holder.number < 0){
                    String group = holder.text;
                    print('group : $group');
                    return Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: GroupTitle(group, color: InvestrendTheme.of(context).greyLighterTextColor),
                    );
                  }else{
                    GeneralDetailPrice gp = value.map[holder.text].elementAt(holder.number);
                    return RowGeneralPrice(gp.code, gp.price, gp.change, gp.percentChange, InvestrendTheme.changeTextColor(gp.change), name: gp.name, firstRow: true, onTap: (){},);
                  }
                  //return EmptyLabel(text: 'Unknown',);
                });
          }),
    );
  }
  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          CardGeneralPrice('search_global_card_index_future_title'.tr(), _futuresNotifier),
          ComponentCreator.divider(context),
          CardGeneralPrice('search_global_card_asia_title'.tr(), _indexAsiaNotifier),
          ComponentCreator.divider(context),
          CardGeneralPrice('search_global_card_europe_title'.tr(), _indexEuropeNotifier),
          ComponentCreator.divider(context),
          CardGeneralPrice('search_global_card_america_title'.tr(), _indexAmericaNotifier),
          ComponentCreator.divider(context),


          SizedBox(height: paddingBottom + 80,),
        ],
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
    Future.delayed(Duration(milliseconds: 500),(){

      GeneralPriceData dataFutures = GeneralPriceData();
      dataFutures.datas.add(GeneralPrice('DOW FUT', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Dow Jones Index Future (New York)'));
      dataFutures.datas.add(GeneralPrice('FTSE FUT', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'FTSE 100 Index Future (London)'));
      dataFutures.datas.add(GeneralPrice('VIX FUT', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'CBOE Volatility Index Future (New York)'));
      dataFutures.datas.add(GeneralPrice('DX', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Dollar Index (New York)'));
      dataFutures.datas.add(GeneralPrice('DX', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: ''));
      _futuresNotifier.setValue(dataFutures);


      GeneralPriceData dataAsia = GeneralPriceData();
      dataAsia.datas.add(GeneralPrice('N225', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Nikkei 225 Index (Tokyo)'));
      dataAsia.datas.add(GeneralPrice('SSEC', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Shanghai Composite Index (Shanghai)'));
      dataAsia.datas.add(GeneralPrice('HSI', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Hang Seng Index (Hong Kong)'));
      dataAsia.datas.add(GeneralPrice('ASX 200', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Straits Times Index (Australia)'));
      dataAsia.datas.add(GeneralPrice('KOSPI', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Straits Times Index (Korea)'));
      dataAsia.datas.add(GeneralPrice('STI', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Straits Times Index (Singapore)'));
      dataAsia.datas.add(GeneralPrice('IDX', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Indonesia Composite Index (Jakarta)'));
      dataAsia.datas.add(GeneralPrice('LQ45', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Indonesia LQ45 Index (Jakarta)'));
      _indexAsiaNotifier.setValue(dataAsia);

      GeneralPriceData dataEurope = GeneralPriceData();
      dataEurope.datas.add(GeneralPrice('FTSE', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'FTSE 100 Index (London)'));
      dataEurope.datas.add(GeneralPrice('DAX', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'FTSE 100 Index (Frankfurt)'));
      dataEurope.datas.add(GeneralPrice('CAC', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'FTSE 100 Index (France)'));
      dataEurope.datas.add(GeneralPrice('STOXX600', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Xetra Dax (Europe)'));
      _indexEuropeNotifier.setValue(dataEurope);

      GeneralPriceData dataAmerica = GeneralPriceData();
      dataAmerica.datas.add(GeneralPrice('DJI', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Dow Jones Index (New York)'));
      dataAmerica.datas.add(GeneralPrice('GSPC', '30.678,00', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'S&P 500 Index (New York)'));
      dataAmerica.datas.add(GeneralPrice('IXIC', '91.151', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Nasdaq (New York)'));
      _indexAmericaNotifier.setValue(dataAmerica);

    });
*/

  }


  @override
  void dispose() {
    // _futuresNotifier.dispose();
    // _indexAmericaNotifier.dispose();
    // _indexEuropeNotifier.dispose();
    // _indexAsiaNotifier.dispose();
    _groupedNotifier.dispose();
    super.dispose();
  }



  @override
  void onInactive() {
    //print(routeName+' onInactive');
  }
}
