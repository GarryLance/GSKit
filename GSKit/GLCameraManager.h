//
//  GLCameraManager.h
//  GLKit
//
//  Created by OSU on 16/5/31.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^GLCameraTakePhotoBlock)(UIImage * image);

@protocol GLCameraManagerDelegate;



@interface GLCameraLayer : CALayer


@end



@interface GLCameraManager : NSObject


/**代理*/
@property(assign,nonatomic) id delegate;

/**浏览图层*/
@property(retain,nonatomic,readonly) GLCameraLayer * layerPreview;

/**开始运行*/
- (void)start;

/**结束运行*/
- (void)stop;

/**拍照*/
- (void)takePhotoBlock:(GLCameraTakePhotoBlock)block;

/**设置闪光灯*/
- (BOOL)changeFlashMode:(AVCaptureFlashMode)flashMode;

/**设置前后摄像头*/
- (BOOL)changeCameraPosition:(AVCaptureDevicePosition)position;

/**更改感兴趣的点*/
- (void)changePointOfInterestInPreviewLayer:(CGPoint)point block:(void(^)())blockForPointOfInterestEnded;

/**是否开启脸部探测*/
@property(assign,nonatomic) BOOL allowFaceDetection;

/**是否打开二维码探测*/
@property(assign,nonatomic) BOOL allowQRCodeDetection;


@end



@protocol GLCameraManagerDelegate <NSObject>

@optional


@end
