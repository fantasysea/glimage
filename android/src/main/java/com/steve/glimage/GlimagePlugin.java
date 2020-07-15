package com.steve.glimage;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.util.LongSparseArray;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.FutureTarget;
import com.bumptech.glide.request.Request;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.SingleRequest;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.target.SizeReadyCallback;
import com.bumptech.glide.request.target.Target;
import com.bumptech.glide.request.transition.Transition;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterPluginRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.FlutterView;
import io.flutter.view.TextureRegistry;

/** GlimagePlugin */
public class GlimagePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
    private  TextureRegistry textures;
    private PlatformViewRegistry platformViews;
    private Context  context;
    private LongSparseArray<OpenGLRenderer> renders = new LongSparseArray<>();
    private HashMap<Object ,FluttetrImage > fluttetrImageHashMap = new HashMap<>();
    private  BinaryMessenger binaryMessenger;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "glimage");
    channel.setMethodCallHandler(this);
    textures = flutterPluginBinding. getTextureRegistry();
    platformViews = flutterPluginBinding.getPlatformViewRegistry();
    platformViews.registerViewFactory("plugins.felix.angelov/textview",new MyImageFactory(flutterPluginBinding.getBinaryMessenger()));
    this.context = flutterPluginBinding.getApplicationContext();
    this.binaryMessenger = flutterPluginBinding.getBinaryMessenger();
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "glimage");
    channel.setMethodCallHandler(new GlimagePlugin());
  }

  @Override  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Map<String, Number> arguments = (Map<String, Number>) call.arguments;
    // Log.d("OpenglTexturePlugin", call.method + " " + call.arguments.toString());
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("create")) {
        TextureRegistry.SurfaceTextureEntry entry = textures.createSurfaceTexture();
        SurfaceTexture surfaceTexture = entry.surfaceTexture();

        int width = arguments.get("width").intValue();
        int height = arguments.get("height").intValue();
        surfaceTexture.setDefaultBufferSize(width, height);

        SampleRenderWorker worker = new SampleRenderWorker(context);
       OpenGLRenderer render = new OpenGLRenderer(surfaceTexture, worker);




        result.success(entry.id());
    } else if (call.method.equals("dispose")) {
        long textureId = arguments.get("textureId").longValue();
        FluttetrImage fluttetrImage =  fluttetrImageHashMap.get(textureId);
        fluttetrImage.dispose();
        fluttetrImageHashMap.remove(textureId);
    } else if (call.method.equals("image")) {
        TextureRegistry.SurfaceTextureEntry entry = textures.createSurfaceTexture();
        int width = arguments.get("width").intValue();
        int height = arguments.get("height").intValue();
        String  url =String.valueOf( arguments.get("url"));
        fluttetrImageHashMap.put(entry.id(),new FluttetrImage(context,url,width,height,entry, binaryMessenger));

        result.success(entry.id());
    }else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
