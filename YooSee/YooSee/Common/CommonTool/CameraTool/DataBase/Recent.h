//
//  Note.h
//  Persistence
//
//  Created by guojunyi on 14-3-18.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RECENT_CALLSTATE_CALLOUT_ACCEPT 0
#define RECENT_CALLSTATE_CALLOUT_REJECT 1
#define RECENT_CALLSTATE_CALLIN_ACCEPT 2
#define RECENT_CALLSTATE_CALLIN_REJECT 4

@interface Recent : NSObject
@property (nonatomic) int row;
@property (strong, nonatomic) NSString *contactId;
@property (nonatomic) int callType;
@property (nonatomic) int callState;
@property (strong, nonatomic) NSString *time;

@end
