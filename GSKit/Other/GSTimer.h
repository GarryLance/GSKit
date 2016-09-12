//
//  GSTimer.h
//  zaozao
//
//  Created by OSU on 16/4/20.
//  Copyright © 2016年 miao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GSTimerProtocol;


@interface GSTimer : NSObject

@property(assign,nonatomic) NSInteger seconds;
@property(assign,nonatomic) NSInteger secondsStart;
@property(assign,nonatomic) NSInteger secondsSum;
@property(weak,nonatomic) id <GSTimerProtocol> delegate;

+ (instancetype)timerCountDown:(NSInteger)secondsSum secondsRemain:(NSInteger)seconds delegate:(id <GSTimerProtocol>)delegate;

@end


@protocol GSTimerProtocol <NSObject>

@optional

/**
 每次循环的开始。返回YES为继续下一次循环，返回NO则退出循环。
 @param timer GSTimer计时器
 @returns 返回YES为继续下一次循环，返回NO则退出循环。
 */
- (BOOL)timerLoopStart:(GSTimer *)timer;

/**
 每次循环的结束。
 @param timer GSTimer计时器
 */
- (void)timerLoopEnd:(GSTimer *)timer;

/**
 最后一次循环结束。
 @param timer GSTimer计时器
 */
- (void)timerDidOver:(GSTimer *)timer;

@end



@interface GSTimer ()

+ (NSString *)stringForTimeFormat:(NSString *)format interval:(NSTimeInterval)interval;

@end