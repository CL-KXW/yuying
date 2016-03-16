//
//  SetCameraNetworkViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y         35.0 * CURRENT_SCALE
#define SPACE_X         15.0 * CURRENT_SCALE
#define ROW_HEIGHT      40.0 * CURRENT_SCALE
#define SECTION_HEIGHT  30.0 * CURRENT_SCALE

#import "SetCameraNetworkViewController.h"

@interface SetCameraNetworkViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, assign) NSInteger netType;//网络类型，0：有线，1：wifi
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) NSString *selectWifiPassword;
@property (nonatomic, strong) NSMutableArray *strengthArray;//wifi信号数组
@property (nonatomic, strong) NSMutableArray *encryptArray;//wifi加密数组
@property (nonatomic, strong) NSMutableArray *wifiNameArray;//wifi名称数组
@property (nonatomic, assign) NSInteger currentWifiIndex;//当前所选wifi在数组中的索引


@end

@implementation SetCameraNetworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"网络设置";
    // Do any additional setup after loading the view.
    _titleArray = @[@"  网络类型",@"  无线网络列表"];
    _netType = -1;
    _currentWifiIndex = -1;
    // Do any additional setup after loading the view.
    [self addTableView];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //获取设置信息
    [LoadingView showLoadingView];
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
}


- (void)addTableView
{
    float height = self.view.frame.size.height - start_y - 2 * SPACE_Y;
    [self addTableViewWithFrame:CGRectMake(SPACE_X, start_y + SPACE_Y, self.view.frame.size.width - 2 * SPACE_X, height) tableType:UITableViewStylePlain tableDelegate:self];
    [CommonTool setViewLayer:self.table withLayerColor:[DE_TEXT_COLOR colorWithAlphaComponent:.6] bordWidth:.5];
    [CommonTool clipView:self.table withCornerRadius:10.0];
    
}

#pragma mark 回调
- (void)receiveRemoteMessage:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key)
    {
        case RET_GET_NPCSETTINGS_NET_TYPE:
        {
            //接收网络类型
            
            NSInteger type = [[parameter valueForKey:@"type"] intValue];
            
            weakSelf.netType = type;
            
            if(weakSelf.netType == SETTING_VALUE_NET_TYPE_WIFI)
            {
                //如果无线网络，发送获取wifi列表请求
                [[P2PClient sharedClient] getWifiListWithId:weakSelf.contact.contactId password:weakSelf.contact.contactPassword];
            }
            else
            {
                if(weakSelf.contact.contactType == CONTACT_TYPE_IPC || weakSelf.contact.contactType == CONTACT_TYPE_DOORBELL)
                {
                    [[P2PClient sharedClient] getWifiListWithId:weakSelf.contact.contactId password:weakSelf.contact.contactPassword];
                }
                else
                {
                    [LoadingView dismissLoadingView];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^
           {
               [weakSelf.table reloadData];
           });
        }
            break;
        case RET_SET_NPCSETTINGS_NET_TYPE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^
           {
               [LoadingView dismissLoadingView];
               if(result == 0)
               {
                   weakSelf.netType = !weakSelf.netType;
                   if (weakSelf.netType)
                   {
                       [[P2PClient sharedClient] getWifiListWithId:weakSelf.contact.contactId password:weakSelf.contact.contactPassword];
                   }
                   else
                   {
                       if (weakSelf.wifiNameArray)
                       {
                           [weakSelf.wifiNameArray removeAllObjects];
                       }
                       if (weakSelf.encryptArray)
                       {
                           [weakSelf.encryptArray removeAllObjects];
                       }
                       if (weakSelf.strengthArray)
                       {
                           [weakSelf.strengthArray removeAllObjects];
                       }
                   }
                   [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                   [weakSelf.table reloadData];
               }
               else
               {
                   [CommonTool addPopTipWithMessage:@"修改失败"];
               }
               [weakSelf.table reloadData];
           });
        }
            break;
        case RET_GET_WIFI_LIST:
        {
            //接收到wifi列表
            //NSInteger count = [[parameter valueForKey:@"count"] intValue];
            NSInteger currentIndex = [[parameter valueForKey:@"currentIndex"] intValue];
            NSMutableArray *names = [parameter valueForKey:@"names"];
            NSMutableArray *types = [parameter valueForKey:@"types"];
            NSMutableArray *strengths = [parameter valueForKey:@"strengths"];
            
            weakSelf.wifiNameArray = [NSMutableArray arrayWithArray:names];
            weakSelf.encryptArray = [NSMutableArray arrayWithArray:types];
            weakSelf.strengthArray = [NSMutableArray arrayWithArray:strengths];
            weakSelf.currentWifiIndex = currentIndex;

            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                [weakSelf.table reloadData];
            });
            
            
        }
            break;
        case RET_SET_WIFI:
        {
            //接收设置wifi结果
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if(result == 0)
                {
                    weakSelf.netType = SETTING_VALUE_NET_TYPE_WIFI;
                    weakSelf.currentWifiIndex = weakSelf.selectIndex;
                    [SVProgressHUD showSuccessWithStatus:@"连接成功"];
                }
                else
                {
                    [CommonTool addPopTipWithMessage:@"连接失败"];
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
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key)
    {
            
        case ACK_RET_GET_NPC_SETTINGS:
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
                    NSLog(@"再次请求设备设置信息");
                    [[P2PClient sharedClient] getNpcSettingsWithId:weakSelf.contact.contactId password:weakSelf.contact.contactPassword];
                }
            });
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_NET_TYPE:
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
                    NSLog(@"再次设置网络类型");
                    [[P2PClient sharedClient] setNetTypeWithId:weakSelf.contact.contactId password:weakSelf.contact.contactPassword type:!weakSelf.netType];

                }
            });
        }
            break;
        case ACK_RET_GET_WIFI_LIST:
        {
            [LoadingView dismissLoadingView];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result == 2)
                {
                    NSLog(@"再次获取WIFI列表");
                    [[P2PClient sharedClient] getWifiListWithId:weakSelf.contact.contactId password:weakSelf.contact.contactPassword];
                }
            });
        }
            break;
        case ACK_RET_SET_WIFI:
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
                    NSLog(@"再次设置wifi");
                    //NSInteger type = [(NSNumber*)encryptArray[weakSelf.] integerValue];
                    NSInteger type = [weakSelf.encryptArray[weakSelf.selectIndex] integerValue];
                    [[P2PClient sharedClient] setWifiWithId:weakSelf.contact.contactId password:self.contact.contactPassword type:type name:weakSelf.wifiNameArray[weakSelf.selectIndex] wifiPassword:weakSelf.selectWifiPassword];
                }
            });
        }
            break;
            
    }
    
}



