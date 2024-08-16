// ignore_for_file: implementation_imports, unused_local_variable

import 'package:Investrend/component/animation_creator.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/onboarding/screen_register_rdn.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/provider.dart';

class BannerOpenAccount extends StatelessWidget {
  const BannerOpenAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String username = context.read(dataHolderChangeNotifier).user.username!;
    return MaterialButton(
      onPressed: () {
        // Navigator.push(
        // context
        // CupertinoPageRoute(
        // builder: (_) => ScreenRegisterRDN(
        //   username: username,
        // ),
        // settings: RouteSettings(name: '/register'),
        // )
        // );

        Navigator.push(
          context,
          PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 1000),
              //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
              pageBuilder: (context, animation1, animation2) =>
                  ScreenRegisterRDN(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimationCreator.transitionSlideUp(
                    context, animation, secondaryAnimation, child);
              }),
        );
      },
      child: Image.asset(
        'images/banner_open_account.png',
        fit: BoxFit.fitWidth,
      ),
      //padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
        side: BorderSide(
          color: InvestrendTheme.of(context).tileBackground!,
          width: 0.0,
        ),
      ),
      padding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.secondary,
      splashColor: InvestrendTheme.of(context).tileSplashColor,
    );
  }
}
