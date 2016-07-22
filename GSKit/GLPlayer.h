//
//  GLPlayer.h
//  zaozao
//
//  Created by OSU on 16/4/28.
//  Copyright © 2016年 miao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GLDefine.h"

#pragma mark - GLPlayer

#define GLPLAYER_KEY_TOTAL    @"GLPlayerKeyTotal"
#define GLPLAYER_KEY_CURRENT  @"GLPlayerKeyCurrent"

@protocol GLPlayerDelegate;



@interface GLPlayer : NSObject

/**当前AVPlayer，只读*/
@property(retain,nonatomic,readonly) AVPlayer * player;
/**当前AVPlayerItem数组，只读*/
@property(copy,nonatomic,readonly) NSArray <AVPlayerItem *> * playerItems;

/**当前视频url数组，可以设置*/
@property(copy,nonatomic) NSArray <NSURL *> * urls;

/**使用需要播放的视频url数组进行初始化，delegate处理业务*/
- (instancetype)initWithUrls:(NSArray *)urls delegate:(id <GLPlayerDelegate>)delegate;

/**在使用play方法前调用这个方法*/
- (BOOL)prepareItemIndex:(NSInteger)index;

- (void)play;

- (void)pause;

@end



@protocol GLPlayerDelegate <NSObject>

- (void)player:(GLPlayer *)player periodicTimeObserver:(NSDictionary *)info;
- (void)player:(GLPlayer *)player statusChange:(AVPlayerItemStatus)status;
- (void)player:(GLPlayer *)player loadedTimeRangeChange:(NSArray *)loadedTimeRange;

@optional

- (void)player:(GLPlayer *)player timeJump:(NSNotification *)notif;
- (void)player:(GLPlayer *)player didPlayToEndTime:(NSNotification *)notif;
- (void)player:(GLPlayer *)player failedToPlayToEndTime:(NSNotification *)notif;
- (void)player:(GLPlayer *)player playbackStalled:(NSNotification *)notif;
- (void)player:(GLPlayer *)player newErrorLogEntry:(NSNotification *)notif;

@end


#pragma mark - GLVideoPlayer

@protocol GLVideoPlayerViewDelegate;
@protocol GLVideoPlayerDelegate;

@interface GLVideoPlayerView : UIView
@end


@interface GLVideoPlayerTopBarView : UIView

/**播放视图*/
@property(assign,nonatomic) GLVideoPlayerView * playerView;
/**尺寸*/
@property(assign,nonatomic) CGSize size;

@end



@interface GLVideoPlayerControlBarView : UIView

/**播放视图*/
@property(assign,nonatomic) GLVideoPlayerView * playerView;
/**尺寸*/
@property(assign,nonatomic) CGSize size;
/**播放/暂停按钮*/
@property(retain,nonatomic) UIButton * playBtn;
/**进度条*/
@property(retain,nonatomic) UISlider * processSlider;
/**全屏按钮*/
@property(retain,nonatomic) UIButton * fullScreenBtn;
/**当前时间标签*/
@property(retain,nonatomic) UILabel  * labelCurrentTime;
/**剩余时间标签*/
@property(retain,nonatomic) UILabel  * labelRemain;
/**总时间标签*/
@property(retain,nonatomic) UILabel  * labelTotalTime;

/**是否正在拖动进度条*/
@property(assign,nonatomic) BOOL isDraggingSlider;

@end



@interface GLVideoPlayerProcessView : UIView

/**播放视图*/
@property(assign,nonatomic) GLVideoPlayerView * playerView;
/**尺寸位置*/
@property(assign,nonatomic) CGRect rect;
/**播放前缓冲进度*/
@property(assign,nonatomic) CGFloat startProcess;
/**进度标签*/
@property(retain,nonatomic) UILabel * labelProcess;
/**指示器*/
@property(retain,nonatomic) UIActivityIndicatorView * indicatorView;

@end



@interface GLVideoPlayerView ()

/**代理*/
@property(assign,nonatomic) id <GLVideoPlayerViewDelegate> delegate;
/**视频幕布上的播放/暂停按钮*/
@property(retain,nonatomic) UIButton * playBtnOnScreen;
@property(assign,nonatomic) CGRect playBtnOnScreenRect;
/**顶部栏*/
@property(retain,nonatomic) GLVideoPlayerTopBarView * topBarView;
/**底部控制栏*/
@property(retain,nonatomic) GLVideoPlayerControlBarView * controlBarView;
/**播放前缓冲的进度栏，需要自定义的时候可以整个替换掉*/
@property(retain,nonatomic) GLVideoPlayerProcessView * processView;

/**是否允许手势拖动进度，默认YES*/
@property(assign,nonatomic) BOOL allowGesturePlayBack;
/**是否允许手动拖动音量，默认YES*/
@property(assign,nonatomic) BOOL allowGestureVolume;
/**是否允许手动拖动亮度，默认YES*/
@property(assign,nonatomic) BOOL allowGestureBrightness;
/**是否允许旋转自动全屏*/
@property(assign,nonatomic) BOOL allowAutoFullScreen;

/**重设子视图frame*/
- (void)resetSubviewFrame;

@end



@protocol GLVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoPlayerView:(GLVideoPlayerView *)playerView showBar:(BOOL)show;
- (void)videoPlayerView:(GLVideoPlayerView *)playerView playBtnAction:(id)sender;
- (void)videoPlayerView:(GLVideoPlayerView *)playerView playback:(NSInteger)seconds;
- (void)videoPlayerView:(GLVideoPlayerView *)playerView fullScreen:(id)sender;
- (void)videoPlayerView:(GLVideoPlayerView *)playerView seeking:(CGFloat)value;//0.0~0.1
- (void)videoPlayerView:(GLVideoPlayerView *)playerView seekToValue:(CGFloat)value;

@end



@interface GLVideoPlayer : NSObject <GLPlayerDelegate,GLVideoPlayerViewDelegate>

@property(assign,nonatomic) id <GLVideoPlayerDelegate> delegate;
@property(retain,nonatomic) GLPlayer * player;
@property(retain,nonatomic) GLVideoPlayerView * playerView;

/**是否为全屏状态，只读*/
@property(assign,nonatomic,readonly) BOOL isFullScreen;

/**
 获取实例
 @param urls     视频url数组
 @param frame    对应playerView的frame
 @param delegate 遵从GLVideoPlayerDelegate协议的代理
 @returns GLVideoPlayer实例
 */
+ (instancetype)videoPlayerWithUrls:(NSArray *)urls frame:(CGRect)frame delegate:(id <GLVideoPlayerDelegate>)delegate;

/**
 播放器样式设置好以后，调用这个方法，返回YES则为成功，可以开始播放了
 @param   index 播放的url索引
 @returns BOOL  指示是否能够完成准备工作
 */
- (BOOL)getReadyForIndex:(NSInteger)index;

- (void)play;

- (void)pause;

@end



@protocol GLVideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayer:(GLVideoPlayer *)videoPlayer customPlayerView:(GLVideoPlayerView *)playerView;
- (void)videoPlayer:(GLVideoPlayer *)videoPlayer sizeChange:(CGSize)size playerView:(GLVideoPlayerView *)playerView;

@end




