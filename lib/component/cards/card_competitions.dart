import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/utils/callbacks.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
//import 'package:easy_localization/easy_localization.dart';

class CardCompetitions extends StatelessWidget {
  final List<HomeCompetition>? listCompetition;
  final String? title;
  const CardCompetitions(this.title, this.listCompetition, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //double width = MediaQuery.of(context).size.width;
    //double tileWidth = width * 0.7;

    return Card(
      margin: const EdgeInsets.only(
          top: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                /*right: InvestrendTheme.cardPaddingGeneral,*/ bottom:
                    InvestrendTheme.cardPadding),
            child: ComponentCreator.subtitleButtonMore(context, title!, () {
              InvestrendTheme.of(context)
                  .showSnackBar(context, "Action Competition More");
            }),
          ),
          //SizedBox(height: InvestrendTheme.cardPadding,),

          LayoutBuilder(builder: (context, constrains) {
            print('constrains ' + constrains.maxWidth.toString());
            double tileWidth = constrains.maxWidth * 0.8;
            //double height = 180.0;
            double height = tileWidth * 0.5;
            return SizedBox(
              height: height,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: listCompetition!.length,
                itemBuilder: (BuildContext context, int index) {
                  //double left = index == 0 ? InvestrendTheme.cardPaddingGeneral : 0.0;

                  bool isFirst = index == 0;
                  bool isLast = index == listCompetition!.length - 1;
                  return tileCompetition(context, listCompetition![index],
                      isFirst, isLast, tileWidth, height);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget tileCompetition(BuildContext context, HomeCompetition competition,
      bool isFirst, bool isLast, double widthTile, double heightTile) {
    double left;
    double right;
    if (isFirst) {
      left = InvestrendTheme.cardPaddingGeneral;
    } else {
      left = InvestrendTheme.cardMargin;
    }
    if (isLast) {
      right = InvestrendTheme.cardPaddingGeneral;
    } else {
      right = 0.0;
    }
    return Padding(
      padding: EdgeInsets.only(left: left, right: right),
      child: ClipRRect(
        //borderRadius: BorderRadius.circular(InvestrendTheme.of(context).tileRoundedRadius),
        borderRadius: BorderRadius.circular(14.0),
        child: SizedBox(
          width: widthTile,
          height: heightTile,
          child: Stack(
            children: [
              ComponentCreator.imageNetwork(
                competition.url_background,
                fit: BoxFit.fill,
                width: widthTile,
                height: heightTile,
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        splashColor: Theme.of(context).colorScheme.secondary,
                        onTap: () {
                          InvestrendTheme.of(context).showSnackBar(
                              context, 'Action Competition detail');
                        })),
              ),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        competition.name,
                        style: InvestrendTheme.of(context)
                            .regular_w600
                            ?.copyWith(
                                color: InvestrendTheme.of(context).textWhite),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'images/icons/trophy.png',
                            width: 24.0,
                            height: 24.0,
                          ),
                          Text(
                            'Rank #' + competition.rank.toString(),
                            style: InvestrendTheme.of(context)
                                .small_w400_compact
                                ?.copyWith(
                                    color:
                                        InvestrendTheme.of(context).textWhite),
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Text(
                        competition.participant_size.toString() + ' Partisipan',
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            ?.copyWith(
                                color: InvestrendTheme.of(context).textWhite),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      AvatarListCompetition(
                        size: 24,
                        participantsAvatar: competition.participants_avatar,
                        totalParticipant: competition.participant_size,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardChart extends StatefulWidget {
  final ChartNotifier? notifier;
  final StringCallback? callbackRange;

  const CardChart(this.notifier, {this.callbackRange, Key? key})
      : super(key: key);

  @override
  _CardChartState createState() => _CardChartState();
}

class _CardChartState extends State<CardChart> {
  List<String> _listChipRange = <String>[
    '1D',
    '1W',
    '1M',
    '3M',
    '6M',
    '1Y',
    '5Y',
    'All'
  ];
  int _selectedRange = 0;
  //int _selectedMarket = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Colors.lightBlueAccent,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chipsRange(context),
          ValueListenableBuilder(
            valueListenable: widget.notifier!,
            builder: (context, ChartLineData? data, child) {
              // if (widget.notifier.invalid()) {
              //   return Center(child: CircularProgressIndicator());
              // }
              return Placeholder(
                fallbackWidth: double.maxFinite,
                fallbackHeight: 220.0,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _chipsRange(BuildContext context) {
    double marginPadding =
        InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    // double marginPadding = 0;
    return Container(
      //color: Colors.green,
      margin: EdgeInsets.only(bottom: marginPadding),
      width: double.maxFinite,
      height: 30.0,

      decoration: BoxDecoration(
        //color: Colors.green,
        color: InvestrendTheme.of(context).tileBackground,
        border: Border.all(
          color: InvestrendTheme.of(context).chipBorder!,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(2.0),

        //color: Colors.green,
      ),

      child: Row(
        children: List<Widget>.generate(
          _listChipRange.length,
          (int index) {
            //print(_listChipRange[index]);
            bool selected = _selectedRange == index;
            return Expanded(
              flex: 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRange = index;
                      if (widget.callbackRange != null) {
                        widget.callbackRange!(_listChipRange[_selectedRange]);
                      }
                    });
                  },
                  child: Container(
                    color: selected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                    child: Center(
                        child: Text(
                      _listChipRange[index],
                      style: InvestrendTheme.of(context)
                          .more_support_w400_compact
                          ?.copyWith(
                              color: selected
                                  ? InvestrendTheme.of(context)
                                      .textWhite /*Colors.white*/
                                  : InvestrendTheme.of(context)
                                      .blackAndWhiteText),
                    )),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
