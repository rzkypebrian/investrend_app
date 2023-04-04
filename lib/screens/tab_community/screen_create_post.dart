import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/sosmed/compose_widget.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/sosmed_object.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imageTools;
// import 'package:path/path.dart';
// import 'package:async/async.dart';
import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class ScreenCreatePost extends StatefulWidget {
  final String fromRoute;
  final BuySell orderData;

  const ScreenCreatePost(this.fromRoute, {this.orderData, Key key}) : super(key: key);

  @override
  _ScreenCreatePostState createState() => _ScreenCreatePostState(this.fromRoute, this.orderData);
}

/*
class ImageList with ChangeNotifier{
  List<String> paths = List.empty(growable: true);
  void add(String filePath){
    paths.add(filePath);
    notifyListeners();
  }
  void remove(int index){
    if(index < paths.length && index >= 0){
      paths.removeAt(index);
      notifyListeners();
    }
  }
}
*/
class _ScreenCreatePostState extends BaseStateNoTabs<ScreenCreatePost> {
  final String fromRoute;
  final BuySell orderData;

  ScrollController scrollController = ScrollController();
  TextEditingController fieldTextController;
  final ImagePicker _picker = ImagePicker();
  List<String> paths = List.empty(growable: true);

  // ImageList imageNotifier = ImageList();
  ValueNotifier<bool> imageNotifier = ValueNotifier(false);
  ValueNotifier<bool> typeNotifier = ValueNotifier(false);

  _ScreenCreatePostState(this.fromRoute, this.orderData) : super('/create_post');

  StateComposePoll statePoll = StateComposePoll();
  StateComposePrediction statePrediction = StateComposePrediction();
  StateActivityTransaction stateTransaction = StateActivityTransaction();

  void addImagePath(String filePath) {
    paths.add(filePath);
    imageNotifier.value = !imageNotifier.value;
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   scrollToBottom();
    // });
    Future.delayed(Duration(milliseconds: 500),scrollToBottom);
  }

