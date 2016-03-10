//
//  YCScreenshotCell.h
//  OspreyIAD
//
//  Created by cellcom on 15/4/9.
//  Copyright (c) 2015年 Suycity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "ScreenshotView.h"

@interface ScreenshotCell : UITableViewCell<UIAlertViewDelegate>

@property (nonatomic, retain) ScreenshotView *screenshotView1;
@property (nonatomic, retain) ScreenshotView *screenshotView2;
@property (nonatomic, assign) BOOL isVideoCell;//cell显示的是视频还是图像

- (void)config:(NSArray *)infos block:(void(^)(ScreenshotView *,UIImage *,NSInteger))block;
@end
