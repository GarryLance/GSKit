//
//  GSDemoCollectionViewController.m
//  GSKitDemo
//
//  Created by Garry on 16/9/12.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSDemoCollectionViewController.h"
#import "GSKit.h"


@interface GSDemoCollectionViewController ()

@end



@implementation GSDemoCollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupCollectionView];
}


- (void)setupCollectionView
{
    GSCollectionViewController * vc = [[GSCollectionViewController alloc] initWithCommonLayoutWithItemSize:CGSizeMake(80, 100)
                                                                                               lineSpacing:20
                                                                                               itemSpacing:20
                                                                                              sectionInset:UIEdgeInsetsMake(20, 20, 20, 20)
                                                                                           scrollDirection:UICollectionViewScrollDirectionVertical];
    
    vc.collectionView.backgroundColor = [UIColor whiteColor];
    
    //安装模型
    [vc numberOfSections:1 numberOfItems:^NSInteger(NSInteger section) {
        
        return 50;
    } modelsForSection:^(__kindof GSCollectionViewSectionModel *sectionModel, NSInteger section) {
        
    } modelsForItem:^(__kindof GSCollectionViewItemModel *itemModel, NSIndexPath *indexPath) {
        
        itemModel.title = [NSString stringWithFormat:@"item_%d",(int)indexPath.item];
    }];

    //安装事件
    for (GSCollectionViewSectionModel * sectionModel in vc.gs_dataModel.gs_sectionModels)
    {
        [vc blockForItemSection:sectionModel
             itemFirstLoadBlock:^(__kindof GSCollectionViewItem *item) {
                
                 item.backgroundColor = [UIColor orangeColor];
                 item.gs_titleLabel.backgroundColor = [UIColor cyanColor];
                 item.gs_itemType = GSCollectionItemTypeDetatched;
                 
             } itemWillSetupBlock:nil itemDidSetupBlock:nil];
    }
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}


@end
