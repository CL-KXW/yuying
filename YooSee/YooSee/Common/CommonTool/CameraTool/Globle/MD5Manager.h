//
//  MD5Manager.h
//  2cu
//
//  Created by wutong on 15/12/16.
//  Copyright © 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Manager : NSObject

/*
函数功能:     密码转换
szPassword:  6～30位字符串 (如果输入字符串位数不在6~30之间，或者输入10位以下的纯数字，则不作任何处理，直接返回0)
返回:         10位以下的unsigned int型数字
 */
+(unsigned int)GetTreatedPassword:(const char*) szPassword;


/*
 函数功能:md5加密
 szInputBuffer:     6～30位字符串 (如果输入字符串位数不在6~30之间，或者输入10位以下的纯数字，则不作任何处理，直接返回NO)
 szOutputBuffer:    32个字节的字符串，用来保存md5密码后的数据
 返回:               YES成功加密，结果保存在szOutputBuffer中；NO加密失败
 */
+(BOOL)GetMD5PasswordWithSrc:(const char*)szInputBuffer Dst:(char*)szOutputBuffer;
@end
