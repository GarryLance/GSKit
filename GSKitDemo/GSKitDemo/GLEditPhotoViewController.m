//
//  GLEditPhotoViewController.m
//  GLKit
//
//  Created by OSU on 16/6/2.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GLEditPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>// ios 8
#import <Photos/Photos.h>// ios 9



@interface GLEditPhotoViewController ()



@end



@implementation GLEditPhotoViewController


- (void)dealloc
{
    [_image release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"camera_background_color"]];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = _image;
    [self.view addSubview:imageView];
    [imageView release];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
