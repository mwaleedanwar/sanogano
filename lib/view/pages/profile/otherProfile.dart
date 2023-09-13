import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/profile/follow_message_profile_buttons.dart';
import 'package:sano_gano/view/pages/profile/userblocked.dart';
import 'package:sano_gano/view/pages/profile/widgets/bio_widget.dart';
import 'package:sano_gano/view/pages/profile/widgets/profile_body.dart';
import 'package:sano_gano/view/pages/profile/widgets/profile_image.dart';
import 'package:sano_gano/view/pages/profile/widgets/website_widget.dart';
import 'package:sano_gano/view/widgets/comment_widget.dart';
import 'package:sano_gano/view/widgets/popup_menu_builder.dart';
import 'package:sano_gano/view/widgets/user_menu_options.dart';

import '../../../controllers/helpers/scroll_focus_controller_helper.dart';

class OtherUserProfile extends StatefulWidget {
  final String userID;
  OtherUserProfile({required this.userID});

  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  var _myProfile = false;
  UserModel? _user;
  var blockedView = false;
  var blockedBy = '';
  var userController = Get.find<UserController>();
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();
  List<ScrollController> scrollControllers = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    userBlockedCheck();
    scrollControllers = List.generate(5, (index) => ScrollController());
  }

  userBlockedCheck() {
    userController.isUserBlocked(widget.userID).then(
      (value) {
        if (value == null) return;
        blockedView = value.isBlocked;
        blockedBy = value.blockedBy;
        setState(() {
          loaded = true;
        });
      },
    );
  }

  var loaded = false;
  var isSubscribed = false;
  Future<void> getUser() async {
    print("getting user ${widget.userID}");
    _user = await UserDatabase().getUser(widget.userID);
    isSubscribed = await userController.isSubscribedToUserPosts(widget.userID);
    log("profile url ${_user!.profileURL!}");
    setState(() {
      loaded = true;
    });
  }

  var db = Database();

  @override
  Widget build(BuildContext context) {
    var format = DateFormat("MMMM d, y");
    if (blockedView)
      return BlockedView(
        blockedBy: blockedBy,
        blockedUser: _user!,
        unblockedCallback: () {
          blockedBy = '';
          blockedView = false;
          setState(() {});
        },
      );

    return !loaded
        ? Scaffold(
            body: Center(child: Container()),
          )
        : Scaffold(
            appBar: CustomAppBar(
                back: !_myProfile,
                title: _user!.username ?? "Username",
                onTapTitle: () {
                  log("other profile");
                  sfc.animateControllerToStartOfPage(sfc.othersPageController);
                },
                iconButton: StreamBuilder<bool>(
                    stream: userController
                        .isSubscribedToUserPostsAsStream(_user!.id!),
                    builder: (context, snapshot) {
                      isSubscribed = snapshot.data ?? false;
                      return buildPopupMenu([
                        PopupItem(
                          title: "Block",
                          index: 0,
                          callback: () {
                            userController
                                .userMenuAction(UserMenuOptions.Block, _user!,
                                    postActionCallback: () {
                              setState(() {
                                userBlockedCheck();
                              });
                            });
                          },
                        ),
                        PopupItem(
                          title:
                              "Turn ${isSubscribed ? 'Off' : 'On'} Post Notifications",
                          index: 1,
                          callback: () async {
                            var res = await userController
                                .toggleSubscribeToUserPosts(_user!.id!);
                            isSubscribed = res;
                            setState(() {});
                          },
                        ),
                      ], icon: optionsSIcon);
                    })

                // buildUserMenuOptions(
                //   _user,
                //   false,
                //   onSelectCallback: (selection) {
                //     userController.userMenuAction(selection, _user,
                //         postActionCallback: () {
                //       setState(() {
                //         if (selection == UserMenuOptions.Block)
                //           userBlockedCheck();
                //       });
                //     });
                //   },
                // ),
                ),
            body: Builder(builder: (context) {
              var _myID = _user!.id;

              return DefaultTabController(
                length: 5,
                child: NestedScrollView(
                  controller: sfc.othersPageController,
                  //physics: NeverScrollableScrollPhysics(),
                  // allows you to build a list of elements that would be scrolled away till the body reached the top
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            height: Get.height < 700
                                ? Get.height * 0.37
                                : Get.height * 0.29,
                            // constraints:
                            //     BoxConstraints(maxHeight: Get.height * 0.37),
                            child: Stack(
                              fit: StackFit.passthrough,
                              alignment: Alignment.topCenter,
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: _user!.bannerURL!.isNotEmpty
                                      ? Image.network(
                                          _user!.bannerURL!,
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
                                    _user!.profileURL!,
                                    _user!.id!,
                                    _user!.username!,
                                    _user!.followers ?? 0,
                                    _user!.following ?? 0,
                                    _user!.name!,
                                  ),
                                ),
                                // Positioned(
                                //   top: 240,
                                //   child: Container(
                                //     child: Column(
                                //       children: [
                                //         Text(
                                //           _user.name ?? "Name",
                                //           style: TextStyle(
                                //               fontSize: 18,
                                //               color: Colors.black,
                                //               fontWeight: FontWeight.bold),
                                //         ),
                                //         addHeight(5.0),
                                //         _buildBioText(_user.bio),
                                //         addHeight(5.0),
                                //         _buildWebsiteText(_user.website),
                                //         addHeight(5.0),
                                //         Text(
                                //           "ESTABLISHED " +
                                //               format
                                //                   .format(
                                //                       _user.established ??
                                //                           DateTime.now())
                                //                   .toUpperCase(),
                                //           style: TextStyle(fontSize: 12),
                                //         ),
                                //         addHeight(5),

                                //         ///Follow And Message For Other Users
                                //         !_myProfile
                                //             ? UserProfile(
                                //                 widget.userID,
                                //                 userModel: _user,
                                //               )
                                //             : Container(),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          addHeight(5),
                          Container(
                            child: Column(
                              children: [
                                addHeight(5.0),
                                Container(
                                  child: Text(
                                    _user!.name ?? "Name",
                                    style: blackText.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (_user!.bio?.isNotEmpty ?? false)
                                  addHeight(5.0),
                                if (_user!.bio?.isNotEmpty ?? false)
                                  BioWidget(bio: _user!.bio!),
                                if (_user!.website?.isNotEmpty ?? false)
                                  addHeight(5.0),
                                if (_user!.website?.isNotEmpty ?? false)
                                  WebsiteWidget(website: _user!.website!),
                                addHeight(5.0),
                                Text(
                                  "ESTABLISHED " +
                                      format
                                          .format(_user!.established ??
                                              DateTime.now())
                                          .toUpperCase(),
                                  style: TextStyle(fontSize: 12),
                                ),
                                addHeight(5),

                                ///Follow And Message For Other Users
                                !_myProfile
                                    ? UserProfile(
                                        userID: widget.userID,
                                        userModel: _user!,
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ];
                  },
                  // You tab view goes here
                  body: ProfileBody(uid: widget.userID),
                ),
              );
            }),
          );
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
