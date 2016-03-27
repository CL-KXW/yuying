//
//  HttpManager.m
//  YooSee
//
//  Created by 周后云 on 16/3/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "HttpManager.h"

@implementation HttpManager

+(BOOL)haveNetwork{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    if (manager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
        return YES;
    }else{
        return NO;
    }
}

+(void)postUrl:(NSString *)url parameters:(id)par
       success:(success)success
       failure:(failure)failure{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:url]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:url parameters:par success:^(AFHTTPRequestOperation *operation, NSDictionary* jsonObject) {
        success(operation,jsonObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}


@end
