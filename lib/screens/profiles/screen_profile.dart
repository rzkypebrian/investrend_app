import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/profiles/screen_profile_linked_accounts.dart';
import 'package:Investrend/screens/screen_coming_soon.dart';
import 'package:Investrend/screens/screen_no_account.dart';
import 'package:Investrend/screens/screen_settings.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as imageTools;
import 'package:http_parser/http_parser.dart';

class ScreenProfile extends StatefulWidget {
  const ScreenProfile({Key key}) : super(key: key);

  @override
  _ScreenProfileState createState() => _ScreenProfileState();
}

class _ScreenProfileState extends BaseStateWithTabs<ScreenProfile> {
  TextEditingController fieldName;
  TextEditingController fieldUsername;
  TextEditingController fieldEmail;
  TextEditingController fieldBiography;

  ValueNotifier<bool> editModeNotifier = ValueNotifier<bool>(false);

  ProfileNotifier profileNotifier =
      ProfileNotifier(Profile('', '', '', '', '', '', '', ''));

  final ImagePicker _picker = ImagePicker();
  String noCache = DateTime.now().toString();

  _ScreenProfileState() : super('/profile');

  @override
  void dispose() {
    editModeNotifier.dispose();
    fieldName.dispose();
    fieldEmail.dispose();
    fieldUsername.dispose();
    fieldBiography.dispose();
    profileNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //context.read(dataHolderChangeNotifier).user.realname

    fieldName = TextEditingController(text: ' ');
    fieldUsername = TextEditingController(text: ' ');
    fieldEmail = TextEditingController(text: ' ');
    fieldBiography = TextEditingController(text: ' ');
  }

  /*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    doUpdate();
  }
  */
  void doUpdate() {
    final resultProfile = InvestrendTheme.tradingHttp.getProfile();
    resultProfile.then((value) {
      if (value != null && !value.isEmpty()) {
        if (mounted) {
          profileNotifier.setValue(value);

          fieldName.text = value.realname;
          fieldUsername.text = value.username;
          fieldEmail.text = value.email;
          fieldBiography.text = value.bio;
        }
      } else {
        setNotifierNoData(profileNotifier);
      }
    }).onError((error, stackTrace) {
      setNotifierError(profileNotifier, error.toString());
      handleNetworkError(this.context, error);
    });
  }

