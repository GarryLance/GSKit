//
//  GSView.m
//  GSKitDemo
//
//  Created by OSU on 16/7/27.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSView.h"

@implementation GSView


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_blockForFrameChange)
    {
        _blockForFrameChange(frame);
    }
}


@end
