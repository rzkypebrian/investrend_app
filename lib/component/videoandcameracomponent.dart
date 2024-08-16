import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class CameraComponent extends StatefulWidget {
  final CameraComponentController? controller;
  final ValueChanged<XFile>? onConfirmImage;
  final bool videoMode;
  final CameraMode cameraMode;
  final int recordingLimit;

  const CameraComponent({
    Key? key,
    this.controller,
    this.onConfirmImage,
    this.videoMode = false,
    this.cameraMode = CameraMode.both,
    this.recordingLimit = 30,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    if (videoMode == false) {
      return CameraComponentState();
    } else {
      return VideoComponentState();
    }
  }
}

class CameraComponentState extends State<CameraComponent> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraComponentValue>(
      valueListenable: widget.controller ?? CameraComponentController(),
      builder: (c, d, w) {
        if (d.cameraController == null) {
          widget.controller?.initCamera();
        }
        return childBuilder(d.state);
      },
    );
  }

  Widget childBuilder(CameraComponensStates state) {
    switch (state) {
      case CameraComponensStates.onInitializeCamera:
        return initializeWidget();
      case CameraComponensStates.onOpenedCamera:
        return openedCameraWidget();
      case CameraComponensStates.onLoadedImage:
        return loadedImageWidget();
      default:
        return const SizedBox();
    }
  }

  Widget initializeWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget openedCameraWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CameraPreview(
                  widget.controller!.value.cameraController!,
                ),
              ),
            ),
          ),
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.changeFlashMode();
                      },
                      child: ValueListenableBuilder<CameraValue>(
                        valueListenable:
                            widget.controller!.value.cameraController!,
                        builder: (c, d, w) {
                          return Icon(
                            widget.controller!.value.cameraController!.value
                                        .flashMode ==
                                    FlashMode.auto
                                ? Icons.flash_auto
                                : widget.controller!.value.cameraController!
                                            .value.flashMode ==
                                        FlashMode.torch
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.takePicture();
                      },
                      child: const Icon(
                        Icons.brightness_1_rounded,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.controller?.changeCamera();
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: ValueListenableBuilder<CameraValue>(
                        valueListenable:
                            widget.controller!.value.cameraController!,
                        builder: (c, d, w) {
                          return const Icon(
                            Icons.sync,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget loadedImageWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PhotoView(
                  enableRotation: true,
                  imageProvider: FileImage(
                      File(widget.controller?.value.captured?.path ?? "")),
                  errorBuilder: (b, o, s) {
                    return const Center(
                      child: Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller
                            ?.setState(CameraComponensStates.onOpenedCamera);
                      },
                      child: const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.value.cameraController
                            ?.dispose()
                            .then((value) => null);
                        if (widget.onConfirmImage != null) {
                          widget.onConfirmImage!(
                              widget.controller!.value.captured!);
                        } else {
                          Navigator.of(context)
                              .pop(widget.controller!.value.captured);
                        }
                      },
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.value.cameraController?.dispose();
    super.dispose();
  }
}

class VideoComponentState extends State<CameraComponent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraComponentValue>(
      valueListenable: widget.controller ?? CameraComponentController(),
      builder: (c, d, w) {
        if (d.cameraController == null) {
          switch (widget.cameraMode) {
            case CameraMode.both:
              widget.controller?.initCamera();
              break;
            case (CameraMode.front):
              availableCameras().then((value) {
                widget.controller?.value.cameraDescriptions = value;
                widget.controller?.initCamera(
                  cameraDescription: value.last,
                );
              });
              break;
            case (CameraMode.back):
              availableCameras().then((value) {
                widget.controller?.value.cameraDescriptions = value;
                widget.controller?.initCamera(
                  cameraDescription: value.first,
                );
              });
              break;
            default:
              widget.controller?.initCamera();
          }
        }
        return childBuilder(d.state);
      },
    );
  }

  Widget childBuilder(CameraComponensStates state) {
    switch (state) {
      case CameraComponensStates.onInitializeCamera:
        return initializeWidget();
      case CameraComponensStates.onOpenedCamera:
        return openedCameraWidget();
      case CameraComponensStates.onRecording:
        return recordingViedeoWidget();
      case CameraComponensStates.onLoadedVideo:
        return loadediedeoWidget();
      default:
        return const SizedBox();
    }
  }

  Widget initializeWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget openedCameraWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(10),
            color: Colors.black,
            alignment: Alignment.center,
            child: Text(
              "${widget.recordingLimit}",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CameraPreview(
                  widget.controller!.value.cameraController!,
                ),
              ),
            ),
          ),
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.changeFlashMode();
                      },
                      child: ValueListenableBuilder<CameraValue>(
                        valueListenable:
                            widget.controller!.value.cameraController!,
                        builder: (c, d, w) {
                          return Icon(
                            widget.controller!.value.cameraController!.value
                                        .flashMode ==
                                    FlashMode.auto
                                ? Icons.flash_auto
                                : widget.controller!.value.cameraController!
                                            .value.flashMode ==
                                        FlashMode.torch
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.startRecording(
                          recordingLimit: widget.recordingLimit,
                        );
                      },
                      child: const Icon(
                        Icons.brightness_1_rounded,
                        color: Colors.red,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                widget.cameraMode != CameraMode.both
                    ? const Expanded(child: SizedBox())
                    : Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.controller?.changeCamera();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: ValueListenableBuilder<CameraValue>(
                              valueListenable:
                                  widget.controller!.value.cameraController!,
                              builder: (c, d, w) {
                                return const Icon(
                                  Icons.sync,
                                  color: Colors.white,
                                  size: 30,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget recordingViedeoWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(10),
            color: Colors.black,
            alignment: Alignment.center,
            child: StreamBuilder<Duration>(
              stream: widget.controller!.value.durationStream.stream,
              builder: (c, s) {
                return Text(
                  "${s.data?.inSeconds ?? ""}",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CameraPreview(
                  widget.controller!.value.cameraController!,
                ),
              ),
            ),
          ),
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.changeFlashMode();
                      },
                      child: ValueListenableBuilder<CameraValue>(
                        valueListenable:
                            widget.controller!.value.cameraController!,
                        builder: (c, d, w) {
                          return Icon(
                            widget.controller!.value.cameraController!.value
                                        .flashMode ==
                                    FlashMode.auto
                                ? Icons.flash_auto
                                : widget.controller!.value.cameraController!
                                            .value.flashMode ==
                                        FlashMode.torch
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.stopRecording();
                      },
                      child: const Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                widget.cameraMode != CameraMode.both
                    ? const Expanded(child: SizedBox())
                    : Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.controller?.changeCamera();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: ValueListenableBuilder<CameraValue>(
                              valueListenable:
                                  widget.controller!.value.cameraController!,
                              builder: (c, d, w) {
                                return const Icon(
                                  Icons.sync,
                                  color: Colors.white,
                                  size: 30,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget loadediedeoWidget() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(10),
            color: Colors.black,
            alignment: Alignment.center,
            // child: Text(
            //   "30",
            //   style: System.data.textStyles!.boldTitleLabel
            //       .copyWith(color: System.data.color!.lightTextColor),
            // ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FutureBuilder<VideoPlayerController>(
                  future: widget.controller?.previewVideo(),
                  builder: (c, s) {
                    return AspectRatio(
                      aspectRatio: (s.data?.value.size.width ??
                              MediaQuery.of(context).size.width) /
                          (s.data?.value.size.height ??
                              MediaQuery.of(context).size.height),
                      child: VideoPlayer(
                        widget.controller!.value.videoPlayerController!,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.value.videoPlayerController
                            ?.dispose();
                        widget.controller
                            ?.setState(CameraComponensStates.onOpenedCamera);
                      },
                      child: const Icon(
                        Icons.timer_sharp,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.controller?.value.videoPlayerController
                            ?.dispose();
                        widget.controller?.value.cameraController
                            ?.dispose()
                            .then((value) => null);
                        if (widget.onConfirmImage != null) {
                          widget.onConfirmImage!(
                              widget.controller!.value.captured!);
                        } else {
                          Navigator.of(context)
                              .pop(widget.controller!.value.captured);
                        }
                      },
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.value.videoPlayerController?.dispose();
    widget.controller?.value.cameraController?.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        // super.dispose();
        break;
      case AppLifecycleState.paused:
        Navigator.of(context).pop();
        break;
      case AppLifecycleState.detached:
        // Navigator.of(context).pop();
        break;
    }
  }
}

class CameraComponentController extends ValueNotifier<CameraComponentValue> {
  CameraComponentController({
    CameraComponentValue? value,
  }) : super(
          value ?? CameraComponentValue(),
        );

  void initCamera({
    CameraDescription? cameraDescription,
  }) {
    setState(CameraComponensStates.onInitializeCamera);
    value.cameraController!.dispose();
    if (cameraDescription != null) {
      value.selectedCamera = cameraDescription;
      value.cameraController =
          CameraController(value.selectedCamera!, ResolutionPreset.high);
      value.cameraController!.initialize().then(
        (camera) {
          value.cameraController!.setFlashMode(value.flashMode);
          setState(CameraComponensStates.onOpenedCamera);
        },
      );
    } else {
      availableCameras().then(
        (availableCamera) {
          value.cameraDescriptions = availableCamera;
          value.selectedCamera = value.cameraDescriptions!.first;
          value.cameraController =
              CameraController(value.selectedCamera!, ResolutionPreset.high);
          value.cameraController!.initialize().then(
            (camera) {
              value.cameraController!.setFlashMode(value.flashMode);
              setState(CameraComponensStates.onOpenedCamera);
            },
          );
        },
      );
    }
  }

  void changeCamera() {
    if ((value.cameraDescriptions?.length ?? 0) > 1) {
      int _indexCamra =
          (value.cameraDescriptions)!.indexOf(value.selectedCamera!);
      if ((_indexCamra + 1) <= (value.cameraDescriptions ?? []).length - 1) {
        value.cameraController?.dispose().then(
          (dispose) {
            initCamera(
              cameraDescription: value.cameraDescriptions![(_indexCamra + 1)],
            );
          },
        );
      } else {
        value.cameraController?.dispose().then(
          (dispose) {
            initCamera(
              cameraDescription: value.cameraDescriptions?.first,
            );
          },
        );
      }
    }
  }

  void changeFlashMode() {
    if (value.flashMode == FlashMode.off) {
      setFlashMode(FlashMode.auto);
    } else if (value.flashMode == FlashMode.auto) {
      setFlashMode(FlashMode.torch);
    } else {
      setFlashMode(FlashMode.off);
    }
  }

  void setFlashMode(FlashMode mode) {
    value.cameraController?.setFlashMode(mode);
    value.flashMode = mode;
    commit();
  }

  void takePicture() {
    value.cameraController?.takePicture().then(
      (image) {
        value.captured = image;
        setState(CameraComponensStates.onLoadedImage);
      },
    );
  }

  void startRecording({int? recordingLimit}) {
    value.cameraController?.startVideoRecording().then((camera) {
      value.state = CameraComponensStates.onRecording;
      commit();
      value.duration = Duration(seconds: recordingLimit!);
      value.recordingTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          value.duration =
              Duration(seconds: (value.duration?.inSeconds ?? 0) - 1);
          value.durationStream
              .add(value.duration ?? const Duration(seconds: 0));
          if ((value.duration?.inSeconds ?? 0) == 0) {
            timer.cancel();
            stopRecording();
          }
        },
      );
    });
  }

  void stopRecording() {
    value.cameraController?.stopVideoRecording().then((video) {
      value.captured = video;
      setState(CameraComponensStates.onLoadedVideo);
    });
  }

  Future<VideoPlayerController> previewVideo() {
    value.videoPlayerController =
        VideoPlayerController.file(File(value.captured!.path));

    value.videoPlayerController?.setLooping(true);
    return value.videoPlayerController!.initialize().then(
      (_) {
        value.videoPlayerController?.play();
        return Future.value().then((v) => value.videoPlayerController!);
      },
    );
  }

  void setState(CameraComponensStates state) {
    value.state = state;
    commit();
  }

  void commit() {
    notifyListeners();
  }
}

class CameraComponentValue {
  CameraComponensStates state = CameraComponensStates.onInitializeCamera;
  CameraController? cameraController;
  List<CameraDescription>? cameraDescriptions;
  CameraDescription? selectedCamera;
  FlashMode flashMode = FlashMode.off;
  VideoPlayerController? videoPlayerController;
  Timer? recordingTimer;
  Duration? duration;
  // ignore: close_sinks
  StreamController<Duration> durationStream =
      StreamController<Duration>.broadcast();

  XFile? captured;
}

enum CameraComponensStates {
  onInitializeCamera,
  onOpenedCamera,
  onLoadedImage,
  onRecording,
  onPausedRecording,
  onLoadedVideo,
}

enum CameraMode {
  front,
  back,
  both,
}
