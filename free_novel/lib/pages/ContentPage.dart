import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:novel/db/Novel.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/search/SearchFactory.dart';
import 'package:novel/utils/SpUtils.dart';

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
  int maxPage = -1;
  Novel _novel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMax();
    loadContent();
  }

  initMax() async {
    if (maxPage == -1) {
      final novel = await NovelDatabase.getInstance().getNovelMaxPage(_id);
      if(novel != null) {
        maxPage = novel.page;
      }
    }
  }

  loadContent() async {
    Novel novel = await NovelDatabase.getInstance().getNovelContent(_id, page);
    //print("content:$content");
    if (novel != null && novel.status == 0) {
      assert(novel.url.isNotEmpty);
      SearchFactory.getDefault().then((search) => {
            search.downloadContent(novel.url, novel.id, novel.page, novel.title,
                complete: (content) {
              novel.content = content;
              SpUtils.savePage(_id, page);
              setState(() {
                _novel = novel;
                //_content = content;//.replaceAll("<br><br>", "\n");
              });
            })
          });
    } else {
      SpUtils.savePage(_id, page);
      setState(() {
        _novel = novel;
        //_content = content;//.replaceAll("<br><br>", "\n");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = (_novel == null) ? "加载中..." : _novel.title;
    final String rightTxt = (page == maxPage) ? "最后一章" : "下一章";
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: goBack,
        ),
        title: new Text(title),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
            child: Center(
                child: Container(
              margin: EdgeInsets.only(right: 20),
              child: Text(
                rightTxt,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6.fontSize,
                    color: (page == maxPage) ? Colors.grey : Colors.white),
              ),
            )),
            onTap: () => nextPage(),
          )
        ],
      ),
      body: (_novel == null)
          ? Center(
              child: Text("加载中..."),
            )
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    String content = _novel.content;
    if(!content.startsWith('<div')) {
      content = '<div>$content</div>';
    }
    return CustomScrollView(
      shrinkWrap: true,
// 内容
      slivers: <Widget>[
        new SliverPadding(
          padding: const EdgeInsets.only(left:10.0, right: 10.0, bottom: 20.0),
          sliver: new SliverList(
            delegate: new SliverChildListDelegate(
              <Widget>[
                Html(
                  data: content,
                  style: {
                    "div": Style(
                    fontSize:FontSize(18),
                    ),
                  },
                ),
                /*new Text(
                  content,
                  style: TextStyle(fontSize: 18),
                ),*/
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

  nextPage() async {
    if (page != maxPage) {
      page++;
    }
    loadContent();
  }
}