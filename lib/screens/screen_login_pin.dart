import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenLoginPin extends StatefulWidget {
  const ScreenLoginPin({Key key}) : super(key: key);

  @override
  _ScreenLoginPinState createState() => _ScreenLoginPinState();
}

const String PIN_SUCCESS = 'pin_success';

class _ScreenLoginPinState extends State<ScreenLoginPin> {
  TextEditingController fieldPinController = TextEditingController();
  ValueNotifier<String> _pinNotifier = ValueNotifier('');
  ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  FocusNode focusNode = FocusNode();
  bool onProgress = false;
  //String pin = '';

  @override
  void dispose() {
    // TODO: implement dispose
    _loadingNotifier.dispose();
    _pinNotifier.dispose();
    focusNode.dispose();
    fieldPinController.dispose();
    alreadyDisposed = true;
    super.dispose();
  }
  bool alreadyDisposed = false;

  @override
  void initState() {
    super.initState();

    fieldPinController.text = '';
    fieldPinController.addListener(() {
      String pin = fieldPinController.text;
      print(DateTime.now().toString()+' fieldPinController  pin : $pin  mounted : $mounted  alreadyDisposed : $alreadyDisposed  onProgress : $onProgress');
      if(!mounted || alreadyDisposed){
        return;
      }

      _pinNotifier.value = pin;
      if (pin.length == 4 && !onProgress) {
        onProgress = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          loginPin(pin);
        });
      }
      // setState(() {
      //     pin = fieldPinController.text;
      //     if(pin.length == 4){
      //       loginPin(pin);
      //     }
      // });
    });
  }
  /*
  bool loadingShowed = false;

  void closeLoading() {
    if (loadingShowed && _loadingNotifier.hasCloseListeners()) {
      _loadingNotifier.notifyClose();
      //_loadingNotifier.closeNotifier.value = !_loadingNotifier.closeNotifier.value;
      //_loadingCloseNotifier.value = !_loadingCloseNotifier.value;
    }
  }

  final LoadingBottomNotifier _loadingNotifier = LoadingBottomNotifier();

  void showLoading(String message) {
    if (loadingShowed && _loadingNotifier.hasCloseListeners()) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        //_loadingMessageNotifier.value = message;
        _loadingNotifier.setMessage(message);
      });
    } else {
      loadingShowed = true;
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
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              //_loadingMessageNotifier.value = message;
              _loadingNotifier.setMessage(message);
            });

            return LoadingBottom(_loadingNotifier);
            //return LoadingBottomSheet(loadingNotifier,text: 'Refreshing token...',);
            // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            //   _loadingNotifier.setValue(true, 'loading_refresh_token_label'.tr());
            // });

            // return LoadingBottomSheetNew(_loadingNotifier);
          }).whenComplete(() {
        loadingShowed = false;
      });
    }
  }
  */

  Future loginPin(String pin) {
    //focusNode.unfocus();
    //showLoading('loading_submit_pin'.tr());
    _loadingNotifier.value = true;
    Future reply = InvestrendTheme.tradingHttp
        .loginPin(pin, InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
    reply.then((value) {
      //closeLoading();
      //_loadingNotifier.value = false;
      if (StringUtils.equalsIgnoreCase('ok', value)) {
        alreadyDisposed = true;
        //context.read(propertiesNotifier).needPinTrading = false;
        //focusNode.unfocus();
        context.read(propertiesNotifier).setNeedPinTrading(false);

        Navigator.of(context).pop(PIN_SUCCESS);
      } else {
        pin = '';
        fieldPinController.text = '';

        InvestrendTheme.of(context).showSnackBar(context, value.message);
        //focusNode.requestFocus();
      }


      /*
      Future.delayed(Duration(milliseconds: 700), () {
        if(mounted){
          _loadingNotifier.value = false;
        }

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (StringUtils.equalsIgnoreCase('ok', value)) {
            //context.read(propertiesNotifier).needPinTrading = false;
            //focusNode.unfocus();
            context.read(propertiesNotifier).setNeedPinTrading(false);

            Navigator.of(context).pop(PIN_SUCCESS);
          } else {
            pin = '';
            fieldPinController.text = '';

            InvestrendTheme.of(context).showSnackBar(context, value.message);
            //focusNode.requestFocus();
          }
        });
      });*/
    }).onError((error, stackTrace) {
      //closeLoading();
      _loadingNotifier.value = false;
      if (error is TradingHttpException) {
        if (error.isUnauthorized()) {
          //InvestrendTheme.of(context).showDialogInvalidSession(context);

          Navigator.of(context).pop(error);
        } else if (error.isErrorTrading()) {
          pin = '';
          fieldPinController.text = '';
          InvestrendTheme.of(context).showSnackBar(context, error.message());
        } else {
          String network_error_label = 'network_error_label'.tr();
          network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, network_error_label);
        }
      } else {
        pin = '';
        fieldPinController.text = '';
        InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
      /*
      Future.delayed(Duration(milliseconds: 700), () {
        if(mounted){
          _loadingNotifier.value = false;
        }
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (error is TradingHttpException) {
            if (error.isUnauthorized()) {
              //InvestrendTheme.of(context).showDialogInvalidSession(context);

              Navigator.of(context).pop(error);
            } else if (error.isErrorTrading()) {
              pin = '';
              fieldPinController.text = '';
              InvestrendTheme.of(context).showSnackBar(context, error.message());
            } else {
              String network_error_label = 'network_error_label'.tr();
              network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
              InvestrendTheme.of(context).showSnackBar(context, network_error_label);
            }
          } else {
            pin = '';
            fieldPinController.text = '';
            InvestrendTheme.of(context).showSnackBar(context, error.toString());
          }
        });

      });
      */
    }).whenComplete(() {
      onProgress = false;
    });
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    String labelText;
    String messageText = '';
    String buttonText;
    String value = '';
    //Widget button;

    //value = pin;
    labelText = 'login_pin_label'.tr();
    //messageText = 'register_create_pin_message'.tr();
    buttonText = 'button_continue'.tr();

    fieldPinController.text = value;
    fieldPinController.selection = TextSelection(baseOffset: value.length, extentOffset: value.length);
    /*
    if (StringUtils.isEmtpy(value) || value.length < 4) {
      button = ComponentCreator.roundedButton(context, ' ', Colors.transparent, Colors.transparent, Colors.transparent, null,
          disabledColor: Colors.transparent);
    } else {
      button = ComponentCreator.roundedButton(
          context, buttonText, Theme.of(context).accentColor, InvestrendTheme.of(context).whiteColor, Theme.of(context).accentColor, () {
          loginPin(pin);
      });
    }

     */
    Widget backButton = AppBarActionIcon('images/icons/action_back.png', () {
      Navigator.of(context).pop('CANCEL');
    });
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: Theme.of(context).backgroundColor,
      //   color:Colors.blueAccent,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: elevation,
            shadowColor: shadowColor,
            leading: backButton,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(
                flex: 1,
              ),
              Text(labelText.tr(), style: InvestrendTheme.of(context).regular_w600, textAlign: TextAlign.center),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text(
                  messageText.tr(),
                  style: InvestrendTheme.of(context).regular_w400,
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Stack(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: _pinNotifier,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          value.length > 0
                              ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                              : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                          value.length > 1
                              ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                              : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                          value.length > 2
                              ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                              : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                          value.length > 3
                              ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                              : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                        ],
                      );
                    },
                  ),
                  /*
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      value.length > 0
                          ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                          : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                      value.length > 1
                          ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                          : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                      value.length > 2
                          ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                          : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                      value.length > 3
                          ? Image.asset('images/icons/dot_purple.png', width: 20.0, height: 20.0)
                          : Image.asset('images/icons/dot_gray.png', width: 20.0, height: 20.0),
                    ],
                  ),*/
                  TextField(
                    focusNode: focusNode,

                    decoration: InputDecoration(
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 1.0)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),
                      focusColor: Colors.transparent,
                      focusedErrorBorder:  UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),
                      errorBorder:  UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),
                      enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),
                      disabledBorder:  UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),

                      labelStyle: TextStyle(color: Colors.transparent),
                      prefixStyle: InvestrendTheme.of(context).inputPrefixStyle.copyWith(color: Colors.transparent),
                      hintStyle: InvestrendTheme.of(context).inputHintStyle.copyWith(color: Colors.transparent),
                      helperStyle: InvestrendTheme.of(context).inputHelperStyle.copyWith(color: Colors.transparent),
                      errorStyle: InvestrendTheme.of(context).inputErrorStyle.copyWith(color: Colors.transparent),
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      counter: SizedBox(
                        height: 1,
                        width: 1,
                      ),
                      contentPadding: EdgeInsets.all(0.0),
                    ),
                    controller: fieldPinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    autofocus: true,
                    cursorColor: Colors.transparent,
                    showCursor: false,
                    style: TextStyle(color: Colors.transparent),
                    onSubmitted: (text) {
                      print('onSubmitted : $text  $value');
                    },
                    onEditingComplete: () {
                      print('onEditingComplete $value');
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _loadingNotifier,
                    builder: (context, value, child) {
                      if(value){
                        return Center(child: CircularProgressIndicator(),);
                      }else{
                        return SizedBox(width: 1.0,);
                      }
                    },
                  ),
                ],
              ),
              Spacer(
                flex: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        animationDuration: Duration(milliseconds: 500),
                        primary: InvestrendTheme.of(context).hyperlink,
                        backgroundColor: Colors.transparent,
                        textStyle: InvestrendTheme.of(context).small_w400_compact_greyDarker),
                    child: Text('login_button_forgot_pin'.tr()),
                    onPressed: () {
                      print('forgot_pin pressed');
                      //showLoginPage(context);
                      //showRegisterPage(context);
                      launchURL(context, 'https://olt1.buanacapital.com:8888/manageaccount');
                    },
                  ),
                ],
              ),
              /*
              FractionallySizedBox(
                child: button,
                widthFactor: 0.9,
              ),
               */
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
  void launchURL(BuildContext context, String _url) async {
    try {
      await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
    } catch (error) {
      //InvestrendTheme.of(context).showSnackBar(context, error.toString());
    }
  }
}
