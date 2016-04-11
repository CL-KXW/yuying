//
//  RootViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/12.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define IMAGE       @"Image"

#import "SplashScreenViewController.h"
#import "AvPlayerView.h"
#import "HomeViewController.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "Utils.h"
#import "P2PClient.h"
#import "ContactDAO.h"

@interface SplashScreenViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImageView *splashImageView;

@end

@implementation SplashScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getAdvListRequest];
}


#pragma mark 初始化UI
- (void)initUI
{
    UIImage *image = [UIImage imageNamed:SCREEN_HEIGHT == 480 ? @"ip4-2" : @"ip6-2"];
    UIImage *lastImage = [UIImage imageWithData:[USER_DEFAULT objectForKey:IMAGE]];
    lastImage = lastImage ? lastImage : image;
    _splashImageView = [CreateViewTool createImageViewWithFrame:self.view.frame placeholderImage:lastImage];
    [self.view addSubview:_splashImageView];
}


#pragma mark 广告请求
- (void)getAdvListRequest
{
    __weak typeof(self) weakSelf = self;
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"0";
    NSString *cityID = [YooSeeApplication shareApplication].cityID;
    cityID = cityID ? cityID : @"1";
    NSString *provinceID = [YooSeeApplication shareApplication].provinceID;
    provinceID = provinceID ? provinceID : @"1";
    NSDictionary *requestDic = @{@"user_id":uid,@"city_id":cityID,@"province_id":provinceID};
    [[RequestTool alloc] requestWithUrl:GET_ADV_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_ADV_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = responseDic;
         int returnCode = [dataDic[@"returnCode"] intValue];
         if (returnCode == 8)
         {
             [USER_DEFAULT setValue:responseDic forKey:@"AdvInfo"];
             
         }
         [weakSelf getAdvFinished];
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [LoadingView dismissLoadingView];
         [weakSelf getAdvFinished];
         NSLog(@"GET_ADV_URL====%@",error);
     }];
}


- (void)getAdvFinished
{
    NSDictionary *infoDic = [USER_DEFAULT objectForKey:@"AdvInfo"];
    NSArray *array = infoDic[@"start_diagram_List"];
    if (array && [array count] > 0)
    {
        NSString *imageUrl = UNNULL_STRING(array[0][@"image_url"]);
        if (imageUrl.length > 0)
        {
            [_splashImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:_splashImageView.image options:SDWebImageContinueInBackground completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [USER_DEFAULT setObject:UIImagePNGRepresentation(image) forKey:IMAGE];
                [USER_DEFAULT synchronize];
                [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(loginServerRequest) userInfo:nil repeats:NO];
            }];
        }
    }
    else
    {
        [USER_DEFAULT removeObjectForKey:IMAGE];
        [self loginServerRequest];
    }
    
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
    [self next];
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
    
    [DELEGATE getAdvList];
    
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
