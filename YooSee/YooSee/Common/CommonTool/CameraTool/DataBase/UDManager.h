//
//  UDManager.h
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LoginResult;
#define kIsLogin @"isLogin"
#define kLoginInfo @"kLoginInfo"

#define kEmail @"email"
#define kPhone @"phone"



@interface UDManager : NSObject

+(BOOL)isLogin;
+(void)setIsLogin:(BOOL)isLogin;
+(LoginResult*)getLoginInfo;
+(void)setLoginInfo:(LoginResult*)loginResult;

+(void)setEmail:(NSString*)email;
+(NSString*)getEmail;
+(void)setPhone:(NSString*)phone;
+(NSString*)getPhone;

+(NSInteger)getDBVersion;
+(void)setDBVersion:(NSInteger)version;
@end
