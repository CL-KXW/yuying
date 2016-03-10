//
//  P2PClient.m
//  Yoosee
//
//  Created by guojunyi on 14-3-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PClient.h"
#import "P2PCInterface.h"
#import "Utils.h"
#import "Constants.h"
#import "config.h"
#import "PAIOUnit.H"

#import "FListManager.h"
#import "mesg.h"
#import "des2.h"
#import "CameraManager.h"

#import "Alarm.h"
#import "AlarmDAO.h"

#import "RecommendInfo.h"
#import "RecommendInfoDAO.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "AppDelegate.h"
//#import "MainController.h"
#import "MPNotificationView.h"

static sRecFilenameType playbackFiles[128];
static int playbackFilesLength  = 0;
static int playbackCurrentFileIndex = -1;

NSMutableArray *camInfoList;


//录像
#import "general.h"
#import "faac.h"
#import "file.h"
#import "file_prop.h"
#import "track.h"
#import "track_prop.h"
#import "interf_dec.h"
#import "sample.h"
#import "mesg.h"



//attribute
DWORD g_dwFrameRate = 0;        //视频帧率
DWORD g_dwVideoHeight = 0;      //视频高
DWORD g_dwVideoWidth = 0;       //视频宽
DWORD g_timeScalVideo = 1000;
DWORD g_timeScalAudio = 8000;

//control
#define TOTAL_RECORD_FRAME  300
MP4FileHandle g_mp4FileHandle = MP4_INVALID_FILE_HANDLE;
FILE* g_accFile = nil;
DWORD g_countFrame = 0;
DWORD g_isNeedKeyFrame = YES;
MP4TrackId g_trackIdVideo = MP4_INVALID_TRACK_ID;
MP4TrackId g_trackIdAudio = MP4_INVALID_TRACK_ID;
void* g_pDecoder = nil;
faacEncHandle g_hFaacEncoder;


DWORD g_channel = 0;                //音频通道数目
DWORD g_sampleRate = 0;             //音频采样率
DWORD g_bitWidth = 0;               //音频位宽
unsigned long g_inputSamples;       //faac编码时所需的原始数据字节数
unsigned long g_maxOutputBytes;

BYTE* g_pDatePCM = nil;
unsigned long g_dwPosPcm = 0;


@implementation P2PClient



-(void)dealloc{
//    [self.callId release];
//    [self.callPassword release];
//    [_recordFileName release];
//    [super dealloc];
}

+ (id)sharedClient
{
    
    static P2PClient *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[P2PClient alloc] init];
        manager.isSendProcRunning = NO;
        manager.callPassword = @"";
    });
    return manager;
}

-(BOOL)p2pConnectWithId:(NSString *)contactId codeStr1:(NSString *)codeStr1 codeStr2:(NSString *)codeStr2{
    if(![contactId isValidateNumber]){
        return NO;
    }
    
    if(![codeStr1 isValidateNumber]){
        return NO;
    }
    
    if(![codeStr2 isValidateNumber]){
        return NO;
    }
    sP2PInitPrm mP2Pprm;
    mP2Pprm.dw3CID = contactId.intValue;
    mP2Pprm.dw3CID |= 0x80000000 ;
    mP2Pprm.dwCode1 = codeStr1.intValue;
    mP2Pprm.dwCode2 = codeStr2.intValue;
    
    mP2Pprm.pHostName = "|www.cloudlinks.cn|www.cloud-links.net|www.gwelltimes.com|www.2cu.co";
    //mP2Pprm.pHostName = "|192.168.1.231";
    mP2Pprm.dwChNs         = 1;
	mP2Pprm.dwChBufSize[0] = 1024*512;
	mP2Pprm.dwChBufSize[1] = 1024*512;
	mP2Pprm.dwChBufSize[2] = 1024*512;
	mP2Pprm.dwChBufSize[3] = 1024*512;
	mP2Pprm.dwPassword     = 1792802871;
    
    //get CustomerID from Common-Configuration.plist
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    NSArray *customerIDArray = dic[@"CustomerID"];
    mP2Pprm.dwCustomerID[0] = [customerIDArray[0] intValue];
    mP2Pprm.dwCustomerID[1] = [customerIDArray[1] intValue];
    mP2Pprm.dwCustomerID[2] = [customerIDArray[2] intValue];
    mP2Pprm.dwCustomerID[3] = [customerIDArray[3] intValue];
    mP2Pprm.dwCustomerID[4] = [customerIDArray[4] intValue];
    mP2Pprm.dwCustomerID[5] = [customerIDArray[5] intValue];
    mP2Pprm.dwCustomerID[6] = [customerIDArray[6] intValue];
    mP2Pprm.dwCustomerID[7] = [customerIDArray[7] intValue];
    mP2Pprm.dwCustomerID[8] = [customerIDArray[8] intValue];
    mP2Pprm.dwCustomerID[9] = [customerIDArray[9] intValue];
	mP2Pprm.vCallingSignal = vCallingSignal;
	mP2Pprm.vRejectSignal  = vRejectSignal;
	mP2Pprm.vAcceptSignal  = vAcceptSignal;
	mP2Pprm.vP2PConnReady  = vP2PConnReady;
    mP2Pprm.vRecvRemoteMessage = vRecvRemoteMessage;
	mP2Pprm.vSendMessageAck=    vSendMessageAck;
	mP2Pprm.vFriendsStatusUpdate = vFriendsStatusUpdate;
    mP2Pprm.vFlagUpdate = NULL;

    return fgP2PInit(&mP2Pprm);

}

//有新的系统消息回调函数
void vFlagUpdate(DWORD *pdwFlag)
{
    //     //friends update
    //    if(pdwFlag[0] > dwMyFlag[0] || dwMyFlag[0] - pdwFlag[0] > 32767)
    //    {
    //
    //    }
    
    //system message update
    //get RecommendFlag flag from local
    NSUInteger dwMyFlag = (NSUInteger)[[[NSUserDefaults standardUserDefaults] objectForKey:@"RecommendFlag"] integerValue];
    if(pdwFlag[1] > dwMyFlag || dwMyFlag - pdwFlag[1] > 32767)
    {
        return;//关闭推送
        
        //取服务器的数据  获取推荐内容列表
        // get storeID
        NSString *storeID = nil;
        
        //get isManualStoreID from Common-Configuration.plist
        NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
        NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
        BOOL isManualStoreID = [dic[@"isManualStoreID"] boolValue];
        if (isManualStoreID) {
            //get ManualStoreID from Common-Configuration.plist
            storeID = dic[@"ManualStoreID"];
            if ([storeID isEqualToString:@""]) {
                storeID = nil;
            }
        }else{
            //get storeID from local
            storeID = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreID"];
        }
        if (!storeID) {
            //要不要提示一下呢（请求添加设备，获取商城ID,或者在.plist文件添加商城ID）
            //能够推送过来，即调用vFlagUpdate，说明storeID存在
            //return ;
        }
        
        //取出最新的一条记录的Index传给服务器，获取最新的推荐列表信息（本地没有的）
        RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
        NSArray *arr = [recoDAO findAll];
        int index = 0;
        if (arr.count > 0) {
            RecommendInfo *m = arr[0];//最新的一条记录
            index = m.messageID;
        }
        //[recoDAO release];
        LoginResult * login = [UDManager getLoginInfo];
        NSInteger userID = login.contactId.integerValue | 0x80000000;
        NSString *sessionID = login.sessionId;
        NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.231/Business/Seller/RecommendInfo.ashx?UserID=%d&SessionID=%@&StoreID=%@&Index=%d&PageIndex=1&PageSize=100",userID,sessionID,storeID,index];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if ((!error)) {//发送请求成功
                NSError *parseError;
                id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                
                int error_code = [[dictionary objectForKey:@"error_code"] intValue];
                int recordCount = [[dictionary objectForKey:@"RecordCount"] intValue];
                if (error_code == 0) {
                    //新的通知已经获取，映射
                    NSString *recommendFlag = [dictionary objectForKey:@"RecommendFlag"];
                    DWORD myFlag[4] = {0};
                    myFlag[1] = (NSUInteger)[recommendFlag integerValue];
                    vP2PSetUpdateFlag(myFlag);
                    //RecommendFlag
                    [[NSUserDefaults standardUserDefaults] setObject:recommendFlag forKey:@"RecommendFlag"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                if (error_code == 0 && recordCount > 0) {//成功获取到数据，且RL不为空
                    NSString *RL = [dictionary objectForKey:@"RL"];
                    
                    NSArray *array = [RL componentsSeparatedByString:@";"];
                    
                    for(NSString *record in array){
                        if([record isEqualToString:@""]){
                            continue;
                        }
                        
                        NSArray *detailArray = [record componentsSeparatedByString:@","];
                        RecommendInfo * recommendInfo = [[RecommendInfo alloc] init];
                        
                        for (int i = 0; i < detailArray.count; i++) {
                            switch (i) {
                                case 0://database key
                                {
                                    recommendInfo.messageID = [detailArray[i] integerValue];
                                }
                                    break;
                                case 1:
                                {
                                    NSString *title = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                    recommendInfo.titleString = title;
                                }
                                    break;
                                case 2:
                                {
                                    NSString *content = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                    recommendInfo.contentString = content;
                                }
                                    break;
                                case 3:
                                {
                                    recommendInfo.imageURLString = detailArray[i];
                                }
                                    break;
                                case 4:
                                {
                                    NSString *imageLinkURLString = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                    recommendInfo.imageLinkURLString = imageLinkURLString;
                                }
                                    break;
                                case 5:
                                {
                                    //预览ID
                                }
                                    break;
                                case 6:
                                {
                                    recommendInfo.timeString = detailArray[i];
                                }
                                    break;
                                case 7:
                                {
                                    //状态
                                }
                                    break;
                            }
                        }
                        recommendInfo.isRead = NO;//YES表示已读
                        
                        //数据库的主键是唯一的，与主键相同的数据当然也插入不了。
                        RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
                        [recoDAO insert:recommendInfo];
                        //[recoDAO release];
                        //[recommendInfo release];
                    }
                    
                    //chenlei_changed
                    //新的通知已经获取，前台、后台推出告诉用户可以查看
                    
                    //需要做一些判断，有新的通知，则显示角标badge；查看新通知，清除角标
//                    MainController *mainController = [AppDelegate sharedDefault].mainController;
//                    mainController.bottomBar.isHavingNewInfo = YES;//显示、隐藏角标
//                    [mainController.bottomBar setNeedsLayout];
                    
                    //取出最新的一条记录，作为通知的推出内容
                    RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
                    NSArray *arr = [recoDAO findAll];
                    if (arr.count > 0) {
                        RecommendInfo *m = arr[0];//最新的一条记录
                        NSString *title = m.titleString;
                        //chenlei_changed
                        //if ([AppDelegate sharedDefault].isGoBack)
                        {
                            //创建一个本地推送
                            UILocalNotification *alarmNotify = [[UILocalNotification alloc] init];
                            //设置3秒之后,推送时间
                            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                            //设置时区
                            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
                            //推送声音
                            alarmNotify.soundName = @"default";
                            //内容
                            alarmNotify.alertBody = title;
                            //显示在icon上的红色圈中的数子
                            alarmNotify.applicationIconBadgeNumber = 1;
                            //定义查看通知的操作名
                            alarmNotify.alertAction = NSLocalizedString(@"open", nil);
                            //添加推送到uiapplication
                            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
                        }
                        
                        [MPNotificationView notifyWithText:NSLocalizedString(@"system_message", nil)  andDetail:title];
                    }
                    //[recoDAO release];
                }else{//获取数据失败
                    //[self.view makeToast:NSLocalizedString(@"get_data_fail", nil)];
                }
                
                
            }else{//发送请求失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.view makeToast:NSLocalizedString(@"send_request_fail", nil)];
                });
            }
        }];
    }
    
    //    //friends update
    //    if(pdwFlag[2] > dwMyFlag[2] || dwMyFlag[2] - pdwFlag[2] > 32767)
    //    {
    //
    //    }
    //
    //    //friends update
    //    if(pdwFlag[3] > dwMyFlag[3] || dwMyFlag[3] - pdwFlag[3] > 32767)
    //    {
    //        
    //    }
    //    
}

