// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/iconAssetStrings.dart';
import 'gallery_icon_widget.dart';

class PostFooter extends StatelessWidget {
  VoidCallback onTapGallery;
  VoidCallback onTapCamera;
  VoidCallback onTapGif;
  PostFooter(
      {Key? key,
      required this.onTapGallery,
      required this.onTapCamera,
      required this.onTapGif})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 30, 15, Get.height * 0.09),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onTapGallery,
                  icon: GalleryIconWidget(
                    key: Key("Gallery-Icon-Widget"),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: onTapCamera,
                  icon: cameraDIcon.copyWith(size: 100),
                ),
                // * Videos removed for now
                // Spacer(),
                // IconButton(
                //   onPressed: () async {
                //     var result = await ImagePickerServices.getVideoFromCamera();
                //     if (result != null) {
                //       attachedFiles.add(result);
                //       imageMode = false;

                //       videoThumbnail =
                //           await ImagePickerServices.getImageThumbnail(
                //               result.path);
                //       setState(() {});
                //     }
                //   },
                //   icon: recordVideoIcon.copyWith(size: 100),
                // ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: InkWell(
                    onTap: onTapGif,
                    child: Icon(
                      Icons.gif_rounded,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
