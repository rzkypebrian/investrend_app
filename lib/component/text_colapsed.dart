import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


class ColapsedText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ColapsedText({Key key, this.text, this.maxLines = 10}) : super(key: key);

  @override
  _ColapsedTextState createState() => _ColapsedTextState();
}

class _ColapsedTextState extends State<ColapsedText> {
  ValueNotifier<bool> colapseNotifier = ValueNotifier<bool>(true);
  @override
  Widget build(BuildContext context) {
    // final Color background = Theme.of(context).backgroundColor;
    // final Color fill = InvestrendTheme.of(context).blackAndWhite;
    // final List<Color> gradient = [
    //   background,
    //   background,
    //   fill,
    //   fill,
    // ];
    // final double fillPercent = 20.0; // fills 56.23% for container from bottom
    // final double fillStop = (100 - fillPercent) / 100;
    // final List<double> stops = [0.0, fillStop, fillStop, 1.0];

    return ValueListenableBuilder(
        valueListenable: colapseNotifier,
        builder: (context, bool showMore, child) {
          if(showMore){
            return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.text,
                  maxLines: showMore ? 10 : null,
                  style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      colapseNotifier.value = !showMore;
                      // setState(() {
                      //   showMore = !showMore;
                      // });
                    },
                    child: Text(
                      showMore ? "button_show_more".tr() : "button_show_less".tr(),
                      textAlign: TextAlign.end,
                      style: InvestrendTheme.of(context)
                          .small_w600
                          .copyWith(color: InvestrendTheme.of(context).investrendPurple/*, fontWeight: FontWeight.bold*/),
                    ),
                  ),
                ),
              ],
            );
          }else{
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.text,
                  maxLines: showMore ? 10 : null,
                  style: InvestrendTheme.of(context).small_w400.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      colapseNotifier.value = !showMore;
                      // setState(() {
                      //   showMore = !showMore;
                      // });
                    },
                    child: Text(
                      showMore ? "button_show_more".tr() : "button_show_less".tr(),
                      textAlign: TextAlign.end,
                      style: InvestrendTheme.of(context)
                          .small_w600
                          .copyWith(color: InvestrendTheme.of(context).investrendPurple/*, fontWeight: FontWeight.bold*/),
                    ),
                  ),
                ),
              ],
            );
          }

        });
  }
}
