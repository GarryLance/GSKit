//
//  GSIndicatorView.h
//  zaozaoAssessmentSliderDemo
//
//  Created by OSU on 16/7/8.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSIndicatorView : UIView

@property (assign, nonatomic) NSInteger now;
@property (assign, nonatomic) NSInteger sum;

+ (instancetype)zaozaoAssessmentIndicator;

- (void)setZaozaoCenter:(CGPoint)center;

@end
