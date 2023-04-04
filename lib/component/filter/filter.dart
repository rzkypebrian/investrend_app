import 'package:Investrend/component/type_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class FilterPage {
  static Widget filterOverview({
    Key key,
    BuildContext context,
    List<Widget> children,
    ReorderCallback onReorder,
    WrapAlignment alignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    Axis direction = Axis.horizontal,
    bool enableReorder = true,
    double spacing = 0.0,
    ScrollController controller,
    ValueListenable<dynamic> valueListenable,
    BuildDraggableFeedback buildDraggableFeedback,
    BuildItemsContainer buildItemsContainer,
    ScrollController scrollController,
    Widget footer,
    List<Widget> header,
    bool ignorePrimaryScrollController = false,
    int maxMainAxisCount,
    int minMainAxisCount,
    bool needsLongPressDraggable = true,
    NoReorderCallback onNoReorder,
    ReorderStartedCallback onReorderStarted,
    EdgeInsets padding,
    Duration reorderAnimationDuration,
    double runSpacing = 0.0,
    Duration scrollAnimationDuration = const Duration(milliseconds: 200),
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics scrollPhysics,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
  }) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 350,
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 20,
                  bottom: 10,
                ),
                child: ValueListenableBuilder(
                  builder: (context, value, child) {
                    return ReorderableWrap(
                      alignment: alignment,
                      children: children,
                      onReorder: onReorder,
                      buildDraggableFeedback: buildDraggableFeedback,
                      buildItemsContainer: buildItemsContainer,
                      controller: scrollController,
                      crossAxisAlignment: crossAxisAlignment,
                      direction: direction,
                      enableReorder: enableReorder,
                      footer: footer,
                      header: header,
                      ignorePrimaryScrollController:
                          ignorePrimaryScrollController,
                      key: key,
                      maxMainAxisCount: maxMainAxisCount,
                      minMainAxisCount: minMainAxisCount,
                      needsLongPressDraggable: needsLongPressDraggable,
                      onNoReorder: onNoReorder,
                      onReorderStarted: onReorderStarted,
                      padding: padding,
                      reorderAnimationDuration: reorderAnimationDuration,
                      runAlignment: alignment,
                      runSpacing: runSpacing,
                      scrollAnimationDuration: scrollAnimationDuration,
                      scrollDirection: scrollDirection,
                      scrollPhysics: scrollPhysics,
                      spacing: spacing,
                      textDirection: textDirection,
                      verticalDirection: verticalDirection,
                    );
                  },
                  valueListenable: valueListenable,
                ),
              );
            });
      },
      icon: Icon(Icons.filter_alt_rounded),
    );
  }
}
