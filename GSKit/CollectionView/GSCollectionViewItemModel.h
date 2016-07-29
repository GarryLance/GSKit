//
//  GSCollectionViewItemModel.h
//  GSKitDemo
//
//  Created by OSU on 16/7/28.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSModelBase.h"

@interface GSCollectionViewItemModel : GSModelBase

@property (copy, nonatomic) NSString * placeholderImageName;
@property (copy, nonatomic) NSString * imageName;
@property (copy, nonatomic) NSURL    * imageUrl;

@property (copy, nonatomic) NSString * title;
@property (copy, nonatomic) NSDictionary * titleAttributes;

@end
