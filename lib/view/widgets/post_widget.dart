import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/commentsController.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/utils.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/utils/globalHelperMethods.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/comments_page.dart';
import 'package:sano_gano/view/widgets/likes_screen.dart';
import 'package:sano_gano/view/widgets/parse/matchers.dart';
import 'package:sano_gano/view/widgets/post_menu_options.dart';
import 'package:sano_gano/view/widgets/recipe_controller.dart';
import 'package:sano_gano/view/widgets/recipe_screen.dart';
import 'package:sano_gano/view/widgets/show_post_widget.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';
import 'package:sano_gano/view/widgets/video_player/app/chewie.dart';
import 'package:sano_gano/view/widgets/view_recipe.dart';
import 'package:sano_gano/view/widgets/view_workout.dart';
import 'package:sano_gano/view/widgets/workout_controller.dart';
import 'package:sano_gano/view/widgets/workout_screen.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../../const/colors.dart';
import '../../models/post_enriched_model.dart';
import '../pages/chat/sending_post_screen.dart';
import 'time_manager_strings.dart';

class PostWidget extends StatefulWidget {
  final PostModel? postModel;
  final bool thumbnailOnly;
  final bool miniMode;
  final String postId;
  final bool dontGoToUser;
  final bool disableOnLongPress;
  final int? popularityIndex;
  const PostWidget(
      {Key? key,
      this.postModel,
      this.thumbnailOnly = false,
      required this.postId,
      this.dontGoToUser = false,
      this.disableOnLongPress = false,
      this.popularityIndex,
      this.miniMode = false})
      : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  PostModel? get postModel => post?.post;
  EnrichedPostModel? post;

  var currentUser = Get.find<UserController>().userModel;

  var sc = Get.find<StreamFeedController>();
  var isLiked = false;
  var isSaved = false;

  @override
  void initState() {
    // log(widget.postModel.toString());
    // TODO: implement initState
    super.initState();
    getPost();
  }

  var loaded = false;
  UserModel? owner;
  Future<void> getPost() async {
    EnrichedPostModel? _post;
    _post = await PostController().getPostEnriched(widget.postId);
    if (_post != null) {
      this.post = _post;
      this.isLiked = _post.isLiked;
      this.isSaved = _post.isSaved;
      this.owner = _post.owner;
    }
    if (mounted)
      setState(() {
        loaded = true;
      });

    return;
  }

