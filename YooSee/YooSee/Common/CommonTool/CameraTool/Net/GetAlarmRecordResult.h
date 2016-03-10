//
//  GetAlarmRecordResult.h
//  Yoosee
//
//  Created by gwelltime on 14-11-10.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetAlarmRecordResult : NSObject

@property (nonatomic) int error_code;
@property (nonatomic,strong) NSArray *alarmRecord;

@end
