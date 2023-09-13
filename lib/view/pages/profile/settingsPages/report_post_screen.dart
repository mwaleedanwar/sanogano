import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';

import 'comment_settings_screen.dart';

class ReportPostScreen extends StatefulWidget {
  const ReportPostScreen({Key? key}) : super(key: key);

  @override
  State<ReportPostScreen> createState() => _ReportPostScreenState();
}

final TextStyle ts = TextStyle(fontWeight: FontWeight.bold);
var reportlist = [
  "Animal Cruelty",
  "Bullying or Harassment",
  "Dangerous Individual or Organization",
  "False Information",
  "Hate Speech or Symbols",
  "Intellectual Property Infringement",
  "Nudity or Sexual Activity",
  "Sale of Illegal or Regulated Goods",
  "Scam or Fraud",
  "Spam",
  "Suicide, Self-Injury, or Dangerous Acts",
  "Violent or Graphic Content",
];

class _ReportPostScreenState extends State<ReportPostScreen> {
  var pc = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "Report",
        iconButton: Container(),
      ),
      body: ListView(
        children: [
          ...List.generate(
            reportlist.length,
            (index) => ListTile(
              onTap: () => Get.back(result: reportlist[index]),
              trailing: forwardDIcon,
              title: Text(
                reportlist[index],
                style: ts,
              ),
            ),
          )
        ],
      ),
    );
  }
}
