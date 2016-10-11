//
//  GSPlayer.m
//  zaozao
//
//  Created by OSU on 16/4/28.
//  Copyright © 2016年 miao. All rights reserved.
//

#import "GSPlayer.h"
#import "GSTimer.h"
#import <MediaPlayer/MediaPlayer.h>

#define GSPLAYER_VIEW_PLAYER_LAYER_NAME @"GSPlayerViewPlayerLayer"

#pragma mark - GSPlayer


@interface GSPlayer ()

@property(weak,nonatomic) id <GSPlayerDelegate> delegate;

@property(strong, nonatomic) id periodicTimeObserver;

@end



@implementation GSPlayer

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserverForPlayerItem:[_player currentItem]];
    [_player removeTimeObserver:_periodicTimeObserver];
}


- (void)setPlayer:(AVPlayer *)player
{
    if (_player != player)
    {
        _player = player;
    }
}


- (instancetype)initWithUrls:(NSArray *)urls delegate:(id<GSPlayerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.urls = urls;
        self.delegate = delegate;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeJump:) name:AVPlayerItemTimeJumpedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newErrorLogEntry:) name:AVPlayerItemNewErrorLogEntryNotification object:nil];
    }
    return self;
}


- (void)setUrls:(NSArray *)urls
{
    if (_urls != urls)
    {
        _urls = urls;
    }
}


- (void)setPlayerItems:(NSArray<AVPlayerItem *> *)playerItems
{
    if (_playerItems != playerItems)
    {
        _playerItems = playerItems;
    }
}


#pragma mark  external

/**
 准备指定索引的playerItem，这个方法有明显的效率问题
 @param index 指定的playerItem索引
 @return 是否准备成功
 */
- (BOOL)prepareItemIndex:(NSInteger)index
{
    //获取playerItem
    AVPlayerItem * playerItem = nil;
    if (index < 0 || self.playerItems.count <= index)
    {
        GSDDLog(@"获取playerItem越界，赋予空playerItem")
        playerItem = [AVPlayerItem new];
    }
    else
    {
        playerItem = [self.playerItems objectAtIndex:index];
    }
    AVPlayerItem * prePlayerItem = [self.player currentItem];
    
    
    //装载playerItem
    if (!self.player)
    {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        [self addPeriodicTimeObserver];
    }
    else
    {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }
    
    //设置观察者
    [self removeObserverForPlayerItem:prePlayerItem];
    [self addObserverForPlayerItem:playerItem];
    
    return YES;
}


- (void)play
{
    [self.player play];
}


- (void)pause
{
    [self.player pause];
}


#pragma mark notif action

- (void)timeJump:(NSNotification *)notif
{
    NSError * error = [notif.userInfo objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey];
    if (error)
    {
        GSDDLog(@"%@",error.localizedDescription)
    }
    GSDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:timeJump:)])
    {
        [self.delegate player:self timeJump:notif];
    }
}


- (void)didPlayToEndTime:(NSNotification *)notif
{
    GSDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:didPlayToEndTime:)])
    {
        [self.delegate player:self didPlayToEndTime:notif];
    }
}


- (void)failedToPlayToEndTime:(NSNotification *)notif
{
    GSDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:failedToPlayToEndTime:)])
    {
        [self.delegate player:self failedToPlayToEndTime:notif];
    }
}


- (void)playbackStalled:(NSNotification *)notif
{
    GSDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:playbackStalled:)])
    {
        [self.delegate player:self playbackStalled:notif];
    }
}


- (void)newErrorLogEntry:(NSNotification *)notif
{
    GSDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:newErrorLogEntry:)])
    {
        [self.delegate player:self newErrorLogEntry:notif];
    }
}


#pragma mark observer


- (void)addPeriodicTimeObserver;
{
    //定时观察
    WEAKSELF
    self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        NSMutableDictionary * dictv = [NSMutableDictionary dictionary];
        
        CGFloat total    = CMTimeGetSeconds([_self.player currentItem].duration);
        CGFloat current  = CMTimeGetSeconds(time);
        
        [dictv setObject:[NSNumber numberWithFloat:total] forKey:GSPLAYER_KEY_TOTAL];
        [dictv setObject:[NSNumber numberWithFloat:current] forKey:GSPLAYER_KEY_CURRENT];
        
        if (_self.delegate && [_self.delegate respondsToSelector:@selector(player:periodicTimeObserver:)])
        {
            [_self.delegate player:_self periodicTimeObserver:dictv];
        }
    }];
}


