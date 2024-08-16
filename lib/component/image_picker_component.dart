import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Investrend/component/camera_component.dart';
import 'package:Investrend/utils/file_service.dart';
import 'package:Investrend/utils/string_utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ImagePickerComponent extends StatefulWidget {
  final ImagePickerController? controller;
  final BuildContext context;
  final double height;
  final double width;
  final String placeHolderImageAsset;
  final ValueChanged<ImagePickerController?>? onImageLoaded;
  final String? camera;
  final String? frame;
  final String? status;

  const ImagePickerComponent({
    Key? key,
    required this.context,
    required this.controller,
    this.height = 120,
    this.width = 120,
    this.placeHolderImageAsset = "images/icon_camera.png",
    this.onImageLoaded,
    this.camera,
    this.frame,
    this.status,
    // this.imagePickerValue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ImagePickerComponentState();
  }
}

class ImagePickerComponentState extends State<ImagePickerComponent>
    with WidgetsBindingObserver {
  bool sendToBackGround = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint("APP LifeCycle State");
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("app state resumed");
        break;
      case AppLifecycleState.inactive:
        debugPrint("app state inactive");
        break;
      case AppLifecycleState.paused:
        debugPrint("app state paused");
        break;
      case AppLifecycleState.detached:
        debugPrint("app state detached");
        MoveToBackground.moveTaskToBack();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ImagePickerValue>(
      valueListenable: widget.controller!,
      builder: (context, value, child) {
        widget.controller!.value.context = context;
        return GestureDetector(
          onTap: () {
            print("CAMERA CEK");
            if (value.imagePickerState == ImagePickerState.onInitUpload) return;
            if (value.imagePickerState == ImagePickerState.onUpload) return;
            print("Camera cek = ${widget.camera}");
            sendToBackGround = false;
            widget.controller!.getImages(
              frame: widget.frame,
              cameraCheck: widget.camera,
            );
          },
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
              border: Border.all(
                  color: widget.status == "NOT DONE" ? Colors.grey : Colors.blue
                  // color: widget.controller.value.imagePickerState ==
                  //         ImagePickerState.empty
                  //     ? Colors.grey
                  //     : Colors.blue,
                  ),
              image: DecorationImage(
                image: widget.status == "NOT DONE"
                    ? AssetImage(
                        "images/icon_camera.png",
                      )
                    : AssetImage("images/checklist_done.png"),
                scale: 4,
                repeat: ImageRepeat.noRepeat,
                alignment: Alignment.center,
                fit: BoxFit.none,
              ),
            ),
            child: childBuilder(value.imagePickerState),
          ),
        );
      },
    );
  }

  Widget childBuilder(ImagePickerState imagePickerState) {
    switch (imagePickerState) {
      case ImagePickerState.onUpload:
        return progressUpload(
          totalSize: widget.controller!.value.fileSize,
          uploadedSize: widget.controller!.value.uploadedSize ?? 0,
          percentage: widget.controller!.value.percentageUpload,
        );
      case ImagePickerState.uploaded:
        if (widget.onImageLoaded != null) {
          widget.onImageLoaded!(widget.controller);
        }
        return loadedImage();
      case ImagePickerState.uploadFiled:
        return const SizedBox();
      case ImagePickerState.loaded:
        if (widget.onImageLoaded != null) {
          widget.onImageLoaded!(widget.controller);
        }
        return loadedImage();
      case ImagePickerState.empty:
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }

  Widget loadedImage() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: widget.status == "NOT DONE"
          ? Image.asset(
              "images/icon_camera.png",
            )
          : Image.asset("images/checklist_done.png"),
      // child: Image.memory(
      //   widget.controller.value.fileUri.contentAsBytes(),
      // ),
    );
  }

  Widget uploadedImage() {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Image.network(widget.controller!.value.uploadedUrl ?? ""),
    );
  }

  Widget progressUpload(
      {required int? totalSize,
      required int uploadedSize,
      required percentage}) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(
                  left: (widget.width) * 10 / 100,
                  right: (widget.width) * 10 / 100),
              padding: const EdgeInsets.all(2),
              width: widget.width,
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1,
                  )),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  width: widget.width * percentage,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePickerController extends ValueNotifier<ImagePickerValue> {
  ImagePickerController({ImagePickerValue? value})
      : super(value ?? ImagePickerValue());

  Future<ImagePickerValue> getImages({
    BuildContext? context,
    String? cameraCheck,
    bool camera = true,
    int imageQuality = 100,
    int compresedQuality = 5,
    String? frame,
  }) async {
    try {
      File _image;
      String _valueBase64Compress = "";
      Uint8List? _uint8Listcompressed;
      PickedFile? _picker;
      if (camera) {
        bool isFront = StringUtils.equalsIgnoreCase(cameraCheck, 'front');
        print("KAMERA TEST DEPAN BELAKANG = $isFront");
        var cameraStatus = await Permission.camera.status;
        var microphoneStatus = await Permission.microphone.status;
        print("status Camera = $cameraStatus");
        print("status microphone = $microphoneStatus");
        if (!cameraStatus.isGranted) await Permission.camera.request();

        if (!microphoneStatus.isGranted) await Permission.microphone.request();

        if (await Permission.camera.isGranted &&
            await Permission.microphone.isGranted) {
          _picker = await openCamera(value.context,
              cameraMode:
                  cameraCheck == "front" ? CameraMode.front : CameraMode.back,
              frame: frame);
        } else if (await Permission.camera.isDenied ||
            await Permission.microphone.isDenied) {
          Fluttertoast.showToast(
            msg: "Provide camera and microphone permission to use camera",
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.indigo,
          );
          openAppSettings();
        } else {
          Fluttertoast.showToast(
            msg: "Provide camera and microphone permission to use camera",
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.indigo,
          );
          openAppSettings();
        }
      } else {
        _picker = await ImagePicker()
            // ignore: deprecated_member_use
            .pickImage(
                source: ImageSource.gallery,
                imageQuality: imageQuality) as PickedFile;
      }

      _image = File(_picker!.path);

      value.fileImage = _image;
      value.fileBase64 = getExtension(_image.toString()) +
          base64.encode(_image.readAsBytesSync());
      notifyListeners();

      _uint8Listcompressed = await FlutterImageCompress.compressWithFile(
        _image.absolute.path,
        quality: compresedQuality,
      );

      _valueBase64Compress = getExtension(_image.toString()) +
          base64.encode(_uint8Listcompressed!);
      value.fileBase64Compresed = _valueBase64Compress;
      value.fileUri = Uri.parse(_valueBase64Compress).data;

      value.imagePickerState = ImagePickerState.loaded;
      value.firstLoad = true;
      commit();
      return value;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFile({
    required String url,
    String? field,
    Map<String, dynamic>? header,
  }) async {
    if (value.fileImage == null) {
      value.imagePickerState = ImagePickerState.error;
      commit();
      throw "no image for upload";
    }

    value.uploadedSize = 0;
    value.fileSize = 0;
    value.imagePickerState = ImagePickerState.onInitUpload;
    commit();
    return FileServiceUtil.fileUploadMultipart(
      file: value.fileImage!,
      field: field,
      url: url,
      header: header,
      onUploadProgress: (
        uploaded,
        fileSize,
      ) {
        onUploadProgress(uploaded, fileSize);
      },
    ).then((result) {
      setUploaded(result);
      return result;
    }).catchError((e) {
      value.imagePickerState = ImagePickerState.error;
      commit();
      throw (e);
    });
  }

  void onUploadProgress(int uploaded, fileSize) {
    value.imagePickerState = ImagePickerState.onUpload;
    value.uploadedSize = uploaded;
    value.fileSize = fileSize;
    commit();
  }

  void setUploaded(String? result) {
    value.uploadedSize = 0;
    value.fileSize = 0;
    value.imagePickerState = ImagePickerState.uploaded;
    value.uploadedResponse = result;
    commit();
  }

  String getExtension(String string) {
    List<String> getList = string.split(".");
    String data = getList.last.replaceAll("'", "");
    String result = "";
    if (data == "png") {
      result = "data:image/png;base64,";
    } else if (data == "jpeg") {
      result = "data:image/jpeg;base64,";
    } else if (data == "jpg") {
      result = "data:image/jpg;base64,";
    } else if (data == "gif") {
      result = "data:image/gif;base64,";
    }
    return result;
  }

  static Future<PickedFile?> openCamera(
    BuildContext context, {
    CameraDescription? cameraDescription,
    CameraMode? cameraMode,
    // int cameraIndex = 0,
    String? frame,
  }) {
    CameraComponentController _cameraComponentController =
        new CameraComponentController();
    return showDialog<PickedFile>(
      context: context,
      builder: (BuildContext ctx) {
        return Container(
          color: Colors.transparent,
          height: double.infinity,
          width: double.infinity,
          child: CameraComponent(
            controller: _cameraComponentController,
            cameraMode: cameraMode,
            frame: frame,
            onConfirmImage: (image) {
              frame == "KTP" || frame == "TTD"
                  ? _cameraComponentController
                      .cropImage(image?.path)
                      .then((value) {
                      Navigator.of(ctx).pop(PickedFile(value!.path));
                    }).whenComplete(
                      () {
                        _cameraComponentController
                            .setState(CameraComponensStates.onLoadedImage);
                      },
                    )
                  : Navigator.of(ctx).pop(PickedFile(image!.path));
            },
          ),
        );
      },
    ).whenComplete(() {
      _cameraComponentController.value.cameraController
          ?.dispose()
          .then((value) => null);
    });
  }

  void commit() {
    notifyListeners();
  }
}

class ImagePickerValue {
  late BuildContext context;
  String? imageHandler;
  ImagePickerState imagePickerState = ImagePickerState.empty;
  bool firstLoad = true;
  File? fileImage;
  String? fileBase64;
  String? fileBase64Compresed;
  UriData? fileUri;
  int? uploadedSize;
  int? fileSize;
  String? uploadedResponse;
  String? uploadedUrl;

  double get percentageUpload {
    return (fileSize == 0 ? 0 : ((uploadedSize ?? 0) / (fileSize ?? 0)) * 100)
        .toDouble();
  }
}

enum ImagePickerState {
  loaded,
  onInitUpload,
  onUpload,
  uploaded,
  uploadFiled,
  empty,
  error,
}
