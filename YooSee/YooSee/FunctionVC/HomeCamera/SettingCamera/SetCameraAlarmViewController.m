//
//  SetCameraAlarmViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y      35.0 * CURRENT_SCALE
#define SPACE_X      15.0 * CURRENT_SCALE
#define ROW_HEIGHT   50.0 * CURRENT_SCALE

#import "SetCameraAlarmViewController.h"
#import "UDManager.h"

@interface SetCameraAlarmViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *statusArray;
@property (nonatomic, strong) NSMutableArray *valueArray;
@property (nonatomic, strong) NSString *emailString;
@property (nonatomic, strong) NSString *bindEmailString;
@property (nonatomic, strong) NSMutableArray *alarmDeviceArray;//推送报警消息的设备
@property (nonatomic, assign) NSInteger maxAlarmDeviceCount;//最大允许的推送报警设备数量

@end

@implementation SetCameraAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"报警设置";
    
    _titleArray = @[@"报警信息",@"报警邮箱",@"移动侦测",@"蜂鸣器"];
    _statusArray = [NSMutableArray arrayWithArray:@[@(0),@(0),@(0),@(0)]];
    _valueArray = [NSMutableArray arrayWithArray:@[@(1),@(1),@(1),@(1)]];
    
    [self addTableView];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *deviceID = self.contact.contactId;
    NSString *password = self.contact.contactPassword;
    [[P2PClient sharedClient] getAlarmEmailWithId:deviceID password:password];
    [[P2PClient sharedClient] getBindAccountWithId:deviceID password:password];
    [[P2PClient sharedClient] getNpcSettingsWithId:deviceID password:password];
}


- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(SPACE_X, start_y + SPACE_Y, self.view.frame.size.width - 2 * SPACE_X, ROW_HEIGHT * [_titleArray count]) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.scrollEnabled = NO;
    [CommonTool setViewLayer:self.table withLayerColor:[DE_TEXT_COLOR colorWithAlphaComponent:.6] bordWidth:.5];
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
    }
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    
    if (1 == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(cell.frame.size.width - 35.0 - 200.0, 0, 200.0, ROW_HEIGHT) textString:@"" textColor:DE_TEXT_COLOR textFont:FONT(15.0)];
        label.text = self.emailString ? self.emailString : @"";
        label.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label];
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([self.statusArray[indexPath.row] intValue] == 0)
        {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [activityView startAnimating];
            cell.accessoryView = activityView;
        }
        else
        {
            UISwitch *switchView = [[UISwitch alloc] init];
            switchView.tag = indexPath.row + 1;
            [switchView setOn:[self.valueArray[indexPath.row] intValue]];
            switchView.userInteractionEnabled = NO;
            cell.accessoryView = switchView;
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 1)
    {
        UISwitch *switchView = (UISwitch *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:indexPath.row + 1];
        [switchView setOn:!switchView.isOn];
        [self switchValueChanged:switchView];
    }
    else
    {
        [self setAlarmSwitch];
    }
}


- (void)setAlarmSwitch
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设置报警邮箱" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.text = (self.emailString && ![self.emailString isEqualToString:@"未绑定"]) ? self.emailString : @"";
    [alertView show];
}

#pragma mark 开关
- (void)switchValueChanged:(UISwitch *)switchView
{
    NSString *deviceID = self.contact.contactId;
    NSString *password = self.contact.contactPassword;
    int index = (int)switchView.tag - 1;
    [self.statusArray replaceObjectAtIndex:index withObject:@(0)];
    [self.table reloadData];
    if (index == 3)
    {
        [[P2PClient sharedClient] setBuzzerWithId:deviceID password:password state:switchView.isOn];
    }
    if (index == 2)
    {
        [[P2PClient sharedClient] setMotionWithId:deviceID password:password state:switchView.isOn];
    }
    else if (index == 0)
    {
        if(![self.valueArray[0] intValue] && [_alarmDeviceArray count] >= _maxAlarmDeviceCount)
        {//如果超过最大报警设备数，禁止添加新的设备
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [CommonTool  addPopTipWithMessage:[NSString stringWithFormat: @"该设备绑定的报警信息接收帐号数已达到最大值：%d 个!",_maxAlarmDeviceCount]];
                return;
            });
        }
        LoginResult *loginResult = [UDManager getLoginInfo];
        if(![self.valueArray[0] integerValue])
            [_alarmDeviceArray addObject:[NSNumber numberWithInt: loginResult.contactId.intValue]];
        else
            [_alarmDeviceArray removeObject:[NSNumber numberWithInt: loginResult.contactId.intValue]];
        [[P2PClient sharedClient] setBindAccountWithId:deviceID password:password datas:_alarmDeviceArray];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __weak typeof(self) weakSelf = self;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField resignFirstResponder];
    if ([title isEqualToString:@"修改"])
    {
        self.bindEmailString = textField.text;
        if ([CommonTool isEmailOrPhoneNumber:self.bindEmailString])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView showLoadingView];
                [[P2PClient sharedClient] setAlarmEmailWithId:weakSelf.contact.contactId password:weakSelf.contact.contactPassword email:weakSelf.bindEmailString];
                
            });
        }
        else
        {
            [CommonTool  addPopTipWithMessage:@"邮箱格式错误"];
            [self setAlarmSwitch];
        }
      
    }
}


