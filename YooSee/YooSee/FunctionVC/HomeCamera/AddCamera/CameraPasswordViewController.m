//
//  AddCameraWithPasswordViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/27.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X             10.0
#define SPACE_Y             15.0

#define VIEW_HEIGHT         480.0 * CURRENT_SCALE
#define VIEW_SPACE_Y        50.0 * CURRENT_SCALE
#define VIEW_SPACE_X        20.0 * CURRENT_SCALE
#define VIEW_ADD_Y          20.0 * CURRENT_SCALE
#define LABEL_HEIGHT        50.0 * CURRENT_SCALE
#define TEXTFIELD_HEIGHT    50.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2
#define SHOWBUTTON_WIDTH    70.0
#define SHOWBUTTON_HEIGHT   30.0


#import "CameraPasswordViewController.h"
#import "CustomTextField.h"
#import "AddCameraFailViewController.h"
#import "AddCameraSucessViewController.h"
#import "FListManager.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "P2PClient.h"

@interface CameraPasswordViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CustomTextField *passwordTextField;

@end

@implementation CameraPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"输入摄像头密码";
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
    
    x = 0;
    y += iconImageView.frame.size.height + VIEW_ADD_Y;
    _titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:[@"ID: " stringByAppendingString:self.deviceID] textColor:DE_TEXT_COLOR textFont:FONT(20.0)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_titleLabel];
    
    
    y += _titleLabel.frame.size.height + VIEW_ADD_Y;
    _passwordTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(VIEW_SPACE_X, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, TEXTFIELD_HEIGHT)];
    _passwordTextField.textField.secureTextEntry = YES;
    _passwordTextField.textField.placeholder = @"请输入摄像头密码";
    _passwordTextField.textField.text = @"";
    [bgView addSubview:_passwordTextField];
    
    y += _passwordTextField.frame.size.height;
    
    UIButton *showButton = [CreateViewTool createButtonWithFrame:CGRectMake(bgView.frame.size.width - VIEW_SPACE_X - SHOWBUTTON_WIDTH, y, SHOWBUTTON_WIDTH, SHOWBUTTON_HEIGHT) buttonTitle:@"显示密码" titleColor:LIGHT_MAIN_COLOR normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:[UIColor clearColor] selectorName:@"showButtonPressed:" tagDelegate:self];
    showButton.titleLabel.font = FONT(14.0);
    [showButton setTitle:@"隐藏密码" forState:UIControlStateSelected];
    [bgView addSubview:showButton];
    
    y +=  3 * VIEW_ADD_Y;
    UIButton *nextButton = [CreateViewTool createButtonWithFrame:CGRectMake(VIEW_SPACE_X, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, BUTTON_HEIGHT) buttonTitle:@"确认" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"sureButtonPressed:" tagDelegate:self];
    [CommonTool clipView:nextButton withCornerRadius:BUTTON_RADIUS];
    [bgView addSubview:nextButton];
}


#pragma mark 显示密码
- (void)showButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.passwordTextField.textField.secureTextEntry = !sender.selected;
}

#pragma mark 确认
- (void)sureButtonPressed:(UIButton *)sender
{
    [self.passwordTextField.textField resignFirstResponder];
    NSString *password = _passwordTextField.textField.text;
    password = password ? password : @"";
    if (password.length == 0)
    {
        [CommonTool addPopTipWithMessage:@"密码不能为空"];
        return;
    }
    if (self.isChange)
    {
        [self setContactData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self setDeviceRequest];
    }
    
}

#pragma mark 设置设备请求
- (void)setDeviceRequest
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid" : uid,
                                 @"did" : self.deviceID,
                                 @"optype" : @"1",
                                 @"hid" : @"",
                                 @"ifimg" : @"",
                                 @"dname" : self.deviceID};
    [[RequestTool alloc] desRequestWithUrl:SET_DEVICE_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
        [LoadingView dismissLoadingView];
         NSLog(@"SET_DEVICE_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"请检查摄像头密码是否正确";
         [weakSelf setDataWithErrorCode:errorCode errorMessage:errorMessage];
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"SET_DEVICE_URL====%@",error);
         [LoadingView dismissLoadingView];
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}

#pragma mark 设置或绑定
- (void)setDataWithErrorCode:(int)errorCode errorMessage:(NSString *)message
{
    if (errorCode == 1)
    {
        AddCameraSucessViewController *addCameraSucessViewController = [[AddCameraSucessViewController alloc] init];
        addCameraSucessViewController.deviceID = self.deviceID;
        [self.navigationController pushViewController:addCameraSucessViewController animated:YES];
        [self setContactData];
        
    }
    else
    {
        AddCameraFailViewController *addCameraFailViewController = [[AddCameraFailViewController alloc] init];
        addCameraFailViewController.errorString = message;
        [self.navigationController pushViewController:addCameraFailViewController animated:YES];
    }
}

- (void)setContactData
{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:self.deviceID];
    if(!contact)
    {
        contact = [[Contact alloc] init];
        contact.contactId = self.deviceID;
        contact.contactName = self.deviceID;
        contact.contactPassword = self.passwordTextField.textField.text;
        contact.contactType = CONTACT_TYPE_PHONE;
        [[FListManager sharedFList] insertContact:contact];
        
        if (![YooSeeApplication shareApplication].contact)
        {
            [YooSeeApplication shareApplication].contact = contact;
            [USER_DEFAULT setObject:contact.contactId forKey:@"DefaultDeviceID"];
        }
    }
    else
    {
        [contact setContactId:self.deviceID];
        [contact setContactName:self.deviceID];
        [contact setContactPassword:self.passwordTextField.textField.text];
        [[FListManager sharedFList] update:contact];
    }
    
    //更新设备列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceListFromServer" object:self];
    
    [[P2PClient sharedClient] getContactsStates:@[contact.contactId]];
    /*!
     *  获取防区状态
     */
    [[P2PClient sharedClient] getDefenceState:contact.contactId
                                     password:contact.contactPassword];
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
