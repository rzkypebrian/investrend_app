import 'dart:math';

import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/tile_price.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';

class GridPriceTwo extends StatelessWidget {
  final double marginTile;
  final int gridCount;
  final double ratioHeight;
  final List? listData;
  final bool showDecimalPrice;
  final StringCallback? onSelected;
  const GridPriceTwo(this.listData,
      {this.onSelected,
      Key? key,
      this.gridCount = 2,
      this.marginTile = 5.0,
      this.ratioHeight = 0.0,
      this.showDecimalPrice = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      //print('GridPriceTwo.constrains ' + constrains.maxWidth.toString());
      //const int gridCount = 3;
      double availableWidth =
          constrains.maxWidth - (marginTile * (gridCount - 1));
      //print('GridPriceTwo.availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      double? tileHeight;
      bool useRatioHeight = ratioHeight > 0.0;
      if (useRatioHeight) {
        tileHeight = tileWidth * ratioHeight;
      }
      //double tileHeight = tileWidth * 0.8;
      //print('GridPriceTwo.tileWidth $tileWidth  tileHeight : $tileHeight');

      int countData = listData != null ? listData!.length : 0;
      if (countData == 0) {
        return SizedBox(
          width: availableWidth,
          height: useRatioHeight ? tileHeight : tileWidth,
          child: Center(
            child: EmptyLabel(),
          ),
        );
      }

      EdgeInsets padding =
          EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0);
      EdgeInsets paddingChange =
          EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0);
      TextStyle? codeStyle = InvestrendTheme.of(context).small_w600_compact;
      //TextStyle priceStyle    = InvestrendTheme.of(context).more_support_w600_compact.copyWith(fontSize: 12.0);
      TextStyle? priceStyle = InvestrendTheme.of(context).support_w600_compact;
      TextStyle? percentStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);

      /* ASLI 2021-09-29
      double availableWidthForCode    = ((tileWidth - padding.left - padding.right) / 5) * 3;
      double availableWidthForPercent = (((tileWidth - padding.left - padding.right) / 5) * 2) - paddingChange.left - paddingChange.right;
      */
      double availableWidthForCode =
          ((tileWidth - padding.left - padding.right) / 4) * 2;
      double availableWidthForPercent =
          (((tileWidth - padding.left - padding.right) / 4) * 2) -
              paddingChange.left -
              paddingChange.right;

      for (int i = 0; i < countData; i++) {
        CodePriceChangePercent? data = listData?.elementAt(i);
        if (data != null) {
          String? codeText = data.code;
          String priceText = InvestrendTheme.formatPriceDouble(data.price,
              showDecimal: showDecimalPrice);
          String changeText = InvestrendTheme.formatChange(data.change);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          codeStyle =
              useFontSize(context, codeStyle, availableWidthForCode, codeText);
          priceStyle = useFontSize(
              context, priceStyle, availableWidthForCode, priceText);
          percentStyle = useFontSize(
              context, percentStyle, availableWidthForPercent, changeText);
          percentStyle = useFontSize(
              context, percentStyle, availableWidthForPercent, percentText);
        }
      }
      if (useRatioHeight) {
        double heightContentLeft = UIHelper.textSize('Pj', codeStyle).height;
        heightContentLeft += UIHelper.textSize('Pj', priceStyle).height;
        heightContentLeft += padding.top + padding.bottom;

        double heightContentRight =
            UIHelper.textSize('Pj', percentStyle).height;
        heightContentRight += UIHelper.textSize('Pj', percentStyle).height;
        heightContentRight += padding.top + padding.bottom;
        heightContentRight += paddingChange.top + paddingChange.bottom;

        double heightContent = max(heightContentLeft, heightContentRight);
        tileHeight = max(heightContent, tileHeight!);
      }

      List<Widget> cols = List<Widget>.empty(growable: true);
      List<Widget> rows = List<Widget>.empty(growable: true);

      for (int i = 0; i < countData; i++) {
        CodePriceChangePercent? data = listData?.elementAt(i);
        if (data != null) {
          String? codeText = data.code;
          String priceText = InvestrendTheme.formatPriceDouble(data.price,
              showDecimal: showDecimalPrice);
          String changeText = InvestrendTheme.formatChange(data.change);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          Color percentChangeTextColor =
              InvestrendTheme.changeTextColor(data.percentChange);
          Color percentChangeBackgroundColor =
              InvestrendTheme.priceBackgroundColorDouble(data.percentChange);

          rows.add(TilePriceTwo(
            width: tileWidth,
            height: tileHeight!,
            codeText: codeText,
            priceText: priceText,
            changeText: changeText,
            percentChangeText: percentText,
            priceColor: percentChangeTextColor,
            percentChangeBackgroundColor: percentChangeBackgroundColor,
            priceStyle: priceStyle?.copyWith(color: percentChangeTextColor),
            padding: padding,
            paddingChange: paddingChange,
            codeStyle: codeStyle,
            percentStyle: percentStyle?.copyWith(color: percentChangeTextColor),
            onPressed: () {
              if (onSelected != null) {
                onSelected!(codeText);
              }
            },
          ));
          if (rows.length >= gridCount) {
            cols.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rows,
            ));
            cols.add(SizedBox(
              height: marginTile,
            ));
            rows = List<Widget>.empty(growable: true);
          }
        }
      }
      if (rows.isNotEmpty) {
        int gap = gridCount - rows.length;
        for (int x = 0; x < gap; x++) {
          rows.add(SizedBox(
            width: tileWidth,
          ));
        }
        cols.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rows,
        ));
      }
      return Column(
        children: cols,
      );
    });
  }

  TextStyle? useFontSize(
      BuildContext context, TextStyle? style, double width, String? text,
      {int tried = 1}) {
    //print('GridPriceThree.useFontSize  try fontSize  : '+style.fontSize.toString()+'  width : $width  text : $text  ');
    const double font_step = 1.5;

    double widthText = UIHelper.textSize(text, style).width;
    bool reduceFont = widthText > width;
    if (reduceFont) {
      style = style?.copyWith(fontSize: style.fontSize! - font_step);
      return useFontSize(context, style, width, text, tried: tried++);
    } else {
      //print('GridPriceThree.useFontSize Final fontSize  : '+style.fontSize.toString()+'  text : $text  tried : $tried');
      return style;
    }
  }
}

