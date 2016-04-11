//
//  PublishAdvertisementViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "PublishAdvertisementViewController.h"

#import "PublishAdvertisementTableViewCell.h"
#import "UUDatePicker.h"
#import "DCPaymentView.h"

#import "FindPasswordViewController.h"

typedef NS_OPTIONS(NSUInteger, ActionSheetTag) {
    ActionSheetTag_area = 1 << 0,
    ActionSheetTag_addPicture = 1 << 1,
};

typedef NS_ENUM(NSUInteger, PulishArea) {
    PulishArea_localCity = 0,
    PulishArea_localProvince,
    PulishArea_country,
};

#define ContentViewHeight 80

#define Hud_uploadFail @"上传失败,请您重试"

#define CellDefaultHeight 50
#define ContentDefaultText2 @"请输入广告内容描述文字。（选填项，可不填）"

@interface PublishAdvertisementViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UUDatePickerDelegate>

@property(nonatomic,strong)NSArray *cellTextArray;
@property(nonatomic,strong)UITextField *totalMoneyField;
@property(nonatomic,strong)UITextField *oneMoneyField;
@property(nonatomic,strong)UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITableView *tableView;

@property(nonatomic,strong)UIButton *areaButton;
@property(nonatomic,strong)UIButton *endDateButton;
@property(nonatomic,strong)UITextView *contentView2;

@property(nonatomic,strong)UIImage *advertisementImage1;
@property(nonatomic,strong)UIImage *advertisementImage2;
@property(nonatomic,strong)UIImage *advertisementImage3;

@property(nonatomic,strong)UUDatePicker *calendarPickView;

@property(nonatomic,strong)NSString *uuid1;
@property(nonatomic,strong)NSString *uuid2;
@property(nonatomic,strong)NSString *uuid3;
@property(nonatomic,strong)NSString *uuid4;

@property(nonatomic,strong)NSString *url1;
@property(nonatomic,strong)NSString *url2;
@property(nonatomic,strong)NSString *url3;
@property(nonatomic,strong)NSString *url4;

@property(nonatomic)NSInteger buttonTag;

@property(nonatomic)float rates; //费率
@property(nonatomic)float commissionMoney;  //手续费
@property(nonatomic)float adTotalMoney;     //广告总额
@property(nonatomic)PulishArea publishArea;

@end

@implementation PublishAdvertisementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = @"发布赚钱广告";
    self.cellTextArray = @[@"红包个数",@"单个金额",@"发布区域",@"结束时间"];
    self.publishArea = PulishArea_localCity;
    self.url1 = @"";
    self.url2 = @"";
    self.url3 = @"";
    self.url4 = @"";
    self.uuid1 =@"";
    self.uuid2 = @"";
    self.uuid3 = @"";
    self.uuid4 = @"";
    UINib *nib = [UINib nibWithNibName:@"PublishAdvertisementTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self setTableFootView];
    [self systemRateRequest];
}

#pragma mark -
-(void)setTableFootView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    footView.backgroundColor = VIEW_BG_COLOR;
    self.tableView.tableFooterView = footView;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).with.offset(20);
        make.leading.equalTo(footView.mas_leading).with.offset(20);
        make.trailing.equalTo(footView.mas_trailing).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    [submitButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
}

#pragma mark - init
-(UITextField *)totalMoneyField{
    if (!_totalMoneyField) {
        _totalMoneyField = Alloc(UITextField);
        _totalMoneyField.font = [UIFont systemFontOfSize:16];
        _totalMoneyField.placeholder = @"填写红包个数";
        _totalMoneyField.width = 150;
        _totalMoneyField.height = CellDefaultHeight;
        _totalMoneyField.textAlignment = NSTextAlignmentRight;
        _totalMoneyField.keyboardType = UIKeyboardTypeNumberPad;
        _totalMoneyField.delegate = self;
    }
    
    return _totalMoneyField;
}

