//
//  CameraSafeInfoViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/5.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define ROW_HEIGHT      190.0 * CURRENT_SCALE
#define HEADER_HEIGHT   15.0

#import "CameraSafeInfoViewController.h"
#import "UDManager.h"
#import "libPwdEncrypt.h"
#import "GetAlarmRecordResult.h"
#import "Alarm.h"
#import "AlarmListCell.h"
#import "CameraPasswordViewController.h"
#import "ContactDAO.h"
#import "CameraMainViewController.h"
#import "PhotoHandleView.h"

@interface CameraSafeInfoViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CameraSafeInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"安全报警";
    [self addBackItem];
    
    [self initUI];
    
    //if (self.contact)
    {
        [self getSafeInfoRequest];
    }
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addTableVIew];
}

- (void)addTableVIew
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
}


#pragma mark 获取数据
- (void)getSafeInfoRequest
{
    if (!self.contact)
    {
        [SVProgressHUD showErrorWithStatus:@"暂无数据"];
        return;
    }
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSDictionary *requestDic = @{@"UserID" : [YooSeeApplication shareApplication].user2CUDic[@"UserID"],
                          @"SessionID" : loginResult.sessionId,
                          @"PageSize" : @"20",
                          @"Option" :  @"2",
                          @"SenderList" : (self.contact) ? self.contact.contactId : @"",
                          @"CheckLevelType" : @"1",
                          @"VKey" : [libPwdEncrypt passwordEncryptWithPassword:self.contact.contactPassword]};
    NSLog(@"%@",requestDic);
    [[RequestTool alloc] requestWithUrl:ALARM_2CU_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"ALARM_2CU_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"error_code"] intValue];
         NSString *errorMessage = dataDic[@"error"];
         errorMessage = errorMessage ? errorMessage : @"加载失败";
         [LoadingView dismissLoadingView];
         if (errorCode == 0)
         {
             [weakSelf setDataWithDictionary:dataDic];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"ALARM_2CU_URL====%@",error);
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:@"加载失败"];
     }];
}

#pragma mark 设置数据
- (void)setDataWithDictionary:(NSDictionary *)dataDic
{
    GetAlarmRecordResult *alarmresult = [[GetAlarmRecordResult alloc] init];
    alarmresult.error_code = [dataDic[@"error_code"] intValue];
    NSString *RL = dataDic[@"RL"];
    
    NSMutableArray *alarmRecord = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *array = [RL componentsSeparatedByString:@";"];
    int count = 0;
    for(NSString *record in array)
    {
        if([record isEqualToString:@""])
        {
            continue;
        }
        
        NSArray *detailArray = [record componentsSeparatedByString:@"&"];
        Alarm * alarm = [[Alarm alloc] init];
        for (int i = 0; i < detailArray.count; i++)
        {
            switch (i)
            {
                case 0:
                {
                    alarm.msgIndex = detailArray[i];
                }
                    break;
                case 1:
                {
                    alarm.deviceId = detailArray[i];
                }
                    break;
                case 2:
                {
                    alarm.alarmTime = detailArray[i];
                }
                    break;
                case 3:
                {
                    alarm.alarmTime = detailArray[i];
                }
                    break;
                case 4:
                {
                    alarm.alarmType = [detailArray[i] intValue];
                }
                    break;
                case 5:
                {
                    alarm.alarmGroup = [detailArray[i] intValue];
                }
                    break;
                case 6:
                {
                    alarm.alarmItem = [detailArray[i] intValue];
                }
                    break;
            }
        }
        alarm.row = count;
        count++;
        [alarmRecord addObject:alarm];
    }
    alarmresult.alarmRecord = alarmRecord;
    
    self.dataArray = [NSArray arrayWithArray:alarmresult.alarmRecord];
    [self.table reloadData];
}


