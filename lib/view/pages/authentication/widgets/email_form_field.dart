import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

import 'input_decor.dart';

class EmailFormField extends StatelessWidget {
  TextEditingController controller;

  EmailFormField(this.controller);

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      controller: controller,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'email is required';
        }
        if (!GetUtils.isEmail(value)) {
          return 'email is not valid';
        }
        return null;
      },
      decoration: inputDecoration("Email and Username"),
    );
  }
}
