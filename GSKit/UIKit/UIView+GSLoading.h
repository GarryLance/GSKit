//
//  UIView+Loading.h
//  Together
//
//  Created by OSU on 16/3/29.
//  Copyright © 2016年 Garry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDICATOR_TAG       13213

@interface UIView (GSLoading)

/**指示视图*/
@property(strong,nonatomic,readonly) UIView * viewIndicator;

/**开始loading动画*/
- (void)startLoading;
/**开始loading动画，不需要夹层*/
- (void)startLoadingWithoutSandwich;

/**
 显示加载进度，注意调用之前需要先调用startLoading
 @param percentDone 完成的百分比分子数
 */
- (void)loadingProcess:(NSInteger)percentDone;
/**
 显示加载进度，注意调用之前需要先调用startLoading，当percentDone为100时自动隐藏
 @param percentDone 完成的百分比分子数
 @param userInteractionEnabled 结束并隐藏后是否启用本视图的userInteractionEnabled属性
 */
- (void)loadingProcess:(NSInteger)percentDone autoHideUserInteractionEnabled:(BOOL)userInteractionEnabled;


/**停止loading动画*/
- (void)stopLoading;

/**停止loading动画，禁止用户交互*/
- (void)stopLoadingNoUserInteractionEnabled;
@end
