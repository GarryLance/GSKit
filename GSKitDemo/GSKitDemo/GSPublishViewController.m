//
//  GSPublishViewController.m
//  GSKit
//
//  Created by OSU on 16/6/2.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSPublishViewController.h"
#import "GSDefine.h"
#import "GSCollectionViewController.h"


@interface GSPublishViewController ()

@end



@implementation GSPublishViewController

- (void)dealloc
{
    [super dealloc];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"camera_background_color"]];
    
    UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(uploadStatus:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
}


- (void)uploadStatus:(id)sender
{
    
}

@end
