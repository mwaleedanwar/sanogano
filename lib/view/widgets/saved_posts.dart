import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/custom_widgets/custom_paginate_firestore.dart';
import 'package:sano_gano/view/widgets/popup_menu_builder.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';

class SavedPosts extends StatefulWidget {
  final String uid;

  const SavedPosts({Key? key, required this.uid}) : super(key: key);

  @override
  _SavedPostsState createState() => _SavedPostsState();
}

class _SavedPostsState extends State<SavedPosts> {
  var db = Database();
  var userId = Get.find<AuthController>().user!.uid;
  var showAll = false;
  List<PostModel?> posts = [];
  bool get isMe => userId == widget.uid;
  @override
  Widget build(BuildContext context) {
    if (widget.uid != null) {
      if (widget.uid == userId) {
        showAll = true;
      }
    }
    return Scaffold(
        appBar: CustomAppBar(
          back: true,
          title: "Saved",
          iconButton: isMe
              ? buildPopupMenu([
                  PopupItem(
                    callback: () {
                      Get.defaultDialog(
                          title: "Alert",
                          content: Text("Unsave All Posts?"),
                          onConfirm: () async {
                            Get.back();
                            PostController postController =
                                Get.find<PostController>();
                            showLoading(loadingText: "Unsaving ...");
                            await Database()
                                .savedPosts(widget.uid)
                                .get()
                                .then((value) async {
                              for (var element in value.docs) {
                                await postController.unsavePost(element.id);
                              }
                            }).then((value) => Get.back());
                            // for (var item in posts) {
                            //   await Get.find<PostController>()
                            //       .unsavePost(item!.postId)
                            //       .then((value) => Get.back());
                            //   setState(() {});
                            //   Get.back();
                            // }
                          },
                          textConfirm: "Unsave All",
                          buttonColor: Colors.transparent,
                          confirmTextColor: Colors.red,
                          textCancel: "Cancel",
                          cancelTextColor:
                              Get.isDarkMode ? Colors.white : Colors.black,
                          onCancel: () {});
                      // Get.defaultDialog(
                      //   cancel: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: InkWell(
                      //         onTap: () => Get.back(), child: Text("Cancel")),
                      //   ),
                      //   confirm: InkWell(
                      //     onTap: () async {
                      //       for (var item in posts) {
                      //         await Get.find<PostController>()
                      //             .unsavePost(item.postId)
                      //             .then((value) => Get.back());
                      //         setState(() {});
                      //       }
                      //     },
                      //     child: Container(
                      //         color: Colors.red,
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Text(
                      //             "Okay",
                      //             style: TextStyle(color: Colors.white),
                      //           ),
                      //         )),
                      //   ),
                      //   title: "Are you sure?",
                      //   content: Text("This cannot be undone."),
                      // );
                    },
                    index: 0,
                    title: "Unsave All",
                  )
                ])

              // TextButton(
              //     onPressed: () {
              //       Get.defaultDialog(
              //         onConfirm: () async {
              //           for (var item in posts) {
              //             await Get.find<PostController>()
              //                 .unsavePost(item.postId);
              //           }
              //         },
              //         onCancel: () {},
              //         cancel: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text("Cancel"),
              //         ),
              //         confirm: Container(
              //             color: Colors.red,
              //             child: Padding(
              //               padding: const EdgeInsets.all(8.0),
              //               child: Text(
              //                 "Okay",
              //                 style: TextStyle(color: Colors.white),
              //               ),
              //             )),
              //         title: "Are you sure?",
              //         content: Text("This cannot be undone."),
              //       );
              //     },
              //     child: Text(
              //       "Clear all saved",
              //       style: blackText,
              //     ))
              : null,
        ),
        body: GetBuilder<PostController>(
          // init: PostController(),
          initState: (_) {},
          builder: (controller) {
            return CustomPaginateFirestore(
              bottomLoader: SizedBox(),

              initialLoader: Center(child: SizedBox()),
              onEmpty: SizedBox(),
              shrinkWrap: true,
              //item builder type is compulsory.
              itemBuilder: (_, docs, index) {
                return PostWidget(
                  postId: docs[index].id,
                );
              },
              // orderBy is compulsory to enable pagination
              query: isMe
                  ? Database()
                      .savedPosts(widget.uid)
                      .orderBy('timestamp', descending: true)
                  : Database()
                      .savedPosts(widget.uid)
                      .where('isPublic', isEqualTo: true)
                      .orderBy('timestamp', descending: true),
              //Change types accordingly
              itemBuilderType: PaginateBuilderType.listView,
              // to fetch real-time data
              isLive: true,
            );
            // return FutureBuilder<List<PostModel?>?>(
            //     future: controller.getAllSavedPosts(uid: widget.uid),
            //     builder: (context, snapshot) {
            //       if (!snapshot.hasData)
            //         return Center(
            //           child: Container(),
            //         );
            //       posts = snapshot.data!;
            //       return ListView.builder(
            //         reverse: false,
            //         itemCount: snapshot.data!.length,
            //         itemBuilder: (BuildContext context, int index) {
            //           if (!snapshot.hasData)
            //             return Center(
            //               child: CircularProgressIndicator(),
            //             );
            //           return PostWidget(
            //             postModel: snapshot.data![index],
            //           );
            //         },
            //       );
            //     });
          },
        ));
  }
}