void commandSettingInAction(DWORD dwCmd, DWORD  dwOption , DWORD * pdwData,  DWORD  dwDataLen)
{
//    if (dwCmd == USR_CMD_REMOTLY_DEFENCE_CTL) {
//        if (dwOption == USR_CMD_OPTION_WRITE_DEFENCE_STATUS) {
//            DLog(@"NSNotificationCenter post");
//            //            [P2PClient sendNotificationMessage:pdwData[0]];
//            NSNumber *name   = [NSNumber numberWithInt:USR_CMD_REMOTLY_DEFENCE_CTL];
//            NSNumber *option = [NSNumber numberWithInt:USR_CMD_OPTION_WRITE_DEFENCE_STATUS];
//            NSNumber *value  = [NSNumber numberWithInt:pdwData[0]];
//            
//            NSDictionary *parameter = @{@"name": name,
//                                        @"option": option,
//                                        @"object" : value};
//            [[P2PClient sharedClient] receivePlayingCommand:parameter];
//            
//        }
//    }
    DLog(@"")
    if (dwCmd == USR_CMD_AUDIO_ONLY) {
        if (dwOption == 1) {
            DLog(@"开启");
        }else{
            DLog(@"关闭");
        }
        
        NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_CHANGE_VIDEO_STATE];
        NSNumber *value  = [NSNumber numberWithBool:dwOption];
        NSDictionary *parameter = @{@"key": key,
                                    @"value" : value};
        [[P2PClient sharedClient] receivePlayingCommand:parameter];
       
    }
    
    if (dwCmd == USR_CMD_CURRENT_USERS_NS) {
        //NSLog(@"%i",dwOption);
        NSNumber *value  = [NSNumber numberWithInt:dwOption];
        NSDictionary *parameter = @{@"value" : value};
        [[P2PClient sharedClient] receivePlayingCommand:parameter];
    }
    
    if (dwCmd == USR_CMD_PLAY_CTL) {
        
        DLog(@"%i",dwOption);
        switch (dwOption) {
            case USR_CMD_OPTION_FILE_INFO:
            {
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                vSetSupperDrop(FALSE);
                
                [[P2PClient sharedClient] setPlayback_startTime:(((uint64_t)pdwData[0]<<32)|pdwData[1])];
                [[P2PClient sharedClient] setPlayback_endTime:(((uint64_t)pdwData[2]<<32)|pdwData[3])];
                
                UINT64 totalTime = [[P2PClient sharedClient] playback_endTime] - [[P2PClient sharedClient] playback_startTime];
                [[P2PClient sharedClient] setPlayback_totalTime:totalTime];
                
                
                //UINT64 hh = playback_totalTime/3600;
                //UINT64 mm = (playback_totalTime/60)%60;
                //UINT64 ss = playback_totalTime%60;
                
                //DLog(@"%llu %llu %llu",hh,mm,ss);
            }
                break;
            case USR_CMD_OPTION_FILE_END:
            {
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
            }
                break;
            case USR_CMD_OPTION_STOP_RET:
            {
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
            }
                break;
            case USR_CMD_OPTION_PLAY_RET:
            {
                 vSetSupperDrop(FALSE);
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
               
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_START];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
            }
                break;
            case USR_CMD_OPTION_JUMP_RET:{
                 vSetSupperDrop(FALSE);
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_START];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
                break;
            }
            case USR_CMD_OPTION_NEXT_FILE_RET:{
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                vSetSupperDrop(FALSE);
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_START];
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
                break;
            }
            default:
                break;
        }
    }
    return;
}

- (void)receivePlayingCommand:(NSDictionary *)dictionary
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_PLAYING_CMD
                                                        object:self
                                                      userInfo:dictionary];
}

-(NSInteger)getPlaybackCurrentFileIndex{
    return playbackCurrentFileIndex;
}

-(NSInteger)getPlaybackFilesLength{
    return playbackFilesLength;
}

-(void)previous{
    if(playbackCurrentFileIndex==0){
        return;
    }
    
    [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
    NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
    NSDictionary *parameter = @{@"key": key};
    [[P2PClient sharedClient] receivePlayingCommand:parameter];
    BYTE prm[8];
    playbackCurrentFileIndex -= 1;
    memcpy(prm, &(playbackFiles[playbackCurrentFileIndex]), sizeof(sRecFilenameType));
    fgSendUserData(USR_CMD_PLAY_CTL, USR_CMD_OPTION_NEXT_FILE, prm, sizeof(sRecFilenameType));
    
}

-(void)next{
    if(playbackCurrentFileIndex>=(playbackFilesLength-1)){
        return;
    }
    
    [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
    NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
    NSDictionary *parameter = @{@"key": key};
    [[P2PClient sharedClient] receivePlayingCommand:parameter];
    
    BYTE prm[8];
    playbackCurrentFileIndex += 1;
    memcpy(prm, &(playbackFiles[playbackCurrentFileIndex]), sizeof(sRecFilenameType));
    fgSendUserData(USR_CMD_PLAY_CTL, USR_CMD_OPTION_NEXT_FILE, prm, sizeof(sRecFilenameType));
    vSetSupperDrop(TRUE);
}

-(void)jump:(UInt64)value{
    UInt64 jumpValue = (self.playback_startTime+value*1000000);
   

    fgSendUserData(USR_CMD_PLAY_CTL, USR_CMD_OPTION_JUMP, (BYTE*)(&jumpValue), sizeof(UInt64));
    vSetSupperDrop(TRUE);
}

-(void)p2pDisconnect{
    vP2PExit();
}

#define  FLAG_VIDEO_TRANS_QVGA 	 (0)  //
#define  FLAG_VIDEO_TRANS_HD     (1)  //
#define  FLAG_VIDEO_TRANS_VGA   (2)  //
-(void)p2pCallWithId:(NSString *)contactId password:(NSString*)password callType:(P2PCallType)type{
    self.p2pCallType = type;
    self.callId = contactId;
    if(!password){
        password = @"";
    }
    if (contactId)
    {
        UINT64 iCallId = [contactId intValue];
        if ([contactId hasPrefix:@"0"]){
            iCallId |= 0x80000000;
            
        }
        NSString *callMsg = @"test callMsg";
        DWORD dwCallPrm[4];
        switch (type) {
            case P2PCALL_TYPE_MONITOR:{
                dwCallPrm[0] = CONN_TYPE_MONITOR;
                dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
                dwCallPrm[2] = FLAG_VIDEO_TRANS_VGA ;
                dwCallPrm[3] = 0 ;
                
                
                if(fgP2PCall(iCallId, 1, [password intValue], dwCallPrm, (char *)[callMsg UTF8String])){
                    DLog(@"call success.");
                }else{
                    DLog(@"call failure.");
                }
                break;
            }
            case P2PCALL_TYPE_VIDEO:{
                
                dwCallPrm[0] = CONN_TYPE_VIDEO_CALL;
                dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
                dwCallPrm[2] = 0 ;
                dwCallPrm[3] = 0 ;
                
                fgP2PCall(iCallId, 0, 0, dwCallPrm, (char *)[callMsg UTF8String]);
                break;
            }
            
            default:
                break;
        }
        
    }

}

-(void)p2pPlaybackCallWithId:(NSString *)contactId password:(NSString *)password index:(NSInteger)index{
    if(index>=playbackFilesLength){
        return;
    }
    playbackCurrentFileIndex = index;
    self.p2pCallType = P2PCALL_TYPE_PLAYBACK;
    self.callId = contactId;
    if(!password){
        password = @"";
    }
    
    
    if (contactId)
    {
        UINT64 iCallId = [contactId intValue];
        if ([contactId hasPrefix:@"0"]){
            iCallId |= 0x80000000;
            
        }
        
        NSString *callMsg = @"";
        DWORD dwCallPrm[4];
        dwCallPrm[0] = CONN_TYPE_FILE_TRANS;
        dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
        dwCallPrm[2] = ((DWORD*)(&playbackFiles[index]))[0];
        dwCallPrm[3] = ((DWORD*)(&playbackFiles[index]))[1];
        
        fgP2PCall(iCallId, 1, [password intValue], dwCallPrm, (char *)[callMsg UTF8String]);
        
    }
}

- (void)p2pAccept {
    DWORD dwCallPrm[4];
    dwCallPrm[0] = CONN_TYPE_VIDEO_CALL;
    dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
    dwCallPrm[2] = 0 ;
    dwCallPrm[3] = 0 ;
    vP2PAccept(dwCallPrm);
}

- (void)p2pHungUp
{
    [[CameraManager sharedManager] stopCamera];
    vStopRecvAndDec();
    vStopAVEncAndSend();
    vP2PHungup(FALSE);
}

- (void)sendCommandType:(int)type andOption:(int)option
{
    fgSendUserData(type, option, NULL, 0);
}

- (void)startCall
{
    DLog(@"startCall.");
    [UIView animateWithDuration:0.1 animations:^{
        
        
    } completion:^(BOOL finished) {
        
        //srecAndDecPrm.dwConnectType = self.chattingCallType;
        //        srecAndDecPrm.dwConnectType = 1;
        
        _srecAndDecPrm.dwConnectType = self.p2pCallType;
        _srecAndDecPrm.vRecvAVData = vRecvAVData1;
        _srecAndDecPrm.vRecvAVHeader = vRecvAVHeader1;
        _srecAndDecPrm.vRecvUserDataCallBack = commandSettingInAction;
        if(fgStartRecvAndDec(&(_srecAndDecPrm))){
            vStopRecord();//初始停止录像
            DLog(@"fgStartRecvAndDec success.");
        }
        if (self.p2pCallType == P2PCALL_TYPE_VIDEO || self.p2pCallType == P2PCALL_TYPE_MONITOR) {
            fgStartAVEncAndSend(VIDEO_FRAME_RATE);
        }
    }];
    
}

#pragma mark
#pragma mark - p2p call back

void vCallingSignal(sCallingPrmType *sCallPrm) {
    unsigned int fgBCalled;
    unsigned int dwHisID;
    unsigned int dwDevType;
    unsigned int fgInSameDomain;
    unsigned int fgMonitorOnly;
    unsigned int dwRemoteChNs;
    
    fgBCalled = sCallPrm->fgBCalled;
    dwHisID = sCallPrm->dwHisID;
    dwDevType = sCallPrm->dwHisDevType;
    fgInSameDomain = sCallPrm->fgInSameDomain;
    fgMonitorOnly = sCallPrm->fgSuperCall;
    dwRemoteChNs = sCallPrm->dwRemoteChNs;
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    
    if(fgBCalled==1){
        [info setObject:[NSString stringWithFormat:@"%i",dwHisID&0x7fffffff] forKey:@"callId"];
        [info setObject:@"YES" forKey:@"isBCalled"];
    }else{
        //[info setObject:@"0" forKey:@"callId"];
        [info setObject:@"NO" forKey:@"isBCalled"];
    }
    
    [[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateCalling:) withObject:info waitUntilDone:YES];
}

void vRejectSignal(unsigned int fgBCalled,  unsigned int dwErrorOption)
{
    NSString *rejectMsg = nil;
	switch((int)dwErrorOption)
	{
		case CALL_ERROR_NONE:
		{
			rejectMsg = @"none";
			break;
		}
		case CALL_ERROR_DESID_NOT_ENABLE:
		{
			rejectMsg = @"id_disabled";
			break;
		}
		case CALL_ERROR_DESID_OVERDATE:
		{
			rejectMsg = @"id_overdate";
			break;
		}
		case CALL_ERROR_DESID_NOT_ACTIVE:
		{
			rejectMsg = @"id_inactived";
			break;
		}
		case CALL_ERROR_DESID_OFFLINE:
		{
			rejectMsg = @"offline";
			break;
		}
		case CALL_ERROR_DESID_BUSY:
		{
			rejectMsg = @"busy";
			break;
		}
		case CALL_ERROR_DESID_POWERDOWN:
		{
			rejectMsg = @"powerdown";
			break;
		}
		case CALL_ERROR_NO_HELPER:
		{
			rejectMsg = @"nohelper";
			break;
		}
		case CALL_ERROR_HANGUP:
		{
			rejectMsg = @"hungup";
			break;
		}
		case CALL_ERROR_TIMEOUT:
		{
			rejectMsg = @"timeout";
			break;
		}
		case CALL_ERROR_INTER_ERROR:
		{
			rejectMsg = @"internal_error";
			break;
		}
		case CALL_ERROR_RING_TIMEOUT:
		{
			rejectMsg = @"no_body";
			break;
		}
		case CALL_ERROR_PW_WRONG:
		{
			rejectMsg = @"pw_incrrect";
			break;
		}
        case CALL_ERROR_NOT_SUPPORT:
        {
            rejectMsg = @"not_support";
        }
		default:
			rejectMsg = @"none";
			break;
	}
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    NSNumber *errorFlag = [NSNumber numberWithInt:dwErrorOption];
    [info setObject:errorFlag forKey:@"errorFlag"];
    [[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateReject:) withObject:info waitUntilDone:YES];
    
}
#define       VIDEO_ABILITY_16_9        (1<<7)
void vAcceptSignal(unsigned int fgBCalled, unsigned int  *pdwPrm)
{

    BOOL is16b9 = NO;
    if(pdwPrm[0]==CONN_TYPE_MONITOR||pdwPrm[0]==CONN_TYPE_FILE_TRANS||pdwPrm[0]==CONN_TYPE_VIDEO_CALL){
        if(((pdwPrm[1] >> 24)& VIDEO_ABILITY_16_9 )||((pdwPrm[1] >> 16)& VIDEO_ABILITY_16_9 ))
        {
            is16b9 = YES;
        }
    }
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setObject:[NSNumber numberWithBool:is16b9] forKey:@"is16b9"];
    [[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateAccept:) withObject:info waitUntilDone:YES];
}

void vP2PConnReady(void)
{
    
	[[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateReady:) withObject:nil waitUntilDone:YES];
}





-(void)getContactsStates:(NSArray *)contacts{
    if(!contacts||[contacts count]==0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContactState" object:nil];
    }
    unsigned int tables[[contacts count]];
    for(int i=0;i<[contacts count];i++){
        
        NSString *contactId = [contacts objectAtIndex:i];
        if([contactId characterAtIndex:0]=='0'){
            tables[i] = contactId.intValue|0x80000000;
        }else{
            tables[i] = contactId.intValue;
        }
    }
    fgP2PGetFriendsStatus(tables, [contacts count]);
}

void   vFriendsStatusUpdate(sFriendsType * pFriends )
{
    int count = pFriends->dwFriendsCount;
    
    for(int i=0;i<count;i++){
        unsigned int state = (unsigned int)pFriends->bStatus[i]&0xf;
        unsigned int type = (unsigned int)pFriends->bType[i]&0xf;
        unsigned int iContactId = (unsigned int)pFriends->dwFriends[i]&0x7fffffff;
        NSString *contactId = nil;
        
        if(((unsigned int)pFriends->dwFriends[i]&0x80000000)!=0){
            contactId = [NSString stringWithFormat:@"0%d",iContactId];
        }else{
            contactId = [NSString stringWithFormat:@"%d",iContactId];
        }
        DLog("contactId:%@  onlineState:%i",contactId,state);
        FListManager *manager = [FListManager sharedFList];
        [manager setStateWithId:contactId state:state];
        
        if(state==1){
            [manager setTypeWithId:contactId type:type];
        }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContactState" object:nil];
    DLog(@"vFriendsStatusUpdate");
}

- (void)setDelegate:(id<P2PClientDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setPlaybackDelegate:(id<P2PPlaybackDelegate>)delegate{
    _playbackDelegate = delegate;
}

#pragma mark delegate method

//The selectors performed on main thread for delegate
- (void)delegateCalling:(NSDictionary*)info {
    NSString *isBCalled = [info objectForKey:@"isBCalled"];
    
    
    if([isBCalled isEqualToString:@"YES"]){
        NSString *callId = [info objectForKey:@"callId"];
        self.callId = callId;
        self.isBCalled = YES;
    }else{
        self.isBCalled = NO;
    }
    
    self.p2pCallState = P2PCALL_STATE_CALLING;
    if(self.isBCalled){
        self.p2pCallType = P2PCALL_TYPE_VIDEO;
    }
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientCalling:)]) {
            [self.delegate P2PClientCalling:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackCalling:)]) {
            [self.playbackDelegate P2PPlaybackCalling:info];
        }
    }
}
- (void)delegateReject:(NSDictionary*)info {
    
    if (self.p2pCallState == P2PCALL_STATE_READY) {
        
        [[PAIOUnit sharedUnit] stopAudio];
        [self p2pHungUp];
    }
    
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
//        Recent *recent = [[Recent alloc] init];
//        if(self.isBCalled){
//            if(self.p2pCallState==P2PCALL_STET_READY){
//                recent.callState = RECENT_CALLSTATE_CALLIN_ACCEPT;
//            }else{
//                recent.callState = RECENT_CALLSTATE_CALLIN_REJECT;
//            }
//        }else{
//            if(self.p2pCallState==P2PCALL_STET_READY){
//                recent.callState = RECENT_CALLSTATE_CALLOUT_ACCEPT;
//            }else{
//                recent.callState = RECENT_CALLSTATE_CALLOUT_REJECT;
//            }
//        }
//        
//        recent.callType = self.p2pCallType;
//        recent.contactId = self.callId;
//        recent.time = [NSString stringWithFormat:@"%d",[Utils getCurrentTimeInterval]];
//        RecentDAO *recentDAO = [[RecentDAO alloc] init];
//        [recentDAO insert:recent];
//        [recent release];
//        [recentDAO release];
        
    }
    self.p2pCallState = P2PCALL_STATE_NONE;
   
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientReject:)]) {
            [self.delegate P2PClientReject:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackReject:)]) {
            [self.playbackDelegate P2PPlaybackReject:info];
        }
    }
}
- (void)delegateAccept:(NSDictionary*)info {

    self.is16B9 = [[info valueForKey:@"is16b9"] intValue];
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientAccept:)]) {
            [self.delegate P2PClientAccept:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackAccept:)]) {
            [self.playbackDelegate P2PPlaybackAccept:info];
        }
    }
}

