//
//  Utils.m
//  Yoosee
//
//  Created by guojunyi on 14-3-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "Utils.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "Constants.h"
#import "LocalDevice.h"
#import "Contact.h"
#import "ContactDAO.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MD5Manager.h"

@implementation Utils
+(UILabel*)getTopBarTitleView{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    return label;
}

+(NSDateComponents*)getNowDateComponents{
    NSDate *now = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    return dateComponent;
}

+(NSDateComponents*)getDateComponentsByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    return dateComponent;
}

+(long)getCurrentTimeInterval{
//    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
//   
//    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
//    NSDate *localDate = [[NSDate date] dateByAddingTimeInterval:interval];
    long timeInterval = [[NSDate date] timeIntervalSince1970];
    return timeInterval;
}

+(NSString*)getDeviceTimeByIntValue:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute{
    NSString *monStr = nil;
    NSString *dayStr = nil;
    NSString *hourStr = nil;
    NSString *minStr = nil;
    if(month>=10){
        monStr = [NSString stringWithFormat:@"%li",(long)month];
    }else{
        monStr = [NSString stringWithFormat:@"0%li",(long)month];
    }
    
    if(day>=10){
        dayStr = [NSString stringWithFormat:@"%li",(long)day];
    }else{
        dayStr = [NSString stringWithFormat:@"0%li",(long)day];
    }
    
    if(hour>=10){
        hourStr = [NSString stringWithFormat:@"%li",(long)hour];
    }else{
        hourStr = [NSString stringWithFormat:@"0%li",(long)hour];
    }
    
    if(minute>=10){
        minStr = [NSString stringWithFormat:@"%li",(long)minute];
    }else{
        minStr = [NSString stringWithFormat:@"0%li",(long)minute];
    }
    return [NSString stringWithFormat:@"%li-%@-%@ %@:%@",(long)year,monStr,dayStr,hourStr,minStr];
}

+(NSString*)getPlanTimeByIntValue:(NSInteger)planTime{
    NSInteger minute_to = planTime&0xff;
    NSInteger minute_from = (planTime>>8)&0xff;
    NSInteger hour_to = (planTime>>16)&0xff;
    NSInteger hour_from = (planTime>>24)&0xff;
    
    NSString *minute_to_str = @"00";
    NSString *minute_from_str = @"00";
    NSString *hour_to_str = @"00";
    NSString *hour_from_str = @"00";
    
    if(minute_to<10){
        minute_to_str = [NSString stringWithFormat:@"0%i",minute_to];
    }else{
        minute_to_str = [NSString stringWithFormat:@"%i",minute_to];
    }
    
    if(minute_from<10){
        minute_from_str = [NSString stringWithFormat:@"0%i",minute_from];
    }else{
        minute_from_str = [NSString stringWithFormat:@"%i",minute_from];
    }
    
    if(hour_to<10){
        hour_to_str = [NSString stringWithFormat:@"0%i",hour_to];
    }else{
        hour_to_str = [NSString stringWithFormat:@"%i",hour_to];
    }
    
    if(hour_from<10){
        hour_from_str = [NSString stringWithFormat:@"0%i",hour_from];
    }else{
        hour_from_str = [NSString stringWithFormat:@"%i",hour_from];
    }
    
    return [NSString stringWithFormat:@"%@:%@-%@:%@",hour_from_str,minute_from_str,hour_to_str,minute_to_str];
}

+(CGFloat)getStringWidthWithString:(NSString *)string font:(UIFont*)font maxWidth:(CGFloat)maxWidth{
    CGSize sizeToFit = [string sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    return sizeToFit.width;
}

+(CGFloat)getStringHeightWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth{
    CGSize sizeToFit = [string sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    return sizeToFit.height;
}
+(NSString*)getPlaybackTime:(UInt64)time{
    UInt64 hh = time/3600;
    UInt64 mm = (time/60)%60;
    UInt64 ss = time%60;
    
    NSString *hhStr = @"00";
    NSString *mmStr = @"00";
    NSString *ssStr = @"00";
    
    if(hh<10){
        hhStr = [NSString stringWithFormat:@"0%llu",hh];
    }else{
        hhStr = [NSString stringWithFormat:@"%llu",hh];
    }
    
    if(mm<10){
        mmStr = [NSString stringWithFormat:@"0%llu",mm];
    }else{
        mmStr = [NSString stringWithFormat:@"%llu",mm];
    }
    
    if(ss<10){
        ssStr = [NSString stringWithFormat:@"0%llu",ss];
    }else{
        ssStr = [NSString stringWithFormat:@"%llu",ss];
    }
    
    return [NSString stringWithFormat:@"%@:%@:%@",hhStr,mmStr,ssStr];
}


+(NSDate*)dateFromString:(NSString *)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *destDate = [formatter dateFromString:dateString];
    return destDate;
}

+(NSDate*)dateFromString2:(NSString *)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *destDate = [formatter dateFromString:dateString];
    return destDate;
}

