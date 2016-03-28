//
//  CheckPwdVC.m
//  YooSee
//
//  Created by Shaun on 16/3/20.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "CheckPwdVC.h"
#import "ZSDSetPasswordView.h"
#import "FindPasswordViewController.h"

@interface CheckPwdVC () <ZSDSetPasswordViewDelegate>
{
    ZSDSetPasswordView *_passwordView;
}
@end
@implementation CheckPwdVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付密码";
    [self addBackItem];
    _passwordView = [[ZSDSetPasswordView alloc] initWithFrame:CGRectMake(10, 74, SCREEN_WIDTH - 20, 35)];
    [_passwordView.passwordTextField becomeFirstResponder];
    _passwordView.delegate = self;
    [self.view addSubview:_passwordView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 115, 90, 30)];
    [self.view addSubview:btn];
    [btn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(forgetPwd) forControlEvents:UIControlEventTouchUpInside];
}

- (void)forgetPwd {
    FindPasswordViewController *findPwd = [[FindPasswordViewController alloc] init];
    findPwd.isPayPassword = YES;
    [self.navigationController pushViewController:findPwd animated:YES];
}

- (void)passwordView:(ZSDSetPasswordView*)passwordView inputPassword:(NSString*)password {
    if (password.length == 6) {

        [self checkRequest:password];
    }
}

- (void)checkRequest:(NSString*)pwd {
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid":uid, @"paypasswd":pwd};
    [[RequestTool alloc] requestWithUrl:CHECK_PAY_PASSWORD_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"MONEY_DRAWCASHCHECK===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             [self requestSubmit];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage duration:2.5];
         }
     }
                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [SVProgressHUD showErrorWithStatus:error.description duration:2.5];
     }];
}

- (void)requestSubmit {
    if (self.cardID == nil) {
        return;
    }
    /*
     user_id 	String 提现用户ID
     tixian_money 	string     提现金额
     poundage_money 	string     提现手续费 提现手续费 没有手续费传入0.00
     name 	string     会员姓名
     alipay 	string     支付宝账号
     phone 	string     会员手机号
     */
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *phone = [[YooSeeApplication shareApplication] userInfoDic][@"phone"];
    phone = phone ? phone : @"";
    NSString *name = [[YooSeeApplication shareApplication] userInfoDic][@"name"];
    name = name ? name : @"";
    NSDictionary *requestDic = @{@"user_id":uid,
                                 @"tixian_money":@(_money),
                                 @"alipay": _cardID,
                                 @"poundage_money":@(0.00),
                                 @"phone":phone,
                                 @"name":name};
    [[RequestTool alloc] requestWithUrl:MONEY_DRAWCASHSUBMIT
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"MONEY_DRAWCASHCHECK===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         //状态码(1失败,2资金不够,3支付密码验证失败,8成功)
         if (errorCode == 8)
         {
             [SVProgressHUD showSuccessWithStatus:errorMessage duration:2.0];
             [self.navigationController performSelector:@selector(popToRootViewControllerAnimated:) withObject:@(YES) afterDelay:2.0];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage duration:2.5];
         }
     }
                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}
@end
