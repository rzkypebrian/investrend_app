import 'package:Investrend/objects/home_objects.dart';
import 'package:Investrend/objects/riverpod_change_notifier.dart';
import 'package:Investrend/objects/iii_objects.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

extension Utility on BuildContext {
  void nextEditableTextFocus() {
    do {
      FocusScope.of(this).nextFocus();
    } while (FocusScope.of(this).focusedChild.context.widget is! EditableText);
  }
}

class ComponentCreator {
  static Widget dotsIndicator(BuildContext context, int size,
      int defaultSelectedIndex, ValueNotifier<int> notifier) {
    double dotSelectedWidth = 20;
    double dotWidth = 10;
    double dotHeight = 5;
    double dotSpaceBetween = 5;
    List<Widget> dots = List.empty(growable: true);
    for (int i = 0; i < size; i++) {
      if (i > 0) {
        // space between dots
        dots.add(SizedBox(
          width: dotSpaceBetween,
        ));
      }
      Widget dot = ValueListenableBuilder<int>(
          valueListenable: notifier,
          builder: (context, value, child) {
            bool selected = notifier.value == i;
            return AnimatedContainer(
                width: selected ? dotSelectedWidth : dotWidth,
                height: dotHeight,
                //color: selected ? Colors.cyan : Colors.grey,
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey[300],
                  border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[300],
                      width: selected ? dotSelectedWidth : dotWidth),
                  // added
                  borderRadius: BorderRadius.circular(2.0),
                ),
                duration: Duration(milliseconds: (selected ? 500 : 500)));
          });
      dots.add(dot);
    }
    int lenght = dots.length;
    print('dots size : $lenght.');
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: dots);
  }

  static Widget roundedButtonSolid(BuildContext context, String text,
      Color color, Color textColor, VoidCallback onPressed,
      {EdgeInsets padding, OutlinedBorder border}) {
    if (padding == null) {
      padding = EdgeInsets.all(10.0);
    }
    if (border == null) {
      border = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      );
    }

    return OutlinedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(padding),
        backgroundColor: MaterialStateColor.resolveWith((states) {
          final Color colors = states.contains(MaterialState.pressed)
              ? color.withOpacity(0.5)
              : color;
          return colors;
        }),
        shape: MaterialStateProperty.all<OutlinedBorder>(border),
        side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
          final Color colors = states.contains(MaterialState.pressed)
              ? color.withOpacity(0.5)
              : color;
          return BorderSide(color: colors, width: 2);
        }),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: Theme.of(context).textTheme.button.copyWith(color: textColor)),
    );
  }

  static Widget divider(BuildContext context, {double thickness = 1.0}) {
    return Divider(
      height: thickness,
      thickness: thickness,
      color: Theme.of(context).dividerColor,
    );
  }

  static Widget dividerCard(BuildContext context, {double thickness = 2.0}) {
    return Divider(
      height: thickness,
      thickness: thickness,
      color: Theme.of(context).dividerColor,
    );
  }

  static Widget roundedButtonHollow(BuildContext context, String text,
      Color color, Color textColor, VoidCallback onPressed,
      {double borderWidth = 2.0}) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) {
          final Color colors =
              states.contains(MaterialState.pressed) ? color : color;
          return colors;
        }),
        padding: MaterialStateProperty.all(EdgeInsets.all(10.0)),
        shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
        side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
          final Color colors =
              states.contains(MaterialState.pressed) ? textColor : textColor;
          return BorderSide(color: colors, width: borderWidth);
        }),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: Theme.of(context).textTheme.button.copyWith(color: textColor)),
    );
  }

  static Widget keyboardHider(BuildContext context, Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: child,
    );
  }

  static Widget dropdownButton(
      BuildContext context,
      Key dropDownKey,
      String selectedCity,
      bool lightTheme,
      String label,
      String hint,
      ValueChanged<String> onChanged,
      List<String> items,
      bool validatorError,
      String validatorErrorText) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
          child: Align(
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
              )),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 3.0, right: 3.0, bottom: 3.0),
              child: Text(
                label,
                //style: Theme.of(context).textTheme.caption,
                style: InvestrendTheme.of(context).inputLabelStyle,
                // style: Theme.of(context)
                //     .textTheme
                //     .caption.copyWith(color: InvestrendCustomTheme.textfield_labelTextColor(lightTheme),
                // ),
                // style: TextStyle(
                //
                //     color: InvestrendCustomTheme.textfield_labelTextColor(
                //         lightTheme)),
              ),
            ),
            SizedBox(
              height: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3.0, right: 3.0),
              child: DropdownButton<String>(
                key: dropDownKey,
                //style: TextStyle(color: Colors.gr),
                value: StringUtils.isEmtpy(selectedCity) ? null : selectedCity,
                hint: Text(
                  hint,
                  style: InvestrendTheme.of(context).inputHintStyle,
                ),
                style: InvestrendTheme.of(context).inputStyle,
                //style: Theme.of(context).textTheme.bodyText2.copyWith(height: 1.5),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.transparent,
                ),
                iconSize: 24,
                elevation: 16,
                isDense: true,

                //style: const TextStyle(color: Colors.deepPurple),
                underline: SizedBox(
                  height: 0,
                ),
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                //padding: const EdgeInsets.only(left: 3.0, right: 10.0),
                width: double.maxFinite,
                height: validatorError ? 1.0 : 1.0,
                color: validatorError
                    ? Theme.of(context).colorScheme.error
                    : Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3.0, right: 3.0, top: 8.0),
              child: Text(
                validatorErrorText,
                key: UniqueKey(),
                //style: Theme.of(context).textTheme.caption.copyWith(color: validatorError ? Theme.of(context).errorColor : Colors.transparent),
                style: InvestrendTheme.of(context).inputErrorStyle.copyWith(
                    color: validatorError
                        ? Theme.of(context).colorScheme.error
                        : Colors.transparent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget roundedButtonHollowIcon(
      BuildContext context,
      String text,
      Color color,
      Color textColor,
      Color borderColor,
      String imageAsset,
      VoidCallback onPressed,
      {double borderWidth = 1.0,
      TextStyle textStyle}) {
    if (textStyle == null) {
      textStyle = Theme.of(context).textTheme.button.copyWith(color: textColor);
    }
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) {
          final Color colors = states.contains(MaterialState.pressed)
              ? color.withOpacity(0.5)
              : color;
          return colors;
        }),
        padding: MaterialStateProperty.all(EdgeInsets.all(10.0)),
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        )),
        side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
          final Color colors = states.contains(MaterialState.pressed)
              ? borderColor.withOpacity(0.5)
              : borderColor;
          return BorderSide(color: colors, width: borderWidth);
        }),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox(width: 10.0,),
          //Image.asset(imageAsset),
          Image.asset(
            imageAsset,
            width: 20.0,
            height: 20.0,
          ),
          // Spacer(
          //   flex: 1,
          // ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            text,
            style: textStyle,
          ),
          // Spacer(
          //   flex: 1,
          // ),
          // SizedBox(width: 10.0,),
        ],
      ),
    );
  }

  /*
  static Widget roundedButtonHollow(BuildContext context, String text, Color color,
      Color textColor,  Color borderColor, VoidCallback onPressed) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states)
        {
          final Color colors = states.contains(MaterialState.pressed)
              ? color
              : color;
          return colors;
        }),
        shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
        side: MaterialStateProperty.resolveWith<BorderSide>(
                (Set<MaterialState> states) {
              final Color colors = states.contains(MaterialState.pressed)
                  ? borderColor
                  : borderColor;
              return BorderSide(color: colors, width: 2);
            }
        ),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .button
              .copyWith(color: textColor)),
    );
  }
  */

  static Widget roundedButton(BuildContext context, String text, Color color,
      Color textColor, Color borderColor, VoidCallback onPressed,
      {EdgeInsets padding, Color disabledColor, double radius}) {
    if (padding == null) {
      padding = EdgeInsets.all(10.0);
    }
    if (disabledColor == null) {
      disabledColor = Theme.of(context).disabledColor;
    }
    return Material(
        color: Colors.transparent,
        child: InkWell(
          child: MaterialButton(
            padding: padding,
            //EdgeInsets.all(10.0),
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            //color: Theme.of(context).accentColor,
            disabledColor: disabledColor,
            disabledTextColor: textColor,
            color: color,
            //textColor: Theme.of(context).primaryColor,
            textColor: textColor,
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: textColor)),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(radius ?? 16.0),
              side: BorderSide(
                color: onPressed != null ? borderColor : disabledColor,
              ),
            ),
            onPressed: onPressed,
          ),
        ));
  }
  /*
  static Widget roundedButton(BuildContext context, String text, Color color, Color textColor, Color borderColor, VoidCallback onPressed,
      {EdgeInsets padding, Color disabledColor, }) {
    if (padding == null) {
      padding = EdgeInsets.all(10.0);
    }
    if(disabledColor == null){
      disabledColor = Theme.of(context).disabledColor;
    }
    return Material(
        color: Colors.transparent,
        child: InkWell(
          child: MaterialButton(
            padding: padding,
            //EdgeInsets.all(10.0),
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            //color: Theme.of(context).accentColor,
            disabledColor: disabledColor,
            disabledTextColor: textColor,
            color: color,
            //textColor: Theme.of(context).primaryColor,
            textColor: textColor,
            child: Text(text, style: Theme.of(context).textTheme.button.copyWith(color: textColor)),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(16.0),
              side: BorderSide(
                color: onPressed != null ? borderColor : disabledColor,
              ),
            ),
            onPressed: onPressed,
          ),
        ));
  }
  */
  // static Widget appBarImageAsset(BuildContext context, String asset,{Size size}){
  //   if(size == null){
  //     return Image.asset(asset, color: Theme.of(context).appBarTheme.foregroundColor, width: 20.0, height: 20.0,);
  //   }else{
  //     return Image.asset(asset, color: Theme.of(context).appBarTheme.foregroundColor, width: size.width, height: size.height,);
  //   }
  // }

  static Widget getTextButton(BuildContext context, String text, Color color,
      Color textColor, Color borderColor, VoidCallback onPressed) {
    return Material(
        child: InkWell(
      splashColor: Colors.red,
      focusColor: Colors.green,
      highlightColor: Colors.yellow,
      child: MaterialButton(
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        //color: Theme.of(context).accentColor,
        color: color,
        //textColor: Theme.of(context).primaryColor,
        textColor: textColor,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        onPressed: onPressed,
      ),
    ));
  }

  static Widget roundedButtonIcon(
      BuildContext context,
      String text,
      Color color,
      Color textColor,
      Color borderColor,
      String imageAsset,
      VoidCallback onPressed) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          child: MaterialButton(
            padding: const EdgeInsets.all(10.0),
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            //color: Theme.of(context).accentColor,
            color: color,
            //textColor: Theme.of(context).primaryColor,
            textColor: textColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  imageAsset,
                  height: 20.0,
                  width: 20.0,
                ),
                SizedBox(
                  width: 20.0,
                ),
                Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: textColor),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(16.0),
              side: BorderSide(
                color: borderColor,
              ),
            ),
            onPressed: onPressed,
          ),
        ));
  }

  static Widget textFieldForm(
    BuildContext context,
    bool lightTheme,
    String prefixText,
    String labelText,
    String hintText,
    String helperText,
    String errorText,
    bool obscureText,
    TextInputType keyboardType,
    TextInputAction textInputAction,
    FormFieldValidator<String> validator,
    TextEditingController controller,
    GestureTapCallback onTap,
    FocusNode focusNode,
    Widget suffixIcon, {
    bool enabled = true,
    String initialValue,
    EdgeInsets padding,
    List<TextInputFormatter> inputFormatters,
    int maxLenght = TextField.noMaxLength,
  }) {
    if (obscureText == null) obscureText = false;
    if (keyboardType == null) keyboardType = TextInputType.text;
    if (textInputAction == null) textInputAction = TextInputAction.done;
    if (validator == null && !StringUtils.isEmtpy(errorText)) {
      validator = (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      };
    }

    Widget textField = TextFormField(
      initialValue: initialValue,
      controller: controller,
      keyboardType: keyboardType,
      style: InvestrendTheme.of(context).inputStyle,
      onTap: onTap,
      focusNode: focusNode,
      cursorColor: Theme.of(context).colorScheme.secondary,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
      onEditingComplete: () {
        if (textInputAction == TextInputAction.next) {
          context.nextEditableTextFocus();
        } else if (textInputAction == TextInputAction.done) {
          FocusScope.of(context).unfocus();
        }
      },
      maxLength: maxLenght,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: 2.0)),
        disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0)),
        focusColor: Theme.of(context).colorScheme.secondary,
        prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
        prefixText: prefixText,
        hintStyle: InvestrendTheme.of(context).inputHintStyle,
        helperStyle: InvestrendTheme.of(context).inputHelperStyle,
        errorStyle: InvestrendTheme.of(context).inputErrorStyle,
        errorMaxLines: 2,
        //floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        helperText: helperText,
        helperMaxLines: 3,
        fillColor: Colors.grey,
        contentPadding: suffixIcon == null
            ? EdgeInsets.all(0.0)
            : EdgeInsets.only(top: 10.0),
        enabled: enabled,
      ),
    );
    Widget stack;
    if (!StringUtils.isEmtpy(prefixText)) {
      stack = Stack(
        children: [
          AbsorbPointer(
            child: TextFormField(
              initialValue: ' ',
              //controller: controller,
              keyboardType: keyboardType,
              style: InvestrendTheme.of(context).inputStyle,
              //onTap: onTap,
              //focusNode: focusNode,
              cursorColor: Colors.transparent,
              cursorWidth: 0.0,
              textInputAction: textInputAction,
              obscureText: obscureText,
              //validator: validator,
              onEditingComplete: () {
                if (textInputAction == TextInputAction.next) {
                  context.nextEditableTextFocus();
                } else if (textInputAction == TextInputAction.done) {
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                border: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 2.0)),
                focusColor: Colors.transparent,
                disabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.transparent, width: 1.0)),
                prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                prefixText: prefixText,
                hintStyle: InvestrendTheme.of(context)
                    .inputHintStyle
                    .copyWith(color: Colors.transparent),
                helperStyle: InvestrendTheme.of(context)
                    .inputHelperStyle
                    .copyWith(color: Colors.transparent),
                errorStyle: InvestrendTheme.of(context)
                    .inputErrorStyle
                    .copyWith(color: Colors.transparent),
                errorMaxLines: 2,
                //floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: hintText,
                helperText: helperText,
                helperMaxLines: 3,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.all(0.0),
              ),
            ),
          ),
          textField,
        ],
      );
    }

    return Padding(
      padding: padding ??
          EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText,
            style: InvestrendTheme.of(context).inputLabelStyle,
          ),
          stack == null ? textField : stack,
        ],
      ),
    );
    /*
    if (StringUtils.isEmtpy(prefixText)) {
      return Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 0),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            //style: Theme.of(context).textTheme.bodyText2,
            // The validator receives the text that the user has entered.

            style: InvestrendTheme.of(context).inputStyle,

            onTap: onTap,
            focusNode: focusNode,
            cursorColor: Theme.of(context).accentColor,
            textInputAction: textInputAction,
            obscureText: obscureText,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              //(onTap != null ? Icon(Icons.keyboard_arrow_down) : null),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
              focusColor: Theme.of(context).accentColor,
              prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
              // prefixStyle: TextStyle(
              //   fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
              //   //color: InvestrendCustomTheme.textfield_labelTextColor( lightTheme),
              //   color: Theme.of(context).textTheme.bodyText1.color,
              // ),
              prefixText: prefixText,
              labelText: labelText,
              labelStyle: InvestrendTheme.of(context).inputLabelStyle,
              hintStyle: InvestrendTheme.of(context).inputHintStyle,
              //labelStyle: Theme.of(context).inputDecorationTheme.labelStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
              //hintStyle: Theme.of(context).inputDecorationTheme.hintStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
              helperStyle: InvestrendTheme.of(context).inputHelperStyle,
              errorStyle: InvestrendTheme.of(context).inputErrorStyle,
              // labelStyle: TextStyle(
              //   color: Theme.of(context).textTheme.bodyText1.color,
              // ),

              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: hintText,
              helperText: helperText,

              helperMaxLines: 3,
              fillColor: Colors.grey,
              contentPadding: EdgeInsets.all(3.0),
            ),
            validator: validator,
            onEditingComplete: () {
              if (textInputAction == TextInputAction.next) {
                context.nextEditableTextFocus();
              } else if (textInputAction == TextInputAction.done) {
                FocusScope.of(context).unfocus();
              }
            },
          ));
    } else {
      return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 0),
        child: Stack(
          children: [
            // Positioned.fill(
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Padding(
            //       padding: const EdgeInsets.only(left: 3.0, bottom: 10.0),
            //       child: Text(prefixText, style: InvestrendTheme.of(context).small_w400
            //           // style: TextStyle(
            //           //   fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
            //           //   color: Theme.of(context).textTheme.bodyText1.color,
            //           // ),
            //           ),
            //     ),
            //   ),
            // ),
            AbsorbPointer(
              child: TextFormField(
                initialValue: ' ',
                //controller: controller,
                keyboardType: keyboardType,
                onTap: onTap,
                focusNode: focusNode,
                style: InvestrendTheme.of(context).inputStyle.copyWith(color: Colors.transparent),

                //prefixStyle: InvestrendTheme.of(context).small_w500,
                //style: Theme.of(context).textTheme.bodyText2,
                // The validator receives the text that the user has entered.
                cursorColor: Theme.of(context).accentColor,
                textInputAction: textInputAction,
                obscureText: obscureText,
                //obscuringCharacter: '❄',
                decoration: InputDecoration(
                  suffixIcon: suffixIcon,
                  //(onTap != null ? Icon(Icons.keyboard_arrow_down) : null),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 1.0)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2.0)),
                  focusColor: Theme.of(context).accentColor,
                  //prefixStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1.fontSize, color: Colors.transparent),
                  prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                  prefixText: prefixText,
                  labelText: labelText,

                  labelStyle: InvestrendTheme.of(context).inputLabelStyle.copyWith(color: Colors.transparent),
                  hintStyle: InvestrendTheme.of(context).inputHintStyle.copyWith(color: Colors.transparent),
                  //labelStyle: Theme.of(context).inputDecorationTheme.labelStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                  //hintStyle: Theme.of(context).inputDecorationTheme.hintStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                  errorStyle: InvestrendTheme.of(context).inputErrorStyle.copyWith(color: Colors.transparent),
                  helperStyle: InvestrendTheme.of(context).inputHelperStyle.copyWith(color: Colors.transparent),
                  //labelStyle: InvestrendTheme.of(context).support_w400,
                  // labelStyle: TextStyle(
                  //   color: Theme.of(context).textTheme.bodyText1.color,
                  // ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: ' ',
                  helperText: ' ',

                  helperMaxLines: 3,

                  fillColor: Colors.grey,
                  contentPadding: EdgeInsets.all(3.0),
                ),
                validator: validator,
                onEditingComplete: () {
                  if (textInputAction == TextInputAction.next) {
                    context.nextEditableTextFocus();
                  } else if (textInputAction == TextInputAction.done) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              onTap: onTap,
              focusNode: focusNode,
              style: InvestrendTheme.of(context).inputStyle,
              //style: Theme.of(context).textTheme.bodyText2,
              // The validator receives the text that the user has entered.
              cursorColor: Theme.of(context).accentColor,
              textInputAction: textInputAction,
              obscureText: obscureText,
              //obscuringCharacter: '❄',
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                //(onTap != null ? Icon(Icons.keyboard_arrow_down) : null),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2.0)),
                focusColor: Theme.of(context).accentColor,
                //prefixStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1.fontSize, color: Colors.transparent),
                prefixStyle: InvestrendTheme.of(context).inputPrefixStyle.copyWith(color: Colors.transparent),
                prefixText: prefixText,
                labelText: labelText,

                labelStyle: InvestrendTheme.of(context).inputLabelStyle,
                hintStyle: InvestrendTheme.of(context).inputHintStyle,
                //labelStyle: Theme.of(context).inputDecorationTheme.labelStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                //hintStyle: Theme.of(context).inputDecorationTheme.hintStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                errorStyle: InvestrendTheme.of(context).inputErrorStyle,
                helperStyle: InvestrendTheme.of(context).inputHelperStyle,
                //labelStyle: InvestrendTheme.of(context).support_w400,
                // labelStyle: TextStyle(
                //   color: Theme.of(context).textTheme.bodyText1.color,
                // ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: hintText,
                helperText: helperText,

                helperMaxLines: 3,

                fillColor: Colors.grey,
                contentPadding: EdgeInsets.all(3.0),
              ),
              validator: validator,
              onEditingComplete: () {
                if (textInputAction == TextInputAction.next) {
                  context.nextEditableTextFocus();
                } else if (textInputAction == TextInputAction.done) {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ],
        ),
      );
    }
    */
  }

  static Widget textFieldSearch(BuildContext context, {VoidCallback onTap}) {
    if (onTap == null) {
      onTap = () {
        FocusScope.of(context).requestFocus(new FocusNode());
        final result = InvestrendTheme.showFinderScreen(context);
        result.then((value) {
          if (value == null) {
            print('result finder = null');
          } else if (value is Stock) {
            //InvestrendTheme.of(context).stockNotifier.setStock(value);

            context.read(primaryStockChangeNotifier).setStock(value);
            InvestrendTheme.of(context).showStockDetail(context);
            print('result finder = ' + value.code);
          } else if (value is People) {
            print('result finder = ' + value.name);
          }
        });
      };
    }
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          style: InvestrendTheme.of(context).small_w400_compact,
          onTap: onTap,
          //enabled: false,
          decoration: new InputDecoration(
            isDense: true,
            contentPadding:
                EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
            border: new OutlineInputBorder(
              //gapPadding: 0.0,
              borderRadius: const BorderRadius.all(
                const Radius.circular(8.0),
              ),
              borderSide: BorderSide(width: 0.0, color: Colors.transparent),
            ),
            enabledBorder: new OutlineInputBorder(
              //gapPadding: 0.0,
              borderRadius: const BorderRadius.all(
                const Radius.circular(8.0),
              ),
              borderSide: BorderSide(width: 0.0, color: Colors.transparent),
            ),
            focusedBorder: new OutlineInputBorder(
              //gapPadding: 0.0,
              borderRadius: const BorderRadius.all(
                const Radius.circular(8.0),
              ),
              borderSide: BorderSide(width: 0.0, color: Colors.transparent),
            ),
            filled: true,
            prefixIcon: new Icon(
              Icons.search,
              //color: InvestrendTheme.of(context).textGrey,
              color: InvestrendTheme.of(context).appBarActionTextColor,
              size: 25.0,
            ),
            hintText: 'title_search_hint'.tr(),
            fillColor: InvestrendTheme.of(context).tileBackground,
          ),
        ),
      ),
    );
  }

  Widget textFieldFormBackup(
    BuildContext context,
    bool lightTheme,
    String prefixText,
    String labelText,
    String hintText,
    String helperText,
    String errorText,
    bool obscureText,
    TextInputType keyboardType,
    TextInputAction textInputAction,
    FormFieldValidator<String> validator,
    TextEditingController controller,
    GestureTapCallback onTap,
    FocusNode focusNode,
    Widget suffixIcon,
  ) {
    if (obscureText == null) obscureText = false;
    if (keyboardType == null) keyboardType = TextInputType.text;
    if (textInputAction == null) textInputAction = TextInputAction.done;
    if (validator == null && !StringUtils.isEmtpy(errorText)) {
      validator = (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      };
    }

    if (StringUtils.isEmtpy(prefixText)) {
      return Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 0),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            //style: Theme.of(context).textTheme.bodyText2,
            // The validator receives the text that the user has entered.

            style: InvestrendTheme.of(context).inputStyle,

            onTap: onTap,
            focusNode: focusNode,
            cursorColor: Theme.of(context).colorScheme.secondary,
            textInputAction: textInputAction,
            obscureText: obscureText,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              //(onTap != null ? Icon(Icons.keyboard_arrow_down) : null),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2.0)),
              focusColor: Theme.of(context).colorScheme.secondary,
              prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
              // prefixStyle: TextStyle(
              //   fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
              //   //color: InvestrendCustomTheme.textfield_labelTextColor( lightTheme),
              //   color: Theme.of(context).textTheme.bodyText1.color,
              // ),
              prefixText: prefixText,
              labelText: labelText,
              labelStyle: InvestrendTheme.of(context).inputLabelStyle,
              hintStyle: InvestrendTheme.of(context).inputHintStyle,
              //labelStyle: Theme.of(context).inputDecorationTheme.labelStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
              //hintStyle: Theme.of(context).inputDecorationTheme.hintStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
              helperStyle: InvestrendTheme.of(context).inputHelperStyle,
              errorStyle: InvestrendTheme.of(context).inputErrorStyle,
              // labelStyle: TextStyle(
              //   color: Theme.of(context).textTheme.bodyText1.color,
              // ),

              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: hintText,
              helperText: helperText,

              helperMaxLines: 3,
              fillColor: Colors.grey,
              contentPadding: EdgeInsets.all(3.0),
            ),
            validator: validator,
            onEditingComplete: () {
              if (textInputAction == TextInputAction.next) {
                context.nextEditableTextFocus();
              } else if (textInputAction == TextInputAction.done) {
                FocusScope.of(context).unfocus();
              }
            },
          ));
    } else {
      return Padding(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 0),
        child: Stack(
          children: [
            // Positioned.fill(
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Padding(
            //       padding: const EdgeInsets.only(left: 3.0, bottom: 10.0),
            //       child: Text(prefixText, style: InvestrendTheme.of(context).small_w400
            //           // style: TextStyle(
            //           //   fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
            //           //   color: Theme.of(context).textTheme.bodyText1.color,
            //           // ),
            //           ),
            //     ),
            //   ),
            // ),
            AbsorbPointer(
              child: TextFormField(
                initialValue: ' ',
                //controller: controller,
                keyboardType: keyboardType,
                onTap: onTap,
                focusNode: focusNode,
                style: InvestrendTheme.of(context)
                    .inputStyle
                    .copyWith(color: Colors.transparent),

                //prefixStyle: InvestrendTheme.of(context).small_w500,
                //style: Theme.of(context).textTheme.bodyText2,
                // The validator receives the text that the user has entered.
                cursorColor: Theme.of(context).colorScheme.secondary,
                textInputAction: textInputAction,
                obscureText: obscureText,
                //obscuringCharacter: '❄',
                decoration: InputDecoration(
                  suffixIcon: suffixIcon,
                  //(onTap != null ? Icon(Icons.keyboard_arrow_down) : null),
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 1.0)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 2.0)),
                  focusColor: Theme.of(context).colorScheme.secondary,
                  //prefixStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1.fontSize, color: Colors.transparent),
                  prefixStyle: InvestrendTheme.of(context).inputPrefixStyle,
                  prefixText: prefixText,
                  labelText: labelText,

                  labelStyle: InvestrendTheme.of(context)
                      .inputLabelStyle
                      .copyWith(color: Colors.transparent),
                  hintStyle: InvestrendTheme.of(context)
                      .inputHintStyle
                      .copyWith(color: Colors.transparent),
                  //labelStyle: Theme.of(context).inputDecorationTheme.labelStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                  //hintStyle: Theme.of(context).inputDecorationTheme.hintStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                  errorStyle: InvestrendTheme.of(context)
                      .inputErrorStyle
                      .copyWith(color: Colors.transparent),
                  helperStyle: InvestrendTheme.of(context)
                      .inputHelperStyle
                      .copyWith(color: Colors.transparent),
                  //labelStyle: InvestrendTheme.of(context).support_w400,
                  // labelStyle: TextStyle(
                  //   color: Theme.of(context).textTheme.bodyText1.color,
                  // ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: ' ',
                  helperText: ' ',

                  helperMaxLines: 3,

                  fillColor: Colors.grey,
                  contentPadding: EdgeInsets.all(3.0),
                ),
                validator: validator,
                onEditingComplete: () {
                  if (textInputAction == TextInputAction.next) {
                    context.nextEditableTextFocus();
                  } else if (textInputAction == TextInputAction.done) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              onTap: onTap,
              focusNode: focusNode,
              style: InvestrendTheme.of(context).inputStyle,
              //style: Theme.of(context).textTheme.bodyText2,
              // The validator receives the text that the user has entered.
              cursorColor: Theme.of(context).colorScheme.secondary,
              textInputAction: textInputAction,
              obscureText: obscureText,
              //obscuringCharacter: '❄',
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                //(onTap != null ? Icon(Icons.keyboard_arrow_down) : null),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2.0)),
                focusColor: Theme.of(context).colorScheme.secondary,
                //prefixStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyText1.fontSize, color: Colors.transparent),
                prefixStyle: InvestrendTheme.of(context)
                    .inputPrefixStyle
                    .copyWith(color: Colors.transparent),
                prefixText: prefixText,
                labelText: labelText,

                labelStyle: InvestrendTheme.of(context).inputLabelStyle,
                hintStyle: InvestrendTheme.of(context).inputHintStyle,
                //labelStyle: Theme.of(context).inputDecorationTheme.labelStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                //hintStyle: Theme.of(context).inputDecorationTheme.hintStyle.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
                errorStyle: InvestrendTheme.of(context).inputErrorStyle,
                helperStyle: InvestrendTheme.of(context).inputHelperStyle,
                //labelStyle: InvestrendTheme.of(context).support_w400,
                // labelStyle: TextStyle(
                //   color: Theme.of(context).textTheme.bodyText1.color,
                // ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: hintText,
                helperText: helperText,

                helperMaxLines: 3,

                fillColor: Colors.grey,
                contentPadding: EdgeInsets.all(3.0),
              ),
              validator: validator,
              onEditingComplete: () {
                if (textInputAction == TextInputAction.next) {
                  context.nextEditableTextFocus();
                } else if (textInputAction == TextInputAction.done) {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ],
        ),
      );
    }
  }

  static Widget tableCellLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: ComponentCreator.textFit(
        context,
        text,
        alignment: Alignment.centerLeft,
        style: InvestrendTheme.of(context).textLabelStyle,
      ),
    );
  }

  static Widget tableCellValueBold(BuildContext context, String text,
      {Color color}) {
    return Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: ComponentCreator.textFit(
          context,
          text,
          alignment: Alignment.centerLeft,
          style: (color == null
              ? InvestrendTheme.of(context)
                  .textValueStyle
                  .copyWith(fontWeight: FontWeight.bold)
              : InvestrendTheme.of(context)
                  .textValueStyle
                  .copyWith(fontWeight: FontWeight.bold, color: color)),
        ));
    /*
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        text,
        maxLines: 1,
        style: (color == null
            ? InvestrendTheme.of(context).textValueStyle.copyWith(fontWeight: FontWeight.bold)
            : InvestrendTheme.of(context).textValueStyle.copyWith(fontWeight: FontWeight.bold, color: color)),
        textAlign: TextAlign.left,
      ),
    );

     */
  }

  static Widget tableCellLeft(BuildContext context, String text,
      {double padding = 0.0}) {
    return Padding(
      padding: EdgeInsets.only(left: padding, top: 5.0, bottom: 5.0),
      child: Text(
        text,
        maxLines: 1,
        style: InvestrendTheme.of(context).textLabelStyle,
        textAlign: TextAlign.left,
      ),
    );
  }

  static Widget tableCellRight(BuildContext context, String text,
      {double padding = 0.0, Color color}) {
    TextStyle textStyle;
    if (color == null) {
      textStyle = InvestrendTheme.of(context).textValueStyle;
    } else {
      textStyle =
          InvestrendTheme.of(context).textValueStyle.copyWith(color: color);
    }
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.centerRight,
      ),
    );
  }

  static Widget tableCellLeftHeader(BuildContext context, String text,
      {double padding = 0.0, Color color}) {
    TextStyle textStyle;
    if (color == null) {
      //textStyle = InvestrendTheme.of(context).textValueStyle.copyWith(fontWeight: FontWeight.w500);
      textStyle = InvestrendTheme.of(context).small_w500;
    } else {
      textStyle = InvestrendTheme.of(context).small_w500.copyWith(color: color);
    }
    /*
    return Padding(padding: EdgeInsets.only(left: padding, top: 5.0, bottom: 5.0),
      child: AutoSizeText(
        textStyle: textStyle,
        maxLines: 1,
        textAlign: TextAlign.left,
      ),
    );
    */
    return Padding(
      padding: EdgeInsets.only(left: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  static Widget tableCellCenterHeader(BuildContext context, String text,
      {double padding = 0.0, Color color}) {
    TextStyle textStyle;
    if (color == null) {
      textStyle = InvestrendTheme.of(context).small_w500;
    } else {
      textStyle = InvestrendTheme.of(context).small_w500.copyWith(color: color);
    }
    /*
    return Padding(padding: EdgeInsets.only(left: padding, top: 5.0, bottom: 5.0),
      child: AutoSizeText(
        textStyle: textStyle,
        maxLines: 1,
        textAlign: TextAlign.left,
      ),
    );
    */
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.center,
      ),
    );
  }

  static Widget tableCellRightHeader(BuildContext context, String text,
      {double padding = 0.0, Color color}) {
    TextStyle textStyle;
    if (color == null) {
      textStyle = InvestrendTheme.of(context).small_w500;
    } else {
      textStyle = InvestrendTheme.of(context).small_w500.copyWith(color: color);
    }
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.centerRight,
      ),
    );
  }

  static Widget tableCellLeftValue(BuildContext context, String text,
      {double padding = 0.0,
      Color color,
      FontWeight fontWeight,
      double height = 1.0}) {
    TextStyle textStyle;
    if (fontWeight == null) {
      fontWeight = InvestrendTheme.of(context).textValueStyle.fontWeight;
    }
    if (color == null) {
      textStyle = InvestrendTheme.of(context)
          .textValueStyle
          .copyWith(fontWeight: fontWeight, height: height);
    } else {
      textStyle = InvestrendTheme.of(context)
          .textValueStyle
          .copyWith(fontWeight: fontWeight, color: color, height: height);
    }

    return Padding(
      padding: EdgeInsets.only(left: padding, top: 5.0, bottom: 5.0),
      child: AutoSizeText(
        text,
        style: textStyle,
        textAlign: TextAlign.left,
        maxLines: 1,
      ),
    );
    /*
    return Padding(
      padding: EdgeInsets.only(left: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.centerLeft,
      ),
    );
    */
  }

  static Widget tableCellRightValue(BuildContext context, String text,
      {double padding = 0.0,
      Color color,
      FontWeight fontWeight,
      double height = 1.0}) {
    TextStyle textStyle;
    if (fontWeight == null) {
      fontWeight = InvestrendTheme.of(context).textValueStyle.fontWeight;
    }
    if (color == null) {
      textStyle = InvestrendTheme.of(context)
          .textValueStyle
          .copyWith(fontWeight: fontWeight, height: height);
    } else {
      textStyle = InvestrendTheme.of(context)
          .textValueStyle
          .copyWith(fontWeight: fontWeight, color: color, height: height);
    }
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: AutoSizeText(
        text,
        style: textStyle,
        textAlign: TextAlign.right,
        maxLines: 1,
      ),
    );
    /*
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.centerRight,
      ),
    );
    */
  }

  static Widget tableCellCenterValue(BuildContext context, String text,
      {double padding = 0.0,
      Color color,
      FontWeight fontWeight,
      double height = 1.0}) {
    TextStyle textStyle;
    if (fontWeight == null) {
      fontWeight = InvestrendTheme.of(context).textValueStyle.fontWeight;
    }
    if (color == null) {
      textStyle = InvestrendTheme.of(context)
          .textValueStyle
          .copyWith(fontWeight: fontWeight, height: height);
    } else {
      textStyle = InvestrendTheme.of(context)
          .textValueStyle
          .copyWith(fontWeight: fontWeight, color: color, height: height);
    }
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: AutoSizeText(
        text,
        style: textStyle,
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
    /*
    return Padding(
      padding: EdgeInsets.only(right: padding, top: 5.0, bottom: 5.0),
      child: ComponentCreator.textFit(
        context,
        text,
        style: textStyle,
        alignment: Alignment.center,
      ),
    );
    */
  }

  static Widget chip(BuildContext context, String text) {
    return Chip(
      label: Text(text),
      //backgroundColor: InvestrendTheme.of(context).tileBackground,
      //labelStyle: InvestrendTheme.of(context).support_w400_compact.copyWith(color: InvestrendTheme.of(context).blackAndWhiteText),
    );
  }

  static Widget textFit(BuildContext context, String text,
      {Alignment alignment = Alignment.center,
      TextStyle style /*, ValueNotifier valueNotifier */
      }) {
    /*
    Widget contentWidget;
    if(valueNotifier != null){
      contentWidget = ValueListenableBuilder(
        valueListenable: valueNotifier,
        builder: (context, value, child) {

          // if (valueNotifier.invalid()) {
          //   return Center(child: CircularProgressIndicator());
          // }
          // return progressPerformance(context, '1 Day', _compositeNotifier.value.change, _compositeNotifier.value.percentChange);
        },
      );
    }
    */
    if (alignment != null && style != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment, //Alignment.centerLeft,
        child: Text(
          text,
          style: style,
        ),
      );
    } else if (alignment != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment, //Alignment.centerLeft,
        child: Text(
          text,
        ),
      );
    } else {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: style,
        ),
      );
    }
    /*
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment, //Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1,

        //textAlign: TextAlign.start,
      ),
    );
    */
  }

  static Widget subtitle(BuildContext context, String text, {Color color}) {
    TextStyle style = InvestrendTheme.of(context).regular_w600_compact;
    if (color != null) {
      style = style.copyWith(color: color);
    }
    return Text(
      text,
      //style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.bold),
      style: style,
    );
  }

  static Widget imageNetwork(
    String src, {
    Key key,
    double width,
    double height,
    BoxFit fit,
    Widget errorWidget,
  }) {
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Center(child: CircularProgressIndicator());
        // You can use LinearProgressIndicator or CircularProgressIndicator instead
      },
      errorBuilder: (context, error, stackTrace) => Center(
          child: errorWidget != null
              ? errorWidget
              : Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                )),
    );
  }

  static Widget imageNetworkCached(
    String src, {
    Key key,
    double width,
    double height,
    BoxFit fit,
    Widget errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: src,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) {
        return Center(child: CircularProgressIndicator());
      },
      errorWidget: (context, url, error) {
        return Center(
          child: errorWidget != null
              ? errorWidget
              : Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
        );
      },
      // loadingBuilder: (context, child, loadingProgress) {
      //   if (loadingProgress == null) return child;
      //
      //   return Center(child: CircularProgressIndicator());
      //   // You can use LinearProgressIndicator or CircularProgressIndicator instead
      // },
      // errorBuilder: (context, error, stackTrace) =>
      //     Center(
      //         child: errorWidget != null ? errorWidget : Icon(
      //           Icons.error_outline,
      //           color: Theme
      //               .of(context)
      //               .errorColor,
      //         )),
    );
  }

  static Widget subtitleButtonMore(
      BuildContext context, String text, VoidCallback callback,
      {String image = 'images/icons/arrow_forward.png', String textButton}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ComponentCreator.subtitle(context, text),
        getButtonIconHorizontal(
            context,
            image,
            textButton ?? 'button_more'.tr(),
            Theme.of(context).colorScheme.secondary,
            callback),
      ],
    );
  }

  static Widget subtitleNoButtonMore(BuildContext context, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ComponentCreator.subtitle(context, text),
        Opacity(
            opacity: 0.0,
            child: getButtonIconHorizontal(
                context, '', ' ', Colors.transparent, null)),
      ],
    );
  }

  static Widget getButtonIconHorizontal(BuildContext context, String image,
      String text, Color textColor, VoidCallback onPressed) {
    return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child: InkWell(
          child: MaterialButton(
            //visualDensity: VisualDensity.compact,
            padding: EdgeInsets.only(
                left: InvestrendTheme.cardPaddingGeneral,
                right: InvestrendTheme.cardPaddingGeneral,
                top: InvestrendTheme.cardPaddingVertical,
                bottom: InvestrendTheme.cardPaddingVertical),
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,

            //visualDensity: VisualDensity.compact,
            //color: Theme.of(context).accentColor,
            //color: color,
            //textColor: Theme.of(context).primaryColor,
            textColor: textColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    //style: TextStyle(fontSize: 13.0, color: textColor, fontWeight: FontWeight.bold),
                    style: InvestrendTheme.of(context)
                        .small_w600_compact
                        .copyWith(color: textColor),
                  ),
                ),
                StringUtils.isEmtpy(image)
                    ? SizedBox(
                        height: 1.0,
                      )
                    : SizedBox(
                        width: 8.0,
                      ),
                StringUtils.isEmtpy(image)
                    ? SizedBox(
                        height: 13,
                      )
                    : Image.asset(
                        image,
                        width: 13,
                        height: 13,
                      ),
              ],
            ),
            onPressed: onPressed,
          ),
        ));
  }

  static Widget tileNews(BuildContext context, HomeNews news,
      {VoidCallback onClick,
      VoidCallback commentClick,
      VoidCallback likeClick,
      VoidCallback shareClick}) {
    if (onClick == null) {
      onClick = () async {
        try {
          await canLaunch(news.url_news)
              ? await launch(news.url_news)
              : throw 'Could not launch ' + news.url_news;
        } catch (error) {
          InvestrendTheme.of(context).showSnackBar(context, error.toString());
        }
      };
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
          InvestrendTheme.of(context).tileSmallRoundedRadius),
      child: Container(
        color: InvestrendTheme.of(context).tileBackground,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onClick,
            child: Padding(
              padding: EdgeInsets.only(
                  left: InvestrendTheme.of(context).tileRoundedRadius,
                  right: InvestrendTheme.of(context).tileRoundedRadius,
                  top: InvestrendTheme.of(context).tileSmallRoundedRadius,
                  bottom: InvestrendTheme.of(context).tileSmallRoundedRadius),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(
                              InvestrendTheme.of(context)
                                  .tileSmallRoundedRadius),
                          child: ComponentCreator.imageNetwork(
                              news.url_tumbnail,
                              width: 60,
                              height: 60,
                              fit: BoxFit.fill)),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.title,
                              maxLines: 2,
                              style: InvestrendTheme.of(context)
                                  .small_w600_compact
                                  .copyWith(height: 1.2),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              news.time + '  |  ' + news.category,
                              maxLines: 1,
                              style: InvestrendTheme.of(context)
                                  .more_support_w400_compact
                                  .copyWith(letterSpacing: 0.1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: InvestrendTheme.cardMargin,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    news.description,
                    style: InvestrendTheme.of(context)
                        .small_w400_compact
                        .copyWith(
                            color: InvestrendTheme.of(context)
                                .greyLighterTextColor,
                            height: 1.5),
                    maxLines: 2,
                  ),
                  Row(
                    children: [
                      /*
                      IconButton(
                        icon: Image.asset('images/icons/comment.png'),
                        onPressed: commentClick,
                      ),
                      Text(
                        news.commentCount.toString(),
                        style:
                            InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                      ),
                      IconButton(
                        icon: Image.asset('images/icons/like.png'),
                        onPressed: likeClick,
                      ),
                      Text(
                        news.likedCount.toString(),
                        style:
                            InvestrendTheme.of(context).small_w400_compact.copyWith(color: InvestrendTheme.of(context).greyLighterTextColor),
                      ),
                      */
                      Spacer(
                        flex: 1,
                      ),
                      IconButton(
                        icon: Image.asset('images/icons/share.png'),
                        onPressed: shareClick,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget sampleRoundedContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            InvestrendTheme.of(context).tileSmallRoundedRadius),
        child: Container(
          width: double.maxFinite,
          color: InvestrendTheme.of(context).tileBackground,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                  left: InvestrendTheme.of(context).tileRoundedRadius,
                  right: InvestrendTheme.of(context).tileRoundedRadius,
                  top: InvestrendTheme.of(context).tileSmallRoundedRadius,
                  bottom: InvestrendTheme.of(context).tileSmallRoundedRadius),
              child: Text(
                'Sample',
                style: TextStyle(
                    color: InvestrendTheme.of(context).blackAndWhiteText),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // news / wall street thinks
  static Widget roundedContainer(BuildContext context, Widget child,
      {bool noPadding = false}) {
    Widget childToAdd;

    if (noPadding) {
      childToAdd = Padding(
          padding: EdgeInsets.only(
              left: 0.0,
              right: 0.0,
              top: InvestrendTheme.of(context).tileSmallRoundedRadius,
              bottom: InvestrendTheme.of(context).tileSmallRoundedRadius),
          child: child);
    } else {
      childToAdd = Padding(
          padding: EdgeInsets.only(
              left: InvestrendTheme.of(context).tileRoundedRadius,
              right: InvestrendTheme.of(context).tileRoundedRadius,
              top: InvestrendTheme.of(context).tileSmallRoundedRadius,
              bottom: InvestrendTheme.of(context).tileSmallRoundedRadius),
          child: child);
    }

    return Padding(
      padding: const EdgeInsets.only(top: InvestrendTheme.cardPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            InvestrendTheme.of(context).tileSmallRoundedRadius),
        child: Container(
          width: double.maxFinite,
          color: InvestrendTheme.of(context).tileBackground,
          child: Material(
            color: Colors.transparent,
            child: childToAdd,
          ),
        ),
      ),
    );
  }
}