#pragma mark UITableViewDelegate&UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SECTION_HEIGHT) textString:self.titleArray[section] textColor:DE_TEXT_COLOR textFont:FONT(14.0)];
    [CommonTool setViewLayer:label withLayerColor:[DE_TEXT_COLOR colorWithAlphaComponent:.5] bordWidth:0.5];
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.titleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 2 : [self.wifiNameArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    UIImageView *imageView;
    //if([self.encryptArray[indexPath.row] intValue] != 0)
    {
        float icon_wh = 24.0;
        imageView = [CreateViewTool createImageViewWithFrame:CGRectMake(self.table.frame.size.width - 40.0 - icon_wh, (ROW_HEIGHT - icon_wh)/2, icon_wh, icon_wh) placeholderImage:nil];
        cell.accessoryView = imageView;
    }
    

    if (indexPath.section == 0)
    {
        cell.textLabel.text = (indexPath.row == 0) ? @"有线网络" : @"无线网络";
        cell.imageView.image = nil;
        imageView.image = [UIImage imageNamed:@"icon_wifi_selected"];
        if (self.netType != indexPath.row)
        {
            imageView.image = nil;
        }
    }
    else if (indexPath.section == 1)
    {
        cell.textLabel.text = self.wifiNameArray[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_strength%d",[self.strengthArray[indexPath.row] integerValue] + 1]];
        imageView.image = [UIImage imageNamed:(self.currentWifiIndex == indexPath.row) ? @"icon_wifi_selected" : @"icon_wifi_lock"];
        if([self.encryptArray[indexPath.row] intValue] == 0)
        {
            imageView.image = nil;
        }
    }
    cell.textLabel.font = FONT(16.0);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (self.netType == indexPath.row)
        {
            return;
        }
        else
        {
            [self addTipViewWithTag:100];
        }
    }
    else if (indexPath.section == 1)
    {
        if (self.currentWifiIndex == indexPath.row)
        {
            return;
        }
        else
        {
            _selectIndex = indexPath.row;
            [self addTipViewWithTag:101];
        }
    }
}

- (void)addTipViewWithTag:(long)tag
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"更改网络会使设备暂时中断，确定要更改吗？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag = tag;
    [alert show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int tag = (int)alertView.tag;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"确定"])
    {
        if (tag == 100)
        {
            //修改网络类型
            [LoadingView showLoadingView];
            [[P2PClient sharedClient] setNetTypeWithId:self.contact.contactId password:self.contact.contactPassword type:!self.netType];
        }
        if (tag == 101)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请输入Wi-Fi密码" message:self.wifiNameArray[self.selectIndex] delegate:self cancelButtonTitle:@"连接" otherButtonTitles:@"取消", nil];
            alert.tag = 102;
            alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [alert show];
        }
    }
    if ([title isEqualToString:@"连接"])
    {
        [LoadingView showLoadingView];
        UITextField *textField = [alertView textFieldAtIndex:0];
        [textField resignFirstResponder];
        NSString *password = textField.text;
        password = password ? password : @"";
        self.selectWifiPassword = password;
        NSInteger type = [self.encryptArray[self.selectIndex] integerValue];
        [[P2PClient sharedClient] setWifiWithId:self.contact.contactId password:self.contact.contactPassword type:type name:self.wifiNameArray[self.selectIndex] wifiPassword:password];
    }
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
