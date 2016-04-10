//
//  SellerMessageEditViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/29.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerMessageEditViewController.h"

#import "PublishAdvertisementTableViewCell.h"

#import <CoreLocation/CoreLocation.h>
#import "GCJTOBD2.h"

#import <MapKit/MapKit.h>
#import "MapLocation.h"

#define CellDefaultHeight 50
#define ContentViewHeight 80

#define FontDefault 14
#define WidthDefault 200

#define ContentDefaultText2 @"请输入商家简介"

#define Hud_uploadFail @"上传失败,请您重试"

typedef NS_OPTIONS(NSUInteger, ActionSheetTag) {
    ActionSheetTag_professionType = 1 << 0,
    ActionSheetTag_addPicture = 1 << 1,
};

@interface SellerMessageEditViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UITextViewDelegate,CLLocationManagerDelegate, MKMapViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@property(nonatomic,strong)UIButton *logoButton;
@property(nonatomic,strong)UITextField *professionTypeField;
@property(nonatomic,strong)UITextField *sellNameField;
@property(nonatomic,strong)UITextField *phoneField;

@property(nonatomic,strong)UITextView *contentView2;
@property(nonatomic,strong)UITextField *addressField;

@property(nonatomic,strong)UIImage *logoImage;
@property(nonatomic,strong)NSArray *textArray;

@property(nonatomic,strong)NSMutableArray *professionNameArray;
@property(nonatomic,strong)NSMutableArray *professionIdArray;

@property(nonatomic,strong)NSString *professionId;
@property(nonatomic,strong)NSString *professionName;

@property(nonatomic,strong)NSString *province;
@property(nonatomic,strong)NSString *city;
@property(nonatomic,strong)NSString *area;
@property(nonatomic,strong)NSString *address;

@property(nonatomic,strong)NSString *jingDu;
@property(nonatomic,strong)NSString *weiDu;

@property(nonatomic,strong)NSString *logoUrl;
@property(nonatomic,strong)CLLocationManager *locationManager;

@property (strong, nonatomic) MKMapView *mapView;

@property(nonatomic,strong)UIImageView *imageview;

@end

@implementation SellerMessageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.title = @"编辑";
    [self setTableFootView];
    self.textArray = @[@"",@"行业类别",@"商户名称",@"客服电话",@"",@"商家位置",@""];
    self.professionIdArray = Alloc(NSMutableArray);
    self.professionNameArray = Alloc(NSMutableArray);
    
    [self getProfessiontyperRequest];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 1000.0f;
    [self locationService];
    
    UINib *nib = [UINib nibWithNibName:@"PublishAdvertisementTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}

#pragma mark -
-(void)setTableFootView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    footView.backgroundColor = VIEW_BG_COLOR;
    self.tableView.tableFooterView = footView;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"修改" forState:UIControlStateNormal];
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
-(UITextField *)professionTypeField{
    if (!_professionTypeField) {
        _professionTypeField = Alloc(UITextField);
        _professionTypeField.font = [UIFont systemFontOfSize:FontDefault];
        _professionTypeField.placeholder = @"请选择所属行业类型";
        _professionTypeField.width = 180;
        _professionTypeField.height = CellDefaultHeight;
        _professionTypeField.textAlignment = NSTextAlignmentRight;
        _professionTypeField.keyboardType = UIKeyboardTypeNumberPad;
        _professionTypeField.delegate = self;
        [_professionTypeField addTarget:self action:@selector(textFieldShouldEditing) forControlEvents:UIControlEventEditingDidBegin];
    }
    
    return _professionTypeField;
}

-(UITextField *)sellNameField{
    if (!_sellNameField) {
        _sellNameField = Alloc(UITextField);
        _sellNameField.font = [UIFont systemFontOfSize:16];
        _sellNameField.placeholder = @"填写工商注册全称";
        _sellNameField.width = WidthDefault;
        _sellNameField.height = CellDefaultHeight;
        _sellNameField.textAlignment = NSTextAlignmentRight;
        _sellNameField.keyboardType = UIKeyboardTypeDefault;
        _sellNameField.delegate = self;
    }
    
    return _sellNameField;
}

