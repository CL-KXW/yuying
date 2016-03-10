//
//  Player.m
//  Player
//
//  Created by Zac on 15/11/6.
//  Copyright © 2015年 lanou. All rights reserved.
//

#import "Player.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UISlider+UISlider_touch.h"
#import "UIView+UIView_Frame.h"

#define KScreenWidth [[UIScreen mainScreen]bounds].size.width
#define KScreenHeight [[UIScreen mainScreen]bounds].size.height

@interface Player()
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, retain) UILabel *startTime;
@property (nonatomic, retain) UILabel *endTime;
@property (nonatomic, retain) UISlider *progress;
@property (nonatomic, retain) UISlider *playableProgress;
@property (nonatomic, retain) UISlider *volume;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIView *backView;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIImageView *timaImage;
@property (nonatomic, retain) UILabel *timeLabel;
@end

@implementation Player

- (instancetype)initWithFrame:(CGRect)frame URL:(NSString *)UrlString
{
    self = [super initWithFrame:frame];
    if (self) {
        NSURL *URL = [NSURL URLWithString:UrlString];
        self.moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:URL];
        self.moviePlayer.view.frame = self.bounds;
        [self.moviePlayer play];
        //  播放器样式
        self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        //  关闭播放器响应,避免抢走其他控件的触控事件
        self.moviePlayer.view.userInteractionEnabled = NO;
        [self addSubview:self.moviePlayer.view];
        
        //  添加通知
        [self addNotification];
    }
    
    [self createUI];
    
    [self performSelector:@selector(playButtonDisappear) withObject:self afterDelay:3];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    return self;
}

- (void)valueChange:(UISlider *)progress other:(UIEvent *)event {
    NSTimeInterval currenttime;
    NSInteger minit;
    NSInteger second;
    UITouch *touch = [[event allTouches] anyObject];
    switch (touch.phase) {
        case UITouchPhaseBegan:
            NSLog(@"start");
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playButtonDisappear) object:nil];
            [self.timer invalidate];
            break;
        case UITouchPhaseMoved:
            currenttime = self.progress.value * self.moviePlayer.duration;
            minit = currenttime / 60;
            second = currenttime - 60 * minit;
            self.startTime.text = self.startTime.text = [NSString stringWithFormat:@"%02d:%02d", minit, second];
            self.timaImage.hidden = NO;
            self.timaImage.center = CGPointMake((KScreenWidth - 12)* self.progress.value + 6, self.progress.frame.origin.y - 15) ;
            
            self.timeLabel.text = self.startTime.text;
            break;
        case UITouchPhaseEnded:
            NSLog(@"end");
            self.timaImage.hidden = YES;
            self.moviePlayer.currentPlaybackTime = self.progress.value * self.moviePlayer.duration;
            if (self.moviePlayer.currentPlaybackRate == 0) {
                [self tapAction];
            }
            [self performSelector:@selector(playButtonDisappear) withObject:self afterDelay:3];
            [self.timer fire];
            break;
        default:
            break;
    }
}

- (void)resetSlider {
    self.moviePlayer.currentPlaybackTime = self.progress.value * self.moviePlayer.duration;
    [self tapAction];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playButtonDisappear) object:nil];
    [self performSelector:@selector(playButtonDisappear) withObject:self afterDelay:3];
}

- (void)refreshCurrentTime {
    NSInteger minit = self.moviePlayer.currentPlaybackTime / 60;
    NSInteger second = self.moviePlayer.currentPlaybackTime - 60 * minit;
    self.startTime.text = [NSString stringWithFormat:@"%02d:%02d", minit, second];
    
    self.progress.value = self.moviePlayer.currentPlaybackTime / self.moviePlayer.duration;
    self.playableProgress.value = self.moviePlayer.playableDuration / self.moviePlayer.duration;
}

-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(DurationAvailable) name:MPMovieDurationAvailableNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

-(void)mediaPlayerPlaybackFinished {
    
}

- (void)DurationAvailable {
    NSInteger minit = self.moviePlayer.duration / 60;
    NSInteger second = self.moviePlayer.duration - 60 * minit;
    self.endTime.text = [NSString stringWithFormat:@"%02d:%02d", minit, second];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}

