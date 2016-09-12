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
    /**只有图片*/
    GSCollectionItemTypeImageOnly,
    /**文字与图片分离*/
    GSCollectionItemTypeDetatched,
};

@class GSCollectionViewItem;

typedef void(^GSItemFirstLoadBlock)(__kindof GSCollectionViewItem * item);
typedef BOOL(^GSItemWillSetupDataBlock)(__kindof GSCollectionViewItem * item, __kindof GSCollectionViewItemModel * model);
typedef void(^GSItemDidSetupDataBlock)(__kindof GSCollectionViewItem * item, __kindof GSCollectionViewItemModel * model);


@interface GSCollectionViewItem : UICollectionViewCell

@property (assign, nonatomic) BOOL isFirstLoaded;
@property (strong, nonatomic) UIImageView * gs_imageView;
@property (strong, nonatomic) UILabel * gs_titleLabel;

/**item样式*/
@property (assign, nonatomic) GSCollectionItemType gs_itemType;

/**数据模型*/
@property (strong, nonatomic) GSCollectionViewItemModel * gs_model;

/**
 item首次加载回调
 @param  item  首次加载的item
 */
@property (assign, nonatomic) GSItemFirstLoadBlock gs_itemFirstLoadBlock;

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
