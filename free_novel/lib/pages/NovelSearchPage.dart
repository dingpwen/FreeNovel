import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:novel/base/BaseSearch.dart';
import 'package:novel/base/SearchFactory.dart';
import 'package:novel/model/SearchBookResult.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NovelSearchPage extends StatefulWidget {
  @override
  createState() => NovelSearchState();
}

class NovelSearchState extends State<NovelSearchPage> {
  final _textController = TextEditingController();
  String _result = "";
  List<SearchBookResult> _resultList = [];
  BaseSearch _search;

  @override
  void initState() {
    _search = SearchFactory.getSearch(SearchFactory.BIQUGE);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: goBack,
          ),
          title: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 36),
            child: TextField(
              controller: _textController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  hintText: '请输入要搜索的小说',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(18)))),
              cursorColor: Colors.blueGrey,
              cursorWidth: 2,
              cursorRadius: Radius.elliptical(2, 8),
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: doSearch)
          ],
        ),
        body: (_result == "")
            ? Center(
                child: Text("Searching..."),
              )
            : _buildSearchResultView());
  }

  _buildSearchResultView() {
    if (_resultList.length == 0) {
      return Center(
        child: Text("没有找到您要找的书籍。"),
      );
    }
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  color: Colors.greenAccent,
                  child: Text(
                    "搜索结果：",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  )
              ),
            )
          ],
        ),
        Expanded(
          child: Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _buildSearchListView()
          ),
        )

      ],
    );
  }

  _buildSearchListView() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _buildSearchItemView(context, _resultList[index]);
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 2,
            color: Theme.of(context).primaryColor,
          );
        },
        itemCount: _resultList.length);
  }

  Widget _buildSearchItemView(BuildContext context, SearchBookResult item) {
    return Container(
      margin: EdgeInsets.only(top:10, bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            height: 120,
            width: 80,
            child: CachedNetworkImage(
                imageUrl: item.bookCover),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.bookName),
                Text(item.author),
                Text(item.bookDesc, maxLines: 2, overflow:TextOverflow.ellipsis),
                Text(item.lastTitle),
              ],
            ),
          )
        ],
      ),
    );
  }

  goBack() {
    Navigator.pop(context);
  }

  doSearch() {
    onSearchResult("");
    //print("Search for ${_textController.text}");
    _search.doSearch(_textController.text, success: (data) {
      onSearchResult(data.toString());
    }, error: (type) {
      print("error type:$type");
    });
  }

  onSearchResult(String result) async {
    print("result:$result");
    if (result.length == 0) {
      //显示 正在搜索...
      setState(() {
        _result = result;
      });
      return;
    }
    var resultList = await compute(_search.parseResult, result);
    print("resultList:$resultList");
    setState(() {
      _result = result;
      _resultList = resultList;
    });
  }
}

/*
new CustomScrollView(
shrinkWrap: true,
// 内容
slivers: <Widget>[
new SliverPadding(
padding: const EdgeInsets.all(20.0),
sliver: new SliverList(
delegate: new SliverChildListDelegate(
<Widget>[
new Text(_result),
],
),
),
),
],
)*/
