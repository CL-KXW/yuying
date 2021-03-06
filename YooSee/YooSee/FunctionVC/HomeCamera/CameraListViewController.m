//
//  CameraListViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/25.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define ROW_HEIGHT      230.0 * CURRENT_SCALE
#define HEADER_HEIGHT   15.0 * CURRENT_SCALE

#import "CameraListViewController.h"
#import "Contact.h"
#import "ContactDAO.h"
#import "FListManager.h"
#import "P2PClient.h"
#import "DeviceListCell.h"
#import "AddCameraMainViewController.h"
#import "CameraMainViewController.h"
#import "CameraFileViewController.h"
#import "CameraSafeInfoViewController.h"
#import "ReplayRecordFileViewController.h"
#import "SettingCameraMainViewController.h"
#import "SetCameraInfoViewController.h"
#import "CameraPasswordViewController.h"
#import "Utils.h"

@interface CameraListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *contactArray;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *deviceIDArray;
@property (nonatomic, assign) NSInteger checkStateTimes;//检测在线状态定时器执行次数
@property (nonatomic, retain) NSTimer   *checkStateTimer;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;

@end

@implementation CameraListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"家视频";
    [self addBackItem];
    [self setNavBarItemWithImageName:@"icon_navbar_add" navItemType:RightItem selectorName:@"addCameraButtonPressed:"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceListRequest)
                                                 name:@"refreshDeviceListFromServer" object:nil];
    
    [self initUI];
    
    [self getDeviceListRequest];


    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.dataArray count] && self.dataArray)
    {
        [self createTimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_checkStateTimer invalidate];
    _checkStateTimer = nil;
    [self unObservingDeviceList];
}

- (void)createTimer
{
    if (!_checkStateTimer)
    {
        //设备列表刷新定时器
        [self observingDeviceList];
        _checkStateTimes = 0;
        _checkStateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDeviceState:) userInfo:nil repeats:YES];
    }
}

#pragma makr 返回
- (void)backButtonPressed:(UIButton *)sender
{
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([array[1] isKindOfClass:[CameraMainViewController class]])
    {
        CameraMainViewController *cameraMainViewController = [[CameraMainViewController alloc] init];
        [array replaceObjectAtIndex:1 withObject:cameraMainViewController];
        self.navigationController.viewControllers = array;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 添加摄像头
- (void)addCameraButtonPressed:(UIButton *)sender
{
    AddCameraMainViewController *addCameraMainViewController = [[AddCameraMainViewController alloc] init];
    [self.navigationController pushViewController:addCameraMainViewController animated:YES];
}

#pragma mark - 监测设备方法

- (void)observingDeviceList
{
//    refreshDeviceListFromServer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDeviceInfo)
                                                 name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDeviceInfo)
                                                 name:@"updateContactState" object:nil];
}

- (void)unObservingDeviceList
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContactState" object:nil];
}

#pragma mark  初始化UI
- (void)initUI
{
    [self addTableView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor clearColor];
    self.table.tableHeaderView = headerView;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, HEADER_HEIGHT)];
    footView.backgroundColor = [UIColor clearColor];
    self.table.tableFooterView = footView;
}

#pragma mark 获取设备列表
- (void)getDeviceListRequest
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    NSDictionary *requestDic = @{@"userid":uid};
    [[RequestTool alloc] requestWithUrl:DEVICE_LIST_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"DEVICE_LIST_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
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
         NSLog(@"GET_ADV_URL====%@",error);
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:@"加载失败"];
     }];

}

