//
//  MessageDAO.m
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "MessageDAO.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Constants.h"
#import "sqlite3.h"
#import "Message.h"
@implementation MessageDAO
-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;

            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSLog(@"Table Message failed to create.");
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
    return @"CREATE TABLE IF NOT EXISTS Message(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,fromId Text,toId Text,message Text,time Text,state integer,flag integer)";
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

-(BOOL)insert:(Message*)message{
    if(![UDManager isLogin]){
        return NO;
    }
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    char *errMsg;
    BOOL result = NO;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"INSERT INTO Message(activeUser,fromId,toId,message,time,state,flag) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%i\",\"%i\")",loginResult.contactId,message.fromId,message.toId,message.message,message.time,message.state,message.flag];
        
        if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
            result = YES;
        }else{
            NSLog(@"Failed to insert Message.");
            sqlite3_free(errMsg);
            result = NO;
        }
        
        [self closeDB];
        
    }
    return result;
}

-(NSMutableArray*)findAllWithId:(NSString *)contactId{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if(![UDManager isLogin]){
        return array;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"SELECT ID,FROMID,TOID,MESSAGE,TIME,STATE,FLAG FROM Message WHERE ACTIVEUSER = \"%@\" AND ((FROMID = \"%@\" AND TOID = \"%@\") OR (FROMID = \"%@\" AND TOID = \"%@\"))",loginResult.contactId,contactId,loginResult.contactId,loginResult.contactId,contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                Message *data = [[Message alloc] init];
                data.row = sqlite3_column_int(statement, 0);
                data.fromId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                data.toId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                data.message = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                data.time = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
                data.state = sqlite3_column_int(statement, 5);
                data.flag = sqlite3_column_int(statement, 6);
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
        Message *message1 = (Message*)obj1;
        Message *message2 = (Message*)obj2;
        if(message1.time.intValue<message2.time.intValue){
            return (NSComparisonResult)NSOrderedAscending;
        }else{
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    return [array sortedArrayUsingComparator:compareByTime];
}

-(BOOL)delete:(Message*)message{
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Message WHERE ID = \"%i\"",message.row];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to find Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}

-(BOOL)clearWithId:(NSString *)contactId{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Message WHERE ACTIVEUSER = \"%@\" AND (FROMID = \"%@\" OR TOID = \"%@\")",loginResult.contactId,contactId,contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to find Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;

}

-(BOOL)updateMessageStateWithFlag:(NSInteger)flag state:(NSInteger)state{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"UPDATE Message SET STATE = \"%d\", FLAG = \"%d\" WHERE ACTIVEUSER = \"%@\" AND FLAG = \"%d\"",state,-1,loginResult.contactId,flag];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to update Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to update Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}

-(BOOL)update:(Message *)message{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"UPDATE Message SET FROMID = \"%@\", TOID = \"%@\",MESSAGE = \"%@\",TIME = \"%@\",STATE = \"%i\",FLAG = \"%i\" WHERE ACTIVEUSER = \"%@\" AND ID = \"%i\"",message.fromId,message.toId,message.message,message.time,message.state,message.flag,loginResult.contactId,message.row];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to update Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to update Message:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}
@end
