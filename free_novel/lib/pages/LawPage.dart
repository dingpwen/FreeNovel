import 'package:flutter/material.dart';

class LawPage extends StatelessWidget{
  static const String law = '1. 本应用只是提供搜索下载接口，原则上不赞同盗版书籍的传播。用户如有下载盗版书籍，请自行在24小时内删除。\n\n' +
      '2. 本应用目前不会收集任何用户信息，用户而安全不用担心信息泄露。\n\n' +
      '3. 本软件属于非盈利性软件，不得利用本软件做非法或不正当用途，以及有损于国家安全和违反法律法规的事情。\n\n' +
  '4. 本软件资源涉及到互联网服务，可能会受到各个环节不稳定因素的影响，存在因不可抗力、计算机病毒、系统不稳定、用户所在位置、用户关机以及其他任何网络、技术、通信线路等原因造成的服务中断或不能满足用户要求的风险，用户须明白并自行承担以上风险，用户因此不能接受阅读消息，或接错消息，本软件不承担任何责任。';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('法律意见'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(top:20, left:10, right: 10),
        child: Text(law, style: TextStyle(fontSize: 18, color: Colors.black),)
      ),
    );
  }
  
}