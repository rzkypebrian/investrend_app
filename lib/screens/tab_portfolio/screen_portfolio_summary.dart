// ignore_for_file: unused_local_variable, non_constant_identifier_names

import 'package:Investrend/component/button_tab_switch.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenPortfolioSummary extends StatefulWidget {
  final TabController? tabController;
  final int tabIndex;

  ScreenPortfolioSummary(this.tabIndex, this.tabController, {Key? key})
      : super(key: key);

  @override
  _ScreenPortfolioSummaryState createState() =>
      _ScreenPortfolioSummaryState(tabIndex, tabController!);
}

class _ScreenPortfolioSummaryState
    extends BaseStateNoTabsWithParentTab<ScreenPortfolioSummary> {
  PortfolioSummaryNotifier _notifier =
      PortfolioSummaryNotifier(PortfolioSummaryData.createBasic());

  //StockPositionNotifier _stockPositionNotifier = StockPositionNotifier(new StockPosition('', 0, 0, 0, 0, 0, 0, List.empty(growable: true)));
  final ValueNotifier<int> _buttonReturnNotifier = ValueNotifier<int>(0);
  //final ValueNotifier<PortfolioSummary> _portfolioSummaryNotifier = ValueNotifier<PortfolioSummary>(null);

  final ValueNotifier<bool> _returnNotifier = ValueNotifier<bool>(false);

  // LabelValueNotifier _shareHolderCompositionNotifier = LabelValueNotifier(new LabelValueData());
  // LabelValueNotifier _boardOfCommisionersNotifier = LabelValueNotifier(new LabelValueData());

  _ScreenPortfolioSummaryState(int tabIndex, TabController tabController)
      : super('/portfolio_summary', tabIndex, tabController,
            parentTabIndex: Tabs.Portfolio.index);

  // @override
  // bool get wantKeepAlive => true;
  //
  // List<String> _range_options = [
  //   'daily_label'.tr(),
  //   'weekly_label'.tr(),
  //   'monthly_label'.tr(),
  //   'annual_label'.tr(),
  // ];
  List<ReturnInfo>? listHighest = List.empty(growable: true);
  List<ReturnInfo>? listLowest = List.empty(growable: true);

  // List<ReturnInfo> listHighest = [
  //   ReturnInfo('ELSA', 'dalam 10 hari', 10.14, 200000000),
  //   ReturnInfo('BBCA', 'dalam 14 hari', 7.14, 50000000),
  //   ReturnInfo('SMRA', 'dalam 30 hari', 3.14, 27000000),
  // ];
  // List<ReturnInfo> listLowest = [
  //   ReturnInfo('BBCA', 'dalam 10 hari', -10.14, -200000000),
  //   ReturnInfo('BUMI', 'dalam 14 hari', -7.14, -50000000),
  //   ReturnInfo('ENRG', 'dalam 30 hari', -3.14, -27000000),
  // ];
  final List<String> button_returns = [
    'portfolio_summary_highest_return_button'.tr(),
    'portfolio_summary_lowest_return_button'.tr(),
  ];

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  active : $active  pullToRefresh : $pullToRefresh");

    final notifier = context.read(accountChangeNotifier);

    User user = context.read(dataHolderChangeNotifier).user;
    Account? activeAccount = user.getAccount(notifier.index);
    if (activeAccount == null) {
      print(routeName + '  active Account is NULL');
      return false;
    }

    try {
      if (_notifier.value!.isEmpty() || pullToRefresh) {
        setNotifierLoading(_notifier);
      }
      final PortfolioSummaryData? result = await InvestrendTheme.tradingHttp
          .portfolioSummary(
              activeAccount.brokercode,
              activeAccount.accountcode,
              user.username,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(
            routeName + ' Future portfolioSummary DATA : ' + result.toString());
        if (mounted) {
          _notifier.setValue(result);
          listHighest?.clear();
          listLowest?.clear();
          if (result.topgain1value > 0.0) {
            listHighest
                ?.add(ReturnInfo(result.topgain1stock, result.topgain1value));
          }
          if (result.topgain2value > 0.0) {
            listHighest
                ?.add(ReturnInfo(result.topgain2stock, result.topgain2value));
          }
          if (result.topgain3value > 0.0) {
            listHighest
                ?.add(ReturnInfo(result.topgain3stock, result.topgain3value));
          }
          if (result.toploss1value < 0.0) {
            listLowest
                ?.add(ReturnInfo(result.toploss1stock, result.toploss1value));
          }
          if (result.toploss2value < 0.0) {
            listLowest
                ?.add(ReturnInfo(result.toploss2stock, result.toploss2value));
          }
          if (result.toploss3value < 0.0) {
            listLowest
                ?.add(ReturnInfo(result.toploss3stock, result.toploss3value));
          }
          _returnNotifier.value = !_returnNotifier.value;
        }
      } else {
        listHighest?.clear();
        listLowest?.clear();
        if (mounted) {
          _returnNotifier.value = !_returnNotifier.value;
        }
        print(routeName + ' Future portfolioSummary NO DATA');
        setNotifierNoData(_notifier);
      }
    } catch (error) {
      print(routeName + ' Future realizedStock Error');
      print(error);
      setNotifierError(_notifier, error.toString());
      handleNetworkError(context, error);
    }

    /*
    String accoun_codes = '';

    context.read(dataHolderChangeNotifier).user?.accounts?.forEach((account) {
      if(StringUtils.isEmtpy(accoun_codes)){
        accoun_codes = account.accountcode;
      }else{
        accoun_codes += '|'+account.accountcode;
      }
    });

    try {
      print(routeName+' try stockPosition');
      final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
          '', // broker
          accoun_codes,
          '', // username
          InvestrendTheme.of(super.context).applicationPlatform,
          InvestrendTheme.of(super.context).applicationVersion);
      DebugWriter.info(routeName+' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
      int count = stockPosition.stockListSize();
      listLowest.clear();
      listHighest.clear();

      if(count > 0){
        stockPosition.stocksList.sort((a, b) => a.stockGL.compareTo(b.stockGL));
        int maxLoop = 3;
        for(int i = 0; i < count; i++){
          if(i < maxLoop){
            StockPositionDetail data =  stockPosition.stocksList.elementAt(i);
            if(data.stockGL.toInt() < 0) {
              listLowest.add(ReturnInfo(data.stockCode, 'dalam ?? hari', data.stockGLPct, data.stockGL.toInt()));
            }
          }else{
            break;
          }
        }
        int index = 0;
        for(int i = count-1; i >= 0; i--){
          if(index < maxLoop){
            StockPositionDetail data =  stockPosition.stocksList.elementAt(i);
            if(data.stockGL.toInt() > 0){
              listHighest.add(ReturnInfo(data.stockCode, 'dalam ?? hari', data.stockGLPct, data.stockGL.toInt()));
            }

            index++;
          }else{
            break;
          }
        }
      }
      _stockPositionNotifier.setValue(stockPosition);
    } catch (e) {
      DebugWriter.info(routeName+' stockPosition Exception : ' + e.toString());

      //handleNetworkError(context, e);

      if(e is TradingHttpException){
        if(e.isUnauthorized()){
          InvestrendTheme.of(super.context).showDialogInvalidSession(super.context);
          return false;
        }else if(e.isErrorTrading()){
          InvestrendTheme.of(context).showSnackBar(context, e.message());
        }else{
          String network_error_label = 'network_error_label'.tr();
          network_error_label = network_error_label.replaceFirst("#CODE#", e.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, network_error_label);
        }
      }else{
        InvestrendTheme.of(context).showSnackBar(context, e.toString());
      }
    }
    */

    /*
    int selected = context.read(accountChangeNotifier).index;
    //Account account = InvestrendTheme.of(context).user.getAccount(selected);
    Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);

    if (account == null) {
      //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
      String text = routeName+' No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
      InvestrendTheme.of(context).showSnackBar(context, text);
      return;
    } else {
      try {
        print(routeName+' try stockPosition');
        final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
            account.brokercode,
            account.accountcode,
            context.read(dataHolderChangeNotifier).user.username,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        DebugWriter.info(routeName+' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());


        int count = stockPosition.stockListSize();
        listLowest.clear();
        listHighest.clear();

        if(count > 0){
          stockPosition.stocksList.sort((a, b) => a.stockGL.compareTo(b.stockGL));
          int maxLoop = 3;
          for(int i = 0; i < count; i++){
            if(i < maxLoop){
              StockPositionDetail data =  stockPosition.stocksList.elementAt(i);
              listLowest.add(ReturnInfo(data.stockCode, 'dalam ?? hari', data.stockGLPct, data.stockGL.toInt()));
            }else{
              break;
            }
          }
          int index = 0;
          for(int i = count-1; i >= 0; i--){
            if(index < maxLoop){
              StockPositionDetail data =  stockPosition.stocksList.elementAt(i);
              listHighest.add(ReturnInfo(data.stockCode, 'dalam ?? hari', data.stockGLPct, data.stockGL.toInt()));
              index++;
            }else{
              break;
            }
          }
        }
        _stockPositionNotifier.setValue(stockPosition);
      } catch (e) {
        DebugWriter.info(routeName+' stockPosition Exception : ' + e.toString());
        if(e is TradingHttpException){
          if(e.unauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return;
          }
        }
      }
    }
     */
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  // Future doUpdate({bool pullToRefresh = false}) async {
  //   print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
  //   return true;
  // }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    List<Widget> childs = [
      ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (context, PortfolioSummaryData? data, child) {
          Widget? noWidget = _notifier.currentState.getNoWidget(onRetry: () {
            doUpdate(pullToRefresh: true);
          });
          if (data == null) {
            return Center(child: CircularProgressIndicator());
          }
          return _contentPerformance(context, data);
        },
      ),
      ButtonTabSwitch(button_returns, _buttonReturnNotifier),
      ValueListenableBuilder(
        valueListenable: _returnNotifier,
        builder: (context, value, child) {
          return activeReturn(context, _buttonReturnNotifier.value);
        },
      ),
      SizedBox(
        height: paddingBottom,
      ),
    ];

    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(
            top: InvestrendTheme.cardPaddingGeneral,
            bottom: InvestrendTheme.cardPaddingGeneral),
        shrinkWrap: false,
        children: childs,
      ),
    );
  }

  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingPlusMargin, bottom: InvestrendTheme.cardPaddingPlusMargin),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _portfolioSummaryNotifier,
              builder: (context, PortfolioSummary data, child) {
                if (data == null) {
                  return Center(child: CircularProgressIndicator());
                }
                return _contentPerformance(context, data);
              },
            ),
            ButtonTabSwitch(button_returns, _buttonReturnNotifier),
            ValueListenableBuilder(
              valueListenable: _returnNotifier,
              builder: (context, value, child) {

                return activeReturn(context, _buttonReturnNotifier.value);
              },
            ),
            /*
            ValueListenableBuilder(
              valueListenable: _buttonReturnNotifier,
              builder: (context, int indexSelected, child) {

                return activeReturn(context, indexSelected);
              },
            ),
            */

            SizedBox(
              height: InvestrendTheme.cardPadding,
            ),

            // SizedBox(
            //   height: paddingBottom + 80,
            // ),
          ],
        ),
      ),
    );
  }
  */
  AutoSizeGroup groupReturnValue = AutoSizeGroup();
  Widget tile(BuildContext context, double size, double height, ReturnInfo info,
      List<Color> colorDarker, List<Color> colorLighter, Color? colorBackground,
      {bool isFirst = false}) {
    TextStyle? small700 = InvestrendTheme.of(context)
        .small_w600_compact
        ?.copyWith(
            color: InvestrendTheme.of(context).whiteColor,
            fontWeight: FontWeight.bold);

    return Container(
      color: colorBackground,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(
            left: (isFirst ? 0.0 : 8.0), top: 8.0, bottom: 8.0
            //, top: InvestrendTheme.cardMargin, bottom: InvestrendTheme.cardMargin
            ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: Gradient.lerp(
                LinearGradient(
                    //tileMode: TileMode.repeated,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.2, 0.4, 0.6, 0.8, 1],
                    colors: colorDarker),
                LinearGradient(
                    //tileMode: TileMode.repeated,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [0.2, 0.4, 0.6, 0.8, 1],
                    colors: colorLighter),
                0.5)),
        child: SizedBox(
          width: size,
          //height: size,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(
                flex: 1,
              ),
              Text(
                info.code!,
                style: small700,
              ),
              //Spacer(flex: 1,),
              //Text(InvestrendTheme.formatPercent(info.percentChange), style: small700,),
              //Spacer(flex: 1,),
              //Text(info.timeRange, style: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).whiteColor),),
              Spacer(
                flex: 5,
              ),
              //Text(InvestrendTheme.formatMoney(info.change, prefixPlus: true),style: small700,),
              AutoSizeText(
                InvestrendTheme.formatMoneyDouble(info.value, prefixPlus: true),
                style: small700,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupReturnValue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> colorsLowest = [
    Color(0xFF982229),
    Color(0xFFAB1B31),
    Color(0xFFBF1339),
    Color(0xFFD20C41),
    Color(0xFFE50449),
  ];
  List<Color> colorsLowest2 = [
    Color(0xFFE50449),
    Color(0xFFD20C41),
    Color(0xFFBF1339),
    Color(0xFFAB1B31),
    Color(0xFF982229),
  ];

  List<Color> colorsHighest = [
    Color(0xFF451B9E),
    Color(0xFF4919AD),
    Color(0xFF4D18BD),
    Color(0xFF5016CC),
    Color(0xFF5414DB),
  ];
  List<Color> colorsHighest2 = [
    Color(0xFF5414DB),
    Color(0xFF5016CC),
    Color(0xFF4D18BD),
    Color(0xFF4919AD),
    Color(0xFF451B9E),
  ];

  List<Color> colorsFlat = [
    Color(0xFFB57431),
    Color(0xFFC67F36),
    Color(0xFFD88A3A),
    Color(0xFFE9953F),
    Color(0xFFFAA043),
  ];
  List<Color> colorsFlat2 = [
    Color(0xFFFAA043),
    Color(0xFFE9953F),
    Color(0xFFD88A3A),
    Color(0xFFC67F36),
    Color(0xFFB57431),
  ];

  Widget activeReturn(BuildContext context, int index) {
    bool highest = index == 0;
    List<Color> colorLowestDarker = colorsLowest;
    List<Color> colorLowestLighter = colorsLowest2;
    //Color colorLowestBackground = Color(0xFFF4F2F9);

    List<Color> colorHighestDarker = colorsHighest;
    List<Color> colorHighestLighter = colorsHighest2;

    List<Color> colorFlatDarker = colorsFlat;
    List<Color> colorFlatLighter = colorsFlat2;

    //Color colorHighestBackground = Color(0xFFF4F2F9);

    List<Color> colorDarker;
    List<Color> colorLighter;
    Color? colorBackground = InvestrendTheme.of(context).tileBackground;
    List<ReturnInfo>? returnList;
    if (highest) {
      returnList = listHighest;
      colorDarker = colorHighestDarker;
      colorLighter = colorHighestLighter;
      //colorBackground = colorHighestBackground;
    } else {
      returnList = listLowest;
      colorDarker = colorLowestDarker;
      colorLighter = colorLowestLighter;
      //colorBackground = colorLowestBackground;
    }
    double tileSize = MediaQuery.of(context).size.width * 0.34;
    double tileHeight = tileSize * 0.835;

    if (returnList!.isEmpty) {
      return Container(
        width: double.maxFinite,
        //height: tileSize + InvestrendTheme.cardPaddingGeneral + 8.0 + 8.0,
        height: tileHeight + InvestrendTheme.cardPaddingGeneral + 8.0 + 8.0,
        margin: EdgeInsets.only(
            left: InvestrendTheme.cardMargin,
            right: InvestrendTheme.cardMargin,
            bottom: InvestrendTheme.cardMargin),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0), color: colorBackground),
        child: Center(
          child: EmptyLabel(
            text: highest
                ? 'summary_return_highest_empty_label'.tr()
                : 'summary_return_lowest_empty_label'.tr(),
          ),
        ),
      );
    }

    //colorBackground = Colors.orange;

    // ignore: unnecessary_null_comparison
    int count = returnList != null ? returnList.length : 0;
    List<Widget> listContent = List<Widget>.generate(
      count,
      (int index) {
        ReturnInfo? info = returnList?.elementAt(index);
        if (info!.value > 0) {
          colorDarker = colorHighestDarker;
          colorLighter = colorHighestLighter;
        } else if (info.value < 0) {
          colorDarker = colorLowestDarker;
          colorLighter = colorLowestLighter;
        } else {
          colorDarker = colorFlatDarker;
          colorLighter = colorFlatLighter;
        }
        return tile(context, tileSize, tileHeight, info, colorDarker,
            colorLighter, colorBackground,
            isFirst: index == 0);
      },
    );

    listContent.insert(
        0,
        Container(
          //height: tileSize+InvestrendTheme.cardPaddingPlusMargin,
          //height: tileSize + InvestrendTheme.cardPaddingGeneral+ 8.0+8.0,
          height: tileHeight + InvestrendTheme.cardPaddingGeneral + 8.0 + 8.0,
          width: 8.0,
          margin: EdgeInsets.only(left: InvestrendTheme.cardMargin),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
              color: colorBackground),
        ));
    listContent.insert(
        listContent.length,
        Container(
          //height: tileSize+InvestrendTheme.cardPaddingPlusMargin,
          //height: tileSize + InvestrendTheme.cardPaddingGeneral+ 8.0+8.0,
          height: tileHeight + InvestrendTheme.cardPaddingGeneral + 8.0 + 8.0,
          width: 8.0,
          margin: EdgeInsets.only(right: InvestrendTheme.cardMargin),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
              color: colorBackground),
        ));
    return Container(
      //width: MediaQuery.of(context).size.width - InvestrendTheme.cardPadding,
      //height: tileSize + InvestrendTheme.cardPaddingGeneral + 8.0 + 8.0,
      height: tileHeight + InvestrendTheme.cardPaddingGeneral + 8.0 + 8.0,
      //margin: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
      //padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10.0),
      //   color: colorBackground,
      // ),
      //color: colorBackground,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: listContent,
      ),
    );
  }

  Widget _rowBold(BuildContext context, String label, String value,
      {Color? valueColor, bool usePaddingTopBottom = true}) {
    TextStyle? regular700 = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle? valueStyle = regular700;
    TextStyle? labelStyle = regular700?.copyWith(
        color: InvestrendTheme.of(context).greyLighterTextColor);
    if (valueColor != null) {
      valueStyle = regular700?.copyWith(color: valueColor);
    }
    double paddingLeftRight = InvestrendTheme.cardPaddingGeneral;
    double paddingTopBottom =
        usePaddingTopBottom ? InvestrendTheme.cardPaddingGeneral : 0.0;
    return Padding(
      padding: EdgeInsets.only(
          left: paddingLeftRight,
          right: paddingLeftRight,
          top: paddingTopBottom,
          bottom: paddingTopBottom),
      child: Row(
        children: [
          Text(label, style: labelStyle),
          Expanded(
              flex: 1,
              child:
                  Text(value, style: valueStyle, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _rowNormal(BuildContext context, String label, String value) {
    TextStyle? small400 = InvestrendTheme.of(context).small_w400_compact;
    TextStyle? labelStyle = small400?.copyWith(
        color: InvestrendTheme.of(context).greyLighterTextColor);

    const padding = InvestrendTheme.cardPaddingGeneral;
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Row(
        children: [
          Text(
            label,
            style: labelStyle,
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: small400,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentPerformance(BuildContext context, PortfolioSummaryData? data) {
    if (data == null) {
      return Text('No Data');
    } else {
      Color profitColor = InvestrendTheme.changeTextColor(data.totalprofit);
      TextStyle? regular700 = InvestrendTheme.of(context).regular_w600_compact;
      TextStyle? moreSupport400 =
          InvestrendTheme.of(context).more_support_w400_compact;
      TextStyle? small400 = InvestrendTheme.of(context).small_w400_compact;
      const double padding = InvestrendTheme.cardPaddingGeneral;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: padding, right: padding, top: padding),
            child: Text('portfolio_summary_info_title'.tr(), style: regular700),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: padding, right: padding, bottom: 25.0, top: 4.0),
            child: Text(
                data.begindate! +
                    ' - ' +
                    'portfolio_summary_current_label'.tr(),
                style: moreSupport400?.copyWith(
                    color: InvestrendTheme.of(context).greyDarkerTextColor)),
          ),

          //SizedBox(height: 20.0),
          _rowBold(
              context,
              'portfolio_summary_total_asset_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.totalasset,
                  prefixRp: false)),
          _rowNormal(
              context,
              'portfolio_summary_portfolio_value_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.portfoliovalue,
                  prefixRp: false)),
          _rowNormal(
              context,
              'portfolio_summary_cash_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.cashvalue,
                  prefixRp: false)),
          Padding(
            padding: EdgeInsets.only(
              left: padding,
              right: padding,
            ),
            child: ComponentCreator.divider(context),
          ),
          _rowBold(
              context,
              'portfolio_summary_capital_fund_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.modalsetor,
                  prefixRp: false)),
          _rowNormal(context, 'portfolio_summary_cash_in_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.cashin, prefixRp: false)),
          _rowNormal(context, 'portfolio_summary_cash_out_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.cashout, prefixRp: false)),
          Padding(
            padding: EdgeInsets.only(
              left: padding,
              right: padding,
            ),
            child: ComponentCreator.divider(context),
          ),
          SizedBox(
            height: padding,
          ),
          _rowBold(
              context,
              'portfolio_summary_total_profit_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.totalprofit,
                  prefixRp: false),
              usePaddingTopBottom: false,
              valueColor: profitColor),
          SizedBox(
            height: padding,
          ),
          /*
          Padding(
            padding: const EdgeInsets.only(left: padding, right: padding, bottom: padding, top: 3.0),
            child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  //InvestrendTheme.formatPercent(data.totalProfitPercentage),
                  '??? %',
                  style: small400.copyWith(color: profitColor),
                )),
          ),
          */
          _rowNormal(
              context,
              'portfolio_summary_realized_profit_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.realizedprofit,
                  prefixRp: false)),
          _rowNormal(
              context,
              'portfolio_summary_unrealized_profit_label'.tr(),
              InvestrendTheme.formatMoneyDouble(data.unrealizedprofit,
                  prefixRp: false)),
          //_rowNormal(context, 'portfolio_summary_interest_profit_label'.tr(), InvestrendTheme.formatMoney(data.interestProfit, prefixRp: false)),
          // SizedBox(
          //   height: padding,
          // ),
          Padding(
            padding: EdgeInsets.only(
                left: padding, right: padding, top: padding, bottom: padding),
            child: Align(
                alignment: Alignment.centerRight,
                child: Text('not_include_fee_label'.tr(),
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact_greyDarker)),
          ),
          ComponentCreator.dividerCard(context),
        ],
      );
    }
  }

  @override
  void onActive() {
    //print(routeName + ' onActive');
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    doUpdate();
    // });
  }

  @override
  void initState() {
    super.initState();

    _buttonReturnNotifier.addListener(() {
      _returnNotifier.value = !_returnNotifier.value;
    });
    /*
    _stockPositionNotifier.addListener(() {
      _returnNotifier.value = !_returnNotifier.value;
    });


    Future.delayed(Duration(milliseconds: 500), () {
      String dateStart = '31 Desc 2019';
      int totalAsset = 450000000;
      int portfolioValue = 250000000;
      int cash = 200000000;
      int capitalFund = 250000000; // modal setor
      int cashIn = 270000000;
      int cashOut = 20000000;
      int totalProfit = 200000000;
      double totalProfitPercentage = 80.0;
      int realizedProfit = 125000000;
      int unrealizedProfit = 65000000;
      int interestProfit = 10000000;
      PortfolioSummary ps = PortfolioSummary(dateStart, totalAsset, portfolioValue, cash, capitalFund, cashIn, cashOut, totalProfit,
          totalProfitPercentage, realizedProfit, unrealizedProfit, interestProfit);
      _portfolioSummaryNotifier.value = ps;

      // ReturnData dataMovers = ReturnData();
      // dataMovers.datas.add(Return('28/01/2021', 3000000, 1.96));
      // dataMovers.datas.add(Return('27/01/2021', -3000000, -1.96));
      // dataMovers.datas.add(Return('26/01/2021', 3000000, 1.96));
      // dataMovers.datas.add(Return('25/01/2021', -3000000, -1.96));
      // dataMovers.datas.add(Return('24/01/2021', 3000000, 1.96));
      // dataMovers.datas.add(Return('23/01/2021', -3000000, -1.96));
      // dataMovers.datas.add(Return('22/01/2021', 3000000, 1.96));
      // dataMovers.datas.add(Return('21/01/2021', -3000000, -1.96));
      // dataMovers.datas.add(Return('20/01/2021', -3000000, -1.96));
      // dataMovers.datas.add(Return('19/01/2021', 3000000, 1.96));
      // _returnDataNotifier.setValue(dataMovers);
    });

     */
  }

  VoidCallback? _activeAccountChangedListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_activeAccountChangedListener != null) {
      context
          .read(accountChangeNotifier)
          .removeListener(_activeAccountChangedListener!);
    } else {
      _activeAccountChangedListener = () {
        if (mounted) {
          bool hasAccount =
              context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          if (hasAccount) {
            //_accountNotifier.value = !_accountNotifier.value;
            doUpdate(pullToRefresh: true);
          }
        }
      };
    }
    context
        .read(accountChangeNotifier)
        .addListener(_activeAccountChangedListener!);
  }

  @override
  void dispose() {
    _buttonReturnNotifier.dispose();
    // _portfolioSummaryNotifier.dispose();
    // _stockPositionNotifier.dispose();
    _returnNotifier.dispose();

    final container = ProviderContainer();
    if (_activeAccountChangedListener != null) {
      container
          .read(accountChangeNotifier)
          .removeListener(_activeAccountChangedListener!);
    }

    super.dispose();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
  }
}

class ReturnInfo {
  String? code = '';
  //String timeRange = '';
  //double percentChange = 0.0;
  //int change = 0;
  double value = 0.0;
  //ReturnInfo(this.code, this.timeRange, this.percentChange, this.change);
  ReturnInfo(this.code, this.value);
}
