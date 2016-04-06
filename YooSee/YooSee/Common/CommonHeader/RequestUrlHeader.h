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
#define SERVER_URL                  @"http://yyw.dianliangtech.com/dianliang/"

#define MAKE_REQUEST_URL(inf)       [NSString stringWithFormat:@"%@%@",SERVER_URL,inf]

//登录服务器
#define LOGIN_SERVER_URL            MAKE_REQUEST_URL(@"app/system/version")

//登录
#define USER_LOGIN_URL              MAKE_REQUEST_URL(@"app/user/login")

//自动登录
#define AUTO_USER_LOGIN_URL         MAKE_REQUEST_URL(@"app/user/loginByToken")

//注册/忘记密码
#define REGISTER_URL                MAKE_REQUEST_URL(@"app/user/register")

//忘记登录密码
#define FIND_LOGIN_PWD_URL          MAKE_REQUEST_URL(@"app/user/update/userpwd")

//忘记支付密码
#define FIND_PAY_PWD_URL            MAKE_REQUEST_URL(@"app/user/update/paypwd")

//注册短信验证码
#define PHONE_CODE_URL              MAKE_REQUEST_URL(@"send/message/code")

//找回密码 code
#define FIND_PHONE_CODE_URL         MAKE_REQUEST_URL(@"send/message/back/userpwd/code")

//找回密码 pay code
#define FIND_PAY_PHONE_CODE_URL     MAKE_REQUEST_URL(@"send/message/back/paypwd/code")

//static NSString *server1 = @"http://cloudlinks.cn/";
//static NSString *server2 = @"http://gwelltimes.com/";
//static NSString *server3 = @"http://2cu.co/";
//static NSString *server4 = @"http://cloud-links.net/";
//2cu_login
#define LOGIN_2CU_URL               @"http://2cu.co/Users/LoginCheck.ashx"

//2cu_Alarm
#define ALARM_2CU_URL               @"http://2cu.co/Alarm/AlarmRecordEx.ashx"

//个人信息
#define USER_INFO_URL               MAKE_REQUEST_URL(@"app/user/querybyID")

//上传图片
#define UPLOAD_PIC_URL              MAKE_REQUEST_URL(@"image/file/upload")

//更新个人信息
#define UPDATE_USER_INFO_URL        MAKE_REQUEST_URL(@"app/user/update/material")

//收货地址列表
#define ADDRESS_LIST_URL            MAKE_REQUEST_URL(@"shipping/addr/list")

//更新收货地址
#define UPDATE_ADDRESS_URL          MAKE_REQUEST_URL(@"shipping/addr/update")

//添加收货地址
#define ADD_ADDRESS_URL             MAKE_REQUEST_URL(@"shipping/addr/add")

//修改密码
#define UPDATE_LOGIN_PWD_URL        MAKE_REQUEST_URL(@"app/user/set/pwd")

//设置支付密码
#define SET_PAY_PASSWOR_URL         MAKE_REQUEST_URL(@"app/user/set/pay")

//修改支付密码
#define UPDATE_PAY_PASSWOR_URL      MAKE_REQUEST_URL(@"app/user/set/paypwd_update")


//校验支付密码
#define CHECK_PAY_PASSWORD_URL      MAKE_REQUEST_URL(@"yyw_user_paypasswdcheck")

//获取绑定卡列表
#define BANK_CARD_LIST_URL          MAKE_REQUEST_URL(@"yyw_user_getcardlist")

//实名，提现等信息检查
#define REALNAME_CHECK_URL          MAKE_REQUEST_URL(@"yyw_money_drawcashcheck")

//绑定卡
#define BIND_CARD_URL               MAKE_REQUEST_URL(@"yyw_user_bindcard")

//获取广告
#define GET_ADV_URL                 MAKE_REQUEST_URL(@"app/guanggaowei/querybyUserId")

//获取头条
#define GET_HEADNEWS_URL            MAKE_REQUEST_URL(@"app/system/headline")

//设置设备信息
#define SET_DEVICE_URL              MAKE_REQUEST_URL(@"/app/camera/add")

//添加设备
#define ADD_DEVICE_URL              MAKE_REQUEST_URL(@"app/camera/add")

//获取设备列表
#define DEVICE_LIST_URL             MAKE_REQUEST_URL(@"app/camera/queryListByUserId")

//删除设备
#define DELETE_DEVICE_URL           MAKE_REQUEST_URL(@"app/camera/delete")

//更新摄像头
#define UPDATE_DEVICE_URL           MAKE_REQUEST_URL(@"app/camera/update")

//帮助
#define HELP_URL                    @"http://dianliangtech.com/help/app"

//获取广告列表
#define GET_AD_LIST                 MAKE_REQUEST_URL(@"app/ab/queryList")

//获取广告奖励
#define GET_AD_REWARD               MAKE_REQUEST_URL(@"app/ab/get/add")

//预约抢红包
#define MAKE_ROB                    MAKE_REQUEST_URL(@"app/register/add")

//红包详情
#define RED_POCKET_DETAIL           MAKE_REQUEST_URL(@"yyw_redpackedgg")

//抢红包
#define RED_POCKET_ROB              MAKE_REQUEST_URL(@"app/red/get/add")

//抢红包排行榜
#define RED_POCKET_ROBER_LIST       MAKE_REQUEST_URL(@"app/red/get/sort")

//创建订单
#define CREATEORDER_URL             MAKE_REQUEST_URL(@"account/recharge/add")

//提现申请
#define MONEY_DRAWCASHSUBMIT        MAKE_REQUEST_URL(@"app/account/personal/tixian/add")

//抢红包列表
#define ROB_RED_PACKGE_LIST         MAKE_REQUEST_URL(@"app/red/send/querybyCity_id")

//点击红包进入红包详情
#define ROB_RED_PACKGE_DETAIL       MAKE_REQUEST_URL(@"app/red/get/add")

//我的红包列表
#define MY_RED_PACKGE_LIST          MAKE_REQUEST_URL(@"app/red/get/querybylingqu_user_id")

//获取红包状态
#define RED_PACKAGE_STATE           MAKE_REQUEST_URL(@"app/red/send/getByOnly_numberAndUser_id")

//查看提现明细
#define GET_TIXIAN_LIST             MAKE_REQUEST_URL(@"app/account/personal/tixian/queryAccountPersonal")
#endif

