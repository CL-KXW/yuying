//
//  Utils.h
//  Yoosee
//
//  Created by guojunyi on 14-3-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  DWORD        unsigned int
#define  BYTE         unsigned char

enum
{
    password_weak,
    password_middle,
    password_strong,
    password_null
};

@interface Utils:NSObject
+(UILabel*)getTopBarTitleView;
+(long)getCurrentTimeInterval;
+(NSString*)convertTimeByInterval:(NSString*)timeInterval;
+(NSArray*)getScreenshotFilesWithId:(NSString*)contactId;

+(void)saveScreenshotFileWithId:(NSString*)contactId data:(NSData*)data;
+(NSString*)getScreenshotFilePathWithName:(NSString*)fileName contactId:(NSString*)contactId;

+(void)saveHeaderFileWithId:(NSString*)contactId data:(NSData*)data;
+(NSString*)getHeaderFilePathWithId:(NSString*)contactId;

+(void)saveAppLaunchImageFileWithFlag:(NSString *)flag imageData:(NSData *)imageData;
+(NSString*)getAppLaunchImageFilePathWithFlag:(NSString *)flag;

+(NSString *)getNormalStringByDecodedBase64String:(NSString *)base64String;

+(NSDateComponents*)getNowDateComponents;
+(NSDateComponents*)getDateComponentsByDate:(NSDate*)date;
+(NSString*)getPlaybackTime:(UInt64)time;
+(NSDate*)dateFromString:(NSString*)dateString;
+(NSDate*)dateFromString2:(NSString*)dateString;
+(NSString*)stringFromDate:(NSDate*)date;

+(NSString*)getDeviceTimeByIntValue:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

+(NSString*)getPlanTimeByIntValue:(NSInteger)planTime;

+(CGFloat)getStringWidthWithString:(NSString*)string font:(UIFont*)font maxWidth:(CGFloat)maxWidth;
+(CGFloat)getStringHeightWithString:(NSString*)string font:(UIFont*)font maxWidth:(CGFloat)maxWidth;

+(void)playMusicWithName:(NSString*)name type:(NSString*)type;

+(NSString*)currentWifiSSID;

+(NSMutableArray*)getNewDevicesFromLan:(NSArray*)lanDevicesArray;
+(NSMutableArray*)getNewUnsetPasswordDevicesFromLan:(NSArray*)lanDevicesArray;
+(NSMutableArray*)getAddedUnsetPasswordDevicesFromLan:(NSArray*)lanDevicesArray;

+(int)pwdStrengthWithPwd:(NSString *)sPassword;
+(NSString*)GetTreatedPassword:(NSString*)sPassword;

//返回录像
+(NSString*) getRecordPathWithUserId:(NSString*)userId contactId:(NSString*)contactId;

+ (BOOL) isCameraAvailable;
+ (BOOL) isRearCameraAvailable;
+ (BOOL) isFrontCameraAvailable;
+ (BOOL) doesCameraSupportTakingPhotos;
+ (BOOL) isPhotoLibraryAvailable;
+ (BOOL) canUserPickVideosFromPhotoLibrary;
+ (BOOL) canUserPickPhotosFromPhotoLibrary;
+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;

+(UIImage*)createImageWithColor:(UIColor*)color;
+(NSString *)aesStingDictionary:(NSMutableDictionary *)dic;

@end

@interface NSString(Utils)


- (NSString *)getMd5_32Bit_String;
- (BOOL) isValidateNumber;
- (BOOL) isValidateP2PVerifyCode1OrP2PVerifyCode2;

@end
