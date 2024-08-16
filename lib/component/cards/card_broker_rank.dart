// ignore_for_file: implementation_imports

import 'package:Investrend/component/broker_rank.dart';
import 'package:Investrend/component/broker_trade_summary.dart';
import 'package:Investrend/component/chips_range.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../broker_trade_summary_value.dart';

class CardBrokerRank extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CardBrokerRankState();
}

class CardBrokerRankState extends State<CardBrokerRank> {
  final RangeNotifier _rangeBrokerRankNotifier =
      RangeNotifier(Range.createBasic());

  List<BrokerData>? brokerData = [];
  AutoSizeGroup groupValue = AutoSizeGroup();
  AutoSizeGroup groupHeader = AutoSizeGroup();

  @override
  void initState() {
    super.initState();
    brokerData = BrokerData.dummy;
  }

  @override
  Widget build(BuildContext context) {
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
    // String displayTime = data.time;
    //           if( !StringUtils.isEmtpy(data.time) && !StringUtils.isEmtpy(data.date)){
    //             String infoTime = 'card_local_foreign_time_info'.tr();
    List<Color> colorStock = [
      InvestrendTheme.of(context).whiteColor,
      InvestrendTheme.greenText,
      InvestrendTheme.of(context).investrendPurpleText!,
      InvestrendTheme.yellowText,
    ];
    TextStyle? styleHeader = InvestrendTheme.of(context).small_w400_compact;
    double fontSize = 14;
    double width = MediaQuery.of(context).size.width;
    final colors = [
      Colors.transparent,
      InvestrendTheme.of(context).oddColor,
    ];

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
          Container(
            child: ComponentCreator.subtitle(context, 'Broker Trade'),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              children: [
                ActionChip(
                    label: Text('Ranking'),
                    onPressed: () {
                      showRatingBrokerTrade(context);
                    }),
                SizedBox(
                  width: 10,
                ),
                ActionChip(
                    label: Text('Summary'),
                    onPressed: () {
                      showBrokerTradeSummary(context);
                    }),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          ChipsRangeCustom(
            _rangeBrokerRankNotifier,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
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
                  width: width / 10,
                  child: Text(
                    'NO',
                    style: styleHeader?.copyWith(
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  width: width / 10,
                  child: Text(
                    'BC',
                    style: styleHeader?.copyWith(
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  width: width / 6,
                  child: Text(
                    'NVAL',
                    style: styleHeader?.copyWith(
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: width / 6,
                  child: Text(
                    'BVAL',
                    style: styleHeader?.copyWith(
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: width / 6,
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
                    width: width / 10,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
                brokerData == null
                    ? 0
                    : (brokerData!.length > 5 ? 5 : brokerData!.length),
                (index) {
              brokerData
                  ?.sort((a, b) => b.tVal!.toInt().compareTo(a.tVal!.toInt()));
              int line = index + 1;
              return Card(
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      color: colors[index % colors.length],
                      width: double.infinity,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                              width: width / 10,
                              child: Text(
                                InvestrendTheme.formatNewComma(line.toDouble()),
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    ?.copyWith(
                                      fontSize: 14,
                                      color: InvestrendTheme.blackTextColor,
                                    ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          SizedBox(
                              width: width / 10,
                              child: TextButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero),
                                  alignment: Alignment.centerLeft,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => BrokerTradeSummary(
                                          selectValue:
                                              brokerData?[index].brokerCode,
                                        ),
                                        settings: RouteSettings(
                                            name: '/brokerTradeSummary'),
                                      ));
                                },
                                child: Text(
                                  brokerData![index].brokerCode!,
                                  style: styleHeader?.copyWith(
                                      fontSize: fontSize,
                                      color: colorStock[
                                          brokerData![index].brokerType!]),
                                  textAlign: TextAlign.left,
                                ),
                              )),
                          SizedBox(
                            width: width / 6,
                            child: Text(
                              '${brokerData![index].nVal.toString()}' + 'B',
                              style: styleHeader?.copyWith(
                                fontSize: fontSize,
                                color: (brokerData![index].nVal)
                                        .toString()
                                        .contains('-')
                                    ? InvestrendTheme.redText
                                    : InvestrendTheme.greenText,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(
                            width: width / 6,
                            child: Text(
                              '${brokerData![index].bVal}' + 'B',
                              style: styleHeader?.copyWith(
                                fontSize: fontSize,
                                color: InvestrendTheme.greenText,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(
                            width: width / 6,
                            child: Text(
                              '${brokerData![index].sVal}' + 'B',
                              style: styleHeader?.copyWith(
                                fontSize: fontSize,
                                color: InvestrendTheme.redText,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SizedBox(
                                width: width / 10,
                                child: Text(
                                  '${brokerData![index].tVal.toString()}' + 'B',
                                  style: styleHeader?.copyWith(
                                    fontSize: fontSize,
                                    color: InvestrendTheme.blackTextColor,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => BrokerRank(),
                      settings: RouteSettings(name: '/brokerTradeSummary')));
            },
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "button_show_more".tr(),
                textAlign: TextAlign.end,
                style: InvestrendTheme.of(context).small_w600?.copyWith(
                    color: InvestrendTheme.of(context)
                        .investrendPurpleText /*, fontWeight: FontWeight.bold*/),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
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
        ],
      ),
    );
  }

  void showRatingBrokerTrade(BuildContext context) {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => BrokerRank(),
          settings: RouteSettings(name: '/brokerRating'),
        ));
  }

  void showBrokerTradeSummary(BuildContext context) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => BrokerTradeSummary(
                  selectValue: brokerData?[0].brokerCode,
                ),
            settings: RouteSettings(name: 'brokerTradeSummary')));
  }
}
