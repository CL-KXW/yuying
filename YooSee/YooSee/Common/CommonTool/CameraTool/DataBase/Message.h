//
//  Message.h
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MESSAGE_STATE_NO_READ 0
#define MESSAGE_STATE_READED 1
#define MESSAGE_STATE_SENDING 2
#define MESSAGE_STATE_SEND_FAILURE 3
@interface Message : NSObject
@property (nonatomic) int row;
@property (strong, nonatomic) NSString *fromId;
@property (strong, nonatomic) NSString *toId;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *time;
@property (nonatomic) int state;
@property (nonatomic) int flag;

@end
