//
//  UIButton+GLBlock.h
//  zaozao
//
//  Created by OSU on 16/5/25.
//  Copyright © 2016年 miao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GLActionBlock)(UIButton * sender);

@interface UIButton (GLBlock)

//现阶段controlEvents尚无法对应block回调，只能设置一个controlEvents
- (void)addAction:(GLActionBlock)block forControlEvents:(UIControlEvents)controlEvents;

@end
