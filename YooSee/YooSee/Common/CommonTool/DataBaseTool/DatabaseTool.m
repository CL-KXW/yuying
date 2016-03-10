//
//  DatabaseTool.m
//  KOShow
//
//  Created by 陈磊 on 16/1/19.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "DatabaseTool.h"
#import "FMDB.h"

@implementation DatabaseTool

+ (NSMutableArray *)queryDataForArray:(NSMutableArray *)array
{
    NSString *path = [FileManageTool findFilePathWithType:FilePathTypeCache fileName:HISTORY_TABLE_FILE];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if ([db open])
    {
        NSString *sql = QUERY_TABLE_SQL;
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString *keyWord = [rs stringForColumn:@"keyWord"];
            [array addObject:keyWord];
        }
        [db close];
    }
    return array;
}


+ (void)insterDataWithValue:(NSString *)value
{
    NSString *path = [FileManageTool findFilePathWithType:FilePathTypeCache fileName:HISTORY_TABLE_FILE];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if ([db open])
    {
        value = value ? value : @"";
        NSString *sql = INSTER_DATA_SQL;
        BOOL result = [db executeUpdate:sql,value];
        NSLog(@"result===%d",result);
        [db close];
    }
}


+ (void)createSearchHistoryTable
{
    NSString *path = [FileManageTool findFilePathWithType:FilePathTypeCache fileName:HISTORY_TABLE_FILE];
    if (![FileManageTool isFileExistsAtPath:path])
    {
        NSLog(@"表不存在，创建表");
        FMDatabase *db =[FMDatabase databaseWithPath:path];
        if ([db open])
        {
            NSString *sql = @"CREATE TABLE 'SearchHistory'('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'keyWord' VARCHAR(100))";//sql语句
            BOOL success = [db executeUpdate:sql];
            if (!success)
            {
                NSLog(@"error when create table ");
            }
            else
            {
                NSLog(@"create table succeed");
            }
            [db close];
        }
        else
        {
            NSLog(@"database open error");
        }
    }
}


+ (void)deleteDataFromDatabase
{
    NSString *path = [FileManageTool findFilePathWithType:FilePathTypeCache fileName:HISTORY_TABLE_FILE];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if ([db open])
    {
        NSString *sql = DELETE_ALL_DATA;
        [db executeUpdate:sql];
    }
    [db close];

}

@end
