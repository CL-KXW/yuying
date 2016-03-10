//
//  ShakeManager.m
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ShakeManager.h"
#import "P2PClient.h"
#import "mesg.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Utils.h"

#include <sys/types.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <errno.h>
#include <pthread.h>

@implementation ShakeManager

+ (id)sharedDefault
{
    
    static ShakeManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            NSLog(@"Alloc ShakeManager");
            manager = [[ShakeManager alloc] init];
            manager.isSearching = NO;
            manager.searchTime = 5;
        }
    }
    return manager;
}

-(BOOL)search{
    if(self.isSearching){
        return NO;
    }
    
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    if (![socket bindToPort:8899 error:&error])
    {
        //NSLog(@"Error binding: %@", [error localizedDescription]);
        return NO;
    }
    if (![socket beginReceiving:&error])
    {
        //NSLog(@"Error receiving: %@", [error localizedDescription]);
        return NO;
    }
    
    if (![socket enableBroadcast:YES error:&error])
    {
        //NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
        return NO;
    }
    
    self.socket = socket;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int times = self.searchTime;
        self.isSearching = YES;
        while(times>0){
            //chenlei_changed
            //if ([[AppDelegate sharedDefault] isGoBack])
            //{
            //    break;
            //}
            [self sendUDPBroadcast];
            usleep(1000000);
            times --;
        }
        if(self.socket){
            [self.socket close];
            self.socket = nil;
        }
        self.isSearching = NO;
        if(self.delegate){
            [self.delegate onSearchEnd];
        }
    });
    
    
    return YES;
}

