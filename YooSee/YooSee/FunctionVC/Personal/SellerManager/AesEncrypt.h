//
//  AesEncrypt.h
//  iAppPay
//
//  Created by xxLe on 15/3/10.
//  Copyright (c) 2015年 iPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (Encryption)

- (NSData *)aes128EncryptWithKey:(NSString *)key;   //加密

- (NSData *)aes128DecryptWithKey:(NSString *)key;   //解密



@end
