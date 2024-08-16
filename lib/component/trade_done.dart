import 'package:Investrend/component/trade_done_value.dart';
import 'package:Investrend/utils/investrend_theme.dart';
// import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/style.dart';
// import 'package:xml/xml.dart';

class TradeDone extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TradeDoneState();
}

class TradeDoneState extends State<TradeDone> {
  List<TradeDoneValue> tradeUser = [];
  TextEditingController searchTradeNumberController =
      new TextEditingController();
  FocusNode focusNodeTradeNumberInput = new FocusNode();

  @override
  void initState() {
    super.initState();
    tradeUser = TradeDoneValue.listDummy;
    focusNodeTradeNumberInput = FocusNode();
    focusNodeTradeNumberInput.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    focusNodeTradeNumberInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      centerTitle: true,
      title: Text('Trade Done'),
      titleTextStyle: InvestrendTheme.of(context).regular_w600?.copyWith(
            color: InvestrendTheme.of(context).investrendPurple,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget body() {
    // return Container(
    //   // color: Colors.blue,
    //   margin: EdgeInsets.only(
    //       left: InvestrendTheme.cardPaddingGeneral,
    //       right: InvestrendTheme.cardPaddingGeneral,
    //       //top: InvestrendTheme.cardPaddingVertical,
    //       bottom: 10.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     mainAxisSize: MainAxisSize.max,
    //     children: [
    //       ComponentCreator.subtitleNoButtonMore(
    //         context,
    //         'card_trade_done_title'.tr(),
    //       ),
    //       SizedBox(
    //         height: 20,
    //       ),
    return getTradeDoneDataNew(context);
    //     ],
    //   ),
    // );
  }

  Widget getTradeDoneDataNew(BuildContext context) {
    final colors = [
      Colors.transparent,
      InvestrendTheme.of(context).oddColor,
    ];
    List<TradeDoneValue> data = TradeDoneValue.listDummy;

    String prev = '6600';
    double textFont = 13;

    return Container(
      margin: EdgeInsets.only(
        left: 10,
        top: 10,
        right: 10,
        bottom: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANTM',
            style: InvestrendTheme.of(context).regular_w600,
          ),
          Text('PT. Antam Tbk',
              style: InvestrendTheme.of(context)
                  .more_support_w400_compact_greyDarker),
          Row(
            children: [
              Container(
                width: 300,
                child: TextField(
                    onChanged: (value) => setFilter(value),
                    decoration: InputDecoration(
                        labelText: 'Search Trade Number',
                        labelStyle: InvestrendTheme.of(context).inputLabelStyle,
                        suffixIcon: IconButton(
                          alignment: Alignment.bottomRight,
                          icon: Icon(
                            Icons.search,
                          ),
                          onPressed: searchTradeNumberController.clear,
                        ))),
              ),
            ],
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
                Container(
                  width: 80,
                  child: Text(
                    'TIME',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 50,
                  child: Text(
                    'PRICE',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 40,
                  child: Text(
                    'LOT',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 25,
                  child: Text(
                    'F/D',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 25,
                  child: Text(
                    'BY',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 25,
                  child: Text(
                    'SL',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 25,
                  child: Text(
                    'F/D',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 40,
                  child: Text(
                    'CHG',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 50,
                  child: Text(
                    '%',
                    style: InvestrendTheme.of(context).textLabelStyle?.copyWith(
                          fontSize: textFont,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tradeUser.length != 0 || tradeUser.isNotEmpty
                ? Container(
                    child: ListView.builder(
                      itemCount: tradeUser.length,
                      itemBuilder: (context, index) {
                        return Card(
                          key: ValueKey(tradeUser[index].noId),
                          child: Column(
                            children: [
                              Container(
                                color: colors[index % colors.length],
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      child: Text(
                                        data[index].time!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: InvestrendTheme
                                                  .blackTextColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      child: Text(
                                        data[index].price!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: data[index].price == prev
                                                  ? Colors.blue
                                                  : int.parse(data[index]
                                                              .price!) <
                                                          int.parse(prev)
                                                      ? Colors.red
                                                      : Colors.green,
                                              // color: Colors.green,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      child: Text(
                                        data[index].lot!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: InvestrendTheme
                                                  .blackTextColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 25,
                                      child: Text(
                                        data[index].fdBuy!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: InvestrendTheme
                                                  .blackTextColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 25,
                                      child: Text(
                                        data[index].buy!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: InvestrendTheme
                                                  .blackTextColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 25,
                                      child: Text(
                                        data[index].sell!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: InvestrendTheme
                                                  .blackTextColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 25,
                                      child: Text(
                                        data[index].fdSell!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: InvestrendTheme
                                                  .blackTextColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      child: Text(
                                        data[index].chg!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                              fontSize: 14,
                                              color: data[index].chg == '0'
                                                  ? Colors.blue
                                                  : data[index]
                                                          .chg!
                                                          .contains('+')
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      child: Text(
                                        data[index].percent!,
                                        style: InvestrendTheme.of(context)
                                            .textLabelStyle
                                            ?.copyWith(
                                                fontSize: 14,
                                                color:
                                                    data[index].percent == '0'
                                                        ? Colors.blue
                                                        : data[index]
                                                                .percent!
                                                                .contains('+')
                                                            ? Colors.green
                                                            : Colors.red),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    'No results found',
                    style: TextStyle(fontSize: 24),
                  ),
          ),
          /*  
              tradeUser.isNotEmpty
                  ? List.generate(data.length, (index) {
                      return Container(
                        color: colors[index % colors.length],
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              child: Text(
                                data[index].time,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: InvestrendTheme.blackTextColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 50,
                              child: Text(
                                data[index].price,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: data[index].price == prev
                                          ? Colors.blue
                                          : int.parse(data[index].price) <
                                                  int.parse(prev)
                                              ? Colors.red
                                              : Colors.green,
                                      // color: Colors.green,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 60,
                              child: Text(
                                data[index].lot,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: InvestrendTheme.blackTextColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 25,
                              child: Text(
                                data[index].fdBuy,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: InvestrendTheme.blackTextColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 25,
                              child: Text(
                                data[index].buy,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: InvestrendTheme.blackTextColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 25,
                              child: Text(
                                data[index].sell,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: InvestrendTheme.blackTextColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 25,
                              child: Text(
                                data[index].fdSell,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: InvestrendTheme.blackTextColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 40,
                              child: Text(
                                data[index].chg,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      fontSize: 14,
                                      color: data[index].chg == '0'
                                          ? Colors.blue
                                          : data[index].chg.contains('+')
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              width: 50,
                              child: Text(
                                data[index].percent,
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                        fontSize: 14,
                                        color: data[index].percent == '0'
                                            ? Colors.blue
                                            : data[index].percent.contains('+')
                                                ? Colors.green
                                                : Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  : Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),

                    */
        ],
      ),
    );
  }

  void setFilter(String enteredKeyword) {
    List<TradeDoneValue> results = [];

    if (enteredKeyword.isEmpty) {
      results = TradeDoneValue.listDummy;
    } else {
      results = TradeDoneValue.listDummy
          .where((e) => e.noId
              .toString()
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
      // } else {
      //   results = TradeDoneValue.listDummy
      //       .where((tradeNumber) => tradeNumber.noId
      //           .toString()
      //           .toLowerCase()
      //           .contains(enteredKeyword.toLowerCase()))
      //       .toList();
    }
    setState(() {
      tradeUser = results;
    });
  }
}
