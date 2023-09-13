import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/widgets/cookbook_page.dart';

class HealthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      init: UserController(),
      initState: (_) {},
      builder: (controller) {
        return CookbookPage(
          uid: controller.userModel.id!,
          username: controller.userModel.username!,
          healthMode: true,
          isRoot: true,
        );
      },
    );
  }
}
