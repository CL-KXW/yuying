//
//  FListManager.h
//  Yoosee
//
//  Created by guojunyi on 14-4-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShakeManager.h"
@class  Contact;
@interface FListManager : NSObject<ShakeManagerDelegate>
@property (retain, nonatomic) NSMutableDictionary *map;
@property (retain, nonatomic) NSMutableDictionary *localDevices;

@property (assign) BOOL isReloadData;
+ (id)sharedFList;


-(NSArray*)getContacts;
-(NSInteger)getType:(NSString*)contactId;
-(void)setTypeWithId:(NSString*)contactId type:(NSInteger)contactType;
-(void)setDefenceStateWithId:(NSString*)contactId type:(NSInteger)defenceState;
-(NSInteger)getState:(NSString*)contactId;
-(void)setStateWithId:(NSString*)contactId state:(NSInteger)onlineState;
-(void)insertContact:(Contact*)contact;
-(void)deleteContact:(Contact*)contact;
-(void)update:(Contact*)contact;

-(NSInteger)getMessageCount:(NSString*)contactId;
-(void)setMessageCountWithId:(NSString*)contactId count:(NSInteger)count;

-(void)getDefenceStates;

-(void)setIsClickDefenceStateBtnWithId:(NSString*)contactId isClick:(BOOL)isClick;
-(BOOL)getIsClickDefenceStateBtn:(NSString*)contactId;
@end
