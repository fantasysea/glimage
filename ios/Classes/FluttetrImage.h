//
//  FluttetrImage.h
//  Runner
//
//  Created by cm on 2020/7/16.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^FrameUpdateCallback)(void);
@interface FluttetrImage : NSObject<FlutterTexture,FlutterStreamHandler>
- (instancetype)initWithUrl:(NSString*)url width:(CGFloat) width height:(CGFloat) height binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger frameUpdateCallback:(FrameUpdateCallback)callback;
- (void)addchannel:(int64_t) textureid ;
@end

NS_ASSUME_NONNULL_END
