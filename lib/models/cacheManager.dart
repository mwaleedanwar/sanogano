class CacheManager {
  Map<String, List<Map<String, dynamic>>> data = {};

  List<Map<String, dynamic>> getData(String key) {
    if (data.containsKey(key)) return data[key]!;
    return [];
  }
}
