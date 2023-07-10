import 'package:Investrend/component/button_account.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/custom_text.dart';
import 'package:Investrend/objects/class_input_formatter.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'base/base_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenFundOut extends StatefulWidget {
  const ScreenFundOut({Key key}) : super(key: key);

  @override
  _ScreenFundOutState createState() => _ScreenFundOutState();
}

class _ScreenFundOutState extends BaseStateNoTabs<ScreenFundOut> {
  _ScreenFundOutState() : super('/fund_out');

  CashPositionNotifier _cashNotifier =
      CashPositionNotifier(CashPosition.createBasic());
  BankRDNNotifier _bankRDNNotifier = BankRDNNotifier(BankRDN('', '', '', ''));
  BankAccountNotifier _bankAccountNotifier =
      BankAccountNotifier(BankAccount('', '', '', '', '', '', ''));
  FundOutTermNotifier _termNotifier =
      FundOutTermNotifier(ResultFundOutTerm('', ''));
  TextEditingController _priceTextEditingController =
      TextEditingController(text: '');
  TextEditingController _instructionTextEditingController =
      TextEditingController(text: '');
  FocusNode _focusNodePrice = FocusNode();
  FocusNode _focusNodeInstruction = FocusNode();
  ValueNotifier<bool> _showButtonSendNotifier = ValueNotifier(false);
  ValueNotifier<bool> _keyboardNotifier = ValueNotifier(false);
  VoidCallback onAccountChangeListener;
  ValueNotifier<String> _dateNotifier;

  ValueNotifier<bool> _agreeTnCNotifier = ValueNotifier<bool>(false);

  ValueNotifier<int> _bankDestinationNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _dateNotifier = ValueNotifier<String>(Utils.formatDate(DateTime.now()));
    _priceTextEditingController.addListener(() {
      /*
      if(_priceTextEditingController.text.isEmpty){
        _showButtonSendNotifier.value = false;
      }else{
        _showButtonSendNotifier.value = true;
      }
      */
      enableDisableSendButton();
    });
    _instructionTextEditingController.addListener(() {
      enableDisableSendButton();
    });

    _keyboardNotifier.addListener(() {
      enableDisableSendButton();
    });

