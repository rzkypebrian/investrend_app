// ignore_for_file: unused_local_variable

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
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VideoPickerComponent extends StatefulWidget {
  final VideoPickerController? controller;
  final BuildContext context;
  final double height;
  final double width;
  final String placeHolderImageAsset;
  final ValueChanged<VideoPickerController?>? onImageLoaded;
  final String? camera;
  final String? frame;
  final String? status;
  final String? naskah;

  const VideoPickerComponent({
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
    this.naskah,
    // this.imagePickerValue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPickerComponentState();
  }
}

class VideoPickerComponentState extends State<VideoPickerComponent>
    with WidgetsBindingObserver {
  bool sendToBackGround = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPickerValue>(
      valueListenable: widget.controller!,
      builder: (context, value, child) {
        widget.controller!.value.context = context;
        return GestureDetector(
          onTap: () {
            if (value.videoPickerState == VideoPickerState.onInitUpload) return;
            if (value.videoPickerState == VideoPickerState.onUpload) return;
            print("Camera cek = ${widget.camera}");
            sendToBackGround = false;
            widget.controller!.getImages(
              frame: widget.frame,
              cameraCheck: widget.camera,
              naskah: widget.naskah,
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
                color: widget.controller!.value.videoPickerState ==
                        VideoPickerState.empty
                    ? Colors.grey
                    : Colors.blue,
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
            child: childBuilder(value.videoPickerState),
          ),
        );
      },
    );
  }

  Widget childBuilder(VideoPickerState imagePickerState) {
    switch (imagePickerState) {
      case VideoPickerState.onUpload:
        debugPrint('state onUpload = ${VideoPickerState.onUpload}');
        return progressUpload(
          totalSize: widget.controller!.value.fileSize,
          uploadedSize: widget.controller!.value.uploadedSize ?? 0,
          percentage: widget.controller!.value.percentageUpload,
        );
      case VideoPickerState.uploaded:
        debugPrint('state uploaded = ${VideoPickerState.uploaded}');
        if (widget.onImageLoaded != null) {
          widget.onImageLoaded!(widget.controller);
        }
        return loadedVideo();
      case VideoPickerState.uploadFiled:
        debugPrint('state uploadfiled = ${VideoPickerState.uploadFiled}');
        return const SizedBox();
      case VideoPickerState.loaded:
        debugPrint('state loaded = ${VideoPickerState.loaded}');
        if (widget.onImageLoaded != null) {
          widget.onImageLoaded!(widget.controller);
        }
        return loadedVideo();
      case VideoPickerState.empty:
        debugPrint('state empty = ${VideoPickerState.empty}');
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }

  Widget loadedVideo() {
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

  // Widget loadedVideo() {
  //   return Padding(
  //     padding: const EdgeInsets.all(3),
  //     child: Container(
  //       child: FutureBuilder<Uint8List>(
  //         future: VideoThumbnail.thumbnailData(
  //           video: widget.controller.value.fileVideo.path,
  //         ),
  //         builder: (c, s) {
  //           if (s.hasData) {
  //             return Image.memory(s.data);
  //           } else {
  //             return SkeletonAnimation(
  //                 child: Container(
  //               color: Colors.grey.shade300,
  //             ));
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }

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

class VideoPickerController extends ValueNotifier<VideoPickerValue> {
  VideoPickerController({VideoPickerValue? value})
      : super(value ?? VideoPickerValue());

  Future<VideoPickerValue> getImages({
    BuildContext? context,
    String? cameraCheck,
    bool camera = true,
    int imageQuality = 100,
    int compresedQuality = 5,
    String? frame,
    String? naskah,
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
          _picker = await openCamera(
            value.context,
            cameraMode: CameraMode.front,
            frame: frame,
            naskah: naskah,
          );
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

        // if (await Permission.camera.isGranted) {
        //   if (await Permission.microphone.isGranted) {
        //     _picker = await openCamera(
        //       value.context,
        //       cameraIndex: cameraCheck == "front" ? 1 : 0,
        //       frame: frame,
        //     );
        //   } else {
        //     Fluttertoast.showToast(
        //       msg:
        //           "Camera needs to access your Microphone, please provide permission",
        //       gravity: ToastGravity.BOTTOM,
        //       textColor: Colors.white,
        //       toastLength: Toast.LENGTH_SHORT,
        //       backgroundColor: Colors.indigo,
        //     );
        //     openAppSettings();
        //   }
        // } else {
        //   Fluttertoast.showToast(
        //     msg: "Provide Camera permission to use camera",
        //     gravity: ToastGravity.BOTTOM,
        //     textColor: Colors.white,
        //     fontSize: 20,
        //     toastLength: Toast.LENGTH_LONG,
        //     backgroundColor: Colors.indigo,
        //   );
        //   openAppSettings();
        // }
        // _picker = checkPermission(
        //   context,
        //   frame,
        //   cameraCheck,
        // );
      } else {
        _picker = await ImagePicker()
            // ignore: deprecated_member_use
            .pickImage(
                source: ImageSource.gallery,
                imageQuality: imageQuality) as PickedFile;
      }

      _image = File(_picker!.path);

      value.fileVideo = _image;
      value.fileBase64 = getExtension(_image.toString()) +
          base64.encode(_image.readAsBytesSync());
      notifyListeners();

      _uint8Listcompressed = await FlutterImageCompress.compressWithFile(
        _image.absolute.path,
        quality: compresedQuality,
      );

      // _valueBase64Compress =
      //     getExtension(_image.toString()) + base64.encode(_uint8Listcompressed);
      value.fileBase64Compresed = _valueBase64Compress;
      value.fileUri = Uri.parse(_valueBase64Compress).data;

      value.videoPickerState = VideoPickerState.loaded;
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
    if (value.fileVideo == null) {
      value.videoPickerState = VideoPickerState.error;
      commit();
      throw "no image for upload";
    }

    value.uploadedSize = 0;
    value.fileSize = 0;
    value.videoPickerState = VideoPickerState.onInitUpload;
    commit();
    return FileServiceUtil.fileUploadMultipart(
      file: value.fileVideo!,
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
      value.videoPickerState = VideoPickerState.error;
      commit();
      throw (e);
    });
  }

  void onUploadProgress(int uploaded, fileSize) {
    value.videoPickerState = VideoPickerState.onUpload;
    value.uploadedSize = uploaded;
    value.fileSize = fileSize;
    commit();
  }

  void setUploaded(String result) {
    value.uploadedSize = 0;
    value.fileSize = 0;
    value.videoPickerState = VideoPickerState.uploaded;
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
    String? frame,
    String? naskah,
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
            videoMode: true,
            cameraMode: cameraMode,
            naskah: naskah,
            onConfirmImage: (image) {
              Navigator.of(ctx).pop(PickedFile(image!.path));
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

class VideoPickerValue {
  late BuildContext context;
  String? imageHandler;
  VideoPickerState videoPickerState = VideoPickerState.empty;
  bool firstLoad = true;
  File? fileVideo;
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

enum VideoPickerState {
  loaded,
  onInitUpload,
  onUpload,
  uploaded,
  uploadFiled,
  empty,
  error,
}
