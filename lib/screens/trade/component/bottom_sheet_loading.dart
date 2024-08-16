// ignore_for_file: invalid_use_of_protected_member

import 'dart:math';

import 'package:Investrend/objects/class_value_notifier.dart';
import 'package:Investrend/objects/data_object.dart';
import 'package:Investrend/utils/investrend_theme.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LoadingBottomNotifier {
  ValueNotifier<bool> closeNotifier = ValueNotifier(false);
  ValueNotifier<String> messageNotifier = ValueNotifier('');
  bool active = true;
  void setMessage(String message) {
    if (active) {
      messageNotifier.value = message;
    }
  }

  bool hasCloseListeners() {
    return closeNotifier.hasListeners;
  }

  void notifyClose() {
    if (active) {
      closeNotifier.value = !closeNotifier.value;
    }
  }

  void addCloseListener(VoidCallback? onClose) {
    if (active) {
      if (onClose != null) {
        closeNotifier.addListener(onClose);
      }
    }
  }

  void removeCloseListener(VoidCallback? onClose) {
    if (active) {
      if (onClose != null) {
        closeNotifier.removeListener(onClose);
      }
    }
  }

  void dispose() {
    active = false;
    closeNotifier.dispose();
    messageNotifier.dispose();
  }
}

class LoadingBottom extends StatefulWidget {
  // final ValueNotifier<bool> loadingCloseNotifier;
  // final ValueNotifier<String> loadingMessageNotifier;
  final LoadingBottomNotifier notifier;
  const LoadingBottom(
      /*this.loadingCloseNotifier, this.loadingMessageNotifier,*/ this.notifier,
      {Key? key})
      : super(key: key);

  @override
  _LoadingBottomState createState() => _LoadingBottomState();
}

