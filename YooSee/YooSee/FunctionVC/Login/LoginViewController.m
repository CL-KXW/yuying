//
//  LoginViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define ROW_HEIGHT      50.0
#define SPACE_X         35.0 * CURRENT_SCALE
#define SPACE_Y         5.0 * CURRENT_SCALE
#define BUTTON_HEIGHT   50.0 * CURRENT_SCALE
#define BUTTON_RADIUS   BUTTON_HEIGHT/2
#define FOOT_SPACE_Y    40.0 * CURRENT_SCALE
#define FOOT_ADD_Y      15.0 * CURRENT_SCALE
#define FOOT_SPACE_B_Y  0.0 * CURRENT_SCALE

#define LOADING_FAIL    @"登录失败"


#import "LoginViewController.h"
#import "CustomTextField.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "Utils.h"
#import "P2PClient.h"
#import "ContactDAO.h"
#import "RegisterViewController.h"
#import "FindPasswordViewController.h"

@interface LoginViewController ()

@property (nonatomic, strong) CustomTextField *usernameTextField;
@property (nonatomic, strong) CustomTextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[CommonTool imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self setNavBarItemWithImageName:@"icon_navbar_close_green" navItemType:LeftItem selectorName:@"closeButtonPressed:"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSucess:) name:@"RegisterSucess" object:nil];
    
    [self initUI];
    // Do any additional setup after loading the view.
}


#pragma mark 初始化UI
- (void)initUI
{
    [self addTableView];
    [self addHeaderView];
    [self addFooterView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.scrollEnabled = NO;
}

- (void)addHeaderView
{
    UIImage *image = [UIImage imageNamed:@"img_login_banner"];
    float width = image.size.width/3.0 * CURRENT_SCALE;
    float height = image.size.height/3.0 * CURRENT_SCALE;
    float x = (self.table.frame.size.width - width)/2;
    UIImageView *headerView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, self.table.frame.size.width, height + SPACE_Y * 2) placeholderImage:nil];
    
    UIImageView *bannerImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, SPACE_Y, width, height) placeholderImage:image];
    [headerView addSubview:bannerImageView];
    
    [self.table setTableHeaderView:headerView];
}

- (void)addFooterView
{
    UIImageView *footView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, self.table.frame.size.width, self.table.frame.size.height - self.table.tableHeaderView.frame.size.height - 2 * ROW_HEIGHT - START_HEIGHT) placeholderImage:nil];
    
    float x = SPACE_X;
    float y = FOOT_SPACE_Y;
    float width = self.table.frame.size.width - 2 * SPACE_X;
    float height = BUTTON_HEIGHT;
    UIButton *loginButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, width, height) buttonTitle:@"登录" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"loginButtonPressed:" tagDelegate:self];
    [CommonTool clipView:loginButton withCornerRadius:BUTTON_RADIUS];
    [footView addSubview:loginButton];
    
    y += loginButton.frame.size.height + FOOT_ADD_Y;
    UIButton *registerButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, width, height) buttonTitle:@"注册" titleColor:[UIColor grayColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:nil selectorName:@"registerButtonPressed:" tagDelegate:self];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CommonTool clipView:registerButton withCornerRadius:BUTTON_RADIUS];
    [CommonTool setViewLayer:registerButton withLayerColor:[UIColor grayColor] bordWidth:1.0];
    [footView addSubview:registerButton];
    
    [self.table setTableFooterView:footView];
    
    y = self.table.frame.size.height - FOOT_SPACE_B_Y - BUTTON_HEIGHT;
    UIButton *getPwdButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, width, height) buttonTitle:@"忘记登录密码？" titleColor:[UIColor grayColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:[UIColor clearColor] selectorName:@"getPwdButtonPressed:" tagDelegate:self];
    [self.view addSubview:getPwdButton];
}

#pragma mark 关闭按钮
- (void)closeButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}


#pragma mark 登录按钮 
- (void)loginButtonPressed:(UIButton *)sender
{
    if (![self isCanCommit])
    {
        return;
    }
    NSString *username = self.usernameTextField.textField.text;
    NSString *password = self.passwordTextField.textField.text;
    [self userLoginRequestWithUsername:username password:password];
}

- (BOOL)isCanCommit
{
    NSString *message = @"";
    NSString *userName = self.usernameTextField.textField.text;
    userName = userName ? userName : @"";
    NSString *password = self.passwordTextField.textField.text;
    password = password ? password : @"";
    if (userName.length == 0)
    {
        message = @"用户名不能为空";
    }
    else if (password.length == 0)
    {
        message = @"密码不能为空";
    }
    else if (![CommonTool isEmailOrPhoneNumber:userName])
    {
        message = @"手机号码不正确";
    }
    else if (password.length < 6)
    {
        message = @"密码不能少于6位";
    }
    
    if (message.length > 0)
    {
        [CommonTool addPopTipWithMessage:message];
        return NO;
    }
    
    return YES;
}

