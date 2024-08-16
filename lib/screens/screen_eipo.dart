import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/help/screen_help.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenEIPO extends StatefulWidget {
  final ListEIPO selectedIpo;
  const ScreenEIPO(this.selectedIpo, {Key? key}) : super(key: key);

  @override
  _ScreenEIPOState createState() => _ScreenEIPOState(selectedIpo);
}

class _ScreenEIPOState extends BaseStateWithTabs<ScreenEIPO> {
  final ListEIPO selectedIpo;
  ContentEIPONotifier? _contentNotifier =
      ContentEIPONotifier(ContentEIPO.createBasic());
  _ScreenEIPOState(this.selectedIpo) : super('/eipo', null, null);

  List<String> tabs = [
    'eipo_tab_company_detail'.tr(),
    'eipo_tab_offering'.tr(),
  ];

  TextStyle? styleLabel;
  TextStyle? styleContent;
  double paddingContent = InvestrendTheme.cardPaddingVertical;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    styleLabel = InvestrendTheme.of(context).support_w500?.copyWith(
        fontSize: InvestrendTheme.of(context).support_w500!.fontSize! + 1);
    styleContent = InvestrendTheme.of(context).support_w400?.copyWith(
        color: InvestrendTheme.of(context).greyDarkerTextColor, height: 1.35);
  }

  void launchURL(BuildContext context, String? _url) async {
    try {
      await canLaunchUrl(Uri.dataFromString(_url!))
          // await canLaunch(_url)
          ? await launchUrl(Uri.dataFromString(_url))
          : throw 'Could not launch $_url';
    } catch (error) {
      //InvestrendTheme.of(context).showSnackBar(context, error.toString());
    }
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    if (!_contentNotifier!.value!.loaded) {
      setNotifierLoading(_contentNotifier);
    }

    try {
      final ContentEIPO? eipo = await InvestrendTheme.datafeedHttp
          .fetchEIPOContent(selectedIpo.code!);
      if (eipo != null) {
        if (mounted) {
          _contentNotifier?.setValue(eipo);
        }
        //context.read(eipoNotifier).setValue(eipo);
        // if(mounted){
        //   context.read(eipoNotifier).setValue(eipo);
        // }else{
        //   print('ignored eipo, mounted : $mounted');
        // }
      } else {
        //_briefingNotifier.setNoData();
        setNotifierNoData(_contentNotifier);
        //context.read(eipoNotifier).setNoData();
      }
    } catch (error) {
      //_briefingNotifier?.setError(message: error.toString());
      setNotifierError(_contentNotifier, error.toString());
      // context.read(eipoNotifier).setError(message: error.toString());
    }
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  @override
  PreferredSizeWidget createAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: AppBarTitleText('eipo_title'.tr()),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        Navigator.pop(context);
      }),
      actions: [
        AppBarActionIcon(
          'images/icons/action_help.png',
          () {
            int defaultMenuIndex = 0;
            if (context.read(helpNotifier).data!.loaded) {
              int? count = context.read(helpNotifier).data?.countMenus();
              for (int i = 0; i < count!; i++) {
                HelpMenu? menu =
                    context.read(helpNotifier).data?.menus?.elementAt(i);
                if (menu != null) {
                  if (StringUtils.equalsIgnoreCase(menu.id!, '6')) {
                    // id 6 --> E-IPO
                    defaultMenuIndex = i;
                    break;
                  }
                }
              }
            }

            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ScreenHelp(
                    defaultMenuIndex: defaultMenuIndex,
                  ),
                  settings: RouteSettings(name: '/help'),
                ));
          },
          color: InvestrendTheme.of(context).greyDarkerTextColor,
        ),
      ],
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ValueListenableBuilder<ContentEIPO?>(
          valueListenable: _contentNotifier!,
          builder: (context, value, child) {
            Widget? noWidget = _contentNotifier?.currentState.getNoWidget(
              onRetry: () => doUpdate(),
            );
            if (noWidget != null) {
              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width / 4),
                    child: Center(child: noWidget),
                  ),
                ],
              );
            }
            return TabBarView(
              controller: pTabController,
              children: List<Widget>.generate(
                tabs.length,
                (int index) {
                  print(tabs[index]);
                  if (index == 0) {
                    return createTabCompanyDetail(
                        context, paddingBottom, value);
                  } else if (index == 1) {
                    return createTabOffering(context, paddingBottom, value);
                  }
                  return Container(
                    child: Center(
                      child: Text(tabs[index]),
                    ),
                  );
                },
              ),
            );
          }),
    );

