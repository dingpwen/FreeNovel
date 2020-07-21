
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSearchMode();
  }

  getSearchMode() async{
    final searchName = await SpUtils.getSearchName();
    setState(() {
      _newValue = searchName;
    });
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
        title: Text("搜索设置"),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          RadioListTile<String>(
            value:"biquge",
            title: Text("从笔趣阁搜索"),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              },
          ),
          RadioListTile<String>(
            value:"23wxc",
            title: Text("从顶点小说搜索"),
            groupValue: _newValue,
            onChanged: (value) {
              setState(() {
                _newValue = value;
              });
            },
          ),
          RadioListTile<String>(
            value:"other",
            title: Text("从其它网址下载"),
            groupValue: _newValue,
            onChanged: (value) {
              setState(() {
                _newValue = value;
              });
            },
          ),
        ],
      )
    );
  }

  goBack() async{
    await SpUtils.saveSearchName(_newValue);
    Navigator.pop(context);
  }


}