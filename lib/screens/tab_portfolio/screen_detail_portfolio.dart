
import 'package:Investrend/component/bottom_sheet/bottom_sheet_alert.dart';
import 'package:Investrend/component/bottom_sheet/bottom_sheet_transaction_filter.dart';
import 'package:Investrend/component/button_order.dart';
import 'package:Investrend/component/component_app_bar.dart';
import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/rows/row_watchlist.dart';
import 'package:Investrend/component/slide_action_button.dart';
import 'package:Investrend/component/tapable_widget.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_holder.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/screens/screen_login_pin.dart';
import 'package:Investrend/screens/screen_main.dart';
import 'package:Investrend/screens/tab_portfolio/screen_detail_portfolio_historical.dart';
import 'package:Investrend/screens/tab_transaction/screen_transaction.dart';
import 'package:Investrend/screens/trade/screen_amend.dart';
import 'package:Investrend/screens/trade/screen_order_detail.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

class ScreenDetailPortfolio extends StatefulWidget {
  // final String init_code;
  // final String init_name;
  // final String init_account;
  // final StockPositionDetail init_portfolio;

  final StockPositionDetail init_portfolio;
  final String init_stock_code;
  final String init_stock_name;
  final String init_account_info;
  final String init_account;
  final String init_user;
  final String init_broker;
  final bool init_historical;

  const ScreenDetailPortfolio(
      this.init_portfolio,this.init_stock_code, this.init_stock_name, this.init_account_info
      , this.init_account, this.init_user, this.init_broker
      , {Key key, this.init_historical=false}) : super(key: key);


  //const ScreenDetailPortfolio(this.init_account,this.init_code, this.init_name, this.init_portfolio, {Key key}) : super(key: key);

  @override
  _ScreenDetailPortfolioState createState() => _ScreenDetailPortfolioState();
}

class _ScreenDetailPortfolioState extends VisibilityAwareState<ScreenDetailPortfolio> {
  final String routeName = '/detail_portfolio';
  bool onProgress = false;
  bool active = false;
  final AutoSizeGroup groupBest = AutoSizeGroup();
  SingleWatchlistPriceNotifier _watchlistNotifier;
  SinglePortfolioNotifier _portfolioNotifier;
  ReportStockHistNotifier _reportStockHistNotifier = ReportStockHistNotifier(ReportStockHistData());
  OrderStatusNotifier _orderStatusNotifier = OrderStatusNotifier(OrderStatusData());
  final SlidableController slidableController = SlidableController();
  static const String PIN_SUCCESS = 'pin_success';
  // ScrollController pScrollController = ScrollController();
  // NetBuySellSummaryNotifier _netbsSummaryNotifier = NetBuySellSummaryNotifier(NetBuySellSummaryData.createBasic());
  // final RangeNotifier _rangeTopBrokerNotifier = RangeNotifier(Range.createBasic());
  // final ValueNotifier<int> marketNotifier = ValueNotifier<int>(0);
  // final ValueNotifier<int> dataByNotifier = ValueNotifier<int>(0);
  // final ValueNotifier<int> filterByNotifier = ValueNotifier<int>(0);
  // final ValueNotifier<String> _lastDataDateNotifier = ValueNotifier<String>('');
  // final ValueNotifier<int> selectedLineNotifier = ValueNotifier<int>(0);
  // List<String> _market_options = [
  //   'card_local_foreign_button_all_market'.tr(),
  //   'card_local_foreign_button_rg_market'.tr(),
  // ];
  //
  // List<String> _data_by_options = [
  //   'data_by_value_label'.tr(),
  //   'data_by_net_label'.tr(),
  // ];
  //
  // List<String> _filter_options = ['filter_by_all_label'.tr(), 'filter_by_domestic_label'.tr(), 'filter_by_foreign_label'.tr()];
  //
  String stock_code ='-';
  String stock_name ='-';
  String account_info='-';
  String account = '-';
  String user = '-';
  String broker = '-';
  // final StockPositionDetail init_portfolio;
  // final String init_stock_code;
  // final String init_stock_name;
  // final String init_account_info;
  // final String init_account;
  // final String init_user;
  // final String init_broker;


  //
  // String data_by; // belum tentu kepakai
  // String type; // belum tentu kepakai

  void onVisibilityChanged(WidgetVisibility visibility) {
    // TODO: Use visibility
    switch (visibility) {
      case WidgetVisibility.VISIBLE:
        // Like Android's Activity.onResume()
        print('*** ScreenVisibility.VISIBLE: ${this.routeName}');
        _onActiveBase(caller: 'onVisibilityChanged.VISIBLE');
        break;
      case WidgetVisibility.INVISIBLE:
        // Like Android's Activity.onPause()
        print('*** ScreenVisibility.INVISIBLE: ${this.routeName}');
        _onInactiveBase(caller: 'onVisibilityChanged.INVISIBLE');
        break;
      case WidgetVisibility.GONE:
        // Like Android's Activity.onDestroy()
        print('*** ScreenVisibility.GONE: ${this.routeName}   mounted : $mounted');
        // _onInactiveBase(caller: 'onVisibilityChanged.GONE');
        break;
    }

    super.onVisibilityChanged(visibility);
  }

  void _onActiveBase({String caller = ''}) {
    active = true;
    print(routeName + ' onActive  $caller');
    runPostFrame(onActive);
  }

