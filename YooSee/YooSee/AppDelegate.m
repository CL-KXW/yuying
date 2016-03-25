//
//  AppDelegate.m
//  YooSee
//
//  Created by chenlei on 16/1/29.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashScreenViewController.h"
#import "P2PClient.h"
#import "ContactDAO.h"
#import "FListManager.h"
#import "MessageDAO.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "Utils.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocial.h"
#import "PAIOUnit.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    
    [self getAdvList];
    
    SplashScreenViewController *splashScreenViewController = [[SplashScreenViewController alloc] init];
    self.window.rootViewController = splashScreenViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [UMSocialData setAppKey:UM_APP_KEY];
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:SINA_CALLBACK];
    
    [UMSocialWechatHandler setWXAppId:WX_APP_ID appSecret:WX_APP_SECRET url:WX_CALLBACK];
    [UMSocialQQHandler setQQWithAppId:QQ_APP_ID appKey:QQ_APP_SECRET url:QQ_CALLBACK];
    
    return YES;
}


#pragma mark 检查更新
- (void)checkUpdateShowTip:(BOOL)isShow
{
    float newVersion = [[YooSeeApplication shareApplication].loginServerDic[@"version_number"] floatValue];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDict[@"CFBundleShortVersionString"];
    float appVersion = [version floatValue];
    if (appVersion == newVersion)
    {
        if (isShow)
        {
            [SVProgressHUD showSuccessWithStatus:@"已是最新版本" duration:1.5];
        }
        return;
    }
    if (appVersion < newVersion)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现新版本" delegate:self cancelButtonTitle:@"升级" otherButtonTitles:@"取消", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"升级"])
    {
        NSString *url = [YooSeeApplication shareApplication].loginServerDic[@"downurl"];
        url = url ? url : @"";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        exit(0);
    }
}


#pragma mark 获取广告
- (void)getAdvList
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *cityID = [YooSeeApplication shareApplication].cityID;
    cityID = cityID ? cityID : @"1";
    NSString *provinceID = [YooSeeApplication shareApplication].provinceID;
    provinceID = provinceID ? provinceID : @"1";
    NSDictionary *requestDic = @{@"user_id":uid,@"city_id":cityID,@"province_id":provinceID};
    [[RequestTool alloc] requestWithUrl:GET_ADV_URL
                         requestParamas:requestDic
                            requestType:RequestTypeSynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_ADV_URL===%@",responseDic);
         
         NSDictionary *dataDic = responseDic;
         int returnCode = [dataDic[@"returnCode"] intValue];
         if (returnCode == 8)
         {
             //[USER_DEFAULT setValue:userName forKey:@"UserName"];
             //[weakSelf setLoginDataWithDictionary:responseDic];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"GET_ADV_URL====%@",error);
         [LoadingView dismissLoadingView];
     }];
}


#pragma mark - NSNotification
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    NSLog(@"receive -- parameter: %@",parameter);
    printf("----> key : %02x\n",key);
    switch(key){
        case RET_RECEIVE_MESSAGE:
        {
            NSString *contactId = [parameter valueForKey:@"contactId"];
            NSString *messageStr = [parameter valueForKey:@"message"];
            LoginResult *loginResult = [UDManager getLoginInfo];
            MessageDAO *messageDAO = [[MessageDAO alloc] init];
            Message *message = [[Message alloc] init];
            
            message.fromId = contactId;
            message.toId = loginResult.contactId;
            message.message = [NSString stringWithFormat:@"%@",messageStr];
            message.state = MESSAGE_STATE_NO_READ;
            message.time = [NSString stringWithFormat:@"%ld",[Utils getCurrentTimeInterval]];
            message.flag = -1;
            [messageDAO insert:message];
            int lastCount = [[FListManager sharedFList] getMessageCount:contactId];
            [[FListManager sharedFList] setMessageCountWithId:contactId count:lastCount+1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
            });
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = @"message.mp3";
            notification.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,messageStr];
            notification.applicationIconBadgeNumber = 1;
            notification.alertAction = NSLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
            break;
        case RET_GET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            if(state == SETTING_VALUE_REMOTE_DEFENCE_STATE_ON)
            {
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_ON];
            }
            else
            {
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_OFF];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
            });
            NSLog(@"RET_GET_NPCSETTINGS_REMOTE_DEFENCE");
            
        }
            break;
            
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    NSString *contactId = [parameter valueForKey:@"contactId"];
    switch(key)
    {
         case ACK_RET_GET_DEFENCE_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                //                NSString *contactId = @"10000";
                if(result==1)
                {
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId])
                    {
                        [CommonTool addPopTipWithMessage:@"设备密码错误"];
                    }
                    
                }
                else if(result==2)
                {
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId])
                    {
                        [CommonTool addPopTipWithMessage:@"网络异常"];
                    }
                    
                }
                else if (result==4)
                {
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId])
                    {
                        [CommonTool addPopTipWithMessage:@"权限不足"];
                    }

                }
                
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                        object:self
                                                                      userInfo:nil];
                });
                
            });
            
            NSLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
        break;
        case ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result==1)
                {
                    
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId])
                    {
                        [CommonTool addPopTipWithMessage:@"设备密码错误"];
                    }
                }
                else if(result == 2)
                {
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId])
                    {
                        [CommonTool addPopTipWithMessage:@"网络异常"];
                    }
                }
                else if (result==4)
                {
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId])
                    {
                        [CommonTool addPopTipWithMessage:@"权限不足"];
                    }
                }
                else
                {
                    ContactDAO *contactDAO = [[ContactDAO alloc] init];
                    Contact *contact = [contactDAO isContact:contactId];
                    if(nil!=contact)
                    {
                        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
                    }
                    
                }
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^
               {
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                        object:self
                        userInfo:nil];
               });
            });
            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
            break;
            
    }
    
}


//  每次试图切换的时候都会走的方法,用于控制设备的旋转方向.
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (_isRotation)
    {
        return UIInterfaceOrientationMaskLandscape;
    }else {
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return  [UMSocialSnsService handleOpenURL:url];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATE_READY)
//    {
//        [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_NONE];
//        [[PAIOUnit sharedUnit] stopAudio];
//    }
//    [[P2PClient sharedClient] p2pHungUp];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATE_READY)
    {
        [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_NONE];
        [[PAIOUnit sharedUnit] stopAudio];
    }
    [[P2PClient sharedClient] p2pHungUp];
    [[P2PClient sharedClient] p2pDisconnect];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterBackground" object:nil];
    LoginResult *loginResult = [UDManager getLoginInfo];
    if(loginResult)
    {
        application.applicationIconBadgeNumber = 0;
        BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
        if(result)
        {
            NSLog(@"p2pConnect success.");
        }
        else
        {
            NSLog(@"p2pConnect failure.");
        }
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
