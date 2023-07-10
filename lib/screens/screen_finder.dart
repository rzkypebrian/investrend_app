import 'package:Investrend/component/avatar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/serializeable.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/base_state.dart';
import 'package:Investrend/screens/screen_coming_soon.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenFinder extends StatefulWidget {
  final bool showStockOnly;
  final String watchlistName;
  final List<Stock> fromListStocks;
  const ScreenFinder(
      {this.showStockOnly = false,
      this.watchlistName,
      this.fromListStocks,
      Key key})
      : super(key: key);

  @override
  _ScreenFinderState createState() => _ScreenFinderState(
      this.showStockOnly, this.watchlistName, this.fromListStocks);
}

class _ScreenFinderState extends BaseStateWithTabs<ScreenFinder> {
  final bool showStockOnly;
  final String watchlistName;
  final List<Stock> fromListStocks;
  _ScreenFinderState(
      this.showStockOnly, this.watchlistName, this.fromListStocks)
      : super('/finder');

  String timeCreation = '-';
  TextEditingController _searchFilterController;
  List<Stock> listStocks = List<Stock>.empty(growable: true);
  List<People> listPeoples = List<People>.empty(growable: true);
  bool watchlistMode = false;
  @override
  void initState() {
    super.initState();
    timeCreation = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    _searchFilterController = new TextEditingController();

    if (showStockOnly) {
      if (fromListStocks != null) {
        listStocks.addAll(fromListStocks);
      } else {
        listStocks.addAll(InvestrendTheme.storedData.listStock);
      }
    }
    //watchlistMode = watchlist != null;
    watchlistMode = !StringUtils.isEmtpy(watchlistName);

    /*
    if (InvestrendTheme.storedData.listFinderRecent.isEmpty) {
      InvestrendTheme.storedData.listFinderRecent.add(People(
          'Emma Watson', '@ewatson', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU'));
      InvestrendTheme.storedData.listFinderRecent.add(InvestrendTheme.storedData.listStock.elementAt(0));
      InvestrendTheme.storedData.listFinderRecent.add(People('Apotik Watson', '@awatson', ''));
      InvestrendTheme.storedData.listFinderRecent.add(InvestrendTheme.storedData.listStock.elementAt(100));
      InvestrendTheme.storedData.listFinderRecent.add(
          People('Watson', '@ewatson', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhMUJGKzrxVoM2r8dLjVenLwcP-idh11n5Fw&usqp=CAU'));
      InvestrendTheme.storedData.listFinderRecent.add(InvestrendTheme.storedData.listStock.elementAt(200));
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: createAppBar(context),
      body: showStockOnly
          ? buildBaseResultStockOnly(context, paddingBottom)
          : buildBaseTab(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  Widget buildBaseResultStockOnly(BuildContext context, double paddingBottom) {
    return resultTabStocks(context);
  }

  Widget buildBaseTab(BuildContext context, double paddingBottom) {
    return DefaultTabController(
      length: tabsLength(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: createTabs(context),
        body: createBody(context, paddingBottom),
      ),
    );
  }

  @override
  void dispose() {
    _searchFilterController.dispose();
    super.dispose();
  }

  List<String> tabsFinder = [
    'finder_tabs_stocks_title'.tr(),
    'finder_tabs_people_title'.tr(),
  ];

  @override
  int tabsLength() {
    return tabsFinder.length;
  }

  void onTextChanged(String textToSearch) {
    textToSearch = textToSearch.toLowerCase();
    print('onTextChanged : [$textToSearch] size : ' +
        InvestrendTheme.storedData.listStock.length.toString());
    if (StringUtils.isEmtpy(textToSearch)) {
      listStocks.clear();
      if (showStockOnly) {
        if (fromListStocks != null) {
          listStocks.addAll(fromListStocks);
        } else {
          listStocks.addAll(InvestrendTheme.storedData.listStock);
        }
      }
    } else {
      listStocks.clear();
      List<Stock> byCodes = List<Stock>.empty(growable: true);
      List<Stock> byName = List<Stock>.empty(growable: true);
      List<Stock> byContainsCode = List<Stock>.empty(growable: true);
      List<Stock> byContainsName = List<Stock>.empty(growable: true);

      List<Stock> source;
      if (fromListStocks != null) {
        source = fromListStocks;
      } else {
        source = InvestrendTheme.storedData.listStock;
      }

      //InvestrendTheme.storedData.listStock.forEach((stock) {
      source.forEach((stock) {
        String code = stock.code;
        String name = stock.name;
        code = code.toLowerCase();
        name = name.toLowerCase();
        //print(code);
        print('onTextChanged : [$textToSearch] [code:$code] [name:$name]');
        if (code.startsWith(textToSearch)) {
          byCodes.add(stock);
        } else if (name.startsWith(textToSearch)) {
          byName.add(stock);
        } else if (code.contains(textToSearch)) {
          byContainsCode.add(stock);
        } else if (name.contains(textToSearch)) {
          byContainsName.add(stock);
        }
      });
      if (byCodes != null) {
        listStocks.addAll(byCodes);
      }
      if (byName != null) {
        listStocks.addAll(byName);
      }
      if (byContainsCode != null) {
        listStocks.addAll(byContainsCode);
      }
      if (byContainsName != null) {
        listStocks.addAll(byContainsName);
      }
    }
    print('onTextChanged : $textToSearch  found : ' +
        listStocks.length.toString());
    setState(() {});
  }

  Widget createStockRow(BuildContext context, Stock stock,
      {VoidCallback onDelete}) {
    String code = stock.code;

    List<Widget> rows = [
      AvatarIconStocks(
        size: 50,
        imageUrl:
            'https://www.investrend.co.id/mobile/assets/stocks_logo/$code.jpg',
        label: code.substring(0, 2),
        cached: true,
      ),
      SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.code,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Text(
              stock.name,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyText2.fontSize - 1),
            ),
          ],
        ),
      ),
      SizedBox(
        width: 10.0,
      ),
    ];
    if (onDelete != null) {
      rows.add(IconButton(
          // icon: Icon(
          //   Icons.clear,
          //   color: Colors.grey,
          // ),
          icon: Image.asset(
            'images/icons/action_clear.png',
            color: InvestrendTheme.of(context).greyLighterTextColor,
            width: 12.0,
            height: 12.0,
          ),
          onPressed: onDelete));
      rows.add(SizedBox(
        width: 10.0,
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(
          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
      child: Row(
        children: rows,
      ),
    );
  }

  Widget createPeopleRow(BuildContext context, People people,
      {VoidCallback onDelete}) {
    String name = people.name;
    String label = StringUtils.getFirstDigitNameTwo(name);

    List<Widget> rows = [
      AvatarIconStocks(
        size: 50,
        imageUrl: people.urlTumbnail,
        label: label,
        cached: true,
      ),
      SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              people.name,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Text(
              people.username,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyText2.fontSize - 1),
            ),
          ],
        ),
      ),
      SizedBox(
        width: 10.0,
      ),
    ];
    if (onDelete != null) {
      rows.add(IconButton(
          icon: Image.asset(
            'images/icons/action_clear.png',
            color: InvestrendTheme.of(context).greyLighterTextColor,
            width: 12.0,
            height: 12.0,
          ),
          // icon: Icon(
          //   Icons.clear,
          //   color: Colors.grey,
          // ),
          onPressed: onDelete));
      rows.add(SizedBox(
        width: 10.0,
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(
          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
      child: Row(
        children: rows,
      ),
    );
  }

  Widget createAppBar(BuildContext context) {
    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,

      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: false,
      automaticallyImplyLeading: false,

      //toolbarHeight: 0.0,
      title: Hero(
        tag: 'finder_field',
        child: Material(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            alignment: Alignment.center,
            height: InvestrendTheme.appBarHeight,
            child: TextField(
              style: InvestrendTheme.of(context).small_w400_compact,
              controller: _searchFilterController,
              autofocus: true,
              onChanged: onTextChanged,
              decoration: new InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                border: new OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                enabledBorder: new OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                focusedBorder: new OutlineInputBorder(
                  //gapPadding: 0.0,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  borderSide: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                filled: true,
                prefixIcon: new Icon(
                  Icons.search,
                  //color: InvestrendTheme.of(context).textGrey,
                  color: InvestrendTheme.of(context).appBarActionTextColor,
                  size: 25.0,
                ),
                hintText: 'title_search_hint'.tr(),
                fillColor: InvestrendTheme.of(context).tileBackground,
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (watchlistMode) {
              /*
              Watchlist.save(context.read(watchlistChangeNotifier).getAll()).then((value) {
                //showWatchlist(context);
                InvestrendTheme.of(context).showSnackBar(context, 'finder_saving_to'.tr() + watchlist?.name);

                FocusScope.of(context).requestFocus(new FocusNode());
                Navigator.pop(context, watchlistName);
              });
              */
              FocusScope.of(context).requestFocus(new FocusNode());
              Navigator.pop(context, watchlistName);
            } else {
              FocusScope.of(context).requestFocus(new FocusNode());
              Navigator.pop(context, null);
            }
            //InvestrendTheme.of(context).showSnackBar(context, 'Action cancel');
          },
          child: Text(
            watchlistMode
                ? 'finder_button_save'.tr()
                : 'finder_button_cancel'.tr(),
            style: Theme.of(context).textTheme.button.copyWith(
                color: InvestrendTheme.of(context).appBarActionTextColor,
                fontWeight: FontWeight.normal),
          ),
        ),
      ],
      /*
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // + 10.0 // here the desired height
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // SizedBox(
          //   height: 10.0,
          // ),
          ComponentCreator.divider(context, thickness: 2.0),
          TabBar(
            isScrollable: true,
            tabs: List<Widget>.generate(
              tabsFinder.length,
              (int index) {
                print(tabsFinder[index]);
                return new Tab(text: tabsFinder[index]);
              },
            ),
          ),
        ]),
      ),
      */
    );
  }

  Widget createTabs(BuildContext context) {
    return TabBar(
      labelPadding:
          InvestrendTheme.paddingTab, //EdgeInsets.symmetric(horizontal: 12.0),
      controller: pTabController,
      isScrollable: true,
      tabs: List<Widget>.generate(
        tabsFinder.length,
        (int index) {
          print(tabsFinder[index]);
          return new Tab(text: tabsFinder[index]);
        },
      ),
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {
    return TabBarView(
      controller: pTabController,
      children: List<Widget>.generate(
        tabsFinder.length,
        (int index) {
          print(tabsFinder[index]);
          if (index == 0 &&
              ((listStocks != null && listStocks.isNotEmpty) ||
                  showStockOnly)) {
            return resultTabStocks(context);
          } else if (index ==
              1 /*&& listPeoples != null && listPeoples.isNotEmpty */) {
            //return resultTabPeoples(context);

            return ScreenComingSoon();
          } else {
            return resultTabRecent(context);
          }
          // return Container(
          //   child: Center(
          //     child: Text(tabsFinder[index]),
          //   ),
          // );
        },
      ),
    );
  }

  /*
  DefaultTabController.of(context).
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: DefaultTabController(
        length: tabsFinder.length,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: createTabs(context),
          body: createBody(context),
        ),
      ),
    );

    // return DefaultTabController(
    //   length: tabsFinder.length,
    //   child: Scaffold(
    //     backgroundColor: Theme.of(context).backgroundColor,
    //     appBar: createAppBar(context),
    //     body: createBody(context),
    //   ),
    // );

  }
  */
  final int MAX_RECENT = 25;
  void saveToRecent(var recent) {
    int foundIndex = -1;
    int count = InvestrendTheme.storedData.listFinderRecent.length;
    for (int i = 0; i < count; i++) {
      var existing = InvestrendTheme.storedData.listFinderRecent.elementAt(i);
      if (existing is Stock && recent is Stock) {
        String code = existing.code;
        if (StringUtils.equalsIgnoreCase(recent.code, code)) {
          foundIndex = i;
          break;
        }
      } else if (existing is People && recent is People) {
        String username = existing.username;
        if (StringUtils.equalsIgnoreCase(recent.username, username)) {
          foundIndex = i;
          break;
        }
      }
    }
    if (foundIndex >= 0) {
      InvestrendTheme.storedData.listFinderRecent.removeAt(foundIndex);
    }
    InvestrendTheme.storedData.listFinderRecent.insert(0, recent);
    if (InvestrendTheme.storedData.listFinderRecent.length >= MAX_RECENT) {
      InvestrendTheme.storedData.listFinderRecent.removeLast();
    }
    InvestrendTheme.storedData.save();
    /*
    if(!InvestrendTheme.storedData.listFinderRecent.contains(recent)){
      InvestrendTheme.storedData.listFinderRecent.insert(0, recent);

      if(InvestrendTheme.storedData.listFinderRecent.length >= MAX_RECENT){
        InvestrendTheme.storedData.listFinderRecent.removeLast();
      }
      InvestrendTheme.storedData.save();
    }
     */
  }

  Widget resultTabStocks(BuildContext context) {
    int countStock = listStocks != null ? listStocks.length : 0;
    if (showStockOnly) {
      countStock += 1;
    }
    Watchlist watchlist;
    if (watchlistMode) {
      watchlist = context
          .read(watchlistChangeNotifier)
          .getWatchlistByName(watchlistName);
    }
    return ListView.separated(
      shrinkWrap: false,
      itemCount: countStock,
      separatorBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return SizedBox(
            width: 1.0,
          );
        }
        // if(showStockOnly){
        //   return Padding(
        //     padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        //     child: ComponentCreator.divider(context, thickness: 1.0),
        //   );
        //
        // }
        return Padding(
          padding: InvestrendTheme.paddingTab,
          //padding: EdgeInsets.only(left: InvestrendTheme.paddingTab, right: InvestrendTheme.paddingTab),
          child: ComponentCreator.divider(context, thickness: 1.0),
        );
      },
      itemBuilder: (BuildContext context, int index) {
        if (showStockOnly) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: InvestrendTheme.cardPaddingGeneral,
                  right: InvestrendTheme.cardPaddingGeneral,
                  top: 12.0,
                  bottom: 12.0),
              //padding: InvestrendTheme.paddingTab,
              child: Text(
                'finder_stocks_list_label'.tr(),
                style: InvestrendTheme.of(context)
                    .regular_w400_compact
                    .copyWith(
                        color:
                            InvestrendTheme.of(context).greyLighterTextColor),
              ),
            );
          }
          Stock stock = listStocks.elementAt(index - 1);
          String code = stock.code;
          Widget addRemove;
          if (watchlistMode && watchlist != null) {
            bool canAdd = !StringUtils.isEmtpy(stock.code) &&
                !watchlist.stocks.contains(code);

            if (canAdd) {
              addRemove = TextButton(
                  onPressed: () {
                    if (watchlist.count() <
                        InvestrendTheme.MAX_STOCK_PER_WATCHLIST) {
                      watchlist.addStock(stock.code);
                      Watchlist.save(
                              context.read(watchlistChangeNotifier).getAll())
                          .then((value) {
                        setState(() {});
                      });
                    } else {
                      InvestrendTheme.of(context)
                          .showSnackBar(context, 'watchlist_full_label'.tr());
                    }
                  },
                  child: Text(
                    "finder_add_to_watchlist".tr(),
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact_greyDarker,
                  ));
            } else {
              addRemove = TextButton(
                  onPressed: () {
                    watchlist.removeStock(stock.code);
                    Watchlist.save(
                            context.read(watchlistChangeNotifier).getAll())
                        .then((value) {
                      setState(() {});
                    });
                  },
                  child: Text(
                    "finder_remove_from_watchlist".tr(),
                    style: InvestrendTheme.of(context)
                        .more_support_w400_compact_greyDarker,
                  ));
            }
          }
          return ListTile(
            visualDensity: VisualDensity.compact,
            //contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 0.0 ),
            contentPadding: InvestrendTheme.paddingTab,
            //title: Text(stock.code,style: InvestrendTheme.of(context).regular_w600_compact,),
            title: Text(
              stock.code,
              style: InvestrendTheme.of(context).regular_w500_compact,
            ),
            subtitle: Text(
              stock.name,
              //style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: Theme.of(context).textTheme.bodyText2.fontSize - 1, height: 1.3, color: InvestrendTheme.of(context).greyDarkerTextColor),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyText2.fontSize - 1,
                  height: 1.3,
                  color: InvestrendTheme.of(context).greyDarkerTextColor),
            ),
            trailing: addRemove,
            onTap: () {
              print('clicked : ' + code);
              if (watchlistMode && watchlist != null) {
              } else {
                saveToRecent(stock);

                FocusScope.of(context).requestFocus(new FocusNode());
                Navigator.pop(context, stock);
              }
            },
          );
        }
        Stock stock = listStocks.elementAt(index);
        String code = stock.code;
        return InkWell(
          child: createStockRow(context, stock),
          onTap: () {
            print('clicked : ' + code);
            saveToRecent(stock);
            /*
            if(!InvestrendTheme.storedData.listFinderRecent.contains(stock)){
              InvestrendTheme.storedData.listFinderRecent.insert(0, stock);

              InvestrendTheme.storedData.listFinderRecent.length
              InvestrendTheme.storedData.save();
            }
            */
            //InvestrendTheme.storedData.save().then((value) => InvestrendTheme.of(context).showSnackBar(context, 'saved to disk'));

            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.pop(context, stock);
          },
        );
      },
    );
  }

  Widget resultTabPeoples(BuildContext context) {
    return ListView.separated(
      shrinkWrap: false,
      //padding: const EdgeInsets.all(8),
      itemCount: listPeoples.length,
      separatorBuilder: (BuildContext context, int index) {
        return ComponentCreator.divider(context);
      },
      itemBuilder: (BuildContext context, int index) {
        People people = listPeoples.elementAt(index);
        String name = people.name;
        return InkWell(
          child: createPeopleRow(context, people),
          onTap: () {
            print('clicked : ' + name);

            saveToRecent(people);

            FocusScope.of(context).requestFocus(new FocusNode());
            Navigator.pop(context, people);
          },
        );
      },
    );
  }

  Widget resultTabRecent(BuildContext context) {
    return ListView.separated(
      shrinkWrap: false,
      //padding: const EdgeInsets.all(8),
      itemCount: InvestrendTheme.storedData.listFinderRecent.length + 1,
      separatorBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return SizedBox(
            width: 1.0,
          );
        }
        return Padding(
          padding: InvestrendTheme.paddingTab,
          child: ComponentCreator.divider(context),
        );
      },
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.all(InvestrendTheme.cardPaddingGeneral),
            child: Text(
              'finder_recent_search_label'.tr(),
              style: InvestrendTheme.of(context).small_w400_compact.copyWith(
                  color: InvestrendTheme.of(context).greyLighterTextColor),
            ),
          );
        } else {
          int realIndex = index - 1;
          var object =
              InvestrendTheme.storedData.listFinderRecent.elementAt(realIndex);
          if (object is People) {
            String name = object.name;
            return InkWell(
              child: createPeopleRow(context, object, onDelete: () {
                print('onDelete : ' + name);
                InvestrendTheme.storedData.listFinderRecent.remove(object);
                var future = InvestrendTheme.storedData.save();
                future.then((value) => {setState(() {})});
              }),
              // onTap: ()=> onChooseFromRecent(object, realIndex),
              onTap: () {
                print('clicked : ' + name);
                InvestrendTheme.storedData.listFinderRecent.remove(object);
                saveToRecent(object);
                FocusScope.of(context).requestFocus(new FocusNode());
                Navigator.pop(context, object);
              },
            );
          } else if (object is Stock) {
            String code = object.code;
            return InkWell(
              child: createStockRow(context, object, onDelete: () {
                print('onDelete : ' + code);
                InvestrendTheme.storedData.listFinderRecent.remove(object);
                var future = InvestrendTheme.storedData.save();
                future.then((value) => {setState(() {})});
              }),
              onTap: () {
                print('clicked : ' + code);
                Stock stock = InvestrendTheme.storedData.findStock(code);
                if (stock != null) {
                  InvestrendTheme.storedData.listFinderRecent.remove(object);
                  saveToRecent(object);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  Navigator.pop(context, stock);
                }
              },
            );
          } else {
            return Text('????');
          }
        }
      },
    );
  }

  @override
  void onActive() {
    // TODO: implement onActive
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }
}
