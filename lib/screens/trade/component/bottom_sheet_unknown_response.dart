import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/screens/trade/screen_amend.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class UnknownResponseSheet extends BaseTradeBottomSheet {
  final BuySell data;
  final String? response;

  UnknownResponseSheet(this.data, this.response);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Unknown Response'),
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
                //Navigator.pop(context);
                Navigator.pop(context, 'KEEP');
              }),
        ),
        body: Center(
          child: Text(
            response ?? '-',
            style: InvestrendTheme.of(context).small_w400_compact,
          ),
        ),
      ),
    );
  }
}
