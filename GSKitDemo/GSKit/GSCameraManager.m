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



@interface GSCameraLayer()


@property(assign,nonatomic) void(^blockForFrameChange)(CGRect frame);


@end



@implementation GSCameraLayer


- (void)dealloc
{
    Block_release(_blockForFrameChange);
    _blockForFrameChange = nil;
    [super dealloc];
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_blockForFrameChange)
    {
        _blockForFrameChange(frame);
    }
}


- (void)setBlockForFrameChange:(void (^)(CGRect))blockForFrameChange
{
    if (_blockForFrameChange)
    {
        Block_release(_blockForFrameChange);
    }
    _blockForFrameChange = Block_copy(blockForFrameChange);
}


@end



@interface GSCameraManager () <AVCaptureVideoDataOutputSampleBufferDelegate>


@property(retain,nonatomic) AVCaptureSession * captureSession;//控制输入输出对象的会话对象
@property(retain,nonatomic) AVCaptureDeviceInput * captureDeviceInput;//输入对象
@property(retain,nonatomic) AVCaptureVideoDataOutput * captureVideoDataOutput;//视频数据输出对象（对内输出，视频数据流）
@property(retain,nonatomic) AVCaptureStillImageOutput * captureStillImageOutput;//静态图片输出对象（对内输出，持久化保存图像）
@property(retain,nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;//实时预览图层（对外输出，实时输出流数据）

@property(assign,nonatomic) dispatch_queue_t captureVideoDataQueue;

@property(assign,nonatomic) GSCameraTakePhotoBlock takePhotoCompletionBlock;
@property(assign,nonatomic) void(^blockForInterestPointEnd)();

@end



@implementation GSCameraManager


- (void)dealloc
{
    [self removeObserverFromDevice:_captureDeviceInput.device];
    [_layerPreview release];
    [_captureSession release];
    [_captureDeviceInput release];
    [_captureStillImageOutput release];
    [_captureVideoPreviewLayer release];
    [super dealloc];
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //会话
        self.captureSession = [[[AVCaptureSession alloc] init] autorelease];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh])
        {
            _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        }
        
        //输入
        AVCaptureDevice * backCamera = [self cameraDevicePosition:AVCaptureDevicePositionBack];
        NSError * error = nil;
        self.captureDeviceInput = [[[AVCaptureDeviceInput alloc] initWithDevice:backCamera error:&error] autorelease];
        if (error)
        {
            GSDDLog(@"%@",error.localizedDescription);
        }
        [self addObserverForDevice:backCamera];
        
        //输出-视频
        self.captureVideoDataOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
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
        self.captureStillImageOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
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
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _layerPreview = [[GSCameraLayer alloc] init];
        [_layerPreview addSublayer:_captureVideoPreviewLayer];
        BLOCKSELF
        _layerPreview.blockForFrameChange = ^(CGRect frame){
            
            blockSelf.captureVideoPreviewLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        };
        
    }
    return self;
}


#pragma mark - Function

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
- (void)takePhotoBlock:(GSCameraTakePhotoBlock)block
{
    if (_takePhotoCompletionBlock)
    {
        Block_release(_takePhotoCompletionBlock);
    }
    _takePhotoCompletionBlock = Block_copy(block);
    
    AVCaptureConnection * connection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
       
        NSData * data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:data];
        if (_takePhotoCompletionBlock)
        {
            _takePhotoCompletionBlock(image);
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
    AVCaptureDeviceInput * captureDeviceInput = [[[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error] autorelease];
    if (error)
    {
        GSDDLog(@"%@",error.localizedDescription);
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
- (void)changePointOfInterestInPreviewLayer:(CGPoint)point block:(void(^)())blockForPointOfInterestEnded
{
    if (_blockForInterestPointEnd)
    {
        Block_release(_blockForInterestPointEnd);
    }
    _blockForInterestPointEnd = Block_copy(blockForPointOfInterestEnded);
    
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


#pragma mark - Observer

/**为设备添加KVO*/
- (void)addObserverForDevice:(AVCaptureDevice *)device
{
    [device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
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
        BOOL old = [[change objectForKey:NSKeyValueChangeOldKey] boolValue];
        BOOL new = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (!old && new)
        {
            
        }
    }
    if ([keyPath isEqualToString:@"adjustingFocus"] || [keyPath isEqualToString:@"adjustingExposure"])
    {
        AVCaptureDevice * device = (AVCaptureDevice *)object;
        if (!(device.adjustingFocus || device.adjustingExposure))
        {
            if (_blockForInterestPointEnd)
            {
                _blockForInterestPointEnd();
            }
        }
    }
}



#pragma mark - Tools


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
    if ([captureDevice lockForConfiguration:&error])
    {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        return YES;
    }
    else
    {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
        return NO;
    }
}


@end
