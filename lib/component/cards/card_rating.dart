import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rating_slider.dart';
import 'package:Investrend/component/text_button_retry.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CardRating extends StatelessWidget {
  //final double rating;
  final ResearchRankNotifier? notifier;
  final VoidCallback? onRetry;
  const CardRating(this.notifier, /*this.rating,*/ {this.onRetry, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          top: InvestrendTheme.cardPaddingVertical,
          bottom: InvestrendTheme.cardPaddingVertical),
      child: LayoutBuilder(builder: (context, constrains) {
        print('CardRating constrains ' + constrains.maxWidth.toString());
        const int gridCount = 5;
        double availableWidth = constrains.maxWidth;
        print('CardRating  $availableWidth');
        double tileWidth = availableWidth / gridCount;
        print('CardRating tileWidth $tileWidth');
        return ValueListenableBuilder<ResearchRank?>(
            valueListenable: notifier!,
            builder: (context, value, child) {
              double? ranks = 0.0;
              String? subtitle = 'card_rating_subtitle'.tr();
              String? description = 'card_rating_content'.tr();

              if (notifier!.currentState.isNoData()) {
                description = 'card_rating_no_content'.tr();
              } else if (notifier!.currentState.isLoading()) {
                description = 'loading_please_wait_label'.tr();
              } else if (notifier!.currentState.isFinished()) {
                subtitle = value?.getSubtitle(
                    language:
                        EasyLocalization.of(context)!.locale.languageCode);
                description = value?.getDescription(
                    language:
                        EasyLocalization.of(context)!.locale.languageCode);
                ranks = value?.value;
              }

              Widget content;
              if (notifier!.currentState.isError()) {
                content = Center(
                    child: TextButtonRetry(
                  onPressed: onRetry!,
                ));
              } else {
                content = Text(
                  description!, //'card_rating_content'.tr(),
                  style: InvestrendTheme.of(context)
                      .small_w400_compact
                      ?.copyWith(
                          color:
                              InvestrendTheme.of(context).greyLighterTextColor),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ComponentCreator.subtitle(
                    context,
                    'card_rating_title'.tr(),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  //getTableDataOrderbook(context),
                  ComponentCreator.roundedContainer(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: InvestrendTheme.of(context)
                                      .tileSmallRoundedRadius *
                                  2,
                              right: InvestrendTheme.of(context)
                                      .tileSmallRoundedRadius *
                                  2,
                              top: InvestrendTheme.cardPadding,
                              bottom: InvestrendTheme.cardPadding),
                          child: Text(
                            subtitle!, //'card_rating_subtitle'.tr(),
                            style: InvestrendTheme.of(context)
                                .support_w600_compact,
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: InvestrendTheme.of(context)
                                      .tileSmallRoundedRadius *
                                  2,
                              right: InvestrendTheme.of(context)
                                      .tileSmallRoundedRadius *
                                  2),
                          child: content,
                          // child: Text(
                          //   description,//'card_rating_content'.tr(),
                          //   style: InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                          // ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RatingSlider(ranks),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    noPadding: true,
                  ),
                ],
              );
            });
      }),
    );
  }
}
