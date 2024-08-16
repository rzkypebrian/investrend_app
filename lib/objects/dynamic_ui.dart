// ignore_for_file: unnecessary_null_comparison

import 'package:Investrend/component/image_picker_component.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Investrend/component/video_picker_component.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// import 'package:search_choices/search_choices.dart';

class DynamicUi {
  String? userid; //": "",
  int? oaid; //": "201",
  String? oatoken; //": "be4067d952bc5447998dcdf3d446fd0c",
  String? oastatus; //": "ONREGISTER",
  String? oamessage; //": "",
  int? lastpage;
  int? backfrompage;
  int? minpage; //": "1",
  List<DynamicUIPage>? pages;

  DynamicUi({
    this.userid,
    this.oaid,
    this.oatoken,
    this.oastatus,
    this.oamessage,
    this.lastpage,
    this.backfrompage,
    this.minpage,
    this.pages,
  });

  factory DynamicUi.fromJson(Map<String, dynamic> jsonData,
      {ValueChanged<DynamicUIField>? onChanged}) {
    return DynamicUi(
      userid: jsonData["userid"] == null ? null : jsonData["userid"] as String?,
      oaid: StringUtils.isNullOrEmpty((jsonData["oaid"] as String?))
          ? null
          : int.parse((jsonData["oaid"] as String)),
      oatoken:
          jsonData["oatoken"] == null ? null : jsonData["oatoken"] as String?,
      oastatus:
          jsonData["oastatus"] == null ? null : jsonData["oastatus"] as String?,
      oamessage: jsonData["oamessage"] == null
          ? null
          : jsonData["oamessage"] as String?,
      lastpage: StringUtils.isNullOrEmpty((jsonData["lastpage"] as String?))
          ? null
          : int.parse((jsonData["lastpage"] as String)),
      backfrompage:
          StringUtils.isNullOrEmpty((jsonData["backfrompage"] as String?))
              ? null
              : int.parse((jsonData["backfrompage"] as String)),
      minpage: StringUtils.isNullOrEmpty((jsonData["minpage"] as String?))
          ? null
          : int.parse((jsonData["minpage"] as String)),
      pages: (jsonData["pages"] as List)
          .where((e) => e != "null")
          .toList()
          .map((e) => DynamicUIPage.fromJson(e, onChanged: onChanged))
          .toList(),
    );
  }
}

class DynamicUIPage {
  int? page; //": "1",
  String? title; //": "BUAT AKUN RDN (1/7)",
  bool? withNext;
  bool? withClose;
  List<DynamicUIField>? form;

  DynamicUIPage({
    this.page,
    this.title,
    this.withNext,
    this.withClose,
    this.form,
  }); //":

  factory DynamicUIPage.fromJson(Map<String, dynamic> jsonData,
      {ValueChanged<DynamicUIField>? onChanged}) {
    return DynamicUIPage(
      page: StringUtils.isNullOrEmpty(jsonData["page"] as String?)
          ? null
          : int.parse(jsonData["page"] as String),
      withNext: Utils.safeBool(jsonData["withnext"]),
      withClose: Utils.safeBool(jsonData["withclose"]),
      title: jsonData["title"] as String?,
      form: (jsonData["form"] as List)
          .map((e) => DynamicUIField.fromJson(e, onChanged: onChanged)!)
          .toList(),
    );
  }
}

class DynamicUIType {
  static const String text = "TEXT";
  static const String textField = "TEXTFIELD";
  static const String checkBox = "CHECKBOX";
  static const String datePicker = "DATEPICKER";
  static const String sizedBox = "SIZEBOX";
  static const String dropDown = "DROPDOWN";
  static const String upload = "UPLOAD";
  static const String textArea = "TEXTAREA";

  static const List<String> basicInput = [
    textArea,
    textField,
    dropDown,
  ];

  static const List<String> fileInput = [
    upload,
  ];

  static const List<String> dateInput = [
    datePicker,
  ];
}

class DynamicUIfileType {
  static const String image = "image";
  static const String video = "video";
}

