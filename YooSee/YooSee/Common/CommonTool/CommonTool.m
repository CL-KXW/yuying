//
//  CommonTool.m
//  SmallPig
//
//  Created by clei on 14/11/6.
//  Copyright (c) 2014年 chenlei. All rights reserved.
//

#import "CommonTool.h"
#import <CommonCrypto/CommonDigest.h>


@implementation CommonTool


//判断是否是Email格式或者手机号
+ (BOOL)isEmailOrPhoneNumber:(NSString*)string
{
    if (!string || string.length == 0)
    {
        return NO;
    }
    //    NSString *patternPhoneNumber = @"^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSString *patternPhoneNumber = @"^((1[0-9])|(1[0-9])|(1[0-9]))\\d{9}$";
    NSString *patternEmail = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    NSError *error = NULL;
    //定义正则表达式
    NSRegularExpression *regexPhoneNumber = [NSRegularExpression regularExpressionWithPattern:patternPhoneNumber options:0 error:&error];
    NSRegularExpression *regexEmail = [NSRegularExpression regularExpressionWithPattern:patternEmail options:0 error:&error];
    //使用正则表达式匹配字符
    NSTextCheckingResult *isMatchPhoneNumber = [regexPhoneNumber firstMatchInString:string
                                                                            options:0
                                                                              range:NSMakeRange(0, [string length])];
    NSTextCheckingResult *isMatchEmail = [regexEmail firstMatchInString:string
                                                                options:0
                                                                  range:NSMakeRange(0, [string length])];
    
    if (isMatchPhoneNumber || isMatchEmail)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//判断身份证是否合格
+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0)
    {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}


//颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//计算文字高度
+ (float)labelHeightWithTextLabel:(UILabel *)textLabel textFont:(UIFont *)font
{
    /*
     *  IOS2 - IOS7
     *  CGSize titleBrandSizeForHeight = [textLabel.text sizeWithFont:font];
     *  CGSize titleBrandSizeForLines = [textLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(textLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
     */
    
    //---IOS7开始使用
    NSDictionary *attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize titleBrandSizeForHeight = [textLabel.text sizeWithAttributes:attributeDic];
    CGSize titleBrandSizeForLines = [textLabel.text boundingRectWithSize:CGSizeMake(textLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic context:nil].size;
    //---
    int number= ceil(titleBrandSizeForLines.height/titleBrandSizeForHeight.height);
    textLabel.numberOfLines = 0;
    float theHeigth=0.0;
    if (number <= 1)
    {
        theHeigth = titleBrandSizeForHeight.height;
    }
    else
    {
        theHeigth = number*titleBrandSizeForHeight.height;
        //textLabel.numberOfLines = number + 1;
    }
    return theHeigth;
}

+ (float)labelHeightWithText:(NSString *)text textFont:(UIFont*)font labelWidth:(float)width
{
    /*
     *  IOS2 - IOS7
     *  CGSize titleBrandSizeForHeight = [textLabel.text sizeWithFont:font];
     *  CGSize titleBrandSizeForLines = [textLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(textLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
     */
    
    //---IOS7开始使用
    NSDictionary *attributeDic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize titleBrandSizeForHeight = [text sizeWithAttributes:attributeDic];
    CGSize titleBrandSizeForLines = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic context:nil].size;
    //---
    int number= ceil(titleBrandSizeForLines.height/titleBrandSizeForHeight.height);
    float theHeigth=0.0;
    if (number <= 1)
    {
        theHeigth = titleBrandSizeForHeight.height;
    }
    else
    {
        theHeigth = number*titleBrandSizeForHeight.height;
    }
    return theHeigth;
}


//设置阴影
+ (void)setViewShadow:(UIView *)view withShadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowOpacity:(float)opacity
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = shadowColor.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowPath = shadowPath.CGPath;
}

//设置图层相关
+ (void)setViewLayer:(UIView *)view withLayerColor:(UIColor *)color bordWidth:(float)width
{
    if (!view)
        return;
    if (color)
        view.layer.borderColor = [color CGColor];
    view.layer.borderWidth = width;
}

//圆角实现
+ (void)clipView:(UIView *)view withCornerRadius:(float)radius
{
    if (!view)
        return;
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

//MD5
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


//创建提示alert
+ (void)addAlertTipWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alertView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
}

+ (void)addPopTipWithMessage:(NSString *)message
{
    [SVProgressHUD showErrorWithStatus:message duration:1.5];
}

//時間轉換成字符串
+ (NSString *)getStringFromDate:(NSDate *)date formatterString:(NSString *)fmtString;
{
    NSDateFormatter *formatter = [[NSDateFormatter  alloc]init];
    [formatter setDateFormat:fmtString];
    return [formatter stringFromDate:date];
}

+ (NSDate*)timeStringToDate:(NSString*)timeString format:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter  alloc]init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:timeString];
}

