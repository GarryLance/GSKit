//
//  GSLayer.m
//  GSKitDemo
//
//  Created by OSU on 16/7/27.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSLayer.h"



@interface GSLayer ()



@end



@implementation GSLayer


- (void)dealloc
{
    Block_release(_blockForFrameChange);
    _blockForFrameChange = nil;
    [super dealloc];
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_blockForFrameChange)
    {
        _blockForFrameChange(frame);
    }
}


- (void)setBlockForFrameChange:(void (^)(CGRect))blockForFrameChange
{
    if (_blockForFrameChange)
    {
        Block_release(_blockForFrameChange);
    }
    _blockForFrameChange = Block_copy(blockForFrameChange);
}

@end
