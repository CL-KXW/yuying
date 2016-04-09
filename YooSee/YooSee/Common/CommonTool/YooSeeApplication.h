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
@property (nonatomic, strong) NSDictionary *userInfoDic;
@property (nonatomic, strong) NSDictionary *userDic;
@property (nonatomic, strong) NSDictionary *user2CUDic;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) NSString *pwd2cu;
@property (nonatomic, strong) LoginResult *loginResult;
@property (nonatomic, strong) NSDictionary *loginServerDic;
@property (nonatomic, strong) NSArray *devInfoListArray;
@property (nonatomic, strong) NSString *cityID;
@property (nonatomic, strong) NSString *provinceID;

+ (instancetype)shareApplication;

@end
