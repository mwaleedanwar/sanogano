import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class CustomChatGifWidget extends StatelessWidget {
  final String url;
  const CustomChatGifWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        child: OptimizedCacheImage(
          imageUrl: url,
          maxWidthDiskCache: 150,
          maxHeightDiskCache: 150,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 150,
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          imageBuilder: (context, imageProvider) {
            return Image(
              height: 150,
              width: 150,
              image: imageProvider,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}
