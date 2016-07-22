//
//  GLCameraViewController.m
//  GLKit
//
//  Created by OSU on 16/5/31.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GLCameraViewController.h"
#import "GLEditPhotoViewController.h"
#import "GSKit.h"


@interface GLCameraViewController ()

@property(retain,nonatomic) GSCameraManager * manager;

@property(retain,nonatomic) UIView * viewForPreview;

@property(retain,nonatomic) UIView * viewSudoku;

@end



@implementation GLCameraViewController


- (void)dealloc
{
    [_manager release];
    [_viewSudoku release];
    [_viewForPreview release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"camera_background_color"]];
    
    [self setupView];
    
    [self setupManager];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_manager start];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.userInteractionEnabled = YES;
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_manager stop];
//    [_viewForPreview stopLoading];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)setupManager
{
    self.manager = [[[GSCameraManager alloc] init] autorelease];
    
    _manager.layerPreview.frame = _viewForPreview.bounds;
    [_viewForPreview.layer insertSublayer:_manager.layerPreview atIndex:0];
    [_manager start];
}


- (void)setupView
{
    UIView * viewForPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    [self.view addSubview:viewForPreview];
    self.viewForPreview = [viewForPreview autorelease];
    
    UIView * viewSudoko = [[UIView alloc] initWithFrame:viewForPreview.bounds];
    [viewSudoko.layer addSublayer:[self layerWithFrame:CGRectMake(CGRectGetWidth(viewSudoko.frame)/3.0-0.5, 0, 1, viewSudoko.frame.size.height)]];
    [viewSudoko.layer addSublayer:[self layerWithFrame:CGRectMake(CGRectGetWidth(viewSudoko.frame)/3.0*2-0.5, 0, 1, viewSudoko.frame.size.height)]];
    [viewSudoko.layer addSublayer:[self layerWithFrame:CGRectMake(0, CGRectGetHeight(viewSudoko.frame)/3.0-0.5, viewSudoko.frame.size.width, 1)]];
    [viewSudoko.layer addSublayer:[self layerWithFrame:CGRectMake(0, CGRectGetHeight(viewSudoko.frame)/3.0*2-0.5, viewSudoko.frame.size.width, 1)]];
    viewSudoko.alpha = 0;
    [_viewForPreview addSubview:viewSudoko];
    self.viewSudoku = [viewSudoko autorelease];
    
    UIButton * btnTakePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * imageTakePoto = [UIImage imageNamed:@"camera_shutter"];
    [btnTakePhoto setImage:imageTakePoto forState:UIControlStateNormal];
    btnTakePhoto.frame = CGRectMake(0, 0, imageTakePoto.size.width, imageTakePoto.size.height);
    btnTakePhoto.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, self.view.frame.size.width + (self.view.frame.size.height - self.view.frame.size.width - 44)/2+20);
    [self.view addSubview:btnTakePhoto];
    [btnTakePhoto addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * btnSudoko = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * imageSudoku = [UIImage imageNamed:@"camera_9_on"];
    [btnSudoko setImage:[imageSudoku coverTintColor:[UIColor colorWithRed:244/255.0 green:242/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
    [btnSudoko setImage:imageSudoku forState:UIControlStateSelected];
    btnSudoko.frame = CGRectMake(0, 0, imageSudoku.size.width, imageSudoku.size.height);
    btnSudoko.center = CGPointMake(CGRectGetWidth(self.view.frame)/3.0, CGRectGetMaxY(_viewForPreview.frame)+CGRectGetHeight(btnSudoko.frame)+17);
    [self.view addSubview:btnSudoko];
    [btnSudoko addTarget:self action:@selector(changeSudokoStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFlash.tag = 1000;
    UIImage * imageFlash = [UIImage imageNamed:@"camera_flash_off"];
    [btnFlash setImage:imageFlash forState:UIControlStateNormal];
    btnFlash.frame = CGRectMake(0, 0, imageFlash.size.width, imageFlash.size.height);
    btnFlash.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.8*2, CGRectGetMaxY(_viewForPreview.frame)+CGRectGetHeight(btnFlash.frame)+17);
    [self.view addSubview:btnFlash];
    [btnFlash addTarget:self action:@selector(changeFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewPreview:)];
    [_viewForPreview addGestureRecognizer:tap];
    [tap release];
}


#pragma mark 更改对焦点

- (void)tapViewPreview:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:tap.view];
    [_manager changePointOfInterestInPreviewLayer:point block:^{
        
        NSLog(@"complete");
    }];
}



#pragma mark 拍照

- (void)takePhoto:(id)sender
{
    self.view.userInteractionEnabled = NO;
//    [_viewForPreview startLoading];
//    [_viewForPreview.viewIndicator viewWithTag:INDICATOR_TAG].backgroundColor = [UIColor clearColor];
    
    __block typeof(self) _self = self;
    [_manager takePhotoBlock:^(UIImage *image) {
       
        [_self showImage:image];
    }];
}


- (void)showImage:(UIImage *)image
{
    GLEditPhotoViewController * vc = [[GLEditPhotoViewController alloc] init];
    vc.image = image;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


#pragma mark 闪光灯

- (void)changeFlashMode:(UIButton *)btn
{
    switch (btn.tag-1000)
    {
        case AVCaptureFlashModeOff:
        {
            [_manager changeFlashMode:AVCaptureFlashModeOn];
            [btn setImage:[UIImage imageNamed:@"camera_flash_on"] forState:UIControlStateNormal];
            btn.tag = 1001;
        }break;
            
        case AVCaptureFlashModeOn:
        {
            [_manager changeFlashMode:AVCaptureFlashModeAuto];
            [btn setImage:[UIImage imageNamed:@"camera_flash_auto"] forState:UIControlStateNormal];
            btn.tag = 1002;
        }break;
            
        case AVCaptureFlashModeAuto:
        {
            [_manager changeFlashMode:AVCaptureFlashModeOff];
            [btn setImage:[UIImage imageNamed:@"camera_flash_off"] forState:UIControlStateNormal];
            btn.tag = 1000;
        }break;
            
        default:
            break;
    }
}


#pragma mark 九宫格

- (void)changeSudokoStatus:(UIButton *)btn
{
    [UIView beginAnimations:nil context:nil];
    _viewSudoku.alpha = _viewSudoku.alpha ? 0 : 1;
    btn.selected = _viewSudoku.alpha;
    [UIView commitAnimations];
}


#pragma mark 工具

- (CALayer *)layerWithFrame:(CGRect)frame
{
    CALayer * layer = [[CALayer alloc] init];
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.frame = frame;
    return [layer autorelease];
}

@end