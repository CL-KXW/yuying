//
//  RealNameCheckViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y             START_HEIGHT + 20 * CURRENT_SCALE
#define TEXTFIELD_HEIGHT    40.0 * CURRENT_SCALE
#define SPACE_X             5.0 * CURRENT_SCALE
#define PLACEHOLDER_EMAIL   @"姓名"
#define PLACEHOLDER_NICK    @"身份证"
#define TIP_LABEL_HEIGHT    40.0 * CURRENT_SCALE
#define ADD_Y               20.0 * CURRENT_SCALE
#define BUTTON_SPACE_X      15.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "BindCardViewController.h"

@interface BindCardViewController ()

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *idTextField;

@end

@implementation BindCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"支付宝绑定";
    [self addBackItem];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    float y = SPACE_Y;
    UILabel *tiplabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, self.view.frame.size.width, TIP_LABEL_HEIGHT) textString: @"请填写真实信息，以方便日后提现~！绑定后不可修改。" textColor:MAIN_TEXT_COLOR textFont:FONT(14.0)];
    tiplabel.numberOfLines = 2;
    tiplabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tiplabel];
    
    y += tiplabel.frame.size.height + ADD_Y;
    _nameTextField = [CreateViewTool createTextFieldWithFrame:CGRectMake(0, y, self.view.frame.size.width, TEXTFIELD_HEIGHT) textColor:MAIN_TEXT_COLOR textFont:FONT(16.0) placeholderText:@"姓名"];
    _nameTextField.backgroundColor = [UIColor whiteColor];
    NSString *name = [YooSeeApplication shareApplication].userInfoDic[@"name"];
    name = name ? name : @"";
    _nameTextField.text = name;
    [self.view addSubview:_nameTextField];
    
    
    y += _nameTextField.frame.size.height + ADD_Y;
    _idTextField = [CreateViewTool createTextFieldWithFrame:CGRectMake(0, y, self.view.frame.size.width, TEXTFIELD_HEIGHT) textColor:MAIN_TEXT_COLOR textFont:FONT(16.0) placeholderText:@"支付宝帐号"];
    _idTextField.backgroundColor = [UIColor whiteColor];
    NSString *alipay = [YooSeeApplication shareApplication].userInfoDic[@"alipay"];
    alipay = alipay ? alipay : @"";
    _idTextField.text = alipay;
    [self.view addSubview:_idTextField];
    
//    if (_isBinded)
//    {
//        _idTextField.enabled = NO;
//        _nameTextField.enabled = NO;
//    }
//    else
    {
        y += _idTextField.frame.size.height + 2 * ADD_Y;
    }
    UIButton *commitButton = [CreateViewTool createButtonWithFrame:CGRectMake(SPACE_X, y, self.view.frame.size.width - 2 * SPACE_X, BUTTON_HEIGHT) buttonTitle:@"确认" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"commitButtonPressed:" tagDelegate:self];
    [CommonTool clipView:commitButton withCornerRadius:BUTTON_RADIUS];
    [self.view addSubview:commitButton];
}

#pragma mark 确认
- (void)commitButtonPressed:(UIButton *)sender
{
    [self.nameTextField resignFirstResponder];
    [self.idTextField resignFirstResponder];
    NSString *username = self.nameTextField.text;
    username = username ? username : @"";
    NSString *cardID = self.idTextField.text;
    cardID = cardID ? cardID : @"";
    if (username.length == 0)
    {
        [CommonTool addPopTipWithMessage:@"姓名不能为空"];
        return;
    }
    else if (cardID.length == 0)
    {
        [CommonTool addPopTipWithMessage:@"支付宝帐号不能为空"];
        return;
    }
    else
    {
        [self changeUserInfoRequest];
    }
}

#pragma mark 添加卡
- (void)changeUserInfoRequest
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:[YooSeeApplication shareApplication].userInfoDic];
    NSMutableDictionary *paramasDic = [NSMutableDictionary dictionaryWithCapacity:0];
    paramasDic[@"id"] = [YooSeeApplication shareApplication].uid;
    paramasDic[@"name"] = self.nameTextField.text;
    paramasDic[@"alipay"] = self.idTextField.text;
    NSDictionary *requestDic = [RequestDataTool encryptWithDictionary:paramasDic];
    [[RequestTool alloc] requestWithUrl:UPDATE_USER_INFO_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"UPDATE_USER_INFO_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 8)
         {
             [SVProgressHUD showSuccessWithStatus:@"保存成功"];
             userInfoDic[@"name"] = self.nameTextField.text;
             userInfoDic[@"alipay"] = self.idTextField.text;
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
         NSLog(@"UPDATE_USER_INFO_URL====%@",error);
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:@"保存失败"];
     }];
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