#pragma mark 设置数据
- (void)setDataWithDictionary:(NSDictionary *)dataDic
{
    NSArray *bodyArray = dataDic[@"resultList"];
    if (!_deviceIDArray)
    {
        _deviceIDArray = [NSMutableArray array];
    }
    [self.deviceIDArray removeAllObjects];
    [self.contactArray removeAllObjects];
    [self.deviceIDArray removeAllObjects];
    NSLog(@"%@",bodyArray);
    
    NSString *defaultDeviceID = [USER_DEFAULT objectForKey:@"DefaultDeviceID"];
    
    if ([bodyArray count] == 0 || !bodyArray)
    {
        [YooSeeApplication shareApplication].devInfoListArray = nil;
        [CommonTool addPopTipWithMessage:@"暂无数据"];
        [YooSeeApplication shareApplication].contact = nil;
        [USER_DEFAULT removeObjectForKey:@"DefaultDeviceID"];
        [self.table reloadData];
        
        AddCameraMainViewController *addCameraMainViewContorller = [[AddCameraMainViewController alloc] init];
        [self.navigationController pushViewController:addCameraMainViewContorller animated:YES];
        
        return;
    }
    else
    {
        [self createTimer];
        for (int i = 0; i < [bodyArray count]; i++)
        {
            NSDictionary *dict = bodyArray[i];
            NSString *deviceid = [NSString stringWithFormat:@"%@",dict[@"camera_number"]];
            
            [_deviceIDArray addObject:deviceid];
            ContactDAO *contactDAO = [[ContactDAO alloc] init];
            Contact *contact = [contactDAO isContact:deviceid];
            NSLog(@"%ld",(long)contact.defenceState);
            NSLog(@"%@",dict[@"camera_name"]);
            if(!contact)
            {
                contact = [[Contact alloc] init];
                contact.contactId = deviceid;
                contact.contactName = dict[@"camera_name"];
                [[FListManager sharedFList] insertContact:contact];
            }
            else
            {
                contact.contactName = dict[@"camera_name"];
                [[FListManager sharedFList] update:contact];
            }
            
            if (!defaultDeviceID)
            {
                
                defaultDeviceID = [NSString stringWithFormat:@"%@",bodyArray[0][@"camera_number"]];
                [USER_DEFAULT setObject:defaultDeviceID forKey:@"DefaultDeviceID"];
                [YooSeeApplication shareApplication].contact = contact;
            }
        }
    }
    
    self.dataArray = [NSArray arrayWithArray:bodyArray];
    //[self setDataSourceArray:[NSMutableArray arrayWithArray:body]];
    
    [YooSeeApplication shareApplication].devInfoListArray = bodyArray;
    
    // 检查是否在线
    [[P2PClient sharedClient] getContactsStates:_deviceIDArray];
    [[FListManager sharedFList] getDefenceStates];
    
    if(self.contactArray == nil)
    {
        self.contactArray = [[NSMutableArray alloc]init];
    }
    
    if([bodyArray count] != 0)
    {//从本地存储里读取设备信息
        NSArray *arr = [[FListManager sharedFList] getContacts];
        for(Contact *contact in arr)
        {
            BOOL ishas = NO;
            for(NSDictionary *dic in bodyArray)
            {
                if([contact.contactId isEqualToString:[NSString stringWithFormat:@"%@",dic[@"camera_number"]]])
                {
                    ishas = YES;
                    [self.contactArray addObject:contact];
                    [self.deviceIDArray addObject:contact.contactId];
                }
            }
            if (!ishas)
            {
                [[FListManager sharedFList] deleteContact:contact];
            }
        }
    }
    [self.table reloadData];
}

#pragma mark 删除
//- (void)deleteDeviceRequestWithContact:(Contact *)contact
//{
//    if (!contact)
//    {
//        return;
//    }
//    NSString *deviceID = contact.contactId;
//    deviceID = deviceID ? deviceID : @"";
//    if (deviceID.length == 0)
//    {
//        return;
//    }
//    //DELETE_DEVICE_URL
//    [LoadingView showLoadingView];
//    __weak typeof(self) weakSelf = self;
//    NSDictionary *requestDic = @{@"id":deviceID};
//    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
//    [[RequestTool alloc] requestWithUrl:DELETE_DEVICE_URL
//                            requestParamas:requestDic
//                               requestType:RequestTypeAsynchronous
//                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
//     {
//         NSLog(@"DELETE_DEVICE_URL===%@",responseDic);
//         NSDictionary *dataDic = (NSDictionary *)responseDic;
//         int errorCode = [dataDic[@"returnCode"] intValue];
//         NSString *errorMessage = dataDic[@"returnMessage"];
//         errorMessage = errorMessage ? errorMessage : @"";
//         [LoadingView dismissLoadingView];
//         if (errorCode == 8)
//         {
//             [weakSelf getDeviceListRequest];
//             [[FListManager sharedFList] deleteContact:contact];
//             NSString *defaultDeviceID = [USER_DEFAULT objectForKey:@"DefaultDeviceID"];
//             defaultDeviceID = defaultDeviceID ? defaultDeviceID : @"";
//             if ([defaultDeviceID isEqualToString:contact.contactId])
//             {
//                 [USER_DEFAULT removeObjectForKey:@"DefaultDeviceID"];
//             }
//         }
//         else
//         {
//             [SVProgressHUD showErrorWithStatus:errorMessage];
//         }
//     }
//     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         NSLog(@"DELETE_DEVICE_URL====%@",error);
//         [LoadingView dismissLoadingView];
//     }];
//}

