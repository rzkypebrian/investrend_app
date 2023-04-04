

import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/message.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenNotification extends StatefulWidget {
  const ScreenNotification({Key key}) : super(key: key);

  @override
  _ScreenNotificationState createState() => _ScreenNotificationState();
}

class _ScreenNotificationState extends BaseStateNoTabs<ScreenNotification> {
  _ScreenNotificationState() : super('/notification');
  bool showLoadingFirstTime = true;
  // @override
  // Widget build(BuildContext context) {
  //   return Container();
  // }

  @override
  Widget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return AppBar(
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      backgroundColor: Theme.of(context).backgroundColor,
      title: AppBarTitleText('notification_title'.tr()),
    );
  }

  ScrollController _scrollController;

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 2), curve: Curves.easeInOutQuint);
  }
  void scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // setState(() {
      //   message = "reach the bottom";
      // });
      if(mounted){
        fetchNextPage();
      }
    }
    if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {

      // setState(() {
      //   message = "reach the top";
      // });
    }
  }
  bool showedLastPageInfo = false;
  void fetchNextPage(){
    if(context.read(inboxChangeNotifier).loadingBottom){
      print('scrollListener nextPage onProgress : '+context.read(inboxChangeNotifier).loadingBottom.toString());
      return;
    }
    print('reach the bottom');




    // String next_page_url = context.read(sosmedFeedChangeNotifier).next_page_url;
    // int current_page = context.read(sosmedFeedChangeNotifier).current_page;
    // int last_page = context.read(sosmedFeedChangeNotifier).last_page;
    // if(current_page == last_page){
    String date_next = context.read(inboxChangeNotifier).date_next;
    if(StringUtils.isEmtpy(date_next)){
      if(showedLastPageInfo){
        return;
      }
      showedLastPageInfo = true;
      InvestrendTheme.of(context).showSnackBar(context, 'notification_label_all_retrieved'.tr(), buttonOnPress: _scrollToTop, buttonLabel: 'button_latest_notification'.tr(), buttonColor: Colors.orange, seconds: 5);
      Future.delayed(Duration(seconds: 1),(){
        context.read(sosmedFeedChangeNotifier).showLoadingBottom(false);
      });
      return;
    }
    context.read(sosmedFeedChangeNotifier).showLoadingBottom(true);
    //int next_page = current_page + 1;
    final result = doUpdate(date_next: date_next);

  }
  Future doUpdate({bool pullToRefresh = false, String date_next=''}) async {
    print(routeName + '.doUpdate');
    showedLastPageInfo = false;
    try{
      context.read(inboxChangeNotifier).showLoadingBottom(true);
      //final fetchPost = await SosMedHttp.sosmedFetchPost('123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, page: nextPage, language: EasyLocalization.of(context).locale.languageCode);

      String username = context.read(dataHolderChangeNotifier).user.username;

      final result = await InvestrendTheme.datafeedHttp.fetchInbox(username, date_next);
      if(result != null ){
        print('fetchInbox got --> '+result.count().toString());
        //_pageSize = fetchPost.result.per_page;
        showLoadingFirstTime = false;
        context.read(inboxChangeNotifier).setResult(result);
        // Future.delayed(Duration(seconds: 2),(){
        context.read(inboxChangeNotifier).showLoadingBottom(false);
        // });

      }
    }catch(error){
      print(routeName + '.doUpdate Exception fetchInbox : '+error.toString());
      //context.read(sosmedPostChangeNotifier).showLoadingBottom(false);
      showLoadingFirstTime = false;
      if(mounted){
        //InvestrendTheme.of(context).showSnackBar(context, 'Error : '+error.toString());
        // Future.delayed(Duration(seconds: 2),(){
        //context.read(sosmedPostChangeNotifier).showLoadingBottom(false);
        context.read(inboxChangeNotifier).showRetryBottom(true);
        // });
        handleNetworkError(context, error);
        return;

      }

      // _pagingController.error = error;
    }


    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');

    return true;
  }
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: Consumer(builder: (context, watch, child) {
        final notifier = watch(inboxChangeNotifier);
        // if(notifier.countData() == 0){
        //   return ListView(
        //     //padding: const EdgeInsets.all(InvestrendTheme.cardMargin),
        //     //children: pre_childs,
        //     children: showLoadingFirstTime ? pre_childs_loading : pre_childs,
        //   );
        // }

        int totalCount = notifier.countData() ;
        if(notifier.loadingBottom || notifier.retryBottom){
          totalCount  = totalCount + 1;
        }
        return ListView.builder(
            controller: _scrollController,
            shrinkWrap: false,
            padding: const EdgeInsets.only(/*left: InvestrendTheme.cardMargin, right: InvestrendTheme.cardMargin,*/ top: InvestrendTheme.cardMargin, bottom: (InvestrendTheme.cardMargin + 100.0)),
            //itemCount: notifier.countPost() + pre_childs.length ,
            itemCount:totalCount,
            itemBuilder: (BuildContext context, int index) {
              if(index < notifier.countData()){
                InboxMessage inboxMessage = notifier.datas().elementAt(index);
                if(inboxMessage != null){
                  //return EmptyLabel(text: 'InboxMessage index $index ADA',);
                  //return listTile(context, inboxMessage.created_at, inboxMessage.fcm_title , null, inboxMessage.fcm_body);
                  return listTile(context, inboxMessage);
                }else{
                  return EmptyLabel(text: 'InboxMessage index $index is null',);
                }
                /*
                int indexPost = index - pre_childs.length;
                Post post = notifier.datas().elementAt(indexPost);

                if(post != null){

                  switch(post.postType){
                    case PostType.POLL:
                      {
                        //return CardSocialTextVote(votes, avatarUrl, name, username, label, datetime, text, commentCount, likedCount, comments);
                        return NewCardSocialTextPoll(post, shareClick: (){}, commentClick: ()=>commentClicked(context, post),likeClick:()=> likeClicked(context, post), onTap: ()=>showDetailPost(context, post), key: Key(post.keyString),);
                      }
                      break;
                    case PostType.PREDICTION:
                      {
                        //return CardSocialTextPrediction(prediction, avatarUrl, name, username, label, datetime, text, commentCount, likedCount, comments);
                        return NewCardSocialTextPrediction(post, shareClick: (){}, commentClick: ()=>commentClicked(context, post),likeClick: ()=> likeClicked(context, post), onTap: ()=>showDetailPost(context, post), key: Key(post.keyString));
                      }
                      break;
                    case PostType.TRANSACTION:
                      {
                        //return CardSocialTextActivity(activityType, activityCode, avatarUrl, name, username, label, datetime, text, commentCount, likedCount, comments);
                        return NewCardSocialTextActivity(post, shareClick: (){}, commentClick: ()=>commentClicked(context, post),likeClick: ()=> likeClicked(context, post), onTap: ()=>showDetailPost(context, post), key: Key(post.keyString));
                      }
                      break;
                    case PostType.TEXT:
                      {
                        if(post.attachmentsCount() > 0 ){
                          return NewCardSocialTextImages(post, shareClick: (){}, commentClick: ()=>commentClicked(context, post),likeClick: ()=> likeClicked(context, post), onTap: ()=>showDetailPost(context, post), key: Key(post.keyString));
                        }else{
                          return NewCardSocialText(post, shareClick: (){}, commentClick: ()=>commentClicked(context, post),likeClick: ()=> likeClicked(context, post), onTap: ()=>showDetailPost(context, post), key: Key(post.keyString));
                        }
                      }
                      break;
                    case PostType.Unknown:
                      {
                        return Text('[$indexPost] --> '+post.type+' is Unknown');
                      }
                      break;
                    default:
                      {
                        return Text('[$indexPost] --> '+post.type+' is Unknown[default]');
                      }
                      break;
                  }
                  //return Text('[$indexPost] --> '+post.type);
                }else{
                  return EmptyLabel(text: 'post index $index is null',);
                }
                */
              }else{
                if(notifier.loadingBottom){
                  if(index == 0){
                    return Padding(
                      padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width / 4),
                      child: Center(child: CircularProgressIndicator(color: Theme.of(context).accentColor, backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),)),
                    );
                  }else{
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).accentColor, backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),));
                  }

                }else if(notifier.retryBottom){
                  return Center(child: TextButton(child: Text('button_retry'.tr(), style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: Theme.of(context).accentColor),), onPressed: (){
                    fetchNextPage();
                  },));
                }else{
                  return Center(child: EmptyLabel(text: 'infinity_label️'.tr(),));
                }
              }


            });
      }),
    );
  }
  Widget listTile(BuildContext context, BaseMessage message /* String date, String title, Image titleIcon, String message*/, {bool selected=false}){
    TextStyle more_support_400 = InvestrendTheme.of(context).more_support_w400.copyWith(fontSize:11.0,letterSpacing: -0.2, color: InvestrendTheme.of(context).greyLighterTextColor);
    TextStyle more_support_400_darker = more_support_400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    return ListTile(
      selectedTileColor: InvestrendTheme.of(context).oddColor,
      contentPadding: EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0,bottom: 8.0),
      enabled: true,
      selected: selected,
      onTap: (){
        //InvestrendTheme.of(context).showSnackBar(context, 'Click message : '+message.fcm_title);
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenMessage(baseMessage: message, caller: 'ListTileNotification',),
              settings: RouteSettings(name: '/message'),
            ));
      },
      title: Text(
        message.created_at,
        style: more_support_400,
      ),
      subtitle: RichText(
        maxLines: 3,
        text: TextSpan(
          text: message.fcm_title,
          style: InvestrendTheme.of(context).small_w400.copyWith(fontSize: 15.0),
          children: <TextSpan>[
            // WidgetSpan(
            //   child: Icon(icon, size: 14),
            // ),
            TextSpan(text: '\n'+message.fcm_body, style: more_support_400_darker,)

          ],
        ),
      ),
    );
  }
  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    //return Future.delayed(Duration(seconds: 3));
  }
  @override
  void initState() {
    super.initState();
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
    _scrollController = ScrollController();
    _scrollController.addListener(scrollListener);

    //doUpdate();
    runPostFrame(doUpdate);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate();
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // _pagingController.dispose();
    super.dispose();
  }
  @override
  void onActive() {
    // TODO: implement onActive
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}


