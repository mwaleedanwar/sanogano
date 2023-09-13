import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/view/pages/chat/chat_page.dart';
import 'package:sano_gano/view/pages/chat/stream_chat_controller.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

import '../../../controllers/theme_controller.dart';
import '../../global/custom_icon.dart';

class FollowingPage extends StatefulWidget {
  final String id;
  FollowingPage(
    this.id, {
    this.onSelect,
    this.singleSelectionOnly = false,
  });
  final bool singleSelectionOnly;
  final Function(UserModel)? onSelect;

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  var c = Get.put(FollowController());
  TextEditingController _searchController = TextEditingController();
  var loaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  bool get selectionMode => widget.onSelect != null;
  var fList = <String>[];
  init() async {
    fList = await FollowDatabase().getFollowingList(widget.id);
    setState(() {
      loaded = true;
      if (fList.contains(uc.currentUid)) {
        fList.sort((a, b) => a == uc.currentUid ? -1 : 1);
      }
    });
  }

  bool multiSelect = false;
  List<String> selectedIds = [];
  RxInt selectedCount = 0.obs;
  UserController uc = Get.find<UserController>();
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
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
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
      appBar: selectionMode
          ? AppBar(
              leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: backDIcon),
              elevation: 0,
              title: multiSelect
                  ? Text(
                      "New Group",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Get.textTheme.bodyText1!.color),
                    )
                  : Text(
                      "New Message",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Get.textTheme.bodyText1!.color),
                    ),
              actions: [
                if (!multiSelect)
                  IconButton(
                    onPressed: () {
                      multiSelect = true;
                      setState(() {});
                    },
                    icon: seeGroupDIcon,
                  ),
                if (multiSelect)
                  Obx(() {
                    return TextButton(
                        onPressed: () async {
                          if (selectedIds.isEmpty) return;
                          var channel = await StreamChatController()
                              .createAndWatchChannel(context,
                                  uids: selectedIds);

                          Get.off(() => ChatPage(channel: channel));
                        },
                        child: Opacity(
                          opacity: selectedCount.value > 0 ? 1 : 0.5,
                          child: Text(
                            "Create",
                            style: TextStyle(
                                color: Color(
                                    Get.find<ThemeController>().globalColor),
                                fontWeight: FontWeight.bold),
                          ),
                        ));
                  })
              ],
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearch(),
            StreamBuilder<String>(
                stream: Stream.value(_searchController.text),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: fList.length,
                      itemBuilder: (_, index) {
                        return UserHeaderTile(
                          uid: fList[index],
                          profileAvatarSize: 24,
                          disableProfileOpening: selectionMode,
                          searchQuery: _searchController.text,
                          withFollowers: !selectionMode,
                          viewFollow: !selectionMode,
                          isFromSearch: false,
                          viewTrailing: !selectionMode || multiSelect,
                          // viewTrailing: true,
                          trailing: fList[index] == uc.currentUid
                              ? null
                              : StatefulBuilder(builder: (context, refresh) {
                                  return IconButton(
                                      onPressed: () {
                                        var value =
                                            selectedIds.contains(fList[index]);
                                        if ((value)) {
                                          selectedIds.remove(fList[index]);
                                          refresh(() {});
                                          selectedCount.value--;
                                        } else {
                                          selectedIds.add(fList[index]);
                                          selectedCount.value++;
                                          refresh(() {});
                                        }
                                      },
                                      icon: selectedIds.contains(fList[index])
                                          ? selectedIcon
                                          : selectIcon);
                                }),
                          onSelect: multiSelect
                              ? null
                              : selectionMode
                                  ? (user) {
                                      if (widget.onSelect != null) {
                                        widget.onSelect!(user);
                                        Get.back();
                                      }
                                    }
                                  : null,
                          onTap: () {},
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
