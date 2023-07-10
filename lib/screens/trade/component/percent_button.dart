import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class PercentButton extends StatelessWidget {
  final int percentValue;
  final int selected;
  final VoidCallback onPressed;

  const PercentButton(this.percentValue, this.selected, {Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = InvestrendTheme.of(context).support_w400.color;
    if (percentValue == selected) {
      color = Theme.of(context).colorScheme.secondary;
    }
    return TextButton(
        style: ButtonStyle(visualDensity: VisualDensity.compact),
        onPressed: onPressed,
        // onPressed: () {
        //   predefineLot(percentValue);
        // },
        child: Text(
          '$percentValue%',
          style: InvestrendTheme.of(context).support_w600.copyWith(color: color),
        ));
  }
}
