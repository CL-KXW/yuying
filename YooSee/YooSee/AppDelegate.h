//
//  AppDelegate.h
//  YooSee
//
//  Created by chenlei on 16/1/29.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isRotation;

- (void)checkUpdateShowTip:(BOOL)isShow;

@end

