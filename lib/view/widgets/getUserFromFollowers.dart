import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class SelectUserScreen extends StatefulWidget {
  final List<String> filter;
  final Function(List<String>) selectionCallback;

  const SelectUserScreen(
      {Key? key, required this.filter, required this.selectionCallback})
      : super(key: key);
  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  var selectedUids = <String>[];

  var _chatController = TextEditingController();
  var _searchController = TextEditingController();
  bool get groupMode => selectedUids.length > 1;
  var sText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Members"),
        actions: [
          TextButton(
              onPressed: selectedUids.isNotEmpty
                  ? () async {
                      widget.selectionCallback(selectedUids);
                      Get.back();
                    }
                  : () {},
              child: selectedUids.isNotEmpty
                  ? Text("Add",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))
                  : Text(
                      "Add",
                      style: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.bold),
                    ))
        ],
      ),
      body: Column(
        children: [
          _buildSearch(),
          Flexible(
            child: GetX<FollowController>(
                init: Get.put(FollowController()),
                builder: (FollowController controller) {
                  var myID = Get.find<AuthController>().user!.uid;
                  controller.getFollowingUserStream(myID);
                  var filtered = controller.following;
                  filtered!.removeWhere(
                      (element) => widget.filter.contains(element.id));
                  if (controller != null && controller.following != null) {
                    return Stack(
                      children: [
                        //_buildSearch(),
                        Positioned.fill(
                          top: 1,
                          child: filtered.isEmpty
                              ? Center(
                                  child: Container(),
                                )
                              : ListView.builder(
                                  shrinkWrap: false,
                                  itemCount: controller.following!.length,
                                  itemBuilder: (_, index) {
                                    if (widget.filter.contains(
                                        controller.following![index].id))
                                      return Container();
                                    UserModel _user =
                                        controller.following![index];
                                    return UserHeaderTile(
                                      uid: _user.id!,
                                      onTap: () {
                                        if (selectedUids.contains(_user.id)) {
                                          selectedUids.remove(_user.id);
                                        } else {
                                          selectedUids.add(_user.id!);
                                        }

                                        setState(() {});
                                      },
                                      searchQuery: sText,
                                      viewTrailing: true,
                                      trailing: selectedUids.contains(_user.id)
                                          ? selectedIcon
                                          : selectIcon,
                                    );
                                  }),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: SpinKitRotatingCircle(
                        color: Colors.black,
                        size: 50.0,
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Align(
        child: Container(
          height: 40,
          child: TextField(
            controller: _chatController,
            style: TextStyle(color: Colors.black),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              /* searchItems = list.where((item) => item.title.toLowerCase().contains(value.toLowerCase())).toList() ;
                  print(value.toString());*/
            },
            decoration: InputDecoration(
              suffixIcon: InkWell(
                  onTap: onPressed,
                  child: Padding(
                      padding: const EdgeInsets.all(7.0), child: sendIcon)),
              hintText: 'Message',
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        controller: _searchController,
        keyboardType: TextInputType.text,
        onChanged: (value) {
          sText = value;
          setState(() {});
        },
        decoration: InputDecoration(
          fillColor: Colors.grey.withOpacity(0.25),
          filled: true,
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey, letterSpacing: 0.5),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
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
}
