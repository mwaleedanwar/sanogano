import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/iconAssetStrings.dart';
import '../../controllers/postController.dart';

class GalleryIconWidget extends StatelessWidget {
  GalleryIconWidget({
    Key? key,
  }) : super(key: key);
  PostController pc = Get.find<PostController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return pc.recentImage == null
          ? galleryDIcon.copyWith(size: 100)
          : ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.memory(
                pc.recentImage!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            );
    });
  }
}
