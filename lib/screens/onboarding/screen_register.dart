import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/screens/onboarding/screen_register_pin.dart';
import 'package:Investrend/screens/screen_content.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenRegister extends StatefulWidget {
  @override
  _ScreenRegisterState createState() => _ScreenRegisterState();
}

class _ScreenRegisterState extends State<ScreenRegister> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formRegisterKey = GlobalKey<FormState>();

  final fieldUsernameController = TextEditingController();
  final fieldfullnameController = TextEditingController();
  final fieldPhoneController = TextEditingController();
  final fieldEmailController = TextEditingController();
  final fieldPasswordController = TextEditingController();
  final fieldPasswordConfirmController = TextEditingController();
  final fieldReferralCodeController = TextEditingController();

  final ValueNotifier<bool> _hidePasswordNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _hidePasswordConfirmNotifier =
      ValueNotifier<bool>(true);

  final ValueNotifier<bool> _agreeTnCNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fieldUsernameController.dispose();
    fieldfullnameController.dispose();
    fieldPhoneController.dispose();
    fieldEmailController.dispose();
    fieldPasswordController.dispose();
    fieldPasswordConfirmController.dispose();
    fieldReferralCodeController.dispose();
    _hidePasswordNotifier.dispose();
    _hidePasswordConfirmNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        //titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        leading: IconButton(
          icon: Image.asset('images/icons/action_back.png'),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.of(context).pop();
          },
          // onPressed: () {
          //   final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
          //
          //   // Find the ScaffoldMessenger in the widget tree
          //   // and use it to show a SnackBar.
          //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // },
        ),
        title: Text('register_title'.tr(),
            style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
      ),
      body: ComponentCreator.keyboardHider(context, getForm(context)),
      /*
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: getForm(context),
      ),

       */
      //bottomSheet: getBottomContainer(),
    );
  }

  Widget getForm(BuildContext context) {
    //bool lightTheme = MediaQuery.of(context).platformBrightness == Brightness.light;
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    return Form(
      key: _formRegisterKey,
      child: ListView(
        shrinkWrap: true,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getTextFieldForm(
            context,
            lightTheme,
            '@',
            'register_field_username'.tr(),
            'register_field_username_hint'.tr(),
            'register_field_username_helper'.tr(),
            'register_field_username_validation_error'.tr(),
            textInputAction: TextInputAction.next,
            controller: fieldUsernameController,
          ),
          getTextFieldForm(
            context,
            lightTheme,
            '',
            'register_field_fullname'.tr(),
            'register_field_fullname_hint'.tr(),
            'register_field_fullname_helper'.tr(),
            'register_field_fullname_validation_error'.tr(),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            controller: fieldfullnameController,
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'register_field_fullname_validation_error'.tr();
            //   }
            //   return Utils.isEmailCompliant(value);
            // },
          ),
          getTextFieldForm(
            context,
            lightTheme,
            '+62 ',
            'register_field_phone'.tr(),
            'register_field_phone_hint'.tr(),
            'register_field_phone_helper'.tr(),
            'register_field_phone_validation_error'.tr(),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            controller: fieldPhoneController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'register_field_phone_validation_error'.tr();
              }
              return Utils.isPhoneNumberCompliant(value);
            },
          ),
          getTextFieldForm(
            context,
            lightTheme,
            '',
            'register_field_email'.tr(),
            'register_field_email_hint'.tr(),
            'register_field_email_helper'.tr(),
            'register_field_email_validation_error'.tr(),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            controller: fieldEmailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'register_field_email_validation_error'.tr();
              }
              return Utils.isEmailCompliant(value);
            },
          ),
          /*
          getTextFieldForm(
            context,
            lightTheme,
            '',
            'register_field_password'.tr(),
            'register_field_password_hint'.tr(),
            'register_field_password_helper'.tr(),
            'register_field_password_validation_error'.tr(),
            textInputAction: TextInputAction.next,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'register_field_password_validation_error'.tr();
              }
              return Utils.isPasswordCompliant(value, 8);
            },
            controller: fieldPasswordController,
          ),
          */

          ValueListenableBuilder<bool>(
              valueListenable: _hidePasswordNotifier,
              builder: (context, value, child) {
                Icon icon;
                if (value) {
                  icon = Icon(
                    Icons.remove_red_eye_outlined,
                    color: InvestrendTheme.of(context).greyLighterTextColor,
                  );
                } else {
                  icon = Icon(Icons.remove_red_eye,
                      color: Theme.of(context).colorScheme.secondary);
                }

                return getTextFieldForm(
                  context,
                  lightTheme,
                  '',
                  'register_field_password'.tr(),
                  'register_field_password_hint'.tr(),
                  'register_field_password_helper'.tr(),
                  'register_field_password_validation_error'.tr(),
                  textInputAction: TextInputAction.next,
                  obscureText: value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'register_field_password_validation_error'.tr();
                    }
                    return Utils.isPasswordCompliant(value, 8);
                  },
                  controller: fieldPasswordController,
                  suffixIcon: IconButton(
                      onPressed: () {
                        _hidePasswordNotifier.value = !value;
                      },
                      icon: icon),
                );
              }),

          /*
          getTextFieldForm(context, lightTheme, '', 'register_field_password_2'.tr(), 'register_field_password_2_hint'.tr(),
              'register_field_password_2_helper'.tr(), 'register_field_password_2_validation_error'.tr(),
              textInputAction: TextInputAction.next, obscureText: true, validator: (value) {
            // cek first password
            String error = Utils.isPasswordCompliant(fieldPasswordController.text, 8);
            if (!StringUtils.isEmtpy(error)) {
              return null; // first password error, biarin diisi dulu ampe bener :)
            } else {
              if (value == null || value.isEmpty) {
                return 'register_field_password_2_validation_error'.tr();
              }
              String error = Utils.isPasswordCompliant(value, 8);
              if (StringUtils.isEmtpy(error) && value != fieldPasswordController.text) {
                return 'error_password_confirm'.tr();
              }
              return error;
            }
          }),
          */
          ValueListenableBuilder<bool>(
              valueListenable: _hidePasswordConfirmNotifier,
              builder: (context, value, child) {
                Icon icon;
                if (value) {
                  icon = Icon(
                    Icons.remove_red_eye_outlined,
                    color: InvestrendTheme.of(context).greyLighterTextColor,
                  );
                } else {
                  icon = Icon(Icons.remove_red_eye,
                      color: Theme.of(context).colorScheme.secondary);
                }

                return getTextFieldForm(
                  context,
                  lightTheme,
                  '',
                  'register_field_password_2'.tr(),
                  'register_field_password_2_hint'.tr(),
                  'register_field_password_2_helper'.tr(),
                  'register_field_password_2_validation_error'.tr(),
                  textInputAction: TextInputAction.next,
                  obscureText: value,
                  validator: (value) {
                    // cek first password
                    String? error = Utils.isPasswordCompliant(
                        fieldPasswordController.text, 8);
                    if (!StringUtils.isEmtpy(error)) {
                      return null; // first password error, biarin diisi dulu ampe bener :)
                    } else {
                      if (value == null || value.isEmpty) {
                        return 'register_field_password_2_validation_error'
                            .tr();
                      }
                      //String error = Utils.isPasswordCompliant(value, 8);
                      //if (/*StringUtils.isEmtpy(error) &&*/ value != fieldPasswordController.text) {
                      if (fieldPasswordController.text !=
                          fieldPasswordConfirmController.text) {
                        return 'error_password_confirm'.tr();
                      }
                      return error;
                    }
                  },
                  controller: fieldPasswordConfirmController,
                  suffixIcon: IconButton(
                      onPressed: () {
                        _hidePasswordConfirmNotifier.value = !value;
                      },
                      icon: icon),
                );
              }),
          getTextFieldForm(
            context,
            lightTheme,
            '',
            'register_field_referral'.tr(),
            'register_field_referral_hint'.tr(),
            'register_field_referral_helper'.tr(),
            '',
            textInputAction: TextInputAction.done,
            controller: fieldReferralCodeController,
            validator: null,
          ),
          SizedBox(
            height: 30,
          ),
          getBottomContainer(context),
        ],
      ),
    );
  }

  void submitRegister() {
    // Validate returns true if the form is valid, or false otherwise.

    if (_formRegisterKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      /*
      String dataText = 'Registering with :\n   ' +
          fieldUsernameController.text +
          '\n   ' +
          fieldfullnameController.text +
          '\n   ' +
          fieldPhoneController.text +
          '\n   ' +
          fieldEmailController.text +
          '\n   ' +
          fieldPasswordController.text +
          '\n   ' +
          fieldReferralCodeController.text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataText)));
      */
      if (!_agreeTnCNotifier.value) {
        InvestrendTheme.of(context)
            .showSnackBar(context, 'register_agreement_error'.tr());
        return;
      }

      if (InvestrendTheme.CHECK_INVITATION) {
        Invitation invitation = Invitation('', false);
        invitation.load().then((value) {
          /*
          if(invitation.invitation_status){

          }else{

          }
          */

          var reply = InvestrendTheme.tradingHttp.register(
              fieldUsernameController.text,
              fieldfullnameController.text,
              '62' + fieldPhoneController.text,
              fieldEmailController.text,
              fieldPasswordController.text,
              fieldReferralCodeController.text,
              InvestrendTheme.of(context).applicationPlatform,
              InvestrendTheme.of(context).applicationVersion,
              invitation: invitation.invitation_code);
          reply.then((RegisterReply? value) {
            if (value != null) {
              if (value.isSuccess()) {
                InvestrendTheme.pushReplacement(
                    context,
                    ScreenRegisterPin(value.username, value.email,
                        fieldPasswordController.text, 'login'),
                    ScreenTransition.SlideLeft,
                    '/register_pin');
              } else {
                InvestrendTheme.of(context)
                    .showSnackBar(context, value.message);
              }
            }
          }).onError((error, stackTrace) {
            if (error is TradingHttpException) {
              if (error.isUnauthorized()) {
                InvestrendTheme.of(context).showDialogInvalidSession(context);
              } else if (error.isErrorTrading()) {
                InvestrendTheme.of(context)
                    .showSnackBar(context, error.message());
              } else {
                String networkErrorLabel = 'network_error_label'.tr();
                networkErrorLabel = networkErrorLabel.replaceFirst(
                    "#CODE#", error.code.toString());
                InvestrendTheme.of(context)
                    .showSnackBar(context, networkErrorLabel);
              }
            } else {
              InvestrendTheme.of(context)
                  .showSnackBar(context, error.toString());
            }
          });
        }).onError((error, stackTrace) {
          print('failed load invitation from disk');
          print(error);
          print(stackTrace);
        });
      } else {
        var reply = InvestrendTheme.tradingHttp.register(
            fieldUsernameController.text,
            fieldfullnameController.text,
            '62' + fieldPhoneController.text,
            fieldEmailController.text,
            fieldPasswordController.text,
            fieldReferralCodeController.text,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        reply.then((RegisterReply? value) {
          if (value != null) {
            if (value.isSuccess()) {
              InvestrendTheme.pushReplacement(
                  context,
                  ScreenRegisterPin(value.username, value.email,
                      fieldPasswordController.text, 'login'),
                  ScreenTransition.SlideLeft,
                  '/register_pin');
            } else {
              InvestrendTheme.of(context).showSnackBar(context, value.message);
            }
          }
        }).onError((error, stackTrace) {
          if (error is TradingHttpException) {
            if (error.isUnauthorized()) {
              InvestrendTheme.of(context).showDialogInvalidSession(context);
            } else if (error.isErrorTrading()) {
              InvestrendTheme.of(context)
                  .showSnackBar(context, error.message());
            } else {
              String networkErrorLabel = 'network_error_label'.tr();
              networkErrorLabel = networkErrorLabel.replaceFirst(
                  "#CODE#", error.code.toString());
              InvestrendTheme.of(context)
                  .showSnackBar(context, networkErrorLabel);
            }
          } else {
            InvestrendTheme.of(context).showSnackBar(context, error.toString());
          }
        });
      }
      /*
      var reply = InvestrendTheme.tradingHttp.register(fieldUsernameController.text,
          fieldfullnameController.text,
          '62'+fieldPhoneController.text,
          fieldEmailController.text,
          fieldPasswordController.text,
          fieldReferralCodeController.text,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      reply.then((value) {
        if(value != null){
          if(value.isSuccess()){
            InvestrendTheme.pushReplacement(context, ScreenRegisterPin(value.username, value.email, fieldPasswordController.text, 'login'), ScreenTransition.SlideLeft, '/register_pin');
          }else{
            InvestrendTheme.of(context).showSnackBar(context, value.message);
          }
        }
      }).onError((error, stackTrace) {
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
      */
    }
  }

  Widget getBottomContainer(BuildContext context) {
    return Column(
      children: [
        getTermAndConditionText(),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: ComponentCreator.roundedButton(
              context,
              'register_button_register'.tr(),
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
              submitRegister),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'landing_question_text'.tr(),
              style: InvestrendTheme.of(context).small_w400,
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: InvestrendTheme.of(context).hyperlink,
                  animationDuration: Duration(milliseconds: 500),
                  backgroundColor: Colors.transparent,
                  textStyle: InvestrendTheme.of(context).small_w500),
              child: Text('landing_button_enter'.tr()),
              onPressed: () {
                print('pressed');
                showLoginPage(context);
              },
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget getTermAndConditionText() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0, bottom: 20.0),
      child: Row(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _agreeTnCNotifier,
            builder: (context, value, child) {
              return Checkbox(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: _agreeTnCNotifier.value,
                  onChanged: (value) {
                    _agreeTnCNotifier.value = !_agreeTnCNotifier.value;
                    //print('remember '+_rememeberMeNotifier.value+' $value');
                  });
            },
          ),
          Flexible(
            child: RichText(
              textAlign: TextAlign.left,
              softWrap: true,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'register_description_1'.tr(),
                      style: InvestrendTheme.of(context).support_w400),
                  createButtonTextSpan(
                      context,
                      'settings_tnc'.tr() +
                          ' , ' +
                          'settings_disclaimer'.tr() +
                          'register_description_3'.tr() +
                          'settings_privacy_policy'.tr(), () {
                    print('tnc_content pressed');
                    String? content = 'tnc_content'.tr();
                    String? applicationName =
                        InvestrendTheme.of(context).applicationName;
                    content =
                        content.replaceAll('<APP_NAME/>', applicationName!);
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ScreenContent(
                            title: 'settings_tnc'.tr(),
                            content: content!,
                          ),
                          settings: RouteSettings(name: '/content'),
                        ));
                  }),
                  /*
                  createButtonTextSpan(context, 'settings_tnc'.tr(), () {
                    print('tnc_content pressed');
                    String content = 'tnc_content'.tr();
                    String applicationName = InvestrendTheme.of(context).applicationName;
                    content = content.replaceAll('<APP_NAME/>', applicationName);
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ScreenContent(
                            title: 'settings_tnc'.tr(),
                            content: content,
                          ),
                          settings: RouteSettings(name: '/content'),
                        ));

                  }),

                  TextSpan(text: ' , ', style: InvestrendTheme.of(context).support_w400),

                  createButtonTextSpan(context, 'settings_disclaimer'.tr(), () {
                    print('privacy_policy pressed');
                    String content = 'privacy_policy_content'.tr();
                    String applicationName = InvestrendTheme.of(context).applicationName;
                    content = content.replaceAll('<APP_NAME/>', applicationName);
                    Navigator.push(context, CupertinoPageRoute(
                      builder: (_) => ScreenContent(title: 'settings_disclaimer'.tr(), content: content,), settings: RouteSettings(name: '/content'),));
                  }),

                  TextSpan(text: 'register_description_3'.tr(), style: InvestrendTheme.of(context).support_w400),
                  createButtonTextSpan(context, 'settings_privacy_policy'.tr(), () {
                    print('disclaimer pressed');
                    String content = 'disclaimers_content'.tr();
                    String applicationName = InvestrendTheme.of(context).applicationName;
                    content = content.replaceAll('<APP_NAME/>', applicationName);
                    Navigator.push(context, CupertinoPageRoute(
                      builder: (_) => ScreenContent(title: 'settings_privacy_policy'.tr(), content: content,), settings: RouteSettings(name: '/content'),));
                  }),
                  */
                  TextSpan(
                      text: 'register_description_5'.tr(),
                      style: InvestrendTheme.of(context).support_w400),
                ],
              ),
            ),
          ),
        ],
      ),
    );

