// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:Investrend/component/animation_creator.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/message.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/persistent_data.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/screen_finder.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/screens/screen_login_pin.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail.dart';
import 'package:Investrend/screens/trade/screen_trade.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:package_info/package_info.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:device_info_plus/device_info_plus.dart';

extension StringCasingExtension on String {
  String toCapitalized() => this.length > 0
      ? '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}'
      : '';
//String get toTitleCase() => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.toCapitalized()).join(" ");
}

class InvestrendTheme extends InheritedWidget {
  static final bool DEBUG = false; // matiin timer, refresh manual
  static final bool CHECK_INVITATION = true;
  static final bool FAST_ORDER = true;
  static final bool LOOP_SPLIT = false;

  //static final HttpServices httpServices = HttpServices();
  // static List<Broker> listBroker = List<Broker>.empty(growable: true);
  // static List<Stock> listStock = List<Stock>.empty(growable: true);
  // static List<Index> listIndex = List<Index>.empty(growable: true);
  //static MD5StockBrokerIndex md5stockBrokerIndex =  MD5StockBrokerIndex('', '', '', 1, '', '', '');
  static TradingHttp tradingHttp = TradingHttp();
  static HttpIII datafeedHttp = HttpIII();
  //static SosMedHttp sosMedHttp = SosMedHttp();

  //User user = User('', '', 0.0, 1, null, null);
  static StoredData? storedData = StoredData();
  static const double cardPadding = 8.0;
  static const double cardMargin = 8.0;
  static const double cardPaddingGeneral = 12.0;
  static const double cardPaddingVertical = 20.0;

  static final int MAX_WATCHLIST_NAME_CHARACTER =
      20; // panjang nama watchlist nya
  static const int MAX_WATCHLIST = 20;
  static const int MAX_STOCK_PER_WATCHLIST = 30;

  static final Color foreignColor = Color(0xFFEEA356);

  static final Color buyColor = Color(0xFF5414DB);
  static final Color sellColor = Color(0xFFE50449);
  static final Color cancelColor = Color(0xFFE50449);
  static final Color attentionColor = Color(0xFFEEA356);

  static final Color buyTextColor = Color(0xFF25B792);
  static final Color sellTextColor = Color(0xFFE50449);

  static final Color blackTextColor =
      Color(0xFF010000); // tidak ganti mesti theme dark light berubah

  final Color _greyLighterTextColorLightTheme = Color(0xFF8C979F);
  final Color _greyLighterTextColorDarkTheme = Color(0xFFA8B0B5);
  Color? greyLighterTextColor;

  final Color _greyDarkerTextColorLightTheme = Color(0xFF394B55);
  final Color _greyDarkerTextColorDarkTheme = Color(0xFF8C979F);
  Color? greyDarkerTextColor;

  final Color _settingsColorLightTheme = Color(0xFF394B55);
  final Color _settingsColorDarkTheme = Color(0xFFEBEBEB); // 0xFFFAFAFA
  Color? settingsColor;

  final Color _greyIconColorLightTheme = Color(0xFFACACAC);
  final Color _greyIconColorDarkTheme = Color(0xFFACACAC);
  Color? greyIconColor;

  final Color _oddColorLightTheme = Color(0xFFF4F2F9);
  final Color _oddColorDarkTheme = Color(0xFF1B1A1D);
  Color? oddColor;

  //Stock stock;
  // StockNotifier stockNotifier = StockNotifier(null);
  // StockSummaryNotifier summaryNotifier = StockSummaryNotifier(null, null);
  // OrderBookNotifier orderbookNotifier = OrderBookNotifier(null, null);
  // TradeBookNotifier tradebookNotifier = TradeBookNotifier(null, null);

  TextStyle? textValueStyle;
  TextStyle? textLabelStyle;

  final Color _colorSoftLight = Color(0xFFF5F0FF);
  final Color _colorSoftDark = Color(0xFFF5F0FF);
  Color? colorSoft;

  final Color _chipBorderLight = Color(0xFFEAE9EC);
  final Color _chipBorderDark = Colors.white24; // need to define
  Color? chipBorder;

  final Color _pollBackgroundLight = Colors.white;
  final Color _pollBackgroundDark = Color(0xFF1B1A1D); // need to define
  Color? pollBackground;

  /*
  final Color _pollProgressLight = Color(0xFFE6DEF6);
  final Color _pollProgressDark = Color(0xFFE6DEF6); // need to define
  Color pollProgress;
  */
  final Color pollProgress = Color(0xFFE6DEF6);

  final Color _hyperlinkLight = Color(0xFF5414db);
  final Color _hyperlinkDark = Color(0xFF5414db); // need to define
  Color? hyperlink;

  // final String _ic_launcherLight = "images/icons/ic_launcher.png";
  // final String _ic_launcherDark = "images/icons/ic_launcher_inverted.png";

  final String _ic_launcherLight = "images/icons/icon_name_black.png";
  final String _ic_launcherDark = "images/icons/icon_name_white.png";
  String? ic_launcher;

  Color? blackAndWhite;
  Color? blackAndWhiteLite;

  Color? blackAndWhiteText;
  Color? blackAndWhiteTextLite;
  Color? blackAndWhiteTextInactive;
  final Color _investrendPurpleLight = Color(0xFF5414DB);
  final Color _investrendPurpleDark = Color(0xFF5414DB);
  Color? investrendPurple;

  final Color _investrendPurpleTextLight = Color(0xFF5414DB);
  final Color _investrendPurpleTextDark = Color(0xFFb49afc);
  Color? investrendPurpleText;

  static final Color _textWhiteLight = Color(0xFFFAFAFA);
  static final Color _textWhiteDark = Color(0xFFEBEBEB);
  Color? textWhite; // = Color(0xFFFAFAFA);

  static final Color greenText = Color(0xFF25B792); //Color(0xFF25B792);
  static final Color greenBackground = Color(0xFFBFF5EB); //Color(0xFFB3F3E8);

  static final Color redText = Color(0xFFE50449);
  static final Color redBackground = Color(0xFFF1CACC);

