//
//  GSLayer.h
//  GSKitDemo
//
//  Created by OSU on 16/7/27.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface GSLayer : CALayer

/**frame设置完成的回调*/
@property(assign,nonatomic) void(^blockForFrameChange)(CGRect frame);

@end
