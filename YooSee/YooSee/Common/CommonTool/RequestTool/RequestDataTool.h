//
//  RequestDataTool.h
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define DESKEY          @"DESKEY"
#define SERVICE         @"SERVICE"
#define SERVICE_URL     @"SERVICEURL"

#import <Foundation/Foundation.h>
#import "DesUtil.h"

@interface RequestDataTool : NSObject

+ (NSDictionary *)makeRequestDictionary:(NSDictionary *)dataDic;

+ (NSString *)encryptWithDictionary:(NSDictionary *)requestDic;

+ (id)decryptJSON:(NSString *)response;

@end
