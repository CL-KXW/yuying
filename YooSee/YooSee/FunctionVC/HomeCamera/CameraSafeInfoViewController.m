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
    AlarmListCell *cell   = (AlarmListCell *)[tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil)
    {
        cell = [[AlarmListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section >= self.dataArray.count)
        return cell;
    
    cell.alarmInfo = self.dataArray[indexPath.section];
    [cell setDeviceName:self.contact.contactName];
    
    return cell;
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
