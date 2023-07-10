// ignore_for_file: require_trailing_commas


import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
/// Message route arguments.
class MessageArguments {
  /// The RemoteMessage
  final RemoteMessage message;

  /// Whether this message caused the application to open.
  final bool openedApplication;

  final String caller;

  // ignore: public_member_api_docs
  MessageArguments(this.message, this.openedApplication,{this.caller=''});
}


class ScreenMessage extends StatefulWidget {
  final BaseMessage baseMessage;
  final String caller;
  ScreenMessage({Key key, this.baseMessage, this.caller=''}) : super(key: key);

  @override
  _ScreenMessageState createState() => _ScreenMessageState();
}

class _ScreenMessageState extends State<ScreenMessage> {
  String routeName = '/message';


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      reportNotification();
    });
  }

  Future<String> reportNotification() async {

    String notifType = ''; // INBOX  BROADCAST
    String notifId   = ''; // ib_id  bc_id

    //Map map = Map();
    if(widget.baseMessage != null){
      notifType = widget.baseMessage.type(); // INBOX  BROADCAST
      notifId   = widget.baseMessage.id(); // ib_id  bc_id
    }else{
      MessageArguments args;
      RemoteMessage message;
      RemoteNotification notification;
      args = ModalRoute.of(context).settings.arguments as MessageArguments;
      message = args.message;
      notification = message.notification;
      if(message != null && message.data != null && message.data.isNotEmpty){
        //map.addAll(message.data);

        notifType = message.data['type']; // INBOX  BROADCAST
        notifId   = message.data['notif_id']; // ib_id  bc_id
      }
    }
    //'body_lenght|recipient|time|type|notif_id', '29|richy|2021-11-08 22:40:20|INBOX|123'




    MyDevice myDevice = MyDevice();
    await myDevice.load();
    try{

      String deviceId  = myDevice.unique_id;
      if( !StringUtils.isEmtpy(notifType)
          && !StringUtils.isEmtpy(notifId)
          && !StringUtils.isEmtpy(deviceId)
        ){
        final result = await InvestrendTheme.datafeedHttp.reportNotification(notifType, notifId, deviceId,action: 'read');
        if(result != null ){
          print(routeName+' reportNotification got --> '+result.toString());
          return result;
        }
        return 'No Response';
      }else{
        print(routeName + ' reportNotification Invalid  notif_type : $notifType  notif_id : $notifId  device_id : $deviceId');
        return 'Invalid';
      }
    }catch(error){
      print(routeName + ' reportNotification Exception : '+error.toString());
      return 'Exception '+error.toString();
    }

    /*
    try{

      String username= context.read(dataHolderChangeNotifier).user.username;
      String device_id  = myDevice.unique_id;
      String device_platform = InvestrendTheme.of(context).applicationPlatform;
      String fcm_token = token;
      String application_version = InvestrendTheme.of(context).applicationVersion;
      final result = await HttpIII.registerDevice(username, device_id, device_platform, fcm_token, application_version);
      if(result != null){
        print('registerDevice result : $result');
      }else{
        print('registerDevice result : NULL');
      }
    }catch(error){
      print('registerDevice error : '+error.toString());
      print(error);
    }
    */

  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    String body = '';
    String time = '';

    String imageUrl = '';

    String caller = '';
    MessageArguments args;
    RemoteMessage message;
    RemoteNotification notification;

    if(widget.baseMessage != null){
      time      = widget.baseMessage.created_at;
      title     = widget.baseMessage.fcm_title;
      body      = widget.baseMessage.fcm_body;
      imageUrl  = widget.baseMessage.fcm_image_url;
      caller    = widget.caller;
    }else{
      // final MessageArguments args = ModalRoute.of(context).settings.arguments as MessageArguments;
      // RemoteMessage message = args.message;
      // RemoteNotification notification = message.notification;

      args = ModalRoute.of(context).settings.arguments as MessageArguments;
      message = args.message;
      notification = message.notification;
      caller = args.caller;

      if(message.data != null && message.data.isNotEmpty){
        if(message.data.containsKey('time')){
          time = message.data['time'];
        }
      }
      if(message.sentTime != null){
        time = message.sentTime.toLocal().toString();
        //time = DateTime.fromMillisecondsSinceEpoch(message.sentTime.millisecondsSinceEpoch, isUtc: false).toString();
      }
      if (notification != null){
        title = notification.title;
        body = notification.body;

        if (notification.apple != null){
          imageUrl = StringUtils.noNullString(notification.apple.imageUrl);
        }
        if (notification.android != null){
          imageUrl = StringUtils.noNullString(notification.android.imageUrl);
        }
      }
    }

    Widget imageWidget = Image.network(imageUrl,fit: BoxFit.fitWidth,);
    if(StringUtils.isEmtpy(imageUrl)){
      imageWidget = SizedBox(width: 1.0,);
    }else{
      imageWidget = Image.network(imageUrl,fit: BoxFit.fitWidth,);
    }

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: elevation,
        shadowColor: shadowColor,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        //title: Text(message.messageId),
        title: AppBarTitleText('message_label'.tr()),
        // actions: [
        //   TextButton(onPressed: (){}, child: Text(showDebug ? 'Hide' : 'Debug')),
        // ],
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: InvestrendTheme.of(context).regular_w600.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
                SizedBox(height: 8.0,),
                Text(time, style: InvestrendTheme.of(context).more_support_w400_compact,),
                SizedBox(height: InvestrendTheme.cardMargin,),
                imageWidget,
                SizedBox(height: InvestrendTheme.cardMargin,),
                Text(body, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
                SizedBox(height: 80.0,),

                if (!InvestrendTheme.tradingHttp.is_production && widget.baseMessage != null)...[
                  row('caller', caller),
                  row('fcm_android_channel_id', widget.baseMessage.fcm_android_channel_id),
                  row('fcm_android_color', widget.baseMessage.fcm_android_color),
                  row('fcm_data_keys', widget.baseMessage.fcm_data_keys),
                  row('fcm_data_values', widget.baseMessage.fcm_data_values),
                  row('fcm_image_url', widget.baseMessage.fcm_image_url),
                  row('fcm_message_id', widget.baseMessage.fcm_message_id),
                  row('id', widget.baseMessage.id()),
                  row('type', widget.baseMessage.type()),
                  row('sent_at', widget.baseMessage.sent_at),
                  row('read_count', widget.baseMessage.read_count.toString()),
                  // row('xxx', widget.baseMessage.),
                  // row('xxx', widget.baseMessage.),
                  // row('xxx', widget.baseMessage.),
                  // row('xxx', widget.baseMessage.),

                ],

                if (!InvestrendTheme.tradingHttp.is_production && widget.baseMessage == null)...[
                  row('caller', caller),
                  row('Triggered application open',
                      args.openedApplication.toString()),
                  row('Message ID', message.messageId),
                  row('Sender ID', message.senderId),
                  row('Category', message.category),
                  row('Collapse Key', message.collapseKey),
                  row('Content Available', message.contentAvailable.toString()),
                  row('Data', message.data.toString()),
                  row('From', message.from),
                  row('Message ID', message.messageId),
                  row('Sent Time', message.sentTime?.toString()),
                  row('Thread ID', message.threadId),
                  row('Time to Live (TTL)', message.ttl?.toString()),
                  if (notification != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remote Notification',
                            style: TextStyle(fontSize: 18),
                          ),
                          row(
                            'Title',
                            notification.title,
                          ),
                          row(
                            'Body',
                            notification.body,
                          ),
                          if (notification.android != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Android Properties',
                              style: TextStyle(fontSize: 18),
                            ),
                            row(
                              'Channel ID',
                              notification.android.channelId,
                            ),
                            row(
                              'Click Action',
                              notification.android.clickAction,
                            ),
                            row(
                              'Color',
                              notification.android.color,
                            ),
                            row(
                              'Count',
                              notification.android.count?.toString(),
                            ),
                            row(
                              'Image URL',
                              notification.android.imageUrl,
                            ),
                            row(
                              'Link',
                              notification.android.link,
                            ),
                            row(
                              'Priority',
                              notification.android.priority.toString(),
                            ),
                            row(
                              'Small Icon',
                              notification.android.smallIcon,
                            ),
                            row(
                              'Sound',
                              notification.android.sound,
                            ),
                            row(
                              'Ticker',
                              notification.android.ticker,
                            ),
                            row(
                              'Visibility',
                              notification.android.visibility.toString(),
                            ),
                          ],
                          if (notification.apple != null) ...[
                            const Text(
                              'Apple Properties',
                              style: TextStyle(fontSize: 18),
                            ),
                            row(
                              'Subtitle',
                              notification.apple.subtitle,
                            ),
                            row(
                              'Image URL',
                              notification.apple.imageUrl,
                            ),
                            row(
                              'Badge',
                              notification.apple.badge,
                            ),
                            row(
                              'Sound',
                              notification.apple.sound?.name,
                            ),
                          ]
                        ],
                      ),
                    )
                  ]
                ]
              ],
            ),
          )),
    );
  }
  /// A single data row.
  Widget row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: '),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}


