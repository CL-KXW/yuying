//
//  AvVideoView.m
//  AvPlayer
//
//  Created by clei on 15/9/14.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//-----------------显示视频的view-----------------------

#import "AvVideoView.h"

@implementation AvVideoView

+(Class)layerClass
{
    return [AVPlayerLayer class];
}

-(AVPlayer *)player
{
    return [(AVPlayerLayer *)self.layer player];
}

-(void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)self.layer setPlayer:player];
}

-(void)setFillMode:(NSString *)fillMode
{
    [(AVPlayerLayer *)self.layer setVideoGravity:fillMode];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