- (void)addObserverForPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)removeObserverForPlayerItem:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        if ([self.delegate respondsToSelector:@selector(player:statusChange:)])
        {
            [self.delegate player:self statusChange:[[change objectForKey:NSKeyValueChangeNewKey] integerValue]];
        }
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        if ([self.delegate respondsToSelector:@selector(player:loadedTimeRangeChange:)])
        {
            [self.delegate player:self loadedTimeRangeChange:[change objectForKey:NSKeyValueChangeNewKey]];
        }
    }
}


#pragma mark other


- (NSArray <AVPlayerItem *> *)playerItemsWithUrls:(NSArray *)urls
{
    NSMutableArray * arrv = [NSMutableArray array];
    for (NSURL * url in urls)
    {
        AVPlayerItem * item = [AVPlayerItem playerItemWithURL:url];
        [arrv addObject:item];
    }
    return [arrv copy];
}

@end



#pragma mark - GSVideoPlayer



#pragma mark GSVideoPlayerTopBarView

@implementation GSVideoPlayerTopBarView


- (void)dealloc
{
    self.playerView = nil;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}


@end



#pragma mark GSVideoPlayerControlBarView

@implementation GSVideoPlayerControlBarView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.processSlider = [[UISlider alloc] init];
        self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.labelCurrentTime = [[UILabel alloc] init];
        self.labelRemain = [[UILabel alloc] init];
        self.labelTotalTime = [[UILabel alloc] init];
        
        [self addSubview:_playBtn];
        [self addSubview:_processSlider];
        [self addSubview:_fullScreenBtn];
        [self addSubview:_labelCurrentTime];
        [self addSubview:_labelRemain];
        [self addSubview:_labelTotalTime];
        
        [self.playBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.processSlider addTarget:self action:@selector(draggingSlider:) forControlEvents:UIControlEventValueChanged];
        [self.processSlider addTarget:self action:@selector(touchUpSlider:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        
        _labelCurrentTime.textColor = [UIColor whiteColor];
        _labelTotalTime.textColor = [UIColor whiteColor];
        _labelRemain.textColor = [UIColor whiteColor];
        
//        _playBtn.backgroundColor = [UIColor greenColor];
//        _labelCurrentTime.backgroundColor = [UIColor orangeColor];
//        _fullScreenBtn.backgroundColor = [UIColor purpleColor];
        
//        self.frame = frame;
    }
    return self;
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _playBtn.frame = CGRectMake(0, 0, 50, frame.size.height);
    _labelCurrentTime.frame = CGRectMake(frame.size.width-100, 0, 50, frame.size.height);
    _fullScreenBtn.frame    = CGRectMake(frame.size.width-50, 0, 50, frame.size.height);
    _processSlider.frame    = CGRectMake(50, 0, frame.size.width-150, frame.size.height);
}


- (void)playOrPause:(id)sender
{
    if ([self.playerView.delegate respondsToSelector:@selector(videoPlayerView:playBtnAction:)])
    {
        [self.playerView.delegate videoPlayerView:self.playerView playBtnAction:sender];
    }
}


- (void)draggingSlider:(UISlider *)slider
{
    self.isDraggingSlider = YES;
    if ([self.playerView.delegate respondsToSelector:@selector(videoPlayerView:seeking:)])
    {
        [self.playerView.delegate videoPlayerView:self.playerView seeking:slider.value];
    }
}


- (void)touchUpSlider:(UISlider *)slider
{
    if ([self.playerView.delegate respondsToSelector:@selector(videoPlayerView:seekToValue:)])
    {
        [self.playerView.delegate videoPlayerView:self.playerView seekToValue:slider.value];
    }
}


- (void)fullScreenAction:(id)sender
{
    if ([self.playerView.delegate respondsToSelector:@selector(videoPlayerView:fullScreen:)])
    {
        [self.playerView.delegate videoPlayerView:self.playerView fullScreen:nil];
    }
}

@end



#pragma mark GSVideoPlayerProcessView

