//
//  UIImage+GSCategory.m
//  GSKitDemo
//
//  Created by OSU on 16/8/1.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "UIImage+GSCategory.h"

@implementation UIImage (GSCategory)


/**覆盖一层颜色*/
- (UIImage *)gs_coverTintColor:(UIColor *)tintColor
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


/**覆盖一层颜色，保留灰度*/
- (UIImage *)gs_coverColorKeepGrey:(UIColor *)tintColor
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


/**UIView截图*/
+ (UIImage *)gs_imageWithView:(UIView*)view specifySize:(NSValue*)specifySize
{
    //支持retina高分的关键
    CGSize size = specifySize ? [specifySize CGSizeValue] : view.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


/**生成毛玻璃图片*/
+(UIImage *)gs_applyBlurRadius:(CGFloat)radius toImage:(UIImage *)image
{
    if (radius < 0) radius = 0;
    
    CIContext *context =  [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    // Setting up gaussian blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return returnImage;
}


/**获取缩略图*/
+ (UIImage *)gs_getThumImage:(UIImage *)image size:(CGSize)size
{
    if (image)
    {
        //@2x与@3x的判断，根据屏幕获取是否为i6p
        NSInteger rate = 2;
        if ([UIScreen mainScreen].bounds.size.height > 667)
        {
            rate = 3;
        }
        
        //类似 ScaleAspectFill 配置
        CGSize sizeImg = image.size;
        if (image.size.height<image.size.width)
        {
            double coe = sizeImg.width/sizeImg.height;
            sizeImg.height = size.height;
            sizeImg.width  = sizeImg.height * coe;
        }
        else
        {
            double coe = sizeImg.width/sizeImg.height;
            sizeImg.width   = size.width;
            sizeImg.height  = sizeImg.width / coe;
        }
        UIGraphicsBeginImageContextWithOptions(sizeImg, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, sizeImg.width, sizeImg.height)];
        UIImage *imageTag = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return imageTag;
    }
    return nil;
}


@end
