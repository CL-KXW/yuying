//
//  UserCenterMainViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define ADV_HEIGHT       195.0 * CURRENT_SCALE
#define ROW_HEIGHT1      195.0 * CURRENT_SCALE
#define ROW_HEIGHT2      100.0 * CURRENT_SCALE
#define ROW_HEIGHT3      50.0 * CURRENT_SCALE
#define HEADER_HEIGHT    10.0 * CURRENT_SCALE
#define SPACE_X          10.0
#define SPACE_Y          10.0 * CURRENT_SCALE
#define ITEM_WH          55.0 * CURRENT_SCALE
#define LABEL_HEIGHT     20.0 * CURRENT_SCALE
#define LABEL_WIDTH      180.0 * CURRENT_SCALE
#define ROW_SPACE_Y      10.0
#define BUTTON_HEIGHT    50.0 * CURRENT_SCALE
#define BUTTON_RADIUS    BUTTON_HEIGHT/2

#import "UserCenterMainViewController.h"
#import "BannerView.h"
#import "LocalWebViewController.h"
#import "SettingViewController.h"
#import "UMSocial.h"
#import "InviteFriendViewController.h"
#import "PersonalInfoViewController.h"
#import "WebViewController.h"
#import "NewsListViewController.h"
#import "GoldLibraryViewController.h"
#import "RedPackgeLibraryVC.h"
#import "UpLoadPhotoTool.h"

#import "SellerCentreViewController.h"
#import "SellerCentreReviewStatusViewController.h"
#import "SellerCentreJoinViewController.h"

@interface UserCenterMainViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UploadPhotoDelegate>

@property (nonatomic, strong) NSArray *otherTitleArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) BannerView *bannerView;
@property (nonatomic, strong) UITableView *otherTableView;
@property (nonatomic, strong) UpLoadPhotoTool *uploadTool;


@end

@implementation UserCenterMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"个人中心";
    [self addBackItem];
    
    _titleArray = @[@[@""],@[@""],@[@""],@[@" 设置"],@[@" 商家注册"]];
    _otherTitleArray = @[@" 邀请好友",@" 分享",@" 软件升级"];
    
    [self initUI];

    //获取个人信息
    [self getUserInfoRequest];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.table reloadData];
}

#pragma mark  初始化UI
- (void)initUI
{
    [self addTableView];
    [self addTableViewHeader];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, HEADER_HEIGHT)];
    footView.backgroundColor = [UIColor clearColor];
    self.table.tableFooterView = footView;
}

- (void)addTableViewHeader
{
    NSDictionary *infoDic = [USER_DEFAULT objectForKey:@"AdvInfo"];
    NSArray *array = infoDic[@"personal_center_List"];
    if (array && array.count > 0)
    {
        self.bannerListArray = [NSArray arrayWithArray:array];
    }
    else
    {
        [self.table setTableHeaderView:nil];
        return;
    }
    UIImageView *headerView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, self.table.frame.size.width, ADV_HEIGHT + SPACE_Y) placeholderImage:nil];
    
    float y = SPACE_Y;
    float x = SPACE_X;
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    
    if (self.bannerListArray && [self.bannerListArray count] > 0)
    {
        if ([self.bannerListArray count] == 1)
        {
            self.bannerListArray = @[self.bannerListArray[0],self.bannerListArray[0],self.bannerListArray[0]];
        }
        for (NSDictionary *dataDic in self.bannerListArray)
        {
            NSString *imageUrl = dataDic[@"image_url"];
            imageUrl = imageUrl ? imageUrl : @"";
            if (imageUrl.length > 0)
            {
                [imageArray addObject:imageUrl];
            }
            
        }
    }
    __weak typeof(self) weakSelf = self;
    if (!_bannerView)
    {
        _bannerView = [[BannerView alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width - 2 * SPACE_X, ADV_HEIGHT) WithNetImages:imageArray];
        _bannerView.AutoScrollDelay = 3;
        _bannerView.placeImage = [UIImage imageNamed:@"adv_default"];
        [CommonTool clipView:_bannerView withCornerRadius:10.0];
        [_bannerView setSmartImgdidSelectAtIndex:^(NSInteger index)
         {
             NSLog(@"网络图片 %d",index);
             NSDictionary *dic = weakSelf.bannerListArray[index];
             NSString *urlString = dic[@"image_href_url"];
             urlString = urlString ? urlString : @"";
             if (urlString.length == 0)
             {
                 return;
             }
             WebViewController *webViewController = [[WebViewController alloc] init];
             webViewController.urlString = urlString;
             webViewController.title = dic[@"title"] ? dic[@"title"] : @"点亮科技";
             [weakSelf.navigationController pushViewController:webViewController animated:YES];
         }];
    }
    
    [headerView addSubview:_bannerView];
    
    [self.table setTableHeaderView:headerView];
}

