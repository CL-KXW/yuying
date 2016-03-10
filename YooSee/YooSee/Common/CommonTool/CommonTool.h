//
//  CommonTool.h
//  SmallPig
//
//  Created by clei on 14/11/6.
//  Copyright (c) 2014年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CommonTool : NSObject

/*
 * 判断手机号或邮箱是否合法
 *
 * @param string 手机号或者邮箱字符串
 *
 * @return 返回格式是否合法
 */
+ (BOOL)isEmailOrPhoneNumber:(NSString*)string;

/*
 * 判断身份证是否合法
 *
 * @param identityCard 身份证号码字符串
 *
 * @return 返回格式是否合法
 */
+ (BOOL) validateIdentityCard: (NSString *)identityCard;

/*
 * 颜色生成图片
 *
 * @param color 颜色
 *
 * @return 返回图片对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/*
 * 根据UILabel计算高度和设置Label高度和行数
 *
 * @param textLabel  Label
 * @param font       字体
 *
 * @return 返回字符串高度
 */
+ (float)labelHeightWithTextLabel:(UILabel *)textLabel textFont:(UIFont *)font;

/*
 * 根据字符串计算高度文字高度
 *
 * @param text       字符串
 * @param font       字体
 * @param width      字符串显示区域宽度
 *
 * @return 返回字符串高度
 */
+ (float)labelHeightWithText:(NSString *)text textFont:(UIFont*)font labelWidth:(float)width;


/*
 *  设置阴影
 *
 *  @pram view          view视图
 *  @pram shadowColor   阴影颜色
 *  @pram offset        阴影区域
 *  @pram opacity       阴影模糊度
 */
+ (void)setViewShadow:(UIView *)view withShadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowOpacity:(float)opacity;

/*
 *  设置view图层相关属性
 *
 *  @param view   view视图
 *  @param color  图层颜色
 *  @param width  图层边缘宽度
 */
+ (void)setViewLayer:(UIView *)view withLayerColor:(UIColor *)color bordWidth:(float)width;

/*
 *  设置特层圆角属性
 *
 *  @param view   view视图
 *  @param radius 圆角大小
 */
+ (void)clipView:(UIView *)view withCornerRadius:(float)radius;


/*
 *  MD5
 *
 *  @param   str    需要加密的字符串
 *
 *  @return        加密后的字符串
 */
+ (NSString *)md5:(NSString *)str;

/*
 *  创建提示alert
 *
 *  @param   message 提示文字
 */
+ (void)addAlertTipWithMessage:(NSString *)message;
+ (void)addPopTipWithMessage:(NSString *)message;

/*
 *  時間轉換為字符串
 *
 *  @param   date   時間
 *
 *  @return        時間字符串
 */
+ (NSString *)getStringFromDate:(NSDate *)date formatterString:(NSString *)fmtString;

///*
// *  URL编码
// *
// *  @param   input  需要编码的字符串
// *
// *  @return        编码后的字符串
// */
//+ (NSString *)encodeToPercentEscapeString: (NSString *) input;
//+ (NSString *)encodeURL:(NSString *)string encoding:(NSStringEncoding)stringEncoding;

/*
 *  多属性字符串
 *
 *  @pram   textString          全字符串
 *  @pram   attributedString    多属性字符串
 *  @pram   string              要改变的字符串
 *  @pram   textColor           字体颜色
 *  @pram   textFont            字体大小
 */
+ (void)makeString:(NSString *)textString toAttributeString:(NSMutableAttributedString *)attributedString  withString:(NSString *)string withTextColor:(UIColor *)textColor withTextFont:(UIFont *)textFont;


/*
 *  多属性字符串
 *
 *  @pram   textString          全字符串
 *  @pram   attributedString    多属性字符串
 *  @pram   string              要改变的字符串
 *  @pram   lineSpace           行间距
 */
+ (void)makeString:(NSString *)textString toAttributeString:(NSMutableAttributedString *)attributedString  withString:(NSString *)string withLineSpacing:(float)lineSpace;

/*
 *  对比字符串显示多少分钟前
 *
 *  @pram   newsDate  要对比的时间字符串
 */
+ (NSString *)getUTCFormateDate:(NSString *)newsDate;

+ (NSString *)getIntervalFormateDate:(long)newsDate;

/*
 *  获取原始图片
 *
 *  @pram   imageName  图片名字
 */
+ (UIImage *)getOriginalImageWithImageName:(NSString *)imageName;

/*
 *  判断数字加字母
 *
 *  @pram   string  比对字符串
 */
+ (BOOL)judgeStringLegal:(NSString *)string;

@end
