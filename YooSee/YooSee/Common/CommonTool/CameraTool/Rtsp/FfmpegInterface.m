//
//  FfmpegInterface.m
//  2cu
//
//  Created by wutong on 15/9/16.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "FfmpegInterface.h"

@implementation FfmpegInterface
+ (id)sharedDefault
{
    static FfmpegInterface *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            manager = [[FfmpegInterface alloc] init];
            manager->_isInited = NO;
        }
    }
    return manager;
}

- (void) vInitVideoDecoder
{
    avcodec_register_all();
//    av_register_all();
    [self add_decode_context];
    _isInited = YES;
}

- (void) vDestoryVideoDecoder
{
    if (!_isInited) {
        return;
    }
    av_free_packet(&_sDecodePkt);
    // Close the codec
    if(_pDecodeAVC)
    {
        avcodec_close(_pDecodeAVC);
        av_free(_pDecodeAVC);
        _pDecodeAVC = NULL;
    }
    // Free the YUV frame
    if(_pDecodeOutputFrame)
    {
        av_free(_pDecodeOutputFrame);
        _pDecodeOutputFrame= NULL;
    }
    
    _isInited = NO;
}

- (void)add_decode_context
{
    AVCodec *codec;
    _pDecodeAVC = NULL;
    // 寻找编码器
    codec = avcodec_find_decoder(CODEC_ID_H264);
    if (!codec) {
        NSLog(@"codec not found\n");
    }
    _pDecodeAVC = avcodec_alloc_context3(codec);
    _pDecodeAVC->bit_rate = 4000000;
    _pDecodeAVC->time_base.den = 15;/////may be remote frame rate
    _pDecodeAVC->time_base.num = 1;
    _pDecodeAVC->pix_fmt = PIX_FMT_YUV420P;
    _pDecodeAVC->codec_type = AVMEDIA_TYPE_VIDEO;
    _pDecodeAVC->rc_buffer_aggressivity = 1.0;
    //浮点数. 表示开启解码器码流缓冲(decoder bitstream buffer)
    _pDecodeAVC->flags |= CODEC_FLAG_GLOBAL_HEADER| CODEC_FLAG_LOOP_FILTER;
    _pDecodeAVC->flags2 |= CODEC_FLAG2_FAST;
    if (avcodec_open2(_pDecodeAVC, codec, NULL) < 0) {
        NSLog(@"could not open encode-codec\n");
    }
    
    // 定义图片缓存变量
    _pDecodeOutputFrame = avcodec_alloc_frame();
    
    av_init_packet(&_sDecodePkt);
    _sDecodePkt.flags = AV_PKT_FLAG_KEY;
}

-(BOOL)  fgDecodePictureFrame:(Byte *)pBuffer dwSize:(DWORD)dwSize u6PTS:(UInt64)u6PTS pFrame:(GAVFrame*)pFrame
{
    // 填充输入缓冲区
    int frameFinished = 0;
    _sDecodePkt.data = pBuffer;
    _sDecodePkt.size = dwSize;
    _sDecodePkt.pts = u6PTS ;
    
    
    frameFinished = avcodec_decode_video2(_pDecodeAVC, _pDecodeOutputFrame, &frameFinished, &_sDecodePkt);
    
    if (!_pDecodeOutputFrame->data[0] || frameFinished <= 0)
    {
        return FALSE;
    }
    pFrame->height = _pDecodeOutputFrame->height;
    pFrame->width  = _pDecodeOutputFrame->width;
    pFrame->pts = _pDecodeOutputFrame->pts;
    pFrame->linesize[0] = _pDecodeOutputFrame->linesize[0];
    pFrame->linesize[1] = _pDecodeOutputFrame->linesize[1];
    pFrame->linesize[2] = _pDecodeOutputFrame->linesize[2];
    memcpy(pFrame->data[0], _pDecodeOutputFrame->data[0], _pDecodeOutputFrame->linesize[0]*_pDecodeOutputFrame->height);
    memcpy(pFrame->data[1], _pDecodeOutputFrame->data[1], _pDecodeOutputFrame->linesize[1]*_pDecodeOutputFrame->height/2);
    memcpy(pFrame->data[2], _pDecodeOutputFrame->data[2], _pDecodeOutputFrame->linesize[2]*_pDecodeOutputFrame->height/2);
    return TRUE ;
}
@end
