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

#import "XGPush.h"

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
    [self.usernameTextField.textField resignFirstResponder];
    [self.passwordTextField.textField resignFirstResponder];
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
    NSDictionary *requestDic = @{@"phone":username,@"password":[RequestDataTool aesDataWithString:[CommonTool md5:password]]};
    [[RequestTool alloc] requestWithUrl:USER_LOGIN_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"USER_LOGIN_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : LOADING_FAIL;
         if (errorCode == 8)
         {
             [USER_DEFAULT setValue:username forKey:@"UserName"];
             [USER_DEFAULT setValue:password forKey:@"Password"];
             [weakSelf setDataWithDictionary:dataDic];
             
             AppDelegate *app = DELEGATE;
             if (app.deviceTokenStr != nil) {
                 [XGPush setAccount:username];
                 NSString*token = [XGPush registerDevice:app.deviceTokenStr successCallback:^{
                     NSLog(@"token succ");
                 } errorCallback:^{

                 }];
                 [self reportToken:token];
             }else{
                 [LoadingView dismissLoadingView];
             }
         }
         else
         {
             [LoadingView dismissLoadingView];
             [YooSeeApplication shareApplication].isLogin = NO;
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"USER_LOGIN_URL====%@",error);
         [YooSeeApplication shareApplication].isLogin = NO;
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
    
}

-(void)reportToken:(NSString *)token{
    if(token == nil){
        [LoadingView dismissLoadingView];
        [self.navigationController dismissViewControllerAnimated:YES completion:Nil];
        return;
    }
    
    NSDictionary *requestDic = @{@"phone":self.usernameTextField.textField.text,@"device_number":token,@"jingdu":@"0.00000",@"weidu":@"0.00000",@"type":@"2"};
    NSString *url = [Url_Host stringByAppendingString:@"/app/xg/report"];
    [[RequestTool alloc] requestWithUrl:url
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         if (errorCode == 8)
         {
             
         }
         
         [LoadingView dismissLoadingView];
         [self.navigationController dismissViewControllerAnimated:YES completion:Nil];
     }requestFail:^(AFHTTPRequestOperation *operation, NSError *error){
         [LoadingView dismissLoadingView];
         [self.navigationController dismissViewControllerAnimated:YES completion:Nil];
     }];
}

#pragma mark 保存系统数据
- (void)setDataWithDictionary:(NSDictionary *)dataDic
{
    NSDictionary *dic = dataDic[@"resultList"][0];
    [YooSeeApplication shareApplication].userDic = dic;
    [USER_DEFAULT setValue:dic[@"token"] forKey:@"Token"];
    NSString *uid = dic[@"user_id"];
    uid = uid ? uid : @"";
    [YooSeeApplication shareApplication].uid = [NSString stringWithFormat:@"%@",uid];
    
    NSString *cityID = dic[@"city_id"];
    cityID = cityID ? cityID : @"1";
    [YooSeeApplication shareApplication].cityID = cityID;
    
    NSString *provinceID = dic[@"province_id"];
    provinceID = provinceID ? provinceID : @"1";
    [YooSeeApplication shareApplication].provinceID = provinceID;
    
    [YooSeeApplication shareApplication].isLogin = YES;
    
    [DELEGATE login2CU:NO];
    
    [DELEGATE getAdvList];
    
    

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
