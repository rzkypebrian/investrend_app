// ignore_for_file: unused_local_variable

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/screens/base/base_stateless_widget.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenLandingRDN extends BaseStatelessWidget {
  // "friends_button_skip": "Skip",
  // "friends_button_contact": "Find in your contacts",
  // "friends_info_text_1": "Find your friends",
  // "friends_info_text_2": "Let's find your friends who have joined this application",

  @override
  Widget build(BuildContext context) {
    //bool lightTheme = MediaQuery.of(context).platformBrightness == Brightness.light;
    bool lightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Text(''),
        actions: [
          TextButton(
            child: Text(
              'landing_rdn_button_skip'.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                  //color: InvestrendCustomTheme.textfield_labelTextColor( lightTheme),
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            onPressed: () {
              // pressed
              showMainPage(context);
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.6,
              child: Image.asset('images/landing_03.png'),
            ),
            Spacer(
              flex: 4,
            ),
            Text('landing_rdn_info_text_1'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Spacer(
              flex: 1,
            ),
            Text('landing_rdn_info_text_2'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 2.0, fontWeight: FontWeight.normal)),
            Spacer(
              flex: 8,
            ),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: ComponentCreator.roundedButton(
                  context,
                  'landing_rdn_button_contact'.tr(),
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary, () {
                // on presss
                //showFindFriendsPage(context);
                // showRegisterRDNPage(context);
              }),
            ),
            Spacer(
              flex: 5,
            ),
          ],
        ),
      ),
    );
  }

  void showMainPage(BuildContext context) {
    InvestrendTheme.showMainPage(context, ScreenTransition.Fade);
    //InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.Fade,'/main');
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
}