#pragma mark - tableView datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"DeviceListCell";
    AlarmListCell *cell   = (AlarmListCell *)[tableView dequeueReusableCellWithIdentifier:cellName ];
    if(cell == nil)
    {
        cell = [[AlarmListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.videoButton addTarget:self action:@selector(itemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.playButton addTarget:self action:@selector(itemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.imageButton addTarget:self action:@selector(itemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.videoButton.tag = 10000 * indexPath.section + 1;
    cell.playButton.tag = 10000 * indexPath.section + 3;
    cell.imageButton.tag = 10000 * indexPath.section + 2;

    
    if(indexPath.section >= self.dataArray.count)
        return cell;
    
    cell.alarmInfo = self.dataArray[indexPath.section];
    [cell setDeviceName:self.contact.contactName];
    
    return cell;
}


#pragma mark 按钮事件
- (void)itemButtonPressed:(UIButton *)sender
{
    int row = (int)sender.tag/10000;
    int tag = (int)sender.tag%10000;
    Alarm *alarm = self.dataArray[row];
    if (tag == 3)
    {
        //播放
        if ([self checkContactReady:self.contact])
        {
            [YooSeeApplication  shareApplication].contact = self.contact;
            [self changedCameraMainView];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        if (tag == 1)
        {
            //视频
            [CommonTool addPopTipWithMessage:@"暂无视频"];
        }
        else if (tag == 2)
        {
            //图片
            NSString *imageUrl = alarm.imageUrl;
            if (imageUrl.length == 0)
            {
                [CommonTool addPopTipWithMessage:@"暂无图片"];
            }
            else
            {
                CGRect rect = [[sender superview] convertRect:[sender frame] toView:nil];
                PhotoHandleView *handleView = [[PhotoHandleView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]] transFrom:rect target:self];
                [handleView show];
            }
        }
    }
}



- (BOOL)checkContactReady:(Contact *)contact
{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    contact = [contactDAO isContact:contact.contactId];
    if (!contact)
    {
        [CommonTool addPopTipWithMessage:@"程序内部错误"];
        return NO;
    }
    if (contact.onLineState == 0)
    {
        [CommonTool addPopTipWithMessage:@"设备已离线"];
        return NO;
    }
    else
    {
        
        NSString *password = contact.contactPassword;
        password = password ? password : @"";
        if (password.length == 0 || [password rangeOfString:@"null"].length > 0)
        {
            [CommonTool addPopTipWithMessage:@"设备密码为空"];
            [self goToChangePasswordView:contact.contactId];
            return NO;
        }
        else
        {
            if (contact.defenceState == DEFENCE_STATE_WARNING_PWD)
            {
                [CommonTool addPopTipWithMessage:@"设备密码错误"];
                [self goToChangePasswordView:contact.contactId];
                return NO;
            }
            if (contact.defenceState > 3)
            {
                if (contact.defenceState > 5)
                {
                    [CommonTool addPopTipWithMessage:@"设备异常"];
                    return NO;
                }
                [CommonTool addPopTipWithMessage:contact.defenceState == 4 ? @"网络异常" : @"权限不足"];
                return NO;
            }
            
        }
    }
    return YES;
}


- (void)goToChangePasswordView:(NSString *)deviceID
{
    deviceID = deviceID ? deviceID : @"";
    if (deviceID.length == 0)
    {
        return;
    }
    CameraPasswordViewController *cameraPasswordViewController = [[CameraPasswordViewController alloc] init];
    cameraPasswordViewController.deviceID = deviceID;
    cameraPasswordViewController.isChange = YES;
    [self.navigationController pushViewController:cameraPasswordViewController animated:YES];
}


#pragma mark 返回播放视图
- (void)changedCameraMainView
{
    CameraMainViewController *cameraMainViewController = [[CameraMainViewController alloc] init];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([array[1] isKindOfClass:[CameraMainViewController class]])
    {
        [array replaceObjectAtIndex:1 withObject:cameraMainViewController];
    }
    else
    {
        [array insertObject:cameraMainViewController atIndex:1];
    }
    self.navigationController.viewControllers = array;
}


- (void)didReceiveMemoryWarning {
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