class DynamicUIKeyboardType {
  static const String text = "text";
  static const String number = "number";
}

class DynamicUIField {
  String? ui;
  String? id;
  bool? mandatory;
  dynamic content;
  dynamic controller;
  ValueChanged<DynamicUIField>? onChanged;
  String? showif;
  bool isError;
  bool? checked;
  FocusNode? focusNode;
  FocusNode? nextFocusNode;
  GlobalKey? globalKey;
  String? status;
  String? mandatoryIf;

  DynamicUIField({
    this.ui,
    this.id,
    this.mandatory,
    this.content,
    this.onChanged,
    this.showif,
    this.isError = false,
    this.checked,
    this.focusNode,
    this.nextFocusNode,
    this.mandatoryIf,
  }) {
    this.focusNode = new FocusNode();
    this.globalKey = new GlobalKey();
  }

  dynamic get getContent {
    return this.content;
  }

  static DynamicUIField? fromJson(
    Map<String, dynamic>? parsedJson, {
    ValueChanged<DynamicUIField>? onChanged,
  }) {
    if (parsedJson == null) {
      return null;
    }
    String? ui = StringUtils.noNullString(parsedJson['ui']);

    switch (ui) {
      case DynamicUIType.text:
        return TextUI.fromJson(parsedJson)?..onChanged = onChanged;
      case DynamicUIType.textField:
        return TextFieldUI.fromJson(parsedJson)?..onChanged = onChanged;
      case DynamicUIType.textArea:
        return TextAreaUI.fromJson(parsedJson)?..onChanged = onChanged;
      case DynamicUIType.checkBox:
        return CheckBoxUI.fromJson(parsedJson)?..onChanged = onChanged;
      case DynamicUIType.datePicker:
        return DatePickerUI.fromJson(parsedJson)?..onChanged = onChanged;
      case DynamicUIType.dropDown:
        return DropDownUI.fromJson(parsedJson)?..onChanged = onChanged;
      case DynamicUIType.sizedBox:
        return SizeBoxUI.fromJson(parsedJson)?..onChanged = onChanged;
      case DynamicUIType.upload:
        return UploadUI.fromJson(parsedJson)?..onChanged = onChanged;
      default:
        return DynamicUIField(
          id: parsedJson["id"] as String?,
          ui: parsedJson["ui"] as String?,
        );
    }
  }

  bool validate(DynamicUIPage page) {
    if (isMandatory(page) == true && (getContent == "" || getContent == null)) {
      return false;
    } else {
      return true;
    }
  }

  List<DynamicCondition> get mandatoryCondition {
    List<DynamicCondition> condition = [];
    if (mandatoryIf != null && mandatoryIf != "") {
      mandatoryIf!.split("|").forEach((e) {
        condition.add(DynamicCondition(
          dynamicId: e.split("=").first,
          value: e.split("=").last,
        ));
      });
    }
    return condition;
  }

  bool? isMandatory(DynamicUIPage? page) {
    bool? _mandatory = mandatory;
    String? val = "";
    if (page != null) {
      if (mandatoryCondition != null && mandatoryCondition.isNotEmpty) {
        mandatoryCondition.forEach((c) {
          val = page.form!.where((e) => e.id == c.dynamicId).first.content;
          _mandatory = c.value == val ? false : _mandatory;
        });
      }
    }
    return _mandatory;
  }

