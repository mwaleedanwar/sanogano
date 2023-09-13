import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/followRequestModel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class ViewAllFollowRequests extends StatefulWidget {
  const ViewAllFollowRequests({Key? key}) : super(key: key);

  @override
  _ViewAllFollowRequestsState createState() => _ViewAllFollowRequestsState();
}

class _ViewAllFollowRequestsState extends State<ViewAllFollowRequests> {
  var db = Database();
  var currentUser = Get.find<UserController>().userModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "Follow Requests",
      ),
      body: GetBuilder<FollowController>(
        init: FollowController(),
        initState: (_) {},
        builder: (controller) {
          return PaginateFirestore(
              isLive: true,
              onEmpty: Center(child: Text("No Requests")),
              itemBuilder: (_, docs, index) {
                var request = FollowRequestModel.fromFirestore(docs[index]);
                return UserHeaderTile(
                  uid: request.senderId!,
                  viewFollow: request.isAccepted,
                  trailing: request.isAccepted
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await controller.acceptFollowRequest(request);
                              },
                              icon: Icon(Icons.check),
                            ),
                            IconButton(
                              onPressed: () async {
                                await controller.rejectFollowRequest(request);
                              },
                              icon: Icon(Icons.clear_outlined),
                            ),
                          ],
                        ),
                );
              },
              shrinkWrap: true,
              query: db
                  .followRequests(currentUser.id!)
                  .orderBy('timestamp', descending: true),
              itemBuilderType: PaginateBuilderType.listView);
        },
      ),
    );
  }
}
