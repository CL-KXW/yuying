//
//  SetCameraInfoViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/27.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X             10.0
#define SPACE_Y             15.0

#define VIEW_HEIGHT         480.0 * CURRENT_SCALE
#define VIEW_SPACE_Y        30.0 * CURRENT_SCALE
#define VIEW_BT_SPACE_Y     50.0 * CURRENT_SCALE
#define VIEW_SPACE_X        20.0 * CURRENT_SCALE
#define VIEW_ADD_Y          10.0 * CURRENT_SCALE
#define LABEL_HEIGHT        35.0 * CURRENT_SCALE
#define TITLE_HEIGHT        25.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define IMAGE_HEIGHT        170.0 * CURRENT_SCALE
#define TEXTFIELD_HEIGHT    50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "SetCameraInfoViewController.h"
#import "CustomTextField.h"
#import "UpLoadPhotoTool.h"

@interface SetCameraInfoViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UploadPhotoDelegate>

@property (nonatomic, strong) CustomTextField *nameTextField;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic, strong) UpLoadPhotoTool *uploadTool;

@end

@implementation SetCameraInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"摄像头信息";
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
    UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:[@"ID: " stringByAppendingString:self.deviceID] textColor:MAIN_TEXT_COLOR textFont:FONT(20.0)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
    
    x = VIEW_SPACE_X;
    y += titleLabel.frame.size.height + VIEW_ADD_Y;
    UILabel *titleLabel1 = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width - 2 * x, TITLE_HEIGHT) textString:@"名称" textColor:DE_TEXT_COLOR textFont:FONT(14.0)];
    [bgView addSubview:titleLabel1];
    
    y += titleLabel1.frame.size.height;
    _nameTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(x, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, TEXTFIELD_HEIGHT)];
    _nameTextField.textField.placeholder = @"备注名称";
    _nameTextField.textField.text = self.deviceID;
    if (self.contact)
    {
        NSString *deviceName = self.contact.contactName;
        deviceName = deviceName ? deviceName : @"";
        if (deviceName.length > 0)
        {
            _nameTextField.textField.text = deviceName;
        }
    }
    
    [bgView addSubview:_nameTextField];
    
    y += _nameTextField.frame.size.height + VIEW_ADD_Y;
    UILabel *titleLabel2 = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width - 2 * x, TITLE_HEIGHT) textString:@"封面图片" textColor:DE_TEXT_COLOR textFont:FONT(14.0)];
    [bgView addSubview:titleLabel2];
    
    y += titleLabel2.frame.size.height + VIEW_ADD_Y;
    x = VIEW_SPACE_X;
    _imageButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, bgView.frame.size.width - 2 * x, IMAGE_HEIGHT) buttonTitle:@"添加封面图片" titleColor:DE_TEXT_COLOR normalBackgroundColor:VIEW_BG_COLOR highlightedBackgroundColor:VIEW_BG_COLOR selectorName:@"imageButtonPressed:" tagDelegate:self];
    [bgView addSubview:_imageButton];
    
    if (self.imageUrl && self.imageUrl.length > 0)
    {
        [_imageButton setBackgroundImageWithURL:[NSURL URLWithString:self.imageUrl] forState:UIControlStateNormal];
        [_imageButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    y += _imageButton.frame.size.height + 3 * VIEW_ADD_Y;
    UIButton *doneButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, bgView.frame.size.width - 2 * x, BUTTON_HEIGHT) buttonTitle:@"完成" titleColor:[UIColor grayColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:nil selectorName:@"infoButtonPressed:" tagDelegate:self];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CommonTool clipView:doneButton withCornerRadius:BUTTON_RADIUS];
    [CommonTool setViewLayer:doneButton withLayerColor:[UIColor grayColor] bordWidth:1.0];
    [bgView addSubview:doneButton];
}


#pragma mark 图片
- (void)imageButtonPressed:(UIButton *)sender
{
    [self.nameTextField.textField resignFirstResponder];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"拍照",nil];
        actionSheet.tag = 100;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",nil];
        actionSheet.tag = 101;
        [actionSheet showInView:self.view];
    }
    
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"取消"])
    {
        return;
    }
    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        if (![title isEqualToString:@"取消"])
        {
            picker.sourceType = (buttonIndex == 0) ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:picker animated:YES completion:Nil];
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [_imageButton setImage:image forState:UIControlStateNormal];
    self.headImage = image;
    NSLog(@"info===%@",info);
    [picker dismissViewControllerAnimated:YES completion:Nil];
    [LoadingView showLoadingView];
    _uploadTool = [[UpLoadPhotoTool alloc] initWithPhotoArray:@[image] upLoadUrl:UPLOAD_PIC_URL requestData:nil];
    _uploadTool.delegate = self;
    
}

#pragma mark UpLoadPhotoDelegate
- (void)uploadPhotoSucessed:(UpLoadPhotoTool *)upLoadPhotoTool
{
    [LoadingView dismissLoadingView];
    NSDictionary *dataDic = upLoadPhotoTool.responseDic;
    if (!dataDic)
    {
        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        return;
    }
    int status = [dataDic[@"returnCode"] intValue];
    NSString *message = dataDic[@"returnMessage"];
    message = message ? message : @"上传失败";
    if (status == 8)
    {
        self.imageUrl = dataDic[@"access_url"];
        self.imageUrl = self.imageUrl ? self.imageUrl : @"";
        if (self.imageUrl && self.imageUrl.length > 0)
        {
            [_imageButton sd_setBackgroundImageWithURL:[NSURL URLWithString:self.imageUrl] forState:UIControlStateNormal];
            [_imageButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:message];
    }
    
}
- (void)uploadPhotoFailed:(UpLoadPhotoTool *)upLoadPhotoTool
{
    [LoadingView dismissLoadingView];
    [SVProgressHUD showErrorWithStatus:@"上传失败"];
}

- (void)isUploadingPhotoWithProcess:(float)process
{
    //[SVProgressHUD showWithStatus:[NSString stringWithFormat:@"已上传%.1f％",process * 100]];
}

#pragma mark 完成
- (void)infoButtonPressed:(UIButton *)sender
{
    [LoadingView showLoadingView];
    NSString *name = self.nameTextField.textField.text;
    name = name ? name : self.deviceID;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    __weak typeof(self) weakSelf = self;
    NSDictionary *requestDic = @{@"camera_name" : name,
                                 @"id" : UNNULL_STRING(self.deviceNo),
                                 @"address_gps" : @"",
                                 @"longitude" : @"",
                                 @"latitude" : @"",
                                 @"camera_cover" : UNNULL_STRING(self.imageUrl)};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:UPDATE_DEVICE_URL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"UPDATE_DEVICE_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 8)
         {
             [SVProgressHUD showSuccessWithStatus:@"保存成功"];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceUpdated" object:self.imageUrl];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceListFromServer" object:nil];
             if (weakSelf.contact)
             {
                 
                [weakSelf.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 [weakSelf.navigationController popToRootViewControllerAnimated:YES];
             }

         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"UPDATE_DEVICE_URL====%@",error);
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:@"保存失败"];
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
