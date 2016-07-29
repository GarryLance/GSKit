//
//  GSCameraNavigationController.m
//  GSKit
//
//  Created by OSU on 16/6/2.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSCameraNavigationController.h"
#import "GSCameraViewController.h"



@interface GSCameraNavigationController ()


@end



@implementation GSCameraNavigationController


- (instancetype)init
{
    GSCameraViewController * vc = [[GSCameraViewController alloc] init];
    self = [super initWithRootViewController:[vc autorelease]];
    if (self)
    {
        self.navigationBar.translucent = NO;
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"camera_background_color"] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage imageNamed:@"camera_background_color"];
        
        //barItem 颜色
        [self.navigationBar setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navColor"]]];
        
        vc.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_titlebar_close_orange"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)] autorelease];
    }
    return self;
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    
    if (self.viewControllers.count > 1)
    {
        UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_titlebar_back_orange"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        viewController.navigationItem.leftBarButtonItem = left;
        [left release];
        
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}


- (void)dismissAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)backAction:(id)sender
{
    [self popViewControllerAnimated:YES];
}


@end
