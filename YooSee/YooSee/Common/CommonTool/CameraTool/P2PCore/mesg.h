#ifndef __MESG_H_
#define __MESG_H_


#define MAXTYPE_ALARM         8
#define MAX_EMAIL_LEN         32
#define MAX_WIFI_SSID_LEN     128
#define MAX_WIFI_PASSWORD_LEN 128
#define MAX_MESSAGE_LEN 1024


#import "P2PCInterface.h"//door ring push
//setting ID
enum
{
  MESG_STTING_ID_DEFENCE,//0 off ; 1 on
  MESG_STTING_ID_BUZZER,  //0 off; 1 on
  MESG_STTING_ID_MOTION_DECT, //0 off; 1 on
  MESG_STTING_ID_RECORD_TYPE, //0 Manual; 1 alarm; 2 schedule
  MESG_STTING_ID_M_RECORD_ON, // 0 off; 1 on
  MESG_STTING_ID_REC_SCHEDULE, //
  MESG_STTING_ID_REC_STATUS,   //0 off ; 1 on
  MESG_STTING_ID_SOS,          //0 off ; 1 on
    
    MESG_STTING_ID_FORMAT,   //0 PAL, 1  NTSC
    MESG_STTING_ID_PASSWD,  //  buzuo shit bitch
    
    MESG_STTING_ID_APP,
    MESG_STTING_ID_ALARM_TIME, //  (==11)
    
    
    
    MESG_STTING_ID_IPSEL,         //(== 12)
    MESG_STTING_ID_NETSEL,       // 13 //高两位 1只有有线 2只有WIFI 3两者都有 低两个字节
    
    MESG_STTING_ID_VOL,           // 14
    
    MESG_STTING_ID_PIC_REVERSE, //  15
    
    
    MESG_STTING_ID_NUM,
    
    MESG_SETTING_ID_FOCUS_ZOOM=38,//38//0都没有;1只有变倍;2只有变焦;3变倍变焦都有
    
    MESG_STTING_ID_MAX  = 0xFF,
    
  
};

enum{
    MESG_SET_OK,  // 0
    MESG_GET_OK,  // 1
    
    MESG_SET_DEFENCE_ERR,         // 2
    MESG_SET_BUZZER_ERR,           // 3
    MESG_SET_MOTION_DECT_ERR,     // 4
    MESG_SET_RECORD_TYPE_ERR,       // 5
	MESG_SET_M_RECORD_ON_ERR,    // 6
	MESG_SET_REC_SCHEDULE_ERR,  // 7
	MESG_SET_REC_STATUS_ERR,  // 8
	MESG_SET_SOS_ERR,           // 9
	MESG_SET_FORMAT_ERR,    // 10
	MESG_SET_PASSWD_ERR,   // 11
	MESG_SET_APP_ERR,			// 12
	MESG_SET_ALARM_TIME_ERR,   // 13
	MESG_SET_DATETIME_ERR,  // 14
	MESG_SET_EMAIL_ERR,  // 15,
    
	MESG_SET_ID_IPSEL_ERR, // 16
	MESG_SET_ID_NETSEL_ERR,  // 17
    
	MESG_SET_ID_NOTWIFI_ERR, // 18
	MESG_SET_ID_WIFI_SIZE_ERR,  // 19
	MESG_SET_ID_WIFI_PASSWDLEN_ERR,  // 20
	MESG_SET_ID_WIFI_NOMATCHNAME_ERR, // 21
	
    
	MESG_SET_ID_VOL_ERR,          // 22
    
