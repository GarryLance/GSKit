//
//  GLPlayer.m
//  zaozao
//
//  Created by OSU on 16/4/28.
//  Copyright © 2016年 miao. All rights reserved.
//

#import "GLPlayer.h"
#import "GLTimer.h"
#import <MediaPlayer/MediaPlayer.h>

#define GLPLAYER_VIEW_PLAYER_LAYER_NAME @"GLPlayerViewPlayerLayer"

#pragma mark - GLPlayer


@interface GLPlayer ()

@property(assign,nonatomic) id <GLPlayerDelegate> delegate;

@property(retain,nonatomic) id periodicTimeObserver;

@end



@implementation GLPlayer

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserverForPlayerItem:[_player currentItem]];
    [_player removeTimeObserver:_periodicTimeObserver];
    [_periodicTimeObserver release];
    [_player release];
    [_urls release];
    [_playerItems release];
    [super dealloc];
}


- (void)setPlayer:(AVPlayer *)player
{
    if (_player)
    {
        [_player release];
    }
    _player = [player retain];
}


- (instancetype)initWithUrls:(NSArray *)urls delegate:(id<GLPlayerDelegate>)delegate
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
    if (_urls)
    {
        [_urls release];
    }
    _urls = [urls copy];
    self.playerItems = [self playerItemsWithUrls:urls];
}

- (void)setPlayerItems:(NSArray<AVPlayerItem *> *)playerItems
{
    if (_playerItems)
    {
        [_playerItems release];
    }
    _playerItems = [playerItems copy];
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
        GLDDLog(@"获取playerItem越界，赋予空playerItem")
        playerItem = [[AVPlayerItem new] autorelease];
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
        GLDDLog(@"%@",error.localizedDescription)
    }
    GLDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:timeJump:)])
    {
        [self.delegate player:self timeJump:notif];
    }
}


- (void)didPlayToEndTime:(NSNotification *)notif
{
    GLDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:didPlayToEndTime:)])
    {
        [self.delegate player:self didPlayToEndTime:notif];
    }
}


- (void)failedToPlayToEndTime:(NSNotification *)notif
{
    GLDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:failedToPlayToEndTime:)])
    {
        [self.delegate player:self failedToPlayToEndTime:notif];
    }
}


- (void)playbackStalled:(NSNotification *)notif
{
    GLDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:playbackStalled:)])
    {
        [self.delegate player:self playbackStalled:notif];
    }
}


- (void)newErrorLogEntry:(NSNotification *)notif
{
    GLDDLog(@"%@",notif);
    
    if ([self.delegate respondsToSelector:@selector(player:newErrorLogEntry:)])
    {
        [self.delegate player:self newErrorLogEntry:notif];
    }
}


#pragma mark observer


- (void)addPeriodicTimeObserver;
{
    //定时观察
    BLOCKSELF
    self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        NSMutableDictionary * dictv = [NSMutableDictionary dictionary];
        
        CGFloat total    = CMTimeGetSeconds([blockSelf.player currentItem].duration);
        CGFloat current  = CMTimeGetSeconds(time);
        
        [dictv setObject:[NSNumber numberWithFloat:total] forKey:GLPLAYER_KEY_TOTAL];
        [dictv setObject:[NSNumber numberWithFloat:current] forKey:GLPLAYER_KEY_CURRENT];
        
        if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(player:periodicTimeObserver:)])
        {
            [blockSelf.delegate player:blockSelf periodicTimeObserver:dictv];
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
    return [[arrv copy] autorelease];
}

@end



#pragma mark - GLVideoPlayer



#pragma mark GLVideoPlayerTopBarView

@implementation GLVideoPlayerTopBarView


