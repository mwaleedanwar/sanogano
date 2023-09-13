import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

import '../../../controllers/user_controller.dart';

class FollowerPage extends StatefulWidget {
  String id;
  FollowerPage(this.id);

  @override
  State<FollowerPage> createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  TextEditingController _searchController = TextEditingController();
  var c = Get.put(FollowController());
  var loaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  UserController uc = Get.find<UserController>();
  var fList = <String>[];
  init() async {
    fList = await FollowDatabase().getFollowerList(widget.id);
    // print(fList.length);
    setState(() {
      loaded = true;
      if (fList.contains(uc.currentUid)) {
        fList.sort((a, b) => a == uc.currentUid ? -1 : 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildSearch() {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: standardContrastColor),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            setState(() {});
          },
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            fillColor: Colors.grey.withOpacity(0.25),
            filled: true,
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey, letterSpacing: 0.5),
            contentPadding:
                EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
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

    return Scaffold(
      body: loaded
          ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearch(),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: fList.length,
                      itemBuilder: (_, index) {
                        return UserHeaderTile(
                          uid: fList[index],
                          profileAvatarSize: 24,
                          searchQuery: _searchController.text,
                          withFollowers: true,
                          viewFollow: true,
                          viewTrailing: true,
                          isFromSearch: false,
                          onTap: () {},
                        );
                      })
                ],
              ),
            )
          : Center(
              child: SpinKitRotatingCircle(
                color: Colors.black,
                size: 50.0,
              ),
            ),

      //  GetX<FollowController>(
      //     init: Get.put(FollowController()),
      //     builder: (FollowController controller) {
      //       var myID = Get.find<AuthController>().user.uid;
      //       controller.getFollowersUserStream(widget.id);
      //       List<UserModel> filteredList = controller.followers;
      //       if (controller != null && controller.followers != null) {
      //         return SingleChildScrollView(
      //           child: Column(
      //             children: [
      //               _buildSearch(),
      //               ListView.builder(
      //                   shrinkWrap: true,
      //                   physics: NeverScrollableScrollPhysics(),
      //                   itemCount: fList.length,
      // itemBuilder: (_, index) {
      //   UserModel _user = filteredList[index];
      //   return FollowTile(
      //     _user,
      //     myID,
      //     searchQuery: _searchController.text,
      //   );
      // })
      //             ],
      //           ),
      //         );
      //       } else {
      //         return Center(
      //           child: SpinKitRotatingCircle(
      //             color: Colors.black,
      //             size: 50.0,
      //           ),
      //         );
      //       }
      //     }),
    );
  }
}
