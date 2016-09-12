//
//  GSCameraManager.m
//  GSKit
//
//  Created by OSU on 16/5/31.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSCameraManager.h"
#import "GSDefine.h"


typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);



@implementation GSCameraLayer


@end



@interface GSCameraManager () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    GSView * _viewPreview;
}

@property(strong,nonatomic) AVCaptureSession * captureSession;//控制输入输出对象的会话对象
@property(strong,nonatomic) AVCaptureDeviceInput * captureDeviceInput;//输入对象
@property(strong,nonatomic) AVCaptureVideoDataOutput * captureVideoDataOutput;//视频数据输出对象（对内输出，视频数据流）
@property(strong,nonatomic) AVCaptureStillImageOutput * captureStillImageOutput;//静态图片输出对象（对内输出，持久化保存图像）
@property(strong,nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;//实时预览图层（对外输出，实时输出流数据）

@property(strong, nonatomic) dispatch_queue_t captureVideoDataQueue;

@property(copy, nonatomic) GSCameraTakePhotoBlock takePhotoCompletionBlock;
@property(copy, nonatomic) GSCameraTakePhotoShutterBlock takePhotoShutterBlock;

@property(strong,nonatomic) NSError * cameraError;//摄像头错误信息

@end



@implementation GSCameraManager

- (void)dealloc
{
    [self removeObserverFromDevice:_captureDeviceInput.device];
}


- (void)setViewPreview:(GSView *)viewPreview
{
    if (_viewPreview != viewPreview)
    {
        _viewPreview = viewPreview;
    }
}


- (void)setLayerPreview:(GSCameraLayer *)layerPreview
{
    if (_layerPreview != layerPreview)
    {
        _layerPreview = layerPreview;
    }
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //会话
        self.captureSession = [[AVCaptureSession alloc] init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto])
        {
            _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        }
        
        //输入
        AVCaptureDevice * backCamera = [self cameraDevicePosition:AVCaptureDevicePositionBack];
        NSError * error = nil;
        self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:backCamera error:&error];
        self.cameraError = error;
        if (error)
        {
            GSDDLog(@"%@",error.localizedDescription);
        }
        [self addObserverForDevice:backCamera];
        
        //输出-视频
        self.captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                           [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [_captureVideoDataOutput setVideoSettings:rgbOutputSettings];
        [_captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];//阻塞线程时跳过（处理图片时有一定的阻塞率）
        
        _captureVideoDataQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [_captureVideoDataOutput setSampleBufferDelegate:self queue:_captureVideoDataQueue];
        
        if ([_captureSession canAddOutput:_captureVideoDataOutput])
        {
            [_captureSession addOutput:_captureVideoDataOutput];
        }
        [[_captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
        
        //输出-静态图
        self.captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        _captureStillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG,
                                                    AVVideoQualityKey:[NSNumber numberWithFloat:1]};
        
        //会话对象获得输入设备
        if ([_captureSession canAddInput:_captureDeviceInput])
        {
            [_captureSession addInput:_captureDeviceInput];
        }
        
        //会话对象获得输出设备
        if ([_captureSession canAddOutput:_captureStillImageOutput])
        {
            [_captureSession addOutput:_captureStillImageOutput];
        }
        
        
        //预览
        self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//预览内容bounce格式
        
        self.layerPreview = [[GSCameraLayer alloc] init];
        _layerPreview.masksToBounds = YES;
        [_layerPreview addSublayer:_captureVideoPreviewLayer];
        BLOCKSELF
        _layerPreview.blockForFrameChange = ^(CGRect frame){
            
            blockSelf.captureVideoPreviewLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        };
        
    }
    return self;
}


#pragma mark  Function

/**开始运行*/
- (void)start
{
    [self.captureSession startRunning];
}


/**结束运行*/
- (void)stop
{
    [self.captureSession stopRunning];
}