- (void)deleteDeviceRequestWithID:(NSString *)deviceID contact:(Contact *)contact
{
    if (!contact || deviceID.length == 0)
    {
        return;
    }
    //DELETE_DEVICE_URL
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"id":deviceID};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:DELETE_DEVICE_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"DELETE_DEVICE_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             ContactDAO *contactDAO = [[ContactDAO alloc] init];
             Contact *contact1 = [contactDAO isContact:contact.contactId];
             if (contact1)
             {
                [[FListManager sharedFList] deleteContact:contact1];
             }
             NSString *defaultDeviceID = [USER_DEFAULT objectForKey:@"DefaultDeviceID"];
             defaultDeviceID = defaultDeviceID ? defaultDeviceID : @"";
             if ([defaultDeviceID isEqualToString:contact.contactId])
             {
                 [USER_DEFAULT removeObjectForKey:@"DefaultDeviceID"];
             }
             [weakSelf getDeviceListRequest];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
    requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"DELETE_DEVICE_URL====%@",error);
         [LoadingView dismissLoadingView];
     }];
}

#pragma mark 检查状态
//检查设备在线状态的定时器，该方法前3次每秒执行一次，后面每3秒执行一次
- (void)checkDeviceState:(NSTimer *)timer
{
    if (!_deviceIDArray || [_deviceIDArray count] == 0)
    {
        return;
    }
    
    for(int i = 0; i < [self.contactArray count]; i++)
    {
        
        Contact *contact = self.contactArray[i];
        //进入首页时，获取设备列表里的设备的可更新状态
        //设备检查更新
        [[P2PClient sharedClient] checkDeviceUpdateWithId:contact.contactId password:contact.contactPassword];
    }
    
    [[P2PClient sharedClient] getContactsStates:_deviceIDArray];
    [[FListManager sharedFList] getDefenceStates];
    
    if(_checkStateTimes >= 3)
    {
        if (_checkStateTimes % 3 != 0)
        {
            return;
        }
    }
    _checkStateTimes++;
}

