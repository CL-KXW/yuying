//
//  RecommendInfoDAO.m
//  Yoosee
//
//  Created by gwelltime on 15-1-31.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "RecommendInfoDAO.h"
#import "Constants.h"

@implementation RecommendInfoDAO

-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;
            
            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSLog(@"Table RecommendInfo failed to create.");
                sqlite3_free(errMsg);
            }
            [self closeDB];
        }
    }
    return self;
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

-(NSString*)dbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DB_NAME];
    return path;
}

-(NSString *)getCreateTableString{
    return @"create table if not exists RecommendInfoTable (ID integer primary key autoincrement,Title text,Date text,ImageURL text,ImageLinkURL text,Content text,IsRead boolean)";
}

-(BOOL)closeDB{
    if(sqlite3_close(self.db)==SQLITE_OK){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)insert:(RecommendInfo *)model{
    
    char *errMsg;
    BOOL result = NO;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"insert into RecommendInfoTable(ID,Title,Date,ImageURL,ImageLinkURL,Content,IsRead) VALUES(\"%i\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%i\")",model.messageID,model.titleString,model.timeString,model.imageURLString,model.imageLinkURLString,model.contentString,model.isRead];
        
        if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
            result = YES;
        }else{
            NSLog(@"Failed to insert RecommendInfo.");
            sqlite3_free(errMsg);
            result = NO;
        }
        
        [self closeDB];
        
    }
    return result;
}

-(NSArray*)findAll{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    
    sqlite3_stmt *statement;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"select * from RecommendInfoTable"];
       
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            
            while(sqlite3_step(statement)==SQLITE_ROW){
                RecommendInfo * m = [[RecommendInfo alloc] init];
               
                m.messageID  = sqlite3_column_int(statement, 0);
                m.titleString = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                m.timeString = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                m.imageURLString = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                m.imageLinkURLString = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
                m.contentString = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
                m.isRead = sqlite3_column_int(statement, 6);
                
                
                [array addObject:m];
                //[m release];
            }
        }else{
            NSLog(@"Failed to find RecommendInfo:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    NSComparator compareByTime = ^(id obj1,id obj2){
        RecommendInfo *recommendInfo1 = (RecommendInfo*)obj1;
        RecommendInfo *recommendInfo2 = (RecommendInfo*)obj2;
        if(recommendInfo1.timeString.intValue>recommendInfo2.timeString.intValue){
            return (NSComparisonResult)NSOrderedAscending;
        }else{
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    return [array sortedArrayUsingComparator:compareByTime];
}

-(BOOL)updateDBWithKey:(int)key modify:(RecommendInfo *)model{
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"update RecommendInfoTable set Title = \"%@\", Date = \"%@\" , ImageURL = \"%@\" , ImageLinkURL = \"%@\" , Content = \"%@\" , IsRead = \"%i\" where ID = \"%i\"",model.titleString,model.timeString,model.imageURLString,model.imageLinkURLString,model.contentString,model.isRead,key];
        
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to update RecommendInfo:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to update RecommendInfo:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}

@end
