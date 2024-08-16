import 'package:flutter/cupertino.dart';

class AnimationCreator{

  static Widget transitionSlideUp(BuildContext context, Animation animation,  Animation secondaryAnimation, Widget child){
    var begin = Offset(0.0, 1.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
  static Widget transitionSlideDown(BuildContext context, Animation animation,  Animation secondaryAnimation, Widget child){
    var begin = Offset(0.0, -1.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
  static Widget transitionSlideLeft(BuildContext context, Animation animation,  Animation secondaryAnimation, Widget child){
    var begin = Offset(1.0, 0.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
  static Widget transitionSlideRight(BuildContext context, Animation animation,  Animation secondaryAnimation, Widget child){
    var begin = Offset(-1.0, 0.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}