//
//  Contact.h
//  Yoosee
//
//  Created by guojunyi on 14-4-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define STATE_ONLINE 1
#define STATE_OFFLINE 0 

#define CONTACT_TYPE_UNKNOWN 0
#define CONTACT_TYPE_NPC 2
#define CONTACT_TYPE_PHONE 3
#define CONTACT_TYPE_DOORBELL 5
#define CONTACT_TYPE_IPC 7

#define DEFENCE_STATE_OFF 0
#define DEFENCE_STATE_ON 1
#define DEFENCE_STATE_LOADING 2
#define DEFENCE_STATE_WARNING_PWD 3
#define DEFENCE_STATE_WARNING_NET 4
#define DEFENCE_STATE_NO_PERMISSION 5
@interface Contact : NSObject
@property (nonatomic) int row;
@property (strong, nonatomic) NSString *contactId;
@property (strong, nonatomic) NSString *contactName;
@property (strong, nonatomic) NSString *contactPassword;
@property (nonatomic) NSInteger contactType;

@property (nonatomic) NSInteger onLineState;
@property (nonatomic) NSInteger messageCount;

@property (nonatomic) NSInteger defenceState;

@property (nonatomic) BOOL isClickDefenceStateBtn;

@property (nonatomic) BOOL isGettingOnLineState;//isGettingOnLineState

@property (nonatomic) BOOL isNewVersionDevice;//设备检查更新
@property (strong, nonatomic) NSString *deviceCurVersion;//设备检查更新
@property (strong, nonatomic) NSString *deviceUpgVersion;//设备检查更新
@property (nonatomic) NSInteger result_sd_server;//设备检查更新

@end
