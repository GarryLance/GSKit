//
//  GSView.h
//  GSKitDemo
//
//  Created by OSU on 16/7/27.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSView : UIView

/**frame设置完成的回调*/
@property(copy, nonatomic) void(^blockForFrameChange)(CGRect frame);

@end