- (void)delegateReady:(NSDictionary*)info {

    self.p2pCallState = P2PCALL_STATE_READY;
    [[PAIOUnit sharedUnit] startAudioWithCallType:self.p2pCallType];
    [self performSelectorOnMainThread:@selector(startCall) withObject:nil waitUntilDone:YES];
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientReady:)]) {
            [self.delegate P2PClientReady:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackReady:)]) {
            [self.playbackDelegate P2PPlaybackReady:info];
        }
    }
}

/*********************************************************/
#define MESG_ID_GET_PLAYBACK_FILES 2000
#define MESG_ID_GET_PLAYBACK_FILES_BY_DATE 3000
#define MESG_ID_GET_DEVICE_TIME 4000
#define MESG_ID_SET_DEVICE_TIME 5000
#define MESG_ID_GET_NPC_SETTINGS 6000
#define MESG_ID_SET_VIDEO_FORMAT 7000
#define MESG_ID_SET_VIDEO_VOLUME 8000
#define MESG_ID_SET_DEVICE_PASSWORD 9000
#define MESG_ID_SET_BUZZER 10000
#define MESG_ID_SET_MOTION 11000
#define MESG_ID_GET_ALARM_EMAIL 12000
#define MESG_ID_SET_ALARM_EMAIL 13000
#define MESG_ID_GET_BIND_ACCOUNT 14000
#define MESG_ID_SET_BIND_ACCOUNT 15000
#define MESG_ID_SET_REMOTE_DEFENCE 16000
#define MESG_ID_SET_REMOTE_RECORD 17000
#define MESG_ID_SET_RECORD_TYPE 18000
#define MESG_ID_SET_RECORD_TIME 19000
#define MESG_ID_SET_RECORD_PLAN_TIME 20000
#define MESG_ID_SET_NET_TYPE 21000
#define MESG_ID_GET_WIFI_LIST 22000
#define MESG_ID_SET_WIFI 23000
#define MESG_ID_GET_DEFENCE_AREA_STATE 24000
#define MESG_ID_SET_DEFENCE_AREA_STATE 25000
#define MESG_ID_SET_INIT_PASSWORD 26000
#define MESG_ID_CHECK_DEVICE_UPDATE 27000
#define MESG_ID_SEND_MESSAGE 28000
#define MESG_ID_GET_DEFENCE_STATE 29000
#define MESG_ID_CANCEL_DEVICE_UPDATE 30000
#define MESG_ID_DO_DEVICE_UPDATE 31000
#define MESG_ID_GET_DEVICE_INFO 32000
#define MESG_ID_SEND_CUSTOM_CMD 33000
#define MESG_ID_SET_IMAGE_INVERSION 34000
#define MESG_ID_SET_AUTO_UPDATE 35000
#define MESG_ID_SET_HUMAN_INFRARED 36000
#define MESG_ID_SET_WIRED_ALARM_INPUT 37000
#define MESG_ID_SET_WIRED_ALARM_OUTPUT 38000
#define MESG_ID_SET_VISITOR_PASSWORD 39000
#define MESG_ID_SET_DEVICE_TIME_ZONE 40000
#define MESG_ID_GET_SDCARD_INFO 41000
#define MESG_ID_SET_SDCARD_INFO 42000
#define MESG_ID_GET_DEFENCE_SWITCH_STATE 43000
#define MESG_ID_SET_DEFENCE_SWITCH_STATE 44000

