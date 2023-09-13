import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/components/userTile.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';

import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/utils/globalHelperMethods.dart';
import 'package:sano_gano/view/global/custom_icon.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/follow/widgets/follow_tile.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:validated/validated.dart';

import '../../controllers/theme_controller.dart';
import '../pages/search/searched_item.dart';

class UserHeaderTile extends StatelessWidget {
  final UserModel? userModel;
  final String uid;
  final bool viewTrailing;
  final Widget? trailing;
  final Widget? subtitle;
  final bool viewFollow;
  final Function? onTap;
  final double profileAvatarSize;
  final database = UserDatabase();
  final currentUserId = Get.find<UserController>().currentUid;
  final double? gapAfterAvatar;
  final String searchQuery;
  final bool isDense;
  final String? imageUrl;
  final bool chatMode;
  final bool disableProfileOpening;
  final bool noSubtitle;
  final bool showName;
  final bool searchMode;
  final bool withFollowers;
  final bool withFollowing;
  final Function(UserModel)? onSelect;
  bool isFromSearch = true;
  UserHeaderTile({
    Key? key,
    this.userModel,
    required this.uid,
    this.viewTrailing = false,
    this.noSubtitle = false,
    this.showName = false,
    this.trailing,
    this.subtitle,
    this.disableProfileOpening = false,
    this.onTap,
    this.imageUrl,
    this.profileAvatarSize = 18,
    this.chatMode = false,
    this.gapAfterAvatar = 10,
    this.viewFollow = false,
    this.isDense = false,
    this.searchMode = false,
    this.searchQuery = '',
    this.withFollowers = false,
    this.withFollowing = false,
    this.onSelect,
    this.isFromSearch = false,
  }) : super(key: key);
  UserModel model = UserModel();
  FollowController fc = Get.put(FollowController());
  UserController uc = Get.find<UserController>();
  FollowStatus? status;
  @override
  Widget build(BuildContext context) {
    if (userModel != null) {
      return buildUserTile(userModel!);
    } else
      return FutureBuilder<UserModel?>(
        future: database.getUser(uid),
        initialData: model,
        builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.data == null)
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 18,
                // backgroundColor: Colors.grey[100],
              ),
            );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(),
            );
          }
          model = snapshot.data!;
          if (!(model.username!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  model.name!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase())) &&
              searchQuery.isNotEmpty) return Container();

          if (searchMode) {
            return buildUserSearchTile(snapshot.data!);
          }
          return buildUserTile(snapshot.data!);
        },
      );

    // return Container();
  }

  Widget buildUserTile(UserModel model) {
    if (model.name == null || model.username == null) return Container();
    return ListTile(
      dense: isDense,
      onTap: onSelect != null
          ? () => onSelect!(model)
          : onTap != null
              ? () => onTap!()
              : () async {
                  if (disableProfileOpening) return;
                  if (searchMode) {
                    SearchController sc = Get.find<SearchController>();
                    AuthController ac = Get.find<AuthController>();
                    Database db = Database();
                    var searchModel = SearchedItemModel(
                        timeOfSearch: DateTime.now(),
                        searchTerm: sc.textFieldController.text,
                        type: sc.getSearchType(),
                        id: model.id!,
                        snapshotJson: model.toMap());
                    db
                        .recentSearches(ac.user!.uid)
                        .doc(model.id)
                        .set(searchModel.toMap());
                  }
                  Get.to(() => ProfilePage(userID: model.id!));
                  return;
                },
      leading: SizedBox(
        height: 40,
        child: InkWell(
            onTap: () {
              if (disableProfileOpening) return;
              Get.to(() => ProfilePage(userID: model.id!));
              return;
            },
            child: UserAvatar(
              uid,
              radius: profileAvatarSize,
            )),
      ),
      title: chatMode
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showName ? model.name! : model.username!,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                trailing ?? Container(),
              ],
            )
          : GestureDetector(
              onTap: onTap == null
                  ? null
                  : () {
                      if (disableProfileOpening) return;
                      Get.to(() => ProfilePage(userID: model.id!));
                      return;
                    },
              child: Text(
                showName ? model.name! : model.username ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
      horizontalTitleGap: gapAfterAvatar == null ? 10 : gapAfterAvatar,
      subtitle: noSubtitle
          ? null
          : subtitle != null
              ? subtitle
              : isFromSearch
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        subtitle ??
                            (Text(
                              model.name ?? "",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            )),
                        OtherUserRelationship(
                          uid: model.id!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        // FutureBuilder<FollowStatus>(
                        //     initialData: status,
                        //     future: checkFollowStatus(
                        //         Get.find<AuthController>().user!.uid,
                        //         model.username!),
                        //     builder: (context, followSnapshot) {
                        //       if (followSnapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         return Text(
                        //           uc.followingList.contains(model)
                        //               ? "Following"
                        //               : "Friends",
                        //           style: TextStyle(
                        //             color: Colors.grey,
                        //             fontSize: 14,
                        //           ),
                        //         );
                        //       }
                        //       status = followSnapshot.data!;

                        //       return status == FollowStatus.friends
                        //           ? Text(
                        //               "Friends",
                        //               style: TextStyle(
                        //                 color: Colors.grey,
                        //                 fontSize: 14,
                        //               ),
                        //             )
                        //           : status == FollowStatus.notFollowing
                        //               ? FollowerTextWidget(
                        //                   uid: model.id!,
                        //                 )
                        //               //
                        //               : Text(
                        //                   "Following",
                        //                   style: TextStyle(
                        //                     color: Colors.grey,
                        //                     fontSize: 14,
                        //                   ),
                        //                 );
                        //     })
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        subtitle ??
                            (Text(
                              model.name!,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            )),
                        if (withFollowers)
                          FollowerTextWidget(
                            uid: model.id!,
                          ),
                        //  Text(model.followers.toString() + ' Followers'),
                        if (withFollowing)
                          FollowingTextWidget(
                            uid: model.id!,
                          ),
                      ],
                    ),
      visualDensity: VisualDensity(horizontal: 0, vertical: -1),
      contentPadding: EdgeInsets.only(
          left: Get.width * 0.040, right: Get.width * 0.02, top: 0, bottom: 0),
      trailing: chatMode
          ? null
          : viewTrailing
              ? viewFollow && (model.id != currentUserId)
                  ? Container(
                      width: Get.width * 0.25,
                      child: FollowButton(
                        userModel: model,
                        uid: model.id,
                      ),
                    )
                  : trailing
              : null,
    );
  }

  Future<FollowStatus> checkFollowStatus(String myID, String userName) async {
    String? otherUserId = await UserDatabase().getUserIDFromUsername(userName);
    if (otherUserId == null) {
      return FollowStatus.notFollowing;
    } else {
      bool isFrinds =
          await fc.checkIfBothUserFollowEachOther(myID, otherUserId);
      if (isFrinds) {
        return FollowStatus.friends;
      } else {
        bool isFollowing = await fc.isFollowed(myID, otherUserId);
        return isFollowing ? FollowStatus.following : FollowStatus.notFollowing;
      }
    }
  }

  goToUserProfile() {
    Get.to(() => ProfilePage(userID: uid));
  }

  Widget buildUserSearchTile(UserModel userModel) {
    return InkWell(
      onTap: onTap != null
          ? onTap!()
          : () {
              print(userModel.id!.trim());

              Get.to(ProfilePage(userID: userModel.id!.trim()));
              return;
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              userModel.id!,
              radius: 24,
            ),
            addWidth(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      print(userModel.id!.trim());
                      Get.to(ProfilePage(userID: userModel.id!.trim()));
                    },
                    child: Text(
                      userModel.username!,
                      style: TextStyle(
                          color: standardContrastColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  addHeight(2),
                  InkWell(
                    onTap: () {
                      print(userModel.id!.trim());
                      Get.to(ProfilePage(userID: userModel.id!.trim()));
                    },
                    child: Text(
                      userModel.name!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      print(userModel.id!.trim());
                      Get.to(ProfilePage(userID: userModel.id!.trim()));
                    },
                    child: OtherUserRelationship(
                      uid: userModel.id!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (uid != currentUserId)
              FollowButton(
                uid: userModel.id,
                userModel: userModel,
                width: Get.width * 0.25,
              ),
          ],
        ),
      ),
    );
  }
}

