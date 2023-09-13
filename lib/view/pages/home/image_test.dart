import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

import '../../../const/iconAssetStrings.dart';

class ImageTest extends StatefulWidget {
  const ImageTest({super.key});

  @override
  State<ImageTest> createState() => _ImageTestState();
}

class _ImageTestState extends State<ImageTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {});
      }),
      body: Center(
        //     child: OptimizedCacheImage(
        //   imageUrl:
        //       'https://firebasestorage.googleapis.com/v0/b/sanogano-bf152.appspot.com/o/Recipes%2Ffile1678471383453?alt=media&token=f8bff9c2-a8de-431b-9b9b-425bb516335a',
        //   height: Get.width * 0.3,
        //   width: Get.width,
        //   fit: BoxFit.cover,
        //   errorWidget: (context, url, error) =>
        //       SvgPicture.asset(cookbookIconAsset, fit: BoxFit.contain),
        // )
        child: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/sanogano-bf152.appspot.com/o/Recipes%2Ffile1678471383453?alt=media&token=f8bff9c2-a8de-431b-9b9b-425bb516335a',
          width: Get.width * 0.3,
          height: Get.height * 0.3,
          fit: BoxFit.cover,
          // errorWidget: (context, url, error) =>
          //     SvgPicture.asset(cookbookIconAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
