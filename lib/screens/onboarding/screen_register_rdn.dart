// ignore_for_file: must_call_super, unnecessary_null_comparison, unused_local_variable, unnecessary_cast

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Investrend/component/component_creator.dart';
import 'package:Investrend/component/image_picker_component.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/objects/dynamic_ui.dart';
import 'package:Investrend/utils/error_handling_util.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:Investrend/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';

// ignore: must_be_immutable
class ScreenRegisterRDN extends StatefulWidget {
  String? username;
  ScreenRegisterRDN({
    this.username,
  });

  @override
  _ScreenRegisterRDNState createState() => _ScreenRegisterRDNViewState();
}

abstract class _ScreenRegisterRDNState extends State<ScreenRegisterRDN>
    with WidgetsBindingObserver {
  ValueNotifier<bool> _bottomSheetNotifier = ValueNotifier(true);

  ScreenRegisterRDNViewModel viewModel = ScreenRegisterRDNViewModel();
  String endpointUrl = "https://register.buanacapital.com:8889/oa_form.php";
  String routeName = '/register_rdn';
  int showBackButton = 3;
  GlobalKey keyUp = new GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getToken(context).then((value) {
        getUi();
      });
    });
  }

  @override
  void didChangeDependencies() {
    bool keyboardShowed = MediaQuery.of(context).viewInsets.bottom > 0;
    _bottomSheetNotifier.value = keyboardShowed;
  }

  @override
  void dispose() {
    _bottomSheetNotifier.dispose();
  }

  void hideKeyboard({BuildContext? context}) {
    if (context == null) {
      context = this.context;
    }
    if (mounted && context != null) {
      FocusScope.of(context).requestFocus(new FocusNode());
    } else {
      print(
          'hideKeyboard aborted caused by -->  mounted : $mounted  context : ' +
              (context != null ? 'OK' : 'NULL'));
    }
  }

  Widget createBottomSheet(BuildContext context, double paddingBottom) {
    return ValueListenableBuilder(
      valueListenable: _bottomSheetNotifier,
      builder: (context, dynamic value, child) {
        if (value as bool) {
          if (Platform.isIOS) {
            return Container(
              // color: Colors.green,
              width: double.maxFinite,
              height: 40.0,
              //padding: EdgeInsets.only(top: 8.0, bottom: paddingBottom > 0 ? paddingBottom : 8.0, right: InvestrendTheme.cardPaddingGeneral),
              //padding: EdgeInsets.only(  right: InvestrendTheme.cardPaddingGeneral),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.only(
                          left: InvestrendTheme.cardPaddingGeneral,
                          right: InvestrendTheme.cardPaddingGeneral),
                      visualDensity: VisualDensity.comfortable),
                  child: Text(
                    'button_done'.tr(),
                    style: InvestrendTheme.of(context)
                        .small_w500_compact
                        ?.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () {
                    _bottomSheetNotifier.value = true;
                    hideKeyboard(context: context);
                  },
                ),
              ),
            );
          }
        }
        return Container(
          width: 0.0,
          height: 0.0,
        );
      },
    );
  }

  void saveOaid() {
    SharedPreferences.getInstance().then((value) {
      value.setString(widget.username! + '_oaid', viewModel.oaid!);
      value.setString(widget.username! + '_oatoken', viewModel.oatoken!);
    });
  }

  Future<void> getToken(BuildContext context) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    viewModel.oaid = sharedPreferences.getString(widget.username! + '_oaid');
    viewModel.oatoken =
        sharedPreferences.getString(widget.username! + '_oatoken');
    if (viewModel.oaid != null && viewModel.oatoken != null) {
      return;
    }

    debugPrint(routeName + " Register RDN Create Device Id");
    viewModel.startLoading();
    Token token = Token('', '');

    MyDevice myDevice = MyDevice();
    await myDevice.load();
    debugPrint(
        routeName + " Register RDN Create Device Id : " + myDevice.unique_id);
    String? uniqId = myDevice.unique_id;
    String devtoken = md5.convert(utf8.encode("INV2201$uniqId")).toString();

    debugPrint(routeName + ' richy_20220607 uniqId = [$uniqId]');
    debugPrint(routeName + ' richy_20220607 devtoken = [$devtoken]');

    // String userId = container.read(dataHolderChangeNotifier).user.username;
    // debugPrint("USER ID RDN INI = " + userId);

    bool hasToken = false;
    try {
      // bool tkn = await token.load();
      hasToken = !StringUtils.isEmtpy(token.access_token) &&
          !StringUtils.isEmtpy(token.refresh_token);
      debugPrint(
          routeName + ' LOGIN LOAD FIRST TIME TOKEN.LOAD HASTOKEN : $hasToken');
      debugPrint(routeName + 'ACCESS TOKEN : ${token.access_token}');
    } catch (e) {
      debugPrint(e.toString());
    }

    if (StringUtils.isEmtpy(uniqId) || StringUtils.isEmtpy(devtoken)) {
      print(routeName + ' Register RDN Error On Create Device ID');
      viewModel.stopLoading(isError: true, message: "error on device load \n");
      String dataText = 'Register RDN data sent :\n   ' +
          'Url Tren' +
          '$endpointUrl' +
          'Action : ' +
          'registration' +
          '\n   ' +
          'Device Id : ' +
          uniqId +
          '\n   ' +
          'Device Token : ' +
          devtoken +
          '\n   ' +
          'User Token : ' +
          token.access_token! +
          '\n   ' +
          'oaid : ' +
          sharedPreferences.getString("oaid")! +
          '\n   ' +
          'oatoken : ' +
          sharedPreferences.getString("oatoken")!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(dataText)));
    } else {
      debugPrint(" ");
      debugPrint(" ");
      debugPrint(
          routeName + ' ===============================================');
      debugPrint(routeName + ' Register RDN Device Id Created : $uniqId');
      debugPrint(routeName + ' Register RDN Request Token');
      debugPrint(
          routeName + ' ===============================================');
      debugPrint(" ");
      debugPrint(" ");
      debugPrint(
          routeName + ' ===============================================');
      debugPrint(routeName + ' action : registration');
      debugPrint(routeName + ' devid : ' + uniqId);
      debugPrint(routeName +
          ' devtoken : ' +
          md5.convert(utf8.encode("INV2201$uniqId")).toString());
      debugPrint(routeName + ' userId : ' + widget.username!);
      // print(routeName + ' userid : ' + user.username);
      debugPrint(routeName + ' usertoken : ' + token.access_token!);
      debugPrint(
          routeName + ' ===============================================');
      debugPrint(" ");
      debugPrint(" ");
      return http.post(
        Uri.parse(endpointUrl),
        body: {
          "action": "registration",
          "devid": uniqId,
          "devtoken": devtoken,
          "userid": widget.username,
          "usertoken": token.access_token,
        },
      ).then(
        (token) {
          viewModel.oaid = json.decode(token.body)["oaid"];
          viewModel.oatoken = json.decode(token.body)["oatoken"];
          saveOaid();
          return;
        },
      ).catchError(
        (e) {
          viewModel.stopLoading(
            isError: true,
            message: ErrorHandlingUtil.handleApiError(e),
          );
        },
      ).timeout(
        Duration(minutes: 1),
        onTimeout: () {
          viewModel.stopLoading(
            isError: true,
            message: "Request Timeout",
          );
        },
      );
    }

    return;
    /*
    debugPrint("Register RDN Create Device Id");
    viewModel.startLoading();
    return MyDevice().getUniqId().then(
      (uniqId) {
        if (uniqId == "") {
          debugPrint("Register RDN Error On Create Device ID");
          viewModel.stopLoading(isError: true, message: "error on device load");
        } else {
          debugPrint("Register RDN Device Id Created : $uniqId");
          debugPrint("Register RDN Request Token");
          return http.post(Uri.parse(endpointUrl), body: {
            "action": "registration",
            "devid": uniqId,
            "devtoken": md5.convert(utf8.encode("INV2201$uniqId")).toString(),
          }, headers: {
            "Accept": "application/json"
          }).then(
            (token) {
              viewModel.oaid = json.decode(token.body)["oaid"];
              viewModel.oatoken = json.decode(token.body)["oatoken"];
              return;
            },
          );
        }
      },
    ).catchError(
      (e) {
        viewModel.stopLoading(
          isError: true,
          message: ErrorHandlingUtil.handleApiError(e),
        );
      },
    ).timeout(
      Duration(minutes: 1),
      onTimeout: () {
        viewModel.stopLoading(
          isError: true,
          message: "Request Timeout",
        );
      },
    );
     */
  }

  // Future<void> getToken() {
  //   debugPrint("Register RDN Create Device Id");
  //   viewModel.startLoading();
  //   return MyDevice().getUniqId().then(
  //     (uniqId) {
  //       if (uniqId == "") {
  //         debugPrint("Register RDN Error On Create Device ID");
  //         viewModel.stopLoading(isError: true, message: "error on device load");
  //       } else {
  //         debugPrint("Register RDN Device Id Created : $uniqId");
  //         debugPrint("Register RDN Request Token");
  //         return http.post(Uri.parse(endpointUrl), body: {
  //           "action": "registration",
  //           "devid": uniqId,
  //           "devtoken": md5.convert(utf8.encode("INV2201$uniqId")).toString(),
  //         }, headers: {
  //           "Accept": "application/json"
  //         }).then(
  //           (token) {
  //             viewModel.oaid = json.decode(token.body)["oaid"];
  //             viewModel.oatoken = json.decode(token.body)["oatoken"];
  //             return;
  //           },
  //         );
  //       }
  //     },
  //   ).catchError(
  //     (e) {
  //       viewModel.stopLoading(
  //         isError: true,
  //         message: ErrorHandlingUtil.handleApiError(e),
  //       );
  //     },
  //   ).timeout(
  //     Duration(minutes: 1),
  //     onTimeout: () {
  //       viewModel.stopLoading(
  //         isError: true,
  //         message: "Request Timeout",
  //       );
  //     },
  //   );
  // }

  void createUi({
    required Map<String, dynamic> data,
    bool autoReCreate = true,
    ValueChanged<DynamicUi>? onGetNewUi,
  }) {
    try {
      var newUI = DynamicUi.fromJson(
        data,
        onChanged: onFieldChanged,
      );
      if (newUI.lastpage != viewModel.dynamicUi?.lastpage)
        viewModel.scrollController
            .jumpTo(viewModel.scrollController.position.minScrollExtent);
      if (autoReCreate == true) viewModel.dynamicUi = newUI;
      if (onGetNewUi != null) onGetNewUi(newUI);
      viewModel.stopLoading();
      if (newUI.oamessage != null && newUI.oamessage != "") {
        showMessage(
          message: newUI.oamessage,
        );
        Scrollable.ensureVisible(keyUp.currentContext!);
      }
      viewModel.commit();
      // setPage(data);
    } catch (e) {
      showMessage(
        height: MediaQuery.of(context).size.height / 2,
        message: e.toString(),
      );
      debugPrint('error disini guys');
      throw e;
    }
  }

  // Future<bool> setPage(Map<String, dynamic> dynamicUi) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool savedPage =
  //       await prefs.setString('current page', json.encode(dynamicUi));
  //   return savedPage;
  // }

  getUi({
    FormData? data,
    bool autoReCreate = true,
    ValueChanged<DynamicUi>? onGetNewUi,
    Function(int, int)? onSendProgress,
    String headers = "application/json",
  }) {
    viewModel.startLoading();
    data = data ?? FormData();
    data.fields.addAll([
      MapEntry("action", "registration"),
      MapEntry("oaid", viewModel.oaid!),
      MapEntry("oatoken", viewModel.oatoken!),

      // MapEntry("lastpage", "5"),
      // MapEntry("submitpage", "5"),
    ]);
    debugPrint(
        "Data send to service : $endpointUrl +  ${data.fields} && ${data.files}");
    Future.delayed(Duration(seconds: 1), () {
      Dio()
          .post(
        endpointUrl,
        data: data,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      )
          .then(
        (form) {
          if (form.statusCode != 200) {
            debugPrint(
                "Register RDN Error On Request form ${ErrorHandlingUtil.handleApiError(form)}");
            viewModel.stopLoading(
                isError: true, message: ErrorHandlingUtil.handleApiError(form));
          } else {
            debugPrint("Request RDN Request Form Success");
            // print(
            //     "form ${json.decode(form.data)["oamessage"]} ==== ERROR OA MESSAGE = ${viewModel.dynamicUi.oamessage}");
            try {
              createUi(
                data: json.decode(form.data),
                autoReCreate: autoReCreate,
                onGetNewUi: onGetNewUi,
              );
            } catch (e) {
              viewModel.stopLoading();
              showMessage(
                height: MediaQuery.of(context).size.height / 2,
                message: e.toString(),
              );
            }
          }
        },
      ).catchError((onError) {
        viewModel.stopLoading();
        showMessage(
          height: MediaQuery.of(context).size.height / 2,
          message: ErrorHandlingUtil.handleApiError(onError),
        );
      });
    });
  }

  Future<void> nextPage() async {
    FocusScope.of(context).unfocus();
    if (!validateMandatory()) {
      showMessage(
        message: "Harap isi seluruh kolom yang bertanda bintang",
      );
      return;
    }
    // else if (viewModel.dynamicUi.pages.first.page == 8) {
    //   Navigator.pushNamed(context, '/');
    // }
    else {
      FocusScope.of(context).requestFocus(FocusNode());
      var data = await collectData();
      getUi(
        data: data,
      );
    }
  }

  void showMessage({
    String? message,
    double? height,
  }) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: height ?? 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Icon(
                          Icons.info_outline,
                          size: 50,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Container(
                            child: SingleChildScrollView(
                              child: Text(
                                "$message",
                                style: InvestrendTheme.of(context).regular_w400,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  width: double.infinity,
                  child: ComponentCreator.roundedButton(
                    context,
                    'button_ok'.tr(),
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                    () {
                      Navigator.of(context).pop();
                    },
                    radius: 0,
                  ),
                )
              ],
            ),
          );
        });
  }

  void prevPage() async {
    ValueChanged<DynamicUi> onGetNewUi;

    var requestBody = {
      'action': 'registration',
      'oaid': '${viewModel.oaid}',
      'oatoken': '${viewModel.oatoken}',
      'backfrompage': '${viewModel.dynamicUi!.lastpage}',
    };
    http.Response? response = await http
        .post(
      Uri.parse(endpointUrl),
      body: requestBody,
    )
        .then((value) {
      viewModel.lastpage = json.decode(value.body)["lastpage"];
      createUi(
        data: json.decode(value.body),
      );
      print('HASIL :' + '${value.body}');
      return null;
    });
    viewModel.dynamicUi!.lastpage = Utils.safeInt("${viewModel.lastpage}");

    viewModel.commit();

    debugPrint("Kembali ke halaman : " +
        "${viewModel.backfrompage}\n" +
        "Halaman terakhir anda : " +
        "${viewModel.dynamicUi!.lastpage}\n" +
        "OaId : " +
        "${viewModel.oaid}\n" +
        "oatoken : " +
        "${viewModel.oatoken}");
  }

  /*
  void prevPage() {
    backPage(Map<String, dynamic> body) async {
      var dio = Dio();
      try {
        FormData data = new FormData.fromMap(body);
        data.fields.add(
          MapEntry("backfrompage", viewModel.dynamicUi.lastpage.toString()),
        );
        var response = await dio.post(endpointUrl, data: data);
        return response.data;
      } catch (e) {
        print(e);
      }
    }
    debugPrint("Kembali ke halaman : " +
        "${viewModel.backfrompage}\n" +
        "Halaman terakhir anda : " +
        "${viewModel.dynamicUi.lastpage}");
    viewModel.commit();
  }

    */

  /*
  void prevPage() {
    if (viewModel.dynamicUi.lastpage == 1) {
      Navigator.of(context).pop();
    } else {
      viewModel.dynamicUi.lastpage--;
      viewModel.commit();
    }
  }
  */

  bool validateMandatory() {
    DynamicUIPage page = viewModel.dynamicUi!.pages!
        .where((e) => e.page == viewModel.dynamicUi!.lastpage)
        .first;

    List<DynamicUIField> form = page.form!;
    List<DynamicUIField> emptyForm = [];
    form.forEach((e) {
      e.isError = false;
      // e.validate();
      debugPrint("FIELD =  ${e.id} + CONTENT = ${e.content}");
    });

    emptyForm = (form
        .where((e) =>
            (
                // (e.getContent == null || e.getContent == "") &&
                //       e.mandatory == true ||
                //   e.checked == false ||
                e.validate(page) == false) &&
            e.isShowUi(page) == true)
        .toList());

    emptyForm.forEach((e) {
      e.isError = true;
    });
    viewModel.commit();
    if (emptyForm.length > 0) {
      debugPrint(
          "focus node ada gak ya   = ${emptyForm.first.focusNode!.canRequestFocus}");
      emptyForm.first.focusNode!.requestFocus();
      Scrollable.ensureVisible(emptyForm.first.globalKey!.currentContext!);
      return false;
    } else {
      return true;
    }
  }

  Future<FormData> collectData() async {
    FormData data = FormData();
    List<DynamicUIField> form = viewModel.dynamicUi!.pages!
        .where((e) => e.page == viewModel.dynamicUi!.lastpage)
        .first
        .form!;
    for (var f in form) {
      if (DynamicUIType.basicInput.contains(f.ui)) {
        data.fields.add(
          MapEntry(f.id!, f.content.toString()),
        );
      } else if (DynamicUIType.checkBox == f.ui &&
          (f.content != null && f.content != "")) {
        data.fields.add(
          MapEntry(f.id!, (f.content as bool?) == true ? "Y" : "N"),
        );
      } else if (DynamicUIType.datePicker == f.ui &&
          (f.content != null && f.content != "")) {
        data.fields.add(
          MapEntry(f.id!, (f.content as DateTime).toIso8601String()),
        );
      }
      // else if (DynamicUIType.fileInput.contains(f.ui) &&
      //     (f.content != null && f.content != "")) {
      //   data.files.add(
      //     MapEntry(
      //       f.id,
      //       await MultipartFile.fromFile(f.content),
      //     ),
      //   );
      // }
    }
    data.fields.add(MapEntry("submitpage", "${viewModel.dynamicUi!.lastpage}"));
    return data;
  }

  Future<void> onFieldChanged(DynamicUIField field) async {
    FormData data = FormData();
    data.fields.add(MapEntry("submitpage", "${viewModel.dynamicUi!.lastpage}"));
    switch (field.ui) {
      case DynamicUIType.upload:
        data.files.add(
          MapEntry(
            field.id!,
            await MultipartFile.fromFile(field.content),
          ),
        );
        getUi(
            data: data,
            autoReCreate: false,
            onSendProgress: (uploaded, fileSize) {
              debugPrint("Upload File Changed $uploaded/$fileSize");
              if (field.controller is ImagePickerController) {
                ImagePickerController ctrl = field.controller;
                ctrl.onUploadProgress(uploaded, fileSize);
              }
            },
            onGetNewUi: (ui) {
              String? status = (ui.pages!
                      .where((p) => p.page == viewModel.dynamicUi!.lastpage)
                      .first
                      .form!
                      .where((f) => f.id == field.id)
                      .first as UploadUI)
                  .status;
              print("upload status $status ");
              (field as UploadUI).status = status;
              field.status = status;
              if (field.controller is ImagePickerController) {
                ImagePickerController ctrl = field.controller;
                ctrl.setUploaded(status!);
              }
              // check all upload status

              List<UploadUI> uploadCheck = (ui.pages!
                  .where((p) => p.page == viewModel.dynamicUi!.lastpage)
                  .first
                  .form!
                  .where((f) => f.ui == DynamicUIType.upload)
                  .toList()
                  .map((e) => (e as UploadUI))
                  .toList());

              if (uploadCheck
                  .where((e) => e.status != "DONE")
                  .toList()
                  .isEmpty) {
                nextPage();
              }
            });
        break;
    }
    viewModel.commit();
  }
}