  void runPostFrame(Function function) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        print(routeName + ' runPostFrame executed');
        function();
      } else {
        print(routeName + ' runPostFrame aborted due mounted : $mounted');
      }
    });
  }

  void _onInactiveBase({String caller = ''}) {
    active = false;
    print(routeName + ' onInactive  $caller');
    onInactive();
  }

  void onActive() {
    //canTapRow = true;
    unsubscribe(context, 'onActive');

    Stock stock = InvestrendTheme.storedData.findStock(stock_code);
    if (!StringUtils.equalsIgnoreCase(stock.code, context.read(stockSummaryChangeNotifier).summary.code)) {
      context.read(stockSummaryChangeNotifier).setStock(stock);
    }
    subscribe(context, stock, 'onActive');
    doUpdate();
  }

  void onInactive() {
    //slidableController.activeState = null;
    //canTapRow = true;
    // if(mounted){
    unsubscribe(context, 'onInactive');
    // }
  }

  SubscribeAndHGET subscribeSummary;

  void unsubscribe(BuildContext context, String caller) {
    if (subscribeSummary != null) {
      print(routeName + ' unsubscribe : ' + subscribeSummary.channel);
      if (context != null) {
        context.read(managerDatafeedNotifier).unsubscribe(subscribeSummary, routeName + '.' + caller);
      } else {
        final container = ProviderContainer();
        container.read(managerDatafeedNotifier).unsubscribe(subscribeSummary, routeName + '.' + caller);
      }

      subscribeSummary = null;
    }
  }

  void subscribe(BuildContext context, Stock stock, String caller) {
    String codeBoard = stock.code + '.' + stock.defaultBoard;
    String channel = DatafeedType.Summary.key + '.' + codeBoard;

    context.read(stockSummaryChangeNotifier).setStock(stock);

    subscribeSummary = SubscribeAndHGET(channel, DatafeedType.Summary.collection, codeBoard, listener: (message) {
      print(routeName + ' got : ' + message.elementAt(1));
      print(message);
      if (mounted) {
        StockSummary stockSummary = StockSummary.fromStreaming(message);
        FundamentalCache cache = context.read(fundamentalCacheNotifier).getCache(stockSummary.code);
        stockSummary.updateCache(context, cache);
        context.read(stockSummaryChangeNotifier).setData(stockSummary, check: true);

        _watchlistNotifier.updateFromSummary(stockSummary, context);
      }
    }, validator: validatorSummary);
    print(routeName + ' subscribe : $codeBoard');
    context.read(managerDatafeedNotifier).subscribe(subscribeSummary, routeName + '.' + caller);
  }

  bool validatorSummary(List<String> data, String channel) {
    //List<String> data = message.split('|');
    if (data != null && data.length > 5 /* && data.first == 'III' && data.elementAt(1) == 'Q'*/) {
      final String HEADER = data[0];
      final String TYPE_SUMMARY = data[1];
      final String start = data[2];
      final String end = data[3];
      final String stockCode = data[4];
      final String boardCode = data[5];
      String codeBoard = stockCode + '.' + boardCode;
      String channelData = DatafeedType.Summary.key + '.' + codeBoard;
      if (HEADER == 'III' && TYPE_SUMMARY == 'Q' && channel == channelData) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    // pScrollController.dispose();
    // _netbsSummaryNotifier.dispose();
    // marketNotifier.dispose();
    // dataByNotifier.dispose();
    // filterByNotifier.dispose();
    // _rangeTopBrokerNotifier.dispose();
    // _lastDataDateNotifier.dispose();
    // selectedLineNotifier.dispose();
    _orderStatusNotifier.dispose();
    _reportStockHistNotifier.dispose();
    _watchlistNotifier.dispose();
    _portfolioNotifier.dispose();
    super.dispose();
  } // belum tentu kepakai

  /*
  Widget _infoTopBrokerTransaction(BuildContext context, double bottomPading) {
    if (bottomPading == 0) {
      bottomPading = InvestrendTheme.cardPaddingGeneral;
    }
    return ValueListenableBuilder(
      valueListenable: _lastDataDateNotifier,
      builder: (context, String date, child) {
        if (StringUtils.isEmtpy(date)) {
          return SizedBox(
            width: 1.0,
            height: bottomPading,
          );
        }

        //String info = 'last_data_date_info_label'.tr();
        //info = info.replaceAll('#DATE#', date);

        String displayTime = date;
        if (!StringUtils.isEmtpy(date)) {
          String infoTime = 'last_data_date_info_label'.tr();

          DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
          //DateFormat timeFormatter = DateFormat('HH:mm:ss');
          DateFormat dateParser = DateFormat('yyyy-MM-dd');
          DateTime dateTime = dateParser.parseUtc(date);
          print('dateTime : ' + dateTime.toString());
          print('stock_top_broker.last_date : ' + date);
          String formatedDate = dateFormatter.format(dateTime);
          //String formatedTime = timeFormatter.format(dateTime);
          infoTime = infoTime.replaceAll('#DATE#', formatedDate);
          //infoTime = infoTime.replaceAll('#TIME#', formatedTime);
          displayTime = infoTime;
        }
        return Center(
          child: Padding(
            padding: EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingGeneral,
                bottom: bottomPading),
            child: Text(
              displayTime,
              style: InvestrendTheme.of(context).more_support_w400_compact.copyWith(
                    fontWeight: FontWeight.w500,
                    color: InvestrendTheme.of(context).greyDarkerTextColor,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        );
      },
    );
  }


  Widget _titleTopBrokerTransaction(BuildContext context) {
    //double paddingMargin = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return Padding(
      padding: EdgeInsets.only(
          left: InvestrendTheme.cardPaddingGeneral,
          right: InvestrendTheme.cardPaddingGeneral,
          bottom: InvestrendTheme.cardPadding,
          top: InvestrendTheme.cardPaddingVertical),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ComponentCreator.subtitle(
              context,
              //'top_broker_transaction_title'.tr(),
              code,
            ),
          ),
          ButtonDropdown(marketNotifier, _market_options),
        ],
      ),
    );
  }

  Widget _filterTopBrokerTransaction(BuildContext context) {
    //double paddingMargin = InvestrendTheme.cardPadding + InvestrendTheme.cardMargin;
    return Padding(
      padding: EdgeInsets.only(
        left: InvestrendTheme.cardPaddingGeneral,
        right: InvestrendTheme.cardPaddingGeneral,
        bottom: InvestrendTheme.cardPadding,
        //top: InvestrendTheme.cardPaddingVertical
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text('Filter', style: InvestrendTheme
          //     .of(context)
          //     .small_w500_compact,),
          // Spacer(flex: 1,),
          ButtonDropdown(marketNotifier, _market_options),
          ButtonDropdown(dataByNotifier, _data_by_options),
          ButtonDropdown(filterByNotifier, _filter_options),
        ],
      ),
    );
  }
  */
  @override
  void initState() {
    super.initState();

    this.stock_code = widget.init_stock_code;
    this.stock_name = widget.init_stock_name;
    this.account_info = widget.init_account_info;

    this.account = widget.init_account;
    this.user = widget.init_user;
    this.broker = widget.init_broker;


    _watchlistNotifier = SingleWatchlistPriceNotifier(WatchlistPrice(this.stock_code, 0, 0, 0.0, this.stock_name));
    _portfolioNotifier = SinglePortfolioNotifier(StockPositionDetail.createBasic());
    _portfolioNotifier.setValue(widget.init_portfolio);
    /*
    //this.board = widget.init_board;
    this.data_by = widget.init_data_by;
    this.type = widget.init_type;
    //this.from = widget.init_from;
    //this.to = widget.init_to;
    marketNotifier.value = widget.init_board;

    String from = 'From';
    String to = 'To';
    if (!StringUtils.equalsIgnoreCase(widget.init_range.from, 'LD')) {
      from = widget.init_range.from;
    }
    if (!StringUtils.equalsIgnoreCase(widget.init_range.to, 'LD')) {
      to = widget.init_range.to;
    }
    _rangeTopBrokerNotifier.value.index = widget.init_range.index;
    _rangeTopBrokerNotifier.value.from = from;
    _rangeTopBrokerNotifier.value.to = to;

    _rangeTopBrokerNotifier.addListener(() {
      if (_rangeTopBrokerNotifier.value == 7) {
        // Custom Range
        //_customRangeNotifier.value = true;
      } else {
        //_customRangeNotifier.value = false;
        doUpdate();
      }
    });
    marketNotifier.addListener(() {
      doUpdate();
    });

    dataByNotifier.addListener(() {
      doUpdate();
    });

    filterByNotifier.addListener(() {
      doUpdate();
    });
    */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doUpdate();
    });
  }

  Future doUpdate({bool pullToRefresh = false}) async {
    if (!mounted) {
      print(routeName + '.doUpdate Aborted : ' + DateTime.now().toString() + "  mounted : $mounted  pullToRefresh : $pullToRefresh");
      return false;
    }
    onProgress = true;
    print(routeName + '.doUpdate : ' + DateTime.now().toString() + "  pullToRefresh : $pullToRefresh");

    /*
    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    if (hasAccount) {
      int selected = context.read(accountChangeNotifier).index;
      Account account = context.read(dataHolderChangeNotifier).user.getAccount(selected);
      if (account == null) {
        //String text = 'No Account Selected. accountSize : ' + InvestrendTheme.of(context).user.accountSize().toString();
        String text = routeName + ' No Account Selected. accountSize : ' + context.read(dataHolderChangeNotifier).user.accountSize().toString();
        InvestrendTheme.of(context).showSnackBar(context, text);
        onProgress = false;
        return;
      } else {

      }
    }
    */

    if (_portfolioNotifier.value.isEmpty()) {
      if (mounted) {
        _portfolioNotifier.setLoading();
      }
    }
    try {
      print(routeName + ' try stockPosition');
      final stockPosition = await InvestrendTheme.tradingHttp.stock_position(
          broker,
          account,
          user,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion,
          stock: this.stock_code);
      //DebugWriter.info(routeName + ' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
      DebugWriter.information(routeName + ' Got stockPosition ' + stockPosition.toString());
      if (stockPosition != null) {
        if (mounted) {
          StockPositionDetail detail = stockPosition.getStockPositionDetailByCode(this.stock_code);
          _portfolioNotifier.setValue(detail);
        }
      } else {
        if (mounted) {
          _portfolioNotifier.setNoData();
        }
      }
    } catch (e) {
      DebugWriter.information(routeName + ' stockPosition Exception : ' + e.toString());
      if (mounted) {
        _portfolioNotifier.setError(message: e.toString());
      }
      //_stockPositionNotifier?.setError(message: e.toString());
      //setNotifierError(_stockPositionNotifier, e);
      handleNetworkError(context, e);
    }


    try {
      print(routeName + ' try orderStatus');
      final orderStatus = await InvestrendTheme.tradingHttp.orderStatus(broker, account, user,
          InvestrendTheme.of(context).applicationPlatform, InvestrendTheme.of(context).applicationVersion, stock: this.stock_code);
      int orderStatusCount = orderStatus != null ? orderStatus.length : 0;
      print('Got orderStatus : ' + orderStatusCount.toString());

      if (orderStatus != null) {

        if(mounted){
          OrderStatusData result = OrderStatusData();
          orderStatus.forEach((status) {
            if (
            StringUtils.equalsIgnoreCase(status.stockCode, this.stock_code)
                && (status.isFilterValid(FilterTransaction.All.index, FilterStatus.Open.index)
                || status.isFilterValid(FilterTransaction.All.index, FilterStatus.New.index))
            ) {
              result.datas.add(status);
            }
          });
          _orderStatusNotifier.setValue(result);
        }

      }else{
        if (mounted) {
          _orderStatusNotifier.setNoData();
        }
      }

    } catch (e) {
      DebugWriter.information(routeName + ' orderStatus Exception : ' + e.toString());
      if (mounted) {
        _orderStatusNotifier.setError(message: e.toString());
      }
      handleNetworkError(context, e);
    }

    try {
      print(routeName + ' try report stock today');
      final report_stock_today = await InvestrendTheme.tradingHttp.report_stock_today(
          broker,
          account,
          user,
          this.stock_code,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      //DebugWriter.info(routeName + ' Got stockPosition ' + stockPosition.accountcode + '   stockList.size : ' + stockPosition.stockListSize().toString());
      DebugWriter.information(routeName + ' Got report_stock_today : ' + report_stock_today.size().toString());
      if (report_stock_today != null && !report_stock_today.isEmpty()) {
        if (mounted) {
          _reportStockHistNotifier.setValue(report_stock_today);
        }
      } else {
        if (mounted) {
          _reportStockHistNotifier.setNoData();
        }
      }
    } catch (e) {
      DebugWriter.information(routeName + ' stockPosition Exception : ' + e.toString());
      if (mounted) {
        _reportStockHistNotifier.setError(message: e.toString());
      }
      handleNetworkError(context, e);
    }


    print(routeName + '.doUpdate finished. pullToRefresh : $pullToRefresh');
    onProgress = false;
    return true;
  }

  void handleNetworkError(BuildContext context, error) {
    print(routeName + ' handleNetworkError : ' + error.toString());
    print(error);
    if (mounted) {
      if (error is TradingHttpException) {
        if (error.isUnauthorized()) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
          // InvestrendTheme.of(context).showDialogInvalidSession(context, onClosePressed: (){
          //   Navigator.pop(context);
          // });
        } else if (error.isErrorTrading()) {
          InvestrendTheme.of(context).showSnackBar(context, error.message());
        } else {
          String network_error_label = 'network_error_label'.tr();
          network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, network_error_label);
        }
      } else {
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        String errorText = Utils.removeServerAddress(error.toString());
        InvestrendTheme.of(context).showSnackBar(context, errorText);
      }
    }
  }

  Future onRefresh() {
    // context.read(stockDetailRefreshChangeNotifier).setRoute(routeName);
    // if (!active) {
    //   active = true;
    //   //onActive();
    //   context.read(stockDetailScreenVisibilityChangeNotifier).setActive(tabIndex, true);
    // }
    return doUpdate(pullToRefresh: true);
    // return Future.delayed(Duration(seconds: 3));
  }

  AutoSizeGroup groupValue = AutoSizeGroup();
  AutoSizeGroup groupHeader = AutoSizeGroup();

  Widget createHeader(
    BuildContext context,
    double leftWidth,
    double centerWidth,
    double rightWidth,
  ) {
    TextStyle styleBold = InvestrendTheme.of(context).regular_w600_compact;
    TextStyle styleHeader = InvestrendTheme.of(context).small_w500_compact;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral,
              right: InvestrendTheme.cardPaddingGeneral,
              top: InvestrendTheme.cardPadding,
              bottom: InvestrendTheme.cardPadding),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Buyer',
                  textAlign: TextAlign.center,
                  style: styleBold.copyWith(color: Theme.of(context).accentColor),
                ),
                flex: 1,
              ),
              //Text(' # ', textAlign: TextAlign.center, style: styleHeader,),
              Expanded(
                child: Text(
                  'Seller',
                  textAlign: TextAlign.center,
                  style: styleBold.copyWith(color: InvestrendTheme.sellTextColor),
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPadding),
          child: Row(
            children: [
              SizedBox(
                width: leftWidth * 0.3,
                child: Text('Code', style: styleHeader, textAlign: TextAlign.left),
              ),
              SizedBox(
                width: leftWidth * 0.3,
                child: AutoSizeText(
                  'Avg',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: leftWidth * 0.4,
                child: AutoSizeText(
                  'Value',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: InvestrendTheme.cardPadding,
              ),
              Container(
                  width: centerWidth,
                  alignment: Alignment.center,
                  //padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  //color: Colors.grey,
                  child: Text('#', style: styleHeader)),
              SizedBox(
                width: InvestrendTheme.cardPadding,
              ),
              SizedBox(
                width: rightWidth * 0.3,
                child: Text('Code', style: styleHeader, textAlign: TextAlign.left),
              ),
              SizedBox(
                width: rightWidth * 0.3,
                child: AutoSizeText(
                  'Avg',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: rightWidth * 0.4,
                child: AutoSizeText(
                  'Value',
                  style: styleHeader,
                  textAlign: TextAlign.right,
                  group: groupHeader,
                  minFontSize: 5,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createRow(BuildContext context, double leftWidth, double centerWidth, double rightWidth, int line, NetBuySellSummary buyer,
      NetBuySellSummary seller, TextStyle style, TextStyle styleBroker) {
    //TextStyle style = InvestrendTheme.of(context).small_w400_compact;

    String buyerCode = '';
    String buyerValue = '';
    String buyerAverage = '';
    if (buyer != null) {
      buyerCode = buyer.Broker;
      buyerValue = InvestrendTheme.formatValue(context, buyer.Value);
      buyerAverage = InvestrendTheme.formatComma(buyer.Average.truncate());
    }

    String sellerCode = '';
    String sellerValue = '';
    String sellerAverage = '';
    if (seller != null) {
      sellerCode = seller.Broker;
      sellerValue = InvestrendTheme.formatValue(context, seller.Value);
      sellerAverage = InvestrendTheme.formatComma(seller.Average.truncate());
    }

    bool odd = (line - 1) % 2 != 0;
    return Container(
      color: odd ? InvestrendTheme.of(context).oddColor : Theme.of(context).backgroundColor,
      padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: leftWidth * 0.2,
            child: Text(buyerCode, style: styleBroker, textAlign: TextAlign.left),
          ),
          SizedBox(
            width: leftWidth * 0.4,
            child: AutoSizeText(
              buyerAverage,
              style: style,
              textAlign: TextAlign.right,
              group: groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: leftWidth * 0.4,
            child: AutoSizeText(
              buyerValue,
              style: style,
              textAlign: TextAlign.right,
              group: groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: InvestrendTheme.cardPadding,
          ),
          Container(
              width: centerWidth,
              //alignment: Alignment.center,
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              color: InvestrendTheme.of(context).greyLighterTextColor,
              child: AutoSizeText(
                InvestrendTheme.formatNewComma(line.toDouble()),
                style: style.copyWith(color: InvestrendTheme.of(context).textWhite),
                textAlign: TextAlign.center,
                group: groupValue,
                minFontSize: 5,
                maxLines: 1,
              )),
          SizedBox(
            width: InvestrendTheme.cardPadding,
          ),
          SizedBox(
            width: rightWidth * 0.2,
            child: Text(sellerCode, style: styleBroker, textAlign: TextAlign.left),
          ),
          SizedBox(
            width: rightWidth * 0.4,
            child: AutoSizeText(
              sellerAverage,
              style: style,
              textAlign: TextAlign.right,
              group: groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: rightWidth * 0.4,
            child: AutoSizeText(
              sellerValue,
              style: style,
              textAlign: TextAlign.right,
              group: groupValue,
              minFontSize: 5,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget createBody(BuildContext context, double paddingBottom) {

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return RefreshIndicator(
          color: InvestrendTheme.of(context).textWhite,
          backgroundColor: Theme.of(context).accentColor,
          onRefresh: onRefresh,
          child: ListView(
            //padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: _watchlistNotifier,
                builder: (context, gp, child) {
                  return Container(
                    margin: const EdgeInsets.only(
                        left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral,
                        top: InvestrendTheme.cardPadding),
                    decoration: BoxDecoration(
                      color: InvestrendTheme.of(context).tileBackground,
                      //border: RoundedRectangleBorder(borderRadius: ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: RowWatchlist(
                      gp,
                      groupBest: groupBest,
                      firstRow: true,
                      onTap: () {
                        print('clicked code : ' + gp.code);
                        // if (canTapRow) {
                        //   canTapRow = false;

                        Stock stock = InvestrendTheme.storedData.findStock(gp.code);
                        if (stock == null) {
                          print('clicked code : ' + gp.code + ' aborted, not find stock on StockStorer');
                          // canTapRow = true;
                          return;
                        }
                        context.read(primaryStockChangeNotifier).setStock(stock);

                        // Future.delayed(Duration(milliseconds: 200), () {
                        // canTapRow = true;
                        InvestrendTheme.of(context).showStockDetail(context);
                        // });
                        // }
                      },
                      paddingLeftRight: InvestrendTheme.cardPaddingGeneral,
                      onPressedButtonCorporateAction: () => onPressedButtonCorporateAction(context, gp.corporateAction),
                      //onPressedButtonSpecialNotation: ()=> onPressedButtonSpecialNotation(context, gp.notation),
                      onPressedButtonSpecialNotation: () => onPressedButtonImportantInformation(context, gp.notation, gp.suspendStock),
                      stockInformationStatus: gp.status,
                      widthRight: _watchlistNotifier.widthRight,
                    ),

                  );
                },
              ),

              SizedBox(
                height: InvestrendTheme.cardPaddingVertical,
              ),
              createLabelValue('accounts_lobel'.tr(), this.account_info,),
              ValueListenableBuilder(
                  valueListenable: _portfolioNotifier,
                  builder: (context, StockPositionDetail value, child) {
                    return Column(
                      children: [
                        createLabelValue('portfolio_detail_total_value'.tr(), InvestrendTheme.formatMoneyDouble(value.marketVal, prefixRp: true),
                            valueStyle: InvestrendTheme.of(context).medium_w600_compact),
                        createLabelValue('portfolio_detail_invested'.tr(), InvestrendTheme.formatMoneyDouble(value.stockVal, prefixRp: true)),
                        createLabelValue(
                            'portfolio_detail_return'.tr(), InvestrendTheme.formatMoneyDouble(value.stockGL, prefixPlus: true, prefixRp: true),
                            valueColor: InvestrendTheme.changeTextColor(widget.init_portfolio.stockGL)),
                        createLabelValue(
                            'portfolio_detail_percentage_return'.tr(), InvestrendTheme.formatPercent(value.stockGLPct, prefixPlus: true),
                            valueColor: InvestrendTheme.changeTextColor(widget.init_portfolio.stockGL)),
                      ],
                    );
                  }),
              // createLabelValue('portfolio_detail_total_value'.tr(), InvestrendTheme.formatMoneyDouble(widget.init_portfolio.marketVal, prefixRp: true),valueStyle: InvestrendTheme.of(context).medium_w600_compact),
              // createLabelValue('portfolio_detail_invested'.tr(), InvestrendTheme.formatMoneyDouble(widget.init_portfolio.stockVal, prefixRp: true)),
              // createLabelValue('portfolio_detail_return'.tr(), InvestrendTheme.formatMoneyDouble(widget.init_portfolio.stockGL, prefixPlus: true, prefixRp: true), valueColor: InvestrendTheme.changeTextColor(widget.init_portfolio.stockGL)),
              // createLabelValue('portfolio_detail_percentage_return'.tr(), InvestrendTheme.formatPercent(widget.init_portfolio.stockGLPct, prefixPlus: true), valueColor: InvestrendTheme.changeTextColor(widget.init_portfolio.stockGL)),

              Padding(
                padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                child: ComponentCreator.divider(context),
              ),
              SizedBox(
                height: InvestrendTheme.cardPaddingGeneral,
              ),
              ValueListenableBuilder(
                  valueListenable: _portfolioNotifier,
                  builder: (context, StockPositionDetail value, child) {
                    return Column(
                      children: [
                        createLabelValue('portfolio_detail_owned_lot'.tr(), InvestrendTheme.formatPrice(value.netBalance.toInt())),
                        createLabelValue('portfolio_detail_average_price'.tr(), InvestrendTheme.formatPrice(value.avgPrice.toInt())),
                      ],
                    );
                  }),

              // createLabelValue('portfolio_detail_owned_lot'.tr(), InvestrendTheme.formatPrice(widget.init_portfolio.netBalance.toInt())),
              // createLabelValue('portfolio_detail_average_price'.tr(), InvestrendTheme.formatPrice(widget.init_portfolio.avgPrice.toInt())),

              ValueListenableBuilder(
                  valueListenable: _watchlistNotifier,
                  builder: (context, WatchlistPrice value, child) {
                    return createLabelValue('portfolio_detail_market_price'.tr(), InvestrendTheme.formatPrice(value.price.toInt()));
                  }),
              SizedBox(
                height: InvestrendTheme.cardPadding,
              ),

              // Padding(
              //   padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
              //   child: Text('today_label'.tr(), style: InvestrendTheme.of(context).headline3.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),),
              // ),

              ValueListenableBuilder(
                  valueListenable: _orderStatusNotifier,
                  builder: (context, OrderStatusData value, child) {
                    //int max_showed = 2;
                    List<Widget> childs = List.empty(growable: true);
                    // if (value.size() > max_showed) {
                    //   childs.add(Padding(
                    //     padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral),
                    //     child: ComponentCreator.subtitleButtonMore(context, 'portfolio_detail_order_open'.tr(), () {
                    //
                    //     }),
                    //   ));
                    // } else {
                      childs.add(Padding(
                        padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                        child: ComponentCreator.subtitleNoButtonMore(context, 'portfolio_detail_order_open'.tr()),
                      ));
                    // }

                    Widget noWidget = _orderStatusNotifier.currentState.getNoWidget(onRetry: () {
                      doUpdate(pullToRefresh: true);
                    });

                    childs.add(createHeaderOpen(context));
                    if (noWidget != null) {
                      childs.add(Padding(
                        padding: EdgeInsets.only(top: InvestrendTheme.cardPaddingVertical, bottom: InvestrendTheme.cardPaddingVertical),
                        child: Center(child: noWidget),
                      ));
                    } else {
                      //int loop = min(max_showed, value.size());
                      int loop = value.size();
                      for (int i = 0; i < loop; i++) {
                        if (i > 0) {
                          childs.add(Padding(
                            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                            child: ComponentCreator.divider(context, thickness: 0.5),
                          ));
                        }
                        //childs.add(createRowOpen(context, value.datas.elementAt(i)));
                        childs.add(createSlidableRowAmendWithdraw(context, value.datas.elementAt(i)));
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: childs,
                    );
                  }),

              SizedBox(
                height: InvestrendTheme.cardPaddingVertical,
              ),
              ValueListenableBuilder(
                  valueListenable: _reportStockHistNotifier,
                  builder: (context, ReportStockHistData value, child) {
                    // int max_showed = 2;
                    List<Widget> childs = List.empty(growable: true);
                    // if (value.size() > max_showed) {
                      childs.add(Padding(
                        padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral),
                        child: ComponentCreator.subtitleButtonMore(context, 'portfolio_detail_order_done'.tr(), () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                //builder: (_) => ScreenDetailPortfolio(accountInfo,stock.code, stock.name, gp),
                                builder: (_) => ScreenDetailPortfolioHistorical(stock_code, stock_name, account, user, broker),
                                settings: RouteSettings(name: '/detail_portfolio_historical'),
                              ));
                        }, textButton: 'historical_text'.tr()),
                      ));
                    // } else {
                    //   childs.add(ComponentCreator.subtitle(context, 'portfolio_detail_order_done'.tr()));
                    // }

                    Widget noWidget = _reportStockHistNotifier.currentState.getNoWidget(onRetry: () {
                      doUpdate(pullToRefresh: true);
                    });

                    childs.add(createHeaderMatched(context));
                    if (noWidget != null) {
                      childs.add(Padding(
                        padding: EdgeInsets.only(top: InvestrendTheme.cardPaddingVertical, bottom: InvestrendTheme.cardPaddingVertical),
                        child: Center(child: noWidget),
                      ));
                    } else {
                      //int loop = min(max_showed, value.size());
                      int loop = value.size();
                      for (int i = 0; i < loop; i++) {
                        if (i > 0) {
                          childs.add(Padding(
                            padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                            child: ComponentCreator.divider(context, thickness: 0.5),
                          ));
                        }
                        childs.add(createRowMatched(context, value.datas.elementAt(i)));
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: childs,
                    );
                  }),

              /*
              Padding(
                padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
                child: Text(
                  code,
                  style: InvestrendTheme.of(context).regular_w600,
                ),
              ),
              */
              SizedBox(
                height: 80.0 + paddingBottom,
              ),
            ],
          ),
        );
      },
    );
  }

  String translateBuySell(String bs) {
    if (StringUtils.equalsIgnoreCase(bs, 'S')) {
      return 'sell_text'.tr();
    } else if (StringUtils.equalsIgnoreCase(bs, 'B')) {
      return 'buy_text'.tr();
    }
    return bs;
  }

  Color colorBuySell(BuildContext context, String bs) {
    if (StringUtils.equalsIgnoreCase(bs, 'S')) {
      return InvestrendTheme.sellTextColor;
    } else if (StringUtils.equalsIgnoreCase(bs, 'B')) {
      return InvestrendTheme.buyTextColor;
    }
    return InvestrendTheme.of(context).greyDarkerTextColor;
  }

  AutoSizeGroup groupMatchedTop = AutoSizeGroup();
  AutoSizeGroup groupMatchedBottom = AutoSizeGroup();
  AutoSizeGroup groupMatchedHeader = AutoSizeGroup();

  AutoSizeGroup groupOpenTop = AutoSizeGroup();
  AutoSizeGroup groupOpenBottom = AutoSizeGroup();
  AutoSizeGroup groupOpenHeader = AutoSizeGroup();

  AutoSizeGroup autoSizeGroup = AutoSizeGroup();
  Widget createSlidableRowAmendWithdraw(BuildContext context, OrderStatus os) {
    List<Widget> listActions = List.empty(growable: true);
    bool isBuy = StringUtils.equalsIgnoreCase(os.bs, 'B');
    if (os.canAmend()) {
      String button_amend = 'button_amend'.tr();
      Color buySellColor = isBuy ? InvestrendTheme.buyColor : InvestrendTheme.sellColor;
      listActions.add(TradeSlideAction(
        button_amend,
        buySellColor,

            () {
          print('amend clicked code : ' + os.stockCode);
          // Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
          // if (stock == null) {
          //   print('amend clicked code : ' + os.stockCode + ' aborted, not find stock on StockStorer');
          //   return;
          // }

          //context.read(primaryStockChangeNotifier).setStock(stock);
          showScreenAmend(context, os);


          // bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          // InvestrendTheme.pushScreenTrade(
          //   context,
          //   hasAccount,
          //   type: OrderType.Buy,
          // );
        },
        tag: isBuy ? 'button_buy' : 'button_sell',
        autoGroup: autoSizeGroup,
      ));
    }

    if (os.canWithdraw()) {
      listActions.add(TradeSlideAction(
        'button_withdraw'.tr(),
        Colors.orange,
            () {
          print('withdraw clicked code : ' + os.stockCode);
          executeCancel(context, os);
          // Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
          // if (stock == null) {
          //   print('withdraw clicked code : ' + os.stockCode + ' aborted, not find stock on StockStorer');
          //   return;
          // }
          //
          // context.read(primaryStockChangeNotifier).setStock(stock);
          //
          // bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
          // InvestrendTheme.pushScreenTrade(
          //   context,
          //   hasAccount,
          //   type: OrderType.Sell,
          // );
        },
        tag: 'button_withdraw',
        autoGroup: autoSizeGroup,
      ));
    }

    if (listActions.isNotEmpty) {
      return Slidable(
        controller: slidableController,
        closeOnScroll: true,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.22,
        secondaryActions: listActions,
        child: createRowOpen(context, os),
      );
    } else {
      return createRowOpen(context, os);
    }
  }

  void executeCancel(BuildContext context, OrderStatus os) {
    if (context.read(propertiesNotifier).isNeedPinTrading()) {
      Future result = Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ScreenLoginPin(),
            settings: RouteSettings(name: '/login_pin'),
          ));
      result.then((value) {
        if (value is TradingHttpException) {
          InvestrendTheme.of(context).showDialogInvalidSession(context);
        } else if (value is String) {
          if (StringUtils.equalsIgnoreCase(value, PIN_SUCCESS)) {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                ),
                //backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  String reffID = Utils.createRefferenceID();
                  return BottomSheetConfirmationCancel(null, os, reffID);
                });
          }
        }
      });
    } else {
      showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          ),
          //backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            String reffID = Utils.createRefferenceID();
            return BottomSheetConfirmationCancel(null, os, reffID);
          });
    }
  }

  void showScreenAmend(BuildContext context, OrderStatus os) {

    Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(os.brokercode, os.accountcode);
    if (account != null) {
      OrderType orderType;
      if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
        orderType = OrderType.Buy;
      } else if (StringUtils.equalsIgnoreCase(os.bs, 'S')) {
        orderType = OrderType.Sell;
      } else {
        orderType = OrderType.Unknown;
      }

      BuySell data = BuySell(orderType);
      data.orderid = os.orderid;
      data.accountType = account.type;
      data.accountName = account.accountname;
      data.accountCode = os.accountcode;
      data.brokerCode = os.brokercode;
      data.stock_code = os.stockCode;

      Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
      data.stock_name = stock != null ? stock.name : '-';
      //data.normalTotalValue = os.price * os.orderQty;
      data.fastTotalValue = 0;
      data.fastMode = false;
      data.tradingLimitUsage = 0;
      data.setNormalPriceLot(os.price, os.orderQty ~/ 100);

      if (context.read(propertiesNotifier).isNeedPinTrading()) {
        Future result = Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => ScreenLoginPin(),
              settings: RouteSettings(name: '/login_pin'),
            ));
        result.then((value) {
          if (value is TradingHttpException) {
            InvestrendTheme.of(context).showDialogInvalidSession(context);
          } else if (value is String) {
            if (StringUtils.equalsIgnoreCase(value, PIN_SUCCESS)) {
              InvestrendTheme.push(context, ScreenAmend(data.cloneAsAmend()), ScreenTransition.SlideLeft, '/amend').then((value) {
                if (value != null && value is String) {
                  if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
                    Navigator.popUntil(context, (route) {
                      print('popUntil : ' + route.toString());
                      if (StringUtils.equalsIgnoreCase(route?.settings?.name, '/main')) {
                        return true;
                      }
                      return route.isFirst;
                    });
                    context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
                  }
                }
              });
            }
          }
        });
      } else {
        InvestrendTheme.push(context, ScreenAmend(data.cloneAsAmend()), ScreenTransition.SlideLeft, '/amend').then((value) {
          if (value != null && value is String) {
            if (StringUtils.equalsIgnoreCase(value, 'FINISHED')) {
              Navigator.popUntil(context, (route) {
                print('popUntil : ' + route.toString());
                if (StringUtils.equalsIgnoreCase(route?.settings?.name, '/main')) {
                  return true;
                }
                return route.isFirst;
              });
              context.read(mainMenuChangeNotifier).setActive(Tabs.Transaction, TabsTransaction.Intraday.index);
            }
          }
        });
      }
    }else{
      InvestrendTheme.of(context).showSnackBar(context, 'Can\'t find order information locally.');
      print('Can\'t find order information locally.');
    }
  }


  void showOrderDetail(BuildContext context, OrderStatus os){
    Account account = context.read(dataHolderChangeNotifier).user.getAccountByCode(os.brokercode, os.accountcode);
    if (account != null) {
      OrderType orderType;
      if (StringUtils.equalsIgnoreCase(os.bs, 'B')) {
        orderType = OrderType.Buy;
      } else if (StringUtils.equalsIgnoreCase(os.bs, 'S')) {
        orderType = OrderType.Sell;
      } else {
        orderType = OrderType.Unknown;
      }

      BuySell data = BuySell(orderType);
      data.orderid = os.orderid;
      data.accountType = account.type;
      data.accountName = account.accountname;
      data.accountCode = os.accountcode;
      data.brokerCode = os.brokercode;
      data.stock_code = os.stockCode;

      Stock stock = InvestrendTheme.storedData.findStock(os.stockCode);
      data.stock_name = stock != null ? stock.name : '-';
      //data.normalTotalValue = os.price * os.orderQty;
      data.fastTotalValue = 0;
      data.fastMode = false;
      data.tradingLimitUsage = 0;
      data.setNormalPriceLot(os.price, os.orderQty ~/ 100);

      //InvestrendTheme.push(context, ScreenOrderDetail(data, os), ScreenTransition.SlideDown, '/order_detail');
      //InvestrendTheme.push(context, ScreenOrderDetail(data, os), ScreenTransition.SlideLeft, '/order_detail', durationMilisecond: 300);
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ScreenOrderDetail(
                data,
                os,
                historicalMode: false,
              ),
              settings: RouteSettings(name: '/order_detail')));
    } else {
      String error = 'validation_account_not_related_to_user'.tr();
      error = error.replaceAll('#account#', os.accountcode);
      error = error.replaceAll('#user#', context.read(dataHolderChangeNotifier).user.username);
      InvestrendTheme.of(context).showSnackBar(context, error);
    }
  }

  Widget createRowOpen(BuildContext context, OrderStatus data) {
    TextStyle styleTop = InvestrendTheme.of(context).regular_w500_compact;
    TextStyle styleBottom = InvestrendTheme.of(context).small_w400_compact_greyDarker;

    int order_lot = data.orderQty ~/ 100;
    int value = data.price * data.orderQty;
    return TapableWidget(
      onTap: ()=>showOrderDetail(context, data),
      child: Padding(

        padding: EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding,left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
                        //color: data.backgroundColor(context),
                        decoration: BoxDecoration(
                          color: data.backgroundColor(context),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: AutoSizeText(
                          data.orderStatus,
                          style: styleTop.copyWith(color: InvestrendTheme.of(context).greyDarkerTextColor),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          minFontSize: 5.0,
                          group: groupOpenTop,
                        ))),
                Expanded(
                    flex: 1,
                    child: AutoSizeText(
                      translateBuySell(data.bs),
                      style: styleTop.copyWith(color: colorBuySell(context, data.bs)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 5.0,
                      group: groupOpenTop,
                    )),
                Expanded(
                    flex: 1,
                    child: AutoSizeText(
                      InvestrendTheme.formatPrice(data.price),
                      style: styleTop,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      minFontSize: 5.0,
                      group: groupOpenTop,
                    )),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: AutoSizeText(
                      data.getTimeFormatted(),
                      style: styleBottom,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      minFontSize: 5.0,
                      group: groupOpenBottom,
                    )),
                Expanded(
                    flex: 1,
                    child: AutoSizeText(
                      InvestrendTheme.formatPrice(order_lot),
                      style: styleBottom,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 5.0,
                      group: groupOpenBottom,
                    )),
                Expanded(
                    flex: 1,
                    child: AutoSizeText(
                      InvestrendTheme.formatMoney(value, prefixRp: true),
                      style: styleBottom,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      minFontSize: 5.0,
                      group: groupOpenBottom,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget createRowMatched(BuildContext context, ReportStockHist data) {
    TextStyle styleTop = InvestrendTheme.of(context).regular_w500_compact;
    TextStyle styleBottom = InvestrendTheme.of(context).small_w400_compact_greyDarker;
    return Padding(
      padding: EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    data.date,
                    style: styleTop,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedTop,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    translateBuySell(data.bs),
                    style: styleTop.copyWith(color: colorBuySell(context, data.bs)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedTop,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    InvestrendTheme.formatPrice(data.price),
                    style: styleTop,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedTop,
                  )),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    ' ',
                    style: styleBottom,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedBottom,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    InvestrendTheme.formatPrice(data.lot),
                    style: styleBottom,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedBottom,
                  )),
              Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    InvestrendTheme.formatMoney(data.value, prefixRp: true),
                    style: styleBottom,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    minFontSize: 5.0,
                    group: groupMatchedBottom,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget createHeaderMatched(BuildContext context) {
    TextStyle styleHeader = InvestrendTheme.of(context).small_w500_compact;
    return Padding(

      padding: EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'date_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.left,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupMatchedHeader,
              )),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'order_lot_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupMatchedHeader,
              )),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'price_total_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.right,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupMatchedHeader,
              )),
        ],
      ),
    );
  }

  Widget createHeaderOpen(BuildContext context) {
    TextStyle styleHeader = InvestrendTheme.of(context).small_w500_compact;
    return Padding(

      padding: EdgeInsets.only(top: InvestrendTheme.cardPadding, bottom: InvestrendTheme.cardPadding, left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'status_date_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.left,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupOpenHeader,
              )),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'order_lot_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupOpenHeader,
              )),
          Expanded(
              flex: 1,
              child: AutoSizeText(
                'price_total_text'.tr(),
                style: styleHeader,
                textAlign: TextAlign.right,
                maxLines: 1,
                minFontSize: 5.0,
                group: groupOpenHeader,
              )),
        ],
      ),
    );
  }

  Widget createLabelValue(String label, String value, {Color valueColor, TextStyle labelStyle, TextStyle valueStyle}) {
    if (labelStyle == null) {
      labelStyle = InvestrendTheme.of(context).small_w400_compact.copyWith(
            color: InvestrendTheme.of(context).greyDarkerTextColor,
          );
    }
    if (valueStyle == null) {
      valueStyle = InvestrendTheme.of(context).regular_w400_compact;
    }

    if (valueColor != null) {
      valueStyle = valueStyle.copyWith(color: valueColor);
    }
    return Padding(
      padding: const EdgeInsets.only(left: InvestrendTheme.cardPaddingGeneral, right: InvestrendTheme.cardPaddingGeneral, bottom: InvestrendTheme.cardPaddingGeneral),
      //padding: const EdgeInsets.only(bottom: InvestrendTheme.cardPaddingGeneral),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label ?? '',
              maxLines: 5,
              softWrap: true,
              style: labelStyle,
              textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            value ?? '',
            style: valueStyle,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  void onPressedButtonCorporateAction(BuildContext context, List<CorporateActionEvent> corporateAction) {
    print('onPressedButtonCorporateAction : ' + corporateAction.toString());

    List<Widget> childs = List.empty(growable: true);
    if (corporateAction != null && corporateAction.isNotEmpty) {
      corporateAction.forEach((ca) {
        if (ca != null) {
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ca.getInformationWidget(context),
          ));
        }
      });

      showAlert(context, childs, childsHeight: (childs.length * 50).toDouble(), title: 'Corporate Action');
    }
  }

  void onPressedButtonImportantInformation(BuildContext context, List<Remark2Mapping> notation, SuspendStock suspendStock) {
    int count = notation == null ? 0 : notation.length;
    if (count == 0 && suspendStock == null) {
      print(routeName + '.onPressedButtonImportantInformation not showing anything');
      return;
    }
    print(routeName + '.onPressedButtonImportantInformation');
    List<Widget> childs = List.empty(growable: true);

    double height = 0;
    if (suspendStock != null) {
      String infoSuspend = 'suspended_time_info'.tr();

      DateFormat dateFormatter = DateFormat('EEEE, dd/MM/yyyy', 'id');
      DateFormat dateParser = DateFormat('yyyy-MM-dd');
      DateTime dateTime = dateParser.parseUtc(suspendStock.date);
      print('dateTime : ' + dateTime.toString());
      //print('indexSummary.date : '+data.date+' '+data.time);
      String formatedDate = dateFormatter.format(dateTime);
      //String formatedTime = timeFormatter.format(dateTime);
      //infoSuspend = infoSuspend.replaceAll('#BOARD#', suspendStock.board);
      infoSuspend = infoSuspend.replaceAll('#DATE#', formatedDate);
      infoSuspend = infoSuspend.replaceAll('#TIME#', suspendStock.time);
      //displayTime = infoTime;
      height += 25.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(
          'Suspended ' + suspendStock.board,
          style: InvestrendTheme.of(context).small_w600,
        ),
      ));

      height += 50.0;
      childs.add(Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: RichText(
          text: TextSpan(text: '•  ', style: InvestrendTheme.of(context).small_w600, children: [
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

      Remark2Mapping remark2 = notation.elementAt(i);
      if (remark2 != null) {
        if (remark2.isSurveilance()) {
          height += 35.0;
          childs.add(Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              remark2.code + ' : ' + remark2.value,
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
              text: TextSpan(text: /*remark2.code + " : "*/ '•  ', style: InvestrendTheme.of(context).small_w600, children: [
                TextSpan(
                  text: remark2.code,
                  style: InvestrendTheme.of(context).small_w600,
                ),
                TextSpan(
                  text: ' : ' + remark2.value,
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

  void showAlert(BuildContext context, List<Widget> childs, {String title, double childsHeight = 0}) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return BottomSheetAlert(
            childs,
            title: title,
            childsHeight: childsHeight,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    double paddingTop = MediaQuery.of(context).padding.top;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double elevation = 0.0;
    Color shadowColor = Theme.of(context).shadowColor;
    if (!InvestrendTheme.tradingHttp.is_production) {
      elevation = 2.0;
      shadowColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      //floatingActionButton: createFloatingActionButton(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
        shadowColor: shadowColor,
        elevation: elevation,
        title: AppBarTitleText('portfolio_detail_title'.tr()),
        actions: [
          AppBarConnectionStatus(
            child: Container(
              width: 20.0,
              height: 20.0,
              color: Colors.transparent,
            ),
          ),
        ],
        leading: AppBarActionIcon(
          'images/icons/action_back.png',
          () {
            Navigator.of(context).pop();
          },
          //color: Theme.of(context).accentColor,
        ),
      ),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {

    Widget codeWidget;
    if(widget.init_historical){
      codeWidget = Text(
        widget.init_stock_code,
        style: InvestrendTheme.of(context).small_w400,
      );
    }else{
      codeWidget = Consumer(builder: (context, watch, child) {
        final notifier = watch(primaryStockChangeNotifier);
        if (notifier.invalid()) {
          return Center(child: CircularProgressIndicator());
        }
        return Text(
          notifier.stock.code,
          style: InvestrendTheme.of(context).small_w400,
        );
      });
    }
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              //color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Consumer(builder: (context, watch, child) {
                      final notifier = watch(primaryStockChangeNotifier);
                      if (notifier.invalid()) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Text(
                        notifier.stock.code,
                        style: InvestrendTheme.of(context).small_w400,
                      );
                    }),
                    //SampleRiverpod(),

                    Consumer(builder: (context, watch, child) {
                      final notifier = watch(stockSummaryChangeNotifier);
                      if (notifier.invalid()) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Text(
                        InvestrendTheme.formatPrice(notifier.summary.close),
                        style: InvestrendTheme.of(context).medium_w600,
                      );
                    }),

                  ],
                ),
              ),
            ),
          ),

          Hero(
            tag: 'button_buy',
            child: Padding(
              padding: const EdgeInsets.only(
                left: 18.0,
                right: 0,
              ),
              child: ButtonOrder(
                OrderType.Buy,
                    () {

                  int close = context.read(stockSummaryChangeNotifier).summary.close;

                  bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
                  InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Buy, initialPriceLot: PriceLot(close, 0));

                },
              ),
            ),
          ),

          Hero(
            tag: 'button_sell',
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0),
              child: ValueListenableBuilder(
                  valueListenable: _portfolioNotifier,
                  builder: (context, StockPositionDetail value, child) {


                    VoidCallback onPressed;
                    if(value.netBalance.toInt() > 0){
                      onPressed = () {
                        int close = context.read(stockSummaryChangeNotifier).summary.close;

                        bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
                        InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Sell, initialPriceLot: PriceLot(close, 0));

                      };
                    }
                    return ButtonOrder(OrderType.Sell, onPressed);

                    /*
                    return Column(
                      children: [
                        createLabelValue('portfolio_detail_owned_lot'.tr(), InvestrendTheme.formatPrice(value.netBalance.toInt())),
                        createLabelValue('portfolio_detail_average_price'.tr(), InvestrendTheme.formatPrice(value.avgPrice.toInt())),
                      ],
                    );
                    */
                  }),
              /*
              child: ButtonOrder(OrderType.Sell, () {
                int close = context.read(stockSummaryChangeNotifier).summary.close;

                bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
                InvestrendTheme.pushScreenTrade(context, hasAccount, type: OrderType.Sell, initialPriceLot: PriceLot(close, 0));

              }),
              */
            ),
          ),

        ],
      ),
    );
  }
}
