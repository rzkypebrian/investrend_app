//import 'dart:math';

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomSheetSelectStock extends StatelessWidget {
  // final ValueNotifier rangeNotifier;
  // final List<String> range_options;

  const BottomSheetSelectStock(
      /*this.rangeNotifier, this.range_options,*/ {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.5;
    //double contentHeight = padding + 44.0 + (44.0 * range_options.length) + padding;

    //maxHeight = min(contentHeight, maxHeight);
    //minHeight = min(minHeight, maxHeight);

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          //mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 64.0,
              height: 4.0,
              margin: EdgeInsets.only(bottom: 40.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.0),
                color: const Color(0xFFE0E0E0),
              ),
            ),
            /*
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(Icons.clear),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
            */
            ComponentCreator.textFieldSearch(context, onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              final result = InvestrendTheme.showFinderScreen(context);
              result.then((value) {
                Navigator.of(context).pop();
                if (value == null) {
                  print('result finder = null');
                } else if (value is Stock) {
                  //InvestrendTheme.of(context).stockNotifier.setStock(value);

                  context.read(primaryStockChangeNotifier).setStock(value);
                  //InvestrendTheme.of(context).showStockDetail(context);
                  print('result finder = ' + value.code!);
                } else if (value is People) {
                  print('result finder = ' + value.name!);
                }
              });
            }),
            Expanded(
              flex: 1,
              child: Consumer(builder: (context, watch, child) {
                final notifier = watch(primaryStockChangeNotifier);

                List<Widget> rows = List.empty(growable: true);
                String? codeSelected =
                    notifier.isValid() ? notifier.stock?.code : '';

                if (!StringUtils.isEmtpy(codeSelected)) {
                  rows.add(createRow(context, codeSelected, true));
                  rows.add(ComponentCreator.divider(context));
                }

                InvestrendTheme.storedData?.listFinderRecent?.forEach((object) {
                  if (object is Stock) {
                    String? code = object.code;
                    if (!StringUtils.equalsIgnoreCase(codeSelected, code)) {
                      rows.add(createRow(context, code, false));
                    }
                  }
                });

                return ListView(
                  children: rows,
                );
              }),
            ),
            /*
            Expanded(
              flex: 1,
              child: ValueListenableBuilder(
                valueListenable: rangeNotifier,
                builder: (context, selectedIndex, child) {
                  List<Widget> list = List.empty(growable: true);

                  int count = range_options.length;
                  for (int i = 0; i < count; i++) {
                    String ca = range_options.elementAt(i);
                    list.add(createRow(context, ca, selectedIndex == i, i));
                  }
                  return ListView(
                    children: list,
                  );
                },
              ),
            ),
            */
          ],
        ),
      ),
      /*
      child: Container(
        padding: EdgeInsets.all(padding),
        // color: Colors.yellow,
        width: double.maxFinite,
        child: ValueListenableBuilder(
          valueListenable: rangeNotifier,
          builder: (context, selectedIndex, child) {
            List<Widget> list = List.empty(growable: true);
            list.add(Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(Icons.clear),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ));
            int count = range_options.length;
            for (int i = 0; i < count; i++) {
              String ca = range_options.elementAt(i);
              list.add(createRow(context, ca, selectedIndex == i, i));
            }
            return ListView(
              children: list,
            );
          },
        ),
      ),
      */
    );
  }

  Widget createRow(
      BuildContext context, String? label, bool selected /*, int index*/) {
    TextStyle? style = InvestrendTheme.of(context).regular_w600_compact;
    //Color colorText = style.color;
    Color colorIcon = Colors.transparent;

    if (selected) {
      style = InvestrendTheme.of(context)
          .regular_w600_compact
          ?.copyWith(color: Theme.of(context).colorScheme.secondary);
      //colorText = Theme.of(context).accentColor;
      colorIcon = Theme.of(context).colorScheme.secondary;
    }

    return TextButton(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(
            //   width: 20.0,
            //   height: 20.0,
            // ),
            Expanded(
                flex: 1,
                child: Text(
                  label!,
                  style:
                      style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
                  textAlign: TextAlign.left,
                )),
            (selected
                ? Image.asset(
                    'images/icons/check.png',
                    color: colorIcon,
                    width: 20.0,
                    height: 20.0,
                  )
                : SizedBox(
                    width: 20.0,
                    height: 20.0,
                  )),
          ],
        ),
      ),
      onPressed: () {
        Stock? stock = InvestrendTheme.storedData?.findStock(label);
        if (stock != null) {
          context.read(primaryStockChangeNotifier).setStock(stock);
          Navigator.of(context).pop();
        }

        // setState(() {
        //   selectedIndex = index;
        // });
        //context.read(marketChangeNotifier).setIndex(index);
        //rangeNotifier.value = index;
      },
    );
  }
}
