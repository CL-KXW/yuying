//
//  RequestUrlHeader.h
//  GeniusWatch
//
//  Created by chenlei on 15/9/3.
//  Copyright (c) 2015年 chenlei. All rights reserved.
//

#ifndef GeniusWatch_RequestUrlHeader_h
#define GeniusWatch_RequestUrlHeader_h

//#define SERVER_URL                  @"http://zhouqiubo.vicp.cc:9998/koi"
//#define SERVER_URL                  @"http://1.199.40.48:8086/koi"
#define SERVER_URL                  @"http://112.74.135.133/yyw/"

#define MAKE_REQUEST_URL(inf)       [NSString stringWithFormat:@"%@%@.flow",SERVER_URL,inf]

//登录服务器
#define LOGIN_SERVER_URL            MAKE_REQUEST_URL(@"yyw_getsysdata")

//登录
#define USER_LOGIN_URL              MAKE_REQUEST_URL(@"yyw_login")

//2cu_login
#define LOGIN_2CU_URL               @"http://cloudlinks.cn/Users/LoginCheck.ashx"

//2cu_Alarm
#define ALARM_2CU_URL               @"http://cloudlinks.cn/Alarm/AlarmRecordEx.ashx"

//个人信息
#define USER_INFO_URL               MAKE_REQUEST_URL(@"yyw_userinfo")

//更新个人信息
#define UPDATE_USER_INFO_URL        MAKE_REQUEST_URL(@"yyw_userinfo_update")

//获取广告
#define GET_ADV_URL                 MAKE_REQUEST_URL(@"yyw_getgg_new")

//获取头条
#define GET_HEADNEWS_URL            MAKE_REQUEST_URL(@"yyw_headlines_list")

//设置设备信息
#define SET_DEVICE_URL              MAKE_REQUEST_URL(@"yyw_setdevice")

//获取设备列表
#define DEVICE_LIST_URL             MAKE_REQUEST_URL(@"yyw_getdevicelist")

//删除设备
#define DELETE_DEVICE_URL           MAKE_REQUEST_URL(@"yyw_deldevice")

//帮助
#define HELP_URL                    @"http://dianliangtech.com/help/app"

#endif
