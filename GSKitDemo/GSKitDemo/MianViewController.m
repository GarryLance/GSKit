//
//  MianViewController.m
//  GSKit
//
//  Created by OSU on 16/5/31.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "MianViewController.h"
#import "GSDefine.h"
#import "GSModelBase.h"
#import "GSCameraNavigationController.h"
#import "GSPublishViewController.h"


@interface FunctionModel : GSModelBase

@property (strong, nonatomic) NSString * title;
@property (assign, nonatomic) Class functionClass;
@property (assign, nonatomic) BOOL isPresent;

+ (instancetype)modelWithTitle:(NSString *)title functionClass:(Class)class isPresent:(BOOL)isPresent;

@end



@implementation FunctionModel

+ (instancetype)modelWithTitle:(NSString *)title functionClass:(Class)class isPresent:(BOOL)isPresent
{
    FunctionModel * model = [[FunctionModel alloc] init];
    model.title = title;
    model.functionClass = class;
    model.isPresent = isPresent;
    return [model autorelease];
}

@end




@interface MianViewController () <UITableViewDelegate,UITableViewDataSource>

@property (copy, nonatomic) NSArray <FunctionModel *> * functionModels;

@end



@implementation MianViewController

- (void)dealloc
{
    [_functionModels release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"GSKitDemo";
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, GSSCREEN_WIDTH, GSSCREEN_HEIGHT - 64)];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [tableView release];
    
    [self setupFunctionModels];
}


- (void)setupFunctionModels
{
    NSMutableArray * array = [NSMutableArray array];
    [array addObject:[FunctionModel modelWithTitle:@"拍照" functionClass:[GSCameraNavigationController class] isPresent:YES]];
    [array addObject:[FunctionModel modelWithTitle:@"GSCollectionView" functionClass:[GSPublishViewController class] isPresent:NO]];
    self.functionModels = array;
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _functionModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [_functionModels objectAtIndex:indexPath.row].title;
    
    return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FunctionModel * model = [_functionModels objectAtIndex:indexPath.row];
    if ([model.functionClass isSubclassOfClass:[UIViewController class]])
    {
        UIViewController * vc = [[model.functionClass alloc] init];
        if (model.isPresent)
        {
            [self.navigationController presentViewController:vc animated:YES completion:nil];
            [vc release];
        }
        else
        {
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    }
}

@end
