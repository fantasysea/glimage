package com.steve.glimage;

import android.content.Context;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;

public class FluttetrImage implements  FluttetrImageInterface {
    static int LOADING = 0;
    static int SUCCESS = 1;
    static int FAIL = 2;

    Context context;
    String url;
    int width;
    int height;
    TextureRegistry.SurfaceTextureEntry mEntry;
    Surface surface;
    EventChannel mEventChannel;
    BinaryMessenger binaryMessenger;
    EventChannel.EventSink mEventSink;
    public FluttetrImage(Context context,String url, int width, int height, TextureRegistry.SurfaceTextureEntry entry, BinaryMessenger binaryMessenger) {
       this.context = context;
        this.url = url;
        this.width = width;
        this.height = height;
        this.mEntry = entry;
        this.surface = new Surface(entry.surfaceTexture());
        this. binaryMessenger =  binaryMessenger;
        addEventChannel(entry);
    }


    private void draw(Bitmap bitmap){
        if(surface!=null&&surface.isValid()){
            mEntry.surfaceTexture().setDefaultBufferSize(width, height);
            Canvas canvas = surface.lockCanvas(null);
            canvas.drawBitmap( bitmap,0.0f, 0.0f, new Paint(3));
            surface.unlockCanvasAndPost(canvas);
            bitmap.recycle();
            if (mEventSink!=null){
                HashMap hashMap  = new HashMap<>();
                hashMap.put("event",SUCCESS);
                hashMap.put("textureId", mEntry.id());
                hashMap.put("error"," ");
                mEventSink.success(hashMap);
            }

//        Rect rect = new Rect(0, 0, width, height);
//        Canvas canvas = surface.lockCanvas(rect);
//        canvas.drawBitmap( bitmap, null, rect, null);
//        bitmap.recycle();
//        surface.unlockCanvasAndPost(canvas);
        }

    }
    private void addEventChannel(TextureRegistry.SurfaceTextureEntry entry) {
        mEventChannel = new EventChannel(binaryMessenger, "flutter.io/image/imageEvevts"+entry.id());
        mEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                mEventSink = eventSink;
                loadImage( context,url,width,height);
            }
            @Override
            public void onCancel(Object o) {
                mEventSink = null;
                surface.release();
                surface = null;
                mEntry.release();
            }
        });
    }

    public void dispose(){
        this.mEventChannel.setStreamHandler(null);
        surface.release();
        surface = null;
        mEntry.release();
    }

    @Override
    public void loadImage(Context context, String url, final int width, int hight) {

        Glide.with(context) .asBitmap() .load(url).into(new CustomTarget<Bitmap>() {
            @Override
            public void onLoadFailed(@Nullable Drawable errorDrawable) {
                super.onLoadFailed(errorDrawable);
                if (mEventSink!=null){
                    HashMap hashMap  = new HashMap<>();
                    hashMap.put("event",FAIL);
                    hashMap.put("textureId", mEntry.id());
                    hashMap.put("error","download fail");

                    mEventSink.success(hashMap);
                }
            }

            @Override
            public void onResourceReady(@NonNull Bitmap bitmap, @Nullable Transition<? super Bitmap> transition) {
                draw(Bitmap.createScaledBitmap(bitmap,width,height,true));
            }

            @Override
            public void onLoadCleared(@Nullable Drawable placeholder) {

            }
        });
    }


}
