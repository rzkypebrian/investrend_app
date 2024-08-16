// ignore_for_file: unused_field, unused_local_variable, unnecessary_null_comparison

import 'dart:async';
import 'dart:io';

import 'package:Investrend/component/broker_rank.dart';
import 'package:Investrend/component/broker_trade_summary.dart';
import 'package:Investrend/component/charts/trading_view_chart.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/filter/filter.dart';
import 'package:Investrend/component/trade_done.dart';
import 'package:Investrend/new_component/webview_new.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/onboarding/screen_friends.dart';
import 'package:Investrend/screens/onboarding/screen_register_pin.dart';
import 'package:Investrend/screens/onboarding/screen_register.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenLogin extends StatefulWidget {
  final String initialUser;
  final String initialEmail;
  final String initialPassword;
  final bool autoLogon;

  ScreenLogin(
      {this.initialUser = '',
      this.initialEmail = '',
      this.initialPassword = '',
      this.autoLogon = true});

  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

const PROP_CLIENT_AGREEMENT = 'client_agreement-0';

class _ScreenLoginState extends State<ScreenLogin> {
  final String routeName = '/login';

  LoginConfig config = LoginConfig();
  final LoadingBottomNotifier _loadingNotifier = LoadingBottomNotifier();
  final _formLoginKey = GlobalKey<FormState>();
  TextEditingController? fieldEmailController;
  TextEditingController? fieldPasswordController;
  final ValueNotifier<bool> _rememberMeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hidePasswordNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<List<String>> listOverViewNotifier =
      ValueNotifier<List<String>>([]);

  DateFormat _formatDate = DateFormat('yyyyMMdd');

  ValueNotifier<String> _versionNotifier = ValueNotifier<String>(' ');

