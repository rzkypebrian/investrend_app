import 'dart:async';
import 'dart:io';

import 'package:Investrend/component/button_banner_open_account.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/widget_buying_power.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/help/screen_help.dart';
import 'package:Investrend/screens/screen_change_password.dart';
import 'package:Investrend/screens/screen_change_pin.dart';
import 'package:Investrend/screens/screen_content.dart';
import 'package:Investrend/screens/tab_portfolio/component/bottom_sheet_list.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_locker/flutter_locker.dart';

class ScreenSettings extends StatefulWidget {
  const ScreenSettings({Key key}) : super(key: key);

  @override
  _ScreenSettingsState createState() => _ScreenSettingsState();
}

const PROP_SELECTED_AUTO_SCROLL = 'auto_scroll_index';

const PROP_SELECTED_PIN_TIMEOUT = 'pin_timeout_index';
const ROUTE_SETTINGS = '/settings';
enum TradingTimeoutDuration {
  FiveMinutes,
  TenMinutes,
  FifteenMinutes,
  TwentyMinutes,
  ThirtyMinutes,
  OneHour
}

extension TradingTimeoutDurationExtension on TradingTimeoutDuration {
  String get text {
    switch (this) {
      case TradingTimeoutDuration.FiveMinutes:
        return 'settings_timeout_5_minutes'.tr();
      case TradingTimeoutDuration.TenMinutes:
        return 'settings_timeout_10_minutes'.tr();
      case TradingTimeoutDuration.FifteenMinutes:
        return 'settings_timeout_15_minutes'.tr();
      case TradingTimeoutDuration.TwentyMinutes:
        return 'settings_timeout_20_minutes'.tr();
      case TradingTimeoutDuration.ThirtyMinutes:
        return 'settings_timeout_30_minutes'.tr();
      case TradingTimeoutDuration.OneHour:
        return 'settings_timeout_1_hour'.tr();
      default:
        return '#unknown_tradingtimeout';
    }
  }

  int get inMinutes {
    switch (this) {
      case TradingTimeoutDuration.FiveMinutes:
        return 5;
      case TradingTimeoutDuration.TenMinutes:
        return 10;
      case TradingTimeoutDuration.FifteenMinutes:
        return 15;
      case TradingTimeoutDuration.TwentyMinutes:
        return 20;
      case TradingTimeoutDuration.ThirtyMinutes:
        return 30;
      case TradingTimeoutDuration.OneHour:
        return 60;
      default:
        return 60;
    }
  }
}

extension ThemeModeExtension on ThemeMode {
  String get text {
    switch (this) {
      case ThemeMode.system:
        //return 'AUTO';
        return 'settings_auto'.tr();
      case ThemeMode.light:
        //return 'LIGHT';
        return 'settings_light'.tr();
      case ThemeMode.dark:
        //return 'DARK';
        return 'settings_dark'.tr();
      default:
        return '#unknown_thememode';
    }
  }
}

class _ScreenSettingsState extends BaseStateNoTabs<ScreenSettings> {
  //_ScreenSettingsState() : super('/settings');
  _ScreenSettingsState() : super(ROUTE_SETTINGS);

  ValueNotifier<String> versionNotifier = ValueNotifier<String>(' ');
  ValueNotifier<int> themeNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> languageNotifier = ValueNotifier<int>(0);
  ValueNotifier<String> reloadAccountNotifier = ValueNotifier<String>(' ');
  ValueNotifier<bool> _accountNotifier = ValueNotifier<bool>(false);
  ValueNotifier<int> timeoutNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> loginMethodNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> autoScrollNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> changePasswordNotifier = ValueNotifier<int>(3);

  /*
  List<String> modesText = [
    'settings_auto'.tr(),
    'settings_dark'.tr(),
    'settings_light'.tr()
  ];

  List<String> modesParameter = [
    'AUTO',
    'DARK',
    'LIGHT'
  ];
  */
  List<String> timeoutsText = List.empty(growable: true);
  List<String> modesText = List.empty(growable: true);
  List<String> languageText = ['Indonesia', 'English'];
  List<String> loginMethodText = ['Password Auth', 'Biometric Auth'];

