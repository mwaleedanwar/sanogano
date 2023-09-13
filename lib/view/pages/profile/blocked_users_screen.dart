import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  var db = Database();
  var userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          back: true,
          title: "Blocked Accounts",
        ),
        body: PaginateFirestore(
            isLive: true,
            onEmpty: Container(
                height: Get.height * 0.1,
                width: Get.width,
                padding: EdgeInsets.only(
                    top: Get.height * 0.35,
                    left: Get.width * 0.33,
                    right: Get.width * 0.3),
                child: Text("")),
            itemBuilder: (_, docs, index) {
              var id = docs[index].id;
              return UserHeaderTile(
                  uid: id,
                  viewTrailing: true,
                  trailing: InkWell(
                    onTap: () async {
                      await userController.unblockUser(id);
                      setState(() {});
                    },
                    child: Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: standardContrastColor, width: 1)),
                      child: Center(
                        child: Text("Unblock"),
                      ),
                    ),
                  ));
            },
            shrinkWrap: true,
            query: db
                .blockedUsersCollection(userController.currentUid)
                .orderBy('timestamp', descending: true),
            itemBuilderType: PaginateBuilderType.listView));
  }
}
