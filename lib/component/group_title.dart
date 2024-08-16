// ignore_for_file: must_be_immutable

import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';

class GroupTitle extends StatelessWidget {
  Color? color;
  String? text;
  GroupTitle(this.text, {this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? style = InvestrendTheme.of(context).support_w600_compact;
    if (color != null) {
      style = style?.copyWith(color: color);
    }
    return Text(
      text!,
      //style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
      style: style,
    );
  }
}
