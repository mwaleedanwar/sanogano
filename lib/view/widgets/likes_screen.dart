import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class PostLikesPage extends GetView<PostController> {
  final String postId;
  final db = Database();
  final PostModel postModel;

  PostLikesPage(this.postId, this.postModel);
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          back: true,
          title: postModel.likeCount == 1
              ? '${postModel.likeCount} Like'
              : '${postModel.likeCount} Likes',
          iconButton: Container(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildSearchbar(),
              GetBuilder<PostController>(
                init: PostController(),
                initState: (_) {
                  searchController.addListener(() {
                    _.setState(() {});
                  });
                },
                builder: (controller) {
                  return RefreshIndicator(
                    onRefresh: () => 1.seconds.delay(),
                    child: StreamBuilder<String>(
                        initialData: '',
                        stream: Stream.value(searchController.text),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox();
                          }
                          print("=============");
                          print(snapshot.data);

                          return PaginateFirestore(
                              isLive: true,
                              onEmpty: Container(),
                              shrinkWrap: true,
                              itemBuilder: (_, docs, index) {
                                return UserHeaderTile(
                                  searchQuery: snapshot.data!,
                                  uid: docs[index].id,
                                  viewFollow: true,
                                  viewTrailing: true,
                                  onTap: () {},
                                );
                              },
                              query: controller.postLikes(postId),
                              itemBuilderType: PaginateBuilderType.listView);
                        }),
                  );
                },
              ),
            ],
          ),
        ));
  }

  Padding buildSearchbar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        controller: searchController,
        keyboardType: TextInputType.text,
        onChanged: (value) {},
        decoration: InputDecoration(
          fillColor: Colors.grey.withOpacity(0.25),
          filled: true,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey,
          ),
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey, letterSpacing: 0.5),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}
