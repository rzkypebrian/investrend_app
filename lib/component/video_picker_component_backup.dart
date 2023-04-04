// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:Investrend/objects/riverpod_change_notifier.dart';
// import 'package:animations/animations.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:skeleton_text/skeleton_text.dart';
// import 'package:video_player/video_player.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:math' as math;

// class VideoPickerComponent extends StatelessWidget {
//   // final double videoContainerRatio;
//   final VideoPickerController controller;
//   final BuildContext context;
//   final double height;
//   final double width;
//   final String placeHolderImageAsset;
//   final ValueChanged<VideoPickerController> onVideoLoaded;
//   final ValueChanged<VideoPickerController> onConfirm;

//   //tambahan

//   const VideoPickerComponent({
//     Key key,
//     @required this.context,
//     @required this.controller,
//     // this.videoContainerRatio = 0.5,
//     this.height = 120,
//     this.width = 120,
//     this.placeHolderImageAsset = "images/icon_record.png",
//     this.onVideoLoaded,
//     this.onConfirm,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<VideoPickerValue>(
//       valueListenable: controller,
//       builder: (context, value, child) {
//         return GestureDetector(
//           onTap: () {
//             if (value.videoPickerState == VideoPickerState.onInitUpload) return;
//             if (value.videoPickerState == VideoPickerState.onUpload) return;
//             controller.initCamera().then((value) {
//               initRecording().then((value) {
//                 controller.cameraController.dispose();
//               });
//             });
//           },
//           child: Container(
//             height: 120,
//             width: 120,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.all(
//                 Radius.circular(15),
//               ),
//               border: Border.all(
//                 color:
//                     controller.value.videoPickerState == VideoPickerState.empty
//                         ? Colors.grey
//                         : Colors.grey,
//               ),
//               image: const DecorationImage(
//                 image: AssetImage(
//                   "images/icon_record.png",
//                 ),
//                 scale: 8,
//                 repeat: ImageRepeat.noRepeat,
//                 alignment: Alignment.center,
//                 fit: BoxFit.none,
//               ),
//             ),
//             child: childBuilder(value.videoPickerState),
//           ),
//         );
//       },
//     );
//   }

//   Widget childBuilder(VideoPickerState imagePickerState) {
//     switch (imagePickerState) {
//       case VideoPickerState.onUpload:
//         return progressUpload(
//           totalSize: controller.value.fileSize,
//           uploadedSize: controller.value.uploadedSize ?? 0,
//           percentage: controller.value.percentageUpload,
//         );
//       case VideoPickerState.uploaded:
//         if (onVideoLoaded != null) {
//           onVideoLoaded(controller);
//         }
//         return loadedVideo();
//       case VideoPickerState.uploadFiled:
//         return const SizedBox();
//       case VideoPickerState.loaded:
//         if (onVideoLoaded != null) {
//           onVideoLoaded(controller);
//         }
//         return loadedVideo();
//       case VideoPickerState.recorded:
//         if (onVideoLoaded != null) {
//           onVideoLoaded(controller);
//         }
//         return loadedVideo();
//       case VideoPickerState.empty:
//         return const SizedBox();
//       default:
//         return const SizedBox();
//     }
//   }

//   Widget loadedVideo() {
//     return Padding(
//       padding: const EdgeInsets.all(3),
//       child: Container(
//         child: FutureBuilder<Uint8List>(
//           future: VideoThumbnail.thumbnailData(
//             video: controller.value.fileVideo.path,
//           ),
//           builder: (c, s) {
//             if (s.hasData) {
//               return Image.memory(s.data);
//             } else {
//               return SkeletonAnimation(
//                   child: Container(
//                 color: Colors.grey.shade300,
//               ));
//             }
//           },
//         ),
//       ),
//     );
//   }

//   // Widget uploadedImage() {
//   //   return Padding(
//   //     padding: const EdgeInsets.all(3),
//   //     child: Image.network(controller.value.uploadedUrl ?? ""),
//   //   );
//   // }

//   Widget progressUpload(
//       {@required int totalSize,
//       @required int uploadedSize,
//       @required percentage}) {
//     return Container(
//       color: Colors.transparent,
//       child: Stack(
//         children: [
//           Center(
//             child: Container(
//               margin: EdgeInsets.only(
//                   left: (width) * 10 / 100, right: (width) * 10 / 100),
//               padding: const EdgeInsets.all(2),
//               width: width,
//               height: 20,
//               decoration: BoxDecoration(
//                   color: Colors.transparent,
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(5),
//                   ),
//                   border: Border.all(
//                     color: Theme.of(context).colorScheme.secondary,
//                     width: 1,
//                   )),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: AnimatedContainer(
//                   duration: const Duration(
//                     milliseconds: 500,
//                   ),
//                   width: width * percentage,
//                   decoration: const BoxDecoration(
//                     color: Colors.green,
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(5),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // void timer() {
//   //   Timer.periodic(Duration(seconds: 60), (timer) {
//   //     if (VideoPickerState.recorded == true) {}
//   //   });
//   // }

