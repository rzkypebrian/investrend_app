import 'package:Investrend/component/bottom_sheet/bottom_sheet_alert.dart';
import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/screens/base/screen_aware.dart';
import 'package:Investrend/screens/trade/component/bottom_sheet_loading.dart';
import 'package:Investrend/utils/connection_services.dart';
import 'package:Investrend/utils/debug_writer.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';
import 'package:easy_localization/easy_localization.dart';

abstract class BaseStateWithTabs<T extends StatefulWidget> extends VisibilityAwareState with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
  TabController pTabController;
  bool active = false;
  final String routeName;
  final bool notifyStockChange;
  final bool screenAware;
  bool _route_active = false;
  final BaseValueNotifier<bool> visibilityNotifier; // if there is visibilityNotifier, then this screen will ignore VisibilityAwareState event
  BaseStateWithTabs(this.routeName, {this.notifyStockChange = false, this.screenAware = false, this.visibilityNotifier});

  // harus set notifyStockChange = true saat constructor super class
  void onStockChanged(Stock newStock) {}

  void onVisibilityChanged(WidgetVisibility visibility) {
    if(visibilityNotifier != null){
      print('*** onVisibilityChanged ignored for: ${this.routeName}  caused by override of visibilityNotifier.');

    }else {
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
          if (active && mounted) {
            _onInactiveBase(caller: 'onVisibilityChanged.GONE');
          }
          //_onInactiveBase(caller: 'onVisibilityChanged.GONE');
          break;
      }
    }
    super.onVisibilityChanged(visibility);
  }

  void _onActiveBase({String caller = ''}) {
    if(screenAware && !_route_active){
      print(routeName + ' cancelled onActive  $caller caused by  _route_active : $_route_active');
      return;
    }
    if(active){
      print(routeName + ' onActive  $caller  aborted, already active');
      return;
    }
    active = true;
    print(routeName + ' onActive  $caller');
    runPostFrame(onActive);
  }

  void _onInactiveBase({String caller = ''}) {
    if(screenAware && _route_active){
      print(routeName + ' cancelled onInactive  $caller caused by  _route_active : $_route_active');
      return;
    }
    if(!active){
      print(routeName + ' onInactive  $caller  aborted, already inactive');
      return;
    }
    active = false;
    print(routeName + ' onInactive  $caller');
    runPostFrame(onInactive);
  }

  void onActive();

  void onInactive();

  void onRefreshCheckPageStatus(){
    if(!active){
      active = true;
      onActive();
    }
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

  void showLoading(BuildContext context, {String text}) {
    loadingNotifier.value = false;
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return LoadingBottomSheet(
            loadingNotifier,
            text: text,
          );
        });
  }

  void setNotifierError(BaseValueNotifier notifier, String error) {
    if (mounted && notifier != null) {
      //notifier.setError(message: error);

      String errorText = Utils.removeServerAddress(error);
      // const String addr = 'buanacapital.com';
      // if(!StringUtils.isEmtpy(errorText) && errorText.toLowerCase().contains(addr)){
      //   errorText = errorText.replaceFirst(addr, '');
      // }
      notifier.setError(message: errorText);
    }
  }

  void setNotifierNoData(BaseValueNotifier notifier) {
    if (mounted && notifier != null) {
      notifier.setNoData();
    }
  }

  void setNotifierLoading(BaseValueNotifier notifier) {
    if (mounted && notifier != null) {
      notifier.setLoading();
    }
  }

  void handleNetworkError(BuildContext context, error) {
    print(' handleNetworkError : ' + error.toString());
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
          String networkErrorLabel = 'network_error_label'.tr();
          networkErrorLabel = networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
        }
      } else {
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        String errorText = Utils.removeServerAddress(error.toString());
        InvestrendTheme.of(context).showSnackBar(context, errorText);
      }
    }
  }

  /*
  void logoutToLoginScreen(){
    Token token = Token('', '');
    token.save().whenComplete(() {
      Navigator.popUntil(context, (route) {
        print('popUntil : ' + route.toString());
        return route.isFirst;
      });
      InvestrendTheme.pushReplacement(context,  ScreenLogin(), ScreenTransition.Fade,'/login');
    });
  }
  void showDialogInvalidSession(BuildContext context){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => new WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Info'),
          //content: const Text('Login and Order is DISABLED!'),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(text: 'Your login', style: InvestrendTheme.of(context).small_w400, children: [
              TextSpan(
                text: ' Session ',
                style: InvestrendTheme.of(context).small_w700.copyWith(color: Colors.orange),
              ),
              TextSpan(
                text: 'is no longer valid, please',
                style: InvestrendTheme.of(context).small_w400,
              ),
              TextSpan(
                text: 'Relogin.',
                style: InvestrendTheme.of(context).small_w700,
              ),
            ]),
          ),

          actions: <Widget>[

            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.greenAccent),),
              onPressed: () {
                logoutToLoginScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
  */
  VoidCallback _visibilityListener(){
    print(routeName+' _visibilityListener  mounted : $mounted  notifier.value : '+visibilityNotifier.value.toString()+'  current state is_active : $active');
    if(mounted){
      if(visibilityNotifier.value){
        if(!active){
          _onActiveBase(caller: 'visibilityNotifier ');
        }
      }else{
        if (active) {
          _onInactiveBase(caller: 'visibilityNotifier');
        }

      }
    }
  }

  @override
  void initState() {
    super.initState();
    pTabController = new TabController(vsync: this, length: tabsLength());

    if(visibilityNotifier != null){
      visibilityNotifier.addListener(_visibilityListener);
    }
  }
  void _onRouteActiveBase({String caller = ''}) {
    _route_active = true;
    print(routeName + ' _onRouteActiveBase  route_active : $_route_active');
    _onActiveBase(caller: '_onRouteActiveBase');
    //runPostFrame(onActive);
  }

  void _onRouteInactiveBase({String caller = ''}) {
    _route_active = false;
    print(routeName + ' _onRouteInactiveBase  route_active : $_route_active');
    _onInactiveBase(caller: '_onRouteInactiveBase');
  }
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    /*
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: DefaultTabController(
        length: tabsLength(),
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: createTabs(context),
          body: createBody(context, paddingBottom),
        ),
      ),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
    */
    Widget mainWidget = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: createAppBar(context),
      body: DefaultTabController(
        length: tabsLength(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: createTabs(context),
          body: createBody(context, paddingBottom),
        ),
      ),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );

    if (screenAware) {
      return ScreenAware(
        routeName: routeName,
        child: mainWidget,
        onActive: _onRouteActiveBase,
        onInactive: _onRouteInactiveBase,
      );
    } else {
      return mainWidget;
    }
  }

  int tabsLength();

  Widget createTabs(BuildContext context);

  //Widget createBody(BuildContext context);
  Widget createBody(BuildContext context, double paddingBottom);

  Widget createAppBar(BuildContext context);

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }

  void hideKeyboard({BuildContext context}) {
    if (context == null) {
      context = this.context;
    }
    if (mounted && context != null) {
      FocusScope.of(context).requestFocus(new FocusNode());
    } else {
      print('hideKeyboard aborted caused by -->  mounted : $mounted  context : ' + (context != null ? 'OK' : 'NULL'));
    }
  }

  @override
  void dispose() {
    pTabController.dispose();
    loadingNotifier.dispose();
    final container = ProviderContainer();
    if (_stockChangeListener != null) {
      container.read(pageChangeNotifier).removeListener(_stockChangeListener);
    }
    if(visibilityNotifier != null){
      visibilityNotifier.removeListener(_visibilityListener);
    }
    super.dispose();
  }

  VoidCallback _stockChangeListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (notifyStockChange) {
      if (_stockChangeListener != null) {
        context.read(primaryStockChangeNotifier).removeListener(_stockChangeListener);
      } else {
        _stockChangeListener = () {
          if (mounted) {
            Stock newStock = context.read(primaryStockChangeNotifier).stock;
            print(routeName + ' onStockChanged newStock : ' + newStock?.code);
            onStockChanged(newStock);
          }
        };
      }
      context.read(primaryStockChangeNotifier).addListener(_stockChangeListener);
    }
  }
}

