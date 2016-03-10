//
//  YAudioStreamPlayer.m
//  Yoosee
//
//  Created by guojunyi on 14-7-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "YAudioStreamPlayer.h"
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Constants.h"
#define kOutputBus 0
#define kInputBus 1

#define pi 3.14159



@interface YAudioStreamPlayer ()
{
    AudioUnit                   _audioUnit;
    AudioBufferList             *_m_inBufferList;
    Float64                     recordSampleRate;
    AudioStreamBasicDescription audioFormat;
    

}



@end



@implementation YAudioStreamPlayer
int SinIndex = 0;
int iAudioLen = 0;
//************************************
int iCrc32(Byte buf[], int len) {
    int dwCrcValue = 0xAA55CC99;
    int i = 0;
    int crc_table[] = { 0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,
        0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3, 0x0edb8832,
        0x79dcb8a4, 0xe0d5e91e, 0x97d2d988, 0x09b64c2b, 0x7eb17cbd,
        0xe7b82d07, 0x90bf1d91, 0x1db71064, 0x6ab020f2, 0xf3b97148,
        0x84be41de, 0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
        0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec, 0x14015c4f,
        0x63066cd9, 0xfa0f3d63, 0x8d080df5, 0x3b6e20c8, 0x4c69105e,
        0xd56041e4, 0xa2677172, 0x3c03e4d1, 0x4b04d447, 0xd20d85fd,
        0xa50ab56b, 0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940,
        0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59, 0x26d930ac,
        0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423,
        0xcfba9599, 0xb8bda50f, 0x2802b89e, 0x5f058808, 0xc60cd9b2,
        0xb10be924, 0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
        0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a, 0x71b18589,
        0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433, 0x7807c9a2, 0x0f00f934,
        0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d, 0x91646c97,
        0xe6635c01, 0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
        0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 0x65b0d9c6,
        0x12b7e950, 0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49,
        0x8cd37cf3, 0xfbd44c65, 0x4db26158, 0x3ab551ce, 0xa3bc0074,
        0xd4bb30e2, 0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
        0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0, 0x44042d73,
        0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 0x5005713c, 0x270241aa,
        0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409,
        0xce61e49f, 0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4,
        0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad, 0xedb88320,
        0x9abfb3b6, 0x03b6e20c, 0x74b1d29a, 0xead54739, 0x9dd277af,
        0x04db2615, 0x73dc1683, 0xe3630b12, 0x94643b84, 0x0d6d6a3e,
        0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
        0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d,
        0x806567cb, 0x196c3671, 0x6e6b06e7, 0xfed41b76, 0x89d32be0,
        0x10da7a5a, 0x67dd4acc, 0xf9b9df6f, 0x8ebeeff9, 0x17b7be43,
        0x60b08ed5, 0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252,
        0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b, 0xd80d2bda,
        0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55,
        0x316e8eef, 0x4669be79, 0xcb61b38c, 0xbc66831a, 0x256fd2a0,
        0x5268e236, 0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
        0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7,
        0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d, 0x9b64c2b0, 0xec63f226,
        0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f, 0x72076785,
        0x05005713, 0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
        0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 0x86d3d2d4,
        0xf1d4e242, 0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b,
        0x6fb077e1, 0x18b74777, 0x88085ae6, 0xff0f6a70, 0x66063bca,
        0x11010b5c, 0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
        0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2, 0xa7672661,
        0xd06016f7, 0x4969474d, 0x3e6e77db, 0xaed16a4a, 0xd9d65adc,
        0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f,
        0x30b5ffe9, 0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6,
        0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf, 0xb3667a2e,
        0xc4614ab8, 0x5d681b02, 0x2a6f2b94, 0xb40bbe37, 0xc30c8ea1,
        0x5a05df1b, 0x2d02ef8d };
    
    if (len != 0)
        do {
            // DO1(buf);
            dwCrcValue = crc_table[((int) dwCrcValue ^ (buf[i])) & 0xff]
            ^ (dwCrcValue >> 8);
            i++;
            len--;
        } while (len != 0);
    
    return dwCrcValue;
}

short SinValue(int frequence) {
    SinIndex++;

    return (short) (32767 * sin(2 * 3.14 * SinIndex * frequence
                                     / 44100));
}

