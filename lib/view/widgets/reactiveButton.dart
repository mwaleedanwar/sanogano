import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class ReactiveButton extends StatefulWidget {
  /// Must point to a document and the button state will be based on the existence of the document

  final DocumentReference existenceQuery;
  final Widget Function(BuildContext context) existencebuilder;
  final Widget Function(BuildContext context) absencebuilder;
  final void Function(bool) onToggle;

  const ReactiveButton(
      {Key? key,
      required this.existenceQuery,
      required this.existencebuilder,
      required this.absencebuilder,
      required this.onToggle})
      : super(key: key);

  @override
  State<ReactiveButton> createState() => _ReactiveButtonState();
}

class _ReactiveButtonState extends State<ReactiveButton> {
  bool exists = false;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReactiveButtonController>(
      init: ReactiveButtonController(widget.existenceQuery),
      initState: (_) {},
      builder: (c) {
        return GestureDetector(
          onTap: () {
            c.exists.value = !c.exists.value;
            //  c.update();
            widget.onToggle(c.exists.value);
          },
          child: StreamBuilder<bool>(
            stream:
                widget.existenceQuery.snapshots().map((event) => event.exists),
            initialData: exists,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              exists = snapshot.data;
              return exists
                  ? widget.existencebuilder(context)
                  : widget.absencebuilder(context);
            },
          ),
        );
      },
    );
  }
}

class ReactiveButtonController extends GetxController {
  var exists = false.obs;
  final DocumentReference existenceQuery;

  ReactiveButtonController(this.existenceQuery);
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    debounce<bool>(
      exists,
      ((callback) async {
        if (callback)
          await existenceQuery.set({'timestamp': FieldValue.serverTimestamp()});
        if (!callback) await existenceQuery.delete();
      }),
      time: 1.seconds,
    );
  }
}