- (void)dealloc
{
    self.playerView = nil;
    [super dealloc];
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



#pragma mark GLVideoPlayerControlBarView

@implementation GLVideoPlayerControlBarView


- (void)dealloc
{
    self.playerView = nil;
    [_playBtn release];
    [_processSlider release];
    [_fullScreenBtn release];
    [_labelCurrentTime release];
    [_labelRemain release];
    [_labelTotalTime release];
    [super dealloc];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.processSlider = [[[UISlider alloc] init] autorelease];
        self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.labelCurrentTime = [[[UILabel alloc] init] autorelease];
        self.labelRemain = [[[UILabel alloc] init] autorelease];
        self.labelTotalTime = [[[UILabel alloc] init] autorelease];
        
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



#pragma mark GLVideoPlayerProcessView

@implementation GLVideoPlayerProcessView

- (void)dealloc
{
    [_labelProcess release];
    [_indicatorView release];
    [super dealloc];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.rect = frame;
        
        self.indicatorView = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, frame.size.height)] autorelease];
        self.labelProcess = [[[UILabel alloc]  initWithFrame:CGRectMake(15, 0, frame.size.width-15, frame.size.height)] autorelease];
        
        UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerTopRight )
                                                              cornerRadii:CGSizeMake(5.0f, 5.0f)];
        CAShapeLayer * shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.frame = self.bounds;
        shapeLayer.path  = maskPath.CGPath;
        shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        [self.layer addSublayer:shapeLayer];
        [shapeLayer release];
        
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



#pragma mark GLVideoPlayerView

typedef NS_ENUM(NSInteger,GLPanGestureDirection)
{
    GLPanGestureDirectionNone,
    GLPanGestureDirectionUp = 1 << 1,
    GLPanGestureDirectionDown = 1 << 2,
    GLPanGestureDirectionLeft = 1 << 3,
    GLPanGestureDirectionRight = 1 << 4,
    GLPanGestureDirectionHorizontal = (GLPanGestureDirectionLeft | GLPanGestureDirectionRight),
    GLPanGestureDirectionVertical = (GLPanGestureDirectionUp | GLPanGestureDirectionDown)
};


@interface GLVideoPlayerView ()

@property(assign,nonatomic) BOOL isShowingBar;
@property(assign,nonatomic) UIView * preSuperView;
@property(assign,nonatomic) CGRect rect;
@property(assign,nonatomic) GLPanGestureDirection panDirection;

@end


@implementation GLVideoPlayerView


- (void)dealloc
{
    self.delegate = nil;
    [_playBtnOnScreen release];
    [_topBarView release];
    [_controlBarView release];
    [_processView release];
    [super dealloc];
}


- (instancetype)initWithFrame:(CGRect)frame player:(GLPlayer *)player
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.playBtnOnScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playBtnOnScreenRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.playBtnOnScreen.frame = self.playBtnOnScreenRect;
        self.playBtnOnScreen.hidden = YES;
        
        self.topBarView = [[[GLVideoPlayerTopBarView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height*0.2)] autorelease];
        self.controlBarView = [[[GLVideoPlayerControlBarView alloc] initWithFrame:CGRectMake(0, frame.size.height-frame.size.height*0.276, frame.size.width, frame.size.height*0.276)] autorelease];
        self.processView = [[[GLVideoPlayerProcessView alloc] initWithFrame:CGRectMake(0, frame.size.height/2-12.5, 50, 25)] autorelease];
        
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
        [tap release];
        
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesturePan:)];
        [self addGestureRecognizer:pan];
        [pan release];
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
        self.panDirection = GLPanGestureDirectionNone;
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        CGFloat tolerate = 15;
        CGPoint translation = [pan translationInView:self];
        CGPoint velocity = [pan velocityInView:self];
        switch (self.panDirection)
        {
            case GLPanGestureDirectionNone:
            {
                if (fabs(translation.x) > tolerate)
                {
                    self.panDirection = GLPanGestureDirectionHorizontal;
                }
                else if (fabs(translation.y) > tolerate)
                {
                    self.panDirection = GLPanGestureDirectionVertical;
                }
            }
                
            case GLPanGestureDirectionHorizontal:
            {
                if (self.allowGesturePlayBack && [self.delegate respondsToSelector:@selector(videoPlayerView:playback:)])
                {
                    [self.delegate videoPlayerView:self playback:0];
                }
            }break;
                
            case GLPanGestureDirectionVertical:
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

        GLDLog(@"%@",[NSValue valueWithCGPoint:[pan translationInView:self]]);
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
        if ([layer.name isEqualToString:GLPLAYER_VIEW_PLAYER_LAYER_NAME])
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
 @param player 对应的GLPlayer
 */
- (void)resetPlayerLayer:(GLPlayer *)player
{
    CGRect layerFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width*(9/16.0));
    
    for (CALayer * sublayer in self.layer.sublayers)
    {
        if ([sublayer.name isEqualToString:GLPLAYER_VIEW_PLAYER_LAYER_NAME])
        {
            layerFrame = sublayer.frame;
            [sublayer removeFromSuperlayer];
            break;
        }
    }
    
    AVPlayerLayer * layer  = [AVPlayerLayer playerLayerWithPlayer:player.player];
    layer.name  = GLPLAYER_VIEW_PLAYER_LAYER_NAME;
    layer.frame = layerFrame;
    layer.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer insertSublayer:layer atIndex:0];
}

