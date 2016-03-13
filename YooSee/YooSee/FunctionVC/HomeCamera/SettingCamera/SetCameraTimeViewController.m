//
//  SetCameraTimeViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define TEXTFIELD_HEIGHT    40.0 * CURRENT_SCALE
#define SPACE_X             30.0 * CURRENT_SCALE
#define SPACE_Y             30.0 * CURRENT_SCALE
#define ADD_Y               15.0
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2
#define DATEPICKER_HEIGHT   200.0 * CURRENT_SCALE

#import "SetCameraTimeViewController.h"
#import "CustomTextField.h"


@interface SetCameraTimeViewController ()

@property (nonatomic, strong) CustomTextField *timeTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation SetCameraTimeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"时间设置";
    
    [self addTextField];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [LoadingView showLoadingView];
    [[P2PClient sharedClient] getDeviceTimeWithId:self.contact.contactId password:[Utils GetTreatedPassword:self.contact.contactPassword]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addTextField
{
    float x = SPACE_X;
    float y = SPACE_Y + start_y;
    float width = self.view.frame.size.width - 2 * x;
    float height = TEXTFIELD_HEIGHT;
    
    _timeTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
    _timeTextField.textField.enabled = NO;
    [self.view addSubview:_timeTextField];
    
    
    y += 3 * SPACE_Y;
    UIButton *commitButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, width, BUTTON_HEIGHT) buttonTitle:@"确认" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"commitButtonPressed:" tagDelegate:self];
    [CommonTool clipView:commitButton withCornerRadius:BUTTON_RADIUS];
    [self.view addSubview:commitButton];
    
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - DATEPICKER_HEIGHT, self.view.frame.size.width, DATEPICKER_HEIGHT)];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    //datePicker.minimumDate = [NSDate  date];
    [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_datePicker];
    

}

#pragma mark 选择时间
- (void)dateChanged:(UIDatePicker *)datePicker
{
    self.timeTextField.textField.text = [CommonTool getStringFromDate:datePicker.date formatterString:@"yyyy-MM-dd hh:mm"];
}

#pragma mark 修改时间
- (void)commitButtonPressed:(UIButton *)sender
{
    [LoadingView showLoadingView];
    [self changeDeviceTime];
}

- (void)changeDeviceTime
{
    NSDateComponents *dateComponents = [Utils getDateComponentsByDate:_datePicker.date];
    [[P2PClient sharedClient] setDeviceTimeWithId:self.contact.contactId password:[Utils GetTreatedPassword:self.contact.contactPassword] year:dateComponents.year month:dateComponents.month day:dateComponents.day hour:dateComponents.hour minute:dateComponents.minute];
}


#pragma mark 回调
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    __weak typeof(self) weakSelf = self;
    switch(key)
    {
        case RET_GET_DEVICE_TIME:
        {
            NSString *time = [parameter valueForKey:@"time"];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                weakSelf.timeTextField.textField.text = time;
            });
            
            NSLog(@"RET_GET_DEVICE_TIME");
        }
            break;
        case RET_SET_DEVICE_TIME:
        {
            NSInteger result = [[parameter valueForKey:@"result"] integerValue];
            if(result==0)
            {

                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [LoadingView dismissLoadingView];
                    [CommonTool  addPopTipWithMessage:@"修改失败"];
                });
            }
        }
        break;
     }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification
{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    __weak typeof(self) weakSelf = self;
    switch(key)
    {
        case ACK_RET_GET_DEVICE_TIME:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if(result==1)
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                    {
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [CommonTool  addPopTipWithMessage:@"设备密码错误"];
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    });
                }
                else if(result==2)
                {
                    NSLog(@"resend get device time");
                    [[P2PClient sharedClient] getDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
            
            NSLog(@"ACK_RET_GET_DEVICE_TIME:%i",result);
        }
            break;
        case ACK_RET_SET_DEVICE_TIME:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [LoadingView dismissLoadingView];
                if(result==1)
                {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                    {
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [CommonTool  addPopTipWithMessage:@"设备密码错误"];
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    });
                }
                else if(result==2)
                {
                    NSLog(@"resend set device time");
                    [weakSelf changeDeviceTime];
                }
            });
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