abstract class BaseStateNoTabs<T extends StatefulWidget> extends VisibilityAwareState {
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
  final String routeName;
  bool active = false;
  final bool screenAware;
  final bool overrideBackButton;
  bool _route_active = false;

  BaseValueNotifier<bool> visibilityNotifier; // if there is visibilityNotifier, then this screen will ignore VisibilityAwareState event
  BaseStateNoTabs(this.routeName, {this.screenAware = false, this.overrideBackButton=false, this.visibilityNotifier});

  void closeLoading() {
    loadingNotifier.value = true;
  }


  VoidCallback _visibilityListener(){
    print(routeName+' _visibilityListener  mounted : $mounted  notifier.value : '+visibilityNotifier.value.toString()+'  current state is_active : $active');
    if(mounted){
      if(visibilityNotifier.value){
        if(!active){
          _onActiveBase(caller: 'visibilityNotifier ');
        }
      }else{
        if (active) {
          _onInactiveBase(caller: 'visibilityNotifier');
        }

      }
    }
  }
  DateTime pre_backpress;
  @override
  void initState() {
    super.initState();
    pre_backpress = DateTime.now().add(Duration(seconds: -5)); // - 5 detik sebelumnya
    
    if(visibilityNotifier != null){
      visibilityNotifier.addListener(_visibilityListener);
    }
  }