@end



#pragma mark GLVideoPlayerFullScreenWindow

@interface GLVideoPlayerFullScreenWindow : UIWindow

@end



@implementation GLVideoPlayerFullScreenWindow

- (void)resignKeyWindow
{
    
}

@end



#pragma mark GLVideoPlayerFullScreenViewController

@interface GLVideoPlayerFullScreenViewController : UIViewController


@end



@implementation GLVideoPlayerFullScreenViewController

- (void)dealloc
{
    [super dealloc];
}


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



#pragma mark GLVideoPlayer

#define REMAIN_COUNT_FOR_HIDE 20

@interface GLVideoPlayer ()

@property(assign,nonatomic) UIWindow * appKeyWindow;
@property(assign,nonatomic) GLVideoPlayerFullScreenWindow * fullScreenWindow;

@property(assign,nonatomic) BOOL manualPause;

@property(assign,nonatomic) NSInteger remainCountForHide;

@end



@implementation GLVideoPlayer 


+ (instancetype)videoPlayerWithUrls:(NSArray *)urls frame:(CGRect)frame delegate:(id <GLVideoPlayerDelegate>)delegate
{
    GLVideoPlayer * videoPlayer = [[GLVideoPlayer alloc] init];
    GLPlayer * player = [[GLPlayer alloc] initWithUrls:urls delegate:videoPlayer];
    GLVideoPlayerView * playerView = [[GLVideoPlayerView alloc] initWithFrame:frame player:player];
    
    videoPlayer.delegate = delegate;
    playerView.delegate = videoPlayer;
    
    videoPlayer.player = player;
    videoPlayer.playerView = playerView;
    
    [player release];
    [playerView release];
    
    if ([videoPlayer.delegate respondsToSelector:@selector(videoPlayer:customPlayerView:)])
    {
        [videoPlayer.delegate videoPlayer:videoPlayer customPlayerView:videoPlayer.playerView];
        [videoPlayer.playerView resetSubviewFrame];
    }
    
    [playerView addObserver:videoPlayer forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:videoPlayer selector:@selector(deviceRotatedNotif:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return [videoPlayer autorelease];
}


- (void)dealloc
{
    [_playerView removeObserver:self forKeyPath:@"frame"];
    [_player release];
    [_playerView release];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [super dealloc];
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
            GLDLog(@"播放视图未被添加");
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


#pragma mark GLPlayerDelegate

- (void)player:(GLPlayer *)player periodicTimeObserver:(NSDictionary *)info
{
//    GLDLog(@"%@",info);
    if (_remainCountForHide)
    {
        _remainCountForHide--;
        if (!_remainCountForHide && self.playerView.isShowingBar)
        {
            [self.playerView showOrHideBar];
        }
    }
    
    CGFloat current = [[info objectForKey:GLPLAYER_KEY_CURRENT] floatValue];
    CGFloat total = [[info objectForKey:GLPLAYER_KEY_TOTAL] floatValue];
    
    if (!self.playerView.controlBarView.isDraggingSlider)
    {
        self.playerView.controlBarView.processSlider.value = current/total;
        
        self.playerView.controlBarView.labelRemain.text = [GLTimer stringForTimeFormat:@"mm:ss" interval:total - current];
        self.playerView.controlBarView.labelTotalTime.text = [GLTimer stringForTimeFormat:@"mm:ss" interval:total];
        self.playerView.controlBarView.labelCurrentTime.text = [GLTimer stringForTimeFormat:@"mm:ss" interval:current];
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


- (void)player:(GLPlayer *)player statusChange:(AVPlayerItemStatus)status
{
    GLDLog(@"statusChange:%ld",(long)status);
}


- (void)player:(GLPlayer *)player loadedTimeRangeChange:(NSArray *)loadedTimeRange
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
        
//        GLDLog(@"loadedTimeRange--start:%f",start);
//        GLDLog(@"loadedTimeRange--duration:%f",duration);
//        GLDLog(@"loadedTimeRange:%@",value);
    }
}


#pragma mark GLVideoPlayerViewDelegate

- (void)videoPlayerView:(GLVideoPlayerView *)playerView showBar:(BOOL)show
{
    if (show)
    {
        self.remainCountForHide = REMAIN_COUNT_FOR_HIDE;
    }
}


- (void)videoPlayerView:(GLVideoPlayerView *)playerView playBtnAction:(id)sender
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


- (void)videoPlayerView:(GLVideoPlayerView *)playerView playback:(NSInteger)seconds
{
    
}


- (void)videoPlayerView:(GLVideoPlayerView *)playerView fullScreen:(id)sender
{
    if (!self.isFullScreen)
    {
        self.isFullScreen = YES;
        self.playerView.controlBarView.fullScreenBtn.selected = YES;
        
        self.playerView.rect = self.playerView.frame;
        self.playerView.preSuperView = self.playerView.superview;

        self.appKeyWindow = [UIApplication sharedApplication].keyWindow;
        
        _fullScreenWindow = [[GLVideoPlayerFullScreenWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _fullScreenWindow.alpha = 0;
        GLVideoPlayerFullScreenViewController * vc = [[GLVideoPlayerFullScreenViewController alloc] init];
        _fullScreenWindow.rootViewController = vc;
        [vc.view addSubview:self.playerView];
        [vc release];
        
        [_fullScreenWindow makeKeyAndVisible];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [UIApplication sharedApplication].statusBarHidden = YES;
            
            self.playerView.frame = CGRectMake(0, 0, GLSCREEN_WIDTH, GLSCREEN_HEIGHT);
            _fullScreenWindow.alpha = 1;
        } completion:nil];
    }
    else
    {
        self.isFullScreen = NO;
        self.playerView.controlBarView.fullScreenBtn.selected = NO;
        
        [UIView animateWithDuration:0.25 animations:^{
                        
            self.playerView.frame = self.playerView.rect;
            [self.playerView.preSuperView addSubview:self.playerView];

            _fullScreenWindow.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            //解决状态栏问题
            UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window.rootViewController = [[[[self.appKeyWindow.rootViewController class] alloc] init] autorelease];
            [window makeKeyWindow];
            [window release];
            
            [_fullScreenWindow release];
            _fullScreenWindow = nil;
            
            [self.appKeyWindow makeKeyAndVisible];
            
            [UIApplication sharedApplication].statusBarHidden = NO;
        }];
    }
}


- (void)videoPlayerView:(GLVideoPlayerView *)playerView seeking:(CGFloat)value
{
    CGFloat total = CMTimeGetSeconds(self.player.player.currentItem.duration);
    self.playerView.controlBarView.labelRemain.text = [GLTimer stringForTimeFormat:@"mm:ss" interval:total - total * value];
    self.playerView.controlBarView.labelCurrentTime.text = [GLTimer stringForTimeFormat:@"mm:ss" interval:total * value];
}


- (void)videoPlayerView:(GLVideoPlayerView *)playerView seekToValue:(CGFloat)value
{
    _remainCountForHide = REMAIN_COUNT_FOR_HIDE;
    
    self.playerView.processView.startProcess = 0;
    [self.playerView.processView start];

    [self.player pause];
    
    CMTime duration = self.player.player.currentItem.duration;
    BLOCKSELF
    [self retain];
    [self.player.player.currentItem seekToTime:CMTimeMake(duration.value * value, duration.timescale) completionHandler:^(BOOL finished) {
        
        if (finished)
        {
            if (!self.manualPause)
            {
                [self.player play];
            }
            self.playerView.controlBarView.isDraggingSlider = NO;
            GLDLog(@"seek done");
        }
        else
        {
            GLDLog(@"seeking timeout");
        }
        [blockSelf release];
    }];
}

@end