  //biometric
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  bool _authenticated = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fieldEmailController?.dispose();
    fieldPasswordController?.dispose();
    _rememberMeNotifier.dispose();
    _loadingNotifier.dispose();
    _versionNotifier.dispose();
    _hidePasswordNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      _versionNotifier.value = 'v' + version + ' ' + buildNumber;
    });

    fieldEmailController = TextEditingController(
        text: StringUtils.noNullString(widget.initialEmail));
    fieldPasswordController = TextEditingController(
        text: StringUtils.noNullString(widget.initialPassword));

    print('initState initialEmail : ' + widget.initialEmail);

    _checkBiometric();

    loadFirstTime();
  }

  Token token = Token('', '');
  void loadFirstTime() async {
    bool hasToken = false;
    try {
      bool tok = await token.load();
      hasToken = !StringUtils.isEmtpy(token.access_token) &&
          !StringUtils.isEmtpy(token.refresh_token);
      debugPrint("${token.access_token}");
      print('/login loadFirstTime Token.load hasToken : $hasToken');
    } catch (e) {
      print('/login loadFirstTime Token.load error : ' + e.toString());
      print(e);
    }
    try {
      bool conf = await config.load();
    } catch (e) {
      print('/login loadFirstTime LoginConfig.load error : ' + e.toString());
      print(e);
    }
    _rememberMeNotifier.value = config.rememberMe;

    if (config.rememberMe) {
      //BIOMETRIC MUNCUL DISINI
      if (config.useBiometrics) {
        bool isAuthenticated = await authenticateBiometrics();

        if (isAuthenticated == false) return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //bool production = context.read(propertiesNotifier).properties.getBool(routeName, 'production', true);

        if (!StringUtils.isEmtpy(widget.initialEmail)) {
          fieldEmailController?.text = widget.initialEmail;
          DebugWriter.info('loadFirstTime rememberMe using initialEmail : ' +
              widget.initialEmail);
        } else {
          fieldEmailController?.text = config.email;
          DebugWriter.info(
              'loadFirstTime rememberMe using savedEmail : ' + config.email);
        }
        if (hasToken) {
          fieldPasswordController?.text = 'refresh_token';
          if (widget.autoLogon) {
            refreshToken(token.refresh_token);
          }
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //bool production = context.read(propertiesNotifier).properties.getBool(routeName, 'production', true);

        if (!StringUtils.isEmtpy(widget.initialEmail)) {
          fieldEmailController?.text = widget.initialEmail;
          DebugWriter.info(
              'loadFirstTime NOT rememberMe using initialEmail : ' +
                  widget.initialEmail);
        } else {
          fieldEmailController?.text = config.email;
          DebugWriter.info('loadFirstTime NOT rememberMe using savedEmail : ' +
              config.email);
        }
      });
    }

    _rememberMeNotifier.addListener(() {
      saveConfig();
    });

    //loadHelps(context);
  }

  void saveConfig() {
    if (_rememberMeNotifier.value) {
      config.update(true, '', fieldEmailController!.text);
    } else {
      config.update(false, '', fieldEmailController!.text);
    }
    config.save();
  }

  Future<void> _checkBiometric() async {
    final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (canCheckBiometrics) {
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        setState(() {
          _isBiometricEnabled = true;
        });
      }
    }
  }

  Future<bool> authenticateBiometrics() async {
    List<BiometricType> availableBiometrics =
        await _localAuth.getAvailableBiometrics();
    if (availableBiometrics.contains(BiometricType.fingerprint) ||
        availableBiometrics.contains(BiometricType.face)) {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      setState(() {
        _authenticated = authenticated;
      });
      return authenticated;
    } else {
      setState(() {
        _authenticated = true;
      });
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ComponentCreator.keyboardHider(context, createBody(context)),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }

  void launchURL(BuildContext context, String _url) async {
    try {
      await canLaunchUrl(Uri.dataFromString(_url))
          ? await launchUrl(Uri.dataFromString(_url))
          : throw 'Could not launch $_url';
    } catch (error) {
      //InvestrendTheme.of(context).showSnackBar(context, error.toString());
    }
  }

  Widget createBody(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double top = height * 0.07;
    double imageSize = width * 0.7;
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    bool? accentColorIsNull = Theme.of(context).colorScheme.secondary == null;
    print('lightTheme : $lightTheme  accentColorIsNull : $accentColorIsNull');

    double spacerHeight = 10.0;
    print('height : $height');

    if (height >= 926) {
      spacerHeight = 65.0;
    } else if (height >= 844) {
      spacerHeight = 50.0;
    } else if (height >= 812) {
      spacerHeight = 40.0;
    } else if (height >= 736) {
      spacerHeight = 25.0;
    } else if (height >= 667) {
      spacerHeight = 12.0;
    }

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      children: [
        SizedBox(
          height: top,
        ),
        Center(child: Image.asset(InvestrendTheme.of(context).ic_launcher!)),
        Container(
          width: double.maxFinite,
          height: elevation,
          color: shadowColor,
        ),
        SizedBox(
          height: spacerHeight,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('login_text_greeting'.tr(),
                style: InvestrendTheme.of(context).headline3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'login_text_continue'.tr(),
              style: InvestrendTheme.of(context).regular_w400_greyDarker,
            ),
          ),
        ),
        SizedBox(
          height: spacerHeight,
        ),
        getForm(context, lightTheme),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: FilterPage.filterOverview(
                context: context,
                valueListenable: listOverViewNotifier,
              ),
            ),
            Container(
              child: IconButton(
                onPressed: () {
                  showBrokerTradePage(context);
                },
                icon: Icon(Icons.track_changes_rounded),
              ),
            ),
            Container(
              child: IconButton(
                icon: Icon(
                  Icons.radio_button_checked,
                ),
                onPressed: () {
                  showBrokerRank(context);
                },
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  showLeaderboardsPage(context);
                },
                icon: Icon(
                  Icons.access_time_filled,
                ),
              ),
            ),
            // IconButton(
            //   onPressed: () {
            //     showBiometricLogin(context);
            //   },
            //   icon: Icon(
            //     Icons.fingerprint,
            //   ),
            // ),

            IconButton(
              onPressed: () {
                showWebviewPage(context);
              },
              icon: Icon(Icons.wine_bar_sharp),
            ),
            IconButton(
              onPressed: () {
                showTradingViewPage(context);
              },
              icon: Icon(Icons.auto_graph_rounded),
            ),
            ValueListenableBuilder<bool>(
                valueListenable: _rememberMeNotifier,
                builder: (context, value, child) {
                  return Checkbox(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      value: _rememberMeNotifier.value,
                      onChanged: (value) {
                        _rememberMeNotifier.value = !_rememberMeNotifier.value;
                      });
                }),
            Text(
              'login_checkbox_text'.tr(),
              style: InvestrendTheme.of(context).small_w400_compact_greyDarker,
            ),
            SizedBox(
              width: 16,
            )
          ],
        ),
        SizedBox(
          height: spacerHeight,
        ),
        FractionallySizedBox(
          widthFactor: 0.7,
          child: ComponentCreator.roundedButton(
              context,
              'login_button_enter'.tr(),
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary, () {
            if (_formLoginKey.currentState!.validate()) {
              if (StringUtils.equalsIgnoreCase(
                      fieldPasswordController!.text, 'refresh_token') &&
                  !StringUtils.isEmtpy(token.refresh_token)) {
                refreshToken(token.refresh_token);
              } else {
                onLoginClicked(context);
              }
            }
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'login_question_text'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: InvestrendTheme.of(context).hyperlink,
                  animationDuration: Duration(milliseconds: 500),
                  backgroundColor: Colors.transparent,
                  textStyle: InvestrendTheme.of(context).small_w400_greyDarker),
              child: Text('login_button_register'.tr()),
              onPressed: () {
                print('register pressed');
                showRegisterPage(context);
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: InvestrendTheme.of(context).hyperlink,
                  animationDuration: Duration(milliseconds: 500),
                  backgroundColor: Colors.transparent,
                  textStyle: InvestrendTheme.of(context)
                      .small_w400_compact_greyDarker),
              child: Text('login_button_forgot_password'.tr()),
              onPressed: () {
                print('forgot_password pressed');
                launchURL(context,
                    'https://olt1.buanacapital.com:8888/manageaccount');
              },
            ),
          ],
        ),
        SizedBox(
          height: spacerHeight,
        ),
        ValueListenableBuilder(
          valueListenable: _versionNotifier,
          builder: (context, value, child) {
            return Center(
                child: Text(
              value as String,
              style: InvestrendTheme.of(context)
                  .more_support_w400_compact
                  ?.copyWith(
                      color: InvestrendTheme.of(context).greyLighterTextColor),
            ));
          },
        ),
      ],
    );
  }

  Widget getForm(BuildContext context, bool lightTheme) {
    return Form(
        key: _formLoginKey,
        child: Column(
          children: [
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
              controller: fieldEmailController!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'register_field_email_validation_error'.tr();
                }
                return Utils.isEmailCompliant(value);
                //return null;
              },
            ),
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
                    textInputAction: TextInputAction.done,
                    obscureText: value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'register_field_password_validation_error'.tr();
                      }
                      //return Utils.isPasswordCompliant(value, 8);
                      return null;
                    },
                    suffixIcon: IconButton(
                        onPressed: () {
                          _hidePasswordNotifier.value = !value;
                        },
                        icon: icon),
                    controller: fieldPasswordController!,
                  );
                }),
          ],
        ));
  }

  void showDialogExpireBuid(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Build Invalid'),
        //content: Text('This App "Build" $expireDate is no longer valid, please update the app!'),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: 'This App "',
              style: InvestrendTheme.of(context).small_w400,
              children: [
                TextSpan(
                  text: 'Build',
                  style: InvestrendTheme.of(context)
                      .small_w600
                      ?.copyWith(color: Colors.orange),
                ),
                TextSpan(
                  text: '" ',
                  style: InvestrendTheme.of(context).small_w400,
                ),
                // TextSpan(
                //   text: '$expireDate',
                //   style: InvestrendTheme.of(context).small_w700.copyWith(color: Colors.cyanAccent),
                // ),
                TextSpan(
                  text: '\nis ',
                  style: InvestrendTheme.of(context).small_w400,
                ),
                TextSpan(
                  text: 'no longer valid',
                  style: InvestrendTheme.of(context)
                      .small_w600
                      ?.copyWith(color: Colors.red),
                ),
                TextSpan(
                  text: '\n\nPlease update the app!',
                  style: InvestrendTheme.of(context).small_w400,
                ),
              ]),
        ),

        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Close'),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool loadingShowed = false;

  void closeLoading() {
    if (loadingShowed && _loadingNotifier.hasCloseListeners()) {
      _loadingNotifier.notifyClose();
      //_loadingNotifier.closeNotifier.value = !_loadingNotifier.closeNotifier.value;
      //_loadingCloseNotifier.value = !_loadingCloseNotifier.value;
    }
  }

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
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0)),
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

  void refreshToken(String? refreshToken) {
    context.read(propertiesNotifier).setNeedPinTrading(true);

    showLoading('loading_refresh_token_label'.tr());

    final result = InvestrendTheme.tradingHttp.refresh(
        InvestrendTheme.of(context).applicationPlatform,
        InvestrendTheme.of(context).applicationVersion,
        refresh_token: refreshToken);
    result.then((value) {
      print('refresh--------------------');
      DebugWriter.info('username = ' + value.username!);
      DebugWriter.info('realname = ' + value.realname!);
      DebugWriter.info('feepct = ' + value.feepct.toString());
      DebugWriter.info('lotsize = ' + value.lotsize.toString());
      DebugWriter.info('access_token = ' + value.token!.access_token!);
      DebugWriter.info('refresh_token = ' + value.token!.refresh_token!);
      DebugWriter.info(
          'accounts.length = ' + value.accounts!.length.toString());
      DebugWriter.info('b_ip = ' + value.b_ip!);
      DebugWriter.info('b_multi = ' + value.b_multi!);
      DebugWriter.info('b_pass = ' + value.b_pass!);
      DebugWriter.info('b_port = ' + value.b_port.toString());
      DebugWriter.info('r_ip = ' + value.r_ip!);
      DebugWriter.info('r_multi = ' + value.r_multi!);
      DebugWriter.info('r_port = ' + value.r_port.toString());
      processResponseLoginRefresh(value);
    }).onError((error, stackTrace) {
      Future.delayed(Duration(milliseconds: 700), () {
        if (error is TradingHttpException) {
          if (error.isUnauthorized()) {
            fieldPasswordController?.text = '';
            InvestrendTheme.of(context).showDialogInvalidSession(context,
                onClosePressed: () {
              Navigator.pop(context);
            }, checkLogged: false);
          } else if (error.isErrorTrading()) {
            InvestrendTheme.of(context).showSnackBar(context, error.message());
          } else {
            String networkErrorLabel = 'network_error_label'.tr();
            networkErrorLabel =
                networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
            InvestrendTheme.of(context)
                .showSnackBar(context, networkErrorLabel);
          }
        } else if (error is TimeoutException) {
          String networkErrorTimeOutLabel = 'network_error_time_out_label'.tr();
          InvestrendTheme.of(context)
              .showSnackBar(context, networkErrorTimeOutLabel);
        } else {
          //InvestrendTheme.of(context).showSnackBar(context, error.toString());

          String errorText = Utils.removeServerAddress(error.toString());
          InvestrendTheme.of(context).showSnackBar(context, errorText);
        }
      });
    });
  }