-(UITextField *)oneMoneyField{
    if (!_oneMoneyField) {
        _oneMoneyField = Alloc(UITextField);
        _oneMoneyField.font = [UIFont systemFontOfSize:16];
        _oneMoneyField.placeholder = @"填写单次领取金额";
        _oneMoneyField.width = 180;
        _oneMoneyField.height = CellDefaultHeight;
        _oneMoneyField.textAlignment = NSTextAlignmentRight;
        _oneMoneyField.keyboardType = UIKeyboardTypeDecimalPad;
        _oneMoneyField.delegate = self;
    }
    
    return _oneMoneyField;
}

-(UIButton *)areaButton{
    if (!_areaButton) {
        _areaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_areaButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        NSString *city = [YooSeeApplication shareApplication].userDic[@"city_name"];
        NSString *string = [NSString stringWithFormat:@"本市(%@)",city];
        [_areaButton setTitle:string forState:UIControlStateNormal];
        _areaButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _areaButton.height = CellDefaultHeight;
        _areaButton.width = 120;
        [_areaButton addTarget:self action:@selector(areaButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _areaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _areaButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 20);
        
        UILabel *downLabel = Alloc(UILabel);
        downLabel.text = @"▼";
        downLabel.frame = CGRectMake(105, 0, 20, CellDefaultHeight);
        [_areaButton addSubview:downLabel];
    }
    
    return _areaButton;
}

-(UIButton *)endDateButton{
    if (!_endDateButton) {
        _endDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_endDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
        NSDate *nowLocalDate = [[NSDate date] dateByAddingTimeInterval:interval+90*24*60*60];
        NSString *string = [formatter stringFromDate:nowLocalDate];
        [_endDateButton setTitle:string forState:UIControlStateNormal];
        _endDateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _endDateButton.height = CellDefaultHeight;
        _endDateButton.width = 200;
        _endDateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _endDateButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 20);
        [_endDateButton addTarget:self action:@selector(endDateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *downLabel = Alloc(UILabel);
        downLabel.text = @"▼";
        downLabel.frame = CGRectMake(200-15, 0, 20, CellDefaultHeight);
        [_endDateButton addSubview:downLabel];
    }
    
    return _endDateButton;
}

-(UITextField *)titleField{
    if (!_titleField) {
        _titleField = Alloc(UITextField);
        _titleField.font = [UIFont systemFontOfSize:16];
        _titleField.placeholder = @"请输入广告标题(必填项)";
        _titleField.width = 200;
        _titleField.height = CellDefaultHeight;
        _titleField.textAlignment = NSTextAlignmentRight;
    }
    
    return _titleField;
}

-(UITextView *)contentView2{
    if (!_contentView2) {
        _contentView2 = Alloc(UITextView);
        _contentView2.font = [UIFont systemFontOfSize:16];
        _contentView2.text = ContentDefaultText2;
        _contentView2.textColor = [UIColor lightGrayColor];
        _contentView2.width = SCREEN_WIDTH-40;
        _contentView2.height = ContentViewHeight;
        _contentView2.delegate = self;
        _contentView2.backgroundColor = [UIColor clearColor];
    }
    
    return _contentView2;
}

#pragma mark -
-(void)areaButtonClick:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"发布区域"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"本市",@"本省", @"全国",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    actionSheet.tag = ActionSheetTag_area;
}

-(void)endDateButtonClick:(UIButton *)button{
   [self allTextFieldResignFirstResponder];
    
    UIWindow *windows = [[UIApplication sharedApplication] keyWindow];
    self.calendarPickView = [[UUDatePicker alloc] initWithframe:windows.bounds Delegate:self PickerStyle:UUDateStyle_YearMonthDayHourMinute];
    self.calendarPickView.minLimitDate = [NSDate date];
    self.calendarPickView.tag = 101;
    [windows addSubview:self.calendarPickView];
    [self.calendarPickView show];
}

-(void)addPictureButtonClick:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
    self.buttonTag = button.tag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从相册中选取",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    actionSheet.tag = ActionSheetTag_addPicture;
}