  Widget printUi(
    BuildContext context, {
    DynamicUIPage? page,
  }) {
    return !isShowUi(page)
        ? SizedBox()
        : Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            padding: EdgeInsets.all(5),
            width: double.infinity,
            color: Colors.red,
            child: Text(
              "Un Implemented UI",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
  }

  List<DynamicCondition> get showIfCondition {
    List<DynamicCondition> condition = [];
    if (showif != null && showif != "") {
      showif!.split("|").forEach((e) {
        condition.add(DynamicCondition(
          dynamicId: e.split("=").first,
          value: e.split("=").last,
        ));
      });
    }
    return condition;
  }

  bool isShowUi(DynamicUIPage? page) {
    bool showUi = false;
    String? val = "";
    if (page != null) {
      if (showIfCondition != null && showIfCondition.isNotEmpty) {
        showIfCondition.forEach((c) {
          val = page.form!.where((e) => e.id == c.dynamicId).first.content;
          showUi = c.value == val ? true : showUi;
        });
      } else {
        showUi = true;
      }
    }
    return showUi;
  }

  DynamicUIField onRecreate(
    VoidCallback onRecreate, {
    DynamicUIField? previousField,
  }) {
    // this.focusNode = new FocusNode();
    if (previousField != null) previousField.nextFocusNode = this.focusNode;
    return this;
  }
}

class CheckBoxUI extends DynamicUIField {
  //"ui": "CHECKBOX",
  //"id": "tnc",
  bool? checked; //": false,
  String? label; //": "Dengan ini saya menyatakan menteujui",
  String? error; //": "Anda harus menyetujui apapun yang ada disini"

  CheckBoxUI({
    String? ui,
    String? id,
    dynamic content,
    bool? mandatory,
    String? showif,
    this.checked,
    this.label,
    this.error,
  }) : super(
          id: id,
          ui: ui,
          mandatory: mandatory,
          content: content,
          showif: showif,
        );

  static CheckBoxUI? fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return CheckBoxUI(
      ui: StringUtils.noNullString(parsedJson["ui"]),
      id: StringUtils.noNullString(parsedJson["id"]),
      content: Utils.safeBool(parsedJson["checked"]),
      checked: Utils.safeBool(parsedJson["checked"]),
      mandatory: Utils.safeBool(parsedJson["mandatory"]),
      label: StringUtils.noNullString(parsedJson["label"]),
      error: StringUtils.noNullString(parsedJson["error"]),
      showif: StringUtils.noNullString(parsedJson["showif"]),
    );
  }