int iCreate5KHzHeader(short wBuffer[]) {
    for (int i = 0; i < 1102; i++) // 25mS
    {
        wBuffer[2 * i] = (short) (32767 * sin(2 * 3.14 * i * 5000
                                                   / 44100));
        wBuffer[2 * i + 1] = (short) (32767 * sin(2 * 3.14 * i * 5000
                                                       / 44100));
    }
    int n = 1102 * 2 + 2425 * 2;// 55mS
    
    return n;
}

int iFillSinData(short wBuffer[], int offset, int pointer,
                 double time_begin_pos, double time_end_pos) {
    SinIndex = 0;
    while (true) {
        double t1 = (double) pointer * 1000 / 44100;
        if (t1 > time_end_pos) {
            break;
        }
        
        if (t1 >= time_begin_pos && t1 <= time_end_pos) {
            wBuffer[offset + pointer * 2] = SinValue(12600);
        } else {
            wBuffer[offset + pointer * 2] = 0;
        }
        wBuffer[offset + pointer * 2 + 1] = wBuffer[offset + pointer * 2];
        pointer++;
    }
    
    return pointer;
}

int iCreateAudioDataSeq(Byte TransData[], int iDataLen,
                        short wBuffer[], int offset) {
    double time_begin = 0;
    double time_end =  9;//3.376;//
    
    int pos = 0;
    pos = iFillSinData(wBuffer, offset, pos, time_begin, time_end);
    
    time_begin = time_end +  4.5; //1.688;//
    time_end = time_begin +  0.56; //0.422;//
    pos = iFillSinData(wBuffer, offset, pos, time_begin, time_end);
    
    
    
    for (int i = 0; i < iDataLen; i++)
    {
        Byte data = TransData[i];
        for (int j = 0; j < 8; j++)
        {
            
            if ((data & 0x01) != 0)
            {
                time_begin = time_end +  1.69; //1.266;//
                time_end = time_begin +  0.56; //0.422; //
                pos = iFillSinData(wBuffer, offset, pos, time_begin,
                                   time_end);
            }
            else
            {
                time_begin = time_end +  0.56; //0.422; //
                time_end = time_begin +  0.56; //0.422; //
                pos = iFillSinData(wBuffer, offset, pos, time_begin,
                                   time_end);
            }
            data >>= 1;
        }
    }
    
    time_begin = time_end +  40; //
    time_end = time_begin +  9; //
    pos = iFillSinData(wBuffer, offset, pos, time_begin,
                       time_end);
    
    time_begin = time_end +  2.25; //
    time_end = time_begin +  0.55; //
    pos = iFillSinData(wBuffer, offset, pos, time_begin,
                       time_end);
    
    // /repeat
    /*
     * time_begin = 110; time_end = 110+9; pos = iFillSinData(wBuffer,
     * offset, pos,time_begin, time_end );
     * 
     * time_begin = time_end + 2.25; time_end = time_begin+0.56; pos =
     * iFillSinData(wBuffer, offset, pos,time_begin, time_end );
     */
    
    return pos * 2;
    
}

int iCreateSetWiFiCmdRawData(int DevicePassword, int iType,
                             char* SSID,int ssidSize,char* wifiPassword,int pwdSize, Byte bCmdBuf[]) {
    bCmdBuf[0] = 0x01;
    bCmdBuf[1] = (Byte) ((Byte) 0xFF & (Byte) (DevicePassword >> 24));
    bCmdBuf[2] = (Byte) ((Byte) 0xFF & (Byte) (DevicePassword >> 16));
    bCmdBuf[3] = (Byte) ((Byte) 0xFF & (Byte) (DevicePassword >> 8));
    bCmdBuf[4] = (Byte) ((Byte) 0xFF & (Byte) (DevicePassword >> 0));
    
    bCmdBuf[5] = (Byte) ((Byte) iType & 0x03);
    
    int k = 6;
    for (int i = 0; i < ssidSize; i++) {
        bCmdBuf[k] = SSID[i];
        k++;
    }
    bCmdBuf[k] = 0;
    k++;
    
    for (int i = 0; i < pwdSize; i++) {
        bCmdBuf[k] = (Byte) wifiPassword[i];
        k++;
    }
    
    bCmdBuf[k] = 0;
    k++;
    
    return k;
}

