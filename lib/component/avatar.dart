import 'dart:math';

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AvatarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String placeholder = 'images/loading.gif';
  final String imageUrl;
  final double size;

  const AvatarButton({Key key, this.onPressed, this.imageUrl, this.size = 24})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: ClipOval(
        child:
            ComponentCreator.imageNetwork(imageUrl, width: size, height: size),
      ),
    );
    /*
    return IconButton(
      icon: ClipOval(
        child: SizedBox(
          //child: FadeInImage.assetNetwork(placeholder: placeholder, image: imageUrl,),
          child: ComponentCreator.imageNetwork(imageUrl),
          width: size,
          height: size,
        ),
      ),
      //onPressed: () => Navigator.of(context).pop(),
      onPressed: onPressed,
    );

     */
  }
}

class AvatarButtonText extends StatelessWidget {
  final VoidCallback onPressed;
  final String placeholder = 'images/loading.gif';
  final String imageUrl;
  final double size;
  final String text;

  const AvatarButtonText(
      {Key key, this.onPressed, this.imageUrl, this.size = 24, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: ClipOval(
        child:
            ComponentCreator.imageNetwork(imageUrl, width: size, height: size),
      ),
    );
    /*
    return IconButton(
      icon: ClipOval(
        child: SizedBox(
          //child: FadeInImage.assetNetwork(placeholder: placeholder, image: imageUrl,),
          child: ComponentCreator.imageNetwork(imageUrl),
          width: size,
          height: size,
        ),
      ),
      //onPressed: () => Navigator.of(context).pop(),
      onPressed: onPressed,
    );

     */
  }
}

class AvatarIcon extends StatelessWidget {
  //final VoidCallback onPressed;
  final String placeholder = 'images/loading.gif';
  final String imageUrl;
  final double size;

  const AvatarIcon({Key key, this.imageUrl, this.size = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (StringUtils.isEmtpy(imageUrl)) {
      return Container(
        width: size,
        height: size,
        color: Colors.red,
      );
    }
    return ClipOval(
      child: ComponentCreator.imageNetwork(imageUrl, width: size, height: size),
    );
    /*
    return ClipOval(
      child: SizedBox(
        //child: FadeInImage.assetNetwork(placeholder: placeholder, image: imageUrl,),
        child: ComponentCreator.imageNetwork(imageUrl),
        width: size,
        height: size,
      ),
    );

     */
  }
}

class AvatarIconStocks extends StatelessWidget {
  //final VoidCallback onPressed;
  final String placeholder = 'images/loading.gif';
  final String imageUrl;
  final double size;
  final String label;
  final bool cached;
  TextStyle errorTextStyle;

  AvatarIconStocks(
      {Key key,
      this.imageUrl,
      this.size = 24,
      this.label = '?',
      this.cached = false,
      this.errorTextStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorTextStyle == null) {
      errorTextStyle = Theme.of(context)
          .textTheme
          .button
          .copyWith(color: Theme.of(context).primaryColor);
    }
    if (cached) {
      return ClipOval(
        child: ComponentCreator.imageNetworkCached(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.scaleDown,
          errorWidget: ClipOval(
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Theme.of(context).accentColor,
              child: Text(
                label,
                //style: Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).primaryColor),
                style: errorTextStyle,
              ),
            ),
          ),
        ),
      );
    } else {
      return ClipOval(
        child: ComponentCreator.imageNetwork(
          imageUrl,
          width: size,
          height: size,
          errorWidget: ClipOval(
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Theme.of(context).accentColor,
              child: Text(
                label,
                //style: Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).primaryColor),
                style: errorTextStyle,
              ),
            ),
          ),
        ),
      );
    }

    /*
    return ClipOval(
      child: SizedBox(
        //child: FadeInImage.assetNetwork(placeholder: placeholder, image: imageUrl,),
        child: ComponentCreator.imageNetwork(imageUrl),
        width: size,
        height: size,
      ),
    );

     */
  }
}

class AvatarProfileButton extends StatelessWidget {
  final String url;
  final String fullname;
  final VoidCallback onPressed;
  TextStyle style;
  final double size;