class _ScreenRegisterRDNViewState extends _ScreenRegisterRDNState {
  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).viewPadding.bottom;

    return ChangeNotifierProvider.value(
      value: super.viewModel,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: appBar(),
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                controller: viewModel.scrollController,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      SizedBox(
                        key: keyUp,
                      ),
                      printPage(),
                    ],
                  ),
                ),
              ),
            ),
            Consumer<ScreenRegisterRDNViewModel>(
              builder: (c, d, w) {
                return d.dynamicUi == null || d.isLoading == true
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.1),
                      )
                    : SizedBox();
              },
            ),
          ],
        ),
        bottomNavigationBar: bottomNavigationBar(),
        bottomSheet: createBottomSheet(context, paddingBottom),
      ),
    );
  }

  //appbar
  PreferredSizeWidget appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      automaticallyImplyLeading: false,
      leading: Consumer<ScreenRegisterRDNViewModel>(
        builder: (c, d, w) {
          if (viewModel != null && viewModel.dynamicUi != null) {
            return viewModel.dynamicUi!.minpage! >= showBackButton &&
                    viewModel.dynamicUi!.minpage! <
                        viewModel.dynamicUi!.lastpage!
                ? d.isLoading == true
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: skeletonLoading(height: 45),
                        ),
                      )
                    : IconButton(
                        icon: Image.asset('images/icons/action_back.png'),
                        onPressed: () => super.prevPage(),
                      )
                : Container(
                    color: Colors.transparent,
                  );
          } else {
            return Container(
              color: Colors.transparent,
            );
          }
        },
      ),
      title: getTitle(context),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget getTitle(BuildContext context) {
    return Container(
      child: Consumer<ScreenRegisterRDNViewModel>(
        builder: (c, d, w) {
          if (d.dynamicUi != null && d.oaid != null) {
            return Text(
                d.dynamicUi!.pages!
                    .where((e) => e.page == d.dynamicUi!.lastpage)
                    .first
                    .title!,
                style: Theme.of(context).appBarTheme.titleTextStyle);
          } else {
            return skeletonLoading(height: 50);
          }
        },
      ),
    );
  }

  Future<Widget> listError() async {
    MyDevice myDevice = MyDevice();
    await myDevice.load();
    debugPrint(
        routeName + " Register RDN Create Device Id : " + myDevice.unique_id);
    String? uniqId = myDevice.unique_id;
    return Container(
      child: Consumer<ScreenRegisterRDNViewModel>(
        builder: (c, d, w) {
          return Column(
            children: [
              Container(
                child: Text("action : registration"),
              ),
              Container(
                child: Text("Device ID : " + "$uniqId"),
              )
            ],
          );
        },
      ),
    );
  }

  /*
   "action": "registration",
          "devid": uniqId,
          "devtoken": devtoken,
          "userid": "rizkypebrian",
          "usertoken": token.access_token,
  */

  Widget printPage() {
    return Container(
      child: Consumer<ScreenRegisterRDNViewModel>(
        builder: (c, d, w) {
          if (d.dynamicUi != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                d.dynamicUi!.pages!
                    .where((e) => e.page == d.dynamicUi!.lastpage)
                    .first
                    .form!
                    .length,
                (index) {
                  return d.dynamicUi!.pages!
                      .where((e) => e.page == d.dynamicUi!.lastpage)
                      .first
                      .form![index]
                      .onRecreate(
                        () => viewModel.commit(),
                        previousField: index == 0
                            ? null
                            : d.dynamicUi!.pages!
                                .where((e) => e.page == d.dynamicUi!.lastpage)
                                .first
                                .form![index - 1],
                      )
                      .printUi(
                        context,
                        page: d.dynamicUi!.pages!
                            .where((e) => e.page == d.dynamicUi!.lastpage)
                            .first,
                      );
                },
              ),
            );
          } else {
            return skeletonLoading(
                height: MediaQuery.of(context).size.height - 50);
          }
        },
      ),
    );
  }

  Widget skeletonLoading({
    double? height,
  }) {
    return SkeletonAnimation(
      child: Container(
        height: height,
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.all(Radius.circular(5))),
      ),
    );
  }

  Widget bottomNavigationBar() {
    return Container(
      //color: Colors.yellow,
      width: double.maxFinite,
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Consumer<ScreenRegisterRDNViewModel>(
          builder: (c, d, w) {
            if (d.dynamicUi == null || d.isLoading == true)
              return skeletonLoading(height: 45);
            return viewModel.dynamicUi!.pages!
                        .where((e) => e.page == viewModel.dynamicUi!.lastpage)
                        .toList()
                        .first
                        .withNext ==
                    false
                ? SizedBox()
                : ComponentCreator.roundedButton(
                    context,
                    (viewModel.dynamicUi!.lastpage! >=
                            viewModel.dynamicUi!.pages!.length)
                        // ? "finish"
                        // : "${viewModel.dynamicUi .pages .where((e) => e .page == viewModel.dynamicUi .lastpage) .toList() .first .withNext}",
                        ? "Finish"
                        : 'register_rdn_button_continue'.tr(),
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary, () {
                    if (viewModel.dynamicUi!.lastpage! <
                        viewModel.dynamicUi!.pages!.length) {
                      super.nextPage();
                    } else {
                      InvestrendTheme.showMainPage(
                          context, ScreenTransition.SlideLeft);
                    }
                  });
          },
        ),
      ),
    );
  }
}

class ScreenRegisterRDNViewModel extends ChangeNotifier {
  String? oaid;
  String? oatoken;
  String? backfrompage;
  String? lastpage;
  bool isLoading = false;
  bool isError = false;
  String? message = "";
  DynamicUi? dynamicUi;
  DynamicUIKeyboardType? dynamicUiKeyboardType;
  ScrollController scrollController = new ScrollController();
  bool isLogged = false;
  bool isForeground = false;
  // User user = User('', '', 0.0, 1, null, null, null, null, null, null, null, 0,
  //     null, null, 0);

  void startLoading() {
    isLoading = true;
    commit();
  }

  void stopLoading({
    String? message,
    bool isError = false,
  }) {
    this.message = message;
    this.isError = isError;
    this.isLoading = false;
    commit();
  }

  void commit() {
    notifyListeners();
  }
}
