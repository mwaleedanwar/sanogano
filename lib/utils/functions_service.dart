import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  static Future<HttpsCallableResult> callFunction(String name,
      [dynamic parameters]) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable(name);
    return callable.call(parameters);
  }
}