+(NSString*)stringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *destString = [formatter stringFromDate:date];
    return destString;
}

+(NSString*)convertTimeByInterval:(NSString*)timeInterval{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval.intValue];

    [format setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *time = [format stringFromDate:date];
    //[format release];
    return time;
}

+(NSArray*)getScreenshotFilesWithId:(NSString*)contactId{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *savePath = [NSString stringWithFormat:@"%@/screenshot/%@",rootPath,contactId];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager subpathsAtPath:savePath];
    NSMutableArray *imgFiles = [NSMutableArray arrayWithCapacity:0];
    for(NSString *str in files){
        if([str hasSuffix:@".png"]){
            [imgFiles addObject:str];
        }
    }
    return imgFiles;
}

+(void)saveScreenshotFileWithId:(NSString*)contactId data:(NSData*)data{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    long timeInterval = [Utils getCurrentTimeInterval];
    NSString *savePath = [NSString stringWithFormat:@"%@/screenshot/%@",rootPath,contactId];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:savePath]){
        [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [data writeToFile:[NSString stringWithFormat:@"%@/%ld.png",savePath,timeInterval] atomically:YES];
}

+(NSString*)getScreenshotFilePathWithName:(NSString *)fileName contactId:(NSString*)contactId{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/screenshot/%@/%@",rootPath,contactId,fileName];
    return filePath;
}

+(NSString*)getHeaderFilePathWithId:(NSString *)contactId{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *filePath = [NSString stringWithFormat:@"%@/screenshot/tempHead/%@/%@.png",rootPath,loginResult.contactId,contactId];
    return filePath;
}

+(void)saveHeaderFileWithId:(NSString*)contactId data:(NSData*)data{
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    //long timeInterval = [Utils getCurrentTimeInterval];
    NSString *savePath = [NSString stringWithFormat:@"%@/screenshot/tempHead/%@",rootPath,loginResult.contactId];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:savePath]){
        [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"savePath:%@",savePath);
    [data writeToFile:[NSString stringWithFormat:@"%@/%@.png",savePath,contactId] atomically:YES];
}

#pragma mark - get launch image path
+(NSString*)getAppLaunchImageFilePathWithFlag:(NSString *)flag{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/appStartInfo/launchImage/%@.png",rootPath,flag];
    return filePath;
}

#pragma mark - save launch image
+(void)saveAppLaunchImageFileWithFlag:(NSString *)flag imageData:(NSData *)imageData{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *savePath = [NSString stringWithFormat:@"%@/appStartInfo/launchImage",rootPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:savePath]){
        [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [imageData writeToFile:[NSString stringWithFormat:@"%@/%@.png",savePath,flag] atomically:YES];
}

#pragma mark - get Normal String from base64String
+(NSString *)getNormalStringByDecodedBase64String:(NSString *)base64String{
    
    // NSData from the Base64 encoded string
    NSData *nsdataFromBase64String = [[NSData alloc] init];
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        nsdataFromBase64String = [nsdataFromBase64String initWithBase64Encoding:base64String];
    }else{
        nsdataFromBase64String = [nsdataFromBase64String
                                  initWithBase64EncodedString:base64String options:0];
    }
    
    // Decoded NSString from the NSData
    NSString *normalString = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    return normalString;
}


+(void)playMusicWithName:(NSString *)name type:(NSString *)type{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:soundPath]), &sound);
    AudioServicesPlaySystemSound(sound);
    //AudioServicesDisposeSystemSoundID(sound);
}

+ (NSString*)currentWifiSSID
{
    NSString *wifiName = nil;
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    
    if (myArray != nil)
    {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil)
        {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    return wifiName;
}

+(NSMutableArray*)getNewDevicesFromLan:(NSArray*)lanDevicesArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    
    for (int i=0; i<[lanDevicesArray count]; i++) {
        LocalDevice *localDevice = [lanDevicesArray objectAtIndex:i];
        
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:localDevice.contactId];
        //[contactDAO release];
        if(nil==contact){
            [array addObject:localDevice];
        }
    }
    
    return array;
}

+(NSArray*)getNewUnsetPasswordDevicesFromLan:(NSArray*)lanDevicesArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];

    
    for (int i=0; i<[lanDevicesArray count]; i++)
    {
        LocalDevice *localDevice = [lanDevicesArray objectAtIndex:i];
        
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:localDevice.contactId];
        //[contactDAO release];
        if(nil==contact&&localDevice.flag==0){
            [array addObject:localDevice];
        }
    }

    return array;
}

