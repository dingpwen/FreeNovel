import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novel/db/Novel.dart';
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
  Novel _novel;

  @override
  void initState() {
    // TODO: implement initState
    loadContent();
    super.initState();
  }

  loadContent() async{
    final novel = await NovelDatabase.getInstance().getNovelContent(_id, page);
    //print("content:$content");
    setState(() {
      _novel = novel;
      //_content = content;//.replaceAll("<br><br>", "\n");
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = (_novel == null)?"加载中...":_novel.title;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: goBack,),
        title: new Text(title), centerTitle: true,
      ),
      body: (_novel == null)?Center(child: Text("加载中..."),):_buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final String content = _novel.content;
    return CustomScrollView(
      shrinkWrap: true,
// 内容
      slivers: <Widget>[
        new SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: new SliverList(
            delegate: new SliverChildListDelegate(
              <Widget>[
                new Text(content, style: TextStyle(fontSize: 18),),
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