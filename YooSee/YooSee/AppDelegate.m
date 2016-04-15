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

#import "XGPush.h"
#import "XGSetting.h"

#import <AlipaySDK/AlipaySDK.h>

#import "WebViewController.h"


@interface AppDelegate ()

@property (nonatomic, assign) BOOL isLoading;

//TODO:每次发版记得修改此处
@property(nonatomic)BOOL isAppStoreCode;  //是企业版还是App Store版

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //默认企业版
    self.isAppStoreCode = NO;
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    
    SplashScreenViewController *splashScreenViewController = [[SplashScreenViewController alloc] init];
    self.window.rootViewController = splashScreenViewController;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [UMSocialData setAppKey:UM_APP_KEY];
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SINA_APP_ID secret:SINA_APP_SECRET RedirectURL:SINA_CALLBACK];
    [UMSocialWechatHandler setWXAppId:WX_APP_ID appSecret:WX_APP_SECRET url:WX_CALLBACK];
    [UMSocialQQHandler setQQWithAppId:QQ_APP_ID appKey:QQ_APP_SECRET url:QQ_CALLBACK];
    [UMSocialQQHandler setSupportWebView:YES];
    
    [self xinGeReregister];
    
    //推送反馈回调版本示例
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
    
    
    return YES;
}


#pragma mark 检查更新
- (void)checkUpdateShowTip:(BOOL)isShow
{
    if (self.isAppStoreCode) {
        return;
    }
    
    NSString *newVersion = [YooSeeApplication shareApplication].loginServerDic[@"version_number"];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDict[@"CFBundleShortVersionString"];

    
    NSComparisonResult result;
    result = [newVersion compare:version options:NSNumericSearch];
    
    if (result == NSOrderedDescending)
    {
        //有新版本
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现新版本" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"升级", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"升级"])
    {
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
        
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.urlString = @"http://fir.im/yyios";
        webViewController.title = @"升级版本";
        [nav pushViewController:webViewController animated:YES];
    }
}


#pragma mark 获取广告
- (void)getAdvList
{
    //__weak typeof(self) weakSelf = self;
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
         
         NSDictionary *dataDic = responseDic;
         int returnCode = [dataDic[@"returnCode"] intValue];
         if (returnCode == 8)
         {
             [USER_DEFAULT setValue:responseDic forKey:@"AdvInfo"];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAdvSucess" object:nil userInfo:nil];
         }
         else
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAdvFail" object:nil userInfo:nil];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAdvFail" object:nil userInfo:nil];
         NSLog(@"GET_ADV_URL====%@",error);
     }];
}


#pragma mark 登录2cu
- (void)login2CU:(BOOL)isShow
{
    if (_isLoading)
    {
        return;
    }
    _isLoading = YES;
    NSString *password = [YooSeeApplication shareApplication].pwd2cu;
    NSString *email = [NSString stringWithFormat:@"newyywapp%@@yywapp.com",[USER_DEFAULT objectForKey:@"UserName"]];
    // 登陆2cu
    NSString *username = email;
    
    NSString *clientId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    clientId = [clientId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    LoginResult *loginResult = [[LoginResult alloc] init];
    //__weak typeof(self) weakSelf = self;
//    NSDictionary *requestDic = @{@"User":username,@"Pwd":[password getMd5_32Bit_String],@"Token":clientId,@"StoreID":@"0"};
    NSDictionary *requestDic = @{@"User":username,@"Pwd":[password getMd5_32Bit_String]};
    requestDic = [RequestDataTool makeRequestDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:LOGIN_2CU_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"2cu_USER_LOGIN_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"error_code"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"登录2cu失败";
       
         _isLoading = NO;
         [LoadingView dismissLoadingView];
        
         if (errorCode == 0)
         {
             if (isShow)
             {
                [SVProgressHUD showSuccessWithStatus:@"登录2cu成功"];
             }
             [YooSeeApplication shareApplication].isLogin2cu = YES;
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
         }
         else
         {
             if (errorCode == 2)
             {
                 [self register2CU];
             }
             [YooSeeApplication shareApplication].isLogin2cu = NO;
             if (isShow)
             {
                 [CommonTool addPopTipWithMessage:errorMessage];
             }
             
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        [YooSeeApplication shareApplication].isLogin2cu = NO;
         _isLoading = NO;
         [LoadingView dismissLoadingView];
         if (isShow)
         {
             [CommonTool addPopTipWithMessage:@"连接2cu服务器失败"];
         }
         NSLog(@"2cu_USER_LOGIN_URL====%@",error);
     }];
    
}

#pragma mark 注册2CU
- (void)register2CU
{
    NSString *password = [[YooSeeApplication shareApplication].pwd2cu getMd5_32Bit_String];
    NSString *email = [NSString stringWithFormat:@"newyywapp%@@yywapp.com",[USER_DEFAULT objectForKey:@"UserName"]];
    NSDictionary *requestDic = @{@"VersionFlag":@"1",@"Email":email,@"CountryCode":@"",@"phone":@"",@"Pwd":password,@"RePwd":password,@"VerifyCode":@"",@"IgnoreSafeWarning":@"1"};
    requestDic = [RequestDataTool makeRequestDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:REGISTER_2CU_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"REGISTER_2CU_URL====%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"error_code"] intValue];
         if (errorCode == 0)
         {
             [self login2CU:YES];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"REGISTER_2CU_URL====%@",error);
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
        
        if ([url.host isEqualToString:@"safepay"]) {
            NSLog(@"支付宝返回url_2： = %@", url);
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                
                NSLog(@"支付宝返回： = %@", resultDic);
                
            }];
            
            return YES;
        }
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

-(void)xinGeReregister{
    [XGPush startApp:2200191134 appKey:@"IZYH4453VV5V"];

    
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            [self registerPush];
        }
    };
    [XGPush initForReregister:successCallback];
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

-(void)registerPush{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound |UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else{
        //ios7注册推送通知
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //NSString * deviceTokenStr = [XGPush registerDevice:deviceToken];
    
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush Demo]register successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush Demo]register errorBlock");
    };
    
    // 设置账号
    //	[XGPush setAccount:@"test"];
    
    //注册设备
//    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
    self.deviceTokenStr = deviceToken;
    
    //如果不需要回调
    //[XGPush registerDevice:deviceToken];
    
    //打印获取的deviceToken的字符串
//    NSLog(@"[XGPush Demo] deviceTokenStr is %@",deviceTokenStr);
}

//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    
    NSLog(@"[XGPush Demo]%@",str);
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
    
    
    //回调版本示例
    /*
     void (^successBlock)(void) = ^(void){
     //成功之后的处理
     NSLog(@"[XGPush]handleReceiveNotification successBlock");
     };
     
     void (^errorBlock)(void) = ^(void){
     //失败之后的处理
     NSLog(@"[XGPush]handleReceiveNotification errorBlock");
     };
     
     void (^completion)(void) = ^(void){
     //失败之后的处理
     NSLog(@"[xg push completion]userInfo is %@",userInfo);
     };
     
     [XGPush handleReceiveNotification:userInfo successCallback:successBlock errorCallback:errorBlock completion:completion];
     */

    NSNumber *message = [userInfo objectForKey:@"key"];
    if ([message intValue ] == 1 || [message intValue ] == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveRed" object:nil];
    }
}


@end
