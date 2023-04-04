import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Investrend/main_application.dart';
import 'package:flutter/material.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';





class ScreenAware extends StatefulWidget {
  final Widget child;
  final Function() onInactive;
  final Function() onActive;
  final String routeName;
  ScreenAware({this.child, this.onActive, this.onInactive, @required this.routeName});

  @override
  State<StatefulWidget> createState() {
    return ScreenAwareState();
    // return ScreenVisibilityState();
  }
}

class ScreenVisibilityState extends VisibilityAwareState<ScreenAware> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
  void onLeaveScreen() {
    if (widget.onInactive != null) {
      widget.onInactive();
    }
  }
  void onScreen() {
    if (widget.onActive != null) {
      widget.onActive();
    }
  }

  @override
  void onVisibilityChanged(WidgetVisibility visibility) {
    // TODO: Use visibility
    switch(visibility) {
      case WidgetVisibility.VISIBLE:
        // Like Android's Activity.onResume()
        print('*** ScreenVisibility.VISIBLE: ${widget.routeName}');
        onScreen();
        break;
      case WidgetVisibility.INVISIBLE:
        // Like Android's Activity.onPause()
        print('*** ScreenVisibility.INVISIBLE: ${widget.routeName}');
        onLeaveScreen();
        break;
      case WidgetVisibility.GONE:
        // Like Android's Activity.onDestroy()
        print('*** ScreenVisibility.GONE: ${widget.routeName}');
        onLeaveScreen();
        break;
    }


    super.onVisibilityChanged(visibility);
  }
}
class ScreenAwareState extends State<ScreenAware> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void onLeaveScreen() {
    if (widget.onInactive != null) {
      widget.onInactive();
    }
  }
  void onScreen() {
    if (widget.onActive != null) {
      widget.onActive();
    }
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MainApplication.routeObserver.subscribe(this, ModalRoute.of(context));

  }

  @override
  void dispose() {
    super.dispose();
    MainApplication.routeObserver.unsubscribe(this);
  }

  @override
  void didPush() {
    print('*** ScreenAware.Entering screen: ${widget.routeName}');
    onScreen();
  }

  void didPushNext() {
    print('*** ScreenAware.Leaving screen: ${widget.routeName}');
    onLeaveScreen();
  }

  @override
  void didPop() {
    print('*** ScreenAware.Going back, leaving screen: ${widget.routeName}');
    onLeaveScreen();
  }

  @override
  void didPopNext() {
    print('*** ScreenAware.Going back to screen: ${widget.routeName}');
    onScreen();
  }

}