  Future<Null> _cropImage(BuildContext context, File imageFile) async {
    print('Try croping ');
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                // CropAspectRatioPreset.ratio3x2,
                // CropAspectRatioPreset.original,
                // CropAspectRatioPreset.ratio4x3,
                // CropAspectRatioPreset.ratio16x9
              ]
            : [
                // CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                // CropAspectRatioPreset.ratio3x2,
                // CropAspectRatioPreset.ratio4x3,
                // CropAspectRatioPreset.ratio5x3,
                // CropAspectRatioPreset.ratio5x4,
                // CropAspectRatioPreset.ratio7x5,
                // CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'image_cropper_title'.tr(),
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'image_cropper_title'.tr(),
          rectX: 1,
          rectY: 1,
          aspectRatioLockEnabled: true,
        ));
    if (croppedFile != null) {
      print('Got cropped image ');
      imageFile = croppedFile;

      print('uploading cropped image ');
      //upload(context, imageFile);
      uploadResized(context, imageFile);
      // setState(() {
      //   state = AppState.cropped;
      // });
    }
  }

  // imageTools.Image resizeImage(String path){
  //   // Read a jpeg image from file.
  //   imageTools.Image image = imageTools.decodeImage(new File(path).readAsBytesSync());
  //
  //   // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
  //
  //   int maxWidth = 2000;
  //   if(image.width > maxWidth){
  //     imageTools.Image resized = imageTools.copyResize(image, width: maxWidth);
  //     return resized;
  //   }else{
  //     return image;
  //   }
  // }
  void upload(BuildContext context, File imageFile) async {
    showLoading(context, text: 'uploading_avatar_label'.tr());

    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String auth = 'Bearer ' + InvestrendTheme.tradingHttp.access_token;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};
    print(headers);
    //var uri = Uri.parse('http://investrend-prod.teltics.in:8888/uploadpic');
    var uri = Uri.parse(
        'https://' + InvestrendTheme.tradingHttp.tradingBaseUrl + '/uploadpic');

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
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
          loadingNotifier.value = true;
          //setState(() {
          noCache = DateTime.now().toString();
          //});
          String url_profile = 'https://' +
              InvestrendTheme.tradingHttp.tradingBaseUrl +
              '/getpic?username=' +
              context.read(dataHolderChangeNotifier).user.username +
              '&url=&nocache=' +
              noCache;
          context.read(avatarChangeNotifier).setUrl(url_profile);
        }
      } else if (StringUtils.equalsIgnoreCase(message, 'unauthorized')) {
        //loadingNotifier.value = true;
        if (mounted) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        }
      } else {
        loadingNotifier.value = true;
        if (mounted) {
          InvestrendTheme.of(context)
              .showSnackBar(context, 'Upload image : ' + message);
        }
      }
    }).onError((error) {
      loadingNotifier.value = true;
      if (mounted) {
        InvestrendTheme.of(context)
            .showSnackBar(context, 'Upload image error : ' + error.toString());
      }
    });
  }

  void uploadResized(BuildContext context, File imageFile) async {
    showLoading(context, text: 'uploading_avatar_label'.tr());

    imageTools.Image resizedFile =
        Utils.resizeImageFile(imageFile, maxWidth: 512);

    // var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // var length = await imageFile.length();

    String auth = 'Bearer ' + InvestrendTheme.tradingHttp.access_token;
    var headers = {"Content-Type": "application/json", 'Authorization': auth};
    print(headers);
    //var uri = Uri.parse('http://investrend-prod.teltics.in:8888/uploadpic');
    var uri = Uri.parse(
        'https://' + InvestrendTheme.tradingHttp.tradingBaseUrl + '/uploadpic');

    var request = new http.MultipartRequest("POST", uri);

    // var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
    // request.files.add(multipartFile);

    request.headers.addAll(headers);

    List<int> encodedJpeg = imageTools.encodeJpg(resizedFile);
    var multipartFile = new http.MultipartFile.fromBytes(
      'file',
      encodedJpeg,
      filename: basename(imageFile.path),
      contentType: MediaType.parse('image/jpeg'),
    );
    request.files.add(multipartFile);

    var response = await request.send();
    print('upload --> response.statusCode : ' + response.statusCode.toString());
    response.stream.transform(utf8.decoder).listen((value) {
      print('upload --> ' + value);
      Map<String, dynamic> parsedJson = jsonDecode(value);
      String message = parsedJson['message'];
      if (StringUtils.equalsIgnoreCase(message, 'success')) {
        if (mounted) {
          loadingNotifier.value = true;
          //setState(() {
          noCache = DateTime.now().toString();
          //});
          String url_profile = 'https://' +
              InvestrendTheme.tradingHttp.tradingBaseUrl +
              '/getpic?username=' +
              context.read(dataHolderChangeNotifier).user.username +
              '&url=&nocache=' +
              noCache;
          context.read(avatarChangeNotifier).setUrl(url_profile);
        }
      } else if (StringUtils.equalsIgnoreCase(message, 'unauthorized')) {
        //loadingNotifier.value = true;
        if (mounted) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        }
      } else {
        loadingNotifier.value = true;
        if (mounted) {
          InvestrendTheme.of(context)
              .showSnackBar(context, 'Upload image : ' + message);
        }
      }
    }).onError((error) {
      loadingNotifier.value = true;
      if (mounted) {
        InvestrendTheme.of(context)
            .showSnackBar(context, 'Upload image error : ' + error.toString());
      }
    });
  }

  void upload2(File imageFile) async {
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("http://investrend-prod.teltics.in:8888/uploadpic");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  /*
  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).viewPadding.top;
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: elevation,
            shadowColor: shadowColor,
            leading: AppBarActionIcon('images/icons/action_back.png', () {
              FocusScope.of(context).requestFocus(new FocusNode());
              Navigator.pop(context);
            }),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
                child: AppBarActionIcon('images/icons/action_settings.png', () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ScreenSettings(),
                        settings: RouteSettings(name: '/settings'),
                      ));
                }),
              ),
            ],
            bottom: createTabs(context),
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 300.0,
            flexibleSpace: Flexible(
              child: Padding(
                padding:  EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral,
                    top: InvestrendTheme.cardPaddingVertical + InvestrendTheme.appBarHeight + paddingTop,
                    bottom: InvestrendTheme.cardPaddingVertical),
                child: ValueListenableBuilder(
                    valueListenable: editModeNotifier,
                    builder: (context, value, child) {
                      if (value) {
                        return createTopInfoEdit(context);
                      } else {
                        return createTopInfo(context);
                      }
                    }),
              ),
            ),
            // expandedHeight: 160.0,
            // flexibleSpace: const FlexibleSpaceBar(
            //   title: Text('SliverAppBar'),
            //   background: FlutterLogo(),
            //
            // ),
          ),
          // SliverToBoxAdapter(
          //   child: createTopInfo(context),
          // ),

          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: InvestrendTheme.cardPaddingVertical, bottom: InvestrendTheme.cardPaddingVertical),
          //     child: ValueListenableBuilder(
          //         valueListenable: editModeNotifier,
          //         builder: (context, value, child) {
          //           if (value) {
          //             return createTopInfoEdit(context);
          //           } else {
          //             return createTopInfo(context);
          //           }
          //         }),
          //   ),
          // ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  color: index.isOdd ? Colors.white : Colors.black12,
                  height: 100.0,
                  child: Center(
                    child: Text('$index', textScaleFactor: 5),
                  ),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingVertical,
                bottom: InvestrendTheme.cardPaddingVertical),
            child: ValueListenableBuilder(
                valueListenable: editModeNotifier,
                builder: (context, value, child) {
                  if (value) {
                    return createTopInfoEdit(context);
                  } else {
                    return createTopInfo(context);
                  }
                }),
          ),
          ComponentCreator.dividerCard(context),
          Expanded(
            flex: 1,
            child: Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: createTabs(context),
              body: createBody(context, paddingBottom),
            ),
          ),
        ],
      ),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }
  */
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingVertical,
                bottom: InvestrendTheme.cardPaddingVertical),
            child: ValueListenableBuilder(
                valueListenable: editModeNotifier,
                builder: (context, value, child) {
                  if (value) {
                    return createTopInfoEdit(context);
                  } else {
                    return createTopInfo(context);
                  }
                }),
          ),
          ComponentCreator.dividerCard(context),
          Expanded(
            flex: 1,
            child: Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: createTabs(context),
              body: createBody(context, paddingBottom),
            ),
          ),
        ],
      ),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: DefaultTabController(
        length: tabsLength(),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, value) {
              return [
                SliverAppBar(
                  floating: false,
                  pinned: true,
                  snap: false,
                  expandedHeight: 200.0,
                  elevation: 0.0,
                  leading: AppBarActionIcon('images/icons/action_back.png', () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    Navigator.pop(context);
                  }),
                  actions: [
                    AppBarActionIcon('images/icons/action_menu.png', () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    }),
                  ],
                  bottom: createTabs(context),
                  flexibleSpace: createTopInfo(context),

                ),

              ];
            },
            body: createBody(context),
          ),
        ),
      ),
    );
  }
  */
  /*
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: Column(
        children: [
          createTopInfo(context),
          DefaultTabController(
            length: tabsLength(),
            child: Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: createTabs(context),
              body: createBody(context),
            ),
          ),
        ],
      ),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }
  */

  Widget createTopInfo(BuildContext context) {
    //String nameAkronim = 'MA';
    //String fullname = 'Mikasa Ackerman';
    //String username = '@ackerman';
    // String about = 'Ackerman adalah sebuah keluarga pada manga berjudul Attack on Titan, tujuan Ackerman adalah melindungin Founding Titan';
    // String info = '🏆 Rank #1 Divisi 100jt  •  1 - 31 Maret 2020';
    int followerCount = 6700;
    int followingCount = 940;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Consumer(builder: (context, watch, child) {
              final notifier = watch(avatarChangeNotifier);
              String url = notifier.url;
              if (notifier.invalid()) {
                url = 'https://' +
                    InvestrendTheme.tradingHttp.tradingBaseUrl +
                    '/getpic?username=' +
                    context.read(dataHolderChangeNotifier).user.username +
                    '&url=&nocache=' +
                    noCache;
              }
              return AvatarProfileButton(
                fullname: context.read(dataHolderChangeNotifier).user.realname,
                url: url,
                size: 82.0,
                style: Theme.of(context).textTheme.headline2.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: 40.0,
                    fontWeight: FontWeight.w500),
              );
            }),
            Spacer(
              flex: 2,
            ),
            /* Hide Fitur Sosmed dulu
            countWidget(context, 'follower_label'.tr(), followerCount),
            Spacer(
              flex: 1,
            ),
            countWidget(context, 'following_label'.tr(), followingCount),
            Spacer(
              flex: 2,
            ),*/
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                  minimumSize: Size(50.0, 36.0),
                  side: BorderSide(
                      color: Theme.of(context).accentColor, width: 1.0),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                ),
                onPressed: () {
                  editModeNotifier.value = true;
                },
                child: Row(
                  children: [
                    Text(
                      'button_edit'.tr(),
                      style: InvestrendTheme.of(context)
                          .small_w600_compact
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Image.asset(
                      'images/icons/action_edit.png',
                      width: 13.0,
                      height: 13.0,
                    ),
                  ],
                )),
          ],
        ),
        SizedBox(
          height: InvestrendTheme.cardPaddingGeneral,
        ),
        Row(
          children: [
            Text(
              context.read(dataHolderChangeNotifier).user.realname,
              style: InvestrendTheme.of(context).regular_w600_compact,
            ),
            SizedBox(
              width: InvestrendTheme.cardPaddingGeneral,
            ),
            Image.asset(
              'images/icons/check_verified.png',
              width: 13.0,
              height: 13.0,
            ),
          ],
        ),
        SizedBox(
          height: InvestrendTheme.cardPadding,
        ),
        Text(
          '@' + context.read(dataHolderChangeNotifier).user.username,
          style: InvestrendTheme.of(context).more_support_w400_compact,
        ),
        SizedBox(
          height: InvestrendTheme.cardPadding,
        ),
        Text(
          context.read(dataHolderChangeNotifier).user.email,
          style:
              InvestrendTheme.of(context).more_support_w400_compact_greyDarker,
        ),
        SizedBox(
          height: InvestrendTheme.cardPaddingGeneral,
        ),
        ValueListenableBuilder<Profile>(
            valueListenable: profileNotifier,
            builder: (context, value, child) {
              Widget noWidget =
                  profileNotifier.currentState.getNoWidget(onRetry: () {
                doUpdate();
              });
              if (noWidget != null) {
                return noWidget;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.bio,
                    style: InvestrendTheme.of(context)
                        .more_support_w400
                        .copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor),
                  ),
                  SizedBox(
                    height: InvestrendTheme.cardPaddingGeneral,
                  ),
                  Text(
                    value.ranking,
                    style: InvestrendTheme.of(context)
                        .more_support_w400
                        .copyWith(color: Theme.of(context).accentColor),
                  )
                ],
              );
            }),
        /*
        Text(
          about,
          style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
        SizedBox(
          height: InvestrendTheme.cardPaddingGeneral,
        ),
        Text(
          info,
          style: InvestrendTheme.of(context).more_support_w400.copyWith(color: Theme.of(context).accentColor),
        ),
         */
      ],
    );
  }

  Future pickImage(BuildContext context, ImageSource source) async {
    try {
      XFile pickedFile = await _picker.pickImage(source: source);
      //PickedFile pickedFile = await _picker.getImage(source: source);
      if (pickedFile != null) {
        print('picked image try to uopload');
        final File file = File(pickedFile.path);
        //upload(file);
        _cropImage(context, file);
        // upload(context, file);
      } else {
        print('picked image is NULL');
      }
    } catch (e) {
      print('Upload exception : ' + e.toString());
    }
  }

  void showOptionPickImage(BuildContext context) {
    hideKeyboard(context: context);
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              actions: [
                /*
          CupertinoButton(
              child: Text('Camera'),
              onPressed: () {
                pickImage(context, ImageSource.camera);
                Navigator.of(context).pop();
              }),
          CupertinoButton(
              child: Text('Photos'),
              onPressed: () {
                pickImage(context, ImageSource.gallery);
                Navigator.of(context).pop();
              }),
          */
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
                    child: Text(
                      'button_cancel'.tr(),
                      style: TextStyle(color: Colors.red),
                    ),
                    //color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            ));
  }

  void doneEditing(BuildContext context) {
    /*
      String platform = InvestrendTheme.of(context).applicationPlatform;
      String version = InvestrendTheme.of(context).applicationVersion;
      showLoading(context, text: '');

      try{
        String result = await InvestrendTheme.tradingHttp.updateBiography(biography, platform, version);
        loadingNotifier.value = true;
      }catch(error){
        loadingNotifier.value = true;
        handleNetworkError(context, error);
      }
      */

    String newBiography = fieldBiography.text;
    bool changedBio =
        !StringUtils.equalsIgnoreCase(newBiography, profileNotifier.value.bio);
    if (changedBio) {
      String platform = InvestrendTheme.of(context).applicationPlatform;
      String version = InvestrendTheme.of(context).applicationVersion;
      showLoading(context, text: '');
      Future result = InvestrendTheme.tradingHttp
          .updateBiography(newBiography, platform, version)
          .then((value) {
        loadingNotifier.value = true;
        if (StringUtils.equalsIgnoreCase(value, 'success')) {
          editModeNotifier.value = false;
          profileNotifier.value.bio = newBiography;
          profileNotifier.mustNotifyListeners();
        }
        InvestrendTheme.of(context).showSnackBar(context, value);
      }).onError((error, stackTrace) {
        loadingNotifier.value = true;
        handleNetworkError(context, error);
      });
    } else {
      editModeNotifier.value = false;
    }
  }

  Widget createTopInfoEdit(BuildContext context) {
    //String nameAkronim = 'MA';
    //String fullname = 'Mikasa Ackerman';
    //String username = '@ackerman';
    //String about = 'Ackerman adalah sebuah keluarga pada manga berjudul Attack on Titan, tujuan Ackerman adalah melindungin Founding Titan';
    //String info = '🏆 Rank #1 Divisi 100jt  •  1 - 31 Maret 2020';
    int followerCount = 6700;
    int followingCount = 940;
    //bool lightTheme = MediaQuery.of(context).platformBrightness == Brightness.light;
    bool lightTheme = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(alignment: Alignment.bottomRight, children: [
              Consumer(builder: (context, watch, child) {
                final notifier = watch(avatarChangeNotifier);
                String url = notifier.url;
                if (notifier.invalid()) {
                  url = 'https://' +
                      InvestrendTheme.tradingHttp.tradingBaseUrl +
                      '/getpic?username=' +
                      context.read(dataHolderChangeNotifier).user.username +
                      '&url=&nocache=' +
                      noCache;
                }
                return AvatarProfileButton(
                  fullname:
                      context.read(dataHolderChangeNotifier).user.realname,
                  url: url,
                  size: 82.0,
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w500),
                  onPressed: () => showOptionPickImage(context),
                );
              }),
              /*
              AvatarProfileButton(
                fullname: context.read(dataHolderChangeNotifier).user.realname,
                url: 'http://' +
                    InvestrendTheme.tradingHttp.tradingBaseUrl +
                    '/getpic?username=' +
                    context.read(dataHolderChangeNotifier).user.username +
                    '&url=&nocache='+noCache,
                size: 82.0,
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Theme.of(context).primaryColor, fontSize: 40.0, fontWeight: FontWeight.w500),
                onPressed: onPressed,
              ),
               */
              /*
                AvatarIconStocks(
                label: nameAkronim,
                size: 82.0,
                imageUrl: '',
                errorTextStyle: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Theme.of(context).primaryColor, fontSize: 40.0, fontWeight: FontWeight.w500),
              ),
                */
              TapableWidget(
                onTap: () => showOptionPickImage(context),
                child: Image.asset(
                  'images/icons/camera_1.png',
                  width: 24.0,
                  height: 24.0,
                ),
              ),
            ]),
            // OutlinedButton.icon(onPressed: (){}, icon: Image.asset('images/icons/action_edit.png',width: 13.0, height: 13.0,), label: Text(
            //   'button_edit'.tr(),
            //   style: InvestrendTheme.of(context).small_w700_compact.copyWith(color: Theme.of(context).accentColor),
            // ),),
            Spacer(
              flex: 2,
            ),
            /* Hide Fitur Sosmed dulu
            countWidget(context, 'follower_label'.tr(), followerCount),
            Spacer(
              flex: 1,
            ),
            countWidget(context, 'following_label'.tr(), followingCount),
            Spacer(
              flex: 2,
            ),
            */
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                  minimumSize: Size(50.0, 36.0),
                  side: BorderSide(
                      color: Theme.of(context).accentColor, width: 1.0),
                  backgroundColor: Theme.of(context).accentColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                ),
                onPressed: () => doneEditing(context),
                child: Row(
                  children: [
                    Text(
                      'button_done'.tr(),
                      style: InvestrendTheme.of(context)
                          .small_w600_compact
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Image.asset(
                      'images/icons/check_2.png',
                      width: 13.0,
                      height: 13.0,
                    ),
                  ],
                )),
          ],
        ),
        SizedBox(
          height: InvestrendTheme.cardPaddingGeneral,
        ),
        /*
        ComponentCreator.textFieldForm(context, lightTheme, '', 'name'.tr(), 'name_hint'.tr(), '', '', false, TextInputType.name,
            TextInputAction.next, (value) => null, fieldName, () {}, null, null,
            enabled: false, initialValue: null),
        ComponentCreator.textFieldForm(context, lightTheme, '@', 'username'.tr(), 'username_hint'.tr(), '', '', false, TextInputType.name,
            TextInputAction.next, (value) => null, fieldUsername, () {}, null, null,
            enabled: false, initialValue: null),
        */
        /*
        ComponentCreator.textFieldForm(context, lightTheme, '', 'email'.tr(), 'username_hint'.tr(), '', '', false, TextInputType.name,
            TextInputAction.next, (value) => null, fieldEmail, () {}, null, null,
            enabled: false, initialValue: null),
        */
        ComponentCreator.textFieldForm(
            context,
            lightTheme,
            '',
            'bio'.tr(),
            'bio_hint'.tr(),
            '',
            '',
            false,
            TextInputType.text,
            TextInputAction.done,
            (value) => null,
            fieldBiography,
            () {},
            null,
            null,
            initialValue: null),
      ],
    );
  }

  Widget countWidget(BuildContext context, String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          InvestrendTheme.formatValue(context, count),
          style: InvestrendTheme.of(context).regular_w600_compact,
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          label,
          style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
              color: InvestrendTheme.of(context).greyLighterTextColor),
        ),
      ],
    );
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
      backgroundColor: Theme.of(context).backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        FocusScope.of(context).requestFocus(new FocusNode());
        Navigator.pop(context);
      }),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
          child: AppBarActionIcon('images/icons/action_settings.png', () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenSettings(),
                  settings: RouteSettings(name: '/settings'),
                ));
          }),
        ),
      ],
      //bottom: createTabs(context),
    );
  }

  Widget createAppBarOld(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      elevation: 0.0,
      // bottom: PreferredSize(
      //   preferredSize: Size.fromHeight(82.0), // + 10.0 // here the desired height
      //   child: Container(
      //     //color: Colors.deepOrange,
      //     padding: EdgeInsets.only(left: InvestrendTheme.cardPadding, right: InvestrendTheme.cardPadding),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [],
      //     ),
      //   ),
      // ),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        FocusScope.of(context).requestFocus(new FocusNode());
        Navigator.pop(context);
      }),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: InvestrendTheme.cardPaddingGeneral),
          child: AppBarActionIcon('images/icons/action_settings.png', () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenSettings(),
                  settings: RouteSettings(name: '/settings'),
                ));
          }),
        ),
      ],
    );
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return TabBarView(
      controller: pTabController,
      children: List<Widget>.generate(
        tabs.length,
        (int index) {
          print(tabs[index]);

          if (tabs[index] == 'profile_tabs_portfolio_title'.tr()) {
          } else if (tabs[index] == 'profile_tabs_posts_title'.tr()) {
          } else if (tabs[index] == 'profile_tabs_competition_title'.tr()) {
          } else if (tabs[index] == 'profile_tabs_linked_account_title'.tr()) {
            bool hasAccount =
                context.read(dataHolderChangeNotifier).user.accountSize() > 0;
            if (!hasAccount) {
              return ScreenNoAccount();
            }
            return ScreenProfileLinkedAccounts(index, pTabController);
          }
          /*
          if (index == 0) {
            return ScreenProfilePortfolio(0, pTabController);
          }
           */
          /* else if (index == 1) {
            return ScreenProfilePost(1, pTabController);
          }*/

          return ScreenComingSoon(
            scrollable: true,
          );
          /*
          return Container(
            child: Center(
              child: Text(tabs[index]),
            ),
          );
           */
        },
      ),
    );
  }

  List<String> tabs = [
    'profile_tabs_linked_account_title'.tr(),
    /* HIDE dulu
    'profile_tabs_portfolio_title'.tr(),
     */
    /* HIDE for audit
    'profile_tabs_posts_title'.tr(),
    'profile_tabs_competition_title'.tr(),

     */
  ];

  @override
  Widget createTabs(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(InvestrendTheme.appBarTabHeight),
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            labelPadding: InvestrendTheme
                .paddingTab, //EdgeInsets.symmetric(horizontal: 12.0),
            controller: pTabController,
            isScrollable: true,
            tabs: List<Widget>.generate(
              tabs.length,
              (int index) {
                print(tabs[index]);
                return new Tab(text: tabs[index]);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  int tabsLength() {
    return tabs.length;
  }

  @override
  void onActive() {
    if (!profileNotifier.value.loaded) {
      profileNotifier.setLoading();
    }
    doUpdate();
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}
