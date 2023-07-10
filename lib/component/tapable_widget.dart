import 'package:flutter/material.dart';

class TapableWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color splashColor;
  const TapableWidget({this.child, this.onTap,this.splashColor, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: splashColor,
        // highlightColor: splashColor,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