#pragma mark - tableView datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0.0 : HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.contactArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"DeviceListCell";
    DeviceListCell *cell   = (DeviceListCell *)[tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil)
    {
        cell = [[DeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName delegate:self];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section >= _contactArray.count)
        return cell;
    
    //设置cell视图
    Contact *contact = [_contactArray objectAtIndex:indexPath.section];
    cell.deviceNameLabel.text = contact.contactName;
    cell.deviceIDLabel.text = [NSString stringWithFormat:@"ID:%@",contact.contactId];
    
    cell.onlineColorView.highlighted = (contact.onLineState == 1);
    cell.onlineStateLabel.text  = (contact.onLineState == 1) ? @"在线" : @"离线";

    //设防
    cell.defenceButton.tag = 10000 + indexPath.section;
    [cell.defenceButton addTarget:self action:@selector(defenceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if(contact.defenceState == DEFENCE_STATE_ON)
    {
        
        cell.defenceLabel.text = @"设防已开启";
        cell.defenceLabel.textColor = APP_MAIN_COLOR;
        [cell.defenceButton setBackgroundImage:[UIImage imageNamed:@"icon_defence_on_up"] forState:UIControlStateNormal];
        [cell.defenceButton setBackgroundImage:[UIImage imageNamed:@"icon_defence_on_down"] forState:UIControlStateHighlighted];

    }
    else
    {
        //(contact.defenceState == DEFENCE_STATE_OFF || contact.defenceState == DEFENCE_STATE_LOADING)
        //未设防
        cell.defenceLabel.text = @"未设防";
        cell.defenceLabel.textColor = DE_TEXT_COLOR;
        [cell.defenceButton setBackgroundImage:[UIImage imageNamed:@"icon_defence_off_up"] forState:UIControlStateNormal];
        [cell.defenceButton setBackgroundImage:[UIImage imageNamed:@"icon_defence_off_down"] forState:UIControlStateHighlighted];
    }
    //安全警报
    cell.alarmButton.tag = 100000 + indexPath.section;
    if (contact.messageCount != 0)
    {
        cell.alarmMessageCountLabel.hidden = NO;
        cell.alarmMessageCountLabel.text = [NSString stringWithFormat:@"%ld",(long)contact.messageCount];
        [cell.alarmButton setBackgroundImage:[UIImage imageNamed:@"icon_alert_on_up"] forState:UIControlStateNormal];
        [cell.alarmButton setBackgroundImage:[UIImage imageNamed:@"icon_alert_on_down"] forState:UIControlStateHighlighted];
    }
    else
    {
        cell.alarmMessageCountLabel.hidden = YES;
        [cell.alarmButton setBackgroundImage:[UIImage imageNamed:@"icon_alert_up"] forState:UIControlStateNormal];
        [cell.alarmButton setBackgroundImage:[UIImage imageNamed:@"icon_alert_down"] forState:UIControlStateHighlighted];
    }
    
    //播放
    cell.playbutton.tag = indexPath.section + 1;
    //照片夹
    cell.photosbutton.tag = 100000 * (indexPath.section + 1) + 1;
    //设置
    cell.settingbutton.tag = 100000 * (indexPath.section + 1) + 2;
    //回放
    cell.playbackbutton.tag = 100000 * (indexPath.section + 1) + 3;
    //编辑
    cell.editDeviceInfoButton.tag = 123 + indexPath.section;
//
//    for (NSDictionary *dict in self.dataArray)
//    {
//        if ([dict[@"deviceid"] isEqualToString:contact.contactId])
//        {
//            cell.deviceImgUrlStr = [dict objectForKey:@"picurl"];
//            cell.contact = contact;
//            break;
//        }
//    }
    
    //默认设备
    cell.showDefaultButton.tag = 1000 + indexPath.section;
    [cell.showDefaultButton addTarget:self action:@selector(showDefaultButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    NSString *defaultDeviceID = [USER_DEFAULT objectForKey:@"DefaultDeviceID"];
    if (!defaultDeviceID)
    {
        defaultDeviceID = ((Contact *)self.contactArray[0]).contactId;
        [USER_DEFAULT setObject:defaultDeviceID forKey:@"DefaultDeviceID"];
    }
    {
        cell.showDefaultLabel.text = ([defaultDeviceID isEqualToString:contact.contactId]) ? @"首页默认显示" : @"设置首页默认显示";
        cell.showDefaultLabel.textColor = ([defaultDeviceID isEqualToString:contact.contactId]) ? APP_MAIN_COLOR : DE_TEXT_COLOR;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete )
    {
        Contact *contact = [_contactArray objectAtIndex:indexPath.section];
        NSString *cameraID = _dataArray[indexPath.section][@"id"];
        //[self deleteDeviceRequestWithContact:contact];
        cameraID = [NSString stringWithFormat:@"%@",cameraID ? cameraID : @""];
        [self deleteDeviceRequestWithID:cameraID contact:contact];
    }
}


//- 编辑cell时取消监测设备列表
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self unObservingDeviceList];
}


//- 重监测列表状态
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self observingDeviceList];
}


#pragma mark 刷新设备状态
- (void)refreshDeviceInfo
{
    if(self.contactArray == nil)
    {
        self.contactArray = [[NSMutableArray alloc] init];
    }
    [self.contactArray removeAllObjects];
    
    NSArray *arr = [[FListManager sharedFList] getContacts];
    for(Contact *contact in arr)
    {
        [self.contactArray addObject:contact];
    }
    //-
    dispatch_async(dispatch_get_main_queue(), ^()
    {
        [self.table reloadData];
    });
}

#pragma mark 播放
- (void)playButtonPressed:(UIButton *)sender
{
    Contact *contact = self.contactArray[sender.tag - 1];
    NSLog(@"contact===%@",self.contactArray);
    //Contact *currentDevice = [YooSeeApplication  shareApplication].contact;
    if (contact)
    {
        //与第三方保持一致 播放不判断状态
        if (![self checkContactReady:contact])
        {
            return;
        }
        [YooSeeApplication  shareApplication].contact = contact;
        [self changedCameraMainView];
        [self.navigationController popViewControllerAnimated:YES];
    }
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

#pragma mark 设置默认
- (void)showDefaultButtonPressed:(UIButton *)sender
{
    int index = (int)sender.tag - 1000;
    NSString *deviceID = ((Contact *)self.contactArray[index]).contactId;
    [USER_DEFAULT setObject:deviceID forKey:@"DefaultDeviceID"];
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:deviceID];
    if (contact)
    {
        [YooSeeApplication shareApplication].contact = contact;
    }
    [self.table reloadData];
}


