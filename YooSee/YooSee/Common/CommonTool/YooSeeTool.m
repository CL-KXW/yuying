//
//  YooSeeTool.m
//  YooSee
//
//  Created by chenlei on 16/2/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "YooSeeTool.h"

@implementation YooSeeTool

+ (NSString *)getStringValueFromDictionary:(NSDictionary *)dataDic key:(NSString *)key
{
    NSString *string;
    
    if (dataDic && key && key.length != 0)
    {
        string = dataDic[key];
        string = string ? string : @"";
    }
    
    return string;
}

+ (void)saveSystemData:(NSDictionary *)dictionary
{
    if (!dictionary)
    {
        return;
    }
    NSString *service = [YooSeeTool getStringValueFromDictionary:dictionary key:@"service"];
    NSString *key = [YooSeeTool getStringValueFromDictionary:dictionary key:@"key"];
    NSString *serviceurl = [YooSeeTool getStringValueFromDictionary:dictionary key:@"serviceurl"];
    [[NSUserDefaults standardUserDefaults] setObject:service forKey:SERVICE];
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:DESKEY];
    [[NSUserDefaults standardUserDefaults] setObject:serviceurl forKey:SERVICE_URL];
}

+ (NSString *)serverIp
{
    NSString *serverIp = @"";
    return serverIp;
}

@end
