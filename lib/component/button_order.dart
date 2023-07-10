import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum OrderType { Buy, Sell, AmendBuy, AmendSell, Unknown }

extension OrderTypeExtension on OrderType {
  String get routeName {
    switch (this) {
      case OrderType.Buy:
        return '/trade_buy';
      case OrderType.Sell:
        return '/trade_sell';
      case OrderType.AmendBuy:
        return '/amend_buy';
      case OrderType.AmendSell:
        return '/amend_sell';
      default:
        return '#unknown_routeName';
    }
  }

  String get shortSymbol {
    switch (this) {
      case OrderType.Buy:
        return 'B';
      case OrderType.Sell:
        return 'S';
      case OrderType.AmendBuy:
        return 'B';
      case OrderType.AmendSell:
        return 'S';
      default:
        return '-';
    }
  }

  bool isBuyOrAmendBuy() {
    return this == OrderType.Buy || this == OrderType.AmendBuy;
  }

  bool isSellOrAmendSell() {
    return this == OrderType.Sell || this == OrderType.AmendSell;
  }

  String get text {
    switch (this) {
      case OrderType.Buy:
        return 'buy_text'.tr();
      case OrderType.Sell:
        return 'sell_text'.tr();
      case OrderType.AmendBuy:
        return 'amend_buy_text'.tr();
      case OrderType.AmendSell:
        return 'amend_sell_text'.tr();
      default:
        return '#unkown_text';
    }
  }

  String get textButton {
    switch (this) {
      case OrderType.Buy:
        return 'button_buy'.tr();
      case OrderType.Sell:
        return 'button_sell'.tr();
      case OrderType.AmendBuy:
        return 'button_amend_buy'.tr();
      case OrderType.AmendSell:
        return 'button_amend_sell'.tr();
      default:
        return '#unkown_button';
    }
  }

  Color get color {
    switch (this) {
      case OrderType.Buy:
        return InvestrendTheme.buyColor;
      case OrderType.Sell:
        return InvestrendTheme.sellColor;
      case OrderType.AmendBuy:
        return InvestrendTheme.buyColor;
      case OrderType.AmendSell:
        return InvestrendTheme.sellColor;
      default:
        return Colors.orangeAccent;
    }
  }

  Color get colorDisabled {
    switch (this) {
      case OrderType.Buy:
        return InvestrendTheme.buyColor.withOpacity(0.3);
      case OrderType.Sell:
        return InvestrendTheme.sellColor.withOpacity(0.3);
      case OrderType.AmendBuy:
        return InvestrendTheme.buyColor.withOpacity(0.3);
      case OrderType.AmendSell:
        return InvestrendTheme.sellColor.withOpacity(0.3);
      default:
        return Colors.orangeAccent.withOpacity(0.7);
    }
  }
}

class ButtonOrder extends StatelessWidget {
  final String label;

  // static final int TYPE_BUY = 0;
  // static final int TYPE_SELL = 1;
  final OrderType orderType;
  final VoidCallback onPressed;

  ButtonOrder(
    this.orderType,
    this.onPressed, {
    Key key,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //bool isBuy = orderType == OrderType.Buy;
    Color color = orderType.isBuyOrAmendBuy()
        ? Theme.of(context).colorScheme.secondary
        : InvestrendTheme.sellColor;
    Color borderColor = orderType.isBuyOrAmendBuy()
        ? Theme.of(context).colorScheme.secondary
        : InvestrendTheme.sellColor;
    Color textColor = InvestrendTheme.of(context).textWhite;
    String text;
    if (label == null) {
      text = orderType.textButton;
      /*
      if(orderType == OrderType.Buy){
          text = 'button_buy'.tr();
      }else if(orderType == OrderType.Sell){
        text = 'button_sell'.tr();
      }else{
        text = '???';
      }
      */
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: MaterialButton(
          padding:
              EdgeInsets.only(left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
          elevation: 0,
          highlightElevation: 0,
          focusElevation: 0,

          //color: Theme.of(context).accentColor,
          //disabledColor: Theme.of(context).disabledColor,
          disabledColor: orderType.colorDisabled,
          disabledTextColor: textColor,
          color: color,
          //textColor: Theme.of(context).primaryColor,
          textColor: textColor,
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: textColor)),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(16.0),
            side: BorderSide(
              //color: onPressed != null ? borderColor : Theme.of(context).disabledColor,
              color: onPressed != null ? borderColor : Colors.transparent,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class ButtonOrderOutlined extends StatelessWidget {
  final String label;

  // static final int TYPE_BUY = 0;
  // static final int TYPE_SELL = 1;
  final OrderType orderType;
  final VoidCallback onPressed;

  ButtonOrderOutlined(
    this.orderType,
    this.onPressed, {
    Key key,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //bool isBuy = orderType == OrderType.Buy;
    Color color = orderType.isBuyOrAmendBuy()
        ? Theme.of(context).colorScheme.secondary
        : InvestrendTheme.sellColor;
    Color borderColor = orderType.isBuyOrAmendBuy()
        ? Theme.of(context).colorScheme.secondary
        : InvestrendTheme.sellColor;
    Color textColor = InvestrendTheme.of(context).textWhite;
    String text;
    if (label == null) {
      text = orderType.textButton;
      /*
      if(orderType == OrderType.Buy){
          text = 'button_buy'.tr();
      }else if(orderType == OrderType.Sell){
        text = 'button_sell'.tr();
      }else{
        text = '???';
      }
      */
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: MaterialButton(
          padding:
              EdgeInsets.only(left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
          elevation: 0,
          highlightElevation: 0,
          focusElevation: 0,

          //color: Theme.of(context).accentColor,
          //disabledColor: Theme.of(context).disabledColor,
          disabledColor: orderType.colorDisabled,
          disabledTextColor: textColor,
          color: textColor,
          //textColor: Theme.of(context).primaryColor,
          textColor: color,
          //child: Text(text, style: Theme.of(context).textTheme.button.copyWith(color: textColor)),
          child: Text(text,
              style: Theme.of(context).textTheme.button.copyWith(color: color)),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(16.0),
            side: BorderSide(
              //color: onPressed != null ? borderColor : Theme.of(context).disabledColor,
              color: onPressed != null ? borderColor : Colors.transparent,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class ButtonCancel extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  ButtonCancel(
    this.onPressed, {
    Key key,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //bool isBuy = orderType == OrderType.Buy;
    Color color = InvestrendTheme.cancelColor;
    Color borderColor = InvestrendTheme.cancelColor;
    Color textColor = Theme.of(context).primaryColor;
    String text;
    if (label == null) {
      text = 'button_cancel'.tr();
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: MaterialButton(
          padding:
              EdgeInsets.only(left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
          elevation: 0,
          highlightElevation: 0,
          focusElevation: 0,

          //color: Theme.of(context).accentColor,
          //disabledColor: Theme.of(context).disabledColor,
          disabledColor: Theme.of(context).disabledColor,
          disabledTextColor: textColor,
          color: color,
          //textColor: Theme.of(context).primaryColor,
          textColor: textColor,
          child: Text(text,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: textColor)),

          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(16.0),
            side: BorderSide(
              //color: onPressed != null ? borderColor : Theme.of(context).disabledColor,
              color: onPressed != null ? borderColor : Colors.transparent,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
