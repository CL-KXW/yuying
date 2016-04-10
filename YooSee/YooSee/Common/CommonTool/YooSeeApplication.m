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


@end
