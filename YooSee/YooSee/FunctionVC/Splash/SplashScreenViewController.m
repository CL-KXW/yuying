//
//  RootViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/12.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "AvPlayerView.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "Utils.h"
#import "P2PClient.h"
#import "ContactDAO.h"

@interface SplashScreenViewController ()<UIAlertViewDelegate>
{
    LoginViewController *loginViewController;
}

@property (nonatomic, strong) AvPlayerView *avPlayerView;

@end

@implementation SplashScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self initData];
    [self addNotification];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addPlayerView];
}

- (void)addPlayerView
{
    _avPlayerView = [[AvPlayerView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_avPlayerView];
}


#pragma mark 设置数据
- (void)initData
{
    int isFirst = [[USER_DEFAULT objectForKey:ISFIRST_KEY] intValue];
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:(isFirst) ? @"ad6s" : @"ad12s" ofType:@"mp4"];
    [_avPlayerView setVideoUrl:videoPath];
    [USER_DEFAULT setObject:@(1) forKey:ISFIRST_KEY];
}

#pragma mark 添加通知
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoPlayFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)videoPlayFinished:(NSNotification *)notification
{
    [self loginServerRequest];
}

#pragma mark 登录服务器接口
- (void)loginServerRequest
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"os":PLATFORM};
    [[RequestTool alloc] requestWithUrl:LOGIN_SERVER_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"LOGIN_SERVER_URL===%@",responseDic);
         
         NSDictionary *dataDic = responseDic;
         int returnCode = [dataDic[@"returnCode"] intValue];
         if (returnCode == 8)
         {
             [weakSelf setDataWithDictionary:responseDic];
         }
         else
         {
             [weakSelf addLoginFailTip];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"LOGIN_SERVER_URL====%@",error);
         [weakSelf addLoginFailTip];
     }];
}

#pragma mark 登录服务器失败
- (void)addLoginFailTip
{
    [LoadingView dismissLoadingView];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"登录服务器失败,是否重试?" delegate:self cancelButtonTitle:@"重试" otherButtonTitles:@"取消", nil];
    [alertView show];
};

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"重试"])
    {
        [self loginServerRequest];
    }
}

#pragma mark设置数据
- (void)setDataWithDictionary:(NSMutableDictionary *)dataDic
{
    NSDictionary *responseDic = dataDic[@"resultList"];
    [YooSeeApplication shareApplication].loginServerDic = responseDic;
    [DELEGATE checkUpdateShowTip:NO];
    [YooSeeApplication shareApplication].pwd2cu = responseDic[@"pwd2cu"];
//    BOOL isShow = [responseDic[@"ifshow"] boolValue];
//    NSString *imageUrl = responseDic[@"startgg"];
//    imageUrl = imageUrl ? imageUrl : @"";
//    if (isShow && imageUrl.length > 0)
//    {
//        UIImageView *splashImageView = [CreateViewTool createImageViewWithFrame:self.view.frame placeholderImage:nil imageUrl:imageUrl isShowProcess:YES];
//        [self.view addSubview:splashImageView];
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        [self.avPlayerView removeFromSuperview];
//        //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(addMainView) userInfo:nil repeats:NO];
//    }
////    else
////    {
////        [self addMainView];
////    }
    NSString *username = [USER_DEFAULT objectForKey:@"UserName"];
    username = username ? username : @"";
    NSString *token = [USER_DEFAULT objectForKey:@"Token"];
    token = token ? token : @"";
    if ([CommonTool isEmailOrPhoneNumber:username] && token.length > 0)
    {
        [self autoLoginWithUserName:username token:token];
    }
    else
    {
        [LoadingView dismissLoadingView];
        [self addMainView];
    }
}


- (void)autoLoginWithUserName:(NSString *)userName token:(NSString *)token
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"phone":userName,@"token":token};
    [[RequestTool alloc] requestWithUrl:AUTO_USER_LOGIN_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"LOGIN_SERVER_URL===%@",responseDic);
         
         NSDictionary *dataDic = responseDic;
         int returnCode = [dataDic[@"returnCode"] intValue];
         if (returnCode == 8)
         {
             [USER_DEFAULT setValue:userName forKey:@"UserName"];
             [weakSelf setLoginDataWithDictionary:responseDic];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"LOGIN_SERVER_URL====%@",error);
         [LoadingView dismissLoadingView];
         [weakSelf addMainView];
     }];
}


#pragma mark 保存系统数据
- (void)setLoginDataWithDictionary:(NSDictionary *)dataDic
{
    NSDictionary *dic = dataDic[@"resultList"][0];
    [YooSeeApplication shareApplication].userDic = dataDic;
    [USER_DEFAULT setValue:dataDic[@"token"] forKey:@"Token"];
    NSString *uid = dataDic[@"user_id"];
    uid = uid ? uid : @"";
    [YooSeeApplication shareApplication].uid = uid;
    
    NSString *cityID = dic[@"city_id"];
    cityID = cityID ? cityID : @"1";
    [YooSeeApplication shareApplication].cityID = cityID;
    
    NSString *provinceID = dic[@"province_id"];
    provinceID = provinceID ? provinceID : @"1";
    [YooSeeApplication shareApplication].provinceID = provinceID;
    
    [self login2CU];
    
    [DELEGATE getAdvList];
    
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
    requestDic = [RequestDataTool makeRequestDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:LOGIN_2CU_URL
                         requestParamas:requestDic
                            requestType:RequestTypeSynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"2cu_USER_LOGIN_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"error_code"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
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
             [weakSelf dismissViewControllerAnimated:YES completion:nil];
         }
         else
         {
             
         }
         [weakSelf addMainView];
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [LoadingView dismissLoadingView];
         [weakSelf addMainView];
         NSLog(@"2cu_USER_LOGIN_URL====%@",error);
     }];
}



- (void)addMainView
{
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [[DELEGATE window] setRootViewController:homeNav];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
