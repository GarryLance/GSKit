//
//  UnderlineSelectionView.h
//  rlf
//
//  Created by OSU on 16/6/23.
//  Copyright © 2016年 Sigma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSUnderlineSelectionView : UIView

- (void)setTitles:(NSArray *)titles commandAttributes:(NSDictionary *)commandAttributes selectedAttributes:(NSDictionary *)selectedAttributes;

@property(assign,nonatomic) NSInteger selectedIndex;

@property(copy,nonatomic) void(^buttonActionBlock)(NSArray * titles,NSInteger index);

@property(assign,nonatomic) CGFloat lineWidth;
@property(assign,nonatomic) CGFloat lineHeight;
@property(strong,nonatomic) UIColor * lineColor;
@property (assign, nonatomic) BOOL lineCapRound;

@end
