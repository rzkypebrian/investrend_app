// ignore_for_file: must_be_immutable, unused_element, non_constant_identifier_names

import 'dart:io';
import 'dart:ui';

import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/chart_candlestick.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/message.dart';
import 'package:Investrend/new_component/custom_scroll_behaviour.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screen_test.dart';
import 'package:Investrend/screens/onboarding/screen_friends.dart';
import 'package:Investrend/screens/onboarding/screen_friends_contact.dart';
import 'package:Investrend/screens/onboarding/screen_landing.dart';
import 'package:Investrend/screens/onboarding/screen_landing_rdn.dart';
import 'package:Investrend/screens/screen_agreement.dart';
import 'package:Investrend/screens/tab_community/screen_create_post.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/screens/onboarding/screen_register.dart';
import 'package:Investrend/screens/screen_text_sample.dart';
import 'package:Investrend/screens/stock_detail/screen_stock_detail.dart';
import 'package:Investrend/screens/trade/screen_amend.dart';
import 'package:Investrend/screens/trade/screen_order_detail.dart';
import 'package:Investrend/screens/trade/screen_trade.dart';
import 'package:Investrend/screen_test_image_picker.dart';
import 'package:Investrend/utils/investrend_theme.dart';

import 'package:flutter/material.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/screen_splash.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'component/charts/trading_view_chart.dart';
import 'component/sosmed/leaderboards.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print(
      'firebase AAA _firebaseMessagingBackgroundHandler a background message ${message.messageId}');
  await Firebase.initializeApp();
  print(
      'firebase BBB _firebaseMessagingBackgroundHandler a background message ${message.messageId}');
}

const String fontFamily = 'WorkSans';
//const String fontFamily = 'LobsterTwo';
//const String fontFamily = 'TitilliumWeb';

class MainApplication extends StatefulWidget {
  // This widget is the root of your application.

/* colors dari nugi

light theme

dark theme

Primary: 5414DB
Redbg: F1CACC
Red: E50449
Greenbg: BFF5EB
Green: 25B792
Body: 394B55
Subtle: 8C979F
Dark: 010000
Light: FAFAFA
Accent: F4F2F9
*/

  static final Map<int, Color> colorInvestrendPurple = {
    50: Color.fromRGBO(84, 20, 219, .1),
    100: Color.fromRGBO(84, 20, 219, .2),
    200: Color.fromRGBO(84, 20, 219, .3),
    300: Color.fromRGBO(84, 20, 219, .4),
    400: Color.fromRGBO(84, 20, 219, .5),
    500: Color.fromRGBO(84, 20, 219, .6),
    600: Color.fromRGBO(84, 20, 219, .7),
    700: Color.fromRGBO(84, 20, 219, .8),
    800: Color.fromRGBO(84, 20, 219, .9),
    900: Color.fromRGBO(84, 20, 219, 1),
  };

  static final Map<int, Color> colorInvestrendBlack = {
    50: Color.fromRGBO(26, 26, 26, .1),
    100: Color.fromRGBO(26, 26, 26, .2),
    200: Color.fromRGBO(26, 26, 26, .3),
    300: Color.fromRGBO(26, 26, 26, .4),
    400: Color.fromRGBO(26, 26, 26, .5),
    500: Color.fromRGBO(26, 26, 26, .6),
    600: Color.fromRGBO(26, 26, 26, .7),
    700: Color.fromRGBO(26, 26, 26, .8),
    800: Color.fromRGBO(26, 26, 26, .9),
    900: Color.fromRGBO(26, 26, 26, 1),
  };

  static final Map<int, Color> colorInvestrendWhite = {
    50: Color.fromRGBO(250, 250, 250, .1),
    100: Color.fromRGBO(250, 250, 250, .2),
    200: Color.fromRGBO(250, 250, 250, .3),
    300: Color.fromRGBO(250, 250, 250, .4),
    400: Color.fromRGBO(250, 250, 250, .5),
    500: Color.fromRGBO(250, 250, 250, .6),
    600: Color.fromRGBO(250, 250, 250, .7),
    700: Color.fromRGBO(250, 250, 250, .8),
    800: Color.fromRGBO(250, 250, 250, .9),
    900: Color.fromRGBO(250, 250, 250, 1),
  };

  static final MaterialColor materialInvestrendPurple =
      MaterialColor(0xFF5414db, colorInvestrendPurple);

