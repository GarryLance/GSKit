//
//  GSShapeSlider.h
//  zaozaoAssessmentSliderDemo
//
//  Created by OSU on 16/7/8.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSIndicatorView.h"

@interface GSShapeSlider : UIView

/**进度(0~1)*/
@property (assign, nonatomic) CGFloat progress;

@property (assign, nonatomic) NSInteger sum;

+ (instancetype)zaozaoAssessmentSlider:(CGFloat)height;

@end
