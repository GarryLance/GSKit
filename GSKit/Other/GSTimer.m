//
//  GSTimer.m
//  zaozao
//
//  Created by OSU on 16/4/20.
//  Copyright © 2016年 miao. All rights reserved.
//

#import "GSTimer.h"
#import "GSDefine.h"

@implementation GSTimer

+ (instancetype)timerCountDown:(NSInteger)secondsSum secondsRemain:(NSInteger)seconds delegate:(id <GSTimerProtocol>)delegate
{
    GSTimer * timer = [[GSTimer alloc] init];
    timer.secondsSum   = secondsSum;
    timer.secondsStart = seconds;
    timer.seconds      = seconds;
    timer.delegate     = delegate;
    
    [timer countDownSeconds:seconds];
    
    return timer;
}


- (void)countDownSeconds:(NSInteger)seconds
{
    self.seconds = seconds;
    
    if ([self.delegate respondsToSelector:@selector(timerLoopStart:)])
    {
        if (![self.delegate timerLoopStart:self])
        {
            return;
        }
    }
    
    if (seconds)
    {
        BLOCKSELF
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([blockSelf.delegate respondsToSelector:@selector(timerLoopEnd:)])
            {
                [blockSelf.delegate timerLoopEnd:blockSelf];
            }
            [blockSelf countDownSeconds:seconds-1];
        });
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(timerLoopEnd:)])
        {
            [self.delegate timerLoopEnd:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(timerDidOver:)])
        {
            [self.delegate timerDidOver:self];
        }
    }
}


#pragma mark

+ (NSString *)stringForTimeFormat:(NSString *)format interval:(NSTimeInterval)interval
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:format ? format : @"HH:mm:ss"]; //you can vary the date string. Ex: "mm:ss"
    return [dateFormatter stringFromDate:date];
}

@end
