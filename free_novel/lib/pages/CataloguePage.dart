import 'package:flutter/material.dart';
import 'package:novel/db/Novel.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/pages/ContentPage.dart';

class CataloguePage extends StatefulWidget {
  CataloguePage(this.arguments);
  final Map arguments;
  @override
  State<StatefulWidget> createState() {
    print("arguments:$arguments");
    if (!arguments.containsKey('id')) {
      throw UnimplementedError("parameter id not exist");
    }
    if (!arguments.containsKey('title')) {
      throw UnimplementedError("parameter title not exist");
    }
    return CatalogueState(arguments['id'], arguments['title']);
  }
}

class CatalogueState extends State<CataloguePage> {
  CatalogueState(this._id, this._title);
  final int _id;
  final String _title;
  List<Novel> _catalogue;
  int order = 0;

  @override
  void initState() {
    // TODO: implement initState
    loadCatalogue();
    super.initState();
  }

  loadCatalogue() async {
    List<Novel> novels =
        await NovelDatabase.getInstance().findNovelById(_id, order: order);
    setState(() {
      _catalogue = novels;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String rightTxt = (order == 0) ? "倒 序" : "顺 序";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: goBack,
        ),
        title: new Text(_title),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
            child: Center(
                child: Container(
              margin: EdgeInsets.only(right: 20),
              child: Text(rightTxt, style: TextStyle(fontSize: Theme.of(context).textTheme.headline6.fontSize),),
            )),
            onTap: () => changeOrder(),
          )
        ],
      ),
      body: (_catalogue == null) ? _buildLoading(context) : _buildBody(context),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(child: Text("书籍目录加载中..."));
  }

  Widget _buildBody(BuildContext context) {
    if (_catalogue.length == 0) {
      return Center(child: Text("书籍目录为空"));
    } else {
      return _buildCatalogueListView(context);
    }
  }

  _buildCatalogueListView(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _buildItemView(context, _catalogue[index]);
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 2,
            color: Theme.of(context).primaryColor,
          );
        },
        itemCount: _catalogue.length);
  }

  Widget _buildItemView(BuildContext context, Novel novel) {
    final String statusTxt = (novel.status == 0) ? "未下载" : "已下载";
    return ListTile(
      title: Text("${novel.title}"),
      subtitle: Text(statusTxt),
      trailing: IconButton(
        icon: Icon(
          Icons.chevron_right,
          size: 28,
        ),
        onPressed: null,
      ),
      onTap: () => gotoContentPage(context, novel),
    );
  }

  changeOrder() {
    order = (order + 1) % 2;
    setState(() {
      _catalogue = null;
    });
    loadCatalogue();
  }

  gotoContentPage(BuildContext context, Novel novel) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new ContentPage(arguments: {'id': novel.id, 'page': novel.page});
    }));
  }

  goBack() {
    Navigator.of(context).pop();
  }
}
