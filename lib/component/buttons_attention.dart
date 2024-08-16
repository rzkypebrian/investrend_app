// ignore_for_file: non_constant_identifier_names

import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class ButtonCorporateAction extends StatelessWidget {
  final double? height;
  final TextStyle? style;
  final Color? background_color;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  const ButtonCorporateAction(
      this.height, this.background_color, this.onPressed,
      {this.style, this.padding, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: InvestrendTheme.cardMargin),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height!),
        child: MaterialButton(
          minWidth: height,
          padding: padding ??
              EdgeInsets.only(left: 12.0, right: 12.0, top: 1.0, bottom: 1.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: CircleBorder(
              //borderRadius: BorderRadius.circular(8.0),
              ),
          elevation: 0.0,
          visualDensity: VisualDensity.compact,
          child: AutoSizeText(
            'CA',
            maxLines: 1,
            minFontSize: 5.0,
            style: style ??
                InvestrendTheme.of(context)
                    .small_w600_compact
                    ?.copyWith(color: InvestrendTheme.of(context).whiteColor),
          ),
          color: background_color ?? Color(0xFFAD5E0C),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class ButtonSpecialNotationAnimation extends StatefulWidget {
  final double? height;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final StockInformationStatus? stockInformationStatus;
  final ValueNotifier<bool>? animateSpecialNotationNotifier;

  const ButtonSpecialNotationAnimation(
      this.height, this.onPressed, this.stockInformationStatus,
      {this.padding, this.animateSpecialNotationNotifier, Key? key})
      : super(key: key);

  @override
  _ButtonSpecialNotationAnimationState createState() =>
      _ButtonSpecialNotationAnimationState();
}

class _ButtonSpecialNotationAnimationState
    extends State<ButtonSpecialNotationAnimation>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Tween<double> _tween = Tween(begin: 1.5, end: 1.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _controller!.repeat(reverse: true);
    widget.animateSpecialNotationNotifier!.addListener(() {
      if (mounted) {
        if (widget.animateSpecialNotationNotifier!.value) {
          _controller!.repeat(reverse: true);
        } else {
          _controller!.reset();
          _controller!.value = 1.0;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String image = widget.stockInformationStatus != null
        ? widget.stockInformationStatus!.image
        : 'images/icons/special_notation.png';
    if (StringUtils.isEmtpy(image)) {
      image = 'images/icons/special_notation.png';
    }
    Widget button = ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: widget.height!, minWidth: widget.height!),
      child: MaterialButton(
        minWidth: widget.height,
        padding: widget.padding ??
            EdgeInsets.only(left: 12.0, right: 12.0, top: 1.0, bottom: 1.0),
        shape: CircleBorder(),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(8.0),
        // ),
        visualDensity: VisualDensity.compact,
        elevation: 0.0,
        child: Image.asset(
          //'images/icons/special_notation.png',
          image,
          width: widget.height,
          height: widget.height,
        ),
        //color: Color(0xFFAD5E0C),
        onPressed: widget.onPressed,
      ),
    );

    if (widget.animateSpecialNotationNotifier != null) {
      return ScaleTransition(
          scale: _tween.animate(CurvedAnimation(
              parent: _controller!, curve: Curves.easeInOutCubic)),
          child: button);
    } else {
      return button;
    }
  }
}

class ButtonSpecialNotation extends StatelessWidget {
  final double? height;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final StockInformationStatus? stockInformationStatus;
  final ValueNotifier<bool>? animateSpecialNotationNotifier;

  const ButtonSpecialNotation(
      this.height, this.onPressed, this.stockInformationStatus,
      {this.padding, this.animateSpecialNotationNotifier, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String image = this.stockInformationStatus != null
        ? this.stockInformationStatus!.image
        : 'images/icons/special_notation.png';
    if (StringUtils.isEmtpy(image)) {
      image = 'images/icons/special_notation.png';
    }
    Widget button = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height!, minWidth: height!),
      child: MaterialButton(
        minWidth: height,
        padding: padding ??
            EdgeInsets.only(left: 12.0, right: 12.0, top: 1.0, bottom: 1.0),
        shape: CircleBorder(),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(8.0),
        // ),
        visualDensity: VisualDensity.compact,
        elevation: 0.0,
        child: Image.asset(
          //'images/icons/special_notation.png',
          image,
          width: height,
          height: height,
        ),
        //color: Color(0xFFAD5E0C),
        onPressed: onPressed,
      ),
    );
    if (animateSpecialNotationNotifier != null) {
      return ValueListenableBuilder(
          valueListenable: animateSpecialNotationNotifier!,
          builder: (context, value, child) {
            return AvatarGlow(
              child: button,
              glowColor: InvestrendTheme.of(context).investrendPurple!,
              endRadius: 30.0,
              duration: Duration(milliseconds: 1000),
              repeat: value as bool,
              showTwoGlows: true,
              repeatPauseDuration: Duration(milliseconds: 100),
            );
          });
    } else {
      return button;
    }
  }
}

class ButtonTextAttention extends StatelessWidget {
  final String? text;
  final double? height;
  final TextStyle? style;

  //final Color background_color;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  const ButtonTextAttention(
      this.text, this.height, /*this.background_color,*/ this.onPressed,
      {this.style, this.padding, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height!, minWidth: height!),
      child: MaterialButton(
        minWidth: height,
        padding: padding ??
            EdgeInsets.only(left: 15.0, right: 15.0, top: 1.0, bottom: 1.0),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(2.0),
        // ),

        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(2.0),
          side: BorderSide(
            //color: onPressed != null ? borderColor : Theme.of(context).disabledColor,
            color: onPressed != null
                ? InvestrendTheme.attentionColor
                : Colors.transparent,
          ),
        ),
        elevation: 0.0,
        visualDensity: VisualDensity.compact,
        child: AutoSizeText(
          this.text ?? '-',
          maxLines: 1,
          minFontSize: 5.0,
          style: style ??
              InvestrendTheme.of(context)
                  .small_w600_compact
                  ?.copyWith(color: InvestrendTheme.attentionColor),
        ),
        //color: background_color ?? Color(0xFFAD5E0C),
        color: Theme.of(context).primaryColor,

        onPressed: onPressed,
      ),
    );
  }
}

