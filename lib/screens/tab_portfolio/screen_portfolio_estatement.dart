import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenESatement extends StatefulWidget {
  const ScreenESatement({Key key}) : super(key: key);

  @override
  _ScreenESatementState createState() => _ScreenESatementState();
}

class _ScreenESatementState extends BaseStateNoTabs<ScreenESatement> {
  _ScreenESatementState() : super('/e-statement');

  // CashPositionNotifier _cashNotifier = CashPositionNotifier(CashPosition.createBasic());
  // BankRDNNotifier _bankRDNNotifier = BankRDNNotifier(BankRDN('','', '', ''));
  // BankAccountNotifier _bankAccountNotifier = BankAccountNotifier(BankAccount('', '', '', '', '', '', ''));
  // FundOutTermNotifier _termNotifier = FundOutTermNotifier(ResultFundOutTerm('',''));
  // TextEditingController _textEditingController = TextEditingController(text: '');
  // FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    // _cashNotifier.dispose();
    // _termNotifier.dispose();
    // _bankRDNNotifier.dispose();
    // _bankAccountNotifier.dispose();
    // _textEditingController.dispose();
    // _focusNode.dispose();
    super.dispose();
  }

  Future doUpdate({bool pullToRefresh = false}) async {

    final notifier = context.read(accountChangeNotifier);
    User user = context
        .read(dataHolderChangeNotifier)
        .user;
    Account active = user.getAccount(notifier.index);
    if(active == null){
      print(routeName+'  active Account is NULL');
      return false;
    }
    /*
    try {
      if (_bankRDNNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_bankRDNNotifier);
      }


      final result = await InvestrendTheme.tradingHttp.getBankRDN(active.accountcode, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future bank rdn DATA : ' + result.toString());
        if (mounted) {
          _bankRDNNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future bank rdn NO DATA');
        setNotifierNoData(_bankRDNNotifier);
      }
    } catch (error) {
      print(routeName + ' Future bank rdn Error');
      print(error);
      setNotifierError(_bankRDNNotifier, error.toString());
      handleNetworkError(context, error);
    }

    try {
      if (_bankAccountNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_bankAccountNotifier);
      }
      final result = await InvestrendTheme.tradingHttp.getBankAcccount(active.accountcode, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future bank account DATA : ' + result.toString());
        if (mounted) {
          _bankAccountNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future bank account NO DATA');
        setNotifierNoData(_bankAccountNotifier);
      }
    } catch (error) {
      print(routeName + ' Future bank account Error');
      print(error);
      setNotifierError(_bankAccountNotifier, error.toString());
      handleNetworkError(context, error);
    }

    try {
      if (_cashNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_cashNotifier);
      }
      final result = await InvestrendTheme.tradingHttp.cashPosition(active.brokercode, active.accountcode, user.username, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future cash DATA : ' + result.toString());
        if (mounted) {
          _cashNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future cash NO DATA');
        setNotifierNoData(_cashNotifier);
      }
    } catch (error) {
      print(routeName + ' Future cash Error');
      print(error);
      setNotifierError(_cashNotifier, error.toString());
      handleNetworkError(context, error);
    }

    try {
      if (_termNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_termNotifier);
      }
      final result = await HttpSSI.fetchFundOutTerm();
      if (result != null) {
        print(routeName + ' Future fund out term DATA : ' + result.toString());
        if (mounted) {
          _termNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future fund out term NO DATA');
        setNotifierNoData(_termNotifier);
      }
    } catch (error) {
      print(routeName + ' Future fund out term Error');
      print(error);
      setNotifierError(_termNotifier, error.toString());
    }

    */
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
  }



  @override
  Widget createAppBar(BuildContext context) {
    // TODO: implement createAppBar
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0.0,
      title: AppBarTitleText('e_statement_title'.tr()),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        Navigator.pop(context);
      }),

      //icon: Image.asset('images/icons/action_clear.png', color: InvestrendTheme.greenText, width: 12.0, height: 12.0),
    );
  }
  Widget createRow(BuildContext context, String date, String url){
    return Container(
      margin: EdgeInsets.only(/*bottom: InvestrendTheme.cardPaddingGeneral, */left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      padding: EdgeInsets.only(left: 12.0, /*right: 12.0, top: 10.0,bottom: 10.0*/),
      decoration: BoxDecoration(
        color: Color(0xFFF4F2F9),
        borderRadius: BorderRadius.circular(3.0),
      ),
      width: double.maxFinite,
      child: Row(
        children: [
          Image.asset('images/icons/statement.png', height: 24.0, width: 24.0,),
          SizedBox(width: InvestrendTheme.cardPaddingGeneral,),
          Text(date??'-', style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: Theme.of(context).colorScheme.secondary),),
          Spacer(flex: 1,),
          TextButton(child: Text('button_see'.tr(), style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: Theme.of(context).colorScheme.secondary),),onPressed: ()=> launchURL(context, url),),
        ],
      ),
    );
  }
  Widget createGroupTitle(BuildContext context, String year){
    return Padding(
      padding: const EdgeInsets.only(top:20.0, /*bottom:8.0,*/ left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Text(year??'-', style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
    );
  }
  void launchURL(BuildContext context, String _url) async {
    try{
      await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
    }catch(error){
      //InvestrendTheme.of(context).showSnackBar(context, error.toString());
    }
  }





  Widget dividerWithPadding(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(bottom:InvestrendTheme.cardPaddingGeneral, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: InvestrendTheme.cardPaddingGeneral),
      child: ComponentCreator.divider(context),
    );
  }
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ListView(
        children: [

          Padding(
            padding: const EdgeInsets.only(bottom:InvestrendTheme.cardPaddingGeneral, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
            child: Text(
              'choose_period_label'.tr(),
              style: InvestrendTheme.of(context).regular_w600,
            ),
          ),

          createGroupTitle(context, '2021'),
          dividerWithPadding(context),
          createRow(context, 'Agustus 2021', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'Juli 2021', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'Juni 2021', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'Mei 2021', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'April 2021', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),

          createGroupTitle(context, '2020'),
          dividerWithPadding(context),
          createRow(context, 'Desember 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'November 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'September 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'Agustus 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'Juli 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'Juni 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'Mei 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          dividerWithPadding(context),
          createRow(context, 'April 2020', 'https://www.e-ipo.co.id/en/pipeline/get-additional-info?id=44'),
          /*
          ValueListenableBuilder(
            valueListenable: _termNotifier,
            builder: (context, value, child) {
              Widget noWidget = _termNotifier.currentState.getNoWidget(onRetry: ()=> doUpdate(pullToRefresh: true));
              if(noWidget != null){
                return Center(
                  child: noWidget,
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom:InvestrendTheme.cardPaddingGeneral, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                child: Text(
                  value.getTerm(language: EasyLocalization.of(context).locale.languageCode),
                  style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
              );
            },
          ),
          
           */

        ],
      ),


      /*
      child: ValueListenableBuilder(
          valueListenable: _banksNotifier,
          builder: (context, ResultTopUpBank value, child) {
            if(value == null){
              value = _banksNotifier.value;
            }
            List<Widget> childs = List.empty(growable: true);
            childs.add(Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: 10.0),
              child: Text(
                'choose_account_label'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ));

            childs.add(ButtonAccount());
            childs.add(createBankInformation(context));
            childs.add(Padding(
              padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
              child: Text(
                'top_up_term_label'.tr(),
                style: InvestrendTheme.of(context).regular_w600,
              ),
            ));
            childs.add(Padding(
              padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
              child: Text(
                value.getTerm(language: EasyLocalization.of(context).locale.languageCode),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
              ),
            ));
            Widget noWidget = _banksNotifier.currentState.getNoWidget(onRetry: ()=>doUpdate(pullToRefresh: true));
            if(noWidget != null){
              childs.add(Center(child: noWidget));
            }
            int countChilds = childs.length;
            int countAll = childs.length + value.count();

            return ListView.separated(
              itemCount: countAll,
              itemBuilder: (context, index) {
                if(index < countChilds) {
                  return childs.elementAt(index);
                }
                int indexBank = index - countChilds;
                if(indexBank < value.count()){
                  TopUpBank bank = value.datas.elementAt(indexBank);
                  return createBankHowTo(context, bank);
                }
                return EmptyLabel(text: ' - ',);
              },
              separatorBuilder: (BuildContext context, int index) {
                if(index < countChilds) {
                  return SizedBox(width: 1.0,);
                }
                // int indexBank = countAll - index;
                // if(indexBank < value.count()){
                  return Padding(
                    padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                    child: ComponentCreator.divider(context, thickness: 1.0),
                  );
                // }
              },
            );
          }),
      */
    );
  }

  /*
  Widget createBankHowTo(BuildContext context, TopUpBank bank){
    return  Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
      child: TopupBankInfoWidget(bank.code, bank.icon_url,
          bank.getGuide(language: EasyLocalization.of(context).locale.languageCode)),
    );
  }
  */
  @override
  void onActive() {
    doUpdate();
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
    //FocusScope.of(context).requestFocus(new FocusNode());
  }
}
