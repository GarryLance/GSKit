//
//  GSCollectionViewCell.m
//  GSKitDemo
//
//  Created by OSU on 16/7/28.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSCollectionViewItem.h"
#import "GSDefine.h"


@implementation GSCollectionViewItem


- (void)dealloc
{
    [_gs_imageView release];
    [_gs_titleLabel release];
    [super dealloc];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _gs_imageView = [[UIImageView alloc] init];
        _gs_titleLabel = [[UILabel alloc] init];
        
        [self.contentView addSubview:_gs_imageView];
        [self.contentView addSubview:_gs_titleLabel];
    }
    return self;
}


- (void)setGs_itemType:(GSCollectionItemType)gs_itemType
{
    //重复设置则直接结束
    if (_gs_itemType == gs_itemType) return;
    
    _gs_itemType = gs_itemType;
    switch (gs_itemType)
    {
        case GSCollectionItemTypeNone:
        {
            
        }break;
            
        case GSCollectionItemTypeImageOnly:
        {
            CGFloat itemWidth  = self.frame.size.width;
            CGFloat itemHeight = self.frame.size.height;
            _gs_imageView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        }break;
            
        case GSCollectionItemTypeDetatched:
        {
            CGFloat itemWidth  = self.frame.size.width;
            CGFloat itemHeight = self.frame.size.height;
            _gs_imageView.frame = CGRectMake(0, 0, itemWidth, itemWidth);
            _gs_imageView.contentMode = UIViewContentModeScaleAspectFit;
            _gs_titleLabel.frame = CGRectMake(0, CGRectGetMaxY(_gs_imageView.frame), itemWidth, itemHeight - itemWidth);
        }break;
            
        default:
            break;
    }
}


- (void)setGs_model:(GSCollectionViewItemModel *)gs_model
{
    _gs_model = gs_model;
    
    //首次加载时调用回调
    if (!_isFirstLoaded && _gs_itemFirstLoadBlock)
    {
        _gs_itemFirstLoadBlock(self);
        _isFirstLoaded = YES;
    }
    
    //执行即将安装的回调
    if (_gs_itemWillSetupDataBlock)
    {
        if(!_gs_itemWillSetupDataBlock(self,gs_model)) return;
    }
    
    //安装title
    _gs_titleLabel.text = nil;
    _gs_titleLabel.attributedText = nil;
    if (gs_model.title && gs_model.titleAttributes)
    {
        _gs_titleLabel.attributedText = [[[NSAttributedString alloc] initWithString:gs_model.title attributes:gs_model.titleAttributes] autorelease];
    }
    else
    {
        _gs_titleLabel.text = gs_model.title;
    }
    
    //安装placeholder图
    if (gs_model.placeholderImageName)
    {
        _gs_imageView.image = [UIImage imageNamed:gs_model.placeholderImageName];
    }
    
    //安装图片
    _gs_imageView.image = nil;
    if (gs_model.imageName)
    {
        _gs_imageView.image = [UIImage imageNamed:gs_model.imageName];
    }
    else if (gs_model.imageUrl)
    {
        BLOCKSELF
        BLOCK_TYPE(gs_model, __gs_model);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:__gs_model.imageUrl]];
            if (image)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    if (__gs_model == blockSelf.gs_model)
                    {
                        blockSelf.gs_imageView.image = image;
                    }
                });
            }
        });
    }
    
    //执行完成安装的回调
    if (_gs_itemDidSetupDataBlock)
    {
        _gs_itemDidSetupDataBlock(self,gs_model);
    }
}


@end