#pragma mark 设防

- (void)defenceButtonPressed:(UIButton *)sender
{

    int index = (int)sender.tag - 10000;
    Contact *contact = (Contact *)self.contactArray[index];
    if (![self checkContactReady:contact])
    {
        return;
    }
//    [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contact.contactId isClick:YES];
//    if (contact.defenceState == 2)
//    {
//        contact.defenceState = contact.defenceState > DEFENCE_STATE_ON ? 1 : 0;
//    }
//    else if(contact.defenceState == 0 || contact.defenceState == 1)
//    {
//        contact.defenceState = contact.defenceState > DEFENCE_STATE_OFF ? 0 : 1;
//    }
//    [[P2PClient sharedClient] setRemoteDefenceWithId:contact.contactId
//                                            password:contact.contactPassword
//                                               state:contact.defenceState];
    
    [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contact.contactId isClick:YES];
    if(contact.defenceState==DEFENCE_STATE_WARNING_NET||contact.defenceState == DEFENCE_STATE_WARNING_PWD)
    {
        contact.defenceState = DEFENCE_STATE_LOADING;
        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
        
    }
    else if(contact.defenceState==DEFENCE_STATE_ON)
    {
        contact.defenceState = DEFENCE_STATE_LOADING;
        [[P2PClient sharedClient] setRemoteDefenceWithId:contact.contactId password:contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF];
    }
    else if(contact.defenceState==DEFENCE_STATE_OFF)
    {
        contact.defenceState = DEFENCE_STATE_LOADING;
        [[P2PClient sharedClient] setRemoteDefenceWithId:contact.contactId password:contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_ON];
    }
}

#pragma mark 报警
- (void)alarmButtonPressed:(UIButton *)sender
{
    CameraSafeInfoViewController *cameraSafeInfoViewController = [[CameraSafeInfoViewController alloc] init];
    cameraSafeInfoViewController.contact = self.contactArray[sender.tag - 100000];
    [self.navigationController pushViewController:cameraSafeInfoViewController animated:YES];
}

#pragma mark 编辑
- (void)editButtonPressed:(UIButton *)sender
{
    int index = (int)sender.tag - 123;
    Contact *contact = self.contactArray[index];
    SetCameraInfoViewController *setCameraInfoViewController = [[SetCameraInfoViewController alloc] init];
    setCameraInfoViewController.deviceNo = UNNULL_STRING(self.dataArray[index][@"id"]);
    setCameraInfoViewController.deviceID = contact.contactId;
    setCameraInfoViewController.contact = contact;
    setCameraInfoViewController.imageUrl = self.dataArray[index][@"camera_cover"];
    [self.navigationController pushViewController:setCameraInfoViewController animated:YES];
}

#pragma mark 功能按钮
- (void)itemButtonPressed:(UIButton *)sender
{
    int index = (int)sender.tag%100000 - 1;
    int row = (int)sender.tag/100000 - 1;
    UIViewController *viewController;
    Contact *contact = self.contactArray[row];
    if (index == 0)
    {
        //照片夹
        CameraFileViewController *cameraFileViewController = [[CameraFileViewController alloc] init];
        viewController = cameraFileViewController;
    }
    if (index == 1)
    {
        //设置
        if (![self checkContactReady:contact])
        {
            return;
        }
        SettingCameraMainViewController *settingCameraMainViewController = [[SettingCameraMainViewController alloc] init];
        settingCameraMainViewController.imageUrl = self.dataArray[row][@"camera_cover"];
        settingCameraMainViewController.contact = contact;
        settingCameraMainViewController.deviceNo =  self.dataArray[row][@"id"];
        viewController = settingCameraMainViewController;
    }
    if (index == 2)
    {
        //回放
        if (![self checkContactReady:contact])
        {
            return;
        }
        ReplayRecordFileViewController *replayRecordFileViewController = [[ReplayRecordFileViewController alloc] init];
        replayRecordFileViewController.imageUrl = self.dataArray[row][@"camera_cover"];
        replayRecordFileViewController.contact = contact;
        viewController = replayRecordFileViewController;
    }
    if (viewController)
    {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (BOOL)checkContactReady:(Contact *)contact
{
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