- (void)sendUDPBroadcast
{
    
    NSString *host = @"255.255.255.255";
    int port = 8899;
    
    sMesgShakeType message;
    message.dwCmd = LAN_TRANS_SHAKE_GET;
    message.dwStructSize = 28;
    message.dwStrCon = 0;
    
    Byte sendBuffer[1024];
    memset(sendBuffer, 0, 1024);
    sendBuffer[0] = 1;
    
    NSData *myData = [NSData dataWithBytes:sendBuffer length:1024];
    [self.socket sendData:myData toHost:host port:port withTimeout:-1 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
//    NSLog(@"did send");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"error %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    
    
    NSString *host = nil;
    uint16_t port = 0;
    
    
    
    if (data) {
        Byte receiveBuffer[1024];
        [data getBytes:receiveBuffer length:1024];
        
        if(receiveBuffer[0]==2){
            
            [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
            NSLog(@"%@",host);
            int contactId = *(int*)(&receiveBuffer[16]);
            int type = *(int*)(&receiveBuffer[20]);
            int flag = *(int*)(&receiveBuffer[24]);
            NSLog(@"%i:%i:%i",contactId,type,flag);
            if(self.delegate){
                
                [self.delegate onReceiveLocalDevice:[NSString stringWithFormat:@"%i",contactId] type:type flag:flag address:host];
            }
        }
        
        
    }
    
}

-(int32_t)createTcpSocket
{
    int32_t sock = -1;
    while (1)
    {
        //没有连接wifi，肯定不是ap模式
        NSString* ssid = [Utils currentWifiSSID];
        if (ssid == nil) {
            NSLog(@"get ap mode info failed, no wifi");
            break;
        }
        
        //create sock
        sock = socket(AF_INET, SOCK_STREAM, 0);
        if (-1 == sock)
        {
            NSLog(@"get ap mode info failed, create sock error");
            break;
        }
        
        //设置sock为非阻塞模式
        int iFlag = fcntl(sock, F_GETFL);
        fcntl(sock, F_SETFL, iFlag | O_NONBLOCK);
        
        //socket地址
        struct sockaddr_in addrDst;
        memset((char*)&addrDst, 0, sizeof(addrDst));
        addrDst.sin_family = AF_INET;
        addrDst.sin_addr.s_addr = inet_addr(ap_address);
        addrDst.sin_port = htons(10086);
        
        int ret = connect(sock, (struct sockaddr*)&addrDst, sizeof(addrDst));
        if(ret != 0)
        {
            int err = errno;
            if((EINPROGRESS != err) &&
               (EWOULDBLOCK != err) &&
               (EAGAIN != err) &&
               (EALREADY != err) &&
               (EISCONN != err))
            {
                NSLog(@"connect failed, err = %d",  err);
                break;
            }
        }
        
        //这一段似乎实在判断connect是否连接成功
        fd_set fdr, fdw;
        FD_ZERO(&fdr);
        FD_ZERO(&fdw);
        FD_SET(sock, &fdr);
        FD_SET(sock, &fdw);
        struct timeval timeout;
        timeout.tv_sec = 3;
        timeout.tv_usec = 0;
        
        int res = select(sock + 1, &fdr, &fdw, NULL, &timeout);
        if(res < 0)
        {
            NSLog(@"Network error...");
            break;
        }
        else if(res == 0)
        {
            NSLog(@"Connect server timeout1");
            break;
        }
        else
        {
            if (FD_ISSET(sock, &fdw) && !FD_ISSET(sock, &fdr)) {
                NSLog(@"Connected, res = %d", res);
            }
            else if(FD_ISSET(sock, &fdw) && FD_ISSET(sock, &fdr))
            {
                int error = 0;
                socklen_t len = sizeof(error);
                if(getsockopt(sock, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
                {
                    //获取SO_ERROR属性选项，当然getsockopt也有可能错误返回
                    NSLog(@"getsockopt SO_ERROR failed");
                    break;
                }
                if(error != 0)
                {
                    //如果error不为0， 则表示链接到此没有建立完成
                    NSLog(@"error = %d", error);
                    break;
                }
            }
            else
            {
                break;
            }
        }
        
        //设置回阻塞模式
        fcntl(sock, F_SETFL, iFlag);
        
        //设置socket超时
        struct timeval ti;
        ti.tv_sec=2;
        ti.tv_usec=0;
        setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &ti, sizeof(int));
        setsockopt(sock,SOL_SOCKET,SO_RCVTIMEO,&ti,sizeof(ti));
        return sock;
    }
    if (sock != -1) {
        close(sock);
        sock = -1;
    }
    return -1;
}

-(int)ApModeGetID
{
    int dw3cid = 0;
    int32_t sock = -1;
    while (1)
    {
        NSLog(@"start create sock");
        sock = [self createTcpSocket];
        if (sock == -1) {
            NSLog(@"create sock failed");
            break;
        }
        
        sTransCheckDeviceWifiModeCmdType stru;
        memset(&stru, 0, sizeof(sTransCheckDeviceWifiModeCmdType));
        stru.dwCmd = 0;
        
        //send message
        NSLog(@"start send");
        ssize_t numBytes = send(sock, &stru, sizeof(stru), 0);
        if (numBytes <= 0) {
            NSLog(@"send failed, send %ld bytes, error = %d", numBytes, errno);
            break;
        }
        else
        {
            NSLog(@"send %ld bytes, sock = %d", numBytes, sock);
        }
 
        NSLog(@"start recv");
        //recv message
        char buffer[1024];
        numBytes = recv(sock, buffer, 1024, 0);
        if (numBytes <= 0) {
            NSLog(@"recv failed, recv %ld bytes sock=%d", numBytes, sock);
        }
        else
        {
            if (numBytes == sizeof(sTransCheckDeviceWifiModeCmdType)) {
                sTransCheckDeviceWifiModeCmdType* pStru = (sTransCheckDeviceWifiModeCmdType*)buffer;
                if (pStru->dwCmd == 1 && pStru->dwErrNo == 1) {
                    dw3cid = pStru->dw3CID;
                }
            }
        }
        
        break;
    }
    
    if (sock != -1) {
        close(sock);
        sock = -1;
    }
    
    NSLog(@"dw3cid = %d", dw3cid);
    return dw3cid;
}

-(BOOL)ApModeSetWifiPassword:(NSString*)password
{
    BOOL ret = NO;
    int32_t sock = -1;
    while (1)
    {
        sock = [self createTcpSocket];
        if (sock == -1) {
            break;
        }
        
        sTcpSetWifiCmdType stru;
        memset(&stru, 0, sizeof(sTcpSetWifiCmdType));
        stru.dwCmd = 2;
        stru.bSetWifiInfo = 1;
        memcpy(stru.sWifiInfo.cPassword, [password UTF8String], [password length]);
        
        //send message
        ssize_t numBytes = send(sock, &stru, sizeof(stru), 0);
        if (numBytes <= 0) {
            NSLog(@"send failed, send %ld bytes, error = %d", numBytes, errno);
            break;
        }
        else
        {
            NSLog(@"send %ld bytes, sock = %d", numBytes, sock);
        }
        
        //recv message
        char buffer[1024];
        numBytes = recv(sock, buffer, 1024, 0);
        if (numBytes <= 0) {
            NSLog(@"recv failed, recv %ld bytes sock=%d", numBytes, sock);
        }
        else
        {
            if (numBytes == sizeof(sTcpSetWifiCmdType)) {
                sTcpSetWifiCmdType* pStru = (sTcpSetWifiCmdType*)buffer;
                if (pStru->dwCmd == 3 && pStru->dwErrNo == 0) {
                    ret = YES;
                }
            }
        }
        
        break;
    }
    
    if (sock != -1) {
        close(sock);
        sock = -1;
    }
    
    return ret;
}


@end
