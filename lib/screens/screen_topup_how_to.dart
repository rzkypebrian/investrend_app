import 'package:Investrend/component/button_account.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/custom_text.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/info_detail_widget.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'base/base_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenTopUpHowTo extends StatefulWidget {
  const ScreenTopUpHowTo({Key key}) : super(key: key);

  @override
  _ScreenTopUpHowToState createState() => _ScreenTopUpHowToState();
}

class _ScreenTopUpHowToState extends BaseStateNoTabs<ScreenTopUpHowTo> {
  _ScreenTopUpHowToState() : super('/topup_how_to');

  TopUpBanksNotifier _banksNotifier = TopUpBanksNotifier(ResultTopUpBank());
  BankRDNNotifier _bankRDNNotifier = BankRDNNotifier(BankRDN('', '', '', ''));

  VoidCallback onAccountChangeListener;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (onAccountChangeListener != null) {
      context
          .read(accountChangeNotifier)
          .removeListener(onAccountChangeListener);
    } else {
      onAccountChangeListener = () {
        if (mounted) {
          doUpdate(pullToRefresh: true);
        }
      };
    }
    context.read(accountChangeNotifier).addListener(onAccountChangeListener);
  }

  @override
  void dispose() {
    _bankRDNNotifier.dispose();
    _banksNotifier.dispose();
    final container = ProviderContainer();
    container
        .read(accountChangeNotifier)
        .removeListener(onAccountChangeListener);
    super.dispose();
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    try {
      final notifier = context.read(accountChangeNotifier);

      User user = context.read(dataHolderChangeNotifier).user;
      Account active = user.getAccount(notifier.index);

      if (active != null) {
        if (_bankRDNNotifier.value.isEmpty() || pullToRefresh) {
          setNotifierLoading(_bankRDNNotifier);
        }

        final result = await InvestrendTheme.tradingHttp.getBankRDN(
            active.accountcode,
            InvestrendTheme.of(context).applicationPlatform,
            InvestrendTheme.of(context).applicationVersion);
        if (result != null) {
          print(routeName + ' Future bank rdn DATA : ' + result.toString());
          if (mounted) {
            _bankRDNNotifier.setValue(result);
          }
        } else {
          print(routeName + ' Future bank rdn NO DATA');
          setNotifierNoData(_bankRDNNotifier);
        }
      }
    } catch (error) {
      print(routeName + ' Future bank rdn Error');
      print(error);
      setNotifierError(_bankRDNNotifier, error.toString());
      handleNetworkError(context, error);
    }

    try {
      if (_banksNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_banksNotifier);
      }
      final result = await InvestrendTheme.datafeedHttp.fetchTopUpBanks();
      if (result != null) {
        print(routeName + ' Future topup banks DATA : ' + result.toString());
        if (mounted) {
          _banksNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future topup banks NO DATA');
        setNotifierNoData(_banksNotifier);
      }
    } catch (error) {
      print(routeName + ' Future topup banks Error');
      print(error);
      setNotifierError(_banksNotifier, error.toString());
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }
  /*
  @override
  Widget build(BuildContext context) {
    String bank = 'BCA';
    String account_name = 'Ackerman';
    String account_number = '97449318301';

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        title: AppBarTitleText('top_up_title'.tr()),
        leading: AppBarActionIcon('images/icons/action_back.png', () {
          Navigator.pop(context);
        }),

        //icon: Image.asset('images/icons/action_clear.png', color: InvestrendTheme.greenText, width: 12.0, height: 12.0),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'how_to_top_up_label'.tr(),
                style: InvestrendTheme.of(context).regular_w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0),
              child: Text(
                'bank_label'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Text(
                bank,
                style: InvestrendTheme.of(context).small_w400,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0),
              child: Text(
                'account_name_label'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Text(
                account_name,
                style: InvestrendTheme.of(context).small_w400,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'account_number_label'.tr(),
                        style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                      ),
                      Text(
                        account_number,
                        style: InvestrendTheme.of(context).small_w400,
                      ),
                    ],
                  ),
                  OutlinedButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Image.asset(
                            'images/icons/action_copy.png',
                            color: InvestrendTheme.of(context).blackAndWhiteText,
                            width: 10.0,
                            height: 10.0,
                          ),
                          // Icon(
                          //   Image.asset('images/icons/action_copy.png'),
                          //   size: 10.0,
                          // ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'button_copy'.tr(),
                            style: InvestrendTheme.of(context).more_support_w400_compact,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Container(
              color: InvestrendTheme.of(context).tileBackground,
              margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
              padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 24.0, bottom: 24.0),
              //width: double.maxFinite,
              child: Column(
                children: [
                  textWithBullet(
                      context, 'We also work with non-profits, other research organizations, and governments to achieve the best outcomes.'),
                  SizedBox(
                    height: 8.0,
                  ),
                  textWithBullet(
                      context, 'We also work with non-profits, other research organizations, and governments to achieve the best outcomes.'),
                  SizedBox(
                    height: 8.0,
                  ),
                  textWithBullet(
                      context, 'We also work with non-profits, other research organizations, and governments to achieve the best outcomes.'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TopupBankInfoWidget('BCA', 'images/icons/bank_bca.png',
                  'We also work with non-profits, other research organizations, and governments to achieve the best outcome'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: ComponentCreator.divider(context),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TopupBankInfoWidget('Permata', 'images/icons/bank_permata.png',
                  'We also work with non-profits, other research organizations, and governments to achieve the best outcome'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: ComponentCreator.divider(context),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TopupBankInfoWidget('OVO', 'images/icons/bank_ovo.png',
                  'We also work with non-profits, other research organizations, and governments to achieve the best outcome'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: ComponentCreator.divider(context),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TopupBankInfoWidget('BNI', 'images/icons/bank_bni.png',
                  'We also work with non-profits, other research organizations, and governments to achieve the best outcome'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: ComponentCreator.divider(context),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TopupBankInfoWidget('Mandiri', 'images/icons/bank_mandiri.png',
                  'We also work with non-profits, other research organizations, and governments to achieve the best outcome'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: ComponentCreator.divider(context),
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget textWithBullet(BuildContext context, String text) {
    // return Text('•  '+text, style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: InvestrendTheme.of(context)
              .more_support_w400
              .copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
        ),
        SizedBox(
          width: 5.0,
        ),
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: InvestrendTheme.of(context).more_support_w400.copyWith(
                color: InvestrendTheme.of(context).greyDarkerTextColor),
          ),
        ),
      ],
    );
  }

  @override
  Widget createAppBar(BuildContext context) {
    // TODO: implement createAppBar
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: elevation,
      shadowColor: shadowColor,
      title: AppBarTitleText('top_up_title'.tr()),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        Navigator.pop(context);
      }),
      //icon: Image.asset('images/icons/action_clear.png', color: InvestrendTheme.greenText, width: 12.0, height: 12.0),
    );
  }

  Widget createBankInformation(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _bankRDNNotifier,
      builder: (context, BankRDN value, child) {
        Widget imageWidget;
        if (StringUtils.isEmtpy(value.bank)) {
          imageWidget = Text(
            value.bank,
            style: InvestrendTheme.of(context).small_w400,
          );
        } else {
          imageWidget = ComponentCreator.imageNetworkCached(
              'https://www.investrend.co.id/mobile/assets/banks_icon/' +
                  value.bank.toLowerCase() +
                  '.png',
              width: 40.0,
              height: 40.0,
              errorWidget: SizedBox(
                height: 40.0,
              ));
          /*
            imageWidget = Row(
              children: [
                ComponentCreator.imageNetworkCached('https://www.investrend.co.id/mobile/assets/banks_icon/'+value.bank.toLowerCase()+'.png',width: 40.0, height: 40.0,errorWidget: SizedBox(height: 1.0,)),
                SizedBox(width: InvestrendTheme.cardPaddingGeneral,),
                Text(
                  value.bank,
                  style: InvestrendTheme.of(context).small_w400,
                ),
              ],
            );
             */
        }
        Widget mainWidget = Padding(
          padding: const EdgeInsets.only(
            left: InvestrendTheme.cardPaddingGeneral,
            right: InvestrendTheme.cardPaddingGeneral, /*top: 12.0*/
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'account_name_label'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
              Text(
                value.acc_name,
                style: InvestrendTheme.of(context).small_w400,
              ),
              SizedBox(
                height: 12.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'bank_label'.tr(),
                        style: InvestrendTheme.of(context)
                            .more_support_w400
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .greyLighterTextColor),
                      ),
                      imageWidget,
                      //SizedBox(height: 12.0,),
                    ],
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardPaddingGeneral,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'account_number_label'.tr(),
                        style: InvestrendTheme.of(context)
                            .more_support_w400
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .greyLighterTextColor),
                      ),
                      Container(
                        height: 40.0,
                        alignment: Alignment.center,
                        child: Text(
                          value.acc_no,
                          style: InvestrendTheme.of(context).small_w400_compact,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: InvestrendTheme.cardPaddingGeneral,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ' ',
                        style: InvestrendTheme.of(context)
                            .more_support_w400
                            .copyWith(
                                color: InvestrendTheme.of(context)
                                    .greyLighterTextColor),
                      ),
                      Container(
                        height: 30.0,
                        margin: EdgeInsets.only(top: 4.0),
                        child: OutlinedButton(
                            onPressed: () {
                              Clipboard.setData(
                                      new ClipboardData(text: value.acc_no))
                                  .then((_) {
                                String info =
                                    'account_number_copied_to_clipboard_info'
                                        .tr();
                                info =
                                    info.replaceFirst('#ACC_NO#', value.acc_no);
                                InvestrendTheme.of(context)
                                    .showSnackBar(context, info);
                              });
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'images/icons/copy.png',
                                  color: InvestrendTheme.of(context)
                                      .blackAndWhiteText,
                                  width: 10.0,
                                  height: 10.0,
                                ),
                                // Icon(
                                //   Image.asset('images/icons/action_copy.png'),
                                //   size: 10.0,
                                // ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  'button_copy'.tr(),
                                  style: InvestrendTheme.of(context)
                                      .more_support_w400_compact,
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
        Widget noWidget = _bankRDNNotifier.currentState
            .getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
        if (noWidget != null) {
          return Stack(
            children: [
              mainWidget,
              Center(child: noWidget),
            ],
          );
        }
        return mainWidget;
      },
    );
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ValueListenableBuilder(
          valueListenable: _banksNotifier,
          builder: (context, ResultTopUpBank value, child) {
            if (value == null) {
              value = _banksNotifier.value;
            }
            List<Widget> childs = List.empty(growable: true);
            childs.add(Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral,
                  top: 10.0),
              child: Text(
                'choose_account_label'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ));

            childs.add(ButtonAccount());
            childs.add(createBankInformation(context));
            childs.add(Padding(
              padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
              child: Text(
                'top_up_term_label'.tr(),
                style: InvestrendTheme.of(context).regular_w600,
              ),
            ));

            /*
            childs.add(Padding(
              padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
              child: Text(
                value.getTerm(language: EasyLocalization.of(context).locale.languageCode),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
              ),
            ));
            */

            childs.add(Padding(
              padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
              child: FormatTextBullet(
                value.getTerm(
                    language: EasyLocalization.of(context).locale.languageCode),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyDarkerTextColor),
              ),
            ));

            // String term = value.getTerm(language: EasyLocalization.of(context).locale.languageCode);
            // while(term != null && term.startsWith('• ')){
            //   String bulletText
            // }

            Widget noWidget = _banksNotifier.currentState
                .getNoWidget(onRetry: () => doUpdate(pullToRefresh: true));
            if (noWidget != null) {
              childs.add(Center(child: noWidget));
            }
            int countChilds = childs.length;
            int countAll = childs.length + value.count();

            return ListView.separated(
              itemCount: countAll,
              itemBuilder: (context, index) {
                if (index < countChilds) {
                  return childs.elementAt(index);
                }
                int indexBank = index - countChilds;
                if (indexBank < value.count()) {
                  TopUpBank bank = value.datas.elementAt(indexBank);
                  return createBankHowTo(context, bank);
                }
                return EmptyLabel(
                  text: ' - ',
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index < countChilds) {
                  return SizedBox(
                    width: 1.0,
                  );
                }
                // int indexBank = countAll - index;
                // if(indexBank < value.count()){
                return Padding(
                  padding: const EdgeInsets.only(
                      left: InvestrendTheme.cardPaddingGeneral,
                      right: InvestrendTheme.cardPaddingGeneral),
                  child: ComponentCreator.divider(context, thickness: 1.0),
                );
                // }
              },
            );
          }),
    );
  }

  Widget createBankHowTo(BuildContext context, TopUpBank bank) {
    return Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
      child: TopupBankInfoWidget(
          bank.code,
          bank.icon_url,
          bank.getGuide(
              language: EasyLocalization.of(context).locale.languageCode)),
    );
  }

  @override
  void onActive() {
    doUpdate();
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}
