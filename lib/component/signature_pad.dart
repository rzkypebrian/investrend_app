import 'package:Investrend/utils/investrend_theme.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;

class SignaturePad extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  TextEditingController controller;
  FocusNode focusNode;
  FocusNode nextFocusNode;
  @override
  Widget build(BuildContext context) {
    GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Signature Pad'),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 6.0,
                      spreadRadius: 5.0,
                      offset: Offset(1, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: SfSignaturePad(
                  key: _signaturePadKey,
                  backgroundColor: Colors.transparent,
                  minimumStrokeWidth: 3.0,
                  maximumStrokeWidth: 6.0,
                ),
                height: 200,
                width: 300,
              ),
              SizedBox(
                height: 20,
              ),
              // ElevatedButton(
              //   onPressed: () async {
              //     ui.Image image =
              //         await _signaturePadKey.currentState.toImage();
              //   },
              //   child: Text('Save As Image'),
              // ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Center(
                        child: Column(
                          children: [
                            Text(
                              'preview_buy'.tr(),
                              style: InvestrendTheme.of(context)
                                  .medium_w400
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Image.asset(
                              'images/order_success_normal_mode.png',
                              color: Theme.of(context).colorScheme.secondary,
                            )
                          ],
                        ),
                      ),
                      content: Container(
                          padding: EdgeInsets.all(
                            15,
                          ),
                          child: Table(
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  10,
                                ),
                              ),
                            ),
                            children: [
                              TableRow(
                                children: [
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Stock',
                                        style: InvestrendTheme.of(context)
                                            .medium_w400
                                            .copyWith(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'PTBA',
                                        style: InvestrendTheme.of(context)
                                            .medium_w400
                                            .copyWith(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Price',
                                        style: InvestrendTheme.of(context)
                                            .medium_w400
                                            .copyWith(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '3820',
                                        style: InvestrendTheme.of(context)
                                            .medium_w400
                                            .copyWith(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Lot',
                                        style: InvestrendTheme.of(context)
                                            .medium_w400
                                            .copyWith(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        style: InvestrendTheme.of(context)
                                            .regular_w400_greyDarker,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              EdgeInsets.only(top: 2),
                                          hintStyle: TextStyle(
                                            fontStyle: FontStyle.normal,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          counterText: "",
                                          errorStyle: TextStyle(
                                              color: Colors.red.shade700),
                                          errorMaxLines: 2,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      actions: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Place Order',
                                style: InvestrendTheme.of(context)
                                    .textLabelStyle
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
