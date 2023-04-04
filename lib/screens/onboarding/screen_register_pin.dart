import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenRegisterPin extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String nextPage;

  const ScreenRegisterPin(this.username,this.email,this.password,this.nextPage, {Key key}) : super(key: key);

  @override
  _ScreenRegisterPinState createState() => _ScreenRegisterPinState();
}

class _ScreenRegisterPinState extends State<ScreenRegisterPin> {
  TextEditingController fieldPinController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String pin = '';
  String confirmPin = '';
  bool showConfirmPin = false;

  @override
  void dispose() {
    // TODO: implement dispose
    focusNode.dispose();
    fieldPinController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();

    fieldPinController.addListener(() {
      setState(() {
        if (showConfirmPin) {
          confirmPin = fieldPinController.text;
        } else {
          pin = fieldPinController.text;
        }
      });
    });
  }

  Future registerPin(String pin) {
    /*
    try{
      var reply = await InvestrendTheme.tradingHttp.register_pin(widget.username, fieldPinController.text,
          InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
      if(reply != null){
        if(reply.isSuccess()){
          InvestrendTheme.pushReplacement(context, ScreenLogin(), ScreenTransition.Fade, '/login');
        }else{
          InvestrendTheme.of(context).showSnackBar(context, reply.message);
        }
      }else{
        InvestrendTheme.of(context).showSnackBar(context, value.message);
      }
    }catch (exception){

    }
    */
    Future reply = InvestrendTheme.tradingHttp.registerPin(widget.username, fieldPinController.text,
        InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
    reply.then((value) {
      if (value != null) {
        if (value.isSuccess()) {
          if(StringUtils.equalsIgnoreCase(widget.nextPage, 'login')){
            InvestrendTheme.pushReplacement(context, ScreenLogin(initialUser: value.username, initialEmail:value.email, initialPassword: widget.password,), ScreenTransition.Fade, '/login');
          }else{
            //InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.Fade, '/main');
            InvestrendTheme.showMainPage(context, ScreenTransition.Fade);
          }
        } else {
          InvestrendTheme.of(context).showSnackBar(context, value.message);
        }
      }
    }).onError((error, stackTrace) {
      //InvestrendTheme.of(context).showSnackBar(context, error.toString());
      /*
      if(error is TradingHttpException){
        if(error.isUnauthorized() || error.isErrorTrading()){
          InvestrendTheme.of(context).showSnackBar(context, error.message());
        }else{
          String network_error_label = 'network_error_label'.tr();
          network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, network_error_label);
        }
      }else{
        InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
      */
      if(error is TradingHttpException){
        if(error.isUnauthorized()){
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        }else if(error.isErrorTrading()){
          InvestrendTheme.of(context).showSnackBar(context, error.message());
        }else{
          String network_error_label = 'network_error_label'.tr();
          network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, network_error_label);
        }
      }else{
        InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
    });
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    String labelText;
    String messageText;
    String buttonText;
    String value = '';
    Widget button;
    if (showConfirmPin) {
      value = confirmPin;
      labelText = 'register_create_pin_confirm_label'.tr();
      messageText = 'register_create_pin_confirm_message'.tr();
      buttonText = 'register_create_pin_confirm_button_label'.tr();
      /*
      if (StringUtils.isEmtpy(confirmPin) || confirmPin.length < 4) {
        button = ComponentCreator.roundedButton(context, ' ', Colors.transparent, Colors.transparent, Colors.transparent, null,
            disabledColor: Colors.transparent);
      } else {
        button = ComponentCreator.roundedButton(
            context, buttonText, Theme.of(context).accentColor, InvestrendTheme.of(context).whiteColor, Theme.of(context).accentColor, () {
          var reply = InvestrendTheme.tradingHttp.register_pin(widget.username, fieldPinController.text,
              InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion);
          reply.then((value) {
            if (value != null) {
              if (value.isSuccess()) {
                InvestrendTheme.pushReplacement(context, ScreenLogin(), ScreenTransition.Fade, '/login');
              } else {
                InvestrendTheme.of(context).showSnackBar(context, value.message);
              }
            }
          });
        });
      }
      */
    } else {
      value = pin;
      labelText = 'register_create_pin_label'.tr();
      messageText = 'register_create_pin_message'.tr();
      buttonText = 'register_create_pin_button_label'.tr();
      /*
      if (StringUtils.isEmtpy(pin) || pin.length < 4) {
        button = ComponentCreator.roundedButton(context, ' ', Colors.transparent, Colors.transparent, Colors.transparent, null,
            disabledColor: Colors.transparent);
      } else {
        button = ComponentCreator.roundedButton(
            context, buttonText, Theme.of(context).accentColor, InvestrendTheme.of(context).whiteColor, Theme.of(context).accentColor, () {
          setState(() {
            showConfirmPin = true;
            fieldPinController.text = '';
          });
        });
      }
      */
    }
    fieldPinController.text = value;
    fieldPinController.selection = TextSelection(baseOffset: value.length, extentOffset: value.length);
    if (StringUtils.isEmtpy(value) || value.length < 4) {
      button = ComponentCreator.roundedButton(context, ' ', Colors.transparent, Colors.transparent, Colors.transparent, null,
          disabledColor: Colors.transparent);
    } else {
      button = ComponentCreator.roundedButton(
          context, buttonText, Theme.of(context).accentColor, InvestrendTheme.of(context).whiteColor, Theme.of(context).accentColor, () {
        if (showConfirmPin) {
          if (!StringUtils.equalsIgnoreCase(pin, confirmPin)) {
            InvestrendTheme.of(context).showSnackBar(context, 'register_create_pin_error_label'.tr());
            return;
          }
          registerPin(pin);
        } else {
          setState(() {
            showConfirmPin = true;
            fieldPinController.text = '';
          });
        }
      });
    }
    Widget backButton = SizedBox(
      width: 1.0,
      height: 1.0,
    );
    if (showConfirmPin) {
      backButton = AppBarActionIcon('images/icons/action_back.png', () {
        setState(() {
          showConfirmPin = false;
        });
      });
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
            elevation: 0.0,
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
                  ),
                  TextField(
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 1.0)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),
                      focusColor: Colors.transparent,
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
                ],
              ),
              Spacer(
                flex: 1,
              ),
              FractionallySizedBox(
                child: button,
                widthFactor: 0.9,
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
