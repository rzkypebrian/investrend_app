import 'package:Investrend/utils/investrend_theme.dart';
// import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TilePriceTwo extends StatelessWidget {
  final String? codeText;
  final String priceText;
  final String changeText;
  final String percentChangeText;
  final Color? priceColor;
  final Color percentChangeBackgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? paddingChange;
  final double width;
  final double? height;
  final VoidCallback? onPressed;
  final TextStyle? codeStyle;
  final TextStyle? percentStyle;
  final TextStyle? priceStyle;
  const TilePriceTwo(
      {Key? key,
      this.codeStyle,
      this.percentStyle,
      this.priceStyle,
      this.onPressed,
      this.codeText = '-',
      this.changeText = '-',
      this.priceText = '-',
      this.percentChangeText = '-',
      this.priceColor/*=Colors.white*/,
      this.percentChangeBackgroundColor = Colors.purple,
      this.padding,
      this.paddingChange,
      this.width = 100,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? width,
      child: MaterialButton(
        height: 64.0,
        elevation: 0.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        padding: padding ??
            EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 48.0,
                // color: Colors.purple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    /*
                    AutoSizeText(
                      codeText,
                      minFontSize: 8.0,
                      style: codeStyle ?? InvestrendTheme.of(context).small_w600_compact,
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      priceText,
                      minFontSize: 8.0,
                      style: priceStyle ?? InvestrendTheme.of(context).more_support_w600_compact.copyWith(fontSize: 12.0, color: priceColor),
                      maxLines: 1,
                    ),
                    */
                    Text(
                      codeText!,
                      style: codeStyle ??
                          InvestrendTheme.of(context).small_w600_compact,
                      maxLines: 1,
                    ),
                    Text(
                      priceText,
                      style: priceStyle ??
                          InvestrendTheme.of(context)
                              .more_support_w600_compact
                              ?.copyWith(
                                  fontSize: 12.0,
                                  color: priceColor ??
                                      InvestrendTheme.of(context).textWhite),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 48.0,
                //color: percentChangeBackgroundColor,
                margin: EdgeInsets.only(left: 8.0),
                padding: paddingChange ??
                    EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                decoration: BoxDecoration(
                  color: percentChangeBackgroundColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                //constraints: BoxConstraints.expand(width: 100, height: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      changeText,
                      style: percentStyle ??
                          InvestrendTheme.of(context)
                              .more_support_w600_compact
                              ?.copyWith(fontSize: 12.0, color: priceColor),
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      percentChangeText,
                      style: percentStyle ??
                          InvestrendTheme.of(context)
                              .more_support_w600_compact
                              ?.copyWith(fontSize: 12.0, color: priceColor),
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),

                    /*
                    AutoSizeText(
                      changeText,
                      minFontSize: 8.0,
                      style: percentStyle ?? InvestrendTheme.of(context).more_support_w600_compact.copyWith(fontSize: 12.0, color: priceColor),
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                    AutoSizeText(
                      percentChangeText,
                      minFontSize: 8.0,
                      style: percentStyle ?? InvestrendTheme.of(context).more_support_w600_compact.copyWith(fontSize: 12.0, color: priceColor),
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                    */
                  ],
                ),
              ),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }
}

class TilePriceThree extends StatelessWidget {
  final String? codeText;
  final String priceText;
  final String percentChangeText;
  final Color? priceColor;
  final Color percentChangeBackgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? paddingPercent;
  final double width;
  final double? height;
  final VoidCallback? onPressed;
  final TextStyle? codeStyle;
  final TextStyle? percentStyle;
  final TextStyle? priceStyle;
  TilePriceThree(
      {Key? key,
      this.codeStyle,
      this.percentStyle,
      this.priceStyle,
      this.onPressed,
      this.codeText = '-',
      this.priceText = '-',
      this.percentChangeText = '-',
      this.priceColor/*= Colors.white*/,
      this.percentChangeBackgroundColor = Colors.purple,
      this.padding,
      this.paddingPercent,
      this.width = 100,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? width,
      child: MaterialButton(
        elevation: 0.0,
        minWidth: 50.0,
        splashColor: InvestrendTheme.of(context).tileSplashColor,
        //padding: EdgeInsets.only(left: padding, right: padding, top: padding, bottom: padding),
        padding: padding ?? EdgeInsets.all(8.0),
        color: InvestrendTheme.of(context).tileBackground,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(
            color: InvestrendTheme.of(context).tileBackground!,
            width: 0.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*
            AutoSizeText(
              codeText,
              minFontSize: 8.0,
              style: codeStyle ?? InvestrendTheme.of(context).small_w600_compact,
              maxLines: 1,
            ),

            AutoSizeText(
              priceText, //InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
              minFontSize: 8.0,
              style: priceStyle ?? InvestrendTheme.of(context).more_support_w600_compact.copyWith(fontSize: 12.0, color: priceColor),
              maxLines: 1,
            ),
            */
            Text(
              codeText!,
              style:
                  codeStyle ?? InvestrendTheme.of(context).small_w600_compact,
              maxLines: 1,
            ),
            Text(
              priceText, //InvestrendTheme.formatPriceDouble(data.price, showDecimal: false),
              style: priceStyle ??
                  InvestrendTheme.of(context)
                      .more_support_w600_compact
                      ?.copyWith(
                          fontSize: 12.0,
                          color: priceColor ??
                              InvestrendTheme.of(context).textWhite),
              maxLines: 1,
            ),
            Container(
              padding: paddingPercent ??
                  EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
              decoration: BoxDecoration(
                color: percentChangeBackgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              /*
              child: AutoSizeText(
                percentChangeText,
                minFontSize: 8.0,
                style: percentStyle ?? InvestrendTheme.of(context).more_support_w600_compact.copyWith(fontSize: 12.0, color: priceColor),
                maxLines: 1,
              ),
              */
              child: Text(
                percentChangeText,
                style: percentStyle ??
                    InvestrendTheme.of(context)
                        .more_support_w600_compact
                        ?.copyWith(fontSize: 12.0, color: priceColor),
                maxLines: 1,
              ),
            ),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
