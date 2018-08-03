//
//  GSCameraManager.h
//  GSKit
//
//  Created by OSU on 16/5/31.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GSLayer.h"
#import "GSView.h"


typedef NS_OPTIONS(NSInteger, GSCameraOption)
{
    GSCameraOptionVideo = 1 << 0,//视频
    GSCameraOptionStillImage = 1 << 1,//照片
    GSCameraOptionMetadata = 1 << 2,//二维码等
};

//拍照回调
typedef void(^GSCameraTakePhotoBlock)(UIImage * image);
//拍照时快门动画的设置回调
typedef void(^GSCameraTakePhotoShutterBlock)();



//摄像头管理者代理声明
@protocol GSCameraManagerDelegate;



//摄像头浏览图层类
@interface GSCameraLayer : GSLayer

@end



//摄像头管理者
@interface GSCameraManager : NSObject

#pragma mark - base

/**
 @param option GSCamera的功能类型选项
 @return GSCameraManager实例对象
 */
- (instancetype)initWithOpitons:(GSCameraOption)option;

/**代理*/
@property (weak, nonatomic) id <GSCameraManagerDelegate> delegate;

/**浏览图层*/
@property (strong, nonatomic, readonly) GSCameraLayer * layerPreview;

/**开始运行*/
- (void)start;

/**结束运行*/
- (void)stop;


#pragma mark stillImageOutput

/**拍照*/
- (void)takePhotoBlock:(GSCameraTakePhotoBlock)block shutterBlock:(GSCameraTakePhotoShutterBlock)shutterBlock;


#pragma mark metaOutput

/**有效的扫描区域(基于layerPreview的bounds)*/
@property (assign, nonatomic) CGRect scanRect;

/**是否开启脸部探测(该功能尚未完成)*/
@property (assign, nonatomic) BOOL allowFaceDetection;

/**是否打开二维码探测(该功能尚未完成)*/
@property (assign, nonatomic) BOOL allowQRCodeDetection;


#pragma mark - commond

/**设置闪光灯*/
- (BOOL)changeFlashMode:(AVCaptureFlashMode)flashMode;

/**设置前后摄像头*/
- (BOOL)changeCameraPosition:(AVCaptureDevicePosition)position;

/**更改感兴趣的点*/
- (void)changePointOfInterestInPreviewLayer:(CGPoint)point;


#pragma mark - extend

/**
 浏览视图
 @discussion 本视图自带changePointOfInterestInPreviewLayer(更改兴趣点)的事件。
 */
@property (strong, nonatomic, readonly) GSView * viewPreview;

/**
 对焦或调整曝光时显示的图片
 @discussion 当设置了该图片后，发生对焦时会产生基于该图片的动画(该功能尚未完成)。
 */
@property (strong, nonatomic) UIImage * imageForIntresetPoint;

/**
 脸部探测覆盖图
 @discussion 当设置了该图片后，发生脸部识别时会产生基于该图片的动画(该功能尚未完成)。
 */
@property (strong, nonatomic) UIImage * imageForFaceDetection;

/**
 二维码探测覆盖图
 @discussion 当设置了该图片后，发生二维码识别时会产生基于该图片的动画(该功能尚未完成)。
 */
@property (strong, nonatomic) UIImage * imageForQRCodeDetection;

@end



@protocol GSCameraManagerDelegate <NSObject>

@optional

/**是否正在对焦*/
- (void)GSCameraManager:(GSCameraManager *)manager adjustingFocus:(BOOL)adjustingFocus;

/**是否正在调整曝光*/
- (void)GSCameraManager:(GSCameraManager *)manager adjustingExposure:(BOOL)adjustingExposure;

/**获取二维码信息*/
- (void)GSCameraManager:(GSCameraManager *)manager QRCodeString:(NSString *)valueString;

@end