	MESG_SET_ID_ALARMCODE_ERR,   // 23
	MESG_SET_ID_LEARN_ALARMCODE_EXIST,           // 24
	MESG_SET_ID_LEARN_ALARMCODE_LEARNING,        // 25
	MESG_SET_ID_LEARN_ALARMCODE_TIMEOUT,         // 26
	MESG_SET_ID_LEARN_ALARMCODE_OTHER_RESON,     // 27
	MESG_SET_ID_CLEAR_ALARMCODE_FAIL_ERR,        // 28
	MESG_SET_ID_CLEAR_ALARMCODE_LEARNING,        // 29
	MESG_SET_ID_CLEAR_ALARMCODE_CLEAR_YET,       // 30
	MESG_SET_ID_CLEAR_ALARMCODE_OTHER_RESON,     // 31
    
	MESG_SET_ID_LEARN_HAV_SAME_RECORD,         // 32
	MESG_SET_ID_CLEAR_ALARMCODE_SELECT_CLEARYET_ERR,  // 33
	MESG_SET_ID_LEARN_ALARMCODE_ISLEARNING_ERR,  // 34
	MESG_SET_ID_LEARN_ALARMCODE_APPTRANS_ERR,  // 35
	MESG_SET_ID_LEARN_ALARMCODE_SELECT_ERR,  // 36
	MESG_SET_ID_LEARN_ALARMCODE_INVALID_KEY_ERR,   // 37
	MESG_SET_ID_LEARN_ALARMCODE_ISNOTLERAN_KEY_ERR,   // 38
    
	MESG_SET_APPID_NUMS_ERR,          // 39
	MESG_SET_APPID_BIG_ERR,             //40
    
    MESG_SET_ID_ALARMCODE_UBOOT_VERSION_ERR, // 41
	MESG_SET_ID_DRBL_ACK_ERR,  // 42
	MESG_SET_PASSWD_INIT_YET_ERR,   // 43   密码已经被初始化
    
	MESG_SET_DEVICE_NOT_SUPPORT = 0XFF,
};

#define MAX_REMOTE_MESSAGE_NS  16
typedef struct sRemoteMesgRecordsType
{
   DWORD       dwSrcID;
   BOOL           fgHasVerifyPassword;
   DWORD       dwMesgSize;
   BYTE           bMesgBody[1024];
}PACKED sRemoteMesgRecordsType;

typedef struct sMesgSetInitPasswdType
{
    BYTE bCmd; //MESG_TYPE_MESSAGE
    BYTE bOption; //0
    WORD wLen; //没用
    BYTE bPasswd[8]; //密码 加密以后的数据
}PACKED sMesgSetInitPasswdType;

typedef struct sMesgGSetAppIdType
{
    BYTE    bCmd; //MESG_TYPE_MESSAGE
    BYTE    bOption; //0
    BYTE   bAppIdMAXCount;
    BYTE   bAppIdCount;  // 1 <= wdwAppIdCount <= 3
    DWORD  dwAppId[1];
}PACKED sMesgGSetAppIdType;

typedef struct sMesgGetAlarmCodeType
{
    BYTE    bCmd; //MESG_TYPE_MESSAGE
    BYTE    bOption; //0
    BYTE    bAlarmCodeCount; //8
    BYTE    bAlarmKeySta;
    BYTE   bAlarmCodeSta[MAXTYPE_ALARM];           // MAXTYPE_ALARM = 8
}PACKED sMesgGetAlarmCodeType;



typedef struct sAlarmCodeType
{
    DWORD       dwAlarmCodeID; //1-8
    DWORD       dwAlarmCodeIndex;//1-8
}PACKED sAlarmCodeType;


typedef struct sMesgAlarmInfoType
{
    BYTE bAlarmMesg[4];
    sAlarmCodeType sAlarmCodes;
}PACKED sMesgAlarmInfoType;

//typedef struct sMesgSetAlarmCodeType
//{
//    BYTE   bCmd; //MESG_TYPE_MESSAGE
//    BYTE   bOption; //0
//    BYTE   bSetAlarmCodeId; //0  learn ,1  clear
//    BYTE   bAlarmCodeCount;// 1    // 1-3
//    sAlarmCodeType   sAlarmCodes[1]; // MAXTYPE_ALARM = 8
//}PACKED sMesgSetAlarmCodeType; //删除遥控就不能删除房区