-(UITextField *)phoneField{
    if (!_phoneField) {
        _phoneField = Alloc(UITextField);
        _phoneField.font = [UIFont systemFontOfSize:FontDefault];
        _phoneField.placeholder = @"填写电话";
        _phoneField.width = WidthDefault;
        _phoneField.height = CellDefaultHeight;
        _phoneField.textAlignment = NSTextAlignmentRight;
        _phoneField.keyboardType = UIKeyboardTypePhonePad;
        _phoneField.delegate = self;
    }
    
    return _phoneField;
}

-(UITextView *)contentView2{
    if (!_contentView2) {
        _contentView2 = Alloc(UITextView);
        _contentView2.font = [UIFont systemFontOfSize:FontDefault];
        _contentView2.text = ContentDefaultText2;
        _contentView2.textColor = [UIColor lightGrayColor];
        _contentView2.width = SCREEN_WIDTH-40;
        _contentView2.height = ContentViewHeight;
        _contentView2.delegate = self;
        _contentView2.backgroundColor = [UIColor clearColor];
        _contentView2.delegate = self;
    }
    
    return _contentView2;
}

-(UITextField *)addressField{
    if (!_addressField) {
        _addressField = Alloc(UITextField);
        _addressField.font = [UIFont systemFontOfSize:FontDefault];
        _addressField.placeholder = @"填写地址或者定位地址";
        _addressField.width = WidthDefault;
        _addressField.height = CellDefaultHeight;
        _addressField.textAlignment = NSTextAlignmentRight;
        _addressField.keyboardType = UIKeyboardTypeDefault;
        _addressField.delegate = self;
    }
    
    return _addressField;
}

-(MKMapView *)mapView{
    if(_mapView == nil){
        _mapView = [[MKMapView alloc] init];
        _mapView.width = SCREEN_WIDTH-40;
        _mapView.height = SCREEN_WIDTH-40;
        _mapView.delegate = self;
        
        [_mapView addSubview:self.imageview];
        self.imageview.frame = CGRectMake((_mapView.width-22)/2, (_mapView.height-22)/2, 22, 22);
    }
    return _mapView;
}

-(UIImageView *)imageview{
    if (_imageview == nil) {
        _imageview = Alloc(UIImageView);
        _imageview.image = [UIImage imageNamed:@"SellerMessageEdit_location"];
    }
    
    return _imageview;
}

#pragma mark -
-(void)submitButtonClick:(UIButton *)button{
    NSString *message;
    
    if (self.professionTypeField.text.length == 0) {
        message = @"请选择行业类别";
        [CommonTool addPopTipWithMessage:message];
        return;
    }else if (self.sellNameField.text.length == 0) {
        message = @"请填写工商注册全称";
        [CommonTool addPopTipWithMessage:message];
        return;
    }else if(self.phoneField.text.length == 0){
        message = @"请填写电话";
        [CommonTool addPopTipWithMessage:message];
        return;
    }else if (self.logoImage == nil) {
        message = @"请选择商家LOGO";
        [CommonTool addPopTipWithMessage:message];
        return;
    }else if(self.addressField.text.length == 0){
        message = @"请填写商家位置";
        [CommonTool addPopTipWithMessage:message];
        return;
    }else if (self.contentView2.text.length == 0) {
        message = @"请输入商家简介";
        [CommonTool addPopTipWithMessage:message];
        return;
    }

    [self editRequest];
}

-(void)addPictureButtonClick:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
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

