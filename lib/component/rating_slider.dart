import 'dart:math';

import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class RatingSlider extends StatelessWidget {
  static final List<String> _ratingText = <String>[
    'rating_text_0'.tr(),
    'rating_text_1'.tr(),
    'rating_text_2'.tr(),
    'rating_text_3'.tr(),
    'rating_text_4'.tr()
  ];
  final double initialValue;
  static final double dotSize = 10.0;
  static final double bubleSize = 30.0;
  static final double padding = 25.0;
  static final Color grayPointColor = Color(0xFFD0D0D0);
  double halfDotSize = dotSize / 2;
  double halfBubleSize =  bubleSize/ 2;
  RatingSlider(this.initialValue, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.red[700],
        inactiveTrackColor: Colors.red[100],
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
        thumbColor: Colors.redAccent,
        overlayColor: Colors.red.withAlpha(32),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
        tickMarkShape: RoundSliderTickMarkShape(),
        activeTickMarkColor: Colors.red[700],
        inactiveTickMarkColor: Colors.red[100],
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: Colors.redAccent,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      child: Slider(
        value: _value,
        min: 0,
        max: 100,
        divisions: 10,
        label: '$_value',
        onChanged: (value) {
          setState(
                () {
              _value = value;
            },
          );
        },
      ),
    )
      */


    return LayoutBuilder(builder: (context, constrains) {
      double minValue = 1.0;
      double maxValue = 5.0;
      int gridCount = 4;

      double availableWidth = constrains.maxWidth - padding - padding;
      print('createCardThinks availableWidth $availableWidth');
      double tileWidth = availableWidth / gridCount;
      //double valueNormalized = min(initialValue, maxValue);
      //valueNormalized = max(valueNormalized, minValue);
      double newValue = min(initialValue, maxValue);
      newValue = max(newValue, minValue);
      double value = newValue - 1;



      double selectedPosition =   ( ( availableWidth)  / gridCount ) * value;
      print('createCardThinks tileWidth $tileWidth  selectedPosition : $selectedPosition  value : $value');
      bool noData = initialValue < 1.0;
      return Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 42.0,
              ),
              Container(
                margin: EdgeInsets.only(left: padding, right: padding, top: 4.0, bottom: 4.0),
                width: double.maxFinite,
                height: 2.0,
                //color: Theme.of(context).dividerColor,
                color: grayPointColor,
              ),


              Positioned(child: _dotGrey(context), left: (padding - halfDotSize)  ),
              Positioned(child: _dotGrey(context), left: (padding - halfDotSize)  + tileWidth * 1,) ,
              Positioned(child: _dotGrey(context), left: (padding - halfDotSize)  + tileWidth * 2,) ,
              Positioned(child: _dotGrey(context), left: (padding - halfDotSize)  + tileWidth * 3,) ,
              Positioned(child: _dotGrey(context), left: (padding - halfDotSize)  + tileWidth * 4,) ,

              //selectedWidget(context, value),
              (noData ? SizedBox(width: 1.0,) : Positioned(child: _bubleText(context,newValue), left: (padding - halfBubleSize) + selectedPosition)),
              // Padding(
              //   padding: EdgeInsets.only(left: padding, right: padding),
              //   child: rowDotsGrey(context, tileWidth),
              // ),
            ],
          ),
          SizedBox(height: 10.0,),
          Padding(
            padding: EdgeInsets.only(left: padding - halfDotSize , right: padding-halfDotSize),
            child: rowText(context, tileWidth, availableWidth),
          ),
        ],
      );
    });
  }

  Widget _bubleText(BuildContext context, double value){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: [
            // Image.asset(
            //   'images/icons/point_purple.png',
            //   width: bubleSize,
            //   height: bubleSize,
            // ),
            _bublePurple(context),
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Text(
                value.toString(),
                style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).textWhite /*Colors.white*/, fontSize: 10.0),
              ),
            )
          ]),
          SizedBox(
            height: 2.0,
          ),
          _dotPurple(context),
          // Image.asset(
          //   'images/icons/dot_purple.png',
          //   width: 10.0,
          //   height: 10.0,
          // ),
        ],
      ),
    );
  }
  // Widget rowDotsGrey(BuildContext context, double tileWidth) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       _dotGrey(context),
  //       _dotGrey(context),
  //       _dotGrey(context),
  //       _dotGrey(context),
  //       _dotGrey(context),
  //     ],
  //   );
  // }

  Widget rowText(BuildContext context, double tileWidth, double availableWidth) {
    double half = availableWidth / 2;

    return Stack(
      children: [
        Align(
          child: _text(context, _ratingText.elementAt(0), tileWidth, textAlign: TextAlign.left, color: Colors.orangeAccent),
          alignment: Alignment.topLeft,
        ),
        Align(
          child: _text(context, _ratingText.elementAt(2), tileWidth, color: Colors.green),
          alignment: Alignment.topCenter,
        ),
        Align(
          child: _text(context, _ratingText.elementAt(4), tileWidth, textAlign: TextAlign.right, color: Colors.purple),
          alignment: Alignment.topRight,
        ),


        Row(
          children: [
            Expanded(
                flex: 1,
                child: Padding(
                  padding:  EdgeInsets.only(left: halfDotSize),
                  child: Text(
                    _ratingText.elementAt(1),
                    textAlign: TextAlign.center,
                    style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                  ),
                )),
            Expanded(
                flex: 1,
                child: Padding(
                  padding:  EdgeInsets.only(right: halfDotSize),
                  child: Text(
                    _ratingText.elementAt(3),
                    textAlign: TextAlign.center,
                    style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                  ),
                )),

            // _text(context, _ratingText.elementAt(1), half, color: Colors.blue),
            // _text(context, _ratingText.elementAt(3), half, color: Colors.lightBlueAccent),
          ],
        ),

        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     SizedBox(width: tileWidth/2,),
        //     _text(context, _ratingText.elementAt(1), tileWidth * 1.3, color: Colors.blue),
        //     _text(context, _ratingText.elementAt(2), tileWidth * 1.3, color: Colors.green),
        //     _text(context, _ratingText.elementAt(3), tileWidth * 1.3, color: Colors.lightBlueAccent),
        //     SizedBox(width: tileWidth/2,),
        //   ],
        // ),
      ],
    );

    /*
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(context, _ratingText.elementAt(0), tileWidth, textAlign: TextAlign.left, color: Colors.orangeAccent),
        _text(context, _ratingText.elementAt(1), tileWidth, color: Colors.blue),
        _text(context, _ratingText.elementAt(2), tileWidth, color: Colors.green),
        _text(context, _ratingText.elementAt(3), tileWidth, color: Colors.lightBlueAccent),
        _text(context, _ratingText.elementAt(4), tileWidth, textAlign: TextAlign.right, color: Colors.purple),
      ],
    );
    */
  }

  Widget _text(BuildContext context, String text, double tileWidth,
      {TextAlign textAlign, double paddingLeft = 0.0, double paddingRight = 0.0, Color color}) {
    if (textAlign == null) {
      textAlign = TextAlign.center;
    }
    return Container(
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
      // color: color,
      width: tileWidth,
      //height: 20.0,
      child: AutoSizeText(
        text,
        maxLines: 2,
        textAlign: textAlign,
        style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
      ),
    );
  }

  Widget _bublePurple(BuildContext context) {
    return Image.asset(
      'images/icons/point_purple.png',
      width: bubleSize,
      height: bubleSize,
    );
  }

  Widget _dotGrey(BuildContext context) {
    return Image.asset(
      'images/icons/dot_gray.png',
      width: dotSize,
      height: dotSize,
      //color: Theme.of(context).dividerColor,
      color: grayPointColor,
    );
  }

  Widget _dotPurple(BuildContext context) {
    return Image.asset(
      'images/icons/dot_purple.png',
      width: dotSize,
      height: dotSize,
      //color: Theme.of(context).dividerColor,
      //color: grayPointColor,
    );
  }
}
