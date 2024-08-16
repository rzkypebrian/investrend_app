// ignore_for_file: unused_local_variable

import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/screens/screen_content.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenAgreement extends StatefulWidget {
  const ScreenAgreement({Key? key}) : super(key: key);

  @override
  State<ScreenAgreement> createState() => _ScreenAgreementState();
}

class _ScreenAgreementState extends State<ScreenAgreement> {
  final ValueNotifier<bool> _disclaimerNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _tncNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _privacyNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _disclaimerNotifier.dispose();
    _tncNotifier.dispose();
    _privacyNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    double paddingTop = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      //floatingActionButton: createFloatingActionButton(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        shadowColor: shadowColor,
        elevation: elevation,
        title: AppBarTitleText('agreement_title'.tr()),
        // actions: [
        //   Image.asset(widget.icon, color: Theme.of(context).primaryColor,),
        // ],
        leading: AppBarActionIcon(
          'images/icons/action_back.png',
          () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.of(context).pop();
          },
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      body: ComponentCreator.keyboardHider(
          context, createBody(context, paddingBottom)),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  Widget? createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    if (paddingBottom == 0) {
      paddingBottom = InvestrendTheme.cardPaddingVertical;
    }
    bool lightTheme = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: paddingBottom),
      //child: Text(content, style: InvestrendTheme.of(context).small_w400_greyDarker,),
      child: Column(
        children: [
          Spacer(
            flex: 4,
          ),
          Text(
            'agreement_content'.tr(),
            style: InvestrendTheme.of(context).regular_w400,
            textAlign: TextAlign.center,
          ),
          Spacer(
            flex: 4,
          ),
          // SizedBox(
          //   height: 30.0,
          // ),

          rowAgreement(context, 'settings_tnc'.tr(), _tncNotifier, () {
            print('tnc_content pressed');
            String content = 'tnc_content'.tr();
            String? applicationName =
                InvestrendTheme.of(context).applicationName;
            content = content.replaceAll('<APP_NAME/>', applicationName!);
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenContent(
                    title: 'settings_tnc'.tr(),
                    content: content,
                  ),
                  settings: RouteSettings(name: '/content'),
                ));
          }),
          // SizedBox(
          //   height: 10.0,
          // ),
          rowAgreement(
              context, 'settings_privacy_policy'.tr(), _privacyNotifier, () {
            print('privacy_policy pressed');
            String content = 'privacy_policy_content'.tr();
            String? applicationName =
                InvestrendTheme.of(context).applicationName;
            content = content.replaceAll('<APP_NAME/>', applicationName!);
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenContent(
                    title: 'settings_privacy_policy'.tr(),
                    content: content,
                  ),
                  settings: RouteSettings(name: '/content'),
                ));
          }),
          // SizedBox(
          //   height: 10.0,
          // ),
          rowAgreement(context, 'settings_disclaimer'.tr(), _disclaimerNotifier,
              () {
            print('disclaimer pressed');
            String content = 'disclaimers_content'.tr();
            String? applicationName =
                InvestrendTheme.of(context).applicationName;
            content = content.replaceAll('<APP_NAME/>', applicationName!);
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenContent(
                    title: 'settings_disclaimer'.tr(),
                    content: content,
                  ),
                  settings: RouteSettings(name: '/content'),
                ));
          }),
          // Spacer(flex: 1,),

          SizedBox(
            height: 50.0,
          ),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: ComponentCreator.roundedButton(
                context,
                'agreement_button_accept'.tr(),
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary, () {
              // on presss
              if (_tncNotifier.value &&
                  _privacyNotifier.value &&
                  _disclaimerNotifier.value) {
                Navigator.of(context).pop('AGREE');
              } else {
                InvestrendTheme.of(context)
                    .showSnackBar(context, 'agreement_error'.tr());
              }
            }),
          ),
          // SizedBox(
          //   height: paddingBottom,
          // ),
        ],
      ),
    );
  }

  void showMainPage(BuildContext context) {
    InvestrendTheme.showMainPage(context, ScreenTransition.Fade);
  }

  Widget rowAgreement(BuildContext context, String buttonText,
      ValueNotifier<bool> notifier, VoidCallback onPressed) {
    return Row(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (context, value, child) {
            return Checkbox(
                activeColor: Theme.of(context).colorScheme.secondary,
                value: notifier.value,
                onChanged: (value) {
                  notifier.value = !notifier.value;
                  //print('remember '+_rememeberMeNotifier.value+' $value');
                });
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: InvestrendTheme.of(context).hyperlink,
              animationDuration: Duration(milliseconds: 500),
              backgroundColor: Colors.transparent,
              textStyle:
                  InvestrendTheme.of(context).small_w400_compact_greyDarker),
          child: Text(buttonText),
          onPressed: onPressed,
        ),
      ],
    );
  }
}