//   Future<void> initRecording() {
//     int selectedCameraIndex;

//     final size = MediaQuery.of(context).size;
//     final deviceRatio = size.width / size.height;
//     final double mirror = selectedCameraIndex == 0 ? math.pi : 0;

//     if (controller.value.fileVideo != null) {
//       controller.initVideoPlayer();
//     }
//     return showModal<void>(
//       context: context,
//       builder: (ctx) {
//         print("MASUK SINI TIMER");
//         return WillPopScope(
//           onWillPop: () async {
//             return false;
//           },
//           child: Container(
//             color: Colors.black,
//             child: ValueListenableBuilder<VideoPickerValue>(
//               valueListenable: controller,
//               builder: (c, d, w) {
//                 return Container(
//                   child: Column(
//                     children: [
//                       Material(
//                         child: Container(
//                           padding: EdgeInsets.only(top: 10),
//                           width: double.infinity,
//                           height: 60,
//                           color: Colors.black,
//                           child: Center(
//                             child: StreamBuilder<Duration>(
//                               initialData: Duration(seconds: 10),
//                               stream: controller.value.durationStream.stream,
//                               builder: (context, snapshot) {
//                                 if (snapshot.data.inSeconds <= 0) {
//                                   controller.stopRecordding();
//                                 }
//                                 return Text(
//                                   "${snapshot.data.inSeconds}",
//                                   style: TextStyle(fontSize: 20)
//                                       .copyWith(color: Colors.white),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Transform(
//                               alignment: Alignment.center,
//                               transform: Matrix4.rotationY(math.pi),
//                               child: CameraPreview(
//                                 controller.cameraController,
//                                 child: Container(
//                                   color: Colors.transparent,
//                                   child: [
//                                     VideoPickerState.recorded
//                                   ].contains(controller.value.videoPickerState)
//                                       ? Container(
//                                           height: double.infinity,
//                                           width: double.infinity,
//                                           color: Colors.black,
//                                           child: VlcPlayer(
//                                             key: key,
//                                             controller: controller
//                                                 .videoPlayerController,
//                                             aspectRatio: deviceRatio /
//                                                 controller.videoPlayerController
//                                                     .value.aspectRatio,
//                                             placeholder: Center(
//                                               child:
//                                                   CircularProgressIndicator(),
//                                             ),
//                                           ),
//                                         )
//                                       : Container(),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 150,
//                         color: Colors.transparent,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 child: [
//                                   // VideoPickerState.loaded,
//                                   VideoPickerState.empty
//                                 ].contains(controller.value.videoPickerState)
//                                     ? SizedBox()
//                                     : [
//                                         VideoPickerState.loaded,
//                                         VideoPickerState.recorded,
//                                       ].contains(
//                                             controller.value.videoPickerState)
//                                         ? submit(
//                                             context,
//                                           )
//                                         : SizedBox(),

//                                 // child: [
//                                 //   VideoPickerState.recording,
//                                 //   VideoPickerState.recordingPaused
//                                 // ].contains(controller.value.videoPickerState)
//                                 //     ? cancel(controller)
//                                 //     : [
//                                 //         VideoPickerState.loaded,
//                                 //         VideoPickerState.recorded
//                                 //       ].contains(
//                                 //             controller.value.videoPickerState)
//                                 //         ? submit(
//                                 //             context,
//                                 //           )
//                                 //         : cancel(controller),
//                               ),
//                             ),
//                             Expanded(
//                               child: Container(
//                                 child: startStopRecord(controller),
//                               ),
//                             ),
//                             Expanded(
//                               child: Container(
//                                 child: [
//                                   // VideoPickerState.recording,
//                                   VideoPickerState.recordingPaused,
//                                   VideoPickerState.loaded,
//                                   VideoPickerState.recorded,
//                                 ].contains(controller.value.videoPickerState)
//                                     ? remove(controller)
//                                     : SizedBox(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     ).then((val) {
//       controller.value.durationStream.add(Duration(seconds: 60));
//     });
//   }

