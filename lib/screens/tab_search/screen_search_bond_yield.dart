import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/group_title.dart';
import 'package:Investrend/component/rows/row_general_price.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenSearchBondYield extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;
  ScreenSearchBondYield(this.tabIndex, this.tabController,  {Key key, this.visibilityNotifier}) : super( key: key);

  @override
  _ScreenSearchBondYieldState createState() => _ScreenSearchBondYieldState(tabIndex, tabController,visibilityNotifier: visibilityNotifier);

}

class _ScreenSearchBondYieldState extends BaseStateNoTabsWithParentTab<ScreenSearchBondYield>

{
  GroupedNotifier _groupedNotifier = GroupedNotifier(GroupedData());
  // GeneralPriceNotifier _usNotifier = GeneralPriceNotifier(new GeneralPriceData());
  // GeneralPriceNotifier _idNotifier = GeneralPriceNotifier(new GeneralPriceData());
  
  
  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenSearchBondYieldState(int tabIndex, TabController tabController,{ValueNotifier<bool> visibilityNotifier})
      : super('/search_currency', tabIndex, tabController,parentTabIndex: Tabs.Search.index,visibilityNotifier: visibilityNotifier);

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
      final groupedData = await InvestrendTheme.datafeedHttp.fetchBonds();
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
          .colorScheme.secondary,
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
                    GeneralDetailPrice gp = value.map[holder.text].elementAt(holder.number);
                    return RowGeneralPrice(gp.code, gp.price, gp.change, gp.percentChange, InvestrendTheme.changeTextColor(gp.change), name: gp.name, firstRow: (index == 0), onTap: (){}, threeDecimal: true, priceDecimal: true,);
                  }
                  //return EmptyLabel(text: 'Unknown',);
                });
          }),
    );
    /*
    List<Widget> childs = List.empty(growable: true);
    childs.add(CardGeneralPrice('search_bond_yield_card_us_bond_title'.tr(), _usNotifier));
    childs.add(ComponentCreator.divider(context));
    childs.add(CardGeneralPrice('search_bond_yield_card_indonesia_bond_title'.tr(), _idNotifier));
    childs.add(SizedBox(height: paddingBottom + 80,));

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: ListView(
        shrinkWrap: false,
        children: childs,
      ),
    );

     */
  }
  
  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          CardGeneralPrice('search_bond_yield_card_us_bond_title'.tr(), _usNotifier),
          ComponentCreator.divider(context),
          CardGeneralPrice('search_bond_yield_card_indonesia_bond_title'.tr(), _idNotifier),



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

      GeneralPriceData dataUs = GeneralPriceData();
      dataUs.datas.add(GeneralPrice('US 10Y', 30678.00, 96.00, 0.31,  name: ''));
      dataUs.datas.add(GeneralPrice('US 5Y', 30678.00, 96.00, 0.31,  name: ''));
      dataUs.datas.add(GeneralPrice('US 2Y', 91.151, -96.00, -0.31,  name: ''));
      _usNotifier.setValue(dataUs);


      GeneralPriceData dataId = GeneralPriceData();
      dataId.datas.add(GeneralPrice('ID 20Y', 30678.00, 96.00, 0.31,  name: ''));
      dataId.datas.add(GeneralPrice('ID 15Y', 30678.00, 96.00, 0.31,  name: ''));
      dataId.datas.add(GeneralPrice('ID 10Y',30678.00, 96.00, 0.31,  name: ''));
      dataId.datas.add(GeneralPrice('ID 5Y', 30678.00, 96.00, 0.31,  name: ''));
      _idNotifier.setValue(dataId);



    });

    */
  }


  @override
  void dispose() {
    _groupedNotifier.dispose();
    // _usNotifier.dispose();
    // _idNotifier.dispose();
    super.dispose();
  }



  @override
  void onInactive() {
    //print(routeName+' onInactive');
  }
}
