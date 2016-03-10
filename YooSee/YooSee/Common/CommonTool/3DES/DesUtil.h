//
//  3DesUtil.h
//  YooSee
//
//  Created by chenlei on 16/2/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesUtil : NSObject

+ (NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key;
+ (NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key;

@end