//   //TODO : pause and play
//   Widget playPausRecord(VideoPickerController controller) {
//     return Center(
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(
//             Radius.circular(50),
//           ),
//           border: Border.all(
//             color: Colors.white,
//             width: 2,
//           ),
//         ),
//         child: Center(
//             // child: GestureDetector(
//             //   onTap: () {
//             //     print('Device Ratio : ' +
//             //         '${controller.videoPlayerController.value.aspectRatio}');
//             //     if (controller.value.videoPickerState ==
//             //         VideoPickerState.recording) {
//             //       controller.pauseRecordding();
//             //     } else {
//             //       controller.resumeRecordding();
//             //     }
//             //   },
//             //   child: Icon(
//             //     controller.value.videoPickerState == VideoPickerState.recording
//             //         ? Icons.pause
//             //         : Icons.play_arrow,
//             //     color: Colors.white,
//             //   ),
//             // ),
//             ),
//       ),
//     );
//   }

//   Widget changeCamera(VideoPickerController controller) {
//     return Center(
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(
//             Radius.circular(50),
//           ),
//           border: Border.all(
//             color: Colors.white,
//             width: 2,
//           ),
//         ),
//         child: GestureDetector(
//           onTap: () {
//             controller.changeCamera();
//           },
//           child: Center(
//             child: Icon(
//               Icons.cameraswitch,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget submit(BuildContext context) {
//     return Center(
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(
//             Radius.circular(50),
//           ),
//           border: Border.all(
//             color: Colors.white,
//             width: 2,
//           ),
//         ),
//         child: Center(
//           child: GestureDetector(
//             onTap: () {
//               Navigator.of(context).pop();
//               if (onConfirm != null) {
//                 onConfirm(controller);
//               }
//             },
//             child: Icon(
//               Icons.check,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget remove(VideoPickerController controller) {
//     return Center(
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(
//             Radius.circular(50),
//           ),
//           border: Border.all(
//             color: Colors.white,
//             width: 2,
//           ),
//         ),
//         child: Center(
//           child: GestureDetector(
//             onTap: () {
//               controller.remove();
//             },
//             child: Icon(
//               Icons.close,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget cancel(VideoPickerController controller) {
//     return Center(
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(
//             Radius.circular(50),
//           ),
//           border: Border.all(
//             color: Colors.white,
//             width: 2,
//           ),
//         ),
//         child: Center(
//           child: GestureDetector(
//             onTap: () {
//               Navigator.of(context).pop();
//             },
//             child: Icon(
//               Icons.backspace,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget startStopRecord(VideoPickerController controller) {
//     return Center(
//       child: Container(
//           height: 90,
//           width: 90,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(
//               Radius.circular(50),
//             ),
//             border: Border.all(
//               color: Colors.white,
//               width: 2,
//             ),
//           ),
//           child: [VideoPickerState.loaded, VideoPickerState.recorded]
//                   .contains(controller.value.videoPickerState)
//               ? playPauseVideo(controller)
//               : [VideoPickerState.empty]
//                       .contains(controller.value.videoPickerState)
//                   ? recordButton(controller)
//                   : stopButton(controller)),
//     );
//   }

//   Widget recordButton(VideoPickerController controller) {
//     return Stack(
//       children: [
//         Container(
//           height: height,
//         ),
//         Center(
//           child: GestureDetector(
//             onTap: () {
//               controller.startRecord();
//             },
//             child: Container(
//               height: 80,
//               width: 80,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(50),
//                 ),
//                 color: Colors.red,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget stopButton(VideoPickerController controller) {
//     return Center(
//       child: GestureDetector(
//         onTap: () {
//           controller.stopRecordding();
//         },
//         child: Container(
//           height: 30,
//           width: 30,
//           decoration: BoxDecoration(
//             color: Colors.red,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget playPauseVideo(VideoPickerController controller) {
//     return Center(
//       child: Container(
//         height: 60,
//         width: 60,
//         child: Center(
//           child: GestureDetector(
//             onTap: () {
//               if (controller.value.videoPlayerState ==
//                   VideoPlayerState.playing) {
//                 controller.pausePlayer();
//               } else {
//                 controller.playPlayer();
//               }
//             },
//             child: Icon(
//               controller.value.videoPlayerState == VideoPlayerState.playing
//                   ? Icons.pause
//                   : Icons.play_arrow,
//               size: 55,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class VideoPickerController extends ValueNotifier<VideoPickerValue> {
//   @override
//   void dispose() async {
//     await videoPlayerController.stopRendererScanning();
//     await videoPlayerController.dispose();
//     value.timer?.cancel();
//     super.dispose();
//   }

//   VideoPickerController({VideoPickerValue value})
//       : super(value ?? VideoPickerValue());

//   bool frontCamera = true;
//   CameraController cameraController;
//   VlcPlayerController videoPlayerController;

//   Future<void> initCamera({bool frontCamera = true}) {
//     return availableCameras().then(
//       (cameras) {
//         if (frontCamera == true) {
//           final front = cameras.firstWhere(
//               (camera) => camera.lensDirection == CameraLensDirection.front);
//           cameraController = CameraController(
//             front,
//             ResolutionPreset.medium,
//             enableAudio: true,
//           );
//           cameraController.initialize().then(
//             (value) {
//               commit();
//               return;
//             },
//           );
//         } else {
//           final front = cameras.firstWhere(
//               (camera) => camera.lensDirection == CameraLensDirection.back);
//           cameraController = CameraController(
//             front,
//             ResolutionPreset.medium,
//             enableAudio: true,
//           );
//           cameraController.initialize().then(
//             (value) {
//               commit();
//               return;
//             },
//           );
//         }
//       },
//     );
//   }

//   void openCamera() {
//     initCamera().then((val) {
//       return cameraController;
//     });
//   }

//   Future<void> startRecord() {
//     return cameraController.prepareForVideoRecording().then((prepare) {
//       cameraController.startVideoRecording().then((start) {
//         value.videoPickerState = VideoPickerState.recording;
//         value.timer?.cancel();
//         value.duration = Duration(seconds: 10);
//         value.timer = Timer.periodic(Duration(seconds: 1), (val) {
//           value.duration = Duration(seconds: value.duration.inSeconds - 1);
//           value.durationStream.add(value.duration);
//         });
//         commit();
//         return;
//       });
//     });
//   }

//   Future<void> pauseRecordding() {
//     return cameraController.pauseVideoRecording().then((start) {
//       value.timer?.cancel();
//       value.videoPickerState = VideoPickerState.recordingPaused;
//       commit();
//       return;
//     });
//   }

//   Future<void> resumeRecordding() {
//     return cameraController.resumeVideoRecording().then((start) {
//       value.videoPickerState = VideoPickerState.recording;
//       commit();
//       return;
//     });
//   }

//   Future<void> stopRecordding() {
//     return cameraController.stopVideoRecording().then(
//       (file) {
//         value.timer?.cancel();
//         value.videoPickerState = VideoPickerState.recorded;
//         value.fileCamera = file;
//         value.fileVideo = File(file.path);
//         initVideoPlayer();
//         value.videoPlayerState = VideoPlayerState.playing;
//         commit();
//         return;
//       },
//     );
//   }

//   initVideoPlayer() {
//     videoPlayerController = VlcPlayerController.file(
//       value.fileVideo,
//       autoPlay: true,
//     );
//     value.videoPlayerState = VideoPlayerState.playing;
//     commit();
//   }

//   Future<void> remove() {
//     return value.fileVideo.delete().then(
//       (file) {
//         value.videoPickerState = VideoPickerState.empty;
//         commit();
//         return;
//       },
//     );
//   }

//   void pausePlayer() {
//     videoPlayerController.pause().then((player) {
//       value.videoPlayerState = VideoPlayerState.paused;
//       commit();
//     });
//   }

//   void playPlayer() {
//     if (videoPlayerController.value.isEnded) {
//       videoPlayerController.stop().then((player) {
//         videoPlayerController.play().then((player) {
//           value.videoPlayerState = VideoPlayerState.playing;
//           commit();
//         });
//       });
//     } else {
//       videoPlayerController.play().then((player) {
//         value.videoPlayerState = VideoPlayerState.playing;
//         commit();
//       });
//     }
//   }

//   void changeCamera() async {
//     if (cameraController != null) {
//       await cameraController.dispose();
//     }
//     if (frontCamera == true) {
//       initCamera(frontCamera: false).then((value) {
//         frontCamera = false;
//         commit();
//       });
//     } else {
//       initCamera(frontCamera: true).then((value) {
//         frontCamera = true;
//         commit();
//       });
//     }
//   }

//   void commit() {
//     notifyListeners();
//   }
// }

// class VideoPickerValue {
//   VideoPickerState videoPickerState = VideoPickerState.empty;
//   VideoPlayerState videoPlayerState = VideoPlayerState.finished;

//   Timer timer;
//   Duration duration;
//   StreamController<Duration> durationStream =
//       StreamController<Duration>.broadcast();
//   File fileVideo;
//   String fileBase64;
//   String fileBase64Compresed;
//   UriData fileUri;
//   int uploadedSize;
//   int fileSize;
//   String uploadedResponse;
//   String uploadedUrl;
//   XFile fileCamera;

//   double get percentageUpload {
//     return (fileSize == 0 ? 0 : ((uploadedSize ?? 0) / (fileSize ?? 0)) * 100)
//         .toDouble();
//   }
// }

// enum VideoPickerState {
//   recording,
//   recordingPaused,
//   recorded,
//   loaded,
//   onInitUpload,
//   onUpload,
//   uploaded,
//   uploadFiled,
//   empty,
//   error,
// }

// enum VideoPlayerState {
//   playing,
//   paused,
//   finished,
// }
