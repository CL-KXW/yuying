//
//  LocalDevice.h
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalDevice : NSObject
@property (strong, nonatomic) NSString *contactId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger contactType;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) double lanTimeInterval;//检查超时
@property (nonatomic) NSInteger isSupportRtsp;
@end
