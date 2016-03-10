//
//  Alarm.h
//  Yoosee
//
//  Created by Jie on 14-10-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alarm : NSObject

@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *alarmTime;
@property (nonatomic) int alarmType;
@property (nonatomic) int alarmGroup;
@property (nonatomic) int alarmItem;
@property (nonatomic) int row;
@property (nonatomic, strong) NSString * msgIndex;

@end
