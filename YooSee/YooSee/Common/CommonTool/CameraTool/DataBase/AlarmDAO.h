//
//  AlarmDAO.h
//  Yoosee
//
//  Created by Jie on 14-10-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alarm.h"
#import "sqlite3.h"
#define DB_NAME @"Yoosee.sqlite"

@interface AlarmDAO : NSObject
@property (nonatomic) sqlite3 *db;


-(BOOL)insert:(Alarm*)alarm;
-(NSMutableArray*)findAll;
-(BOOL)delete:(Alarm*)alarm;
-(BOOL)clear;

@end