/*
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0, bottom: 20.0),
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'register_description_1'.tr(),
                  style: InvestrendTheme.of(context).support_w400),
              TextSpan(
                  text: 'register_description_2'.tr(),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      //launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html');
                      final snackBar = SnackBar(content: Text('Show EULA'));
                      // Find the ScaffoldMessenger in the widget tree
                      // and use it to show a SnackBar.
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  style: InvestrendTheme.of(context).support_w400?.copyWith(
                      color: InvestrendTheme.of(context).hyperlink,
                      decoration: TextDecoration.underline)),
              TextSpan(
                  text: 'register_description_3'.tr(),
                  style: InvestrendTheme.of(context).support_w400),
              TextSpan(
                  text: 'register_description_4'.tr(),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      //launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html');
                      final snackBar =
                          SnackBar(content: Text('Show Terms and Agreement'));
                      // Find the ScaffoldMessenger in the widget tree
                      // and use it to show a SnackBar.
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  style: InvestrendTheme.of(context).support_w400?.copyWith(
                      color: InvestrendTheme.of(context).hyperlink,
                      decoration: TextDecoration.underline)),
              TextSpan(
                  text: 'register_description_5'.tr(),
                  style: InvestrendTheme.of(context).support_w400),
            ],
          ),
        ),
      ),
    );
    */
  }

  TextSpan createButtonTextSpan(
      BuildContext context, String text, VoidCallback onPressed) {
    return TextSpan(
      text: text,
      recognizer: new TapGestureRecognizer()..onTap = onPressed,
      style: InvestrendTheme.of(context).support_w400?.copyWith(
          color: InvestrendTheme.of(context).hyperlink,
          decoration: TextDecoration.underline),
    );
  }

  void showLoginPage(BuildContext context) {
    //Navigator.pushReplacementNamed(context, '/login');
    //Navigator.pushReplacementNamed(context, '/landing');
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
        pageBuilder: (context, animation1, animation2) => ScreenLogin(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  Widget getTextFieldForm(
    BuildContext context,
    bool lightTheme,
    String prefixText,
    String labelText,
    String hintText,
    String helperText,
    String errorText, {
    bool? obscureText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    FormFieldValidator<String>? validator,
    TextEditingController? controller,
    GestureTapCallback? onTap,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    if (obscureText == null) obscureText = false;
    if (keyboardType == null) keyboardType = TextInputType.text;
    if (textInputAction == null) textInputAction = TextInputAction.done;
    return ComponentCreator.textFieldForm(
      context,
      lightTheme,
      prefixText,
      labelText,
      hintText,
      helperText,
      errorText,
      obscureText,
      keyboardType,
      textInputAction,
      validator,
      controller,
      onTap,
      focusNode,
      suffixIcon,
    );
  }
/*
  Widget getTextField(BuildContext context, bool lightTheme, String prefixText,
      String labelText, String hintText, String helperText, String errorText,
      {bool obscureText,
      TextInputType keyboardType,
      TextInputAction textInputAction}) {
    if (obscureText == null) obscureText = false;
    if (keyboardType == null) keyboardType = TextInputType.text;
    if (textInputAction == null) textInputAction = TextInputAction.done;

    if (StringUtils.isEmtpy(prefixText)) {
      return Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 0),
          child: TextFormField(
            keyboardType: keyboardType,
            //style: Theme.of(context).textTheme.bodyText2,
            // The validator receives the text that the user has entered.
            cursorColor: Theme.of(context).accentColor,
            textInputAction: textInputAction,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).accentColor, width: 2.0)),
              focusColor: Theme.of(context).accentColor,
              prefixStyle: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                  color: InvestrendCustomTheme.textfield_labelTextColor(
                      lightTheme)),
              prefixText: prefixText,
              labelText: labelText,
              labelStyle: TextStyle(
                  color: InvestrendCustomTheme.textfield_labelTextColor(
                      lightTheme)),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: hintText,
              helperText: helperText,
              helperMaxLines: 3,
              fillColor: Colors.grey,
              contentPadding: EdgeInsets.all(3.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return errorText;
              }
              return null;
            },
          ));
    } else {
      return Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 16, bottom: 0),
          child: Stack(children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3.0, bottom: 5.0),
                  child: Text(
                    prefixText,
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                        // backgroundColor: Colors.green,
                        color: InvestrendCustomTheme.textfield_labelTextColor(
                            lightTheme)),
                  ),
                ),
              ),
            ),
            TextFormField(
              keyboardType: keyboardType,
              //style: Theme.of(context).textTheme.bodyText2,
              // The validator receives the text that the user has entered.
              cursorColor: Theme.of(context).accentColor,
              textInputAction: textInputAction,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).accentColor, width: 2.0)),
                focusColor: Theme.of(context).accentColor,
                prefixStyle: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                    color: Colors.transparent),
                prefixText: prefixText,
                labelText: labelText,
                labelStyle: TextStyle(
                    color: InvestrendCustomTheme.textfield_labelTextColor(
                        lightTheme)),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: hintText,
                helperText: helperText,
                helperMaxLines: 3,
                fillColor: Colors.grey,
                contentPadding: EdgeInsets.all(3.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return errorText;
                }
                return null;
              },
            ),
          ]));
    }
  }

   */
}

/*
class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formRegisterKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    bool lightTheme =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Column(
      children: [
        Expanded(
          flex: 1,
          child:
        ),
        //getBottomContainer(),

      ],
    );
  }


}
*/
