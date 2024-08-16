//import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rows/row_general_price.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
//import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
//import 'package:easy_localization/easy_localization.dart';

class CardGeneralPrice extends StatelessWidget {
  final String? title;
  final GeneralPriceNotifier? notifier;

  const CardGeneralPrice(this.title, this.notifier, {Key? key})
      : super(key: key);

  Widget subtitle(BuildContext context, String text, {Color? color}) {
    TextStyle? style = InvestrendTheme.of(context).support_w600_compact;
    if (color != null) {
      style = style?.copyWith(color: color);
    }
    return Text(
      text,
      //style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.all(InvestrendTheme.cardMargin),
      child: Padding(
        padding: EdgeInsets.all(InvestrendTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: InvestrendTheme.cardPaddingGeneral,
            ),
            subtitle(context, title!,
                color: InvestrendTheme.of(context).greyLighterTextColor),
            SizedBox(
              height: InvestrendTheme.cardPadding,
            ),
            ValueListenableBuilder(
              valueListenable: this.notifier!,
              builder: (context, GeneralPriceData? data, child) {
                if (notifier!.invalid()) {
                  return Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: List<Widget>.generate(
                    data!.count(),
                    (int index) {
                      GeneralPrice gp = data.datas!.elementAt(index);
                      return RowGeneralPrice(
                        gp.code,
                        gp.price,
                        gp.change,
                        gp.percent,
                        gp.priceColor,
                        name: gp.name,
                        firstRow: (index == 0),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
