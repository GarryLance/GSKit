//
//  UIView+Loading.m
//  Together
//
//  Created by OSU on 16/3/29.
//  Copyright © 2016年 Garry. All rights reserved.
//

#import "UIView+GSLoading.h"
#import <objc/runtime.h>

#define PROCESS_LAYER_NAME  @"progress"


@implementation UIView (GSLoading)


static char   LoadingViewIndicator;


- (void)setViewIndicator:(UIView *)viewIndicator
{
    [self willChangeValueForKey:@"viewIndicator"];
    objc_setAssociatedObject(self, &LoadingViewIndicator, viewIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"viewIndicator"];
}


- (UIView *)viewIndicator
{
    return objc_getAssociatedObject(self, &LoadingViewIndicator);
}


- (void)setupIndicatorView
{
    if (!self.viewIndicator)
    {
        self.viewIndicator = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.viewIndicator.alpha  = 0;
        self.viewIndicator.hidden = YES;
        self.viewIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self addSubview:self.viewIndicator];
        
        UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        indicator.center = CGPointMake(self.viewIndicator.frame.size.width/2, self.viewIndicator.frame.size.height/2);
        indicator.tag = INDICATOR_TAG;
        indicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        indicator.layer.cornerRadius = 5;
        indicator.layer.masksToBounds = YES;
        indicator.hidesWhenStopped    = YES;
        [self.viewIndicator addSubview:indicator];
        [indicator release];
    }
}


- (CAShapeLayer *)setupLoadingProcessView
{
    [self setupIndicatorView];
    CAShapeLayer * progressLayer = nil;
    for (CALayer * sublayer in self.viewIndicator.layer.sublayers)
    {
        if ([sublayer.name isEqualToString:PROCESS_LAYER_NAME])
        {
            progressLayer = (CAShapeLayer *)sublayer;
        }
    }
    if (!progressLayer)
    {
        CGFloat diameter = 25;
        progressLayer = [[CAShapeLayer alloc] init];
        progressLayer.name = PROCESS_LAYER_NAME;
        progressLayer.frame    = CGRectMake(0, 0, diameter, diameter);
        progressLayer.position = CGPointMake(self.viewIndicator.frame.size.width/2, self.viewIndicator.frame.size.height/2);
        UIBezierPath *path =  [UIBezierPath bezierPathWithArcCenter:CGPointMake(diameter / 2.f, diameter / 2.f)
                                                             radius:diameter / 2.f
                                                         startAngle:- M_PI_2
                                                           endAngle:M_PI * 1.5
                                                          clockwise:YES];
        progressLayer.path = path.CGPath;
        progressLayer.lineWidth   = 5;
        progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        progressLayer.fillColor   = [UIColor clearColor].CGColor;
        progressLayer.fillRule    = kCAFillRuleNonZero;
        progressLayer.lineCap     = kCALineCapRound;
        progressLayer.strokeStart = 0;
        [self.viewIndicator.layer addSublayer:progressLayer];
        [progressLayer release];
        
//        NSLog(@"%@",self.viewIndicator.layer.sublayers);
        
        CAShapeLayer * trackLayer = [[CAShapeLayer alloc] init];
        trackLayer.frame = progressLayer.frame;
        trackLayer.path = progressLayer.path;
        trackLayer.lineWidth   = progressLayer.lineWidth;
        trackLayer.strokeColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        trackLayer.fillColor   = [UIColor clearColor].CGColor;
        trackLayer.fillRule    = kCAFillRuleNonZero;
        trackLayer.lineCap     = kCALineCapRound;
        trackLayer.strokeStart = 0;
        trackLayer.strokeEnd   = 1;
        [self.viewIndicator.layer insertSublayer:trackLayer below:progressLayer];
        [trackLayer release];
        
//        NSLog(@"%@",self.viewIndicator.layer.sublayers);
    }
    return progressLayer;
}


- (void)startLoading
{
    [self setupIndicatorView];
    if (self.viewIndicator.hidden)
    {
        self.userInteractionEnabled = NO;
        self.viewIndicator.hidden = NO;
        [self bringSubviewToFront:self.viewIndicator];
        [UIView animateWithDuration:0.3 animations:^{
            self.viewIndicator.alpha = 1;
        }];
    }
    else
    {
        while ([self.viewIndicator.layer.sublayers.lastObject isKindOfClass:[CAShapeLayer class]])
        {
            [self.viewIndicator.layer.sublayers.lastObject removeFromSuperlayer];
        }
    }
    [(UIActivityIndicatorView*)[self.viewIndicator viewWithTag:INDICATOR_TAG] startAnimating];
}


- (void)startLoadingWithoutSandwich
{
    [self setupIndicatorView];
    if (self.viewIndicator.hidden)
    {
        self.userInteractionEnabled = NO;
        self.viewIndicator.hidden = NO;
        [self bringSubviewToFront:self.viewIndicator];
        [UIView animateWithDuration:0.3 animations:^{
            self.viewIndicator.alpha = 1;
        }];
    }
    else
    {
        while ([self.viewIndicator.layer.sublayers.lastObject isKindOfClass:[CAShapeLayer class]])
        {
            [self.viewIndicator.layer.sublayers.lastObject removeFromSuperlayer];
        }
    }
    [(UIActivityIndicatorView*)[self.viewIndicator viewWithTag:INDICATOR_TAG] startAnimating];
    
    [self.viewIndicator viewWithTag:INDICATOR_TAG].backgroundColor = [UIColor clearColor];
}


- (void)loadingProcess:(NSInteger)percentDone
{
    [(UIActivityIndicatorView*)[self.viewIndicator viewWithTag:INDICATOR_TAG] stopAnimating];
    CAShapeLayer * progressLayer = [self setupLoadingProcessView];
    progressLayer.strokeEnd = percentDone*0.01;
}


- (void)loadingProcess:(NSInteger)percentDone autoHideUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [self loadingProcess:percentDone];
    if (percentDone == 100)
    {
        if (userInteractionEnabled)
        {
            [self stopLoading];
        }
        else
        {
            [self stopLoadingNoUserInteractionEnabled];
        }
    }
}


- (void)stopLoading
{
    [self retain];
    [UIView animateWithDuration:0.3 animations:^{
        self.viewIndicator.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.viewIndicator.alpha == 0)
        {
            self.viewIndicator.hidden = YES;
            self.userInteractionEnabled = YES;
            [((UIActivityIndicatorView*)[self.viewIndicator viewWithTag:INDICATOR_TAG]) stopAnimating];
            [self release];
        }
    }];
}


- (void)stopLoadingNoUserInteractionEnabled
{
    [self retain];
    [UIView animateWithDuration:0.3 animations:^{
        self.viewIndicator.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.viewIndicator.alpha == 0)
        {
            self.viewIndicator.hidden = YES;
            [((UIActivityIndicatorView*)[self.viewIndicator viewWithTag:INDICATOR_TAG]) stopAnimating];
            [self release];
        }
    }];
}


@end
