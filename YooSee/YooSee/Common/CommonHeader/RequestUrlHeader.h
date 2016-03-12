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

//修改密码
#define UPDATE_LOGIN_PWD_URL        MAKE_REQUEST_URL(@"yyw_updatepwd")

//校验支付密码
#define CHECK_PAY_PASSWORD_URL      MAKE_REQUEST_URL(@"yyw_user_paypasswdcheck")

//设置支付密码
#define SET_PAY_PASSWOR_URL         MAKE_REQUEST_URL(@"yyw_user_setpaypasswd")

//获取绑定卡列表
#define BANK_CARD_LIST_URL          MAKE_REQUEST_URL(@"yyw_user_getcardlist")

//实名，提现等信息检查
#define REALNAME_CHECK_URL          MAKE_REQUEST_URL(@"yyw_money_drawcashcheck")

//绑定卡
#define BIND_CARD_URL               MAKE_REQUEST_URL(@"yyw_user_bindcard")

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

//获取广告列表
#define GET_AD_LIST                 MAKE_REQUEST_URL(@"yyw_getlookgglist_new")

//获取广告奖励
#define GET_AD_REWARD               MAKE_REQUEST_URL(@"yyw_getlookmoney")
#endif