enum FollowStatus { friends, following, notFollowing }

class UserAvatar extends StatelessWidget {
  final String? uid;
  final double? radius;
  final String? name;
  final String? image;
  Function(String)? usernameCallback;
  final bool autoFontSize;
  final bool showOnlineIndicator;

  bool isdisabledTap = false;

  UserAvatar(this.uid,
      {this.radius = 24,
      this.name,
      this.usernameCallback,
      this.image,
      this.autoFontSize = false,
      this.showOnlineIndicator = false,
      this.isdisabledTap = false});
  final db = UserDatabase();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double getFontSize() =>
        autoFontSize ? (size.aspectRatio * 50) : ((radius ?? 18) / 0.8);

    if (usernameCallback == null) {
      usernameCallback = (val) {};
    }
    if ((image != null || name != null)) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CircleAvatar(
            backgroundColor: Color(Get.find<ThemeController>().globalColor),
            radius: radius,
            backgroundImage: image != null && image!.isNotEmpty
                ? OptimizedCacheImageProvider(image!)
                : null,
            child: name != null && (image?.isEmpty ?? true)
                ? Text(
                    name![0].toUpperCase(),
                    style: GoogleFonts.nunito(
                      color: Get.isDarkMode ? Colors.black : Colors.white,
                      fontSize: getFontSize(),
                    ),
                  )
                : null,
          ),
          Visibility(
            visible: showOnlineIndicator,
            child: Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                width: 10,
                height: 10,
              ),
            ),
          ),
        ],
      );
    }
    return FutureBuilder<UserModel?>(
        future: db.getUser(uid!),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return CircleAvatar(
                radius: radius,
                backgroundColor:
                    Color(Get.find<ThemeController>().globalColor));
          var model = snapshot.data;
          if (model == null) {
            return Container();
          }
          if (model.username == null) {
            return Container();
          }
          usernameCallback!(model.username!);
          return Container(
            child: (!isdisabledTap)
                ? GestureDetector(
                    onTap: () {
                      Get.to(() => ProfilePage(userID: model.id!));
                    },
                    child: CircleAvatar(
                      backgroundColor:
                          Color(Get.find<ThemeController>().globalColor),
                      radius: radius,
                      backgroundImage: image != null && image!.isNotEmpty
                          ? OptimizedCacheImageProvider(image!)
                          : !isNullOrBlank(model.profileURL)
                              ? OptimizedCacheImageProvider(model.profileURL!)
                              : null,
                      child: isNullOrBlank(model.profileURL) || name != null
                          ? Text(
                              name ?? model.name![0].toUpperCase(),
                              style: GoogleFonts.nunito(
                                color: Get.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: getFontSize(),
                              ),
                            )
                          : null,
                    ),
                  )
                : CircleAvatar(
                    backgroundColor:
                        Color(Get.find<ThemeController>().globalColor),
                    radius: radius,
                    backgroundImage: image != null
                        ? OptimizedCacheImageProvider(image!)
                        : !isNullOrBlank(model.profileURL)
                            ? OptimizedCacheImageProvider(model.profileURL!)
                            : null,
                    child: isNullOrBlank(model.profileURL) || name != null
                        ? Text(
                            name ??
                                (isEmoji(model.name!)
                                    ? model.username![0].toUpperCase()
                                    : getFirstCharacter(model.name!)
                                        .toUpperCase()),
                            style: GoogleFonts.nunito(
                              color:
                                  Get.isDarkMode ? Colors.black : Colors.white,
                              fontSize: getFontSize(),
                            ),
                          )
                        : null,
                  ),
          );
        });
  }

  String getFirstCharacter(String str) {
    return str[RegExp(r'[a-zA-Z0-9]').firstMatch(str)?.start ?? 0];
  }
}