  void showLoading(BuildContext context, {String text}) {
    loadingNotifier.value = false;
    showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        ),
        //backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return LoadingBottomSheet(
            loadingNotifier,
            text: text,
          );
        });
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
          String networkErrorLabel = 'network_error_label'.tr();
          networkErrorLabel = networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
        }
      } else {
        String errorText = Utils.removeServerAddress(error.toString());
        InvestrendTheme.of(context).showSnackBar(context, errorText);
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
      }
    }
  }

  void setNotifierError(BaseValueNotifier notifier, String error) {
    if (mounted && notifier != null) {
      //notifier.setError(message: error);
      String errorText = Utils.removeServerAddress(error);
      // const String addr = 'buanacapital.com';
      // if(!StringUtils.isEmtpy(errorText) && errorText.toLowerCase().contains(addr)){
      //   errorText = errorText.replaceFirst(addr, '');
      // }
      notifier.setError(message: errorText);
      //
    }
  }

  void setNotifierNoData(BaseValueNotifier notifier) {
    if (mounted && notifier != null) {
      notifier.setNoData();
    }
  }

  void setNotifierLoading(BaseValueNotifier notifier) {
    if (mounted && notifier != null) {
      notifier.setLoading();
    }
  }

  void hideKeyboard({BuildContext context}) {
    if (context == null) {
      context = this.context;
    }
    if (mounted && context != null) {
      FocusScope.of(context).requestFocus(new FocusNode());
    } else {
      print(routeName + '.hideKeyboard aborted caused by -->  mounted : $mounted  context : ' + (context != null ? 'OK' : 'NULL'));
    }
  }

  void onVisibilityChanged(WidgetVisibility visibility) {
    if(visibilityNotifier != null){
      print('*** onVisibilityChanged ignored for: ${this.routeName}  caused by override of visibilityNotifier.');

    }else{
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
          if (mounted) {
            _onInactiveBase(caller: 'onVisibilityChanged.GONE');
          }
          break;
      }
    }


    super.onVisibilityChanged(visibility);
  }

  /*
  void logoutToLoginScreen(){
    Token token = Token('', '');
    token.save().whenComplete(() {
      Navigator.popUntil(context, (route) {
        print('popUntil : ' + route.toString());
        return route.isFirst;
      });
      InvestrendTheme.pushReplacement(context,  ScreenLogin(), ScreenTransition.Fade,'/login');
    });
  }
  void showDialogInvalidSession(BuildContext context){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => new WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Info'),
          //content: const Text('Login and Order is DISABLED!'),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(text: 'Your login', style: InvestrendTheme.of(context).small_w400, children: [
              TextSpan(
                text: ' Session ',
                style: InvestrendTheme.of(context).small_w700.copyWith(color: Colors.orange),
              ),
              TextSpan(
                text: 'is no longer valid, please',
                style: InvestrendTheme.of(context).small_w400,
              ),
              TextSpan(
                text: 'Relogin.',
                style: InvestrendTheme.of(context).small_w700,
              ),
            ]),
          ),

          actions: <Widget>[

            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.greenAccent),),
              onPressed: () {
                logoutToLoginScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
  */

  void updateAccountCashPosition(BuildContext context) {
    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    //int accountSize = context.read(dataHolderChangeNotifier).user.accountSize();
    //if (accountSize > 0) {
    if (hasAccount) {
      List<String> listAccountCode = List.empty(growable: true);
      // InvestrendTheme.of(context).user.accounts.forEach((account) {
      //   listAccountCode.add(account.accountcode);
      // });
      context.read(dataHolderChangeNotifier).user.accounts.forEach((account) {
        listAccountCode.add(account.accountcode);
      });

      print(routeName + ' try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp.accountStockPosition(
          '' /*account.brokercode*/,
          listAccountCode,
          context.read(dataHolderChangeNotifier).user.username,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((value) {
        if (mounted) {
          DebugWriter.information(routeName + ' Got accountStockPosition  accountStockPosition.size : ' + value.length.toString());
          AccountStockPosition first = (value != null && value.length > 0) ? value.first : null;
          if (first != null && first.ignoreThis()) {
            // ignore in aja
            print(routeName + ' accountStockPosition ignored.  message : ' + first.message);
          } else {
            context.read(accountsInfosNotifier).updateList(value);

            Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
            if (activeAccount != null) {
              AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
              if (accountInfo != null) {
                //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.rdnBalance);
                //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.cashBalance);
                context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.availableCash, accountInfo.creditLimit);
              }
            }
          }
        } else {
          DebugWriter.information('NOT mounted --> Got accountStockPosition  accountStockPosition.size : ' + value.length.toString());
        }
      }).onError((error, stackTrace) {
        DebugWriter.information(routeName+' accountStockPosition Exception : ' + error.toString());
        handleNetworkError(context, error);
        /*
        if (error is TradingHttpException) {
          DebugWriter.info('mounted : $mounted --> accountStockPosition Exception : ' + error.toString());
          if (mounted) {
            if (error.isUnauthorized()) {
              // if (mounted) {
              InvestrendTheme.of(context).showDialogInvalidSession(context);
              // } else {
              //   DebugWriter.info('NOT mounted --> accountStockPosition Exception : ' + error.toString());
              // }

              return;
            } else {
              String network_error_label = 'network_error_label'.tr();
              network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
              InvestrendTheme.of(context).showSnackBar(context, network_error_label);
              return;
            }
          }
        }
         */
      });
    }
  }

  //VoidCallback _pageListener;

  /*
  @override
  void initState() {
    super.initState();



  }
  */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(routeName + ' didChangeDependencies');
    /*
    if (_pageListener != null) {
      context.read(pageChangeNotifier).removeListener(_pageListener);
    }
    _pageListener = () {
      //final container = ProviderContainer();
      if (!mounted) {
        print(routeName + ' _pageListener ignored, mounted : $mounted');
        return;
      }
      bool isCurrentActive = context.read(pageChangeNotifier).isCurrentActive(routeName);
      print(routeName + ' _pageListener executed, mounted : $mounted  isCurrentActive : $isCurrentActive');
      if (isCurrentActive) {
        if (!active) {
          _onActiveBase(caller: '_pageListener');
        }
      } else {
        if (active) {
          _onInactiveBase(caller: '_pageListener');
        }
      }
    };
    //final container = ProviderContainer();
    context.read(pageChangeNotifier).addListener(_pageListener);
    // }
    */
  }

  @override
  void dispose() {
    active = false;
    // if (_pageListener != null) {
    //   final container = ProviderContainer();
    //   container.read(pageChangeNotifier).removeListener(_pageListener);
    // }
    print(routeName + ' dispose');
    visibilityNotifier?.removeListener(_visibilityListener);
    super.dispose();
  }

  /// ASLI 2021-06-08
  /*
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: createBody(context),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }
  */
  void _onActiveBase({String caller = ''}) {

    if(screenAware && !_route_active){
      print(routeName + ' cancelled onActive  $caller caused by  _route_active : $_route_active');
      return;
    }
    active = true;
    print(routeName + ' onActive  $caller');
    runPostFrame(onActive);
  }

  void _onInactiveBase({String caller = ''}) {
    if(screenAware && _route_active){
      print(routeName + ' cancelled onInactive  $caller caused by  _route_active : $_route_active');
      return;
    }
    active = false;
    print(routeName + ' onInactive  $caller');
    //onInactive();
    runPostFrame(onInactive);
  }

  //bool isTabSelected();

  void onActive();

  void onInactive();

  void _onRouteActiveBase({String caller = ''}) {
    _route_active = true;
    print(routeName + ' _onRouteActiveBase  route_active : $_route_active');
    //runPostFrame(onActive);
    _onActiveBase(caller: '_onRouteActiveBase');
  }

  void _onRouteInactiveBase({String caller = ''}) {
    _route_active = false;
    print(routeName + ' _onRouteInactiveBase  route_active : $_route_active');
    _onInactiveBase(caller: '_onRouteInactiveBase');
  }

  Future<bool> onBackPressed(BuildContext context) async{

    if(context.read(dataHolderChangeNotifier).isLogged){
      final timegap = DateTime.now().difference(pre_backpress);
      final cantExit = timegap >= Duration(seconds: 3);
      print('cantExit : $cantExit');
      pre_backpress = DateTime.now();
      if(cantExit){
        //show snackbar
        final snack = SnackBar(content: Text('exit_back_button_instruction'.tr()),duration: Duration(seconds: 3),);
        ScaffoldMessenger.of(context).showSnackBar(snack);
        return false; // false will do nothing when back press
      }else{
        SystemNavigator.pop();
        return true;   // true will exit the app
      }
    }else{
      SystemNavigator.pop();
      return true;   // true will exit the app
    }
    /*
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('exit_title'.tr(), style: InvestrendTheme.of(context).small_w500,),
        content: new Text('exit_question'.tr(), style: InvestrendTheme.of(context).small_w400,),
        actions: <Widget>[
          TextButton(
            child: Text('button_no'.tr(), style: InvestrendTheme.of(context).small_w600,),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('button_yes'.tr(), style: InvestrendTheme.of(context).small_w500.copyWith(color: InvestrendTheme.redText),),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          /*
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("button_no".tr()),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text("button_yes".tr()),
          ),
          */
        ],
      ),
    ) ??
        false;

     */
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    /*
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: createAppBar(context),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
      bottomNavigationBar: createBottomNavigationBar(context),
    );
    */
    Widget mainWidget = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: createAppBar(context),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
      bottomNavigationBar: createBottomNavigationBar(context),
    );

    if (screenAware) {

      if(overrideBackButton){
        return WillPopScope(onWillPop: ()=>onBackPressed(context),child: ScreenAware(
          routeName: routeName,
          child: mainWidget,
          onActive: _onRouteActiveBase,
          onInactive: _onRouteInactiveBase,
        ));
      }else{
        return ScreenAware(
          routeName: routeName,
          child: mainWidget,
          onActive: _onRouteActiveBase,
          onInactive: _onRouteInactiveBase,
        );
      }
    } else {
      if(overrideBackButton){
        return WillPopScope(onWillPop: ()=>onBackPressed(context),child: mainWidget);
      }else{
        return mainWidget;
      }
      
    }
    /*
    return ScreenAware(
      routeName: routeName,
      onActive: _onActiveBase,
      onInactive: _onInactiveBase,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: createAppBar(context),
        body: createBody(context, paddingBottom),
        bottomSheet: createBottomSheet(context, paddingBottom),
        bottomNavigationBar: createBottomNavigationBar(context),
      ),
    );
    */
  }

  Widget createBottomNavigationBar(BuildContext context) {
    return null;
  }

  Widget createBody(BuildContext context, double paddingBottom);

  Widget createAppBar(BuildContext context);

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }
}