  @override
  bool validate(DynamicUIPage page) {
    if (isMandatory(page) == true &&
        (getContent == "" || getContent == null || checked == false)) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget printUi(BuildContext context, {DynamicUIPage? page, controller}) {
    return !isShowUi(page)
        ? SizedBox()
        : Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          key: globalKey,
                          padding: EdgeInsets.only(bottom: 10),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: isError == true
                                    ? Colors.red.shade700
                                    : Colors.transparent,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: checked,
                                onChanged: (val) {
                                  content = val;
                                  checked = val;
                                  onChanged!(this);
                                },
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: label,
                                        style: InvestrendTheme.of(context)
                                            .regular_w400,
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: isMandatory(page) == true
                                                ? '*'
                                                : "",
                                            style: InvestrendTheme.of(context)
                                                .inputErrorStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                    isError == true
                                        ? Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "$error",
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class DropDownUI extends DynamicUIField {
  //": true,
  String? label; //": "Ya/Tidak",
  String? hint; //": "Pilih Jawaban",
  String? error;
  List<String>? optionsId;
  List<String>? optionsLabel;
  bool? searchable;
  List<Option> options;

  DropDownUI({
    String? id,
    String? ui,
    dynamic content,
    bool? mandatory,
    String? showif,
    String? mandatoryIf,
    this.label,
    this.hint,
    this.error,
    this.optionsId,
    this.optionsLabel,
    this.searchable,
    this.options = const [],
  }) : super(
          id: id,
          ui: ui,
          content: content,
          mandatory: mandatory,
          showif: showif,
          mandatoryIf: mandatoryIf,
        ) {
    options = getOptions;
  }

  List<Option> get getOptions {
    List<Option> data = [];
    for (int i = 0; i < optionsId!.length; i++) {
      data.add(new Option(
        key: optionsId![i],
        value: optionsLabel![i],
      ));
    }
    return data;
  }

  Option? get selected {
    if (content == null || content == "") {
      print("SELECTED MODE 1 = ${options.first.value} || $content");
      return null;
    } else {
      List<Option>? found = options.where((e) => e.key == content).toList();
      print("FOUND LENGTH = ${found.length}");
      if (found.length > 0) {
        print("SELECTED MODE 2 = ${found.first.value} || $content ");

        return found.first;
      }
      print("SELECTED MODE 3 = ${options.first.value} || $content");
      return options.first;
    }
  }

  static DropDownUI? fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    // print(
    //     "dropdown ID = ${StringUtils.noNullString(parsedJson["id"])} \n showif = ${StringUtils.noNullString(parsedJson["showif"])}");
    var data = DropDownUI(
      id: StringUtils.noNullString(parsedJson["id"]),
      ui: StringUtils.noNullString(parsedJson["ui"]),
      content: StringUtils.noNullString(parsedJson["content"]),
      mandatory: Utils.safeBool(parsedJson["mandatory"]),
      label: StringUtils.noNullString(parsedJson["label"]),
      hint: StringUtils.noNullString(parsedJson["hint"]),
      error: StringUtils.noNullString(parsedJson["error"]),
      optionsId:
          (parsedJson["options_id"] as List).map((e) => e as String).toList(),
      optionsLabel: (parsedJson["options_label"] as List)
          .map((e) => e as String)
          .toList(),
      showif: StringUtils.noNullString(parsedJson["showif"]),
      mandatoryIf: StringUtils.noNullString(parsedJson["mandatoryif"]),
      searchable: Utils.safeBool(parsedJson["searchable"]),
    );
    if (!data.optionsId!.contains(data.content as String?)) {
      data.content = "";
    }
    return data;
  }

  @override
  Widget printUi(
    BuildContext context, {
    DynamicUIPage? page,
  }) {
    // print(
    //     "showif DROPDOWN $id ==================== ${isShowUi(page)}\n searchable = $searchable");
    return !isShowUi(page)
        ? SizedBox()
        : Container(
            // margin: EdgeInsets.only(bottom: 5),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: label,
                    style: InvestrendTheme.of(context).regular_w400,
                    children: <TextSpan>[
                      TextSpan(
                        text: isMandatory(page) == true ? '*' : "",
                        style: InvestrendTheme.of(context).inputErrorStyle,
                      ),
                    ],
                  ),
                ),
                searchable == true
                    ? Stack(
                        children: [
                          /*
                          SearchChoices<Option>.single(
                            key: globalKey,
                            value: selected,
                            isExpanded: true,
                            autofocus: false,
                            padding: 0.0,
                            icon: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Icon(Icons.arrow_drop_down_sharp),
                            ),
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            items: List.generate(options.length, (index) {
                              return DropdownMenuItem<Option>(
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    options[index].value,
                                    style: InvestrendTheme.of(context)
                                        .regular_w400_greyDarker,
                                  ),
                                ),
                                value: options[index],
                              );
                            }),
                            searchFn: (String keyword, items) {
                              List<int> ref = [];
                              for (int i = 0; i < options.length; i++) {
                                print("keyword = ${options[i].value}");
                                if (options[i]
                                    .value
                                    .toString()
                                    .toLowerCase()
                                    .contains(keyword)) {
                                  ref.add(i);
                                }
                              }
                              return ref;
                            },
                            displayClearIcon: false,
                            hint: Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Text(
                                hint,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              print(
                                  "CEK PRINT VALUE = ${val.price} || ${val.key}");
                              content = (val as Option).key;
                              onChanged(this);
                            },
                            underline: Container(
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.only(bottom: 10),
                              width: double.infinity,
                              height: 10,
                              color: Colors.transparent,
                              child: Container(
                                height: 1,
                                width: double.infinity,
                                color: isError == true
                                    ? Colors.red.shade700
                                    : Color(0xFFBDBDBD),
                              ),
                            ),
                          ),
                         */
                          isError == true
                              ? Container(
                                  margin: EdgeInsets.only(bottom: 15, top: 34),
                                  child: Text(
                                    "$error",
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      )
                    : Stack(
                        children: [
                          Container(
                            height: 40,
                            margin: EdgeInsets.only(bottom: 10),
                            child: DropdownButton<String>(
                              key: globalKey,
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              value:
                                  optionsId!.contains(content) ? content : null,
                              isExpanded: true,
                              selectedItemBuilder: (BuildContext context) {
                                return List.generate(optionsId!.length,
                                    (index) {
                                  return Text(
                                    optionsLabel![index],
                                    style: InvestrendTheme.of(context)
                                        .regular_w400_greyDarker,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                });
                              },
                              items: List.generate(
                                optionsId!.length,
                                (index) {
                                  return DropdownMenuItem<String>(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 10, top: 10),
                                      child: Text(
                                        optionsLabel![index],
                                        textAlign: TextAlign.justify,
                                        style: InvestrendTheme.of(context)
                                            .regular_w400_greyDarker,
                                      ),
                                    ),
                                    value: optionsId![index],
                                  );
                                },
                              ),
                              icon: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Icon(Icons.arrow_drop_down_sharp),
                              ),
                              hint: Text(
                                hint!,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onChanged: (val) {
                                content = val;
                                onChanged!(this);
                              },
                              underline: Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(bottom: 0),
                                width: double.infinity,
                                child: Container(
                                  height: 1,
                                  width: double.infinity,
                                  color: isError == true
                                      ? Colors.red
                                      : Color(0xFFBDBDBD),
                                ),
                              ),
                            ),
                          ),
                          isError == true
                              ? Container(
                                  margin: EdgeInsets.only(top: 35, bottom: 15),
                                  child: Text(
                                    "$error",
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
              ],
            ),
          );
  }
}

class DatePickerUI extends DynamicUIField {
  String? label; //": "Tanggal Lahir",
  String? hint; //": "Masukan tanggal lahir sesuai KTP",
  String? error; //": "Harap isi tanggal lahir sesuai KTP"

  DatePickerUI({
    String? ui,
    String? id,
    dynamic content,
    bool? mandatory,
    String? showif,
    this.label,
    this.hint,
    this.error,
  }) : super(
          id: id,
          ui: ui,
          content: content,
          mandatory: mandatory,
          showif: showif,
        );

  static DatePickerUI? fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    return DatePickerUI(
      ui: StringUtils.noNullString(parsedJson["ui"]),
      id: StringUtils.noNullString(parsedJson["id"]),
      content: parsedJson["content"] == null || parsedJson["content"] == ""
          ? null
          : DateTime.parse(parsedJson["content"]),
      mandatory: Utils.safeBool(parsedJson["mandatory"]),
      label: StringUtils.noNullString(parsedJson["label"]),
      hint: StringUtils.noNullString(parsedJson["hint"]),
      error: StringUtils.noNullString(parsedJson["error"]),
      showif: StringUtils.noNullString(parsedJson["showif"]),
    );
  }

  @override
  Widget printUi(
    BuildContext context, {
    DynamicUIPage? page,
  }) {
    controller = controller ?? TextEditingController();
    if (content != null && content != "") {
      controller.text = controller.text == ""
          ? DateFormat("yyyy-MM-dd").format(content)
          : controller.text;
    }

    // content = DateTime.parse(content);
    return !isShowUi(page)
        ? SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: label,
                        style: InvestrendTheme.of(context).regular_w400,
                        children: <TextSpan>[
                          TextSpan(
                            text: isMandatory(page) == true ? '*' : "",
                            style: InvestrendTheme.of(context).inputErrorStyle,
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      key: globalKey,
                      onTap: () {
                        getDate(context).then(
                          (value) {
                            if (value == null) return;
                            content = value;
                            (controller as TextEditingController).text =
                                DateFormat("yyyy-MM-dd").format(value);
                          },
                        );
                      },
                      readOnly: true,
                      controller: controller,
                      style:
                          InvestrendTheme.of(context).regular_w400_greyDarker,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 2),
                        isDense: true,
                        hintText: hint,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        content = val;
                        onChanged!(this);
                      },
                    ),
                    isError == true
                        ? Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "$error",
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          );
  }

