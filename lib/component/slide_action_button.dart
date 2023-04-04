import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';



class TradeSlideAction extends ClosableSlideAction {
  final String text;
  final String tag;
  final AutoSizeGroup autoGroup;
  TradeSlideAction(
      this.text,
      Color color,
      VoidCallback onTap, {
        this.autoGroup,
        this.tag,
      }) : super(onTap: onTap, color: color, closeOnTap: true);

  void _handleCloseAfterTap(BuildContext context) {
    onTap?.call();
    Slidable.of(context)?.close();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Material(
      color: color,
      borderRadius: BorderRadius.circular(4.0),
      child: InkWell(
        onTap: !closeOnTap ? onTap : () => _handleCloseAfterTap(context),
        child: buildAction(context),
      ),
    );
    if (!StringUtils.isEmtpy(tag)) {
      child = Hero(tag: tag, child: child);
    }
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: child,
      ),
    );
    /*
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(4.0),
          child: InkWell(
            onTap: !closeOnTap ? onTap : () => _handleCloseAfterTap(context),
            child: buildAction(context),
          ),
        ),
      ),
    );
     */
  }

  @override
  Widget buildAction(BuildContext context) {
    Widget textWidget;
    if(autoGroup != null){
      textWidget = AutoSizeText(
        text,
        group: autoGroup,
        minFontSize: 8.0,
        maxLines: 1,
        style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: InvestrendTheme.of(context).textWhite),
      );
    }else{
      textWidget = Text(
        text,
        style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: InvestrendTheme.of(context).textWhite),
      );
    }
    return Container(
      child: Center(
        child: textWidget,
      ),
    );
  }
}

class CancelSlideAction extends ClosableSlideAction {
  final String text;

  CancelSlideAction(this.text, Color color, VoidCallback onTap) : super(onTap: onTap, color: color, closeOnTap: true);

  @override
  Widget buildAction(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          text,
          style: InvestrendTheme.of(context).small_w600_compact.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
        ),
      ),
    );
  }
}