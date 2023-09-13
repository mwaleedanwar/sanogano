import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import 'package:sano_gano/controllers/commentsController.dart';
import 'package:sano_gano/models/commentModel.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class CommentLikesPage extends StatefulWidget {
  final CommentModel commentModel;
  const CommentLikesPage({
    Key? key,
    required this.commentModel,
  }) : super(key: key);

  @override
  _CommentLikesPageState createState() => _CommentLikesPageState();
}

class _CommentLikesPageState extends State<CommentLikesPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          back: true,
          title: widget.commentModel.commentLikes == 1
              ? '${widget.commentModel.commentLikes} Like'
              : '${widget.commentModel.commentLikes} Likes',
          iconButton: Container(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildSearchbar(),
              GetBuilder<CommentsController>(
                init: CommentsController(),
                initState: (_) {},
                builder: (controller) {
                  return RefreshIndicator(
                    onRefresh: () => 1.seconds.delay(),
                    child: StreamBuilder<String>(
                        stream: Stream.value(val),
                        builder: (context, snapshot) {
                          return PaginateFirestore(
                              onEmpty: Container(),
                              isLive: true,
                              shrinkWrap: true,
                              itemBuilder: (_, docs, index) {
                                return UserHeaderTile(
                                  uid: docs[index].id,
                                  viewFollow: true,
                                  viewTrailing: true,
                                  searchQuery: snapshot.data!,
                                  onTap: () {},
                                );
                              },
                              query: widget.commentModel.ref!
                                  .collection('likedBy')
                                  .orderBy('timestamp'),
                              itemBuilderType: PaginateBuilderType.listView);
                        }),
                  );
                },
              ),
            ],
          ),
        ));
  }

  String val = '';

  Padding buildSearchbar() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        controller: searchController,
        keyboardType: TextInputType.text,
        onChanged: (value) {
          //  print(value);
          setState(() {
            val = value;
          });
        },
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
