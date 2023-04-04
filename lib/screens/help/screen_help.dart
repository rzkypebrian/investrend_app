import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/help/screen_help_detail.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenHelp extends StatefulWidget {
  final int defaultMenuIndex;

  const ScreenHelp({this.defaultMenuIndex = 0, Key key}) : super(key: key);

  @override
  _ScreenHelpState createState() => _ScreenHelpState('/help', defaultMenuIndex);
}

class _ScreenHelpState extends BaseStateNoTabs<ScreenHelp> {
  final int defaultMenuIndex;
  ValueNotifier<int> _optionNotifier; // = ValueNotifier(5);

  _ScreenHelpState(String routeName, this.defaultMenuIndex) : super(routeName);

  @override
  void initState() {
    super.initState();
    _optionNotifier = ValueNotifier<int>(defaultMenuIndex);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (context.read(helpNotifier).data.loaded) {
          updateMenusAndContents();
        } else {
          context.read(helpNotifier).data.load().then((value) {
            updateMenusAndContents();
          }).onError((error, stackTrace) {
            print(routeName + ' Future help load Error');
            print(error);
            print(stackTrace);
          });
          // try {} catch (error) {
          //   print(routeName + ' Future help load Error');
          //   print(error);
          // }
        }
      });
    });
  }

  @override
  Widget createAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: AppBarTitleText('eipo_help_title'.tr()),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        Navigator.pop(context);
      }),
    );
  }

  List<String> options = List.empty(growable: true);

  // List<String> options  = [
  //   'help_about_investrend'.tr(),
  //   'help_registration'.tr(),
  //   'help_transaction'.tr(),
  //   'help_stock'.tr(),
  //   'help_investrend_account'.tr(),
  //   'help_eipo'.tr(),
  //   'help_others'.tr(),
  // ];

  void updateMenusAndContents() {
    options.clear();
    if (context.read(helpNotifier).data.loaded) {
      for (var menu in context.read(helpNotifier).data.menus) {
        String menuText = menu.getMenu(language: EasyLocalization.of(context).locale.languageCode);
        options.add(menuText);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // options.clear();
    // if (context.read(helpNotifier).data.loaded) {
    //   for (var menu in context.read(helpNotifier).data.menus) {
    //     String menuText = menu.getMenu(language: EasyLocalization.of(context).locale.languageCode);
    //     options.add(menuText);
    //   }
    // }
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    /*
    try {
      await context.read(helpNotifier).data.load();
    } catch (error) {
      print(routeName + ' Future help load Error');
      print(error);
    }
    */

    if(!context.read(helpNotifier).data.loaded){
      print(routeName + ' doUpdate aborted helpNotifier.data.loaded : '+context.read(helpNotifier).data.loaded.toString());
      return;
    }
    try {
      String md5_help_contents = context.read(helpNotifier).data.md5_help_contents;
      String md5_help_menus = context.read(helpNotifier).data.md5_help_menus;
      final help = await InvestrendTheme.datafeedHttp.fetchHelp(md5_help_contents: md5_help_contents, md5_help_menus: md5_help_menus);
      if (help != null) {
        print(routeName + ' Future help DATA : ' + help.toString());
        //_summaryNotifier.setData(stockSummary);
        bool menusChanged = !StringUtils.equalsIgnoreCase(md5_help_menus, help.md5_help_menus) && help.menus != null && help.menus.isNotEmpty;
        bool contentChanged = !StringUtils.equalsIgnoreCase(md5_help_contents, help.md5_help_contents) &&
            help.contents != null &&
            help.md5_help_contents.isNotEmpty;

        if (menusChanged) {
          int countBefore = context.read(helpNotifier).data.menus.length;
          context.read(helpNotifier).data.updateMenus(help.md5_help_menus, help.menus);
          int countAfter = context.read(helpNotifier).data.menus.length;
          print(routeName + '  menusChanged : $menusChanged  countBefore : $countBefore  countAfter : $countAfter');
        }
        if (contentChanged) {
          int countBefore = context.read(helpNotifier).data.contents.length;
          context.read(helpNotifier).data.updateContents(help.md5_help_contents, help.contents);
          int countAfter = context.read(helpNotifier).data.contents.length;
          print(routeName + '  contentChanged : $contentChanged  countBefore : $countBefore  countAfter : $countAfter');
        }
        if (menusChanged || contentChanged) {
          context.read(helpNotifier).data.save();
          updateMenusAndContents();
          //setState(() {});
        }
        context.read(helpNotifier).notifyListeners();
      } else {
        print(routeName + ' Future help NO DATA');
      }
    } catch (error) {
      print(routeName + ' Future help Error');
      print(error);
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).accentColor,
      onRefresh: onRefresh,
      child: Column(
        //shrinkWrap: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ValueListenableBuilder(
                    valueListenable: _optionNotifier,
                    builder: (context, index, child) {
                      HelpMenu activeMenu = context.read(helpNotifier).data.menus.elementAt(index);
                      String menuText = activeMenu.getMenu(language: EasyLocalization.of(context).locale.languageCode);
                      return Text(
                        menuText, //'eipo_label'.tr(),
                        style: InvestrendTheme.of(context).regular_w600_compact,
                      );
                    },
                  ),
                ),
                ButtonDropdown(
                  _optionNotifier,
                  options,
                  staticText: 'button_choose'.tr(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: ComponentCreator.divider(context),
          ),
          Expanded(
            flex: 1,
            child: ValueListenableBuilder(
                valueListenable: _optionNotifier,
                builder: (context, index, child) {
                  HelpMenu activeMenu = context.read(helpNotifier).data.menus.elementAt(index);
                  List<HelpContent> activeContents = context.read(helpNotifier).getContent(activeMenu);
                  int countContent = activeContents != null ? activeContents.length : 0;
                  return ListView.builder(
                    itemCount: countContent,
                    itemBuilder: (context, index) {
                      HelpContent content = activeContents.elementAt(index);
                      if (content == null) {
                        return EmptyLabel();
                      }
                      String subtitleText = content.getSubtitle(language: EasyLocalization.of(context).locale.languageCode);
                      String contentText = content.getContent(language: EasyLocalization.of(context).locale.languageCode);
                      return createTile(context, subtitleText, contentText);
                    },
                  );
                }),
          ),
          /*
        createTile(context, 'Apa itu e-IPO?',
            'e-IPO atau Electronic Indonesia Public Offering merupakan sarana elektronik untuk mendukung proses penawaran umum saham perdana kepada publik. Sebelum saham Perusahaan dicatatkan dan mulai diperdagangkan di Bursa Efek Indonesia, terdapat proses yang sering kita kenal dengan IPO atau Initial Public Offering atau Penawaran Umum. IPO atau penawaran umum ini merupakan proses penawaran saham perdana kepada publik (pasar perdana), di mana investor yang berminat dapat melakukan pemesanan atas saham yang ditawarkan di pasar perdana. Setelah proses penawaran umum saham perdana, selanjutnya saham Perusahaan tercatatkan di Bursa, dan saham tersebut dapat diperdagangkan di Bursa Efek Indonesia (pasar sekunder).'),
        createTile(context, 'Bagaimana cara daftar e-IPO?',
            'e-IPO atau Electronic Indonesia Public Offering merupakan sarana elektronik untuk mendukung proses penawaran umum saham perdana kepada publik. Sebelum saham Perusahaan dicatatkan dan mulai diperdagangkan di Bursa Efek Indonesia, terdapat proses yang sering kita kenal dengan IPO atau Initial Public Offering atau Penawaran Umum. IPO atau penawaran umum ini merupakan proses penawaran saham perdana kepada publik (pasar perdana), di mana investor yang berminat dapat melakukan pemesanan atas saham yang ditawarkan di pasar perdana. Setelah proses penawaran umum saham perdana, selanjutnya saham Perusahaan tercatatkan di Bursa, dan saham tersebut dapat diperdagangkan di Bursa Efek Indonesia (pasar sekunder).'),
        createTile(context, 'Bagaimana cara memesan e-IPO?',
            'e-IPO atau Electronic Indonesia Public Offering merupakan sarana elektronik untuk mendukung proses penawaran umum saham perdana kepada publik. Sebelum saham Perusahaan dicatatkan dan mulai diperdagangkan di Bursa Efek Indonesia, terdapat proses yang sering kita kenal dengan IPO atau Initial Public Offering atau Penawaran Umum. IPO atau penawaran umum ini merupakan proses penawaran saham perdana kepada publik (pasar perdana), di mana investor yang berminat dapat melakukan pemesanan atas saham yang ditawarkan di pasar perdana. Setelah proses penawaran umum saham perdana, selanjutnya saham Perusahaan tercatatkan di Bursa, dan saham tersebut dapat diperdagangkan di Bursa Efek Indonesia (pasar sekunder).'),
        */
        ],
      ),
    );
    /*
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ValueListenableBuilder(
                  valueListenable: _optionNotifier,
                  builder: (context, index, child) {
                    HelpMenu activeMenu = context.read(helpNotifier).data.menus.elementAt(index);
                    String menuText = activeMenu.getMenu(language: EasyLocalization.of(context).locale.languageCode);
                    return Text(
                        menuText, //'eipo_label'.tr(),
                      style: InvestrendTheme.of(context).regular_w600_compact,
                    );
                  },
                ),
              ),
              ButtonDropdown(_optionNotifier, options),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: ComponentCreator.divider(context),
        ),
        Expanded(
          flex: 1,
          child: ValueListenableBuilder(
              valueListenable: _optionNotifier,
              builder: (context, index, child) {
                HelpMenu activeMenu = context.read(helpNotifier).data.menus.elementAt(index);
                List<HelpContent> activeContents = context.read(helpNotifier).getContent(activeMenu);
                int countContent = activeContents != null ? activeContents.length : 0;
                return ListView.builder(
                  itemCount: countContent,
                  itemBuilder: (context, index) {
                    HelpContent content = activeContents.elementAt(index);
                    if (content == null) {
                      return EmptyLabel();
                    }
                    String subtitleText = content.getSubtitle(language: EasyLocalization.of(context).locale.languageCode);
                    String contentText = content.getContent(language: EasyLocalization.of(context).locale.languageCode);
                    return createTile(context, subtitleText, contentText);
                  },
                );
              }),
        ),
        /*
        createTile(context, 'Apa itu e-IPO?',
            'e-IPO atau Electronic Indonesia Public Offering merupakan sarana elektronik untuk mendukung proses penawaran umum saham perdana kepada publik. Sebelum saham Perusahaan dicatatkan dan mulai diperdagangkan di Bursa Efek Indonesia, terdapat proses yang sering kita kenal dengan IPO atau Initial Public Offering atau Penawaran Umum. IPO atau penawaran umum ini merupakan proses penawaran saham perdana kepada publik (pasar perdana), di mana investor yang berminat dapat melakukan pemesanan atas saham yang ditawarkan di pasar perdana. Setelah proses penawaran umum saham perdana, selanjutnya saham Perusahaan tercatatkan di Bursa, dan saham tersebut dapat diperdagangkan di Bursa Efek Indonesia (pasar sekunder).'),
        createTile(context, 'Bagaimana cara daftar e-IPO?',
            'e-IPO atau Electronic Indonesia Public Offering merupakan sarana elektronik untuk mendukung proses penawaran umum saham perdana kepada publik. Sebelum saham Perusahaan dicatatkan dan mulai diperdagangkan di Bursa Efek Indonesia, terdapat proses yang sering kita kenal dengan IPO atau Initial Public Offering atau Penawaran Umum. IPO atau penawaran umum ini merupakan proses penawaran saham perdana kepada publik (pasar perdana), di mana investor yang berminat dapat melakukan pemesanan atas saham yang ditawarkan di pasar perdana. Setelah proses penawaran umum saham perdana, selanjutnya saham Perusahaan tercatatkan di Bursa, dan saham tersebut dapat diperdagangkan di Bursa Efek Indonesia (pasar sekunder).'),
        createTile(context, 'Bagaimana cara memesan e-IPO?',
            'e-IPO atau Electronic Indonesia Public Offering merupakan sarana elektronik untuk mendukung proses penawaran umum saham perdana kepada publik. Sebelum saham Perusahaan dicatatkan dan mulai diperdagangkan di Bursa Efek Indonesia, terdapat proses yang sering kita kenal dengan IPO atau Initial Public Offering atau Penawaran Umum. IPO atau penawaran umum ini merupakan proses penawaran saham perdana kepada publik (pasar perdana), di mana investor yang berminat dapat melakukan pemesanan atas saham yang ditawarkan di pasar perdana. Setelah proses penawaran umum saham perdana, selanjutnya saham Perusahaan tercatatkan di Bursa, dan saham tersebut dapat diperdagangkan di Bursa Efek Indonesia (pasar sekunder).'),
        */
      ],
    );

     */
  }

  Widget createTile(BuildContext context, String label, String content) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
      ),
      title: Text(
        label,
        style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
      ),
      trailing: Image.asset('images/icons/arrow_forward.png', width: 15.0, height: 15.0, color: InvestrendTheme.of(context).greyDarkerTextColor),
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenEIPOHelpDetails(label, content),
              settings: RouteSettings(name: '/e-ipo_help_details'),
            ));
      },
    );
  }

  @override
  void dispose() {
    _optionNotifier.dispose();
    super.dispose();
  }

  @override
  void onActive() {
    // TODO: implement onActive
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}
