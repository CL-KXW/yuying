//
//  GlobalThread.m
//  Yoosee
//
//  Created by guojunyi on 14-4-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "GlobalThread.h"
#import "Constants.h"
#import "FListManager.h"
#import "Contact.h"
#import "P2PClient.h"
#import "ShakeManager.h"
@implementation GlobalThread
static int g_initCount;
+ (id)sharedThread:(BOOL)isRelease
{
    
    static GlobalThread *manager = nil;
    
    @synchronized([self class]){
        if(isRelease){
            NSLog(@"Release GlobalThread");
            manager = nil;
        }else{
            if(manager==nil){
                NSLog(@"Alloc GlobalThread");
                g_initCount = 3;
                manager = [[GlobalThread alloc] init];
                manager.isRun = NO;
            }
        }
        
    }
    return manager;
}

-(void)start{
    if(!self.isRun){
        self.isRun = !self.isRun;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            while(g_initCount>0){
                g_initCount --;
                NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
                NSArray *contacts = [[FListManager sharedFList] getContacts];
                for(int i=0;i<[contacts count];i++){
                    
                    Contact *contact = [contacts objectAtIndex:i];
                    [contactIds addObject:contact.contactId];
                    
                    //进入首页时，获取设备列表里的设备的可更新状态
                    //设备检查更新
                    [[P2PClient sharedClient] checkDeviceUpdateWithId:contact.contactId password:contact.contactPassword];
                }
                [[P2PClient sharedClient] getContactsStates:contactIds];
                sleep(1.0);
            }
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while(self.isRun){
                    if(!self.isPause){
                        NSLog(@"Thread getContactsStatus");
                        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
                        NSArray *contacts = [[FListManager sharedFList] getContacts];
                        for(int i=0;i<[contacts count];i++){
                            
                            Contact *contact = [contacts objectAtIndex:i];
                            [contactIds addObject:contact.contactId];
                        }
                        [[P2PClient sharedClient] getContactsStates:contactIds];
                        [[FListManager sharedFList] getDefenceStates];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocalDevices" object:nil];
                        usleep(60*1000000);
                    }else{
                        sleep(1.0);
                    }
                    
                }
                
            });
            
            
        });
        
        
        
    }
}

-(void)kill{
    self.isRun = NO;
    [GlobalThread sharedThread:YES];
}
@end
