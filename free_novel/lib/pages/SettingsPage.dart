import 'package:flutter/material.dart';
import 'package:novel/pages/SearchModePage.dart';

import 'AboutPage.dart';

class SettingsPage extends StatelessWidget {
  final List<String> _settings = ["搜索设置", "其它设置", "关于本应用"];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'), centerTitle: true,
      ),
      body: _buildListView(context)
    );
  }

  _buildListView(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _buildItemView(context, index);
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 2,
            color: Theme.of(context).primaryColor,
          );
        },
        itemCount: _settings.length);
  }

  Widget _buildItemView(BuildContext context, int index) {
    return ListTile(
      title: Text("${_settings[index]}"),
      //subtitle: Text(statusTxt),
      trailing: IconButton(
        icon: Icon(
          Icons.chevron_right,
          size: 28,
        ),
        onPressed: null,
      ),
      onTap: () => gotoSettingsPage(context, index),
    );
  }

  gotoSettingsPage(BuildContext context, int index) {
    if(index == 0) {
      Navigator.push(context, MaterialPageRoute(builder:(context){
        return SearchModePage();
      }));
    } else if(index == 2) {
      Navigator.push(context, MaterialPageRoute(builder:(context){
        return AboutPage();
      }));
    }
  }
}