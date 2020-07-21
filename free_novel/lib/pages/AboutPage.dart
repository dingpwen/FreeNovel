
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget{
  final String _address = "wenpd8@foxmail.com";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(child: Text("软件说明"),);
  }

  void sendEmail(String email) => launch("mailto:$_address");
}