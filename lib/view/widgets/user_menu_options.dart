import 'package:flutter/material.dart';
import 'package:sano_gano/models/user.dart';

enum UserMenuOptions {
  Report,
  Block,
}

buildUserMenuOptions(UserModel user, bool isMe,
    {required void Function(UserMenuOptions) onSelectCallback}) {
  return PopupMenuButton<UserMenuOptions>(
    onSelected: onSelectCallback,
    itemBuilder: (BuildContext context) => <PopupMenuEntry<UserMenuOptions>>[
      if (!isMe)
        const PopupMenuItem<UserMenuOptions>(
          value: UserMenuOptions.Report,
          child: Text('Report'),
        ),
      if (!isMe)
        const PopupMenuItem<UserMenuOptions>(
          value: UserMenuOptions.Block,
          child: Text('Block'),
        ),
    ],
  );
}

enum LeaderboardFilterOptions { ALL, FRIENDS }
buildFilterOptions({
  required void Function(LeaderboardFilterOptions) onSelectCallback,
  Widget? icon,
}) {
  return PopupMenuButton<LeaderboardFilterOptions>(
    onSelected: onSelectCallback,
    icon: icon,
    itemBuilder: (BuildContext context) =>
        <PopupMenuEntry<LeaderboardFilterOptions>>[
      const PopupMenuItem<LeaderboardFilterOptions>(
        value: LeaderboardFilterOptions.ALL,
        child: Text('All'),
      ),
      const PopupMenuItem<LeaderboardFilterOptions>(
        value: LeaderboardFilterOptions.FRIENDS,
        child: Text('Friends'),
      ),
    ],
  );
}
