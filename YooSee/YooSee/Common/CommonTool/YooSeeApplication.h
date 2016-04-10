//
//  YooSeeApplication.h
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"
#import "LoginResult.h"

@interface YooSeeApplication : NSObject

@property (nonatomic, assign) BOOL isLogin2cu;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) NSDictionary *userInfoDic;//个人信息返回的用户信息
@property (nonatomic, strong) NSDictionary *userDic;//用户用户登录返回的用户信息
@property (nonatomic, strong) NSDictionary *user2CUDic;//登录2cu返回数据
@property (nonatomic, strong) NSString *uid;//用户ID
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) NSString *pwd2cu;
@property (nonatomic, strong) LoginResult *loginResult;
@property (nonatomic, strong) NSDictionary *loginServerDic;//系统参数
@property (nonatomic, strong) NSArray *devInfoListArray;
@property (nonatomic, strong) NSString *cityID;
@property (nonatomic, strong) NSString *provinceID;

+ (instancetype)shareApplication;

@end
