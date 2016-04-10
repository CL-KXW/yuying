//
//  RequestDataTool.m
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//



#import "RequestDataTool.h"


@implementation RequestDataTool



+ (NSString *)getKeyString
{
    return AES_KEY;
}


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
    
//    NSArray *array = [@"00.46.01.01" componentsSeparatedByString:@"."];
//    int a = [[array objectAtIndex:0] intValue]<<24;
//    int b = [[array objectAtIndex:1] intValue]<<16;
//    int c = [[array objectAtIndex:2] intValue]<<8;
//    int d = [[array objectAtIndex:3] intValue];
//    requestDic[@"AppVersion"] = [NSString stringWithFormat:@"%i",a|b|c|d];
    
    requestDic[@"AppOS"] = @"2";
    requestDic[@"AppVersion"] = @"2883598";
    requestDic[@"VersionFlag"] = @"1";

    return requestDic;
    
}


//单一参数加密
+ (NSString *)aesDataWithString:(NSString *)string
{
    string = string ? string : @"";
    if (string.length == 0)
    {
        return @"";
    }
    string = [FBEncryptorAES encryptBase64String:string keyString:AES_KEY];
    string = string ? string : @"";
    return string;
}


//整体加密
+ (NSDictionary *)encryptWithDictionary:(NSDictionary *)requestDic
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    //加密
    NSString *key = [RequestDataTool getKeyString];
    NSString *requestString = [FBEncryptorAES encryptBase64String:jsonString keyString:key separateLines:YES];
    
    if (requestString)
    {
        return @{@"requestmessage":requestString};
    }
    return nil;
}

//AES
+ (id)decryptJSON:(NSString *)response
{
    if (response.length > 0)
    {
        NSString *key = [RequestDataTool getKeyString];
        NSError *error;
        NSString *decryptStr = [FBEncryptorAES decryptBase64String:response keyString:key];
        //decryptStr = [decryptStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSData *data = [decryptStr dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        return jsonObject;
    }
    return nil;
}


//明文
+ (id)decryptMessage:(NSString *)response
{
    if (response.length > 0)
    {
        NSError *error;
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        return jsonObject;
    }
    return nil;
}

@end
