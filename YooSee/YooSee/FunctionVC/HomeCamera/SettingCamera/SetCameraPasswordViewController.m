//
//  SetCameraPasswordViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define TEXTFIELD_HEIGHT    40.0 * CURRENT_SCALE
#define SPACE_X             30.0 * CURRENT_SCALE
#define SPACE_Y             35.0 * CURRENT_SCALE
#define ADD_Y               15.0
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "SetCameraPasswordViewController.h"
#import "CustomTextField.h"

@interface SetCameraPasswordViewController ()

@property (nonatomic, strong) NSMutableArray *textFiledArray;
@property (nonatomic, strong) NSString *oldPassword;
@property (nonatomic, strong) NSString *surePassword;

@end

@implementation SetCameraPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"修改密码";
    
    [self addTextFields];
    // Do any additional setup after loading the view.
}


#pragma mark 初始化UI
- (void)addTextFields
{
    float x = SPACE_X;
    float y = SPACE_Y + start_y;
    float width = self.view.frame.size.width - 2 * x;
    float height = TEXTFIELD_HEIGHT;
    
    NSArray *array = @[@"输入原始密码",@"设置新密码",@"再次输入密码"];
    
    for (int i = 0; i < [array count]; i++)
    {
        CustomTextField *textField = [[CustomTextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        textField.textField.placeholder = array[i];
        textField.textField.secureTextEntry = YES;
        
        [self.view addSubview:textField];
        
        if (!_textFiledArray)
        {
            _textFiledArray = [[NSMutableArray alloc] init];
        }
        [self.textFiledArray addObject:textField];
        y += textField.frame.size.height + ADD_Y;
    }
    
    y += 2 * SPACE_Y;
    UIButton *commitButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, width, BUTTON_HEIGHT) buttonTitle:@"确认" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"commitButtonPressed:" tagDelegate:self];
    [CommonTool clipView:commitButton withCornerRadius:BUTTON_RADIUS];
    [self.view addSubview:commitButton];
}


#pragma mark 确认按钮
- (void)commitButtonPressed:(UIButton *)sender
{
    [self dismissKeyBorad];
    
    NSString *oldPassword = ((CustomTextField *)self.textFiledArray[0]).textField.text;
    NSString *newPassword = ((CustomTextField *)self.textFiledArray[1]).textField.text;
    NSString *surePassword = ((CustomTextField *)self.textFiledArray[2]).textField.text;
    
    if (oldPassword.length == 0)
    {
        [CommonTool addPopTipWithMessage:@"原始密码不能为空"];
        return;
    }
    if (newPassword.length < 6 || surePassword.length < 6)
    {
        [CommonTool addPopTipWithMessage:@"新密码不能小于6位"];
        return;
    }
    else if (![newPassword isEqualToString:surePassword])
    {
        [CommonTool addPopTipWithMessage:@"密码不一致"];
        return;
    }
    
    self.oldPassword = [Utils GetTreatedPassword:oldPassword];
    self.surePassword = [Utils GetTreatedPassword:newPassword];
    
    [LoadingView showLoadingView];
    [[P2PClient sharedClient] setDevicePasswordWithId:self.contact.contactId password:self.oldPassword newPassword:self.surePassword];
}

- (void)dismissKeyBorad
{
    for (CustomTextField *textField in self.textFiledArray)
    {
        [textField.textField resignFirstResponder];
    }
}

#pragma mark 回调
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    
    __weak typeof(self) weakSelf = self;
    switch(key)
    {
            
        case RET_SET_DEVICE_PASSWORD:
        {
        
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0)
            {
                weakSelf.contact.contactPassword = weakSelf.surePassword;
                [[FListManager sharedFList] update:weakSelf.contact];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                     [LoadingView dismissLoadingView];
                    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                    {
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        });
                    });
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                     [LoadingView dismissLoadingView];
                    [CommonTool addPopTipWithMessage:@"修改失败"];
                });
            }
        }
        break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    __weak typeof(self) weakSelf = self;
    switch(key)
    {
        case ACK_RET_SET_DEVICE_PASSWORD:
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
                    NSLog(@"resend set device password");
                    [[P2PClient sharedClient] setDevicePasswordWithId:weakSelf.contact.contactId password:weakSelf.oldPassword newPassword:weakSelf.surePassword];
                }
            });
            
            NSLog(@"ACK_RET_SET_DEVICE_PASSWORD:%i",result);
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