#pragma mark -  fgP2PSendRemoteMessage -> vRecvRemoteMessage
void  vSendMessageAck(DWORD dwDesID,DWORD dwMesgID, DWORD  dwError)
{
    NSNumber *result = [NSNumber numberWithInt:dwError];
    NSNumber *mesgId = [NSNumber numberWithInt:dwMesgID];
    if(dwMesgID<MESG_ID_GET_PLAYBACK_FILES&&dwMesgID>=(MESG_ID_GET_PLAYBACK_FILES-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_PLAYBACK_FILES];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_PLAYBACK_FILES_BY_DATE&&dwMesgID>=(MESG_ID_GET_PLAYBACK_FILES_BY_DATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_PLAYBACK_FILES];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEVICE_TIME&&dwMesgID>=(MESG_ID_GET_DEVICE_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEVICE_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEVICE_TIME&&dwMesgID>=(MESG_ID_SET_DEVICE_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEVICE_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_NPC_SETTINGS&&dwMesgID>=(MESG_ID_GET_NPC_SETTINGS-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_NPC_SETTINGS];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_VIDEO_FORMAT&&dwMesgID>=(MESG_ID_SET_VIDEO_FORMAT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_VIDEO_FORMAT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_VIDEO_VOLUME&&dwMesgID>=(MESG_ID_SET_VIDEO_VOLUME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_VIDEO_VOLUME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEVICE_PASSWORD&&dwMesgID>=(MESG_ID_SET_DEVICE_PASSWORD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEVICE_PASSWORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_BUZZER&&dwMesgID>=(MESG_ID_SET_BUZZER-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_BUZZER];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_MOTION&&dwMesgID>=(MESG_ID_SET_MOTION-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_MOTION];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_ALARM_EMAIL&&dwMesgID>=(MESG_ID_GET_ALARM_EMAIL-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_ALARM_EMAIL];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_ALARM_EMAIL&&dwMesgID>=(MESG_ID_SET_ALARM_EMAIL-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_ALARM_EMAIL];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_BIND_ACCOUNT&&dwMesgID>=(MESG_ID_GET_BIND_ACCOUNT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_BIND_ACCOUNT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_BIND_ACCOUNT&&dwMesgID>=(MESG_ID_SET_BIND_ACCOUNT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_BIND_ACCOUNT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_REMOTE_DEFENCE&&dwMesgID>=(MESG_ID_SET_REMOTE_DEFENCE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE];
        NSString *contactId = [NSString stringWithFormat:@"%i",dwDesID];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result,@"contactId":contactId};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_REMOTE_RECORD&&dwMesgID>=(MESG_ID_SET_REMOTE_RECORD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_RECORD_TYPE&&dwMesgID>=(MESG_ID_SET_RECORD_TYPE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_RECORD_TYPE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_RECORD_TIME&&dwMesgID>=(MESG_ID_SET_RECORD_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_RECORD_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_RECORD_PLAN_TIME&&dwMesgID>=(MESG_ID_SET_RECORD_PLAN_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_RECORD_PLAN_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_NET_TYPE&&dwMesgID>=(MESG_ID_SET_NET_TYPE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_NET_TYPE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_WIFI_LIST&&dwMesgID>=(MESG_ID_GET_WIFI_LIST-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_WIFI_LIST];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_WIFI&&dwMesgID>=(MESG_ID_SET_WIFI-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_WIFI];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEFENCE_AREA_STATE&&dwMesgID>=(MESG_ID_GET_DEFENCE_AREA_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEFENCE_AREA_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEFENCE_AREA_STATE&&dwMesgID>=(MESG_ID_SET_DEFENCE_AREA_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEFENCE_AREA_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEFENCE_AREA_STATE&&dwMesgID>=(MESG_ID_SET_DEFENCE_AREA_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_INIT_PASSWORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_CHECK_DEVICE_UPDATE&&dwMesgID>=(MESG_ID_CHECK_DEVICE_UPDATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_CHECK_DEVICE_UPDATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SEND_MESSAGE&&dwMesgID>=(MESG_ID_SEND_MESSAGE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SEND_MESSAGE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result,@"flag":mesgId};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEFENCE_STATE&&dwMesgID>=(MESG_ID_GET_DEFENCE_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEFENCE_STATE];
        NSString *contactId = [NSString stringWithFormat:@"%i",dwDesID];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result,@"contactId":contactId};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_DO_DEVICE_UPDATE&&dwMesgID>=(MESG_ID_DO_DEVICE_UPDATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_DO_DEVICE_UPDATE];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEVICE_INFO&&dwMesgID>=(MESG_ID_GET_DEVICE_INFO-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEVICE_INFO];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SEND_CUSTOM_CMD&&dwMesgID>=(MESG_ID_SEND_CUSTOM_CMD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_CUSTOM_CMD];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_IMAGE_INVERSION&&dwMesgID>=(MESG_ID_SET_IMAGE_INVERSION-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_IMAGE_INVERSION];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_AUTO_UPDATE&&dwMesgID>=(MESG_ID_SET_AUTO_UPDATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_AUTO_UPDATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_HUMAN_INFRARED&&dwMesgID>=(MESG_ID_SET_HUMAN_INFRARED-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_HUMAN_INFRARED];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_WIRED_ALARM_INPUT&&dwMesgID>=(MESG_ID_SET_WIRED_ALARM_INPUT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_WIRED_ALARM_OUTPUT&&dwMesgID>=(MESG_ID_SET_WIRED_ALARM_OUTPUT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_VISITOR_PASSWORD&&dwMesgID>=(MESG_ID_SET_VISITOR_PASSWORD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_VISITOR_PASSWORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEVICE_TIME_ZONE&&dwMesgID>=(MESG_ID_SET_DEVICE_TIME_ZONE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_TIME_ZONE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_SDCARD_INFO&&dwMesgID>=(MESG_ID_GET_SDCARD_INFO-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_SDCARD_INFO];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_SDCARD_INFO&&dwMesgID>=(MESG_ID_SET_SDCARD_INFO-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_SDCARD_INFO];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEFENCE_SWITCH_STATE&&dwMesgID>=(MESG_ID_GET_DEFENCE_SWITCH_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEFENCE_SWITCH_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEFENCE_SWITCH_STATE&&dwMesgID>=(MESG_ID_SET_DEFENCE_SWITCH_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEFENCE_SWITCH_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }

    

}
/*!
 *  一般消息回调
 */
void  vRecvRemoteMessage(DWORD dwSrcID,  unsigned int fgHasCheckdPassword, void *pMesg, DWORD dwMesgSize)
{
    BYTE *pMesgBuffer = (BYTE *)pMesg;
    DLog(@"vRecvRemoteMessage");
    
    if(pMesgBuffer[0]==MESG_TYPE_RET_REC_LIST){
        sMesgRetRecListType *sRetRec = (sMesgRetRecListType*)pMesg;
        
        if(sRetRec->bFileNs>128){
            return;
        }
        
        if(sRetRec->bFileNs==0){
            NSNumber *key = [NSNumber numberWithInt:RET_GET_PLAYBACK_FILES];
            NSArray *files = [NSArray arrayWithObjects:nil];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:files forKey:@"files"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
            
        }else{
            NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *times = [NSMutableArray arrayWithCapacity:0];
            playbackFilesLength = sRetRec->bFileNs;
            for(int i=0;i<sRetRec->bFileNs;i++){
                char buffer[64];
                memset(buffer, 0, 64);
                sprintf(buffer, "disc%d/%04d-%02d-%02d_%02d:%02d:%02d_%c.av",
                        sRetRec->sFileName[i].bMon>>4,
                        sRetRec->sFileName[i].wYear,
                        sRetRec->sFileName[i].bMon&0xf,
                        sRetRec->sFileName[i].bDay,
                        sRetRec->sFileName[i].bHour,
                        sRetRec->sFileName[i].bMin,
                        sRetRec->sFileName[i].bSec,
                        sRetRec->sFileName[i].cType);
                
                NSString *file = [NSString stringWithUTF8String:buffer];
                [files addObject:file];
                

                memcpy(playbackFiles, sRetRec->sFileName, sizeof(sRecFilenameType)*sRetRec->bFileNs);
            }
            

            for(int i=0;i<sRetRec->bFileNs;i++){
                char buffer[64];
                memset(buffer, 0, 64);
                sprintf(buffer, "%04d-%02d-%02d %02d:%02d",
                        sRetRec->sFileName[i].wYear,
                        sRetRec->sFileName[i].bMon&0xf,
                        sRetRec->sFileName[i].bDay,
                        sRetRec->sFileName[i].bHour,
                        sRetRec->sFileName[i].bMin);
                
                NSString *time = [NSString stringWithUTF8String:buffer];
                [times addObject:time];
                
                
                memcpy(playbackFiles, sRetRec->sFileName, sizeof(sRecFilenameType)*sRetRec->bFileNs);
            }
            

            NSNumber *key = [NSNumber numberWithInt:RET_GET_PLAYBACK_FILES];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:files forKey:@"files"];
            [parameter setValue:times forKey:@"times"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_DATETIME){
        sMesgDateTimeType *pDate = (sMesgDateTimeType*)pMesg;
        if(pDate->bOption==1){
           
        
            NSNumber *key = [NSNumber numberWithInt:RET_GET_DEVICE_TIME];
            NSString *time = [Utils getDeviceTimeByIntValue:pDate->sMesgSysTime.wYear month:pDate->sMesgSysTime.bMon day:pDate->sMesgSysTime.bDay hour:pDate->sMesgSysTime.bHour minute:pDate->sMesgSysTime.bMin];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:time forKey:@"time"];
        
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_DEVICE_TIME];
            NSNumber *result = [NSNumber numberWithInt:pDate->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_SETTING){
        sMessageSettingsType *pSetting = (sMessageSettingsType*)pMesg;
        pSetting->wSettingCount &= 0xff;
        if(pSetting->wSettingCount<=0){
            return;
        }
        for(int i=0;i<pSetting->wSettingCount;i++){
            if((pSetting->bOption&0xff)==1){
                if(pSetting->sSettings[i].dwSettingID==0){
                    
                }
                switch(pSetting->sSettings[i].dwSettingID){
                    case 0:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_REMOTE_DEFENCE];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        NSString *contactId = [NSString stringWithFormat:@"%i",dwSrcID];
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        [parameter setValue:contactId forKey:@"contactId"];
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                    break;
                    case 1:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_BUZZER];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 2:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_MOTION];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 3:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_RECORD_TYPE];
                        
                        NSNumber *type = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:type forKey:@"type"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                    break;
                    case 4:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_REMOTE_RECORD];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                    break;
                    case 5:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_RECORD_PLAN_TIME];
                        
                        NSNumber *time = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:time forKey:@"time"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 8:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_VIDEO_FORMAT];
                        
                        NSNumber *type = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:type forKey:@"type"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 11:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_RECORD_TIME];
                        
                        NSNumber *time = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:time forKey:@"time"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                    break;
                    case 13:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_NET_TYPE];
                        
                        NSNumber *type = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue&0xffff];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:type forKey:@"type"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 14:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_VIDEO_VOLUME];
                        
                        NSNumber *value = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:value forKey:@"value"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    
                    case 16:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_AUTO_UPDATE];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 17:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_HUMAN_INFRARED];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 18:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_WIRED_ALARM_INPUT];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 19:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_WIRED_ALARM_OUTPUT];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 20:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_TIME_ZONE];
                        
                        NSNumber *value = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:value forKey:@"value"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 24:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_IMAGE_INVERSION];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                }
            }else{
                switch(pSetting->sSettings[i].dwSettingID){
                    case 0:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_REMOTE_DEFENCE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                    break;
                    case 1:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_BUZZER];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 2:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_MOTION];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 3:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_RECORD_TYPE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                    break;
                    case 4:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_REMOTE_RECORD];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                    break;
                    case 5:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_RECORD_PLAN_TIME];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 8:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_VIDEO_FORMAT];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 9:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_DEVICE_PASSWORD];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 11:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_RECORD_TIME];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 13:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_NET_TYPE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 14:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_VIDEO_VOLUME];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    
                    case 16:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_AUTO_UPDATE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 17:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_HUMAN_INFRARED];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 18:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 19:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 20:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_TIME_ZONE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 21:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_VISITOR_PASSWORD];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 24:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_IMAGE_INVERSION];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                }
            }
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_EMIAL){
        sMesgEmailType *pEmail = (sMesgEmailType*)pMesg;
        if(pEmail->bOption==1){
            
            
            NSNumber *key = [NSNumber numberWithInt:RET_GET_ALARM_EMAIL];
            NSString *email = [NSString stringWithUTF8String:pEmail->cString];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:email forKey:@"email"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_ALARM_EMAIL];
            NSNumber *result = [NSNumber numberWithInt:pEmail->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_APPID){
        sMesgGSetAppIdType *pAppId = (sMesgGSetAppIdType*)pMesg;
        if(pAppId->bOption==1){
            
            
            NSNumber *key = [NSNumber numberWithInt:RET_GET_BIND_ACCOUNT];
            NSNumber *count = [NSNumber numberWithInt:pAppId->bAppIdCount];
            NSNumber *maxCount = [NSNumber numberWithInt:pAppId->bAppIdMAXCount];
            NSMutableArray *datas = [NSMutableArray arrayWithCapacity:0];
            if([count intValue]==1&&pAppId->dwAppId[0]==0){
            
            }else{
                for(int i=0;i<pAppId->bAppIdCount;i++){
                    [datas addObject:[NSNumber numberWithInt:pAppId->dwAppId[i]]];
                }
            }
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:count forKey:@"count"];
            [parameter setValue:maxCount forKey:@"maxCount"];
            [parameter setValue:datas forKey:@"datas"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_BIND_ACCOUNT];
            NSNumber *result = [NSNumber numberWithInt:pAppId->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_WIFILIST){
        sMesgGetWifiListType *pWifi = (sMesgGetWifiListType*)pMesg;
        sNpcWifiListType *sList = &(pWifi->sNpcWifiList);
        
        
        if(pWifi->bOption==1){
            NSNumber *key = [NSNumber numberWithInt:RET_GET_WIFI_LIST];
            NSMutableArray *types = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *names = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *strengths = [NSMutableArray arrayWithCapacity:0];
            NSNumber *count = [NSNumber numberWithInt:sList->bWifiApNs];
            NSNumber *currentIndex = [NSNumber numberWithInt:sList->wCurrentConnSSIDIndex];
            for(int i=0;i<sList->bWifiApNs;i++){
                BYTE data = sList->bEncTpSigLev[i];
                
                [types addObject:[NSNumber numberWithInt:(int)data>>4]];
                [strengths addObject:[NSNumber numberWithInt:(int)((data&0xf)&0xff)]];
                
                
                
            }
            
            
            
            char buffer[128];
            int n = 0;
            for(int i=0;i<pWifi->wLen;i++){
                if(sList->cAllESSID[i]!='\0'){
                    buffer[n] = sList->cAllESSID[i];
                    n++;
                }else{
                    buffer[n] = '\0';
                    if([NSString stringWithUTF8String:buffer]){
                        [names addObject:[NSString stringWithUTF8String:buffer]];
                    }else{
                        [names addObject:@"Error Name"];
                    }
                    
                    n = 0;
                }
            }
            
            
            
            
            if([names count]!=sList->bWifiApNs){
                DLog(@"WIFI LIST ERROR");
                return;
            }
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:types forKey:@"types"];
            [parameter setValue:names forKey:@"names"];
            [parameter setValue:strengths forKey:@"strengths"];
            [parameter setValue:count forKey:@"count"];
            [parameter setValue:currentIndex forKey:@"currentIndex"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_WIFI];
            NSNumber *result = [NSNumber numberWithInt:pWifi->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_ALARMCODE_STATUS){
        sMesgGetAlarmCodeType *pCode = (sMesgGetAlarmCodeType*)pMesg;
        
        
        
        if(pCode->bOption==1){
            NSNumber *key = [NSNumber numberWithInt:RET_GET_DEFENCE_AREA_STATE];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableArray *status = [NSMutableArray arrayWithCapacity:0];
            
            NSMutableArray *keyGroup = [NSMutableArray arrayWithCapacity:0];
            int keyValue = pCode->bAlarmKeySta;
            
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>0)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>1)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>2)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>3)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>4)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>5)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>6)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>7)&0x1)]];
            DLog(@"%i %i %i %i %i %i %i %i",[[keyGroup objectAtIndex:0] intValue],
                 [[keyGroup objectAtIndex:1] intValue],
                 [[keyGroup objectAtIndex:2] intValue],
                 [[keyGroup objectAtIndex:3] intValue],
                 [[keyGroup objectAtIndex:4] intValue],
                 [[keyGroup objectAtIndex:5] intValue],
                 [[keyGroup objectAtIndex:6] intValue],
                 [[keyGroup objectAtIndex:7] intValue]);
            [status addObject:keyGroup];
            for(int i=0;i<pCode->bAlarmCodeCount;i++){
                NSMutableArray *group = [NSMutableArray arrayWithCapacity:0];
                int value = pCode->bAlarmCodeSta[i];
                
                [group addObject:[NSNumber numberWithInt:((value>>0)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>1)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>2)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>3)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>4)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>5)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>6)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>7)&0x1)]];
                [status addObject:group];
                DLog(@"%i %i %i %i %i %i %i %i",[[group objectAtIndex:0] intValue],
                     [[group objectAtIndex:1] intValue],
                     [[group objectAtIndex:2] intValue],
                     [[group objectAtIndex:3] intValue],
                     [[group objectAtIndex:4] intValue],
                     [[group objectAtIndex:5] intValue],
                     [[group objectAtIndex:6] intValue],
                     [[group objectAtIndex:7] intValue]);
            }
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:status forKey:@"status"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_DEFENCE_AREA_STATE];
            NSNumber *result = [NSNumber numberWithInt:pCode->bOption];
            NSNumber *group = [NSNumber numberWithInt:(int)pCode->bAlarmCodeSta[0]];
            NSNumber *item = [NSNumber numberWithInt:(int)pCode->bAlarmCodeSta[4]];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [parameter setValue:group forKey:@"group"];
            [parameter setValue:item forKey:@"item"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_DEFENCE_SWITCH_STATE){
        sMesgGetDefenceSwitchType * pSwitchState = (sMesgGetDefenceSwitchType *)pMesg;
   
        if(pSwitchState->bOption==1){//表示获取成功
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSNumber *key = [NSNumber numberWithInt:RET_GET_DEFENCE_SWITCH_STATE];
            NSMutableArray *switchStatus = [NSMutableArray arrayWithCapacity:0];
            
            NSMutableArray *keyGroup = [NSMutableArray arrayWithCapacity:0];
            int keyValue = pSwitchState->bReserve;
            
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>0)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>1)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>2)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>3)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>4)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>5)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>6)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>7)&0x1)]];

            [switchStatus addObject:keyGroup];
            for(int i=0;i<pSwitchState->bDefenceSetSwitchCount;i++){
                NSMutableArray *group = [NSMutableArray arrayWithCapacity:0];
                int value = pSwitchState->bDefenceSetSwitch[i];
                
                [group addObject:[NSNumber numberWithInt:((value>>0)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>1)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>2)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>3)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>4)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>5)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>6)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>7)&0x1)]];
                
                [switchStatus addObject:group];

            }
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:switchStatus forKey:@"switchStatus"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else if (pSwitchState->bOption==0){//表示设置成功
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSNumber *key = [NSNumber numberWithInt:RET_SET_DEFENCE_SWITCH_STATE];
            NSNumber *result = [NSNumber numberWithInt:pSwitchState->bOption];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_INIT_PASSWD){
        sMesgSetInitPasswdType *pPassword = (sMesgSetInitPasswdType*)pMesg;
        
        NSNumber *key = [NSNumber numberWithInt:RET_SET_INIT_PASSWORD];
        NSNumber *result = [NSNumber numberWithInt:pPassword->bOption];
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0]==MESG_TYPE_UPG_CHEK_VERSION_RET){
        sMesgUpgType *pUpg = (sMesgUpgType*)pMesg;
        
        int iCurVersion = pUpg->sRemoteUpgMesg.dwUpgID;
        int iUpgVersion = pUpg->sRemoteUpgMesg.dwUpgVal;
        
        int a = iCurVersion&0xff;
        int b = (iCurVersion>>8)&0xff;
        int c = (iCurVersion>>16)&0xff;
        int d = (iCurVersion>>24)&0xff;
        
        int e = iUpgVersion&0xff;
        int f = (iUpgVersion>>8)&0xff;
        int g = (iUpgVersion>>16)&0xff;
        int h = (iUpgVersion>>24)&0xff;
        
        NSNumber *key = [NSNumber numberWithInt:RET_CHECK_DEVICE_UPDATE];
        NSNumber *result = [NSNumber numberWithInt:pUpg->bOption];
        NSString *curVersion = [NSString stringWithFormat:@"%i.%i.%i.%i",d,c,b,a];
        NSString *upgVersion = [NSString stringWithFormat:@"%i.%i.%i.%i",h,g,f,e];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:curVersion forKey:@"curVersion"];
        [parameter setValue:upgVersion forKey:@"upgVersion"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0]==MESG_TYPE_UPG_FILE_TO_DOWNLOAD_RET){
        sMesgUpgType *pUpg = (sMesgUpgType*)pMesg;
        
        
        NSNumber *key = [NSNumber numberWithInt:RET_DO_DEVICE_UPDATE];
        NSNumber *result = [NSNumber numberWithInt:pUpg->bOption];
        NSNumber *value = [NSNumber numberWithInt:pUpg->sRemoteUpgMesg.dwUpgVal];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:value forKey:@"value"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0]==MESG_TYPE_DEVICE_NOT_SUPPORT_RET){
        
        NSNumber *key = [NSNumber numberWithInt:RET_DEVICE_NOT_SUPPORT];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0]==MESG_TYPE_MESSAGE){
        
        NSNumber *key = [NSNumber numberWithInt:RET_RECEIVE_MESSAGE];
        
        sMesgStringMesgType *pMessage = (sMesgStringMesgType*)pMesg;
        
        if(pMessage->wLen<=0) return;
        
        pMessage->cString[pMessage->wLen] = 0;
        NSString *message = [NSString stringWithUTF8String:pMessage->cString];
        NSString *contactId = [NSString stringWithFormat:@"0%d",dwSrcID&0x7fffffff];
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:message forKey:@"message"];
        [parameter setValue:contactId forKey:@"contactId"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0]==MESG_TYPE_ALARM_CALL){
        sMesgAlarmInfoType *pAlarm = (sMesgAlarmInfoType*)pMesg;
        
        int isSupport = 0;
        if((pMesgBuffer[2]&0x1)==1){
            isSupport = 1;
        }else{
            isSupport = 0;
        }
        NSString *contactId = [NSString stringWithFormat:@"%i",dwSrcID];
        NSNumber *type = [NSNumber numberWithInt:pMesgBuffer[1]];
        NSNumber *isSupportExternAlarm = [NSNumber numberWithInt:isSupport];
        NSNumber *group = [NSNumber numberWithInt:pAlarm->sAlarmCodes.dwAlarmCodeID];
        NSNumber *item = [NSNumber numberWithInt:pAlarm->sAlarmCodes.dwAlarmCodeIndex];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:contactId forKey:@"contactId"];
        [parameter setValue:type forKey:@"type"];
        [parameter setValue:isSupportExternAlarm forKey:@"isSupportExternAlarm"];
        [parameter setValue:group forKey:@"group"];
        [parameter setValue:item forKey:@"item"];
        [[P2PClient sharedClient] receiveReceiveAlarmMessage:parameter];
        
        NSString *deviceId   = [parameter valueForKey:@"contactId"];
        int alarmType   = [[parameter valueForKey:@"type"] intValue];
        int alarmGroup   = [[parameter valueForKey:@"group"] intValue];
        int alarmItem   = [[parameter valueForKey:@"item"] intValue];
        
        Alarm * alarm = [[Alarm alloc]init];
        AlarmDAO * alarmDAO = [[AlarmDAO alloc]init];
        alarm.deviceId = deviceId;
        alarm.alarmTime = [NSString stringWithFormat:@"%ld",[Utils getCurrentTimeInterval]];
        alarm.alarmType = alarmType;
        alarm.alarmGroup = alarmGroup;
        alarm.alarmItem = alarmItem;
        
        NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
        NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
        BOOL isLocalAlarmRecord = [dic[@"isLocalAlarmRecord"] boolValue];
        if (isLocalAlarmRecord) {//YES则保存到本地
            [alarmDAO insert:alarm];
        }
        //[alarm release];
        //[alarmDAO release];

        
    }
    else if(pMesgBuffer[0]==MESG_TYPE_GET_SYS_VERSION_RET){
        sMesgSysVersionType *pVersion = (sMesgSysVersionType*)pMesg;
        int iCurVersion = pVersion->dwCurAppVersion;
        int iKernelVersion = pVersion->dwKernelVersion;
        int iRootfsVersion = pVersion->dwRootfsVersion;
        int iUbootVersion = pVersion->dwUbootVersion;
        int a = iCurVersion&0xff;
        int b = (iCurVersion>>8)&0xff;
        int c = (iCurVersion>>16)&0xff;
        int d = (iCurVersion>>24)&0xff;

        NSNumber *key = [NSNumber numberWithInt:RET_GET_DEVICE_INFO];
        NSNumber *result = [NSNumber numberWithInt:pVersion->bOption];
        NSString *curVersion = [NSString stringWithFormat:@"%i.%i.%i.%i",d,c,b,a];
        NSString *kernelVersion = [NSString stringWithFormat:@"%i",iKernelVersion];
        NSString *rootfsVersion = [NSString stringWithFormat:@"%i",iRootfsVersion];
        NSString *ubootVersion = [NSString stringWithFormat:@"%i",iUbootVersion];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:curVersion forKey:@"curVersion"];
        [parameter setValue:ubootVersion forKey:@"ubootVersion"];
        [parameter setValue:kernelVersion forKey:@"kernelVersion"];
        [parameter setValue:rootfsVersion forKey:@"rootfsVersion"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0]==MESG_TYPE_USER_CMD_RET){
        
        NSNumber *key = [NSNumber numberWithInt:RET_CUSTOM_CMD];
        
        sMesgStringMesgType *pMessage = (sMesgStringMesgType*)pMesg;
        
        if(pMessage->wLen<=0) return;
        
        pMessage->cString[pMessage->wLen] = 0;
        
        NSString *cmd = [NSString stringWithUTF8String:pMessage->cString];
        NSString *contactId = [NSString stringWithFormat:@"0%d",dwSrcID&0x7fffffff];
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:cmd forKey:@"cmd"];
        [parameter setValue:contactId forKey:@"contactId"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0] == MESG_TYPE_GET_SDCARD_INFO){
        sMesgSDCardInfoType * sSDCardInfo = (sMesgSDCardInfoType *)pMesg;
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        NSNumber *key = [NSNumber numberWithInt:RET_GET_SDCARD_INFO];
        [parameter setValue:key forKey:@"key"];
        
        NSString * result = [NSString stringWithFormat:@"%d",sSDCardInfo->bOption];
        [parameter setValue:result forKey:@"result"];
        
        if (sSDCardInfo->bOption == 1) {
            NSString * storageCount = [NSString stringWithFormat:@"%d",sSDCardInfo->wSDCardCount];
            [parameter setValue:storageCount forKey:@"storageCount"];
            
            int storageID;
            storageID = sSDCardInfo->sSDCard[0].bSDCardID;
            int storageType = storageID & 16;
            [parameter setValue:[NSString stringWithFormat:@"%d",storageType] forKeyPath:@"storageType"];
            
            if (storageType == SDCARD) {
                [parameter setValue:[NSString stringWithFormat:@"%d",storageID] forKeyPath:@"sdCardID"];
                
                NSString * sdTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDTotalSpace/(1024*1024)];
                [parameter setValue:sdTotalStorage forKey:@"sdTotalStorage"];
                NSString * sdFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDCardFreeSpace/(1024*1024)];
                [parameter setValue:sdFreeStorage forKey:@"sdFreeStorage"];
            }else{
                NSString * usbTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDTotalSpace/(1024*1024)];
                [parameter setValue:usbTotalStorage forKey:@"usbTotalStorage"];
                NSString * usbFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDCardFreeSpace/(1024*1024)];
                [parameter setValue:usbFreeStorage forKey:@"usbFreeStorage"];
            }
            
            if (sSDCardInfo->wSDCardCount > 1) {
                if (storageType == SDCARD) {
                    NSString * usbTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[1].u64SDTotalSpace/(1024*1024)];
                    [parameter setValue:usbTotalStorage forKey:@"usbTotalStorage"];
                    NSString * usbFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[1].u64SDCardFreeSpace/(1024*1024)];
                    [parameter setValue:usbFreeStorage forKey:@"usbFreeStorage"];
                }else{
                    NSString * sdTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDTotalSpace/(1024*1024)];
                    [parameter setValue:sdTotalStorage forKey:@"sdTotalStorage"];
                    NSString * sdFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDCardFreeSpace/(1024*1024)];
                    [parameter setValue:sdFreeStorage forKey:@"sdFreeStorage"];
                }
            }
        }else{//MESG_SDCARD_NO_EXIST
            //sd卡不存在
        }
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0] == MESG_TYPE_SET_FORMAT_SDCARD){
        sMesgSDCardFormatType * sSDCardFormat = (sMesgSDCardFormatType *)pMesg;
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        NSNumber *key = [NSNumber numberWithInt:RET_SET_SDCARD_FORMAT];
        [parameter setValue:key forKey:@"key"];
        NSNumber * result = [NSNumber numberWithInt:sSDCardFormat->bOption];
        [parameter setValue:result forKey:@"result"];
        
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
}

