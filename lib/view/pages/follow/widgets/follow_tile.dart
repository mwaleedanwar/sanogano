import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class FollowTile extends StatefulWidget {
  UserModel users;
  String id;
  final String searchQuery;
  FollowTile(this.users, this.id, {this.searchQuery = ''});

  @override
  _FollowTileState createState() => _FollowTileState();
}

class _FollowTileState extends State<FollowTile> {
  UserModel? user;
  bool? followed;
  var _firestore = FirebaseFirestore.instance;
  var id;
  var db = Database();
  @override
  void initState() {
    user = widget.users;
    id = widget.id;
    checkFollowed(id, user!.id!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!(user!.username!
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase()) ||
            user!.name!
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase())) &&
        widget.searchQuery.isNotEmpty) return Container();
    return InkWell(
      onTap: () {
        Focus.of(Get.context!).unfocus();
        Get.to(() => ProfilePage(userID: user!.id!));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 60, child: UserAvatar(user!.id!)),

            // ClipRRect(
            //   borderRadius: BorderRadius.circular(30),
            //   child: Container(
            //     width: 60,
            //     height: 60,
            //     decoration: BoxDecoration(color: Colors.grey),
            //     child: user.profileURL == null
            //         ? Center(
            //             child: Icon(
            //               Icons.person,
            //               color: Colors.white,
            //               size: 25,
            //             ),
            //           )
            //         : OptimizedCacheImage(
            //             imageUrl: user.profileURL,
            //             placeholder: (context, url) =>
            //                 CircularProgressIndicator(),
            //             errorWidget: (context, url, error) => Icon(Icons.error),
            //           ),
            //   ),
            // ),
            addWidth(10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.username!,
                    style: TextStyle(
                        color: standardContrastColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user!.name!,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${user!.followers} Follower${user!.followers == 1 ? '' : 's'}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            user!.id != id
                ? InkWell(
                    onTap: () {
                      setFollow(id, user!.id!);
                      refreshUser();
                    },
                    child: Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: standardContrastColor, width: 1)),
                      child: Center(
                        child: Text(followed ?? false ? "Friends" : "Follow"),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void setFollow(String myID, String userID) {
    if (followed!) {
      setState(() {
        followed = false;
      });
      _firestore
          .collection("followers")
          .doc(userID)
          .collection("u_followers")
          .doc(myID)
          .delete();
      _firestore
          .collection("following")
          .doc(myID)
          .collection("u_following")
          .doc(userID)
          .delete();

      _firestore
          .collection("users")
          .doc(userID)
          .update({"followers": FieldValue.increment(-1)});
      _firestore
          .collection("users")
          .doc(myID)
          .update({"following": FieldValue.increment(-1)});
    } else {
      setState(() {
        followed = true;
      });
      _firestore
          .collection("followers")
          .doc(userID)
          .collection("u_followers")
          .doc(myID)
          .set({"follow": true});
      _firestore
          .collection("following")
          .doc(myID)
          .collection("u_following")
          .doc(userID)
          .set({"follow": true});

      _firestore
          .collection("users")
          .doc(userID)
          .update({"followers": FieldValue.increment(1)});
      _firestore
          .collection("users")
          .doc(myID)
          .update({"following": FieldValue.increment(1)});
      // print(_followed.value);
    }
  }

  void checkFollowed(String myID, String userID) async {
    var followRef = _firestore.collection("followers").doc(userID);
    var docSnapshot = await followRef.collection("u_followers").doc(myID).get();
    if (docSnapshot.exists) {
      if (mounted)
        setState(() {
          followed = true;
        });
      print("check true");
    } else {
      if (mounted)
        setState(() {
          followed = false;
        });
      print("check tru");
    }
    print("function called " + userID);
  }

  void refreshUser() async {
    user = await db.getUser(user!.id!);
    setState(() {});
  }
}
/*
class FollowTile extends StatelessWidget {

  UserModel user ;
  FollowTile(this.user);

  @override
  Widget build(BuildContext context) {
      return GetX(
        init: Get.put(FollowController()),
        builder:(FollowController controller) {
          var id = Get.find<AuthController>().user.uid ;
          controller.checkFollowed(id, user.id);

          return Padding(
          padding: const EdgeInsets.symmetric(vertical :10.0,horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey
                  ),
                  child: user.profileURL == null
                      ? Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 25,
                    ),
                  )
                      :  OptimizedCacheImage(
                    imageUrl: user.profileURL,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              addWidth(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    addHeight(5),
                    Text(
                      user.name,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      user.followers.toString()+ " followers",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              user.id != id ? InkWell(
                onTap: (){
                  controller.setFollow(id,user.id);
                },
                child: Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black,width: 1)
                  ),
                  child: Center(child: Text(controller.followed ? "Following" : "Follow"),),
                ),
              ) : Container(),
            ],
          ),
        );
        }
      );
  }
}
*/

// class FollowButton extends StatefulWidget {
//   UserModel userModel;
//   final String uid;
//   final double width;

//   FollowButton({Key key, this.userModel, this.uid, this.width})
//       : super(key: key);

//   @override
//   _FollowButtonState createState() => _FollowButtonState();
// }

// class _FollowButtonState extends State<FollowButton> {
//   var currentUserID = Get.find<UserController>().currentUid;

//   get followed => null;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     if (widget.uid != null) getUser();
//     print(widget.userModel);
//     print("current uid $currentUserID");
//     print(Get.find<UserController>().userModel);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<FollowController>(
//       init: FollowController(),
//       initState: (_) {},
//       builder: (controller) {
//         return StreamBuilder<String>(
//             stream: controller.buttonStatus(currentUserID, widget.userModel.id),
//             builder: (context, snapshot) {
//               return InkWell(
//                 onTap: () async {
//                   await controller.toggleFollow(
//                       currentUserID, widget.userModel.id);
//                   setState(() {});
//                   controller.update();
//                 },
//                 child: Container(
//                   width: widget.width ?? Get.width * 0.45,
//                   height: 30,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                           color: Get.isDarkMode ? Colors.white : Colors.black,
//                           width: 1)),
//                   child: Center(
//                     child: !snapshot.hasData
//                         ? Text(controller.initialStringValue(
//                             currentUserID, widget.userModel.id))
//                         : Text(snapshot?.data ?? ""),
//                   ),
//                 ),
//               );
//             });
//       },
//     );
//   }

//   void getUser() async {
//     widget.userModel = await UserDatabase().getUser(widget.uid);
//     setState(() {});
//   }
// }

class FollowButton extends StatefulWidget {
  UserModel? userModel;
  final String? uid;
  final double? width;
  final bool notificationMode;

  FollowButton(
      {Key? key,
      this.userModel,
      this.uid,
      this.width,
      this.notificationMode = false})
      : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  var currentUserID = Get.find<UserController>().currentUid;

  get followed => null;
  @override
  void initState() {
    super.initState();
    if (widget.uid != null) getUser();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FollowController>(
      init: FollowController(),
      initState: (_) {},
      builder: (controller) {
        return StreamBuilder<DocumentSnapshot>(
            stream: controller.db
                .followingCollection(currentUserID)
                .doc(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox.shrink();
              }
              if (!snapshot.hasData) return followButtonBody(snapshot);
              if (widget.notificationMode && snapshot.data!.exists)
                return Container();

              return InkWell(
                onTap: () async {
                  print("Following");
                  await controller.toggleFollow(
                      currentUserID,
                      widget.uid!.isNotEmpty
                          ? widget.uid!
                          : widget.userModel!.id!,
                      isFollowing: snapshot.data!.exists);
                  if (mounted) setState(() {});
                  controller.update();
                },
                child: followButtonBody(snapshot),
              );

              // return TapDebouncer(
              //   onTap: () async {
              //     log("Following");
              //     await controller.toggleFollow(
              //         currentUserID,
              //         widget.uid!.isNotEmpty
              //             ? widget.uid!
              //             : widget.userModel!.id!,
              //         isFollowing: snapshot.data!.exists);
              //     if (mounted) setState(() {});
              //     controller.update();
              //   },
              //   builder: (BuildContext context, TapDebouncerFunc? onTap) {
              //     return InkWell(
              //       onTap: onTap,
              //       child: followButtonBody(snapshot),
              //     );
              //   },
              // );
            });
      },
    );
  }

  Container followButtonBody(
      AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
    var isFollowed = snapshot.data?.exists ?? false;
    var isFriend = !isFollowed
        ? false
        : ((snapshot.data!.data() as Map<String, dynamic>)['isFriend'] ?? false)
            as bool;

    return Container(
      width: widget.width ?? Get.width * 0.45,
      height: 30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Get.isDarkMode ? Colors.white : Colors.black, width: 1)),
      child: Center(
        child: !snapshot.hasData
            ? Text('Follow')
            : Text(
                isFollowed
                    ? isFriend
                        ? "Friends"
                        : "Following"
                    : "Follow",
              ),
      ),
    );
  }

  void getUser() async {
    widget.userModel = await UserDatabase().getUser(widget.uid!);
    setState(() {});
  }
}