/// Displays information about a [RemoteMessage].
class MessageView extends StatelessWidget {
  /// A single data row.
  Widget row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: '),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  //bool showDebug = false;
  @override
  Widget build(BuildContext context) {
    final MessageArguments args =
    ModalRoute.of(context).settings.arguments as MessageArguments;
    RemoteMessage message = args.message;
    RemoteNotification notification = message.notification;
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    String title = '';
    String body = '';
    String time = '';
    if(message.data != null && message.data.isNotEmpty){
      if(message.data.containsKey('time')){
        time = message.data['time'];
      }
    }
    if(message.sentTime != null){
      time = message.sentTime.toLocal().toString();
      //time = DateTime.fromMillisecondsSinceEpoch(message.sentTime.millisecondsSinceEpoch, isUtc: false).toString();
    }
    if (notification != null){
      title = notification.title;
      body = notification.body;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: elevation,
        shadowColor: shadowColor,
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        //title: Text(message.messageId),
        title: AppBarTitleText('message_label'.tr()),
        // actions: [
        //   TextButton(onPressed: (){}, child: Text(showDebug ? 'Hide' : 'Debug')),
        // ],
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: InvestrendTheme.of(context).regular_w600.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
                SizedBox(height: 8.0,),
                Text(time, style: InvestrendTheme.of(context).more_support_w400_compact,),
                SizedBox(height: InvestrendTheme.cardPaddingVertical,),
                Text(body, style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
                SizedBox(height: 80.0,),

                if (!InvestrendTheme.tradingHttp.is_production)...[
                  row('Triggered application open',
                      args.openedApplication.toString()),
                  row('Message ID', message.messageId),
                  row('Sender ID', message.senderId),
                  row('Category', message.category),
                  row('Collapse Key', message.collapseKey),
                  row('Content Available', message.contentAvailable.toString()),
                  row('Data', message.data.toString()),
                  row('From', message.from),
                  row('Message ID', message.messageId),
                  row('Sent Time', message.sentTime?.toString()),
                  row('Thread ID', message.threadId),
                  row('Time to Live (TTL)', message.ttl?.toString()),
                  if (notification != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remote Notification',
                            style: TextStyle(fontSize: 18),
                          ),
                          row(
                            'Title',
                            notification.title,
                          ),
                          row(
                            'Body',
                            notification.body,
                          ),
                          if (notification.android != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Android Properties',
                              style: TextStyle(fontSize: 18),
                            ),
                            row(
                              'Channel ID',
                              notification.android.channelId,
                            ),
                            row(
                              'Click Action',
                              notification.android.clickAction,
                            ),
                            row(
                              'Color',
                              notification.android.color,
                            ),
                            row(
                              'Count',
                              notification.android.count?.toString(),
                            ),
                            row(
                              'Image URL',
                              notification.android.imageUrl,
                            ),
                            row(
                              'Link',
                              notification.android.link,
                            ),
                            row(
                              'Priority',
                              notification.android.priority.toString(),
                            ),
                            row(
                              'Small Icon',
                              notification.android.smallIcon,
                            ),
                            row(
                              'Sound',
                              notification.android.sound,
                            ),
                            row(
                              'Ticker',
                              notification.android.ticker,
                            ),
                            row(
                              'Visibility',
                              notification.android.visibility.toString(),
                            ),
                          ],
                          if (notification.apple != null) ...[
                            const Text(
                              'Apple Properties',
                              style: TextStyle(fontSize: 18),
                            ),
                            row(
                              'Subtitle',
                              notification.apple.subtitle,
                            ),
                            row(
                              'Badge',
                              notification.apple.badge,
                            ),
                            row(
                              'Sound',
                              notification.apple.sound?.name,
                            ),
                          ]
                        ],
                      ),
                    )
                  ]
                ]
              ],
            ),
          )),
    );
  }
}