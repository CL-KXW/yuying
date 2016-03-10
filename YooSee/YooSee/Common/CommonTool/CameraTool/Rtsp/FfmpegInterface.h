//
//  FfmpegInterface.h
//  2cu
//
//  Created by wutong on 15/9/16.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "avcodec.h"
#import "P2PCInterface.h"

@interface FfmpegInterface : NSObject
{
    AVPacket _sDecodePkt;
    AVCodecContext*  _pDecodeAVC;
    AVFrame* _pDecodeOutputFrame;
    
    BOOL _isInited;
}
+ (id)sharedDefault;
- (void) vInitVideoDecoder;
- (void) vDestoryVideoDecoder;
-(BOOL)  fgDecodePictureFrame:(Byte *)pBuffer dwSize:(DWORD)dwSize u6PTS:(UInt64)u6PTS pFrame:(GAVFrame*)pFrame;
@end