typedef struct sMesgSetAlarmCodeType
{
    BYTE   bCmd; //MESG_TYPE_MESSAGE
    BYTE   bOption; //0
    BYTE   bSetAlarmCodeId; //0  learn ,1  clear
    BYTE   bAlarmCodeCount;// 1    // 1-3
    sAlarmCodeType   sAlarmCodes[1]; // MAXTYPE_ALARM = 8
}PACKED sMesgSetAlarmCodeType; //删除遥控就不能删除房区

typedef struct sNpcWifiListType
{
    BYTE fgReady;
    BYTE bWifiApNs; //wifi个数
    WORD wCurrentConnSSIDIndex; //当前wifi下标
    BYTE bEncTpSigLev[100];     //高四位:类型(0:没有密码 12:有密码)  低四位:信号强度 0-4
    char cAllESSID[1];          //WIFI名字
}PACKED sNpcWifiListType;


typedef struct sMesgGetWifiListType
{
    BYTE bCmd; //MESG_GET_WIFILIST
    BYTE bOption; //0
    WORD wLen;   //cAllESSID长度
    sNpcWifiListType  sNpcWifiList;
}PACKED sMesgGetWifiListType;

typedef struct sWIFIInfoType
{
    DWORD  dwEncType;  //(0:没有密码 12:有密码)
    char cESSID[MAX_WIFI_SSID_LEN]; //wifi名字
    char cPassword[MAX_WIFI_PASSWORD_LEN]; //密码
}sWIFIInfoType;


typedef struct sMesgSetWifiListType
{
    BYTE bCmd; //MESG_SET_WIFIList
    BYTE bOption; //0
    WORD wLen;    //1
    sWIFIInfoType  sPhoneWifiInfo;
}PACKED sMesgSetWifiListType;

typedef struct sSettingType
{
    DWORD       dwSettingID;
    DWORD       dwSettingValue;
}PACKED sSettingType;


typedef struct sMessageSettingsType
{
    BYTE           bCmd;//get set setting
   BYTE           bOption;// 0
   WORD           wSettingCount;
   sSettingType   sSettings[1];
}PACKED  sMessageSettingsType;

typedef struct sMesgEmailType
{
    BYTE bCmd; //MESG_TYPE_EMAIL
    BYTE     bOption; //(0:只获取或设置邮箱地址, 1:获取或设置整个SMTP相关信息)
    WORD   wLen;//发件邮箱密码长度
    char     cString[64];//邮箱地址
    
    DWORD  dwSmtpPort;//SMTP端口
    char     cSmtpServer[64];//SMTP服务器(最多支持5个)
    char     cSmtpUser[64];//SMTP服务器地址
    char     cSmtpPwd[64];//Smtp密码
    char     cEmailSubject[64];//Email主题
    char     cEmailContent[96];//Email内容
    BYTE  bEncryptType;//加密类型
    BYTE  bReserve;//根据GET返回值中 bReserver来判断, 如果bReserve =0x01则显示手工设置(固件新版本一律回0x01),  否则不显示
    WORD  wReserver;//预留
}PACKED sMesgEmailType;

typedef struct sMesgStringMesgType
{
    BYTE bCmd; //MESG_TYPE_MESSAGE
    BYTE bOption; //0
    WORD wLen;
    char cString[MAX_MESSAGE_LEN] ;//
}sMesgStringMesgType;

//开锁结构体
typedef struct UserCmdMesg
{
    BYTE bCmd;
    BYTE bOption;
    BYTE len;
    BYTE bReseve;
    char Data[248];
}PACKED UserCmdMesg;

typedef struct sMesgSysVersionType
{
	BYTE bCmd;
    BYTE bOption;
    WORD wLen;
    DWORD dwCurAppVersion;
    DWORD dwUbootVersion;
    DWORD dwKernelVersion;
    DWORD dwRootfsVersion;
    DWORD dwRes[4];
}PACKED sMesgSysVersionType;