/*
class ScreenNotification extends StatelessWidget {
  const ScreenNotification({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    print('paddingBottom  : $paddingBottom');
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: createBody(context, paddingBottom),
    );
  }
  Future onRefresh() {
    //return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  Widget createBody(BuildContext context, double paddingBottom) {

    return RefreshIndicator(
        color: Colors.white,
        backgroundColor: Theme.of(context).accentColor,
        onRefresh: onRefresh,
    //    child: child
    );


    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width / 4,
        ),
        Center(child: EmptyLabel(text: 'notification_empty_label'.tr(),),),
        //Spacer(flex: 4,),
      ],
    );
    /* di HIDE dulu karena belum support
    return ListView(
      children: ListTile.divideTiles(
        //color: InvestrendTheme.of(context).blackAndWhiteText,
        color: InvestrendTheme.of(context).oddColor,
          context: context,
          tiles: [
            listTile(context, 'Kemarin', 'What\'s new ✨' , null, 'You can personalise your notifications to receive alerts based on your interests.'),
            listTile(context, '12 Oktober 2020', 'Welcome to "App" 🎁' , null, 'We will show you what\'s good near you.'),
            listTile(context, '12 Oktober 2020', 'Our Top-rated experiences 💎' , null, 'You can personalise your notifications to receive alerts based on your interests.'),
            listTile(context, '12 Oktober 2020', 'Improve Every Day 🎯' , null, 'You can personalise your notifications to receive alerts based on your interests.'),
            listTile(context, '12 Oktober 2020', 'Perfect Time for Invest ⏱️' , null, 'You can personalise your notifications to receive alerts based on your interests.', selected: true),
            listTile(context, '12 Oktober 2020', 'Today Trading Idea 💡' , null, 'You can personalise your notifications to receive alerts based on your interests.', selected: true),
            listTile(context, '12 Oktober 2020', 'Agriculture stock on the rise 🌴' , null, 'You can personalise your notifications to receive alerts based on your interests.', selected: true),
            listTile(context, '12 Oktober 2020', 'Live up you life 🏖️' , null, 'You can personalise your notifications to receive alerts based on your interests.', selected: true),
            listTile(context, '12 Oktober 2020', 'Investrend is on the rise 📈' , null, 'You can personalise your notifications to receive alerts based on your interests.', selected: true),
            listTile(context, '12 Oktober 2020', 'Kompetisi Tujuh Belas Agustus 🇮🇩️' , null, 'You can personalise your notifications to receive alerts based on your interests.', selected: true),
            listTile(context, '12 Oktober 2020', 'Profit taking is awesome 💯️' , null, 'You can personalise your notifications to receive alerts based on your interests.', selected: true),
            SizedBox(height: paddingBottom,),
          ]
      ).toList(),
    );
    */
  }

  Widget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return AppBar(
      elevation: elevation,
      shadowColor: shadowColor,
      backgroundColor: Theme.of(context).backgroundColor,
      title: AppBarTitleText('notification_title'.tr()),
    );
  }

  Widget listTile(BuildContext context, String date, String title, Image titleIcon, String message, {bool selected=false}){
    TextStyle more_support_400 = InvestrendTheme.of(context).more_support_w400.copyWith(fontSize:11.0,letterSpacing: -0.2, color: InvestrendTheme.of(context).greyLighterTextColor);
    TextStyle more_support_400_darker = more_support_400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);
    return ListTile(
      selectedTileColor: InvestrendTheme.of(context).oddColor,
      contentPadding: EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0,bottom: 8.0),
      enabled: true,
      selected: selected,
      onTap: (){
        InvestrendTheme.of(context).showSnackBar(context, 'Click message : '+title);
      },
      title: Text(
        date,
        style: more_support_400,
      ),
      subtitle: RichText(
        //maxLines: 2,
        text: TextSpan(
          text: title,
          style: InvestrendTheme.of(context).small_w400.copyWith(fontSize: 15.0),
          children: <TextSpan>[
            // WidgetSpan(
            //   child: Icon(icon, size: 14),
            // ),
            TextSpan(text: '\n$message', style: more_support_400_darker,)

          ],
        ),
      ),
    );
  }
}
*/