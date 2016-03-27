//
//  HttpManager.h
//  YooSee
//
//  Created by 周后云 on 16/3/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"

typedef void(^success)(AFHTTPRequestOperation *operation, NSDictionary* jsonObject);
typedef void(^failure)(AFHTTPRequestOperation *operation,NSError *error);

@interface HttpManager : NSObject

+(BOOL)haveNetwork;


+(void)postUrl:(NSString *)url parameters:(id)par
       success:(success)success
       failure:(failure)failure;

@end