#pragma mark -
-(void)editRequest{
    if(![HttpManager haveNetwork]){
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.phoneField.text forKey:@"contact_phone"];
    [dic setObject:self.province forKey:@"province_name"];
    [dic setObject:self.city forKey:@"city_name"];
    [dic setObject:self.area forKey:@"area_name"];
    [dic setObject:self.jingDu forKey:@"jigndu"];
    [dic setObject:self.weiDu forKey:@"weidu"];
    
    [dic setObject:self.professionName forKey:@"hangye_name"];
    [dic setObject:self.professionId forKey:@"hangye_id"];
    
    [dic setObject:self.sellNameField.text forKey:@"dian_name"];
    [dic setObject:self.contentView2.text forKey:@"dian_content"];
    [dic setObject:self.logoUrl forKey:@"dian_logo"];
    
    NSString *url = [Url_Host stringByAppendingString:@"app/shop/update"];

    [HttpManager postUrl:url parameters:dic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:@"参数错误"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

-(void)uploadImageRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    
    int totalCount = 0;
    __block int sendCount = 0;
    
    if (self.logoImage != nil) {
        totalCount++;
    }
    
    WeakSelf(weakSelf);
    
    if (self.logoImage != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.logoImage, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                weakSelf.logoUrl = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self editRequest];
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

#pragma mark -
-(void)getProfessiontyperRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSString *urlString = [Url_Host stringByAppendingString:@"app/goods/classify/query"];
    WeakSelf(weakSelf);
    
    [HttpManager postUrl:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            for(NSDictionary *dic in message.resultList){
                [weakSelf.professionNameArray addObject:dic[@"fenlei_content"]];
                [weakSelf.professionIdArray addObject:[NSString stringWithFormat:@"%@",dic[@"id"]]];
            }
        }else if ([message.returnCode intValue] == 1){
            [SVProgressHUD showSuccessWithStatus:@"获取数据失败"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.textArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%d",indexPath.row];

    if(indexPath.row == 0){
        PublishAdvertisementTableViewCell *cell = (PublishAdvertisementTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        cell.contentLabel.text = @"商家LOGO";
        [cell.addPicture1 addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.addPicture2.hidden = YES;
        cell.addPicture3.hidden = YES;
        return cell;
    }
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = self.textArray[indexPath.row];
    
    switch (indexPath.row) {
        case 1:{
            cell.accessoryView = self.professionTypeField;
        }
            break;
            
        case 2:{
            cell.accessoryView = self.sellNameField;
        }
            break;
            
        case 3:{
            cell.accessoryView = self.phoneField;
        }
            break;
            
        case 4:{
            cell.accessoryView = self.contentView2;
        }
            break;
            
        case 5:{
            cell.accessoryView = self.addressField;
        }
            break;
            
        case 6:{
            cell.accessoryView = self.mapView;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 44;
    
    if(indexPath.row == 0){
        height = 35+(SCREEN_WIDTH-20*4)/3+10;
        return height;
    }else if(indexPath.row == 4){
        height = ContentViewHeight;
    }else if (indexPath.row == 6){
        height = SCREEN_WIDTH-40;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //分割线顶格
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

#pragma mark - UITextFieldDelegate
-(void)textFieldShouldEditing{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    for (NSString *string in self.professionNameArray) {
        [actionSheet addButtonWithTitle:string];
    }
    
    [actionSheet showInView:self.view];
    [self performSelector:@selector(allTextFieldResignFirstResponder) withObject:nil afterDelay:0.1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.sellNameField) {
        [self.phoneField becomeFirstResponder];
    }else if (textField == self.phoneField){
        [self.contentView2 becomeFirstResponder];
    }else if(textField == self.addressField){
        [self.addressField resignFirstResponder];
    }
    
    return YES;
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

#pragma mark -
-(void)allTextFieldResignFirstResponder{
    [self.professionTypeField resignFirstResponder];
    [self.sellNameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
    [self.contentView2 resignFirstResponder];
    [self.addressField resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag == ActionSheetTag_addPicture){
        if (buttonIndex == 0) {
            // 拍照
            if ([Utils isCameraAvailable] && [Utils doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([Utils isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
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
        return;
    }else{
        if (buttonIndex == 0) {
            return;
        }
        
        self.professionId = self.professionIdArray[buttonIndex-1];
        self.professionName = self.professionNameArray[buttonIndex-1];
        
        self.professionTypeField.text = self.professionNameArray[buttonIndex-1];
        [self.sellNameField becomeFirstResponder];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        PublishAdvertisementTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [picker dismissViewControllerAnimated:YES completion:^() {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [cell.addPicture1 setBackgroundImage:image forState:UIControlStateNormal];
            self.logoImage = image;
        }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - location
-(void)locationService
{
    if ([CLLocationManager locationServicesEnabled])
    {
        //定位功能可用，开始定位
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
        }
#endif
        [_locationManager startUpdatingLocation];
    }else{
        [_locationManager stopUpdatingLocation];
        //请求数据
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message: @"请在系统设置中开启定位服务" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
//    _locationManager.delegate = nil;
//    _locationManager = nil;
    
    CLLocation *currLocation = [locations lastObject];
    CLLocationCoordinate2D coordinate = currLocation.coordinate;
    [self getCity:coordinate];
    
//    double lat = [GCJTOBD2 bd_encryptLat:coordinate.latitude gglon:coordinate.longitude];
//    double lon = [GCJTOBD2 bd_encryptLon:coordinate.latitude gglon:coordinate.longitude];
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    [self.mapView setCenterCoordinate:coordinate animated:YES];

    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center = coordinate;
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [_mapView setRegion:theRegion animated:YES];
    
    self.jingDu = [NSString stringWithFormat:@"%f",coordinate.longitude];
    self.weiDu = [NSString stringWithFormat:@"%f",coordinate.latitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    [manager stopUpdatingLocation];
    switch([error code]) {
        case kCLErrorDenied:
            errorString = @"无法成功定位";
            break;
        case kCLErrorLocationUnknown:
            errorString = @"定位服务不可用";
            break;
        default:
            errorString = @"无法成功定位";
            break;
    }
    [SVProgressHUD showErrorWithStatus:errorString];
}

#pragma mark -
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D centerCoordinate = mapView.centerCoordinate;
    [self getCity:centerCoordinate];
}

#pragma mark -
-(void)getCity:(CLLocationCoordinate2D)coordinate{
    double lat = [GCJTOBD2 bd_encryptLat:coordinate.latitude gglon:coordinate.longitude];
    double lon = [GCJTOBD2 bd_encryptLon:coordinate.latitude gglon:coordinate.longitude];
    
    self.jingDu = [NSString stringWithFormat:@"%f",coordinate.longitude];
    self.weiDu = [NSString stringWithFormat:@"%f",coordinate.latitude];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
//             [SVProgressHUD showErrorWithStatus:@"定位失败"];
             return;
         }
         
         if(placemarks.count > 0)
         {
             CLPlacemark *placemark = placemarks[0];
             NSRange range =[placemark.locality rangeOfString:@"省"];
             if(range.location != NSNotFound){
                 self.province = placemark.locality;
                 self.city = placemark.administrativeArea;
                 self.area = placemark.subAdministrativeArea;
             }
             
             NSLog(@"subLocality==%@",placemark.subLocality);
             
             NSRange range1 =[placemark.locality rangeOfString:@"市"];
             if(range1.location != NSNotFound){
                 self.province = placemark.administrativeArea;
                 self.city = placemark.locality;
                 self.area = placemark.subLocality;
             }
             
             NSString *string;
             if (placemark.subThoroughfare == nil) {
                 string = [NSString stringWithFormat:@"%@%@%@",self.city,self.area,placemark.thoroughfare];
             }else{
                 string = [NSString stringWithFormat:@"%@%@%@%@",self.city,self.area,placemark.thoroughfare,placemark.subThoroughfare];
             }
             self.address = placemark.thoroughfare;
             self.addressField.text = string;
         }
     }];
}

@end
