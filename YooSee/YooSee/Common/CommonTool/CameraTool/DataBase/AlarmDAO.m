//
//  AlarmDAO.m
//  Yoosee
//
//  Created by Jie on 14-10-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AlarmDAO.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Constants.h"
#import "sqlite3.h"
#import "Alarm.h"

@implementation AlarmDAO
-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;
            
            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSLog(@"Table Alarm failed to create.");
                sqlite3_free(errMsg);
            }
            [self closeDB];
        }
    }
    return self;
}

-(NSString*)dbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DB_NAME];
    return path;
}

-(NSString *)getCreateTableString{
    return @"CREATE TABLE IF NOT EXISTS Alarm(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,deviceId Text,alarmTime Text,alarmType integer,alarmGroup integer,alarmItem integer)";
}

-(BOOL)openDB{
    BOOL result = NO;
    if(sqlite3_open([[self dbPath] UTF8String], &_db)==SQLITE_OK){
        result = YES;
    }else{
        result = NO;
        NSLog(@"Failed to open database");
    }
    
    return result;
};

-(BOOL)closeDB{
    if(sqlite3_close(self.db)==SQLITE_OK){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)insert:(Alarm*)alarm{
    if(![UDManager isLogin]){
        return NO;
    }
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    char *errMsg;
    BOOL result = NO;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"INSERT INTO Alarm(activeUser,deviceId,alarmTime,alarmType,alarmGroup,alarmItem) VALUES(\"%@\",\"%@\",\"%@\",\"%i\",\"%i\",\"%i\")",loginResult.contactId,alarm.deviceId,alarm.alarmTime,alarm.alarmType,alarm.alarmGroup,alarm.alarmItem];
        
        if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
            result = YES;
        }else{
            NSLog(@"Failed to insert Alarm.");
            sqlite3_free(errMsg);
            result = NO;
        }
        
        [self closeDB];
        
    }
    return result;
}

-(NSMutableArray*)findAll{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if(![UDManager isLogin]){
        return array;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"SELECT ID,DEVICEID,ALARMTIME,ALARMTYPE,ALARMGROUP,ALARMITEM FROM Alarm WHERE ACTIVEUSER = \"%@\"",loginResult.contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                Alarm *data = [[Alarm alloc] init];
                data.row = sqlite3_column_int(statement, 0);
                data.deviceId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                data.alarmTime = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                data.alarmType = sqlite3_column_int(statement, 3);
                data.alarmGroup = sqlite3_column_int(statement, 4);
                data.alarmItem = sqlite3_column_int(statement, 5);
                [array addObject:data];
                //[data release];
            }
        }else{
            NSLog(@"Failed to find Message:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    NSComparator compareByTime = ^(id obj1,id obj2){
        Alarm *alarm1 = (Alarm*)obj1;
        Alarm *alarm2 = (Alarm*)obj2;
        if(alarm1.alarmTime.intValue>alarm2.alarmTime.intValue){
            return (NSComparisonResult)NSOrderedAscending;
        }else{
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    return (NSMutableArray*)[array sortedArrayUsingComparator:compareByTime];
}

-(BOOL)delete:(Alarm*)alarm{
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Alarm WHERE ID = \"%i\"",alarm.row];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to find Alarm:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Alarm:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}

-(BOOL)clear{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Alarm WHERE ACTIVEUSER = \"%@\"",loginResult.contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to find Alarm:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Alarm:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
    
}



@end
