//
//  FluttetrImage.m
//  Runner
//
//  Created by cm on 2020/7/16.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "FluttetrImage.h"
//#import "UIImageView+WebCache.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDWebImageManager.h>
#define _LOADING 0
#define _SUCCESS 1
#define _FAIL 2

@implementation FluttetrImage{
    NSString* _url;
    CGFloat _width;
    CGFloat _height;
    CVPixelBufferRef _targetBuf;
    NSObject<FlutterBinaryMessenger> *_mybinaryMessenger;
    FlutterEventSink _events;
    int64_t _textureid;
    FrameUpdateCallback _callback;

}




- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events{
        // arguments flutter给native的参数
        // 回调给flutter， 建议使用实例指向，因为该block可以使用多次
    _events = events;
     [self initImage];
    return nil;
}


- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
     return nil;
}

- (CVPixelBufferRef)copyPixelBuffer {
    CVBufferRetain(_targetBuf);
    return _targetBuf;
}

- (instancetype)initWithUrl:(NSString*)url width:(CGFloat) width height:(CGFloat) height binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger frameUpdateCallback:(FrameUpdateCallback)callback;
{
    if (self = [super init]) {
        _url = url;
        _width = width;
        _height = height;
        _mybinaryMessenger = messenger;
        _callback = callback;
    }
    return self;
}

-(void)initImage{

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager loadImageWithURL:[NSURL URLWithString:_url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (error) {
            if (self->_events) {
                NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
                [params setValue:[NSNumber numberWithInt:_FAIL]  forKey:@"event"];
                [params setValue:[NSNumber numberWithLongLong:self->_textureid]  forKey:@"textureId"];
                [params setValue:error.localizedDescription forKey:@"error"];
                self->_events(params);
            }
        }else{
             [self CVPixelBufferRefFromUiImage:image];
            if (self->_events) {
                NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
                [params setValue:[NSNumber numberWithInt:_SUCCESS]  forKey:@"event"];
                [params setValue:[NSNumber numberWithLongLong:self->_textureid]  forKey:@"textureId"];
                [params setValue:@"" forKey:@"error"];
                self->_events(params);
                _callback();
            }
        }
        
    }];
}

- (void)addchannel:(int64_t) textureid {
    _textureid = textureid;
    NSString *channel = [NSString stringWithFormat:@"flutter.io/image/imageEvevts%lld",textureid];
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:channel binaryMessenger:_mybinaryMessenger];
    [eventChannel setStreamHandler:self];
   
}
static OSType inputPixelFormat2(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType2(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}

// alpha的判断
BOOL CGImageRefContainsAlpha2(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

// 此方法能还原真实的图片
- (void)CVPixelBufferRefFromUiImage:(UIImage *)img {
    CGSize size = img.size;
    CGImageRef image = [img CGImage];
    
    BOOL hasAlpha = CGImageRefContainsAlpha2(image);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
//    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, inputPixelFormat2(), (__bridge CFDictionaryRef) options, &_targetBuf);
    
    NSParameterAssert(status == kCVReturnSuccess && _targetBuf != NULL);
    
    CVPixelBufferLockBaseAddress(_targetBuf, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(_targetBuf);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType2(inputPixelFormat2(), (bool)hasAlpha);
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(_targetBuf), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CVPixelBufferUnlockBaseAddress(_targetBuf, 0);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
//    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _target, NULL, GL_TEXTURE_2D, GL_RGBA, size.width, size.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &_texture);
    
//    return pxbuffer;
}


@end
