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

@interface SplashScreenViewController ()<UIAlertViewDelegate>

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
    NSDictionary *requestDic = nil;
    [[RequestTool alloc] requestWithUrl:LOGIN_SERVER_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         [LoadingView dismissLoadingView];
         NSLog(@"LOGIN_SERVER_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int returnCode = [dataDic[@"returnCode"] intValue];
         if (returnCode == 1)
         {
             [weakSelf setDataWithDictionary:responseDic];
         }
         else
         {
             [weakSelf adNSLoginFailTip];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"LOGIN_SERVER_URL====%@",error);
         [LoadingView dismissLoadingView];
         [weakSelf adNSLoginFailTip];
     }];
}

#pragma mark 登录服务器失败
- (void)adNSLoginFailTip
{
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
    NSDictionary *responseDic = dataDic[@"body"][0];
    [YooSeeApplication shareApplication].loginServerDic = responseDic;
    [YooSeeTool saveSystemData:responseDic];
    [DELEGATE checkUpdateShowTip:NO];
    BOOL isShow = [responseDic[@"ifshow"] boolValue];
    [YooSeeApplication shareApplication].pwd2cu = responseDic[@"pwd2cu"];
    NSString *imageUrl = responseDic[@"startgg"];
    imageUrl = imageUrl ? imageUrl : @"";
    if (isShow && imageUrl.length > 0)
    {
        UIImageView *splashImageView = [CreateViewTool createImageViewWithFrame:self.view.frame placeholderImage:nil imageUrl:imageUrl isShowProcess:YES];
        [self.view addSubview:splashImageView];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.avPlayerView removeFromSuperview];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(addMainView) userInfo:nil repeats:NO];
    }
    else
    {
        [self addMainView];
    }
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