@implementation GSVideoPlayerProcessView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.rect = frame;
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, frame.size.height)];
        self.labelProcess = [[UILabel alloc]  initWithFrame:CGRectMake(15, 0, frame.size.width-15, frame.size.height)];
        
        UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerTopRight )
                                                              cornerRadii:CGSizeMake(5.0f, 5.0f)];
        CAShapeLayer * shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.frame = self.bounds;
        shapeLayer.path  = maskPath.CGPath;
        shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        [self.layer addSublayer:shapeLayer];
        
        _indicatorView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        _labelProcess.textColor = [UIColor whiteColor];
        _labelProcess.textAlignment = NSTextAlignmentCenter;
        _labelProcess.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:_indicatorView];
        [self addSubview:_labelProcess];
    }
    return self;
}


- (void)setStartProcess:(CGFloat)startProcess
{
    _startProcess = startProcess;
    
    _labelProcess.text = [NSString stringWithFormat:@"%d%%   ",(int)(startProcess*100)];
}


- (void)start
{
    [_indicatorView startAnimating];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = self.rect;
        self.alpha = 1;
    } completion:nil];
}

- (void)stop
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect rect = self.rect;
        self.frame = CGRectMake(-rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
        self.alpha = 0;
    } completion:nil];
}


@end



#pragma mark GSVideoPlayerView

typedef NS_ENUM(NSInteger,GSPanGestureDirection)
{
    GSPanGestureDirectionNone,
    GSPanGestureDirectionUp = 1 << 1,
    GSPanGestureDirectionDown = 1 << 2,
    GSPanGestureDirectionLeft = 1 << 3,
    GSPanGestureDirectionRight = 1 << 4,
    GSPanGestureDirectionHorizontal = (GSPanGestureDirectionLeft | GSPanGestureDirectionRight),
    GSPanGestureDirectionVertical = (GSPanGestureDirectionUp | GSPanGestureDirectionDown)
};


@interface GSVideoPlayerView ()

@property(assign,nonatomic) BOOL isShowingBar;
@property(weak,nonatomic) UIView * preSuperView;
@property(assign,nonatomic) CGRect rect;
@property(assign,nonatomic) GSPanGestureDirection panDirection;

@end


@implementation GSVideoPlayerView


- (instancetype)initWithFrame:(CGRect)frame player:(GSPlayer *)player
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.playBtnOnScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playBtnOnScreenRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.playBtnOnScreen.frame = self.playBtnOnScreenRect;
        self.playBtnOnScreen.hidden = YES;
        
        self.topBarView = [[GSVideoPlayerTopBarView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height*0.2)];
        self.controlBarView = [[GSVideoPlayerControlBarView alloc] initWithFrame:CGRectMake(0, frame.size.height-frame.size.height*0.276, frame.size.width, frame.size.height*0.276)];
        self.processView = [[GSVideoPlayerProcessView alloc] initWithFrame:CGRectMake(0, frame.size.height/2-12.5, 50, 25)];
        
        self.topBarView.playerView = self;
        self.controlBarView.playerView = self;
        
        self.topBarView.size = self.topBarView.frame.size;
        self.controlBarView.size = self.controlBarView.frame.size;
        self.processView.rect = self.processView.frame;
        
        self.topBarView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.controlBarView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        [self addSubview:_playBtnOnScreen];
        [self addSubview:_controlBarView];
        [self addSubview:_topBarView];
        [self addSubview:_processView];
        
        self.isShowingBar = YES;
        self.allowGestureVolume = YES;
        self.allowGesturePlayBack = YES;
        self.allowGestureBrightness = YES;
        self.allowAutoFullScreen = YES;
        
        [self.playBtnOnScreen addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTap:)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}


- (void)playOrPause:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:playBtnAction:)])
    {
        [self.delegate videoPlayerView:self playBtnAction:sender];
    }
}


- (void)showOrHideBar
{
    if (self.isShowingBar)
    {
        self.isShowingBar = NO;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.controlBarView.alpha = 0;
            self.topBarView.alpha = 0;
        } completion:nil];
    }
    else
    {
        self.isShowingBar = YES;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.controlBarView.alpha = 1;
            self.topBarView.alpha = 1;
        } completion:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerView:showBar:)])
    {
        [self.delegate videoPlayerView:self showBar:self.isShowingBar];
    }
}


- (void)gestureTap:(UITapGestureRecognizer *)tap
{
    [self showOrHideBar];
}


