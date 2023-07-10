import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final double buttonSize;
  final String imageAsset;
  Color imageColor;
  final double imageSize;
  Color backgroundColor;
  Color splashColor;
  final VoidCallback onTap;
  EdgeInsets imagePadding;

  CircleButton(this.imageAsset, {
    this.buttonSize = 40.0,
    this.imageColor,
    this.imageSize = 24.0,
    this.backgroundColor,
    this.splashColor,
    this.onTap,
    this.imagePadding,
    Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    imageColor = imageColor?? Theme.of(context).colorScheme.secondary;
    imagePadding = imagePadding?? EdgeInsets.all(4.0);
    backgroundColor = backgroundColor ?? Theme.of(context).primaryColor;
    splashColor = splashColor ?? Theme.of(context).splashColor;

    return ClipOval(
      child: Material(
        color: backgroundColor, // Button color
        child: InkWell(
          splashColor: splashColor, // Splash color
          onTap: onTap,
          child: SizedBox(width: buttonSize, height: buttonSize,child: Padding(
            padding: imagePadding,
            child: Image.asset(imageAsset, color: imageColor, width: imageSize, height: imageSize,),
            //child: Icon(Icons.arrow_back_ios, size: 24.0, color: Theme.of(context).primaryColor,),
          )),
        ),
      ),
    );
  }
}
