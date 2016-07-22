//
//  GLCalendar.h
//  zaozao
//
//  Created by OSU on 16/4/22.
//  Copyright © 2016年 miao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GL_ZZ_START_DATE_OF_THE_DAY  @"GLCalenderZeroZoneDateStartOfTheDay"
#define GL_ZZ_END_DATE_OF_THE_DAY    @"GLCalenderZeroZoneDateEndOfTheDay"

@interface GLCalendar : NSObject

/**
 获取与当前时区的日期相同的“UTC时间”，并获得“零时区”在该日期的开始时间与结束时间
 @returns NSDictionary 包含“UTC时间”当天开始时间和结束时间的字典
 */
+ (NSDictionary *)zeroZoneDateOfToday;

@end
