//
//  GSIndicatorView.m
//  zaozaoAssessmentSliderDemo
//
//  Created by OSU on 16/7/8.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSIndicatorView.h"
#import "GSDefine.h"

@interface GSIndicatorView ()

@property (retain, nonatomic) UILabel * nowLabel;
@property (retain, nonatomic) UILabel * sumLabel;

@end


@implementation GSIndicatorView

+ (instancetype)zaozaoAssessmentIndicator
{
    GSIndicatorView * indicatorView = [[GSIndicatorView alloc] initWithZaozaoAssessmentIndicator];
    return [indicatorView autorelease];
}


- (void)dealloc
{
    [_nowLabel release];
    [_sumLabel release];
    [super dealloc];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        _nowLabel = [[UILabel alloc] init];
        _sumLabel = [[UILabel alloc] init];
    }
    return self;
}


- (void)setNow:(NSInteger)now
{
    _now = now;
    if (!_now)
    {
        _now = 1;
    }
    if (_now > _sum)
    {
        _now = _sum;
    }
    _nowLabel.text = [NSString stringWithFormat:@"%ld",(long)_now];
}


- (void)setSum:(NSInteger)sum
{
    _sum = sum;
    _sumLabel.text = [NSString stringWithFormat:@"%ld",(long)sum];
}


- (instancetype)initWithZaozaoAssessmentIndicator
{
    self = [self initWithFrame:CGRectZero];
    if (self)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"questionnaire_progress_mark"]];
        self.frame = imageView.frame;
        [self addSubview:imageView];
        [imageView release];
        
        _nowLabel.frame = CGRectMake(5, 5, 25, 10);
        _sumLabel.frame = CGRectMake(5, CGRectGetMaxY(_nowLabel.frame)+3.5, 25, 10);
        
        _nowLabel.font = [UIFont systemFontOfSize:12];
        _sumLabel.font = [UIFont systemFontOfSize:12];
        
        _nowLabel.textAlignment = NSTextAlignmentCenter;
        _sumLabel.textAlignment = NSTextAlignmentCenter;
        
        _nowLabel.textColor = [UIColor whiteColor];
        _sumLabel.textColor = GSColorHex(0xffa157);
        
        [self addSubview:_nowLabel];
        [self addSubview:_sumLabel];
    }
    return self;
}


- (void)setZaozaoCenter:(CGPoint)center
{
    self.center = CGPointMake(center.x, (-self.frame.size.height/2+6.5)+center.y);
}


@end