/**拍照*/
- (void)takePhotoBlock:(GSCameraTakePhotoBlock)block shutterBlock:(GSCameraTakePhotoShutterBlock)shutterBlock
{
    if (_cameraError)
    {
        //摄像头有问题则直接结束
        return;
    }
    
    self.takePhotoCompletionBlock = block;
    self.takePhotoShutterBlock = shutterBlock;
    
    //快门动画时机回调
    if (!_captureDeviceInput.device.adjustingFocus)
    {
        if (self.takePhotoShutterBlock)
        {
            self.takePhotoShutterBlock();
            _takePhotoShutterBlock = nil;
        }
    }
    
    BLOCKSELF
    AVCaptureConnection * connection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        [blockSelf stop];
        NSData * data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:data];
        //完成回调
        if (blockSelf.takePhotoCompletionBlock)
        {
            blockSelf.takePhotoCompletionBlock(image);
        }
    }];
}


/**设置闪光灯*/
- (BOOL)changeFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice * device = _captureDeviceInput.device;
    if (!device.hasFlash)
    {
        //没有闪光灯
        GSDLog(@"没有闪光灯");
        return NO;
    }
    
    if (![device isFlashModeSupported:flashMode])
    {
        GSDLog(@"不支持该闪光灯模式");
        return NO;
    }
    
    BLOCK_TYPE(device, __device);
    return [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        
        __device.flashMode = flashMode;
    }];
}


/**设置前后摄像头*/
- (BOOL)changeCameraPosition:(AVCaptureDevicePosition)position
{
    AVCaptureDevice * elderCamera = _captureDeviceInput.device;
    if (elderCamera.position == position)
    {
        GSDLog(@"镜头方向已经是要求设定的方向");
        return NO;
    }
    
    [_captureSession beginConfiguration];
    
    AVCaptureDevice * camera =[self cameraDevicePosition:position];
    NSError * error = nil;
    AVCaptureDeviceInput * captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    self.cameraError = error;
    if (error)
    {
        GSDDLog(@"%@",error.localizedDescription);
        return NO;
    }
    
    [self removeObserverFromDevice:elderCamera];
    [_captureSession removeInput:_captureDeviceInput];
    if ([_captureSession canAddInput:captureDeviceInput])
    {
        [_captureSession addInput:captureDeviceInput];
        [self addObserverForDevice:camera];
        self.captureDeviceInput = captureDeviceInput;
        [_captureSession commitConfiguration];
        return YES;
    }
    else
    {
        GSDDLog(@"无法切换镜头");
        [_captureSession commitConfiguration];
        return NO;
    }
}


/**更改感兴趣的点*/
- (void)changePointOfInterestInPreviewLayer:(CGPoint)point
{
    [self beginFocusAnimation:point];
    CGPoint scalarPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];//获得图片相对点
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        
        //设定曝光点
        if ([captureDevice isExposurePointOfInterestSupported])
        {
            [captureDevice setExposurePointOfInterest:scalarPoint];
        }
        //设定对焦点
        if ([captureDevice isFocusPointOfInterestSupported])
        {
            [captureDevice setFocusPointOfInterest:scalarPoint];
        }
        //曝光模式、统一设定为持续自动
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //对焦模式、统一设定为持续自动
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
    }];
}


#pragma mark  Observer

