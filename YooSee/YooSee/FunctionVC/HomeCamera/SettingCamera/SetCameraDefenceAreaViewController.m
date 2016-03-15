//
//  SetCameraDefenceAreaViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y         35.0 * CURRENT_SCALE
#define SPACE_X         15.0 * CURRENT_SCALE
#define ROW_HEIGHT1     50.0 * CURRENT_SCALE
#define ROW_HEIGHT2     110.0 * CURRENT_SCALE
#define ITEM_WH         40.0 * CURRENT_SCALE
#define ITEM_SPACE_Y    10.0 * CURRENT_SCALE
#define ITEM_SPACE_X    (SCREEN_WIDTH - 2 * SPACE_X - 4 * ITEM_WH)/5.0

#import "SetCameraDefenceAreaViewController.h"

@interface SetCameraDefenceAreaViewController ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *statusArray;
@property (nonatomic, assign) int selectIndex;
@property (nonatomic, assign) int selectItem;

@end

@implementation SetCameraDefenceAreaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"防区设置";
    
    _titleArray = @[@"遥控",@"大厅",@"窗户",@"阳台",@"卧室",@"厨房",@"庭院"];
    self.selectIndex = -1;
    // Do any additional setup after loading the view.
    [self addTableView];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [LoadingView showLoadingView];
    [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
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
    int key = [[parameter valueForKey:@"key"] intValue];
    switch(key){
            
        case RET_DEVICE_NOT_SUPPORT://不支持禁用、启用开关
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                [CommonTool addPopTipWithMessage:@"当前设备不支持传感器开关"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            });
            NSLog(@"当前设备不支持传感器开关");
        }
            break;
        case RET_GET_DEFENCE_AREA_STATE:
        {
            [LoadingView dismissLoadingView];
            NSMutableArray *status = [parameter valueForKey:@"status"];
            weakSelf.statusArray = [NSMutableArray arrayWithArray:status];
            NSLog(@"获取状态成功！");
            dispatch_async(dispatch_get_main_queue(), ^
            {
                
//                if(isSetting)
//                {
//                    isSetting = NO;
//                    //settingSuccess = YES;
//                    [self.view makeToast:@"操作成功"];
//                    NSLog(@"操作成功");
//                }
//                [table reloadData];
            });
            
            
        }
            break;
        case RET_SET_DEFENCE_AREA_STATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^
           {
               [LoadingView dismissLoadingView];
               
               if(result == 0)
               {
                   [LoadingView showLoadingView];
                   [[P2PClient sharedClient] getDefenceAreaState:weakSelf.contact.contactId password:weakSelf.contact.contactPassword];
                   NSLog(@"设置成功");
               }
               else if(result == 32)
               {
                   int group = [[parameter valueForKey:@"group"] intValue];
                   int item = [[parameter valueForKey:@"item"] intValue];
                   NSString *message = [NSString stringWithFormat:@"该设备已学习过对码，位于%@ 防区第%d项！",weakSelf.titleArray[group],item + 1];
                   [CommonTool addPopTipWithMessage:message];
                   [weakSelf.table reloadData];
                   NSLog(@"重复学习对码！");
               }
               else if(result == 41)
               {
                   [CommonTool addPopTipWithMessage:@"当前设备不支持防区功能!"];
                   [weakSelf.navigationController popViewControllerAnimated:YES];
               }
               else
               {
                   [weakSelf.table reloadData];
                   [CommonTool addPopTipWithMessage:@"操作失败"];
                    NSLog(@"操作失败");
               }
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
    switch(key){
        case ACK_RET_GET_DEFENCE_AREA_STATE:
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
                    NSLog(@"再次获取防区设置信息");
                    [[P2PClient sharedClient]
                     getDefenceAreaState:weakSelf.contact.contactId
                     password:weakSelf.contact.contactPassword];
                }
            });
        }
            break;
        case ACK_RET_SET_DEFENCE_AREA_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if(result == 1)
                {
                    [weakSelf passwordError];
                }
                else if(result==2)
                {
                    NSLog(@"再次设置防区");
                    [[P2PClient sharedClient] setDefenceAreaState:weakSelf.contact.contactId password:weakSelf.contact.contactPassword group:weakSelf.selectIndex item:weakSelf.selectItem type:![weakSelf.statusArray[weakSelf.selectIndex][weakSelf.selectItem]intValue]];
                }
            });
        }
            break;
            /*case ACK_RET_GET_DEFENCE_SWITCH_STATE:{
             dispatch_async(dispatch_get_main_queue(), ^{
             if(result==1){
             [self.progressAlert hide:YES];
             [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
             
             }else if(result==2){
             DLog(@"resend do device update");
             [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
             }
             
             
             });
             
             DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
             }
             break;
             case ACK_RET_SET_DEFENCE_SWITCH_STATE:{
             dispatch_async(dispatch_get_main_queue(), ^{
             if(result==1){
             [self.progressAlert hide:YES];
             [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
             
             }else if(result==2){
             DLog(@"resend do device update");
             [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:self.lastSetSwitchType alarmCodeId:self.lastSetSwitchGroup alarmCodeIndex:self.lastSetSwitchItem];
             }
             
             
             });
             
             DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
             }
             break;*/
            
    }
    
}



#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.titleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.selectIndex == section) ? 2 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  (indexPath.row == 0) ? ROW_HEIGHT1 : ROW_HEIGHT2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (self.selectIndex != -1)
    {
        if (indexPath.section == self.selectIndex && indexPath.row == 1)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = self.titleArray[indexPath.section];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"";
        if ([self.statusArray count] > indexPath.section)
        {
            NSArray *array = self.statusArray[indexPath.section];
            if (array && [array count] > 0)
            {
                float y = ITEM_SPACE_Y;
                float x = ITEM_SPACE_X;
                for (int i = 1; i <= [array count]; i++)
                {
                    if (i % 4 == 1 && i != 1)
                    {
                        y += ITEM_SPACE_Y + ITEM_WH;
                        x = ITEM_SPACE_X;
                    }
                    UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, ITEM_WH, ITEM_WH) buttonTitle:[NSString stringWithFormat:@"%d",i] titleColor:[UIColor whiteColor] normalBackgroundColor:DE_TEXT_COLOR highlightedBackgroundColor:APP_MAIN_COLOR selectorName:@"itemButtonPressed:" tagDelegate:self];
                    button.tag = i;
                    button.selected = ![array[i-1] intValue];
                    [CommonTool clipView:button withCornerRadius:ITEM_WH/2];
                    [cell.contentView addSubview:button];
                     x += ITEM_SPACE_X + ITEM_WH;
                }
            }
        }
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectIndex = (self.selectIndex == indexPath.section) ? -1 : indexPath.section;
    [self.table reloadData];
    if (self.selectIndex == -1)
    {
        return;
    }
    if (indexPath.row == 1)
    {
        return;
    }
    if (!self.statusArray || [self.statusArray count] == 0)
    {
        [LoadingView showLoadingView];
        [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
    }
    else if ([self.statusArray count]  < indexPath.section + 1)
    {
        [CommonTool  addPopTipWithMessage:@"数据异常"];
        return;
    }
    else
    {
        [tableView reloadData];
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:self.selectIndex]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


#pragma mark  点击数字按钮
- (void)itemButtonPressed:(UIButton *)sender
{
    int item = (int)sender.tag - 1;
    int status = [self.statusArray[self.selectIndex][item] intValue];
    
    self.selectItem = item;
    
    [LoadingView showLoadingView];
    
    [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.selectIndex item:item  type:!status];
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
