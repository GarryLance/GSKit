//
//  WattingCircleView.m
//  Together
//
//  Created by OSU on 16/3/22.
//  Copyright © 2016年 Garry. All rights reserved.
//

#import "GLWaittingView.h"

@interface GLWaittingView ()

@property(retain,nonatomic)CAShapeLayer  *progressLayer;
@property(assign,nonatomic)CADisplayLink *progressDisplayLink;

@property(assign,nonatomic)NSInteger framesAll;
@property(assign,nonatomic)NSInteger framesRemain;
@property(assign,nonatomic)NSInteger frameForCountSecond;

@property(assign,nonatomic)void(^remainBlock)(NSInteger second);
@property(assign,nonatomic)void(^endBlock)();

@end


@implementation GLWaittingView

- (void)dealloc
{
    [_progressDisplayLink invalidate];
    [_progressLayer release];
    if (_remainBlock)
    {
        Block_release(_remainBlock);
    }
    if (_endBlock)
    {
        Block_release(_endBlock);
    }
    [super dealloc];
}

- (void)setSecondsAll:(NSInteger)secondsAll
{
    _secondsAll = secondsAll;
}

- (void)setSecondsRemain:(NSInteger)secondsRemain
{
    _secondsRemain = secondsRemain;
}

- (instancetype)initWithDiameter:(CGFloat)diameter secondRemain:(NSInteger)secondRemain secondAll:(NSInteger)secondAll lineWidth:(CGFloat)lineWidth color:(UIColor *)color secondRemainBlock:(void (^)(NSInteger))remainBlock endBlock:(void (^)())endBlock
{
    self = [super initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    if (self)
    {
        self.framesAll     = self.secondsAll    * 60;
        self.framesRemain  = self.secondsRemain * 60;
        
        _progressLayer = [[CAShapeLayer alloc] init];
        _progressLayer.frame   = self.bounds;
        UIBezierPath *path =  [UIBezierPath bezierPathWithArcCenter:CGPointMake(diameter / 2.f, diameter / 2.f)
                                                             radius:diameter / 2.f
                                                         startAngle:- M_PI_2
                                                           endAngle:M_PI * 1.5
                                                          clockwise:YES];
        _progressLayer.path = path.CGPath;
        _progressLayer.lineWidth   = lineWidth;
        _progressLayer.strokeColor = color.CGColor;
        _progressLayer.fillColor   = [UIColor clearColor].CGColor;
        _progressLayer.lineCap     = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd   = self.framesRemain/(double)self.framesAll;
        [self.layer addSublayer:_progressLayer];
        
        _remainBlock = Block_copy(remainBlock);
        _endBlock    = Block_copy(endBlock);
    }
    return self;
}

- (void)startCountDown
{
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeProgress)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _progressDisplayLink = displayLink;
}

- (void)changeProgress
{
    self.frameForCountSecond++;
    if (self.frameForCountSecond == 60)
    {
        self.frameForCountSecond = 0;
        self.secondsRemain--;
        if (_remainBlock)
        {
            _remainBlock(self.secondsRemain);
        }
    }
    _progressLayer.strokeEnd = self.framesRemain--/(double)self.framesAll;
    if (!self.framesRemain)
    {
        [_progressDisplayLink invalidate];
        _progressDisplayLink = nil;
        if (_endBlock)
        {
            _endBlock();
        }
    }
}

@end