- (void)gesturePan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        self.panDirection = GSPanGestureDirectionNone;
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        CGFloat tolerate = 15;
        CGPoint translation = [pan translationInView:self];
        CGPoint velocity = [pan velocityInView:self];
        switch (self.panDirection)
        {
            case GSPanGestureDirectionNone:
            {
                if (fabs(translation.x) > tolerate)
                {
                    self.panDirection = GSPanGestureDirectionHorizontal;
                }
                else if (fabs(translation.y) > tolerate)
                {
                    self.panDirection = GSPanGestureDirectionVertical;
                }
            }
                
            case GSPanGestureDirectionHorizontal:
            {
                if (self.allowGesturePlayBack && [self.delegate respondsToSelector:@selector(videoPlayerView:playback:)])
                {
                    [self.delegate videoPlayerView:self playback:0];
                }
            }break;
                
            case GSPanGestureDirectionVertical:
            {
                CGPoint point = [pan locationInView:self];
                if (point.x > self.frame.size.width/2 && self.allowGestureVolume)
                {
                    //声音
                    [UIScreen mainScreen].brightness += velocity.y * (- 0.0001);
                }
                else if(self.allowGestureBrightness)
                {
                    //亮度
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wdeprecated"
                    [MPMusicPlayerController applicationMusicPlayer].volume += velocity.y * (- 0.0001);
                    #pragma clang diagnostic pop
                }
            }break;
                
            default:
                break;
        }

        GSDLog(@"%@",[NSValue valueWithCGPoint:[pan translationInView:self]]);
    }
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self resetSubviewFrame];
}


- (void)resetSubviewFrame
{
    CGSize playerSize = self.bounds.size;
    
    for (CALayer * layer in self.layer.sublayers)
    {
        if ([layer.name isEqualToString:GSPLAYER_VIEW_PLAYER_LAYER_NAME])
        {
            layer.frame = self.bounds;
        }
    }
    
    //顶部、控制视图
    _playBtnOnScreen.frame = self.playBtnOnScreenRect;
    _topBarView.frame     = CGRectMake(0, 0, playerSize.width, _topBarView.size.height);
    _controlBarView.frame = CGRectMake(0, playerSize.height - _controlBarView.size.height, playerSize.width, _controlBarView.size.height);
    _processView.frame = _processView.rect;
}


/**
 重设 AVPlayerLayer
 @param player 对应的GSPlayer
 */
- (void)resetPlayerLayer:(GSPlayer *)player
{
    CGRect layerFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width*(9/16.0));
    
    for (CALayer * sublayer in self.layer.sublayers)
    {
        if ([sublayer.name isEqualToString:GSPLAYER_VIEW_PLAYER_LAYER_NAME])
        {
            layerFrame = sublayer.frame;
            [sublayer removeFromSuperlayer];
            break;
        }
    }
    
    AVPlayerLayer * layer  = [AVPlayerLayer playerLayerWithPlayer:player.player];
    layer.name  = GSPLAYER_VIEW_PLAYER_LAYER_NAME;
    layer.frame = layerFrame;
    layer.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer insertSublayer:layer atIndex:0];
}

@end



#pragma mark GSVideoPlayerFullScreenWindow

@interface GSVideoPlayerFullScreenWindow : UIWindow

@end



@implementation GSVideoPlayerFullScreenWindow

- (void)resignKeyWindow
{
    
}

@end



#pragma mark GSVideoPlayerFullScreenViewController

@interface GSVideoPlayerFullScreenViewController : UIViewController


@end



@implementation GSVideoPlayerFullScreenViewController


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (BOOL)shouldAutorotate
{
    return YES;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.view.subviews firstObject].frame = CGRectMake(0, 0, size.width, size.height);
}

@end



#pragma mark GSVideoPlayer

#define REMAIN_COUNT_FOR_HIDE 20

@interface GSVideoPlayer ()

@property(weak,nonatomic) UIWindow * appKeyWindow;
@property(strong,nonatomic) GSVideoPlayerFullScreenWindow * fullScreenWindow;

@property(assign,nonatomic) BOOL manualPause;

@property(assign,nonatomic) NSInteger remainCountForHide;

@end



@implementation GSVideoPlayer 


