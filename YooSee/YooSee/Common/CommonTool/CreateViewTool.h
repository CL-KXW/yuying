//
//  CreateViewTool.h
//  SmallPig
//
//  Created by clei on 14/11/5.
//  Copyright (c) 2014年 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonTool.h"  
#import "UIImageView+WebCache.h"
#import "UIImageView+LK.h"
#import "UIButton+WebCache.h"

@interface CreateViewTool : NSObject

/*
 *  创建Label
 *
 *  @param   frame   Label尺寸
 *  @param   color   文字颜色
 *  @param   text    文字内容
 *  @param   font    文字字体
 *
 *  @return UILabel对象
 */
+ (UILabel *)createLabelWithFrame:(CGRect)frame  textString:(NSString *)text textColor:(UIColor *)color textFont:(UIFont *)font;

/*
 *  创建UIImageView 获取网络图片
 *
 *  @param   frame       Label尺寸
 *  @param   image       默认图片
 *  @param   urlString   图片地址
 *  @param   showProcess 是否显示进度条
 *
 *  @return UIImageView对象
 */
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame placeholderImage:(UIImage *)image imageUrl:(NSString *)urlString isShowProcess:(BOOL)showProcess;

/*
 *  创建普通的UIImageView
 *
 *  @param   frame   Label尺寸
 *  @param   image   默认图片
 *
 *  @return UIImageView对象
 */
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame placeholderImage:(UIImage *)image;

/*
 *  圆形头像UIImageView视图
 *
 *  @param   frame     Label尺寸
 *  @param   image     默认图片
 *  @param   urlString 图片地址
 *  @param   color     layer颜色
 *
 *  @return UIImageView对象
 */
+ (UIImageView *)createRoundImageViewWithFrame:(CGRect)frame placeholderImage:(UIImage *)image  borderColor:(UIColor*)color  imageUrl:(NSString *)urlString;

/*
 *  创建UITextField
 *
 *  @param   frame   Label尺寸
 *  @param   color   文字颜色
 *  @param   font    文字大小
 *  @param   text    默认文字
 *
 *  @return UITextField对象
 */
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame textColor:(UIColor *)color textFont:(UIFont *)font placeholderText:(NSString *)text;

/*
 *  以图片创建按钮
 *
 *  @param   imageName  图片名称(如：back_up back_down 传back)
 *  @param   selName    方法名
 *  @param   delegate   按钮响应方法类
 *
 *  @return UIButton对象
 */
+ (UIButton *)createButtonWithImage:(NSString *)imageName selectorName:(NSString *)selName tagDelegate:(id)delegate;

/*
 *  以frame创建按钮
 *
 *  @param   frame      button尺寸
 *  @param   imageName  图片名称
 *  @param   selName    方法名
 *  @param   delegate   按钮响应方法类
 *
 *  @return UIButton对象
 */

+ (UIButton *)createButtonWithFrame:(CGRect)frame buttonImage:(NSString *)imageName selectorName:(NSString *)selName tagDelegate:(id)delegate;

/*
 *  以frame创建按钮 用颜色设置图片
 *
 *  @param   nor_Title       button正常状态title
 *  @param   color           button正常状态titlecolor
 *  @param   frame           button尺寸
 *  @param   normalColor     默认颜色
 *  @param   selectedColor   选中颜色
 *  @param   selName         方法名
 *  @param   delegate        按钮响应方法类
 *
 *  @return UIButton对象
 */
+ (UIButton *)createButtonWithFrame:(CGRect)frame buttonTitle:(NSString *)nor_Title  titleColor:(UIColor *)color normalBackgroundColor:(UIColor *)normalColor highlightedBackgroundColor:(UIColor *)selectedColor selectorName:(NSString *)selName tagDelegate:(id)delegate;
@end
