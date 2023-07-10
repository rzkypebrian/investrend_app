import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBarTitleText extends StatelessWidget {
  final String text;
  const AppBarTitleText(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).appBarTheme.titleTextStyle,
    );
  }
}
class AppBarConnectionStatus extends StatelessWidget {
  final Widget child; // action bar
  const AppBarConnectionStatus({this.child, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(child == null){
      return Consumer(builder: (context, watch, child) {
        final notifier = watch(managerDatafeedNotifier);
        return Container(
          // width: 5.0,
          // height: 5.0,
          //color: notifier.statusColor,
          child: Icon(Icons.circle, color: notifier.statusColor, size: 10.0,),
        );
      });
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: Consumer(builder: (context, watch, child) {
              final notifier = watch(managerDatafeedNotifier);
              return Container(
                // width: 5.0,
                // height: 5.0,
                //color: notifier.statusColor,
                margin: EdgeInsets.only(top: 2.0, right: 2.0),
                child: Icon(Icons.circle, color: notifier.statusColor, size: 12.0,),
              );
            }),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: Consumer(builder: (context, watch, child) {
              final notifier = watch(managerEventNotifier);


              return Container(
                // width: 5.0,
                // height: 5.0,
                //color: notifier.statusColor,
                margin: EdgeInsets.only(top: 5.0, right: 5.0),

                decoration: BoxDecoration(
                  // border: Border.all(
                  //   width: 0.5,
                  //   color: Theme.of(context).backgroundColor,
                  //   style: BorderStyle.none,
                  // ),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Theme.of(context).colorScheme.background,
                  // color: Colors.black,
                ),
                child: Icon(Icons.circle, color: notifier.statusColor, size: 6.0,),
                // child: SizedBox(width: 5.0, height: 5.0,),
              );
            }),
          ),
        ),
        child,
      ],
    );
  }
}

class AppBarActionIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onPressed;
  final Size size;
  Color color;
  AppBarActionIcon(this.asset, this.onPressed, {Key key, this.size, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      //icon: Image.asset(asset, color: Theme.of(context).appBarTheme.foregroundColor),
      //visualDensity: VisualDensity.comfortable,
      icon: _imageAsset(context, asset, size: size),
      onPressed: onPressed,
      // onPressed: () {
      //   final snackBar = SnackBar(content: Text('Action Search clicked. tab : ' + _selectedTab.index.toString()));
      //
      //   // Find the ScaffoldMessenger in the widget tree
      //   // and use it to show a SnackBar.
      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // },
    );
  }
  Widget _imageAsset(BuildContext context, String asset,{Size size}){
    if(color == null){
      color = Theme.of(context).appBarTheme.foregroundColor;
    }
    if(size == null){
      return Image.asset(asset, color: color, width: 20.0, height: 20.0,);
    }else{
      return Image.asset(asset, color: color, width: size.width, height: size.height,);
    }
  }

}
