//
//  GSCollectionViewCell.h
//  GSKitDemo
//
//  Created by OSU on 16/7/28.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSCollectionViewItemModel.h"


typedef NS_ENUM(NSInteger,GSCollectionItemType)
{
    /**没有样式*/
    GSCollectionItemTypeNone,
    /**文字与图片分离*/
    GSCollectionItemTypeDetatched,
};

@class GSCollectionViewItem;

typedef BOOL(^GSItemWillSetupDataBlock)(__kindof GSCollectionViewItem * item, __kindof GSCollectionViewItemModel * model);
typedef void(^GSItemDidSetupDataBlock)(__kindof GSCollectionViewItem * item, __kindof GSCollectionViewItemModel * model);


@interface GSCollectionViewItem : UICollectionViewCell

@property (retain, nonatomic) UIImageView * gs_imageView;
@property (retain, nonatomic) UILabel * gs_titleLabel;

/**item样式*/
@property (assign, nonatomic) GSCollectionItemType gs_itemType;

/**数据模型*/
@property (retain, nonatomic) GSCollectionViewItemModel * gs_model;

/**
 item即将安装数据的回调
 @param  item  即将进行安装的item
 @param  model item安装使用的数据模型
 @return 指定是否继续执行默认安装程序
 */
@property (assign, nonatomic) GSItemWillSetupDataBlock gs_itemWillSetupDataBlock;


/**
 item完成安装数据的回调
 @param  item  完成模型安装的item
 @param  model item安装使用的数据模型
 */
@property (assign, nonatomic) GSItemDidSetupDataBlock gs_itemDidSetupDataBlock;

@end
