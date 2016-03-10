//
//  AvVideoView.h
//  AvPlayer
//
//  Created by clei on 15/9/14.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AvVideoView : UIView

@property (nonatomic,strong) AVPlayer *player;

-(void)setFillMode:(NSString *)fillMode;

@end