  AvatarProfileButton(
      {this.url = '',
      this.fullname = '??',
      this.onPressed,
      this.style,
      this.size = 30.0,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (style == null) {
      style = Theme.of(context)
          .textTheme
          .button
          .copyWith(color: Theme.of(context).primaryColor);
    }
    CircleAvatar avatar = CircleAvatar(
      foregroundImage: NetworkImage(
        StringUtils.noNullString(url),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: AutoSizeText(
          StringUtils.getFirstDigitNameTwo(fullname).toUpperCase(),
          style: style,
          maxLines: 1,
          minFontSize: 5.0,
        ),
      ),
      backgroundColor: Theme.of(context).accentColor,
      radius: size / 2,
    );
    if (onPressed == null) {
      return avatar;
    }
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: avatar,
      onPressed: onPressed,
      iconSize: size,
      padding: EdgeInsets.all(0.0),
    );
  }
}

class AvatarIconProfile extends StatelessWidget {
  //final VoidCallback onPressed;
  final String placeholder = 'images/loading.gif';
  final String imageUrl;
  final double size;
  final String label;
  final bool cached;
  final bool canEdit;
  TextStyle errorTextStyle;
  VoidCallback onPressed;

  AvatarIconProfile(
      {Key key,
      this.onPressed,
      this.imageUrl,
      this.size = 30,
      this.label = '?',
      this.cached = false,
      this.errorTextStyle,
      this.canEdit = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorTextStyle == null) {
      errorTextStyle = Theme.of(context)
          .textTheme
          .button
          .copyWith(color: Theme.of(context).primaryColor);
    }

    Widget imageWidget;
    if (cached) {
      imageWidget = ClipOval(
        child: ComponentCreator.imageNetworkCached(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.scaleDown,
          errorWidget: ClipOval(
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Theme.of(context).accentColor,
              child: AutoSizeText(
                label,
                //style: Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).primaryColor),
                style: errorTextStyle,
                maxLines: 1,
              ),
            ),
          ),
        ),
      );
    } else {
      imageWidget = ClipOval(
        child: ComponentCreator.imageNetwork(
          imageUrl,
          width: size,
          height: size,
          errorWidget: ClipOval(
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Theme.of(context).accentColor,
              child: AutoSizeText(
                label,
                //style: Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).primaryColor),
                style: errorTextStyle,
                maxLines: 1,
              ),
            ),
          ),
        ),
      );
    }
    if (onPressed == null) {
      return imageWidget;
    } else {
      return IconButton(
        onPressed: onPressed,
        icon: imageWidget,
        iconSize: size,
      );
    }
  }
}

class AvatarListCompetition extends StatelessWidget {
  final double size;
  final int total_participant;
  final List<String> participants_avatar;
  final bool showCountingNumber;

  AvatarListCompetition(
      {Key key,
      this.size = 24,
      this.participants_avatar,
      this.total_participant,
      this.showCountingNumber = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var avatars = <Widget>[];
    if (participants_avatar == null || participants_avatar.length == 0) {
      return Text("No Data");
    }
    double paddingBetween = size * 0.7;
    int count = min(6, participants_avatar.length);

    for (int i = 0; i < count; i++) {
      if (i == 0) {
        avatars.add(AvatarIcon(
          imageUrl: participants_avatar[i],
          size: size,
        ));
      } else {
        avatars.insert(
            0,
            Padding(
              padding: EdgeInsets.only(left: paddingBetween * i),
              child: AvatarIcon(
                imageUrl: participants_avatar[i],
                size: size,
              ),
            ));
      }
    }
    if (count < total_participant && showCountingNumber) {
      int more = total_participant - count;
      avatars.add(Padding(
        padding: EdgeInsets.only(left: paddingBetween * count),
        child: ClipOval(
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            color: Colors.black54,
            child: AutoSizeText(
              '+$more',
              minFontSize: 6.0,
              style: InvestrendTheme.of(context)
                  .more_support_w400_compact
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ));
    }
    return Stack(
      children: avatars,
    );
  }
}
