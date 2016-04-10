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
@property (nonatomic, strong) NSString *imageUrl;

@end

@implementation SplashScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self addNotification];
    
    [DELEGATE getAdvListWithRequestType:RequestTypeSynchronous];
    
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAdvSucess:) name:@"GetAdvSucess" object:nil];
    
}


- (void)getAdvSucess:(NSNotification *)notification
{
    NSDictionary *infoDic = [USER_DEFAULT objectForKey:@"AdvInfo"];
    NSArray *array = infoDic[@"start_diagram_List"];
    if (array && [array count] > 0)
    {
        NSString *imageUrl =  array[0][@"image_url"];
        imageUrl = imageUrl ? imageUrl : @"";
        self.imageUrl = imageUrl;
    }
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
    
    if (self.imageUrl.length > 0)
    {
        UIImageView *splashImageView = [CreateViewTool createImageViewWithFrame:self.view.frame placeholderImage:[UIImage imageNamed:SCREEN_HEIGHT == 480 ? @"ip4-2" : @"ip6-2"]];
        [splashImageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrl] placeholderImage:[UIImage imageNamed:@"KJ.jpg"]];
        [self.view addSubview:splashImageView];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.avPlayerView removeFromSuperview];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(next) userInfo:nil repeats:NO];
    }
    else
    {
        [self next];
    }
}

- (void)next
{
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
         NSLog(@"AUTO_USER_LOGIN_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = responseDic;
         int returnCode = [dataDic[@"returnCode"] intValue];
         if (returnCode == 8)
         {
             [USER_DEFAULT setValue:userName forKey:@"UserName"];
             [weakSelf setLoginDataWithDictionary:responseDic];
         }
         else
         {
             [YooSeeApplication shareApplication].isLogin = NO;
             [weakSelf addMainView];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"AUTO_USER_LOGIN_URL====%@",error);
         [YooSeeApplication shareApplication].isLogin = NO;
         [LoadingView dismissLoadingView];
         [weakSelf addMainView];
     }];
}


#pragma mark 保存系统数据
- (void)setLoginDataWithDictionary:(NSDictionary *)dataDic
{
    NSDictionary *dic = dataDic[@"resultList"][0];
    [YooSeeApplication shareApplication].userDic = dic;
    [USER_DEFAULT setValue:dic[@"token"] forKey:@"Token"];
    NSString *uid = dic[@"id"];
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
    
    [DELEGATE getAdvListWithRequestType:RequestTypeAsynchronous];
    
    [self addMainView];
    
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