-(void)submitButtonClick:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
    NSString *message;
    if (self.totalMoneyField.text.length == 0) {
        message = @"请填写红包个数";
        [CommonTool addPopTipWithMessage:message];
    }else if(self.oneMoneyField.text.length == 0){
        message = @"请填写单次领取金额";
        [CommonTool addPopTipWithMessage:message];
    }else if (self.titleField.text.length == 0){
        message = @"请填写广告标题";
        [CommonTool addPopTipWithMessage:message];
    }else if(self.advertisementImage1 == nil){
        message = @"请选择广告封面";
        [CommonTool addPopTipWithMessage:message];
    }else if([self.totalMoneyField.text intValue] == 0){
        message = @"红包个数必须大于0";
        [CommonTool addPopTipWithMessage:message];
    }else if([self.oneMoneyField.text floatValue] == 0.0){
        message = @"单次领取金额必须大于0";
        [CommonTool addPopTipWithMessage:message];
    }else{
        [[IQKeyboardManager sharedManager] setEnable:NO];
        DCPaymentView *payAlert = [[DCPaymentView alloc]init];
        payAlert.title = @"请输入支付密码";
        [payAlert show];
        payAlert.completeHandle = ^(NSString *inputPwd) {
            [[IQKeyboardManager sharedManager] setEnable:NO];
            [self passwordIsTrue:inputPwd];
        };
        payAlert.forgetPasswordHandle = ^(){
            [[IQKeyboardManager sharedManager] setEnable:NO];
            FindPasswordViewController *findPasswordViewController = [[FindPasswordViewController alloc] init];
            findPasswordViewController.isPayPassword = YES;
            [self.navigationController pushViewController:findPasswordViewController animated:YES];
        };
    }
}

