package com.steve.glimage;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES20;
import android.opengl.GLUtils;

class SampleRenderWorker implements OpenGLRenderer.Worker {
    public static final int NO_TEXTURE = -1;
    private double _tick = 0;
    private Context context;
    public SampleRenderWorker(Context context){
        this.context = context;
    }
    @Override
    public void onCreate() {

    }
    public  static int textureImageId = NO_TEXTURE;
    @Override
    public boolean onDraw() {
        _tick = _tick + Math.PI / 60;

        float green = (float) ((Math.sin(_tick) + 1) / 2);
//        GLES20.glClearColor(0f, green, 0f, 1f);
//        textureImageId = loadTexture(  BitmapFactory.decodeResource(context.getResources(),R.drawable.ic_launcher),textureImageId,true);

//        GLES20.glClearColor(0f, green, 0f, 1f);
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
        return true;
    }

    @Override
    public void onDispose() {

    }


    public static int loadTexture(final Bitmap img, final int usedTexId, final boolean recycle) {
        int textures[] = new int[]{-1};
        if (usedTexId == NO_TEXTURE) {
            GLES20.glGenTextures(1, textures, 0);
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textures[0]);
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
            //纹理也有坐标系，称UV坐标，或者ST坐标
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_REPEAT); // S轴的拉伸方式为重复，决定采样值的坐标超出图片范围时的采样方式
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_REPEAT); // T轴的拉伸方式为重复

            GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, img, 0);
        } else {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, usedTexId);
            GLUtils.texSubImage2D(GLES20.GL_TEXTURE_2D, 0, 0, 0, img);
            textures[0] = usedTexId;
        }
        if (recycle) {
            img.recycle();
        }
        return textures[0];
    }

}