class GridPriceThree extends StatelessWidget {
  final double marginTile;
  final int gridCount;
  final double ratioHeight;
  final List? listData;
  final bool showDecimalPrice;
  final StringCallback? onSelected;
  final String? emptyMessage;
  final TextStyle? stylePrice;
  const GridPriceThree(this.listData,
      {this.stylePrice,
      this.onSelected,
      Key? key,
      this.gridCount = 2,
      this.marginTile = 5.0,
      this.ratioHeight = 0.0,
      this.showDecimalPrice = true,
      this.emptyMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      print('constrains ' + constrains.maxWidth.toString());
      //const int gridCount = 3;
      double availableWidth =
          constrains.maxWidth - (marginTile * (gridCount - 1));
      print('availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      double? tileHeight;
      bool useRatioHeight = ratioHeight > 0.0;
      if (useRatioHeight) {
        tileHeight = tileWidth * ratioHeight;
      }
      //double tileHeight = tileWidth * 0.8;
      print('tileWidth $tileWidth');

      int countData = listData != null ? listData!.length : 0;
      if (countData == 0) {
        return SizedBox(
          width: availableWidth,
          height: useRatioHeight ? tileHeight : tileWidth,
          child: Center(
            child: EmptyLabel(
              text: emptyMessage,
            ),
          ),
        );
      }

      EdgeInsets padding =
          EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0, bottom: 8.0);
      EdgeInsets paddingPercent =
          EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 4.0);
      TextStyle? codeStyle = InvestrendTheme.of(context).small_w600_compact;
      TextStyle? priceStyle =
          stylePrice ?? InvestrendTheme.of(context).support_w600_compact;
      TextStyle? percentStyle = InvestrendTheme.of(context)
          .more_support_w600_compact
          ?.copyWith(fontSize: 12.0);
      double availableWidthForCode = tileWidth - padding.left - padding.right;
      double availableWidthForPercent = tileWidth -
          padding.left -
          padding.right -
          paddingPercent.left -
          paddingPercent.right;

      for (int i = 0; i < countData; i++) {
        CodePricePercent? data = listData?.elementAt(i);
        if (data != null) {
          String? codeText = data.code;
          String priceText = InvestrendTheme.formatPriceDouble(data.price,
              showDecimal: showDecimalPrice);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          codeStyle =
              useFontSize(context, codeStyle, availableWidthForCode, codeText);
          priceStyle = useFontSize(
              context, priceStyle, availableWidthForCode, priceText);
          percentStyle = useFontSize(
              context, percentStyle, availableWidthForPercent, percentText);
        }
      }
      if (useRatioHeight) {
        double heightContent = UIHelper.textSize('Pj', codeStyle).height;
        heightContent += UIHelper.textSize('Pj', priceStyle).height;
        heightContent += UIHelper.textSize('Pj', percentStyle).height;
        heightContent += padding.top + padding.bottom;
        heightContent += paddingPercent.top + paddingPercent.bottom;

        tileHeight = max(heightContent, tileHeight!);
      }

      List<Widget> cols = List<Widget>.empty(growable: true);
      List<Widget> rows = List<Widget>.empty(growable: true);

      for (int i = 0; i < countData; i++) {
        CodePricePercent? data = listData?.elementAt(i);
        if (data != null) {
          if (rows.length >= gridCount) {
            cols.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rows,
            ));
            cols.add(SizedBox(
              height: marginTile,
            ));
            rows = List<Widget>.empty(growable: true);
          }

          String? codeText = data.code;
          String priceText = InvestrendTheme.formatPriceDouble(data.price,
              showDecimal: showDecimalPrice);
          String percentText =
              InvestrendTheme.formatPercentChange(data.percentChange);
          Color percentChangeTextColor =
              InvestrendTheme.changeTextColor(data.percentChange);
          Color percentChangeBackgroundColor =
              InvestrendTheme.priceBackgroundColorDouble(data.percentChange);

          rows.add(TilePriceThree(
            width: tileWidth,
            height: tileHeight,
            codeText: codeText,
            priceText: priceText,
            percentChangeText: percentText,
            priceColor: percentChangeTextColor,
            percentChangeBackgroundColor: percentChangeBackgroundColor,
            priceStyle: priceStyle?.copyWith(color: percentChangeTextColor),
            padding: padding,
            paddingPercent: paddingPercent,
            codeStyle: codeStyle,
            percentStyle: percentStyle?.copyWith(color: percentChangeTextColor),
            onPressed: () {
              if (onSelected != null) {
                onSelected!(codeText);
              }
            },
          ));
        }
      }
      if (rows.isNotEmpty) {
        int gap = gridCount - rows.length;
        for (int x = 0; x < gap; x++) {
          rows.add(SizedBox(
            width: tileWidth,
          ));
        }
        cols.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rows,
        ));
      }
      return Column(
        children: cols,
      );
    });
  }

  TextStyle? useFontSize(
      BuildContext context, TextStyle? style, double width, String? text,
      {int tried = 1}) {
    //print('GridPriceThree.useFontSize  try fontSize  : '+style.fontSize.toString()+'  width : $width  text : $text  ');
    const double font_step = 1.5;

    double widthText = UIHelper.textSize(text, style).width;
    bool reduceFont = widthText > width;
    if (reduceFont) {
      style = style?.copyWith(fontSize: style.fontSize! - font_step);
      return useFontSize(context, style, width, text, tried: tried++);
    } else {
      //print('GridPriceThree.useFontSize Final fontSize  : '+style.fontSize.toString()+'  text : $text  tried : $tried');
      return style;
    }
  }
}