typedef struct  sDateTime
{
    WORD    wYear;
     BYTE     bMon;
     BYTE     bDay;
     BYTE     bHour;
     BYTE     bMin;
} sDateTime;

typedef struct  sMesgDateTimeType
{
    BYTE bCmd; //MESG_TYPE_GET_DATETIME
    BYTE bOption; //0
    WORD wOption; //0
    
    sDateTime sMesgSysTime;
    
    //     sDateTime  sMesgSysTime;  // 2000-1-1 0:0
}PACKED sMesgDateTimeType;

typedef struct sSDCardInfo{
    BYTE bSDCardID;
    UINT64 u64SDTotalSpace;
    UINT64 u64SDCardFreeSpace;
}PACKED sSDCardInfo;

typedef struct sMesgSDCardInfoType{
    BYTE bCommandType;
    BYTE bOption;
    WORD wSDCardCount;
    
    sSDCardInfo sSDCard[2];
}PACKED sMesgSDCardInfoType;

typedef struct sMesgSDCardFormatType{
    BYTE bCommandType;
    BYTE bOption;
    WORD wRemainByte;
    BYTE bSDCardID;
}sMesgSDCardFormatType;

typedef struct sMesgGetDefenceSwitchType{
    BYTE    bCmd; //MESG_TYPE_MESSAGE
    BYTE    bOption; //0
    BYTE    bDefenceSetSwitchCount;
    BYTE    bReserve; // 保留区
    BYTE    bDefenceSetSwitch[MAXTYPE_ALARM];  //  MAXTYPE = 8
}PACKED sMesgGetDefenceSwitchType;

typedef struct sAlarmCodesType{
    DWORD       dwAlarmCodeID;//  要设置的防区
    DWORD       dwAlarmCodeIndex;//  要设置的通道
}PACKED sAlarmCodesType;

typedef struct sMesgSetDefenceSwitchType{
    BYTE   bCmd; //MESG_TYPE_MESSAGE
    BYTE   bOption; //0
    BYTE   bSetDefenceSetSwitchId; //  1  on,  0  off
    BYTE   bDefenceSetSwitchCount;
    sAlarmCodeType    sAlarmCodes[1];           // MAXTYPE_ALARM = 8
}PACKED sMesgSetDefenceSwitchType;

typedef struct  sMesgGetRecListType
{
     BYTE bCmd; //MESG_TYPE_GET_REC_LIST
     BYTE bOption; //0
     WORD wOption; //0
     
     sDateTime  sBeginTime;  // 2000-1-1 0:0
     sDateTime  sEndTime ;   // 2100-12-31 23:59
}sMesgGetRecListType;

typedef struct  sRecFilenameType
{
    WORD    wYear;
     BYTE     bMon; /// (bDiscID<<4)|(bMon) for remote
     BYTE     bDay;
     BYTE     bHour;
     BYTE     bMin;
     BYTE     bSec;
     char      cType;//'M','S','A'
}PACKED sRecFilenameType;

typedef struct  sMesgRetRecListType
{
     BYTE bCmd; //MESG_TYPE_RET_REC_LIST
     BYTE bOption0;//0
     BYTE bOption1;//0
     BYTE bFileNs;//
     
     sRecFilenameType   sFileName[1];//files info
}sMesgRetRecListType;

//
typedef struct  sMesgAlarmCallType
{
   BYTE bCmd; //MESG_TYPE_ALARM_CALL
   BYTE bAlarmType;
}sMesgAlarmCallType;

//GPIO口控制
typedef struct sMesgSetGpioCtrl
{
    BYTE bCmd; // MESG_TYPE_SET_GPIO_CTL
    BYTE bOption; // 0
    BYTE bGroup; // GPIO 所属组
    BYTE bPin;  // GPIO 管脚编号
    BYTE bValueNs;  // 波形值改变的个数
    int  iTimer_ms[8];  // 波形依次保持的 时间 ， 以毫秒为单位
}PACKED  sMesgSetGpioCtrl;

