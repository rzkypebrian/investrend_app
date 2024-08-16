import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/screens/base/base_stateless_widget.dart';
import 'package:Investrend/screens/onboarding/screen_landing_rdn.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScreenFriendsContact extends BaseStatelessWidget {
  /*
  "friends_contact_text_1": "Contact list",
  "friends_contact_button_follow_all": "Follow All",
  "friends_contact_button_follow": "Follow",
  "friends_contact_button_invite": "Invite",
  "friends_contact_button_finish": "Selesai",
  */
  @override
  Widget build(BuildContext context) {
    //bool lightTheme = MediaQuery.of(context).platformBrightness == Brightness.light;
    // bool lightTheme = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        //alignment: Alignment.topCenter,
        //padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0, bottom: 16.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 80.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'friends_contact_text_1'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                  TextButton(
                    child: Text('friends_contact_button_follow_all'.tr(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary)),
                    onPressed: () {
                      // pressed
                      final snackBar = SnackBar(
                          content: Text('Action ' +
                              'friends_contact_button_follow_all'.tr()));

                      // Find the ScaffoldMessenger in the widget tree
                      // and use it to show a SnackBar.
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
              children: [
                createFollowRow(context,
                    name: 'Teresa Webb',
                    username: '@teressa',
                    url:
                        'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70'),
                createFollowRow(context,
                    name: 'Jerome Bell',
                    username: '@jeromebell',
                    url:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU'),
                createFollowRow(context,
                    name: 'Jenny Wilson',
                    username: '@wislon',
                    url:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTHWL4kom23RBdd0GP-xLOsFu-7t-bRAtSGEA&usqp=CAU'),
                createFollowRow(context,
                    name: 'Albert Flores',
                    username: '@flra',
                    url:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU'),
                createFollowRow(context,
                    name: 'Kristin Watson',
                    username: '@krisss',
                    url:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiJinli8IBVIpd5Un3l2uUuMb9iIXihrGobg&usqp=CAU'),
                createFollowRow(context,
                    name: 'Emma Watson',
                    username: '@emson',
                    url:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmJaEK71AwtaHZvhvBQioHWW2MGi4ukH1_9w&usqp=CAU'),
                createFollowRow(context,
                    name: 'Apotik Watson',
                    username: '@watson',
                    url:
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStgx25x3vrWgwCRz0buSYNf7lII-0TWtcFXg&usqp=CAU'),
                Divider(),
                createInviteRow(context, name: 'Philmon Tanuri', symbol: 'PT'),
                createInviteRow(context, name: 'Stella Tambunan', symbol: 'ST'),
                createInviteRow(context, name: 'Stella Sinarta', symbol: 'SS'),
                createInviteRow(context, name: 'Richy Allen', symbol: 'RA'),
              ],
            )),
            Container(
              //color: InvestrendCustomTheme.friends_bottom_container(lightTheme),
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 16.0, bottom: 16.0),
              color: InvestrendTheme.of(context).blackAndWhite,
              width: double.maxFinite,
              child: ComponentCreator.roundedButton(
                  context,
                  'friends_contact_button_finish'.tr(),
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary, () {
                // pressed
                //showMainPage(context);
                showLandingRDNPage(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget createFollowRow(BuildContext context,
      {String name = '',
      String username = '',
      String url =
          'https://cdn130.picsart.com/309744679150201.jpg?to=crop&r=256&q=70'}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Row(
        children: [
          AvatarIcon(
            imageUrl: url,
            size: 50,
          ),
          // ClipOval(
          //   child: SizedBox(
          //     child: Image.network(url),
          //     width: 50,
          //     height: 50,
          //   ),
          // ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  username,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(letterSpacing: 0.2),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          ComponentCreator.roundedButtonHollow(
              context,
              'friends_contact_button_follow'.tr(),
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.secondary, () {
            // pressed
            final snackBar = SnackBar(
                content:
                    Text('Action ' + 'friends_contact_button_follow'.tr()));

            // Find the ScaffoldMessenger in the widget tree
            // and use it to show a SnackBar.
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }, borderWidth: 0.5)
        ],
      ),
    );
  }

  Widget createInviteRow(BuildContext context,
      {String name = '', String symbol = ''}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.secondary,
              child: Text(
                symbol,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          ComponentCreator.roundedButtonHollow(
              context,
              'friends_contact_button_invite'.tr(),
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.secondary, () {
            //pressed
            final snackBar = SnackBar(
                content:
                    Text('Action ' + 'friends_contact_button_invite'.tr()));

            // Find the ScaffoldMessenger in the widget tree
            // and use it to show a SnackBar.
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }, borderWidth: 0.5)
        ],
      ),
    );
  }

  void showMainPage(BuildContext context) {
    InvestrendTheme.showMainPage(context, ScreenTransition.SlideLeft);
    //InvestrendTheme.pushReplacement(context, ScreenMain(), ScreenTransition.SlideLeft, '/main');
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

  void showLandingRDNPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1000),
        //pageBuilder: (context, animation1, animation2) => ScreenLanding(),
        pageBuilder: (context, animation1, animation2) => ScreenLandingRDN(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}
