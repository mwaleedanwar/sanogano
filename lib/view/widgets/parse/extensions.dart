import 'package:validated/validated.dart';

extension SanoganoExtensions on String {
  bool get isValidUsername {
    if (this.isEmpty) {
      return false;
    }
    if (this.contains('@')) {
      return false;
    }
    // if (this.length > 17) {
    //  return false;
    // }

    if (isEmoji(this)) {
      return false;
    }

    if (this.contains(" ")) {
      return false;
    }

    for (var i = 1; i < this.length; i++) {
      if (RegExp(r'[a-zA-Z0-9_]').hasMatch(this[i])) {
      } else {
        return false;
      }
    }

    // for (var i = 0; i < this.length; i++) {
    //   if (RegExp(r'[a-zA-Z0-9_]').hasMatch(this)) {
    //   } else {
    //     return false;
    //   }
    // }
    return true;
  }
}
