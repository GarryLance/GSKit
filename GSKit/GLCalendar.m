//
//  GLCalendar.m
//  zaozao
//
//  Created by OSU on 16/4/22.
//  Copyright © 2016年 miao. All rights reserved.
//

#import "GLCalendar.h"

@implementation GLCalendar


+ (NSDictionary *)zeroZoneDateOfToday
{
    NSMutableDictionary * dictv = [NSMutableDictionary dictionary];
    
    NSTimeZone * systemTimeZone = [NSTimeZone systemTimeZone];
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                                fromDate:[NSDate date]];
    
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    [dictv setObject:[[calendar dateFromComponents:components] dateByAddingTimeInterval:systemTimeZone.secondsFromGMT] forKey:GL_ZZ_START_DATE_OF_THE_DAY];
    
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    [dictv setObject:[[calendar dateFromComponents:components] dateByAddingTimeInterval:systemTimeZone.secondsFromGMT] forKey:GL_ZZ_END_DATE_OF_THE_DAY];
    
    return [[dictv copy] autorelease];
}


@end