int iSetWiFiCmd(int DevicePassword, int iType,const char* SSID,int ssidSize,const char* wifiPassword,int pwdSize, short PlayBuf[]) {
    Byte bCmdData[256];
    memset(bCmdData, 0, 256);
    int ilen = iCreateSetWiFiCmdRawData(DevicePassword, iType, SSID,ssidSize,
                                        wifiPassword,pwdSize, bCmdData);
    
    // create 5kHz header
    
    int AudioDataLen = iCreate5KHzHeader(PlayBuf);

    Byte bPlayData[6];
    Byte bTmp;
    int iSeqCnt = ilen / 5 + 1;
    if ((ilen % 5) != 0)
        iSeqCnt += 1;
    int idx = 0;
    
    for (int i = 0; i < iSeqCnt; i++) {
        bPlayData[1] = (Byte) bCmdData[idx];
        idx++;
        bPlayData[2] = (Byte) bCmdData[idx];
        idx++;
        bPlayData[3] = (Byte) bCmdData[idx];
        idx++;
        bPlayData[4] = (Byte) bCmdData[idx];
        idx++;
        bPlayData[5] = (Byte) bCmdData[idx];
        idx++;
        bPlayData[0] = (Byte) ((Byte) i & 0x0F);
        bTmp = (Byte) (bPlayData[0] ^ bPlayData[1] ^ bPlayData[2]
                       ^ bPlayData[3] ^ bPlayData[4] ^ bPlayData[5]);
        bPlayData[0] = (Byte) ((Byte) ((bTmp & 0xF0) ^ (bTmp << 4)) | (bPlayData[0] & 0x0F));
        
        int offset = iCreateAudioDataSeq(bPlayData, 6, PlayBuf,
                                         AudioDataLen);
        AudioDataLen += offset;
        
        AudioDataLen += 20*(44100*2/1000) ; //50mS
        
        if(i==0)
        {
            offset = iCreateAudioDataSeq(bPlayData, 6, PlayBuf,
                                         AudioDataLen);
            AudioDataLen += offset;
            AudioDataLen += 20*(44100*2/1000) ; //50mS
        }
        
        // offset = iCreate5KHzHeader(PlayBuf); //5KHz Header
        // AudioDataLen += offset;
        
        // Log.e("e", "AudioDataLen1="+AudioDataLen);
    }
    
    // /CRC
    Byte bCrcData[6];
    int iCrcValue = iCrc32(bCmdData, ilen);
    bCrcData[0] = 0x0F;
    bCrcData[1] = (Byte) ilen;
    bCrcData[2] = (Byte) ((Byte) (iCrcValue >> 24) & 0xFF);
    bCrcData[3] = (Byte) ((Byte) (iCrcValue >> 16) & 0xFF);
    bCrcData[4] = (Byte) ((Byte) (iCrcValue >> 8) & 0xFF);
    bCrcData[5] = (Byte) ((Byte) (iCrcValue >> 0) & 0xFF);
    
    bTmp = (Byte) (bCrcData[0] ^ bCrcData[1] ^ bCrcData[2] ^ bCrcData[3]
                   ^ bCrcData[4] ^ bCrcData[5]);
    bCrcData[0] = (Byte) ((Byte) ((bTmp & 0xF0) ^ (bTmp << 4)) | (bCrcData[0] & 0x0F));
    
   
    
    int offset = iCreateAudioDataSeq(bCrcData, 6, PlayBuf, AudioDataLen);
    AudioDataLen += offset;
    
    AudioDataLen += 50 * (44100 * 2 / 1000); // 50mS
    
    // Log.e("e", "AudioDataLen2="+AudioDataLen);
    
    return AudioDataLen;
}

int iSetPTZCmd(Byte bDirection, short PlayBuf[]) {
    Byte bCmdData[256];
    memset(bCmdData, 0, 256);
    
    // create 5kHz header

   // memset(PlayBuf, 0, sizeof(PlayBuf));
    int AudioDataLen = iCreate5KHzHeader(PlayBuf);
    
    Byte bData[6];
    Byte bTmp;
    bData[0] = 0x0F;
    bData[1] = (Byte) 0x04;
    bData[2] = (Byte) 0x02;
    bData[3] = (Byte) bDirection;
    bData[4] = (Byte) 0;
    bData[5] = (Byte) 0;
    
    bTmp = (Byte) (bData[0] ^ bData[1] ^ bData[2] ^ bData[3] ^ bData[4] ^ bData[5]);
    bData[0] = (Byte) ((Byte) ((bTmp & 0xF0) ^ (bTmp << 4)) | (bData[0] & 0x0F));
    
    ///first time
    int offset = iCreateAudioDataSeq(bData, 6, PlayBuf, AudioDataLen);
    AudioDataLen += offset;
    
    AudioDataLen += 20*(44100*2/1000) ; //50mS
    
    ///second time
    offset = iCreateAudioDataSeq(bData, 6, PlayBuf, AudioDataLen);
    AudioDataLen += offset;
    
    AudioDataLen += 20*(44100*2/1000) ; //50mS
    
    //3 time
    offset = iCreateAudioDataSeq(bData, 6, PlayBuf, AudioDataLen);
    AudioDataLen += offset;
    
    AudioDataLen += 20*(44100*2/1000) ; //50mS
    
    return AudioDataLen;
}

