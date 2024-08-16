import 'package:Investrend/component/broker_trade_summary_value.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/ui_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BrokerRank extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BrokerRankState();
}

class BrokerRankState extends State<BrokerRank> {
  final RangeNotifier _rangeBrokerRankNotifier =
      RangeNotifier(Range.createBasic());

  List<BrokerData> brokerData = [];
  AutoSizeGroup groupValue = AutoSizeGroup();
  AutoSizeGroup groupHeader = AutoSizeGroup();

  @override
  void initState() {
    super.initState();
    brokerData = BrokerData.dummy;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBar(),
        body: body(),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    return AppBar(
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
      title: Text('Broker Rank'),
      titleTextStyle: InvestrendTheme.of(context).regular_w600?.copyWith(
            color: InvestrendTheme.of(context).investrendPurple,
            fontWeight: FontWeight.bold,
          ),
      leading: AppBarActionIcon(
        'images/icons/action_back.png',
        () {
          Navigator.of(context).pop();
        },
        //color: Theme.of(context).accentColor,
      ),
    );
  }

  Widget body() {
    String tanggalSekarang = "2023-06-19";
    String waktuSekarang = '15:00:00';

    String dateInfo = 'card_local_foreign_time_info'.tr();
    DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
    DateFormat dateParser = DateFormat('yyyy-MM-dd');
    DateTime dateTime = dateParser.parseUtc(tanggalSekarang);
    print('dateTime : ' + dateTime.toString());
    String formatedDate = dateFormatter.format(dateTime);

    dateInfo = dateInfo.replaceAll('#DATE#', formatedDate);
    dateInfo = dateInfo.replaceAll('#TIME#', waktuSekarang);
    List<Color> colorStock = [
      InvestrendTheme.of(context).whiteColor,
      InvestrendTheme.greenText,
      InvestrendTheme.of(context).investrendPurpleText!,
      InvestrendTheme.yellowText,
    ];
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final colors = [
        Colors.transparent,
        InvestrendTheme.of(context).oddColor,
      ];
      double fontSize = 14;
      TextStyle? styleHeader = InvestrendTheme.of(context).small_w500_compact;
      TextStyle? styleDarker =
          InvestrendTheme.of(context).small_w400_compact_greyDarker;
      double? centerWidth = UIHelper.textSize(' 000 ', styleDarker).width;
      double availableWidth = constraints.maxWidth -
          (InvestrendTheme.cardPaddingGeneral * 2) -
          (InvestrendTheme.cardPadding * 2);
      double leftWidth = (availableWidth - centerWidth) / 2;
      return Container(
        margin: EdgeInsets.only(
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical,
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChipsRangeCustom(
              _rangeBrokerRankNotifier,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(3),
                color: InvestrendTheme.of(context).tileBackground,
              ),
              height: 30,
              child: Row(
                children: [
                  SizedBox(
                    width: leftWidth * 0.2,
                    child: Text(
                      'NO',
                      style: styleHeader?.copyWith(
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    width: leftWidth * 0.2,
                    child: Text(
                      'BC',
                      style: styleHeader?.copyWith(
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(
                    width: leftWidth * 0.45,
                    child: Text(
                      'NVAL',
                      style: styleHeader?.copyWith(
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: leftWidth * 0.45,
                    child: Text(
                      'BVAL',
                      style: styleHeader?.copyWith(
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: leftWidth * 0.45,
                    child: Text(
                      'SVAL',
                      style: styleHeader?.copyWith(
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: leftWidth * 0.3,
                      child: Text(
                        'TVAL',
                        style: styleHeader?.copyWith(
                          fontSize: fontSize,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: brokerData.length,
                    itemBuilder: (context, index) {
                      brokerData.sort(
                          (a, b) => b.tVal!.toInt().compareTo(a.tVal!.toInt()));
                      int line = index + 1;
                      return Card(
                        child: Column(
                          children: [
                            Container(
                              color: colors[index % colors.length],
                              width: double.infinity,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: leftWidth * 0.2,
                                    child: Text(
                                      InvestrendTheme.formatNewComma(
                                          line.toDouble()),
                                      style: InvestrendTheme.of(context)
                                          .textLabelStyle
                                          ?.copyWith(
                                            fontSize: 14,
                                            color:
                                                InvestrendTheme.blackTextColor,
                                          ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  SizedBox(
                                      width: leftWidth * 0.2,
                                      child: Text(
                                        brokerData[index].brokerCode!,
                                        style: styleHeader?.copyWith(
                                            fontSize: fontSize,
                                            color: colorStock[
                                                brokerData[index].brokerType!]),
                                        textAlign: TextAlign.left,
                                      )),
                                  SizedBox(
                                    width: leftWidth * 0.45,
                                    child: Text(
                                      '${brokerData[index].nVal.toString()}' +
                                          'B',
                                      style: styleHeader?.copyWith(
                                        fontSize: fontSize,
                                        color: (brokerData[index].nVal)
                                                .toString()
                                                .contains('-')
                                            ? InvestrendTheme.redText
                                            : InvestrendTheme.greenText,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  SizedBox(
                                    width: leftWidth * 0.45,
                                    child: Text(
                                      '${brokerData[index].bVal}' + 'B',
                                      style: styleHeader?.copyWith(
                                        fontSize: fontSize,
                                        color: InvestrendTheme.greenText,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  SizedBox(
                                    width: leftWidth * 0.45,
                                    child: Text(
                                      '${brokerData[index].sVal}' + 'B',
                                      style: styleHeader?.copyWith(
                                        fontSize: fontSize,
                                        color: InvestrendTheme.redText,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      width: leftWidth * 0.45,
                                      child: Text(
                                        '${brokerData[index].tVal.toString()}' +
                                            'B',
                                        style: styleHeader?.copyWith(
                                          fontSize: fontSize,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Text(
                  dateInfo,
                  style: InvestrendTheme.of(context)
                      .more_support_w400_compact
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: InvestrendTheme.of(context).greyDarkerTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