#pragma mark 回调
- (void)receiveRemoteMessage:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key)
    {
        case RET_GET_NPCSETTINGS_MOTION:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            [weakSelf.valueArray replaceObjectAtIndex:2 withObject:@(state)];
            [weakSelf.statusArray replaceObjectAtIndex:2 withObject:@(1)];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [weakSelf.table reloadData];
            });
            
            NSLog(@"接收移动检测开启状态：%d",state);
        }
            break;
        case RET_SET_NPCSETTINGS_MOTION:
        {
            [weakSelf.statusArray replaceObjectAtIndex:2 withObject:@(1)];
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
        
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [weakSelf.table reloadData];
                if(result == 0)
                {
                    [weakSelf.valueArray replaceObjectAtIndex:2 withObject:@(![weakSelf.valueArray[2] intValue])];
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                }
                else
                {
                    [CommonTool addPopTipWithMessage:@"修改失败"];
                }
            });

        }
            break;
            
        case RET_GET_NPCSETTINGS_BUZZER:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            [weakSelf.valueArray replaceObjectAtIndex:3 withObject:@(state)];
            [weakSelf.statusArray replaceObjectAtIndex:3 withObject:@(1)];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [weakSelf.table reloadData];
            });
            NSLog(@"接收蜂鸣检测开启状态：%d",state);
        }
            break;
        case RET_SET_NPCSETTINGS_BUZZER:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            [weakSelf.statusArray replaceObjectAtIndex:3 withObject:@(1)];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [weakSelf.table reloadData];
                    if (result == 0)
                    {
                        [weakSelf.valueArray replaceObjectAtIndex:3 withObject:@(![weakSelf.valueArray[3] intValue])];
                        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                    }
                    else
                    {
                        [CommonTool addPopTipWithMessage:@"修改失败"];
                    }
                });
        }
            break;
        case RET_GET_ALARM_EMAIL:
        {
            weakSelf.emailString = [parameter valueForKey:@"email"];
            
            if([weakSelf.emailString  isEqualToString:@"0"])
                weakSelf.emailString  = @"未绑定";
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [weakSelf.table reloadData];
            });
            
            NSLog(@"接收报警邮箱地址！");
        }
            break;
        case RET_SET_ALARM_EMAIL:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if (result == 0)
                {
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                    weakSelf.emailString = weakSelf.bindEmailString;
                    
                }
                else
                {
                    [CommonTool  addPopTipWithMessage:@"修改失败"];
                }
                [weakSelf.table reloadData];
                
            });
        }
            break;
        case RET_GET_BIND_ACCOUNT:
        {
            LoginResult *loginResult = [UDManager getLoginInfo];
            NSInteger maxCount = [[parameter valueForKey:@"maxCount"] intValue];
            NSArray *datas = [parameter valueForKey:@"datas"];
            NSLog(@"bindIDs=%@",datas);
            _maxAlarmDeviceCount = maxCount;
            _alarmDeviceArray = [NSMutableArray arrayWithArray:datas];
            NSLog(@"%@",_alarmDeviceArray);
            
            int state = [_alarmDeviceArray containsObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
            [weakSelf.valueArray replaceObjectAtIndex:0 withObject:@(state)];
            [weakSelf.statusArray replaceObjectAtIndex:0 withObject:@(1)];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [weakSelf.table reloadData];
            });
            
        }
            break;
        case RET_SET_BIND_ACCOUNT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            [weakSelf.statusArray replaceObjectAtIndex:0 withObject:@(1)];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (result == 0)
                {
                    [weakSelf.valueArray replaceObjectAtIndex:0 withObject:@(![weakSelf.valueArray[0] intValue])];
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                }
                else
                {
                    [CommonTool addPopTipWithMessage:@"修改失败"];
                }
                [weakSelf.table reloadData];
            });

        }
            break;
            
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    NSString *deviceID = self.contact.contactId;
    NSString *password = self.contact.contactPassword;
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_GET_NPC_SETTINGS:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result == 2)
                {
                    NSLog(@"重新获取设置信息");
                    [[P2PClient sharedClient] getNpcSettingsWithId:deviceID  password:password];
                }
            });
        }
            break;
            
        case ACK_RET_SET_NPCSETTINGS_MOTION:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result == 2)
                {
                    [[P2PClient sharedClient] setMotionWithId:deviceID  password:password state:![weakSelf.statusArray[2] integerValue]];
                    NSLog(@"重新设置移动侦测开启状态");
                }
            });
            
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_BUZZER:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result == 2)
                {
                    [[P2PClient sharedClient] setBuzzerWithId:deviceID  password:password state:![weakSelf.statusArray[3] integerValue]];
                    NSLog(@"重新设置蜂鸣器开启状态");
                }
            });
        }
            break;
        case ACK_RET_GET_ALARM_EMAIL:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result == 2)
                {
                    [[P2PClient sharedClient] getAlarmEmailWithId:deviceID  password:password];
                    NSLog(@"重新获取报警信息接收邮箱");
                }
            });
        }
            break;
            
        case ACK_RET_SET_ALARM_EMAIL:
        {
            dispatch_async(dispatch_get_main_queue(), ^
           {
               [LoadingView dismissLoadingView];
               if(result == 1)
               {
                   [weakSelf passwordError];
               }
               else if(result == 2)
               {
                   [[P2PClient sharedClient] setAlarmEmailWithId:deviceID password:password email:self.bindEmailString];
                   NSLog(@"重新设置报警邮箱");
               }
               
           });

        }
            break;
        case ACK_RET_GET_BIND_ACCOUNT:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result == 2)
                {
                    [[P2PClient sharedClient] getBindAccountWithId:deviceID  password:password];
                    NSLog(@"重新获取报警推送帐号");
                }
                
            });
        }
            break;
        case ACK_RET_SET_BIND_ACCOUNT:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result == 2)
                {
                    [[P2PClient sharedClient] setBindAccountWithId:deviceID  password:password datas:_alarmDeviceArray];
                    NSLog(@"重新添加报警推送帐号");
                }
            });
            
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_HUMAN_INFRARED:
        {
            
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT:
        {
            
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT:
        {
            
        }
        break;
    }
    
}

    
- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
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
