//
//  AVPlayerViewController.h
//  Player
//
//  Created by Zac on 15/11/6.
//  Copyright © 2015年 lanou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AVPlayerVCDelegate <NSObject>

- (void)dismissViewController:(id)player;

@end

typedef NS_ENUM(NSInteger, PanDirection) {
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};
@interface AVPlayerViewController : UIViewController
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) id<AVPlayerVCDelegate>delegate;
@end
