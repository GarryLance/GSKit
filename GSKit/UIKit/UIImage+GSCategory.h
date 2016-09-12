//
//  UIImage+GSCategory.h
//  GSKitDemo
//
//  Created by OSU on 16/8/1.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GSCategory)

/**覆盖一层颜色*/
- (UIImage *)gs_coverTintColor:(UIColor *)tintColor;

/**覆盖一层颜色，保留灰度*/
- (UIImage *)gs_coverColorKeepGrey:(UIColor *)tintColor;

/**生成毛玻璃图片*/
- (UIImage *)gs_applyBlurRadius:(CGFloat)radius;

/**获取截图*/
- (UIImage *)gs_croppingInset:(UIEdgeInsets)inset;

/**获取缩略图*/
- (UIImage *)gs_thumSize:(CGSize)size;

/**UIView截图*/
+ (UIImage *)gs_imageWithView:(UIView*)view specifySize:(NSValue*)specifySize;

@end
