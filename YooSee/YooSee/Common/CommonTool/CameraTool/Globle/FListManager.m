//
//  FListManager.m
//  Yoosee
//
//  Created by guojunyi on 14-4-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "FListManager.h"
#import "Contact.h"
#import "ContactDAO.h"
#import "Constants.h"
#import "UDManager.h"
#import "P2PClient.h"
#import "ShakeManager.h"
#import "LocalDevice.h"
#import "AppDelegate.h"

@implementation FListManager{
    ;
}


-(void)dealloc{
//    [self.map release];
//    [self.localDevices release];
//    [super dealloc];
}

+ (id)sharedFList
{
    
    static FListManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            NSLog(@"Alloc FListManager");
            
            manager = [[FListManager alloc] init];
            [manager setIsReloadData:NO];
            ContactDAO *contactDAO = [[ContactDAO alloc] init];
            
            
            manager.map = [[NSMutableDictionary alloc] initWithCapacity:0];
            manager.localDevices = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableArray *array = [NSMutableArray arrayWithArray:[contactDAO findAll]];
            
            
            for(int i=0;i<[array count];i++){
                Contact *contact = [array objectAtIndex:i];
                if(contact.contactType==CONTACT_TYPE_PHONE){
                    continue;
                }
                [manager.map setObject:contact forKey:contact.contactId];
            }
            
            //[contactDAO release];
        }else{
            if([manager isReloadData]&&[UDManager isLogin]){
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                
                
                manager.map = [[NSMutableDictionary alloc] initWithCapacity:0];
                manager.localDevices = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSMutableArray *array = [NSMutableArray arrayWithArray:[contactDAO findAll]];
                for(int i=0;i<[array count];i++){
                    Contact *contact = [array objectAtIndex:i];
                    if(contact.contactType==CONTACT_TYPE_PHONE){
                        continue;
                    }
                    [manager.map setObject:contact forKey:contact.contactId];
                }
                
                //[contactDAO release];
                [manager setIsReloadData:NO];
            }
        }
    }
    return manager;
}

//获取本地已经添加的设备
-(NSArray*)getContacts{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for(NSString *key in self.map.allKeys){
        Contact *contact = [self.map objectForKey:key];
        [array addObject:contact];
    }
    
    NSComparator compareByState = ^(id obj1,id obj2){
        Contact *contact1 = (Contact*)obj1;
        Contact *contact2 = (Contact*)obj2;
        if(contact1.onLineState>contact2.onLineState){
            return (NSComparisonResult)NSOrderedAscending;
        }else if(contact1.onLineState<contact2.onLineState){
            return (NSComparisonResult)NSOrderedDescending;
        }else{
            return (NSComparisonResult)NSOrderedSame;
        }
        
    };
    
    return [array sortedArrayUsingComparator:compareByState];
}

//获取本地已经添加的设备的类型
-(NSInteger)getType:(NSString *)contactId{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    //[contactDAO release];
    if(contact!=nil){
        return contact.contactType;
    }else{
        return CONTACT_TYPE_UNKNOWN;
    }
}

//修改本地已经添加的设备的类型
-(void)setTypeWithId:(NSString*)contactId type:(NSInteger)contactType{
    Contact *contact = [self.map objectForKey:contactId];
    
    if(contact!=nil){
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        contact.contactType = contactType;
        
        [contactDAO updateContact:contact];//更新数据库
        //[contactDAO release];
    }
    
    //chenlei_changed
//    Contact *contact2 = [AppDelegate sharedDefault].contact;
//    if (contact2 != nil) {
//        contact2.contactType = contactType;
//    }
}

-(NSInteger)getMessageCount:(NSString *)contactId{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    //[contactDAO release];
    if(contact!=nil){
        return contact.messageCount;
    }else{
        return 0;
    }

}

-(void)setMessageCountWithId:(NSString *)contactId count:(NSInteger)count{
    Contact *contact = [self.map objectForKey:contactId];
    
    if(contact!=nil){
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        contact.messageCount = count;
        
        [contactDAO updateContact:contact];
        //[contactDAO release];
    }
}

//获取本地已经添加的设备的在线状态
-(NSInteger)getState:(NSString *)contactId{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    //[contactDAO release];
    if(contact!=nil){
        return contact.onLineState;
    }else{
        return STATE_OFFLINE;
    }
}

//修改本地已经添加的设备的在线状态
-(void)setStateWithId:(NSString *)contactId state:(NSInteger)onlineState{

    Contact *contact = [self.map objectForKey:contactId];
    if(contact!=nil){
        contact.onLineState = onlineState;
        //没有更新数据库代码？为什么没有更新数据库设备的状态，也能够更新设备列表里的设备状态呢
        //难道是强引用，引用了self.map里的设备，从而更新了self.map里设备的在线状态吗
        
        //isGettingOnLineState
        //sleep(1.0);
        contact.isGettingOnLineState = NO;
    }
}

-(void)setIsClickDefenceStateBtnWithId:(NSString*)contactId isClick:(BOOL)isClick{
    Contact *contact = [self.map objectForKey:contactId];
    if(contact!=nil){
        contact.isClickDefenceStateBtn = isClick;
    }
}

-(BOOL)getIsClickDefenceStateBtn:(NSString*)contactId{
    Contact *contact = [self.map objectForKey:contactId];
    if(contact!=nil){
        return contact.isClickDefenceStateBtn;
    }else{
        return NO;
    }
}

-(void)setDefenceStateWithId:(NSString *)contactId type:(NSInteger)defenceState{
    Contact *contact = [self.map objectForKey:contactId];
    if(contact)
    {
        contact.defenceState = defenceState;
    }
//    //chenlei_changed
//    //重新调整监控画面
//    Contact *newContact = [YooSeeApplication shareApplication].contact;
//    if (newContact)
//    {
//        newContact.defenceState = defenceState;
//    }
//    [YooSeeApplication shareApplication].contact = newContact;
//    //重新调整监控画面
}

-(void)insertContact:(Contact *)contact{
    
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    [contactDAO insert:contact];
    //[contactDAO release];
    
    [self.map setObject:contact forKey:contact.contactId];
}

-(void)deleteContact:(Contact *)contact{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    [contactDAO delete:contact];
    //[contactDAO release];
    [self.map removeObjectForKey:contact.contactId];
}

-(void)update:(Contact *)contact{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    [contactDAO updateContact:contact];
    //[contactDAO release];
    
    [self.map setObject:contact forKey:contact.contactId];//updatepwd
    Contact *oldContact = [self.map objectForKey:contact.contactId];
    oldContact = contact;
}

-(void)getDefenceStates{
    NSArray *array = [self getContacts];
    for(Contact *contact in array){
        if(contact.contactType==CONTACT_TYPE_NPC||
           contact.contactType==CONTACT_TYPE_IPC||
           contact.contactType==CONTACT_TYPE_DOORBELL){
            [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
        }
    }
}

@end
