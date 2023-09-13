import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/view/pages/search/search_screen_body.dart';
import 'package:sano_gano/view/widgets/comment_widget.dart';

import '../../../controllers/search_controller.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();

  SearchController searchController = Get.find<SearchController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: CupertinoSearchTextField(
                // key: Key("SearchField"),
                focusNode: sfc.focus,
                borderRadius: BorderRadius.circular(25),
                controller: searchController.textFieldController,
                style: blackText,

                onSuffixTap: () {
                  searchController.clearSearchField(showRecentSearches: false);
                },
                onSubmitted: (String _) {},
              ),
            ),
            sfc.showRecent
                ? Expanded(child: SearchScreenBody())
                : Expanded(
                    child: DefaultTabController(
                        length: 4, child: SearchScreenBody()))
          ],
        ),
      );
    });
    // return buildUserSearch();
  }
}




































// * junk code

//   Padding buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(15.0),
//       child: TextField(
//         controller: searchController.textFieldController,
//         style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
//         keyboardType: TextInputType.text,
//         onChanged: (value) {},
//         decoration: InputDecoration(
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             color: Colors.black,
//           ),
//           hintText: 'Search',
//           hintStyle: TextStyle(color: Colors.grey),
//           contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black, width: 1.0),
//             borderRadius: BorderRadius.all(Radius.circular(25.0)),
//           ),
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black, width: 1.0),
//             borderRadius: BorderRadius.all(Radius.circular(25.0)),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black, width: 2.0),
//             borderRadius: BorderRadius.all(Radius.circular(25.0)),
//           ),
//         ),
//       ),
//     );
//   }




  // init() async {
  //   _defaultUsers.value = await defaultUserSearchResults();
  //   // setState(() {});
  // }

  // Widget buildInitial(int index) {
  //   if (searchController.isInitialDataEmpty) {
  //     return Container();
  //   }
  //   return ListView.builder(
  //     itemCount: searchController.initialTrendingData[index]!.length,
  //     itemBuilder: (_, i) {
  //       var data = searchController.initialTrendingData[index]![i];
  //       switch (index) {
  //         case 0:
  //           return UserHeaderTile(
  //             uid: data['id'],
  //             userModel: UserModel.fromJson(data),
  //             viewFollow: true,
  //             withFollowers: true,
  //             searchMode: true,
  //             isFromSearch: true,
  //           );
  //         case 1:
  //           return HashtagSearchTile(
  //             hashtagModel: HashtagModel.fromMap(data),
  //           );
  //         case 2:
  //           return recipeSearchTile(RecipeModel.fromMap(data));
  //         case 3:
  //           return workoutSearchTile(
  //             WorkoutModel.fromMap(data),
  //           );
  //         default:
  //           return Container();
  //       }
  //     },
  //   );
  // }


   // @override
  // void initState() {
  //   super.initState();
  //   // DefaultTabController.of(Get.context!)!.addListener(() {
  //   //   _currentScreen.value = DefaultTabController.of(Get.context!)!.index;
  //   // });
  //   // textFieldController.addListener(() async {
  //   //   _isSearchActive.value = true;
  //   //   // setState(() {});
  //   //   // if (_textFieldController.text.isEmpty) {
  //   //   //   isSearchActive = false;

  //   //   //   setState(() {});
  //   //   // } else {
  //   //   //   isSearchActive = true;
  //   //   //   setState(() {});
  //   //   // }
  //   //   if (textFieldController.text.isEmpty) {
  //   //     _hitsList.value = [];
  //   //     setState(() {});
  //   //   }

  //   //   if (searchText != textFieldController.text &&
  //   //       textFieldController.text.length > 0) {
  //   //     // setState(() {
  //   //     // });
  //   //     _searchText.value = textFieldController.text;
  //   //     //  TODO uncommend
  //   //     // await _getSearchResult(searchText);
  //   //   }
  //   // });
  //   // init();
  // }