  List<String> autoScrollText = ['off_label'.tr(), 'on_label'.tr()];

  @override
  void dispose() {
    reloadAccountNotifier.dispose();
    themeNotifier.dispose();
    timeoutNotifier.dispose();
    languageNotifier.dispose();
    loginMethodNotifier.dispose();
    versionNotifier.dispose();
    _accountNotifier.dispose();
    autoScrollNotifier.dispose();
    final container = ProviderContainer();
    if (onAccountChange != null) {
      container.read(accountChangeNotifier).removeListener(onAccountChange);
    }
    if (onAccountData != null) {
      container.read(accountsInfosNotifier).removeListener(onAccountData);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    runPostFrame(() async {
      reloadAccountNotifier.value =
          context.read(dataHolderChangeNotifier).user.accountSize().toString() +
              ' ' +
              'accounts_lobel'.tr();

      int indexLanguage = 0;
      if (StringUtils.equalsIgnoreCase(
          EasyLocalization.of(context).locale.languageCode, 'EN')) {
        indexLanguage = 1;
      }
      languageNotifier.value = indexLanguage;

      languageNotifier.addListener(() {
        if (languageNotifier.value == 0) {
          EasyLocalization.of(context).setLocale(Locale('id'));
        } else {
          EasyLocalization.of(context).setLocale(Locale('en'));
        }
      });

      //TODO : BIOMETRIC AUTHENTICATION

      final pref = await SharedPreferences.getInstance();
      loginMethodNotifier.value =
          pref.getBool('use_biometrics') == true ? 1 : 0;

      loginMethodNotifier.addListener(() async {
        if (loginMethodNotifier.value == 0) {
          pref.setBool('use_biometrics', false);
        } else {
          pref.setBool('use_biometrics', true);
        }
      });

      int autoScroll = context
          .read(propertiesNotifier)
          .properties
          .getInt(routeName, PROP_SELECTED_AUTO_SCROLL, 0);
      autoScrollNotifier.value = autoScroll;
      autoScrollNotifier.addListener(() {
        int index = autoScrollNotifier.value;
        print('autoScrollNotifier changed : ' +
            index.toString() +
            '  ' +
            autoScrollText.elementAt(index));
        context.read(propertiesNotifier).properties.saveInt(
            routeName, PROP_SELECTED_AUTO_SCROLL, autoScrollNotifier.value);
      });
    });
    modesText.clear();
    int countTheme = ThemeMode.values.length;
    for (int i = 0; i < countTheme; i++) {
      modesText.add(ThemeMode.values.elementAt(i).text);
    }

    timeoutsText.clear();
    int countTimeout = TradingTimeoutDuration.values.length;
    for (int i = 0; i < countTimeout; i++) {
      timeoutsText.add(TradingTimeoutDuration.values.elementAt(i).text);
    }

    // modesText.add(ThemeMode.values.elementAt(0).text);
    // modesText.add(ThemeMode.values.elementAt(1).text);
    // modesText.add(ThemeMode.values.elementAt(2).text);

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      versionNotifier.value = 'v' + version + ' ' + buildNumber;
    });

    //updateAccountCashPosition(context);

    themeNotifier.addListener(() {
      print('themeNotifier changed : ' + themeNotifier.value.toString());
      context.read(themeModeNotifier).setIndex(themeNotifier.value);
      saveTheme(themeNotifier.value);
    });

