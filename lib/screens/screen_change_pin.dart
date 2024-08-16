// ignore_for_file: unused_local_variable

import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenChangePin extends StatefulWidget {
  const ScreenChangePin({Key? key}) : super(key: key);

  @override
  State<ScreenChangePin> createState() => _ScreenChangePinState();
}

class _ScreenChangePinState extends State<ScreenChangePin> {
  TextEditingController fieldOldPin = TextEditingController(text: '');
  TextEditingController fieldNewPin = TextEditingController(text: '');
  TextEditingController fieldNewPinConfirmation =
      TextEditingController(text: '');

  FocusNode focusNodeOld = FocusNode();
  FocusNode focusNodeNew = FocusNode();
  FocusNode focusNodeNewConfirmation = FocusNode();

  final ValueNotifier<bool> _hideOldPinNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _hideNewPinNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _hideNewPinConfiirmationNotifier =
      ValueNotifier<bool>(true);

  @override
  void dispose() {
    fieldOldPin.dispose();
    fieldNewPin.dispose();
    fieldNewPinConfirmation.dispose();

    focusNodeOld.dispose();
    focusNodeNew.dispose();
    focusNodeNewConfirmation.dispose();

    _hideOldPinNotifier.dispose();
    _hideNewPinNotifier.dispose();
    _hideNewPinConfiirmationNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    double paddingTop = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      //floatingActionButton: createFloatingActionButton(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        shadowColor: shadowColor,
        elevation: elevation,
        title: AppBarTitleText('settings_change_pin'.tr()),
        // actions: [
        //   Image.asset(widget.icon, color: Theme.of(context).primaryColor,),
        // ],
        leading: AppBarActionIcon(
          'images/icons/action_back.png',
          () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.of(context).pop();
          },
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      body: ComponentCreator.keyboardHider(
          context, createBody(context, paddingBottom)),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  Widget? createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    if (paddingBottom == 0) {
      paddingBottom = InvestrendTheme.cardPaddingVertical;
    }
    bool lightTheme = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.only(
          // left: InvestrendTheme.cardPaddingGeneral,
          // right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: paddingBottom),
      //child: Text(content, style: InvestrendTheme.of(context).small_w400_greyDarker,),
      child: Column(
        children: [
          /*
          ComponentCreator.textFieldForm(context, lightTheme, '', 'change_pin_old'.tr(), 'change_pin_old'.tr(), '', '', false, TextInputType.number,
              TextInputAction.next, (value) => null, fieldOldPin, () {}, null, null,
              initialValue: null),
          ComponentCreator.textFieldForm(context, lightTheme, '', 'change_pin_new'.tr(), 'change_pin_new'.tr(), '', '', false, TextInputType.number,
              TextInputAction.next, (value) => null, fieldNewPin, () {}, null, null,
              initialValue: null),
          ComponentCreator.textFieldForm(context, lightTheme, '', 'change_pin_new_confirmation'.tr(), 'change_pin_new_confirmation'.tr(), '', '', false, TextInputType.number,
              TextInputAction.next, (value) => null, fieldNewPinConfirmation, () {}, null, null,
              initialValue: null),
          */
          getForm(context, lightTheme),

          //Spacer(flex: 1,),
          SizedBox(
            height: 20.0,
          ),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: ComponentCreator.roundedButton(
                context,
                'change_pin_button'.tr(),
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary, () {
              // on presss
              //EasyLocalization.of(context).setLocale(Locale('en'));
              //showRegisterPage(context);
              if (_formLChangePinKey.currentState!.validate()) {
                //onLoginClicked(context);
                //print('form change pin sesuai');
                changePin();
              }
            }),
          ),
          //Spacer(flex: 9,),
          SizedBox(
            height: 20.0,
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: InvestrendTheme.of(context).hyperlink,
                animationDuration: Duration(milliseconds: 500),
                backgroundColor: Colors.transparent,
                textStyle:
                    InvestrendTheme.of(context).small_w400_compact_greyDarker),
            child: Text('login_button_forgot_pin'.tr()),
            onPressed: () {
              print('forgot_pin pressed');
              //showLoginPage(context);
              //showRegisterPage(context);
              launchURL(
                  context, 'https://olt1.buanacapital.com:8888/manageaccount');
            },
          ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  final _formLChangePinKey = GlobalKey<FormState>();

  Widget getForm(BuildContext context, bool lightTheme) {
    return Form(
        key: _formLChangePinKey,
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _hideOldPinNotifier,
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
                  'change_pin_old'.tr(),
                  'change_pin_old_hint'.tr(),
                  'change_pin_old_helper'.tr(),
                  'change_pin_old_validation_error'.tr(),
                  textInputAction: TextInputAction.done,
                  obscureText: value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'change_pin_old_validation_error'.tr();
                    }
                    //return Utils.isPasswordCompliant(value, 8);
                    return null;
                  },
                  suffixIcon: IconButton(
                      onPressed: () {
                        _hideOldPinNotifier.value = !value;
                      },
                      icon: icon),
                  controller: fieldOldPin,
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _hideNewPinNotifier,
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
                  'change_pin_new'.tr(),
                  'change_pin_new_hint'.tr(),
                  'change_pin_new_helper'.tr(),
                  'change_pin_new_validation_error'.tr(),
                  textInputAction: TextInputAction.done,
                  obscureText: value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'change_pin_new_validation_error'.tr();
                    }
                    //return Utils.isPasswordCompliant(value, 8);
                    return null;
                  },
                  suffixIcon: IconButton(
                      onPressed: () {
                        _hideNewPinNotifier.value = !value;
                      },
                      icon: icon),
                  controller: fieldNewPin,
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _hideNewPinConfiirmationNotifier,
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
                  'change_pin_new_confirmation'.tr(),
                  'change_pin_new_confirmation_hint'.tr(),
                  'change_pin_new_confirmation_helper'.tr(),
                  'change_pin_new_confirmation_validation_error'.tr(),
                  textInputAction: TextInputAction.done,
                  obscureText: value,
                  validator: (value) {
                    if (!StringUtils.equalsIgnoreCase(
                        fieldNewPinConfirmation.text, fieldNewPin.text)) {
                      return 'change_pin_new_confirmation_validation_error'
                          .tr();
                    }
                    //return Utils.isPasswordCompliant(value, 8);
                    return null;
                  },
                  suffixIcon: IconButton(
                      onPressed: () {
                        _hideNewPinConfiirmationNotifier.value = !value;
                      },
                      icon: icon),
                  controller: fieldNewPinConfirmation,
                );
              },
            ),
          ],
        ));
  }

  Future changePin() {
    Future reply = InvestrendTheme.tradingHttp.changePin(
        context.read(dataHolderChangeNotifier).user.username!,
        fieldOldPin.text,
        fieldNewPin.text,
        InvestrendTheme.of(context).applicationPlatform,
        InvestrendTheme.of(context).applicationVersion);
    reply.then((value) {
      if (value != null) {
        if (value.isSuccess()) {
          InvestrendTheme.of(context).showSnackBar(context, value.message);
          fieldOldPin.text = '';
          fieldNewPin.text = '';
          fieldNewPinConfirmation.text = '';
          Navigator.of(context).pop();
          // if(StringUtils.equalsIgnoreCase(widget.nextPage, 'login')){
          //   InvestrendTheme.pushReplacement(context, ScreenLogin(initialUser: value.username, initialEmail:value.email, initialPassword: widget.password,), ScreenTransition.Fade, '/login');
          // }else{
          //   //InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.Fade, '/main');
          //   InvestrendTheme.showMainPage(context, ScreenTransition.Fade);
          // }
        } else {
          InvestrendTheme.of(context).showSnackBar(context, value.message);
        }
      }
    }).onError((error, stackTrace) {
      if (error is TradingHttpException) {
        if (error.isUnauthorized()) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        } else if (error.isErrorTrading()) {
          InvestrendTheme.of(context).showSnackBar(context, error.message());
        } else {
          String networkErrorLabel = 'network_error_label'.tr();
          networkErrorLabel =
              networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
        }
      } else {
        InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
    });
    return reply;
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
    if (keyboardType == null) keyboardType = TextInputType.number;
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
      maxLenght: 4,
    );
  }

  void launchURL(BuildContext context, String _url) async {
    try {
      await canLaunchUrl(Uri.dataFromString(_url))
          ? await launchUrl(Uri.dataFromString(_url))
          : throw 'Could not launch $_url';
    } catch (error) {
      InvestrendTheme.of(context).showSnackBar(context, error.toString());
    }
  }
}
