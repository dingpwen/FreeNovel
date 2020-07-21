package com.wen.novel;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.io.UnsupportedEncodingException;
import java.lang.Character.UnicodeBlock;
import java.util.*;
import java.net.URLDecoder;
/**
 * author: dingp
 * created on: 2020/6/24 13:45
 * description:
 */
public class MyMethodChannel implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL_NAME = "org.wen.icude/my";
    private Context mContext;
    private MyMethodChannel(Context context, FlutterEngine engine) {
        mContext = context;
        new MethodChannel(engine.getDartExecutor(), CHANNEL_NAME).setMethodCallHandler(this);
    }

    public static void register(FlutterActivity flutterActivity, FlutterEngine engine) {
        new MyMethodChannel(flutterActivity, engine);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        //result.notImplemented();
        String content;
        switch (call.method) {
            case "gbk":
                content = call.argument("content");
                try{
                    String gbk = toGBK(content);
                    android.util.Log.d("wenpd", "gbk:" + gbk);
                    result.success(gbk);
                } catch(UnsupportedEncodingException e) {

                }
                break;
            case "utf8":
                content = call.argument("content");
                try{
                    String utf8 = new String(content.getBytes("GBK"), "UTF_8");
                    android.util.Log.d("wenpd", "utf8:" + utf8);
                    result.success(utf8);
                } catch(UnsupportedEncodingException e) {

                }
                break;
            case "decode":
                String url = call.argument("url");
                try {
                    String utf8 = URLDecoder.decode(url, "gbk");
                    android.util.Log.d("wenpd", "utf8:" + utf8);
                    result.success(utf8);
                } catch(UnsupportedEncodingException e) {

                }
                break;
            default:
                result.notImplemented();
        }
    }

    public static String toGBK(String source) throws UnsupportedEncodingException {
        StringBuilder sb = new StringBuilder();
        byte[] bytes = source.getBytes("GBK");
        for(byte b : bytes) {
            sb.append("%" + Integer.toHexString((b & 0xff)).toUpperCase());
        }

        return sb.toString();
    }
}