class UsernameWidget extends StatelessWidget {
  final String uid;

  UsernameWidget({Key? key, required this.uid}) : super(key: key);
  final db = UserDatabase();
  UserModel? user;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      initialData: user,
      future: db.getUserNullable(uid),
      builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("");
        }
        var user = snapshot.data;
        return Text(
          user?.username ?? "",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        );
      },
    );
  }
}

class FollowerTextWidget extends StatelessWidget {
  final String uid;
  final bool? numberOnly;
  final TextStyle? style;
  final bool? streamMode;

  const FollowerTextWidget(
      {Key? key,
      required this.uid,
      this.numberOnly = false,
      this.style,
      this.streamMode = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (streamMode!) {
      return StreamBuilder(
        stream: FollowDatabase().getFollowerListStream(uid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (numberOnly!)
            return Text(
              (snapshot.data?.length ?? "").toString(),
              style: style,
            );
          return Text(
            (snapshot.data?.length ?? "").toString() + ' Followers',
            style: style,
          );
        },
      );
    }
    return StreamBuilder(
      stream: FollowDatabase().getFollowerListStream(uid),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (numberOnly!)
          return Text(
            (snapshot.data?.length ?? 0).toString(),
            style: style,
          );
        return Text(
          (snapshot.data?.length ?? 0).toString() + ' Followers',
          style: style,
        );
      },
    );
  }
}

class FollowingTextWidget extends StatelessWidget {
  final String uid;
  final bool? numberOnly;
  final TextStyle? style;

  const FollowingTextWidget(
      {Key? key, required this.uid, this.numberOnly = false, this.style})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FollowDatabase().getFollowingCountStream(uid),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (numberOnly!)
          return Text(
            (snapshot.data?.length ?? "").toString(),
            style: style,
          );
        return Text(
          (snapshot.data?.length ?? "").toString() + ' Following',
          style: style,
        );
      },
    );
  }
}

class OtherUserRelationship extends StatelessWidget {
  final String uid;

  final TextStyle? style;

  const OtherUserRelationship({Key? key, required this.uid, this.style})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRelationship?>(
      future: FollowDatabase.getUserRelationship(uid),
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == null)
          return Text(
            "",
            style: style,
          );
        var relationship = snapshot.data;
        if (relationship!.areFriends) {
          return Text(
            "Friends",
            style: style,
          );
        }
        if (relationship.isFollowing) {
          return Text(
            "Following",
            style: style,
          );
        }
        return Text(
          handlePlurals(relationship.otherUserFollowers, "Follower"),
          style: style,
        );
      },
    );
  }
}

String handlePlurals(int number, String word) {
  if (number == 1) {
    return "$number $word";
  }
  return "$number ${word}s";
}
