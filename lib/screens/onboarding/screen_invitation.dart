import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/screens/onboarding/screen_landing.dart';
import 'package:Investrend/screens/screen_login.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenInvitation extends StatefulWidget {
  final Invitation invitation;

  const ScreenInvitation(this.invitation, {Key key}) : super(key: key);

  @override
  _ScreenInvitationState createState() =>
      _ScreenInvitationState(this.invitation);
}

class _ScreenInvitationState extends State<ScreenInvitation> {
  final Invitation invitation;
  TextEditingController controller = TextEditingController(text: '');
  FocusNode focusNode = FocusNode();

  _ScreenInvitationState(this.invitation);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kode Invitasi',
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              'Saat ini kami sedang pada Fase Test tertutup, mohon memasukkan kode invitasi yang anda punya',
              style: InvestrendTheme.of(context).small_w400_greyDarker,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 50.0,
            ),
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              focusNode: focusNode,
              style: InvestrendTheme.of(context).regular_w600_compact,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2.0)),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                focusColor: Theme.of(context).colorScheme.secondary,
                prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                hintStyle: InvestrendTheme.of(context).inputHintStyle,
                helperStyle: InvestrendTheme.of(context).inputHelperStyle,
                errorStyle: InvestrendTheme.of(context).inputErrorStyle,
                errorMaxLines: 2,
                //floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Kode Invitasi',
                fillColor: Colors.grey,
                contentPadding: EdgeInsets.all(0.0),
              ),
            ),
            TextButton(
                onPressed: () {
                  Clipboard.getData(Clipboard.kTextPlain).then((value) {
                    print(value.text); //value is clipbarod data
                    controller.text = value.text;
                  });
                },
                child: Text(
                  'Paste / Tempel',
                  style: InvestrendTheme.of(context)
                      .small_w500_compact
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                )),
            SizedBox(
              height: 20.0,
            ),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: ComponentCreator.roundedButton(
                  context,
                  'Masuk',
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary, () {
                print('controller invitation code : ' + controller.text);
                if (StringUtils.isEmtpy(controller.text)) {
                  InvestrendTheme.of(context)
                      .showSnackBar(context, 'Harap isi kode invitasi.');
                  return;
                }
                checkInvitation(context, controller.text);
              }),
            ),
          ],
        ),
      ),
    );
  }

  void checkInvitation(BuildContext context, String code) async {
    try {
      final result = await InvestrendTheme.tradingHttp.checkInvitation(
          code,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        InvestrendTheme.of(context).showSnackBar(context, result);
        if (StringUtils.equalsIgnoreCase(result, 'success')) {
          invitation.update(code, true);
          invitation.save().then((value) {
            Token token = Token('', '');
            token.load().then((value) {
              bool hasToken = !StringUtils.isEmtpy(token.access_token) &&
                  !StringUtils.isEmtpy(token.refresh_token);
              print('hasToken : $hasToken');
              if (hasToken) {
                InvestrendTheme.pushReplacement(
                    context, ScreenLogin(), ScreenTransition.Fade, '/login');
              } else {
                InvestrendTheme.pushReplacement(context, ScreenLanding(),
                    ScreenTransition.Fade, '/landing');
              }
            }).onError((error, stackTrace) {
              InvestrendTheme.pushReplacement(
                  context, ScreenLanding(), ScreenTransition.Fade, '/landing');
              print(error);
              print(stackTrace);
            });
          }).onError((error, stackTrace) {
            InvestrendTheme.of(context).showSnackBar(context,
                'Gagal menyimpan code invitasi. (' + error.toString() + ')');
            print(error);
            print(stackTrace);
          });
        }
      } else {
        InvestrendTheme.of(context).showSnackBar(context, 'Response kosong');
      }
    } catch (error) {
      InvestrendTheme.of(context).showSnackBar(context, error.toString());
    }
  }
}
