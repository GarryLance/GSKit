//
//  MianViewController.m
//  GLKit
//
//  Created by OSU on 16/5/31.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "MianViewController.h"
#import "GLCameraNavigationController.h"



@interface MianViewController ()


@end



@implementation MianViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GLCameraNavigationController * vc = [[GLCameraNavigationController alloc] init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
    [vc release];
}



@end