/*
    return ValueListenableBuilder<ContentEIPO>(
        valueListenable: _contentNotifier,
        builder: (context, value, child) {
          Widget noWidget = _contentNotifier.currentState.getNoWidget(
            onRetry: () => doUpdate(),
          );
          if (noWidget != null) {
            return ListView(
              children: [
                noWidget,
              ],
            );
          }
          return TabBarView(
            controller: pTabController,
            children: List<Widget>.generate(
              tabs.length,
              (int index) {
                print(tabs[index]);
                if (index == 0) {
                  return createTabCompanyDetail(context, paddingBottom, value);
                } else if (index == 1) {
                  return createTabOffering(context, paddingBottom, value);
                }
                return Container(
                  child: Center(
                    child: Text(tabs[index]),
                  ),
                );
              },
            ),
          );
        });
        */
    /*
    return TabBarView(
      controller: pTabController,
      children: List<Widget>.generate(
        tabs.length,
            (int index) {
          print(tabs[index]);
          if(index == 0){
            return createTabCompanyDetail(context, paddingBottom);
          }else if(index == 1){
            return createTabOffering(context, paddingBottom);
          }
          return Container(
            child: Center(
              child: Text(tabs[index]),
            ),
          );
        },
      ),
    );

     */
  }

  @override
  PreferredSizeWidget createTabs(BuildContext context) {
    return TabBar(
      controller: pTabController,
      labelPadding: InvestrendTheme.paddingTab,
      //indicatorSize: TabBarIndicatorSize.label,
      isScrollable: true,
      tabs: List<Widget>.generate(
        tabs.length,
        (int index) {
          print(tabs[index]);

          return new Tab(text: tabs[index]);
        },
      ),
    );
  }

  @override
  int tabsLength() {
    return tabs.length;
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    //double height = 80.0 + paddingBottom;

    return ValueListenableBuilder<ContentEIPO?>(
        valueListenable: _contentNotifier!,
        builder: (context, value, child) {
          Widget? noWidget = _contentNotifier?.currentState.getNoWidget(
            onRetry: () => doUpdate(),
          );
          if (noWidget != null) {
            return SizedBox(
              width: 1.0,
            );
          }
          return Container(
            width: double.maxFinite,
            //height: height,
            //color: Colors.red,
            padding:
                EdgeInsets.only(left: 24.0, right: 24.0, bottom: paddingBottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    flex: 1,
                    child: TextButton(
                        onPressed: () =>
                            launchURL(context, value?.action_register_eipo),
                        child: Text('eipo_register_button'.tr()))),
                SizedBox(
                  width: 24.0,
                ),
                Expanded(
                    flex: 1,
                    child: ComponentCreator.roundedButton(
                        context,
                        'eipo_enter_button'.tr(),
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                        () => launchURL(context, value?.action_enter_eipo)))
              ],
            ),
          );
        });

    /*
    return Container(
      width: double.maxFinite,
      //height: height,
      //color: Colors.red,
      padding: EdgeInsets.only(left: 24.0, right: 24.0
          , bottom: paddingBottom
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          Expanded(
            flex: 1,
              child: TextButton(onPressed: ()=>launchURL(context, ipo.action_register_eipo), child: Text('eipo_register_button'.tr()))),
          SizedBox(width: 24.0,),
          Expanded(
            flex: 1,
              child: ComponentCreator.roundedButton(context, 'eipo_enter_button'.tr(), Theme.of(context).accentColor, Theme.of(context).primaryColor, Theme.of(context).accentColor, () => launchURL(context, ipo.action_enter_eipo)))
        ],
      ),
    );
    */
  }

  Widget createTabCompanyDetail(
      BuildContext context, double paddingBottom, ContentEIPO? ipo) {
    // TextStyle more_support_400 = InvestrendTheme.of(context).more_support_w400;
    // TextStyle more_support_400_gray = more_support_400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);

    //TextStyle styleLabel = InvestrendTheme.of(context).support_w500.copyWith(fontSize: InvestrendTheme.of(context).support_w500.fontSize+1);
    //TextStyle styleContent = InvestrendTheme.of(context).support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor,height: 1.32);

    double bottom = paddingBottom + 80;

    List<Widget> childs = [
      Text(
        'eipo_stock_code'.tr(),
        style: styleLabel,
      ),
      Text(
        ipo!.code!,
        style: styleContent,
      ),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_sector'.tr(),
        style: styleLabel,
      ),
      Text(
        ipo.sector!,
        style: styleContent,
      ),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_subsector'.tr(),
        style: styleLabel,
      ),
      Text(
        ipo.sub_sector!,
        style: styleContent,
      ),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_company_description'.tr(),
        style: styleLabel,
      ),
      Text(
        ipo.company_description!,
        style: styleContent,
      ),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_address'.tr(),
        style: styleLabel,
      ),
      Text(
        ipo.company_address!,
        style: styleContent,
      ),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_website'.tr(),
        style: styleLabel,
      ),
      TapableWidget(
          onTap: () => launchURL(context, ipo.company_website!),
          child: Text(
            ipo.company_website!,
            style: styleContent?.copyWith(
                color: Theme.of(context).colorScheme.secondary),
          )),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_shared_offered'.tr(),
        style: styleLabel,
      ),
      Text(
        InvestrendTheme.formatComma(ipo.offering_lot!),
        style: styleContent,
      ),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_percentage_of_total_share'.tr(),
        style: styleLabel,
      ),
      Text(
        InvestrendTheme.formatPercent(ipo.offering_lot_percentage!),
        style: styleContent,
      ),
      SizedBox(
        height: paddingContent,
      ),
      Text(
        'eipo_partisipant_admin'.tr(),
        style: styleLabel,
      ),
    ];

    for (int i = 0; i < ipo.countParticipantAdmin(); i++) {
      String participantAdmin = ipo.listParticipantAdmin!.elementAt(i);
      if (!StringUtils.isEmtpy(participantAdmin)) {
        childs.add(Text(
          participantAdmin,
          style: styleContent,
        ));
      }
    }
    childs.add(SizedBox(
      height: paddingContent,
    ));

    childs.add(Text(
      'eipo_underwriter'.tr(),
      style: styleLabel,
    ));
    for (int i = 0; i < ipo.countUnderwriter(); i++) {
      String underwriter = ipo.listUnderwriter!.elementAt(i);
      if (!StringUtils.isEmtpy(underwriter)) {
        childs.add(Text(
          underwriter,
          style: styleContent,
        ));
      }
    }
    childs.add(SizedBox(
      height: paddingContent,
    ));

    const bool showLargeIcon = false;
    Widget widget;
    if (showLargeIcon == false) {
      widget = Stack(
        alignment: Alignment.topRight,
        children: [
          FractionallySizedBox(
              widthFactor: 0.3,
              child:
                  ComponentCreator.imageNetworkCached(ipo.company_icon_large!,
                      errorWidget: SizedBox(
                        width: 24.0,
                        height: 24.0,
                      ))),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: childs,
          ),
        ],
      );
    } else {
      widget = Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: childs,
      );
    }

    return SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.only(
              left: 12.0, right: 12.0, top: 12.0, bottom: bottom),
          child: widget),
    );
  }

  /*
  "eipo_title": "PENAWARAN E-IPO",

  "eipo_tab_company_detail": "Detail Emiten",
  "eipo_tab_offering": "Penawaran",

  "eipo_stock_code": "Kode Saham",
  "eipo_sector": "Sektor",
  "eipo_subsector": "Subsektor",
  "eipo_company_description": "Detail Perusahaan",
  "eipo_address": "Alamat",
  "eipo_website": "Situs",
  "eipo_shared_offered": "Saham Ditawarkan",
  "eipo_percentage_of_total_share": "Persen dari Total Saham",
  "eipo_partisipant_admin": "Admin Partisipan",
  "eipo_underwriter": "Penjamin Emisi",

  "eipo_book_building": "Book Building",
  "eipo_offering": "Offering",
  "eipo_allotment": "Allotment (Closing)",
  "eipo_distribution": "Distribution",
  "eipo_listing_date": "Listing Date",
  "eipo_prospectus": "Prospectus",
  "eipo_additional_information": "Additional Information",
  "eipo_register_button": "Daftar e-IPO",
  "eipo_enter_button": "Masuk e-IPO",
  */

  final List<Color> colors = [
    Colors.blue,
    Colors.orangeAccent,
    Colors.red,
    Colors.purple,
    Colors.green
  ];
  Widget createTabOffering(
      BuildContext context, double paddingBottom, ContentEIPO? ipo) {
    // TextStyle more_support_400 = InvestrendTheme.of(context).more_support_w400;
    // TextStyle more_support_400_gray = more_support_400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor);

    double bottom = paddingBottom + 80;

    String bookbuilding = ipo!.book_building_date_start! +
        ' - ' +
        ipo.book_building_date_end! +
        '\nIDR ' +
        InvestrendTheme.formatPrice(ipo.book_building_price_start!) +
        ' - IDR ' +
        InvestrendTheme.formatPrice(ipo.book_building_price_end!);
    String offering = ipo.offering_date_start! +
        ' - ' +
        ipo.offering_date_end! +
        '\nIDR ' +
        InvestrendTheme.formatPrice(ipo.offering_price!);

    List<Widget> childProspectus = List.empty(growable: true);
    for (int i = 0; i < ipo.countProspectus(); i++) {
      String prospectus = ipo.listProspectus!.elementAt(i);
      if (!StringUtils.isEmtpy(prospectus)) {
        childProspectus.add(
          IconButton(
            onPressed: () => launchURL(context, prospectus),
            icon: Image.asset(
              'images/icons/pdf.png',
              width: 24.0,
              height: 24.0,
              color: colors.elementAt(i),
            ),
          ),
        );
      }
    }
    if (childProspectus.isEmpty) {
      childProspectus.add(SizedBox(
        width: 24.0,
        height: 24.0,
      ));
    }

    List<Widget> childAdditional = List.empty(growable: true);
    for (int i = 0; i < ipo.countAdditional(); i++) {
      String additional = ipo.listAdditional!.elementAt(i);
      int indexColor = colors.length - i - 1;
      if (!StringUtils.isEmtpy(additional)) {
        childAdditional.add(
          IconButton(
            onPressed: () => launchURL(context, additional),
            icon: Image.asset(
              'images/icons/pdf.png',
              width: 24.0,
              height: 24.0,
              color: colors.elementAt(indexColor),
            ),
          ),
        );
      }
    }
    if (childAdditional.isEmpty) {
      childAdditional.add(SizedBox(
        width: 24.0,
        height: 24.0,
      ));
    }

    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'eipo_shared_offered'.tr(),
              style: styleLabel,
            ),
            Text(
              InvestrendTheme.formatComma(ipo.offering_lot!) + ' Lot',
              style: styleContent,
            ),
            SizedBox(
              height: paddingContent,
            ),

            Text(
              'eipo_book_building'.tr(),
              style: styleLabel,
            ),
            Text(
              bookbuilding,
              style: styleContent,
            ),
            SizedBox(
              height: paddingContent,
            ),

            Text(
              'eipo_offering'.tr(),
              style: styleLabel,
            ),
            Text(
              offering,
              style: styleContent,
            ),
            SizedBox(
              height: paddingContent,
            ),

            Text(
              'eipo_allotment'.tr(),
              style: styleLabel,
            ),
            Text(
              ipo.allotment_date!,
              style: styleContent,
            ),
            SizedBox(
              height: paddingContent,
            ),

            Text(
              'eipo_distribution'.tr(),
              style: styleLabel,
            ),
            Text(
              ipo.distribution_date!,
              style: styleContent,
            ),
            SizedBox(
              height: paddingContent,
            ),

            Text(
              'eipo_listing_date'.tr(),
              style: styleLabel,
            ),
            Text(
              ipo.listing_date!,
              style: styleContent,
            ),
            SizedBox(
              height: paddingContent,
            ),

            Text(
              'eipo_prospectus'.tr(),
              style: styleLabel,
            ),
            Row(
              children: childProspectus,
              /*
              children: [
                IconButton(onPressed: (){}, icon: Image.asset('images/icons/pdf.png', width: 24.0, height: 24.0, color: Colors.blue, ),),
                IconButton(onPressed: (){}, icon: Image.asset('images/icons/pdf.png', width: 24.0, height: 24.0, color: Colors.red, ),),
              ],
              */
            ),
            SizedBox(
              height: paddingContent,
            ),

            Text(
              'eipo_additional_information'.tr(),
              style: styleLabel,
            ),
            //IconButton(onPressed: (){}, icon: Image.asset('images/icons/pdf.png', width: 24.0, height: 24.0, color: Colors.green, ),),
            Row(
              children: childAdditional,
            ),
            SizedBox(
              height: paddingContent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onActive() {
    doUpdate();
  }

  @override
  void onInactive() {}
}
