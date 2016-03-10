//
//  CustomLineLabel.m
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define NORMAL_LINE_COLOR   [UIColor lightGrayColor]
#define HIGHT_LINE_COLOR    RGB(23.0,149.0,26.0)

#import "CustomTextField.h"

@interface CustomTextField()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *lineImageView;

@end

@implementation CustomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
    }
    return self;
}

#pragma mark 初始化UI
- (void)initUI
{
    _textField = [CreateViewTool createTextFieldWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) textColor:[UIColor blackColor] textFont:FONT(20.0) placeholderText:@""];
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    [self addSubview:_textField];
    _lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, self.frame.size.height - 1.0, self.frame.size.width, 1.0) placeholderImage:nil];
    _lineImageView.backgroundColor = NORMAL_LINE_COLOR;
    [self addSubview:_lineImageView];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _lineImageView.backgroundColor = HIGHT_LINE_COLOR;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _lineImageView.backgroundColor = NORMAL_LINE_COLOR;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
