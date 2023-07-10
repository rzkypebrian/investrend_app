import 'package:Investrend/component/button_banner_open_account.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenNoAccount extends StatelessWidget {
  const ScreenNoAccount({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      width: double.maxFinite,
      height: double.maxFinite,
      margin: EdgeInsets.only(
        top: InvestrendTheme.cardPaddingVertical,
        bottom: InvestrendTheme.cardPaddingVertical,
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
      ),
      child: Column(
        children: [
          BannerOpenAccount(),
          SizedBox(
            height: 50,
          ),
          EmptyTitleLabel(
            text: 'no_active_account_found_message'.tr(),
          ),
          SizedBox(
            height: InvestrendTheme.cardPaddingVertical,
          ),
          EmptyLabel(text: 'no_account_found_message_short'.tr()),
        ],
      ),
    );
  }
}
