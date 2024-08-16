// ignore_for_file: unused_local_variable

import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/persistent_data.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/onboarding/screen_invitation.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding/screen_landing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// // ignore: import_of_legacy_library_into_null_safe
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ScreenSplash extends StatefulWidget {
  @override
  _ScreenSplashState createState() => _ScreenSplashState();
}

class _ScreenSplashState
    extends State<ScreenSplash> // with SingleTickerProviderStateMixin
{
  var animate = false;

  // AnimationController _controller;
  // Animation<Offset> _offsetAnimation;

  Future<StoredData>? futuretoredData;

  /*
  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  void enableFirebaseMessaging() {
    //if (!kIsWeb) {
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

    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onSelectNotification);

    /* ASLI */

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
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
          Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
          //showInfoDialog(context, title: 'Push Message', content: message.notification.title);
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
        Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
        //showInfoDialog(context, title: 'Push Message', content: message.notification.title);
      });
    });

    requestPermissions();
    FirebaseMessaging.instance.subscribeToTopic('fcm_test');
  }


  Future onSelectNotification(String payload) {
    print('firebase onSelectNotification : $payload');
    InvestrendTheme.of(context).showInfoDialog(context, title: 'Push Message', content: payload);
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    //   // return NewScreen(
    //   //   payload: payload,
    //   // );
    // }));
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
  void initState() {
    super.initState();

    //enableFirebaseMessaging();

    futuretoredData = StoredData.load();
    futuretoredData?.then((snapshot) {
      DebugWriter.info('futuretoredData then');
      InvestrendTheme.storedData = snapshot;
      Stock? stock =
          snapshot.listStock!.isEmpty ? null : snapshot.listStock?.first;
      //InvestrendTheme.of(context).stockNotifier.setStock(stock);
      context.read(primaryStockChangeNotifier).setStock(stock!);
    }).onError((error, stackTrace) {
      DebugWriter.info('futuretoredData onError : ' + error.toString());
    }).whenComplete(() {
      DebugWriter.info('futuretoredData whenComplete');
    });

    Timer(new Duration(milliseconds: 300), animateSplash);
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // );
    // _offsetAnimation = Tween<Offset>(
    //   begin: const Offset(0.0, 1.0),
    //   end: Offset.zero,
    // ).animate(CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.elasticIn,
    // ));
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  void animateSplash() {
    animate = true;
    setState(() {});
  }

  void showNextPage() {
    //Navigator.pushReplacementNamed(context, '/login');
    //Navigator.pushReplacementNamed(context, '/landing');

    //InvestrendTheme.pushReplacement(context,  ScreenLogin(), ScreenTransition.Fade,'/login');
    //InvestrendTheme.pushReplacement(context,  ScreenMain(), ScreenTransition.Fade,'/main');

    if (InvestrendTheme.CHECK_INVITATION) {
      Invitation invitation = Invitation('', false);
      invitation.load().then((value) {
        if (invitation.invitation_status) {
          Token token = Token('', '');
          token.load().then((value) {
            bool hasToken = !StringUtils.isEmtpy(token.access_token) &&
                !StringUtils.isEmtpy(token.refresh_token);
            DebugWriter.info('hasToken : $hasToken');
            if (hasToken) {
              InvestrendTheme.pushReplacement(
                  context, ScreenLogin(), ScreenTransition.Fade, '/login');
            } else {
              InvestrendTheme.pushReplacement(
                  context, ScreenLanding(), ScreenTransition.Fade, '/landing');
            }
          }).onError((error, stackTrace) {
            InvestrendTheme.pushReplacement(
                context, ScreenLanding(), ScreenTransition.Fade, '/landing');
          });
        } else {
          InvestrendTheme.pushReplacement(context, ScreenInvitation(invitation),
              ScreenTransition.Fade, '/invitation');
        }
      }).onError((error, stackTrace) {
        InvestrendTheme.pushReplacement(context, ScreenInvitation(invitation),
            ScreenTransition.Fade, '/invitation');
      });
    } else {
      Token token = Token('', '');
      token.load().then((value) {
        bool hasToken = !StringUtils.isEmtpy(token.access_token) &&
            !StringUtils.isEmtpy(token.refresh_token);
        DebugWriter.info('hasToken : $hasToken');
        if (hasToken) {
          InvestrendTheme.pushReplacement(
              context, ScreenLogin(), ScreenTransition.Fade, '/login');
        } else {
          InvestrendTheme.pushReplacement(
              context, ScreenLanding(), ScreenTransition.Fade, '/landing');
        }
      }).onError((error, stackTrace) {
        InvestrendTheme.pushReplacement(
            context, ScreenLanding(), ScreenTransition.Fade, '/landing');
      });
    }

    /*
    Token token = Token('', '');
    token.load().then((value) {
      bool hasToken = !StringUtils.isEmtpy(token.access_token) && !StringUtils.isEmtpy(token.refresh_token);
      DebugWriter.info('hasToken : $hasToken');
      if(hasToken){
        InvestrendTheme.pushReplacement(context,  ScreenLogin(), ScreenTransition.Fade,'/login');
      }else{
        InvestrendTheme.pushReplacement(context,  ScreenLanding(), ScreenTransition.Fade,'/landing');
      }
    }).onError((error, stackTrace) {
      InvestrendTheme.pushReplacement(context,  ScreenLanding(), ScreenTransition.Fade,'/landing');
    });
    */

    // bool hasToken = InvestrendTheme.tradingHttp.hasToken();
    // DebugWriter.info('hasToken : $hasToken');
    // hasToken = InvestrendTheme.tradingHttp.hasToken();
    // DebugWriter.info('hasToken : $hasToken');
    // if(hasToken){
    //   InvestrendTheme.pushReplacement(context,  ScreenLogin(), ScreenTransition.Fade,'/login');
    // }else{
    //   InvestrendTheme.pushReplacement(context,  ScreenLanding(), ScreenTransition.Fade,'/landing');
    // }

    //InvestrendTheme.pushReplacement(context,  ScreenRegisterPin('username'), ScreenTransition.Fade,'/landing');

    /*
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        // pageBuilder: (context, animation1, animation2) => ScreenLanding(),
        pageBuilder: (context, animation1, animation2) => ScreenMain(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
     */
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DebugWriter.info('ScreenSplash didChangeDependencies');
    EasyLocalization.of(context)?.setLocale(Locale('id'));
    TextStyle? tst = InvestrendTheme.of(context).regular_w500;
    DebugWriter.info(
        'ScreenSplash didChangeDependencies datafeedHttp.isLoaded : ' +
            InvestrendTheme.datafeedHttp.isLoaded.toString());
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    //Image icon = Image.asset('images/icons/ic_launcher_white.png');
    double left = (width - 65) / 2;
    double top = (height - 20) / 2;
    double leftPadding = (width - (60 * 3)) / 2;
    double topBadge = height;
    double leftBadge1 = 0;
    double leftBadge2 = leftPadding + 60;
    double leftBadge3 = width;

    double topBuana = height;
    double leftBuana = (width - 112) / 2;

    if (animate) {
      top = height * 0.07;
      topBadge = height * 0.87;
      leftBadge1 = leftPadding - 30;
      leftBadge3 = leftPadding + (60 * 2) + 30;

      topBuana = topBadge - 40;
    }
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/backgrounds/splash_background.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: animate ? 1 : 0,
          duration: Duration(milliseconds: 2000),
          curve: Curves.bounceOut,
          child: Center(child: Image.asset("images/splash_3_person.png")),
          onEnd: () {
            if (animate) {
              context
                  .read(propertiesNotifier)
                  .properties
                  .load()
                  .whenComplete(() {
                Timer(new Duration(milliseconds: 1000), showNextPage);
              });
              //Timer(new Duration(milliseconds: 1000), showNextPage);
            }
          },
        ),
        AnimatedOpacity(
          opacity: animate ? 1 : 0,
          duration: Duration(milliseconds: 2000),
          curve: Curves.bounceInOut,
          child: Center(child: Image.asset("images/splash_2_tree.png")),
        ),

        // SlideTransition(
        //   position: _offsetAnimation,
        //   child:  Center(child: Image.asset("images/splash_2_tree.png")),
        // ),

        AnimatedOpacity(
          opacity: animate ? 1 : 0,
          duration: Duration(milliseconds: 1000),
          curve: Curves.bounceInOut,
          child: Center(child: Image.asset("images/splash_1_birds.png")),
        ),

        AnimatedPositioned(
            duration: Duration(milliseconds: 800),
            top: topBuana,
            left: leftBuana,
            curve: Curves.decelerate,
            child: Image.asset('images/icons/buana_icon_name_white.png')),

        AnimatedPositioned(
            duration: Duration(milliseconds: 800),
            top: top,
            left: left,
            curve: Curves.decelerate,
            child: Image.asset('images/icons/icon_name_white.png')),
        AnimatedPositioned(
            duration: Duration(milliseconds: 1500),
            top: topBadge,
            left: leftBadge1,
            curve: Curves.decelerate,
            child: Image.asset('images/icons/badge_1.png')),
        AnimatedPositioned(
            duration: Duration(milliseconds: 1500),
            top: topBadge,
            left: leftBadge2,
            curve: Curves.decelerate,
            child: Image.asset('images/icons/badge_2.png')),
        AnimatedPositioned(
            duration: Duration(milliseconds: 1500),
            top: topBadge,
            left: leftBadge3,
            curve: Curves.decelerate,
            child: Image.asset('images/icons/badge_3.png')),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<StoredData>(
              future: futuretoredData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  InvestrendTheme.storedData = snapshot.data!;
                  //Stock stock = snapshot.data.listStock.isEmpty ? null : snapshot.data.listStock.first;
                  //InvestrendTheme.of(context).stockNotifier.setStock(stock);
                  //context.read(primaryStockChangeNotifier).setStock(stock);
                  //return Center(child: Text('Loaded stored data last updated :\n'+snapshot.data.updated,style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white,), textAlign: TextAlign.center,));
                  return SizedBox(
                    width: 1.0,
                    height: 1.0,
                  );
                } else if (snapshot.hasError) {
                  return Text(
                      'Loading stored data error ' + snapshot.error.toString());
                }
                return Text('Loading stored data...');
              },
            ),
          ],
        ),
      ],
    );
  }
/*
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          child: Text(
            'Invest',
            style: Theme.of(context).textTheme.headline4,
          ),
          color: Colors.amber,
        ));
  }
  */
}