//void vPTZCtrlByIR(Byte bDirection) {
//    short play_buffer[44100*10];
//    int iLen = iSetPTZCmd(bDirection, play_buffer);
//    
//}

//************************************

#define checkstatus(x) yCheckStatusWithLineNumber(__LINE__, x)
void yCheckStatusWithLineNumber(int lineNumber, OSStatus status) {
	if (status != 0) NSLog(@"An error occurred on line %d: %d", lineNumber, (int)status);
}

void yInterruptionListenerCallback (void *inUserData, UInt32 interruptionState)
{
    
    if (interruptionState == kAudioSessionBeginInterruption) {
        //hungup
    }
    
}

void yAudioRouteChangeCallback(void*inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void*inData) {
    CFDictionaryRef routeChangeDictionary = inData;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    switch (routeChangeReason) {
        case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
            NSLog(@"AudioSessionRouteChange : Old Audio Device Unavailable");
            break;
        case kAudioSessionRouteChangeReason_NewDeviceAvailable:
            NSLog(@"AudioSessionRouteChange : New Audio Device Available");
            break;
        case kAudioSessionRouteChangeReason_Override:
            NSLog(@"AudioSessionRouteChange : Audio Device Route Change Override");
            break;
        default:
            if (routeChangeReason == kAudioSessionRouteChangeReason_NoSuitableRouteForCategory) {
                NSLog(@"AudioSessionRouteChange : No Suitable Route For Category");
            }
            break;
    }
    
    [[YAudioStreamPlayer sharedDefault] checkSpeaker];
}



static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    //NSLog(@"*");
    
    return noErr;
}

static short play_buffer[44100*10];
static int   iAudioIndex = 0;
static int   iTargetAudioLen = 0;
static OSStatus playbackCallback(void *inRefCon,
								 AudioUnitRenderActionFlags *ioActionFlags,
								 const AudioTimeStamp *inTimeStamp,
								 UInt32 inBusNumber,
								 UInt32 inNumberFrames,
								 AudioBufferList *ioData) {
    
    short *buffer = (short*)ioData->mBuffers[0].mData;
    int AudioSize = ioData->mBuffers[0].mDataByteSize;
    
    if(iTargetAudioLen)
    {
        if(iAudioIndex + AudioSize/2 >= 44100*10)
        {
            AudioSize = (44100*10 -iAudioIndex) *2;
        }
        
        memcpy(buffer,&(play_buffer[iAudioIndex]),AudioSize);
        iAudioIndex += (AudioSize/2);
        if(iAudioIndex>=iTargetAudioLen)
        {
            iTargetAudioLen = 0;
            iAudioIndex = 0;
        }
    }
    else
    {
        memset(buffer, 0, AudioSize);
    }
    
    return noErr;
}

void playCmd(int cmd){
    if(iTargetAudioLen==0){
        memset(play_buffer,0,44100*10*2);
        iTargetAudioLen = iSetPTZCmd(cmd, play_buffer);
    }
}

void playWIFI(int devicePassword,int type,const char *ssid,int ssidSize,const char *wifiPassword,int pwdSize){
    if(iTargetAudioLen==0){
        memset(play_buffer,0,44100*10*2);
        
        iTargetAudioLen = iSetWiFiCmd(devicePassword, type, ssid, ssidSize, wifiPassword, pwdSize, play_buffer);
    }
}

+ (id)sharedDefault
{
    
    static YAudioStreamPlayer *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            NSLog(@"Alloc FListManager");
            
            manager = [[YAudioStreamPlayer alloc] init];
            manager.isPlay = NO;
        }
    }
    return manager;
}

-(void)playCmd:(NSInteger)cmd{
    playCmd(cmd);
}

-(void)playWIFI:(NSString *)ssid wifiPassword:(NSString *)wifiPassword devicePassword:(NSString *)devicePassword{
    int type = 0;
    if(wifiPassword.length>0){
        type = 2;
    }else{
        type = 0;
    }
    
    playWIFI(devicePassword.intValue,type,[ssid UTF8String],[ssid length],[wifiPassword UTF8String],[wifiPassword length]);
}