/*
  void showRegisterRDNPage(BuildContext context) {
    // InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.SlideUp, '/main');

    Navigator.push(
      context,
      PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 1000),
          //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
          pageBuilder: (context, animation1, animation2) => ScreenRegisterRDN(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimationCreator.transitionSlideUp(
                context, animation, secondaryAnimation, child);
          }
          // transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          //     FadeTransition(
          //   opacity: animation,
          //   child: child,
          // ),
          ),
    );
  }
  */

  void processResponseLoginRefresh(User value) async {
    InvestrendTheme.datafeedHttp.serverAddress.update(
        value.b_ip!,
        value.b_multi!,
        value.b_pass!,
        value.b_port!,
        value.r_ip!,
        value.r_multi!,
        value.r_port!);
    await InvestrendTheme.datafeedHttp.serverAddress.save();
    await InvestrendTheme.datafeedHttp.serverAddress.load();

    DebugWriter.info(
        "ONLOGIN " + InvestrendTheme.datafeedHttp.serverAddress.toString());

    config.update(_rememberMeNotifier.value, value.username!, value.email!);
    context.read(dataHolderChangeNotifier).user.update(
        value.username!,
        value.realname!,
        value.feepct!,
        value.lotsize!,
        value.accounts!,
        value.token!,
        value.message!,
        value.email!,
        value.b_ip!,
        value.b_multi!,
        value.b_pass!,
        value.b_port!,
        value.r_ip!,
        value.r_multi!,
        value.r_port!);
    DebugWriter.info(context.read(dataHolderChangeNotifier).user.toString());
    context.read(dataHolderChangeNotifier).isLogged = true;
    context.read(dataHolderChangeNotifier).isForeground = true;
    String urlProfile = 'https://' +
        InvestrendTheme.tradingHttp.tradingBaseUrl +
        '/getpic?username=' +
        value.username! +
        '&url=&nocache=' +
        DateTime.now().toString();
    context.read(avatarChangeNotifier).setUrl(urlProfile);
    context.read(accountChangeNotifier).setIndex(0);

    context.read(managerDatafeedNotifier).initiate(
          clientUsername: value.username!,
          ip: value.b_ip!, //'36.89.110.91',
          port: value.b_port!, //3911,
          password: value.b_pass!, //'b1aae845890dd94829ea48d3cdd1dede1',
          platform: InvestrendTheme.of(context).applicationPlatform,
          version: InvestrendTheme.of(context).applicationVersion,
        );
    context.read(managerEventNotifier).initiate(
          clientUsername: value.username!,
          ip: value.b_ip!, //'36.89.110.91',
          port: value.b_port!, //3911,
          password: value.b_pass!, //'b1aae845890dd94829ea48d3cdd1dede1',
          platform: InvestrendTheme.of(context).applicationPlatform,
          version: InvestrendTheme.of(context).applicationVersion,
        );

    checkVersion(context);
  }

  static final int expireDate = 20211030; // YEAR MONTH DATE
  void onLoginClicked(BuildContext context, {bool useLogin = true}) async {
    // If the form is valid, display a snackbar. In the real world,
    // you'd often call a server or save the information in a database.

    context.read(propertiesNotifier).setNeedPinTrading(true);
    if (useLogin) {
      showLoading('loading_loging_in_label'.tr());

      saveConfig();
      String username = fieldEmailController!.text;
      String password = fieldPasswordController!.text;
      Future<User> result = InvestrendTheme.tradingHttp.login(
          username,
          password,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);

      result.then((value) {
        step = 1;
        print('step = $step');
        print('login--------------------');
        DebugWriter.info('username = ' + value.username!);
        DebugWriter.info('realname = ' + value.realname!);
        DebugWriter.info('feepct = ' + value.feepct.toString());
        DebugWriter.info('lotsize = ' + value.lotsize.toString());
        DebugWriter.info('access_token = ' + value.token!.access_token!);
        DebugWriter.info('refresh_token = ' + value.token!.refresh_token!);
        DebugWriter.info(
            'accounts.length = ' + value.accounts!.length.toString());

        DebugWriter.info('b_ip = ' + value.b_ip!);
        DebugWriter.info('b_multi = ' + value.b_multi!);
        DebugWriter.info('b_pass = ' + value.b_pass!);
        DebugWriter.info('b_port = ' + value.b_port.toString());
        DebugWriter.info('r_ip = ' + value.r_ip!);
        DebugWriter.info('r_multi = ' + value.r_multi!);
        DebugWriter.info('r_port = ' + value.r_port.toString());
        processResponseLoginRefresh(value);
      }).onError((error, stackTrace) {
        closeLoading();
        print(error);
        Future.delayed(Duration(milliseconds: 700), () {
          if (error is TradingHttpException) {
            if (error.isUnauthorized()) {
              // statusCode 401
              InvestrendTheme.of(context).showDialogInvalidSession(context,
                  message: error.message(), onClosePressed: () {
                Navigator.pop(context);
              });
            } else if (error.isErrorTrading()) {
              // statusCode  500
              InvestrendTheme.of(context)
                  .showSnackBar(context, error.message());
            } else {
              String networkErrorLabel = 'network_error_label'.tr();
              networkErrorLabel = networkErrorLabel.replaceFirst(
                  "#CODE#", error.code.toString());
              InvestrendTheme.of(context)
                  .showSnackBar(context, networkErrorLabel);
            }
          } else if (error is TimeoutException) {
            String networkErrorTimeOutLabel =
                'network_error_time_out_label'.tr();
            InvestrendTheme.of(context)
                .showSnackBar(context, networkErrorTimeOutLabel);
          } else {
            String errorText = Utils.removeServerAddress(error.toString());
            InvestrendTheme.of(context).showSnackBar(context, errorText);
          }
        });
      });
    } else {
      showDialogWarningNoLoginNoOrder(context);
    }
  }

  void showDialogWarningNoLoginNoOrder(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Warning'),
        //content: const Text('Login and Order is DISABLED!'),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: 'Login',
              style: InvestrendTheme.of(context)
                  .small_w600
                  ?.copyWith(color: Colors.orange),
              children: [
                TextSpan(
                  text: ' and ',
                  style: InvestrendTheme.of(context).small_w400,
                ),
                TextSpan(
                  text: 'Order',
                  style: InvestrendTheme.of(context)
                      .small_w600
                      ?.copyWith(color: Colors.orange),
                ),
                TextSpan(
                  text: ' is ',
                  style: InvestrendTheme.of(context).small_w400,
                ),
                TextSpan(
                  text: 'DISABLED!',
                  style: InvestrendTheme.of(context)
                      .small_w600
                      ?.copyWith(color: InvestrendTheme.redText),
                ),
              ]),
        ),

        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'Back'),
          ),
          TextButton(
            child: const Text(
              'I\'m Good',
              style: TextStyle(color: Colors.greenAccent),
            ),
            onPressed: () {
              //showMainPage(context);
              //loadDataStockBrokerIndex(context, noLogin: true);
              checkVersion(context, noLogin: true);
            },
          ),
        ],
      ),
    );
  }

  void showMainPage(BuildContext context) {
    InvestrendTheme.showMainPage(context, ScreenTransition.Fade);
    //InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.Fade, '/main');
    /*
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
        pageBuilder: (context, animation1, animation2) => ScreenMain(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
     */
  }

  void showWebviewPage(BuildContext context) {
    InvestrendTheme.push(
        context, WebviewNew(), ScreenTransition.SlideDown, '/WebviewNew');
  }

  void showTradingViewPage(BuildContext context) {
    InvestrendTheme.push(context, TradingViewChartPage(), ScreenTransition.Fade,
        '/tradingViewChart');
  }

  void showBrokerTradePage(BuildContext context) {
    InvestrendTheme.push(context, BrokerTradeSummary(), ScreenTransition.Fade,
        '/brokerTradeSummary');
  }

  void showLeaderboardsPage(BuildContext context) {
    InvestrendTheme.push(
        context, TradeDone(), ScreenTransition.Fade, '/leaderboards');
  }

  void showBrokerRank(BuildContext context) {
    InvestrendTheme.push(
        context, BrokerRank(), ScreenTransition.Fade, '/brokerRating');
  }

  // void showBiometricLogin(BuildContext context) {
  //   InvestrendTheme.push(
  //       context, FastOrderNew(), ScreenTransition.Fade, '/signaturepad');
  // }

  void showFriendsPage(BuildContext context) {
    InvestrendTheme.pushReplacement(
        context, ScreenFriends(), ScreenTransition.Fade, '/friends');
    /*
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
        pageBuilder: (context, animation1, animation2) => ScreenFriends(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
     */
  }

  void loadHelps(BuildContext context) async {
    const String routeName = '/login';

    try {
      await context.read(helpNotifier).data?.load();
    } catch (error) {
      print(routeName + ' Future help load Error');
      print(error);
    }

    try {
      String? md5HelpContents =
          context.read(helpNotifier).data?.md5_help_contents;
      String? md5HelpMenus = context.read(helpNotifier).data?.md5_help_menus;
      final help = await InvestrendTheme.datafeedHttp.fetchHelp(
          md5_help_contents: md5HelpContents, md5_help_menus: md5HelpMenus);
      if (help != null) {
        print(routeName + ' Future help DATA : ' + help.toString());
        //_summaryNotifier.setData(stockSummary);
        bool menusChanged =
            !StringUtils.equalsIgnoreCase(md5HelpMenus, help.md5_help_menus) &&
                help.menus != null &&
                help.menus!.isNotEmpty;
        bool contentChanged = !StringUtils.equalsIgnoreCase(
                md5HelpContents, help.md5_help_contents) &&
            help.contents != null &&
            help.md5_help_contents!.isNotEmpty;

        if (menusChanged) {
          context
              .read(helpNotifier)
              .data
              ?.updateMenus(help.md5_help_menus, help.menus);
        }
        if (contentChanged) {
          context
              .read(helpNotifier)
              .data
              ?.updateContents(help.md5_help_contents, help.contents);
        }
        if (menusChanged || contentChanged) {
          context.read(helpNotifier).data?.save();
        }
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        context.read(helpNotifier).notifyListeners();
      } else {
        print(routeName + ' Future help NO DATA');
      }
    } catch (error) {
      print(routeName + ' Future help Error');
      print(error);
    }
  }

  void checkVersion(BuildContext context, {bool noLogin = false}) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String versionCode = packageInfo.version;
      double versionNumber = Utils.safeDouble(packageInfo.buildNumber);
      //versionNotifier.value = 'v'+version+' '+buildNumber;

      showLoading('loading_version_label'.tr());
      String platform = Platform.isIOS ? 'ios' : 'android';
      final Future<Version>? version =
          InvestrendTheme.datafeedHttp.checkVersion(platform);
      if (version != null) {
        version.then((server) {
          if (!server.isEmpty()) {
            closeLoading();

            print('Device versionCode   : $versionCode');
            print('Device versionNumber : $versionNumber');
            print('Server versionCode   : ' + server.version_code!);
            print('Server versionNumber : ' + server.version_number.toString());
            print('Server minimum_version_code : ' +
                server.minimum_version_code.toString());
            print('Server minimum_version_number : ' +
                server.minimum_version_number.toString());
            /*
            flutter: Device versionCode   : 1.0.0
            flutter: Device versionNumber : 78.0
            flutter: Server versionCode   : 1.0.0
            flutter: Server versionNumber : 70.0
            flutter: Server minimum_version_code : 1.0.0
            flutter: Server minimum_version_number : 70.0
            */

            bool isMandatory = false;
            bool isMinor = false;

            // if (Utils.isVersionCodeNewer(versionCode, server.version_code)) {
            //   if (Utils.isVersionCodeNewer(
            //       versionCode, server.minimum_version_code)) {
            //     // mandatory
            //     isMandatory = true;
            //   } else {
            //     // not mandatory
            //     isMinor = true;
            //   }
            // } else if (Utils.isVersionCodeOlder(
            //     versionCode, server.version_code)) {
            //   print('version isOlder');
            // } else {
            //   // same version code, check version number
            //   if (versionNumber < server.minimum_version_number) {
            //     // mandatory
            //     isMandatory = true;
            //   } else if (versionNumber < server.version_number) {
            //     // not mandatory
            //     isMinor = true;
            //   }
            // }

            print('version isMandatory : $isMandatory');
            print('version isMinor : $isMinor');
            if (isMandatory == true) {
              // major upgrade
              String title = 'version_label'.tr() +
                  ' ' +
                  server.version_code! +
                  ' ' +
                  server.version_number.toString();
              String content = 'version_major_upgrade_label'.tr();
              content = content + '\n\n' + server.changes_notes!;
              //InvestrendTheme.of(context).showInfoDialog(context, title: title, content: content);

              String buttonYes = 'button_update'.tr();
              // if(Platform.isIOS){
              //   buttonYes = 'button_open_appstore'.tr();
              // }else if(Platform.isAndroid){
              //   buttonYes = 'button_open_playtore'.tr();
              // }
              String buttonNo = 'button_close'.tr();
              VoidCallback onPressedYes = () {
                Navigator.of(context).pop();

                // StoreRedirect.redirect(androidAppId: "com.investrend.afs.investrend_app",
                //     iOSAppId: "1570771595");

                if (Platform.isIOS) {
                  launchURL(context,
                      'https://apps.apple.com/us/app/tren-investasi-saham/id1570771595');
                } else if (Platform.isAndroid) {
                  launchURL(context,
                      'https://market.android.com/details?id=com.investrend.afs.investrend_app&feature=search_result');
                }
                //
              };
              VoidCallback onPressedNo = () {
                Navigator.of(context).pop();
              };

              InvestrendTheme.of(context).showDialogPlatform(
                  context, title, content,
                  buttonYes: buttonYes,
                  buttonNo: buttonNo,
                  onPressedYes: onPressedYes,
                  onPressedNo: onPressedNo);
            } else if (isMinor == isMinor) {
              // minor upgrade
              String title = 'version_label'.tr() +
                  ' ' +
                  server.version_code! +
                  ' ' +
                  server.version_number.toString();
              String content = 'version_minor_upgrade_label'.tr();
              content = content + '\n\n' + server.changes_notes!;
              // InvestrendTheme.of(context).showInfoDialog(context, title: title, content: content, onClose: () {
              //   loadDataStockBrokerIndex(context, noLogin: noLogin);
              //   loadHelps(context);
              // });

              String buttonYes = 'button_update'.tr();
              // if(Platform.isIOS){
              //   buttonYes = 'button_open_appstore'.tr();
              // }else if(Platform.isAndroid){
              //   buttonYes = 'button_open_playtore'.tr();
              // }
              String buttonNo = 'button_skip'.tr();
              VoidCallback onPressedYes = () {
                Navigator.of(context).pop();
                // StoreRedirect.redirect(androidAppId: "com.investrend.afs.investrend_app",
                //     iOSAppId: "1570771595");

                if (Platform.isIOS) {
                  launchURL(context,
                      'https://apps.apple.com/us/app/tren-investasi-saham/id1570771595');
                } else if (Platform.isAndroid) {
                  launchURL(context,
                      'https://market.android.com/details?id=com.investrend.afs.investrend_app&feature=search_result');
                }
              };
              VoidCallback onPressedNo = () {
                Navigator.of(context).pop();
                loadDataStockBrokerIndex(context, noLogin: noLogin);
                loadHelps(context);
              };

              InvestrendTheme.of(context).showDialogPlatform(
                  context, title, content,
                  buttonYes: buttonYes,
                  buttonNo: buttonNo,
                  onPressedYes: onPressedYes,
                  onPressedNo: onPressedNo);
            } else {
              loadDataStockBrokerIndex(context, noLogin: noLogin);
              loadHelps(context);
            }

            /* ASLI 2022-03-10
            if (versionNumber < server.minimum_version_number) {
              // major upgrade
              String title = 'version_label'.tr() + ' ' + server.version_code + ' ' + server.version_number.toString();
              String content = 'version_major_upgrade_label'.tr();
              content = content + '\n\n' + server.changes_notes;
              InvestrendTheme.of(context).showInfoDialog(context, title: title, content: content);
            } else if (versionNumber < server.version_number) {
              // minor upgrade
              String title = 'version_label'.tr() + ' ' + server.version_code + ' ' + server.version_number.toString();
              String content = 'version_minor_upgrade_label'.tr();
              content = content + '\n\n' + server.changes_notes;
              InvestrendTheme.of(context).showInfoDialog(context, title: title, content: content, onClose: () {
                loadDataStockBrokerIndex(context, noLogin: noLogin);
                loadHelps(context);
              });
            } else {
              loadDataStockBrokerIndex(context, noLogin: noLogin);
              loadHelps(context);
            }
             */
          } else {
            closeLoading();
            InvestrendTheme.of(context).showSnackBar(
                context, 'error_loading_server_version_label'.tr() + ' [1]');
          }
        }).onError((error, stackTrace) {
          print(error);
          closeLoading();
          InvestrendTheme.of(context).showSnackBar(
              context, 'error_loading_server_version_label'.tr() + ' [2]');
        });
      } else {
        closeLoading();
        InvestrendTheme.of(context).showSnackBar(
            context, 'error_loading_server_version_label'.tr() + ' [3]');
      }
    }).onError((error, stackTrace) {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'error_loading_device_version_label'.tr());
    });
  }

  void loadDataStockBrokerIndex(BuildContext context, {bool noLogin = false}) {
    /*
    if(_loadingNotifier.value.showLoading){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _loadingNotifier.setValue(true, 'loading_data_market_label'.tr());
      });

    }else{

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
            //return LoadingBottomSheet(loadingNotifier,text: 'Loging in...',);


            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              _loadingNotifier.setValue(true, 'loading_data_market_label'.tr());
            });

            return LoadingBottomSheetNew(_loadingNotifier);
          });

    }
    */
    showLoading('loading_data_market_label'.tr());

    MD5StockBrokerIndex? md5 = InvestrendTheme.storedData?.md5;
    if (md5 != null) {
      //futureStockBrokerIndex = HttpSSI.fetchStockBrokerIndex(md5.md5broker, md5.md5stock, md5.md5index);
      //final result =  HttpSSI.fetchStockBrokerIndex(md5.md5broker, md5.md5stock, md5.md5index);
      final result = InvestrendTheme.datafeedHttp.fetchMarketData(
          md5.md5broker, md5.md5stock, md5.md5index, md5.md5sector);
      result.then((value) {
        bool validBrokerChanged = value['validBrokerChanged'] ?? false;
        bool validStockChanged = value['validStockChanged'] ?? false;
        bool validIndexChanged = value['validIndexChanged'] ?? false;
        bool validSectorChanged = value['validSectorChanged'] ?? false;

        MD5StockBrokerIndex md5 = value['md5'];

        print('future validBrokerChanged : ' + validBrokerChanged.toString());
        print('future validStockChanged : ' + validStockChanged.toString());
        print('future validIndexChanged : ' + validIndexChanged.toString());
        print('future validSectorChanged : ' + validSectorChanged.toString());

        bool isValid = md5 != null && md5.isValid();
        print('future md5 isValid : $isValid');

        if (isValid) {
          InvestrendTheme.storedData?.md5.sharePerLot = md5.sharePerLot;
        }

        if (validStockChanged && isValid) {
          InvestrendTheme.storedData?.md5.md5stock = md5.md5stock;
          InvestrendTheme.storedData?.md5.md5stockUpdate = md5.md5stockUpdate;
          InvestrendTheme.storedData?.listStock?.clear();
          if (value['stocks'] != null) {
            InvestrendTheme.storedData?.listStock?.addAll(value['stocks']);
          }
        }

        if (validBrokerChanged && isValid) {
          InvestrendTheme.storedData?.md5.md5broker = md5.md5broker;
          InvestrendTheme.storedData?.md5.md5brokerUpdate = md5.md5brokerUpdate;
          InvestrendTheme.storedData?.listBroker?.clear();
          if (value['brokers'] != null) {
            InvestrendTheme.storedData?.listBroker?.addAll(value['brokers']);
          }
        }

        if (validIndexChanged && isValid) {
          InvestrendTheme.storedData?.md5.md5index = md5.md5index;
          InvestrendTheme.storedData?.md5.md5indexUpdate = md5.md5indexUpdate;
          InvestrendTheme.storedData?.listIndex?.clear();
          if (value['indexs'] != null) {
            InvestrendTheme.storedData?.listIndex?.addAll(value['indexs']);
          }
        }

        if (validSectorChanged && isValid) {
          InvestrendTheme.storedData?.md5.md5sector = md5.md5sector;
          InvestrendTheme.storedData?.md5.md5sectorUpdate = md5.md5sectorUpdate;
          InvestrendTheme.storedData?.listSector?.clear();
          if (value['sectors'] != null) {
            InvestrendTheme.storedData?.listSector?.addAll(value['sectors']);
          }
        }

        int? countIndex = InvestrendTheme.storedData?.listIndex?.length;
        InvestrendTheme.storedData?.listStock?.forEach((stock) {
          for (int i = 0; i < countIndex!; i++) {
            Index? index = InvestrendTheme.storedData?.listIndex?.elementAt(i);
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
        //_loadingNotifier.closeLoading();
        closeLoading();

        if (noLogin) {
        } else {
          User user = context.read(dataHolderChangeNotifier).user;
          //print(context.read(dataHolderChangeNotifier).user.toString());
          DebugWriter.info(user.toString());
          //if(context.read(dataHolderChangeNotifier).user.needRegisterPin()){
          context.read(managerDatafeedNotifier).connect();
          context.read(managerEventNotifier).connect();

          if (user.needRegisterPin()) {
            // show register pin
            print('needRegisterPin : ' + user.message!);
            InvestrendTheme.pushReplacement(
                context,
                ScreenRegisterPin(
                    user.username!,
                    user.email!,
                    '', //fieldPasswordController.text,
                    'main'),
                ScreenTransition.SlideLeft,
                '/register_pin');
          } else {
            bool hasAccount =
                context.read(dataHolderChangeNotifier).user.accountSize() > 0;
            if (hasAccount) {
              showMainPage(context);
            } else {
              //showFriendsPage(context);
              showMainPage(context);
            }
            /*
            if(context
                .read(dataHolderChangeNotifier)
                .user.accountSize() <= 0){
              showFriendsPage(context);
            }else{
              showMainPage(context);
            }
             */
          }
        }
      }).onError((error, stackTrace) {
        //_loadingNotifier.closeLoading();
        print(error);
        print(stackTrace);
        closeLoading();
        InvestrendTheme.of(context).showSnackBar(context, 'Connection Error');
      }).whenComplete(() {});
    } else {
      print('error md5 is null');
    }
  }

  void showRegisterPage(BuildContext context) {
    //Navigator.pushReplacementNamed(context, '/login');
    //Navigator.pushReplacementNamed(context, '/landing');
    InvestrendTheme.push(
        context, ScreenRegister(), ScreenTransition.SlideUp, '/register');
    /*
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),

        pageBuilder: (context, animation1, animation2) => ScreenRegister(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimationCreator.transitionSlideUp(
              context, animation, secondaryAnimation, child);
        },
      ),
    );
     */
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

  int step = 0;
  User? userLogged;

  void test() {
    if (step == 0) {
      // test LOGIN
      String dataText = 'Login with :\n   ' +
          fieldEmailController!.text +
          '\n   ' +
          fieldPasswordController!.text +
          '\n   rembember : ' +
          (_rememberMeNotifier.value ? 'true' : 'false');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(dataText)));

      Future<User> result = InvestrendTheme.tradingHttp
          .login('user', 'password', 'mobile', '0.0.1');

      result.then((value) {
        step = 1;
        print('step = $step');
        print('login--------------------');
        print('username = ' + value.username!);
        print('access_token = ' + value.token!.access_token!);
        print('refresh_token = ' + value.token!.refresh_token!);
        print('accounts.length = ' + value.accounts!.length.toString());
        userLogged = value;
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    } else if (step == 1) {
      // test PIN
      Future<String?>? resultPin =
          InvestrendTheme.tradingHttp.loginPin('123456', 'mobile', '0.0.1');
      resultPin.then((value) {
        step = 2;
        print('step = $step');
        print('pin--------------------');
        print('login pin : ' + value!);
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    } else if (step == 2) {
      // test Order New
      Account accountFirst = userLogged!.accounts!.first;

      String broker = accountFirst.brokercode;
      String account = accountFirst.accountcode;
      String user = userLogged!.username!;
      String buySell = 'B';
      String stock = 'PWON';
      String board = 'RG';
      int price = 100;
      int qty = 10;

      String platform = 'mobile';
      String version = '0.0.1';

      String reff = Utils.createRefferenceID();

      Future<OrderReply> resultOrder = InvestrendTheme.tradingHttp.orderNew(
        reff,
        broker,
        account,
        user,
        buySell,
        stock,
        board,
        price.toString(),
        qty.toString(),
        platform,
        version,
      );
      resultOrder.then((value) {
        step = 4;
        print('step = $step');
        print('pin--------------------');
        print('result order new : ' + value.accountcode);
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    } else if (step == 3) {
      // test REFRESH
      Future<User> result =
          InvestrendTheme.tradingHttp.refresh('mobile', '0.0.1');

      result.then((value) {
        step = 3;
        print('step = $step');
        print('refresh--------------------');
        print('username = ' + value.username!);
        print('access_token = ' + value.token!.access_token!);
        print('refresh_token = ' + value.token!.refresh_token!);
        print('accounts.length = ' + value.accounts!.length.toString());
        //showFriendsPage(context);
        userLogged = value;
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    }
  }
}
