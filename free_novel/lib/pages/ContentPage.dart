import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novel/db/NovelDatabase.dart';

class ContentPage extends StatefulWidget{
  ContentPage({this.arguments});
  final Map arguments;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    if(!arguments.containsKey('id')) {
      throw UnimplementedError("parameter id not exist");
    }
    if(!arguments.containsKey('page')) {
      return ContentState(arguments['id']);
    }
    return ContentState(arguments['id'], page: arguments['page']);
  }
}

class ContentState extends State<ContentPage>{
  ContentState(this._id, {this.page = 0});
  final int _id;
  int page;
  String _content = "";

  @override
  void initState() {
    // TODO: implement initState
    loadContent();
    super.initState();
  }

  loadContent() async{
    final content = await NovelDatabase.getInstance().getNovelContent(_id, page);
    //print("content:$content");
    setState(() {
      _content = content;//.replaceAll("<br><br>", "\n");
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: goBack,),
        title: new Text("Content page"), centerTitle: true,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: true,
// 内容
      slivers: <Widget>[
        new SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: new SliverList(
            delegate: new SliverChildListDelegate(
              <Widget>[
                new Text(_content,style: TextStyle(fontSize: 18),),
              ],
            ),
          ),
        ),
      ],
    );
  }

  goBack() {
    Navigator.of(context).pop();
  }
}