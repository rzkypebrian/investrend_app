// ignore_for_file: unused_local_variable, unused_field, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/button_account.dart';
import 'package:Investrend/component/charts/trading_view_chart.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/message.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/serializeable.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/profiles/screen_profile.dart';
import 'package:Investrend/screens/tab_community/screen_community.dart';
import 'package:Investrend/screens/tab_home/screen_home.dart';
import 'package:Investrend/screens/tab_home/screen_notification.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio.dart';
import 'package:Investrend/screens/tab_search/screen_search.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
// import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ScreenMain extends StatefulWidget {
  @override
  _ScreenMainState createState() => _ScreenMainState('/main');
}

/* colors dari nugi

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
enum Languages { Indonesia, English }

/* HIDE for audit*/
enum Tabs { Home, Search, Portfolio, Transaction, Community }

class _ScreenMainState extends BaseStateNoTabs<
    ScreenMain> //with AutomaticKeepAliveClientMixin<ScreenMain>
{
  static const Duration durationBackgroundUpdate = Duration(minutes: 5);
  Timer? timer;

  // @override
  // bool get wantKeepAlive => true;

  //dartis
  /*
  Client redisDatafeedClient;
  PubSub redisDatafeedPubSub;
  */
  ValueNotifier<Map> notifierStockBrokerIndex = ValueNotifier<Map>(Map());
  final Key homeKey = UniqueKey();
  final Key searchKey = UniqueKey();
  final Key portfolioKey = UniqueKey();
  final Key transactionKey = UniqueKey();
  final Key communityKey = UniqueKey();
  WrapperHomeNotifier _wrapperHomeNotifier = WrapperHomeNotifier();
  Widget? screenSearch;

  // Widget screenSearch = new ScreenSearch(
  //   key: UniqueKey(),
  // );
  // Widget screenHome;// = new ScreenHome(_wrapperHomeNotifier, key: UniqueKey());
  Widget? screenHome;
  Widget screenPortfolio = new ScreenPortfolio(
    key: UniqueKey(),
  );
  Widget screenTransaction = new ScreenTransaction(
    key: UniqueKey(),
  );
  Widget screenCommunity = new ScreenCommunity(
    key: UniqueKey(),
  );

  TextEditingController? _searchFilterController;
  String? lastStatus = '';
  _ScreenMainState(String routeName)
      : super(routeName,
            screenAware: true, overrideBackButton: Platform.isAndroid);

  //Future<Map> futureStockBrokerIndex;

  //Home, Search, Portfolio, Transaction, Community
  List<BaseValueNotifier<bool>>? _visibilityNotifiers = [
    BaseValueNotifier<bool>(false),
    BaseValueNotifier<bool>(false),
    BaseValueNotifier<bool>(false),
    BaseValueNotifier<bool>(false),
    BaseValueNotifier<bool>(false),
  ];

  /*
  final String TYPE_SUMMARY 				  = 'Q'; // 'SUMMARY';
  final String TYPE_SUMMARY_LIST 			= 'W'; // 'SUMMARY_LIST';
  final String TYPE_SUMMARY_SHORT			= 'E'; // 'SUMMARY_SHORT';
  final String TYPE_STOCK 				    = 'R'; // 'STOCK';
  final String TYPE_STOCK_FD				  = 'T'; // 'STOCK_FD';
  final String TYPE_COMPOSITE_FD			= 'Y'; // 'COMPOSITE_FD';
  final String TYPE_STOCK_SHORT			  = 'U'; // 'STOCK_SHORT';
  final String TYPE_BROKER 				    = 'I'; // 'BROKER';
  final String TYPE_TRADE 				    = 'O'; // 'TRADE';
  final String TYPE_INDICES 				  = 'Z'; // 'INDICES';
  final String TYPE_INDICES_STOCK			= 'X'; // 'INDICES_STOCK';
  final String TYPE_STATUS 				    = 'C'; // 'STATUS';
  final String TYPE_NEWS	 				    = 'V'; // 'NEWS';
  final String TYPE_INFO	 				    = 'B'; // 'INFO';
  final String TYPE_ORDERBOOK 			  = 'N'; // 'ORDERBOOK';
  final String TYPE_TRADEBOOK 			  = 'M'; // 'TRADEBOOK';
  final String TYPE_ORDER					    = 'A'; // 'ORDER';
  final String TYPE_ORDERBOOK_QUEUE		= 'S'; // 'ORDER_QUEUE';
  final String TYPE_ORDERBOOK_QUEUE_DETAIL= 'D'; // 'ORDERBOOK_QUEUE_DETAIL';

  final String COLLECTION = 'C';
  final String HASH 		  = 'H';
  final String KEY	 	    = 'K';
  final String SORTED_SET	= 'SS';

  String COLLECTION_SUMMARY; // 	= COLLECTION + TYPE_SUMMARY; 			// "IDX.SUMMARY";
  String COLLECTION_INDICES; // 	= COLLECTION + TYPE_INDICES; 			// "IDX.INDICES";
  String COLLECTION_ORDERBOOK; // 	= COLLECTION + TYPE_ORDERBOOK; 		// "IDX.ORDERBOOK";
  String COLLECTION_STOCK_FD; //	= COLLECTION + TYPE_STOCK_FD; 		// "IDX.STOCK_FD";
  String COLLECTION_TRADEBOOK; // 	= COLLECTION + TYPE_TRADEBOOK; 		// "IDX.TRADEBOOK";


  String HASH_SUMMARY; // 		= HASH + TYPE_SUMMARY; 		// "HASH.SUMMARY";
  String HASH_ORDERBOOK; //		= HASH + TYPE_ORDERBOOK; 		// "HASH.ORDERBOOK";
  String HASH_TRADEBOOK; //		= HASH + TYPE_TRADEBOOK; 		// "HASH.TRADEBOOK";
  String HASH_INDICES; // 		= HASH + TYPE_INDICES; 		// "HASH.INDICES";
  String HASH_INDICES_STOCK; //	= HASH + TYPE_INDICES_STOCK; 	// "HASH.INDICES_STOCK";
  String HASH_STATUS; // 		= HASH + TYPE_STATUS; 		// "HASH.STATUS";
  String HASH_STOCK_FD; //		= HASH + TYPE_STOCK_FD; 		// "HASH.STOCK_FD";
  String HASH_COMPOSITE_FD; //	= HASH + TYPE_COMPOSITE_FD; 	// "HASH.COMPOSITE_FD";
  String HASH_ORDER; //			= HASH + TYPE_ORDER; 			// "HASH.ORDER";

  String KEY_SUMMARY; //		= KEY + TYPE_SUMMARY; 		// "IDX.SUMMARY";
  String KEY_ORDERBOOK; // 		= KEY + TYPE_ORDERBOOK; 		// "IDX.ORDERBOOK";
  String KEY_TRADEBOOK; // 		= KEY + TYPE_TRADEBOOK; 		// "IDX.TRADEBOOK";
  String KEY_INDICES; // 		= KEY + TYPE_INDICES; 		// "IDX.INDICES";
  String KEY_INDICES_STOCK; //	= KEY + TYPE_INDICES_STOCK; 	// "IDX.INDICES_STOCK";
  String KEY_STATUS; //			= KEY + TYPE_STATUS; 			// "IDX.STATUS";
  String KEY_STOCK_FD; //		= KEY + TYPE_STOCK_FD; 		// "IDX.STOCK_FD";
  String KEY_COMPOSITE_FD; //	= KEY + TYPE_COMPOSITE_FD; 	// "IDX.COMPOSITE_FD";
  String KEY_STOCK; // 			= KEY + TYPE_STOCK; 			// "IDX.STOCK";
  String KEY_BROKER; // 		= KEY + TYPE_BROKER; 			// "IDX.BROKER";
  String KEY_TRADE; // 			= KEY + TYPE_TRADE; 			// "IDX.TRADE";
  String KEY_ORDER; //			= KEY + TYPE_ORDER; 			// "IDX.ORDER";
  */
  /*
  void connnectRedis(BuildContext context, {String redis_ip, String redis_port, String redis_password}) async{
    print('connnectRedis');
    try{
      String ip = redis_ip ?? '36.89.110.91';
      String port = redis_port ?? '8811';
      String password = redis_password ?? '83bc008633616fa21c81054d5eaff1573';
      redisDatafeedClient = await Client.connect('redis://$ip:$port');
      final commands = redisDatafeedClient.asCommands<String, String>();
      await commands.auth(password);

      // Create the PubSub object using the client connection
      redisDatafeedPubSub = PubSub<String, String>(redisDatafeedClient.connection);
      redisDatafeedPubSub.stream.listen((PubSubEvent event){

        if(event is MessageEvent){
          print('channel '+event.channel+' --> '+event.message);
        }else if(event is SubscriptionEvent){
          print(event.command+' --> channel '+event.channel+' --> count '+event.channelCount.toString());
        }else{
          print('redisDatafeedPubSub Got Event');
          print(event);
        }
      }, onError: print);

      redisDatafeedPubSub.subscribe(channel: 'KC'); // KEY_STATUS
      subcribeDatafeed();


      print('connnectRedis success');
    }catch(error){
      print('connnectRedis error');
      print(error);

    }
  }


  void subcribeDatafeed(){
    if(redisDatafeedPubSub == null){
      print(routeName+'.subcribeDatafeed aborted caused by redisDatafeedPubSub = NULL');
      return;
    }
    if(context.read(subscriptionDatafeedChangeNotifier).unusedChannels.isNotEmpty){
      for(var channel in context.read(subscriptionDatafeedChangeNotifier).unusedChannels){
        if(!StringUtils.isEmtpy(channel)){
          redisDatafeedPubSub.unsubscribe(channel: channel);
        }
      }
    }
    context.read(subscriptionDatafeedChangeNotifier).unusedChannels.clear();
    for(var channel in context.read(subscriptionDatafeedChangeNotifier).channels()){
      if(!StringUtils.isEmtpy(channel)){
        redisDatafeedPubSub.subscribe(channel: channel);
      }
    }
  }




  void disconnnectRedis() async{
    print('disconnnectRedis');
    try{
      //print('disconnnectRedis redisDatafeedPubSub');
      //redisDatafeedPubSub?.disconnect();
      print('disconnnectRedis redisDatafeedClient');
      redisDatafeedClient?.disconnect();
      print('disconnnectRedis success');

      redisDatafeedPubSub = null;
      redisDatafeedClient = null;
    }catch(error){
      print('disconnnectRedis error');
      print(error);
    }
  }
  */

  void doUpdateBackground() async {
    try {
      final Remark2Data? remark2 =
          await InvestrendTheme.datafeedHttp.fetchRemark2();
      if (remark2 != null) {
        print(routeName + ' Future remark2 DATA : ' + remark2.toString());
        //_summaryNotifier.setData(stockSummary);
        context.read(remark2Notifier).setData(remark2);
      } else {
        print(routeName + ' Future remark2 NO DATA');
      }
    } catch (error) {
      print(routeName + ' Future remark2 Error');
      print(error);
    }

    try {
      final Map<String, FundamentalCache>? fundamentalCache =
          await InvestrendTheme.datafeedHttp.fetchFundamentalCache();
      if (fundamentalCache != null) {
        print(routeName +
            ' Future fundamentalCache DATA : ' +
            fundamentalCache.length.toString());
        //_summaryNotifier.setData(stockSummary);
        context.read(fundamentalCacheNotifier).setData(fundamentalCache);
      } else {
        print(routeName + ' Future fundamentalCache NO DATA');
      }
    } catch (error) {
      print(routeName + ' Future fundamentalCache Error');
      print(error);
    }

    try {
      final List<CorporateActionEvent>? corporateActionEvent =
          await InvestrendTheme.datafeedHttp.fetchCorporateActionEvent();
      if (corporateActionEvent != null) {
        print(routeName +
            ' Future corporateActionEvent DATA : ' +
            corporateActionEvent.length.toString());
        //_summaryNotifier.setData(stockSummary);
        context
            .read(corporateActionEventNotifier)
            .setData(corporateActionEvent);
      } else {
        print(routeName + ' Future corporateActionEvent NO DATA');
      }
    } catch (error) {
      print(routeName + ' Future corporateActionEvent Error');
      print(error);
    }

    try {
      final SuspendedStockData? suspendStock =
          await InvestrendTheme.datafeedHttp.fetchStockSuspend();
      if (suspendStock != null) {
        print(routeName +
            ' Future suspendStock DATA : ' +
            suspendStock.toString());
        //_summaryNotifier.setData(stockSummary);
        context.read(suspendedStockNotifier).setData(suspendStock);
      } else {
        print(routeName + ' Future suspendStock NO DATA');
      }
    } catch (error) {
      print(routeName + ' Future suspendStock Error');
      print(error);
    }

    if (StringUtils.equalsIgnoreCase(lastStatus, 'P') // market not yet open
            ||
            StringUtils.equalsIgnoreCase(lastStatus, 'B') // market break
        ) {
      // kalau market not yet open
      print(routeName +
          ' background fecth marketData DATA : ' +
          DateTime.now().toString());
      MD5StockBrokerIndex? md5 = InvestrendTheme.storedData?.md5;
      if (md5 != null) {
        try {
          final Map<dynamic, dynamic>? value =
              await InvestrendTheme.datafeedHttp.fetchMarketData(
                  md5.md5broker, md5.md5stock, md5.md5index, md5.md5sector);
          if (value != null) {
            print(routeName + ' Future marketData DATA : ' + value.toString());
            bool validBrokerChanged = value['validBrokerChanged'] ?? false;
            bool validStockChanged = value['validStockChanged'] ?? false;
            bool validIndexChanged = value['validIndexChanged'] ?? false;
            bool validSectorChanged = value['validSectorChanged'] ?? false;

            MD5StockBrokerIndex? md5 = value['md5'];

            print(
                'future validBrokerChanged : ' + validBrokerChanged.toString());
            print('future validStockChanged : ' + validStockChanged.toString());
            print('future validIndexChanged : ' + validIndexChanged.toString());
            print(
                'future validSectorChanged : ' + validSectorChanged.toString());

            bool isValid = md5 != null && md5.isValid();
            print('future md5 isValid : $isValid');

            if (isValid) {
              InvestrendTheme.storedData?.md5.sharePerLot = md5.sharePerLot;
            }

            if (validStockChanged && isValid) {
              InvestrendTheme.storedData?.md5.md5stock = md5.md5stock;
              InvestrendTheme.storedData?.md5.md5stockUpdate =
                  md5.md5stockUpdate;
              InvestrendTheme.storedData?.listStock?.clear();
              if (value['stocks'] != null) {
                InvestrendTheme.storedData?.listStock?.addAll(value['stocks']);
              }
            }

            if (validBrokerChanged && isValid) {
              InvestrendTheme.storedData?.md5.md5broker = md5.md5broker;
              InvestrendTheme.storedData?.md5.md5brokerUpdate =
                  md5.md5brokerUpdate;
              InvestrendTheme.storedData?.listBroker?.clear();
              if (value['brokers'] != null) {
                InvestrendTheme.storedData?.listBroker
                    ?.addAll(value['brokers']);
              }
            }

            if (validIndexChanged && isValid) {
              InvestrendTheme.storedData?.md5.md5index = md5.md5index;
              InvestrendTheme.storedData?.md5.md5indexUpdate =
                  md5.md5indexUpdate;
              InvestrendTheme.storedData?.listIndex?.clear();
              if (value['indexs'] != null) {
                InvestrendTheme.storedData?.listIndex?.addAll(value['indexs']);
              }
            }

            if (validSectorChanged && isValid) {
              InvestrendTheme.storedData?.md5.md5sector = md5.md5sector;
              InvestrendTheme.storedData?.md5.md5sectorUpdate =
                  md5.md5sectorUpdate;
              InvestrendTheme.storedData?.listSector?.clear();
              if (value['sectors'] != null) {
                InvestrendTheme.storedData?.listSector
                    ?.addAll(value['sectors']);
              }
            }

            int? countIndex = InvestrendTheme.storedData?.listIndex?.length;
            InvestrendTheme.storedData?.listStock?.forEach((stock) {
              for (int i = 0; i < countIndex!; i++) {
                Index? index =
                    InvestrendTheme.storedData?.listIndex?.elementAt(i);
                if (index!.isSector) {
                  index.checkAndAddMembers(stock);
                }
              }
            });

            print('future stocks : ' +
                InvestrendTheme.storedData!.listStock!.length.toString());
            print('future brokers : ' +
                InvestrendTheme.storedData!.listBroker!.length.toString());
            print('future indexs : ' +
                InvestrendTheme.storedData!.listIndex!.length.toString());
            print('future sectors : ' +
                InvestrendTheme.storedData!.listSector!.length.toString());

            Future<bool>? savedFuture = InvestrendTheme.storedData?.save();
          } else {
            print(routeName + ' Future marketData NO DATA');
          }
        } catch (error) {
          print(routeName + ' Future marketData Error');
          print(error);
        }
      }
    }
  }

  void startTimer() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(durationBackgroundUpdate, (timer) {
        if (mounted) {
          doUpdateBackground();
        }
      });
    }
  }

  void stopTimer() {
    if (timer == null || !timer!.isActive) {
      return;
    }
    timer?.cancel();
    timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(routeName + ' didChangeAppLifecycleState state = $state');
    switch (state) {
      case AppLifecycleState.inactive:
        //redisConnector.disconnectRedis(info:"inactive");
        break;
      case AppLifecycleState.detached:
        //redisConnector.disconnectRedis(info:"detached");
        break;
      case AppLifecycleState.paused:
        // if (maintainConnection) {
        //   redisConnector.disconnectRedis(info: "paused");
        // }
        // if(context != null && mounted){
        //
        // }
        context.read(dataHolderChangeNotifier).isForeground = false;
        context.read(managerDatafeedNotifier).disconnect(
              info: 'paused',
            );
        context.read(managerEventNotifier).disconnect(
              info: 'paused',
            );

        break;
      case AppLifecycleState.resumed:
        // if (maintainConnection && !redisConnector.isReady()) {
        //   redisConnector.connectRedis();
        // }
        context.read(dataHolderChangeNotifier).isForeground = true;
        context.read(managerDatafeedNotifier).connect();
        context.read(managerEventNotifier).connect();
        break;
    }
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel? channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  void enableFirebaseMessaging() {
    //if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.

    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();

    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin?.initialize(initSetttings,
        onSelectNotification: onSelectNotification);

    /* ASLI */

    flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    //}

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      bool valid = message != null;
      //bool valid = message != null && !StringUtils.isEmtpy(message.notification.title);
      //bool valid = message != null && message.notification != null;

      bool contextIsNull = context == null;
      print(DateTime.now().toString() +
          ' firebase AAA getInitialMessage valid : $valid  contextIsNull : $contextIsNull');
      if (valid) {
        Future.delayed(Duration(seconds: 1), () {
          bool contextIsNull = context == null;
          print(DateTime.now().toString() +
              ' firebase BBB getInitialMessage valid : $valid  contextIsNull : $contextIsNull');
          Navigator.pushNamed(context, '/message',
              arguments:
                  MessageArguments(message, true, caller: 'getInitialMessage'));
          //showInfoDialog(context, title: 'Push Message', content: message.notification.title);
        });
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //   Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
        // });
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      RemoteNotification? notification = message?.notification;
      AndroidNotification? android = message?.notification?.android;
      bool valid = notification != null && android != null;
      print(DateTime.now().toString() +
          ' firebase AAA onMessage receive valid : $valid');

      if (valid /*notification != null && android != null && !kIsWeb*/) {
        //showSnackBar(context, notification.title);

        String time = '';
        String type = '';
        String bodyLenght = '';
        String recipient = '';
        if (message?.data != null && message!.data.isNotEmpty) {
          if (message.data.containsKey('time')) {
            time = message.data['time'];
          }
          if (message.data.containsKey('recipient')) {
            recipient = message.data['recipient'];
          }
          if (message.data.containsKey('type')) {
            type = message.data['type'];
          }
          if (message.data.containsKey('body_lenght')) {
            bodyLenght = message.data['body_lenght'];
          }
        }

        String? createdAt = StringUtils.noNullString(time);
        String sentAt = '';
        String? fcmTitle = StringUtils.noNullString(notification.title!);
        String? fcmBody = StringUtils.noNullString(notification.body!);
        String? fcmImageUrl =
            StringUtils.noNullString(notification.android!.imageUrl!);
        String? fcmAndroidColor = StringUtils.noNullString(android.color!);
        String? fcmAndroidChannelId =
            StringUtils.noNullString(android.channelId!);
        String fcmDataKeys = '';
        String fcmDataValues = '';
        if (message?.data != null && message!.data.isNotEmpty) {
          fcmDataKeys = message.data.keys.join('|');
          fcmDataValues = message.data.values.join('|');
        }
        String? fcmMessageId = StringUtils.noNullString(message?.messageId!);
        int readCount = 0;

        BaseMessage baseMessage;
        if (StringUtils.equalsIgnoreCase(type, "INBOX")) {
          baseMessage = InboxMessage(
              '-',
              recipient,
              createdAt,
              sentAt,
              fcmTitle,
              fcmBody,
              fcmImageUrl,
              fcmAndroidColor,
              fcmAndroidChannelId,
              fcmDataKeys,
              fcmDataValues,
              fcmMessageId,
              readCount);
        } else if (StringUtils.equalsIgnoreCase(type, "BROADCAST")) {
          baseMessage = BroadcastMessage(
              '-',
              recipient,
              createdAt,
              sentAt,
              fcmTitle,
              fcmBody,
              fcmImageUrl,
              fcmAndroidColor,
              fcmAndroidChannelId,
              fcmDataKeys,
              fcmDataValues,
              fcmMessageId,
              readCount);
        }

        /**
         * TO DO Richy
         * serialize message nya buat nanti di onSelectNotification di unzerialize buat di buka di ScreenMessage
         */
        /*
        if(baseMessage != null){
          InvestrendTheme.of(context).showSnackBarPushMessage(context, baseMessage);
        }else{
          InvestrendTheme.of(context).showInfoDialog(context,title: fcm_title,content: fcm_body);
        }
        */
        //String payload = baseMessage != null ? baseMessage.serialize() : notification.title;
        String? payload = notification.title;
        flutterLocalNotificationsPlugin?.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              icon: 'launch_background',
            ),
          ),
          payload: payload, //'Hello LocalNotif AFS'
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      bool valid = message != null;
      bool contextIsNull = context == null;
      print(DateTime.now().toString() +
          ' firebase AAA onMessageOpenedApp event was published!  valid : $valid  contextIsNull : $contextIsNull');
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   Navigator.pushNamed(context, '/message', arguments: MessageArguments(message, true));
      // });
      if (valid) {
        Future.delayed(Duration(seconds: 1), () {
          bool contextIsNull = context == null;
          print(DateTime.now().toString() +
              ' firebase BBB onMessageOpenedApp event was published!  contextIsNull : $contextIsNull');
          Navigator.pushNamed(context, '/message',
              arguments: MessageArguments(message, true,
                  caller: 'onMessageOpenedApp'));
          //showInfoDialog(context, title: 'Push Message', content: message.notification.title);
        });
      }
    });

    requestPermissions();
    FirebaseMessaging.instance.subscribeToTopic('fcm_test');
    FirebaseMessaging.instance.subscribeToTopic('investrend');
    if (Platform.isIOS) {
      FirebaseMessaging.instance.subscribeToTopic('IOS');
    } else if (Platform.isAndroid) {
      FirebaseMessaging.instance.subscribeToTopic('ANDROID');
    }

    firebaseTokenRegister();
  }

  void firebaseTokenRegister() async {
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    // String userId = FirebaseAuth.instance.currentUser.uid;
    //
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .update({
    //   'tokens': FieldValue.arrayUnion([token]),
    // });

    MyDevice myDevice = MyDevice();
    await myDevice.load();
    try {
      String? username = context.read(dataHolderChangeNotifier).user.username;
      String? deviceId = myDevice.unique_id;
      String? devicePlatform = InvestrendTheme.of(context).applicationPlatform;
      String fcmToken = token;
      String? applicationVersion =
          InvestrendTheme.of(context).applicationVersion;
      final String? result = await InvestrendTheme.datafeedHttp.registerDevice(
          username, deviceId, devicePlatform, fcmToken, applicationVersion);
      if (result != null) {
        print('registerDevice result : $result');
      } else {
        print('registerDevice result : NULL');
      }
    } catch (error) {
      print('registerDevice error : ' + error.toString());
      print(error);
    }
  }

  Future? onSelectNotification(String? payload) {
    print(DateTime.now().toString() +
        ' firebase onSelectNotification : $payload');
    Serializeable? serializeable = Serializeable.unserialize(payload!);
    bool? isBaseMessage = serializeable != null && serializeable is BaseMessage;
    print(DateTime.now().toString() +
        ' firebase onSelectNotification isBaseMessage : $isBaseMessage');
    if (isBaseMessage) {
      //InboxMessage or BroadcastMessage
      BaseMessage message = serializeable;

      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ScreenMessage(
              baseMessage: message,
              caller: 'onSelectNotification',
            ),
            settings: RouteSettings(name: '/message'),
          ));
    } else {
      InvestrendTheme.of(context)
          .showInfoDialog(context, title: 'Push Message', content: payload);
    }
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    //   // return NewScreen(
    //   //   payload: payload,
    //   // );
    // }));
    return null;
  }

  void requestPermissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
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
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<bool> printDevice() async {
    MyDevice myDevice = MyDevice();
    await myDevice.load();
    print(routeName + ' richy_20220607 uniqId = [' + myDevice.unique_id + ']');
    return true;
  }

  @override
  void initState() {
    super.initState();
    print(routeName + ' initState aaaa');
    //initFirebaseMessaging();
    printDevice();

    enableFirebaseMessaging();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdateBackground();
      subscribe(context, 'initState_PostFrameCallback');
    });

    startTimer();

    _searchFilterController = new TextEditingController();

    screenSearch = ScreenSearch(
      key: UniqueKey(),
      visibilityNotifier: _visibilityNotifiers?.elementAt(Tabs.Search.index),
    );
    screenHome = ScreenHome(
      _wrapperHomeNotifier,
      key: UniqueKey(),
      visibilityNotifier: _visibilityNotifiers?.elementAt(Tabs.Home.index),
    );
    /*
    COLLECTION_SUMMARY 	  = COLLECTION + TYPE_SUMMARY; 			// "IDX.SUMMARY";
    COLLECTION_INDICES 	  = COLLECTION + TYPE_INDICES; 			// "IDX.INDICES";
    COLLECTION_ORDERBOOK 	= COLLECTION + TYPE_ORDERBOOK; 		// "IDX.ORDERBOOK";
    COLLECTION_STOCK_FD	  = COLLECTION + TYPE_STOCK_FD; 		// "IDX.STOCK_FD";
    COLLECTION_TRADEBOOK 	= COLLECTION + TYPE_TRADEBOOK; 		// "IDX.TRADEBOOK";


    HASH_SUMMARY 		    = HASH + TYPE_SUMMARY; 		// "HASH.SUMMARY";
    HASH_ORDERBOOK		  = HASH + TYPE_ORDERBOOK; 		// "HASH.ORDERBOOK";
    HASH_TRADEBOOK		  = HASH + TYPE_TRADEBOOK; 		// "HASH.TRADEBOOK";
    HASH_INDICES 		    = HASH + TYPE_INDICES; 		// "HASH.INDICES";
    HASH_INDICES_STOCK	= HASH + TYPE_INDICES_STOCK; 	// "HASH.INDICES_STOCK";
    HASH_STATUS 		    = HASH + TYPE_STATUS; 		// "HASH.STATUS";
    HASH_STOCK_FD		    = HASH + TYPE_STOCK_FD; 		// "HASH.STOCK_FD";
    HASH_COMPOSITE_FD	  = HASH + TYPE_COMPOSITE_FD; 	// "HASH.COMPOSITE_FD";
    HASH_ORDER			    = HASH + TYPE_ORDER; 			// "HASH.ORDER";

    KEY_SUMMARY		      = KEY + TYPE_SUMMARY; 		// "IDX.SUMMARY";
    KEY_ORDERBOOK 		  = KEY + TYPE_ORDERBOOK; 		// "IDX.ORDERBOOK";
    KEY_TRADEBOOK 		  = KEY + TYPE_TRADEBOOK; 		// "IDX.TRADEBOOK";
    KEY_INDICES 		    = KEY + TYPE_INDICES; 		// "IDX.INDICES";
    KEY_INDICES_STOCK	  = KEY + TYPE_INDICES_STOCK; 	// "IDX.INDICES_STOCK";
    KEY_STATUS			    = KEY + TYPE_STATUS; 			// "IDX.STATUS";
    KEY_STOCK_FD		    = KEY + TYPE_STOCK_FD; 		// "IDX.STOCK_FD";
    KEY_COMPOSITE_FD	  = KEY + TYPE_COMPOSITE_FD; 	// "IDX.COMPOSITE_FD";
    KEY_STOCK 			    = KEY + TYPE_STOCK; 			// "IDX.STOCK";
    KEY_BROKER 		      = KEY + TYPE_BROKER; 			// "IDX.BROKER";
    KEY_TRADE 			    = KEY + TYPE_TRADE; 			// "IDX.TRADE";
    KEY_ORDER			      = KEY + TYPE_ORDER; 			// "IDX.ORDER";
    */
    //connnectRedis();

    // final futureStockBrokerIndex = updateStockBrokerIndex();
    // futureStockBrokerIndex.then((value) {
    //   notifierStockBrokerIndex.value = value;
    // }).onError((error, stackTrace) {
    //
    // }).whenComplete(() {
    //
    // });

    /*
    // orientation -------
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    // -------------------

     */
  }

  VoidCallback? menuChangeListener;
  VoidCallback? onPinTimeout;

  //VoidCallback subscriptionChangeListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ScreenMain.didChangeDependencies ');
    DebugWriter.info('ScreenMain.didChangeDependencies ' +
        context.read(dataHolderChangeNotifier).user.toString());
    /*
    if(subscriptionChangeListener != null){
      context.read(subscriptionDatafeedChangeNotifier).removeListener(subscriptionChangeListener);
    }else{
      subscriptionChangeListener = (){
        if(mounted){
          subcribeDatafeed();
        }
      };
    }
    context.read(subscriptionDatafeedChangeNotifier).addListener(subscriptionChangeListener);
    */
    Future<List<Watchlist>> savedWatchlist = Watchlist.load();
    savedWatchlist.then((value) {
      context.read(watchlistChangeNotifier).clear();
      value.forEach((watchlist) {
        context.read(watchlistChangeNotifier).addWatchlist(watchlist);
      });
    }).onError((error, stackTrace) {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'Can\'t load watchlist ');
      print('Can\'t load watchlist ');
      print(error);
    });

    if (menuChangeListener != null) {
      context.read(mainMenuChangeNotifier).removeListener(menuChangeListener!);
    } else {
      menuChangeListener = () {
        if (!mounted) {
          print(
              'ScreenMain.menuChangeListener aborted, caused by widget mounted : ' +
                  mounted.toString());
          return;
        }
        Tabs mainTab = context.read(mainMenuChangeNotifier).mainTab;
        //int subTab = context.read(mainMenuChangeNotifier).subTab;
        if (mainTab != _selectedTab) {
          _onBottomTabClicked(mainTab.index);
        }
      };
    }
    context.read(mainMenuChangeNotifier).addListener(menuChangeListener!);
    //context.read(amendChangeNotifier).getData(orderType).setStock(stock.code, stock.name);

    if (onPinTimeout != null) {
      context.read(propertiesNotifier).removeListener(onPinTimeout!);
    } else {
      onPinTimeout = () {
        if (mounted) {
          /*
          Navigator.of(context).removeRoute(CupertinoPageRoute(
            builder: (_) => ScreenTrade(OrderType.Unknown), //PriceLot(close, 0)
            settings: RouteSettings(name: '/trade'),
          ));
          */
          //Navigator.of(context).popUntil((route) => route.isFirst);
          InvestrendTheme.backToScreenMainAndShowTabScreen(
              context, Tabs.Home, 0);
          InvestrendTheme.of(context)
              .showSnackBar(context, 'pin_is_timeout'.tr());
        }
      };
    }
    context.read(propertiesNotifier).addListener(onPinTimeout!);
  }

  @override
  void dispose() {
    print('ScreenMain.dispose ');
    //timer?.cancel();
    stopTimer();

    //disconnnectRedis();
    _wrapperHomeNotifier.dispose();
    notifierStockBrokerIndex.dispose();
    _searchFilterController?.dispose();
    final container = ProviderContainer();

    if (menuChangeListener != null) {
      container
          .read(mainMenuChangeNotifier)
          .removeListener(menuChangeListener!);
    }
    menuChangeListener = null;

    if (onPinTimeout != null) {
      container.read(propertiesNotifier).removeListener(onPinTimeout!);
    }
    onPinTimeout = null;

    for (int i = 0; i < _visibilityNotifiers!.length; i++) {
      _visibilityNotifiers?.elementAt(i).dispose();
    }
    /*
    // orientation -------
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // -------------------
    */
    super.dispose();
  }

  //int _selectedIndex = 0;
  Tabs _selectedTab = Tabs.Home;

  void _onBottomTabClicked(int index) {
    context.read(mainTabNotifier).setIndex(index);

    _selectedTab = Tabs.values[index];

    setState(() {
      //_selectedIndex = index;
      //_selectedTab = Tabs.values[index];

      // notify child is active
      for (int i = 0; i < _visibilityNotifiers!.length; i++) {
        BaseValueNotifier? childNotifier = _visibilityNotifiers?.elementAt(i);
        if (_selectedTab.index == i) {
          if (childNotifier != null) {
            childNotifier.value = true;
          }
        } else {
          if (childNotifier != null) {
            childNotifier.value = false;
          }
        }
      }
    });
  }

  Languages? _selectionLanguage;

  Widget createBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'images/tabs_bottom/tab_beranda.png',
            color:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          ),
          activeIcon: Image.asset(
            'images/tabs_bottom/tab_beranda_active.png',
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          label: 'tab_bottom_home_title'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'images/tabs_bottom/tab_pencarian.png',
            color:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          ),
          activeIcon: Image.asset(
            'images/tabs_bottom/tab_pencarian_active.png',
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          label: 'tab_bottom_search_title'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'images/tabs_bottom/tab_portfolio.png',
            color:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          ),
          activeIcon: Image.asset(
            'images/tabs_bottom/tab_portfolio_active.png',
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          label: 'tab_bottom_portfolio_title'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'images/tabs_bottom/tab_transaksi.png',
            color:
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          ),
          activeIcon: Image.asset(
            'images/tabs_bottom/tab_transaksi_active.png',
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          label: 'tab_bottom_transaction_title'.tr(),
        ),

        // HIDE for Audit
        /*
        BottomNavigationBarItem(
          icon: Image.asset(
            'images/tabs_bottom/tab_komunitas.png',
            color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          ),
          activeIcon: Image.asset(
            'images/tabs_bottom/tab_komunitas_active.png',
            color: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          ),
          label: 'tab_bottom_community_title'.tr(),
        ),
        */
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedTab.index,
      //backgroundColor: ThemeData.,
      // selectedItemColor: Color(0xFF5414DB),
      // unselectedItemColor: Color(0xFFCFCFCF),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: _onBottomTabClicked,
    );
  }

  PreferredSizeWidget _appBarHome(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return AppBar(
      //backgroundColor: Theme.of(context).backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,

      leading: AppBarActionIcon(
        'images/icons/action_bell.png',
        () {
          // final snackBar = SnackBar(content: Text('Action Bell clicked. tab : ' + _selectedTab.index.toString()));
          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //InvestrendTheme.push(context, ScreenNotification(), ScreenTransition.SlideRight, '/notification');

          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ScreenNotification(),
                settings: RouteSettings(name: '/notification'),
              ));
        },
      ),

      /*
      leading: IconButton(
        //icon: Image.asset('images/icons/action_bell.png', color: Theme.of(context).accentIconTheme.color),
        icon: ComponentCreator.appBarImageAsset(context, 'images/icons/action_bell.png'),
        //onPressed: () => Navigator.of(context).pop(),
        onPressed: () {
          final snackBar = SnackBar(content: Text('Action Bell clicked. tab : ' + _selectedTab.index.toString()));

          // Find the ScaffoldMessenger in the widget tree
          // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
      ),
      */
      title: Image.asset(
        InvestrendTheme.of(context).ic_launcher!,
        //color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      actions: [
        /*
        PopupMenuButton<Languages>(
          icon: Icon(
            Icons.flag,
            color: Theme.of(context).appBarTheme.foregroundColor,
            semanticLabel: 'Text to announce in accessibility modes',
          ),
          onSelected: (Languages result) {
            setState(() {
              _selectionLanguage = result;
              if (_selectionLanguage == Languages.Indonesia) {
                EasyLocalization.of(context).setLocale(Locale('id'));
                print('Set Indonesia');
              } else {
                EasyLocalization.of(context).setLocale(Locale('en'));
                print('Set Inggris');
              }
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Languages>>[
            const PopupMenuItem<Languages>(
              value: Languages.Indonesia,
              child: Text('Indonesia'),
            ),
            const PopupMenuItem<Languages>(
              value: Languages.English,
              child: Text('English'),
            ),
          ],
        ),
        */
        AppBarActionIcon('images/icons/action_bell.png', () {
          // InvestrendTheme.push(context, TradingViewChart(),
          //     ScreenTransition.Fade, 'tradingViewChart');
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ))
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => TradingViewChartPage(),
              settings: RouteSettings(name: '/tradingViewChart'),
            ),
          );
        }),
        AppBarActionIcon('images/icons/action_search.png', () {
          FocusScope.of(context).requestFocus(new FocusNode());
          final result = InvestrendTheme.showFinderScreen(context);
          result.then((value) {
            if (value == null) {
              print('result finder = null');
            } else if (value is Stock) {
              print('result finder = ' + value.code!);
              //InvestrendTheme.of(context).stockNotifier.setStock(value);

              context.read(primaryStockChangeNotifier).setStock(value);

              InvestrendTheme.of(context).showStockDetail(context);
            } else if (value is People) {
              print('result finder = ' + value.name!);
            }
          });
        }),
        /*
        IconButton(
          //icon: Image.asset('images/icons/action_search.png', color: Theme.of(context).accentIconTheme.color),
          icon: ComponentCreator.appBarImageAsset(context, 'images/icons/action_search.png'),
          //onPressed: () => Navigator.of(context).pop(),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            final result = InvestrendTheme.showFinderScreen(context);
            result.then((value) {

              if(value == null){
                print('result finder = null');
              }else if(value is Stock){
                print('result finder = '+value.code);
                InvestrendTheme.of(context).stockNotifier.setStock(value);
                showStockDetail(context);

              }else if(value is People){
                print('result finder = '+value.name);
              }
            });
          },
        ),
        */
        /*
        AvatarButton(
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
          onPressed: () {
            //final snackBar = SnackBar(content: Text('Action Profile clicked. tab : ' + _selectedTab.index.toString()));

            // Find the ScaffoldMessenger in the widget tree
            // and use it to show a SnackBar.
            //ScaffoldMessenger.of(context).showSnackBar(snackBar);

            Navigator.push(context, CupertinoPageRoute(
              builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));

          },
        ),
        */
        /*
        AvatarProfileButton(
          url: 'http://' +InvestrendTheme.tradingHttp.tradingBaseUrl +'/getpic?username=' +context.read(dataHolderChangeNotifier).user.username +'&url=',
          fullname: context.read(dataHolderChangeNotifier).user.realname,
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(
              builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));
          },
        ),
        */
        /*
        Padding(
          padding: const EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
          child: Consumer(builder: (context, watch, child) {
            final notifier = watch(avatarChangeNotifier);
            return AvatarProfileButton(
              url: notifier.url,
              fullname: context.read(dataHolderChangeNotifier).user.realname,
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(
                  builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));
              },
            );
          }),
        ),
        */
        AppBarConnectionStatus(
          child: Padding(
            padding: const EdgeInsets.only(
                right: InvestrendTheme.cardPaddingGeneral),
            child: Consumer(builder: (context, watch, child) {
              final notifier = watch(avatarChangeNotifier);
              return AvatarProfileButton(
                url: notifier.url,
                fullname: context.read(dataHolderChangeNotifier).user.realname!,
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ScreenProfile(),
                        settings: RouteSettings(name: '/profile'),
                      ));
                },
              );
            }),
          ),
        ),

        /*
        AvatarIconProfile(
          //imageUrl: 'http://103.109.155.226:8888/getpic?username='+context.read(dataHolderChangeNotifier).user.username+'&url=',
          imageUrl:
              InvestrendTheme.tradingHttp.tradingBaseUrl + '/getpic?username=' + context.read(dataHolderChangeNotifier).user.username + '&url=',
          label: StringUtils.getFirstDigitNameTwo(context.read(dataHolderChangeNotifier).user.realname).toUpperCase(),
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return AccountBottomSheet();
                });
          },
        ),
        */
      ],
    );
  }

  PreferredSizeWidget _appBarPortfolio(BuildContext context) {
    // Map<String, String> headersMap = {
    //   'accesstoken' : context.read(dataHolderChangeNotifier).user.token.access_token;
    // };
    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    AppBar appBar = AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'title_portfolio'.tr(),
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      leading: hasAccount
          ? ButtonAccount(
              shortDisplay: true,
            )
          : null,
      actions: [
        AppBarActionIcon('images/icons/action_search.png', () {
          FocusScope.of(context).requestFocus(new FocusNode());
          final result = InvestrendTheme.showFinderScreen(context);
          result.then((value) {
            if (value == null) {
              print('result finder = null');
            } else if (value is Stock) {
              print('result finder = ' + value.code!);
              //InvestrendTheme.of(context).stockNotifier.setStock(value);

              context.read(primaryStockChangeNotifier).setStock(value);

              InvestrendTheme.of(context).showStockDetail(context);
            } else if (value is People) {
              print('result finder = ' + value.name!);
            }
          });
        }),
        /*
        Padding(
          padding: const EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
          child: Consumer(builder: (context, watch, child) {
            final notifier = watch(avatarChangeNotifier);
            return AvatarProfileButton(
              url: notifier.url,
              fullname: context.read(dataHolderChangeNotifier).user.realname,
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(
                  builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));
              },
            );
          }),
        ),
        */

        AppBarConnectionStatus(
          child: Padding(
            padding: const EdgeInsets.only(
                right: InvestrendTheme.cardPaddingGeneral),
            child: Consumer(builder: (context, watch, child) {
              final notifier = watch(avatarChangeNotifier);
              return AvatarProfileButton(
                url: notifier.url,
                fullname: context.read(dataHolderChangeNotifier).user.realname!,
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ScreenProfile(),
                        settings: RouteSettings(name: '/profile'),
                      ));
                },
              );
            }),
          ),
        ),
      ],
    );
    return appBar;
    /*
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      elevation: 0.0,
      shadowColor: Theme.of(context).shadowColor,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'title_portfolio'.tr(),
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      leading: hasAccount ? ButtonAccount(shortDisplay: true,) : null,
      actions: [
        AppBarActionIcon('images/icons/action_search.png', () {
          FocusScope.of(context).requestFocus(new FocusNode());
          final result = InvestrendTheme.showFinderScreen(context);
          result.then((value) {
            if (value == null) {
              print('result finder = null');
            } else if (value is Stock) {
              print('result finder = ' + value.code);
              //InvestrendTheme.of(context).stockNotifier.setStock(value);

              context.read(primaryStockChangeNotifier).setStock(value);

              InvestrendTheme.of(context).showStockDetail(context);
            } else if (value is People) {
              print('result finder = ' + value.name);
            }
          });
        }),
        Consumer(builder: (context, watch, child) {
          final notifier = watch(avatarChangeNotifier);
          return AvatarProfileButton(
            url: notifier.url,
            fullname: context.read(dataHolderChangeNotifier).user.realname,
            onPressed: () {
              Navigator.push(context, CupertinoPageRoute(
                builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));
            },
          );
        }),
      ],
    );
    */
  }

  PreferredSizeWidget _appBarTransaction(BuildContext context) {
    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;

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
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: AppBarTitleText('title_transaction'.tr()),
      // title: Text(
      //   'title_transaction'.tr(),
      //   style: Theme.of(context).appBarTheme.titleTextStyle,
      // ),
      leading: hasAccount
          ? ButtonAccount(
              shortDisplay: true,
            )
          : null,
      actions: [
        AppBarActionIcon(
          'images/icons/action_search.png',
          () {
            FocusScope.of(context).requestFocus(new FocusNode());
            final result = InvestrendTheme.showFinderScreen(context);
            result.then((value) {
              if (value == null) {
                print('result finder = null');
              } else if (value is Stock) {
                print('result finder = ' + value.code!);
                //InvestrendTheme.of(context).stockNotifier.setStock(value);

                context.read(primaryStockChangeNotifier).setStock(value);

                InvestrendTheme.of(context).showStockDetail(context);
              } else if (value is People) {
                print('result finder = ' + value.name!);
              }
            });
          },
        ),
        /*
        Padding(
          padding: const EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
          child: Consumer(builder: (context, watch, child) {
            final notifier = watch(avatarChangeNotifier);
            return AvatarProfileButton(
              url: notifier.url,
              fullname: context.read(dataHolderChangeNotifier).user.realname,
              onPressed: () {

                Navigator.push(context, CupertinoPageRoute(
                  builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));
                /*
                updateAccountCashPosition(context);
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                    ),
                    //backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return AccountBottomSheet();
                    });
                */
              },
            );
          }),
        ),
        */
        AppBarConnectionStatus(
          child: Padding(
            padding: const EdgeInsets.only(
                right: InvestrendTheme.cardPaddingGeneral),
            child: Consumer(builder: (context, watch, child) {
              final notifier = watch(avatarChangeNotifier);
              return AvatarProfileButton(
                url: notifier.url,
                fullname: context.read(dataHolderChangeNotifier).user.realname!,
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ScreenProfile(),
                        settings: RouteSettings(name: '/profile'),
                      ));
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _appBarCommunity(BuildContext context) {
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
      centerTitle: true,
      leading: AppBarActionIcon(
        'images/icons/action_bell.png',
        //onPressed: () => Navigator.of(context).pop(),
        () {
          //InvestrendTheme.push(context, ScreenNotification(), ScreenTransition.SlideRight, '/notification');

          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ScreenNotification(),
                settings: RouteSettings(name: '/notification'),
              ));
        },
      ),
      title: Image.asset(
        InvestrendTheme.of(context).ic_launcher!,
        //color: Theme.of(context).accentColor,
        //color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      actions: [
        AppBarActionIcon(
          'images/icons/action_search.png',
          //onPressed: () => Navigator.of(context).pop(),
          () {
            FocusScope.of(context).requestFocus(new FocusNode());
            final result = InvestrendTheme.showFinderScreen(context);

            result.then((value) {
              if (value == null) {
                print('result finder = null');
              } else if (value is Stock) {
                print('result finder = ' + value.code!);
                //InvestrendTheme.of(context).stockNotifier.setStock(value);

                context.read(primaryStockChangeNotifier).setStock(value);

                InvestrendTheme.of(context).showStockDetail(context);

                InvestrendTheme.of(context).showStockDetail(context);
              } else if (value is People) {
                print('result finder = ' + value.name!);
              }
            });
          },
        ),
        /*
        AvatarButton(
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU',
          onPressed: () {
            //final snackBar = SnackBar(content: Text('Action Profile clicked. tab : ' + _selectedTab.index.toString()));

            // Find the ScaffoldMessenger in the widget tree
            // and use it to show a SnackBar.
            //ScaffoldMessenger.of(context).showSnackBar(snackBar);

            Navigator.push(context, CupertinoPageRoute(
              builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));
          },
        ),
        */
        /*
        AvatarProfileButton(
          url: 'http://' +InvestrendTheme.tradingHttp.tradingBaseUrl +'/getpic?username=' +context.read(dataHolderChangeNotifier).user.username +'&url=',
          fullname: context.read(dataHolderChangeNotifier).user.realname,
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(
              builder: (_) => ScreenProfile(), settings: RouteSettings(name: '/profile'),));
          },
        ),
        */

        Padding(
          padding:
              const EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
          child: Consumer(builder: (context, watch, child) {
            final notifier = watch(avatarChangeNotifier);
            return AvatarProfileButton(
              url: notifier.url,
              fullname: context.read(dataHolderChangeNotifier).user.realname!,
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ScreenProfile(),
                      settings: RouteSettings(name: '/profile'),
                    ));
              },
            );
          }),
        ),

        /*
        AvatarIconProfile(
          //imageUrl: 'http://103.109.155.226:8888/getpic?username='+context.read(dataHolderChangeNotifier).user.username+'&url=',
          imageUrl:
              InvestrendTheme.tradingHttp.tradingBaseUrl + '/getpic?username=' + context.read(dataHolderChangeNotifier).user.username + '&url=',
          label: StringUtils.getFirstDigitNameTwo(context.read(dataHolderChangeNotifier).user.realname).toUpperCase(),
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return AccountBottomSheet();
                });
          },
        ),
        */
      ],
    );
  }

  PreferredSizeWidget _appBarSearch(BuildContext context) {
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
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Hero(
        tag: 'finder_field',
        child: Material(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            alignment: Alignment.center,
            height: InvestrendTheme.appBarHeight,
            child: ComponentCreator.textFieldSearch(context),
            /*
            child: TextField(
              style: Theme.of(context).textTheme.bodyText1,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                final result = InvestrendTheme.showFinderScreen(context);
                result.then((value) {
                  if (value == null) {
                    print('result finder = null');
                  } else if (value is Stock) {
                    //InvestrendTheme.of(context).stockNotifier.setStock(value);

                    context.read(primaryStockChangeNotifier).setStock(value);
                    InvestrendTheme.of(context).showStockDetail(context);
                    print('result finder = ' + value.code);
                  } else if (value is People) {
                    print('result finder = ' + value.name);
                  }
                });
              },
              decoration: new InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                border: new OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                enabledBorder: new OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                focusedBorder: new OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                filled: true,
                prefixIcon: new Icon(
                  Icons.search,
                  //color: InvestrendTheme.of(context).textGrey,
                  color: InvestrendTheme.of(context).appBarActionTextColor,
                  size: 25.0,
                ),
                hintText: 'title_search_hint'.tr(),
                fillColor: InvestrendTheme.of(context).tileBackground,
              ),
            ),
            */
          ),
        ),
      ),
    );
  }

  /*
  Widget createBody(BuildContext context) {
    switch (_selectedTab) {
      case Tabs.Home:
        {
          //return ScreenHome(key:homeKey);
          return screenHome;
        }
      case Tabs.Search:
        {
          //return ScreenSearch(key: searchKey,);
          return screenSearch;
        }
      case Tabs.Portfolio:
        {
          //return ScreenPortfolio(key: portfolioKey,);
          return screenPortfolio;
        }
      case Tabs.Transaction:
        {
          //return ScreenTransaction(key: transactionKey,);
          return screenTransaction;
        }
      case Tabs.Community:
        {
          //return ScreenCommunity(key: communityKey,);
          return screenCommunity;
        }
    }
    return Container(
      color: Colors.blue,
      child: Text('No Screen based on Tabs'),
    );
  }
  */

  Widget createBody(BuildContext context, double paddingBottom) {
    // String test = InvestrendTheme.formatNewComma(-123456789.012345);
    // print('formatNewComma : $test');
    switch (_selectedTab) {
      case Tabs.Home:
        {
          //return ScreenHome(key:homeKey);
          return screenHome!;
          //return ScreenHome(_wrapperHomeNotifier, key: UniqueKey(), visibilityNotifier: _visibilityNotifiers.elementAt(Tabs.Home.index),);
        }
      case Tabs.Search:
        {
          //return ScreenSearch(key: searchKey,);
          // return ScreenSearch(key: UniqueKey(), visibilityNotifier: _visibilityNotifiers.elementAt(Tabs.Search.index),);
          return screenSearch!;
        }
      case Tabs.Portfolio:
        {
          //return ScreenPortfolio(key: portfolioKey,);
          return screenPortfolio;
        }
      case Tabs.Transaction:
        {
          //return ScreenTransaction(key: transactionKey,);
          return screenTransaction;
        }
      case Tabs.Community:
        {
          //return ScreenCommunity(key: communityKey,);
          return screenCommunity;
        }
    }
    /*
    return Container(
      color: Colors.blue,
      child: Text('No Screen based on Tabs'),
    );
    */
  }

  /*
  Future <Object> showFinderScreen() {
    return Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),

        pageBuilder: (context, animation1, animation2) => ScreenFinder(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimationCreator.transitionSlideUp(context, animation, secondaryAnimation, child);
        },
      ),
    );
  }
  */
  /*
  Future <Object> showFinderScreen() async{
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),

        pageBuilder: (context, animation1, animation2) => ScreenFinder(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimationCreator.transitionSlideUp(context, animation, secondaryAnimation, child);
        },
      ),
    );
    if(result != null){
      if(result is People){
        print('result People : '+result.name+' selected by user');
      }else if(result is Stock){
        print('result Stock : '+result.code+' selected by user');
      }else{
        print('result Unknown '+result.toString());
      }
    }else{
      print('result NULL maybe canceled by user');
    }
    return result;
  }
  */
  // void showStockDetail(BuildContext context) {
  //   //InvestrendTheme.push(context, ScreenStockDetail(), ScreenTransition.SlideLeft, '/stock_detail');
  //
  //
  //   Navigator.push(context, CupertinoPageRoute(
  //     builder: (_) => ScreenStockDetail(), settings: RouteSettings(name: '/stock_detail'),));
  //
  //   /*
  //   Navigator.push(
  //     context,
  //     PageRouteBuilder(
  //         transitionDuration: Duration(milliseconds: 1000),
  //         pageBuilder: (context, animation1, animation2) => ScreenStockDetail(),
  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //           return AnimationCreator.transitionSlideLeft(
  //               context, animation, secondaryAnimation, child);
  //         }),
  //   );
  //
  //    */
  // }

  Future<Map>? updateStockBrokerIndex() {
    //final _prefs = await SharedPreferences.getInstance();
    // Try reading data from the key. If it doesn't exist, return empty string.

    print('updateStockBrokerIndex');

    MD5StockBrokerIndex? md5 = InvestrendTheme.storedData?.md5;
    if (md5 != null) {
      //futureStockBrokerIndex = HttpSSI.fetchStockBrokerIndex(md5.md5broker, md5.md5stock, md5.md5index);
      return InvestrendTheme.datafeedHttp
          .fetchStockBrokerIndex(md5.md5broker!, md5.md5stock!, md5.md5index!);
    } else {
      print('error md5 is null');
    }
    return null;
  }

  @override
  PreferredSizeWidget createAppBar(BuildContext context) {
    switch (_selectedTab) {
      case Tabs.Home:
        {
          return _appBarHome(context);
        }
      case Tabs.Search:
        {
          return _appBarSearch(context);
        }
      case Tabs.Portfolio:
        {
          return _appBarPortfolio(context);
        }
      case Tabs.Transaction:
        {
          return _appBarTransaction(context);
        }
      case Tabs.Community:
        {
          return _appBarCommunity(context);
        }
    }
    // return Container(
    //   color: Colors.blue,
    //   child: Text('No Appbar based on Tabs'),
    // ) as PreferredSizeWidget;
  }

  void updateAccountCashPosition(BuildContext context) {
    int accountSize = context.read(dataHolderChangeNotifier).user.accountSize();
    if (accountSize > 0) {
      List<String> listAccountCode = List.empty(growable: true);
      // InvestrendTheme.of(context).user.accounts.forEach((account) {
      //   listAccountCode.add(account.accountcode);
      // });
      context.read(dataHolderChangeNotifier).user.accounts?.forEach((account) {
        listAccountCode.add(account.accountcode);
      });

      print(routeName + ' try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp
          .accountStockPosition(
              '' /*account.brokercode*/,
              listAccountCode,
              context.read(dataHolderChangeNotifier).user.username!,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((List<AccountStockPosition>? value) {
        // DebugWriter.information(routeName +
        //     ' Got accountStockPosition  accountStockPosition.size : ' +
        //     value.length.toString());
        if (!mounted) {
          print(
              routeName + ' accountStockPosition ignored.  mounted : $mounted');
          return;
        }
        AccountStockPosition? first =
            (value != null && value.length > 0) ? value.first : null;
        if (first != null && first.ignoreThis()) {
          // ignore in aja
          print(routeName +
              ' accountStockPosition ignored.  message : ' +
              first.message);
        } else {
          context.read(accountsInfosNotifier).updateList(value);
          Account? activeAccount = context
              .read(dataHolderChangeNotifier)
              .user
              .getAccount(context.read(accountChangeNotifier).index);
          if (activeAccount != null) {
            AccountStockPosition? accountInfo = context
                .read(accountsInfosNotifier)
                .getInfo(activeAccount.accountcode);
            if (accountInfo != null) {
              //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.rdnBalance);
              //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.cashBalance);
              context.read(buyRdnBuyingPowerChangeNotifier).update(
                  accountInfo.outstandingLimit,
                  accountInfo.availableCash,
                  accountInfo.creditLimit);
            }
          }
        }
      }).onError((error, stackTrace) {
        DebugWriter.information(routeName +
            ' accountStockPosition Exception : ' +
            error.toString());
        /*
        if(error is TradingHttpException){
          if(error.isUnauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label  = network_error_label.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }
        */
        handleNetworkError(context, error);
        /*
        if(error is TradingHttpException){
          if(error.isUnauthorized()){
            InvestrendTheme.of(context).showDialogInvalidSession(context);
            return;
          }else if(error.isErrorTrading()){
            InvestrendTheme.of(context).showSnackBar(context, error.message());
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }else{
          InvestrendTheme.of(context).showSnackBar(context, error.toString());
          return;
        }
        */
      });
    }
  }

  @override
  void onActive() {
    //if(redisClient == null || redisPubSub == null){
    //connnectRedis(context);
    //}
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if(mounted){
    updateAccountCashPosition(context);
    //   }
    // });

    for (int i = 0; i < _visibilityNotifiers!.length; i++) {
      BaseValueNotifier? childNotifier = _visibilityNotifiers?.elementAt(i);
      if (_selectedTab.index == i) {
        if (childNotifier != null) {
          childNotifier.value = true;
        }
      } else {
        if (childNotifier != null) {
          childNotifier.value = false;
        }
      }
    }
  }

  @override
  void onInactive() {
    //disconnnectRedis();
    if (mounted) {
      for (int i = 0; i < _visibilityNotifiers!.length; i++) {
        BaseValueNotifier? childNotifier = _visibilityNotifiers?.elementAt(i);
        if (childNotifier != null && !childNotifier.isDiposed) {
          childNotifier.value = false;
        }
      }
    }
  }

  PsubscribeAndHGET? subscribeSingleSignOn;

  SubscribeAndGET? subscribeSystemEvent;
  SubscribeAndGET? subscribeStatus;
  void unsubscribe(BuildContext context, String caller) {
    if (subscribeSingleSignOn != null) {
      print(routeName + ' unsubscribe : ' + subscribeSingleSignOn!.channel!);
      context
          .read(managerEventNotifier)
          .punsubscribe(subscribeSingleSignOn!, routeName + '.' + caller);
      subscribeSingleSignOn = null;
    }

    if (subscribeSystemEvent != null) {
      print(routeName + ' unsubscribe : ' + subscribeSystemEvent!.channel!);
      context
          .read(managerEventNotifier)
          .unsubscribe(subscribeSystemEvent!, routeName + '.' + caller);
      subscribeSystemEvent = null;
    }

    if (subscribeStatus != null) {
      print(routeName + ' unsubscribe : ' + subscribeStatus!.channel!);
      context
          .read(managerEventNotifier)
          .unsubscribe(subscribeStatus!, routeName + '.' + caller);
      subscribeStatus = null;
    }
  }

  void subscribe(BuildContext context, String caller) {
    //String codeBoard = stock.code + '.' + stock.defaultBoard;
    String username = context.read(dataHolderChangeNotifier).user.username!;
    //String channel = DatafeedType.SingleSignON.key + '.' + username ;
    String channel = DatafeedType.SingleSignON.key + '.*|' + username + '|*';

    //context.read(stockSummaryChangeNotifier).setStock(stock);

    subscribeSystemEvent = SubscribeAndGET('SYS', 'SYS', listener: (message) {
      String HEADER = message[0]; // BOT
      String TYPE = message[1]; // EXIT
      String time = message[2]; // time
      String information = message[3]; // message

      //String tokenNew = message.elementAt(0);
      print(routeName +
          ' got SystemEvent $channel  time $time : $TYPE  --> $information');
      print(message);
      if (mounted) {
        if (HEADER == 'BOT' && TYPE == 'EXIT') {
          InvestrendTheme.of(context).showDialogLogout(context,
              message: information, title: 'system_event_title'.tr());
        }
      }
      return '';
    }, validator: validatorSystemEvent);
    print(routeName + ' subscribe : ' + subscribeSystemEvent!.channel!);
    context
        .read(managerEventNotifier)
        .subscribe(subscribeSystemEvent!, routeName + '.' + caller);

    subscribeSingleSignOn = PsubscribeAndHGET(
        channel, DatafeedType.SingleSignON.collection, username,
        listener: (message) {
      String HEADER = message[0];
      String TYPE = message[1];
      String time = message[2];

      //String tokenNew = message.elementAt(0);
      print(
          routeName + ' got SingleSignOn $channel  type : $TYPE  time $time ');
      print(message);
      if (mounted) {
        if (HEADER == 'BOT') {
          if (TYPE == 'TOKEN') {
            String tokenNew = message[3];
            String information = message[4];
            print(routeName +
                ' got SingleSignOn $channel  time $time : ' +
                tokenNew);
            String? tokenExisting =
                context.read(dataHolderChangeNotifier).user.token?.access_token;
            if (!StringUtils.equalsIgnoreCase(tokenNew, tokenExisting)) {
              String defaultMessage = 'single_sign_on_message'.tr();
              String defaultTitle = 'single_sign_on_title'.tr();

              information = defaultMessage + '\n\n' + information;
              // Future.delayed(Duration(seconds: 1),(){
              //
              // });
              InvestrendTheme.of(context).showDialogInvalidSession(context,
                  message: information, title: defaultTitle);
            } else {
              String tokenNew = message[3];
              String information = message[4];
              print('SingleSignOn tokenNew : $tokenNew');
              print('SingleSignOn tokenExisting : $tokenExisting');
              print('SingleSignOn information : $information');
            }
          } else if (TYPE == 'STATUS') {
            //  0     1               2           3   4     5
            //[BOT, STATUS, 20220210-10:43:50, ORDER, 13, E108]
            //[BOT, STATUS, 20220210-10:51:30, TRADE, 000000605285, 13, 13, E108]

            //[BOT, STATUS, 20220210-10:43:50, ORDER, E108, 13]
            //[BOT, STATUS, 20220210-10:51:30, TRADE, E108, 13, 13, 000000605285]

            String refreshType = message[3];
            String accountCode = message[4];
            String parentOrderId = message[5];
            String childOrderId = message.length >= 7 ? message[6] : '';
            String tradeNo = message.length >= 8 ? message[7] : '';

            //print(routeName + ' got STATUS refresh  $channel  time $time :   $refresh_type  order_id : $order_id  $account_code' );
            print(routeName +
                ' got STATUS on $channel  refresh_type : $refreshType  $accountCode time : $time   parent_order_id : $parentOrderId  child_order_id : $childOrderId  trade_no : $tradeNo');

            context.read(statusRefreshNotifier).setData(time, refreshType,
                accountCode, parentOrderId, childOrderId, tradeNo);
          }
        }
      }
      return '';
    }, validator: validatorSingleSignOn, receiveUnknownMessage: false);
    print(routeName + ' psubscribe : ' + subscribeSingleSignOn!.channel!);
    context
        .read(managerEventNotifier)
        .psubscribe(subscribeSingleSignOn!, routeName + '.' + caller);

    subscribeStatus =
        SubscribeAndGET(DatafeedType.Status.key, DatafeedType.Status.key,
            listener: (List<String>? message) {
      //print('got : '+message.join('|'));
      // DebugWriter.info('$routeName got status : ' + message.elementAt(1));
      DebugWriter.info(message);
      //[III, C, 15:35:00, Z, Market Close]
      // P = market not yet open
      lastStatus = message?.elementAt(3) ?? '';
      print('lastStatus : $lastStatus');
      return '';
    }, validator: validatorStatus);
    print(routeName + ' subscribe : ' + subscribeStatus!.channel!);
    context
        .read(managerEventNotifier)
        .subscribe(subscribeStatus!, routeName + '.' + caller);
  }

  bool validatorStatus(List<String> data, String channel) {
    //List<String> data = message.split('|');
    if (data.length > 2 && data.first == 'III' && data.elementAt(1) == 'C') {
      return true;
    }
    return false;
  }

  bool validatorSystemEvent(List<String>? data, String channel) {
    if (data != null &&
            data.length >= 4 &&
            StringUtils.equalsIgnoreCase(channel, subscribeSystemEvent!.channel)
        //&& StringUtils.equalsIgnoreCase(channel, subscribeSingleSignOn.channel)
        ) {
      final String HEADER = data[0]; // BOT
      final String TYPE = data[1];
// EXIT

      if (HEADER == 'BOT' && TYPE == 'EXIT') {
        return true;
      }
    }
    return false;
  }

  bool validatorSingleSignOn(List<String>? data, String channel) {
    if (data != null &&
            data.length > 2 &&
            channel.startsWith(DatafeedType.SingleSignON.key)
        //&& StringUtils.equalsIgnoreCase(channel, subscribeSingleSignOn.channel)
        ) {
      final String HEADER = data[0];
      final String TYPE = data[1];
      if (HEADER == 'BOT' && TYPE == 'TOKEN') {
        return true;
      }
    }

    /*
    if (data != null && data.length >= 3 ) {
      final String HEADER = data[0];
      final String TYPE = data[1];
      final String time = data[2];
      final String token = data[3];

      if (HEADER == 'BOT' && TYPE == 'TOKEN' && channel == channelData) {
        return true;
      }
    }
    */
    return false;
  }
}
