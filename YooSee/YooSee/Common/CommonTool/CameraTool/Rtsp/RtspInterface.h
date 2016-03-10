//
//  RtspInterface.h
//  2cu
//
//  Created by wutong on 15/9/16.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "rtsp_instance.h"

@interface RtspInterface : NSObject
{
    uint64_t _currRtspID;
}
+ (id)sharedDefault;

- (BOOL)CreateRtspConnection:(char*)szIp;
- (void)DestroyRtspConnection;
- (BOOL)GetVideoFrame:(FRAME_VIDEO*) frame;
- (BOOL)GetAudioBuffer:(uint8_t*)pOutBuffer dwLength:(uint32_t)dwLength;
- (void)PTZControl:(int) direction;

- (void)PushIntercomData:(uint8_t*)pOutBuffer dwLength:(uint32_t)dwLength;
- (uint8_t)OpenIntercom;
- (void)CloseIntercom;
@end
