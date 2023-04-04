import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class ButtonOutlinedRounded extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const ButtonOutlinedRounded(this.text,{this.onPressed, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) {
            final Color colors =
            states.contains(MaterialState.pressed)
                ? Colors.transparent
                : Colors.transparent;
            return colors;
          }),
          //visualDensity: VisualDensity.comfortable,
          padding: MaterialStateProperty.all(EdgeInsets.only(
              left: 10.0, right: 10.0, top: 2.0, bottom: 2.0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                //side: BorderSide(color: Colors.red)
              )),
          side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                final Color colors =
                states.contains(MaterialState.pressed)
                    ? Theme.of(context).accentColor
                    : Theme.of(context).accentColor;
                return BorderSide(color: colors, width: 1.0);
              }),
        ),
        child: Text(
          text,
          style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: Theme.of(context).accentColor),
        ),
        onPressed: onPressed);
  }
}
