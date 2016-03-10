//
//  LoginResult.h
//  Yoosee
//
//  Created by guojunyi on 14-3-24.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginResult : NSObject<NSCoding>
@property (strong, nonatomic) NSString* contactId;
@property (strong, nonatomic) NSString* rCode1;
@property (strong, nonatomic) NSString* rCode2;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* sessionId;
@property (strong, nonatomic) NSString* countryCode;
@property (nonatomic) int error_code;
@end
