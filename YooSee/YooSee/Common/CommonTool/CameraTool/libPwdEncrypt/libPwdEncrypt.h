//
//  libPwdEncrypt.h
//  libPwdEncrypt
//
//  Created by gwelltime on 15-3-5.
//  Copyright (c) 2015年 gwelltime. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  DWORD        unsigned int
#define  BYTE         unsigned char

@interface libPwdEncrypt : NSObject

+(NSString *)passwordEncryptWithPassword:(NSString *)password;//encrypt password

@end