- (void)receiveReceiveAlarmMessage:(NSDictionary *)dictionary{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_ALARM_MESSAGE
                                                        object:self
                                                      userInfo:dictionary];
}

- (void)receiveReceiveRemoteMessage:(NSDictionary *)dictionary{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_REMOTE_MESSAGE
                                                        object:self
                                                      userInfo:dictionary];
}

- (void)ack_receiveReceiveRemoteMessage:(NSDictionary *)dictionary{
    [[NSNotificationCenter defaultCenter] postNotificationName:ACK_RECEIVE_REMOTE_MESSAGE
                                                        object:self
                                                      userInfo:dictionary];
}

-(void)getPlaybackFilesWithId:(NSString *)contactId password:(NSString *)password timeInterval:(NSInteger)interval{
    static int mesg_id = MESG_ID_GET_PLAYBACK_FILES-1000;
    if(mesg_id>=MESG_ID_GET_PLAYBACK_FILES){
        mesg_id = MESG_ID_GET_PLAYBACK_FILES-1000;
    }
    
    NSDateComponents *dateComponents = [Utils getNowDateComponents];
    
    int year = [dateComponents year];
    int month = [dateComponents month];
    int day = [dateComponents day];
    int hour = [dateComponents hour];
    int minute = [dateComponents minute];
    //int second = [dateComponents second];

    DLog(@"%i",mesg_id);
    
    
    sMesgGetRecListType sGetRec;
    if(day<interval){
        sGetRec.bCmd = MESG_TYPE_GET_REC_LIST;
        sGetRec.bOption = 0;
        sGetRec.wOption = 0;
        sGetRec.sBeginTime.wYear = year;
        sGetRec.sBeginTime.bMon = month-1;
        sGetRec.sBeginTime.bDay = interval-day;
        sGetRec.sBeginTime.bHour = hour;
        sGetRec.sBeginTime.bMin = minute;
    }else{
        sGetRec.bCmd = MESG_TYPE_GET_REC_LIST;
        sGetRec.bOption = 0;
        sGetRec.wOption = 0;
        sGetRec.sBeginTime.wYear = year;
        sGetRec.sBeginTime.bMon = month;
        sGetRec.sBeginTime.bDay = day-interval;
        sGetRec.sBeginTime.bHour = hour;
        sGetRec.sBeginTime.bMin = minute;
    }
    
    
    sGetRec.sEndTime.wYear = year;
    sGetRec.sEndTime.bMon = month;
    sGetRec.sEndTime.bDay = day;
    sGetRec.sEndTime.bHour = hour;
    sGetRec.sEndTime.bMin = minute;
    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sGetRec, sizeof(sMesgGetRecListType), NULL, 0, 0);
    mesg_id++;
    
}

