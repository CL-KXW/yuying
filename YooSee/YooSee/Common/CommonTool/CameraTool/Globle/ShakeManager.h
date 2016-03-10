//
//  ShakeManager.h
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#define ap_address      "192.168.1.1"
#define ap_p2p_id       @"1"
#define ap_p2p_password @"0"

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@protocol ShakeManagerDelegate <NSObject>
-(void)onReceiveLocalDevice:(NSString*)contactId type:(NSInteger)type flag:(NSInteger)flag address:(NSString*)address;
-(void)onSearchEnd;
@end


@interface ShakeManager : NSObject
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) NSInteger searchTime;

@property (assign) id<ShakeManagerDelegate> delegate;
+ (id)sharedDefault;
-(BOOL)search;
-(int)ApModeGetID;
-(BOOL)ApModeSetWifiPassword:(NSString*)password;
@end
