import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/serializeable.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WatchlistBottomSheet extends StatelessWidget {
  final ValueNotifier watchlistNotifier;
  final List<Watchlist>? watchlistOption;
  final VoidCallback? onTapCreate;
  final bool onClickClosed;
  final Function? onSlideDelete;
  final Function? onSlideRename;
  const WatchlistBottomSheet(this.watchlistNotifier, this.watchlistOption,
      {this.onTapCreate,
      this.onClickClosed = false,
      this.onSlideDelete,
      this.onSlideRename,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    int count = watchlistOption == null ? 0 : watchlistOption!.length + 1;
    //double contentHeight = padding + 44.0 + (44.0 * count) + padding + padding + 2.0 + 15.0;
    double buttonCloseHeight = 44.0;
    double buttonAddHeight = 44.0;
    double dividerHeight = 1.0;
    double safeAreaBottom = MediaQuery.of(context).viewPadding.bottom;
    double contentHeight = (44.0 * count) +
        buttonCloseHeight +
        buttonAddHeight +
        dividerHeight +
        safeAreaBottom;

    if (contentHeight < maxHeight && contentHeight > minHeight) {
      maxHeight = contentHeight;
    } else if (contentHeight < minHeight) {
      maxHeight = minHeight;
    }
    // maxHeight = min(contentHeight, maxHeight);
    // minHeight = min(minHeight, maxHeight);

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Container(
        padding: EdgeInsets.only(bottom: safeAreaBottom),
        // color: Colors.yellow,
        width: double.maxFinite,
        child: ValueListenableBuilder(
          valueListenable: watchlistNotifier,
          builder: (context, selectedIndex, child) {
            List<Widget> list = List.empty(growable: true);
            /*
            list.add(Padding(
              padding: EdgeInsets.only(top: padding, left: padding, right: padding),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    //icon: Icon(Icons.clear),
                    icon: Image.asset(
                      'images/icons/action_clear.png',
                      color: InvestrendTheme.of(context).greyLighterTextColor,
                      width: 12.0,
                      height: 12.0,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
            ));
            */
            int count = watchlistOption!.length;
            /*
            for (int i = 0; i < count; i++) {
              Watchlist ca = watchlistOption.elementAt(i);
              bool enable = true;
              String disableText = '';
              if(onClickClosed && ca.count() >= InvestrendTheme.MAX_STOCK_PER_WATCHLIST){
                enable = false;
                disableText = 'full_label'.tr();
              }
              list.add(createRow(context, ca.name, selectedIndex == i, i, enable: enable, disableText: disableText));
            }
            */
            if (onClickClosed) {
              List<StringIndex> listFull = List.empty(growable: true);
              List<StringIndex> listAvailable = List.empty(growable: true);
              for (int i = 0; i < count; i++) {
                Watchlist ca = watchlistOption!.elementAt(i);
                if (ca.count() < InvestrendTheme.MAX_STOCK_PER_WATCHLIST) {
                  listAvailable.add(StringIndex(name: ca.name, index: i));
                } else {
                  listFull.add(StringIndex(name: ca.name, index: i));
                }
              }
              for (int i = 0; i < listAvailable.length; i++) {
                StringIndex ca = listAvailable.elementAt(i);
                list.add(createRow(
                    context, ca.name, selectedIndex == ca.index, ca.index));
              }

              if (listFull.isNotEmpty) {
                list.add(Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'watchlist_full_label'.tr(),
                          style: InvestrendTheme.of(context)
                              .more_support_w400_compact
                              ?.copyWith(
                                  color: InvestrendTheme.of(context)
                                      .greyLighterTextColor),
                        ))));

                for (int i = 0; i < listFull.length; i++) {
                  StringIndex ca = listFull.elementAt(i);
                  list.add(createRow(
                      context, ca.name, selectedIndex == ca.index, ca.index,
                      enable: false));
                }
              }
            } else {
              for (int i = 0; i < count; i++) {
                Watchlist ca = watchlistOption!.elementAt(i);
                list.add(createRow(context, ca.name, selectedIndex == i, i));
              }
            }

            /*
            list.add(Padding(
              padding: EdgeInsets.only(left: padding, right: padding),
              child: ComponentCreator.divider(context),
            ));



            if(count < InvestrendTheme.MAX_WATCHLIST){
              list.add(Padding(
                padding: EdgeInsets.only(left: padding, right: padding, bottom: padding, top: 8.0),
                child: createRow(context, 'search_watchlist_add_button'.tr(), true, -1, onTap: onTapCreate),
              ));
            }else{
              list.add(Container(
                width: double.maxFinite,
                height: 44.0,
                child: Center(
                  child: Text('error_maximum_create_watchlist'.tr().replaceFirst('#MAX#', InvestrendTheme.MAX_WATCHLIST.toString()), style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),),
                ),
              ));
            }
            */

            Widget bottomWidget;
            if (count < InvestrendTheme.MAX_WATCHLIST) {
              bottomWidget = Padding(
                padding:
                    EdgeInsets.only(left: padding, right: padding, bottom: 8.0),
                child: createRow(
                    context, 'search_watchlist_add_button'.tr(), true, -1,
                    onTap: onTapCreate!),
              );
            } else {
              bottomWidget = Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(bottom: 8.0),
                height: 44.0,
                child: Center(
                  child: Text(
                    'error_maximum_create_watchlist'.tr().replaceFirst(
                        '#MAX#', InvestrendTheme.MAX_WATCHLIST.toString()),
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact
                        ?.copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor),
                  ),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: padding, left: padding, right: padding),
                  child: Align(
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
                ),
                Expanded(
                  flex: 1,
                  child: Scrollbar(
                    thickness: 2.0,
                    thumbVisibility: true,
                    child: ListView(
                      children: list,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: padding, right: padding, bottom: 8.0),
                  child: ComponentCreator.divider(context),
                ),
                bottomWidget,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget createRow(BuildContext context, String label, bool selected, int index,
      {VoidCallback? onTap, bool enable = true}) {
    TextStyle? style = InvestrendTheme.of(context).regular_w400_compact;
    //Color colorText = style.color;
    Color colorIcon = Colors.transparent;

    if (selected) {
      style = InvestrendTheme.of(context)
          .regular_w600_compact
          ?.copyWith(color: Theme.of(context).colorScheme.secondary);
      //colorText = Theme.of(context).accentColor;
      colorIcon = Theme.of(context).colorScheme.secondary;
    } else if (!enable) {
      style = style?.copyWith(
          color: InvestrendTheme.of(context).greyLighterTextColor);
    }

    bool useSlideAction =
        onTap == null && (onSlideDelete != null || onSlideRename != null);
    if (onTap == null && enable) {
      onTap = () {
        watchlistNotifier.value = index;
        if (onClickClosed) {
          Navigator.of(context).pop();
        }
      };
    }

    Widget row = Padding(
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        child: SizedBox(
          height: 44.0,
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      label,
                      style:
                          style, //InvestrendTheme.of(context).regular_w700_compact.copyWith(color: colorText),
                      textAlign: TextAlign.center,
                    )),
                (selected && index >= 0
                    ? Image.asset(
                        'images/icons/check.png',
                        color: colorIcon,
                        width: 20.0,
                        height: 20.0,
                      )
                    : SizedBox(
                        width: 20.0,
                        height: 20.0,
                      )),
              ],
            ),
            onPressed: onTap,
          ),
        ));

    if (useSlideAction) {
      List<Widget> listActionSlide = List.empty(growable: true);
      if (onSlideDelete != null) {
        listActionSlide.add(IconSlideAction(
          caption: 'button_remove'.tr(),
          color: Colors.orange,
          icon: Icons.delete_forever_outlined,
          onTap: () {
            //print('Clicked Remove on : '+label);
            //InvestrendTheme.of(context).showSnackBar(context, 'Clicked Remove on : '+label);
            onSlideDelete!(index);
          },
          foregroundColor:
              InvestrendTheme.of(context).textWhite /*Colors.white*/,
        ));
      }
      if (onSlideRename != null) {
        listActionSlide.add(IconSlideAction(
          caption: 'button_rename'.tr(),
          color: Colors.cyan,
          icon: Icons.drive_file_rename_outline,
          onTap: () {
            //print('Clicked Remove on : '+label);
            //InvestrendTheme.of(context).showSnackBar(context, 'Clicked Remove on : '+label);
            onSlideRename!(index);
          },
          foregroundColor:
              InvestrendTheme.of(context).textWhite /*Colors.white*/,
        ));
      }
      return Slidable(
        child: row,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.20,
        actions: listActionSlide,
      );
    } else {
      return row;
    }
  }
}

class StringIndex {
  final String name;
  final int index;

  const StringIndex({this.name = '', this.index = -1});
}