-(void)getPlaybackFilesWithIdByDate:(NSString *)contactId password:(NSString *)password startDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    static int mesg_id = MESG_ID_GET_PLAYBACK_FILES_BY_DATE-1000;
    if(mesg_id>=MESG_ID_GET_PLAYBACK_FILES_BY_DATE){
        mesg_id = MESG_ID_GET_PLAYBACK_FILES_BY_DATE-1000;
    }
    
    NSDateComponents *startdateComponents = [Utils getDateComponentsByDate:startDate];
    
    int start_year = [startdateComponents year];
    int start_month = [startdateComponents month];
    int start_day = [startdateComponents day];
    int start_hour = [startdateComponents hour];
    //int start_minute = [startdateComponents minute];
    int start_second = [startdateComponents second];
    
    NSDateComponents *enddateComponents = [Utils getDateComponentsByDate:endDate];
    
    int end_year = [enddateComponents year];
    int end_month = [enddateComponents month];
    int end_day = [enddateComponents day];
    int end_hour = [enddateComponents hour];
    int end_minute = [enddateComponents minute];
    //int end_second = [enddateComponents second];
    
    
    sMesgGetRecListType sGetRec;
    sGetRec.bCmd = MESG_TYPE_GET_REC_LIST;
    sGetRec.bOption = 0;
    sGetRec.wOption = 0;
    sGetRec.sBeginTime.wYear = start_year;
    sGetRec.sBeginTime.bMon = start_month;
    sGetRec.sBeginTime.bDay = start_day;
    sGetRec.sBeginTime.bHour = start_hour;
    sGetRec.sBeginTime.bMin = start_second;
    
    
    sGetRec.sEndTime.wYear = end_year;
    sGetRec.sEndTime.bMon = end_month;
    sGetRec.sEndTime.bDay = end_day;
    sGetRec.sEndTime.bHour = end_hour;
    sGetRec.sEndTime.bMin = end_minute;
    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sGetRec, sizeof(sMesgGetRecListType), NULL, 0, 0);
    mesg_id++;

}

-(void)getDeviceTimeWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEVICE_TIME-1000;
    if(mesg_id>=MESG_ID_GET_DEVICE_TIME){
        mesg_id = MESG_ID_GET_DEVICE_TIME-1000;
    }
    sMesgDateTimeType sDate;
    sDate.bCmd = MESG_TYPE_GET_DATETIME;
    sDate.bOption = 0;
    sDate.wOption = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sDate, sizeof(sMesgDateTimeType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDeviceTimeWithId:(NSString *)contactId password:(NSString *)password year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute{
    static int mesg_id = MESG_ID_SET_DEVICE_TIME-1000;
    if(mesg_id>=MESG_ID_SET_DEVICE_TIME){
        mesg_id = MESG_ID_SET_DEVICE_TIME-1000;
    }
    sMesgDateTimeType sDate;
    sDate.bCmd = MESG_TYPE_SET_DATETIME;
    sDate.bOption = 0;
    sDate.wOption = 0;
    
    sDate.sMesgSysTime.wYear = year;
    sDate.sMesgSysTime.bMon = month;
    sDate.sMesgSysTime.bDay = day;
    sDate.sMesgSysTime.bHour = hour;
    sDate.sMesgSysTime.bMin = minute;
    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sDate, sizeof(sMesgDateTimeType), NULL, 0, 0);
    mesg_id++;
}

-(void)getSDCardInfoWithId:(NSString *)contactId password:(NSString *)password
{
    static int mesg_id = MESG_ID_GET_SDCARD_INFO - 1000;
    if (mesg_id >= MESG_ID_GET_SDCARD_INFO) {
        mesg_id = MESG_ID_GET_SDCARD_INFO - 1000;
    }
    
    sMesgSDCardInfoType sSDCardInfo;
    sSDCardInfo.bCommandType = MESG_TYPE_GET_SDCARD_INFO;
    sSDCardInfo.bOption = 0;
    sSDCardInfo.wSDCardCount = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSDCardInfo, sizeof(sMesgSDCardInfoType), NULL, 0, 0);
    mesg_id++;
}

-(void)setSDCardInfoWithId:(NSString *)contactId password:(NSString *)password sdcardID:(int)sdcardID
{
    static int mesg_id = MESG_ID_SET_SDCARD_INFO - 1000;
    if (mesg_id >= MESG_ID_SET_SDCARD_INFO) {
        mesg_id = MESG_ID_SET_SDCARD_INFO - 1000;
    }
    
    sMesgSDCardFormatType sSDCardFormat;
    sSDCardFormat.bCommandType = MESG_TYPE_SET_FORMAT_SDCARD;
    sSDCardFormat.bOption = 0;
    sSDCardFormat.wRemainByte = 0;
    sSDCardFormat.bSDCardID = sdcardID;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSDCardFormat, sizeof(sMesgSDCardFormatType), NULL, 0, 0);
    mesg_id++;
}

-(void)getNpcSettingsWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_NPC_SETTINGS-1000;
    if(mesg_id>=MESG_ID_GET_NPC_SETTINGS){
        mesg_id = MESG_ID_GET_DEVICE_TIME-1000;
    }
    BYTE pMessageBody[4];
    pMessageBody[0] = MESG_TYPE_GET_SETTING;
    pMessageBody[1] = 0;
    pMessageBody[2] = 0;
    pMessageBody[3] = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, pMessageBody, 4, NULL, 0, 0);
    mesg_id++;
}

-(void)getDefenceState:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEFENCE_STATE-1000;
    if(mesg_id>=MESG_ID_GET_DEFENCE_STATE){
        mesg_id = MESG_ID_GET_DEFENCE_STATE-1000;
    }
    BYTE pMessageBody[4];
    pMessageBody[0] = MESG_TYPE_GET_SETTING;
    pMessageBody[1] = 0;
    pMessageBody[2] = 0;
    pMessageBody[3] = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, pMessageBody, 4, NULL, 0, 0);
    mesg_id++;
}

