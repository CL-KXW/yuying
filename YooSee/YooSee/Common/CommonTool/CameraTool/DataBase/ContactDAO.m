//
//  ContactDAO.m
//  Yoosee
//
//  Created by guojunyi on 14-4-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ContactDAO.h"
#import "Contact.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "FMDatabase.h"
#import "Constants.h"
@implementation ContactDAO

-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;
//                    NSString *dropSQL = @"DROP TABLE Contact";
//                    if(sqlite3_exec(self.db, [dropSQL UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
//                        NSLog(@"Table Contact failed to delete.");
//                        sqlite3_free(errMsg);
//                    }
            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSLog(@"Table Contact failed to create.");
                sqlite3_free(errMsg);
            }
            [self closeDB];
        }
        
        int version = [ContactDAO getDBVersion];
        if(version<CONTACT_DB_VERSION){
            [self updateDB:version];
        }
    }
    return self;
}

+(NSInteger)getDBVersion{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    return [manager integerForKey:kContactDBVersion];
    
}

+(void)setDBVersion:(NSInteger)version{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    [manager setInteger:version forKey:kContactDBVersion];
    [manager synchronize];
}

-(void)updateDB:(NSInteger)version{
    if(version==0){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"FM.db"];
        FMDatabase *tmp = [FMDatabase databaseWithPath:dbPath];
        if (!tmp || ![tmp open]) {
            NSLog(@"db not exist");
            [ContactDAO setDBVersion:CONTACT_DB_VERSION];
            return;
        }else{
            NSString * sql = @"SELECT * FROM contact";
            FMResultSet *rs = [tmp executeQuery:sql];
            while ([rs next]) {
                
                
                NSString *contactName = [rs stringForColumn:@"cName"];
                NSString *contactId = [rs stringForColumn:@"accountNPC"];
                NSString *contactPassword = [rs stringForColumn:@"pwdNPC"];
                NSString *activeUser = [NSString stringWithFormat:@"0%d", [rs intForColumn:@"currentUser"]&0x7fffffff];
                NSLog(@"%@:%@:%@:%@",contactName,contactId,contactPassword,activeUser);
                
                char *errMsg;
                BOOL result = NO;
                if([self openDB]){
                    NSString *SQL = [NSString stringWithFormat:@"INSERT INTO Contact(activeUser,contactId,contactName,contactPassword,contactType,messageCount) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%i\",\"%i\")",activeUser,contactId,contactName,contactPassword,CONTACT_TYPE_UNKNOWN,0];
                    
                    if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
                        result = YES;
                    }else{
                        NSLog(@"Failed to insert Contact.");
                        sqlite3_free(errMsg);
                        result = NO;
                    }
                    
                    [self closeDB];
                    
                }
            }
            [ContactDAO setDBVersion:CONTACT_DB_VERSION];

        }
    }
}

-(NSString*)dbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DB_NAME];
    return path;
}

-(NSString *)getCreateTableString{
    return @"CREATE TABLE IF NOT EXISTS Contact(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,contactId Text,contactName Text,contactPassword Text,contactType integer,messageCount integer)";
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

-(BOOL)insert:(Contact *)contact{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    char *errMsg;
    BOOL result = NO;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"INSERT INTO Contact(activeUser,contactId,contactName,contactPassword,contactType,messageCount) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%i\",\"%i\")",loginResult.contactId,contact.contactId,contact.contactName,contact.contactPassword,contact.contactType,contact.messageCount];
        
        if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
            result = YES;
        }else{
            NSLog(@"Failed to insert Contact.");
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
        NSString *SQL = [NSString stringWithFormat:@"SELECT ID,CONTACTID,CONTACTNAME,CONTACTPASSWORD,CONTACTTYPE,MESSAGECOUNT FROM Contact WHERE ACTIVEUSER = \"%@\"",loginResult.contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                Contact *data = [[Contact alloc] init];
                data.row = sqlite3_column_int(statement, 0);
                data.contactId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                data.contactName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                data.contactPassword = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                data.contactType = sqlite3_column_int(statement, 4);
                data.messageCount = sqlite3_column_int(statement, 5);
                [array addObject:data];
                 NSLog(@"%@",data.contactId);
                //[data release];
               
            }
        }else{
            NSLog(@"Failed to find Contact:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }

    return array;
}

-(BOOL)delete:(Contact *)contact{
    if(![UDManager isLogin]){
        return NO;
    }
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Contact WHERE ACTIVEUSER = \"%@\" AND CONTACTID = \"%@\"",loginResult.contactId,contact.contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to delete Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}

- (Contact*)isContact:(NSString *)contactId
{
    Contact *contact = nil;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if(![UDManager isLogin])
    {
        return nil;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"SELECT ID,CONTACTID,CONTACTNAME,CONTACTPASSWORD,CONTACTTYPE,MESSAGECOUNT FROM Contact WHERE ACTIVEUSER = \"%@\" AND CONTACTID = \"%@\"",loginResult.contactId,contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                Contact *data = [[Contact alloc] init];
                data.row = sqlite3_column_int(statement, 0);
                data.contactId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                data.contactName = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                data.contactPassword = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                data.contactType = sqlite3_column_int(statement, 4);
                data.messageCount = sqlite3_column_int(statement, 5);
                [array addObject:data];
                //[data release];
            }
        }else{
            NSLog(@"Failed to find Contact:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    if([array count]>0){
        contact = [array objectAtIndex:0];
    }
    return contact;
}

-(BOOL)updateContact:(Contact *)contact{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"UPDATE Contact SET CONTACTID = \"%@\", CONTACTNAME = \"%@\",CONTACTPASSWORD = \"%@\",CONTACTTYPE = \"%i\",MESSAGECOUNT = \"%i\" WHERE ACTIVEUSER = \"%@\" AND CONTACTID = \"%@\"",contact.contactId,contact.contactName,contact.contactPassword,contact.contactType,contact.messageCount,loginResult.contactId,contact.contactId];
        NSLog(@"%@",SQL);
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to update Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to update Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}
@end
