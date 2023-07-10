import 'dart:async';
import 'dart:math';

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomSheetRelatedStock extends StatefulWidget {
  final ChangeNotifier onDoUpdate;

  BottomSheetRelatedStock(this.onDoUpdate);

  @override
  _BottomSheetRelatedStockState createState() =>
      _BottomSheetRelatedStockState();
}

class _BottomSheetRelatedStockState extends State<BottomSheetRelatedStock> {
  List<StockSummary> summarys = List.empty(growable: true);
  List<Stock> relatedStocks = List.empty(growable: true);

  ValueNotifier<bool> priceNotifier = ValueNotifier<bool>(false);
  String codes = '';
  @override
  void initState() {
    super.initState();
    widget.onDoUpdate?.addListener(doUpdate);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdate();
    });
  }

  VoidCallback stockChangeListener;

  @override
  void dispose() {
    widget.onDoUpdate?.removeListener(doUpdate);

    final container = ProviderContainer();
    container
        .read(primaryStockChangeNotifier)
        .removeListener(stockChangeListener);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (stockChangeListener != null) {
      context
          .read(primaryStockChangeNotifier)
          .removeListener(stockChangeListener);
    }

    constructRelatedStocks(context);
    stockChangeListener = () {
      if (!mounted) {
        print(routeName +
            '.stockChangeListener aborted, caused by widget mounted : ' +
            mounted.toString());
        return;
      }
      constructRelatedStocks(context);
      setState(() {});
      //doUpdate(pullToRefresh: true);
    };
    context.read(primaryStockChangeNotifier).addListener(stockChangeListener);
  }

  List<Stock> getRelatedStock(String forCode) {
    List<Stock> relatedStocks = List.empty(growable: true);
    String mainCode = forCode;
    int index = forCode.indexOf('-');
    if (index > 0) {
      mainCode = forCode.substring(0, index);
      print('getRelatedStock mainCode = $mainCode  from stock.code = ' +
          forCode);
    }
    relatedStocks.clear();

    for (var value in InvestrendTheme.storedData.listStock) {
      if (value != null &&
          value is Stock &&
          value.code.toLowerCase().startsWith(mainCode.toLowerCase())) {
        relatedStocks.add(value);
      }
    }
    return relatedStocks;
  }

  void constructRelatedStocks(BuildContext context) {
    String newCode = context.read(primaryStockChangeNotifier).stock.code;

    String mainCode = newCode;
    int index = newCode.indexOf('-');
    if (index > 0) {
      mainCode = newCode.substring(0, index);
      print('mainCode = $mainCode  from stock.code = ' + newCode);
    }
    relatedStocks.clear();
    String newCodes = '';
    for (var value in InvestrendTheme.storedData.listStock) {
      if (value != null &&
          value is Stock &&
          value.code.toLowerCase().startsWith(mainCode.toLowerCase())) {
        relatedStocks.add(value);
        if (newCodes.isEmpty) {
          newCodes = value.code;
        } else {
          newCodes = newCodes + "_" + value.code;
        }
      }
    }

    if (!StringUtils.equalsIgnoreCase(newCodes, codes)) {
      summarys.clear();
    }
    codes = newCodes;
    // InvestrendTheme.storedData.listStock.forEach((value) {
    //   if (value != null && value is Stock && value.code.toLowerCase().startsWith(mainCode.toLowerCase())) {
    //     relatedStocks.add(value);
    //   }
    // });
  }

  final String routeName = '/BottomSheetRelatedStock';
  void doUpdate() async {
    try {
      print(routeName + ' try Summarys');
      if (!StringUtils.isEmtpy(codes)) {
        final stockSummarys = await InvestrendTheme.datafeedHttp
            .fetchStockSummaryMultiple(codes, 'RG');
        if (stockSummarys != null && stockSummarys.isNotEmpty) {
          for (var newValue in stockSummarys) {
            bool updated = false;
            for (var existing in summarys) {
              if (StringUtils.equalsIgnoreCase(existing.code, newValue.code)) {
                existing.copyValueFrom(newValue);
                updated = true;
              }
            }
            if (!updated) {
              updated = true;
              summarys.add(newValue);
            }
            print("updated : $updated  --> " + newValue.toString());
          }
          /*
          summarys.clear();
          if(stockSummarys != null){
            summarys.addAll(stockSummarys);
          }
          */
          priceNotifier.value = !priceNotifier.value;
          //_watchlistDataNotifier.updateBySummarys(stockSummarys);
        } else {
          print(routeName + ' Future Summarys NO DATA');
        }
      }
    } catch (e) {
      print(routeName + ' Summarys Exception : ' + e.toString());
      print(e);
    }
  }

  StockSummary getSummary(String code) {
    StockSummary result;
    for (var summary in summarys) {
      if (summary != null && StringUtils.equalsIgnoreCase(code, summary.code)) {
        result = summary;

        break;
      }
    }
    if (result != null) {
      print('getSummary $code found : ' + result.close.toString());
    } else {
      print('getSummary $code NOT found');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    /*
    double padding = 24.0;
    final notifier = context.read(primaryStockChangeNotifier);
    Stock stock = notifier.stock;
    List<Widget> childs = List.empty(growable: true);
    if(stock != null && stock.code != null){
      String mainCode = '';
      int index = stock.code.indexOf('-');
      if(index > 0){
        mainCode = stock.code.substring(0, index);
        print('mainCode = $mainCode  from stock.code = '+stock.code);
      }else{
        mainCode = stock.code;
      }


      InvestrendTheme.storedData.listStock.forEach((value) {
        if(value != null && value is Stock && value.code.toLowerCase().startsWith(mainCode.toLowerCase())){

          bool selected = StringUtils.equalsIgnoreCase(stock.code, value.code);
          TextStyle titleStyle = InvestrendTheme.of(context).regular_w600_compact;
          Color color =  selected ? Theme.of(context).accentColor : titleStyle.color;
          Color colorPrice =  selected ? Theme.of(context).accentColor : InvestrendTheme.of(context).greyDarkerTextColor;
          childs.add(ListTile(
            onTap: (){
              context.read(primaryStockChangeNotifier).setStock(value);
            },
            //visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: padding, right: padding),
            title: Text(value.code, style: InvestrendTheme.of(context).regular_w600.copyWith(color:color ),),
            subtitle: Text('Price', style: InvestrendTheme.of(context).small_w400.copyWith(color: colorPrice),),
            trailing: selected ? Image.asset(
              'images/icons/check.png',
              color: Theme.of(context).accentColor,
              width: 20.0,
              height: 20.0,
            ) : null,
          ));
        }
      });


    }
    */

    double childsHeight = (relatedStocks.length * 80).toDouble();
    double padding = 24.0;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double minHeight = height * 0.5;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + childsHeight + padding;

    minHeight = max(minHeight, contentHeight);
    maxHeight = min(maxHeight, minHeight);
    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        //padding: EdgeInsets.all(padding),
        padding: EdgeInsets.only(top: padding, bottom: padding),
        child: Column(
          //mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 64.0,
              height: 4.0,
              margin: EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                color: const Color(0xFFE0E0E0),
              ),
            ),
            /*
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(left: padding, right: padding),
                child: IconButton(
                    icon: Icon(Icons.clear),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
            ),
            */

            Expanded(
              flex: 1,
              child: ValueListenableBuilder(
                valueListenable: priceNotifier,
                builder: (context, value, child) {
                  Stock selectedStock =
                      context.read(primaryStockChangeNotifier).stock;
                  return ListView.separated(
                    itemCount: relatedStocks.length,
                    padding: EdgeInsets.only(top: 16.0),
                    separatorBuilder: (BuildContext context, int index) {
                      // if(index == 0){
                      //   return SizedBox(width: 1.0,);
                      // }
                      return Padding(
                        padding: EdgeInsets.only(left: padding, right: padding),
                        child: ComponentCreator.dividerCard(context,
                            thickness: 1.0),
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      Stock rowStock = relatedStocks.elementAt(index);
                      print("$index  rowStock : " + rowStock.code);
                      StockSummary summary = getSummary(rowStock.code);

                      return createRow(
                          context, selectedStock, rowStock, summary, padding);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile createRow(BuildContext context, Stock selectedStock, Stock value,
      StockSummary summary, double padding) {
    bool selected =
        StringUtils.equalsIgnoreCase(selectedStock.code, value.code);
    TextStyle titleStyle = InvestrendTheme.of(context).regular_w600_compact;
    Color color = selected ? Theme.of(context).colorScheme.secondary : titleStyle.color;
    Color colorPrice = selected
        ? Theme.of(context).colorScheme.secondary
        : InvestrendTheme.of(context).greyDarkerTextColor;
    return ListTile(
      onTap: () {
        context.read(primaryStockChangeNotifier).setStock(value);
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      },
      //visualDensity: VisualDensity.compact,
      contentPadding:
          EdgeInsets.only(top: 8.0, bottom: 8.0, left: padding, right: padding),
      title: Text(
        value.code,
        style: InvestrendTheme.of(context).regular_w600.copyWith(color: color),
      ),
      subtitle: Text(
        summary != null ? InvestrendTheme.formatPrice(summary.close) : '-',
        style: InvestrendTheme.of(context).small_w400_greyDarker,
      ),
      trailing: selected
          ? Image.asset(
              'images/icons/check.png',
              color: Theme.of(context).colorScheme.secondary,
              width: 20.0,
              height: 20.0,
            )
          : null,
    );
  }
}
