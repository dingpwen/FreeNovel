import 'package:flutter/material.dart';

class Toast{
  static void show(BuildContext context, String message, {int duration}) {
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.7,
        ),
        alignment: Alignment.center,
        child: Center(
          child: Container(
            decoration:new BoxDecoration(
              border: new Border.all(color: Color(0xFFFFFFFF), width: 0.5), // 边色与边宽度
              color: Color(0x6F9E9E9E), // 底色
              borderRadius: BorderRadius.circular(30.0), // 也可控件一边圆角大小
            ),
            //color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20),
              child: Material(
                child: Text(
                  message,
                  style: TextStyle(backgroundColor: Color(0x6F9E9E9E)),
                ),
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context).insert(entry);
    Future.delayed(Duration(seconds: duration ?? 2)).then((value) {
      // 移除层可以通过调用OverlayEntry的remove方法。
      entry.remove();
    });
  }
}