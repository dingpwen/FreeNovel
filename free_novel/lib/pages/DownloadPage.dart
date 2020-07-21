
import 'package:flutter/material.dart';

class DownloadPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return DownloadState();
  }

}

class DownloadState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("下载书籍"),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context){
    return Center(child: Text("书籍下载页面"),);
  }
}