//
//  GSPlayer.h
//  zaozao
//
//  Created by OSU on 16/4/28.
//  Copyright © 2016年 miao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GSDefine.h"

#pragma mark - GSPlayer

#define GSPLAYER_KEY_TOTAL    @"GSPlayerKeyTotal"
#define GSPLAYER_KEY_CURRENT  @"GSPlayerKeyCurrent"

@protocol GSPlayerDelegate;



@interface GSPlayer : NSObject

/**当前AVPlayer，只读*/
@property(strong,nonatomic,readonly) AVPlayer * player;
/**当前AVPlayerItem数组，只读*/
@property(copy,nonatomic,readonly) NSArray <AVPlayerItem *> * playerItems;

/**当前视频url数组，可以设置*/
@property(copy,nonatomic) NSArray <NSURL *> * urls;

/**使用需要播放的视频url数组进行初始化，delegate处理业务*/
- (instancetype)initWithUrls:(NSArray *)urls delegate:(id <GSPlayerDelegate>)delegate;

/**在使用play方法前调用这个方法*/
- (BOOL)prepareItemIndex:(NSInteger)index;

/**播放*/
- (void)play;

/**暂停*/
- (void)pause;

@end



@protocol GSPlayerDelegate <NSObject>

- (void)player:(GSPlayer *)player periodicTimeObserver:(NSDictionary *)info;
- (void)player:(GSPlayer *)player statusChange:(AVPlayerItemStatus)status;
- (void)player:(GSPlayer *)player loadedTimeRangeChange:(NSArray *)loadedTimeRange;

@optional

- (void)player:(GSPlayer *)player timeJump:(NSNotification *)notif;
- (void)player:(GSPlayer *)player didPlayToEndTime:(NSNotification *)notif;
- (void)player:(GSPlayer *)player failedToPlayToEndTime:(NSNotification *)notif;
- (void)player:(GSPlayer *)player playbackStalled:(NSNotification *)notif;
- (void)player:(GSPlayer *)player newErrorLogEntry:(NSNotification *)notif;

@end


#pragma mark - GSVideoPlayer

@protocol GSVideoPlayerViewDelegate;
@protocol GSVideoPlayerDelegate;

@interface GSVideoPlayerView : UIView
@end


@interface GSVideoPlayerTopBarView : UIView

/**播放视图*/
@property(weak,nonatomic) GSVideoPlayerView * playerView;
/**尺寸*/
@property(assign,nonatomic) CGSize size;

@end



@interface GSVideoPlayerControlBarView : UIView

/**播放视图*/
@property(weak,nonatomic) GSVideoPlayerView * playerView;
/**尺寸*/
@property(assign,nonatomic) CGSize size;
/**播放/暂停按钮*/
@property(strong,nonatomic) UIButton * playBtn;
/**进度条*/
@property(strong,nonatomic) UISlider * processSlider;
/**全屏按钮*/
@property(strong,nonatomic) UIButton * fullScreenBtn;
/**当前时间标签*/
@property(strong,nonatomic) UILabel  * labelCurrentTime;
/**剩余时间标签*/
@property(strong,nonatomic) UILabel  * labelRemain;
/**总时间标签*/
@property(strong,nonatomic) UILabel  * labelTotalTime;

/**是否正在拖动进度条*/
@property(assign,nonatomic) BOOL isDraggingSlider;

@end



@interface GSVideoPlayerProcessView : UIView

/**播放视图*/
@property(weak,nonatomic) GSVideoPlayerView * playerView;
/**尺寸位置*/
@property(assign,nonatomic) CGRect rect;
/**播放前缓冲进度*/
@property(assign,nonatomic) CGFloat startProcess;
/**进度标签*/
@property(strong,nonatomic) UILabel * labelProcess;
/**指示器*/
@property(strong,nonatomic) UIActivityIndicatorView * indicatorView;

@end



@interface GSVideoPlayerView ()

/**代理*/
@property(weak,nonatomic) id <GSVideoPlayerViewDelegate> delegate;
/**视频幕布上的播放/暂停按钮*/
@property(strong,nonatomic) UIButton * playBtnOnScreen;
@property(assign,nonatomic) CGRect playBtnOnScreenRect;
/**顶部栏*/
@property(strong,nonatomic) GSVideoPlayerTopBarView * topBarView;
/**底部控制栏*/
@property(strong,nonatomic) GSVideoPlayerControlBarView * controlBarView;
/**播放前缓冲的进度栏，需要自定义的时候可以整个替换掉*/
@property(strong,nonatomic) GSVideoPlayerProcessView * processView;

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



@protocol GSVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoPlayerView:(GSVideoPlayerView *)playerView showBar:(BOOL)show;
- (void)videoPlayerView:(GSVideoPlayerView *)playerView playBtnAction:(id)sender;
- (void)videoPlayerView:(GSVideoPlayerView *)playerView playback:(NSInteger)seconds;
- (void)videoPlayerView:(GSVideoPlayerView *)playerView fullScreen:(id)sender;
- (void)videoPlayerView:(GSVideoPlayerView *)playerView seeking:(CGFloat)value;//0.0~0.1
- (void)videoPlayerView:(GSVideoPlayerView *)playerView seekToValue:(CGFloat)value;

@end



@interface GSVideoPlayer : NSObject <GSPlayerDelegate,GSVideoPlayerViewDelegate>

@property(weak,nonatomic) id <GSVideoPlayerDelegate> delegate;
@property(strong,nonatomic) GSPlayer * player;
@property(strong,nonatomic) GSVideoPlayerView * playerView;

/**是否为全屏状态，只读*/
@property(assign,nonatomic,readonly) BOOL isFullScreen;

/**
 获取实例
 @param urls     视频url数组
 @param frame    对应playerView的frame
 @param delegate 遵从GSVideoPlayerDelegate协议的代理
 @returns GSVideoPlayer实例
 */
+ (instancetype)videoPlayerWithUrls:(NSArray *)urls frame:(CGRect)frame delegate:(id <GSVideoPlayerDelegate>)delegate;

/**
 播放器样式设置好以后，调用这个方法，返回YES则为成功，可以开始播放了
 @param   index 播放的url索引
 @returns BOOL  指示是否能够完成准备工作
 */
- (BOOL)getReadyForIndex:(NSInteger)index;

/**播放*/
- (void)play;

/**暂停*/
- (void)pause;

@end



@protocol GSVideoPlayerDelegate <NSObject>

@optional
/**在这个代理方法中自定义playerView*/
- (void)videoPlayer:(GSVideoPlayer *)videoPlayer customPlayerView:(GSVideoPlayerView *)playerView;
/**播放视图的size变化时调用*/
- (void)videoPlayer:(GSVideoPlayer *)videoPlayer sizeChange:(CGSize)size playerView:(GSVideoPlayerView *)playerView;

@end




