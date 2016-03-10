#pragma once
#include <sys/types.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <errno.h>
#include <pthread.h>

#define G711_PACK_SIZE	160
#define PCM_PACK_SIZE	320
#define MAX_FRAME_SIZE	512*1024



#define WM_RTSP_CONNECT WM_USER+1000
enum
{
	msg_rtsp_connect_ok,
	msg_rtsp_connect_failed,
	msg_rtsp_connect_interrupted,
	msg_rtsp_connect_resuccess,
};

enum
{
    intercom_connect_failed,
    intercom_connect_unsupport,
    intercom_connect_ok
};

typedef struct __aux_frame_video
{
	unsigned int dataSize;
	unsigned char frame_data[MAX_FRAME_SIZE];
	uint32_t pts;		//毫秒
}FRAME_VIDEO;

typedef struct __aux_frame_audio
{
	unsigned char frame_data[PCM_PACK_SIZE];
	uint32_t pts;
}FRAME_AUDIO;

enum
{
	ptz_direction_up,
	ptz_direction_right,
	ptz_direction_down,
	ptz_direction_left,
};

#define INVALID_SOCKET -1


//--------------------------------------------
//【创建实例】
//返回值: 创建rstp链接的实例;
//参数-szRemoteIp	:	设备的ip地址，如"192.168.1.13"
//参数-msgHwnd		:	如果用阻塞模式，则msgHwnd置null;否则,msgHwnd设置为接收详细的句柄
uint64_t rtsp_createConnect(char* szRemoteIp);
//--------------------------------------------


//--------------------------------------------
//【销毁实例】
//参数-id: rtsp_startConnect的返回值
void rtsp_destroyConnect(uint64_t id);
//--------------------------------------------


//--------------------------------------------
//【获取一个H264视频帧】
//参数-id:		rtsp_startConnect的返回值
//参数-frame_t:	视频帧保存的结构体
uint8_t rtsp_GetVideoFrame(uint64_t id, FRAME_VIDEO* frame_t);
//--------------------------------------------


//--------------------------------------------
//【获取一个G711音频帧】
//参数-id:		rtsp_startConnect的返回值
//参数-frame_t:	音频帧保存的结构体
uint8_t rtsp_GetAudioBuffer(uint64_t id, uint8_t* pOutBuffer, int32_t dwLength);
//--------------------------------------------


void rtsp_PtzControl(uint64_t id, int direction);

//intercom
uint8_t rtsp_OpenIntercom(uint64_t id);
void    rtsp_CloseIntercom(uint64_t id);
void    rtsp_PushIntercomData(uint64_t id, uint8_t* pOutBuffer, int32_t dwLength);