//
//  3DesUtil.m
//  YooSee
//
//  Created by chenlei on 16/2/22.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define kAES128BlockSize	    kCCBlockSizeAES128
#define kAES128KeySize	        kCCKeySizeAES128

#define kDESBlockSize	        kCCBlockSizeDES
#define kDESKeySize				kCCKeySizeDES

#define k3DESBlockSize	        kCCBlockSize3DES
#define k3DESKeySize	        kCCKeySize3DES

#import "DesUtil.h"
#import "GTMBase64.h"
#include <CommonCrypto/CommonCryptor.h>

@implementation DesUtil
static NSString *gIv = @"cell2yyw";

+ (NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key
{
    // 利用 GTMBase64 解碼 Base64 字串
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    
    //unsigned char buffer[1024];
    //memset(buffer, 0, sizeof(char));
    
    uint8_t *buffer = NULL;
    size_t bufferPtrSize = 0;
    bufferPtrSize = ([cipherData length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    buffer = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)buffer, 0x0, bufferPtrSize);
    
    
    size_t numBytesDecrypted = 0;
    
    // IV 偏移量不需使用
    const void *vinitVec = (const void *) [gIv UTF8String];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithm3DES,
                                          kCCOptionPKCS7Padding,//| kCCOptionECBMode
                                          [key UTF8String],
                                          kCCKeySize3DES,
                                          vinitVec,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          bufferPtrSize,
                                          &numBytesDecrypted);
    NSString *plainText = nil;
    if (cryptStatus == kCCSuccess)
    {
        NSData* data = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        NSLog(@"data===%@",data);
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}


+ (NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    const void *vinitVec = (const void *) [gIv UTF8String];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithm3DES,
                                          kCCOptionPKCS7Padding,//| kCCOptionECBMode
                                          [key UTF8String],
                                          kCCKeySize3DES,
                                          vinitVec,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess)
    {
        NSData *dataTemp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [GTMBase64 stringByEncodingData:dataTemp];
    }
    else
    {
        NSLog(@"DES加密失败");
    }
    return plainText;
}



@end
