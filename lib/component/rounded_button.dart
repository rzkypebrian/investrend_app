import 'package:flutter/material.dart';
class RoundedButton extends StatelessWidget {

  final VoidCallback onPressed;
  final String text;
  final String imageAsset;
  final Color textColor;
  final Color borderColor;
  final Color color;
  const RoundedButton({Key key,this.text,  this.textColor, this.color, this.onPressed, this.imageAsset,this.borderColor, }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    RoundedRectangleBorder borderShape;
    if(this.borderColor == null){
      borderShape = new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(30.0),
        //side: BorderSide(color: borderColor),
      );
    }else{
      borderShape = new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(30.0),
        side: BorderSide(color: borderColor),
      );
    }

    if(imageAsset == null){
      return MaterialButton(
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,

        //textColor: (textColor == null ? Theme.of(context).accentColor : textColor),
        //color: (color ==null ? Theme.of(context).primaryColor: color),
        child: Row(children: [
          Spacer(flex: 1,),
          Text(text, style: Theme.of(context).textTheme.button.copyWith(
            color: (textColor == null ? Theme.of(context).accentColor : textColor),
          ),),
          Spacer(flex: 1,),
        ],),
        onPressed: onPressed,
        shape: borderShape,
      );
    }else{
      return MaterialButton(
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,

        //textColor: (textColor == null ? Theme.of(context).accentColor : textColor),
        color: (color ==null ? Theme.of(context).primaryColor: color),
        child: Row(children: [
          // SizedBox(width: 20,),
          Image.asset(imageAsset),
          Spacer(flex: 1,),
          Text(text, style: Theme.of(context).textTheme.button.copyWith(
            color: (textColor == null ? Theme.of(context).accentColor : textColor),
          ),),
          Spacer(flex: 1,),
        ],),
        onPressed: onPressed,
        shape: borderShape,
      );
    }
  }
}
