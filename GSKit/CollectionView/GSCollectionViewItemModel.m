//
//  GSCollectionViewItemModel.m
//  GSKitDemo
//
//  Created by OSU on 16/7/28.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSCollectionViewItemModel.h"

@implementation GSCollectionViewItemModel

- (void)dealloc
{
    [_imageUrl release];
    [super dealloc];
}

@end
