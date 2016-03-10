//
//  AddCameraByIDViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//
#define SPACE_X             10.0
#define SPACE_Y             15.0

#define VIEW_HEIGHT         480.0 * CURRENT_SCALE
#define VIEW_SPACE_Y        50.0 * CURRENT_SCALE
#define VIEW_SPACE_X        20.0 * CURRENT_SCALE
#define VIEW_ADD_Y          20.0 * CURRENT_SCALE
#define TEXTFIELD_HEIGHT    50.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "AddCameraByIDViewController.h"
#import "CustomTextField.h"
#import "CameraPasswordViewController.h"

@interface AddCameraByIDViewController ()

@property (nonatomic, strong) CustomTextField *deviceIDTextField;

@end

@implementation AddCameraByIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"输入摄像头ID";
    [self addBackItem];
    
    [self initUI];
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
    
    UIImage *image = [UIImage imageNamed:@"camera_icon_big"];
    float width = image.size.width/2.0;
    float height = image.size.height/2.0;
    x = (bgView.frame.size.width - width)/2;
    UIImageView *iconImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, height) placeholderImage:image];
    [bgView addSubview:iconImageView];
    
    y += iconImageView.frame.size.height + 2 * VIEW_ADD_Y;
    _deviceIDTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(VIEW_SPACE_X, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, TEXTFIELD_HEIGHT)];
    _deviceIDTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    _deviceIDTextField.textField.placeholder = @"请输入摄像头ID";
    _deviceIDTextField.textField.text = @"";
    [bgView addSubview:_deviceIDTextField];
    
    y += _deviceIDTextField.frame.size.height + 3 * VIEW_ADD_Y;
    UIButton *nextButton = [CreateViewTool createButtonWithFrame:CGRectMake(VIEW_SPACE_X, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, BUTTON_HEIGHT) buttonTitle:@"确认" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"sureButtonPressed:" tagDelegate:self];
    [CommonTool clipView:nextButton withCornerRadius:BUTTON_RADIUS];
    [bgView addSubview:nextButton];
}


#pragma mark 确认
- (void)sureButtonPressed:(UIButton *)sender
{
    [self.deviceIDTextField.textField resignFirstResponder];
    NSString *deviceID = _deviceIDTextField.textField.text;
    deviceID = deviceID ? deviceID : @"";
    if (deviceID.length != 7)
    {
        [CommonTool addPopTipWithMessage:@"设备ID为0-7位数字"];
        return;
    }
    
    CameraPasswordViewController *cameraPasswordViewController = [[CameraPasswordViewController alloc] init];
    cameraPasswordViewController.deviceID = deviceID;
    cameraPasswordViewController.isChange = NO;
    [self.navigationController pushViewController:cameraPasswordViewController animated:YES];
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
