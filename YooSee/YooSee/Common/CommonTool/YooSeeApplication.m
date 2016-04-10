//
//  YooSeeApplication.m
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "YooSeeApplication.h"

@implementation YooSeeApplication

+ (instancetype)shareApplication
{
    static YooSeeApplication *yooSeeApplication;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        yooSeeApplication = [[self alloc] init];
    });
    return yooSeeApplication;
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _isLogin = NO;
        _isLogin2cu = NO;
    }
    return self;
}

- (NSString *)getUserID
{
    NSDictionary *userDic = [YooSeeApplication shareApplication].userInfoDic;
    NSString *key = userDic ? @"id" : @"user_id";
    userDic = userDic ? userDic : [YooSeeApplication shareApplication].userDic;
    NSString *user_id = userDic[key];
    user_id = UNNULL_STRING(user_id);
    return user_id;
}

@end
