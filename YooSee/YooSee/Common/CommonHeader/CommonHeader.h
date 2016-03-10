//
//  CommonHeader.h
//  GeniusWatch
//
//  Created by clei on 15/8/21.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//

#ifndef GeniusWatch_CommonHeader_h
#define GeniusWatch_CommonHeader_h

#import "RequestUrlHeader.h"

//Default
#define USER_DEFAULT            [NSUserDefaults standardUserDefaults]

//APPDelegate
#define DELEGATE                (AppDelegate *)([[UIApplication sharedApplication] delegate])

//设置RGB
#define RGBA(R,G,B,AL)          [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:AL]
#define RGB(R,G,B)              [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

//设置字体大小
#define FONT(f)                 [UIFont systemFontOfSize:f]

//设置加粗字体大小
#define BOLD_FONT(f)            [UIFont boldSystemFontOfSize:f]

//null
#define NO_NULL(string)         (string) ? string : @"";

//主色调
//#define APP_MAIN_COLOR          RGB(227.0,128.0,29.0)
#define APP_MAIN_COLOR          RGB(24.0,168.0,2.0)
//#define LIGHT_MAIN_COLOR        RGB(28.0,117.0,31.0)
#define LIGHT_MAIN_COLOR        RGB(23.0,149.0,26.0)

//起始高度
#define START_HEIGHT            STATUS_BAR_HEIGHT + NAVBAR_HEIGHT

//状态栏高度
#define STATUS_BAR_HEIGHT       20.0

//导航条高度
#define NAVBAR_HEIGHT           44.0

//Tabbar高度
#define TABBAR_HEIGHT           49.0

//屏幕宽度
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height

//屏幕高度
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width

//设备型号
#define DEVICE_MODEL            [[UIDevice currentDevice] model]

//分辨率
#define DEVICE_RESOLUTION       [NSString stringWithFormat:@"%.0f*%.0f", SCREEN_WIDTH * [[UIScreen mainScreen] scale], SCREEN_HEIGHT * [[UIScreen mainScreen] scale]]

//系统版本
#define DEVICE_SYSTEM_VERSION   [[[UIDevice currentDevice] systemVersion] floatValue]

//scale
#define CURRENT_SCALE           SCREEN_WIDTH/375.0

//DEBUG LOG
#ifdef DEBUG

#define NSLog( s, ... ) NSLog( @"< %@:(%d) > %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

#define NSLog( s, ... )

#endif


#endif