  static final Color yellowText = Color(0xFFFAA043);
  static final Color yellowBackground = Color(0xFFFEE7D0);

  Color? tileBackground;
  final Color _tileBackgroundLight = Color(0xFFF2F0F8);
  //final Color _tileBackgroundDark = Color(0xFF1A191B);
  final Color _tileBackgroundDark = Color(0xFF222124);

  Color? accelerationBackground;
  final Color _accelerationBackgroundLight = Color(0xFFF2F0F8);
  final Color _accelerationBackgroundDark = Color(0xFF222124);

  Color? accelerationTextColor;
  final Color _accelerationTextLight = Color(0xFF5414DB);
  final Color _accelerationTextDark = Color(0xFFb49afc);

  Color? tileBorder;
  final Color _tileBorderLight = Color(0xFFEAE6F6);
  final Color _tileBorderDark = Color(0xFF353436);

  Color? tileSplashColor;
  final Color _tileSplashColorLight = Color(0xFF9e86d1);

  //final Color _tileBackgroundDark = Colors.black26; // need to define
  final Color _tileSplashColorDark = Color(0xFF5414db);

  //static final double appBarTabPaddingTopBottom = 0.0;
  static final double appBarTabHeight =
      46.0; // + appBarTabPaddingTopBottom + appBarTabPaddingTopBottom ;
  static final double appBarHeight = 40.0;

  //const double _kTabHeight = 46.0;
  //const double _kTextAndIconTabHeight = 72.0;

  final Color _appBarActionTextColorLight = Color(0xFF394B55);
  final Color _appBarActionTextColorDark = Color(0xFFF4F2F9);
  Color? appBarActionTextColor;

  final Color whiteColor = Color(0xFFF4F2F9);

  final double tileRoundedRadius = 20.0;
  final double tileSmallRoundedRadius = 10.0;

  static final EdgeInsets paddingTab =
      EdgeInsets.symmetric(horizontal: cardPaddingGeneral);

  TextStyle? headline3;
  TextStyle? regular_w400;
  TextStyle? regular_w500;
  TextStyle? regular_w600;

  TextStyle? regular_w400_compact;
  TextStyle? regular_w500_compact;
  TextStyle? regular_w600_compact;

  TextStyle? regular_w400_greyDarker;
  TextStyle? regular_w500_greyDarker;
  TextStyle? regular_w600_greyDarker;

  TextStyle? regular_w400_compact_greyDarker;
  TextStyle? regular_w500_compact_greyDarker;
  TextStyle? regular_w600_compact_greyDarker;

  TextStyle? medium_w400;
  TextStyle? medium_w500;
  TextStyle? medium_w600;

  TextStyle? medium_w400_compact;
  TextStyle? medium_w500_compact;
  TextStyle? medium_w600_compact;

  TextStyle? small_w600;
  TextStyle? small_w500;
  TextStyle? small_w400;

  TextStyle? small_w600_compact;
  TextStyle? small_w500_compact;
  TextStyle? small_w400_compact;

  TextStyle? small_w600_greyDarker;
  TextStyle? small_w500_greyDarker;
  TextStyle? small_w400_greyDarker;

  TextStyle? small_w600_compact_greyDarker;
  TextStyle? small_w500_compact_greyDarker;
  TextStyle? small_w400_compact_greyDarker;

  TextStyle? support_w600;
  TextStyle? support_w500;
  TextStyle? support_w400;
  TextStyle? more_support_w600;
  TextStyle? more_support_w500;
  TextStyle? more_support_w400;

  TextStyle? support_w600_compact;
  TextStyle? support_w500_compact;
  TextStyle? support_w400_compact;

  TextStyle? support_w600_compact_greyDarker;
  TextStyle? support_w500_compact_greyDarker;
  TextStyle? support_w400_compact_greyDarker;

  TextStyle? support_w600_compact_greyLighter;
  TextStyle? support_w500_compact_greyLighter;
  TextStyle? support_w400_compact_greyLighter;

  TextStyle? more_support_w600_compact;
  TextStyle? more_support_w500_compact;
  TextStyle? more_support_w400_compact;

  TextStyle? more_support_w600_compact_greyDarker;
  TextStyle? more_support_w500_compact_greyDarker;
  TextStyle? more_support_w400_compact_greyDarker;

  TextStyle? inputLabelStyle;
  TextStyle? inputHintStyle;
  TextStyle? inputHelperStyle;
  TextStyle? inputPrefixStyle;
  TextStyle? inputStyle;
  TextStyle? inputErrorStyle;

  String? applicationName = '';
  String? applicationVersion = '';
  String? applicationBuild = '';
  String? applicationPlatform = 'Mobile';
  // String applicationDeviceType = 'Mobile';

  InvestrendTheme({BuildContext? context, Widget? child, Key? key})
      : super(child: child!, key: key) {
    print('InvestrendTheme created ' + DateTime.now().toString());
    constructTheme(context!);
  }

