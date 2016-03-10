//
//  YooSeeTool.h
//  YooSee
//
//  Created by chenlei on 16/2/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YooSeeTool : NSObject

+ (void)saveSystemData:(NSDictionary *)dictionary;

+ (NSString *)serverIp;

@end
