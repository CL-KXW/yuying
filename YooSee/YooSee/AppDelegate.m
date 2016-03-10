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


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self.window makeKeyAndVisible];
    
    SplashScreenViewController *splashScreenViewController = [[SplashScreenViewController alloc] init];
    self.window.rootViewController = splashScreenViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [UMSocialData setAppKey:UM_APP_KEY];
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:SINA_CALLBACK];
    
    [UMSocialWechatHandler setWXAppId:WX_APP_ID appSecret:WX_APP_SECRET url:WX_CALLBACK];
    [UMSocialQQHandler setQQWithAppId:QQ_APP_ID appKey:QQ_APP_SECRET url:QQ_CALLBACK];
    
    return YES;
}


#pragma mark 检查更新
- (void)checkUpdateShowTip:(BOOL)isShow
{
    float minVersion = [[YooSeeApplication shareApplication].loginServerDic[@"minversion"] floatValue];
    float appVersion = [PRODUCT_VERSION floatValue];
    float newVersion = [[YooSeeApplication shareApplication].loginServerDic[@"minversion"] floatValue];
    if (appVersion == newVersion)
    {
        if (isShow)
        {
            [SVProgressHUD showSuccessWithStatus:@"已是最新版本" duration:1.5];
        }
        return;
    }
    if (appVersion < minVersion)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现新版本" delegate:self cancelButtonTitle:@"升级" otherButtonTitles:nil, nil];
        [alert show];
    }
    if (appVersion > minVersion && appVersion < newVersion)
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
            DLog(@"RET_GET_NPCSETTINGS_REMOTE_DEFENCE");
            
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


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
