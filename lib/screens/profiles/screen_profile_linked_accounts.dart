// ignore_for_file: unused_local_variable

import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';

class ScreenProfileLinkedAccounts extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  ScreenProfileLinkedAccounts(this.tabIndex, this.tabController, {Key? key})
      : super(key: key);

  @override
  _ScreenProfileLinkedAccountsState createState() =>
      _ScreenProfileLinkedAccountsState(tabIndex, tabController);
}

class _ScreenProfileLinkedAccountsState
    extends BaseStateNoTabsWithParentTab<ScreenProfileLinkedAccounts> {
  // final SlidableController slidableController = SlidableController();
  // //PortfolioNotifier _portfolioNotifier = PortfolioNotifier(new PortfolioData());
  // StockPositionNotifier _stockPositionNotifier = StockPositionNotifier(new StockPosition('', 0, 0, 0, 0, 0, 0, List.empty(growable: true)));
  //final ValueNotifier<bool> _updateListNotifier = ValueNotifier<bool>(false);
  // Map summarys = new Map();

  final ValueNotifier<int> _selectedListNotifier = ValueNotifier<int>(0);

  // bool canTapRow = true;
  _ScreenProfileLinkedAccountsState(int tabIndex, TabController tabController)
      : super('/profile_linked_accounts', tabIndex, tabController,
            parentTabIndex: Tabs.Portfolio.index);

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  void onChanged(StockPositionDetail stockPD, bool value) {}

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (!hasAccount) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
          child: EmptyLabel(
            text: 'no_account_found_message'.tr(),
          ),
        ),
      );
    }
    return ValueListenableBuilder(
      valueListenable: _selectedListNotifier,
      builder: (context, value, child) {
        int itemCount =
            context.read(dataHolderChangeNotifier).user.accountSize();

        return ListView.builder(
            controller: pScrollController,
            shrinkWrap: false,
            padding: EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingVertical,
                bottom: InvestrendTheme.cardPaddingVertical),
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) {
              Account? account =
                  context.read(dataHolderChangeNotifier).user.getAccount(index);
              return createCardAccount(context, account!, index, value as int);
            });
      },
    );
  }

  static final Color colorReguler = Color(0xFFB399D4);
  static final Color colorMargin = Color(0xFFFF6D6A);

  static final Color colorRegulerDetail = Color(0xFFebe6f2);
  static final Color colorMarginDetail = Color(0xFFf0cac9);

  Widget rowDetail(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: InvestrendTheme.of(context)
                .support_w400_compact
                ?.copyWith(color: InvestrendTheme.blackTextColor),
          ),
          Expanded(
              flex: 1,
              child: Text(
                value,
                style: InvestrendTheme.of(context)
                    .support_w600_compact
                    ?.copyWith(color: InvestrendTheme.blackTextColor),
                textAlign: TextAlign.right,
              ))
        ],
      ),
    );
  }

  Widget createCardAccount(BuildContext context, Account account,
      final int itemIndex, int selectedIndex) {
    Color cardColor = StringUtils.equalsIgnoreCase(account.type, 'R')
        ? colorReguler
        : (StringUtils.equalsIgnoreCase(account.type, 'M')
            ? colorMargin
            : Color(0xFFffd085));

    Color cardColorDetail = StringUtils.equalsIgnoreCase(account.type, 'R')
        ? colorRegulerDetail
        : (StringUtils.equalsIgnoreCase(account.type, 'M')
            ? colorMarginDetail
            : Color(0xFFfaf1e3));

    String accountType = StringUtils.equalsIgnoreCase(account.type, 'R')
        ? 'Regular'
        : (StringUtils.equalsIgnoreCase(account.type, 'M')
            ? 'Margin'
            : account.type);
    TextStyle? styleTitle = InvestrendTheme.of(context)
        .medium_w400_compact
        ?.copyWith(color: InvestrendTheme.of(context).textWhite);
    TextStyle? styleTitle600 = InvestrendTheme.of(context)
        .medium_w600_compact
        ?.copyWith(color: InvestrendTheme.of(context).textWhite);
    TextStyle? styleReguler = InvestrendTheme.of(context)
        .regular_w500_compact
        ?.copyWith(color: InvestrendTheme.of(context).textWhite);
    TextStyle? styleReguler600 = InvestrendTheme.of(context)
        .regular_w600_compact
        ?.copyWith(color: InvestrendTheme.of(context).textWhite);

    TextStyle? styleSupport = InvestrendTheme.of(context)
        .support_w400_compact
        ?.copyWith(color: InvestrendTheme.of(context).textWhite);
    TextStyle? styleSupport600 = InvestrendTheme.of(context)
        .support_w600_compact
        ?.copyWith(color: InvestrendTheme.of(context).textWhite);

    Widget bottom;
    if (itemIndex == selectedIndex) {
      bottom = Container(
        //color: Colors.white,
        margin: EdgeInsets.only(top: InvestrendTheme.cardPadding),
        padding: EdgeInsets.all(InvestrendTheme.cardPadding),
        decoration: BoxDecoration(
          color: cardColorDetail, //Theme.of(context).backgroundColor,
          border: Border.all(width: 1.0, color: cardColor),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rowDetail(context, 'email'.tr(), account.email),
            rowDetail(context, 'SID', account.sid),
            rowDetail(context, 'sub_account_label'.tr(), account.subrek),

            //SizedBox(height: InvestrendTheme.cardPadding,),
            Padding(
              padding: const EdgeInsets.only(
                  top: InvestrendTheme.cardPadding, bottom: 4.0),
              child: Text(
                'RDN',
                style: InvestrendTheme.of(context)
                    .small_w600_compact
                    ?.copyWith(color: InvestrendTheme.blackTextColor),
              ),
            ),
            rowDetail(context, 'Bank', account.bank),
            rowDetail(context, 'No', account.acc_no),

            rowDetail(context, 'Name', account.acc_name),
          ],
        ),
      );
    } else {
      bottom = Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: TextButton(
          onPressed: () {
            _selectedListNotifier.value = itemIndex;
          },
          child: Text('button_view_detail'.tr()),
        ),
      );
    }

    return Container(
      // duration: Duration(milliseconds: 2000),
      // curve: Curves.bounceIn,
      //padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding, top: InvestrendTheme.cardPadding),
      margin: EdgeInsets.only(bottom: InvestrendTheme.cardPaddingVertical),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(width: 1.0, color: cardColor),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: InvestrendTheme.cardPadding,
                right: InvestrendTheme.cardPadding,
                top: InvestrendTheme.cardPadding),
            child: Row(
              children: [
                Image.asset(
                  'images/icons/ic_launcher_white.png',
                  height: 35.0,
                  width: 35.0,
                ),
                Text(
                  account.accountcode,
                  style: styleReguler600,
                  maxLines: 1,
                ),
                Spacer(
                  flex: 1,
                ),
                Text(
                  accountType,
                  style: styleReguler,
                  maxLines: 1,
                ),
                SizedBox(
                  width: 10.0,
                ),
              ],
            ),
          ),
          Container(
            //height: 50.0,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
                left: InvestrendTheme.cardPadding + 10.0,
                right: InvestrendTheme.cardPadding + 10.0),
            child: Text(
              account.acc_name,
              style: styleTitle,
            ),
          ),

          /*
          Container(
            height: 50.0,
            padding: EdgeInsets.only(left: InvestrendTheme.cardPadding + 10.0, right: InvestrendTheme.cardPadding + 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SID',
                  style: styleReguler,
                ),
                Spacer(
                  flex: 1,
                ),
                Text(
                  account.sid,
                  style: styleTitle600,
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: InvestrendTheme.cardPadding + 10.0, right: InvestrendTheme.cardPadding + 10.0),
            child: Text(
              account.acc_name,
              style: styleSupport,
              maxLines: 1,
            ),
          ),
          */
          /*
          Padding(
            padding: EdgeInsets.only(left: 10.0 , right: 10.0),
            child: TextButton(
              onPressed: () {
                _selectedListNotifier.value = itemIndex;
              },
              child: Text('button_view_detail'.tr()),
            ),
          ),
          */
          bottom,
        ],
      ),
    );
  }

  @override
  void onActive() {
    //print(routeName + ' onActive');
  }

  @override
  void dispose() {
    _selectedListNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void onInactive() {
    //print(routeName + ' onInactive');
  }
}
