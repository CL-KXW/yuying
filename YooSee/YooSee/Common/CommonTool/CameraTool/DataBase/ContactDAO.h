//
//  ContactDAO.h
//  Yoosee
//
//  Created by guojunyi on 14-4-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@class Contact;
#define DB_NAME @"Yoosee.sqlite"
#define kContactDBVersion @"kContactDBVersion"
#define CONTACT_DB_VERSION 1
@interface ContactDAO : NSObject
@property (nonatomic) sqlite3 *db;

-(BOOL)insert:(Contact*)contact;
-(NSMutableArray*)findAll;
-(BOOL)delete:(Contact*)recent;
-(BOOL)updateContact:(Contact*)contact;
-(Contact*)isContact:(NSString*)contactId;
@end