+(NSArray*)getAddedUnsetPasswordDevicesFromLan:(NSArray*)lanDevicesArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<[lanDevicesArray count]; i++)
    {
        LocalDevice *localDevice = [lanDevicesArray objectAtIndex:i];
        
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:localDevice.contactId];
        //[contactDAO release];
        if(contact&&localDevice.flag==0){
            [array addObject:localDevice];
        }
    }
    
    return array;
}

/*
如果不包含(数字+字母)----弱密码
否则
数字、大写字母、小写字母、其他符号，有两种元素为中密码，三种或者三种以上为强密码
 */

+(int)pwdStrengthWithPwd:(NSString *)sPassword{
    if ([sPassword length] == 0) {
        return password_null;
    }
    if ([sPassword length] <6) {
        return password_weak;
    }
    
    const char* szBuffer = [sPassword UTF8String];
    BOOL isIncludeNumber = NO;
    BOOL isIncludeLowerLetter = NO;
    BOOL isIncludeUpperLetter = NO;
    BOOL isIncludeOther = NO;
    for (int i=0; i<strlen(szBuffer); i++) {
        char ch = szBuffer[i];
        if (ch >= '0' && ch <= '9') {
            isIncludeNumber = YES;
        }
        else if (ch >= 'a' && ch <= 'z') {
            isIncludeLowerLetter = YES;
        }
        else if (ch >= 'A' && ch <= 'Z')
        {
            isIncludeUpperLetter = YES;
        }
        else
        {
            isIncludeOther = YES;
        }
    }
    
    //如果没有数字或者字母，返回弱密码
    if (!isIncludeNumber || !(isIncludeUpperLetter || isIncludeLowerLetter)) {
        return password_weak;
    }

    //2种是弱密码，3种及以上是强密码
    int dwCountCase = 0;
    if (isIncludeNumber) {
        dwCountCase ++;
    }
    if (isIncludeLowerLetter) {
        dwCountCase ++;
    }
    if (isIncludeUpperLetter) {
        dwCountCase ++;
    }
    if (isIncludeOther) {
        dwCountCase ++;
    }
    if (dwCountCase == 2) {
        return password_middle;
    }
    return password_strong;
}

+(BOOL)IsNeedEncrypt:(NSString *)sPassword
{
    if ([sPassword length] == 0)
    {
        return NO;
    }
    
    BOOL isPureNumber = YES;
    const char* szBuffer = [sPassword UTF8String];
    for (int i=0; i<strlen(szBuffer); i++) {
        char ch = szBuffer[i];
        if (ch < '0' || ch > '9') {
            isPureNumber = NO;
            break;
        }
    }
    
    if (!isPureNumber) {
        return YES;
    }
    else
    {
        if ([sPassword length] >= 10) {
            return YES;
        }
    }
    
    return NO;
}

+(NSString*)GetTreatedPassword:(NSString*)sPassword
{
    BOOL isNeedEncrypt = [Utils IsNeedEncrypt:sPassword];
    if (isNeedEncrypt) {
        unsigned int ret = [MD5Manager GetTreatedPassword:[sPassword UTF8String]];
        sPassword = [NSString stringWithFormat:@"0%d", ret];
    }
    return sPassword;
}


+(NSString*) getRecordPathWithUserId:(NSString*)userId contactId:(NSString*)contactId
{
    //document目录
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    /*NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
     [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
     NSString *recordDate = [formatter stringFromDate:[NSDate date]];*/
    
    path = [NSString stringWithFormat:@"%@/videorecord/%@",path,userId];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:path]){
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filename = [NSString stringWithFormat:@"%@_%ld.mp4",contactId,[Utils getCurrentTimeInterval] ];
    
    path = [NSString stringWithFormat:@"%@/%@",path,filename];
    NSLog(@"录像保存路径%@",path);
    
    return path;
}


@end

@implementation NSString (Utils)

- (NSString *)getMd5_32Bit_String{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return [result lowercaseString];
}


- (BOOL) isValidateNumber{
    const char *cvalue = [self UTF8String];
    int len = strlen(cvalue);
    for (int i = 0; i < len; i++) {
        if (!(cvalue[i] >= '0' && cvalue[i] <= '9')) {
            return FALSE;
        }
    }
    return TRUE;
}

- (BOOL) isValidateP2PVerifyCode1OrP2PVerifyCode2{
    
    if ([self characterAtIndex:0] == '-') {//带“-”的codeStr1
        if(![[self substringFromIndex:1] isValidateNumber]){//有效的number
            return NO;
        }
    }else if (![self isValidateNumber]){//有效的number
        return NO;
    }
    
    unsigned  int verifyCode = (unsigned int)self.intValue;
    unsigned  int min = 0;
    unsigned  int max = (unsigned int)(pow(2.0,32) - 1);
    if (verifyCode < min || verifyCode > max){
        return NO;
    }
    
    return YES;
}

@end