    _agreeTnCNotifier.addListener(() {
      enableDisableSendButton();
    });
  }

  Widget getAgreementText() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: InvestrendTheme.cardPaddingGeneral,
          //left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _agreeTnCNotifier,
            builder: (context, value, child) {
              return Checkbox(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: _agreeTnCNotifier.value,
                  onChanged: (value) {
                    _agreeTnCNotifier.value = !_agreeTnCNotifier.value;
                    print('_agreeTnCNotifier ' +
                        _agreeTnCNotifier.value.toString());
                  });
            },
          ),
          Flexible(
            child: Text('fund_out_agreement_content'.tr(),
                style: InvestrendTheme.of(context).support_w400),
          ),
        ],
      ),
    );
  }

  void enableDisableSendButton() {
    bool enable = true;
    if (_priceTextEditingController.text.isEmpty) {
      enable = false;
    }
    if (_instructionTextEditingController.text.isEmpty) {
      enable = false;
    }
    if (_keyboardNotifier.value) {
      enable = false;
    }
    if (!_agreeTnCNotifier.value) {
      enable = false;
    }
    _showButtonSendNotifier.value = enable;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bool keyboardShowed = MediaQuery.of(context).viewInsets.bottom > 0;
    _keyboardNotifier.value = keyboardShowed;

    if (onAccountChangeListener != null) {
      context
          .read(accountChangeNotifier)
          .removeListener(onAccountChangeListener);
    } else {
      onAccountChangeListener = () {
        if (mounted) {
          _bankDestinationNotifier.value = 0;
          doUpdate(pullToRefresh: true);
        }
      };
    }
    context.read(accountChangeNotifier).addListener(onAccountChangeListener);
  }

  @override
  void dispose() {
    _dateNotifier.dispose();
    _cashNotifier.dispose();
    _termNotifier.dispose();
    _bankRDNNotifier.dispose();
    _bankAccountNotifier.dispose();
    _priceTextEditingController.dispose();
    _instructionTextEditingController.dispose();
    _focusNodePrice.dispose();
    _focusNodeInstruction.dispose();
    _keyboardNotifier.dispose();
    _showButtonSendNotifier.dispose();
    _agreeTnCNotifier.dispose();
    _bankDestinationNotifier.dispose();
    final container = ProviderContainer();
    if (onAccountChangeListener != null) {
      container
          .read(accountChangeNotifier)
          .removeListener(onAccountChangeListener);
    }

    super.dispose();
  }

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  void selectDate(BuildContext context) {
    DateTime
        initDate; // =  _dateFormat.parse(_customFromNotifier.value, false);
    try {
      initDate = _dateFormat.parse(_dateNotifier.value, false);
    } catch (e) {
      initDate = DateTime.now();
      print(e);
    }
    DatePicker.showDatePicker(context,
        showTitleActions: true, minTime: DateTime.now(), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
      _dateNotifier.value = _dateFormat.format(date);
    }, currentTime: initDate); // DateTime.now()
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    final notifier = context.read(accountChangeNotifier);

    User user = context.read(dataHolderChangeNotifier).user;
    Account active = user.getAccount(notifier.index);
    if (active == null) {
      print(routeName + '  active Account is NULL');
      return false;
    }
    try {
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
    } catch (error) {
      print(routeName + ' Future bank rdn Error');
      print(error);
      setNotifierError(_bankRDNNotifier, error.toString());
      handleNetworkError(context, error);
    }

    try {
      if (_bankAccountNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_bankAccountNotifier);
      }
      final result = await InvestrendTheme.tradingHttp.getBankAcccount(
          active.accountcode,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future bank account DATA : ' + result.toString());
        if (mounted) {
          _bankAccountNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future bank account NO DATA');
        setNotifierNoData(_bankAccountNotifier);
      }
    } catch (error) {
      print(routeName + ' Future bank account Error');
      print(error);
      setNotifierError(_bankAccountNotifier, error.toString());
      handleNetworkError(context, error);
    }

    try {
      if (_cashNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_cashNotifier);
      }
      final result = await InvestrendTheme.tradingHttp.cashPosition(
          active.brokercode,
          active.accountcode,
          user.username,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      if (result != null) {
        print(routeName + ' Future cash DATA : ' + result.toString());
        if (mounted) {
          _cashNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future cash NO DATA');
        setNotifierNoData(_cashNotifier);
      }
    } catch (error) {
      print(routeName + ' Future cash Error');
      print(error);
      setNotifierError(_cashNotifier, error.toString());
      handleNetworkError(context, error);
    }

    try {
      if (_termNotifier.value.isEmpty() || pullToRefresh) {
        setNotifierLoading(_termNotifier);
      }
      final result = await InvestrendTheme.datafeedHttp.fetchFundOutTerm();
      if (result != null) {
        print(routeName + ' Future fund out term DATA : ' + result.toString());
        if (mounted) {
          _termNotifier.setValue(result);
        }
      } else {
        print(routeName + ' Future fund out term NO DATA');
        setNotifierNoData(_termNotifier);
      }
    } catch (error) {
      print(routeName + ' Future fund out term Error');
      print(error);
      setNotifierError(_termNotifier, error.toString());
    }

    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Future onRefresh() {
    return doUpdate(pullToRefresh: true);
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
      title: AppBarTitleText('fund_out_title'.tr()),
      leading: AppBarActionIcon('images/icons/action_back.png', () {
        Navigator.pop(context);
      }),

      //icon: Image.asset('images/icons/action_clear.png', color: InvestrendTheme.greenText, width: 12.0, height: 12.0),
    );
  }

  Widget createBankSource(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _bankRDNNotifier,
      builder: (context, BankRDN value, child) {
        Widget mainWidget = Padding(
          padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'fund_out_from_rdn'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                value.bank + ' - ' + value.acc_no,
                style: InvestrendTheme.of(context).small_w400,
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                value.acc_name,
                style: InvestrendTheme.of(context).more_support_w400,
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

  Widget createBankDestination(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _bankAccountNotifier,
      builder: (context, final BankAccount value, child) {
        bool lightTheme = Theme.of(context).brightness == Brightness.light;

        List<String> list = List.empty(growable: true);
        list.add(value.bank + ' - ' + value.acc_no);
        if (value.isMultiple()) {
          list.add(value.bank2 + ' - ' + value.acc_no2);
        }

        Widget mainWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: Text(
                'fund_out_to_account'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            // SizedBox(
            //   height: 4.0,
            // ),
            TextButtonDropdown(
              _bankDestinationNotifier,
              list,
              clickAndClose: true,
              style: InvestrendTheme.of(context).small_w400_compact,
            ),
            /*
            Text(
              value.bank + ' - ' + value.acc_no,
              style: InvestrendTheme.of(context).small_w400,
            ),
            */
            // SizedBox(
            //   height: 4.0,
            // ),
            ValueListenableBuilder(
              valueListenable: _bankDestinationNotifier,
              builder: (context, int index, child) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: InvestrendTheme.cardPaddingGeneral,
                      right: InvestrendTheme.cardPaddingGeneral),
                  child: Text(
                    index == 0 ? value.acc_name : value.acc_name2,
                    style:
                        InvestrendTheme.of(context).more_support_w400_compact,
                  ),
                );
              },
            ),
            /*
            Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
              child: Text(
                value.acc_name,
                style: InvestrendTheme.of(context).more_support_w400,
              ),
            ),
            */
            SizedBox(
              height: InvestrendTheme.cardPaddingGeneral,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: Text(
                'fund_out_nominal'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: ComponentCreator.textFieldForm(
                context,
                lightTheme,
                'Rp ',
                '',
                null,
                null,
                '',
                false,
                TextInputType.number,
                TextInputAction.done,
                null,
                _priceTextEditingController,
                null,
                _focusNodePrice,
                null,
                padding: EdgeInsets.only(top: 1.0),
                inputFormatters: [
                  PriceFormatter(),
                ],
              ),
            ),
            /*
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingGeneral),
                  child: Text(
                    'Rp ',
                    style:
                        InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: ComponentCreator.textFieldForm(context, lightTheme, null, '', null, null, '', false, TextInputType.number,
                        TextInputAction.done, null, _textEditingController, null, _focusNode, null,
                        padding: EdgeInsets.only(top: 1.0))),
              ],
            ),

             */
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'fund_out_balance_rdn_t2'.tr(),
                    style: InvestrendTheme.of(context)
                        .more_support_w400
                        .copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _cashNotifier,
                    builder: (context, CashPosition value, child) {
                      Widget noWidget = _cashNotifier.currentState.getNoWidget(
                          onRetry: () => doUpdate(pullToRefresh: true));
                      if (noWidget != null) {
                        return Center(
                          child: noWidget,
                        );
                      }
                      return Text(
                        InvestrendTheme.formatMoneyDouble(
                          value.cashBalance,
                          prefixPlus: false,
                        ),
                        style: InvestrendTheme.of(context).small_w400.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: Text(
                'fund_out_date'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _dateNotifier,
              builder: (context, value, child) {
                return TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.only(
                          left: InvestrendTheme.cardPaddingGeneral,
                          right: InvestrendTheme.cardPaddingGeneral,
                          top: InvestrendTheme.cardPadding,
                          bottom: InvestrendTheme.cardPadding),
                      alignment: Alignment.centerLeft),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.button.copyWith(
                        color: InvestrendTheme.of(context).investrendPurple),
                  ),
                  onPressed: () => selectDate(context),
                );
              },
            ),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: Text(
                'fund_out_description'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(
                    color: InvestrendTheme.of(context).greyLighterTextColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral),
              child: ComponentCreator.textFieldForm(
                context,
                lightTheme,
                '',
                '',
                null,
                null,
                '',
                false,
                TextInputType.multiline,
                TextInputAction.done,
                null,
                _instructionTextEditingController,
                null,
                _focusNodeInstruction,
                null,
                padding: EdgeInsets.only(top: 1.0),
              ),
            ),
          ],
        );
        Widget noWidget = _bankAccountNotifier.currentState
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

  void submitFundOut(BuildContext context) async {
    final notifier = context.read(accountChangeNotifier);
    bool hasAccount =
        context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (!hasAccount) {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'no_account_found_message'.tr());
      return;
    }
    User user = context.read(dataHolderChangeNotifier).user;
    Account active = user.getAccount(notifier.index);
    if (active == null) {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'no_active_account_found_message'.tr());
      return;
    }
    if (_bankRDNNotifier.value.isEmpty()) {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'no_source_bank_found_message'.tr());
      return;
    }
    if (_bankAccountNotifier.value.isEmpty()) {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'no_destination_bank_found_message'.tr());
      return;
    }
    String scrappedAmount =
        _priceTextEditingController.text.replaceAll(',', '');
    //int amountNumber = Utils.safeInt(_textEditingController.text);
    int amountNumber = Utils.safeInt(scrappedAmount);
    if (amountNumber <= 0) {
      InvestrendTheme.of(context)
          .showSnackBar(context, 'error_amount_is_empty'.tr());
      return;
    }

    bool firstBank = _bankDestinationNotifier.value == 0;
    String email = user.email;
    String realname = user.realname;
    String account = active.accountcode;
    String amount = _priceTextEditingController.text;
    String rdnbank = _bankRDNNotifier.value.bank;
    String rdnno = _bankRDNNotifier.value.acc_no;
    String rdnname = _bankRDNNotifier.value.acc_name;
    String bank = firstBank
        ? _bankAccountNotifier.value.bank
        : _bankAccountNotifier.value.bank2;
    String bankno = firstBank
        ? _bankAccountNotifier.value.acc_no
        : _bankAccountNotifier.value.acc_no2;
    String bankname = firstBank
        ? _bankAccountNotifier.value.acc_name
        : _bankAccountNotifier.value.acc_name2;

    String date = _dateNotifier.value;
    String message = _instructionTextEditingController.text;

    String platform = InvestrendTheme.of(context).applicationPlatform;
    String version = InvestrendTheme.of(context).applicationVersion;
    showLoading(context, text: 'loading_submit_fund_out'.tr());
    try {
      final result = await InvestrendTheme.tradingHttp.submitFundOut(
          email,
          realname,
          account,
          amount,
          rdnbank,
          rdnno,
          rdnname,
          bank,
          bankno,
          bankname,
          date,
          message,
          platform,
          version);

      closeLoading();
      if (result is String) {
        print('submitFundOut result : ' + result.toString());
        //InvestrendTheme.of(context).showSnackBar(context, result);
        if (StringUtils.equalsIgnoreCase(result, 'sent')) {
          _priceTextEditingController.text = '';
          InvestrendTheme.of(context).showInfoDialog(context,
              title: 'info_label'.tr(),
              content: 'Withdrawal Instruction has been sent.'.tr(),
              onClose: () {
            Navigator.of(context).pop();
          });
        }
      } else {
        print('submitFundOut result : ' + result.toString());
        InvestrendTheme.of(context).showSnackBar(context, result);
      }
    } catch (error) {
      closeLoading();
      handleNetworkError(context, error);
    }
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      //return null;
      paddingBottom = 0;
    }
    return ValueListenableBuilder(
      valueListenable: _showButtonSendNotifier,
      builder: (context, value, child) {
        if (value) {
          return Container(
            width: double.maxFinite,
            //color: Colors.yellow,
            padding: EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingGeneral,
                bottom: (InvestrendTheme.cardPaddingGeneral + paddingBottom)),
            child: ComponentCreator.roundedButton(
                context,
                'button_send'.tr(),
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
                () => submitFundOut(context)),
          );
        } else {
          return SizedBox(
            width: 1.0,
          );
        }
      },
    );
    /*
    return Container(
      width: double.maxFinite,
      //color: Colors.yellow,
      padding: EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: InvestrendTheme.cardPaddingGeneral, bottom: (InvestrendTheme.cardPaddingGeneral+paddingBottom)),
      child: ComponentCreator.roundedButton(context, 'button_send'.tr(), Theme.of(context).accentColor,
          Theme.of(context).primaryColor, Theme.of(context).accentColor, ()=>submitFundOut(context)),
    );
    */
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return ComponentCreator.keyboardHider(
        context,
        RefreshIndicator(
          color: InvestrendTheme.of(context).textWhite,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onRefresh: onRefresh,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral,
                    top: 10.0),
                child: Text(
                  'choose_account_label'.tr(),
                  style: InvestrendTheme.of(context).more_support_w400.copyWith(
                      color: InvestrendTheme.of(context).greyLighterTextColor),
                ),
              ),
              ButtonAccount(),
              createBankSource(context),
              Padding(
                padding: const EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child:
                            ComponentCreator.divider(context, thickness: 1.0)),
                    Image.asset(
                      'images/icons/transfer.png',
                      width: 15.0,
                      height: 15.0,
                    ),
                  ],
                ),
              ),
              createBankDestination(context),
              Padding(
                padding: const EdgeInsets.only(
                    top: InvestrendTheme.cardPaddingGeneral,
                    bottom: InvestrendTheme.cardPaddingGeneral),
                child: ComponentCreator.divider(context, thickness: 1.0),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: InvestrendTheme.cardPaddingGeneral,
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral),
                child: Text(
                  'fund_out_term_label'.tr(),
                  style: InvestrendTheme.of(context).regular_w600,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _termNotifier,
                builder: (context, value, child) {
                  Widget noWidget = _termNotifier.currentState.getNoWidget(
                      onRetry: () => doUpdate(pullToRefresh: true));
                  if (noWidget != null) {
                    return Center(
                      child: noWidget,
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                        //bottom: InvestrendTheme.cardPaddingGeneral,
                        left: InvestrendTheme.cardPaddingGeneral,
                        right: InvestrendTheme.cardPaddingGeneral),
                    child: FormatTextBullet(
                      value.getTerm(
                          language:
                              EasyLocalization.of(context).locale.languageCode),
                      style: InvestrendTheme.of(context)
                          .more_support_w400
                          .copyWith(
                              color: InvestrendTheme.of(context)
                                  .greyDarkerTextColor),
                    ),
                    /*
                child: Text(
                  value.getTerm(language: EasyLocalization.of(context).locale.languageCode),
                  style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                */
                  );
                },
              ),
              SizedBox(
                height: InvestrendTheme.cardPaddingVertical,
              ),
              getAgreementText(),
              SizedBox(
                height: paddingBottom + 80,
              ),
            ],
          ),

          /*
      child: ValueListenableBuilder(
          valueListenable: _banksNotifier,
          builder: (context, ResultTopUpBank value, child) {
            if(value == null){
              value = _banksNotifier.value;
            }
            List<Widget> childs = List.empty(growable: true);
            childs.add(Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, top: 10.0),
              child: Text(
                'choose_account_label'.tr(),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
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
            childs.add(Padding(
              padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
              child: Text(
                value.getTerm(language: EasyLocalization.of(context).locale.languageCode),
                style: InvestrendTheme.of(context).more_support_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
              ),
            ));
            Widget noWidget = _banksNotifier.currentState.getNoWidget(onRetry: ()=>doUpdate(pullToRefresh: true));
            if(noWidget != null){
              childs.add(Center(child: noWidget));
            }
            int countChilds = childs.length;
            int countAll = childs.length + value.count();

            return ListView.separated(
              itemCount: countAll,
              itemBuilder: (context, index) {
                if(index < countChilds) {
                  return childs.elementAt(index);
                }
                int indexBank = index - countChilds;
                if(indexBank < value.count()){
                  TopUpBank bank = value.datas.elementAt(indexBank);
                  return createBankHowTo(context, bank);
                }
                return EmptyLabel(text: ' - ',);
              },
              separatorBuilder: (BuildContext context, int index) {
                if(index < countChilds) {
                  return SizedBox(width: 1.0,);
                }
                // int indexBank = countAll - index;
                // if(indexBank < value.count()){
                  return Padding(
                    padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                    child: ComponentCreator.divider(context, thickness: 1.0),
                  );
                // }
              },
            );
          }),
      */
        ));
  }

  /*
  Widget createBankHowTo(BuildContext context, TopUpBank bank){
    return  Padding(
      padding: const EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
      child: TopupBankInfoWidget(bank.code, bank.icon_url,
          bank.getGuide(language: EasyLocalization.of(context).locale.languageCode)),
    );
  }
  */
  @override
  void onActive() {
    doUpdate();
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}