/**为设备添加KVO*/
- (void)addObserverForDevice:(AVCaptureDevice *)device
{
    [device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}


/**移除设备KVO*/
- (void)removeObserverFromDevice:(AVCaptureDevice *)device
{
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
    [device removeObserver:self forKeyPath:@"adjustingExposure"];
}


/**观察者回调*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"adjustingFocus"])
    {
        BOOL new = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if ([self.delegate respondsToSelector:@selector(GSCameraManager:adjustingFocus:)])
        {
            [self.delegate GSCameraManager:self adjustingFocus:new];
        }
        if (!new)
        {
            if (self.takePhotoShutterBlock)
            {
                self.takePhotoShutterBlock();
                _takePhotoShutterBlock = nil;
            }
        }
    }
    else if([keyPath isEqualToString:@"adjustingExposure"])
    {
        BOOL new = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if ([self.delegate respondsToSelector:@selector(GSCameraManager:adjustingExposure:)])
        {
            [self.delegate GSCameraManager:self adjustingExposure:new];
        }
    }
}


#pragma mark Extend

/**懒加载预览视图*/
- (GSView *)viewPreview
{
    if (!_viewPreview)
    {
        self.viewPreview = [[GSView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_layerPreview.frame), CGRectGetHeight(_layerPreview.frame))];
        BLOCKSELF
        [_viewPreview setBlockForFrameChange:^(CGRect frame) {
            
            blockSelf.layerPreview.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        }];
        
        //添加浏览层
        [_viewPreview.layer addSublayer:_layerPreview];
        
        //添加单击手势
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewPreview:)];
        [_viewPreview addGestureRecognizer:tapGesture];
    }
    return _viewPreview;
}


/**点击预览视图事件*/
- (void)tapViewPreview:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:tap.view];
    [self changePointOfInterestInPreviewLayer:point];
}


- (void)beginFocusAnimation:(CGPoint)point
{
    if (_imageForIntresetPoint)
    {
        for (int i = 0 ; i < _layerPreview.sublayers.count; i++)
        {
            CALayer * layer = [_layerPreview.sublayers objectAtIndex:i];
            if([layer.name isEqualToString:@"floatingLayer"])
            {
                [layer removeFromSuperlayer];
                break;
            }
        }
        CALayer * layerFloating = [[CALayer alloc] init];
        layerFloating.name = @"floatingLayer";
        layerFloating.frame = CGRectMake(0, 0, 80, 80);
        layerFloating.contents = (id)self.imageForIntresetPoint.CGImage;
        layerFloating.position = point;
        [_layerPreview addSublayer:layerFloating];
        
        CABasicAnimation * animationScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animationScale.fromValue = @1.3;
        animationScale.toValue = @1;
        animationScale.duration = 0.25;
        
        CABasicAnimation * animationScale2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animationScale2.beginTime = 0.25;
        animationScale2.fromValue = @1;
        animationScale2.toValue = @1;
        animationScale2.duration = 0.25;
        
        CABasicAnimation * animationOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animationOpacity.beginTime = 0.5;
        animationOpacity.fromValue = @1;
        animationOpacity.toValue  = @0;
        animationOpacity.duration = 0.25;
        
        CAAnimationGroup * animationGroup = [[CAAnimationGroup alloc] init];
        animationGroup.delegate = self;
        animationGroup.animations = @[animationScale,animationScale2,animationOpacity];
        animationGroup.duration = 0.75;
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.removedOnCompletion = NO;
        [layerFloating addAnimation:animationGroup forKey:@"focusAnimation"];
    }
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        for (int i = 0 ; i < _layerPreview.sublayers.count; i++)
        {
            CALayer * layer = [_layerPreview.sublayers objectAtIndex:i];
            if([layer.name isEqualToString:@"floatingLayer"])
            {
                [layer removeFromSuperlayer];
                break;
            }
        }
    }
}


#pragma mark  Tools


/**获取对应位置的摄像头*/
- (AVCaptureDevice *)cameraDevicePosition:(AVCaptureDevicePosition)position
{
    NSArray * deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * device in deviceArray)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}


/**更改AVCaptureDevice属性的统一方法*/
- (BOOL)changeDeviceProperty:(PropertyChangeBlock)propertyChange
{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    [captureDevice lockForConfiguration:&error];
    if (error)
    {
        NSLog(@"设置设备属性过程发生错误");
        return NO;
    }
    propertyChange(captureDevice);
    [captureDevice unlockForConfiguration];
    return YES;
}


@end