  var hidden = false;
  @override
  void didUpdateWidget(PostWidget oldWidget) {
    //log("yes dependencies have changed, old id was ${oldWidget.postModel?.postId} new id is ${widget.postModel?.postId}");
    if (oldWidget.postId != widget.postId) {
      setState(() {
        if (postModel != null) postModel!.postId = widget.postId;
      });
      getPost();
    }
    if (oldWidget.postId != widget.postId) {
      setState(() {});
    }
    if (oldWidget.postModel?.postId != widget.postModel?.postId) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  PostController? controller;
  @override
  Widget build(BuildContext context) {
    if (!loaded) return Container();
    return buildPostBody();
  }

  EnrichedPostModel? cache;

  var db = Database();
  Widget buildPostBody() {
    return GetBuilder<PostController>(
      init: PostController(),
      initState: (_) {},
      builder: (postController) {
        if (hidden) return Container();
        if (postModel == null) return Container();
        controller = postController;
        if (widget.thumbnailOnly)
          return OptimizedCacheImage(
            imageUrl: postModel!.postAttachmentUrl!,
            height: Get.width * 0.3,
            width: Get.width * 0.3,
            fit: BoxFit.cover,
          );
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //  likedRecipeDIcon.copyWith(size: 100),
              UserHeaderTile(
                userModel: owner,
                disableProfileOpening: widget.dontGoToUser,
                onTap: () {},
                isDense: true,
                profileAvatarSize: 18,
                uid: postModel!.ownerId!,
                gapAfterAvatar: 5,
                noSubtitle: false,
                subtitle: Text(//, locale: 'en_short'
                    getTime(postModel!.timestamp!)),
                viewTrailing: true,
                trailing: (widget.miniMode)
                    ? null
                    : Padding(
                        padding: EdgeInsets.only(
                            right: widget.popularityIndex != null
                                ? Get.width * 0.025
                                : Get.width * 0.005),
                        child: widget.popularityIndex != null
                            ? AutoSizeText(
                                squeezeNumbers(widget.popularityIndex)!,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                    color: ThemeColor().getLeaderBoardColor(
                                        widget.popularityIndex!),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15))
                            : buildPostMenuOptions(postModel!,
                                postModel!.ownerId == currentUser.id,
                                onSelectCallback: (selection) {
                                postController.postMenuAction(
                                  selection,
                                  postModel!,
                                  postActionCallback: () {
                                    print(selection);
                                    print("post deleted");
                                  },
                                  onDelete: () {
                                    hidden = true;
                                    controller!.update();
                                  },
                                );
                              }),
                      ),
              ),
              if (!postModel!.isTextPost)
                Padding(
                  padding: postModel!.postCaption!.isNotEmpty
                      ? EdgeInsets.only(bottom: 8)
                      : EdgeInsets.zero,
                  child: buildPostText(),
                ),
              //  Text("post body"),
              //  buildPostMediaBody(),

              widget.disableOnLongPress
                  ? buildPostMediaBody()
                  : GestureDetector(
                      onDoubleTap: () {
                        likePost();
                      },
                      onLongPress: () async {
                        if (postModel!.hasText) {
                          await Clipboard.setData(
                              ClipboardData(text: postModel!.postCaption));

                          Fluttertoast.showToast(
                              msg: "Copied to clipboard",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: buildPostMediaBody()),
              SizedBox(
                height: 5,
              ),
              // TapDebouncer(
              //   onTap: () async {
              //     return;
              //   }, //async => await togglelikePost(),
              //   builder: (context, onTap) => GestureDetector(
              //       onLongPress: ()async {
              //         if (postModel.hasText)
              //           await Clipboard.setData(
              //               ClipboardData(text: postModel.postCaption));
              //       },
              //       onDoubleTap: onTap,
              //       child: buildPostMediaBody()),
              // ),
              if (!widget.miniMode) buildPostFooter(() async {}),
              // if (!isNullOrBlank(postModel.attachedRecipeId))
              //   TextButton(
              //     onPressed: goToRecipe,
              //     child: Text("Go to Recipe"),
              //   ),
              // if (!isNullOrBlank(postModel.attachedWorkoutId))
              //   TextButton(
              //     onPressed: goToWorkout,
              //     child: Text("Go to Workout"),
              //   ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPostMediaBody() {
    //  print("//////////");
    //  print(postModel.hasVideo);
    if (postModel!.isTextPost) {
      // print("text post");
      return buildPostText();
    }
    if (postModel!.hasGif) {
      return Container(child: GiphyCustomWidget(gif: postModel!.gif!));
      // return Padding(
      //   padding: EdgeInsets.symmetric(horizontal: Get.width * 0.040),
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.all(Radius.circular(17)),
      //     child: Container(
      //       // constraints: BoxConstraints(
      //       //   maxHeight: Get.width,
      //       // ),
      //       child: GiphyCustomWidget(gif: postModel!.gif!),
      //       //  Image.network(
      //       //   postModel!.gif!.images!.original!.url,
      //       //   loadingBuilder: (context, child, loadingProgress) =>
      //       //       Text("loading gif"),
      //       //   errorBuilder: (context, error, stackTrace) =>
      //       //       Icon(Icons.error_outline),
      //       //   // headers: {'accept': 'image/*'},
      //       //   fit: BoxFit.contain,
      //       //   // height: postModel!.gif!.isSticker == 1 ? 100 : Get.height * 0.4,
      //       //   width: Get.width,
      //       // ),
      //     ),
      //   ),
      // );
    }

    if (postModel!.hasVideo) {
      // log("thumbnail url is ${postModel!.thumbnailUrl}");
      return GestureDetector(
        onTap: () {
          Get.to(ChewieDemo(
            title: "",
            videoUrl: postModel!.postAttachmentUrl!,
          ));
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.040),
              child: AspectRatio(
                aspectRatio: postModel?.videoAspectRatio ?? 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  child: Container(
                      height: Get.height * 0.3,
                      child: OptimizedCacheImage(
                        fadeInCurve: Curves.easeIn,
                        imageUrl: postModel!.thumbnailUrl!,
                        height: Get.height * 0.3,
                        errorWidget: (context, url, error) =>
                            Text(error.toString()),
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
            Center(
              child: playDIcon.copyWith(
                  color: Colors.white.withOpacity(0.5), size: Get.width * 0.1),
              // Container(
              //   decoration: BoxDecoration(
              //       color: Get.isDarkMode ? Colors.black : Colors.white,
              //       shape: BoxShape.circle,
              //       border: Border.all(width: 1)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(1.0),
              //     child:
              //         playDIcon.copyWith(color: Colors.white.withOpacity(0.5)),
              //   ),
              // ),
            )
          ],
        ),
      );
    }

    // print("post is video ${postModel.hasVideo}");
    if (!postModel!.hasVideo || postModel!.gif != null) {
      //   print("building post image");
      // print("has gif ${postModel.hasGif}");
      // log(postModel.toMap().toString());
      // print(postModel.gif?.toJson);
      return ZoomOverlay(
        minScale: 0.5, // Optional
        maxScale: 3.0, // Optional
        twoTouchOnly: true,
        child: GestureDetector(
          onTap: () {
            if (postModel!.taggedUsers!.isNotEmpty) {
              Get.bottomSheet(Material(
                color: Get.isDarkMode ? Colors.black : Colors.white,
                child: Scaffold(
                  appBar: CustomAppBar(
                    back: false,
                    title: "In This Photo",
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: postModel!.taggedUsers!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return UserHeaderTile(
                              uid: postModel!.taggedUsers![index]!,
                              viewFollow: true,
                              viewTrailing: true,
                              onTap: () {},
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ));
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.040),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(17)),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.6,
                ),
                child: OptimizedCacheImage(
                  imageUrl: postModel!.postAttachmentUrl!,
                  placeholder: (_, __) => Container(
                    height: Get.height * 0.3,
                  ),
                  // height: Get.height * 0.5,
                  errorWidget: (context, url, error) => Text("Image Error"),
                  width: Get.width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Text("error");
    // Padding(
    //         padding: EdgeInsets.symmetric(horizontal: Get.width * 0.040),
    //         child: ClipRRect(
    //           borderRadius: BorderRadius.all(Radius.circular(17)),
    //           child: Container(
    //             height: Get.height * 0.5,
    //             width: Get.width,
    //             child: Text("asd"),
    //             //  FutureBuilder(
    //             //   future: ImagePickerServices.getImageThumbnail(
    //             //       postModel.postAttachmentUrl),
    //             //   builder: (BuildContext context, AsyncSnapshot snapshot) {
    //             //     if (!snapshot.hasData)
    //             //       return Container(
    //             //         height: Get.height * 0.4,
    //             //         child: CircularProgressIndicator.adaptive(),
    //             //       );

    //             //     return Image.file(snapshot.data);
    //             //   },
    //             // ),
    //           ),
    //         ),
    //       )
  }

  var liked = false;
  Widget getLikeIcon(bool likeStatus) {
    if (likeStatus) {
      if (!isNullOrBlank(postModel!.attachedRecipeId)) return likedRecipeDIcon;
      if (!isNullOrBlank(postModel!.attachedWorkoutId))
        return likedWorkoutDIcon;
      return likedDIcon;
    } else {
      if (!isNullOrBlank(postModel!.attachedRecipeId)) return likeRecipeDIcon;
      if (!isNullOrBlank(postModel!.attachedWorkoutId)) return likeWorkoutDIcon;
      return likeDIcon;
    }
  }

  Function likePost = () {};
  Widget buildPostFooter(Function fetchPost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: Get.width * 0.04, right: Get.width * 0.035),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LikeButton(
                initialState: isLiked,
                postModel: postModel!,
                controller: controller!,
                postframeCallback: (fun) {
                  likePost = fun;
                },
              ),

              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      await Get.to(() => CommentPage(
                            showKeyboard: true,
                            postId: postModel!.postId,
                            postModel: postModel!,
                            onCommentCountChanged: (newcount) {
                              postModel!.totalCommentCount = newcount;
                            },
                          ));
                      setState(() {});
                      fetchPost();
                    },
                    child: commentDIcon,
                  ),
                  SizedBox(
                    width: Get.width * 0.035,
                  ),
                  StreamBuilder<int>(
                      stream:
                          CommentsController().totalCommentCount(widget.postId),
                      builder: (context, snapshot) {
                        postModel!.totalCommentCount =
                            snapshot.data ?? postModel!.totalCommentCount;
                        return InkWell(
                            onTap: () async {
                              await Get.to(() => CommentPage(
                                    showKeyboard: false,
                                    postId: postModel!.postId,
                                    postModel: postModel!,
                                    onCommentCountChanged: (newcount) {
                                      postModel!.totalCommentCount = newcount;
                                    },
                                  ));
                              setState(() {});
                              fetchPost();
                            },
                            child: postModel!.totalCommentCount! > 0
                                ? Text(
                                    postModel!.totalCommentCount.toString(),
                                    style: TextStyle(
                                        color: Get.isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  )
                                : Text(''));
                      }),
                ],
              ),
              // TextButton.icon(
              //   onPressed: () async {
              //     await Get.to(() => CommentPage(
              //           postId: postModel.postId,
              //           postModel: postModel,
              //         ));
              //     fetchPost();
              //   },
              //   icon: commentDIcon,
              //   label: Padding(
              //     padding: EdgeInsets.only(
              //       left: Get.width * 0.035,
              //     ),
              //     child: Text(
              //       postModel.commentCount.toString(),
              //       style: TextStyle(
              //           color: Get.isDarkMode ? Colors.white : Colors.black),
              //     ),
              //   ),
              // ),
              TextButton(
                onPressed: () {
                  Get.to(
                      () => SendingPostScreen(
                            postModel: postModel!,
                          ),
                      transition: Transition.cupertino,
                      popGesture: true);
                },
                child: sendDIcon,
              ),
              SaveWidget(
                  initialState: isSaved,
                  controller: controller!,
                  postModel: postModel!)
              // Container(
              //   child: StreamBuilder<bool>(
              //       stream: controller.isSaved(postModel.postId).asStream(),
              //       builder: (context, snapshot) {
              //         return InkWell(
              //           onTap: () async {
              //             await controller.toggleSave(postModel);
              //             setState(() {});
              //           },
              //           child: snapshot?.data ?? false ? savedDIcon : saveDIcon,
              //         );
              //       }),
              // ),
            ],
          ),
        ),
        // if (!postModel.isTextPost) buildPostText(),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Text(
        //     timeago.format(postModel.timestamp ?? DateTime.now(), locale: 'en'),
        //     style: TextStyle(fontSize: 12),
        //   ),
        // ),
        if (!isNullOrBlank(postModel!.attachedRecipeId))
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: Get.width * 0.04),
              child: InkWell(
                onTap: () async {
                  Get.put(RecipeController());
                  var controller = Get.find<RecipeController>();
                  var recipe =
                      await controller.getRecipe(postModel!.attachedRecipeId!);
                  Get.to(() => ViewRecipe(
                        recipeModel: recipe,
                      ));
                },
                child: Text(
                  "Go to Recipe",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: standardContrastColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        if (!isNullOrBlank(postModel!.attachedWorkoutId!))
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: Get.width * 0.04),
              child: InkWell(
                onTap: () async {
                  Get.put(WorkoutController());
                  var controller = Get.find<WorkoutController>();
                  var workout = await controller
                      .getWorkout(postModel!.attachedWorkoutId!);
                  Get.to(() => ViewWorkout(
                        workoutModel: workout!,
                      ));
                },
                child: Text("Go to Workout",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: standardContrastColor,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        if (!isNullOrBlank(postModel!.attachedWorkoutId) ||
            !isNullOrBlank(postModel!.attachedRecipeId))
          SizedBox(
            height: 8,
          ),
        // Divider(),
      ],
    );
  }

  Widget buildPostText() {
    return postModel!.postCaption!.isNotEmpty
        ? Padding(
            padding: EdgeInsets.fromLTRB(
                widget.miniMode ? Get.width * 0.05 : 0, 0, 8, 0),
            child: Container(
              // constraints: BoxConstraints(
              //   minHeight: Get.height * 0.04,
              // ),
              width: Get.width * 0.9,
              child: TextParser(
                postModel!.postCaption!,
                isTextPost: postModel!.isTextPost,
              ),
              // ParsedText(
              //   selectable: true,
              //   alignment: TextAlign.start,
              //   text: postModel.postCaption,
              //   overflow: TextOverflow.clip,
              //  style: getTextStyle(),
              //   parse: [
              //     MatchText(
              //       onTap: (value) => launch(value),
              //       // canLaunch(value).then((s) =>launch(value) ),
              //       type: ParsedType.URL,
              //       style: TextStyle(
              //         color:
              //             Get.isDarkMode ? Colors.blue[400] : Colors.blue[900],
              //       ),
              //     ),
              //     MatchText(
              //       onTap: (value) => Get.to(() => HashtagsScreen(value)),
              //       pattern: r"\B(\#[a-zA-Z]+\b)(?!;)",
              //       style: TextStyle(
              //         color:
              //             Get.isDarkMode ? Colors.blue[400] : Colors.blue[900],
              //       ),
              //     ),
              //     MatchText(
              //       type: ParsedType.CUSTOM,
              //       onTap: (value) async {
              //         print(value);
              //         print(value.substring(1, value.length));
              //         var id = await UserDatabase()
              //             .getUserIDFromUsername(value.substring(1));
              //         print(id);
              //         if (id != null) Get.to(() => ProfilePage(id));
              //       },
              //       pattern:
              //           r"(?=.{8,20}$)(?![_.])(?!.*[_.]{2})\@[a-zA-Z0-9._]+(?<![_.])", // r"\B(\@[a-zA-Z0-9]+\b)(?!;)",
              //       style: TextStyle(
              //         color:
              //             Get.isDarkMode ? Colors.blue[400] : Colors.blue[900],
              //       ),
              //     )
              //   ],
              //   regexOptions: RegexOptions(caseSensitive: false),
              // ),
            ),
          )
        : Container();
  }

  TextStyle getTextStyle() {
    var color = Get.isDarkMode ? Colors.white : Colors.black;
    if (postModel!.isTextPost) return TextStyle(color: color, fontSize: 16);
    return TextStyle(color: color, fontSize: 16);
  }

  Future<void> togglelikePost() async {
    print("toggle like post");
    // bool result = !liked;
    // setState(() {
    //   if (result) {
    //     liked = true;
    //     postModel.likeCount++;
    //   } else {
    //     liked = false;
    //     postModel.likeCount--;
    //   }
    // });
    //result =
    await controller!.toggleLike(postModel!);
    controller!.update();
    //print(result);
  }

  void goToRecipe() {
    Get.to(() => RecipeScreen());
  }

  void goToWorkout() {
    Get.to(() => WorkoutScreen());
  }

  // void _launchURL(String url) async =>
  //     await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}

// class LikeButton extends StatelessWidget {
//   final PostModel postModel;
//   final bool initialState;
//   final PostController controller;
//   LikeButton(
//       {Key? key,
//       required this.initialState,
//       required this.postModel,
//       required this.controller})
//       : super(key: key);
//   RxBool isLiked = false.obs;
//   RxInt likeCount = 0.obs;
//   var uc = Get.find<UserController>();
//   LikeData? likeData;
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<LikeData>(
//       stream: controller.getLikeData(postModel.postId),
//       initialData: likeData,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           log("stream called");
//           likeData = snapshot.data;
//           likeCount.value = likeData!.likeCount;
//           isLiked.value = likeData!.isLiked;
//         }
//         return Row(
//           children: [
//             InkWell(
//               onTap: () {
//                 isLiked.value = !isLiked.value;

//                 if (isLiked.value == true) {
//                   likeCount.value++;
//                 } else if (isLiked.value == false) {
//                   likeCount.value--;
//                 }
//                 EasyDebounce.debounce(
//                     'like-debouncer', // <-- An ID for this particular debouncer
//                     Duration(seconds: 2), // <-- The debounce duration
//                     () => togglelikePost() // <-- The target method
//                     );
//               },
//               child: getLikeIcon(isLiked.value),
//             ),
//             SizedBox(
//               width: Get.width * 0.035,
//             ),
//             InkWell(
//               onTap: () {
//                 Get.to(() => PostLikesPage(postModel.postId, postModel));
//               },
//               child: likeCount.value > 0
//                   ? Text(likeCount.value.toString())
//                   : Text(
//                       '1',
//                       style: TextStyle(color: Colors.transparent),
//                     ),
//             ),
//           ],
//         );
//       },
//     );

//     // likeCount.value = postModel.likeCount!;
//     // temp.value = initialState;
//     // return Row(
//     //   children: [
//     //     Obx(() => InkWell(
//     //           onTap: () {
//     //             temp.value = !temp.value;

//     //             if (temp.value == true) {
//     //               likeCount.value++;
//     //             } else if (temp.value == false) {
//     //               likeCount.value--;
//     //             }
//     //             EasyDebounce.debounce(
//     //                 'like-debouncer', // <-- An ID for this particular debouncer
//     //                 Duration(seconds: 2), // <-- The debounce duration
//     //                 () => togglelikePost(temp.value, postModel.likeCount!,
//     //                     likeCount.value) // <-- The target method
//     //                 );
//     //           },
//     //           child: getLikeIcon(temp.value),
//     //         )),
//     //     SizedBox(
//     //       width: Get.width * 0.035,
//     //     ),
//     //     Obx(() => InkWell(
//     //           onTap: () {
//     //             Get.to(() => PostLikesPage(postModel.postId, postModel));
//     //           },
//     //           child: likeCount.value > 0
//     //               ? Text(likeCount.value.toString())
//     //               : Text(
//     //                   '1',
//     //                   style: TextStyle(color: Colors.transparent),
//     //                 ),
//     //         )),
//     //   ],
//     // );
//   }

//   Future<void> togglelikePost() async {
//     await controller.toggleLikeWithInitialState(postModel, isLiked.value);
//     return;
//   }

class LikeButton extends StatefulWidget {
  final PostModel postModel;
  final bool initialState;
  final PostController controller;
  final Function(Function) postframeCallback;
  LikeButton({
    Key? key,
    required this.initialState,
    required this.postModel,
    required this.controller,
    required this.postframeCallback,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  RxBool temp = false.obs;

  RxInt likeCount = 0.obs;

  var uc = Get.find<UserController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    likeCount.value = widget.postModel.likeCount!;
    temp.value = widget.initialState;
  }

  void onTap() {
    temp.value = !temp.value;

    if (temp.value == true) {
      likeCount.value++;
    } else if (temp.value == false) {
      likeCount.value--;
    }
    EasyDebounce.debounce(
        'like-debouncer', // <-- An ID for this particular debouncer
        Duration(milliseconds: 500), // <-- The debounce duration
        () => togglelikePost(temp.value, widget.postModel.likeCount!,
            likeCount.value) // <-- The target method
        );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.postframeCallback(onTap);
    });

    return Row(
      children: [
        Obx(() => InkWell(
              onTap: () {
                print(widget.postModel.postId);
                print(widget.postModel.popularity);
                onTap();
              },
              child: getLikeIcon(temp.value),
            )),
        SizedBox(
          width: Get.width * 0.035,
        ),
        Obx(() => InkWell(
              onTap: () {
                Get.to(() =>
                    PostLikesPage(widget.postModel.postId, widget.postModel));
              },
              child: likeCount.value > 0
                  ? Text(likeCount.value.toString())
                  : Text(
                      '1',
                      style: TextStyle(color: Colors.transparent),
                    ),
            )),
      ],
    );
  }

  Future<void> togglelikePost(
      bool liked, int previousLikes, int currentlikes) async {
    bool result = liked;
    if (previousLikes != currentlikes) {
      if (result) {
        liked = true;
        widget.postModel.likeCount = widget.postModel.likeCount! + 1;
      } else {
        liked = false;
        widget.postModel.likeCount = widget.postModel.likeCount! - 1;
      }

      result = await widget.controller.toggleLike(widget.postModel);
    }

    print(result);
    print(widget.postModel.likeCount);
  }

  Widget getLikeIcon(bool likeStatus) {
    if (likeStatus) {
      if (!isNullOrBlank(widget.postModel.attachedRecipeId))
        return likedRecipeDIcon;
      if (!isNullOrBlank(widget.postModel.attachedWorkoutId))
        return likedWorkoutDIcon;
      return likedDIcon;
    } else {
      if (!isNullOrBlank(widget.postModel.attachedRecipeId))
        return likeRecipeDIcon;
      if (!isNullOrBlank(widget.postModel.attachedWorkoutId))
        return likeWorkoutDIcon;
      return likeDIcon;
    }
  }
}

// class LikeButton extends Staet {
//   final PostModel postModel;
//   final controller;
//   const LikeButton(
//       {Key key, @required this.postModel, @required this.controller})
//       : super(key: key);

// class _LikeButtonState extends State<LikeButton> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         FutureBuilder<bool>(
//           initialData: false,
//           future: widget.controller.isLiked(widget.postModel.postId),
//           builder: (context, snapshot) {
//             var temp = snapshot.data;
//             return InkWell(
//               onTap: () {
//                 temp = !temp;
//                 togglelikePost();
//               },
//               child: getLikeIcon(temp),
//             );
//           },
//         ),
//         SizedBox(
//           width: Get.width * 0.035,
//         ),
//         InkWell(
//             onTap: () {
//               Get.to(() =>
//                   PostLikesPage(widget.postModel.postId, widget.postModel));
//             },
//             child: widget.postModel.likeCount > 0
//                 ? Text(widget.postModel.likeCount.toString())
//                 : Text('')),
//       ],
//     );
//   }

class SaveWidget extends StatefulWidget {
  final PostController controller;
  final PostModel postModel;
  final bool initialState;
  SaveWidget(
      {Key? key,
      required this.initialState,
      required this.controller,
      required this.postModel})
      : super(key: key);

  @override
  State<SaveWidget> createState() => _SaveWidgetState();
}

class _SaveWidgetState extends State<SaveWidget> {
  RxBool temp = false.obs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    temp.value = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<bool>(
          future: widget.controller.isPostSaved(widget.postModel.postId),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return Center(
            //     child: saveDIcon,
            //   );
            // }

            return Obx(() => InkWell(
                  onTap: () async {
                    temp.value = !temp.value;

                    EasyDebounce.debounce(
                        'save-debouncer', // <-- An ID for this particular debouncer
                        Duration(
                            milliseconds: 500), // <-- The debounce duration
                        () => temp.value
                            ? widget.controller
                                .savePost(widget.postModel.postId)
                            : widget.controller.unsavePost(widget
                                .postModel.postId) // <-- The target method
                        );
                    // EasyDebounce.debounce(
                    //     'save-debouncer', // <-- An ID for this particular debouncer
                    //     Duration(seconds: 3), // <-- The debounce duration
                    //     () => temp.value = snapshot.data
                    //         ? controller.toggleSave(postModel)
                    //         : () {
                    //             print('value not equal');
                    //           } // <-- The target method
                    //     );
                  },
                  child: temp.value ? savedDIcon : saveDIcon,
                ));
          }),
    );
  }
}
