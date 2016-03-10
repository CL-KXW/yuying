//
//  NoteDAO.h
//  Persistence
//
//  Created by guojunyi on 14-3-18.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@class Recent;
#define DB_NAME @"Yoosee.sqlite"
@interface RecentDAO : NSObject
@property (nonatomic) sqlite3 *db;


-(BOOL)insert:(Recent*)recent;
-(NSMutableArray*)findAll;
-(BOOL)delete:(Recent*)recent;
-(BOOL)clear;
@end