class _LoadingBottomState extends State<LoadingBottom> {
  void closeListener() {
    if (mounted) {
      print(
          'closeListener LoadingBottom loadingCloseNotifier.removeListener  --> mounted : $mounted');
      //widget.loadingCloseNotifier.removeListener(closeListener);
      widget.notifier.removeCloseListener(closeListener);
      print(
          'closeListener LoadingBottom Navigator.pop  --> mounted : $mounted');
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    //widget.loadingCloseNotifier.addListener(closeListener);
    widget.notifier.addCloseListener(closeListener);
  }

  @override
  void dispose() {
    print(
        'dispose LoadingBottom loadingCloseNotifier.removeListener  --> mounted : $mounted');
    //widget.loadingCloseNotifier.removeListener(closeListener);
    widget.notifier.removeCloseListener(closeListener);
    super.dispose();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + 44.0 + padding + 100.0;

    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Text(
                'loading_please_wait_label'.tr(),
                style: InvestrendTheme.of(context).regular_w600,
              ),
              ValueListenableBuilder<String>(
                  valueListenable: widget.notifier.messageNotifier,
                  builder: (context, textLoading, child) {
                    if (StringUtils.isEmtpy(textLoading)) {
                      return SizedBox(height: 1.0);
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          textLoading,
                          style: InvestrendTheme.of(context).small_w400_compact,
                        ),
                      );
                    }
                  }),
              // SizedBox(height: widget.text != null ? 20.0 : 1.0),
              // widget.text != null ? Text(widget.text, style: InvestrendTheme.of(context).small_w400_compact,) : SizedBox(height: 1.0),
              SizedBox(height: 20.0),
              CircularProgressIndicator(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingBottomSheetNew extends StatefulWidget {
  //final String text;
  // final ValueNotifier<bool> finishedNotifier;

  final LoadingNotifier loadingNotifier;
  const LoadingBottomSheetNew(this.loadingNotifier, {Key? key})
      : super(key: key);

  @override
  _LoadingBottomSheetNewState createState() => _LoadingBottomSheetNewState();
}

class _LoadingBottomSheetNewState extends State<LoadingBottomSheetNew> {
  // DateTime startLoadingTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    widget.loadingNotifier.addListener(() {
      print('Finished Loading  --> mounted : $mounted  finishedNotifier : ' +
          widget.loadingNotifier.value.toString());

      if (mounted) {
        if (!widget.loadingNotifier.value!.showLoading) {
          print(
              'Finished Loading Navigator.pop  --> mounted : $mounted  finishedNotifier : ' +
                  widget.loadingNotifier.value.toString());
          Navigator.pop(context);
        }

        // DateTime endLoadingTime = DateTime.now();
        // int gap = endLoadingTime.difference(startLoadingTime).inMilliseconds;
        // if(gap > 3000){

        // }else{
        //   Future.delayed(Duration(milliseconds: gap), (){
        //     Navigator.pop(context);
        //   });
        // }
      } else {
        // widget.loadingNotifier.setValue(false, '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + 44.0 + padding + 100.0;

    //if (contentHeight > minHeight) {
    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);
    //}

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Text(
                'loading_please_wait_label'.tr(),
                style: InvestrendTheme.of(context).regular_w600,
              ),
              ValueListenableBuilder<LoadingData?>(
                  valueListenable: widget.loadingNotifier,
                  builder: (context, value, child) {
                    if (StringUtils.isEmtpy(value!.textLoading)) {
                      return SizedBox(height: 1.0);
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          value.textLoading,
                          style: InvestrendTheme.of(context).small_w400_compact,
                        ),
                      );
                    }
                  }),
              // SizedBox(height: widget.text != null ? 20.0 : 1.0),
              // widget.text != null ? Text(widget.text, style: InvestrendTheme.of(context).small_w400_compact,) : SizedBox(height: 1.0),
              SizedBox(height: 20.0),
              CircularProgressIndicator(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingBottomSheetSimple extends StatelessWidget {
  final String textLoading;
  const LoadingBottomSheetSimple(this.textLoading, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + 44.0 + padding + 100.0 + 20.0;

    //if (contentHeight > minHeight) {
    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);
    //}

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Text(
                'loading_please_wait_label'.tr(),
                style: InvestrendTheme.of(context).regular_w600,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  textLoading,
                  style: InvestrendTheme.of(context).small_w400_compact,
                ),
              ),
              SizedBox(height: 20.0),
              CircularProgressIndicator(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingBottomSheet extends StatefulWidget {
  final String? text;
  final ValueNotifier<bool> finishedNotifier;
  const LoadingBottomSheet(this.finishedNotifier, {this.text, Key? key})
      : super(key: key);

  @override
  _LoadingBottomSheetState createState() => _LoadingBottomSheetState();
}

class _LoadingBottomSheetState extends State<LoadingBottomSheet> {
  // DateTime startLoadingTime = DateTime.now();
  @override
  void initState() {
    super.initState();

    widget.finishedNotifier.addListener(() {
      print('Finished Loading  --> mounted : $mounted  finishedNotifier : ' +
          widget.finishedNotifier.value.toString());
      if (mounted && widget.finishedNotifier.value) {
        // DateTime endLoadingTime = DateTime.now();
        // int gap = endLoadingTime.difference(startLoadingTime).inMilliseconds;
        // if(gap > 3000){
        Navigator.pop(context);
        // }else{
        //   Future.delayed(Duration(milliseconds: gap), (){
        //     Navigator.pop(context);
        //   });
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //final selected = watch(marketChangeNotifier);
    //print('selectedIndex : ' + selected.index.toString());
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double padding = 24.0;
    double minHeight = height * 0.2;
    double maxHeight = height * 0.7;
    double contentHeight = padding + 44.0 + 44.0 + padding + 100.0;

    //if (contentHeight > minHeight) {
    maxHeight = min(contentHeight, maxHeight);
    minHeight = min(minHeight, maxHeight);
    //}

    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: minHeight,
        minWidth: width,
        maxHeight: maxHeight,
        maxWidth: width,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Text(
                'loading_please_wait_label'.tr(),
                style: InvestrendTheme.of(context).regular_w600,
              ),
              SizedBox(height: widget.text != null ? 20.0 : 1.0),
              widget.text != null
                  ? Text(
                      widget.text!,
                      style: InvestrendTheme.of(context).small_w400_compact,
                    )
                  : SizedBox(height: 1.0),
              SizedBox(height: 20.0),
              CircularProgressIndicator(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
