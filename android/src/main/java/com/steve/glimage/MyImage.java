package com.steve.glimage;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.bumptech.glide.Glide;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class MyImage implements PlatformView, MethodChannel.MethodCallHandler {
    Context context;
    private final ImageView imageView;
    private final MethodChannel methodChannel;

    MyImage(Context context, BinaryMessenger messenger, int id) {
        this.context = context;
        imageView = new ImageView(context);
        methodChannel = new MethodChannel(messenger, "plugins.felix.angelov/textview_" + id);
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public View getView() {
        return imageView;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "setText":
                setText(call, result);
                break;
            default:
                result.notImplemented();
        }
    }


    private void setText(MethodCall methodCall, MethodChannel.Result result) {
        String text = (String) methodCall.arguments;
        Glide.with(context).load("https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3107760802,239774629&fm=26&gp=0.jpg");
        result.success(null);
    }
}