abstract class BaseStateNoTabsWithParentTab<T extends StatefulWidget> extends VisibilityAwareState
    with AutomaticKeepAliveClientMixin<StatefulWidget> {
  final String routeName;
  bool active = false;
  final TabController tabController;
  final int tabIndex;
  final int parentTabIndex;
  final bool notifyStockChange;
  final ValueNotifier<bool> visibilityNotifier; // if there is visibilityNotifier, then this screen will ignore VisibilityAwareState event
  ScrollController pScrollController = ScrollController();
  BaseStateNoTabsWithParentTab(this.routeName, this.tabIndex, this.tabController, {this.parentTabIndex = -1, this.notifyStockChange = false, this.visibilityNotifier});

  // BaseStateNoTabsWithParentTab(this.routeName);
  @override
  bool get wantKeepAlive => true;

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

  void updateAccountCashPosition(BuildContext context) {
    bool hasAccount = context.read(dataHolderChangeNotifier).user.accountSize() > 0;
    //int accountSize = context.read(dataHolderChangeNotifier).user.accountSize();
    //if (accountSize > 0) {
    if (hasAccount) {
      List<String> listAccountCode = List.empty(growable: true);
      // InvestrendTheme.of(context).user.accounts.forEach((account) {
      //   listAccountCode.add(account.accountcode);
      // });
      context.read(dataHolderChangeNotifier).user.accounts.forEach((account) {
        listAccountCode.add(account.accountcode);
      });

      print(routeName + ' try accountStockPosition');
      final accountStockPosition = InvestrendTheme.tradingHttp.accountStockPosition(
          '' /*account.brokercode*/,
          listAccountCode,
          context.read(dataHolderChangeNotifier).user.username,
          InvestrendTheme.of(context).applicationPlatform,
          InvestrendTheme.of(context).applicationVersion);
      accountStockPosition.then((value) {
        if (mounted) {
          DebugWriter.information(routeName + ' Got accountStockPosition  accountStockPosition.size : ' + value.length.toString());
          AccountStockPosition first = (value != null && value.length > 0) ? value.first : null;
          if (first != null && first.ignoreThis()) {
            // ignore in aja
            print(routeName + ' accountStockPosition ignored.  message : ' + first.message);
          } else {
            context.read(accountsInfosNotifier).updateList(value);

            Account activeAccount = context.read(dataHolderChangeNotifier).user.getAccount(context.read(accountChangeNotifier).index);
            if (activeAccount != null) {
              AccountStockPosition accountInfo = context.read(accountsInfosNotifier).getInfo(activeAccount.accountcode);
              if (accountInfo != null) {
                //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.rdnBalance);
                //context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.cashBalance);
                context.read(buyRdnBuyingPowerChangeNotifier).update(accountInfo.outstandingLimit, accountInfo.availableCash, accountInfo.creditLimit);
              }
            }
          }
        } else {
          DebugWriter.information('NOT mounted --> Got accountStockPosition  accountStockPosition.size : ' + value.length.toString());
        }
      }).onError((error, stackTrace) {
        DebugWriter.information(routeName+' accountStockPosition Exception : ' + error.toString());
        handleNetworkError(context, error);
        /*
        if (error is TradingHttpException) {
          DebugWriter.info('mounted : $mounted --> accountStockPosition Exception : ' + error.toString());
          if (mounted) {
            if (error.isUnauthorized()) {
              // if (mounted) {
              InvestrendTheme.of(context).showDialogInvalidSession(context);
              // } else {
              //   DebugWriter.info('NOT mounted --> accountStockPosition Exception : ' + error.toString());
              // }

              return;
            } else {
              String network_error_label = 'network_error_label'.tr();
              network_error_label = network_error_label.replaceFirst("#CODE#", error.code.toString());
              InvestrendTheme.of(context).showSnackBar(context, network_error_label);
              return;
            }
          }
        }
         */
      });
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
          String networkErrorLabel = 'network_error_label'.tr();
          networkErrorLabel = networkErrorLabel.replaceFirst("#CODE#", error.code.toString());
          InvestrendTheme.of(context).showSnackBar(context, networkErrorLabel);
        }
      } else {
        //InvestrendTheme.of(context).showSnackBar(context, error.toString());
        String errorText = Utils.removeServerAddress(error.toString());
        InvestrendTheme.of(context).showSnackBar(context, errorText);
      }
    }
  }

  void setNotifierError(BaseValueNotifier notifier, var error) {
    if (mounted && notifier != null) {

      String errorText = Utils.removeServerAddress(error.toString());
      // const String addr = 'buanacapital.com';
      // if(!StringUtils.isEmtpy(errorText) && errorText.toLowerCase().contains(addr)){
      //   errorText = errorText.replaceFirst(addr, '');
      // }
      notifier.setError(message: errorText);
      //notifier.setError(message: error.toString());

    }
  }

  void setNotifierNoData(BaseValueNotifier notifier) {
    if (mounted && notifier != null) {
      notifier.setNoData();
    }
  }

  void setNotifierLoading(BaseValueNotifier notifier) {
    if (mounted && notifier != null) {
      notifier.setLoading();
    }
  }

  void hideKeyboard({BuildContext context}) {
    if (context == null) {
      context = this.context;
    }
    if (mounted && context != null) {
      FocusScope.of(context).requestFocus(new FocusNode());
    } else {
      print(routeName + '.hideKeyboard aborted caused by -->  mounted : $mounted  context : ' + (context != null ? 'OK' : 'NULL'));
    }
  }

  // VoidCallback _pageListener;
  void onVisibilityChanged(WidgetVisibility visibility) {
    if(visibilityNotifier != null){
      print('*** onVisibilityChanged ignored for: ${this.routeName}  caused by override of visibilityNotifier.');

    }else{
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
          //_onInactiveBase(caller: 'onVisibilityChanged.GONE');
          break;
      }
    }
    super.onVisibilityChanged(visibility);
  }

  VoidCallback _visibilityListener(){
    print(routeName+' _visibilityListener  mounted : $mounted  notifier.value : '+visibilityNotifier.value.toString()+'  current state is_active : $active');
    if(mounted){
      if(visibilityNotifier.value){
        if(!active){
          _onActiveBase(caller: 'visibilityNotifier ');
        }
      }else{
        if (active) {
          _onInactiveBase(caller: 'visibilityNotifier');
        }

      }
    }
  }
  @override
  void initState() {
    super.initState();

    tabController?.addListener(_tabListener);
    /*
    _pageListener = () {
      final container = ProviderContainer();
      if (container.read(pageChangeNotifier).isCurrentActive(routeName)) {
        if (!active) {
          _onActiveBase(caller: '_pageListener');
        }
      } else {
        if (active) {
          _onInactiveBase(caller: '_pageListener');
        }
      }
    };
    final container = ProviderContainer();
    container.read(pageChangeNotifier).addListener(_pageListener);

     */
    if(visibilityNotifier != null){
      print(routeName+' visibilityNotifier.addListener');
      visibilityNotifier.addListener(_visibilityListener);
    }
  }

  @override
  void dispose() {
    active = false;
    pScrollController.dispose();
    final container = ProviderContainer();
    if (_stockChangeListener != null) {
      container.read(pageChangeNotifier).removeListener(_stockChangeListener);
    }
    if (_mainTabListener != null) {
      container.read(mainTabNotifier).removeListener(_mainTabListener);
    }

    if(visibilityNotifier != null){
      print(routeName+' visibilityNotifier.removeListener');
      visibilityNotifier.removeListener(_visibilityListener);
    }

    tabController?.removeListener(_tabListener);
    super.dispose();
  }

  void _onActiveBase({String caller = ''}) {
    if(tabController == null){
      active = true;
    }else{
      active = true && _isTabSelected();
    }

    if (active) {
      //final container = ProviderContainer();
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   context.read(pageChangeNotifier).onActive(routeName);
      // });

      print(routeName + ' onActive  $caller');
      //onActive();
      runPostFrame(onActive);
    }
  }

  @override
  bool _isTabSelected() {
    if(tabController != null){
      return tabIndex == tabController.index;
    }else{
      return false;
    }
  }

  void _onInactiveBase({String caller = ''}) {
    active = false;

    //final container = ProviderContainer();
    // context.read(pageChangeNotifier).onInactive(routeName);

    print(routeName + ' onInactive  $caller');

    runPostFrame(onInactive);
  }

  // harus set notifyStockChange = true saat constructor super class
  void onStockChanged(Stock newStock) {
    pScrollController.animateTo(0,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  VoidCallback _stockChangeListener;
  VoidCallback _mainTabListener;

  void _tabListener (){
    print(routeName+' tabListener mounted : $mounted');
    if (mounted) {
      if (_isTabSelected()) {
        if (!active) {
          _onActiveBase(caller: 'tabListener');
        }
      } else {
        if (active) {
          _onInactiveBase(caller: 'tabListener');
        }
      }
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(routeName + ' didChangeDependencies');

    if (notifyStockChange) {
      if (_stockChangeListener != null) {
        context.read(primaryStockChangeNotifier).removeListener(_stockChangeListener);
      } else {
        _stockChangeListener = () {
          if (mounted) {
            Stock newStock = context.read(primaryStockChangeNotifier).stock;
            print(routeName + ' onStockChanged newStock : ' + newStock?.code);
            onStockChanged(newStock);
          }
        };
      }
      context.read(primaryStockChangeNotifier).addListener(_stockChangeListener);
    }
    //tabController?.addListener(_tabListener);
    /*
    tabController?.addListener(() {
      if (mounted) {
        if (_isTabSelected()) {
          if (!active) {
            _onActiveBase();
          }
        } else {
          if (active) {
            _onInactiveBase();
          }
        }
      }
    });

     */
    if (parentTabIndex != -1) {
      if(_mainTabListener != null ){
        context.read(mainTabNotifier).removeListener(_mainTabListener);
      }else{
        _mainTabListener = (){
          print(routeName+' _mainTabListener mounted : $mounted');
          if (mounted) {
            int currentMainTab = context?.read(mainTabNotifier).index;
            if (currentMainTab == parentTabIndex) {
              if (!active) {
                _onActiveBase(caller: 'mainTabNotifier');
              }
            } else {
              if (active) {
                _onInactiveBase(caller: 'mainTabNotifier');
              }
            }
          }
        };
      }
      context.read(mainTabNotifier).addListener(_mainTabListener);
      /*
      context?.read(mainTabNotifier).addListener(() {
        if (mounted) {
          int currentMainTab = context?.read(mainTabNotifier).index;
          if (currentMainTab == parentTabIndex) {
            if (!active) {
              _onActiveBase(caller: 'mainTabNotifier');
            }
          } else {
            if (active) {
              _onInactiveBase(caller: 'mainTabNotifier');
            }
          }
        }
      });
       */
    }
  }

  void onActive();

  void onInactive();
  void onRefreshCheckPageStatus(){
    if(!active){
      active = true;
      if(visibilityNotifier != null){
        visibilityNotifier.value = true;
      }else{
        _onActiveBase(caller: 'onRefreshCheckPageStatus');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      floatingActionButton: createFloatingActionButton(context),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: createAppBar(context),
      body: createBody(context, paddingBottom),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
    /*
    return ScreenAware(
      routeName: routeName,
      onActive: _onActiveBase,
      onInactive: _onInactiveBase,
      child: Scaffold(
        floatingActionButton: createFloatingActionButton(context),
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: createAppBar(context),
        body: createBody(context, paddingBottom),
        bottomSheet: createBottomSheet(context, paddingBottom),
      ),
    );
    */
  }

  Widget createFloatingActionButton(context) {
    return null;
  }

  Widget createBody(BuildContext context, double paddingBottom);

  Widget createAppBar(BuildContext context);

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }
}

abstract class BaseStatefullWidgetChildTab extends StatefulWidget {
  final TabController tabController;
  final int tabIndex;

  const BaseStatefullWidgetChildTab(this.tabIndex, this.tabController, {Key key}) : super(key: key);
}

abstract class BaseConsumerState<T extends ConsumerWidget> extends State {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: createAppBar(context),
      body: DefaultTabController(
        length: tabsLength(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: createTabs(context),
          body: createBody(context),
        ),
      ),
      bottomSheet: createBottomSheet(context, paddingBottom),
    );
  }

  int tabsLength();

  Widget createTabs(BuildContext context);

  Widget createBody(BuildContext context);

  Widget createAppBar(BuildContext context);

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return null;
  }
}
