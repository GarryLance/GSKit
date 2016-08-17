//
//  GSEditPhotoViewController.m
//  GSKit
//
//  Created by OSU on 16/6/2.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSEditPhotoViewController.h"
#import "GSPublishViewController.h"
#import "GSDefine.h"
#import "GSCollectionViewController.h"
#import "GSUnderlineSelectionView.h"


@interface GSEditPhotoViewController ()

@property (retain, nonatomic) UIImageView * imageView;
@property (retain, nonatomic) GSCollectionViewController * collectionViewController;

@end



@implementation GSEditPhotoViewController


- (void)dealloc
{
    [_image release];
    [_imageView release];
    [_collectionViewController release];
    [super dealloc];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"camera_background_color"]];
    
    UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStep:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    [self setupImageView];
    [self setupBottomButtons];
    [self setupCollectionView];
}


- (void)nextStep:(id)sender
{
    GSPublishViewController * vc = [[GSPublishViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


- (void)setupImageView
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = _image;
    [self.view addSubview:imageView];
    [imageView release];
    self.imageView = imageView;
}


- (void)setupBottomButtons
{
    UIView * viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, GSSCREEN_HEIGHT-50-44, GSSCREEN_WIDTH, 50)];
    viewBottom.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewBottom];
    [viewBottom release];
    
    GSUnderlineSelectionView * underlineSelectionView = [[GSUnderlineSelectionView alloc] initWithFrame:CGRectMake(0, 7.5, GSSCREEN_WIDTH, 35)];
    underlineSelectionView.lineColor  = [UIColor orangeColor];
    underlineSelectionView.lineHeight = 6;
    underlineSelectionView.lineWidth = 80;
    underlineSelectionView.lineCapRound = YES;
    [underlineSelectionView setTitles:@[@"勋章贴纸",@"滤镜"] commandAttributes:nil selectedAttributes:nil];
    [viewBottom addSubview:underlineSelectionView];
    [underlineSelectionView release];
}


- (void)setupCollectionView
{
    //init collection vc
    GSCollectionViewController * vc = [[GSCollectionViewController alloc] initWithCommonLayoutWithItemSize:CGSizeMake(80, 115)
                                                                                               lineSpacing:20
                                                                                               itemSpacing:20
                                                                                              sectionInset:UIEdgeInsetsMake(20, 20, 20, 20)
                                                                                           scrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    //安装data
    [vc numberOfSections:1 numberOfItems:^NSInteger(NSInteger section) {
        
        return 100;
    } modelsForSection:nil modelsForItem:^(__kindof GSCollectionViewItemModel *itemModel, NSIndexPath *indexPath) {
        
        itemModel.imageName = @"camera_9_on";
        itemModel.title = @"hahahaha";
    }];
    
    //安装item
    for (GSCollectionViewSectionModel * sectionModel in vc.gs_dataModel.gs_sectionModels)
    {
        [vc blockForItemSection:sectionModel
             itemFirstLoadBlock:nil
             itemWillSetupBlock:^BOOL(__kindof GSCollectionViewItem *item, __kindof GSCollectionViewItemModel *model) {
                 
                 item.gs_imageView.backgroundColor = [UIColor whiteColor];
                 item.gs_itemType = GSCollectionItemTypeDetatched;
                 return YES;
             } itemDidSetupBlock:nil];
    }
    
    //安装action
    [vc setGs_didSelectCollectionViewItemBlock:^(GSCollectionViewController * vc, __kindof GSCollectionViewItem * item, __kindof GSCollectionViewItemModel * itemModel, NSIndexPath * indexPath) {
        
        GSDLog(@"%@",itemModel);
    }];

    vc.view.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame), GSSCREEN_WIDTH, 115+20+20+44);
    vc.collectionView.backgroundColor = [UIColor clearColor];
    vc.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:vc.view];
    [vc release];
    
    self.collectionViewController = vc;
}

@end