  static final MaterialColor materialInvestrendBlack =
      MaterialColor(0xFF1A1A1A, colorInvestrendBlack);

  static final MaterialColor materialInvestrendWhite =
      MaterialColor(0xFFFAFAFA, colorInvestrendWhite);

  static final Color investrend_purple = Color(0xFF5414DB);
  static final Color investrend_white = Color(0xFFFAFAFA);

  static const Color textColorLightTheme = Color(0xFF010000);
  static final TextTheme textThemeLight = ThemeData.light().textTheme.copyWith(
        displayLarge: ThemeData.light().textTheme.displayLarge?.copyWith(
          color: textColorLightTheme,
          fontSize: 50.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        displayMedium: ThemeData.light().textTheme.displayMedium?.copyWith(
          color: textColorLightTheme,
          fontSize: 45.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        headlineMedium: ThemeData.light().textTheme.headlineMedium?.copyWith(
          color: textColorLightTheme,
          fontSize: 24.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        headlineSmall: ThemeData.light().textTheme.headlineSmall?.copyWith(
          color: textColorLightTheme,
          fontSize: 20.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        titleLarge: ThemeData.light().textTheme.titleLarge?.copyWith(
          color: textColorLightTheme,
          fontSize: 18.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        //Button        font-size: 14px;    font-weight: bold;  line-height: 20px;  text-transform: capitalize;
        labelLarge: ThemeData.light().textTheme.labelLarge?.copyWith(
          color: textColorLightTheme,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        //, height: 1.3

        //H3            font-size: 40px;    fontWeigh: 700      line-height: 48px;
        displaySmall: ThemeData.light().textTheme.displaySmall?.copyWith(
          color: textColorLightTheme,
          fontSize: 26.0,
          fontWeight: FontWeight.w600,
          height: 1.2,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Regular       font-size: 16px;    fontWeight 700      line-height: 28px;
        titleMedium: ThemeData.light().textTheme.titleMedium?.copyWith(
          color: textColorLightTheme,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          height: 1.61,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Regular       font-size: 16px;    fontWeight 400      line-height: 28px;
        bodyLarge: ThemeData.light().textTheme.bodyLarge?.copyWith(
          color: textColorLightTheme,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          height: 1.61,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Small         font-size: 14px;    fontWeight  500     line-height: 24px;   letter-spacing: -0.002em;
        titleSmall: ThemeData.light().textTheme.bodyMedium?.copyWith(
          color: textColorLightTheme,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          height: 1.714,
          letterSpacing: -0.002,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Small         font-size: 14px;    fontWeight  400      line-height: 24px;    letter-spacing: -0.002em;
        bodyMedium: ThemeData.light().textTheme.bodyMedium?.copyWith(
          color: textColorLightTheme,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          height: 1.714,
          letterSpacing: -0.002,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Support       font-size: 11px;    fontWeight  400 sama 500    line-height: 14px;    letter-spacing: -0.002em;
        bodySmall: ThemeData.light().textTheme.bodySmall?.copyWith(
          color: textColorLightTheme,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          height: 1.272,
          letterSpacing: -0.002,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //More Support  font-size: 10px;    fontWeight  400             line-height: 14px;    letter-spacing: -0.002em;
        labelSmall: ThemeData.light().textTheme.labelSmall?.copyWith(
          color: textColorLightTheme,
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.002,
          height: 1.4,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
      );
  //static const Color textColorDarkTheme = Color(0xFFFAFAFA);
  static const Color textColorDarkTheme = Color(0xFFEBEBEB);

  static final TextTheme textThemeDark = ThemeData.dark().textTheme.copyWith(
        displayLarge: ThemeData.dark().textTheme.displayLarge?.copyWith(
          color: textColorDarkTheme,
          fontSize: 50.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        displayMedium: ThemeData.dark().textTheme.displayMedium?.copyWith(
          color: textColorDarkTheme,
          fontSize: 45.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        headlineMedium: ThemeData.dark().textTheme.headlineMedium?.copyWith(
          color: textColorDarkTheme,
          fontSize: 24.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(
          color: textColorDarkTheme,
          fontSize: 20.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
        titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(
          color: textColorDarkTheme,
          fontSize: 18.0,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Button        font-size: 14px;    font-weight: bold;  line-height: 20px;  text-transform: capitalize;
        labelLarge: ThemeData.dark().textTheme.labelLarge?.copyWith(
          color: textColorDarkTheme,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ), //, height: 1.3

        //H3            font-size: 40px;    fontWeigh: 700      line-height: 48px;
        displaySmall: ThemeData.dark().textTheme.displaySmall?.copyWith(
          color: textColorDarkTheme,
          fontSize: 26.0,
          fontWeight: FontWeight.w600,
          height: 1.2,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Regular       font-size: 16px;    fontWeight 700      line-height: 28px;
        titleMedium: ThemeData.dark().textTheme.bodyLarge?.copyWith(
          color: textColorDarkTheme,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          height: 1.61,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Regular       font-size: 16px;    fontWeight 400      line-height: 28px;
        bodyLarge: ThemeData.dark().textTheme.bodyLarge?.copyWith(
          color: textColorDarkTheme,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
          height: 1.61,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Small         font-size: 14px;    fontWeight  500     line-height: 24px;   letter-spacing: -0.002em;
        titleSmall: ThemeData.dark().textTheme.bodyMedium?.copyWith(
          color: textColorDarkTheme,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          height: 1.714,
          letterSpacing: -0.002,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Small         font-size: 14px;    fontWeight  400      line-height: 24px;    letter-spacing: -0.002em;
        bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(
          color: textColorDarkTheme,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          height: 1.714,
          letterSpacing: -0.002,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //Support       font-size: 11px;    fontWeight  400 sama 500    line-height: 14px;    letter-spacing: -0.002em;
        bodySmall: ThemeData.dark().textTheme.bodySmall?.copyWith(
          color: textColorDarkTheme,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          height: 1.272,
          letterSpacing: -0.002,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),

        //More Support  font-size: 10px;    fontWeight  400             line-height: 14px;    letter-spacing: -0.002em;
        labelSmall: ThemeData.dark().textTheme.labelSmall?.copyWith(
          color: textColorDarkTheme,
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.002,
          height: 1.4,
          fontFamily: fontFamily /*'WorkSans'*/,
          fontFeatures: [
            FontFeature.stylisticSet(1),
            FontFeature.stylisticSet(2)
          ],
        ),
      );

  static final purpleInvestrend = Color(0xFFFAFAFA);
  static final ThemeData themeLight = ThemeData(
    fontFamily: fontFamily,
    //fontFamily: 'WorkSans',
    //fontFamily: 'LobsterTwo',

    primaryColor: Color(0xFFFAFAFA),
    // splashColor: Colors.red,
    focusColor: Color(0xFF5414DB),
    checkboxTheme: ThemeData.light().checkboxTheme,
    disabledColor: Color(0xFFC8BAF0),
    shadowColor: ThemeData.light().shadowColor,
    primaryIconTheme: IconThemeData(color: Colors.grey),
    //bottomAppBarColor: Colors.blue,
    // splashColor: Color(0xFF8f4bff),
    bottomSheetTheme: ThemeData.light()
        .bottomSheetTheme
        .copyWith(backgroundColor: Color(0xFFF9F9F9)),
    cardTheme: ThemeData.light().cardTheme.copyWith(
          elevation: 0.0,
          color: Color(0xFFFAFAFA),
          shape: null,
        ),
    chipTheme: ThemeData.light().chipTheme.copyWith(
          labelStyle: ThemeData.light().textTheme.bodySmall?.copyWith(
              color: textColorLightTheme,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              height: 1.272,
              letterSpacing: -0.002),
          backgroundColor: Color(0xFFF4F2F9),
        ),
    bottomNavigationBarTheme:
        ThemeData.light().bottomNavigationBarTheme.copyWith(
              backgroundColor: Color(0xFFFAFAFA),
              selectedItemColor: Color(0xFF5414DB),
              unselectedItemColor: Color(0xFFCFCFCF),
              elevation: 0.0,
            ),
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
          backgroundColor: Color(0xFFFAFAFA),
          foregroundColor: Color(0xFF5414DB),
          titleTextStyle: TextStyle(
              fontSize: 14.0,
              fontFamily: fontFamily /*'WorkSans'*/,
              color: Color(0xFF5414DB),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.054),
          iconTheme: IconThemeData(
            color: Color(0xFF5414DB),
          ),
          //color: Color(0xFFFAFAFA)
        ),
    dataTableTheme:
        ThemeData.light().dataTableTheme.copyWith(dividerThickness: 0.0),
    tabBarTheme: ThemeData.light().tabBarTheme.copyWith(
          indicator: BoxDecoration(),
          labelColor: Color(0xFF010000),
          labelStyle: textThemeLight.titleMedium,
          unselectedLabelColor: Color(0xFF8C979F),
          unselectedLabelStyle: textThemeLight.titleMedium?.copyWith(
            color: Color(0xFF8C979F),
          ),
          //labelStyle: ThemeData.light().textTheme.button.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18.0),
          // unselectedLabelStyle: ThemeData.light().textTheme.button.copyWith(
          //       fontWeight: FontWeight.bold,
          //       color: Colors.black54,
          //       fontSize: 18.0,
          //     ),
        ),
    //inputDecorationTheme: ThemeData.light().inputDecorationTheme,
    textTheme: textThemeLight,
    // colorScheme: ColorScheme.fromSwatch(primarySwatch: materialInvestrendPurple)
    //     .copyWith(secondary: Color(0xFF5414DB), brightness: Brightness.light)
    //     .copyWith(background: Color(0xFFFAFAFA), brightness: Brightness.light),

    colorScheme: ThemeData.light()
        .colorScheme
        .copyWith(secondary: Color(0xFF5414DB), background: Color(0xFFFAFAFA)),
  );

  static final ThemeData themeDark = ThemeData(
    fontFamily: fontFamily,
    //fontFamily: 'WorkSans',
    // fontFamily: 'LobsterTwo',

    primaryColor: Color(0xFFFAFAFA),
    // splashColor: Colors.green,
    focusColor: Color(0xFF5414DB),
    disabledColor: Color(0xFFC8BAF0),
    shadowColor: Colors.grey,
    checkboxTheme: ThemeData.light().checkboxTheme,
    primaryIconTheme: IconThemeData(color: Colors.grey[300]),
    // bottomAppBarColor: Colors.yellow,
    // splashColor: Color(0xFF8f4bff),`
    bottomSheetTheme: ThemeData.light()
        .bottomSheetTheme
        .copyWith(backgroundColor: Color(0xFF1B1A1D)),
    cardTheme: ThemeData.light().cardTheme.copyWith(
          elevation: 0.0,
          //color: Color(0xFF010000),
          color: Color(0xFF141414),
          shape: null,
        ),
    chipTheme: ThemeData.dark().chipTheme.copyWith(
          labelStyle: ThemeData.dark().textTheme.bodySmall?.copyWith(
              color: textColorDarkTheme,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              height: 1.272,
              letterSpacing: -0.002),
          backgroundColor: Color(0xFF1B1A1D),
        ),
    bottomNavigationBarTheme:
        ThemeData.dark().bottomNavigationBarTheme.copyWith(
              backgroundColor: Color(0xFF1A1A1A),
              selectedItemColor: Color(0xFF5414DB),
              unselectedItemColor: Color(0xFF8C979F),
              elevation: 0.0,
            ),
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          backgroundColor: Color(0xFF141414),
          foregroundColor: Color(0xFFEBEBEB),
          titleTextStyle: TextStyle(
              fontSize: 14.0,
              fontFamily: fontFamily /*'WorkSans'*/,
              color: Color(0xFFEBEBEB),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.054),
          iconTheme: IconThemeData(color: Color(0xFFEBEBEB)),
        ),
    dataTableTheme:
        ThemeData.dark().dataTableTheme.copyWith(dividerThickness: 0.0),
    tabBarTheme: ThemeData.dark().tabBarTheme.copyWith(
          indicator: BoxDecoration(),
          labelColor: Color(0xFFEBEBEB),
          labelStyle: textThemeLight.titleMedium,
          unselectedLabelColor: Color(0xFF8C979F),
          unselectedLabelStyle:
              textThemeLight.titleMedium?.copyWith(color: Color(0xFF8C979F)),

          // labelColor: Colors.white,
          // labelStyle: ThemeData.dark().textTheme.button.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18.0),
          // unselectedLabelColor: Color(0xFF8E979E),
          // unselectedLabelStyle: ThemeData.dark()
          //     .textTheme
          //     .button
          //     .copyWith(fontWeight: FontWeight.bold, color: Color(0xFF8E979E), fontSize: 18.0, letterSpacing: 0.1),
        ),
    //inputDecorationTheme: ThemeData.dark().inputDecorationTheme,
    textTheme: textThemeDark,
    // colorScheme: ColorScheme.fromSwatch(primarySwatch: materialInvestrendWhite)
    //     .copyWith(secondary: Color(0xFF5414DB), brightness: Brightness.dark)
    //     .copyWith(background: Color(0xFF141414), brightness: Brightness.dark),
    colorScheme: ThemeData.dark()
        .colorScheme
        .copyWith(secondary: Color(0xFF5414DB), background: Color(0xFF141414)),
  );
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  int savedThemeModeIndex;
  //bool firstime = true;
  MainApplication(this.savedThemeModeIndex, {Key? key}) : super(key: key) {
    // final container = ProviderContainer();
    // container.read(themeModeNotifier).setIndex(savedThemeModeIndex);
  }

  @override
  State<MainApplication> createState() => _MainApplicationState();
}

class _MainApplicationState extends State<MainApplication> {
  ThemeData? themeCustom;

  Key keyInvestrend = UniqueKey();
  //final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  ValueNotifier<String>? notifierFirebase;
  @override
  void initState() {
    super.initState();

    notifierFirebase = ValueNotifier('loading');

    //enableFirebaseMessaging();
  }

  /*
  /// Define a top-level named handler which background/terminated messages will
  /// call.
  ///
  /// To verify things are working, check out the native platform logs.
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }
  */
  /*
  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void enableFirebaseMessaging() async{
    //if (?kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.

    var initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();

    var initSetttings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    await flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onSelectNotification);

    /* ASLI */

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    //}


    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
      bool valid = message != null;

      bool contextIsNull = context == null;
      print('firebase AAA getInitialMessage valid : $valid  contextIsNull : $contextIsNull');
      if (valid) {
        Future.delayed(Duration(seconds: 5),(){
          bool contextIsNull = context == null;
          print('firebase BBB getInitialMessage valid : $valid  contextIsNull : $contextIsNull');
          //Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
          showInfoDialog(context, title: 'Push Message', content: message.notification.title);
        });
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //   Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
        // });

      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      bool valid = notification != null && android != null;
      print('firebase AAA onMessage receive valid : $valid');

      if (valid /*notification != null && android != null && !kIsWeb*/) {
        //showSnackBar(context, notification.title);

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'launch_background',
            ),
          ),
          payload: notification.title, //'Hello LocalNotif AFS'
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      bool contextIsNull = context == null;
      print('firebase AAA onMessageOpenedApp event was published!  contextIsNull : $contextIsNull');
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
      // });
      Future.delayed(Duration(seconds: 5),(){
        bool contextIsNull = context == null;
        print('firebase BBB onMessageOpenedApp event was published!  contextIsNull : $contextIsNull');
        //Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
        showInfoDialog(context, title: 'Push Message', content: message.notification.title);
      });
    });

    requestPermissions();
    await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
  }


  Future onSelectNotification(String payload) {
    print('firebase onSelectNotification : $payload');
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    //   // return NewScreen(
    //   //   payload: payload,
    //   // );
    // }));
  }
  Future<void> showInfoDialog(BuildContext context, {String title = 'Info', String content = '', VoidCallback onClose}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content, style: Theme.of(context).textTheme.caption,),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('button_close'.tr()),

              onPressed: () {
                Navigator.of(context).pop();
                if(onClose != null){
                  onClose();
                }
              },
            ),
          ],
        );
      },
    );
  }
  void requestPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
  */
  @override
  void dispose() {
    if (notifierFirebase != null) {
      notifierFirebase?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildInvestrend(context, '/', '');
    /*
    return ValueListenableBuilder<String>(
        valueListenable: notifierFirebase,
        builder: (context, value, child) {
          if(StringUtils.equalsIgnoreCase('loading', value)){
            return buildInvestrend(context, '/initiliaze_loading','');
          }else if(StringUtils.equalsIgnoreCase('finished', value)){
            return buildInvestrend(context, '/', '');
          }else{
            //error
            return buildInvestrend(context, '/initiliaze_error', value);
          }
        });
    */

    /*
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          //return buildFirebaseSomethingWentWrong(context, snapshot.error.toString());

          return buildInvestrend(context, '/initiliaze_error', snapshot.error.toString());
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return buildInvestrend(context, '/', '');
        }

        // Otherwise, show something whilst waiting for initialization to complete
        //return buildFirebaseLoading(context);
        return buildInvestrend(context, '/initiliaze_loading','');
      },
    );
    */
  }

  Widget buildFirebaseSomethingWentWrong(BuildContext context, String error) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: elevation,
        shadowColor: shadowColor,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: AppBarTitleText('Initialize Error'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        width: double.maxFinite,
        height: double.maxFinite,
        child: Center(
            child: Row(
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            OutlinedButton(
              onPressed: () {
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
              },
              child: Text(
                'Exit',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.red),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget buildFirebaseLoading(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: elevation,
        shadowColor: shadowColor,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: AppBarTitleText('Initializing'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        width: double.maxFinite,
        height: double.maxFinite,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildInvestrend(
      BuildContext context, String initialRoute, String error) {
    String title = 'Investrend Mobile';

    // for live
    //String initialRoute = '/';
    //String initialRoute = '/text_sample';

    // for test
    // String initialRoute = '/create_post';
    // EasyLocalization.of(context).setLocale(Locale('id', ''));

    // String initialRoute = '/test';

    context.read(themeModeNotifier).index = widget.savedThemeModeIndex;
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(themeModeNotifier);
      ThemeMode themeMode = ThemeMode.values.elementAt(notifier.index);
      print('themeModeNotifier build : ' + themeMode.index.toString());
      keyInvestrend = Key('IVST_theme_' + themeMode.index.toString());
      return MaterialApp(
        scrollBehavior: CustomScrollBehaviour(),
        //key: Key('themeMode_'+themeMode.index.toString()),
        // debugShowCheckedModeBanner: false,
        title: title,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        navigatorObservers: [MainApplication.routeObserver],
        locale: context.locale,
        theme: MainApplication.themeLight,
        darkTheme: MainApplication.themeDark,
        themeMode: themeMode,

        // home: MyHomePage(title: title /*'Flutter Demo Home Page'*/),
        initialRoute: initialRoute,
        //'/',
        routes: {
          '/': (context) => ScreenSplash(),
          '/message': (context) => ScreenMessage(),
          '/agreement': (context) => ScreenAgreement(),
          '/initiliaze_loading': (context) => buildFirebaseLoading(context),
          '/initiliaze_error': (context) =>
              buildFirebaseSomethingWentWrong(context, error),
          //'/invitation': (context) => ScreenInvitation(null),
          '/test': (context) => ScreenTest(),
          '/main': (context) => ScreenMain(),
          '/landing': (context) => ScreenLanding(),
          '/register': (context) => ScreenRegister(),
          '/login': (context) => ScreenLogin(),
          '/friends': (context) => ScreenFriends(),
          '/friends_contact': (context) => ScreenFriendsContact(),
          '/landing_rdn': (context) => ScreenLandingRDN(),
          // '/register_rdn': (context) => ScreenRegisterRDN(),
          '/text_sample': (context) => ScreenTextSample(),
          '/trade': (context) => ScreenTrade(OrderType.Buy),
          '/stock_detail': (context) => ScreenStockDetail(),
          '/order_detail': (context) =>
              ScreenOrderDetail(BuySell(OrderType.Buy), null),
          '/amend': (context) => ScreenAmend(BuySell(OrderType.AmendBuy)),
          '/create_post': (context) => ScreenCreatePost('/trade'),
          '/candlestick_chart': (context) => CandlestickChart(),
          '/leaderboards': (context) => Leaderboards(),
          '/leaderboardsTransaction': (context) => LeaderboardsTransaction(),
          '/leaderboardsPrediction': (context) => LeaderboardsPrediction(),
          '/tradingViewChart': (context) => TradingViewChartPage(),
          //'/password': (context) => ScreenPassword(),
          //'/exit': (context) => ScreenExit(),

          '/test_image_picker': (context) => TestImagePickerPage(),
        },
        builder: (context, child) {
          return MediaQuery(
            child: Listener(
              //onPointerUp: (e) => onUserInteraction(context, 'onPointerUp', e),
              onPointerDown: (e) =>
                  onUserInteraction(context, 'onPointerDown', e),
              //onPointerCancel: (e) => onUserInteraction(context, 'onPointerCancel', e),
              child: InvestrendTheme(
                context: context, child: child,
                key: keyInvestrend,
                // key: Key('theme_'+themeMode?.index?.toString()),
              ),
            ),
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        },
      );
    });
  }

  void onUserInteraction(BuildContext? context, String event, e) {
    print('onUserInteraction $event : ' +
        DateTime.now().toString() +
        '  ' +
        e.toString());
    if (context != null) {
      context.read(propertiesNotifier).updateUserActivity(caller: event);
    }
  }
}
