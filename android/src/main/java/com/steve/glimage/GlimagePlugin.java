package com.steve.glimage;

import android.graphics.SurfaceTexture;
import android.util.Log;
import android.util.LongSparseArray;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

/** GlimagePlugin */
public class GlimagePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
    private  TextureRegistry textures;
    private LongSparseArray<OpenGLRenderer> renders = new LongSparseArray<>();


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "glimage");
    channel.setMethodCallHandler(this);
    textures = flutterPluginBinding. getTextureRegistry();
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
    Log.d("OpenglTexturePlugin", call.method + " " + call.arguments.toString());
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("create")) {
        TextureRegistry.SurfaceTextureEntry entry = textures.createSurfaceTexture();
        SurfaceTexture surfaceTexture = entry.surfaceTexture();

        int width = arguments.get("width").intValue();
        int height = arguments.get("height").intValue();
        surfaceTexture.setDefaultBufferSize(width, height);

        SampleRenderWorker worker = new SampleRenderWorker();
       OpenGLRenderer render = new OpenGLRenderer(surfaceTexture, worker);

        renders.put(entry.id(), render);

        result.success(entry.id());
    } else if (call.method.equals("dispose")) {
        long textureId = arguments.get("textureId").longValue();
        OpenGLRenderer render = renders.get(textureId);
        render.onDispose();
        renders.delete(textureId);
    }else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
