//
//  RequestDataTool.m
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//



#import "RequestDataTool.h"


@implementation RequestDataTool


+ (NSString *)arc4RandomStringWithLength:(NSInteger)length
{
    NSString *arcString = @"";
    for (int i = 0; i < length; i++)
    {
        arcString = [arcString stringByAppendingFormat:@"%d", arc4random() % 9];
    }
    return arcString;
}

/******固定数据拼接******/
+ (NSDictionary *)makeRequestDictionary:(NSDictionary *)dataDic
{
    
    NSMutableDictionary *requestDic;
    if (dataDic)
    {
        requestDic = [[NSMutableDictionary alloc] initWithDictionary:dataDic];
    }
    else
    {
        requestDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    //id
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyyMMdd";
    NSString *timeStr = [formater stringFromDate:nowDate];
    
    NSString *arcString = [RequestDataTool arc4RandomStringWithLength:8];
    
    NSString *ID = [NSString stringWithFormat:@"%@%@%@", @"yywapp", timeStr, arcString];
    
    //clientId
    NSString *clientId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    clientId = [clientId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //os
    NSString *os = @"iOS";
    
    //channel
    NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:SERVICE];
    if (!channel.length)
    {
        channel = @"hn";
    }
    
    //version
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDict[@"CFBundleShortVersionString"];
    
    //osversion
    NSString *osversion = [[UIDevice currentDevice] systemVersion];
    
    //systemNo
    NSString *systemNo = @"01";
    
    //body
    NSString *body = @"JSON";
    
    //time
    formater.dateFormat = @"yyyyMMddHHmmss";
    NSString *time = [formater stringFromDate:nowDate];
    
    //key
    NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:DESKEY];
    if (!key.length)
    {
        key = @"cellcom";
    }
    
    //signInfo
    NSString * needToMd5String = [NSString stringWithFormat:@"%@%@%@",systemNo,ID, time];
    NSString *signInfo = [NSString stringWithFormat:@"%@%@", [CommonTool md5:needToMd5String], key];
    signInfo = [CommonTool md5:signInfo];
    
    //token
    NSString *token = @"";
    

    NSArray *array = [@"00.46.01.01" componentsSeparatedByString:@"."];
    int a = [[array objectAtIndex:0] intValue]<<24;
    int b = [[array objectAtIndex:1] intValue]<<16;
    int c = [[array objectAtIndex:2] intValue]<<8;
    int d = [[array objectAtIndex:3] intValue];

    
    requestDic[@"AppOS"] = @"2";
    requestDic[@"AppVersion"] = [NSString stringWithFormat:@"%i",a|b|c|d];
    requestDic[@"VersionFlag"] = @"1";
    requestDic[@"id"] = ID;
    requestDic[@"clientId"] = clientId;
    requestDic[@"os"] = os;
    requestDic[@"channel"] = channel;
    requestDic[@"version"] = version;
    requestDic[@"osversion"] = osversion;
    requestDic[@"systemNo"] = systemNo;
    requestDic[@"body"] = body;
    requestDic[@"time"] = time;
    requestDic[@"signInfo"] = signInfo;
    requestDic[@"token"] = token;
    
    return requestDic;
    
}

+ (NSString *)encryptWithDictionary:(NSDictionary *)requestDic
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    //加密
    NSString *key = [RequestDataTool getKeyString];
    NSString *requestString = [DesUtil encryptUseDES:jsonString key:key];

    //NSString *request = [DesUtil decryptUseDES:requestString key:key];
    
    return requestString;
}

+ (NSString *)getKeyString
{
    NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:DESKEY];
    if (!key.length)
    {
        key = @"cellcom";
    }
    return key;
}

+ (id)decryptJSON:(NSString *)response
{
    if (response.length > 0)
    {
        NSString *key = [RequestDataTool getKeyString];
        NSError *error;
        //NSString *encStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *decryptStr = [DesUtil decryptUseDES:response key:key];
        //decryptStr = [decryptStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSData *data = [decryptStr dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        return jsonObject;
    }
    return nil;
}

@end