  Future<DateTime?> getDate(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: content != null && content != "" ? content : DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 200, 1),
      lastDate: DateTime.now(),
    );
  }
}

class TextFieldUI extends DynamicUIField {
  //"ui": "TEXTFIELD",
  //"id": "nik",
  String? label; //": "NIK",
  String? hint; //": "Masukan nomor NIK KTP",
  String? error; //": "Harap isi NIK sesuai KTP anda",
  String? keyboard; //": "number",
  String? action; //": "next"
  String? length; //": "10-20 / 3"

  TextFieldUI({
    String? ui,
    String? id,
    dynamic content,
    bool? mandatory,
    String? showif,
    String? mandatoryIf,
    this.label,
    this.hint,
    this.error,
    this.keyboard,
    this.action,
    this.length,
  }) : super(
          id: id,
          ui: ui,
          mandatory: mandatory,
          content: content,
          showif: showif,
          mandatoryIf: mandatoryIf,
        );

  static TextFieldUI? fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return TextFieldUI(
      ui: StringUtils.noNullString(parsedJson["ui"]),
      id: StringUtils.noNullString(parsedJson["id"]),
      content: StringUtils.noNullString(parsedJson["content"]),
      mandatory: Utils.safeBool(parsedJson["mandatory"]),
      label: StringUtils.noNullString(parsedJson["label"]),
      hint: StringUtils.noNullString(parsedJson["hint"]),
      error: StringUtils.noNullString(parsedJson["error"]),
      keyboard: StringUtils.noNullString(parsedJson["keyboard"]),
      action: StringUtils.noNullString(parsedJson["action"]),
      showif: StringUtils.noNullString(parsedJson["showif"]),
      length: StringUtils.noNullString(parsedJson["length"]),
      mandatoryIf: StringUtils.noNullString(parsedJson["mandatoryif"]),
    );
  }

  int get maxLength {
    if (length != null && length != "") {
      return Utils.safeInt(length!.split("-")[1]);
    } else {
      return 1000;
    }
  }

  int get minLength {
    if (length != null && length != "") {
      return Utils.safeInt(length!.split("-")[0]);
    } else {
      return 0;
    }
  }

  @override
  bool validate(DynamicUIPage page) {
    if (super.validate(page) == true) {
      int _contentLength =
          (controller as TextEditingController).text.trim().length;
      if (minLength == 0) return true;

      if (_contentLength > 0 && _contentLength < minLength) {
        isError = true;
        error = "Input terlalu pendek, minimal $minLength karakter";
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  @override
  Widget printUi(
    BuildContext context, {
    DynamicUIPage? page,
  }) {
    // print("length = $length");
    // String maxLengthChar = "";
    // String minlengthChar = "";
    // final split = length.split('-');
    // final Map<int, String> values = {
    //   for (int i = 0; i < split.length; i++) i: split[i]
    // };
    // if (length != null || length != "") {
    //   String minLength = values[0];
    //   String maxLength = values[1];
    //   maxLengthChar = maxLength;
    //   minlengthChar = minLength;
    // }

    // print(
    //     "showif TextFormField $id ==================== ${isShowUi(page)} ========== $maxLength dan $minLength");
    controller = controller ?? TextEditingController();
    controller = TextEditingController.fromValue(
      TextEditingValue(
        text: content ?? "",
        selection: TextSelection.collapsed(offset: content?.length ?? 0),
      ),
    );
    return !isShowUi(page)
        ? SizedBox()
        : Container(
            margin: EdgeInsets.only(bottom: 15),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: RichText(
                    text: TextSpan(
                      text: label,
                      style: InvestrendTheme.of(context).regular_w400,
                      children: <TextSpan>[
                        TextSpan(
                          text: isMandatory(page) == true ? '*' : "",
                          style: InvestrendTheme.of(context).inputErrorStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: TextField(
                    maxLength:
                        maxLength == null ? 1000 : Utils.safeInt(maxLength),
                    focusNode: focusNode,
                    controller: controller,
                    style: InvestrendTheme.of(context).regular_w400_greyDarker,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(top: 2),
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.normal,
                        overflow: TextOverflow.ellipsis,
                      ),
                      counterText: "",
                      errorText: isError == true ? "$error" : null,
                      errorStyle: TextStyle(color: Colors.red.shade700),
                      errorMaxLines: 2,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                    keyboardType: getInputType(),
                    onChanged: (val) {
                      content = val.trim();
                    },
                    onSubmitted: (val) {
                      print("MASUK SINI SUBMITTED TEXTFIELD");
                      content = val.trim();
                      onChanged!(this);
                    },
                  ),
                ),
              ],
            ),
          );
  }

  TextInputType getInputType() {
    switch (keyboard) {
      case DynamicUIKeyboardType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}

class TextAreaUI extends DynamicUIField {
  String? style;
  double? size;

  TextAreaUI({
    String? id,
    String? ui,
    dynamic content,
    String? showif,
    this.style,
    this.size,
  }) : super(
          id: id,
          ui: ui,
          content: content,
          showif: showif,
        );

  static TextAreaUI? fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return TextAreaUI(
      ui: parsedJson["ui"] as String?,
      id: parsedJson["id"] as String?,
      content: parsedJson["content"] as String?,
      style: StringUtils.isNullOrEmpty(parsedJson["style"] as String?)
          ? "normal"
          : (parsedJson["style"] as String?),
      size: parsedJson['size'] == ""
          ? null
          : Utils.safeDouble(parsedJson['size']),
      showif: parsedJson["showif"] as String?,
    );
  }

  @override
  Widget printUi(
    BuildContext context, {
    ScrollController? scrollController,
    DynamicUIPage? page,
  }) {
    return !isShowUi(page)
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.vertical,
              child: Container(
                child: Text(
                  this.content,
                  textAlign: TextAlign.justify,
                  style: InvestrendTheme.of(context).regular_w400!.copyWith(
                        fontWeight: style == "bold"
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: size,
                      ),
                ),
              ),
            ),
          );
  }
}

class TextUI extends DynamicUIField {
  String? style;
  double? size;

  TextUI({
    String? id,
    String? ui,
    dynamic content,
    String? showif,
    this.style,
    this.size,
  }) : super(
          id: id,
          ui: ui,
          content: content,
          showif: showif,
        );

  static TextUI? fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return TextUI(
      ui: parsedJson["ui"] as String?,
      id: parsedJson["id"] as String?,
      content: parsedJson["content"] as String?,
      style: StringUtils.isNullOrEmpty(parsedJson["style"] as String?)
          ? "normal"
          : (parsedJson["style"] as String?),
      size: parsedJson['size'] == ""
          ? null
          : Utils.safeDouble(parsedJson['size']),
      showif: parsedJson["showif"] as String?,
    );
  }

  @override
  Widget printUi(
    BuildContext context, {
    DynamicUIPage? page,
  }) {
    return !isShowUi(page)
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              this.content,
              style: InvestrendTheme.of(context).regular_w400!.copyWith(
                    fontWeight:
                        style == "bold" ? FontWeight.bold : FontWeight.normal,
                    fontSize: size,
                  ),
            ),
          );
  }
}

