import 'package:flutter/material.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "About",
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            onTap: () => launch('https://www.sanogano.com/privacy'),
            title: Text(
              "Privacy Policy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: forwardDIcon,
          ),
          ListTile(
            onTap: () => launch('https://www.sanogano.com/terms'),
            title: Text(
              "Terms of Use",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: forwardDIcon,
          ),
        ],
      ),
    );
  }
}
