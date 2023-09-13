import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ImageShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: Get.height * 0.6,
      width: Get.width,
      child: Shimmer.fromColors(
        baseColor: Colors.black45,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(15),
                ),
                height: Get.height * 0.4,
                width: Get.width,
                child: Text(""),
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class PostShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: Get.height * 0.6,
      width: Get.width,
      child: Shimmer.fromColors(
        baseColor: Colors.black45,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[100],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width * 0.4,
                        child: Text(""),
                        color: Colors.black45,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: Get.width * 0.2,
                        child: Text(""),
                        color: Colors.black45,
                      ),
                    ],
                  )
                ],
              ),
            ),
            // ListTile(
            //   leading: CircleAvatar(
            //     backgroundColor: Colors.grey[100],
            //   ),
            //   title: Container(
            //     width: 100,
            //     child: Text(""),
            //     color: Colors.black45,
            //   ),
            //   // subtitle: Container(
            //   //   width: 50,
            //   //   child: Text(""),
            //   //   color: Colors.black45,
            //   // ),
            // ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(15),
                ),
                height: Get.height * 0.4,
                width: Get.width,
                child: Text(""),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            // Container(
            //   height: Get.width * 0.05,
            //   width: Get.width * 0.3,
            //   child: Text(""),
            //   color: Colors.black45,
            // ),
          ],
        ),
      ),
    );
  }
}

class CommentShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: Get.height * 0.6,
      width: Get.width,
      child: Shimmer.fromColors(
        baseColor: Colors.black45,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[100],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width * 0.4,
                        child: Text(""),
                        color: Colors.black45,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: Get.width * 0.2,
                        child: Text(""),
                        color: Colors.black45,
                      ),
                    ],
                  )
                ],
              ),
            ),
            // ListTile(
            //   leading: CircleAvatar(
            //     backgroundColor: Colors.grey[100],
            //   ),
            //   title: Container(
            //     width: 100,
            //     child: Text(""),
            //     color: Colors.black45,
            //   ),
            //   // subtitle: Container(
            //   //   width: 50,
            //   //   child: Text(""),
            //   //   color: Colors.black45,
            //   // ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.black45,
            //       borderRadius: BorderRadius.circular(15),
            //     ),
            //     height: Get.height * 0.4,
            //     width: Get.width,
            //     child: Text(""),
            //   ),
            // ),
            // SizedBox(
            //   height: 5,
            // ),
            // Container(
            //   height: Get.width * 0.05,
            //   width: Get.width * 0.3,
            //   child: Text(""),
            //   color: Colors.black45,
            // ),
          ],
        ),
      ),
    );
  }
}