class ButtonTextAttentionMozaic extends StatefulWidget {
  final String? text;
  final double? height;
  final TextStyle? style;

  //final Color background_color;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final StockInformationStatus? stockInformationStatus;
  final ValueNotifier<bool>? animateSpecialNotationNotifier;

  const ButtonTextAttentionMozaic(
      this.text,
      this.height,
      this.stockInformationStatus,
      /*this.background_color,*/
      this.onPressed,
      {this.style,
      this.padding,
      this.animateSpecialNotationNotifier,
      Key? key})
      : super(key: key);

  @override
  State<ButtonTextAttentionMozaic> createState() =>
      _ButtonTextAttentionMozaicState();
}

class _ButtonTextAttentionMozaicState extends State<ButtonTextAttentionMozaic>
    with TickerProviderStateMixin {
  AutoSizeGroup group = AutoSizeGroup();
  AnimationController? _controller;
  Tween<double> _tween = Tween(begin: 1.2, end: 0.8);
  @override
  void initState() {
    super.initState();
    if (widget.animateSpecialNotationNotifier != null) {
      _controller = AnimationController(
          duration: const Duration(milliseconds: 800), vsync: this);
      _controller!.repeat(reverse: true);
      widget.animateSpecialNotationNotifier!.addListener(() {
        if (mounted) {
          if (widget.animateSpecialNotationNotifier!.value) {
            _controller!.repeat(reverse: true);
          } else {
            _controller!.reset();
            _controller!.value = 1.0;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  Widget mozaicWidget(BuildContext context, String? text, double height) {
    int count = text != null ? text.length : 0;
    if (count == 2) {
      double size = height / 2;
      return Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: characterWidget(context, size, text?[0]),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: characterWidget(context, size, text?[1]),
          ),
        ],
      );
    } else if (count == 3) {
      double size = height / 2;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
            ],
          ),
          characterWidget(context, size, text?[2]),
        ],
      );
    } else if (count == 4) {
      double size = height / 2;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[2]),
              characterWidget(context, size, text?[3]),
            ],
          ),
        ],
      );
    } else if (count == 5) {
      double size = height / 3;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: characterWidget(context, size, text?[2]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[3]),
              characterWidget(context, size, text?[4]),
            ],
          ),
        ],
      );
    } else if (count == 6) {
      double size = height / 3;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[2]),
              characterWidget(context, size, text?[3]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[4]),
              characterWidget(context, size, text?[5]),
            ],
          ),
        ],
      );
    } else if (count == 7) {
      double size = height / 3;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
              characterWidget(context, size, text?[2]),
            ],
          ),
          characterWidget(context, size, text?[3]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[4]),
              characterWidget(context, size, text?[5]),
              characterWidget(context, size, text?[6]),
            ],
          ),
        ],
      );
    } else if (count == 8) {
      double size = height / 3;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
              characterWidget(context, size, text?[2]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[3]),
              characterWidget(context, size, text?[4]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[5]),
              characterWidget(context, size, text?[6]),
              characterWidget(context, size, text?[7]),
            ],
          ),
        ],
      );
    } else if (count == 9) {
      double size = height / 3;
      //List<Widget> childs = List.empty(growable: true);
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
              characterWidget(context, size, text?[2]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[3]),
              characterWidget(context, size, text?[4]),
              characterWidget(context, size, text?[5]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[6]),
              characterWidget(context, size, text?[7]),
              characterWidget(context, size, text?[8]),
            ],
          ),
        ],
      );
    } else if (count == 10) {
      double size = height / 3;
      //List<Widget> childs = List.empty(growable: true);
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
              characterWidget(context, size, text?[2]),
              characterWidget(context, size, text?[3]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[4]),
              characterWidget(context, size, text?[5]),
              characterWidget(context, size, text?[6]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[7]),
              characterWidget(context, size, text?[8]),
              characterWidget(context, size, text?[9]),
            ],
          ),
        ],
      );
    } else if (count == 11) {
      double size = height / 3;
      //List<Widget> childs = List.empty(growable: true);
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
              characterWidget(context, size, text?[2]),
              characterWidget(context, size, text?[3]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              characterWidget(context, size, text?[4]),
              characterWidget(context, size, text?[5]),
              characterWidget(context, size, text?[6]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[7]),
              characterWidget(context, size, text?[8]),
              characterWidget(context, size, text?[9]),
              characterWidget(context, size, text?[10]),
            ],
          ),
        ],
      );
    } else if (count == 12) {
      double size = height / 3;
      //List<Widget> childs = List.empty(growable: true);
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[0]),
              characterWidget(context, size, text?[1]),
              characterWidget(context, size, text?[2]),
              characterWidget(context, size, text?[3]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[4]),
              characterWidget(context, size, text?[5]),
              characterWidget(context, size, text?[6]),
              characterWidget(context, size, text?[7]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              characterWidget(context, size, text?[8]),
              characterWidget(context, size, text?[9]),
              characterWidget(context, size, text?[10]),
              characterWidget(context, size, text?[11]),
            ],
          ),
        ],
      );
    }

    return characterWidget(context, widget.height!, widget.text!);
    /*
    return AutoSizeText(
      this.widget.text ?? '-',
      maxLines: 1,
      minFontSize: 1.0,
      style: widget.style ?? InvestrendTheme.of(context).small_w600_compact.copyWith(color: InvestrendTheme.attentionColor),
      group: group,
    );
    */
  }

  Widget characterWidget(BuildContext context, double size, String? character) {
    return Container(
      width: size,
      height: size,
      //padding: EdgeInsets.all(1.0),
      // color: Colors.deepPurple,
      alignment: Alignment.center,
      child: AutoSizeText(
        character ?? '-',
        maxLines: 1,
        minFontSize: 1.0,
        //style: widget.style ?? InvestrendTheme.of(context).small_w600_compact.copyWith(color: InvestrendTheme.attentionColor),
        style: widget.style ??
            InvestrendTheme.of(context)
                .small_w600_compact
                ?.copyWith(color: Theme.of(context).primaryColor),
        group: group,
        // textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.stockInformationStatus!.colorBorder;
    Color backgrounColor = widget.stockInformationStatus!.colorBackground;

    int count = widget.text != null ? widget.text!.length : 0;
    double width = widget.height!;
    if (count > 9) {
      width = (width / 3) + width;
    }

    Widget button = ConstrainedBox(
      //constraints: BoxConstraints(maxHeight: widget.height, minWidth: widget.height, maxWidth: widget.height),
      constraints: BoxConstraints(
          maxHeight: widget.height!, minWidth: width, maxWidth: width),
      child: MaterialButton(
        //minWidth: widget.height,
        minWidth: width,
        //padding: widget.padding ?? EdgeInsets.only(left: 15.0, right: 15.0, top: 1.0, bottom: 1.0),
        padding: widget.padding ??
            EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 2.0),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(2.0),
        // ),

        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(2.0),
          side: BorderSide(
            color: widget.onPressed != null ? borderColor : Colors.transparent,
            //color: widget.onPressed != null ? InvestrendTheme.attentionColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        elevation: 0.0,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: mozaicWidget(context, this.widget.text!, widget.height! - 4),
        ),
        //color: background_color ?? Color(0xFFAD5E0C),
        //color: Theme.of(context).primaryColor,
        //color: widget.stockInformationStatus.index == StockInformationStatus.UnderWatchlist ? InvestrendTheme.redBackground : InvestrendTheme.attentionColor,
        color: backgrounColor,
        onPressed: widget.onPressed,
      ),
    );

    if (widget.stockInformationStatus!.strip) {
      /*
      return Stack(
        children: [
          button,
          IgnorePointer(
            ignoring: true,
            child: CustomPaint(
              size: Size(widget.height, widget.height),
              painter: StripPainter(),
            ),
          ),
        ],
      );
      */
      Widget stack = Stack(
        children: [
          button,
          IgnorePointer(
            ignoring: true,
            child: CustomPaint(
              size: Size(widget.height!, widget.height!),
              painter: StripPainter(),
            ),
          ),
        ],
      );
      if (widget.animateSpecialNotationNotifier != null) {
        return ScaleTransition(
            scale: _tween.animate(CurvedAnimation(
                parent: _controller!, curve: Curves.easeInOutCubic)),
            child: Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardMargin),
              child: stack,
            ));
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: InvestrendTheme.cardMargin),
          child: stack,
        );
      }
    } else {
      //return button;
      if (widget.animateSpecialNotationNotifier != null) {
        return ScaleTransition(
            scale: _tween.animate(CurvedAnimation(
                parent: _controller!, curve: Curves.easeInOutCubic)),
            child: Padding(
              padding: const EdgeInsets.only(left: InvestrendTheme.cardMargin),
              child: button,
            ));
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: InvestrendTheme.cardMargin),
          child: button,
        );
      }
    }
  }
}

class StripPainter extends CustomPainter {
  //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(size.width - 1, 1);
    final p2 = Offset(1, size.height - 1);
    final paint = Paint()
      ..color = InvestrendTheme.redText
      ..strokeWidth = 1;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
