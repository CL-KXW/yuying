//
//  RequestDataTool.h
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//


#define AES_KEY                     @"4934505598453075"

#import <Foundation/Foundation.h>

@interface RequestDataTool : NSObject

//拼接数据
+ (NSDictionary *)makeRequestDictionary:(NSDictionary *)dataDic;

//单一加密
+ (NSString *)aesDataWithString:(NSString *)string;

//整体加密
+ (NSDictionary *)encryptWithDictionary:(NSDictionary *)requestDic;

//Aes
+ (id)decryptJSON:(NSString *)response;

//明文
+ (id)decryptMessage:(NSString *)response;



@end
