import 'package:Investrend/component/type_util.dart';
import 'package:Investrend/screens/tab_portfolio/screen_portfolio_detail.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class FilterPageTest extends StatefulWidget {
  List<Widget> children;
  ReorderCallback onReorder;
  WrapAlignment alignment;
  WrapAlignment runAlignment;
  WrapCrossAlignment crossAxisAlignment;
  Axis direction;
  bool enableReorder;
  double spacing;
  ScrollController controller;
  ValueNotifier<int> valueListenable;
  BuildDraggableFeedback buildDraggableFeedback;
  BuildItemsContainer buildItemsContainer;
  ScrollController scrollController;
  Widget footer;
  List<Widget> header;
  bool ignorePrimaryScrollController;
  int maxMainAxisCount;
  int minMainAxisCount;
  bool needsLongPressDraggable;
  NoReorderCallback onNoReorder;
  ReorderStartedCallback onReorderStarted;
  EdgeInsets padding;
  Duration reorderAnimationDuration;
  double runSpacing;
  Duration scrollAnimationDuration;
  Axis scrollDirection;
  ScrollPhysics scrollPhysics;
  TextDirection textDirection;
  VerticalDirection verticalDirection;
  ValueNotifier<List<String>> listOverviewNotifier;
  List<LabelValueColor> listOverview;

  FilterPageTest({
    Key key,
    this.onReorder,
    this.alignment = WrapAlignment.spaceBetween,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.direction = Axis.horizontal,
    this.enableReorder = true,
    this.valueListenable,
    this.buildDraggableFeedback,
    this.buildItemsContainer,
    this.spacing = 10.0,
    this.needsLongPressDraggable = false,
    this.children,
    this.controller,
    this.footer,
    this.header,
    this.ignorePrimaryScrollController = false,
    this.listOverview,
    this.listOverviewNotifier,
    this.maxMainAxisCount,
    this.minMainAxisCount,
    this.onNoReorder,
    this.onReorderStarted,
    this.padding,
    this.reorderAnimationDuration = const Duration(milliseconds: 200),
    this.runSpacing = 0.0,
    this.scrollAnimationDuration = const Duration(milliseconds: 200),
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.scrollPhysics,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
  }) : super(key: key) {
    this.listOverviewNotifier = ValueNotifier<List<String>>([]);
    // this.listOverview = [];
  }

  @override
  State<StatefulWidget> createState() => FilterPageTestState();
}

class FilterPageTestState extends State<FilterPageTest> with ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
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
                  valueListenable: widget.listOverviewNotifier,
                  builder: (context, value, child) {
                    return _createFilter(context);
                  },
                ),
              );
            });
      },
      icon: Icon(Icons.filter_alt_rounded),
    );
  }

  Widget _createFilter(BuildContext context) {
    return ReorderableWrap(
      alignment: widget.alignment, //alignment space between
      buildDraggableFeedback: widget.buildDraggableFeedback,
      buildItemsContainer: widget.buildItemsContainer,
      controller: widget.scrollController,
      crossAxisAlignment: widget.crossAxisAlignment,

      direction: widget.direction,
      enableReorder: widget.enableReorder,
      footer: widget.footer,
      header: widget.header,
      ignorePrimaryScrollController: widget.ignorePrimaryScrollController,
      key: widget.key,
      maxMainAxisCount: widget.maxMainAxisCount,
      minMainAxisCount: widget.minMainAxisCount,
      needsLongPressDraggable: widget.needsLongPressDraggable,
      onNoReorder: widget.onNoReorder,
      onReorderStarted: widget.onReorderStarted,
      padding: widget.padding,
      reorderAnimationDuration: widget.reorderAnimationDuration,
      runAlignment: widget.runAlignment,
      runSpacing: widget.runSpacing,
      scrollAnimationDuration: widget.scrollAnimationDuration,
      scrollDirection: widget.scrollDirection,
      scrollPhysics: widget.scrollPhysics,
      spacing: widget.spacing,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      onReorder: (int oldIndex, int newIndex) {
        setState(
          () {
            if (widget.listOverview[oldIndex].isShown == false) return;

            if (newIndex > oldIndex) {
              widget.listOverview
                  .insert(newIndex + 1, widget.listOverview[oldIndex]);
              widget.listOverview.removeAt(oldIndex);
            } else {
              widget.listOverview
                  .insert(newIndex, widget.listOverview[oldIndex]);
              widget.listOverview.removeAt(oldIndex + 1);
            }
            widget.listOverviewNotifier.notifyListeners();
          },
        );
      },
      children: List.generate(widget.listOverview.length, (index) {
        return Container(
          width: MediaQuery.of(context).size.width / 2 - 30,
          child: Row(
            children: [
              Checkbox(
                  value: widget.listOverview[index].isShown,
                  onChanged: (newValue) {
                    setState(() {
                      debugPrint("BISA DI KLIK !");
                      LabelValueColor lastShown = widget.listOverview
                              .where(
                                (e) => e.isShown == true,
                              )
                              .toList()
                              .isEmpty
                          ? widget.listOverview.first
                          : widget.listOverview
                              .where(
                                (e) => e.isShown == true,
                              )
                              .toList()
                              .last;

                      int lastShownIndex =
                          widget.listOverview.indexOf(lastShown);
                      print(
                          "data terakhir = ${lastShown.label} + posisi terakhir = $lastShownIndex + listoverview index = ${widget.listOverview[index].label}");
                      print("posisi terakhir $lastShownIndex");

                      widget.listOverview[index].isShown = newValue;

                      if (newValue == false) {
                        widget.listOverview.add(
                          widget.listOverview[index],
                        );
                        widget.listOverview.removeAt(index);
                      }

                      if (newValue == true) {
                        if (lastShownIndex > index) {
                          widget.listOverview.insert(
                            lastShownIndex + (lastShownIndex == 0 ? 0 : 1),
                            widget.listOverview[index],
                          );
                          widget.listOverview.removeAt(index);
                        } else {
                          widget.listOverview.insert(
                            lastShownIndex + (lastShownIndex == 0 ? 0 : 1),
                            widget.listOverview[index],
                          );
                          widget.listOverview.removeAt(index + 1);
                        }
                      }
                      widget.listOverviewNotifier.notifyListeners();
                    });
                  }),
              Expanded(
                child: Container(
                  child: Text(
                    widget.listOverview[index].label,
                  ),
                ),
              ),
              widget.listOverview[index].isShown == true
                  ? Icon(Icons.drag_handle_outlined)
                  : SizedBox(),
            ],
          ),
        );
      }),
    );
  }
}
