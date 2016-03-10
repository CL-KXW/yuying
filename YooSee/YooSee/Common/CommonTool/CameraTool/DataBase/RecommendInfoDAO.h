//
//  RecommendInfoDAO.h
//  Yoosee
//
//  Created by gwelltime on 15-1-31.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecommendInfo.h"
#import "sqlite3.h"
#define DB_NAME @"Yoosee.sqlite"

@interface RecommendInfoDAO : NSObject
@property (nonatomic) sqlite3 *db;

-(BOOL)insert:(RecommendInfo *)model ;
-(NSMutableArray*)findAll;
-(BOOL)updateDBWithKey:(int)key modify:(RecommendInfo *)model;
//-(BOOL)delete:(RecommendInfo *)model ;
//-(BOOL)clear;

@end