////URL编码
//+ (NSString *)encodeToPercentEscapeString: (NSString *) input
//{
//    NSString *outputStr = (NSString *)
//    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                              (CFStringRef)input,
//                                                              NULL,
//                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                              kCFStringEncodingUTF8));
//    //自定义需要编码的特殊字符
//    return outputStr;
//}

//+ (NSString *)encodeURL:(NSString *)string encoding:(NSStringEncoding)stringEncoding
//{
//    CFStringRef originalURLString = (__bridge CFStringRef)string;
//    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(stringEncoding);
//    CFStringRef preprocessedString =
//    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, originalURLString, CFSTR(""), encoding);
//    CFStringRef urlString =
//    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, preprocessedString, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), encoding);
//    
//    NSString *newString = [NSString stringWithString:(__bridge NSString *)urlString];
//    return [newString length] ? newString : @"";
//}
//
//
////URL解码
//+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
//{
//    NSMutableString *outputStr = [NSMutableString stringWithString:input];
//    [outputStr replaceOccurrencesOfString:@"+"
//                               withString:@" "
//                                  options:NSLiteralSearch
//                                    range:NSMakeRange(0, [outputStr length])];
//    
//    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//}

//多属性字符串
+ (void)makeString:(NSString *)textString toAttributeString:(NSMutableAttributedString *)attributedString  withString:(NSString *)string withTextColor:(UIColor *)textColor withTextFont:(UIFont *)textFont
{
    [attributedString addAttribute:NSFontAttributeName
                             value:textFont
                             range:[textString rangeOfString:string]];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:textColor
                             range:[textString rangeOfString:string]];
}

+ (void)makeString:(NSString *)textString toAttributeString:(NSMutableAttributedString *)attributedString  withString:(NSString *)string withLineSpacing:(float)lineSpace
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    [attributedString addAttributes:attributes range:[textString rangeOfString:string]];
}

//时间
+ (NSString *)getUTCFormateDate:(NSString *)newsDate
{
    //    newsDate = @"2013-08-09 17:01";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    
    NSLog(@"newsDate = %@",newsDate);
    NSDate *newsDateFormatted = [dateFormatter dateFromString:newsDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate* current_date = [NSDate date];
    
    NSTimeInterval time=[current_date timeIntervalSinceDate:newsDateFormatted];//间隔的秒数
    int month=((int)time)/(3600*24*30);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    NSLog(@"time=%.0f",(double)time);
    
    NSString *dateContent;
    
    if(month!=0)
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",month,@"个月前"];
        
    }
    else if(days!=0)
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",days,@"天前"];
    }
    else if(hours!=0)
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",hours,@"小时前"];
    }
    else if(minute == 0)
    {
        dateContent = @" 刚刚";
    }
    else
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",minute,@"分钟前"];
    }
    
    //    NSString *dateContent=[[NSString alloc] initWithFormat:@"%i天%i小时",days,hours];
    
    return dateContent;
}

//时间
+ (NSString *)getIntervalFormateDate:(long)newsDate
{
    
    NSLog(@"newsDate = %ld",newsDate);
    NSDate *newsDateFormatted = [NSDate dateWithTimeIntervalSince1970:newsDate/1000];
    NSDate* current_date = [NSDate date];
    
    NSTimeInterval time = [current_date timeIntervalSinceDate:newsDateFormatted];//间隔的秒数
    int month=((int)time)/(3600*24*30);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    NSLog(@"time=%.0f",(double)time);
    
    NSString *dateContent;
    
    if(month!=0)
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",month,@"个月前"];
        
    }
    else if(days!=0)
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",days,@"天前"];
    }
    else if(hours!=0)
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",hours,@"小时前"];
    }
    else if(minute == 0)
    {
        dateContent = @" 刚刚";
    }
    else
    {
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",minute,@"分钟前"];
    }
    
    //    NSString *dateContent=[[NSString alloc] initWithFormat:@"%i天%i小时",days,hours];
    
    return dateContent;
}

//原始图片
+ (UIImage *)getOriginalImageWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

//判断数字加字母
+ (BOOL)judgeStringLegal:(NSString *)string
{
    BOOL result = false;
   
    //判断是否同时包含数字和字符
    NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    result = [predicate evaluateWithObject:string];
    
    return result;
}

+ (NSString*)dateString2MDString:(NSString*)string {
    NSDateFormatter *formatter = [[NSDateFormatter  alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *date = [formatter dateFromString:string];
    if (!date) {
        return @"";
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:date];
    return [NSString stringWithFormat:@"%d月%d日", cmp1.month, cmp1.day];
}

+ (NSString*)dateString2MDHMString:(NSString*)string {
    NSDateFormatter *formatter = [[NSDateFormatter  alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:string];
    if (!date) {
        return @"";
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:date];
    return [NSString stringWithFormat:@"%d月%d日 %02d:%02d", cmp1.month, cmp1.day, cmp1.hour, cmp1.minute];
}
@end
