import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/view/global/space.dart';

class UserTile extends StatefulWidget {
  final String uid;
  final UserModel? userModel;
  final String subtitleText;
  final String timestamp;
  final bool isChatTile;

  const UserTile(
      {Key? key,
      required this.uid,
      this.userModel,
      required this.subtitleText,
      required this.timestamp,
      this.isChatTile = false})
      : super(key: key);

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  var loaded = false;
  late UserModel userModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.userModel == null) {
      getUser();
    } else {
      userModel = widget.userModel!;
      loaded = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return !loaded
        ? ListTile()
        : InkWell(
            onTap: () {
              if (widget.isChatTile) {
                //Get.to(() => ChatPage(userModel.id!, false));
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.grey),
                    child: userModel.profileURL == null
                        ? Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 25,
                            ),
                          )
                        : ClipOval(
                            child: Image.network(userModel.profileURL!,
                                fit: BoxFit.fill)),
                  ),
                  addWidth(10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              userModel.name!,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              widget.timestamp.isNotEmpty
                                  ? widget.timestamp
                                  : "",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        addHeight(5),
                        Text(
                          widget.subtitleText.isNotEmpty
                              ? widget.subtitleText
                              : userModel.username!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void getUser() async {
    try {
      userModel = (await UserDatabase().getUser(widget.uid));
      setState(() {
        loaded = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class GroupChatTile extends StatelessWidget {
  final String groupName;
  final String chatID;
  final String subtitleText;
  final String timestamp;
  final bool isChatTile;

  const GroupChatTile(
      {Key? key,
      required this.groupName,
      required this.chatID,
      required this.subtitleText,
      required this.timestamp,
      required this.isChatTile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40), color: Colors.grey),
              child: CircleAvatar(
                child: Text(
                  groupName[0].toUpperCase(),
                  style: GoogleFonts.nunito(),
                ),
              ),
            ),
            addWidth(10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        groupName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        timestamp.isNotEmpty ? timestamp : "",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  addHeight(5),
                  Text(
                    subtitleText.isNotEmpty ? subtitleText : "",
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
