//
//  Constants.h
//  Yoosee
//
//  Created by guojunyi on 14-3-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//
#ifndef LOG_ON
#define LOG_OFF
#endif

#ifdef LOG_ON
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define APP_VERSION @"00.46.01.06"

#define XBgColor [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0]

#define XHeadBarBgColor [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:1.0]

#define XHeadBarTextColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define XHeadBarTextSize (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 24.0:18.0)

#define customRedCorlor [UIColor colorWithRed:217.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1]


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGB_A(rgbValue,alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#define UIColorFromRGBA(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF000000) >> 24))/255.0 \
green:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
blue:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
alpha:((float)(rgbValue & 0xFF))/255.0]

#define XBlack [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]
#define XBlack_128 [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:128.0/255.0]
#define XBlue [UIColor colorWithRed:101.0/255.0 green:181.0/255.0 blue:250.0/255.0 alpha:1.0]

#define XWhite [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]


#define XBGAlpha [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]

#define XFontBold_18 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont boldSystemFontOfSize:20.0]:[UIFont boldSystemFontOfSize:18.0])
#define XFontBold_16 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont boldSystemFontOfSize:16.0]:[UIFont boldSystemFontOfSize:14.0])
#define XFontBold_14 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont boldSystemFontOfSize:14.0]:[UIFont boldSystemFontOfSize:12.0])
#define XFontBold_12 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont boldSystemFontOfSize:12.0]:[UIFont boldSystemFontOfSize:10.0])
//global
#define CURRENT_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define TAB_BAR_HEIGHT 49
#define NAVIGATION_BAR_HEIGHT ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 44:44):(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:64))
//#define NAVIGATION_BAR_HEIGHT ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44):(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:64))

//TABLE TEXTFIELD
#define BAR_BUTTON_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 68:46)
#define BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 36:24)
#define BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 24:18)
#define BAR_BUTTON_MARGIN_LEFT_AND_RIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 25:15)

#define TEXT_FIELD_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:40)

//BUTTON
#define NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 45:35)

//storage type
#define SDCARD 16
#define USB 0

typedef enum{
    P2PCALL_TYPE_MONITOR,
    P2PCALL_TYPE_VIDEO,
    P2PCALL_TYPE_PLAYBACK
} P2PCallType;

typedef enum{
    P2PCALL_STATE_NONE,
    P2PCALL_STATE_CALLING,
    P2PCALL_STATE_READY
} P2PCallState;

typedef enum{
    PLAYBACK_STATE_STOP,
    PLAYBACK_STATE_PAUSE,
    PLAYBACK_STATE_PLAYING
} PlaybackState;


typedef struct DeviceDate{
    int year;
    int month;
    int day;
    int hour;
    int minute;
}DeviceDate;









