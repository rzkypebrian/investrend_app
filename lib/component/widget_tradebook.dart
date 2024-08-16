// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class WidgetTradebook extends StatefulWidget {
  //final TradeBookNotifier  _tradeBookNotifier;
  final int maxShowLine;
  //final bool showMore;
  final ValueNotifier<bool>? showMoreNotifier;
  const WidgetTradebook(
      /*this._tradeBookNotifier,*/ {this.showMoreNotifier,
      this.maxShowLine = 0,
      Key? key})
      : super(key: key);

  @override
  State<WidgetTradebook> createState() => _WidgetTradebookState();
}

class _WidgetTradebookState extends State<WidgetTradebook> {
  bool showMore = true;
  bool hasMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.showMoreNotifier != null) {
      this.showMore = widget.showMoreNotifier!.value;
      widget.showMoreNotifier?.addListener(() {
        this.showMore = widget.showMoreNotifier!.value;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if(widget.showMoreNotifier != null){
    //   return ValueListenableBuilder<bool>(
    //       valueListenable: widget.showMoreNotifier,
    //       builder: (context, value, child) {
    //         return getTableDataTradebook(context);
    //       });
    // }

    return getTableDataTradebook(context);
  }

  Widget getTableDataTradebook(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final notifier = watch(tradeBookChangeNotifier);
      // if (notifier.invalid()) {
      //   return Center(child: CircularProgressIndicator());
      // }
      if (!notifier.isLoaded()) {
        if (notifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
      }
      const padding = 10.0;
      List<TableRow> list = List.empty(growable: true);

      TableRow header = TableRow(children: [
        ComponentCreator.tableCellLeftHeader(context, 'Price',
            padding: InvestrendTheme.cardPaddingGeneral),
        ComponentCreator.tableCellCenterHeader(context, 'Lot'),
        ComponentCreator.tableCellCenterHeader(context, 'Buy Lot'),
        ComponentCreator.tableCellCenterHeader(context, 'Sell Lot',
            padding: InvestrendTheme.cardPaddingGeneral),
      ]);
      list.add(header);

      if (notifier.tradebook!.countRows() == 0 && widget.maxShowLine > 0) {
        double fontHeight =
            UIHelper.textSize('AjKg', InvestrendTheme.of(context).small_w400)
                .height;
        double rowHeight = fontHeight + 5.0 + 5.0;
        return Column(
          children: [
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              //border: TableBorder.all(color: Colors.black),
              columnWidths: {
                0: FractionColumnWidth(.25),
                1: FractionColumnWidth(.25),
                2: FractionColumnWidth(.25),
                3: FractionColumnWidth(.25),
              },
              children: list,
            ),
            Container(
              width: double.maxFinite,
              height: rowHeight * widget.maxShowLine,
              child: Center(child: EmptyLabel()),
            )
          ],
        );
      } else {
        StockSummary? stockSummary =
            context.read(stockSummaryChangeNotifier).summary;
        int? prev = stockSummary != null && stockSummary.prev != null
            ? stockSummary.prev
            : 0;
        int? close = stockSummary != null && stockSummary.close != null
            ? stockSummary.close
            : 0;
        /*
      StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
      int prev = _summaryNotifier != null && _summaryNotifier.value != null ? _summaryNotifier.value.prev : 0;
      */

        // notifier.tradebook.listTradeBookRows.length

        int countMax = notifier.tradebook!.countRows();

        if (widget.maxShowLine > 0) {
          hasMore = widget.maxShowLine < countMax;
          if (showMore) {
            countMax = min(widget.maxShowLine, countMax);
          } else {
            countMax = countMax;
          }
        }

        //for (int index = 0; index < notifier.tradebook.countRows(); index++) {
        for (int index = 0; index < countMax; index++) {
          TradeBookRow tr =
              notifier.tradebook!.listTradeBookRows!.elementAt(index);
          bool highlightPrice = close == tr.price;
          int lot = tr.volume ~/ 100;
          int buyerLot = tr.buyerVolume ~/ 100;
          int sellerLot = tr.sellerVolume ~/ 100;
          bool odd = index % 2 != 0;
          TableRow row;
          if (odd) {
            row = TableRow(
                decoration: BoxDecoration(
                  color: InvestrendTheme.of(context).oddColor,
                ),
                children: [
                  createLabelLeft(
                      context, InvestrendTheme.formatPrice(tr.price),
                      color:
                          InvestrendTheme.priceTextColor(tr.price, prev: prev!),
                      padding: InvestrendTheme.cardPaddingGeneral,
                      highlightPrice: highlightPrice),
                  createLabelCenter(context, InvestrendTheme.formatPrice(lot)),
                  createLabelCenter(
                      context, InvestrendTheme.formatPrice(buyerLot)),
                  createLabelCenter(
                      context, InvestrendTheme.formatPrice(sellerLot),
                      padding: InvestrendTheme.cardPaddingGeneral),
                ]);
          } else {
            row = TableRow(children: [
              createLabelLeft(context, InvestrendTheme.formatPrice(tr.price),
                  color: InvestrendTheme.priceTextColor(tr.price, prev: prev!),
                  padding: InvestrendTheme.cardPaddingGeneral,
                  highlightPrice: highlightPrice),
              createLabelCenter(context, InvestrendTheme.formatPrice(lot)),
              createLabelCenter(context, InvestrendTheme.formatPrice(buyerLot)),
              createLabelCenter(context, InvestrendTheme.formatPrice(sellerLot),
                  padding: InvestrendTheme.cardPaddingGeneral),
            ]);
          }
          // TableRow row = TableRow(
          //     children: [
          //   createLabelLeft(context, InvestrendTheme.formatPrice(tr.price), color: InvestrendTheme.priceTextColor(tr.price, prev: prev)),
          //   createLabelCenter(context, InvestrendTheme.formatPrice(lot)),
          //   createLabelCenter(context, InvestrendTheme.formatPrice(buyerLot)),
          //   createLabelCenter(context, InvestrendTheme.formatPrice(sellerLot)),
          //
          // ]);
          list.add(row);
        }

        if (hasMore) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                //border: TableBorder.all(color: Colors.black),
                columnWidths: {
                  0: FractionColumnWidth(.25),
                  1: FractionColumnWidth(.25),
                  2: FractionColumnWidth(.25),
                  3: FractionColumnWidth(.25),
                },
                children: list,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: InvestrendTheme.cardPaddingGeneral,
                    right: InvestrendTheme.cardPaddingGeneral),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // setState(() {
                      //   showMore = !showMore;
                      // });
                      widget.showMoreNotifier!.value =
                          !widget.showMoreNotifier!.value;
                    },
                    child: Text(
                      showMore
                          ? "button_show_more".tr()
                          : "button_show_less".tr(),
                      textAlign: TextAlign.end,
                      style: InvestrendTheme.of(context).small_w600?.copyWith(
                          color: InvestrendTheme.of(context)
                              .investrendPurple /*, fontWeight: FontWeight.bold*/),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      }

      return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        //border: TableBorder.all(color: Colors.black),
        columnWidths: {
          0: FractionColumnWidth(.25),
          1: FractionColumnWidth(.25),
          2: FractionColumnWidth(.25),
          3: FractionColumnWidth(.25),
        },
        children: list,
      );
    });
    /*
    return ValueListenableBuilder(
      valueListenable: _tradeBookNotifier,
      builder: (context, TradeBook value, child) {
        if (_tradeBookNotifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }


        //return Text(value.listTradeBookRows.length.toString());

        const padding = 10.0;
        List<TableRow> list = List.empty(growable: true);

        TableRow header = TableRow(children: [
          ComponentCreator.tableCellLeftHeader(context, 'Price'),
          ComponentCreator.tableCellCenterHeader(context, 'Lot'),
          ComponentCreator.tableCellCenterHeader(context, 'Buy Lot'),
          ComponentCreator.tableCellCenterHeader(context, 'Sell Lot'),

        ]);
        list.add(header);


        StockSummary stockSummary = context.read(stockSummaryChangeNotifier).summary;
        int prev = stockSummary != null && stockSummary.prev != null ? stockSummary.prev : 0;

        // StockSummaryNotifier _summaryNotifier = InvestrendTheme.of(context).summaryNotifier;
        // int prev = _summaryNotifier != null && _summaryNotifier.value != null ? _summaryNotifier.value.prev : 0;


        for (int index = 0; index < value.listTradeBookRows.length; index++) {
          TradeBookRow tr = value.listTradeBookRows.elementAt(index);
          int lot = tr.volume ~/ 100;
          int buyerLot = tr.buyerVolume ~/ 100;
          int sellerLot = tr.sellerVolume ~/ 100;

          TableRow row = TableRow(children: [
            createLabelLeft(context, InvestrendTheme.formatPrice(tr.price), color: InvestrendTheme.priceTextColor(tr.price, prev: prev)),
            createLabelCenter(context, InvestrendTheme.formatPrice(lot)),
            createLabelCenter(context, InvestrendTheme.formatPrice(buyerLot)),
            createLabelCenter(context, InvestrendTheme.formatPrice(sellerLot)),

          ]);
          list.add(row);
        }

        // TableRow total = TableRow(children: [
        //   SizedBox(width: 1),
        //   ComponentCreator.tableCellLeftHeader(context, InvestrendTheme.formatComma(totalVolumeShowedBid)),
        //   ComponentCreator.tableCellRightHeader(context, 'Total', padding: padding),
        //   ComponentCreator.tableCellLeftHeader(context, 'Total', padding: padding),
        //   ComponentCreator.tableCellRightHeader(context, InvestrendTheme.formatComma(totalVolumeShowedOffer)),
        //   SizedBox(width: 1),
        // ]);
        // list.add(total);

        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          //border: TableBorder.all(color: Colors.black),
          columnWidths: {
            0: FractionColumnWidth(.25),
            1: FractionColumnWidth(.25),
            2: FractionColumnWidth(.25),
            3: FractionColumnWidth(.25),
          },
          children: list,
        );
      },
    );

     */
  }

  Widget createLabelLeft(BuildContext context, String text,
      {double padding = 0.0, Color? color, bool highlightPrice = false}) {
    if (color == null) {
      color = InvestrendTheme.of(context).greyDarkerTextColor;
    }
    TextStyle? style;
    if (highlightPrice) {
      text = ' $text ';
      style = InvestrendTheme.of(context).small_w400?.copyWith(
          color: Theme.of(context).primaryColor, backgroundColor: color);
    } else {
      style = InvestrendTheme.of(context).small_w400?.copyWith(color: color);
    }
    return Padding(
      padding: EdgeInsets.only(left: padding, top: 5.0, bottom: 5.0),
      child: Text(
        text,
        maxLines: 1,
        style: style,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget createLabelCenter(BuildContext context, String text,
      {double padding = 0.0, Color? color}) {
    if (color == null) {
      color = InvestrendTheme.of(context).greyDarkerTextColor;
    }
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: Text(
        text,
        maxLines: 1,
        style: InvestrendTheme.of(context).small_w400?.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
