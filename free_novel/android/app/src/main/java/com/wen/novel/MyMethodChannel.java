package com.wen.novel;

import android.app.Activity;
import android.widget.Toast;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.io.UnsupportedEncodingException;
/**
 * author: dingp
 * created on: 2020/6/24 13:45
 * description:
 */
public class MyMethodChannel implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL_NAME = "org.wen.icude/my";
    private Activity mActivity;
    private MyMethodChannel(Activity activity, FlutterEngine engine) {
        mActivity = activity;
        new MethodChannel(engine.getDartExecutor(), CHANNEL_NAME).setMethodCallHandler(this);
    }

    static void register(FlutterActivity flutterActivity, FlutterEngine engine) {
        new MyMethodChannel(flutterActivity, engine);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        //result.notImplemented();
        String content;
        switch (call.method) {
            case "gbk":
                content = call.argument("content");
                if(content == null) {
                    return;
                }
                try{
                    String gbk = toGBK(content);
                    android.util.Log.d("wenpd", "gbk:" + gbk);
                    result.success(gbk);
                } catch(UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
                break;
            case "ailpay":
                if (AlipayUtil.hasInstalledAlipayClient(mActivity)){
                    AlipayUtil.startAlipayClient(mActivity,"fkx06116xmcuh8wn2ef9321"); // 第二步获取到的字符串
                }else{
                    Toast.makeText(mActivity, "未检测到支付宝，无法实现打赏功能", Toast.LENGTH_SHORT).show();
                }
                result.success("ok");
                break;
            default:
                result.notImplemented();
        }
    }

    private static String toGBK(String source) throws UnsupportedEncodingException {
        StringBuilder sb = new StringBuilder();
        byte[] bytes = source.getBytes("GBK");
        for(byte b : bytes) {
            sb.append("%").append(Integer.toHexString((b & 0xff)).toUpperCase());
        }

        return sb.toString();
    }
}
