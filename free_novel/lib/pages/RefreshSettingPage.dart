
import 'package:flutter/material.dart';
import 'package:novel/utils/SpUtils.dart';

class RefreshSettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RefreshState();
  }

}

class RefreshState extends State<RefreshSettingPage> {
  int _newValue = 10;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSearchMode();
  }

  getSearchMode() async{
    var refreshValue = await SpUtils.getRefreshValue();
    if(refreshValue == null) {
      refreshValue = 10;
    }
    setState(() {
      _newValue = refreshValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop:() async {
        await SpUtils.saveRefreshValue(_newValue);;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: goBack,
          ),
          title: Text("自动更新设置"),
          centerTitle: true,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            RadioListTile<int>(
              value:10,
              title: Text("更新最新10本书籍"),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              },
            ),
            RadioListTile<int>(
              value:20,
              title: Text("更新最新20本书籍"),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              },
            ),
            RadioListTile<int>(
              value:30,
              title: Text("更新最新30本书籍"),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              },
            ),
            RadioListTile<int>(
              value:-1,
              title: Text("只更新置顶的书籍"),
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
    await SpUtils.saveRefreshValue(_newValue);
    Navigator.pop(context);
  }
}