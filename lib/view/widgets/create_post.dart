import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/services/ImagePickerServices.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/services/permissoins.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/cookbook_page.dart';
import 'package:sano_gano/view/widgets/gym_page.dart';
import 'package:sano_gano/view/widgets/post_footer.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';
import 'package:sano_gano/view/widgets/user_tile_dense.dart';
import 'package:sano_gano/view/widgets/video_player/app/chewie.dart';
import 'package:sano_gano/view/widgets/view_recipe.dart';
import 'package:sano_gano/view/widgets/view_workout.dart';

import '../../services/user_database.dart';
import '../../utils.dart';
import 'comment_widget.dart';
import 'generic_appbar.dart';

class CreatePost extends StatefulWidget {
  final RecipeModel? recipeModel;
  final WorkoutModel? workoutModel;

  CreatePost({Key? key, this.recipeModel, this.workoutModel}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> with TickerProviderStateMixin {
  var userController = Get.find<UserController>();
  var postTEC = TextEditingController();

  late TabController tabController;
  RecipeModel? recipeModel = RecipeModel();
  WorkoutModel? workoutModel = WorkoutModel();

  bool get hasAttachments =>
      widget.recipeModel != null || widget.workoutModel != null;
  var lastSearchTerm = "";

  File? thumb;
  List<File> attachedFiles = [];
  bool? get gifMode => _gif != null;
  RxBool get _isReady =>
      (attachedFiles.isNotEmpty || postTEC.text != "" || _gif != null).obs;
  bool get isReady => _isReady.value;

  bool fromGiphy = false;
  String getGifPath(String gifId) {
    return "https://i.giphy.com/media/$gifId/giphy-hd.mp4";
  }

  GiphyGif? _gif;
  Size? videoSize;

  File? videoThumbnail;
  var postModes = ['Story', 'Photo', 'Recipe', 'Workout'];
  var imageMode = true;
  List<UserModel> taggedUsers = [];
  // Map<int, String> gridLocationsOfTaggedUsers = {};
  var search = '';
  List<UserModel> usersList = [];
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(
      init: PostController(),
      initState: (_) {
        // postTEC.addListener(() {
        //   setState(() {});
        // });
      },
      builder: (controller) {
        return Scaffold(
          extendBody: true,
          bottomNavigationBar: Material(
            color: Get.isDarkMode ? Colors.grey[850] : Colors.white,
            child: Container(
              height: Get.height * 0.08,
              color: standardThemeModeColor,
              child: TabBar(
                  indicatorColor: Colors.transparent,
                  controller: tabController,
                  automaticIndicatorColorAdjustment: true,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black45),
                  // tabController.index == 0 ? Colors.white : Colors.black,
                  tabs: [
                    Tab(
                      text: "Post",
                    ),
                    Tab(
                      text: "Recipe",
                    ),
                    Tab(
                      text: "Workout",
                    ),
                  ]),
            ),
          ),
          body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                buildCreatePostBody(controller),
                Padding(
                  padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                  child: CookbookPage(
                    isRoot: true,
                    isFromCreatePost: true,
                    selectionMode: true,
                    uid: userController.currentUid,
                    onRecipeSelectedCallback: (recipe) {
                      print("callback");

                      recipeModel = recipe;
                      workoutModel = WorkoutModel();

                      tabController.animateTo(0);
                      2.seconds.delay().then((value) {
                        setState(() {});
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                  child: GymPage(
                    isRoot: true,
                    uid: userController.currentUid,
                    selectionMode: true,
                    isFromCreatePost: true,
                    onWorkoutSelected: (workout) {
                      workoutModel = workout;
                      recipeModel = RecipeModel();
                      tabController.animateTo(0);
                      2.seconds.delay().then((value) {
                        setState(() {});
                      });
                    },
                  ),
                ),
              ]),
        );
      },
    );
  }

  Widget buildCreatePostBody(PostController controller) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Create Post",
        trailingActionButton: Obx(() {
          return Opacity(
            opacity: isReady ? 1 : 0.5,
            child: TextButton(
                onPressed: () => submitPost(controller),
                child: Text(
                  "Post",
                  style: blackText.copyWith(
                      fontSize: 17, fontWeight: FontWeight.bold),
                )),
          );
        }),
      ),
      bottomSheet: PostFooter(
        onTapCamera: () {
          getMediaFromCamera();
          // _imgFromSource(ImageSource.camera);
        },
        onTapGallery: () {
          getMediaFromGallery();
          // _imgFromSource(ImageSource.gallery);
        },
        onTapGif: () async {
          _gif = await ImagePickerServices.getGif();
          fromGiphy = true;
          setState(() {});
        },
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        reverse: true,
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              DenseUserTile(
                user: userController.userModel,
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: postTEC,
                maxLines: 5,

                // maxLength: 500,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  counter: Container(),
                  contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                  border: InputBorder.none,
                  hintText: "What's up?",
                  hintStyle: TextStyle(
                    fontSize: 22,
                    //fontWeight: FontWeight.w800,
                    color: Colors.grey,
                  ),
                ),
              ),
              if (recipeModel!.recipeId != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => ViewRecipe(
                          recipeModel: widget.recipeModel ?? recipeModel));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Go to Recipe",
                        style: blackText.copyWith(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          // color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              if (workoutModel!.workoutId != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => ViewWorkout(
                            workoutModel: workoutModel!,
                          ));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Go to Workout",
                        style: blackText.copyWith(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          // color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              if (attachedFiles.isNotEmpty || _gif != null) buildImageViewer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTaggedUsers() {
    if (taggedUsers.isEmpty) return Container();
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.vertical,
      children: List.generate(
        taggedUsers.length,
        (index) => ActionChip(
          padding: EdgeInsets.zero,
          onPressed: () {
            taggedUsers.removeAt(index);
            // gridLocationsOfTaggedUsers[index] = '';
            setState(() {});
          },
          label: Text(taggedUsers[index].username!),
        ),
      ),
    );
  }

  Widget buildImageViewer() {
    print("build image viewer");
    print(_gif != null);
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (!fromGiphy) showUsersBottomSheet();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.040),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(17)),
              child: gifMode!
                  ? Center(
                      child: Image.network(
                        _gif!.images!.original!.webp!,
                        headers: {'accept': 'image/*'},
                        height: _gif!.isSticker == 1 ? 100 : Get.height * 0.4,
                      ),
                    )
                  : imageMode
                      ? Image.file(
                          attachedFiles.first,
                          height: Get.height * 0.4,
                          width: Get.width,
                          fit: BoxFit.cover,
                        )
                      : AspectRatio(
                          aspectRatio: videoSize?.aspectRatio ?? 1,
                          child: ChewieDemo(
                            video: attachedFiles.first,
                            videoUrl: "",
                          ),
                        ),
            ),
          ),
        ),
        Container(height: Get.height * 0.4, child: buildTaggedUsers()),
      ],
    );
  }

  showUsersBottomSheet() async {
    await showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, modalState) => Scaffold(
          body: StreamBuilder<List<UserModel>>(
              initialData: usersList,
              stream: FollowDatabase()
                  .getFollowingModelList(userController.userModel.id!)
                  .asStream(), // .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator.adaptive());
                usersList = snapshot.data!;
                // remove users that are in taggedUsers
                usersList = usersList
                    .where((element) => !taggedUsers
                        .map((e) => e.id)
                        .toList()
                        .contains(element.id))
                    .toList();

                // usersList = usersList
                //     .where((element) =>
                //         !gridLocationsOfTaggedUsers.values.contains(element.id))
                //     .toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoSearchTextField(
                        onChanged: (val) {
                          modalState(() {
                            search = val;
                          });
                        },
                        style: TextStyle(
                          color: standardContrastColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: StreamBuilder<String>(
                            stream: Stream.value(search),
                            builder: (context, snapshot) {
                              return ListView.builder(
                                physics: AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: usersList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var user = usersList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // gridLocationsOfTaggedUsers[index] =
                                      //     user.id!;
                                      taggedUsers.add(user);
                                      Get.back();
                                      setState(() {});
                                    },
                                    child: AbsorbPointer(
                                      absorbing: true,
                                      child: UserHeaderTile(
                                        //  userModel: user,
                                        disableProfileOpening: true,
                                        uid: user.id!,
                                        searchQuery: search,
                                        trailing: Container(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Future<void> submitPost(PostController postController) async {
    if (isReady) {
      if (attachedFiles.isEmpty && postTEC.text.isEmpty && _gif == null) {
        Get.snackbar(
            "Error", "Please add a photo/video or some text to continue",
            colorText: Colors.white,
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      showLoading(loadingText: "Uploading Post");
      String mediaUrl = '';
      if (attachedFiles.isNotEmpty)
        mediaUrl = await FirebaseStorageServices.uploadToStorage(
            isVideo: !imageMode,
            file: attachedFiles.first,
            folderName:
                "files/${userController.userModel.id}/${DateTime.now().millisecondsSinceEpoch}");
      String thumbnailUrl = '';
      if (videoThumbnail != null) {
        log("video thumbnail is not empty");

        thumbnailUrl = await FirebaseStorageServices.uploadToStorage(
            file: videoThumbnail!,
            isVideo: !imageMode,
            folderName:
                "files/${userController.userModel.id}/${DateTime.now().millisecondsSinceEpoch}");
        log("thumbnail url: $thumbnailUrl");
      }
      List<UserModel> taggedUsersToSendNotifications = [];
      // get all tagged user names in tec
      List<String>? taggedUserNames = postTEC.text
          .split(" ")
          .where((element) => element.startsWith("@"))
          .toList();
      List<String>? taggedUsersIds = [];
      for (var element in taggedUserNames) {
        // get user model from username

        String? userId = await UserDatabase()
            .getUserIDFromUsernameWithNoCaseSensitivity(
                element.substring(1, element.length).toLowerCase());
        if (userId != null) {
          taggedUsersIds.add(userId);
        }
      }
      //removing duplicate ids
      taggedUsersIds = taggedUsersIds.toSet().toList();
      for (var element in taggedUsersIds) {
        UserModel? userModel = await UserDatabase().getUser(element);
        taggedUsersToSendNotifications.add(userModel);
      }

      var post = PostModel(
        postId: postController.generatePostId(),
        videoMode: !imageMode,
        attachedRecipeId: recipeModel!.recipeId ?? '',
        attachedWorkoutId: workoutModel!.workoutId ?? '',
        commentCount: 0,
        likeCount: 0,
        videoAspectRatio: videoSize?.aspectRatio,
        ownerId: userController.userModel.id,
        postAttachmentUrl: mediaUrl != "" ? mediaUrl : '',
        postCaption: postTEC.text.trim(),
        taggedUsers: taggedUsers.map((e) => e.id).toList(),
        taggedUserModels: taggedUsers,
        thumbnailUrl: thumbnailUrl,
        gif: _gif,
      );
      PostModel? p =
          await postController.createPost(post, taggedUsersToSendNotifications);
      p!.timestamp = DateTime.now();
      postTEC.clear();
      await Get.find<SearchController>().loadInitialTrendingData();
      hideLoading();
      Get.back(result: true);
    }
  }

  Future<void> getMediaFromGallery() async {
    if (await PermissionsService().checkAndRequestGalleryPermission()) {
      var result = await ImagePickerServices.getMediaFromGallery(
        imagesOnly: true,
        responseCallback: (res) {
          setState(() {
            imageMode = !res.isVideo!;
          });
        },
        // videoResponseCallback: (res) {
        //   // videoSize = res.videoDimensions;
        //   // videoThumbnail = res.cover;
        //   // log("videothumbnail is ${videoThumbnail?.path}");
        // }
      );
      if (result != null) {
        log("Result with type $imageMode");
        attachedFiles = [result];
        fromGiphy = false;
      }

      setState(() {});
    } else {
      Fluttertoast.showToast(msg: "Please grant permissions");
      openAppSettings();
    }
  }

  Future<void> getMediaFromCamera() async {
    if (await PermissionsService().checkAndRequestCameraPermissions() &&
        await PermissionsService().checkAndRequestGalleryPermission()) {
      var result = await ImagePickerServices.getMediaFromCamera(
        responseCallback: (res) {
          setState(() {
            imageMode = !res.isVideo!;
          });
        },
        // videoResponseCallback: (res) {
        //   // videoSize = res.videoDimensions;
        //   // videoThumbnail = res.cover;
        //   // log("videothumbnail is ${videoThumbnail?.path}");
        // }
      );
      if (result != null) {
        log("Result with type $imageMode");
        attachedFiles = [result];
        fromGiphy = false;
      }

      setState(() {});
    } else {
      Fluttertoast.showToast(msg: "Please grant permissions");

      openAppSettings();
    }
  }

  @override
  void initState() {
    tabController = TabController(
      initialIndex: hasAttachments ? 1 : 0,
      length: 3,
      vsync: this,
    );
    recipeModel =
        widget.recipeModel != null ? widget.recipeModel! : RecipeModel();
    workoutModel =
        widget.workoutModel != null ? widget.workoutModel! : WorkoutModel();
    postTEC.addListener(() async {
      setState(() {});

      var atsInLastTerm =
          lastSearchTerm.characters.where((p0) => p0 == "@").length;

      var atsInLatestTerm =
          postTEC.text.characters.where((p0) => p0 == "@").length;

      if (postTEC.text.isNotEmpty && lastSearchTerm != postTEC.text) {
        lastSearchTerm = postTEC.text;
        // postTEC.text[postTEC.text.length - 1] == "@" &&
        if (atsInLatestTerm > atsInLastTerm) {
          List<String>? alreadyTagged = [];
          List<String>? taggedUserNames = postTEC.text
              .split(" ")
              .where((element) => element.startsWith("@"))
              .toList();
          for (var element in taggedUserNames) {
            String? userId = await UserDatabase()
                .getUserIDFromUsernameWithNoCaseSensitivity(
                    element.substring(1, element.length).toLowerCase());
            if (userId != null) {
              print("adding $userId to already tagged");
              alreadyTagged.add(userId);
            }
          }
          setState(() {});
          await triggerMentions(
            onlyShow: [
              ...userController.followerList,
              ...userController.followingList,
            ].toSet().toList(),
            onSelect: (user) async {
              // taggedUsers.add(user);
              postTEC.text.removeAllWhitespace;

              postTEC.text = postTEC.text.trim() + "${user.username!.trim()}";
              postTEC.selection =
                  TextSelection.collapsed(offset: postTEC.text.length);
              // add space after username
              postTEC.text = postTEC.text.trim() + " ";
              Get.back();
            },
            onSelectUserWhenEmpty: (user) async {
              // taggedUsers.add(user);

              postTEC.text =
                  postTEC.text.trim() + "${user.username?.trim()}" + " ";

              // move cursor to end
              postTEC.selection =
                  TextSelection.collapsed(offset: postTEC.text.length);
              Get.back();
            },
          );
        }
        // move cursor to end if there is an @ in the text last word and the last word is not @
        else if (postTEC.text.isNotEmpty &&
            postTEC.text[postTEC.text.length - 1] != "@" &&
            postTEC.text.split(" ").last.contains("@")) {
          // postTEC.selection =
          //     TextSelection.collapsed(offset: postTEC.text.length);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    postTEC.dispose();
    super.dispose();
  }

  Future<void> _imgFromSource(ImageSource source,
      {required bool profilePic}) async {
    try {
      var pickedImage = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
      );
      if (pickedImage != null) {
        File? croppedImage = await ImagePickerServices.cropImage(
            File(pickedImage.path),
            coverPhoto: !profilePic,
            profilePic: profilePic);
        if (croppedImage != null) {
          setState(() {
            attachedFiles = [croppedImage];
            fromGiphy = false;
          });
        }
      }
    } on Exception catch (e) {
      hideLoading();
      return;
    }
  }
}

Future<File?> showImagePicker(context,
    {bool squareMode = false,
    bool skipMode = false,
    bool recipeMode = false,
    bool workoutMode = false,
    bool landscape = false,
    String? skipText = "Skip",
    VoidCallback? onSkip,
    Function? removeCallback}) async {
  return await showModalBottomSheet<File>(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                  leading: cameraDIcon,
                  title: new Text('Camera'),
                  onTap: () async {
                    print("showing camera");
                    var result = await ImagePickerServices.getImageFromCamera(
                        squareMode,
                        landscape: landscape);
                    Get.back<File>(
                      result: result!,
                    );
                  },
                ),
                new ListTile(
                    leading: galleryDIcon,
                    title: new Text('Library'),
                    onTap: () async {
                      var result =
                          await ImagePickerServices.getMediaFromGallery(
                        imagesOnly: true,
                      );
                      Get.back<File>(
                        result: result,
                      );
                    }),
                if (skipMode)
                  new ListTile(
                      leading: xDIcon,
                      title: new Text(skipText ?? 'Skip'),
                      onTap: () async {
                        File? result;

                        Get.back<File>(
                          result: result,
                        );
                        onSkip!();
                      }),
                if (removeCallback != null)
                  new ListTile(
                      leading: trashDIcon,
                      title: new Text('Remove'),
                      onTap: () async {
                        removeCallback();
                        Get.back<File>(
                          result: null,
                        );
                      }),
              ],
            ),
          ),
        );
      });
}

// * junk code

// postTEC.addListener(() {
//   var atsInLastTerm =
//       lastSearchTerm.characters.where((p0) => p0 == "@").length;

//   var atsInLatestTerm =
//       postTEC.text.characters.where((p0) => p0 == "@").length;

//   if (postTEC.text.isNotEmpty && lastSearchTerm != postTEC.text) {
//     lastSearchTerm = postTEC.text;

//     if (postTEC.text[postTEC.text.length - 1] == "@" &&
//         atsInLatestTerm > atsInLastTerm) {
//       triggerMentions(
//         onSelect: (doc) {
//           taggedUsers.add(UserModel.fromFirestore(doc));
//           postTEC.text =
//               postTEC.text.substring(0, postTEC.selection.baseOffset) +
//                   "${doc.get('username')}" +
//                   postTEC.text.substring(postTEC.selection.extentOffset);
//           Get.back();
//         },
//         onSelectUserWhenEmpty: (user) {
//           taggedUsers.add(user);
//           postTEC.text =
//               postTEC.text.substring(0, postTEC.selection.baseOffset) +
//                   "${user.username}" +
//                   postTEC.text.substring(postTEC.selection.extentOffset);
//           Get.back();
//         },
//       );
//     }
//   }
// });

// FutureBuilder<List<UserModel>>(
//     future: FollowDatabase()
//         .getFollowingModelList(userController.currentUid),
//     builder: (context, snapshot) {
//       return Container(
//         child: FlutterMentions(
//           style: TextStyle(fontSize: 22),
//           suggestionPosition: SuggestionPosition.Bottom,
//           // maxLines: null,
//           minLines: 4, maxLines: 10,
//           textInputAction: TextInputAction.done,
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 20),
//             border: InputBorder.none,
//             hintText: "What's up?",
//             hintStyle: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               color: Colors.grey,
//             ),
//           ),
//           onMentionAdd: (data) {
//             var model = UserModel(
//               id: data['id'],
//               name: data['full_name'],
//               username: data['display'],
//               profileURL: data['photo'],
//             );
//             taggedUsers.add(model);
//             setState(() {});
//           },
//           onChanged: (value) => postTEC.text = value,
//           mentions: [
//             Mention(
//               trigger: '@',
//               style: TextStyle(
//                 color: Colors.blue,
//               ),
//               data: [
//                 if (snapshot.hasData)
//                   ...List.generate(
//                       snapshot.data!.length,
//                       (index) => {
//                             'id': snapshot.data![index].id,
//                             'display':
//                                 snapshot.data![index].username,
//                             'full_name':
//                                 snapshot.data![index].name,
//                             'photo': snapshot
//                                     .data![index].profileURL ??
//                                 "",
//                           }),
//               ],
//               matchAll: false,
//               suggestionBuilder: (data) {
//                 print("suggestions");
//                 var model = UserModel(
//                   id: data['id'],
//                   name: data['display'],
//                   username: data['full_name'],
//                   profileURL: data['photo'],
//                 );
//                 return Container(
//                     color: Get.isDarkMode
//                         ? Colors.black
//                         : Colors.white,
//                     padding: EdgeInsets.all(10.0),
//                     child: GestureDetector(
//                       child: AbsorbPointer(
//                         absorbing: true,
//                         child: UserHeaderTile(
//                           userModel: model,
//                           uid: model.id!,
//                         ),
//                       ),

//                       //  UserHeaderTile(
//                       //   uid: data['id'],
//                       //   userModel: model,
//                       // ),
//                     )

//                     // Row(
//                     //   children: <Widget>[

//                     //     CircleAvatar(
//                     //       backgroundImage: NetworkImage(
//                     //         data['photo'],
//                     //       ),
//                     //     ),
//                     //     SizedBox(
//                     //       width: 20.0,
//                     //     ),
//                     //     Column(
//                     //       crossAxisAlignment: CrossAxisAlignment.start,
//                     //       children: <Widget>[
//                     //         Text(data['full_name']),
//                     //         Text('@${data['display']}'),
//                     //       ],
//                     //     )
//                     //   ],
//                     // ),
//                     );
//               },
//             ),
//           ],
//         ),
//       );
//     })
//
// Container(
//   height: Get.height * 0.4,
//   width: Get.width,
//   child: GridView.builder(
//     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 10,
//     ),
//     itemCount: 100,
//     itemBuilder: (BuildContext context, int index) {
//       return GestureDetector(
//         onTap: () {
//           showUsersBottomSheet();
//         },
//         child: Container(
//           child: Text(''),
//         ),
//       );
//     },
//   ),
// ),

//

// if (!gifMode!)
// Positioned(
//   top: 3,
//   left: 20,
//   child: Container(
//     child: IconButton(
//       padding: EdgeInsets.all(4),
//       onPressed: () async {
//         if (imageMode && !gifMode!) {
//           ImagesPicker.saveImageToAlbum(attachedFiles.first,
//               albumName: "");
//         } else if (gifMode!) {
//           // launchUrl(Uri.tryParse(getGifPath(_gif!.id!))!);
//           // return;
//           var path = (await getApplicationDocumentsDirectory()).path +
//               '/' +
//               '${_gif!.id}.mp4';

//           var res = await dio.download(getGifPath(_gif!.id!), path,
//               onReceiveProgress: (rec, total) {
//             print("rec: $rec, total: $total");
//           }).then((value) async {
//             // await ImagesPicker.saveImageToAlbum(File(path),
//             //     albumName: "");
//             print("downloaded $path");
//           });
//         } else {
//           ImagesPicker.saveVideoToAlbum(attachedFiles.first,
//               albumName: "");
//         }
//       },
//       icon: savePictureDIcon.copyWith(color: Colors.white, size: 28),
//     ),
//   ),
// ),

// Positioned(
//   top: 3,
//   right: 20,
//   child: Container(
//     child: IconButton(
//       padding: EdgeInsets.all(4),
//       onPressed: () {
//         attachedFiles = [];
//         _gif = null;
//         fromGiphy = false;
//         setState(() {});
//       },
//       icon: xDIcon.copyWith(color: Colors.white, size: 28),
//     ),
//   ),
// ),

//  if ((recipeModel!=null || workoutModel!=null) && (attachedFiles.isEmpty && postTEC.text.isEmpty) ) {
//   Get.snackbar("Error", "Please add a photo/video or some text to continue",
//       colorText: Colors.white,
//       backgroundColor: Colors.red,
//       snackPosition: SnackPosition.BOTTOM);
//   return;
// }
// if (result != null) {
//   attachedFiles.add(result.file!);
//   imageMode = !result.isVideo!;
//   thumb = result.thumbnail;
//   setState(() {});
// }
// Opacity(
//   opacity: attachedFiles.isNotEmpty && imageMode ? 1 : 0.2,
//   child: IconButton(
//     onPressed: () async {
//       _gif = await ImagePickerServices.getGif();
//     },
//     icon: Icon(
//       Icons.gif_rounded,
//       size: 100,
//     ),
//   ),
// ),
// showModalBottomSheet(
//     context: context,
//     builder: (BuildContext bc) {
//       return SafeArea(
//         child: Container(
//           child: new Wrap(
//             children: <Widget>[
//               new ListTile(
//                 leading: cameraIcon,
//                 title: new Text('Images'),
//                 onTap: () async {
//                   attachedFiles =
//                       await ImagePickerServices.getImageAssets(context);
//                   if (attachedFiles.isNotEmpty)
//                     setState(() {
//                       imageMode = true;
//                     });
//                   Get.back();
//                 },
//               ),
//               new ListTile(
//                   leading: galleryDIcon,
//                   title: new Text('Videos'),
//                   onTap: () async {
//                     attachedFiles =
//                         await ImagePickerServices.getVideoAssets(context);
//                     if (attachedFiles.isNotEmpty)
//                       setState(() {
//                         imageMode = false;
//                       });
//                     Get.back();
//                   }),
//             ],
//           ),
//         ),
//       );
//     });