enum{
	LAN_MESG_SET_OK, // 没用
	LAN_MESG_GET_OK,
	LAN_MESG_GET_SHAKE_SIZE_ERR,       // 3
    
	LAN_MESG_GET_DRBL_CHECK_ERR,      // 4
	LAN_MESG_GET_DRBL_IS_NOT_ASK_ERR,        //5
	
};
enum{
	LAN_TRANS_MIN,          // 没用
	LAN_TRANS_SHAKE_GET,     //
	LAN_TRANS_SHAKE_RET,     //
    
	LAN_TRANS_DRBL_ACK_GET, // 4
    LAN_TRANS_DRBL_ACK_RET,   // 5
    LAN_TRANS_MAX,
};

typedef struct sDeviceInfoType{
	DWORD      dw3CId;         // 设备3c号
	DWORD 		dwDeviceType;  // 设备类型    // 
	BOOL    	fgPasswdFlag;  //设备密码是否已设置 0，未设置， 1，已设置
}sDeviceInfoType;

typedef struct sMesgShakeType{
	DWORD 		dwCmd;        // 	LAN_TRANS_SHAKE_GET
	DWORD 		dwErrNO;      //  错误码
	DWORD 		dwStructSize; // 结构体的大小 sizeof(sMesgShakeType) 28
	DWORD 		dwStrCon;     // 字符串的个数                        0
	sDeviceInfoType 		sDeviceInfo;   //设备的信息
}sMesgShakeType;

typedef struct sUpgMesg
{
    DWORD       dwUpgID;
    DWORD       dwUpgVal;
}PACKED sUpgMesg;


typedef struct sMesgUpgType
{
	BYTE bCmd;     //MESG_TYPE_UPG_DEVICE ,     BYTE bOption; //0
	BYTE bOption;
    WORD wLen;
    sUpgMesg sRemoteUpgMesg;
}PACKED sMesgUpgType;

enum{
    CUSTOMER_CMDNOVER_ID_MIN,
    CUSTOMER_CMDNOVER_ID_DEL_ALARM_ACCOUNT,  // 删除报警推送账号
    CUSTOMER_CMDNOVER_ID_STOP_DOORBELL_PUSH = 3, // 告诉设备端不要再推送门铃
};

typedef struct sCmdDataMesg
{
    DWORD       dwCmdID;               // 客户命令选项
    DWORD       dwCmdVal;
}PACKED sCmdDataMesg;

typedef struct sMesgCustomNoVerifyCmdType
{
    BYTE bCmd;
    BYTE bOption;
    WORD wLen;
    DWORD dwMesgVersion;
    sCmdDataMesg sCmdData;
}PACKED sMesgCustomNoVerifyCmdType;

typedef struct sTransCheckDeviceWifiModeCmdType
{
    DWORD dwCmd;
    DWORD dwErrNo;
    
    BYTE  bWifiMode;
    BYTE  bReresve[3];
    DWORD dwIp;
    DWORD dw3CID;
}PACKED sTransCheckDeviceWifiModeCmdType;

typedef struct sTcpSetWifiCmdType
{
    DWORD dwCmd;
    DWORD dwErrNo;
    
    BYTE  bSetWifiInfo; // 1 set ap wifi     2 set wifi info
    BYTE  bReresve[3];
    sWIFIInfoType sWifiInfo;
}PACKED sTcpSetWifiCmdType;

//设备语言消息结构体
typedef struct sMesgDeviceLanguageCmdType
{
    BYTE bCmd;
    BYTE bOption;
    WORD wReserve;
    
    BYTE bSupportLanguageCount;
    BYTE bCurLanguage;
    BYTE bLanguageSupport[0];
    
}PACKED sMesgDeviceLanguageCmdType;

#endif