    timeoutNotifier.addListener(() {
      int index = timeoutNotifier.value;
      print('timeoutNotifier changed : ' +
          index.toString() +
          '  ' +
          TradingTimeoutDuration.values.elementAt(index).text);
      context
          .read(propertiesNotifier)
          .properties
          .saveInt(routeName, PROP_SELECTED_PIN_TIMEOUT, timeoutNotifier.value);
    });
  }

  VoidCallback onAccountChange;
  VoidCallback onAccountData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (onAccountChange != null) {
      context.read(accountChangeNotifier).removeListener(onAccountChange);
    } else {
      onAccountChange = () {
        if (mounted) {
          _accountNotifier.value = !_accountNotifier.value;
          //doUpdate();
          updateAccountCashPosition(context);
        }
      };
    }
    context.read(accountChangeNotifier).addListener(onAccountChange);

    if (onAccountData != null) {
      context.read(accountsInfosNotifier).removeListener(onAccountData);
    } else {
      onAccountData = () {
        if (mounted) {
          _accountNotifier.value = !_accountNotifier.value;
        }
      };
    }
    context.read(accountsInfosNotifier).addListener(onAccountData);

    themeNotifier.value = context.read(themeModeNotifier).index;
    /* move to initState
    themeNotifier.addListener(() {
      print('themeNotifier changed : '+themeNotifier.value.toString());
      context.read(themeModeNotifier).setIndex(themeNotifier.value);
      saveTheme(themeNotifier.value);
    });
    */

    int pinTimeoutIndex = context.read(propertiesNotifier).properties.getInt(
        routeName,
        PROP_SELECTED_PIN_TIMEOUT,
        TradingTimeoutDuration.FifteenMinutes.index);
    if (pinTimeoutIndex < 0 ||
        pinTimeoutIndex >= TradingTimeoutDuration.values.length) {
      pinTimeoutIndex = 0; //reset ke 0
      context
          .read(propertiesNotifier)
          .properties
          .saveInt(routeName, PROP_SELECTED_PIN_TIMEOUT, pinTimeoutIndex);
    }
    timeoutNotifier.value = pinTimeoutIndex;
  }

  Future<bool> saveTheme(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool saved = await prefs.setInt('theme_mode', index);
    return saved;
  }

  @override
  Widget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: elevation,
      shadowColor: shadowColor,
      //title: AppBarTitleText('settings'.tr().toUpperCase()),
      title: Text(
        'settings'.tr().toUpperCase(),
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        FocusScope.of(context).requestFocus(new FocusNode());
        Navigator.pop(context);
      }),
    );
  }

  Widget dividerWithPadding() {
    return Padding(
        padding: const EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral),
        child: ComponentCreator.divider(context));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hasAccount
              ? createCardPortfolio(context)
              : Container(
                  margin: EdgeInsets.only(
                      top: InvestrendTheme.cardPaddingVertical,
                      bottom: InvestrendTheme.cardPaddingVertical,
                      left: InvestrendTheme.cardPaddingGeneral,
                      right: InvestrendTheme.cardPaddingGeneral),
                  child: BannerOpenAccount()),
          ComponentCreator.divider(context),
          //SizedBox(height: InvestrendTheme.cardPaddingVertical,),

          ValueListenableBuilder(
            valueListenable: languageNotifier,
            builder: (context, value, child) {
              return createRowSetting(
                context,
                'settings_language'.tr(),
                'images/icons/settings_language.png',
                () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0)),
                      ),
                      //backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ListBottomSheet(languageNotifier, languageText);
                      });
                },
                labelRight: languageText.elementAt(value),
                alwaysShowIcon: true,
              );
            },
          ),

          dividerWithPadding(),
          ValueListenableBuilder(
            valueListenable: themeNotifier,
            builder: (context, value, child) {
              return createRowSetting(context, 'settings_ui_mode'.tr(),
                  'images/icons/settings_darklight.png', () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0)),
                    ),
                    //backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return ListBottomSheet(themeNotifier, modesText);
                    });
              }, labelRight: modesText.elementAt(value), alwaysShowIcon: true);
            },
          ),

          dividerWithPadding(),
          ValueListenableBuilder(
              valueListenable: loginMethodNotifier,
              builder: (context, value, child) {
                return createRowSetting(
                  context,
                  'settings_login_method'.tr(),
                  'images/icons/settings_timer.png',
                  () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ListBottomSheet(
                              loginMethodNotifier, loginMethodText);
                        });
                  },
                  labelRight: loginMethodText.elementAt(value),
                  alwaysShowIcon: true,
                );
              }),

          dividerWithPadding(),
          ValueListenableBuilder(
            valueListenable: timeoutNotifier,
            builder: (context, value, child) {
              return createRowSetting(context, 'settings_timeout'.tr(),
                  'images/icons/settings_timer.png', () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0)),
                    ),
                    //backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return ListBottomSheet(timeoutNotifier, timeoutsText);
                    });
              },
                  labelRight: timeoutsText.elementAt(value),
                  alwaysShowIcon: true);
            },
          ),

          dividerWithPadding(),
          ValueListenableBuilder(
            valueListenable: autoScrollNotifier,
            builder: (context, value, child) {
              return createRowSetting(context, 'settings_auto_scroll'.tr(),
                  'images/icons/settings_auto_scroll.png', () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0)),
                    ),
                    //backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return ListBottomSheet(
                        autoScrollNotifier,
                        autoScrollText,
                        information: 'settings_auto_scroll_information'.tr(),
                      );
                    });
              },
                  labelRight: autoScrollText.elementAt(value),
                  alwaysShowIcon: true);
            },
          ),

          dividerWithPadding(),
          ValueListenableBuilder(
            valueListenable: reloadAccountNotifier,
            builder: (context, value, child) {
              return createRowSetting(context, 'settings_refresh_accounts'.tr(),
                  'images/icons/settings_refresh_accounts.png', () async {
                Token token = Token('', '');
                bool hasToken = false;
                try {
                  bool tok = await token.load();
                  hasToken = !StringUtils.isEmtpy(token.access_token) &&
                      !StringUtils.isEmtpy(token.refresh_token);
                  print(routeName + ' Token.load hasToken : $hasToken');
                  InvestrendTheme.of(context).showSnackBar(
                      context, 'loading_refreshing_accounts'.tr());
                  refreshToken(token.refresh_token);
                } catch (e) {
                  print(routeName + ' Token.load error : ' + e.toString());
                  print(e);
                }
              }, labelRight: value ?? '-');
            },
          ),

          dividerWithPadding(),
          createRowSetting(context, 'settings_change_password_pin'.tr(),
              'images/icons/settings_change_password.png', () {
            changePasswordNotifier.value = 3;
            Future result = showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return ListBottomSheet(
                    changePasswordNotifier,
                    [
                      'settings_change_password'.tr(),
                      'settings_change_pin'.tr()
                    ],
                    clickAndClose: true,
                  );
                });
            result.then((value) {
              if (value is int) {
                if (value == 0) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ScreenChangePassword(),
                        settings: RouteSettings(name: '/change_password'),
                      ));
                } else if (value == 1) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ScreenChangePin(),
                        settings: RouteSettings(name: '/change_pin'),
                      ));
                }
              }
            });
          }),
          /*
          dividerWithPadding(),
          createRowSetting(context, 'settings_change_pin'.tr(), 'images/icons/settings_change_pin.png', () {
            Navigator.push(context, CupertinoPageRoute(
              builder: (_) => ScreenChangePin(), settings: RouteSettings(name: '/change_pin'),));
          }),

          dividerWithPadding(),
          createRowSetting(context, 'settings_change_password'.tr(), 'images/icons/settings_change_password.png', () {
            Navigator.push(context, CupertinoPageRoute(
              builder: (_) => ScreenChangePassword(), settings: RouteSettings(name: '/change_password'),));
          }),
          */

          dividerWithPadding(),
          createRowSetting(
              context, 'settings_help'.tr(), 'images/icons/settings_help.png',
              () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenHelp(),
                  settings: RouteSettings(name: '/help'),
                ));
          }),
          dividerWithPadding(),
          createRowSetting(
              context, 'settings_tnc'.tr(), 'images/icons/settings_tnc.png',
              () {
            String content = 'tnc_content'.tr();
            String applicationName =
                InvestrendTheme.of(context).applicationName;
            content = content.replaceAll('<APP_NAME/>', applicationName);
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
          dividerWithPadding(),
          createRowSetting(context, 'settings_contact_us'.tr(),
              'images/icons/settings_call_us.png', () async {
            String phone = '0212793 8800';
            String phoneParam = 'tel://$phone';
            if (Platform.isIOS) {
              phoneParam = 'tel:$phone';
            }
            try {
              await canLaunch(phoneParam)
                  ? await launch(phoneParam)
                  : throw 'Could not launch call ' + phone;
            } catch (error) {
              InvestrendTheme.of(context)
                  .showSnackBar(context, error.toString());
            }
          }),
          /*
          dividerWithPadding(),
          createRowSetting(context, 'settings_privacy_policy'.tr(), 'images/icons/settings_privacy.png', () {
            String content = 'privacy_policy_content'.tr();
            String applicationName = InvestrendTheme.of(context).applicationName;
            content = content.replaceAll('<APP_NAME/>', applicationName);
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
          */

          dividerWithPadding(),
          createRowSetting(context, 'settings_about_us'.tr(),
              'images/icons/settings_about_us.png', () {}),

          /* di HIDE dulu, belum munculin sosmed untuk test launch
          dividerWithPadding(),
          createRowSetting(context, 'settings_connect_friends'.tr(), 'images/icons/settings_friends.png', () {}),
          */

          ComponentCreator.divider(context),

          createRowSetting(context, 'settings_rate_us'.tr(),
              'images/icons/settings_rating.png', () {},
              labelRight: ' '),
          dividerWithPadding(),
          ValueListenableBuilder(
            valueListenable: versionNotifier,
            builder: (context, value, child) {
              return createRowSetting(
                  context,
                  'settings_application_version'.tr(),
                  'images/icons/settings_version.png',
                  () {},
                  labelRight: value);
              //return activeReturn(context, indexSelected);
            },
          ),

          ComponentCreator.divider(context),
          createRowSetting(
              context, 'settings_exit'.tr(), 'images/icons/settings_exit.png',
              () {
            InvestrendTheme.tradingHttp.logout(
                InvestrendTheme.of(context).applicationPlatform,
                InvestrendTheme.of(context).applicationVersion);
            InvestrendTheme.of(context).logoutToLoginScreen(context);
          }, labelRight: ' '),
          SizedBox(
            height: 20.0,
          ),

          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                color: Color(0xFF4B25CE),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {},
                      child: Image.asset(
                        'images/banner_margin.png',
                        fit: BoxFit.fitWidth,
                      )),
                ),
              ),
            ),
          ),
          SizedBox(
            height: paddingBottom,
          ),
          //IconButton(onPressed: (){}, icon: Image.asset('images/banner_margin.png'),),
        ],
      ),
    );
  }

  Widget createRowSetting(
      BuildContext context, String label, String iconLeft, VoidCallback onPress,
      {String labelRight, bool alwaysShowIcon = false}) {
    List<Widget> rows = List.empty(growable: true);
    rows.add(Image.asset(
      iconLeft,
      color: InvestrendTheme.of(context).settingsColor,
      width: 20.0,
      height: 20.0,
    ));
    rows.add(SizedBox(
      width: InvestrendTheme.cardPaddingGeneral,
    ));
    rows.add(Expanded(
        flex: 1,
        child: Text(label,
            style: InvestrendTheme.of(context)
                .regular_w400_compact
                .copyWith(color: InvestrendTheme.of(context).settingsColor))));

    if (!StringUtils.isEmtpy(labelRight)) {
      rows.add(Text(labelRight,
          style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
                color: InvestrendTheme.of(context).settingsColor,
              )));
      if (alwaysShowIcon) {
        rows.add(Padding(
          padding:
              const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral),
          child: Image.asset(
            'images/icons/settings_arrow_right.png',
            color: InvestrendTheme.of(context).settingsColor,
            width: 10.0,
            height: 10.0,
          ),
        ));
      }
    } else {
      rows.add(Image.asset(
        'images/icons/settings_arrow_right.png',
        color: InvestrendTheme.of(context).settingsColor,
        width: 10.0,
        height: 10.0,
      ));
    }

    /*
    Widget rightWidget = null;
    if(StringUtils.isEmtpy(labelRight)){
      rightWidget = Image.asset(
        'images/icons/settings_arrow_right.png',
        color: InvestrendTheme.of(context).settingsColor,
        width: 10.0,
        height: 10.0,
      );
    }else{
      rightWidget = Text(labelRight, style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor,));
    }
     */
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPress,
        child: Padding(
          padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              top: 15.0,
              bottom: 15.0),
          child: Row(
            children: rows,
            /*
            children: [
              Image.asset(
                iconLeft,
                color: InvestrendTheme.of(context).settingsColor,
                width: 20.0,
                height: 20.0,
              ),
              SizedBox(width: InvestrendTheme.cardPaddingPlusMargin,),
              Expanded(
                  flex: 1,
                  child: Text(label,
                      style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).settingsColor))),
              rightWidget,
            ],
            */
          ),
        ),
      ),
    );
  }

  Widget createCardPortfolio(BuildContext context) {
    // double moneyAccount = 200005956;
    // double gainLossMoneyAccount = 30000000;
    // double gainLossPercentageAccount = 14.58;
    // double buyingPower = 200200000780;
    return Container(
      margin: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentCreator.subtitle(context, 'portfolio_card_title'.tr()),
          SizedBox(
            height: InvestrendTheme.cardPaddingGeneral,
          ),
          /*
          Text(
            InvestrendTheme.formatMoneyDouble(moneyAccount),
            style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            InvestrendTheme.formatMoneyDouble(gainLossMoneyAccount, prefixPlus: true) +
                ' (' +
                InvestrendTheme.formatPercentChange(gainLossPercentageAccount) +
                ')',
            style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.changeTextColor(gainLossPercentageAccount)),
          ),
          */
          ValueListenableBuilder(
            valueListenable: _accountNotifier,
            builder: (context, data, child) {
              User user = context.read(dataHolderChangeNotifier).user;
              Account activeAccount =
                  user.getAccount(context.read(accountChangeNotifier).index);
              String portfolioValue = ' - ';
              String portfolioGainLoss = ' - ';
              String portfolioGainLossPercentage = ' - ';
              int gainLossIDR = 0;
              bool hasData = false;
              if (activeAccount != null) {
                AccountStockPosition accountInfo = context
                    .read(accountsInfosNotifier)
                    .getInfo(activeAccount.accountcode);
                if (accountInfo != null) {
                  gainLossIDR = accountInfo.totalGL;
                  portfolioValue = InvestrendTheme.formatMoney(
                      accountInfo.totalMarket,
                      prefixRp: true);
                  portfolioGainLoss = InvestrendTheme.formatMoney(
                          accountInfo.totalGL,
                          prefixRp: true) +
                      ' (' +
                      InvestrendTheme.formatPercentChange(
                          accountInfo.totalGLPct,
                          sufixPercent: true) +
                      ')';
                  hasData = true;
                }
              }
              if (hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portfolioValue, //InvestrendTheme.formatMoneyDouble(moneyAccount),
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      portfolioGainLoss,
                      style: InvestrendTheme.of(context).small_w400.copyWith(
                          color: InvestrendTheme.priceTextColor(gainLossIDR)),
                    ),
                  ],
                );
              } else {
                return Container(
                    width: double.maxFinite,
                    height: 40.0,
                    child: Center(child: EmptyLabel()));
              }
            },
          ),
          SizedBox(
            height: InvestrendTheme.cardPaddingVertical,
          ),
          WidgetBuyingPower(),
          // SizedBox(
          //   height: InvestrendTheme.cardPaddingVertical,
          // ),
        ],
      ),
    );
  }

  @override
  void onActive() {
    // TODO: implement onActive
    updateAccountCashPosition(context);
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  void refreshToken(String refreshToken) {
    //showLoading('loading_refresh_token_label'.tr());

    // final result = InvestrendTheme.tradingHttp.refresh(
    //     InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
    //     refresh_token: refresh_token, device: 'website');
    final result = InvestrendTheme.tradingHttp.refresh(
        'website', InvestrendTheme.of(context).applicationVersion,
        refresh_token: refreshToken);

    result.then((value) {
      //loadingNotifier.value = true;
      //_loadingNotifier.closeLoading();
      print('refresh--------------------');
      print('username = ' + value.username);
      print('realname = ' + value.realname);
      print('feepct = ' + value.feepct.toString());
      print('lotsize = ' + value.lotsize.toString());
      print('access_token = ' + value.token.access_token);
      print('refresh_token = ' + value.token.refresh_token);
      print('accounts.length = ' + value.accounts.length.toString());

      print('b_ip = ' + value.b_ip);
      print('b_multi = ' + value.b_multi.length.toString());
      print('b_pass = ' + value.b_pass);
      print('b_port = ' + value.b_port.toString());
      print('r_ip = ' + value.r_ip);
      print('r_multi = ' + value.r_multi.length.toString());
      print('r_port = ' + value.r_port.toString());

      context.read(dataHolderChangeNotifier).user.update(
          value.username,
          value.realname,
          value.feepct,
          value.lotsize,
          value.accounts,
          value.token,
          value.message,
          value.email,
          value.b_ip,
          value.b_multi,
          value.b_pass,
          value.b_port,
          value.r_ip,
          value.r_multi,
          value.r_port);
      print(context.read(dataHolderChangeNotifier).user.toString());

      String urlProfile = 'https://' +
          InvestrendTheme.tradingHttp.tradingBaseUrl +
          '/getpic?username=' +
          value.username +
          '&url=&nocache=' +
          DateTime.now().toString();
      context.read(avatarChangeNotifier).setUrl(urlProfile);
      context.read(accountChangeNotifier).setIndex(0);
      reloadAccountNotifier.value =
          value.accounts.length.toString() + ' ' + 'accounts_lobel'.tr();

      String info = 'finished_refreshing_accounts'.tr();
      info = info.replaceFirst('#NO#', value.accounts.length.toString());
      InvestrendTheme.of(context).showSnackBar(context, info);
    }).onError((error, stackTrace) {
      //_loadingNotifier.closeLoading();
      //closeLoading();
      print(error);
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      /*
      if(error is TradingHttpException){
        if(error.isUnauthorized()){
          InvestrendTheme.of(context).showDialogInvalidSession(context, onClosePressed: (){
            Navigator.pop(context);
          });
        }else{
          String network_error_label = 'network_error_label'.tr();
          network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, network_error_label);
        }
      }else{
        InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
      */

      Future.delayed(Duration(milliseconds: 700), () {
        if (error is TradingHttpException) {
          if (error.isUnauthorized()) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
          } else if (error.isErrorTrading()) {
            InvestrendTheme.of(context).showSnackBar(context, error.message());
          } else {
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel =
                networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context)
                .showSnackBar(context, networkErrorLabel);
          }
        } else if (error is TimeoutException) {
          String networkErrorTimeOutLabel = 'network_error_time_out_label'.tr();
          InvestrendTheme.of(context)
              .showSnackBar(context, networkErrorTimeOutLabel);
        } else {
          InvestrendTheme.of(context).showSnackBar(context, error.toString());
        }
      });
    });
  }
}
