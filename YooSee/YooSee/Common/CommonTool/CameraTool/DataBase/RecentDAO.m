//
//  NoteDAO.m
//  Persistence
//
//  Created by guojunyi on 14-3-18.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "RecentDAO.h"
#import "Recent.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Constants.h"
@implementation RecentDAO

-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;
//            NSString *dropSQL = @"DROP TABLE Recent";
//            if(sqlite3_exec(self.db, [dropSQL UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
//                NSLog(@"Table Note failed to create.");
//                sqlite3_free(errMsg);
//            }
            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSLog(@"Table Note failed to create.");
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
    return @"CREATE TABLE IF NOT EXISTS Recent(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,contactId Text,callType integer,callState integer,time Text)";
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

-(BOOL)insert:(Recent *)recent{
    if(![UDManager isLogin]){
        return NO;
    }
    LoginResult *loginResult = [UDManager getLoginInfo];

    char *errMsg;
    BOOL result = NO;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"INSERT INTO Recent(activeUser,contactId,callType,callState,time) VALUES(\"%@\",\"%@\",\"%i\",\"%i\",\"%@\")",loginResult.contactId,recent.contactId,recent.callType,recent.callState,recent.time];
        
        if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
            result = YES;
        }else{
            NSLog(@"Failed to insert Note.");
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
        NSString *SQL = [NSString stringWithFormat:@"SELECT ID,CONTACTID,CALLTYPE,CALLSTATE,TIME FROM Recent WHERE ACTIVEUSER = \"%@\"",loginResult.contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                Recent *data = [[Recent alloc] init];
                data.row = sqlite3_column_int(statement, 0);
                data.contactId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                data.callType = sqlite3_column_int(statement, 2);
                data.callState = sqlite3_column_int(statement, 3);
                data.time = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
                [array addObject:data];
                //[data release];
            }
        }else{
            NSLog(@"Failed to find Note:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    NSComparator compareByTime = ^(id obj1,id obj2){
        Recent *recent1 = (Recent*)obj1;
        Recent *recent2 = (Recent*)obj2;
        if(recent1.time.intValue>recent2.time.intValue){
            return (NSComparisonResult)NSOrderedAscending;
        }else{
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    return (NSMutableArray*)[array sortedArrayUsingComparator:compareByTime];
}

-(BOOL)delete:(Recent *)recent{
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Recent WHERE ID = \"%i\"",recent.row];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to find Note:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Note:%s",sqlite3_errmsg(self.db));
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
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Recent WHERE ACTIVEUSER = \"%@\"",loginResult.contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to find Note:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Note:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}



@end
