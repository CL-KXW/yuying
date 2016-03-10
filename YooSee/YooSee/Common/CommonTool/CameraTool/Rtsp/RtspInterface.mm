//
//  RtspInterface.m
//  2cu
//
//  Created by wutong on 15/9/16.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "RtspInterface.h"


@implementation RtspInterface
+ (id)sharedDefault
{
    static RtspInterface *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            manager = [[RtspInterface alloc] init];
            manager->_currRtspID = NULL;
        }
    }
    return manager;
}

- (BOOL)CreateRtspConnection:(char*)szIp
{
    uint64_t ret = rtsp_createConnect(szIp);
    if (ret != 0) {
        _currRtspID = ret;
        return TRUE;
    }
    return FALSE;
}

- (void)DestroyRtspConnection
{
    @synchronized(self)
    {
        if (_currRtspID != 0) {
            rtsp_destroyConnect(_currRtspID);
            _currRtspID = 0;
        }
    }
}

- (BOOL)GetVideoFrame:(FRAME_VIDEO*) frame
{
    @synchronized(self)
    {
        if (_currRtspID != 0) {
            uint8_t ret = rtsp_GetVideoFrame(_currRtspID, frame);
            if (ret != 0) {
                return TRUE;
            }
        }
    }
    return FALSE;
}

- (BOOL)GetAudioBuffer:(uint8_t*)pOutBuffer dwLength:(uint32_t)dwLength
{
    @synchronized(self)
    {
        if (_currRtspID != 0) {
            uint8_t ret = rtsp_GetAudioBuffer(_currRtspID, pOutBuffer, dwLength);
            if (ret != 0) {
                return TRUE;
            }
        }
    }
    
    return FALSE;
}

- (void)PTZControl:(int) direction
{
    @synchronized(self)
    {
        if (_currRtspID != 0) {
            rtsp_PtzControl(_currRtspID, direction);
        }        
    }
}

- (void)PushIntercomData:(uint8_t*)pOutBuffer dwLength:(uint32_t)dwLength
{
    @synchronized(self)
    {
        if (_currRtspID != 0) {
            rtsp_PushIntercomData(_currRtspID, pOutBuffer, dwLength);
        }
    }
}

- (uint8_t)OpenIntercom
{
    @synchronized(self)
    {
        if (_currRtspID != 0) {
            uint8_t ret = rtsp_OpenIntercom(_currRtspID);
            return ret;
        }
    }
    return intercom_connect_failed;
}

- (void)CloseIntercom
{
    if (_currRtspID != 0) {
        rtsp_CloseIntercom(_currRtspID);
    }
}

@end