+ (instancetype)videoPlayerWithUrls:(NSArray *)urls frame:(CGRect)frame delegate:(id <GSVideoPlayerDelegate>)delegate
{
    GSVideoPlayer * videoPlayer = [[GSVideoPlayer alloc] init];
    GSPlayer * player = [[GSPlayer alloc] initWithUrls:urls delegate:videoPlayer];
    GSVideoPlayerView * playerView = [[GSVideoPlayerView alloc] initWithFrame:frame player:player];
    
    videoPlayer.delegate = delegate;
    playerView.delegate = videoPlayer;
    
    videoPlayer.player = player;
    videoPlayer.playerView = playerView;
    
    if ([videoPlayer.delegate respondsToSelector:@selector(videoPlayer:customPlayerView:)])
    {
        [videoPlayer.delegate videoPlayer:videoPlayer customPlayerView:videoPlayer.playerView];
        [videoPlayer.playerView resetSubviewFrame];
    }
    
    [playerView addObserver:videoPlayer forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:videoPlayer selector:@selector(deviceRotatedNotif:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return videoPlayer;
}


- (void)dealloc
{
    [_playerView removeObserver:self forKeyPath:@"frame"];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.manualPause  = NO;
        self.isFullScreen = NO;
        self.remainCountForHide = REMAIN_COUNT_FOR_HIDE;
    }
    return self;
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
}

- (BOOL)getReadyForIndex:(NSInteger)index
{
    if (self.playerView)
    {
        if (![self.playerView superview])
        {
            GSDLog(@"播放视图未被添加");
            return NO;
        }
        
        if (![self.player prepareItemIndex:index])
        {
            return NO;
        }
        
        [self.playerView resetPlayerLayer:self.player];
    }
    
    return YES;
}


- (void)play
{
    self.manualPause = NO;
    [self.player play];
}


- (void)pause
{
    self.manualPause = YES;
    [self.player pause];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
    {
        CGRect rect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        if ([self.delegate respondsToSelector:@selector(videoPlayer:sizeChange:playerView:)])
        {
            [self.delegate videoPlayer:self sizeChange:rect.size playerView:self.playerView];
        }
    }
}


- (void)deviceRotatedNotif:(NSNotification *)notif
{
    if (self.playerView.allowAutoFullScreen)
    {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
        {
            if (!self.isFullScreen)
            {
                [self videoPlayerView:self.playerView fullScreen:nil];
            }
        }
        else if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            if (self.isFullScreen)
            {
                [self videoPlayerView:self.playerView fullScreen:nil];
            }
        }
    }
}


#pragma mark GSPlayerDelegate

- (void)player:(GSPlayer *)player periodicTimeObserver:(NSDictionary *)info
{
//    GSDLog(@"%@",info);
    if (_remainCountForHide)
    {
        _remainCountForHide--;
        if (!_remainCountForHide && self.playerView.isShowingBar)
        {
            [self.playerView showOrHideBar];
        }
    }
    
    CGFloat current = [[info objectForKey:GSPLAYER_KEY_CURRENT] floatValue];
    CGFloat total = [[info objectForKey:GSPLAYER_KEY_TOTAL] floatValue];
    
    if (!self.playerView.controlBarView.isDraggingSlider)
    {
        self.playerView.controlBarView.processSlider.value = current/total;
        
        self.playerView.controlBarView.labelRemain.text = [GSTimer stringForTimeFormat:@"mm:ss" interval:total - current];
        self.playerView.controlBarView.labelTotalTime.text = [GSTimer stringForTimeFormat:@"mm:ss" interval:total];
        self.playerView.controlBarView.labelCurrentTime.text = [GSTimer stringForTimeFormat:@"mm:ss" interval:current];
    }

    if (player.player.rate)
    {
        self.playerView.playBtnOnScreen.selected = YES;
        self.playerView.controlBarView.playBtn.selected = YES;
    }
    else if (self.manualPause)
    {
        self.playerView.playBtnOnScreen.selected = NO;
        self.playerView.controlBarView.playBtn.selected = NO;
    }
}


- (void)player:(GSPlayer *)player statusChange:(AVPlayerItemStatus)status
{
    GSDLog(@"statusChange:%ld",(long)status);
}


- (void)player:(GSPlayer *)player loadedTimeRangeChange:(NSArray *)loadedTimeRange
{
    for (NSValue * value in loadedTimeRange)
    {
        CMTimeRange timeRange = [value CMTimeRangeValue];
        CGFloat start = CMTimeGetSeconds(timeRange.start);
        CGFloat duration = CMTimeGetSeconds(timeRange.duration);
        CGFloat total = CMTimeGetSeconds(player.player.currentItem.duration);
        CGFloat cache = (total - start) > 10 ? 10.0 : (total - start);
        CGFloat process = duration/cache;
        process = process >= 1 ? 1 : process;
        
        if (process < 1)
        {
            [self.playerView.processView start];
            [self.player pause];
        }
        else
        {
            [self.playerView.processView stop];
            if (!self.manualPause)
            {
                [self.player play];
            }
        }
        self.playerView.processView.startProcess = process;
        
//        GSDLog(@"loadedTimeRange--start:%f",start);
//        GSDLog(@"loadedTimeRange--duration:%f",duration);
//        GSDLog(@"loadedTimeRange:%@",value);
    }
}


