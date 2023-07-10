import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputComponent {
  static Widget inputTextWithCorner({
    position = InputPosition.Center,
    double corner = 0,
    hintText = "",
    bool obscureText = false,
    String fontsFamily = "",
    Color fontColor, // = SavedDataUtil.data.colors.inputTextColor,
    double fontSize, //= System.data.fontUtil.m,
    TextInputType keyboardType = TextInputType.text,
    Color hintColor = Colors.grey,
    Widget suffixIcon,
    Widget prefixIcon,
    InputComponentTextEditingController controller,
    StateInput stateInput = StateInput.Enable,
    ValueChanged<String> onChanged,
    ValueChanged<String> onSubmited,
    bool numberOnly = false,
    Color inputBorderError = Colors.redAccent,
    Color borderInputGray = Colors.grey,
    double borderWidth = 2,
    bool autoFocus = false,
    VoidCallback onTap,
    FocusNode focusnode,
    VoidCallback onEditingComplete,
    TextInputAction textInputAction = TextInputAction.done,
    TextAlign textAlign = TextAlign.left,
    bool readOnly = false,
    int maxLines,
    Color backgroundColor,
    List<TextInputFormatter> formatter,
    EdgeInsetsGeometry contentPadding,
    String masking,
    bool expands = false,
    TextAlignVertical textAlignVertical,
    // StringBuilder<String> masking,
  }) {
    fontSize = fontSize ?? 14;
    controller.stateInput = (stateInput);
    controller.inputType = keyboardType;
    return Stack(
      children: <Widget>[
        TextField(
          maxLengthEnforcement: MaxLengthEnforcement.none,
          textAlignVertical: textAlignVertical ?? TextAlignVertical.center,
          expands: expands,
          maxLines: expands
              ? null
              : obscureText == true ||
                      masking != null ||
                      keyboardType == TextInputType.number
                  ? 1
                  : maxLines,
          minLines: expands ? null : 1,
          enabled: readOnly == true ? false : true,
          onTap: onTap,
          readOnly: readOnly,
          focusNode: focusnode,
          autofocus: autoFocus,
          onChanged: (val) {
            onChanged(val);
          },
          onSubmitted: (val) {
            onSubmited(val);
          },
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete,
          inputFormatters: keyboardType == TextInputType.number
              ? formatter ?? [FilteringTextInputFormatter.digitsOnly]
              : formatter,
          style: TextStyle(
              fontFamily: fontsFamily, fontSize: fontSize, color: fontColor),
          obscureText: obscureText,
          keyboardType: keyboardType,
          // controller: _controller, //using local controller
          controller: controller,
          textAlign: textAlign,
          decoration: new InputDecoration(
              contentPadding: contentPadding,
              border: new OutlineInputBorder(
                borderSide: new BorderSide(
                    color: controller.stateInput == StateInput.Error
                        ? inputBorderError
                        : borderInputGray,
                    width: borderWidth),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(position == InputPosition.Bottom ||
                            position == InputPosition.Center
                        ? corner
                        : 0.0),
                    bottomRight: Radius.circular(
                        position == InputPosition.Bottom ||
                                position == InputPosition.Center
                            ? corner
                            : 0.0),
                    topLeft: Radius.circular(position == InputPosition.Top ||
                            position == InputPosition.Center
                        ? corner
                        : 0.0),
                    topRight: Radius.circular(
                        position == InputPosition.Top || position == InputPosition.Center ? corner : 0.0)),
              ),
              enabledBorder: new OutlineInputBorder(
                borderSide: new BorderSide(
                    color: controller.stateInput == StateInput.Error
                        ? inputBorderError
                        : borderInputGray,
                    width: borderWidth),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(position == InputPosition.Bottom ||
                            position == InputPosition.Center
                        ? corner
                        : 0.0),
                    bottomRight: Radius.circular(
                        position == InputPosition.Bottom ||
                                position == InputPosition.Center
                            ? corner
                            : 0.0),
                    topLeft: Radius.circular(position == InputPosition.Top ||
                            position == InputPosition.Center
                        ? corner
                        : 0.0),
                    topRight: Radius.circular(
                        position == InputPosition.Top || position == InputPosition.Center ? corner : 0.0)),
              ),
              focusedBorder: new OutlineInputBorder(
                borderSide: new BorderSide(
                    color: controller.stateInput == StateInput.Error
                        ? inputBorderError
                        : borderInputGray,
                    width: borderWidth),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(position == InputPosition.Bottom ||
                            position == InputPosition.Center
                        ? corner
                        : 0.0),
                    bottomRight: Radius.circular(
                        position == InputPosition.Bottom ||
                                position == InputPosition.Center
                            ? corner
                            : 0.0),
                    topLeft: Radius.circular(position == InputPosition.Top ||
                            position == InputPosition.Center
                        ? corner
                        : 0.0),
                    topRight: Radius.circular(
                        position == InputPosition.Top || position == InputPosition.Center ? corner : 0.0)),
              ),
              filled: true,
              hintStyle: new TextStyle(color: hintColor),
              hintText: hintText,
              fillColor: backgroundColor ?? Color(0xffFFFFFF),
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon),
        )
      ],
    );
  }

  static Container dropDownWithCorner<T>({
    double corner = 5,
    double padding = 10,
    Object value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T> onChangeds,
    String hint = "hint",
    Color borderColor = Colors.black38,
    Color backgroundColor,
    Widget icons,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: icons == null ? 10 : 0),
      decoration: new BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(corner)),
          border: new Border.all(color: borderColor)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChangeds,
          isExpanded: true,
          hint: Text(hint ?? ""),
          icon: icons ?? null,
        ),
      ),
    );
  }

  static Container inputTextWithUnderLine({
    TextEditingController controller,
    TextAlign textAlign = TextAlign.left,
    double height = 30,
    double width,
    String hintText = "",
    Color hintTextColor,
    Color textColor = Colors.black,
    TextStyle hintTextStyle,
    TextStyle textStyle,
    IconData suffix,
    Widget suffixWidget,
    VoidCallback onSuffixIconTap,
    Color suffixIconColor,
    Color underLineColor = Colors.black,
    Color enableUnderLineColor,
    Color focusedUnderLineColor,
    Color disableUnderlineColor,
    bool obscureText = false,
    Widget leadingWidget,
    IconData leadingIcon,
    VoidCallback onTapLeadingIcon,
    Color leadingIconColor,
    IconData trailingIcon,
    VoidCallback onTapTrailingIcon,
    Color trailingIconColor,
    bool readOnly = false,
    ValueChanged<String> onChange,
    EdgeInsets contentPadding,
    FocusNode focusNode,
    TextInputAction textInputAction = TextInputAction.done,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String> onSubmited,
    bool showCursor = true,
  }) {
    return Container(
      width: double.infinity,
      height: (height * 1.2).toDouble(),
      color: width ?? Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            leadingWidget != null
                ? leadingWidget
                : leadingIcon == null
                    ? Container()
                    : GestureDetector(
                        onTap: onTapLeadingIcon,
                        child: Icon(
                          leadingIcon,
                          color: leadingIconColor ?? Colors.black,
                          size: height,
                        ),
                      ),
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: leadingIcon == null ? 0 : 10,
                          right: trailingIcon == null ? 0 : 10),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TextField(
                          showCursor: showCursor,
                          textInputAction: textInputAction,
                          keyboardType: keyboardType,
                          focusNode: focusNode,
                          textAlign: textAlign,
                          controller: controller,
                          readOnly: readOnly,
                          onChanged: onChange,
                          onSubmitted: onSubmited,
                          style: textStyle ??
                              TextStyle(
                                color: textColor,
                              ),
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "$hintText",
                            hintStyle: hintTextStyle ??
                                TextStyle(
                                  color: hintTextColor ??
                                      Colors.black.withOpacity(0.3),
                                ),
                            contentPadding: contentPadding != null
                                ? contentPadding
                                : EdgeInsets.only(
                                    bottom: 3,
                                    right: suffix != null ? height * 3 / 4 : 0),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: underLineColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      enableUnderLineColor ?? underLineColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      focusedUnderLineColor ?? underLineColor),
                            ),
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      disableUnderlineColor ?? underLineColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                    suffix == null && suffixWidget == null
                        ? Container()
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: onSuffixIconTap,
                              child: Container(
                                height: height * 3 / 4,
                                width: height * 3 / 4,
                                color: Colors.transparent,
                                margin: EdgeInsets.only(right: 10, bottom: 5),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: suffixWidget ??
                                      Icon(
                                        suffix,
                                        size: height * 3 / 4,
                                        color: suffixIconColor ?? Colors.black,
                                      ),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
            trailingIcon == null
                ? Container()
                : GestureDetector(
                    onTap: onTapTrailingIcon,
                    child: Icon(
                      trailingIcon,
                      color: trailingIconColor ?? Colors.black,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

enum InputPosition {
  ///
  /// Define this enum for declare the top position of input verticaly
  ///
  ///
  Top,

  ///
  /// Define this enum for declare the center position of input verticaly
  ///
  ///
  Center,

  ///
  /// Define this enum for declare the top bottom of input verticaly
  ///
  ///
  Bottom
}

enum StateInput {
  ///
  /// Define this enum for declare the top position of input verticaly
  ///
  ///
  Enable,

  ///
  /// Define this enum for declare the top position of input verticaly
  ///
  ///
  Disable,

  ///
  /// Define this enum for declare the top position of input verticaly
  ///
  ///
  Focus,

  ///
  /// Define this enum for declare the top position of input verticaly
  ///
  ///
  Error
}

enum StateInputMessageStatus {
  Danger,
  Warning,
  Info,
}

class StateInputMessage {
  Color dangerColor;
  Color warningColor;
  Color infoColor;
  StateInputMessageStatus status;
  String message;

  StateInputMessage({
    this.dangerColor = Colors.red,
    this.warningColor = Colors.orange,
    this.infoColor = Colors.green,
    this.status,
    this.message,
  });

  void get setDanger {
    this.status = StateInputMessageStatus.Danger;
  }

  void get setWarning {
    this.status = StateInputMessageStatus.Warning;
  }

  void get setInfo {
    this.status = StateInputMessageStatus.Info;
  }

  Color get color {
    switch (status) {
      case StateInputMessageStatus.Danger:
        return dangerColor;
        break;
      case StateInputMessageStatus.Warning:
        return warningColor;
        break;
      case StateInputMessageStatus.Info:
        return infoColor;
        break;
      default:
        return infoColor;
        break;
    }
  }
}

AlignmentGeometry convertAlignment(TextAlign textAlign) {
  switch (textAlign) {
    case TextAlign.left:
      return Alignment.topLeft;
      break;
    case TextAlign.right:
      return Alignment.topRight;
      break;
    case TextAlign.start:
      return Alignment.centerLeft;
      break;
    case TextAlign.end:
      return Alignment.centerRight;
      break;
    case TextAlign.center:
      return Alignment.center;
      break;
    case TextAlign.justify:
      return Alignment.topLeft;
      break;
    default:
      return Alignment.topLeft;
      break;
  }
}

class InputComponentTextEditingController extends TextEditingController {
  InputComponentTextEditingController({String content, this.useCustomeText})
      : super(text: content) {
    this._content = content;
  }
  String _content;
  // String masking = "###,###.###";
  TextInputType inputType = TextInputType.text;
  bool useCustomeText;
  StateInput stateInput = StateInput.Enable;
  StateInputMessage stateInputMessage = new StateInputMessage();
  bool obscureText = false;

  set content(String value) {
    this.content = this._content;
  }

  bool customeText() {
    if (this.useCustomeText == null) {
      if (this.inputType == TextInputType.number) {
        return true;
      } else {
        return false;
      }
    } else {
      return this.useCustomeText;
    }
  }

  get content {
    if (customeText()) {
      final intRegex = RegExp(r'(\d)', multiLine: true);

      return intRegex
          .allMatches(text.toString())
          .map((m) => m.group(0))
          .toList()
          .join('');
    } else {
      return this.text;
    }
  }

  int get contentAsInt {
    if (customeText()) {
      final intRegex = RegExp(r'(\d)', multiLine: true);

      try {
        return int.parse(intRegex
            .allMatches(text.toString())
            .map((m) => m.group(0))
            .toList()
            .join(''));
      } catch (e) {
        return 0;
      }
    } else {
      return 0;
    }
  }

  set setStateInput(StateInput stateInput) {
    this.stateInput = stateInput;
    this.notifyListeners();
  }

  set setStateInputMessage(StateInputMessage message) {
    this.stateInputMessage = message;
    this.notifyListeners();
  }

  set setObscureText(bool obscureText) {
    this.obscureText = obscureText;
    this.notifyListeners();
  }

  void toogleObscureText() {
    this.obscureText = this.obscureText.toggle();
    this.notifyListeners();
  }

  // @override
  // Future<TextSpan> buildTextSpan({TextStyle style, bool withComposing}) async {
  //   if (customeText()) {
  //     text = text;
  //   }
  //   return super.buildTextSpan(style: style, withComposing: withComposing, context: null);
  // }

  @override
  set text(String newText) {
    String _updateText = updateText(newText);
    value = value.copyWith(
      text: customeText() ? _updateText : newText,
      selection: TextSelection.collapsed(
          offset: customeText() ? _updateText.length : -1),
      composing: TextRange.empty,
    );
  }

  // void updateText(String text) {
  //   if (text != null) {

  //   } else {
  //     this.text = '';
  //   }

  //   this._lastUpdatedText = this.text;
  // }

  String updateText(String newText) {
    if (customeText()) {
      final _intRegex = RegExp(r'(\d)', multiLine: true);

      // //get int only to content if in digit only
      String _int = _intRegex
          .allMatches(newText.toString())
          .map((m) => m.group(0))
          .toList()
          .join('');

      //format the new text
      try {
        newText = NumberFormat("#,###", "en-US").format(int.parse(_int ?? "0"));
      } catch (e) {
        newText = "";
      }

      return newText;
    } else {
      return text;
    }
  }

  // String get getMasking => masking;
  StateInput get getStateInput => stateInput;
}

class UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));

    final intRegex = RegExp(r'(\d)', multiLine: true);
    // final doubleRegex = RegExp(r'\s+(\d+\.\d+)\s+', multiLine: true);
    // final timeRegex = RegExp(r'\s+(\d{1,2}:\d{2})\s+', multiLine: true);

    String _int = // newText.toString();
        intRegex
            .allMatches(newText.toString())
            .map((m) => m.group(0))
            .toList()
            .join('');
    // print(doubleRegex.allMatches(text).map((m) => m.group(0)));
    // print(timeRegex.allMatches(text).map((m) => m.group(0)));
    String _newText =
        NumberFormat("#,###", "en-US").format(int.parse(_int ?? "0"));

    ///test
    return TextEditingValue(
      text: _newText,
      selection: TextSelection.collapsed(offset: _newText.length),
    );
  }
}

extension BoolExtention on bool {
  bool toggle() {
    if (this == true) {
      return false;
    } else {
      return true;
    }
  }
}