#pragma mark -
-(void)passwordIsTrue:(NSString *)password{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    NSString *md5 = [password getMd5_32Bit_String];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:md5 forKey:@"pwd"];
    NSString *user_id = [YooSeeApplication shareApplication].uid;
    [dic setObject:[NSString stringWithFormat:@"%@",user_id] forKey:@"user_id"];
    
    NSString *url = [Url_Host stringByAppendingString:@"app/shop/verifyPassword"];
    [LoadingView showLoadingView];
    [HttpManager postUrl:url parameters:dic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag) {
            [self uploadImageRequest];
        }else if([jsonObject[@"returnCode"] intValue] == 3){
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:@"支付密码错误"];
        }else if([jsonObject[@"returnCode"] intValue] == 4){
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:@"您还没设置支付密码"];
        }else if([jsonObject[@"returnCode"] intValue] == 1){
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:@"参数错误"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

-(void)sendSubmitRequest{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *user_id = [YooSeeApplication shareApplication].uid;
    [dic setObject:[NSString stringWithFormat:@"%@",user_id] forKey:@"user_id"];
    NSNumber *shop_number = [YooSeeApplication shareApplication].userDic[@"shop_number"];
    [dic setObject:[NSString stringWithFormat:@"%@",shop_number] forKey:@"shop_number"];
    NSString *area_city_role_id;
    if (self.publishArea == PulishArea_localCity) {
        area_city_role_id = [YooSeeApplication shareApplication].userDic[@"city_id"];
    }else if (self.publishArea == PulishArea_localProvince){
        area_city_role_id = [YooSeeApplication shareApplication].userDic[@"province_id"];
    }else if (self.publishArea == PulishArea_country){
        area_city_role_id = @"1";
    }
    [dic setObject:[NSString stringWithFormat:@"%@",area_city_role_id] forKey:@"area_city_role_id"];
    [dic setObject:self.endDateButton.titleLabel.text forKey:@"end_time"];
    
    NSString *totalMoney = [NSString stringWithFormat:@"%.2f",[self.totalMoneyField.text intValue]*[self.oneMoneyField.text floatValue]];
    [dic setObject:totalMoney forKey:@"guanggao_money"];
    [dic setObject:self.oneMoneyField.text forKey:@"lingqu_money"];
    [dic setObject:[NSString stringWithFormat:@"%.2f",self.commissionMoney] forKey:@"rate_money"];
    [dic setObject:self.oneMoneyField.text forKey:@"fa_sum_number"];
    
    [dic setObject:self.titleField.text forKey:@"content_1"];
    NSString *content2 = @"";
    if(![self.contentView2.text isEqualToString:ContentDefaultText2]){
        content2 = self.contentView2.text;
    }
    [dic setObject:content2 forKey:@"content_2"];
    
    NSString *content3 = @"";
    [dic setObject:content3 forKey:@"content_3"];
    
    NSString *content4 = @"";
    [dic setObject:content4 forKey:@"content_4"];
    
    [dic setObject:self.url1 forKey:@"url_1"];
    [dic setObject:self.url2 forKey:@"url_2"];
    [dic setObject:self.url3 forKey:@"url_3"];
    [dic setObject:self.url4 forKey:@"url_4"];
    [dic setObject:self.uuid1 forKey:@"url_uuid_1"];
    [dic setObject:self.uuid2 forKey:@"url_uuid_2"];
    [dic setObject:self.uuid3 forKey:@"url_uuid_3"];
    [dic setObject:self.uuid4 forKey:@"url_uuid_4"];
    
    NSString *aesString = [Utils aesStingDictionary:dic];
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:aesString forKey:@"requestmessage"];
    WeakSelf(weakSelf);
    
    NSString *string = [Url_Host stringByAppendingString:@"app/ab/send"];
    [HttpManager postUrl:string parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else if ([message.returnCode intValue] == 3){
            [SVProgressHUD showSuccessWithStatus:@"余额不足"];
        }else if ([message.returnCode intValue] == 1){
            [SVProgressHUD showSuccessWithStatus:@"参数为空"];
        }else if ([message.returnCode intValue] == 2){
            [SVProgressHUD showSuccessWithStatus:@"参数错误"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

-(void)uploadImageRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [LoadingView showLoadingView];
    
    int totalCount = 0;
    __block int sendCount = 0;

    if (self.advertisementImage1 != nil) {
        totalCount++;
    }
    if (self.advertisementImage2 != nil) {
        totalCount++;
    }
    if (self.advertisementImage3 != nil) {
        totalCount++;
    }
    
    WeakSelf(weakSelf);
    
    if (self.advertisementImage1 != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.advertisementImage1, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                weakSelf.uuid1 = response.uuid;
                weakSelf.url1 = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];
    }
    if (self.advertisementImage2 != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.advertisementImage2, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                weakSelf.uuid2 = response.uuid;
                weakSelf.url2 = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];
        
    }
    if (self.advertisementImage3 != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.advertisementImage3, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                weakSelf.uuid3 = response.uuid;
                weakSelf.url3 = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];
    }
}

