// import 'dart:typed_data';

// import 'package:crop_your_image/crop_your_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sano_gano/view/global/custom_appbar.dart';

// class ImageCropperService extends StatelessWidget {
//   final Uint8List image;
//   final void Function(Uint8List) onCropped;

//   ImageCropperService({Key? key, required this.image, required this.onCropped})
//       : super(key: key);
//   final _cropController = CropController();
//   Rx<Uint8List?> croppedImage = Rx<Uint8List?>(null);
//   @override
//   //TODO not working
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         back: true,
//         iconButton: IconButton(
//             onPressed: () {
//               if (croppedImage.value == null) {
//                 _cropController.crop();
//                 2
//                     .seconds
//                     .delay()
//                     .then((value) => onCropped(croppedImage.value!));
//               } else {
//                 onCropped(croppedImage.value!);
//               }
//             },
//             icon: Icon(Icons.crop)),
//       ),
//       body: Crop(
//           image: image,
//           controller: _cropController,
//           onCropped: (val) {
//             croppedImage.value = val;
//           }),
//     );
//   }
// }