#pragma mark GSVideoPlayerViewDelegate

- (void)videoPlayerView:(GSVideoPlayerView *)playerView showBar:(BOOL)show
{
    if (show)
    {
        self.remainCountForHide = REMAIN_COUNT_FOR_HIDE;
    }
}


- (void)videoPlayerView:(GSVideoPlayerView *)playerView playBtnAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (self.player.player.rate)
    {
        btn.selected = NO;
        self.manualPause = YES;
        [self.player pause];
    }
    else
    {
        btn.selected = YES;
        self.manualPause = NO;
        [self.player play];
    }
}


- (void)videoPlayerView:(GSVideoPlayerView *)playerView playback:(NSInteger)seconds
{
    
}


- (void)videoPlayerView:(GSVideoPlayerView *)playerView fullScreen:(id)sender
{
    if (!self.isFullScreen)
    {
        self.isFullScreen = YES;
        self.playerView.controlBarView.fullScreenBtn.selected = YES;
        
        self.playerView.rect = self.playerView.frame;
        self.playerView.preSuperView = self.playerView.superview;

        self.appKeyWindow = [UIApplication sharedApplication].keyWindow;
        
        self.fullScreenWindow = [[GSVideoPlayerFullScreenWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _fullScreenWindow.alpha = 0;
        GSVideoPlayerFullScreenViewController * vc = [[GSVideoPlayerFullScreenViewController alloc] init];
        _fullScreenWindow.rootViewController = vc;
        [vc.view addSubview:self.playerView];
        
        [_fullScreenWindow makeKeyAndVisible];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [UIApplication sharedApplication].statusBarHidden = YES;
            
            self.playerView.frame = CGRectMake(0, 0, GSSCREEN_WIDTH, GSSCREEN_HEIGHT);
            self.fullScreenWindow.alpha = 1;
        } completion:nil];
    }
    else
    {
        self.isFullScreen = NO;
        self.playerView.controlBarView.fullScreenBtn.selected = NO;
        
        [UIView animateWithDuration:0.25 animations:^{
                        
            self.playerView.frame = self.playerView.rect;
            [self.playerView.preSuperView addSubview:self.playerView];

            self.fullScreenWindow.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            //解决状态栏问题
            UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window.rootViewController = [[[self.appKeyWindow.rootViewController class] alloc] init];
            [window makeKeyWindow];
            
            self.fullScreenWindow = nil;
            
            [self.appKeyWindow makeKeyAndVisible];
            
            [UIApplication sharedApplication].statusBarHidden = NO;
        }];
    }
}


- (void)videoPlayerView:(GSVideoPlayerView *)playerView seeking:(CGFloat)value
{
    CGFloat total = CMTimeGetSeconds(self.player.player.currentItem.duration);
    self.playerView.controlBarView.labelRemain.text = [GSTimer stringForTimeFormat:@"mm:ss" interval:total - total * value];
    self.playerView.controlBarView.labelCurrentTime.text = [GSTimer stringForTimeFormat:@"mm:ss" interval:total * value];
}


- (void)videoPlayerView:(GSVideoPlayerView *)playerView seekToValue:(CGFloat)value
{
    _remainCountForHide = REMAIN_COUNT_FOR_HIDE;
    
    self.playerView.processView.startProcess = 0;
    [self.playerView.processView start];

    [self.player pause];
    
    CMTime duration = self.player.player.currentItem.duration;
    if (!duration.value)
    {
        GSDDLog(@"视频时间为零，可能尚未成功加载视频，无法跳转进度条。");
        return;
    }

    WEAKSELF
    [self.player.player.currentItem seekToTime:CMTimeMake(duration.value * value, duration.timescale) completionHandler:^(BOOL finished) {
        
        if (finished)
        {
            if (!_self.manualPause)
            {
                [_self.player play];
            }
            _self.playerView.controlBarView.isDraggingSlider = NO;
            GSDLog(@"seek done");
        }
        else
        {
            GSDLog(@"seeking timeout");
        }
    }];
}

@end