#pragma mark 登录请求
- (void)userLoginRequestWithUsername:(NSString *)username password:(NSString *)password
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"phone":username,@"passwd":[CommonTool md5:password]};
    [[RequestTool alloc] desRequestWithUrl:USER_LOGIN_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"USER_LOGIN_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : LOADING_FAIL;
         if (errorCode == 1)
         {
             [USER_DEFAULT setValue:username forKey:@"UserName"];
             [USER_DEFAULT setValue:password forKey:@"Password"];
             [weakSelf setDataWithDictionary:dataDic];
         }
         else
         {
             [LoadingView dismissLoadingView];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFinish" object:nil];
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"USER_LOGIN_URL====%@",error);
         [LoadingView dismissLoadingView];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFinish" object:nil];
         [SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
    
}

#pragma mark 保存系统数据
- (void)setDataWithDictionary:(NSDictionary *)dataDic
{
    [YooSeeApplication shareApplication].userDic = dataDic[@"body"][0];
    NSString *uid = dataDic[@"body"][0][@"uid"];
    uid = uid ? uid : @"";
    [YooSeeApplication shareApplication].uid = uid;
    [self login2CU];

}

- (void)login2CU
{
    NSString *password = [YooSeeApplication shareApplication].pwd2cu;
    NSString *email = [NSString stringWithFormat:@"newyywapp%@@yywapp.com",[USER_DEFAULT objectForKey:@"UserName"]];
    // 登陆2cu
    NSString *username = email;
    
    NSString *clientId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    clientId = [clientId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    LoginResult *loginResult = [[LoginResult alloc] init];
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"User":username,@"Pwd":[password getMd5_32Bit_String],@"Token":clientId,@"StoreID":@"0"};
    [[RequestTool alloc] requestWithUrl:LOGIN_2CU_URL
                            requestParamas:requestDic
                               requestType:RequestTypeSynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"2cu_USER_LOGIN_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"error_code"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : LOADING_FAIL;
         [LoadingView dismissLoadingView];
         
         if (errorCode == 0)
         {
             [YooSeeApplication shareApplication].user2CUDic = dataDic;
             int iContactId = ((NSString*)dataDic[@"UserID"]).intValue & 0x7fffffff;
             loginResult.contactId = [NSString stringWithFormat:@"0%i",iContactId];
             loginResult.rCode1 = dataDic[@"P2PVerifyCode1"];
             loginResult.rCode2 = dataDic[@"P2PVerifyCode2"];
             loginResult.phone = dataDic[@"PhoneNO"];
             loginResult.email = dataDic[@"Email"];
             loginResult.sessionId = dataDic[@"SessionID"];
             loginResult.countryCode = dataDic[@"CountryCode"];
             loginResult.error_code = [dataDic[@"error_code"] integerValue];
             [UDManager setIsLogin:YES];
             [UDManager setLoginInfo:loginResult];
             
             BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId  codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
             NSLog(@"p2pConnect success.===%d",result);
             
             NSString *defaultDeviceID = [USER_DEFAULT objectForKey:@"DefaultDeviceID"];
             defaultDeviceID = defaultDeviceID ? defaultDeviceID : @"";
             if (defaultDeviceID.length != 0)
             {
                 ContactDAO *contactDAO = [[ContactDAO alloc] init];
                 Contact *contact = [contactDAO isContact:defaultDeviceID];
                 if (contact)
                 {
                     [YooSeeApplication shareApplication].contact = contact;
                 }
             }
             [YooSeeApplication shareApplication].isLogin = YES;
             [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFinish" object:nil];
             [weakSelf dismissViewControllerAnimated:YES completion:nil];
         }
         else
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFinish" object:nil];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFinish" object:nil];
         [LoadingView dismissLoadingView];
         NSLog(@"2cu_USER_LOGIN_URL====%@",error);
     }];

    
    
//    [[NetManager sharedManager] loginWithUserName:username password:password token:/*[UserDefaults objectForKey:@"2cu_token"]*/[NSString UUID] callBack:^(id result) {
//        
//        LoginResult *loginResult = (LoginResult*)result;
//        /*! *设置登录状态 */
//        [UDManager setIsLogin:loginResult.error_code == NET_RET_LOGIN_SUCCESS];
//        switch (loginResult.error_code) {
//            case NET_RET_LOGIN_SUCCESS:
//                
//                NSLog(@"contactId:%@",loginResult.contactId);
//                NSLog(@"Email:%@",loginResult.email);
//                NSLog(@"Phone:%@",loginResult.phone);
//                NSLog(@"CountryCode:%@",loginResult.countryCode);
//                [UDManager setLoginInfo:loginResult];
//                
//                [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON)
//                {
//                    AccountResult *accountResult = (AccountResult*)JSON;
//                    loginResult.email = accountResult.email;
//                    loginResult.phone = accountResult.phone;
//                    loginResult.countryCode = accountResult.countryCode;
//                    [UDManager setLoginInfo:loginResult];
//                }];
//                
//                
//                [[NetManager sharedManager] checkNewMessage:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON)
//                 {
//                     CheckNewMessageResult *checkNewMessageResult = (CheckNewMessageResult*)JSON;
//                     
//                     if(checkNewMessageResult.error_code == NET_RET_CHECK_NEW_MESSAGE_SUCCESS){
//                         if(checkNewMessageResult.isNewContactMessage){
//                             DLog(@"have new");
//                             [[NetManager sharedManager] getContactMessageWithUsername:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
//                                 NSArray *datas = [NSArray arrayWithArray:JSON];
//                                 if([datas count]<=0){
//                                     return;
//                                 }
//                                 BOOL haveContact = NO;
//                                 for(GetContactMessageResult *result in datas){
//                                     DLog(@"%@",result.message);
//                                     ContactDAO *contactDAO = [[ContactDAO alloc] init];
//                                     Contact *contact = [contactDAO isContact:result.contactId];
//                                     if(nil!=contact){
//                                         haveContact = YES;
//                                     }
//                                     [contactDAO release];
//                                     
//                                     MessageDAO *messageDAO = [[MessageDAO alloc] init];
//                                     Message *message = [[Message alloc] init];
//                                     
//                                     message.fromId = result.contactId;
//                                     message.toId = loginResult.contactId;
//                                     message.message = [NSString stringWithFormat:@"%@",result.message];
//                                     message.state = MESSAGE_STATE_NO_READ;
//                                     message.time = [NSString stringWithFormat:@"%@",result.time];
//                                     message.flag = result.flag;
//                                     [messageDAO insert:message];
//                                     [message release];
//                                     [messageDAO release];
//                                     int lastCount = [[FListManager sharedFList] getMessageCount:result.contactId];
//                                     [[FListManager sharedFList] setMessageCountWithId:result.contactId count:lastCount+1];
//                                     
//                                 }
//                                 if(haveContact)
//                                 {
//                                     [Utils playMusicWithName:@"message" type:@"mp3"];
//                                 }
//                                 
//                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                                     object:self
//                                                                                   userInfo:nil];
//                             }];
//                         }
//                     }else{
//                         
//                     }
//                 }];
//                if(succes)succes();
//                break;
//            case NET_RET_LOGIN_USER_UNEXIST:
//                // 用户不存在
//                //[self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
//                [self register2Cu:succes];
//                break;
//            case NET_RET_LOGIN_PWD_ERROR:
//                //  密码错误
//                [self.view makeToast:NSLocalizedString(@"2cu平台帐号密码错误", nil)];
//                break;
//            case NET_RET_LOGIN_EMAIL_FORMAT_ERROR:
//                
//                
//                //                    [self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
//                break;
//            default:
//                /*[[UIApplication sharedApplication].keyWindow makeToast:
//                 [NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"login_failure", nil),loginResult.error_code]
//                 duration:2 position:@"center"];*/
//                //弹出登陆视图
//                //[[NSNotificationCenter defaultCenter] postNotificationName:@"doShowLoginVC" object:nil];
//                break;
//        }
//    }];
}


