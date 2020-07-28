import 'package:flutter/material.dart';
import 'package:novel/utils/SpUtils.dart';

class SearchModePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchModeState();
  }
}

class SearchModeState extends State<SearchModePage> {
  String _newValue = "biquge";
  TextStyle _common = TextStyle(fontSize: 18);
  TextStyle _subTitle = TextStyle(fontSize: 16, color: Color(0xAC000000));
  //final List<TextEditingController> _textController = [TextEditingController(), TextEditingController(), TextEditingController()];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSearchMode();
  }

  getSearchMode() async {
    var searchName = await SpUtils.getSearchName();
    if(searchName == null || searchName.length == 0) {
      searchName = 'biquge';
    }
    setState(() {
      _newValue = searchName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        return await saveSetting();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: goBack,
          ),
          title: Text("搜索设置"),
          centerTitle: true,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            RadioListTile<String>(
              value: "biquge",
              title: Text("从笔趣阁搜索", style: _common),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              },
            ),
            RadioListTile<String>(
              value: "23wxc",
              title: Text("从顶点小说搜索", style: _common),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              },
            ),
            RadioListTile<String>(
              value: "other",
              title: Text("从其它网址下载", style: _common),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              },
            ),
            Offstage(
              offstage: (_newValue == 'other') ? false : true,
              child: _buildOtherSearch(context),
            )
          ],
        ));
  }

  goBack() async {
    bool saved = await saveSetting();
    if(saved) {
      Navigator.pop(context);
    }
  }

  Future<bool> saveSetting() async {
    await SpUtils.saveSearchName(_newValue);
    return true;
  }

  /*Future<bool> saveSetting() async {
    if(_newValue == 'other') {
      final pid = _textController[0].text;
      final path = _textController[1].text;
      final myid = _textController[2].text;
      if (pid.isEmpty) {
        Toast.show(context, '小说目录父节点id不能为空！');
        return false;
      }
      if (path.isEmpty) {
        Toast.show(context, '小说目录查询路径不能为空！');
        return false;
      }
      if (myid.isEmpty) {
        Toast.show(context, '小说内容节点id不能为空！');
        return false;
      }
      SearchDesc desc = await NovelDatabase.getInstance().findSearch(
          pid, path, myid);
      if (desc == null) {
        desc = SearchDesc(pid: pid, path: path, myid: myid);
        desc.id = await NovelDatabase.getInstance().insertSearch(desc);
      }
      if(desc.id < 0) {
        return true;
      }
      await SpUtils.saveSearchType(desc.id + SearchFactory.TYPE_OTHER);
    } else if(_newValue == 'biquge') {
      await SpUtils.saveSearchType(SearchFactory.TYPE_BIQUGE);
    } else if(_newValue == '23wxc') {
      await SpUtils.saveSearchType(SearchFactory.TYPE_WXC);
    }
    await SpUtils.saveSearchName(_newValue);
    return true;
  }*/

  Widget _buildOtherSearch(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text("输入小说章节列表所在网址，直接下载整本小说，需要注意网页编码是否是gbk，如果是下载时注意勾选gbk选项，是否下载到的内容可能是乱码。", style: _subTitle),
    );
  }

  /*Widget _buildOtherSearch(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: <Widget>[
          _buildOtherItem(context, '小说目录父节点id', _textController[0]),
          _buildOtherItem(context, '小说目录查询路径', _textController[1]),
          _buildOtherItem(context, '小说内容节点id', _textController[2]),
        ],
      ),
    );
  }

  Widget _buildOtherItem(BuildContext context, String title, TextEditingController textController) {
    return Padding(
      padding: EdgeInsets.only(top:10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: _subTitle, ),
          TextField(
            controller:textController,
            style: _common,
            decoration: new InputDecoration(
              focusColor: Color(0x9F9E9E9E),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              border: OutlineInputBorder(
                  borderSide:BorderSide(color: Color(0x6F9E9E9E)),
                  borderRadius: BorderRadius.circular(30.0)), // 边色与边宽度
            ),
          )
        ],
      ),
    );
  }*/
}