package com.steve.glimage;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class MyImageFactory extends PlatformViewFactory {

    private final BinaryMessenger messenger;

    public MyImageFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }
    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new MyImage(context, messenger, viewId);
    }

}
