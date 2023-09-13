import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

import '../../../const/iconAssetStrings.dart';
import '../../../controllers/theme_controller.dart';

class FollowingSelectionScreen extends StatefulWidget {
  final Function(List<String>) selectedIds;

  const FollowingSelectionScreen({Key? key, required this.selectedIds})
      : super(key: key);

  @override
  State<FollowingSelectionScreen> createState() =>
      _FollowingSelectionScreenState();
}

class _FollowingSelectionScreenState extends State<FollowingSelectionScreen> {
  var c = Get.put(FollowController());
  TextEditingController _searchController = TextEditingController();
  var loaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  var fList = <String>[];
  var uc = Get.find<UserController>();
  init() async {
    fList = await FollowDatabase().getFollowingList(uc.userModel.id!);
    setState(() {
      loaded = true;
    });
  }

  bool multiSelect = false;
  List<String> selectedIds = [];
  RxInt selectedCount = 0.obs;
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
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: backDIcon.copyWith(size: 20)),
        elevation: 0,
        title: Text(
          "New Member",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Get.textTheme.bodyText1!.color),
        ),
        actions: [
          Obx(() {
            return TextButton(
                onPressed: () async {
                  if (selectedCount.value > 0) {
                    Get.back<List<String>>(result: selectedIds);
                  }
                },
                child: Opacity(
                  opacity: selectedCount.value > 0 ? 1 : 0.5,
                  child: Text(
                    "Add",
                    style: TextStyle(
                        color: Color(Get.find<ThemeController>().globalColor),
                        fontWeight: FontWeight.bold),
                  ),
                ));
          })
        ],
      ),
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
                          disableProfileOpening: true,
                          searchQuery: _searchController.text,
                          withFollowers: false,
                          viewFollow: false,
                          viewTrailing: true,
                          trailing:
                              StatefulBuilder(builder: (context, refresh) {
                            return IconButton(
                                onPressed: () {
                                  if (selectedIds.contains(fList[index])) {
                                    selectedIds.remove(fList[index]);
                                    refresh(() {});
                                    selectedCount.value = selectedIds.length;
                                  } else {
                                    selectedIds.add(fList[index]);
                                    refresh(() {});
                                    selectedCount.value = selectedIds.length;
                                  }
                                },
                                icon: selectedIds.contains(fList[index])
                                    ? selectedIcon
                                    : selectIcon);
                          }),
                          // onSelect: null,
                          // onTap: () {},
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}

  //  Checkbox(
                            //     value: selectedIds.contains(fList[index]),
                            //     onChanged: (value) {
                            //       if (!(value ?? true)) {
                            //         selectedIds.remove(fList[index]);
                            //         refresh(() {});
                            //       } else {
                            //         selectedIds.add(fList[index]);
                            //         refresh(() {});
                            //       }
                            //     },
                            //     shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(5)));