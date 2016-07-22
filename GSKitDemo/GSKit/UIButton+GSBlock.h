//
//  UIButton+GSBlock.h
//  zaozao
//
//  Created by OSU on 16/5/25.
//  Copyright © 2016年 miao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GSActionBlock)(UIButton * sender);

@interface UIButton (GSBlock)

//现阶段controlEvents尚无法对应block回调，只能设置一个controlEvents
- (void)addAction:(GSActionBlock)block forControlEvents:(UIControlEvents)controlEvents;

@end
