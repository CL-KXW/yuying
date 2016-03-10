//
//  UDPManager.h
//  2cu
//
//  Created by wutong on 15-1-13.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalDevice.h"


@protocol UDPGetWifiListdelegate <NSObject>
@optional
- (void)receiveWifiList:(NSDictionary *)dictionary;
@end

@protocol UDPSetWifidelegate <NSObject>
@optional
- (void)setWifiSuccess;
@end

typedef  int32_t  SWL_socket_t;
#define  SWL_INVALID_SOCKET   -1
#define MAX_COMMAND_SIZE    1024

@interface UDPManager : NSObject
{
    SWL_socket_t _socketSender;
    SWL_socket_t _socketRecevier;
    int _localPort;
    BOOL _isReceving;
}

//局域网搜索
@property (retain, nonatomic) NSMutableDictionary *LanlDevices;

+ (id)sharedDefault;
//局域网搜索
- (void)ScanLanDevice;
- (NSArray*)getLanDevices;
-(void)clearData;

//更新密码标记
-(void)setContactWithID:(LocalDevice*)localDevice contactID:(NSString*)contactID;

@end
