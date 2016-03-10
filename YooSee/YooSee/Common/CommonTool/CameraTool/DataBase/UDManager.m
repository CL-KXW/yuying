//
//  UDManager.m
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "UDManager.h"
#import "LoginResult.h"
@implementation UDManager

+(BOOL)isLogin{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    return [manager boolForKey:kIsLogin];
}

+(void)setIsLogin:(BOOL)isLogin
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    [manager setBool:isLogin forKey:kIsLogin];
    [manager synchronize];
}

+(void)setLoginInfo:(LoginResult *)loginResult{
//    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
//    NSArray *array = [[NSArray alloc] initWithObjects:loginResult,nil];
    [YooSeeApplication shareApplication].loginResult = loginResult;
    //[manager setObject:@[loginResult] forKey:kLoginInfo];
    //[manager synchronize];
    //[array release];
}

+(LoginResult*)getLoginInfo{
    LoginResult *result = [YooSeeApplication shareApplication].loginResult;
//    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
//    //NSData *data = [manager objectForKey:kLoginInfo];
//    NSArray *array = [manager objectForKey:kLoginInfo];
//    result = [array objectAtIndex:0];
////    if(data!=nil){
////        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
////        result = [array objectAtIndex:0];
////    }
    
    return result;
}

+(NSString*)getEmail{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        return [manager stringForKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kEmail]];
    }else{
        return nil;
    }
    
}

+(void)setEmail:(NSString*)email{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        [manager setValue:email forKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kEmail]];
        [manager synchronize];
    }
}

+(NSString*)getPhone{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        return [manager stringForKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kPhone]];
    }else{
        return nil;
    }
    
}

+(void)setPhone:(NSString*)phone{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        [manager setValue:phone forKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kPhone]];
        [manager synchronize];
    }
}



@end