-(void)systemRateRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        //获取手续费率
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [LoadingView showLoadingView];
    [HttpManager postUrl:Url_systemRate parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag) {
            NSArray *array = jsonObject[@"resultList"];
            NSDictionary *dic = [array firstObject];
            self.rates = [dic[@"rate_ad"] floatValue];
            [self.tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionError];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark - UUDatePicker
-(void)uuDatePicker:(UUDatePicker *)datePicker year:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute weekDay:(NSString *)weekDay{
    NSString *yearStr = [year substringWithRange:NSMakeRange(0, year.length-1)];
    NSString *monthStr = [month substringWithRange:NSMakeRange(0, month.length-1)];
    NSString *dayStr = [day substringWithRange:NSMakeRange(0, day.length-1)];
    NSString *hourStr = [hour substringWithRange:NSMakeRange(0, hour.length-1)];
    NSString *minStr = [minute substringWithRange:NSMakeRange(0, minute.length-1)];
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:00",yearStr,monthStr,dayStr,hourStr,minStr];
    if (datePicker.tag == 101) {
        [self.endDateButton setTitle:dateStr forState:UIControlStateNormal];
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }else if(section == 1){
        return 1;
    }else{
        return 3;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.cellTextArray[indexPath.row];
        
        switch (indexPath.row) {
            case 0:{
                UIView *view = Alloc(UIView);
                view.width = self.totalMoneyField.width+20;
                view.height = CellDefaultHeight;
                [view addSubview:self.totalMoneyField];
                UILabel *label = Alloc(UILabel);
                label.text = @"个";
                label.font = [UIFont systemFontOfSize:16];
                label.textColor = [UIColor blackColor];
                label.textAlignment = NSTextAlignmentRight;
                label.frame = CGRectMake(view.width-20, 0, 20, CellDefaultHeight);
                [view addSubview:label];
                cell.accessoryView = view;
            }
                break;
                
            case 1:{
                UIView *view = Alloc(UIView);
                view.width = self.oneMoneyField.width+20;
                view.height = CellDefaultHeight;
                [view addSubview:self.oneMoneyField];
                UILabel *label = Alloc(UILabel);
                label.text = @"元";
                label.font = [UIFont systemFontOfSize:16];
                label.textColor = [UIColor blackColor];
                label.textAlignment = NSTextAlignmentRight;
                label.frame = CGRectMake(view.width-20, 0, 20, CellDefaultHeight);
                [view addSubview:label];
                cell.accessoryView = view;
            }
                break;
                
            case 2:{
                cell.accessoryView = self.areaButton;
            }
                break;
                
            case 3:{
                cell.accessoryView = self.endDateButton;
            }
                break;
                
            default:
                break;
        }
    }else if(indexPath.section == 1){
        cellIdent = @"CELL1";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdent];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.adTotalMoney = [self.totalMoneyField.text floatValue]*[self.oneMoneyField.text floatValue];
        self.commissionMoney = self.adTotalMoney*self.rates/100;
        float allMoney = self.adTotalMoney+self.commissionMoney;
        NSString *string = [NSString stringWithFormat:@"总支付  ¥%.2f",allMoney];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        UIColor *color =[ UIColor blackColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, 6)];
        color = [UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(6,string.length-6)];
        cell.textLabel.attributedText = attrString;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        string = [NSString stringWithFormat:@"其中包含收取手续费%.2f%@,合计%.2f元",self.rates,@"%",self.commissionMoney];
        attrString = [[NSMutableAttributedString alloc] initWithString:string];
        color =[ UIColor blackColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, 9)];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(13, string.length-13)];
        color = [UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(9,4)];
        cell.detailTextLabel.attributedText = attrString;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }else{
        switch (indexPath.row) {
            case 0:
            {
                cell.accessoryView = self.titleField;
                cell.textLabel.text = @"标题";
            }
                break;
                
            case 1:{
                cell.accessoryView = self.contentView2;
            }
                break;
                
            case 2:{
                PublishAdvertisementTableViewCell *cell = (PublishAdvertisementTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = nil;
                [cell.addPicture1 addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.addPicture2 addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.addPicture3 addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                if(self.advertisementImage1 != nil){
                    cell.addPicture2.hidden = NO;
                    [cell.addPicture1 setBackgroundImage:self.advertisementImage1 forState:UIControlStateNormal];
                }else{
                    cell.addPicture2.hidden = YES;
                }
                if(self.advertisementImage2 != nil){
                    cell.addPicture3.hidden = NO;
                    [cell.addPicture2 setBackgroundImage:self.advertisementImage2 forState:UIControlStateNormal];
                }else{
                    cell.addPicture3.hidden = YES;
                }
                if (self.advertisementImage3 != nil) {
                    [cell.addPicture3 setBackgroundImage:self.advertisementImage3 forState:UIControlStateNormal];
                }
                return cell;
            }
                break;
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = CellDefaultHeight;
    
    if(indexPath.section == 2 && indexPath.row == 2){
        height = 35+(SCREEN_WIDTH-20*4)/3+10;
    }else if(indexPath.section == 2 && indexPath.row == 1){
        height = ContentViewHeight;
    }else if(indexPath.section == 1){
        height = 70;
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+0, bounds.size.height-lineHeight, bounds.size.width-0, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == ActionSheetTag_area) {
        if (buttonIndex == 3) {
            return;
        }
        
        self.publishArea = buttonIndex;
        if(buttonIndex == 0){
            NSString *city = [YooSeeApplication shareApplication].userDic[@"city_name"];
            NSString *string = [NSString stringWithFormat:@"本市(%@)",city];
            [self.areaButton setTitle:string forState:UIControlStateNormal];
        }else if(buttonIndex == 1){
            NSString *province = [YooSeeApplication shareApplication].userDic[@"province_name"];
            NSString *string = [NSString stringWithFormat:@"本省(%@)",province];
            [self.areaButton setTitle:string forState:UIControlStateNormal];
        }else{
            [self.areaButton setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        }
    }else{
        if (buttonIndex == 0) {
            // 拍照
            if ([Utils isCameraAvailable] && [Utils doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([Utils isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([Utils isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:2];
    PublishAdvertisementTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        switch (self.buttonTag) {
            case 2:{
                [cell.addPicture1 setBackgroundImage:image forState:UIControlStateNormal];
                self.advertisementImage1 = image;
            }
                break;
                
            case 3:{
                [cell.addPicture2 setBackgroundImage:image forState:UIControlStateNormal];
                self.advertisementImage2 = image;
            }
                break;
                
            case 4:{
                [cell.addPicture3 setBackgroundImage:image forState:UIControlStateNormal];
                self.advertisementImage3 = image;
            }
                break;
        }
        
        NSIndexPath *ind = [NSIndexPath indexPathForRow:2 inSection:2];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ind] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.contentView2) {
        if([_contentView2.text isEqualToString:ContentDefaultText2]){
            _contentView2.text = @"";
        }
        _contentView2.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView == self.contentView2) {
        if([self.contentView2.text isEqualToString:@""]){
            textView.text = ContentDefaultText2;
            textView.textColor = [UIColor lightGrayColor];
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    NSString *willString;
    willString = [NSString stringWithFormat:@"%@%@%@",[textField.text substringToIndex:range.location],string,[textField.text substringFromIndex:range.location]];
    
    if ([willString isEqualToString:@"00"]) {
        return NO;
    }
    
    //两个小数点
    NSRange rangNow = [textField.text rangeOfString:@"."];
    if (rangNow.location != NSNotFound && [string isEqualToString:@"."]) {
        return NO;
    }

    //小数点超过两位
    rangNow = [willString rangeOfString:@"."];
    if (rangNow.location != NSNotFound && 3<(willString.length-rangNow.location)) {
        return NO;
    }
    
    if([willString isEqualToString:@"0"] && textField == self.totalMoneyField){
        return NO;
    }
    
    //单个红包大小
    if ([willString floatValue] > 200.0 && textField == self.oneMoneyField) {
        return NO;
    }
    
    //红包个数
    if ([willString floatValue] > 99999 && textField == self.totalMoneyField) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
-(void)allTextFieldResignFirstResponder{
    [self.totalMoneyField resignFirstResponder];
    [self.oneMoneyField resignFirstResponder];
    [self.titleField resignFirstResponder];
    [self.contentView2 resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.totalMoneyField || textField == self.oneMoneyField) {
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
