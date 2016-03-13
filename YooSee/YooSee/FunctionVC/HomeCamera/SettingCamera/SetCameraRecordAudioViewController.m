//
//  SetCameraRecordAudioViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y      40.0 * CURRENT_SCALE
#define SPACE_X      20.0 * CURRENT_SCALE
#define ROW_HEIGHT   50.0 * CURRENT_SCALE

#import "SetCameraRecordAudioViewController.h"

@interface SetCameraRecordAudioViewController ()

@property (nonatomic, assign) int lastType;
@property (nonatomic, assign) int shouldType;
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation SetCameraRecordAudioViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"录像设置";
    
    _lastType = -1;
    _shouldType = -1;
    _titleArray = @[@"不录像",@"报警录像",@"全天候录像"];
    
    [self addTableView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [LoadingView showLoadingView];
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:[Utils GetTreatedPassword:self.contact.contactPassword]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(SPACE_X, start_y + SPACE_Y, self.view.frame.size.width - 2 * SPACE_X, ROW_HEIGHT * [_titleArray count]) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.scrollEnabled = NO;
    [CommonTool setViewLayer:self.table withLayerColor:[DE_TEXT_COLOR colorWithAlphaComponent:.6] bordWidth:.4];
    [CommonTool clipView:self.table withCornerRadius:10.0];
    
}


#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.text = self.titleArray[indexPath.row];
    
    if (self.lastType == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.shouldType = indexPath.row;
    [LoadingView showLoadingView];
    [[P2PClient sharedClient] setRecordTypeWithId:self.contact.contactId password:[Utils GetTreatedPassword:self.contact.contactPassword] type:self.shouldType];
}


#pragma mark 回调
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    __weak typeof(self) weakSelf = self;
    switch(key)
    {
        case RET_GET_NPCSETTINGS_RECORD_TYPE://接收录像类型
        {

            NSInteger type = [[parameter valueForKey:@"type"] intValue];
            
            weakSelf.lastType = type;
    
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                [weakSelf.table reloadData];
            });
            
            
        }
            break;
        case RET_SET_NPCSETTINGS_RECORD_TYPE://设置录像类型结果
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    weakSelf.lastType = weakSelf.shouldType;
                    [weakSelf.table reloadData];
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    [weakSelf.table reloadData];
                    [CommonTool  addPopTipWithMessage:@"修改失败"];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_RECORD_TIME://接收报警录像时所录时间长度值
        {
            NSInteger time = [[parameter valueForKey:@"time"] intValue];
            NSLog(@"报警录像时间段：%i",time);
        }
        break;
        case RET_SET_NPCSETTINGS_RECORD_TIME://接收设置报警录像时所录时间长度值结果
        {
            
        }
        break;
        case RET_GET_NPCSETTINGS_RECORD_PLAN_TIME://接收定时录像时间段
        {
            NSInteger time = [[parameter valueForKey:@"time"] intValue];
            NSLog(@"plan time = %i",time);
            
            int h_s = time>>24;      //开始录像时间点的小时值
            int m_s = (time>>16) & 0x0ff;//开始录像时间点的分钟值
            int h_e = (time>>8) & 0x0ff;//结束录像时间点的小时值
            int m_e = time & 0x0ff;//结束录像时间点的分钟值
            
            //定时录像时间为1:0-0:59分，认为是全天候录像，如果选择了定时录像，但时间值不是这个，不选择任何录像类型。
            if(h_s == 1 && m_s == 0 && h_e == 0 && m_e == 59)
            {
                
                weakSelf.lastType = 2;
            }
            else
                //wholeday_record = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                [weakSelf.table reloadData];
            });
            
        }
            break;
        case RET_SET_NPCSETTINGS_RECORD_PLAN_TIME://接收设置定时录像时间段结果
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    weakSelf.lastType = 2;
                    [weakSelf.table reloadData];
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    [weakSelf.table reloadData];
                    [CommonTool  addPopTipWithMessage:@"修改失败"];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_REMOTE_RECORD:
        {//手动录像时，设备的录像状态
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            NSLog(@"手动录像开启状态：%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_REMOTE_RECORD:
        {//接收手动开启关闭录像结果
            
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    __weak typeof(self) weakSelf = self;
    NSString *deviceID = [weakSelf.contact contactId];
    NSString *password = [Utils GetTreatedPassword:weakSelf.contact.contactPassword];
    switch(key){
        case ACK_RET_GET_NPC_SETTINGS:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if(result==1)
                {
                    [CommonTool  addPopTipWithMessage:@"设备密码错误"];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                else if(result==2)
                {
                    NSLog(@"再次获取设备设置信息");
                    [[P2PClient sharedClient] getNpcSettingsWithId:deviceID password:[Utils GetTreatedPassword:password]];
                }
            });
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_RECORD_TYPE:
        {
            
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if(result==1){
                    [CommonTool  addPopTipWithMessage:@"设备密码错误"];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else if(result==2)
                {
                    NSLog(@"再次设置设备录像类型");
                    //设置定时录像
                    [[P2PClient sharedClient] setRecordTypeWithId:deviceID password:password type:_shouldType];
                    if (_shouldType == 2)
                    {
                        //设置定时录像时间段
                        [[P2PClient sharedClient] setRecordPlanTimeWithId:deviceID password:password time:16777275];
                        //16777275对应的时间段为1:0-0:59
                    }
                }
                
                
            });
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_RECORD_TIME:
        {
            /*dispatch_async(dispatch_get_main_queue(), ^{
             if(result==1){
             [CommonTool  addPopTipWithMessage:@"设备密码错误"];
             }else if(result==2){
             DLog(@"resend set record time");
             [[P2PClient sharedClient] setRecordTimeWithId:self.contact.contactId password:self.contact.contactPassword value:self.recordTime];
             }
             });
             DLog(@"ACK_RET_SET_NPCSETTINGS_RECORD_TIME:%i",result);*/
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_RECORD_PLAN_TIME:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if(result==1)
                {
                    [CommonTool  addPopTipWithMessage:@"设备密码错误"];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                else if(result==2)
                {
                    NSLog(@"再次设置计划录像时间");
                    [[P2PClient sharedClient] setRecordPlanTimeWithId:deviceID password:password time:16777275];
                    //16777275对应的时间段为1:0-0:59
                }
                
                
            });
        }
        break;
        case ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD:
        {
            /* dispatch_async(dispatch_get_main_queue(), ^{
             if(result==1){
             [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             usleep(800000);
             dispatch_async(dispatch_get_main_queue(), ^{
             [self onBackPress];
             });
             });
             }else if(result==2){
             DLog(@"resend set remote record state");
             [[P2PClient sharedClient] setRemoteRecordWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteRecordState];
             }
             
             
             });
            DLog(@"ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD:%i",result);*/
        }
            break;
    }
    
}


- (void)didReceiveMemoryWarning {
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