- (void)addItemButtonToView:(UIView *)view
{
    NSArray *titleArray = @[@"消息",@"现金库",@"红包库",@"卡券库",@"购物车",@"我的订单",@"我的收藏",@"发广告"];
    float item_width = view.frame.size.width/4;
    float y = ROW_SPACE_Y;
    float x = 0;
    for (int i = 1; i <= [titleArray count] ; i++)
    {
        if (i < 5)
        {
            y = ITEM_WH + ROW_SPACE_Y + ROW_SPACE_Y;
        }
        else
        {
            y = 2  * (ITEM_WH + ROW_SPACE_Y) + LABEL_HEIGHT + ROW_SPACE_Y + ROW_SPACE_Y;
        }
        if (i == 5)
        {
            x = 0;
        }
        UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, item_width, LABEL_HEIGHT) textString:titleArray[i - 1] textColor:DE_TEXT_COLOR textFont:FONT(14.0)];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(x + (label.frame.size.width - ITEM_WH)/2, y - ITEM_WH - ROW_SPACE_Y, ITEM_WH, ITEM_WH) buttonImage:[NSString stringWithFormat:@"icon_usercenter_%d",i] selectorName:@"itemButtonPressed:" tagDelegate:self];
        button.tag = 100 + i;
        [view addSubview:button];
        
        x += item_width;
    }
}

- (void)addPersonalInfoToView:(UIView *)view
{
    float imageView_wh = view.frame.size.height - 4 * SPACE_Y;
    float x = 2 * SPACE_X;
    float y = 2 * SPACE_Y;
    
    NSDictionary *userDic = [YooSeeApplication shareApplication].userDic;
    NSDictionary *userInfoDic = [YooSeeApplication shareApplication].userInfoDic;
    NSDictionary *dataDic = (userInfoDic) ? userInfoDic : userDic;
    
    NSString *imageUrl = dataDic[@"head_url"];
    imageUrl = imageUrl ? imageUrl : @"";
    
    NSString *username = dataDic[@"username"];
    username = username ? username : @"";

    UIImage *image = [UIImage imageNamed:@"user_icon_default"];
    
    UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, imageView_wh, imageView_wh) buttonImage:@"" selectorName:@"tapGestureHandler:" tagDelegate:self];
    [button setImage:image forState:UIControlStateNormal];
    if (imageUrl.length > 0)
    {
       [button setImageWithURL:[NSURL URLWithString:imageUrl] forState:UIControlStateNormal];
    }
    [CommonTool setViewLayer:button withLayerColor:[UIColor lightGrayColor] bordWidth:0.5];
    [CommonTool clipView:button withCornerRadius:imageView_wh/2];
    [view addSubview:button];

    
    x += 2 * SPACE_X + button.frame.size.width;
    
    UILabel *nicknameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, LABEL_WIDTH, button.frame.size.height/2) textString:username textColor:DE_TEXT_COLOR textFont:FONT(16.0)];
    [view addSubview:nicknameLabel];
    
    y += nicknameLabel.frame.size.height;
    UILabel *usernameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, LABEL_WIDTH, button.frame.size.height/2) textString:[@"ID: " stringByAppendingString:[USER_DEFAULT objectForKey:@"UserName"]] textColor:DE_TEXT_COLOR textFont:FONT(16.0)];
    [view addSubview:usernameLabel];
}

