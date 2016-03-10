//
//  AvPlayerView.h
//  KOShow
//
//  Created by chenlei on 15/12/3.
//  Copyright © 2015年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol AvPlayerViewDelegate;


@interface AvPlayerView : UIView

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, assign) id<AvPlayerViewDelegate> delegate;

@end


@protocol AvPlayerViewDelegate <NSObject>

@optional

- (void)isSwitchFullScreen:(BOOL)fullScreen;

@end