import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel/db/BookDesc.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/search/OtherSearch.dart';
import 'package:novel/search/SearchFactory.dart';
import 'package:novel/utils/Toast.dart';

class DownloadPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return DownloadState();
  }

}

class DownloadState extends State<DownloadPage> {
  OtherSearch _search;
  final _textController = TextEditingController();
  TextStyle _common = TextStyle(fontSize: 18);
  TextStyle _blue = TextStyle(fontSize: 18, color: Colors.blue);
  //bool _newValue = false;
  String _curUrl;
  Timer _timer;
  int _refresh = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search = SearchFactory.getSearchByType(SearchFactory.TYPE_OTHER);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        await goBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("下载书籍"),
          centerTitle: true,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context){
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
          color: Color(0x3F9E9E9E),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 20, 10, 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller:_textController,
                        style: _common,
                        decoration: new InputDecoration(
                          hintText: '输入书籍章节列表所在网址',
                          focusColor: Color(0xFFFFFFFF),
                          fillColor: Color(0xFFFFFFFF),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                          border: OutlineInputBorder(
                              borderSide:BorderSide(color: Color(0x6F9E9E9E)),
                              borderRadius: BorderRadius.circular(30.0)), // 边色与边宽度
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        _download();
                      },
                      child: Text('下载收藏', style: _blue),)
                  ],
                ),
              ),
              /*Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0, 10, 0),
                child: CheckboxListTile(
                  activeColor: Colors.blue,
                  value: _newValue,
                  title: Text("是否是gbk网页",style: _common,),
                  onChanged: (value) {
                    setState(() {
                      _newValue = value;
                    });
                  },
                ),
              )*/
            ],
          ),
        ),
        Offstage(
          offstage: (_curUrl == null)?true:false,
          child: Container(
            height: MediaQuery.of(context).size.height*0.5,
            child: Center(
              child: FlatButton(
                  onPressed: () => _cancelDownload(context),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.5,
                    height: MediaQuery.of(context).size.width*0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.blue,
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )),
            ),
          ),
        ),

      ],
    );
  }

  _download() async{
    if(_curUrl != null) {
      Toast.show(context, '正在下载，请稍后！');
      return;
    }
    _refresh = 1;
    String url = _textController.text;
    //_search.setGbk(_newValue);
    if(url.isNotEmpty) {
      setState(() {
        _curUrl = url;
      });
      final book = await NovelDatabase.getInstance().findBookFromUrl(url);
      if(book != null) {
        _search.setGbk(book.gbk == 1);
        _search.downloadItem(url, book.id);
      } else {
        BookDesc book = BookDesc('', url, '', '',
            '', '', '', '');
        book.search = SearchFactory.TYPE_OTHER;
        //book.gbk = _newValue?1:0;
        int id = await NovelDatabase.getInstance().insertBook(book);
        _search.downloadItem(url, id);
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_search.getDownloadState() == 1) {
        onComplete();
      }
    });
  }

  onComplete() {
    _timer.cancel();
    _timer = null;
    setState(() {
      _curUrl = null;
    });
  }

  _cancelDownload(BuildContext context) {
    showConfirmDialog(context, '取消任务', '确定要取消下载吗？',
        callback: () {
          _search.cancel();
          onComplete();
        });
  }

  goBack() {
    if (_curUrl != null) {
      showConfirmDialog(context, '退出确认', '你有书籍正在下载，退出将取消下载，确认要退出吗？',
          callback: () {
            _search.cancel();
            Navigator.pop(context, [_refresh]);
          });
    } else {
      Navigator.pop(context, [_refresh]);
    }
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