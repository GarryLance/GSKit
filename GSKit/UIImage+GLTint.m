//
//  UIImage+GLTint.m
//  zaozao
//
//  Created by OSU on 16/5/12.
//  Copyright © 2016年 miao. All rights reserved.
//

#import "UIImage+GLTint.h"

@implementation UIImage (GLTint)


- (UIImage *)coverTintColor:(UIColor *)tintColor
{
    //开始图片上下文绘制,保持透明度
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    [tintColor setFill];//设置填充色
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //用指定颜色绘图
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1];//保留透明度
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}


- (UIImage *)coverColorKeepGrey:(UIColor *)tintColor
{
    //开始图片上下文绘制,保持透明度
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    [tintColor setFill];//设置填充色
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //用指定颜色绘图
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1];//保留透明度
    [self drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1];//保留灰度
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}


@end
