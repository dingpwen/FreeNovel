import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/search/BaseSearch.dart';
import 'package:novel/search/SearchFactory.dart';
import 'package:novel/db/BookDesc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:novel/utils/Toast.dart';

class NovelSearchPage extends StatefulWidget {
  @override
  createState() => NovelSearchState();
}

class NovelSearchState extends State<NovelSearchPage> {
  int refresh = 0;
  final _textController = TextEditingController();
  String _result;
  Map<String, int> _downloadItems = {};
  String _curUrl;
  List<BookDesc> _resultList = [];
  BaseSearch _search;
  Timer _timer;

  @override
  void initState() {
    initSearch();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  void initSearch() async {
    _search = await SearchFactory.getDefault();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
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
          body: _buildBody(context)),
      onWillPop: () {
        return goBack();
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_result == null) {
      return Center(
        child: Text("开始搜书吧..."),
      );
    }
    return (_result == "")
        ? Center(
            child: Text("正在搜索..."),
          )
        : _buildSearchResultView();
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
                  )),
            )
          ],
        ),
        Expanded(
          child: Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _buildSearchListView()),
        )
      ],
    );
  }

  Widget _buildSearchListView() {
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

  Widget _buildSearchItemView(BuildContext context, BookDesc item) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            height: 120,
            width: 80,
            child: CachedNetworkImage(
                placeholder: (context, string) =>
                    Image.asset("lib/images/nopage.jpg"),
                errorWidget: (context, url, error) =>
                    Image.asset("lib/images/nopage.jpg"),
                imageUrl: item.bookCover),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.bookName),
                  Text("作者：${item.author}"),
                  Text("简介：${item.bookDesc}",
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text("最新章节：${item.lastTitle}"),
                ],
              ),
            )
          ),
          Expanded(
            child: Center(
              child: _buildTrail(context, item),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrail(BuildContext context, BookDesc item) {
    if (_downloadItems.containsKey(item.bookUrl)) {
      if (_downloadItems[item.bookUrl] == 1) {
        //0:下载中 1：下载完成 2：下载取消或中断
        return FlatButton(
          onPressed: null,
          child: Text("下载完成"),
        );
      } else if (_curUrl == item.bookUrl) {
        return FlatButton(
            onPressed: () => cancelDownload(context, item),
            child: CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: Colors.blue,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ));
        /*return CircularProgressIndicator(
          strokeWidth: 4,
          backgroundColor: Colors.blue,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
        );*/
      } else {
        return FlatButton(
          onPressed: () => downloadItem(item),
          child: Text("重新下载"),
        );
      }
    } else {
      return FlatButton(
        onPressed: () => downloadItem(item),
        child: Text("下载收藏"),
      );
    }
  }

  goBack() {
    if (_curUrl != null) {
      showConfirmDialog(context, '退出确认', '你有书籍正在下载，退出将取消下载，确认要退出吗？',
          callback: () {
        _search.cancel();
        Navigator.pop(context, [refresh]);
      });
    } else {
      Navigator.pop(context, [refresh]);
    }
  }

  doSearch() async {
    onSearchResult("");
    _downloadItems.clear();
    print("Search for ${_textController.text}");
    _search.doSearch(_textController.text, success: (data) {
      _textController.clear();
      onSearchResult(data.toString());
    }, error: (type) {
      print("error type:$type");
    });
  }

  onSearchResult(String result) async {
    //print("result:$result");
    if (result.length == 0) {
      //显示 正在搜索...
      setState(() {
        _result = result;
      });
      return;
    }
    var resultList = await _search.parseResult(result);
    //print("resultList:$resultList");
    setState(() {
      _result = result;
      _resultList = resultList;
    });
  }

  downloadItem(BookDesc book) async {
    //compute(download, [_search, item.bookUrl]);
    if (_curUrl != null && _downloadItems[_curUrl] == 0) {
      Toast.show(context, "您有其它任务在下载中！", duration: 2);
      return;
    }
    final exist =
        await NovelDatabase.getInstance().findBookFromUrl(book.bookUrl);
    int id = -1;
    if (exist != null) {
      //showToast();
      id = exist.id;
    } else {
      id = await NovelDatabase.getInstance().insertBook(book);
    }
    book.search = _search.getSearchType();
    refresh = 1;
    _downloadItems[book.bookUrl] = 0;
    setState(() {
      _curUrl = book.bookUrl;
    });
    _search.downloadItem(book.bookUrl, id);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_search.getDownloadState() == 1) {
        onComplete();
      }
    });
  }

  onComplete() {
    _downloadItems[_curUrl] = 1;
    _timer.cancel();
    _timer = null;
    setState(() {
      _curUrl = null;
    });
  }

  cancelDownload(BuildContext context, BookDesc book) async {
    showConfirmDialog(context, '取消任务', '确定要取消下载 ${book.bookName} 吗？',
        callback: () {
      _search.cancel();
      _downloadItems[book.bookUrl] = 2;
      setState(() {
        _curUrl = null;
      });
    });
  }

  showConfirmDialog(BuildContext context, String title, String message,
      {Function() callback}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (callback != null) {
                    callback();
                  }
                },
              ),
            ],
          );
        });
  }
}