-(BOOL)initSession{
    OSStatus error = AudioSessionInitialize(NULL, NULL, yInterruptionListenerCallback, NULL); // 初始化音频会话
    if (error)
        printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
    
    //    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
    
    // 侦听耳机插拔事件
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, yAudioRouteChangeCallback, (__bridge void *)(self));
    
    //    UInt32 routeSpeaker = kAudioSessionOverrideAudioRoute_Speaker;
    //    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(routeSpeaker), &routeSpeaker);
    
    UInt32 doSetProperty = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    
    Float32 duration = (float)320.0/44100.0;
    //double version = [[UIDevice currentDevice].systemVersion doubleValue];
//    if (version >= 7.0) {
//        if ([UIScreen mainScreen].bounds.size.height == 568.0) {
//            duration = (float)160.0/44100.0;
//        }
//    }
    
    //Float32 duration = (float)kAudioBufferNumFrames / kDefaultSoundRate;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(duration), &duration);
    Float64 hwSampleRate = 44100.0;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(hwSampleRate), &hwSampleRate);
    
    OSStatus status = AudioSessionSetActive(true); // 激活会话
    if (status) {
        NSLog(@"error when open AudioSession!");
        return NO;
    }
    return YES;
}

- (BOOL)uninitSession
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, yAudioRouteChangeCallback, (__bridge void *)(self));
    OSStatus status = AudioSessionSetActive(false); // 反激活会话
    if (status) {
        NSLog(@"error when close AudioSession!");
        return NO;
    }
    return YES;
}

-(BOOL)initAudio{
    
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_RemoteIO;//kAudioUnitSubType_VoiceProcessingIO;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    OSStatus status = noErr;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    
    UInt32 flag = 1;
    // Enable IO for recording
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkstatus(status);
    
    // Enable IO for playback
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkstatus(status);
	
	// Describe format
	audioFormat.mSampleRate			= 44100;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 2;
	audioFormat.mBitsPerChannel		= 16;//short
	audioFormat.mBytesPerPacket		= 4;
	audioFormat.mBytesPerFrame		= 4;
	
    // Apply format
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkstatus(status);
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkstatus(status);
    
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
	// Set output callback
    callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_audioUnit,
								  kAudioUnitProperty_SetRenderCallback,
								  kAudioUnitScope_Global,
								  kOutputBus,
								  &callbackStruct,
								  sizeof(callbackStruct));
    checkstatus(status);
	
	// Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkstatus(status);
    
    if (status) {
        return NO;
    }
    
    _m_inBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
    _m_inBufferList->mNumberBuffers = 1;
    _m_inBufferList->mBuffers[0].mNumberChannels = 1;
    _m_inBufferList->mBuffers[0].mDataByteSize = 320 * 2;
    _m_inBufferList->mBuffers[0].mData = malloc( 320 * 2 );
    
    return YES;
}

- (BOOL)uninitAudio{
    OSStatus status;
    free(_m_inBufferList->mBuffers[0].mData);
    free(_m_inBufferList);
    status = AudioComponentInstanceDispose(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }

    return YES;
}

- (BOOL)startAudio{
    OSStatus status;
    status = AudioUnitInitialize(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    status = AudioOutputUnitStart(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    
    return YES;
}

- (BOOL)stopAudio
{
    OSStatus status = AudioOutputUnitStop(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
	status = AudioUnitUninitialize(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }

	return YES;
}

-(BOOL)start{
    if(self.isPlay){
        return NO;
    }
    
    BOOL b1 = [self initSession];
    
    if(!b1){
        return NO;
    }
    
    BOOL b2 = [self initAudio];
    
    if(!b2){
        return NO;
    }
    
    BOOL b3 = [self startAudio];
    
    if(!b3){
        return NO;
    }
    
    self.isPlay = YES;
    return YES;
}

-(void)stop{
    if(!self.isPlay){
        return;
    }
    
    [self stopAudio];
    [self uninitAudio];
    [self uninitSession];
    self.isPlay = NO;
}


- (BOOL)isHeadphone {
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString *)route;
        NSLog(@"AudioRoute: %@", routeStr);
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

- (void)checkSpeaker
{
    UInt32 audioRoute;
    if (self.isHeadphone) {
        audioRoute = kAudioSessionOverrideAudioRoute_None; // 默认输出
    } else {
        audioRoute = kAudioSessionOverrideAudioRoute_Speaker; // 扬声器输出
    }
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(UInt32), &audioRoute);
}

@end
