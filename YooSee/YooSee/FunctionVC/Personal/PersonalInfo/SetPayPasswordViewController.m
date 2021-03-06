//
//  SetPayPasswordViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define TEXTFIELD_HEIGHT    40.0 * CURRENT_SCALE
#define SPACE_X             30.0 * CURRENT_SCALE
#define SPACE_Y             30.0 * CURRENT_SCALE
#define ADD_Y               15.0
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "SetPayPasswordViewController.h"
#import "CustomTextField.h"

@interface SetPayPasswordViewController ()

@property (nonatomic, strong) NSMutableArray *textFiledArray;
@property (nonatomic, strong) NSString *password;

@end

@implementation SetPayPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置支付密码";
    [self addBackItem];
    
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
    
    NSArray *array = @[@"输入密码(6位)",@"再次输入密码"];
    
    for (int i = 0; i < [array count]; i++)
    {
        CustomTextField *textField = [[CustomTextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        textField.textField.placeholder = array[i];
        textField.textField.secureTextEntry = YES;
        textField.textField.keyboardType = UIKeyboardTypeNumberPad;
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


#pragma mark 确认按钮
- (void)commitButtonPressed:(UIButton *)sender
{
    NSString *newPassword = ((CustomTextField *)self.textFiledArray[0]).textField.text;
    NSString *surePassword = ((CustomTextField *)self.textFiledArray[1]).textField.text;
    
    if (newPassword.length != 6 || surePassword.length != 6)
    {
        [CommonTool addPopTipWithMessage:@"密码为6位数字"];
        return;
    }
    else if (![newPassword isEqualToString:surePassword])
    {
        [CommonTool addPopTipWithMessage:@"密码不一致"];
        return;
    }
    self.password = surePassword;
    [self updatePasswordRequest];
}

#pragma mark 更新密码
- (void)updatePasswordRequest
{
    [self dismissKeyBorad];
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:[YooSeeApplication shareApplication].userInfoDic];
    NSDictionary *requestDic = @{@"phone":[USER_DEFAULT objectForKey:@"UserName"],@"paypwd":[CommonTool md5:self.password],@"userpwd":[CommonTool md5:[USER_DEFAULT objectForKey:@"Password"]]};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:SET_PAY_PASSWOR_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"SET_PAY_PASSWOR_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 8)
         {
             [SVProgressHUD showSuccessWithStatus:@"设置成功"];
             userInfoDic[@"paytype"] = @"1";
             [YooSeeApplication shareApplication].userInfoDic = userInfoDic;
             [weakSelf.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"UPDATE_LOGIN_PWD_URL====%@",error);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
