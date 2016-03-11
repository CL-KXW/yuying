//
//  ReciverInfoViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define TEXTFIELD_HEIGHT    40.0 * CURRENT_SCALE
#define SPACE_X             30.0 * CURRENT_SCALE
#define SPACE_Y             30.0 * CURRENT_SCALE
#define ADD_Y               15.0
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "ReciverInfoViewController.h"
#import "CustomTextField.h"
#import "STPickerArea.h"

@interface ReciverInfoViewController ()<STPickerAreaDelegate>

@property (nonatomic, strong) NSMutableArray *textFiledArray;
@property (nonatomic, strong) STPickerArea *areaPicker;

@end

@implementation ReciverInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"收货地址";
    [self addBackItem];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    float x = SPACE_X;
    float y = SPACE_Y + START_HEIGHT;
    float width = self.view.frame.size.width - 2 * x;
    float height = TEXTFIELD_HEIGHT;
    
    NSArray *array = @[@"收货人", @"联系人电话",@"省份地区",@"详细地址",@"邮政编码"];
    
    NSDictionary *dic = [YooSeeApplication shareApplication].userInfoDic;
    NSArray *valueArray = @[dic[@"receiver"],dic[@"contact"],dic[@"address"],dic[@"fulladdress"],[dic[@"areacode"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    for (int i = 0; i < [array count]; i++)
    {
        CustomTextField *textField = [[CustomTextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
        textField.textField.placeholder = array[i];
        textField.textField.text = valueArray[i];
        if (i == 1 || i == 4)
        {
            textField.textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        [self.view addSubview:textField];
        
        if (!_textFiledArray)
        {
            _textFiledArray = [[NSMutableArray alloc] init];
        }
        [self.textFiledArray addObject:textField];
        
        if (i == 2)
        {
            UIButton *button = [CreateViewTool createButtonWithFrame:textField.frame buttonImage:@"" selectorName:@"showAreaPickerView:"  tagDelegate:self];
            [self.view addSubview:button];
        }
        
        y += textField.frame.size.height + ADD_Y;
    }
    
    y += SPACE_Y;
    UIButton *commitButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, width, BUTTON_HEIGHT) buttonTitle:@"保存" titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"commitButtonPressed:" tagDelegate:self];
    [CommonTool clipView:commitButton withCornerRadius:BUTTON_RADIUS];
    [self.view addSubview:commitButton];
}

#pragma mark 显示pickview
- (void)showAreaPickerView:(UIButton *)sender
{
    [self dismissKeyBorad];
    if (!_areaPicker)
    {
        _areaPicker = [[STPickerArea alloc] initWithDelegate:self];
    }
    [_areaPicker show];
}


- (void)dismissKeyBorad
{
    for (CustomTextField *textField in self.textFiledArray)
    {
        [textField.textField resignFirstResponder];
    }
}

- (void)pickerArea:(STPickerArea *)pickerArea province:(NSString *)province city:(NSString *)city area:(NSString *)area;
{
    ((CustomTextField *)self.textFiledArray[2]).textField.text = [NSString stringWithFormat:@"%@%@%@",province,city,area];
}

#pragma mark 保存按钮
- (void)commitButtonPressed:(UIButton *)sender
{
    NSString *contact = ((CustomTextField *)self.textFiledArray[0]).textField.text;
    NSString *phone = ((CustomTextField *)self.textFiledArray[1]).textField.text;
    NSString *address = ((CustomTextField *)self.textFiledArray[2]).textField.text;
    NSString *fullAddress = ((CustomTextField *)self.textFiledArray[3]).textField.text;
    NSString *proCode = ((CustomTextField *)self.textFiledArray[4]).textField.text;
    
    NSString *message = @"";
    if (contact.length == 0)
    {
        message = @"联系人不能空";
    }
    else if (![CommonTool isEmailOrPhoneNumber:phone])
    {
        message = @"请输入正确的手机号";
    }
    else if (address.length == 0)
    {
        message = @"请输入选择地址";
    }
    else if (fullAddress.length == 0)
    {
        message = @"请输入详细地址";
    }
    else if (proCode.length != 6)
    {
        message = @"请输入正确的邮政编码";
    }
    if (message.length != 0)
    {
        [CommonTool addPopTipWithMessage:message];
        return;
    }
    
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *userInfo = [YooSeeApplication shareApplication].userInfoDic;
    NSDictionary *requestDic = @{@"uid":uid,@"username":userInfo[@"username"],@"sex":userInfo[@"sex"],@"receiver":contact,@"contact":phone,@"address":address,@"fulladdress":fullAddress,@"areacode":proCode};
    [self saveAddressInfoRequest:requestDic];
}

#pragma mark 保存地址
- (void)saveAddressInfoRequest:(NSDictionary *)requestDic
{
    [LoadingView showLoadingView];
    //__weak typeof(self) weakSelf = self;
    [[RequestTool alloc] desRequestWithUrl:UPDATE_USER_INFO_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"UPDATE_USER_INFO_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             [SVProgressHUD showSuccessWithStatus:@"修改成功"];
             [YooSeeApplication shareApplication].userInfoDic = requestDic;
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"UPDATE_USER_INFO_URL====%@",error);
         [LoadingView dismissLoadingView];
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];

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
