//
//  UDPManager.m
//  2cu
//
//  Created by wutong on 15-1-13.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//


#import "UDPManager.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "LocalDevice.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "mesg.h"

@implementation UDPManager

-(void)dealloc
{
    //[self.LanlDevices release];
    //[super dealloc];
}

+ (id)sharedDefault
{
    static UDPManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            manager = [[UDPManager alloc] init];
            manager->_socketSender = SWL_INVALID_SOCKET;
            manager->_socketRecevier = SWL_INVALID_SOCKET;
            //_socketRecevier绑定的端口
            manager->_localPort = 8899;
             //存储数据
            NSMutableDictionary* LanlDevices = [[NSMutableDictionary alloc] initWithCapacity:0];
            manager.LanlDevices = LanlDevices;
            //[LanlDevices release];
        }
    }
    return manager;
}

- (void)ScanLanDevice
{
    //循环发送命令
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendSearchCmdLoop];
    });
    
    //循环接收数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recviveDataLoop];
    });

    //循环删除超时的设备
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkTimeoutLoop];
    });
}

-(void)CreateSender
{
    SWL_socket_t sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (SWL_INVALID_SOCKET == sock)
    {
        return;
    }
    
    int bOpt = 1;
    int ret = setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (const void*)&bOpt, sizeof(bOpt));
    if (ret != -1) {
        _socketSender = sock;
    }
}

-(void)CreateRevicer
{
    SWL_socket_t sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (SWL_INVALID_SOCKET == sock)
    {
        return;
    }
    
    int ret;
    int nCount = 0;
    //写此while循环的原因：如果端口8899被占用，则绑定会失败，于是端口号+1000再绑定
    while (nCount<20) {
        struct sockaddr_in addr;
        memset((char*)&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        addr.sin_port = htons(_localPort);
        
        ret = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
        if (ret != -1) {
            break;
        }
        else
        {
            _localPort += 1000;
            usleep(10000);
        }
        nCount++;
    }
    if (ret != -1) {
        _socketRecevier = sock;
    }
}

-(void)sendSearchCmdLoop
{
    while (1)
    {
        if (_socketSender == SWL_INVALID_SOCKET) {
            [self CreateSender];
        }
        
        struct sockaddr_in addr;
        memset((char*)&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_BROADCAST);
        addr.sin_port = htons(8899);
        
        char sendBuf = 1;
        const char* inBuffer = &sendBuf;
        long inLength = sizeof(char);
        int val = sendto(_socketSender, inBuffer, inLength, 0, (struct sockaddr*)&addr, sizeof(addr));
        if (val == -1) {
        }
        usleep(3*1000000);
    }
}

-(void)recviveDataLoop
{
    struct sockaddr_in addr_cli;
    int addr_cli_len = sizeof(addr_cli);
    
    char receiveBuffer[MAX_COMMAND_SIZE] = {0};
    long bytes = 0;
    _isReceving = TRUE;
    //_isReceving
    while (_isReceving) {
        if (_socketRecevier == SWL_INVALID_SOCKET)
        {
            [self CreateRevicer];
            if (_socketRecevier == SWL_INVALID_SOCKET) {
                continue;
            }
        }
        bytes = recvfrom(_socketRecevier, (char*)receiveBuffer, MAX_COMMAND_SIZE, 0, (struct sockaddr *)&addr_cli, (socklen_t *)&addr_cli_len);
        if (bytes == -1 || bytes == 0)
        {
            _isReceving = FALSE;
        }
        else if (bytes == 1)
        {
            usleep(1*100000);
        }
        else
        {
            int orderid = *(int*)(receiveBuffer);
            if(orderid == 2){
                //局域网结果
                char* szIP = inet_ntoa(addr_cli.sin_addr);
                int isSupportRtsp = *(int*)(&receiveBuffer[12]);
                isSupportRtsp = ((isSupportRtsp>>2)&1);
                
                int contactId = *(int*)(&receiveBuffer[16]);
                int type = *(int*)(&receiveBuffer[20]);
                int flag = *(int*)(&receiveBuffer[24]);
                if (type != 7 && type != 2 && type != 5)     //只搜索ipc和npc和门铃
                {
                    continue;
                }
                
                NSDate* date = [[NSDate alloc]init];
                double interval = [date timeIntervalSince1970];
                //[date release];
                
                LocalDevice *localDevice = [[LocalDevice alloc] init];
                localDevice.contactId = [NSString stringWithFormat:@"%i",contactId];
                localDevice.contactType = type;
                localDevice.flag = flag;
                localDevice.isSupportRtsp = isSupportRtsp;
                localDevice.address = [NSString stringWithFormat:@"%s", szIP];
                localDevice.lanTimeInterval = interval;
                [self setContactWithID:localDevice contactID:[NSString stringWithFormat:@"%i",contactId]];
                //[localDevice release];
            }
            
        }
    }
}

-(void)setContactWithID:(LocalDevice*)localDevice contactID:(NSString*)contactID
{
    @synchronized(self)
    {
        [self.LanlDevices setObject:localDevice forKey:contactID];
    }
}

-(void)checkTimeoutLoop
{
    while (1)
    {
        @synchronized(self)
        {
            NSDate* date = [[NSDate alloc]init];
            double interval = [date timeIntervalSince1970];
            //[date release];
            
            for(NSString *key in self.LanlDevices.allKeys)
            {
                LocalDevice *localDevice = [self.LanlDevices objectForKey:key];
                if ((interval - localDevice.lanTimeInterval)>8.0)
                {
                    [self.LanlDevices removeObjectForKey:key];
                }
            }
        }
        usleep(3*1000000);
    }
}

-(NSArray*)getLanDevices
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    @synchronized(self)
    {
        for(NSString *key in self.LanlDevices.allKeys)
        {
            LocalDevice *localDevice = [self.LanlDevices objectForKey:key];
            [array addObject:localDevice];
        }
    }
    
    return array;
}

-(void)clearData
{
    @synchronized(self)
    {
        [self.LanlDevices removeAllObjects];
    }
}

@end