class SizeBoxUI extends DynamicUIField {
  double? width;
  double? height;

  SizeBoxUI({
    String? ui,
    String? id,
    String? showif,
    this.width,
    this.height,
  }) : super(
          id: id,
          ui: ui,
          showif: showif,
        );

  static SizeBoxUI? fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    return SizeBoxUI(
      ui: StringUtils.noNullString(parsedJson['ui']),
      width: Utils.safeDouble(parsedJson['width']),
      height: Utils.safeDouble(parsedJson['height']),
      showif: StringUtils.noNullString(parsedJson['showif']),
    );
  }

  @override
  Widget printUi(
    BuildContext context, {
    DynamicUIPage? page,
  }) {
    return !isShowUi(page)
        ? SizedBox()
        : Container(
            height: height,
            width: width,
          );
  }
}

class UploadUI extends DynamicUIField {
  String? label; //": "Upload KTP",
  String? hint; //": "Upload KTP",
  String? error; //": "Harap Upload KTP",
  String? filetype; //": "image",
  String? status;
  String? camera;
  String? frame;
  String? naskah;

  UploadUI({
    String? ui,
    String? id,
    bool? mandatory,
    dynamic content,
    String? showif,
    String? mandatoryIf,
    this.label,
    this.hint,
    this.error,
    this.filetype,
    this.status,
    this.camera,
    this.frame,
    this.naskah,
  }) : super(
          id: id,
          ui: ui,
          mandatory: mandatory,
          content: content,
          showif: showif,
          mandatoryIf: mandatoryIf,
        ); //": "NOT DONE"

