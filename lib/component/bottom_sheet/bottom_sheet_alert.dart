import 'dart:math';

import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomSheetAlert extends StatelessWidget {
  final List<Widget> childs;
  final String title;
  final double childsHeight;
  const BottomSheetAlert(this.childs,
      {this.title, Key key, this.childsHeight = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
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
        padding: EdgeInsets.all(padding),
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
            SizedBox(
              height: 40.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        title ?? 'bottom_sheet_alert_title'.tr(),
                        style: InvestrendTheme.of(context).regular_w600_compact,
                      )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        //icon: Icon(Icons.clear),
                        icon: Image.asset(
                          'images/icons/action_clear.png',
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor,
                          width: 12.0,
                          height: 12.0,
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                padding: EdgeInsets.only(top: 16.0),
                children: childs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
