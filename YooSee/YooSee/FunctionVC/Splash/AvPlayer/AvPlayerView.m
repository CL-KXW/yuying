//
//  AvPlayerView.m
//  KOShow
//
//  Created by chenlei on 15/12/3.
//  Copyright © 2015年 chenlei. All rights reserved.
//

#define BOTTOM_HEIGHT   44.0

#import "AvPlayerView.h"
#import "AvVideoView.h"


@interface AvPlayerView ()

@property (nonatomic,strong) AVPlayer *videoPlayer;                         //播放器
@property (nonatomic,strong) AvVideoView *videoView;                        //播放器显示层
@property (strong) AVPlayerItem *item;

@property (nonatomic,assign) CGRect originFrame;
@property (nonatomic,assign) BOOL isFullscreen;                             //是否横屏
@property (nonatomic,assign) UIInterfaceOrientation currentOrientation;     //当前屏幕方向

@property (nonatomic,strong) id timeObserver;

@end

@implementation AvPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.originFrame = self.frame;
    
    //添加屏幕单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    
}

#pragma mark 设置播放地址
-(void)setVideoUrl:(NSString *)videoUrl
{
    if(_videoUrl != videoUrl)
    {
        _videoUrl = videoUrl;
        if(_videoUrl == nil)
        {
            return;
        }
        
        NSURL *url = [NSURL fileURLWithPath:_videoUrl];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        NSArray *requestedKeys = @[@"playable"];
        
        __weak typeof(self) weakSelf = self;
        
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
            dispatch_async(dispatch_get_main_queue(),^{
                [weakSelf prepareToPlayAsset:asset withKeys:requestedKeys];
            });
        }];
    }
}

/////////////////////////////////
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
    }
    
    if (!asset.playable)
    {
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    if (self.item)
    {
        [self.item removeObserver:self forKeyPath:@"status"];
    }
    
    self.item = [AVPlayerItem playerItemWithAsset:asset];
    
    [self.item addObserver:self
                forKeyPath:@"status"
                   options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                   context:nil];
    
    if (!self.videoPlayer)
    {
        self.videoPlayer = [AVPlayer playerWithPlayerItem:self.item];
    }
    
    if (self.videoPlayer.currentItem != self.item)
    {
        [self.videoPlayer replaceCurrentItemWithPlayerItem:self.item];
    }
    
    [self removeTimeObserver];
    
    
    if(!_videoView)
    {
        self.videoView = [[AvVideoView alloc]initWithFrame:self.frame];
        _videoView.translatesAutoresizingMaskIntoConstraints = NO;
        _videoView.player = _videoPlayer;
        [_videoView setFillMode:AVLayerVideoGravityResizeAspectFill];
        [self addSubview:_videoView];
    }
    [self sendSubviewToBack:_videoView];
    
    [_videoPlayer play];
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)removeTimeObserver
{
    if (_timeObserver)
    {
        [self.videoPlayer removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture
{

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerStatusReadyToPlay:
            {
                //只有在播放状态才能获取视频时间长度
                //AVPlayerItem *playerItem = (AVPlayerItem *)object;
                //NSTimeInterval duration = CMTimeGetSeconds(playerItem.asset.duration);
            }
            break;
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
            case AVPlayerStatusUnknown:
            {

            }
                break;
            default:
                break;
        }
    }
}


- (void)dealloc
{
    [self removeTimeObserver];
    [self.item removeObserver:self
                forKeyPath:@"status"
                   context:nil];
}

@end