-(void)setVideoFormatWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_VIDEO_FORMAT-1000;
    if(mesg_id>=MESG_ID_SET_VIDEO_FORMAT){
        mesg_id = MESG_ID_SET_VIDEO_FORMAT-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 8;
    sSetting.sSettings[0].dwSettingValue = type;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setVideoVolumeWithId:(NSString *)contactId password:(NSString *)password value:(NSInteger)value{
    static int mesg_id = MESG_ID_SET_VIDEO_VOLUME-1000;
    if(mesg_id>=MESG_ID_SET_VIDEO_VOLUME){
        mesg_id = MESG_ID_SET_VIDEO_VOLUME-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 14;
    sSetting.sSettings[0].dwSettingValue = value;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDevicePasswordWithId:(NSString *)contactId password:(NSString *)password newPassword:(NSString *)newPassword{
    
    static int mesg_id = MESG_ID_SET_DEVICE_PASSWORD-1000;
    if(mesg_id>=MESG_ID_SET_DEVICE_PASSWORD){
        mesg_id = MESG_ID_SET_DEVICE_PASSWORD-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 9;
    sSetting.sSettings[0].dwSettingValue = newPassword.intValue;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setVisitorPasswordWithId:(NSString *)contactId password:(NSString *)password newPassword:(NSString *)newPassword{
    static int mesg_id = MESG_ID_SET_VISITOR_PASSWORD-1000;
    if(mesg_id>=MESG_ID_SET_VISITOR_PASSWORD){
        mesg_id = MESG_ID_SET_VISITOR_PASSWORD-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 21;
    sSetting.sSettings[0].dwSettingValue = newPassword.intValue;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setBuzzerWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_BUZZER-1000;
    if(mesg_id>=MESG_ID_SET_BUZZER){
        mesg_id = MESG_ID_SET_BUZZER-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 1;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setMotionWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_MOTION-1000;
    if(mesg_id>=MESG_ID_SET_MOTION){
        mesg_id = MESG_ID_SET_MOTION-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 2;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setImageInversionWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_IMAGE_INVERSION-1000;
    if(mesg_id>=MESG_ID_SET_IMAGE_INVERSION){
        mesg_id = MESG_ID_SET_IMAGE_INVERSION-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 24;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}


-(void)setAutoUpdateWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_AUTO_UPDATE-1000;
    if(mesg_id>=MESG_ID_SET_AUTO_UPDATE){
        mesg_id = MESG_ID_SET_AUTO_UPDATE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 16;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setHumanInfraredWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_HUMAN_INFRARED-1000;
    if(mesg_id>=MESG_ID_SET_HUMAN_INFRARED){
        mesg_id = MESG_ID_SET_HUMAN_INFRARED-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 17;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setWiredAlarmInputWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_WIRED_ALARM_INPUT-1000;
    if(mesg_id>=MESG_ID_SET_WIRED_ALARM_INPUT){
        mesg_id = MESG_ID_SET_WIRED_ALARM_INPUT-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 18;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setWiredAlarmOutputWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_WIRED_ALARM_OUTPUT-1000;
    if(mesg_id>=MESG_ID_SET_WIRED_ALARM_OUTPUT){
        mesg_id = MESG_ID_SET_WIRED_ALARM_OUTPUT-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 19;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDeviceTimezoneWithId:(NSString *)contactId password:(NSString *)password value:(NSInteger)value{
    static int mesg_id = MESG_ID_SET_DEVICE_TIME_ZONE-1000;
    if(mesg_id>=MESG_ID_SET_DEVICE_TIME_ZONE){
        mesg_id = MESG_ID_SET_DEVICE_TIME_ZONE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 20;
    sSetting.sSettings[0].dwSettingValue = value;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)getAlarmEmailWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_ALARM_EMAIL-1000;
    if(mesg_id>=MESG_ID_GET_ALARM_EMAIL){
        mesg_id = MESG_ID_GET_ALARM_EMAIL-1000;
    }
    sMesgEmailType sEmail;
    sEmail.bCmd = MESG_TYPE_GET_EMIAL;
    sEmail.bOption = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sEmail, sizeof(sMesgEmailType), NULL, 0, 0);
    mesg_id++;
}

-(void)setAlarmEmailWithId:(NSString *)contactId password:(NSString *)password email:(NSString *)email{
    static int mesg_id = MESG_ID_SET_ALARM_EMAIL-1000;
    if(mesg_id>=MESG_ID_SET_ALARM_EMAIL){
        mesg_id = MESG_ID_SET_ALARM_EMAIL-1000;
    }
    sMesgEmailType sEmail;
    sEmail.bCmd = MESG_TYPE_SET_EMIAL;
    sEmail.bOption = 0;
    char *tempStr = (char *)[email UTF8String];
    memcpy(sEmail.cString,tempStr,strlen(tempStr));
    sEmail.cString[strlen(tempStr)] = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sEmail, sizeof(sMesgEmailType), NULL, 0, 0);
    mesg_id++;
}

-(void)getBindAccountWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_BIND_ACCOUNT-1000;
    if(mesg_id>=MESG_ID_GET_BIND_ACCOUNT){
        mesg_id = MESG_ID_GET_BIND_ACCOUNT-1000;
    }
    sMesgGSetAppIdType sAppId;
    sAppId.bCmd = MESG_TYPE_GET_APPID;
    sAppId.bOption = 0;
    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAppId, sizeof(sMesgGSetAppIdType), NULL, 0, 0);
    mesg_id++;
}
    
-(void)setBindAccountWithId:(NSString *)contactId password:(NSString *)password datas:(NSMutableArray *)datas{
    static int mesg_id = MESG_ID_SET_BIND_ACCOUNT-1000;
    if(mesg_id>=MESG_ID_SET_BIND_ACCOUNT){
        mesg_id = MESG_ID_SET_BIND_ACCOUNT-1000;
    }
    
    NSMutableArray *setDatas = [NSMutableArray arrayWithArray:datas];
    int count = [setDatas count];
    if(count==0){
        [setDatas addObject:[NSNumber numberWithInt:0]];
        count = 1;
    }
    int ids[count];
    
    for(int i=0;i<count;i++){
        NSNumber *bindId = [setDatas objectAtIndex:i];
        ids[i] = [bindId intValue];
    }
    BYTE buffer[256];
    sMesgGSetAppIdType *sAppId = (sMesgGSetAppIdType*)buffer;
    sAppId->bCmd = MESG_TYPE_SET_APPID;
    sAppId->bAppIdCount = count;
    memcpy(sAppId->dwAppId, ids, count*sizeof(int));
    int length = sizeof(sMesgGSetAppIdType)+(count-1)*sizeof(int);
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, sAppId, length, NULL, 0, 0);
    mesg_id++;
}
    
-(void)setRemoteDefenceWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_REMOTE_DEFENCE-1000;
    if(mesg_id>=MESG_ID_SET_REMOTE_DEFENCE){
        mesg_id = MESG_ID_SET_REMOTE_DEFENCE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 0;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}
    

-(void)setRemoteRecordWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_REMOTE_RECORD-1000;
    if(mesg_id>=MESG_ID_SET_REMOTE_RECORD){
        mesg_id = MESG_ID_SET_REMOTE_RECORD-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 4;
    sSetting.sSettings[0].dwSettingValue = state;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}
    
-(void)setRecordTypeWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_RECORD_TYPE-1000;
    if(mesg_id>=MESG_ID_SET_RECORD_TYPE){
        mesg_id = MESG_ID_SET_RECORD_TYPE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 3;
    sSetting.sSettings[0].dwSettingValue = type;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setRecordTimeWithId:(NSString *)contactId password:(NSString *)password value:(NSInteger)value{
    static int mesg_id = MESG_ID_SET_RECORD_TIME-1000;
    if(mesg_id>=MESG_ID_SET_RECORD_TIME){
        mesg_id = MESG_ID_SET_RECORD_TIME-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 11;
    sSetting.sSettings[0].dwSettingValue = value;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setRecordPlanTimeWithId:(NSString *)contactId password:(NSString *)password time:(NSInteger)time{
    static int mesg_id = MESG_ID_SET_RECORD_PLAN_TIME-1000;
    if(mesg_id>=MESG_ID_SET_RECORD_PLAN_TIME){
        mesg_id = MESG_ID_SET_RECORD_PLAN_TIME-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 5;
    sSetting.sSettings[0].dwSettingValue = time;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setNetTypeWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_NET_TYPE-1000;
    if(mesg_id>=MESG_ID_SET_NET_TYPE){
        mesg_id = MESG_ID_SET_NET_TYPE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 13;
    sSetting.sSettings[0].dwSettingValue = type;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)getWifiListWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_WIFI_LIST-1000;
    if(mesg_id>=MESG_ID_GET_WIFI_LIST){
        mesg_id = MESG_ID_GET_WIFI_LIST-1000;
    }
    sMesgGetWifiListType sWifi;
    sWifi.bCmd = MESG_TYPE_GET_WIFILIST;
    sWifi.bOption = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sWifi, sizeof(sMesgGetWifiListType), NULL, 0, 0);
    mesg_id++;
}

-(void)setWifiWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type name:(NSString *)name wifiPassword:(NSString *)wifiPassword{
    static int mesg_id = MESG_ID_SET_WIFI-1000;
    if(mesg_id>=MESG_ID_SET_WIFI){
        mesg_id = MESG_ID_SET_WIFI-1000;
    }
    sMesgSetWifiListType sWifi;
    sWifi.bCmd = MESG_TYPE_SET_WIFILIST;
    sWifi.bOption = 0;
    
    sWifi.sPhoneWifiInfo.dwEncType = type;
    memcpy(sWifi.sPhoneWifiInfo.cESSID, [name UTF8String], [name length]);
    memcpy(sWifi.sPhoneWifiInfo.cPassword, [wifiPassword UTF8String], [wifiPassword length]);
    
    sWifi.sPhoneWifiInfo.cESSID[[name length]] = 0;
    sWifi.sPhoneWifiInfo.cPassword[[wifiPassword length]] = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sWifi, sizeof(sMesgSetWifiListType), NULL, 0, 0);
    mesg_id++;
}

-(void)getDefenceAreaState:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEFENCE_AREA_STATE-1000;
    if(mesg_id>=MESG_ID_GET_DEFENCE_AREA_STATE){
        mesg_id = MESG_ID_GET_DEFENCE_AREA_STATE-1000;
    }
    sMesgGetAlarmCodeType sCode;
    sCode.bCmd = MESG_TYPE_GET_ALARMCODE_STATUS;
    sCode.bOption = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sCode, sizeof(sMesgGetAlarmCodeType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDefenceAreaState:(NSString *)contactId password:(NSString *)password group:(NSInteger)group item:(NSInteger)item type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_DEFENCE_AREA_STATE-1000;
    if(mesg_id>=MESG_ID_SET_DEFENCE_AREA_STATE){
        mesg_id = MESG_ID_SET_DEFENCE_AREA_STATE-1000;
    }
    sMesgSetAlarmCodeType sCode;
    sCode.bCmd = MESG_TYPE_SET_ALARMCODE_STATUS;
    sCode.bOption = 0;
    sCode.bSetAlarmCodeId = type;
    sCode.bAlarmCodeCount = 1;
    sCode.sAlarmCodes[0].dwAlarmCodeID = group;
    sCode.sAlarmCodes[0].dwAlarmCodeIndex = item;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sCode, sizeof(sMesgSetAlarmCodeType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 学习对码，添加启用或禁用开关
#pragma mark 获取启用或禁用开关
- (void) getDefenceSwitchStateWithId:(NSString *)contactId password:(NSString *)password
{
    static int mesg_id = MESG_ID_GET_DEFENCE_SWITCH_STATE - 1000;
    if (mesg_id >= MESG_ID_GET_DEFENCE_SWITCH_STATE) {
        mesg_id = MESG_ID_GET_DEFENCE_SWITCH_STATE - 1000;
    }
    
    sMesgGetDefenceSwitchType sGetDefenceSwitch;
    sGetDefenceSwitch.bCmd = MESG_TYPE_GET_DEFENCE_SWITCH_STATE;
    sGetDefenceSwitch.bOption = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sGetDefenceSwitch, sizeof(sMesgGetDefenceSwitchType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark 设置启用或禁用开关
- (void) setDefenceSwitchStateWithId:(NSString *)contactId password:(NSString *)password switchId:(int)switchId alarmCodeId:(int)alarmCodeId alarmCodeIndex:(int)alarmCodeIndex
{
    static int mesg_id = MESG_ID_SET_DEFENCE_SWITCH_STATE - 1000;
    if (mesg_id >= MESG_ID_SET_DEFENCE_SWITCH_STATE) {
        mesg_id = MESG_ID_SET_DEFENCE_SWITCH_STATE - 1000;
    }
    
    sMesgSetDefenceSwitchType sSetDefenceSwitch;
    sSetDefenceSwitch.bCmd = MESG_TYPE_SET_DEFENCE_SWITCH_STATE;
    sSetDefenceSwitch.bOption = 0;
    sSetDefenceSwitch.bSetDefenceSetSwitchId = switchId;
    sSetDefenceSwitch.sAlarmCodes[0].dwAlarmCodeID = alarmCodeId;
    sSetDefenceSwitch.sAlarmCodes[0].dwAlarmCodeIndex = alarmCodeIndex;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetDefenceSwitch, sizeof(sMesgSetDefenceSwitchType), NULL, 0, 0);
    mesg_id++;
}

-(void)setInitPasswordWithId:(NSString *)contactId initPassword:(NSString *)initPassword{
    static int mesg_id = MESG_ID_SET_INIT_PASSWORD-1000;
    if(mesg_id>=MESG_ID_SET_INIT_PASSWORD){
        mesg_id = MESG_ID_SET_INIT_PASSWORD-1000;
    }
    sMesgSetInitPasswdType sPassword;
    sPassword.bCmd = MESG_TYPE_SET_INIT_PASSWD;
    BYTE souceBuf[8];
    BYTE desBuf[8];
    BYTE key[8] = {0x9c, 0xae, 0x6a, 0x5a, 0xe1,0xfc,0xb0, 0x82};
    DWORD password = [initPassword intValue];
    memcpy(souceBuf, &password, sizeof(DWORD));
    
    des(souceBuf,desBuf,key,0);
    memcpy(sPassword.bPasswd, desBuf, 8);
    
    fgP2PSendRemoteMessage(contactId.intValue, 0, mesg_id, &sPassword, sizeof(sMesgSetInitPasswdType), NULL, 0, 0);
    mesg_id++;
}


-(void)checkDeviceUpdateWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_CHECK_DEVICE_UPDATE-1000;
    if(mesg_id>=MESG_ID_CHECK_DEVICE_UPDATE){
        mesg_id = MESG_ID_CHECK_DEVICE_UPDATE-1000;
    }
    sMesgUpgType sUpg;
    sUpg.bCmd = MESG_TYPE_UPG_CHEK_VERSION;
    sUpg.sRemoteUpgMesg.dwUpgVal = 1;
    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sUpg, sizeof(sMesgUpgType), NULL, 0, 0);
    mesg_id++;
}

-(void)doDeviceUpdateWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_DO_DEVICE_UPDATE-1000;
    if(mesg_id>=MESG_ID_DO_DEVICE_UPDATE){
        mesg_id = MESG_ID_DO_DEVICE_UPDATE-1000;
    }
    sMesgUpgType sUpg;
    sUpg.bCmd = MESG_TYPE_UPG_FILE_TO_DOWNLOAD;

    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sUpg, sizeof(sMesgUpgType), NULL, 0, 0);
    mesg_id++;
}

-(void)cancelDeviceUpdateWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_CANCEL_DEVICE_UPDATE-1000;
    if(mesg_id>=MESG_ID_CANCEL_DEVICE_UPDATE){
        mesg_id = MESG_ID_CANCEL_DEVICE_UPDATE-1000;
    }
    sMesgUpgType sUpg;
    sUpg.bCmd = MESG_TYPE_UPG_FILE_CANCEL_DOWNLOAD;
    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sUpg, sizeof(sMesgUpgType), NULL, 0, 0);
    mesg_id++;
}

-(NSInteger)sendMessageToFriend:(NSString *)contactId message:(NSString *)message{
    static int mesg_id = MESG_ID_SEND_MESSAGE-1000;
    if(mesg_id>=MESG_ID_SEND_MESSAGE){
        mesg_id = MESG_ID_SEND_MESSAGE-1000;
    }
    
    char *messageStr = (char*)[message UTF8String];
    int length = strlen(messageStr);
    
    if(!message||length<=0||length>1024){
        return -1;
    }
    
    
    
    
    sMesgStringMesgType sMessage;
    
    sMessage.bCmd = MESG_TYPE_MESSAGE;
    sMessage.bOption = 0;
    sMessage.wLen = length;
    
    memcpy(sMessage.cString, messageStr, length);
    mesg_id++;
    fgP2PSendRemoteMessage(contactId.intValue|0x80000000, 0, mesg_id, &sMessage, length+4, sMessage.cString, length, (DWORD)PUSH_MESG_FRIEND);
    return mesg_id;
}

-(void)getDeviceInfoWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEVICE_INFO-1000;
    if(mesg_id>=MESG_ID_GET_DEVICE_INFO){
        mesg_id = MESG_ID_GET_DEVICE_INFO-1000;
    }
    sMesgSysVersionType sVersion;
    sVersion.bCmd = MESG_TYPE_GET_SYS_VERSION;

    
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sVersion, sizeof(sMesgSysVersionType), NULL, 0, 0);
    mesg_id++;
}

-(NSInteger)sendCustomCmdWithId:(NSString *)contactId password:(NSString *)password cmd:(NSString *)cmd{
    static int mesg_id = MESG_ID_SEND_CUSTOM_CMD-1000;
    if(mesg_id>=MESG_ID_SEND_CUSTOM_CMD){
        mesg_id = MESG_ID_SEND_CUSTOM_CMD-1000;
    }
    
    char *cmdStr = (char*)[cmd UTF8String];
    int length = strlen(cmdStr);
    
    if(length<=0||length>1024){
        return -1;
    }
    
    sMesgStringMesgType sMessage;
    
    sMessage.bCmd = MESG_TYPE_USER_CMD;
    sMessage.bOption = 0;
    sMessage.wLen = length;
    
    memcpy(sMessage.cString, cmdStr, length);
    mesg_id++;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sMessage, length+4, sMessage.cString, length, (DWORD)PUSH_MESG_FRIEND);
    return mesg_id;
}

#pragma mark - 判断是否是关键帧
-(BOOL) isKeyFrame:(BYTE*) pVideoData
{
    BOOL bIFrame = FALSE;
    sH264NaluHeader* pH264NaluHder = (sH264NaluHeader*) pVideoData;
    if( (pH264NaluHder->dwFlag == 0x1000000)
       && (((pH264NaluHder->bNalu_Type&0x1F) == 0x07) || ((pH264NaluHder->bNalu_Type&0x1F) == 0x05)))  ////0x07:SPS	0x05:I-Pic	 0x01:P/B pic
    {
        bIFrame = TRUE;
    }
    return bIFrame;
}

void vRecvAVHeader1(sAVInfoType * pAVInfo)
{
    g_dwFrameRate = pAVInfo->videoFrameRate;
    g_dwVideoHeight = pAVInfo->VideoHeight;
    g_dwVideoWidth = pAVInfo->VideoWidth;
    
    g_countFrame = 0;
    g_isNeedKeyFrame = YES;
    
    WORD bitWidth[] = {8, 16, 32};
    WORD sampleRate[] = {8000, 11000, 16000, 22000, 24000, 32000, 44000, 48000};
    int channel[] = {1, 2};
    
    g_channel = channel[pAVInfo->AudioMode];
    g_sampleRate = sampleRate[pAVInfo->AudioSampleRate];
    g_bitWidth = bitWidth[pAVInfo->AudioBitWidth];

    
    /*if (g_mp4FileHandle != MP4_INVALID_FILE_HANDLE) {
        MP4SetTimeScale(g_mp4FileHandle, 1000);
            }*/

    
    /*P2PClient *client = [P2PClient sharedClient];
    BOOL startRecord = client.startRecord;
    if(!startRecord)
    {
        
        return;
    }else
    {
        char* string = "isomiso2avc1mp41";
        if(g_mp4FileHandle == MP4_INVALID_FILE_HANDLE)
            g_mp4FileHandle = MP4CreateEx([client.recordFileName UTF8String], 0, 1, 0, "iosm", 0x00000200, &string, 4);
    }*/
    
    /*if (g_mp4FileHandle != MP4_INVALID_FILE_HANDLE) {
        MP4Close(g_mp4FileHandle, 0);
        g_mp4FileHandle = MP4_INVALID_FILE_HANDLE;
    }*/
    
}


void vRecvAVData1(BYTE *pAudioData, DWORD dwAudioDataLen, DWORD dwFrames, UINT64 u64APTS, BYTE *pVideoData, DWORD dwVideoLen,  UINT64 u64VPTS)
{
    if (g_mp4FileHandle == MP4_INVALID_FILE_HANDLE) {
        return;
    }
    
    if (dwVideoLen != 0)
    {
        BOOL isKeyFrame = [[P2PClient sharedClient] isKeyFrame:pVideoData];
        if (g_isNeedKeyFrame) {
            if (!isKeyFrame) {
                return;
            }
            else
            {
                NSLog(@"关键帧");
                //video
                BYTE* pNualData1 = pVideoData+4;
                BYTE* pNualData2 = pVideoData+18;
                g_trackIdVideo = MP4AddH264VideoTrack(g_mp4FileHandle, g_timeScalVideo, MP4_INVALID_DURATION, g_dwVideoWidth, g_dwVideoHeight, pNualData1[1], pNualData1[2], pNualData1[3], 3);
                if (g_trackIdVideo == MP4_INVALID_TRACK_ID) {
                    MP4Close(g_mp4FileHandle, 0);
                    g_mp4FileHandle = MP4_INVALID_FILE_HANDLE;
                    return;
                }
                MP4SetVideoProfileLevel(g_mp4FileHandle, 0x7f);
                MP4AddH264SequenceParameterSet(g_mp4FileHandle, g_trackIdVideo, (const uint8_t*)pNualData1, 10);
                MP4AddH264PictureParameterSet(g_mp4FileHandle, g_trackIdVideo, (const uint8_t*)pNualData2, 4);
                
                //audio
                g_hFaacEncoder = faacEncOpen(g_sampleRate, g_channel, &g_inputSamples, &g_maxOutputBytes);
                faacEncConfigurationPtr pConfiguration = faacEncGetCurrentConfiguration(g_hFaacEncoder);
                if (pConfiguration->version != FAAC_CFG_VERSION) {
                    NSLog(@"faacEncGetCurrentConfiguration failed");
                    return;
                }
                
                if (!pConfiguration) {
                    NSLog(@"faacEncGetCurrentConfiguration failed");
                    return;
                }
                
                pConfiguration->version = MPEG4;
                pConfiguration->aacObjectType = LOW;
                pConfiguration->inputFormat = FAAC_INPUT_16BIT;
                pConfiguration->outputFormat = 0;     // (0 = Raw; 1 = ADTS)录制MP4文件时，要用raw流。检验编码是否正确时可设置为 adts传输流，
                pConfiguration->shortctl = SHORTCTL_NORMAL;
                pConfiguration->useTns = 1;
                pConfiguration->quantqual = 100;
                pConfiguration->bandWidth = 0;
                pConfiguration->bitRate = 0;
                pConfiguration->allowMidside = 1;
                faacEncSetConfiguration(g_hFaacEncoder, pConfiguration);
                
                g_trackIdAudio = MP4AddAudioTrack(g_mp4FileHandle, g_timeScalAudio, MP4_INVALID_DURATION, MP4_MPEG4_AUDIO_TYPE);
                if (g_trackIdAudio == MP4_INVALID_TRACK_ID) {
                    MP4Close(g_mp4FileHandle, 0);
                    g_mp4FileHandle = MP4_INVALID_FILE_HANDLE;
                    return;
                }
                
                MP4SetAudioProfileLevel(g_mp4FileHandle, 0x2);
                
                unsigned char* faacDecoderInfo = NULL;
                unsigned long  faacDecoderInfoSize = 0;
                int ret = faacEncGetDecoderSpecificInfo(g_hFaacEncoder, &faacDecoderInfo, &faacDecoderInfoSize);
                if (ret != 0)
                {
                    NSLog(@"faacEncGetDecoderSpecificInfo failed");
                }
                
                if (!MP4SetTrackESConfiguration(g_mp4FileHandle, g_trackIdAudio, faacDecoderInfo, faacDecoderInfoSize))
                {
                    NSLog(@"MP4SetTrackESConfiguration failed");
                }
                free( faacDecoderInfo );
                
                g_pDecoder = Decoder_Interface_init();
                
                g_pDatePCM = (BYTE*)malloc(1024*8);
                
                g_isNeedKeyFrame = NO;
            }
        }
        if (g_trackIdVideo != MP4_INVALID_TRACK_ID)
        {
            if (NO == isKeyFrame) {
                BYTE* data = (BYTE*)malloc(dwVideoLen);
                data[0] = (dwVideoLen-4) >> 24;
                data[1] = (dwVideoLen-4) >> 16;
                data[2] = (dwVideoLen-4) >> 8;
                data[3] = (dwVideoLen-4) & 0xff;
                memcpy(data+4, pVideoData+4, dwVideoLen-4);
                MP4WriteSample(g_mp4FileHandle, g_trackIdVideo, data, dwVideoLen, g_timeScalVideo/g_dwFrameRate, 0, 1);
                free(data);
            }
            else
            {
                BYTE* data1 = (BYTE*)malloc(9);
                data1[0] = 5 >> 24;         //除以24次2
                data1[1] = 5 >> 16;
                data1[2] = 5 >> 8;
                data1[3] = 5 & 0xff;
                int * value = (int*)data1;
                NSLog(@"data1 = %d, %d, %d, %d, length = %d", data1[0], data1[1], data1[2], data1[3], 5);
                memcpy(data1+4, pVideoData+22, 5);
                MP4WriteSample(g_mp4FileHandle, g_trackIdVideo, data1, 9, g_timeScalVideo/g_dwFrameRate, 0, 1);
                free(data1);
                
                BYTE* data2 = (BYTE*)malloc(dwVideoLen-31);
                data2[0] = (dwVideoLen-35) >> 24;
                data2[1] = (dwVideoLen-35) >> 16;
                data2[2] = (dwVideoLen-35) >> 8;
                data2[3] = (dwVideoLen-35) & 0xff;
                value = (int*)data2;
                NSLog(@"data2 = %d, %d, %d, %d, length = %d", data2[0], data2[1], data2[2], data2[3], dwVideoLen-35);
                
                memcpy(data2+4, pVideoData+35, dwVideoLen-35);
                MP4WriteSample(g_mp4FileHandle, g_trackIdVideo, data2, dwVideoLen-31, g_timeScalVideo/g_dwFrameRate, 0, 1);
                free(data2);
            }
            
            /*if (g_countFrame == TOTAL_RECORD_FRAME)
            {
                MP4Close(g_mp4FileHandle, 0);
                g_mp4FileHandle = MP4_INVALID_FILE_HANDLE;
                g_countFrame = 0;
                
            }*/
            g_countFrame++;
            if (g_countFrame % 10 == 0) {
                NSLog(@"record %d frames", g_countFrame);
            }
        }
    }
    
    int inputBytes = g_inputSamples*(16/8);
    if (dwFrames != 0 && g_isNeedKeyFrame == NO)
    {
        for (int i=0; i<dwFrames; i++)
        {
            Decoder_Interface_Decode(g_pDecoder, pAudioData+i*32, (short*)(g_pDatePCM+g_dwPosPcm), 0);
            g_dwPosPcm += 320;
        }
        
        int posTemp = 0;
        BOOL isEncode = NO;
        while (g_dwPosPcm >= (posTemp+inputBytes))
        {
            isEncode = YES;
            BYTE buffAAC[768] = {0};
            int ret = faacEncEncode(g_hFaacEncoder, (int*)(g_pDatePCM+posTemp), g_inputSamples, buffAAC, g_maxOutputBytes);
            
            //write
            uint64_t duration = (g_timeScalAudio*inputBytes*20)/(320*1000);
            if (ret)
            {
                MP4WriteSample(g_mp4FileHandle, g_trackIdAudio, (BYTE*)&buffAAC, ret, duration, 0, 1);
                NSLog(@"write aac %d byte， duation = %lld", ret, duration);
            }
            
            posTemp += inputBytes;
            
        }
        
        //编码之后
        if (g_dwPosPcm > posTemp && isEncode)
        {
            int lenReamin = g_dwPosPcm - posTemp;
            BYTE* buffRemain = (BYTE*)malloc(g_dwPosPcm-posTemp);
            memcpy(buffRemain, g_pDatePCM+posTemp, lenReamin);
            memcpy(g_pDatePCM, buffRemain, lenReamin);
            g_dwPosPcm = lenReamin;
        }
    }
}


#pragma mark - add by youyoujushi 
//返回接收回放文件数组的地址
-(void*)getPlaybackFilenameTypeCArray{
    return playbackFiles;
}

//停止录像
-(void)stopRecord{
    _startRecord = NO;
    if(g_mp4FileHandle != MP4_INVALID_FILE_HANDLE)
    {
        MP4Close(g_mp4FileHandle, 0);
        g_mp4FileHandle = MP4_INVALID_FILE_HANDLE;
    }
    self.recordFileName = nil;
}

//创建录像文件
-(void)createRecordFile{
    NSString* userId =[UDManager getLoginInfo].contactId;
    NSString* contactId = [[P2PClient sharedClient] callId];
    
    if(self.recordFileName == nil)
        self.recordFileName = [Utils getRecordPathWithUserId:userId contactId:contactId];
    
    char* string = "isomiso2avc1mp41";
    if(g_mp4FileHandle == MP4_INVALID_FILE_HANDLE)
        g_mp4FileHandle = MP4CreateEx([_recordFileName UTF8String], 0, 1, 0, "iosm", 0x00000200, &string, 4);
    if(g_mp4FileHandle != MP4_INVALID_FILE_HANDLE)
        MP4SetTimeScale(g_mp4FileHandle, 1000);
}

@end
