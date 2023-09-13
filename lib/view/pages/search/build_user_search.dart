import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/search_controller.dart';

import '../../../models/user.dart';
import '../../widgets/user_header_tile.dart';
import 'build_initial.dart';

class AccountsSearchScreen extends StatelessWidget {
  AccountsSearchScreen({super.key});
  SearchController sc = Get.find<SearchController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(children: <Widget>[
        Expanded(
          child: sc.isHitListEmpty && sc.textFieldController.text.isEmpty
              ? BuildInitial(index: 0)
              : ListView.builder(
                  shrinkWrap: false,
                  itemCount: sc.searchCount,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (_, index) {
                    var user = UserModel.fromJson(sc.hitsList![index].data);
                    return UserHeaderTile(
                      uid: user.id!,
                      userModel: user,
                      viewFollow: true,
                      withFollowers: true,
                      searchMode: true,
                      isFromSearch: true,
                    );
                  }),
        )
      ]);
    });
  }
}
