import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class SearchedUserAccounts extends StatefulWidget {
  // UserModel users ;
  String id;
  String name;
  String username;
  String profileURL;
  int followers;
  String userID;

  SearchedUserAccounts(this.id, this.name, this.username, this.profileURL,
      this.followers, this.userID);

  @override
  _SearchedUserAccountsState createState() => _SearchedUserAccountsState();
}

class _SearchedUserAccountsState extends State<SearchedUserAccounts> {
  //UserModel user ;
  bool? followed;
  var _firestore = FirebaseFirestore.instance;
  var id;

  @override
  void initState() {
    //user = widget.users ;
    id = widget.id;
    checkFollowed(id, widget.userID);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
              onTap: () {
                print(widget.userID.trim());
              },
              child: UserAvatar(
                widget.userID,
              )),
          addWidth(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    print(widget.userID.trim());
                    Get.to(ProfilePage(userID: widget.userID.trim()));
                  },
                  child: Text(
                    widget.username,
                    style: TextStyle(
                        color: standardContrastColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                addHeight(2),
                Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                FollowerTextWidget(
                  uid: widget.userID,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                )
                // status == FollowStatus.friends
                //     ? Text(
                //         "Friends",
                //         style: TextStyle(
                //           color: Colors.grey,
                //           fontSize: 14,
                //         ),
                //       )
                //     : status == FollowStatus.notFollowing
                //         ? Text(
                //             "not Following",
                //             style: TextStyle(
                //               color: Colors.grey,
                //               fontSize: 14,
                //             ),
                //           )
                //         //
                //         : Text(
                //             "Following",
                //             style: TextStyle(
                //               color: Colors.grey,
                //               fontSize: 14,
                //             ),
                //           )
              ],
            ),
          ),
          // FollowButton(
          //   uid: widget.userID,
          //   // userModel: UserModel(id: widget.userID),
          //   width: Get.width * 0.25,
          // ),
        ],
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
      setState(() {
        followed = true;
      });
    } else {
      setState(() {
        followed = false;
      });
    }
  }
}
