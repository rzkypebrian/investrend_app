import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/screens/trade/screen_amend.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class ErrorBottomSheet extends BaseTradeBottomSheet {
  final BuySell data;
  final String? message;
  ErrorBottomSheet(this.data, {this.message});

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          //backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            elevation: 0.0,
            leading: IconButton(
                // icon: Icon(
                //   Icons.clear,
                //   color: InvestrendTheme.redText,
                // ),
                icon: Image.asset(
                  'images/icons/action_clear.png',
                  color: InvestrendTheme.redText,
                  width: 12.0,
                  height: 12.0,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 36.0,
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Center(
                    child: Image.asset(
                      'images/order_error.png',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 64.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Text(
                  'trade_error_text_1'.tr(),
                  style: InvestrendTheme.of(context)
                      .regular_w600_compact
                      ?.copyWith(color: InvestrendTheme.redText),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              createErrorMessage(context),

              // RichText(
              //   text: TextSpan(
              //     text: 'Open: ',
              //     style: InvestrendTheme.of(context).regular_w700_compact.copyWith(
              //       color: InvestrendTheme.of(context).greyDarkerTextColor,
              //     ),
              //     children: <TextSpan>[
              //       TextSpan(
              //         text: InvestrendTheme.formatComma(openLot),
              //         style: InvestrendTheme.of(context).regular_w400_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
              //       ),
              //     ],
              //   ),
              // ),
              Spacer(
                flex: 3,
              ),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: ComponentCreator.roundedButton(
                    context,
                    'trade_error_button_try_again'.tr(),
                    InvestrendTheme.redText,
                    InvestrendTheme.of(context).whiteColor,
                    InvestrendTheme.redText, () {
                  print('order Lagi clicked');
                  Navigator.pop(context, 'KEEP'); // clear data
                }),
              ),
              TextButton(
                  child: Text(
                    'trade_error_button_faq'.tr(),
                    style: InvestrendTheme.of(context)
                        .small_w400_compact
                        ?.copyWith(
                            color: InvestrendTheme.of(context)
                                .greyDarkerTextColor),
                  ),
                  onPressed: () {
                    print('lihat FAQ');
                    //Navigator.pop(context, 'KEEP'); // keep data
                    // Navigator.popUntil(context, (route)  {
                    //   print('popUntil : '+route.toString());
                    //   return route.isFirst;
                    // });
                    // context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
                  }),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createErrorMessage(BuildContext context) {
    String? text = 'trade_error_text_2'.tr();
    if (/*InvestrendTheme.DEBUG && */ !StringUtils.isEmtpy(this.message)) {
      text = this.message;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
      child: Text(
        text!,
        style: InvestrendTheme.of(context)
            .regular_w400
            ?.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