- (void)addOtherTableViewToView:(UIView *)view
{
    if (!_otherTableView)
    {
        _otherTableView = [[UITableView alloc]initWithFrame:CGRectMake(-view.frame.origin.x, 0, self.table.frame.size.width, view.frame.size.height) style:UITableViewStylePlain];
        _otherTableView.dataSource = self;
        _otherTableView.delegate = self;
        _otherTableView.backgroundColor = [UIColor clearColor];
        _otherTableView.scrollEnabled = NO;
    }
    [view addSubview:_otherTableView];

}


#pragma mark 获取用户信息
- (void)getUserInfoRequest
{
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"id":uid};
    [[RequestTool alloc] requestWithUrl:USER_INFO_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"USER_INFO_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 8)
         {
             [YooSeeApplication shareApplication].userInfoDic = dataDic[@"resultList"];
             [weakSelf.table reloadData];
         }
         else
         {
             //[SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"USER_INFO_URL====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}

-(void)userIsSellerRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    NSString *user_id = [YooSeeApplication shareApplication].userInfoDic[@"id"];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",nil];
    
    WeakSelf(weakSelf);
    NSString *url = [Url_Host stringByAppendingString:@"app/shop/querybyUserId"];
    [HttpManager postUrl:url parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if (message.returnCode.intValue == SucessFlag)
        {
            SellerCentreViewController *sellerVC = [[SellerCentreViewController alloc] initWithNibName:@"SellerCentreViewController" bundle:nil];
            [weakSelf.navigationController pushViewController:sellerVC animated:YES];
        }else if (message.returnCode.intValue == 1){
            //无请求数据
        }else if (message.returnCode.intValue == 2){
            //不是商家
            SellerCentreJoinViewController *vc = Alloc_viewControllerNibName(SellerCentreJoinViewController);
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else if (message.returnCode.intValue == 3){
            //审核中
            SellerCentreReviewStatusViewController *vc = Alloc_viewControllerNibName(SellerCentreReviewStatusViewController);
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark 点击功能按钮  
- (void)itemButtonPressed:(UIButton *)sender
{
    int tag = (int)sender.tag - 101;
    NSArray *array = @[CARDTICKET,SHOPPING_CAR,USER_ORDER,USER_SAVE,PUBLIC_ADV];
    if (tag > 2)
    {
        LocalWebViewController *localWebViewController = [[LocalWebViewController alloc] init];
        localWebViewController.urlString = array[tag - 3];
        [self.navigationController pushViewController:localWebViewController animated:YES];
    }
    if (tag == 0)
    {
        //消息
        NewsListViewController *newsListViewController = [[NewsListViewController alloc] init];
        [self.navigationController pushViewController:newsListViewController animated:YES];
    }
    if (tag == 1)
    {
        //现金库
        GoldLibraryViewController *vc = [[GoldLibraryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (tag == 2)
    {
        //红包库
        RedPackgeLibraryVC *vc = [[RedPackgeLibraryVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark 修改头像
- (void)tapGestureHandler:(UIButton *)button
{
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
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [self updateUseInfoWithImageUrl:dataDic[@"access_url"]];
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

- (void)updateUseInfoWithImageUrl:(NSString *)imageUrl
{
    imageUrl = imageUrl ? imageUrl : @"";
    if (imageUrl.length == 0)
    {
        return;
    }
    [self changeUserInfoRequest:imageUrl forKey:@"head_url"];
}

#pragma mark 修改个人信息
- (void)changeUserInfoRequest:(NSString *)string forKey:(NSString *)key
{
    
    string = string ? string : @"";
    key = key ? key : @"";
    if (key.length == 0)
    {
        return;
    }
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:[YooSeeApplication shareApplication].userInfoDic];
    NSMutableDictionary *paramasDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    paramasDic[@"id"] = uid;
    paramasDic[key] = string;
    NSDictionary *requestDic = [RequestDataTool encryptWithDictionary:paramasDic];
    [[RequestTool alloc] requestWithUrl:UPDATE_USER_INFO_URL
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
         if (errorCode == 8)
         {
             [SVProgressHUD showSuccessWithStatus:@"修改成功"];
             userInfoDic[key] = string;
             [YooSeeApplication shareApplication].userInfoDic = userInfoDic;
             [weakSelf.table reloadData];
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


#pragma mark - tableView datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (tableView == _otherTableView) ? 0 : HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _otherTableView)
    {
        return ROW_HEIGHT3;
    }
    if (indexPath.section == 0)
    {
        return ROW_HEIGHT1;
    }
    if (indexPath.section == 1)
    {
        return ROW_HEIGHT2;
    }
    if (indexPath.section == 2)
    {
        return [_otherTitleArray count] * ROW_HEIGHT3;
    }
    
    return ROW_HEIGHT3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableView == _otherTableView ? 1 : [self.titleArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  tableView == _otherTableView ? [self.otherTitleArray count] : [self.titleArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    static NSString *cellID2 = @"cellID2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableView == _otherTableView  ? cellID2 : cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableView == _otherTableView  ? cellID2 : cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    
    if (tableView == _otherTableView)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.otherTitleArray[indexPath.row];
        cell.textLabel.font = FONT(16.0);
        return cell;
    }
    
    int section = (int)indexPath.section;
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    float height = ROW_HEIGHT3;
    if (indexPath.section == 0)
    {
        height = ROW_HEIGHT1;
    }
    if (indexPath.section == 1)
    {
        height = ROW_HEIGHT2;
    }
    if (indexPath.section == 2)
    {
        height =  [_otherTitleArray count] * ROW_HEIGHT3;
    }
    UIImageView *bgImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, 0, self.table.frame.size.width - 2 * SPACE_X, height) placeholderImage:nil];
    bgImageView.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:bgImageView withCornerRadius:10.0];
    [cell.contentView addSubview:bgImageView];
    
    if (section < 3)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"";
        if (section == 0)
        {
            [self addItemButtonToView:bgImageView];
        }
        if (section == 1)
        {
            [self addPersonalInfoToView:bgImageView];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (section == 2)
        {
            [self addOtherTableViewToView:bgImageView];
        }
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.titleArray[section][indexPath.row];
        cell.textLabel.font = FONT(16.0);
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _otherTableView)
    {
        //row 0:邀请好友 1:分享 2:软件升级
        int row = (int)indexPath.row;
        if (row == 0)
        {
            InviteFriendViewController *inviteFriendViewController = [[InviteFriendViewController alloc] init];
            [self.navigationController pushViewController:inviteFriendViewController animated:YES];
        }
        if (row == 1)
        {
            [self showShareView];
        }
        if (row == 2)
        {
            [DELEGATE checkUpdateShowTip:YES];
        }
    }
    else if (tableView == self.table)
    {
        UIViewController *viewController;
        int section = indexPath.section;
        //section 1:个人 3:设置 4:商家注册
        if (section == 1)
        {
            PersonalInfoViewController *personalInfoViewController = [[PersonalInfoViewController alloc] init];
            viewController = personalInfoViewController;
        }
        if (section == 3)
        {
            SettingViewController *settingViewController = [[SettingViewController alloc] init];
            viewController = settingViewController;
        }
        if (section == 4)
        {
            NSString *shop_number = [YooSeeApplication shareApplication].userInfoDic[@"shop_number"];
            if ([shop_number intValue] != 0) {
                SellerCentreViewController *sellerVC = [[SellerCentreViewController alloc] initWithNibName:@"SellerCentreViewController" bundle:nil];
                viewController = sellerVC;
            }else{
                [self userIsSellerRequest];
            }
        }
        if (viewController)
        {
            [self.navigationController pushViewController:viewController animated:YES];
        }
        
    }
}

#pragma mark 分享
- (void)showShareView
{
    NSString *shareText = @"欢迎加入鱼鹰，看广告赚话费金币，免费兑换商品，照顾家车安全。请点击下载：http://dianliangtech.com/download.html";
    UIImage *shareImage = [UIImage imageNamed:@"big_icon"];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UM_APP_KEY
                                      shareText:shareText
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToQzone,UMShareToEmail,UMShareToSms,nil]
                                       delegate:nil];
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