  void removeImage(int index) {
    if (index < paths.length && index >= 0) {
      paths.removeAt(index);
      imageNotifier.value = !imageNotifier.value;
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container();
  // }

  imageTools.Image resizeImage(String path){
    // Read a jpeg image from file.
    imageTools.Image image = imageTools.decodeImage(new File(path).readAsBytesSync());

    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).

    int maxWidth = 2000;
    if(image.width > maxWidth){
      imageTools.Image resized = imageTools.copyResize(image, width: maxWidth);
      return resized;
    }else{
      return image;
    }
  }

  Future pickImage(BuildContext context, ImageSource source) async {
    try {
      XFile pickedFile = await _picker.pickImage(source: source);
      //PickedFile pickedFile = await _picker.getImage(source: source);
      if (pickedFile != null) {
        print('picked image try to uopload');
        //imageNotifier.value = pickedFile.path;
        addImagePath(pickedFile.path);
        //final File file = File(pickedFile.path);
        //upload(file);
        //_cropImage(context, file);
      } else {
        print('picked image is NULL');
      }
    } catch (e) {
      print('Upload exception : ' + e.toString());
    }
  }
  /*
  void upload(BuildContext context, File imageFile) async {
    /*
    showLoading(context, text: 'uploading_avatar_label'.tr());
    */
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String auth = 'Bearer ' + InvestrendTheme.tradingHttp.access_token;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};
    print(headers);
    //var uri = Uri.parse('http://investrend-prod.teltics.in:8888/uploadpic');
    var uri = Uri.parse('http://' + InvestrendTheme.tradingHttp.tradingBaseUrl + '/uploadpic');

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));
    request.headers.addAll(headers);
    request.files.add(multipartFile);
    var response = await request.send();
    print('upload --> response.statusCode : ' + response.statusCode.toString());
    response.stream.transform(utf8.decoder).listen((value) {
      print('upload --> ' + value);
      Map<String, dynamic> parsedJson = jsonDecode(value);
      String message = parsedJson['message'];
      if (StringUtils.equalsIgnoreCase(message, 'success')) {
        if (mounted) {
          /*
          loadingNotifier.value = true;

          noCache = DateTime.now().toString();
          String url_profile = 'http://' +
              InvestrendTheme.tradingHttp.tradingBaseUrl +
              '/getpic?username=' +
              context.read(dataHolderChangeNotifier).user.username +
              '&url=&nocache='+noCache;
          context.read(avatarChangeNotifier).setUrl(url_profile);
          */
        }
      } else if (StringUtils.equalsIgnoreCase(message, 'unauthorized')) {
        if (mounted) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        }
      } else {
        /*
        loadingNotifier.value = true;
         */
        if (mounted) {
          InvestrendTheme.of(context).showSnackBar(context, 'Upload image : ' + message);
        }
      }
    });
  }
  */
  @override
  void initState() {
    super.initState();
    fieldTextController = TextEditingController();
    if(_fromOrder()){
      print('_fromOrder : '+orderData.toString());
      isSelected[0] = true;
      isSelected[1] = false;
      isSelected[2] = false;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    typeNotifier.dispose();
    fieldTextController.dispose();
    imageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget createAppBar(BuildContext context) {
    // return null;

    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).backgroundColor,
      leading: AppBarActionIcon(
        'images/icons/action_clear.png',
        () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void scrollToBottom(){
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    //bool lightTheme = MediaQuery.of(context).platformBrightness == Brightness.light;
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    return ComponentCreator.keyboardHider(
      context,
      Scrollbar(
        //isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(left: 14.0, right: 14.0, bottom: (paddingBottom + 55)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBarActionIcon(
              //   'images/icons/action_clear.png',
              //       (){
              //     Navigator.of(context).pop();
              //   },
              // ),
              Container(
                //color: Colors.green,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Consumer(builder: (context, watch, child) {
                        final notifier = watch(avatarChangeNotifier);
                        String url = notifier.url;
                        if (notifier.invalid()) {
                          url = 'https://' +
                              InvestrendTheme.tradingHttp.tradingBaseUrl +
                              '/getpic?username=' +
                              context.read(dataHolderChangeNotifier).user.username +
                              '&url=&nocache=';
                        }
                        return AvatarProfileButton(
                          fullname: context.read(dataHolderChangeNotifier).user.realname,
                          url: url,
                          size: 32.0,
                          // style: Theme.of(context)
                          //     .textTheme
                          //     .headline2
                          //     .copyWith(color: Theme.of(context).primaryColor, fontSize: 40.0, fontWeight: FontWeight.w500),
                        );
                      }),
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          TextField(
                            controller: fieldTextController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            maxLength: 300,
                            //textInputAction: TextInputAction.done,
                            // onEditingComplete: () {
                            //     FocusScope.of(context).unfocus();
                            // },
                            style: InvestrendTheme.of(context).regular_w400,
                            decoration: InputDecoration(
                              //counterText: (300 - fieldTextController.text.length).toString(),
                              hintText: 'create_post_information'.tr(),
                              hintStyle: InvestrendTheme.of(context)
                                  .regular_w400_compact
                                  .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                              counterStyle: InvestrendTheme.of(context)
                                  .more_support_w400_compact.copyWith(fontSize: 10.0)
                                  .copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                              disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                              errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                              focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0.0)),
                              focusColor: Theme.of(context).accentColor,
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          ValueListenableBuilder<bool>(
                              valueListenable: typeNotifier,
                              builder: (context, value, child) {
                                bool isText = !isSelected[0] && !isSelected[1] && !isSelected[2];
                                bool isOrder = isSelected[0] && !isSelected[1] && !isSelected[2];
                                bool isPoll = !isSelected[0] && isSelected[1] && !isSelected[2];
                                bool isPrediction = !isSelected[0] && !isSelected[1] && isSelected[2];

                                if (isPoll) {
                                  return ComposePollWidget(
                                    statePoll,
                                    onDelete: () {
                                      print('onDelete Poll');
                                      statePoll.clear();
                                      isSelected[1] = false;
                                      typeNotifier.value = !typeNotifier.value;
                                    },
                                  );
                                } else if (isPrediction) {
                                  return ComposePredictionWidget(
                                    statePrediction,
                                    onDelete: () {
                                      print('onDelete Poll');
                                      statePrediction.clear();
                                      isSelected[2] = false;
                                      typeNotifier.value = !typeNotifier.value;
                                    },
                                  );
                                } else if (isOrder && orderData != null) {
                                  bool isBuy = orderData.isBuy();
                                  print('fromOrder widget isBuy : $isBuy ');
                                  print('fromOrder --> '+orderData.toString());

                                  if(isBuy){
                                    return ComposeActivityBuyWidget(orderData, onDelete: () {
                                      print('onDelete Activity');
                                      isSelected[0] = false;
                                      stateTransaction.clear();
                                      typeNotifier.value = !typeNotifier.value;
                                    },);
                                  }else{
                                    return ComposeActivitySellWidget(stateTransaction, orderData, onDelete: () {
                                      print('onDelete Activity');
                                      isSelected[0] = false;
                                      stateTransaction.clear();
                                      typeNotifier.value = !typeNotifier.value;
                                    },);  
                                  }
                                  

                                } else {
                                  return ValueListenableBuilder<bool>(
                                      valueListenable: imageNotifier,
                                      builder: (context, value, child) {
                                        if (paths.isEmpty) {
                                          return SizedBox(
                                            width: 1.0,
                                            height: 1.0,
                                          );
                                        }
                                        return Column(
                                          children: List<Widget>.generate(
                                            paths.length,
                                            (int index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 14.0),
                                                child: Column(
                                                  //alignment: Alignment.topRight,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        removeImage(index);
                                                      },
                                                      icon: Image.asset('images/icons/delete_circle.png'),
                                                      visualDensity: VisualDensity.compact,
                                                      padding: EdgeInsets.only(left: 10.0, bottom: 1.0, top: 1.0),
                                                    ),
                                                    Image.file(File(paths.elementAt(index))),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      });
                                }
                              }),
                        ],
                      ),
                    ),
                    //Text('create_post_information'.tr(), style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
                    // Container(
                    //   color: Colors.orange,
                    //   width: double.maxFinite,
                    //     child: ComponentCreator.textFieldForm(context, lightTheme, '', '', 'create_post_information'.tr(), '', '', false, TextInputType.text, TextInputAction.done, (value) => null, fieldTextController, () { }, null, null)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _fromOrder() {
    return StringUtils.equalsIgnoreCase(fromRoute, '/trade');
  }

  Color _getColorToggle(BuildContext context, int index) {
    if(index == 0 && _fromOrder()){
      return isSelected[index] ? Theme.of(context).accentColor : InvestrendTheme.of(context).greyLighterTextColor;
    }else{
      return isSelected[index] ? InvestrendTheme.of(context).greyDarkerTextColor : InvestrendTheme.of(context).greyLighterTextColor;
    }
  }

  //int selectedIndex = -1;
  List<bool> isSelected = [false, false, false];

  @override
  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    double height = 52.0 + paddingBottom;
    /*
    List<Widget> listToggle = <Widget>[
      Image.asset(
        _fromOrder() ? 'images/icons/create_post_order.png' : 'images/icons/create_post_order_list.png',
        color: Theme.of(context).accentColor,
      ),
      Image.asset(
        'images/icons/create_post_poll.png',
        color: InvestrendTheme.of(context).greyLighterTextColor,
      ),
      Image.asset(
        'images/icons/create_post_prediction.png',
        color: InvestrendTheme.of(context).greyLighterTextColor,
      ),
    ];
    */
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ComponentCreator.divider(context),
        Container(
          // color: Colors.orange,
          height: height,
          padding: EdgeInsets.only(left: 14.0, right: 14.0, bottom: paddingBottom),
          width: double.maxFinite,
          child: Row(
            children: [
              ValueListenableBuilder<bool>(
                  valueListenable: typeNotifier,
                  builder: (context, value, child) {
                    return ToggleButtons(

                      borderColor: Colors.transparent,
                      selectedBorderColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      selectedColor: Colors.transparent,
                      fillColor: Colors.transparent,
                      disabledBorderColor: Colors.transparent,
                      disabledColor: Colors.transparent,
                      children: [
                        Image.asset(
                          _fromOrder() ? 'images/icons/create_post_order.png' : 'images/icons/create_post_order_list.png',
                          color: _getColorToggle(context, 0),
                        ),
                        Image.asset('images/icons/create_post_poll.png', color: _getColorToggle(context, 1)),
                        Image.asset('images/icons/create_post_prediction.png', color: _getColorToggle(context, 2)),
                      ],
                      onPressed: (int index) {
                        // setState(() {

                        for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                          if (buttonIndex == index) {
                            isSelected[buttonIndex] = !isSelected[buttonIndex];
                          } else {
                            isSelected[buttonIndex] = false;
                          }
                        }
                        // });
                        typeNotifier.value = !typeNotifier.value;
                      },
                      isSelected: isSelected,
                    );
                  }),
              Spacer(
                flex: 1,
              ),
              ValueListenableBuilder<bool>(valueListenable: typeNotifier, builder: (context, value, child) {
                bool isText = !isSelected[0] && !isSelected[1] && !isSelected[2];
                if(isText && paths.length < 3){
                  return TapableWidget(
                    //splashColor: InvestrendTheme.of(context).tileSplashColor,
                    child: SizedBox(
                        width: height - paddingBottom,
                        height: height - paddingBottom,
                        child: Image.asset('images/icons/create_post_add_image.png', color: InvestrendTheme.of(context).greyDarkerTextColor)),
                    onTap: () => chooseImageSource(context),
                  );
                }else{
                  return SizedBox(
                      width: height - paddingBottom,
                      height: height - paddingBottom,
                      child: Image.asset('images/icons/create_post_add_image.png', color: InvestrendTheme.of(context).greyLighterTextColor));
                }
              }),
              /*
              TapableWidget(
                //splashColor: InvestrendTheme.of(context).tileSplashColor,
                child: SizedBox(
                    width: height - paddingBottom,
                    height: height - paddingBottom,
                    child: Image.asset('images/icons/create_post_add_image.png', color: InvestrendTheme.of(context).greyDarkerTextColor)),
                onTap: () => chooseImageSource(context),
              ),
              */
              // AppBarActionIcon('images/icons/create_post_add_image.png', (){
              //
              // }, color: InvestrendTheme.of(context).greyDarkerTextColor,),
              Padding(
                padding: const EdgeInsets.only(
                  right: 14.0,
                  top: 14.0,
                  bottom: 14.0,
                ),
                child: VerticalDivider(
                  thickness: 1.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
              //ComponentCreator.roundedButton(context, 'Post', Theme.of(context).accentColor, Theme.of(context).primaryColor, Theme.of(context).accentColor, () { }),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  minimumSize: Size(50.0, 36.0),
                  side: BorderSide(color: Theme.of(context).accentColor, width: 1.0),
                  backgroundColor: Theme.of(context).accentColor,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                ),
                onPressed: () => submitPost(context),
                child: Text(
                  'button_post'.tr(),
                  style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void chooseImageSource(BuildContext context) {
    hideKeyboard(context: context);
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              actions: [
                CupertinoButton(
                    child: Text('button_camera'.tr()),
                    onPressed: () {
                      pickImage(context, ImageSource.camera);
                      Navigator.of(context).pop();
                    }),
                CupertinoButton(
                    child: Text('button_photos'.tr()),
                    onPressed: () {
                      pickImage(context, ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                CupertinoButton(
                    child: Text('button_cancel'.tr(), style: TextStyle(color: Colors.red),),
                    //color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            ));
  }

  void showCommunityFeedScreen(BuildContext context, bool fromOrder){
    context.read(sosmedFeedChangeNotifier).mustNotifyListener();
    if(fromOrder){
      context.read(sosmedActiveActionNotifier).index = ActiveActionType.DoUpdate.index;
      /*
      Navigator.popUntil(context, (route) {
        print('popUntil : ' + route.toString());
        return route.isFirst;
      });
      context.read(mainMenuChangeNotifier).setActive(Tabs.Community, TabsCommunity.Feed.index);
      */
      Navigator.of(context).pop('SHOW_COMMUNITY_FEED');
    }else{
      Navigator.pop(context,'REFRESH');
    }
  }

  void submitPost(BuildContext context) async {
    bool isText = !isSelected[0] && !isSelected[1] && !isSelected[2];
    bool isOrder = isSelected[0] && !isSelected[1] && !isSelected[2];
    bool isPoll = !isSelected[0] && isSelected[1] && !isSelected[2];
    bool isPrediction = !isSelected[0] && !isSelected[1] && isSelected[2];

    if(isOrder && orderData == null){
      InvestrendTheme.of(context).showSnackBar(context, 'sosmed_activity_error_please_select_order'.tr());
      return;
    }


    String text = fieldTextController.text;
    if(StringUtils.isEmtpy(text)){
      InvestrendTheme.of(context).showSnackBar(context, 'sosmed_error_text'.tr());
      return;
    }
    if(isPrediction){
      String error = statePrediction.getError();
      if(!StringUtils.isEmtpy(error)){
        InvestrendTheme.of(context).showSnackBar(context, error);
        return;
      }
    }else if(isPoll){
      String error = statePoll.getError();
      if(!StringUtils.isEmtpy(error)){
        InvestrendTheme.of(context).showSnackBar(context, error);
        return;
      }
    }else if(isOrder && orderData.isSell()){
      String error = stateTransaction.getError();
      if(!StringUtils.isEmtpy(error)){
        InvestrendTheme.of(context).showSnackBar(context, error);
        return;
      }
    }


    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          String action = 'sosmed_label_posting'.tr();
          return LoadingBottomSheetSimple(action);
        });


    if (isText) {
      try {
        /* ASLI
        SubmitCreateText submitResult = await SosMedHttp.createPostText(
            fieldTextController.text, '123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
            attachments: paths,
            language: EasyLocalization.of(context).locale.languageCode);
        */
        SubmitCreateText submitResult;
        if(Utils.safeLenght(paths) <= 0){
          /*
          submitResult = await SosMedHttp.createPostText(
              fieldTextController.text, '123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
              //attachments: paths,
              language: EasyLocalization.of(context).locale.languageCode);
          */

          submitResult = await InvestrendTheme.tradingHttp.sosmedCreatePostText(
              fieldTextController.text,  InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
              //attachments: paths,
              language: EasyLocalization.of(context).locale.languageCode);
        }else{
          /*
          submitResult = await SosMedHttp.createPostTextWithAttachments(
              fieldTextController.text,paths, '123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
              language: EasyLocalization.of(context).locale.languageCode);
          */

          submitResult = await InvestrendTheme.tradingHttp.sosmedCreatePostTextWithAttachments(
              fieldTextController.text,paths, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
              language: EasyLocalization.of(context).locale.languageCode);

        }
        if (submitResult != null) {
          print('submitResult = ' + submitResult.toString());
          bool success = submitResult.status == 200; // && submitResult?.result?.id >= 0;
          if (mounted) {
            Navigator.of(context).pop();
            InvestrendTheme.of(context).showSnackBar(context, submitResult.message);
          }
          if (success) {
            if (mounted) {
              showCommunityFeedScreen(context, _fromOrder());
              /*
              context.read(sosmedPostChangeNotifier).mustNotifyListener();
              Navigator.popUntil(context, (route) {
                print('popUntil : ' + route.toString());
                return route.isFirst;
              });
              context.read(mainMenuChangeNotifier).setActive(Tabs.Community, TabsCommunity.Feed.index);
              */
            }
          }
        }
      } catch (error) {
        print(routeName + '.createPostText Exception like : ' + error.toString());
        print(error);
        Navigator.of(context).pop();
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        handleNetworkError(context, error);
        return;
        /*
        if(error is TradingHttpException){
          if(error.isUnauthorized()){
            InvestrendTheme.of(super.context).showDialogInvalidSession(super.context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }
        */
      }
    } else if (isOrder) {
      String code = orderData.stock_code;
      int buy_price = 0;
      int sell_price = 0;
      String transaction_type = '';
      String order_id = orderData.orderid;
      String publish_time = _fromOrder() ? 'PENDING' : 'NOW';
      String order_date = orderData.orderdate;
      if(orderData.isBuy()){
        transaction_type = 'BUY';
        buy_price = orderData.normalPriceLot.price;
        sell_price = 0;
      }else{
        transaction_type = 'SELL';
        buy_price = stateTransaction.averagePrice; //  di isi berdasarkan average price portfolio stock nya.
        sell_price = orderData.normalPriceLot.price;
      }




      try {
        /*
        SubmitCreateTransaction submitResult = await SosMedHttp.createPostTransaction(
            code, transaction_type,  buy_price, sell_price,
            fieldTextController.text, order_id, publish_time, order_date,
            '123', InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
            language: EasyLocalization.of(context).locale.languageCode);
        */
        SubmitCreateTransaction submitResult = await InvestrendTheme.tradingHttp.sosmedCreatePostTransaction(
            code, transaction_type,  buy_price, sell_price,
            fieldTextController.text, order_id, publish_time, order_date,
            InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
            language: EasyLocalization.of(context).locale.languageCode);


        if (submitResult != null) {
          print('submitResult = ' + submitResult.toString());
          bool success = submitResult.status == 200; // && submitResult?.result?.id >= 0;
          if (mounted) {
            Navigator.of(context).pop();
            InvestrendTheme.of(context).showSnackBar(context, submitResult.message);
          }
          if (success) {
            if (mounted) {
              showCommunityFeedScreen(context, _fromOrder());
              /*
              if(_fromOrder()){
                Navigator.of(context).pop('SHOW_COMMUNITY_FEED');
              }else{
                context.read(sosmedPostChangeNotifier).mustNotifyListener();
                Navigator.popUntil(context, (route) {
                  print('popUntil : ' + route.toString());
                  return route.isFirst;
                });
                context.read(mainMenuChangeNotifier).setActive(Tabs.Community, TabsCommunity.Feed.index);
              }
              */
            }
          }
        }
      } catch (error) {
        print(routeName + '.likeClicked Exception like : ' + error.toString());
        print(error);
        Navigator.of(context).pop();
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        handleNetworkError(context, error);
        return;
        /*
        if(error is TradingHttpException){
          if(error.isUnauthorized()){
            InvestrendTheme.of(super.context).showDialogInvalidSession(super.context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }
        */
      }
    } else if (isPoll) {
      try {
        // SubmitCreatePolls submitResult = await SosMedHttp.createPostPoll(fieldTextController.text, statePoll.options, statePoll.expire_at, '123',
        //     InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
        //     language: EasyLocalization.of(context).locale.languageCode);

        SubmitCreatePolls submitResult = await InvestrendTheme.tradingHttp.sosmedCreatePostPoll(fieldTextController.text, statePoll.options, statePoll.expire_at,
            InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
            language: EasyLocalization.of(context).locale.languageCode);

        if (submitResult != null) {
          print('submitResult = ' + submitResult.toString());
          bool success = submitResult.status == 200; // && submitResult?.result?.id >= 0;
          if (mounted) {
            Navigator.of(context).pop();
            InvestrendTheme.of(context).showSnackBar(context, submitResult.message);
          }
          if (success) {
            if (mounted) {
              showCommunityFeedScreen(context, _fromOrder());
              /*
              context.read(sosmedPostChangeNotifier).mustNotifyListener();
              Navigator.popUntil(context, (route) {
                print('popUntil : ' + route.toString());
                return route.isFirst;
              });
              context.read(mainMenuChangeNotifier).setActive(Tabs.Community, TabsCommunity.Feed.index);
              */
            }
          }
        }
      } catch (error) {
        print(routeName + '.likeClicked Exception like : ' + error.toString());
        print(error);
        Navigator.of(context).pop();
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        handleNetworkError(context, error);
        return;
        /*
        if(error is TradingHttpException){
          if(error.isUnauthorized()){
            InvestrendTheme.of(super.context).showDialogInvalidSession(super.context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }
        */

      }
    } else if (isPrediction) {
      try {
        /*
        SubmitCreatePrediction submitResult = await SosMedHttp.createPostPrediction(
            statePrediction.transaction_type, fieldTextController.text, statePrediction.code,
            statePrediction.start_price, statePrediction.target_price, statePrediction.expire_at, '123',
            InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
            language: EasyLocalization.of(context).locale.languageCode);
        */
        SubmitCreatePrediction submitResult = await InvestrendTheme.tradingHttp.sosmedCreatePostPrediction(
            statePrediction.transaction_type, fieldTextController.text, statePrediction.code,
            statePrediction.start_price, statePrediction.target_price, statePrediction.expire_at,
            InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion,
            language: EasyLocalization.of(context).locale.languageCode);

        if (submitResult != null) {
          print('submitResult = ' + submitResult.toString());
          bool success = submitResult.status == 200; // && submitResult?.result?.id >= 0;
          if (mounted) {
            Navigator.of(context).pop();
            InvestrendTheme.of(context).showSnackBar(context, submitResult.message);
          }
          if (success) {
            if (mounted) {
              showCommunityFeedScreen(context, _fromOrder());
              /*
              context.read(sosmedPostChangeNotifier).mustNotifyListener();
              Navigator.popUntil(context, (route) {
                print('popUntil : ' + route.toString());
                return route.isFirst;
              });
              context.read(mainMenuChangeNotifier).setActive(Tabs.Community, TabsCommunity.Feed.index);
               */
            }
          }
        }
      } catch (error) {
        print(routeName + '.likeClicked Exception like : ' + error.toString());
        print(error);
        Navigator.of(context).pop();
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        handleNetworkError(context, error);
        return;
        /*
        if(error is TradingHttpException){
          if(error.isUnauthorized()){
            InvestrendTheme.of(super.context).showDialogInvalidSession(super.context);
            return;
          }else{
            String network_error_label = 'network_error_label'.tr();
            network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            return;
          }
        }
        */
      }
    }
  }

  @override
  void onActive() {}

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}
class IntFlag {
  static final int error_value = 9999999;
  static final int loading_value = 8888888;
}
class StateActivityTransaction{
  int averagePrice = 0;
  String getError(){
    if(averagePrice == IntFlag.error_value){
      return 'sosmed_activity_error_cost_failed'.tr();
    }else if(averagePrice == IntFlag.loading_value){
      return 'sosmed_activity_error_cost_loading'.tr();
    }else if (averagePrice <= 0){
      return 'sosmed_activity_error_cost_invalid'.tr();
    }
    return null;
  }

  void clear() {
    averagePrice = 0;
  }
}

class StateComposePoll {
  List<String> options = List.empty(growable: true);
  String expire_at = '';

  void set(String option, int index) {
    options.insert(index, option);
  }

  void clear() {
    expire_at = '';
    options.clear();
  }
  bool valid() {
    int optionsCount = 0;
    options.forEach((value) {
      if( !StringUtils.isEmtpy(value) ){
        optionsCount++;
      }
    });
    return !StringUtils.isEmtpy(expire_at) && optionsCount >= 2;
  }
  bool inValid() {
    return !valid();
  }

  String getError(){
    int optionsCount = 0;
    options.forEach((value) {
      if( !StringUtils.isEmtpy(value) ){
        optionsCount++;
      }
    });
    if(StringUtils.isEmtpy(expire_at)){
      return 'sosmed_polling_error_expire_at'.tr();
    }else if(optionsCount < 2){
      return 'sosmed_polling_error_options'.tr();
    }
    return null;
  }

}

class StateComposePrediction {
  String code = '';
  int target_price = 0;
  int start_price = 0;
  String expire_at = '';
  String transaction_type = '';

  void clear() {
    expire_at = '';
    code = '';
    target_price = 0;
    start_price = 0;
    transaction_type = '';
  }

  bool valid() {
    return !StringUtils.isEmtpy(code) && target_price > 0 && start_price > 0
        && !StringUtils.isEmtpy(expire_at) && !StringUtils.isEmtpy(transaction_type);
  }
  bool inValid() {
    return !valid();
  }
  String getError(){
    if(StringUtils.isEmtpy(code)){
      return 'sosmed_prediction_error_code'.tr();
    }else if(target_price <= 0){
      return 'sosmed_prediction_error_target_price'.tr();
    }else if(start_price <= 0){
      return 'sosmed_prediction_error_start_price'.tr();
    }else if(StringUtils.isEmtpy(expire_at)){
      return 'sosmed_prediction_error_expire_at'.tr();
    }else if(StringUtils.isEmtpy(transaction_type)){
      return 'sosmed_prediction_error_transaction_type'.tr();
    }
    return null;
  }
}
