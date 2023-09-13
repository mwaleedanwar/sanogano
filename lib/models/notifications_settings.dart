import 'dart:convert';

import 'package:sano_gano/services/notificationService.dart';

class NotificationSettings {
  Map<NotificationType, bool>? notificationSettings;
  NotificationSettings({
    this.notificationSettings,
  });

  Map<String, dynamic> toMap() {
    return Map.fromEntries(List.generate(NotificationType.values.length,
        (index) => MapEntry(NotificationType.values[index].toString(), true)));
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    var finalMap = map.map<NotificationType, bool>(
        (key, value) => MapEntry(getNotificationType(key), value));
    return NotificationSettings(
      notificationSettings: finalMap,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationSettings.fromJson(String source) =>
      NotificationSettings.fromMap(json.decode(source));

  static NotificationType getNotificationType(String name) {
    return NotificationType.values.firstWhere(
        (element) => element.toString().toLowerCase() == name.toLowerCase(),
        orElse: () => NotificationType.GENERIC);
  }
}
