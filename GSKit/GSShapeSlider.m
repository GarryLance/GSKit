//
//  GSShapeSlider.m
//  zaozaoAssessmentSliderDemo
//
//  Created by OSU on 16/7/8.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSShapeSlider.h"
#import "GSDefine.h"

@interface GSShapeSlider ()

@property (strong, nonatomic) __kindof UIView * indicatorView;

@property (strong, nonatomic) UIView * progressView;

@end


@implementation GSShapeSlider


+ (instancetype)zaozaoAssessmentSlider:(CGFloat)height
{
    GSShapeSlider * slider = [[GSShapeSlider alloc] initWithZaozaoAssessmentSlider:height];
    return slider;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (instancetype)initWithZaozaoAssessmentSlider:(CGFloat)height
{
    self = [self initWithFrame:CGRectMake(0, 0, 36, height)];
    if (self){
        
        CGFloat lineWidth = 6;
        
        UIView * progressView = [[UIView alloc] init];
        progressView.frame = CGRectMake((36-lineWidth)/2, 0, lineWidth, _progress);
        progressView.layer.cornerRadius = lineWidth/2;
        progressView.layer.backgroundColor = GSRGBA(253,142,70,1).CGColor;
        [self addSubview:progressView];
        self.progressView = progressView;
        
        UIView * trackView = [[UIView alloc] init];
        trackView.frame = CGRectMake((36-lineWidth)/2, 0, lineWidth, height);
        trackView.layer.cornerRadius = progressView.layer.cornerRadius;
        trackView.layer.backgroundColor = GSRGBA(245, 242, 215, 1).CGColor;
        [self insertSubview:trackView belowSubview:progressView];

        GSIndicatorView * indicatorView = [GSIndicatorView zaozaoAssessmentIndicator];
        [indicatorView setZaozaoCenter:CGPointMake(indicatorView.frame.size.width/2, 0)];
        indicatorView.now = 0;
        indicatorView.sum = 50;
        [self addSubview:indicatorView];
        self.indicatorView = indicatorView;
    }
    return self;
}


- (void)setSum:(NSInteger)sum
{
    _sum = sum;
    [_indicatorView setSum:sum];
}


//0~1
- (void)setProgress:(CGFloat)progress
{
    progress = progress > 1 ?  1 : progress;
    progress = progress < 0 ?  0 : progress;
    _progress = progress;
    _progressView.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, _progressView.frame.size.width, self.frame.size.height*progress);
    [_indicatorView setZaozaoCenter:CGPointMake(_indicatorView.frame.size.width/2, self.frame.size.height*progress)];
    [_indicatorView setNow:[_indicatorView sum]*progress + 1];
}


- (void)changeProgress
{
//    self.progress += 0.001;
}


@end
