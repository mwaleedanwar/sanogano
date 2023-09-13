import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/utils/database.dart';

import 'controllers/follow_controller.dart';
import 'models/user.dart';
import 'view/pages/search/generic_prefix_search.dart';
import 'view/widgets/user_header_tile.dart';

String createChatID(String a, String b) {
  if (a.compareTo(b) > 0) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}

class GiphyCustomWidget extends StatelessWidget {
  final GiphyGif gif;

  const GiphyCustomWidget({Key? key, required this.gif}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GiphyGifWidget(
          gif: gif,
          showGiphyLabel: false,
          borderRadius: BorderRadius.circular(17),
          imageAlignment: Alignment.center,
          giphyGetWrapper: GiphyGetWrapper(
              giphy_api_key: Platform.isIOS
                  ? "RDC1STU4vHsYmJGjsRtlEdxlZWdYOMPl"
                  : "T7ssrBOfOqGeio4GInFH4H1lx9HzeAzz",
              builder: (_, __) => Container())),
    );
  }
}

Future<void> triggerMentions(
    {required Function(UserModel) onSelect,
    dynamic Function(UserModel)? onSelectUserWhenEmpty,
    List<String>? removeUsers,
    // Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)?
    //     itemBuilder,
    List<String>? onlyShow}) async {
  await Get.bottomSheet(
    Material(
      child: GenericPrefixSearch(
        // itemBuilder: itemBuilder,
        onlyShow: onlyShow,
        onEmpty: ListView.builder(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: Get.find<UserController>().followingList.length,
          itemBuilder: (BuildContext context, int index) {
            return UserHeaderTile(
              onSelect: onSelectUserWhenEmpty,
              uid: Get.find<UserController>().followingList[index],
              disableProfileOpening: true,
            );
          },
        ),
        onSelect: onSelect,
      ),
    ),
  );
  return;
}

class DebounceIconButton extends StatefulWidget {
  final bool initialState;
  final Widget falseState;
  final Widget trueState;
  final Future<bool> onPressed;

  const DebounceIconButton(
      {Key? key,
      required this.initialState,
      required this.falseState,
      required this.trueState,
      required this.onPressed})
      : super(key: key);

  @override
  State<DebounceIconButton> createState() => _DebounceIconButtonState();
}

class _DebounceIconButtonState extends State<DebounceIconButton> {
  bool currentState = false;

  @override
  void initState() {
    super.initState();
    currentState = widget.initialState;
  }

  var loading = false;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: loading
          ? CupertinoActivityIndicator()
          : currentState
              ? widget.trueState
              : widget.falseState,
      onPressed: () async {
        if (loading) return;
        print("running");
        try {
          setState(() {
            loading = true;
          });
          currentState = await widget.onPressed;
          setState(() {
            loading = false;
          });
        } on Exception catch (e) {
          loading = false;
          print(e);
        }
      },
    );
  }
}


//junk 
// Future<void>  triggerMentions(
//     {required Function(DocumentSnapshot<Object?>) onSelect,
//     dynamic Function(UserModel)? onSelectUserWhenEmpty,
//     Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)?
//         itemBuilder,
//     List<String>? evaluateAndRemoveThese}) async {
//   await Get.bottomSheet(
//     Material(
//       child: GenericPrefixSearch(
//         itemBuilder: itemBuilder,
//         fieldName: 'username',
//         collectionReference: Database().usersCollection,
//         evaluateAndRemoveThese: evaluateAndRemoveThese,
//         specialConditonOnEachItem: (doc, index) => FollowController()
//             .isFollowed(Get.find<UserController>().currentUid, doc.id),
//         onEmpty: ListView.builder(
//           physics: ClampingScrollPhysics(),
//           shrinkWrap: true,
//           itemCount: Get.find<UserController>().followingList.length,
//           itemBuilder: (BuildContext context, int index) {
//             return UserHeaderTile(
//               onSelect: onSelectUserWhenEmpty,
//               uid: Get.find<UserController>().followingList[index],
//               disableProfileOpening: true,
//             );
//           },
//         ),
//         onSelect: onSelect,
//       ),
//     ),
//   );
//   return;
// }