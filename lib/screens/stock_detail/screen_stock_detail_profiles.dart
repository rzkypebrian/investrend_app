import 'package:Investrend/component/cards/card_label_value.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenStockDetailProfiles extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;
  final ValueNotifier<bool> visibilityNotifier;
  ScreenStockDetailProfiles(this.tabIndex, this.tabController,  {Key key, this.visibilityNotifier}) : super( key: key);

  @override
  _ScreenStockDetailProfilesState createState() => _ScreenStockDetailProfilesState(tabIndex, tabController, visibilityNotifier: visibilityNotifier);

}

class _ScreenStockDetailProfilesState extends BaseStateNoTabsWithParentTab<ScreenStockDetailProfiles>

{
  //CompanyProfileNotifier _companyProfileNotifier = CompanyProfileNotifier(DataCompanyProfile.createBasic());
  LabelValueNotifier _historyNotifier = LabelValueNotifier(new LabelValueData());
  LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenStockDetailProfilesState(int tabIndex, TabController tabController, {ValueNotifier<bool> visibilityNotifier})
      : super('/stock_detail_profiles', tabIndex, tabController, notifyStockChange: true, visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;


  @override
  void onStockChanged(Stock newStock) {
    super.onStockChanged(newStock);
    doUpdate(pullToRefresh: true);
  }

  @override
  Widget createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    Stock stock = context.read(primaryStockChangeNotifier).stock;
    if (stock == null || !stock.isValid()) {
      Stock stockDefault = InvestrendTheme.storedData.listStock.isEmpty ? null : InvestrendTheme.storedData.listStock.first;
      context.read(primaryStockChangeNotifier).setStock(stockDefault);
      stock = context.read(primaryStockChangeNotifier).stock;
    }
    String code = stock != null ? stock.code : "";
    if( !StringUtils.isEmtpy(code) ){
      setNotifierLoading(_historyNotifier);
      setNotifierLoading(_boardOfCommisionersNotifier);
      setNotifierLoading(_shareHolderCompositionNotifier);
      try {
        final result = await InvestrendTheme.datafeedHttp.fetchCompanyProfile(code);
        if (result != null && !result.isEmpty()) {
          if(mounted){
            print('Got fetchCompanyProfile : '+result.toString());
            //_incomeStatementNotifier.setValue(result);


            LabelValueData dataHistory = new LabelValueData();
            dataHistory.datas.add(LabelValue('card_history_listing_date_label'.tr(), result.listing_date));
            dataHistory.datas.add(LabelValue('card_history_effective_date_label'.tr(), result.effective_date));
            dataHistory.datas.add(LabelValue('card_history_nominal_label'.tr(), result.nominal));
            dataHistory.datas.add(LabelValue('card_history_ipo_price_label'.tr(), result.ipo_price));
            dataHistory.datas.add(LabelValue('card_history_ipo_shares_label'.tr(), result.ipo_shares));
            dataHistory.datas.add(LabelValue('card_history_ipo_amount_label'.tr(), result.ipo_amount));
            dataHistory.datas.add(LabelValueDivider());

            int countUnderwriter = result.countUnderwriter();
            if(countUnderwriter == 0){
              dataHistory.datas.add(LabelValue('card_history_underwriter_label'.tr(), '-'));
            }else{
              for(int i = 0; i <countUnderwriter; i++){
                if(i == 0){
                  dataHistory.datas.add(LabelValue('card_history_underwriter_label'.tr(), result.underwriter_list.elementAt(i)));
                }else{
                  dataHistory.datas.add(LabelValue(' ', result.underwriter_list.elementAt(i)));
                }
              }
            }

            //dataHistory.datas.add(LabelValue(' ', 'PT CIMB-GK Securities Indonesia'));
            //dataHistory.datas.add(LabelValue(' ', 'PT Indo Premier Securities'));
            dataHistory.datas.add(LabelValueDivider());

            int countShareRegistrar = result.countShareRegistrar();
            if(countShareRegistrar == 0){
              dataHistory.datas.add(LabelValue('card_history_share_registrar_label'.tr(), '-'));
            }else{
              for(int i = 0; i <countShareRegistrar; i++){
                if(i == 0){
                  dataHistory.datas.add(LabelValue('card_history_share_registrar_label'.tr(), result.share_registrar_list.elementAt(i)));
                }else{
                  dataHistory.datas.add(LabelValue(' ', result.share_registrar_list.elementAt(i)));
                }
              }
            }

            //dataHistory.datas.add(LabelValue('card_history_share_registrar_label'.tr(), 'PT Datindo Entrycom'));
            print('dataHistory : '+dataHistory.count().toString());
            _historyNotifier.setValue(dataHistory);


            LabelValueData dataShareholders = new LabelValueData();
            dataShareholders.additionalInfo = result.additionalInfo;
            int countContentList = result.countContentList();
            for(int i = 0; i <countContentList; i++){
              DynamicContent dc = result.contentList.elementAt(i);
              if(dc.isDivider()){
                dataShareholders.datas.add(LabelValueDivider());
              }else if(dc.isSubtitle()){
                dataShareholders.datas.add(LabelValueSubtitle(dc.text_1));
              }else{
                dataShareholders.datas.add(LabelValuePercent(dc.text_1, dc.text_2,dc.text_3,valuePercentColor: dc.color));
              }
            }

            _shareHolderCompositionNotifier.setValue(dataShareholders);



            LabelValueData dataCommisioners = new LabelValueData();

            addTo(dataCommisioners, result.countPresidentCommissioner(), 'card_board_of_commisioners_president_commissioner_label'.tr(), result.president_commissioner_list);
            addTo(dataCommisioners, result.countVicePresidentCommissioner(), 'card_board_of_commisioners_vice_president_commissioner_label'.tr(), result.vice_president_commissioner_list);
            addTo(dataCommisioners, result.countCommissioner(), 'card_board_of_commisioners_commissioner_label'.tr(), result.commissioner_list);
            dataCommisioners.datas.add(LabelValueDivider());

            addTo(dataCommisioners, result.countPresidentDirector(), 'card_board_of_commisioners_president_director_label'.tr(), result.president_director_list);
            addTo(dataCommisioners, result.countVicePresidentDirector(), 'card_board_of_commisioners_vice_president_director_label'.tr(), result.vice_president_director_list);
            addTo(dataCommisioners, result.countDirectorList(), 'card_board_of_commisioners_director_label'.tr(), result.director_list);

            _boardOfCommisionersNotifier.setValue(dataCommisioners);
            /*
            int countPresidentCommissioner = result.countPresidentCommissioner();
            if(countPresidentCommissioner == 0){
              dataHistory.datas.add(LabelValue('card_board_of_commisioners_president_commissioner_label'.tr(), '-'));
            }else{
              for(int i = 0; i <countPresidentCommissioner; i++){
                if(i == 0){
                  dataHistory.datas.add(LabelValue('card_board_of_commisioners_president_commissioner_label'.tr(), result.president_commissioner_list.elementAt(i)));
                }else{
                  dataHistory.datas.add(LabelValue(' ', result.president_commissioner_list.elementAt(i)));
                }
              }
            }
            */

            // dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_commissioner_label'.tr(), 'Jarot Widyoko'));
            // dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_commissioner_label'.tr(), 'Phil Foden'));
            // dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_commissioner_label'.tr(), 'Edy Sudarmanto'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));
            // dataCommisioners.datas.add(LabelValueDivider());
            // dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_director_label'.tr(), 'Agung Budi Waskito'));
            // dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_director_label'.tr(), 'Agung Budi Waskito'));
            // dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_director_label'.tr(), 'Edy Sudarmanto'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
            // dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));




          }else{
            print('ignored fetchCompanyProfile, mounted : $mounted');
          }
        } else {
          setNotifierNoData(_historyNotifier);
          setNotifierNoData(_boardOfCommisionersNotifier);
          setNotifierNoData(_shareHolderCompositionNotifier);
        }
      } catch (error) {
        print('fetchCompanyProfile : '+error.toString());
        setNotifierError(_historyNotifier, error);
        setNotifierError(_boardOfCommisionersNotifier, error);
        setNotifierError(_shareHolderCompositionNotifier, error);
      }
    }
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  void addTo(LabelValueData data, int count,  String label, List<String> content){
    //int countPresidentCommissioner = result.countPresidentCommissioner();
    if(count == 0){
      data.datas.add(LabelValue(label, '-'));
    }else{
      for(int i = 0; i <count; i++){
        if(i == 0){
          data.datas.add(LabelValue(label, content.elementAt(i)));
        }else{
          data.datas.add(LabelValue(' ', content.elementAt(i)));
        }
      }
    }
  }

  Future onRefresh() {
    context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    if(!active){
      active = true;
      //onActive();
      context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      CardLabelValueNotifier('card_history_title'.tr(), _historyNotifier),
      ComponentCreator.divider(context),
      CardLabelValueNotifier('card_shareholders_composition_title'.tr(), _shareHolderCompositionNotifier),
      ComponentCreator.divider(context),
      CardLabelValueNotifier('card_board_of_commisioners_title'.tr(), _boardOfCommisionersNotifier),
      SizedBox(height: paddingBottom + 80,),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ListView(
        controller: pScrollController,
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
          CardLabelValueNotifier('card_history_title'.tr(), _historyNotifier),
          ComponentCreator.divider(context),
          CardLabelValueNotifier('card_shareholders_composition_title'.tr(), _shareHolderCompositionNotifier),
          ComponentCreator.divider(context),
          CardLabelValueNotifier('card_board_of_commisioners_title'.tr(), _boardOfCommisionersNotifier),
          //ComponentCreator.divider(context),


          SizedBox(height: paddingBottom + 80,),
        ],
      ),
    );
  }
  */
  @override
  void onActive() {
    //print(routeName+' onActive');

    context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    doUpdate(pullToRefresh: true);
  }


  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate(pullToRefresh: true);
    // });
    /*
    Future.delayed(Duration(milliseconds: 500),(){

      LabelValueData dataHistory = new LabelValueData();
      dataHistory.datas.add(LabelValue('card_history_listing_date_label'.tr(), '28 Oct 2007'));
      dataHistory.datas.add(LabelValue('card_history_effective_date_label'.tr(), '11 Oct 2007'));
      dataHistory.datas.add(LabelValue('card_history_nominal_label'.tr(), '100'));
      dataHistory.datas.add(LabelValue('card_history_ipo_price_label'.tr(), '420'));
      dataHistory.datas.add(LabelValue('card_history_ipo_shares_label'.tr(), '1,85 B'));
      dataHistory.datas.add(LabelValue('card_history_ipo_amount_label'.tr(), '775,43 B'));
      dataHistory.datas.add(LabelValueDivider());
      dataHistory.datas.add(LabelValue('card_history_underwriter_label'.tr(), 'PT Bahana Securities'));
      dataHistory.datas.add(LabelValue(' ', 'PT CIMB-GK Securities Indonesia'));
      dataHistory.datas.add(LabelValue(' ', 'PT Indo Premier Securities'));
      dataHistory.datas.add(LabelValueDivider());
      dataHistory.datas.add(LabelValue('card_history_share_registrar_label'.tr(), 'PT Datindo Entrycom'));
      _historyNotifier.setValue(dataHistory);


      LabelValueData dataShareholders = new LabelValueData();
      dataShareholders.additionalInfo = '(Effective 31 Dec 2020)';
      dataShareholders.datas.add(LabelValuePercent('Negara Republik Indonesia (P)', '5.834.850.000','65,049%'));
      dataShareholders.datas.add(LabelValuePercent('Public', '3.134.001.372','34,939%'));
      dataShareholders.datas.add(LabelValuePercent('Saham Treasury', '1.100.000','0,012%'));
      dataShareholders.datas.add(LabelValueDivider());
      dataShareholders.datas.add(LabelValuePercent('Total', '8.969.951.372','100%'));
      dataShareholders.datas.add(LabelValuePercent('Shareholders Total', '46.105','(+9.423)',valuePercentColor: InvestrendTheme.greenText));
      dataShareholders.datas.add(LabelValueDivider());
      dataShareholders.datas.add(LabelValueSubtitle('Shareholders by BoC and BoD'));
      dataShareholders.datas.add(LabelValuePercent('Ade Wahyu', '457.435','0,0051%'));
      dataShareholders.datas.add(LabelValuePercent('Agung Budi Waskito', '34.200','0,0004%'));

      _shareHolderCompositionNotifier.setValue(dataShareholders);

      LabelValueData dataCommisioners = new LabelValueData();
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_commissioner_label'.tr(), 'Jarot Widyoko'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_commissioner_label'.tr(), 'Phil Foden'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_commissioner_label'.tr(), 'Edy Sudarmanto'));
      dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
      dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
      dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
      dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));
      dataCommisioners.datas.add(LabelValueDivider());
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_president_director_label'.tr(), 'Agung Budi Waskito'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_vice_president_director_label'.tr(), 'Agung Budi Waskito'));
      dataCommisioners.datas.add(LabelValue('card_board_of_commisioners_director_label'.tr(), 'Edy Sudarmanto'));
      dataCommisioners.datas.add(LabelValue(' ', 'Firdaus Ali'));
      dataCommisioners.datas.add(LabelValue(' ', 'Satya Bhakti Parikesit'));
      dataCommisioners.datas.add(LabelValue(' ', 'Harris Arthur Hedar'));
      dataCommisioners.datas.add(LabelValue(' ', 'Suryo Hapsoro Tri Utomo'));
      _boardOfCommisionersNotifier.setValue(dataCommisioners);





    });
*/

  }


  @override
  void dispose() {
    _historyNotifier.dispose();
    _shareHolderCompositionNotifier.dispose();
    _boardOfCommisionersNotifier.dispose();
    //_companyProfileNotifier.dispose();
    final container = ProviderContainer();
    container.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, false);

    super.dispose();
  }



  @override
  void onInactive() {
    //print(routeName+' onInactive');
    context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, false);
  }
}
