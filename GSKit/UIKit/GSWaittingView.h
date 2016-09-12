//
//  WattingCircleView.h
//  Together
//
//  Created by OSU on 16/3/22.
//  Copyright © 2016年 Garry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSWaittingView : UIView

/**总共时间*/
@property(assign,nonatomic,readonly)NSInteger secondsAll;
/**剩余时间*/
@property(assign,nonatomic,readonly)NSInteger secondsRemain;

/**
 生成倒数视图
 @param diameter      圆形直径
 @param secondRemain  剩余时间
 @param secondAll     总共时间
 @param lineWidth     线粗
 @param color         颜色
 @returns 倒数视图
 */
- (instancetype)initWithDiameter:(CGFloat)diameter secondRemain:(NSInteger)secondRemain secondAll:(NSInteger)secondAll lineWidth:(CGFloat)lineWidth color:(UIColor *)color secondRemainBlock:(void(^)(NSInteger second))remainBlock endBlock:(void(^)())endBlock;

- (void)startCountDown;

@end