#pragma mark 忘记密码
- (void)getPwdButtonPressed:(UIButton *)sender
{
    FindPasswordViewController *findPasswordViewController = [[FindPasswordViewController alloc] init];
    [self.navigationController pushViewController:findPasswordViewController animated:YES];
}

#pragma mark 注册
- (void)registerButtonPressed:(UIButton *)sender
{
    RegisterViewController *registerViewController = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerViewController animated:YES];
}


#pragma mark 注册成功
- (void)registerSucess:(NSNotification *)notification
{
    NSArray *array = (NSArray *)notification.object;
    self.usernameTextField.textField.text = array[0];
    self.passwordTextField.textField.text = array[1];
    [self loginButtonPressed:nil];
}

#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (!_usernameTextField)
    {
        _usernameTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(SPACE_X, 0, SCREEN_WIDTH - 2 * SPACE_X, ROW_HEIGHT)];
        _usernameTextField.textField.placeholder = @"手机号码";
        _usernameTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
        _usernameTextField.textField.text = @"";
    }
    
    if (!_passwordTextField)
    {
        _passwordTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(SPACE_X, 0, SCREEN_WIDTH - 2 * SPACE_X, ROW_HEIGHT)];
        _passwordTextField.textField.secureTextEntry = YES;
        _passwordTextField.textField.placeholder = @"登录密码";
        _passwordTextField.textField.text = @"";
    }
    
    if (indexPath.row == 0)
    {
        [cell.contentView addSubview:_usernameTextField];
    }
    if (indexPath.row == 1)
    {
        [cell.contentView addSubview:_passwordTextField];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
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
