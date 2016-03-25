//
//  FindPasswordViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define TEXTFIELD_HEIGHT    40.0 * CURRENT_SCALE
#define SPACE_X             30.0 * CURRENT_SCALE
#define SPACE_Y             35.0 * CURRENT_SCALE
#define ADD_Y               15.0
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2
#define SHOWBUTTON_WIDTH    100.0

#import "FindPasswordViewController.h"
#import "CustomTextField.h"

@interface FindPasswordViewController ()

@property (nonatomic, strong) NSMutableArray *textFiledArray;
@property (nonatomic, strong) NSString *codeString;
@property (nonatomic, strong) NSString *surePassword;
@property (nonatomic, strong) NSString *phoneString;
@property (nonatomic, strong) UIButton *codeButton;
@property (nonatomic, strong) NSTimer *countTimer;
@property (nonatomic, assign) int count;

@end

@implementation FindPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"忘记密码";
    [self addBackItem];
    
    self.count = 60;
    
    [self initUI];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    float x = SPACE_X;
    float y = SPACE_Y + START_HEIGHT;
    float width = self.view.frame.size.width - 2 * x;
    float height = TEXTFIELD_HEIGHT;
    
    NSArray *array = @[@"手机号", @"短信验证码",@"设置新的密码",@"再次输入密码"];
    
    for (int i = 0; i < [array count]; i++)
    {
        CustomTextField *textField = [[CustomTextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        textField.textField.placeholder = array[i];
        if (i > 1)
        {
            textField.textField.secureTextEntry = YES;
        }
        if (i == 0)
        {
            textField.textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        if (i == 1)
        {
            _codeButton = [CreateViewTool createButtonWithFrame:CGRectMake(0, 0, SHOWBUTTON_WIDTH, height) buttonTitle:@"获取验证码" titleColor:LIGHT_MAIN_COLOR normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:[UIColor clearColor] selectorName:@"codeButtonPressed:" tagDelegate:self];
            _codeButton.titleLabel.font = FONT(14.0);
            _codeButton.showsTouchWhenHighlighted = YES;
            textField.textField.rightView = _codeButton;
            textField.textField.rightViewMode = UITextFieldViewModeAlways;
        }
        [self.view addSubview:textField];
        
        if (!_textFiledArray)
        {
            _textFiledArray = [[NSMutableArray alloc] init];
        }
        [self.textFiledArray addObject:textField];
        y += textField.frame.size.height + ADD_Y;
    }
    
    y += 2 * SPACE_Y;
    UIButton *commitButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, width, BUTTON_HEIGHT) buttonTitle:@"确认" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"commitButtonPressed:" tagDelegate:self];
    [CommonTool clipView:commitButton withCornerRadius:BUTTON_RADIUS];
    [self.view addSubview:commitButton];
}

#pragma mark 获取验证码
- (void)codeButtonPressed:(UIButton *)sender
{
    NSString *phone = ((CustomTextField *)self.textFiledArray[0]).textField.text;
    if (![CommonTool isEmailOrPhoneNumber:phone])
    {
        [CommonTool addPopTipWithMessage:@"手机号码不正确"];
        return;
    }
    self.phoneString = phone;
    [self getCodeRequest];
}
//创建Timer
- (void)createTimer
{
    self.codeButton.enabled = NO;
    if ([_countTimer isValid])
    {
        [_countTimer invalidate];
    }
    _countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeCount:) userInfo:nil repeats:YES];
}

//定时器执行方法
- (void)changeCount:(NSTimer *)timer
{
    self.count--;
    if (self.count == 0)
    {
        [self resetTimer];
        return;
    }
    NSString *titleStr = [NSString stringWithFormat:@"重新获取(%ds)",self.count];
    [self.codeButton setTitle:titleStr forState:UIControlStateNormal];
    
}

//清掉定时器
- (void)resetTimer
{
    [self.countTimer invalidate];
    self.codeButton.enabled = YES;
    self.count = 60;
    [self.codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

- (void)getCodeRequest
{
    [self dismissKeyBorad];
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"phone":self.phoneString,@"method":@(2)};
    NSString *url =  PHONE_CODE_URL;
    [[RequestTool alloc] requestWithUrl:url
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"PHONE_CODE_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             [SVProgressHUD showSuccessWithStatus:@"发送成功"];
             [weakSelf createTimer];
             weakSelf.codeButton.enabled = NO;
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"PHONE_CODE_URL====%@",error);
         [LoadingView dismissLoadingView];
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];

}

#pragma mark 确认按钮
- (void)commitButtonPressed:(UIButton *)sender
{
    NSString *phone = ((CustomTextField *)self.textFiledArray[0]).textField.text;
    NSString *code = ((CustomTextField *)self.textFiledArray[1]).textField.text;
    NSString *password = ((CustomTextField *)self.textFiledArray[2]).textField.text;
    NSString *surePassword = ((CustomTextField *)self.textFiledArray[3]).textField.text;

    NSString *message = @"";
    if (![CommonTool isEmailOrPhoneNumber:phone])
    {
        message = @"请输入正确的手机号";
    }
    else if (code.length == 0)
    {
        message = @"请输入手机验证码";
    }
    else if (password.length < 6 || surePassword.length < 6)
    {
        message = @"密码不小于6位";
    }
    else if (![password isEqualToString:surePassword])
    {
        message = @"密码不一致";
    }
    if (message.length != 0)
    {
        [CommonTool addPopTipWithMessage:message];
        return;
    }
    
    self.codeString = code;
    self.surePassword = surePassword;
    self.phoneString = phone;
    [self updatePasswordRequest];
}

#pragma mark 更新密码
- (void)updatePasswordRequest
{
    [self dismissKeyBorad];
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"phone":self.phoneString,@"passwd":[CommonTool md5:self.surePassword],@"verifysms":self.codeString,@"method":@(2)};
    
    NSString *url =  REGISTER_URL;
    if (self.isPayPassword) {
        url = SET_PAY_PASSWOR_URL;
        requestDic = @{@"paypasswd":[CommonTool md5:self.surePassword], @"uid":[[YooSeeApplication shareApplication] uid], @"smscode":self.codeString};
    }
    [[RequestTool alloc] requestWithUrl:url
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"REGISTER_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             [SVProgressHUD showSuccessWithStatus:@"修改成功"];
             [USER_DEFAULT setObject:self.surePassword forKey:@"Password"];
             [weakSelf.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"REGISTER_URL====%@",error);
         [LoadingView dismissLoadingView];
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}

- (void)dismissKeyBorad
{
    for (CustomTextField *textField in self.textFiledArray)
    {
        [textField.textField resignFirstResponder];
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.countTimer invalidate];
    self.countTimer = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