  static UploadUI? fromJson(Map<String, dynamic> parsedJson) {
    return UploadUI(
      ui: StringUtils.noNullString(parsedJson["ui"]),
      id: StringUtils.noNullString(parsedJson["id"]),
      mandatory: Utils.safeBool(parsedJson["mandatory"]),
      content: parsedJson["content"] as String?,
      label: StringUtils.noNullString(parsedJson["label"]),
      hint: StringUtils.noNullString(parsedJson["hint"]),
      error: StringUtils.noNullString(parsedJson["error"]),
      filetype: StringUtils.noNullString(parsedJson["filetype"]),
      status: StringUtils.noNullString(parsedJson["status"]),
      showif: StringUtils.noNullString(parsedJson["showif"]),
      camera: StringUtils.noNullString(parsedJson["camera"]),
      frame: StringUtils.noNullString(parsedJson["frame"]),
      naskah: StringUtils.noNullString(parsedJson["naskah"]),
      mandatoryIf: StringUtils.noNullString(parsedJson["mandatoryif"]),
    );
  }

  @override
  String? get getContent {
    if (status == "DONE") {
      return "DONE";
    } else {
      return this.content;
    }
  }

  @override
  Widget printUi(
    BuildContext context, {
    DynamicUIPage? page,
  }) {
    return !isShowUi(page)
        ? SizedBox()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: label,
                  style: InvestrendTheme.of(context).regular_w400,
                  children: <TextSpan>[
                    TextSpan(
                      text: isMandatory(page) == true ? '*' : "",
                      style: InvestrendTheme.of(context).inputErrorStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                key: globalKey,
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    getInputTypeUi(context),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Status : $status",
                      style: InvestrendTheme.of(context).regular_w400,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          );
  }

  Widget getInputTypeUi(BuildContext context) {
    switch (filetype) {
      case DynamicUIfileType.image:
        return imagePicker(context);
      case DynamicUIfileType.video:
        return videoPicker(context);
      default:
        return super.printUi(context);
    }
  }

  Widget imagePicker(BuildContext context) {
    controller = controller ?? ImagePickerController();
    return ImagePickerComponent(
      frame: frame,
      camera: camera,
      context: context,
      controller: controller,
      status: status,
      width: double.infinity,
      onImageLoaded: (ctrl) {
        content = ctrl?.value.fileImage!.path;

        if (ctrl?.value.imagePickerState == ImagePickerState.loaded &&
            ctrl?.value.firstLoad == true) {
          ctrl?.value.firstLoad = false;
          onChanged!(this);
        }
      },
    );
  }

  Widget videoPicker(BuildContext context) {
    controller = controller ?? VideoPickerController();
    return VideoPickerComponent(
      frame: frame,
      camera: camera,
      context: context,
      controller: controller,
      status: status,
      naskah: naskah,
      width: double.infinity,
      onImageLoaded: (ctrl) {
        if (content == null && ctrl?.value.firstLoad == true) {
          content = ctrl?.value.fileVideo!.path;
        } else if (content == null && ctrl?.value.firstLoad == false) {
          content = ctrl?.value.fileVideo!.path;
        } else {
          return null;
        }

        if (ctrl?.value.videoPickerState == VideoPickerState.loaded &&
            ctrl?.value.firstLoad == true) {
          ctrl?.value.firstLoad = false;
          onChanged!(this);
        }
      },
    );
  }
}

class Option {
  String? key;
  String? value;

  Option({
    this.key,
    this.value,
  });
}

class DynamicCondition {
  String? dynamicId;
  String? value;

  DynamicCondition({
    this.dynamicId,
    this.value,
  });
}
