import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class EmptyLabel extends StatelessWidget {
  final Color? color;
  final EdgeInsets? padding;
  final String? text;
  const EmptyLabel({Key? key, this.color, this.padding, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget empty = Center(
      child: Text(
        text ?? 'empty_label'.tr(),
        textAlign: TextAlign.center,
        style: InvestrendTheme.of(context).small_w400?.copyWith(
            color: color ?? InvestrendTheme.of(context).greyLighterTextColor),
      ),
    );
    if (padding == null) {
      return empty;
    }
    return Padding(
      padding: padding!,
      child: empty,
    );
  }
}

class EmptyTitleLabel extends StatelessWidget {
  final Color? color;
  final EdgeInsets? padding;
  final String? text;
  const EmptyTitleLabel({Key? key, this.color, this.padding, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget empty = Center(
      child: Text(
        text ?? 'empty_label'.tr(),
        style: InvestrendTheme.of(context).small_w600?.copyWith(
            color: color ?? InvestrendTheme.of(context).greyDarkerTextColor),
      ),
    );
    if (padding == null) {
      return empty;
    }
    return Padding(
      padding: padding!,
      child: empty,
    );
  }
}
