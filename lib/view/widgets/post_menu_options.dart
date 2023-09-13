import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/models/postmodel.dart';

enum PostMenuOption { Report, Delete, Edit }
Widget buildPostMenuOptions(PostModel postModel, bool isOwner,
    {void Function(PostMenuOption)? onSelectCallback}) {
  return PopupMenuButton<PostMenuOption>(
    child: Container(
      padding: EdgeInsets.only(right: Get.width * 0.02),
      child: optionsSIcon,
    ),
    padding: EdgeInsets.zero,
    onSelected: onSelectCallback,
    itemBuilder: (BuildContext context) => <PopupMenuEntry<PostMenuOption>>[
      // if (isOwner)
      //   const PopupMenuItem<PostMenuOption>(
      //     value: PostMenuOption.Edit,
      //     child: Text('Edit'),
      //   ),
      if (isOwner)
        const PopupMenuItem<PostMenuOption>(
          value: PostMenuOption.Delete,
          child: Text('Delete'),
        ),
      if (!isOwner)
        const PopupMenuItem<PostMenuOption>(
          value: PostMenuOption.Report,
          child: Text('Report'),
        ),
    ],
  );
}
