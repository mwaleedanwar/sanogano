import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/utils/globalHelperMethods.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/profile/settings.dart';
import 'package:sano_gano/view/pages/profile/follow_message_profile_buttons.dart';
import 'package:sano_gano/view/pages/profile/widgets/bio_widget.dart';
import 'package:sano_gano/view/pages/profile/widgets/profile_body.dart';
import 'package:sano_gano/view/pages/profile/widgets/profile_image.dart';
import 'package:sano_gano/view/pages/profile/widgets/website_widget.dart';
import 'package:sano_gano/view/widgets/comment_widget.dart';
import 'package:sano_gano/view/widgets/createRecipe.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:sano_gano/view/widgets/create_workout.dart';
import 'package:sano_gano/view/widgets/popup_menu_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'otherProfile.dart';

class ProfilePage extends StatefulWidget {
  String userID;
  final Function()? healthCallback;

  final bool hideBack;
  ProfilePage(
      {required this.userID, this.healthCallback, this.hideBack = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  bool get wantKeepAlive => true;
  // ScrollController _mainPageController = ScrollController();

  PostController postController = Get.put(PostController());
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();

  final db = Database();
  AuthController authController = Get.find<AuthController>();
  var format = DateFormat("MMMM d, y");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return BuildProfileBody();

    return authController.user!.uid != widget.userID
        ? OtherUserProfile(
            userID: widget.userID,
          )
        : GetX<UserController>(
            builder: (UserController controller) {
              var _myID = authController.user!.uid;
              var _myProfile = true;

              controller.getCurrentUser(widget.userID);
              if (controller != null && controller.userModel != null) {
                var _user = controller.userModel;
                _myProfile = controller.userModel.id == _myID;

                return Obx(() {
                  return StreamBuilder<UserModel>(
                      initialData: _user,
                      stream: controller.currentUserStream
                          .map((event) => UserModel.fromFirestore(event)),
                      builder: (context, snapshot) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            1.seconds.delay().then((value) => setState(() {}));
                          },
                          child: Scaffold(
                            // backgroundColor: Colors.white, TODO fix dark theme
                            appBar: CustomAppBar(
                              back: !widget.hideBack || !_myProfile,
                              leading: buildPopupMenu([
                                PopupItem(
                                    callback: () => Get.to(CreatePost()),
                                    index: 0,
                                    title: "Create Post"),
                                PopupItem(
                                    callback: () => createRecipe(),
                                    index: 1,
                                    title: "Create Recipe"),
                                PopupItem(
                                    callback: () => createWorkout(),
                                    index: 2,
                                    title: "Create Workout"),
                              ], icon: addIcon),
                              title: _user.username ?? "Username",
                              onTapTitle: () {
                                log("my profile");

                                sfc.animateControllerToStartOfPage(
                                    sfc.profilePageScrollController);
                              },
                              iconButton: _myProfile && widget.hideBack
                                  ? InkWell(
                                      onTap: () async {
                                        await Get.to(() => SettingsPage());
                                        controller.update();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 5),
                                        child: settingsDIcon,
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      child: Container(),
                                    ),
                            ),
                            body: DefaultTabController(
                              length: 5,
                              child: NestedScrollView(
                                controller: sfc.profilePageScrollController,
                                scrollBehavior: ScrollBehavior(),
                                // physics: ClampingScrollPhysics(),
                                // allows you to build a list of elements that would be scrolled away till the body reached the top
                                headerSliverBuilder: (context, _) {
                                  return [
                                    SliverList(
                                      delegate: SliverChildListDelegate([
                                        Container(
                                          height: Get.height < 700
                                              ? Get.height * 0.37
                                              : Get.height * 0.29,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: controller
                                                            .userModel
                                                            .bannerURL
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? Image.network(
                                                        controller.userModel
                                                            .bannerURL!,
                                                        height: 120,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Image.asset(
                                                        "assets/banner.png",
                                                        height: 120,
                                                        fit: BoxFit.fill,
                                                      ),
                                              ),
                                              Positioned(
                                                top: 65,
                                                child: ProfileImage(
                                                  _user.profileURL!,
                                                  _user.id!,
                                                  _user.username!,
                                                  _user.followers ?? 0,
                                                  _user.following ?? 0,
                                                  _user.name!,
                                                  healthCallback:
                                                      widget.healthCallback,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              //  addHeight(5.0),
                                              Text(
                                                _user.name ?? "Name",
                                                style: blackText.copyWith(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              addHeight(5.0),
                                              Container(
                                                  width: Get.width * 0.8,
                                                  child: BioWidget(
                                                      bio: _user.bio)),
                                              addHeight(5.0),
                                              WebsiteWidget(
                                                  website: _user.website),
                                              addHeight(5),
                                              Text(
                                                "ESTABLISHED " +
                                                    format
                                                        .format(
                                                            _user.established ??
                                                                DateTime.now())
                                                        .toUpperCase(),
                                                style: TextStyle(fontSize: 10),
                                              ),
                                              // addHeight(5),

                                              //Follow And Message For Other Users
                                              !_myProfile
                                                  ? UserProfile(
                                                      userID: widget.userID,
                                                      userModel: _user,
                                                    )
                                                  : Container(
                                                      padding: EdgeInsets.zero,
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ];
                                },
                                // You tab view goes here

                                body: ProfileBody(uid: _myID),
                              ),
                            ),
                          ),
                        );
                      });
                });
              } else {
                return Center(
                  child: SpinKitCircle(
                    size: 25,
                    color: Colors.black,
                  ),
                );
              }
            },
          );
  }

  void createWorkout() async {
    var result = await showImagePicker(Get.context,
        skipMode: true, squareMode: true, workoutMode: true, onSkip: () {
      Get.to(CreateWorkout(
        workoutImage: null,
        skipMode: true,
      ));
    });

    if (result != null)
      Get.to(CreateWorkout(
        workoutImage: result,
      ));
  }

  void createRecipe() async {
    var result = await showImagePicker(Get.context,
        squareMode: true, recipeMode: true, skipMode: true, onSkip: () {
      Get.to(CreateRecipe(
        recipeImage: null,
        skipMode: true,
      ));
    });

    if (result != null)
      Get.to(CreateRecipe(
        recipeImage: result,
      ));
  }
}

/*class ProfilePage extends StatelessWidget {

  String userID;
  ProfilePage(this.userID);

  @override
  Widget build(BuildContext context) {
    var format = DateFormat("MMMM d, y");

    Widget _buildBioText(String bio) {
      if (bio == null) {
        return Text(
          "bio",
          style: TextStyle(color: Colors.grey),
        );
      } else {
        if (bio.length == 0) {
          return Text(
            "bio",
            style: TextStyle(color: Colors.grey),
          );
        } else {
          return Text(bio);
        }
      }
    }

    Widget _buildWebsiteText(String website) {
      if (website == null) {
        return Text(
          "website",
          style: TextStyle(color: Colors.grey),
        );
      } else {
        if (website.length == 0) {
          return Text(
            "website",
            style: TextStyle(color: Colors.grey),
          );
        } else {
          return Text(
            website,
            style: TextStyle(
              color: Colors.blue,
            ),
          );
        }
      }
    }

    return DefaultTabController(
      length: 5,

      child: GetX<UserController>(
        init: Get.put(UserController()),
        builder: (UserController controller) {

          var _myID = Get.find<AuthController>().user.uid;
          var _myProfile = true;

          controller.getCurrentUser(userID);
           if(controller != null && controller.userModel != null) {

             var _user = controller.userModel;
             _myProfile = controller.userModel.id == _myID;

             return Scaffold(
               backgroundColor: Colors.white,
               appBar: CustomAppBar(
                 back: !_myProfile,
                 title: _user.username ?? "Username",
                 iconButton: _myProfile
                     ? InkWell(
                   onTap: () {
                     Get.to(() => SettingsPage());
                   },
                   child: Padding(
                     padding: const EdgeInsets.symmetric(
                         horizontal: 20.0, vertical: 5),
                     child: CustomIcon("assets/icons/setting.svg", 20),
                   ),
                 )
                     : Padding(
                   padding: EdgeInsets.symmetric(
                       horizontal: 20, vertical: 5),
                   child: Container(),
                 ),
               ),
               body: Column(
                 children: [
                   Container(
                     height: !_myProfile ? 400 : 350 ,
                     child: Stack(
                       alignment: Alignment.center,
                       children: [
                         Positioned(
                             top: 0,
                             left: 0,
                             right: 0,
                             child: Image.asset(
                               "assets/images/cover.png",
                               height: 120,
                               fit: BoxFit.fill,
                             )),
                         Positioned(
                           top: 75,
                           child: ProfileImage(
                               _user.profileURL,
                               _user.id,
                               _user.username,
                               _user.followers ?? 0,
                               _user.following ?? 0),
                         ),
                         Positioned(
                           top: 250,
                           child: Container(
                             child: Column(
                               children: [
                                 Text(
                                   _user.name ?? "Name",
                                   style: TextStyle(
                                       fontSize: 18,
                                       color: Colors.black,
                                       fontWeight: FontWeight.bold),
                                 ),
                                 addHeight(5.0),
                                 _buildBioText(_user.bio),
                                 addHeight(5.0),
                                 _buildWebsiteText(_user.website),
                                 addHeight(5.0),
                                 Text("ESTABLISHED " +
                                     format.format(
                                         _user.established ??
                                             DateTime.now()).toUpperCase()),
                                 addHeight(5),

                                 ///Follow And Message For Other Users
                                 !_myProfile
                                     ? UserProfile(userID)
                                     : Container(),
                               ],
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   SizedBox(
                     height: 50,
                     child: AppBar(
                       elevation: 0.0,
                       backgroundColor: Colors.white,
                       bottom: TabBar(
                         labelColor: Colors.black,
                         indicatorColor: Colors.black,
                         labelStyle: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold),
                         unselectedLabelStyle: TextStyle(fontSize: 12,color: Colors.black,),
                         tabs: [
                           Tab(
                             text: "ALL",
                           ),
                           Tab(
                             text: "Media",
                           ),
                           Tab(
                             text: "Recipe",
                           ),
                           Tab(
                             text: "Workout",
                           ),
                           Tab(
                             text: "Tagged",
                           ),
                         ],
                       ),
                     ),
                   ),
                   Expanded(
                     child: TabBarView(
                       children: [
                         Center(
                           child: Text(
                             'All',
                           ),
                         ),
                         Center(
                           child: Text(
                             'Media',
                           ),
                         ),
                         Center(
                           child: Text(
                             'Recipe',
                           ),
                         ),
                         Center(
                           child: Text(
                             'Workout',
                           ),
                         ),
                         Center(
                           child: Text(
                             'Tagged',
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             );
           }else {
            return Center(
               child: SpinKitCircle(
                 size: 25,
                 color: Colors.black,
               ),
             );
           }
        },
      ),
    );
  }
}*/
