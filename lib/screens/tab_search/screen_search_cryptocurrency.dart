import 'package:Investrend/component/cards/card_earning_pershare.dart';
import 'package:Investrend/component/cards/card_general_price.dart';
import 'package:Investrend/component/cards/card_label_value.dart';
import 'package:Investrend/component/cards/card_local_foreign.dart';
import 'package:Investrend/component/cards/card_performance.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/group_title.dart';
import 'package:Investrend/component/rows/row_general_price.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenSearchCryptocurrency extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;
  ScreenSearchCryptocurrency(this.tabIndex, this.tabController,  {Key key, this.visibilityNotifier}) : super( key: key);

  @override
  _ScreenSearchCryptocurrencyState createState() => _ScreenSearchCryptocurrencyState(tabIndex, tabController, visibilityNotifier: visibilityNotifier);

}

class _ScreenSearchCryptocurrencyState extends BaseStateNoTabsWithParentTab<ScreenSearchCryptocurrency>

{
  GroupedNotifier _groupedNotifier = GroupedNotifier(GroupedData());
  //GeneralPriceNotifier _cryptoNotifier = GeneralPriceNotifier(new GeneralPriceData());
  
  
  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenSearchCryptocurrencyState(int tabIndex, TabController tabController, {ValueNotifier<bool> visibilityNotifier})
      : super('/search_cryptocurrency', tabIndex, tabController,parentTabIndex: Tabs.Search.index, visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;




  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName+'.doUpdate '+DateTime.now().toString());
    if(_groupedNotifier.value.isEmpty() || pullToRefresh){
      setNotifierLoading(_groupedNotifier);
    }

    try {
      final groupedData = await InvestrendTheme.datafeedHttp.fetchCrypto();
      if(groupedData != null){
        if(mounted){
          _groupedNotifier.setValue(groupedData);
        }
      }else{
        setNotifierNoData(_groupedNotifier);
      }
    } catch (error) {
      setNotifierError(_groupedNotifier, error);
    }
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
            Widget noWidget = _groupedNotifier.currentState.getNoWidget(onRetry: (){
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
                    CryptoPrice cp = value.map[holder.text].elementAt(holder.number);
                    //return RowGeneralPrice(gp.code, gp.price, gp.change, gp.percentChange, InvestrendTheme.changeTextColor(gp.change), name: gp.name, firstRow: (index == 0), onTap: (){},);

                    Color priceColor = InvestrendTheme.changeTextColor(cp.percent_change_24h);
                    return ListTile(
                      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                      //leading: Image.network(cp.icon_url, width: 40.0, height: 40.0,),
                      leading: ComponentCreator.imageNetworkCached(cp.icon_url, width: 35.0, height: 35.0,),
                      title: Row(
                        children: [
                          Text(
                            cp.code,
                            style: InvestrendTheme.of(context).regular_w600_compact,
                          ),
                          Spacer(flex: 1,),
                          Text(
                            InvestrendTheme.formatPriceDouble(cp.price),
                            style: InvestrendTheme.of(context).regular_w600_compact.copyWith(color: priceColor),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            cp.name,
                            style:
                            InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                          ),
                          Spacer(flex: 1,),
                          Text(
                            //'$change ($percentChange)',
                            //InvestrendTheme.formatChange(change)+
                            ' ('+InvestrendTheme.formatPercentChange(cp.percent_change_24h)+')',
                            style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: priceColor),
                          )
                        ],
                      ),
                      

                    );

                  }
                  //return EmptyLabel(text: 'Unknown',);
                });
          }),
    );

    /*
    List<Widget> childs = List.empty(growable: true);
    childs.add(ValueListenableBuilder(
      valueListenable: _cryptoNotifier,
      builder: (context, GeneralPriceData data, child) {
        if (_cryptoNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          children: List<Widget>.generate(
            data.count(),
                (int index) {
              GeneralPrice gp = data.datas.elementAt(index);
              return RowGeneralPrice(gp.code, gp.price, gp.change, gp.percent, gp.priceColor, name: gp.name, firstRow: (index == 0),);

            },
          ),
        );
      },
    ));
    childs.add(SizedBox(height: paddingBottom + 80,));

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: Padding(
        padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
        child: ListView(
          shrinkWrap: false,
          children: childs,
        ),
      ),
    );
    */
  }
  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardPaddingPlusMargin),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // CardGeneralPrice('search_currency_card_idr_rate_title'.tr(), _idrNotifier),
            // ComponentCreator.divider(context),
            // CardGeneralPrice('search_currency_card_cross_rate_title'.tr(), _crossNotifier),
            ValueListenableBuilder(
              valueListenable: _cryptoNotifier,
              builder: (context, GeneralPriceData data, child) {
                if (_cryptoNotifier.invalid()) {
                  return Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: List<Widget>.generate(
                    data.count(),
                        (int index) {
                      GeneralPrice gp = data.datas.elementAt(index);
                      return RowGeneralPrice(gp.code, gp.price, gp.change, gp.percent, gp.priceColor, name: gp.name, firstRow: (index == 0),);

                    },
                  ),
                );
              },
            ),


            SizedBox(height: paddingBottom + 80,),
          ],
        ),
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

      GeneralPriceData dataIdr = GeneralPriceData();
      dataIdr.datas.add(GeneralPrice('BTC', 826678213, 96.00, 0.31,  name: 'Bitcoin'));
      dataIdr.datas.add(GeneralPrice('ETH', 30678.00, 96.00, 0.31,  name: 'Etherium'));
      dataIdr.datas.add(GeneralPrice('DOGE', 30678.00, 96.00, 0.31,  name: 'Dogecoin'));
      dataIdr.datas.add(GeneralPrice('XRP', 30678.00, 96.00, 0.31,  name: 'Ripple'));
      dataIdr.datas.add(GeneralPrice('XLM', 30678.00, 96.00, 0.31,  name: 'Stellar Lumens'));
      dataIdr.datas.add(GeneralPrice('NEO', 30678.00, 96.00, 0.31,  name: 'Neo'));
      dataIdr.datas.add(GeneralPrice('YFI', 30678.00, 96.00, 0.31,  name: 'Yearn Finance'));
      dataIdr.datas.add(GeneralPrice('LTC', 30678.00, 96.00, 0.31,  name: 'Litecoin'));
      dataIdr.datas.add(GeneralPrice('WAVES', 461330668.00, -0.036, -0.04, name: 'Waves'));
      _cryptoNotifier.setValue(dataIdr);



    });

    */
  }


  @override
  void dispose() {
    //_cryptoNotifier.dispose();
    _groupedNotifier.dispose();


    super.dispose();
  }



  @override
  void onInactive() {
    //print(routeName+' onInactive');
  }
}
