// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:Investrend/component/bottom_sheet/bottom_sheet_watchlist.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/button_rounded.dart';
import 'package:Investrend/component/empty_label.dart';
import 'package:Investrend/component/rows/row_watchlist.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/serializeable.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenSearchWatchlist extends StatefulWidget {
  final TabController? tabController;
  final int tabIndex;
  final ValueNotifier<bool>? visibilityNotifier;

  ScreenSearchWatchlist(this.tabIndex, this.tabController,
      {Key? key, this.visibilityNotifier})
      : super(key: key);

  @override
  _ScreenSearchWatchlistState createState() =>
      _ScreenSearchWatchlistState(tabIndex, tabController,
          visibilityNotifier: visibilityNotifier);
}

/*
enum SortWatchlist {
  A_to_Z , Z_to_A,
}
extension SortWatchlistExtension on SortWatchlist {
  String get text {
    switch (this) {
      case SortWatchlist.A_to_Z:
        return 'watchlist_sort_by_a_to_z'.tr();
      case SortWatchlist.Z_to_A:
        return 'watchlist_sort_by_z_to_a'.tr();
      case SortWatchlist.AmendBuy:
        return '/amend_buy';
      case OrderType.AmendSell:
        return '/amend_sell';
      default:
        return '#unknown_routeName';
    }
  }
}
*/
class _ScreenSearchWatchlistState
    extends BaseStateNoTabsWithParentTab<ScreenSearchWatchlist> {
  //final GeneralPriceNotifier _watchlistDataNotifier = GeneralPriceNotifier(new GeneralPriceData());
  final WatclistPriceNotifier _watchlistDataNotifier =
      WatclistPriceNotifier(new WatchlistPriceData());
  final SlidableController slidableController = SlidableController();
  final ValueNotifier<int> _watchlistNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _sortNotifier = ValueNotifier<int>(0);
  final AutoSizeGroup groupBest = AutoSizeGroup();
  Timer? _timer;
  bool canTapRow = true;
  static const Duration _durationUpdate = Duration(milliseconds: 2500);

  _ScreenSearchWatchlistState(int tabIndex, TabController? tabController,
      {ValueNotifier<bool>? visibilityNotifier})
      : super('/search_watchlist', tabIndex, tabController,
            parentTabIndex: Tabs.Search.index,
            visibilityNotifier: visibilityNotifier);

  // @override
  // bool get wantKeepAlive => true;

  List<String> _sort_by_option = [
    'watchlist_sort_by_a_to_z'.tr(),
    'watchlist_sort_by_z_to_a'.tr(),
    'watchlist_sort_by_movers_highest'.tr(),
    'watchlist_sort_by_movers_lowest'.tr(),
    'watchlist_sort_by_price_highest'.tr(),
    'watchlist_sort_by_price_lowest'.tr(),
    'watchlist_sort_by_value_highest'.tr(),
    'watchlist_sort_by_value_lowest'.tr()
  ];

  void sort() {
    switch (_sortNotifier.value) {
      case 0: //a_to_z
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => a.code!.compareTo(b.code!));
        }
        break;
      case 1: // z_to_a
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => b.code!.compareTo(a.code!));
        }
        break;
      case 2: // movers_highest
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => b.percent!.compareTo(a.percent!));
        }
        break;
      case 3: // movers_lowest
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => a.percent!.compareTo(b.percent!));
        }
        break;
      case 4: // price_highest
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => b.price!.compareTo(a.price!));
        }
        break;
      case 5: // price_lowest
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => a.price!.compareTo(b.price!));
        }
        break;
      case 6: // value_highest
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => b.value!.compareTo(a.value!));

          // List<WatchlistPrice> list = _watchlistDataNotifier.value.datas;
          // list.sort(( a, b) => b.value.compareTo(a.value));
          // _watchlistDataNotifier.value.datas = list;
        }
        break;
      case 7: // value_lowest
        {
          _watchlistDataNotifier.value?.datas
              ?.sort((a, b) => a.value!.compareTo(b.value!));

          // List<WatchlistPrice> list = _watchlistDataNotifier.value.datas;
          // list.sort((a, b) => a.value.compareTo(b.value));
          // _watchlistDataNotifier.value.datas = list;
        }
        break;
    }
    _watchlistDataNotifier.notifyListeners();
    context
        .read(propertiesNotifier)
        .properties
        .saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
  }

  bool onProgress = false;

  double widthRight = 0;
  Future doUpdate({bool pullToRefresh = false}) async {
    if (!active) {
      print(routeName +
          '.doUpdate Aborted : ' +
          DateTime.now().toString() +
          "  active : $active  pullToRefresh : $pullToRefresh");
      return false;
    }

    if (mounted && context != null) {
      bool isForeground = context.read(dataHolderChangeNotifier).isForeground;
      if (!isForeground) {
        print(routeName +
            ' doUpdate ignored isForeground : $isForeground  isVisible : ' +
            isVisible().toString());
        return false;
      }
    }

    print(routeName +
        '.doUpdate : ' +
        DateTime.now().toString() +
        "  active : $active  pullToRefresh : $pullToRefresh");

    onProgress = true;

    Watchlist? activeWatchlist = context
        .read(watchlistChangeNotifier)
        .getWatchlist(_watchlistNotifier.value);
    if (activeWatchlist != null && activeWatchlist.stocks!.isNotEmpty) {
      try {
        print(routeName + ' try Summarys');
        String? codes = activeWatchlist.stocks?.join('_');

        final List<StockSummary>? stockSummarys = await InvestrendTheme
            .datafeedHttp
            .fetchStockSummaryMultiple(codes, 'RG');
        if (stockSummarys != null && stockSummarys.isNotEmpty) {
          //print(routeName + ' Future Summary DATA : ' + stockSummary.code + '  prev : ' + stockSummary.prev.toString());
          //_summaryNotifier.setData(stockSummary);
          //context.read(stockSummaryChangeNotifier).setData(stockSummary);
          _watchlistDataNotifier.updateBySummarys(stockSummarys,
              context: context);
          sort();
        } else {
          print(routeName + ' Future Summarys NO DATA');
        }
      } catch (e) {
        DebugWriter.information(
            routeName + ' Summarys Exception : ' + e.toString());
        print(e);
      }
    } else {
      print(routeName + ' Aborted due to Active Watchlist is EMPTY');
    }

    onProgress = false;
    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    return true;
  }

  Widget _options(BuildContext context) {
    return Container(
      //color: Colors.purple,
      padding: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        children: [
          /*
          OutlinedButton(
              onPressed: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 10.0,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    'button_filter'.tr(),
                    style: InvestrendTheme.of(context).more_support_w400_compact,
                  ),
                ],
              )),
          */
          ValueListenableBuilder(
            valueListenable: _watchlistNotifier,
            builder: (context, index, child) {
              String label = '';
              if (context.read(watchlistChangeNotifier).isEmpty()!) {
                label = 'search_watchlist_default_label'.tr();
              } else {
                Watchlist? activeWatchlist = context
                    .read(watchlistChangeNotifier)
                    .getWatchlist(index as int);
                if (activeWatchlist != null) {
                  label = activeWatchlist.name;
                }
              }

              return MaterialButton(
                  elevation: 0.0,
                  //visualDensity: VisualDensity.comfortable,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  color: InvestrendTheme.of(context).tileBackground,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: InvestrendTheme.of(context)
                            .more_support_w400_compact
                            ?.copyWith(
                                color: InvestrendTheme.of(context)
                                    .greyDarkerTextColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Image.asset(
                          'images/icons/arrow_down.png',
                          width: 10.0,
                          height: 10.0,
                        ),
                      ),
                      /*
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                      */
                    ],
                  ),
                  onPressed: () {
                    //InvestrendTheme.of(context).showSnackBar(context, 'Action choose Market');
                    showWatchlist(context);
                  });
            },
          ),
          Spacer(
            flex: 1,
          ),
          ButtonDropdown(
            _sortNotifier,
            _sort_by_option,
            clickAndClose: true,
          ),
        ],
      ),
    );
  }

  Widget buttonAddWatchlist(BuildContext context) {
    // TextStyle? style = InvestrendTheme.of(context)
    //     .regular_w600_compact
    //     ?.copyWith(color: Theme.of(context).colorScheme.secondary);
    // Color colorIcon = Theme.of(context).colorScheme.secondary;
    return Center(
      child: TextButton(
          onPressed: () => createWatchlist(context),
          child: Text('search_watchlist_add_button'.tr())),
    );
  }

  Widget buttonAddStock(BuildContext context) {
    // TextStyle? style = InvestrendTheme.of(context)
    //     .regular_w600_compact
    //     ?.copyWith(color: Theme.of(context).colorScheme.secondary);
    // Color colorIcon = Theme.of(context).colorScheme.secondary;
    return Center(
      child: TextButton(
          onPressed: () {
            Watchlist? activeWatchlist = context
                .read(watchlistChangeNotifier)
                .getWatchlist(_watchlistNotifier.value);
            if (activeWatchlist != null) {
              final result = InvestrendTheme.showFinderScreen(context,
                  showStockOnly: true, watchlistName: activeWatchlist.name);
              result.then((value) {
                loadActiveWatchlist(context);
              });
            } else {
              InvestrendTheme.of(context).showSnackBar(
                  context, 'error_watchlist_cant_find_active'.tr());
            }
          },
          child: Text('search_watchlist_add_stock_button'.tr())),
    );
  }

  TextEditingController controller = TextEditingController();

  Function? onSlideDelete(int index) {
    //IntCallback onSlideDelete(int index){
    Navigator.of(context).pop();
    print('onSlideDelete');
    Watchlist? toDelete =
        context.read(watchlistChangeNotifier).getWatchlist(index);
    String title = 'watchlist_info_title'.tr();

    String content =
        'confirmation_remove_label'.tr() + '\n\'' + toDelete!.name + '\' ?';
    String actionSave = 'button_yes'.tr();
    String actionCancel = 'button_cancel'.tr();

    VoidCallback onPressedYes = () {
      Navigator.of(context).pop();
      //_watchlistNotifier.value = 0;
      context.read(watchlistChangeNotifier).removeWatchlist(index);
      //_listWatchlist.add(Watchlist(controller.text));
      Watchlist.save(context.read(watchlistChangeNotifier).getAll())
          .then((value) {
        _watchlistNotifier.value = 0;
        showWatchlist(context);
        _watchlistNotifier.notifyListeners();
      });
    };

    VoidCallback onPressedNo = () {
      Navigator.of(context).pop();
      showWatchlist(context);
    };
    InvestrendTheme.of(context).showDialogPlatform(context, title, content,
        buttonYes: actionSave,
        buttonNo: actionCancel,
        onPressedYes: onPressedYes,
        onPressedNo: onPressedNo);

    /*
    if (Platform.isIOS) {
      // iOS-specific code
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  CupertinoDialogAction(
                    child: Text(action_save),
                    onPressed: () {
                      Navigator.of(context).pop();
                      //_watchlistNotifier.value = 0;
                      context.read(watchlistChangeNotifier).removeWatchlist(index);
                      //_listWatchlist.add(Watchlist(controller.text));
                      Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                        _watchlistNotifier.value = 0;
                        showWatchlist(context);
                        _watchlistNotifier.notifyListeners();
                      });
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(action_cancel),
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showWatchlist(context);
                    },
                  ),
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    child: Text(action_save),
                    onPressed: () {
                      Navigator.of(context).pop();
                      //_watchlistNotifier.value = 0;
                      context.read(watchlistChangeNotifier).removeWatchlist(index);
                      //_listWatchlist.add(Watchlist(controller.text));
                      Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                        _watchlistNotifier.value = 0;
                        showWatchlist(context);
                        _watchlistNotifier.notifyListeners();
                      });
                    },
                  ),
                  TextButton(
                    child: Text(action_cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showWatchlist(context);
                    },
                  ),
                ],
              ));
    }
    */
    return null;
  }

  void createWatchlist(BuildContext context) {
    //Navigator.of(context).pop();
    print('createWatchlist');
    controller.text = '';

    if (context.read(watchlistChangeNotifier).count()! >=
        InvestrendTheme.MAX_WATCHLIST) {
      String errorFull = 'error_maximum_create_watchlist'.tr();
      errorFull = errorFull.replaceFirst(
          '#MAX#', InvestrendTheme.MAX_WATCHLIST.toString());
      InvestrendTheme.of(context).showSnackBar(context, errorFull);
    } else {
      VoidCallback onCancelPressed = () {
        Navigator.of(context).pop();
        //showWatchlist(context);
      };
      VoidCallback onSavePressed = () {
        if (StringUtils.isEmtpy(controller.text)) {
          InvestrendTheme.of(context)
              .showSnackBar(context, 'error_watchlist_name_empty'.tr());
          return;
        }
        print(controller.text);
        Watchlist? existing = context
            .read(watchlistChangeNotifier)
            .getWatchlistByName(controller.text);
        if (existing != null) {
          String error = 'error_watchlist_already_exist'.tr();
          error = error.replaceFirst('#NAME#', controller.text);
          InvestrendTheme.of(context).showSnackBar(context, error);
          return;
        }
        //Navigator.of(context).pop();

        final Watchlist newWatchlist = Watchlist(controller.text);
        context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);

        //showWatchlist(context);

        Watchlist.save(context.read(watchlistChangeNotifier).getAll())
            .then((value) {
          Navigator.of(context).pop();
          final result = InvestrendTheme.showFinderScreen(context,
              showStockOnly: true, watchlistName: newWatchlist.name);
          result.then((value) {
            //showWatchlist(context);
            int usedIndex = context.read(watchlistChangeNotifier).count()! - 1;
            //usedIndex = min(usedIndex, 0);
            _watchlistNotifier.value = usedIndex;
            // if(usedIndex == 0){
            //   loadActiveWatchlist(context);
            // }
          });
        });
      };

      String title = 'new_watchlist_title'.tr();
      String actionSave = 'button_save'.tr();
      String actionCancel = 'button_cancel'.tr();
      if (Platform.isIOS) {
        // iOS-specific code
        showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
                  title: Text(title),
                  content: CupertinoTextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                        color: InvestrendTheme.of(context).blackAndWhiteText),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(actionSave),
                      onPressed: onSavePressed,
                    ),
                    CupertinoDialogAction(
                      child: Text(actionCancel),
                      isDestructiveAction: true,
                      onPressed: onCancelPressed,
                    ),
                  ],
                ));
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text(title),
                  content: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.name,
                    style: TextStyle(
                        color: InvestrendTheme.of(context).blackAndWhiteText),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                  ),
                  actions: [
                    TextButton(
                      child: Text(actionSave),
                      onPressed: onSavePressed,
                    ),
                    TextButton(
                      child: Text(actionCancel),
                      onPressed: onCancelPressed,
                    ),
                  ],
                ));
      }
    }
  }

  VoidCallback? onTapCreate() {
    Navigator.of(context).pop();
    print('onTapCreate');
    controller.text = '';

    if (context.read(watchlistChangeNotifier).count()! >=
        InvestrendTheme.MAX_WATCHLIST) {
      String errorFull = 'error_maximum_create_watchlist'.tr();
      errorFull = errorFull.replaceFirst(
          '#MAX#', InvestrendTheme.MAX_WATCHLIST.toString());
      InvestrendTheme.of(context).showSnackBar(context, errorFull);
    } else {
      String title = 'new_watchlist_title'.tr();
      String actionSave = 'button_save'.tr();
      String actionCancel = 'button_cancel'.tr();

      VoidCallback onPressedYes = () {
        if (StringUtils.isEmtpy(controller.text)) {
          InvestrendTheme.of(context)
              .showSnackBar(context, 'error_watchlist_name_empty'.tr());
          return;
        }
        print(controller.text);
        Watchlist? existing = context
            .read(watchlistChangeNotifier)
            .getWatchlistByName(controller.text);
        if (existing != null) {
          String error = 'error_watchlist_already_exist'.tr();
          error = error.replaceFirst('#NAME#', controller.text);
          InvestrendTheme.of(context).showSnackBar(context, error);
          return;
        }
        //Navigator.of(context).pop();

        final Watchlist newWatchlist = Watchlist(controller.text);
        context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);

        // _watchlistNotifier.value = context.read(watchlistChangeNotifier).count() -1;
        // showWatchlist(context);

        Watchlist.save(context.read(watchlistChangeNotifier).getAll())
            .then((value) {
          Navigator.of(context).pop();
          final result = InvestrendTheme.showFinderScreen(context,
              showStockOnly: true, watchlistName: newWatchlist.name);
          result.then((value) {
            // loadActiveWatchlist(context);
            // showWatchlist(context);
            _watchlistNotifier.value =
                context.read(watchlistChangeNotifier).count()! - 1;
            onActive();
            showWatchlist(context);
          });
        });
      };

      VoidCallback onPressedNo = () {
        Navigator.of(context).pop();
        showWatchlist(context);
      };

      InvestrendTheme.of(context).showDialogInputPlatform(
        context,
        controller,
        title,
        buttonYes: actionSave,
        buttonNo: actionCancel,
        onPressedYes: onPressedYes,
        onPressedNo: onPressedNo,
        maxInputLength: InvestrendTheme.MAX_WATCHLIST_NAME_CHARACTER,
      );
      /*
      if (Platform.isIOS) {
        // iOS-specific code
        showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
                  title: Text(title),
                  content: CupertinoTextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.name,
                    style: TextStyle(color: InvestrendTheme.of(context).blackAndWhiteText),
                    cursorColor: Theme.of(context).accentColor,
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(action_save),
                      onPressed: () {
                        if (StringUtils.isEmtpy(controller.text)) {
                          InvestrendTheme.of(context).showSnackBar(context, 'error_watchlist_name_empty'.tr());
                          return;
                        }
                        print(controller.text);
                        Watchlist existing = context.read(watchlistChangeNotifier).getWatchlistByName(controller.text);
                        if (existing != null) {
                          String error = 'error_watchlist_already_exist'.tr();
                          error = error.replaceFirst('#NAME#', controller.text);
                          InvestrendTheme.of(context).showSnackBar(context, error);
                          return;
                        }
                        Navigator.of(context).pop();

                        final Watchlist newWatchlist = Watchlist(controller.text);
                        context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);

                        showWatchlist(context);

                        Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                          Navigator.of(context).pop();
                          final result = InvestrendTheme.showFinderScreen(context, showStockOnly: true, watchlistName: newWatchlist.name);
                          result.then((value) {
                            showWatchlist(context);
                          });
                        });
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text(action_cancel),
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        showWatchlist(context);
                      },
                    ),
                  ],
                ));
      } else {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text(title),
                  content: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.name,
                    style: TextStyle(color: InvestrendTheme.of(context).blackAndWhiteText),
                    cursorColor: Theme.of(context).accentColor,
                  ),
                  actions: [
                    TextButton(
                      child: Text(action_save),
                      onPressed: () {
                        if (StringUtils.isEmtpy(controller.text)) {
                          InvestrendTheme.of(context).showSnackBar(context, 'error_watchlist_name_empty'.tr());
                          return;
                        }
                        print(controller.text);
                        Watchlist existing = context.read(watchlistChangeNotifier).getWatchlistByName(controller.text);
                        if (existing != null) {
                          String error = 'error_watchlist_already_exist'.tr();
                          error = error.replaceFirst('#NAME#', controller.text);
                          InvestrendTheme.of(context).showSnackBar(context, error);
                          return;
                        }
                        Navigator.of(context).pop();

                        final Watchlist newWatchlist = Watchlist(controller.text);
                        context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);

                        showWatchlist(context);

                        Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                          Navigator.of(context).pop();
                          final result = InvestrendTheme.showFinderScreen(context, showStockOnly: true, watchlistName: newWatchlist.name);
                          result.then((value) {
                            showWatchlist(context);
                          });
                        });
                        /*
                        Navigator.of(context).pop();
                        print(controller.text);
                        final Watchlist newWatchlist = Watchlist(controller.text);
                        context.read(watchlistChangeNotifier).addWatchlist(newWatchlist);
                        Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                          //showWatchlist(context);
                          final result = InvestrendTheme.showFinderScreen(context, showStockOnly: true, watchlistName: newWatchlist.name);
                          result.then((value) {
                            //showWatchlist(context);
                            Navigator.of(context).pop();
                            showWatchlist(context);
                          });
                        });
                         */
                      },
                    ),
                    TextButton(
                      child: Text(action_cancel),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showWatchlist(context);
                      },
                    ),
                  ],
                ));
      }
      */
    }
    return null;
  }

  VoidCallback? onSlideRename(int index) {
    Navigator.of(context).pop();
    Watchlist? toRename =
        context.read(watchlistChangeNotifier).getWatchlist(index);
    print('onSlideRename [$index] : ' + toRename!.name);
    controller.text = toRename.name;
    String title = 'rename_watchlist_title'.tr();
    String actionSave = 'button_save'.tr();
    String actionCancel = 'button_cancel'.tr();

    VoidCallback onPressedYes = () {
      if (StringUtils.isEmtpy(controller.text)) {
        InvestrendTheme.of(context)
            .showSnackBar(context, 'error_watchlist_name_empty'.tr());
        return;
      }
      print('onSlideRename new name: ' + controller.text);

      if (!StringUtils.equalsIgnoreCase(controller.text, toRename.name)) {
        Watchlist? existing = context
            .read(watchlistChangeNotifier)
            .getWatchlistByName(controller.text);
        if (existing != null) {
          String error = 'error_watchlist_already_exist'.tr();
          error = error.replaceFirst('#NAME#', controller.text);
          InvestrendTheme.of(context).showSnackBar(context, error);
          return;
        }
      }

      Navigator.of(context).pop();

      toRename.name = controller.text;
      print('onSlideRename saving new name: ' + toRename.name);
      context.read(watchlistChangeNotifier).replaceWatchlist(index, toRename);
      Watchlist.save(context.read(watchlistChangeNotifier).getAll())
          .then((value) {
        showWatchlist(context);
      });
    };
    VoidCallback onPressedNo = () {
      Navigator.of(context).pop();
      showWatchlist(context);
    };
    InvestrendTheme.of(context).showDialogInputPlatform(
        context, controller, title,
        buttonYes: actionSave,
        buttonNo: actionCancel,
        onPressedYes: onPressedYes,
        onPressedNo: onPressedNo,
        maxInputLength: InvestrendTheme.MAX_WATCHLIST_NAME_CHARACTER);
    /*
    if (Platform.isIOS) {
      // iOS-specific code
      showCupertinoDialog(
          context: context,
          builder: (_) =>
              CupertinoAlertDialog(
                title: Text(title),
                content: CupertinoTextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: InvestrendTheme
                      .of(context)
                      .blackAndWhiteText),
                  cursorColor: Theme
                      .of(context)
                      .accentColor,
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text(action_save),
                    onPressed: () {
                      if (StringUtils.isEmtpy(controller.text)) {
                        InvestrendTheme.of(context).showSnackBar(context, 'error_watchlist_name_empty'.tr());
                        return;
                      }
                      print(controller.text);

                      if (!StringUtils.equalsIgnoreCase(controller.text, toRename.name)) {
                        Watchlist existing = context.read(watchlistChangeNotifier).getWatchlistByName(controller.text);
                        if (existing != null) {
                          String error = 'error_watchlist_already_exist'.tr();
                          error = error.replaceFirst('#NAME#', controller.text);
                          InvestrendTheme.of(context).showSnackBar(context, error);
                          return;
                        }
                      }

                      Navigator.of(context).pop();

                      toRename.name = controller.text;

                      Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                        showWatchlist(context);
                      });
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(action_cancel),
                    isDestructiveAction: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showWatchlist(context);
                    },
                  ),
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text(title),
                content: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: InvestrendTheme
                      .of(context)
                      .blackAndWhiteText),
                  cursorColor: Theme
                      .of(context)
                      .accentColor,
                ),
                actions: [
                  TextButton(
                    child: Text(action_save),
                    onPressed: () {
                      if (StringUtils.isEmtpy(controller.text)) {
                        InvestrendTheme.of(context).showSnackBar(context, 'error_watchlist_name_empty'.tr());
                        return;
                      }
                      print(controller.text);

                      if (!StringUtils.equalsIgnoreCase(controller.text, toRename.name)) {
                        Watchlist existing = context.read(watchlistChangeNotifier).getWatchlistByName(controller.text);
                        if (existing != null) {
                          String error = 'error_watchlist_already_exist'.tr();
                          error = error.replaceFirst('#NAME#', controller.text);
                          InvestrendTheme.of(context).showSnackBar(context, error);
                          return;
                        }
                      }

                      Navigator.of(context).pop();

                      toRename.name = controller.text;

                      Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                        showWatchlist(context);
                      });
                    },
                  ),
                  TextButton(
                    child: Text(action_cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showWatchlist(context);
                    },
                  ),
                ],
              ));
    }
    */
    return null;
  }

  void showWatchlist(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return WatchlistBottomSheet(
            _watchlistNotifier,
            context.read(watchlistChangeNotifier).getAll(),
            onTapCreate: onTapCreate,
            onSlideDelete: onSlideDelete,
            onSlideRename: onSlideRename,
          );
        });
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) {
    return null;
  }

  //List<String> _listChipRange = <String>['1D', '1W', '1M', '3M', '6M', '1Y', '5Y'];
  Future onRefresh() {
    if (!active) {
      print(routeName + ' onRefresh force active');
      active = true;
      //onActive();

      canTapRow = true;
      loadActiveWatchlist(context);
      //doUpdate();
      _startTimer();
    }
    return doUpdate(pullToRefresh: true);
    //return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return RefreshIndicator(
      color: InvestrendTheme.of(context).textWhite,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onRefresh: onRefresh,
      child: ValueListenableBuilder(
          valueListenable: _watchlistDataNotifier,
          builder: (context, WatchlistPriceData? data, child) {
            bool? noWatchlist = context.read(watchlistChangeNotifier).isEmpty();
            //bool noStock = data == null || data.count() == 0;
            int countData = data == null ? 0 : data.count();
            bool noStock = countData == 0;

            Widget? buttonAdd;
            if (noWatchlist! || noStock) {
              if (noWatchlist) {
                buttonAdd = buttonAddWatchlist(context);
              } else if (noStock) {
                buttonAdd = buttonAddStock(context);
              } else {
                buttonAdd = EmptyLabel();
              }

              return ListView(
                padding: EdgeInsets.only(
                    top: InvestrendTheme.cardPadding,
                    bottom: InvestrendTheme.cardPaddingGeneral),
                children: [
                  _options(context),
                  Container(
                      //color: Colors.orange,
                      height: MediaQuery.of(context).size.width,
                      child: buttonAdd),
                ],
              );
            }
            Watchlist? active = context
                .read(watchlistChangeNotifier)
                .getWatchlist(_watchlistNotifier.value);
            if (active != null &&
                active.count() < InvestrendTheme.MAX_STOCK_PER_WATCHLIST) {
              buttonAdd = buttonAddStock(context);
            }
            return Column(
              children: [
                _options(context),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(
                        parent: ScrollPhysics(),
                      ),
                      shrinkWrap: false,
                      padding: EdgeInsets.only(
                          /*top: InvestrendTheme.cardPadding,*/ bottom:
                              InvestrendTheme.cardPaddingGeneral),
                      itemCount: countData /*data.count()*/ /*+ 1 */ +
                          (buttonAdd != null ? 1 : 0),
                      // separatorBuilder: (BuildContext context, int index) {
                      //   if(index == 0){
                      //     return SizedBox(width: 1.0,);
                      //   }
                      //   return Padding(
                      //     padding: EdgeInsets.only( left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                      //     child: ComponentCreator.divider(context),
                      //   );
                      // },
                      itemBuilder: (BuildContext context, int index) {
                        // if (index == 0) {
                        //   return _options(context);
                        // }
                        //int indexData = index - 1;
                        int indexData = index;
                        if (indexData >= countData /*data.count()*/) {
                          if (buttonAdd != null) {
                            return Center(child: buttonAdd);
                          } else {
                            return Center(
                                child: EmptyLabel(
                              text: 'infinity_label️'.tr(),
                            ));
                          }
                        }

                        GeneralPrice? generalPrice =
                            data?.datas?.elementAt(indexData);
                        WatchlistPrice? gp;
                        if (generalPrice is WatchlistPrice) {
                          gp = generalPrice;
                        }

                        return Slidable(
                          controller: slidableController,
                          closeOnScroll: true,
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.22,
                          secondaryActions: <Widget>[
                            TradeSlideAction(
                              'button_buy'.tr(),
                              InvestrendTheme.buyColor,
                              () {
                                print('buy clicked code : ' + gp!.code!);
                                Stock? stock = InvestrendTheme.storedData
                                    ?.findStock(gp.code);
                                if (stock == null) {
                                  print('buy clicked code : ' +
                                      gp.code! +
                                      ' aborted, not find stock on StockStorer');
                                  return;
                                }

                                context
                                    .read(primaryStockChangeNotifier)
                                    .setStock(stock);

                                //InvestrendTheme.push(context, ScreenTrade(OrderType.Buy), ScreenTransition.SlideLeft, '/trade');

                                bool hasAccount = context
                                        .read(dataHolderChangeNotifier)
                                        .user
                                        .accountSize() >
                                    0;
                                InvestrendTheme.pushScreenTrade(
                                    context, hasAccount,
                                    type: OrderType.Buy,
                                    initialPriceLot:
                                        PriceLot(gp.price?.toInt(), 0));
                                /*
                                  Navigator.push(context,
                                      CupertinoPageRoute(builder: (_) => ScreenTrade(OrderType.Buy), settings: RouteSettings(name: '/trade')));
                                  */
                              },
                              tag: 'button_buy',
                            ),
                            TradeSlideAction(
                              'button_sell'.tr(),
                              InvestrendTheme.sellColor,
                              () {
                                print('sell clicked code : ' + gp!.code!);
                                Stock? stock = InvestrendTheme.storedData
                                    ?.findStock(gp.code);
                                if (stock == null) {
                                  print('sell clicked code : ' +
                                      gp.code! +
                                      ' aborted, not find stock on StockStorer');
                                  return;
                                }

                                context
                                    .read(primaryStockChangeNotifier)
                                    .setStock(stock);
                                //InvestrendTheme.push(context, ScreenTrade(OrderType.Sell), ScreenTransition.SlideLeft, '/trade');

                                bool hasAccount = context
                                        .read(dataHolderChangeNotifier)
                                        .user
                                        .accountSize() >
                                    0;
                                InvestrendTheme.pushScreenTrade(
                                    context, hasAccount,
                                    type: OrderType.Sell,
                                    initialPriceLot:
                                        PriceLot(gp.price?.toInt(), 0));
                                /*
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => ScreenTrade(OrderType.Sell),
                                        settings: RouteSettings(name: '/trade'),
                                      ));
                                  */
                              },
                              tag: 'button_sell',
                            ),
                            // CancelSlideAction('button_cancel'.tr(), Theme.of(context).backgroundColor, () {
                            //   InvestrendTheme.of(context).showSnackBar(context, 'cancel');
                            // }),
                          ],
                          actions: <Widget>[
                            IconSlideAction(
                              caption: 'button_remove'.tr(),
                              color: Colors.orange,
                              icon: Icons.delete_forever_outlined,
                              onTap: () {
                                print('Clicked Remove on : ' + gp!.code!);
                                //InvestrendTheme.of(context).showSnackBar(context, 'Clicked Remove on : '+gp.code);
                                Watchlist? active = context
                                    .read(watchlistChangeNotifier)
                                    .getWatchlist(_watchlistNotifier.value);
                                bool? removed = active?.removeStock(gp.code);
                                if (removed!) {
                                  Watchlist.save(context
                                          .read(watchlistChangeNotifier)
                                          .getAll())
                                      .then((value) {
                                    InvestrendTheme.of(context).showSnackBar(
                                        context,
                                        gp!.code! +
                                            'search_watchlist_removed_from_label'
                                                .tr() +
                                            active!.name);
                                    int existing = _watchlistNotifier.value;
                                    _watchlistNotifier.value = existing + 1;
                                    _watchlistNotifier.value = existing;
                                  }).onError((error, stackTrace) {});
                                }
                              },
                              foregroundColor: InvestrendTheme.of(context)
                                  .textWhite /*Colors.white*/,
                            ),
                          ],
                          child: RowWatchlist(
                            gp,
                            groupBest: groupBest,
                            firstRow: (indexData == 0),
                            onTap: () {
                              print('clicked code : ' +
                                  gp!.code! +
                                  '  canTapRow : $canTapRow');
                              if (canTapRow) {
                                canTapRow = false;

                                Stock? stock = InvestrendTheme.storedData
                                    ?.findStock(gp.code);
                                if (stock == null) {
                                  print('clicked code : ' +
                                      gp.code! +
                                      ' aborted, not find stock on StockStorer');
                                  canTapRow = true;
                                  return;
                                }
                                context
                                    .read(primaryStockChangeNotifier)
                                    .setStock(stock);

                                Future.delayed(Duration(milliseconds: 200), () {
                                  canTapRow = true;
                                  InvestrendTheme.of(context)
                                      .showStockDetail(context);
                                });
                              }
                            },
                            paddingLeftRight:
                                InvestrendTheme.cardPaddingGeneral,
                            onPressedButtonCorporateAction: () =>
                                onPressedButtonCorporateAction(
                                    context, gp?.corporateAction),
                            //onPressedButtonSpecialNotation: ()=> onPressedButtonSpecialNotation(context, gp.notation),
                            onPressedButtonSpecialNotation: () =>
                                onPressedButtonImportantInformation(
                                    context, gp?.notation, gp?.suspendStock),
                            stockInformationStatus: gp?.status,
                            widthRight: _watchlistDataNotifier.widthRight,
                          ),
                          /*
                          child: RowGeneralPrice(
                            gp.code,
                            gp.price,
                            gp.change,
                            gp.percent,
                            gp.priceColor,
                            name: gp.name,
                            firstRow: (indexData == 0),
                            onTap: () {
                              print('clicked code : ' + gp.code + '  canTapRow : $canTapRow');
                              if (canTapRow) {
                                canTapRow = false;

                                Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                                if (stock == null) {
                                  print('clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
                                  canTapRow = true;
                                  return;
                                }
                                context.read(primaryStockChangeNotifier).setStock(stock);

                                Future.delayed(Duration(milliseconds: 200), () {
                                  canTapRow = true;
                                  InvestrendTheme.of(context).showStockDetail(context);
                                });
                              }
                            },
                            paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
                            priceDecimal: false,
                            changeDecimal: false,
                          ),
                          */
                        );
                      }),
                ),
              ],
            );
          }),
    );
  }

  void onPressedButtonImportantInformation(BuildContext context,
      List<Remark2Mapping>? notation, SuspendStock? suspendStock) {
    int count = notation == null ? 0 : notation.length;
    if (count == 0 && suspendStock == null) {
      print(routeName +
          '.onPressedButtonImportantInformation not showing anything');
      return;
    }
    print(routeName + '.onPressedButtonImportantInformation');
    List<Widget> childs = List.empty(growable: true);

    double height = 0;
    if (suspendStock != null) {
      String infoSuspend = 'suspended_time_info'.tr();

      DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
      DateFormat dateParser = DateFormat('yyyy-MM-dd');
      DateTime dateTime = dateParser.parseUtc(suspendStock.date!);
      print('dateTime : ' + dateTime.toString());
      //print('indexSummary.date : '+data.date+' '+data.time);
      String formatedDate = dateFormatter.format(dateTime);
      //String formatedTime = timeFormatter.format(dateTime);
      //infoSuspend = infoSuspend.replaceAll('#BOARD#', suspendStock.board);
      infoSuspend = infoSuspend.replaceAll('#DATE#', formatedDate);
      infoSuspend = infoSuspend.replaceAll('#TIME#', suspendStock.time!);
      //displayTime = infoTime;
      height += 25.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          'Suspended ' + suspendStock.board!,
          style: InvestrendTheme.of(context).small_w600,
        ),
      ));

      height += 50.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: RichText(
          text: TextSpan(
              text: '•  ',
              style: InvestrendTheme.of(context).small_w600,
              children: [
                TextSpan(
                  text: infoSuspend,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
        ),
      ));
    }
    bool titleSpecialNotation = true;
    for (int i = 0; i < count; i++) {
      /*
      Remark2Mapping remark2 = notation.elementAt(i);
      if(remark2 != null){
        if(remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(remark2.value, style: InvestrendTheme.of(context).small_w600,),
          ));

        }else {
          if(titleSpecialNotation){
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text('bottom_sheet_alert_title'.tr(), style: InvestrendTheme.of(context).small_w600,),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      }
       */

      Remark2Mapping? remark2 = notation?.elementAt(i);
      if (remark2 != null) {
        if (remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              remark2.code! + ' : ' + remark2.value!,
              style: InvestrendTheme.of(context).small_w600,
            ),
          ));
        } else {
          if (titleSpecialNotation) {
            titleSpecialNotation = false;
            height += 25.0;
            childs.add(Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                'bottom_sheet_alert_title'.tr(),
                style: InvestrendTheme.of(context).small_w600,
              ),
            ));
          }
          height += 40.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(
                  text: /*remark2.code + " : "*/ '•  ',
                  style: InvestrendTheme.of(context).small_w600,
                  children: [
                    TextSpan(
                      text: remark2.code,
                      style: InvestrendTheme.of(context).small_w600,
                    ),
                    TextSpan(
                      text: ' : ' + remark2.value!,
                      style: InvestrendTheme.of(context).small_w400,
                    )
                  ]),
            ),
          ));
        }
      }
    }
    if (childs.isNotEmpty) {
      showAlert(context, childs, childsHeight: height, title: ' ');
    }
  }

  /*
  void onPressedButtonSpecialNotation(BuildContext context, List<Remark2Mapping> notation) {
    List<Widget> childs = List.empty(growable: true);
    if (notation != null && notation.isNotEmpty) {
      notation.forEach((remark2) {
        if (remark2 != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: RichText(
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.value,
                  style: InvestrendTheme.of(context).small_w400,
                )
              ]),
            ),
          ));
        }
      });

      showAlert(context, childs, childsHeight: (childs.length * 40).toDouble());
    }
  }
  */
  void onPressedButtonCorporateAction(
      BuildContext context, List<CorporateActionEvent>? corporateAction) {
    print('onPressedButtonCorporateAction : ' + corporateAction.toString());

    List<Widget> childs = List.empty(growable: true);
    if (corporateAction != null && corporateAction.isNotEmpty) {
      corporateAction.forEach((CorporateActionEvent? ca) {
        if (ca != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ca.getInformationWidget(context),
          ));
        }
      });

      showAlert(context, childs,
          childsHeight: (childs.length * 50).toDouble(),
          title: 'Corporate Action');
    }
  }
  /*
  @override
  Widget createBody(BuildContext context, double paddingBottom) {
    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPaddingPlusMargin, bottom: InvestrendTheme.cardPaddingPlusMargin),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // CardGeneralPrice('search_currency_card_idr_rate_title'.tr(), _idrNotifier),
            // ComponentCreator.divider(context),
            // CardGeneralPrice('search_currency_card_cross_rate_title'.tr(), _crossNotifier),
            _options(context),
            //ChipsRange(_listChipRange, _rangeNotifier),
            // SizedBox(
            //   height: 8.0,
            // ),
            ValueListenableBuilder(
              valueListenable: _watchlistDataNotifier,
              builder: (context, GeneralPriceData data, child) {
                if (_watchlistDataNotifier.invalid() || data.count() == 0) {
                  return EmptyLabel(padding: const EdgeInsets.only(
                    top: 200.0,
                  ),);

                }
                return Column(
                  children: List<Widget>.generate(
                    data.count(),
                        (int index) {
                      GeneralPrice gp = data.datas.elementAt(index);
                      return Slidable(
                          controller: slidableController,
                          closeOnScroll: true,
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.22,
                          secondaryActions: <Widget>[
                            TradeSlideAction(
                              'button_buy'.tr(),
                              InvestrendTheme.buyColor,
                                  () {
                                print('buy clicked code : ' + gp.code);
                                Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                                if (stock == null) {
                                  print('buy clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
                                  return;
                                }

                                context.read(primaryStockChangeNotifier).setStock(stock);

                                //InvestrendTheme.push(context, ScreenTrade(OrderType.Buy), ScreenTransition.SlideLeft, '/trade');

                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => ScreenTrade(OrderType.Buy),
                                      settings: RouteSettings(name: '/trade'),
                                    ));
                              },
                              tag: 'button_buy',
                            ),
                            TradeSlideAction(
                              'button_sell'.tr(),
                              InvestrendTheme.sellColor,
                                  () {
                                print('sell clicked code : ' + gp.code);
                                Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                                if (stock == null) {
                                  print('sell clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
                                  return;
                                }

                                context.read(primaryStockChangeNotifier).setStock(stock);
                                //InvestrendTheme.push(context, ScreenTrade(OrderType.Sell), ScreenTransition.SlideLeft, '/trade');

                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => ScreenTrade(OrderType.Sell),
                                      settings: RouteSettings(name: '/trade'),
                                    ));
                              },
                              tag: 'button_sell',
                            ),
                            CancelSlideAction('button_cancel'.tr(), Theme
                                .of(context)
                                .backgroundColor, () {
                              InvestrendTheme.of(context).showSnackBar(context, 'cancel');
                            }),
                          ],
                          actions: <Widget>[
                            IconSlideAction(
                              caption: 'button_remove'.tr(),
                              color: Colors.orange,
                              icon: Icons.delete_forever_outlined,
                              onTap: () {
                                print('Clicked Remove on : ' + gp.code);
                                //InvestrendTheme.of(context).showSnackBar(context, 'Clicked Remove on : '+gp.code);
                                Watchlist active = context.read(watchlistChangeNotifier).getWatchlist(_watchlistNotifier.value);
                                bool removed = active.removeStock(gp.code);
                                if (removed) {
                                  Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                                    InvestrendTheme.of(context).showSnackBar(context, gp.code + ' removed from ' + active.name);
                                    int existing = _watchlistNotifier.value;
                                    _watchlistNotifier.value = existing + 1;
                                    _watchlistNotifier.value = existing;
                                  }).onError((error, stackTrace) {});
                                }
                              },
                              foregroundColor: Colors.white,
                            ),
                          ],
                          child: RowGeneralPrice(
                            gp.code,
                            gp.price,
                            gp.change,
                            gp.percent,
                            gp.priceColor,
                            name: gp.name,
                            firstRow: (index == 0),
                            onTap: () {
                              print('clicked code : ' + gp.code + '  canTapRow : $canTapRow');
                              if (canTapRow) {
                                canTapRow = false;

                                Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                                if (stock == null) {
                                  print('clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
                                  canTapRow = true;
                                  return;
                                }
                                context.read(primaryStockChangeNotifier).setStock(stock);

                                Future.delayed(Duration(milliseconds: 200), () {
                                  canTapRow = true;
                                  InvestrendTheme.of(context).showStockDetail(context);
                                });
                              }
                            },
                            paddingLeftRight: InvestrendTheme.cardPaddingPlusMargin,
                          ));
                    },
                  ),
                );
              },
            ),

            SizedBox(
              height: paddingBottom + 80,
            ),
          ],
        ),
      ),
    );
  }
  */

  @override
  void onActive() {
    //print(routeName + ' onActive');
    canTapRow = true;
    // int existing = _watchlistNotifier.value;
    // _watchlistNotifier.value = existing + 1;
    // _watchlistNotifier.value = existing;

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   doUpdate();
    //   _startTimer();
    // });

    // int existing = _watchlistNotifier.value;
    // _watchlistNotifier.value = existing + 1;
    // _watchlistNotifier.value = existing;
    //doUpdate();

    loadActiveWatchlist(context);
    doUpdate();
    _startTimer();

    // runPostFrame((){
    //   int existing = _watchlistNotifier.value;
    //   _watchlistNotifier.value = existing + 1;
    //   _watchlistNotifier.value = existing;
    //   //doUpdate();
    //   _startTimer();
    // });
  }

  bool loadActiveWatchlist(BuildContext context) {
    bool loaded = false;
    Watchlist? active = context
        .read(watchlistChangeNotifier)
        .getWatchlist(_watchlistNotifier.value);
    if (active != null) {
      //GeneralPriceData dataWatchlist = GeneralPriceData();
      WatchlistPriceData dataWatchlist = WatchlistPriceData();
      active.stocks?.forEach((code) {
        Stock? stock = InvestrendTheme.storedData?.findStock(code);
        if (stock != null) {
          //dataWatchlist.datas.add(GeneralPrice(stock.code, 0.0, 0.0, 0.0, name: stock.name));
          dataWatchlist.datas?.add(
              WatchlistPrice(stock.code, 0.0, 0.0, 0.0, stock.name, value: 0));
        } else {
          //dataWatchlist.datas.add(GeneralPrice(code, 0.0, 0.0, 0.0, name: '-'));
          dataWatchlist.datas
              ?.add(WatchlistPrice(code, 0.0, 0.0, 0.0, '-', value: 0));
        }
      });

      _watchlistDataNotifier.setValue(dataWatchlist);
      if (dataWatchlist.count() > 0) {
        loaded = true;
        sort();
      }
      // _stopTimer();
      // doUpdate();
      // _startTimer();
      context.read(propertiesNotifier).properties.saveInt(
          routeName, PROP_SELECTED_WATCHLIST, _watchlistNotifier.value);
    } else {
      _watchlistDataNotifier.setValue(null);
    }
    return loaded;
  }

  final String PROP_SELECTED_WATCHLIST = 'selectedWatchlist';
  final String PROP_SELECTED_SORT = 'selectedSort';

  @override
  void initState() {
    super.initState();
    _sortNotifier.addListener(sort);
    //load();
    _watchlistNotifier.addListener(() {
      if (mounted) {
        bool loaded = loadActiveWatchlist(context);

        _stopTimer();
        if (loaded) {
          doUpdate();
          _startTimer();
        }
        /*
        Watchlist active = context.read(watchlistChangeNotifier).getWatchlist(_watchlistNotifier.value);
        if (active != null) {
          GeneralPriceData dataWatchlist = GeneralPriceData();
          active.stocks.forEach((code) {
            Stock stock = InvestrendTheme.storedData.findStock(code);
            if (stock != null) {
              dataWatchlist.datas.add(GeneralPrice(stock.code, 0.0, 0.0, 0.0, name: stock.name));
            } else {
              dataWatchlist.datas.add(GeneralPrice(code, 0.0, 0.0, 0.0, name: '-'));
            }
          });
          _watchlistDataNotifier.setValue(dataWatchlist);
          _stopTimer();
          doUpdate();
          _startTimer();
        }else{
          _watchlistDataNotifier.setValue(null);
        }
        */
      }
    });
    runPostFrame(() {
      // #1 get properties
      int selectedWatchlist = context
          .read(propertiesNotifier)
          .properties
          .getInt(routeName, PROP_SELECTED_WATCHLIST, 0);
      int selectedSort = context
          .read(propertiesNotifier)
          .properties
          .getInt(routeName, PROP_SELECTED_SORT, 0);

      // #2 use properties
      int? countWatchlist = context.read(watchlistChangeNotifier).count();
      _watchlistNotifier.value = min(selectedWatchlist, countWatchlist! - 1);
      _sortNotifier.value = min(selectedSort, _sort_by_option.length - 1);

      // #3 check properties if changed, then save again
      if (selectedWatchlist != _watchlistNotifier.value) {
        context.read(propertiesNotifier).properties.saveInt(
            routeName, PROP_SELECTED_WATCHLIST, _watchlistNotifier.value);
      }
      if (selectedSort != _sortNotifier.value) {
        context
            .read(propertiesNotifier)
            .properties
            .saveInt(routeName, PROP_SELECTED_SORT, _sortNotifier.value);
      }

      bool loaded = loadActiveWatchlist(context);
      _stopTimer();
      if (loaded) {
        doUpdate();
        _startTimer();
      }
    });

    /*
    Future.delayed(Duration(milliseconds: 500), () {
      GeneralPriceData dataMovers = GeneralPriceData();
      dataMovers.datas.add(GeneralPrice('UNVR', '1.750', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Unilever Indonesia Tbk.'));
      dataMovers.datas.add(GeneralPrice('BOLA', '250', '-96,00', '-0,31%', InvestrendTheme.redText, name: 'Bali Bintang Sejahtera Tbk.'));
      dataMovers.datas.add(GeneralPrice('ASII', '7.100', '+96,00', '+0,31%', InvestrendTheme.greenText, name: 'Astra International Tbk.'));
      dataMovers.datas.add(GeneralPrice('ITIC', '470', '-30,00', '-0,31%', InvestrendTheme.redText, name: 'Indonesian Tobacco Tbk.'));
      dataMovers.datas.add(GeneralPrice('ELSA', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Elnusa Tbk.'));
      dataMovers.datas.add(GeneralPrice('BUMI', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Bumi resource'));
      dataMovers.datas.add(GeneralPrice('BBCA', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Bank BCA.'));
      dataMovers.datas.add(GeneralPrice('BSDE', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Bumi Serpong.'));
      dataMovers.datas.add(GeneralPrice('GGRM', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Gudang Garam.'));
      dataMovers.datas.add(GeneralPrice('AALI', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Astra Agro.'));
      dataMovers.datas.add(GeneralPrice('BJBR', '350', '-2,11', '-0,31%', InvestrendTheme.redText, name: 'Bank Jabar.'));
      _watchlistDataNotifier.setValue(dataMovers);
    });
    */
  }

  void _startTimer() {
    print(routeName + '._startTimer');
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(_durationUpdate, (timer) {
        print('_timer.tick : ' + _timer!.tick.toString());
        if (active) {
          if (onProgress) {
            print(routeName +
                ' timer aborted caused by onProgress : $onProgress');
          } else {
            doUpdate();
          }
        }
      });
    }
  }

  void _stopTimer() {
    print(routeName + '._stopTimer');
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _sortNotifier.dispose();
    _watchlistDataNotifier.dispose();
    _watchlistNotifier.dispose();
    _timer?.cancel();
    controller.dispose();
    //_rangeNotifier.dispose();
    super.dispose();
  }

  @override
  void onInactive() {
    _stopTimer();
    //print(routeName + ' onInactive');
    slidableController.activeState = null;
    canTapRow = true;
  }
}
