//
//  CreateViewTool.m
//  SmallPig
//
//  Created by clei on 14/11/5.
//  Copyright (c) 2014年 chenlei. All rights reserved.
//

#import "CreateViewTool.h"


@implementation CreateViewTool

#pragma mark UILabel

//创建Label
+ (UILabel *)createLabelWithFrame:(CGRect)frame  textString:(NSString *)text textColor:(UIColor *)color textFont:(UIFont *)font
{
    UILabel *lable = [[UILabel alloc] initWithFrame:frame];
    lable.backgroundColor = [UIColor clearColor];
    lable.textColor = color;
    lable.font = font;
    lable.textAlignment = NSTextAlignmentLeft;
    if (text && ![@"" isEqualToString:text])
    {
        lable.text = text;
    }
    
    return lable;
}

#pragma mark UIImageView
//创建UIImageView 获取网络图片
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame placeholderImage:(UIImage *)image imageUrl:(NSString *)urlString isShowProcess:(BOOL)showProcess
{
    UIImageView *imageView = [self createImageViewWithFrame:frame placeholderImage:image];
    if (!showProcess)
    {
        [imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:image];
    }
    else
    {
        imageView.imageURL = urlString;
    }
    return imageView;
}

//创建普通的UIImageView
+ (UIImageView *)createImageViewWithFrame:(CGRect)frame placeholderImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.userInteractionEnabled = YES;
    imageView.image = image;
    return imageView;
}

//圆形头像视图
+ (UIImageView *)createRoundImageViewWithFrame:(CGRect)frame placeholderImage:(UIImage *)image  borderColor:(UIColor *)color  imageUrl:(NSString *)urlString
{
    UIImageView *imageView = [self createImageViewWithFrame:frame placeholderImage:image];
    imageView.layer.borderWidth = 0.5;
    if (!color)
    {
        imageView.layer.borderWidth = 0.0;
        color = [UIColor clearColor];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    imageView.layer.borderColor = [color CGColor];
    imageView.layer.cornerRadius = CGRectGetWidth(frame)/2;
    imageView.layer.masksToBounds = YES;
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:image];
    return imageView;
}

#pragma mark UITextField
//创建UITextField
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame textColor:(UIColor *)color textFont:(UIFont *)font placeholderText:(NSString *)text
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    textField.backgroundColor = [UIColor clearColor];
    textField.textColor = color;
    textField.text = @"";
    textField.font = font;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.borderStyle = UITextBorderStyleNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.placeholder = text;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, textField.frame.size.height)];
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    return textField;
}


#pragma mark UIButton
//以图片创建按钮
+ (UIButton *)createButtonWithImage:(NSString *)imageName selectorName:(NSString *)selName tagDelegate:(id)delegate
{
    if (!imageName || [@"" isEqualToString:imageName])
    {
        return nil;
    }
    UIImage *image_up = [UIImage imageNamed:[imageName stringByAppendingString:@"_up.png"]];
    UIImage *image_down = [UIImage imageNamed:[imageName stringByAppendingString:@"_down.png"]];
    if (!image_up)
    {
        return nil;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image_up.size.width/2, image_up.size.height/2);
    [button setBackgroundImage:image_up forState:UIControlStateNormal];
    [button setBackgroundImage:image_down forState:UIControlStateHighlighted];
    [button setBackgroundImage:image_down forState:UIControlStateSelected];
    if (selName && ![@"" isEqualToString:selName])
    {
        if (delegate && [delegate respondsToSelector:NSSelectorFromString(selName)])
        {
            [button addTarget:delegate action:NSSelectorFromString(selName) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return button;
}

//以frame创建按钮
+ (UIButton *)createButtonWithFrame:(CGRect)frame buttonImage:(NSString *)imageName selectorName:(NSString *)selName tagDelegate:(id)delegate
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    if (imageName && ![@"" isEqualToString:imageName])
    {
        UIImage *image_up = [UIImage imageNamed:[imageName stringByAppendingString:@"_up.png"]];
        UIImage *image_down = [UIImage imageNamed:[imageName stringByAppendingString:@"_down.png"]];
        [button setBackgroundImage:image_up forState:UIControlStateNormal];
        [button setBackgroundImage:image_down forState:UIControlStateHighlighted];
        [button setBackgroundImage:image_down forState:UIControlStateSelected];
    }
    if (selName && ![@"" isEqualToString:selName])
    {
        if (delegate && [delegate respondsToSelector:NSSelectorFromString(selName)])
        {
            [button addTarget:delegate action:NSSelectorFromString(selName) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return button;
}

//以frame创建按钮 用颜色设置图片
+ (UIButton *)createButtonWithFrame:(CGRect)frame buttonTitle:(NSString *)nor_Title  titleColor:(UIColor *)color normalBackgroundColor:(UIColor *)normalColor highlightedBackgroundColor:(UIColor *)selectedColor selectorName:(NSString *)selName tagDelegate:(id)delegate
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    if (nor_Title && ![@"" isEqualToString:nor_Title])
    {
        [button setTitle:nor_Title forState:UIControlStateNormal];
    }
    if (color)
    {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    if (normalColor)
    {
        [button setBackgroundImage:[CommonTool imageWithColor:normalColor] forState:UIControlStateNormal];
    }
    if (selectedColor)
    {
        [button setBackgroundImage:[CommonTool imageWithColor:selectedColor] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[CommonTool imageWithColor:selectedColor] forState:UIControlStateSelected];
    }
    else
    {
        [button setBackgroundImage:[CommonTool imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    }
    if (selName && ![@"" isEqualToString:selName])
    {
        if (delegate && [delegate respondsToSelector:NSSelectorFromString(selName)])
        {
            [button addTarget:delegate action:NSSelectorFromString(selName) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    button.titleLabel.font = FONT(16.0);
    
    return  button;
}



@end
