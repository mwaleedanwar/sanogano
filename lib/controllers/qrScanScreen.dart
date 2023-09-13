// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:sano_gano/const/iconAssetStrings.dart';
// import 'package:sano_gano/controllers/qrcodeController.dart';
// import 'package:sano_gano/controllers/user_controller.dart';
// import 'package:sano_gano/services/save_image_to_gallery.dart';
// import 'package:sano_gano/view/global/custom_appbar.dart';
// import 'package:sano_gano/view/global/space.dart';
// import 'package:screenshot/screenshot.dart';

// import '../services/user_database.dart';
// import '../view/pages/profile/profile.dart';

// class QRScanPage extends GetView<QRController> {
//   var scan = false;
//   ScreenshotController screenshotController = ScreenshotController();

//   bool fetching = false;
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<QRController>(
//       init: QRController(),
//       initState: (_) {},
//       builder: (_) {
//         return Scaffold(
//             appBar: CustomAppBar(
//               back: true,
//               title: !scan ? "QR Code" : "Scan QR Code",

//               // iconButton: TextButton(
//               //     onPressed: () {
//               //       screenshotController
//               //           .capture(delay: Duration(milliseconds: 10))
//               //           .then((capturedImage) async {
//               //         if (capturedImage != null) {
//               //           Directory appDocDir = await getTemporaryDirectory();
//               //           String appDocPath = appDocDir.path;
//               //           await File(appDocPath).create();
//               //           await File(appDocPath).writeAsBytes(capturedImage);
//               //           Get.snackbar("Saved", "QR Code saved to gallery");
//               //         }
//               //       }).catchError((onError) {
//               //         print(onError);
//               //       });
//               //     },
//               //     child: Text("Share")),
//             ),
//             body: scan
//                 ? SafeArea(
//                     child: Center(
//                         child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Spacer(),
//                       InkWell(
//                         onTap: () {
//                           scan = !scan;
//                           controller.update();
//                         },
//                         child: Container(
//                             width: Get.width * 0.8,
//                             height: Get.height * 0.4,
//                             child: controller.hasCameraPermission
//                                 ? MobileScanner(
//                                     allowDuplicates: false,
//                                     controller: MobileScannerController(
//                                       facing: CameraFacing.back,
//                                       formats: [BarcodeFormat.qrCode],
//                                       torchEnabled: true,
//                                     ),
//                                     onDetect: (barcode, args) async {
//                                       if (barcode.rawValue == null) {
//                                         debugPrint('Failed to scan Barcode');
//                                       } else {
//                                         final String result = barcode.rawValue!;
//                                         debugPrint('Barcode found! $result');

//                                         print(
//                                             "++++++++++++ RESULT ++++++++++++++++");

//                                         if ((result.length ==
//                                                 Get.find<UserController>()
//                                                     .currentUid
//                                                     .length) &&
//                                             !fetching) {
//                                           fetching = true;
//                                           var scannedUser = await UserDatabase()
//                                               .getUserNullable(result);
//                                           if (scannedUser != null)
//                                             await Get.to(ProfilePage(
//                                                 userID: scannedUser.id!));
//                                           fetching = false;
//                                         }
//                                       }
//                                     })
//                                 : Center(
//                                     child: Column(
//                                     children: [
//                                       Text("Permission Denied"),
//                                       addHeight(10),
//                                       TextButton(
//                                           onPressed: () =>
//                                               controller.getPermissions(),
//                                           child: Text('Grant Permission'))
//                                     ],
//                                   ))),
//                       ),
//                       Spacer(),
//                       InkWell(
//                           onTap: () {
//                             scan = !scan;
//                             controller.update();
//                           },
//                           child: gotoQRCodeDIcon.copyWith(size: 30)),
//                       addHeight(20)
//                     ],
//                   )))
//                 : SafeArea(
//                     child: Center(
//                         child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(left: Get.width * 0.025),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: TextButton(
//                             child: Text(
//                               'Save to Gallery',
//                               style: TextStyle(
//                                   color: Get.isDarkMode
//                                       ? Colors.white
//                                       : Colors.black),
//                             ),
//                             onPressed: () async {
//                               String uid =
//                                   Get.find<UserController>().userModel.id!;
//                               saveImageToGallery(uid: uid);
//                               // GallerySaver.saveImage();
//                             },
//                           ),
//                         ),
//                       ),
//                       Spacer(),
//                       Screenshot(
//                           controller: screenshotController,
//                           child: controller.qrCodeFromUID()),
//                       Spacer(),
//                       InkWell(
//                           onTap: () {
//                             scan = !scan;
//                             controller.update();
//                           },
//                           child: cameraIcon.copyWith(size: 30)),
//                       addHeight(20)
//                     ],
//                   ))));
//       },
//     );
//   }
// }

// Future<dynamic> ShowCapturedWidget(
//     BuildContext context, Uint8List? capturedImage) {
//   return showDialog(
//     useSafeArea: false,
//     context: context,
//     builder: (context) => Scaffold(
//       appBar: AppBar(
//         title: Text("Captured widget screenshot"),
//       ),
//       body: Center(
//           child: capturedImage != null
//               ? Image.memory(capturedImage)
//               : Container()),
//     ),
//   );
// }

// // _saved(File image) async {
// //   // final result = await ImageGallerySaver.save(image.readAsBytesSync());
// //   print("File Saved to Gallery");
// // }
// Future<void> writeToFile(ByteData data, String path) async {
//   final buffer = data.buffer;
//   await File(path)
//       .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes))
//       .whenComplete(() {
//     print('qr code saved to gallery');
//   });
// }

// // Future<String> createQrPicture(String qr) async {
// //   ...
// //   return path;
// // }



