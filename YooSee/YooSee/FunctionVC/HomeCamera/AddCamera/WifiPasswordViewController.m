//
//  ConnectWIFIViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/25.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X             10.0
#define SPACE_Y             15.0

#define VIEW_HEIGHT         480.0 * CURRENT_SCALE
#define VIEW_SPACE_Y        20.0 * CURRENT_SCALE
#define VIEW_SPACE_X        20.0 * CURRENT_SCALE
#define VIEW_ADD_Y          20.0 * CURRENT_SCALE
#define LABEL_HEIGHT        50.0 * CURRENT_SCALE
#define TEXTFIELD_HEIGHT    50.0 * CURRENT_SCALE
#define SHOWBUTTON_WIDTH    70.0
#define SHOWBUTTON_HEIGHT   30.0
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "WifiPasswordViewController.h"
#import "CustomTextField.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ConnectWifiViewController.h"

@interface WifiPasswordViewController ()

@property (nonatomic, strong) UILabel *wifiLabel;
@property (nonatomic, strong) CustomTextField *passwordTextField;

@end

@implementation WifiPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"输入WIFI密码";
    [self addBackItem];
    
    [self initUI];
    
    [self getSSIDInfo];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    UIImageView *bgView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, SPACE_Y + START_HEIGHT, self.view.frame.size.width - 2 * SPACE_X , VIEW_HEIGHT) placeholderImage:nil];
    [CommonTool clipView:bgView withCornerRadius:10.0];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    float x = 0;
    float y = VIEW_SPACE_Y;
    UILabel *tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:@"检测到WIFI" textColor:DE_TEXT_COLOR textFont:FONT(17.0)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:tipLabel];
    
    y += tipLabel.frame.size.height + VIEW_ADD_Y;
    _wifiLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:@"" textColor:MAIN_TEXT_COLOR textFont:FONT(25.0)];
    _wifiLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_wifiLabel];
    
    y += _wifiLabel.frame.size.height + VIEW_ADD_Y;
    _passwordTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(VIEW_SPACE_X, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, TEXTFIELD_HEIGHT)];
    _passwordTextField.textField.secureTextEntry = YES;
    _passwordTextField.textField.placeholder = @"请输入WIFI密码";
    _passwordTextField.textField.text = @"";
    [bgView addSubview:_passwordTextField];
    
    y += _passwordTextField.frame.size.height;
    
    UIButton *showButton = [CreateViewTool createButtonWithFrame:CGRectMake(bgView.frame.size.width - VIEW_SPACE_X - SHOWBUTTON_WIDTH, y, SHOWBUTTON_WIDTH, SHOWBUTTON_HEIGHT) buttonTitle:@"显示密码" titleColor:LIGHT_MAIN_COLOR normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:[UIColor clearColor] selectorName:@"showButtonPressed:" tagDelegate:self];
    showButton.titleLabel.font = FONT(14.0);
    [showButton setTitle:@"隐藏密码" forState:UIControlStateSelected];
    [bgView addSubview:showButton];
    
    
    y += 3 * VIEW_ADD_Y;
    
    UILabel *tipLabel1 = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:@"" textColor:DE_TEXT_COLOR textFont:FONT(17.0)];
    tipLabel1.numberOfLines = 2.0;
    NSString *text = @"请正确的输入密码,\n使摄像头能够成功连接.";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [CommonTool makeString:text toAttributeString:string withString:text withLineSpacing:5.0];
    tipLabel1.attributedText = string;
    tipLabel1.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:tipLabel1];
    
    y += tipLabel1.frame.size.height + 2 * VIEW_ADD_Y;
    UIButton *nextButton = [CreateViewTool createButtonWithFrame:CGRectMake(VIEW_SPACE_X, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, BUTTON_HEIGHT) buttonTitle:@"下一步" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"nextButtonPressed:" tagDelegate:self];
    [CommonTool clipView:nextButton withCornerRadius:BUTTON_RADIUS];
    [bgView addSubview:nextButton];
}

#pragma mark 获取wifi信息
- (void)getSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    
    for (NSString *ifnam in ifs)
    {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count])
            break;
    }
    NSLog(@"=====%@",info);
    NSString *ssid = info[@"SSID"];
    ssid = ssid ? ssid : @"";
    self.wifiLabel.text = ssid;
}


#pragma mark 显示密码
- (void)showButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.passwordTextField.textField.secureTextEntry = !sender.selected;
}

#pragma mark 下一步
- (void)nextButtonPressed:(UIButton *)sender
{
    NSString *password = _passwordTextField.textField.text;
    password = password ? password : @"";
    if (password.length == 0)
    {
        [CommonTool addPopTipWithMessage:@"密码不能为空"];
        return;
    }
    ConnectWifiViewController *connectWifiViewController = [[ConnectWifiViewController alloc] init];
    connectWifiViewController.password = password;
    connectWifiViewController.wifiName = _wifiLabel.text;
    [self.navigationController pushViewController:connectWifiViewController animated:YES];
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
