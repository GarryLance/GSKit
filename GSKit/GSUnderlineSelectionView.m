//
//  UnderlineSelectionView.m
//  rlf
//
//  Created by OSU on 16/6/23.
//  Copyright © 2016年 Sigma. All rights reserved.
//

#import "GSUnderlineSelectionView.h"

@interface GSUnderlineSelectionView ()

@property(copy,nonatomic) NSArray * titleArray;
@property(copy,nonatomic) NSDictionary * commandAttributes;
@property(copy,nonatomic) NSDictionary * selectedAttributes;

@property(retain,nonatomic) CALayer * underlineLayer;

@end


@implementation GSUnderlineSelectionView

- (void)dealloc
{
    [_lineColor release];
    [_underlineLayer release];
    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)setTitles:(NSArray *)titles commandAttributes:(NSDictionary *)commandAttributes selectedAttributes:(NSDictionary *)selectedAttributes
{
    CGFloat margin = 20;
    CGFloat padding = 50;
    CGFloat buttonWidth = (self.frame.size.width - margin*2 - padding * (titles.count - 1))/titles.count;
    
    _lineWidth  = !_lineWidth ? buttonWidth : _lineWidth;
    _lineHeight = !_lineHeight ? 2 : _lineHeight;
    _lineColor  = !_lineColor ? [UIColor grayColor] : _lineColor;
    
    if (!commandAttributes)
    {
        commandAttributes = @{NSForegroundColorAttributeName:[UIColor grayColor],
                              NSFontAttributeName:[UIFont systemFontOfSize:16]};
    }
    if (!selectedAttributes)
    {
        selectedAttributes = commandAttributes;
    }
    
    self.titleArray = titles;
    self.commandAttributes = commandAttributes;
    self.selectedAttributes = selectedAttributes;
    
    //clean
    while (self.layer.sublayers)
    {
        [[self.layer.sublayers firstObject] removeFromSuperlayer];
    }
    
    //add
    for (int i = 0 ; i < titles.count; i++)
    {
        UIButton * button = [[UIButton alloc] init];
        button.frame = CGRectMake(margin+(buttonWidth+padding)*i, 0, buttonWidth, self.frame.size.height);
        button.tag = 200+i;
        NSAttributedString * astr = [[NSAttributedString alloc] initWithString:[titles objectAtIndex:i] attributes:commandAttributes];
        [button setAttributedTitle:astr forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [astr release];
        [button release];
    }
    
    //underline
    _underlineLayer = [[CALayer alloc] init];
    _underlineLayer.frame = CGRectMake(0, self.frame.size.height-_lineHeight, _lineWidth, _lineHeight);
    _underlineLayer.backgroundColor = _lineColor.CGColor;
    _underlineLayer.cornerRadius = _lineCapRound ? _lineHeight/2 : 0;
    [self.layer addSublayer:_underlineLayer];
    
    //default
    [self btnAction:[self.subviews firstObject]];
}


- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (self.subviews.count > selectedIndex)
    {
        _selectedIndex = selectedIndex;
        [self btnAction:[self.subviews objectAtIndex:selectedIndex]];
    }
}


- (void)btnAction:(UIButton *)btn
{
    if (_buttonActionBlock)
    {
        _buttonActionBlock(self.titleArray, btn.tag-200);
    }
    
    for (UIButton * button in self.subviews)
    {
        if ([button isKindOfClass:[UIButton class]])
        {
            if (button == btn)
            {
                NSAttributedString * astr = [[NSAttributedString alloc] initWithString:[_titleArray objectAtIndex:button.tag-200] attributes:_selectedAttributes];
                [button setAttributedTitle:astr forState:UIControlStateNormal];
                _underlineLayer.position = CGPointMake(button.center.x, _underlineLayer.position.y);
            }
            else
            {
                NSAttributedString * astr = [[NSAttributedString alloc] initWithString:[_titleArray objectAtIndex:button.tag-200] attributes:_commandAttributes];
                [button setAttributedTitle:astr forState:UIControlStateNormal];
                [astr release];
            }
        }
    }
}

@end
