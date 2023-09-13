import 'package:flutter/material.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';

Widget buildPopupMenu(List<PopupItem> items, {Widget? icon}) {
  for (var i = 0; i < items.length; i++) {
    items[i].index = i;
  }
  return PopupMenuButton<int>(
    icon: icon ?? optionsSIcon,
    onSelected: (value) => items[value].callback(),
    itemBuilder: (context) => List.generate(
        items.length,
        (index) => PopupMenuItem<int>(
            value: items[index].index, child: Text(items[index].title))),
  );
}

class PopupItem {
  int? index;
  String title;
  VoidCallback callback;
  PopupItem({
    this.index,
    required this.title,
    required this.callback,
  });
}