  // void platformInfo() async{
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
  //     applicationDeviceType = androidInfo.model;
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     print('Running on ${iosInfo.utsname.machine}');
  //     applicationDeviceType = iosInfo.utsname.machine;
  //   }
  //   print('platformInfo  applicationDeviceType : $applicationDeviceType ');
  // }
  void constructTheme(BuildContext context) {
    print('InvestrendTheme constructTheme ' + DateTime.now().toString());
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    //bool lightTheme = MediaQuery.of(context).platformBrightness == Brightness.light;
    print('InvestrendTheme constructTheme lightTheme : $lightTheme');
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      print(
          'PackageInfo.fromPlatform  appName : $appName  packageName : $packageName  version : $version  buildNumber : $buildNumber  ');
      //flutter: PackageInfo.fromPlatform  appName : Investrend  packageName : com.investrend.afs.investrendApp  version : 1.0.0  buildNumber : 1
      applicationName = appName;
      applicationVersion = version;
      applicationBuild = buildNumber;
      applicationPlatform =
          Platform.isIOS ? 'iOS' : (Platform.isAndroid ? 'Android' : 'Other');

      // platformInfo();
    });

    hyperlink = lightTheme ? _hyperlinkLight : _hyperlinkDark;
    ic_launcher = lightTheme ? _ic_launcherLight : _ic_launcherDark;

    pollBackground = lightTheme ? _pollBackgroundLight : _pollBackgroundDark;

    blackAndWhite = lightTheme ? Colors.white : Colors.black;
    blackAndWhiteLite = lightTheme ? Colors.white54 : Colors.black54;

    blackAndWhiteText =
        lightTheme ? Color(0xFF010000) : Color(0xFFEBEBEB); //FAFAFA
    blackAndWhiteTextLite = lightTheme ? Colors.black87 : Colors.white70;
    blackAndWhiteTextInactive = lightTheme ? Colors.black45 : Colors.white54;

    tileBackground = lightTheme ? _tileBackgroundLight : _tileBackgroundDark;
    tileSplashColor = lightTheme ? _tileSplashColorLight : _tileSplashColorDark;
    tileBorder = lightTheme ? _tileBorderLight : _tileBorderDark;

    accelerationBackground =
        lightTheme ? _accelerationBackgroundLight : _accelerationBackgroundDark;
    accelerationTextColor =
        lightTheme ? _accelerationTextLight : _accelerationTextDark;

    investrendPurple =
        lightTheme ? _investrendPurpleLight : _investrendPurpleDark;
    greyLighterTextColor = lightTheme
        ? _greyLighterTextColorLightTheme
        : _greyLighterTextColorDarkTheme;

    chipBorder = lightTheme ? _chipBorderLight : _chipBorderDark;
    colorSoft = lightTheme ? _colorSoftLight : _colorSoftDark;

    headline3 = Theme.of(context).textTheme.displaySmall;

    medium_w600 = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontSize: 20.0, fontWeight: FontWeight.w600);
    medium_w500 = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontSize: 20.0, fontWeight: FontWeight.w500);
    medium_w400 = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontSize: 20.0, fontWeight: FontWeight.w400);

    regular_w600 = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w600);
    regular_w500 = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w500);
    regular_w400 = Theme.of(context).textTheme.bodyLarge;

    small_w600 = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w600);
    small_w500 = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w500);
    small_w400 = Theme.of(context).textTheme.bodyMedium;

    support_w600 = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(fontWeight: FontWeight.w600);
    support_w500 = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(fontWeight: FontWeight.w500);
    support_w400 = Theme.of(context).textTheme.bodySmall;

    more_support_w600 = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(fontWeight: FontWeight.w600);
    more_support_w500 = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(fontWeight: FontWeight.w500);
    more_support_w400 = Theme.of(context).textTheme.labelSmall;

    regular_w400_compact = regular_w400?.copyWith(height: 1.0);
    regular_w500_compact = regular_w500?.copyWith(height: 1.0);
    regular_w600_compact = regular_w600?.copyWith(height: 1.0);
    medium_w400_compact = medium_w400?.copyWith(height: 1.0);
    medium_w500_compact = medium_w500?.copyWith(height: 1.0);
    medium_w600_compact = medium_w600?.copyWith(height: 1.0);
    small_w600_compact = small_w600?.copyWith(height: 1.0);
    small_w500_compact = small_w500?.copyWith(height: 1.0);
    small_w400_compact = small_w400?.copyWith(height: 1.0);
    support_w600_compact = support_w600?.copyWith(height: 1.0);
    support_w500_compact = support_w500?.copyWith(height: 1.0);
    support_w400_compact = support_w400?.copyWith(height: 1.0);

    more_support_w600_compact = more_support_w600?.copyWith(height: 1.0);
    more_support_w500_compact = more_support_w500?.copyWith(height: 1.0);
    more_support_w400_compact = more_support_w400?.copyWith(height: 1.0);

    inputLabelStyle = support_w400?.copyWith(height: 0.1);
    inputHintStyle = small_w400?.copyWith(color: greyLighterTextColor);
    inputHelperStyle = support_w400?.copyWith(color: greyLighterTextColor);
    inputPrefixStyle = small_w400;
    inputStyle = small_w400;
    inputErrorStyle =
        support_w400?.copyWith(color: Theme.of(context).colorScheme.error);

    appBarActionTextColor =
        lightTheme ? _appBarActionTextColorLight : _appBarActionTextColorDark;
    greyDarkerTextColor = lightTheme
        ? _greyDarkerTextColorLightTheme
        : _greyDarkerTextColorDarkTheme;
    greyIconColor =
        lightTheme ? _greyIconColorLightTheme : _greyIconColorDarkTheme;

    // textValueStyle = Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.w400);
    // textLabelStyle = Theme.of(context).textTheme.bodyText2.copyWith(color: greyLighterTextColor, fontWeight: FontWeight.w300);

    textValueStyle = support_w400;
    textLabelStyle = support_w400?.copyWith(color: greyLighterTextColor);

    oddColor = lightTheme ? _oddColorLightTheme : _oddColorDarkTheme;

    settingsColor =
        lightTheme ? _settingsColorLightTheme : _settingsColorDarkTheme;

    textWhite = lightTheme ? _textWhiteLight : _textWhiteDark;

    investrendPurpleText =
        lightTheme ? _investrendPurpleTextLight : _investrendPurpleTextDark;

    small_w600_greyDarker = small_w600?.copyWith(color: greyDarkerTextColor);
    small_w500_greyDarker = small_w500?.copyWith(color: greyDarkerTextColor);
    small_w400_greyDarker = small_w400?.copyWith(color: greyDarkerTextColor);

    small_w600_compact_greyDarker =
        small_w600?.copyWith(height: 1.0, color: greyDarkerTextColor);
    small_w500_compact_greyDarker =
        small_w500?.copyWith(height: 1.0, color: greyDarkerTextColor);
    small_w400_compact_greyDarker =
        small_w400?.copyWith(height: 1.0, color: greyDarkerTextColor);

    regular_w400_greyDarker =
        regular_w400?.copyWith(color: greyDarkerTextColor);
    regular_w500_greyDarker =
        regular_w500?.copyWith(color: greyDarkerTextColor);
    regular_w600_greyDarker =
        regular_w600?.copyWith(color: greyDarkerTextColor);

    regular_w400_compact_greyDarker =
        regular_w400?.copyWith(height: 1.0, color: greyDarkerTextColor);
    regular_w500_compact_greyDarker =
        regular_w500?.copyWith(height: 1.0, color: greyDarkerTextColor);
    regular_w600_compact_greyDarker =
        regular_w600?.copyWith(height: 1.0, color: greyDarkerTextColor);

    more_support_w600_compact_greyDarker =
        more_support_w600_compact?.copyWith(color: greyDarkerTextColor);
    more_support_w500_compact_greyDarker =
        more_support_w500_compact?.copyWith(color: greyDarkerTextColor);
    more_support_w400_compact_greyDarker =
        more_support_w400_compact?.copyWith(color: greyDarkerTextColor);

    support_w600_compact_greyDarker =
        support_w600_compact?.copyWith(color: greyDarkerTextColor);
    support_w500_compact_greyDarker =
        support_w500_compact?.copyWith(color: greyDarkerTextColor);
    support_w400_compact_greyDarker =
        support_w400_compact?.copyWith(color: greyDarkerTextColor);

    support_w600_compact_greyLighter =
        support_w600_compact?.copyWith(color: greyLighterTextColor);
    support_w500_compact_greyLighter =
        support_w500_compact?.copyWith(color: greyLighterTextColor);
    support_w400_compact_greyLighter =
        support_w400_compact?.copyWith(color: greyLighterTextColor);
  }

  static Color darkenColor(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lightenColor(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  double _bottomVoidSpace = 0.0;

  double bottomVoidSpace() {
    if (Platform.isAndroid) {
      // Android-specific code
    } else if (Platform.isIOS) {
      // iOS-specific code
      _bottomVoidSpace = 30.0;
    }
    return _bottomVoidSpace;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static Future<dynamic> showFinderScreen(BuildContext context,
      {bool showStockOnly = false,
      String? watchlistName,
      List<Stock>? fromListStocks}) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation1, animation2) => ScreenFinder(
          showStockOnly: showStockOnly,
          watchlistName: watchlistName,
          fromListStocks: fromListStocks,
        ),
        settings: RouteSettings(name: '/finder'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimationCreator.transitionSlideUp(
              context, animation, secondaryAnimation, child);
        },
      ),
    );

    // return Navigator.push(context, CupertinoPageRoute(
    //   builder: (_) => ScreenFinder(), settings: RouteSettings(name: '/finder'),));
  }

  void showStockDetail(BuildContext context) {
    //InvestrendTheme.push(context, ScreenStockDetail(), ScreenTransition.SlideLeft, '/stock_detail');

    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ScreenStockDetail(),
          settings: RouteSettings(name: '/stock_detail'),
        ));

    /*
    Navigator.push(
      context,
      PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 1000),
          pageBuilder: (context, animation1, animation2) => ScreenStockDetail(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimationCreator.transitionSlideLeft(
                context, animation, secondaryAnimation, child);
          }),
    );

     */
  }

  static Color changeTextColor(double? value, {double? prev = 0.0}) {
    if (prev == 0.0) {
      if (value! > 0.0) {
        return greenText;
      } else if (value < 0.0) {
        return redText;
      } else {
        return yellowText;
      }
    } else {
      if (value! > prev!) {
        return greenText;
      } else if (value < prev) {
        return redText;
      } else {
        return yellowText;
      }
    }
  }

  static Color? priceTextColor(int? value, {int? prev = 0}) {
    if (prev == 0) {
      if (value! > 0) {
        return greenText;
      } else if (value < 0) {
        return redText;
      } else {
        return yellowText;
      }
    } else {
      if (value! > prev!) {
        return greenText;
      } else if (value < prev) {
        return redText;
      } else {
        return yellowText;
      }
    }
  }

  /* buat DEBUG
  static Color priceTextColor(int value, {int prev = 0, String caller}) {

    if (prev == 0) {
      if (value > 0) {
        if(caller != null)
          print('priceTextColor  price : $value  prev : $prev   Green  $caller');
        return greenText;
      } else if (value < 0) {
        if(caller != null)
          print('priceTextColor  price : $value  prev : $prev   Red  $caller');
        return redText;
      } else {
        if(caller != null)
          print('priceTextColor  price : $value  prev : $prev   Yellow  $caller');
        return yellowText;
      }
    } else {
      if (value > prev) {
        if(caller != null)
          print('priceTextColor  price : $value  prev : $prev   Green  $caller');
        return greenText;
      } else if (value < prev) {
        if(caller != null)
          print('priceTextColor  price : $value  prev : $prev   Red  $caller');
        return redText;
      } else {
        if(caller != null)
          print('priceTextColor  price : $value  prev : $prev   Yellow  $caller');
        return yellowText;
      }
    }
  }

   */

  static Color priceBackgroundColorDouble(double? value, {double prev = 0.0}) {
    if (prev == 0) {
      if (value! > 0.0) {
        return greenBackground;
      } else if (value < 0.0) {
        return redBackground;
      } else {
        return yellowBackground;
      }
    } else {
      if (value! > prev) {
        return greenBackground;
      } else if (value < prev) {
        return redBackground;
      } else {
        return yellowBackground;
      }
    }
  }

  static Color priceBackgroundColor(int value, {int prev = 0}) {
    if (prev == 0) {
      if (value > 0) {
        return greenBackground;
      } else if (value < 0) {
        return redBackground;
      } else {
        return yellowBackground;
      }
    } else {
      if (value > prev) {
        return greenBackground;
      } else if (value < prev) {
        return redBackground;
      } else {
        return yellowBackground;
      }
    }
  }

  static String formatPrice(int? price) {
    return _formatterNumber.format(price);
  }

  static String formatComma(int? number) {
    return _formatterNumber.format(number);
  }

  static String formatNewComma(double number) {
    int frontValue = number.truncate();
    String text = number.toString();
    int index = text.indexOf('.');
    String endText = '';
    if (index > 0) {
      endText = text.substring(index + 1);
      if (Utils.safeInt(endText) == 0) {
        endText = '';
      } else {
        endText = '.' + endText;
      }
    }
    String frontText = formatComma(frontValue);
    return frontText + endText;
  }

  static String formatCompact(BuildContext context, int? number) {
    if (number! >= 100000) {
      return InvestrendTheme.formatValue(context, number);
    }
    return _formatterNumber.format(number);
  }

  static String formatCommaDouble(double number) {
    return _formatterNumberDouble.format(number);
  }

  static String formatValue(BuildContext context, int? value) {
    //String text = NumberFormat.compact(locale: 'en_US').format(value);

    String text = NumberFormat.compact(
            locale: EasyLocalization.of(context)?.locale.languageCode)
        .format(value);

    //String text = NumberFormat.compactSimpleCurrency(locale: 'en_US',decimalDigits: 2).format(value);
    String lastCharacter = text[text.length - 1];
    if (lastCharacter == 'M' || lastCharacter == 'B' || lastCharacter == 'T') {
      text = text.substring(0, text.length - 1).trim() + ' ' + lastCharacter;
    }
    return text;
  }

  static String formatValueLong(int value) {
    return NumberFormat.compactLong(locale: 'en_US').format(value);
  }

  static String formatMoneyDouble(double? money,
      {bool prefixPlus = false, bool prefixRp = true, bool decimal = false}) {
    // String prefix = 'Rp ';
    // if (money > 0.0 && prefixPlus) {
    //   prefix = '+ Rp ';
    // }

    String textRP = '';
    if (prefixRp) {
      textRP = 'Rp ';
    }

    String prefix = textRP;
    if (money! > 0.0 && prefixPlus) {
      prefix = '+$textRP';
    } else if (money < 0.0 && prefixPlus) {
      prefix = '-$textRP';
      money = money * -1;
    }
    if (decimal) {
      return prefix + _formatterNumberDouble.format(money);
    } else {
      return prefix + _formatterNumber.format(money);
    }

    /*
    if(money > 0.0 && prefixPlus){
      return "+Rp "+formatterNumber.format(money);
    }else{
      return "Rp "+formatterNumber.format(money);
    }
    */
  }

  static String formatMoney(int? money,
      {bool prefixPlus = false, bool prefixRp = true}) {
    String? prefix = 'Rp ';
    if (money! > 0.0 && prefixPlus) {
      prefix = '+Rp ';
    } else if (money < 0.0 && prefixPlus) {
      prefix = '-Rp ';
      money = money * -1;
    }
    return prefix + _formatterNumber.format(money);
    /*
    if(money > 0.0 && prefixPlus){
      return "+Rp "+formatterNumber.format(money);
    }else{
      return "Rp "+formatterNumber.format(money);
    }
    */
  }

  // static String formatMoneyDouble(double money, {bool prefixPlus: false, bool prefixRp: true}) {
  //   String prefix = 'Rp ';
  //   if (money > 0.0 && prefixPlus) {
  //     prefix = '+ Rp ';
  //   }
  //   return prefix + _formatterNumber.format(money);
  //   /*
  //   if(money > 0.0 && prefixPlus){
  //     return "+Rp "+formatterNumber.format(money);
  //   }else{
  //     return "Rp "+formatterNumber.format(money);
  //   }
  //   */
  // }

  static String formatPriceDouble(double? price,
      {bool? showDecimal = true, bool? threeDecimal = false}) {
    if (showDecimal!) {
      if (threeDecimal!) {
        return _formatterNumberDoubleThreeDecimal.format(price);
      } else {
        return _formatterNumberDouble.format(price);
      }
    } else {
      return _formatterNumber.format(price?.truncate());
    }
  }

  static String formatPercentChange(double? number,
      {bool sufixPercent = true, bool? threeDecimal = false}) {
    String prefix = '';
    String sufix = '';
    //String formmated  = '';
    if (number! > 0.0) {
      prefix = '+';
    }
    if (sufixPercent) {
      sufix = '%';
    }

    //return prefix + _formatterNumberDouble.format(number) + sufix;

    if (threeDecimal!) {
      return prefix + _formatterNumberDoubleThreeDecimal.format(number) + sufix;
    } else {
      return prefix + _formatterNumberDouble.format(number) + sufix;
    }
  }

  static String formatPercent(double? number,
      {bool sufixPercent = true, bool prefixPlus = false}) {
    String prefix = '';
    String sufix = '';
    //String formmated  = '';
    if (number! > 0.0 && prefixPlus) {
      prefix = '+';
    }
    if (sufixPercent) {
      sufix = '%';
    }

    return prefix + _formatterNumberDoubleDecimal.format(number) + sufix;
  }

  static String formatChange(double? number, {bool? threeDecimal = false}) {
    return formatPercentChange(number,
        sufixPercent: false, threeDecimal: threeDecimal);
  }

  static String formatNewPrice(var number, {int decimalValue = 0}) {
    NumberFormat formatter;
    if (decimalValue == 2) {
      formatter = _formatterNumberDoubleDecimal;
    } else if (decimalValue == 3) {
      formatter = _formatterNumberDoubleThreeDecimal;
    } else {
      formatter = _formatterNumber;
      if (number is double) {
        number = number.truncate();
      }
    }

    //String prefix = '';
    //String sufix = '';

    // if(number is double){
    //   if (number > 0.0) {
    //     prefix = '+';
    //   }
    // }else if(number is int){
    //   if (number > 0) {
    //     prefix = '+';
    //   }
    // }

    // return prefix + formatter.format(number) ;
    return formatter.format(number);
  }

  static String formatNewChange(var number, {int decimalValue = 0}) {
    NumberFormat formatter;
    if (decimalValue == 2) {
      formatter = _formatterNumberDoubleDecimal;
    } else if (decimalValue == 3) {
      formatter = _formatterNumberDoubleThreeDecimal;
    } else {
      formatter = _formatterNumber;
      if (number is double) {
        number = number.truncate();
      }
    }

    String prefix = '';
    //String sufix = '';

    if (number is double) {
      if (number > 0.0) {
        prefix = '+';
      }
    } else if (number is int) {
      if (number > 0) {
        prefix = '+';
      }
    }

    return prefix + formatter.format(number);
  }

  static String formatNewPercentChange(var number, {int decimalValue = 2}) {
    NumberFormat formatter;
    if (decimalValue == 2) {
      formatter = _formatterNumberDoubleDecimal;
    } else if (decimalValue == 3) {
      formatter = _formatterNumberDoubleThreeDecimal;
    } else {
      formatter = _formatterNumber;
      if (number is double) {
        number = number.truncate();
      }
    }

    String prefix = '';
    String sufix = '%';

    if (number is double) {
      if (number > 0.0) {
        prefix = '+';
      }
    } else if (number is int) {
      if (number > 0) {
        prefix = '+';
      }
    }

    return prefix + formatter.format(number) + sufix;
  }

  // static Icon getChangeIcon(double change) {
  //   if (change > 0.0) {
  //     return Icon(
  //       Image.asset('images/icons/price_up.png'),
  //       color: greenText,
  //     );
  //   } else if (change < 0.0) {
  //     return Icon(
  //       Image.asset('images/icons/price_down.png'),
  //       color: redText,
  //     );
  //   } else {
  //     return Icon(
  //       Image.asset('images/icons/price_no_changes.png'),
  //       color: yellowText,
  //     );
  //   }
  // }
  static Image getChangeImage(double change, {double size = 15.0}) {
    //const size = 15.0;
    if (change > 0.0) {
      return Image.asset(
        'images/icons/price_up.png',
        width: size,
        height: size,
      );
    } else if (change < 0.0) {
      return Image.asset(
        'images/icons/price_down.png',
        width: size,
        height: size,
      );
    } else {
      return Image.asset(
        'images/icons/price_no_changes.png',
        width: size,
        height: size,
        color: Colors.transparent,
      );
    }
  }

  static Image getChangeImageInt(int change, {double size = 15.0}) {
    //const size = 15.0;
    if (change > 0.0) {
      return Image.asset(
        'images/icons/price_up.png',
        width: size,
        height: size,
      );
    } else if (change < 0.0) {
      return Image.asset(
        'images/icons/price_down.png',
        width: size,
        height: size,
      );
    } else {
      return Image.asset(
        'images/icons/price_no_changes.png',
        width: size,
        height: size,
      );
    }
  }

  static final NumberFormat _formatterNumberDoubleDecimal =
      NumberFormat("#,##0.##", 'en_US'); //"id"
  static final NumberFormat _formatterNumberDouble =
      NumberFormat("#,##0.00", 'en_US'); //"id"
  static final NumberFormat _formatterNumber =
      NumberFormat("#,###", 'en_US'); //"id"

  static final NumberFormat _formatterNumberDoubleThreeDecimal =
      NumberFormat("#,##0.000", 'en_US'); //"id"

  static InvestrendTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InvestrendTheme>()!;

  Future showDialogTooltips(
      BuildContext context, String title, String content) {
    bool showYes = true;
    String buttonYes = 'button_ok'.tr();
    VoidCallback onPressedYes = () {
      Navigator.of(context).pop();
    };
    List<Widget> listActions = List.empty(growable: true);

    if (showYes) {
      listActions.add(TextButton(
        child: Text(
          buttonYes,
          style: InvestrendTheme.of(context)
              .small_w600_compact
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        onPressed: onPressedYes,
      ));
    }

    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(
                title,
                style: InvestrendTheme.of(context)
                    .regular_w600_compact
                    ?.copyWith(fontSize: 19.0),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  content,
                  style: InvestrendTheme.of(context).small_w400?.copyWith(
                      color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
              ),
              actions: listActions,
            ));
  }

  Future showDialogPlatform(BuildContext context, String title, String content,
      {String? buttonYes,
      String? buttonNo,
      VoidCallback? onPressedYes,
      VoidCallback? onPressedNo}) {
    bool showYes = !StringUtils.isEmtpy(buttonYes);
    bool showNo = !StringUtils.isEmtpy(buttonNo);
    if (!showYes && !showNo) {
      showYes = true;
      buttonYes = 'button_close'.tr();
      onPressedYes = () {
        Navigator.of(context).pop();
      };
    }
    List<Widget> listActions = List.empty(growable: true);
    if (Platform.isIOS) {
      // iOS-specific code
      if (showYes) {
        listActions.add(CupertinoDialogAction(
          child: Text(buttonYes!),
          onPressed: onPressedYes,
        ));
      }
      if (showNo) {
        listActions.add(CupertinoDialogAction(
          child: Text(buttonNo!),
          isDestructiveAction: true,
          onPressed: onPressedNo,
        ));
      }

      return showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text(
                  title,
                  style: InvestrendTheme.of(context).small_w600,
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    content,
                    style: InvestrendTheme.of(context).support_w400?.copyWith(
                        color: InvestrendTheme.of(context).greyDarkerTextColor),
                  ),
                ),
                actions: listActions,
              ));
    } else {
      if (showYes) {
        listActions.add(TextButton(
          child: Text(
            buttonYes!,
            style: InvestrendTheme.of(context).small_w500_compact,
          ),
          onPressed: onPressedYes,
        ));
      }
      if (showNo) {
        listActions.add(TextButton(
          child: Text(
            buttonNo!,
            style: InvestrendTheme.of(context)
                .small_w500_compact
                ?.copyWith(color: InvestrendTheme.redText),
          ),
          onPressed: onPressedNo,
        ));
      }

      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text(
                  title,
                  style: InvestrendTheme.of(context).small_w600,
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    content,
                    style: InvestrendTheme.of(context).support_w400?.copyWith(
                        color: InvestrendTheme.of(context).greyDarkerTextColor),
                  ),
                ),
                actions: listActions,
              ));
    }
  }

  Future? showDialogInputPlatform(
      BuildContext context, TextEditingController controller, String title,
      {String? buttonYes,
      String? buttonNo,
      VoidCallback? onPressedYes,
      VoidCallback? onPressedNo,
      int? maxInputLength}) {
    bool showYes = !StringUtils.isEmtpy(buttonYes);
    bool showNo = !StringUtils.isEmtpy(buttonNo);
    if (!showYes && !showNo) {
      showYes = true;
      buttonYes = 'button_close'.tr();
      onPressedYes = () {
        Navigator.of(context).pop();
      };
    }
    List<Widget> listActions = List.empty(growable: true);
    if (Platform.isIOS) {
      // iOS-specific code
      if (showYes) {
        listActions.add(CupertinoDialogAction(
          child: Text(buttonYes!),
          onPressed: onPressedYes,
        ));
      }
      if (showNo) {
        listActions.add(CupertinoDialogAction(
          child: Text(buttonNo!),
          isDestructiveAction: true,
          onPressed: onPressedNo,
        ));
      }
      return showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text(title),
                content: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CupertinoTextField(
                      controller: controller,
                      maxLength: maxInputLength,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      //TextStyle(color: InvestrendTheme.of(context).blackAndWhiteText)
                      style: InvestrendTheme.of(context).small_w400_compact,
                      cursorColor: Theme.of(context).colorScheme.secondary),
                ),
                actions: listActions,
              ));
    } else {
      if (showYes) {
        listActions.add(TextButton(
          child: Text(
            buttonYes!,
            style: InvestrendTheme.of(context).small_w500_compact,
          ),
          onPressed: onPressedYes,
        ));
      }
      if (showNo) {
        listActions.add(TextButton(
          child: Text(
            buttonNo!,
            style: InvestrendTheme.of(context)
                .small_w500_compact
                ?.copyWith(color: InvestrendTheme.redText),
          ),
          onPressed: onPressedNo,
        ));
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text(title),
                  content: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      maxLength: maxInputLength,
                      //style: TextStyle(color: InvestrendTheme.of(context).blackAndWhiteText),
                      style: InvestrendTheme.of(context).small_w400_compact,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  actions: listActions,
                ));
      }
    }
    return null;
  }

  Future<void> showInfoDialog(BuildContext context,
      {String title = 'Info',
      String content = '',
      VoidCallback? onClose}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: InvestrendTheme.of(context).small_w400_compact,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('button_close'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
                if (onClose != null) {
                  onClose();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showSnackBar(BuildContext context, String? text,
      {VoidCallback? buttonOnPress,
      String? buttonLabel,
      Color? buttonColor,
      int seconds = 2}) {
    SnackBarAction? button;
    if (!StringUtils.isEmtpy(buttonLabel)) {
      button = SnackBarAction(
        label: buttonLabel!,
        onPressed: buttonOnPress!,
        textColor: buttonColor ?? Theme.of(context).colorScheme.secondary,
      );
    }
    final snackBar = SnackBar(
      content: Text(text!),
      duration: Duration(seconds: seconds),
      action: button,
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSnackBarPushMessage(BuildContext context, BaseMessage message) {
    SnackBarAction button = SnackBarAction(
      label: 'button_view'.tr(),
      onPressed: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenMessage(
                baseMessage: message,
              ),
              settings: RouteSettings(name: '/message'),
            ));
      },
      textColor: Colors.white,
    );

    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      content: SizedBox(
        height: 60.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.fcm_title,
              style: InvestrendTheme.of(context)
                  .small_w500_compact
                  ?.copyWith(color: InvestrendTheme.of(context).textWhite),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(message.fcm_body,
                style: InvestrendTheme.of(context).small_w400_compact?.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      duration: Duration(seconds: 5),
      action: button,
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showMainPage(BuildContext context, ScreenTransition transition) {
    Navigator.popUntil(context, (route) {
      print('popUntil : ' + route.toString());
      // if (StringUtils.equalsIgnoreCase(route?.settings?.name, '/main')) {
      //   return true;
      // }
      return route.isFirst;
    });
    InvestrendTheme.pushReplacement(
        context, ScreenMain(), ScreenTransition.Fade, '/main');
  }

  static void backToScreenMainAndShowTabScreen(
      BuildContext context, Tabs tab, int childTabIndex) {
    Navigator.popUntil(context, (route) {
      print('popUntil : ' + route.toString());
      if (StringUtils.equalsIgnoreCase(route.settings.name, '/main')) {
        return true;
      }
      return route.isFirst;
    });
    //context.read(mainMenuChangeNotifier).setActive(Tabs.Portfolio, TabsTransaction.Intraday.index);
    context.read(mainMenuChangeNotifier).setActive(tab, childTabIndex);
  }

  static void pushReplacement(BuildContext context, Widget screen,
      ScreenTransition transition, String routeName) {
    switch (transition) {
      case ScreenTransition.SlideLeft:
        {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration: Duration(milliseconds: 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideLeft(
                    context, animation, secondaryAnimation, child);
              },
            ),
          );
        }
        break;
      case ScreenTransition.SlideRight:
        {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration: Duration(milliseconds: 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideRight(
                    context, animation, secondaryAnimation, child);
              },
            ),
          );
        }
        break;

      case ScreenTransition.SlideUp:
        {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration: Duration(milliseconds: 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideUp(
                    context, animation, secondaryAnimation, child);
              },
            ),
          );
        }
        break;

      default:
        {
          //Fade
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration: Duration(milliseconds: 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              // transitionsBuilder:
              //     (context, animation, secondaryAnimation, Widget? child) {
              //   return FadeTransition(
              //     opacity: animation,
              //     child: child,
              //   );
              // },
              //     (context, animation, secondaryAnimation, child) =>
              //         FadeTransition(
              //   opacity: animation,
              //   child: child,
              // ),
            ),
          );
        }
        break;
    }
  }

  static Future<dynamic>? pushScreenTrade(BuildContext context, bool hasAccount,
      {OrderType type = OrderType.Buy, PriceLot? initialPriceLot}) {
    //bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (hasAccount) {
      if (context.read(propertiesNotifier).isNeedPinTrading()) {
        Future result = Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenLoginPin(),
              settings: RouteSettings(name: '/login_pin'),
            ));
        result.then((value) {
          if (value is TradingHttpException) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
          } else if (value is String) {
            if (StringUtils.equalsIgnoreCase(value, PIN_SUCCESS)) {
              return Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ScreenTrade(
                      type,
                      initialPriceLot: initialPriceLot,
                    ), //PriceLot(close, 0)
                    settings: RouteSettings(name: '/trade'),
                  ));
            }
          }
        });
      } else {
        return Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenTrade(
                type,
                initialPriceLot: initialPriceLot,
              ), //PriceLot(close, 0)
              settings: RouteSettings(name: '/trade'),
            ));
      }
    } else {
      InvestrendTheme.of(context).showInfoDialog(context,
          title: 'info_label'.tr(), content: 'no_account_found_message'.tr());
    }
    return null;
  }

  static Future<dynamic> push(BuildContext context, Widget screen,
      ScreenTransition transition, String routeName,
      {int? durationMilisecond}) {
    switch (transition) {
      case ScreenTransition.SlideLeft:
        {
          return Navigator.push(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration:
                  Duration(milliseconds: durationMilisecond ?? 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideLeft(
                    context, animation, secondaryAnimation, child);
              },
            ),
          );
        }
      // break;
      case ScreenTransition.SlideRight:
        {
          return Navigator.push(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration:
                  Duration(milliseconds: durationMilisecond ?? 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideRight(
                    context, animation, secondaryAnimation, child);
              },
            ),
          );
        }
      // break;

      case ScreenTransition.SlideUp:
        {
          return Navigator.push(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration:
                  Duration(milliseconds: durationMilisecond ?? 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideUp(
                    context, animation, secondaryAnimation, child);
              },
            ),
          );
        }
      // break;
      case ScreenTransition.SlideDown:
        {
          return Navigator.push(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration:
                  Duration(milliseconds: durationMilisecond ?? 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideDown(
                    context, animation, secondaryAnimation, child);
              },
            ),
          );
        }
      // break;

      default:
        {
          //Fade
          return Navigator.push(
            context,
            PageRouteBuilder(
              settings: RouteSettings(name: routeName),
              transitionDuration:
                  Duration(milliseconds: durationMilisecond ?? 1000),
              pageBuilder: (context, animation1, animation2) => screen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
          );
        }
      // break;
    }
  }

  //@override
  void dispose() {
    print('202104-27 InvestrendTheme.dispose');
    // stockNotifier.dispose();
    // summaryNotifier.dispose();
    // orderbookNotifier.dispose();
    // tradebookNotifier.dispose();
    //super.dispose();
  }

  void logoutToLoginScreen(BuildContext context, {bool clearToken = true}) {
    context.read(dataHolderChangeNotifier).isLogged = false;
    if (clearToken) {
      Token token = Token('', '');
      token.save().whenComplete(() {
        context.read(managerDatafeedNotifier).disconnect(info: 'logout');
        context.read(managerEventNotifier).disconnect(info: 'logout');
        Navigator.popUntil(context, (route) {
          print('popUntil : ' + route.toString());
          return route.isFirst;
        });
        InvestrendTheme.pushReplacement(
            context, ScreenLogin(), ScreenTransition.Fade, '/login');
      });
    } else {
      context.read(managerDatafeedNotifier).disconnect(info: 'logout');
      context.read(managerEventNotifier).disconnect(info: 'logout');
      Navigator.popUntil(context, (route) {
        print('popUntil : ' + route.toString());
        return route.isFirst;
      });
      InvestrendTheme.pushReplacement(
          context,
          ScreenLogin(
            autoLogon: false,
          ),
          ScreenTransition.Fade,
          '/login');
    }
  }

  void showDialogInvalidSession(BuildContext context,
      {VoidCallback? onClosePressed,
      String? message,
      String? title,
      bool checkLogged = true}) {
    if (checkLogged && !context.read(dataHolderChangeNotifier).isLogged) {
      return;
    }

    context.read(dataHolderChangeNotifier).isLogged = false;
    context.read(managerDatafeedNotifier).disconnect(
          info: 'paused',
        );
    context.read(managerEventNotifier).disconnect(
          info: 'paused',
        );
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => new WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(title ?? 'info_label'.tr()),
          content: Text(message ?? 'session_invalid_error_label'.tr(),
              style: InvestrendTheme.of(context).small_w400),
          actions: <Widget>[
            TextButton(
              child: Text(
                'button_close'.tr(),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: onClosePressed ??
                  () {
                    logoutToLoginScreen(context);
                  },
            ),
          ],
        ),
      ),
    );
  }

  void showDialogLogout(BuildContext context,
      {VoidCallback? onClosePressed,
      String? message,
      String? title,
      bool checkLogged = true}) {
    if (checkLogged && !context.read(dataHolderChangeNotifier).isLogged) {
      return;
    }

    context.read(dataHolderChangeNotifier).isLogged = false;
    context.read(managerDatafeedNotifier).disconnect(
          info: 'paused',
        );
    context.read(managerEventNotifier).disconnect(
          info: 'paused',
        );
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => new WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(title ?? 'info_label'.tr()),
          content: Text(message ?? '-',
              style: InvestrendTheme.of(context).small_w400),
          actions: <Widget>[
            TextButton(
              child: Text(
                'button_close'.tr(),
                style: TextStyle(color: Colors.red),
              ),
              onPressed: onClosePressed ??
                  () {
                    logoutToLoginScreen(context, clearToken: false);
                  },
            ),
          ],
        ),
      ),
    );
  }
}

enum ScreenTransition { Fade, SlideUp, SlideLeft, SlideDown, SlideRight }
// class InvestrendCustomTheme {
//   //static Color textfield_labelTextColor(bool light) => light ? Colors.black : Colors.white;
//   static Color friends_bottom_container(bool light) => light ? Colors.white : Colors.black;
// }
