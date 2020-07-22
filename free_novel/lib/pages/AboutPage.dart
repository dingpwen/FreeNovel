import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const _address = "wenpd8@foxmail.com";
  static const _footerStyle = TextStyle(
      fontSize: 18,
      color: Colors.green,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline);
  static const _bodyStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("软件说明"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildBody(context),
          ),
          Expanded(flex: 1, child: _buildFooter(context))
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Image.asset(
            "lib/images/nopage.jpg",
            width: 240,
            height: 240.0,
            //类似于Android的scaleType 此处让图片尽可能小 以覆盖整个widget
            fit: BoxFit.cover,
          ),
          Text("个人免费书屋", style: _bodyStyle),
          Text("当前版本：1.0.0", style: _bodyStyle),
          Text("开发者：dingpwen", style: _bodyStyle),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        GestureDetector(
          child: Text("打 赏", style: _footerStyle),
          onTap: () => sendEmail(),
        ),
        GestureDetector(
          child: Text("法律意见", style: _footerStyle),
          onTap: () => sendEmail(),
        ),
        GestureDetector(
          child: Text("问题反馈", style: _footerStyle),
          onTap: () => sendEmail(),
        )
      ],
    );
  }

  void sendEmail({String email = _address}) => launch("mailto:$email");
}