- (void)createUI {
    //  backView
    self.backView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.backView.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.backView.userInteractionEnabled = YES;
    [self addSubview:self.backView];
    
    //  PlayButton
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateSelected];
    self.playButton.frame = CGRectMake(0, 0, 46, 46);
    self.playButton.center = self.center;
    [self.backView addSubview:self.playButton];
    
    //  startTime
    self.startTime = [[UILabel alloc]initWithFrame:CGRectMake(KScreenWidth - 15 - 35 - 10 - 30, KScreenHeight - 45, 35, 15)];
    self.startTime.text = @"00:00";
    self.startTime.font = [UIFont systemFontOfSize:12];
//    self.startTime.backgroundColor = [UIColor redColor];
    self.startTime.textColor = [UIColor whiteColor];
    [self.backView addSubview:self.startTime];
    
    //  /
    UILabel *gang = [[UILabel alloc]initWithFrame:CGRectMake(KScreenWidth - 15 - 35 - 3, KScreenHeight - 46, 10, 15)];
    gang.text = @"/";
    gang.font = [UIFont systemFontOfSize:12];
    gang.textColor = [UIColor whiteColor];
    [self.backView addSubview:gang];
    
    //  endTime
    self.endTime = [[UILabel alloc]initWithFrame:CGRectMake(KScreenWidth - 15 - 30, KScreenHeight - 45, 35, 15)];
    self.endTime.text = @"00:00";
    self.endTime.font = [UIFont systemFontOfSize:12];
    self.endTime.textColor = [UIColor whiteColor];
    [self.backView addSubview:self.endTime];
    
    // playalbeslider
    self.playableProgress =[[UISlider alloc]initWithFrame:CGRectMake(0, KScreenHeight - 15 - 15, KScreenWidth, 15)];
    //  滑块左侧颜色
    self.playableProgress.minimumTrackTintColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    //  滑块右侧颜色
    self.playableProgress.maximumTrackTintColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:0.5];
    UIImage *thumbImageEmp = [[UIImage alloc]init];
    [self.playableProgress setThumbImage:thumbImageEmp forState:UIControlStateNormal];
    [self.playableProgress setThumbImage:thumbImageEmp forState:UIControlStateSelected];
    self.playableProgress.userInteractionEnabled = NO;
    [self addSubview:self.playableProgress];
    
    //slider
    self.progress =[[UISlider alloc]initWithFrame:CGRectMake(0, KScreenHeight - 15 - 15, KScreenWidth, 15)];
    //  滑块左侧颜色
    self.progress.minimumTrackTintColor = [UIColor whiteColor];
    //  滑块右侧颜色
    self.progress.maximumTrackTintColor = [UIColor clearColor];
    UIImage *thumbImage0 = [UIImage imageNamed:@"Oval 1"];
    [self.progress setThumbImage:thumbImage0 forState:UIControlStateNormal];
    [self.progress setThumbImage:thumbImage0 forState:UIControlStateSelected];
    [self.progress addTarget:self action:@selector(valueChange:other:) forControlEvents:UIControlEventValueChanged];
    [self.progress addTapGestureWithTarget:self action:@selector(resetSlider)];
    [self addSubview:self.progress];
    
    //  backButton
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"Safari Back"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.frame = CGRectMake(15, 15, 34, 34);
    [self.backView addSubview:self.backButton];
    
    //  timeImage
    self.timaImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ThumBut"]];
    self.timaImage.frame = CGRectMake(0, 0, 30, 12);
    self.timaImage.hidden = YES;
    [self addSubview:self.timaImage];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 12)];
    self.timeLabel.font = [UIFont systemFontOfSize:8];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.timaImage addSubview:self.timeLabel];
    
}

- (void)backAction {
    [self.moviePlayer pause];
    [self removeFromSuperview];
}

-(void)tapAction {
    if (self.backView.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            self.progress.y = KScreenHeight -30;
            self.playableProgress.y = KScreenHeight -30;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.backView.hidden = NO;
            self.backView.alpha = 1;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playButtonDisappear) object:nil];
        }completion:^(BOOL finished) {
        }];
    }else {
        [self performSelector:@selector(playButtonDisappear) withObject:self afterDelay:3];
    }
    if (self.playButton.selected) {
        [self.moviePlayer play];
    }else {
        [self.moviePlayer pause];
    }
    self.playButton.selected = !self.playButton.selected;
}

-(void)playButtonDisappear {
    if (self.playButton.selected) {
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.progress.y = KScreenHeight -9;
        self.playableProgress.y = KScreenHeight -9;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        self.backView.alpha = 0;
    }completion:^(BOOL finished) {
        self.backView.hidden = YES;
    }];
}

@end
