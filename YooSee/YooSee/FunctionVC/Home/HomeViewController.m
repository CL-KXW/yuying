//
//  HomeViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X                     10.0 * CURRENT_SCALE
#define SPACE_Y                     15.0
#define ADV_HEIGHT                  195.0 * CURRENT_SCALE

#define SECTION_HEIGHT              15.0 * CURRENT_SCALE
#define ROW1_HEIGHT                 50.0
#define ROW2_HEIGHT                 190.0 * CURRENT_SCALE
#define ROW3_HEIGHT                 160.0 * CURRENT_SCALE
#define HEADER_LABEL_WIDTH          30.0
#define HEADER_NEW_WIDTH            240.0 * CURRENT_SCALE
#define BUTTON_TITLE_HEIGHT         30.0 * CURRENT_SCALE
#define ITEM_BUTTON_TITLE_HEIGHT    25.0 * CURRENT_SCALE

#define LINE_COLOR                  RGB(239.0,239.0,239.0)

#define TIP_TEXT                @" 特别推荐 "
#define TIP_TEXT_FONT           FONT(14.0)
#define ADD_X                   10.0 * CURRENT_SCALE
#define LABEL_HEIGHT            30.0 * CURRENT_SCALE
#define LINE_HEIGHT             0.5
#define LINE_SPACE_X            30 * CURRENT_SCALE

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "BannerView.h"
#import "LocalWebViewController.h"
#import "AddCameraMainViewController.h"
#import "CameraMainViewController.h"
#import "LoginViewController.h"
#import "ScanViewController.h"
#import "UserCenterMainViewController.h"
#import "GetMoneryViewController.h"
#import "WebViewController.h"
#import "NewsListViewController.h"
#import "CameraListViewController.h"
#import "CameraSafeInfoViewController.h"
#import "CameraPasswordViewController.h"
#import "Y1YViewController.h"
#import "RobRedPackgeListVC.h"
#import "TempPicViewController.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *rowHeightArray;
@property (nonatomic, strong) BannerView *bannerView;
@property (nonatomic, strong) NSArray *bannerListArray;
@property (nonatomic, strong) UIView *headNewsView;
@property (nonatomic, strong) UILabel *headNewLabel;
@property (nonatomic, strong) NSArray *headNewsListArray;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *commendView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int newIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavBarItemWithImageName:@"icon_navbar_usercenter" navItemType:LeftItem selectorName:@"userCenterButtonPressed:"];
    [self setNavBarItemWithImageName:@"icon_navbar_sys" navItemType:RightItem selectorName:@"scanButtonPressed:"];
    
    _newIndex = 0;
    //_rowHeightArray = @[@(ROW1_HEIGHT),@(ROW2_HEIGHT)];
    
    //if (SCREEN_HEIGHT == 480.0)
    {
        _rowHeightArray = @[@(ROW1_HEIGHT),@(ROW2_HEIGHT),@(ROW3_HEIGHT)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePassword) name:@"ChangedPassword" object:nil];
    
    [self initUI];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAdvSucess:) name:@"GetAdvSucess" object:nil];

    //获取头条消息
    [self getHeadNewsRequest];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addTableView];
    [self addTableViewHeader];
    [self addCommendView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)addTableViewHeader
{
    NSDictionary *infoDic = [USER_DEFAULT objectForKey:@"AdvInfo"];
    NSArray *array = infoDic[@"home_page_List"];
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
    headerView.backgroundColor = [UIColor whiteColor];
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




- (void)getAdvSucess:(NSNotification *)notification
{
    [self addTableViewHeader];
}


#pragma mark 新闻头条
- (void)initHeadNewView
{
    if (!_headNewsView)
    {
        _headNewsView = [[UIView alloc] initWithFrame:CGRectMake(SPACE_X, 0, self.table.frame.size.width - 2 * SPACE_X, ROW1_HEIGHT)];
        _headNewsView.backgroundColor = [UIColor whiteColor];
        [CommonTool clipView:_headNewsView withCornerRadius:10.0];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
        [_headNewsView addGestureRecognizer:tapGesture];
        
//        UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, 0, HEADER_LABEL_WIDTH, _headNewsView.frame.size.height) textString:@"头条" textColor:[UIColor orangeColor] textFont:FONT(16.0)];
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        [_headNewsView addSubview:titleLabel];
        
        UIImageView *iconImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(HEADER_LABEL_WIDTH/2, (_headNewsView.frame.size.height - 15.0)/2, HEADER_LABEL_WIDTH, 15.0) placeholderImage:[UIImage imageNamed:@"img_hot"]];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_headNewsView addSubview:iconImageView];
        
        float x = iconImageView.frame.origin.x + iconImageView.frame.size.width + HEADER_LABEL_WIDTH/2;
        float y = 5.0;
        float width = 2.0;
        float add_x = 10.0;
        UIImageView *lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, _headNewsView.frame.size.height - 2 * y) placeholderImage:nil];
        lineImageView.backgroundColor = LINE_COLOR;
        [_headNewsView addSubview:lineImageView];
        
        x += lineImageView.frame.size.width + add_x;
        _headNewLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, 0, HEADER_NEW_WIDTH, _headNewsView.frame.size.height) textString:@"" textColor:[UIColor grayColor] textFont:FONT(16.0)];
        [_headNewsView addSubview:_headNewLabel];
    
    }
    
    if (self.headNewsListArray && [self.headNewsListArray count] > 0)
    {
        _headNewLabel.text = self.headNewsListArray[0][@"title"];
        [self creatTimer];
    }
}

- (void)creatTimer
{
    if (_timer)
    {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeText) userInfo:nil repeats:YES];
}

- (void)changeText
{
    _newIndex = (_newIndex + 1) % [self.headNewsListArray count];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:kCATransitionFromTop];
    [_headNewLabel.layer addAnimation:animation forKey:nil];
    
    _headNewLabel.text = self.headNewsListArray[_newIndex][@"title"];
}

- (void)tapGestureHandle:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    if (point.x <= HEADER_LABEL_WIDTH)
    {
        //列表
        NewsListViewController *newsListViewController = [[NewsListViewController alloc] init];
        newsListViewController.dataArray = self.headNewsListArray;
        [self.navigationController pushViewController:newsListViewController animated:YES];
    }
    else
    {
        //详情
        NSDictionary *dataDic = self.headNewsListArray[_newIndex];
        //if ([dataDic[@"targettype"] integerValue] == 2)
        {
            NSString *url = dataDic[@"url"];
            url = url ? url : @"";
            NSString *title = dataDic[@"title"];
            title = title ? title : @"点亮科技";
            if (url.length > 0)
            {
                WebViewController *webViewController = [[WebViewController alloc] init];
                webViewController.urlString = url;
                webViewController.title = title;
                [self.navigationController pushViewController:webViewController animated:YES];
            }
        }
    }
}


#pragma mark 功能视图
- (void)initMainFunctionView
{
    if (!_mainView)
    {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(SPACE_X, 0, self.table.frame.size.width - 2 * SPACE_X, ROW2_HEIGHT)];
        _mainView.backgroundColor = [UIColor clearColor];
        
        NSArray *imageArray = @[@"icon_home_monery",@"icon_home_sale",@"icon_home_camera"];
        NSArray *titleArray = @[@"赚钱",@"商家优惠",@"家视频"];
        NSArray *itemImageArray = @[@[@"icon_home_zxj",@"icon_home_charge"],@[@"icon_home_shop",@"icon_home_public"],@[@"icon_home_alert",@"icon_home_more"]];
        NSArray *itemTitleArray = @[@[@"抢红包",@"摇一摇"],@[@"体验购",@"发广告"],@[@"警报",@"更多"]];
        UIImage *image = [UIImage imageNamed:@"icon_home_monery_up"];
        float itemWidth = (_mainView.frame.size.width - 2 * SPACE_X)/[imageArray count];
        float button_wh = image.size.width/2  * CURRENT_SCALE;
        float button_space_x = (itemWidth - button_wh)/2;
        float space_y = 10.0 * CURRENT_SCALE;
        for (int i = 0; i < [imageArray count]; i++)
        {
            UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(button_space_x + (itemWidth + SPACE_X) * i, 0, button_wh, button_wh) buttonImage:imageArray[i] selectorName:@"functionButtonPressed:" tagDelegate:self];
            button.tag = 1 + i;
            [_mainView addSubview:button];
            
            float y = button.frame.origin.y + button_wh/3;
            UIImageView *imageView = [CreateViewTool createImageViewWithFrame:CGRectMake((itemWidth + SPACE_X) * i, y, itemWidth, _mainView.frame.size.height - y) placeholderImage:nil];
            imageView.backgroundColor = [UIColor whiteColor];
            [CommonTool clipView:imageView withCornerRadius:10.0];
            [_mainView insertSubview:imageView atIndex:0];
            
            y = button.frame.origin.y + button.frame.size.height;
            UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(imageView.frame.origin.x, y, imageView.frame.size.width, BUTTON_TITLE_HEIGHT) textString:titleArray[i] textColor:[UIColor grayColor] textFont:FONT(16.0)];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [_mainView addSubview:titleLabel];
            
            for (int j = 0; j < [itemImageArray[i] count]; j++)
            {
                float itemTitleLabel_width = imageView.frame.size.width/[itemImageArray[i] count];
                y = _mainView.frame.size.height - space_y - ITEM_BUTTON_TITLE_HEIGHT;
                UILabel *itemTitleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(imageView.frame.origin.x + j * itemTitleLabel_width, y, itemTitleLabel_width, ITEM_BUTTON_TITLE_HEIGHT) textString:itemTitleArray[i][j] textColor:[UIColor lightGrayColor] textFont:FONT(12.0)];
                itemTitleLabel.textAlignment = NSTextAlignmentCenter;
                [_mainView addSubview:itemTitleLabel];
                
                UIImage *itemImage = [UIImage imageNamed:@"icon_home_zxj_up"];
                float item_button_wh = itemImage.size.width/2  * CURRENT_SCALE;
                float item_button_space_x = (itemWidth/2 - item_button_wh)/2.0;
                y -=  item_button_wh;
                UIButton *itemButton = [CreateViewTool createButtonWithFrame:CGRectMake(item_button_space_x + (itemWidth/2) * j + imageView.frame.origin.x, y, item_button_wh, item_button_wh) buttonImage:itemImageArray[i][j] selectorName:@"itemButtonPressed:" tagDelegate:self];
                itemButton.tag = 10 + i * 10 + j;
                [_mainView addSubview:itemButton];

            }
        }
    }
}


#pragma mark 添加精彩推荐
- (void)addCommendView
{
    if (!_commendView)
    {
        float width0 = self.table.frame.size.width;
        float height0 = ROW3_HEIGHT;
        float x0 = 0;
        float y0 = 0;
        _commendView = [CreateViewTool createImageViewWithFrame:CGRectMake(x0, y0, width0, height0) placeholderImage:nil];
        _commendView.backgroundColor = [UIColor whiteColor];
        float y = 10.0 * CURRENT_SCALE;
        CGSize size = [TIP_TEXT sizeWithAttributes:@{NSFontAttributeName:TIP_TEXT_FONT}];
        float width = size.width + 2 * ADD_X;
        UILabel *tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake((self.view.frame.size.width - width)/2, y, width, LABEL_HEIGHT) textString:TIP_TEXT textColor:DE_TEXT_COLOR textFont:TIP_TEXT_FONT];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [_commendView addSubview:tipLabel];
        
        y += (tipLabel.frame.size.height - LINE_HEIGHT)/2;
        
        UIImageView *leftLineView = [CreateViewTool createImageViewWithFrame:CGRectMake(LINE_SPACE_X, y, tipLabel.frame.origin.x - LINE_SPACE_X, LINE_HEIGHT)placeholderImage:nil];
        leftLineView.backgroundColor = DE_TEXT_COLOR;
        [_commendView addSubview:leftLineView];
        
        UIImageView *rightLineView = [CreateViewTool createImageViewWithFrame:CGRectMake(self.view.frame.size.width - leftLineView.frame.size.width - LINE_SPACE_X, y, tipLabel.frame.origin.x - LINE_SPACE_X, LINE_HEIGHT)placeholderImage:nil];
        rightLineView.backgroundColor = DE_TEXT_COLOR;
        [_commendView addSubview:rightLineView];
        
        NSArray *imageArray = @[@"temp_golo.png",
                                @"temp_camera.png"];
        NSArray *titleArray = @[@"车载Wifi汽车检测仪",
                                @"鱼鹰摄像头"];
        float image_width = 117.0 * CURRENT_SCALE;
        float image_height = 90.0 * CURRENT_SCALE;
        float itemWidth = _commendView.frame.size.width/[imageArray count];
        float x = (itemWidth - image_width)/2;
        for (int i = 0; i < [imageArray count]; i++)
        {
            //float add_y = 10 * CURRENT_SCALE;
            y = tipLabel.frame.size.height + tipLabel.frame.origin.y;
            UIImageView *imageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x + i * itemWidth, y, image_width, image_height) placeholderImage:[UIImage imageNamed:imageArray[i]]];
            [_commendView addSubview:imageView];
            
            y += imageView.frame.size.height;
            UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(i * itemWidth, y, itemWidth, LABEL_HEIGHT) textString:titleArray[i] textColor:DE_TEXT_COLOR textFont:TIP_TEXT_FONT];
            label.textAlignment = NSTextAlignmentCenter;
            [_commendView addSubview:label];
        }
    }
}

#pragma mark 获取头条消息
- (void)getHeadNewsRequest
{
    __weak typeof(self) weakSelf = self;
    NSString *cityID = [YooSeeApplication shareApplication].cityID;
    cityID = cityID ? cityID : @"1";
    NSString *provinceID = [YooSeeApplication shareApplication].provinceID;
    provinceID = provinceID ? provinceID : @"1";
    NSDictionary *requestDic = @{@"city_id":cityID,@"province_id":provinceID};
    [[RequestTool alloc] requestWithUrl:GET_HEADNEWS_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_HEADNEWS_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 8)
         {
             //[weakSelf setDataWithDictionary:dataDic];
             weakSelf.headNewsListArray = dataDic[@"resultList"];
             [weakSelf.table reloadData];
         }
         else
         {
             //[SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"GET_HEADNEWS_URL====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}

-(void)userIsSellerRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    NSDictionary *userDic = [YooSeeApplication shareApplication].userInfoDic;
    NSString *key = userDic ? @"id" : @"user_id";
    userDic = userDic ? userDic : [YooSeeApplication shareApplication].userDic;
    NSString *user_id = userDic[key];
    user_id = UNNULL_STRING(user_id);
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

#pragma mark 个人中心
- (void)userCenterButtonPressed:(UIButton *)sender
{
    if (![YooSeeApplication shareApplication].isLogin)
    {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [self presentViewController:loginNav animated:YES completion:Nil];
        return;
    }
    UserCenterMainViewController *userCenterMainViewController = [[UserCenterMainViewController alloc] init];
    userCenterMainViewController.bannerListArray = self.bannerListArray;
    [self.navigationController pushViewController:userCenterMainViewController animated:YES];
}

#pragma mark 扫描
- (void)scanButtonPressed:(UIButton *)sender
{
    if (![YooSeeApplication shareApplication].isLogin)
    {
        [self addLoginView];
        return;
    }
    ScanViewController *scanViewController = [[ScanViewController alloc] init];
    scanViewController.tipString = @"若扫描没有反应，请将二维码远离手机";
    [self.navigationController pushViewController:scanViewController animated:YES];
}

#pragma mark 功能按钮 
- (void)functionButtonPressed:(UIButton *)sender
{
    int tag = (int)sender.tag - 1;
    
    BOOL isLogin = [YooSeeApplication shareApplication].isLogin;
    BOOL isLogin2cu = [YooSeeApplication shareApplication].isLogin2cu;
    
    if (!isLogin)
    {
        [self addLoginView];
        return;
    }
    
    if (tag == 2)
    {
        if (!isLogin2cu)
        {
            [LoadingView showLoadingView];
            [DELEGATE login2CU:YES];
            return;
        }
    }
    
    
    UIViewController *viewController = nil;
    if (tag == 0)
    {
        GetMoneryViewController *getMoneryViewController = [[GetMoneryViewController alloc] init];
        viewController = getMoneryViewController;
    }
    if (tag == 1)
    {
        //LocalWebViewController *storeDiscountViewController = [[LocalWebViewController alloc] init];
        //storeDiscountViewController.urlString = @"shopsDiscount";
        //viewController = storeDiscountViewController;
        TempPicViewController *tempPicViewController = [[TempPicViewController alloc] init];
        tempPicViewController.imageString = @"storeCut";
        tempPicViewController.title = @"商家优惠";
        [self.navigationController pushViewController:tempPicViewController animated:YES];
    }
    if (tag == 2)
    {
        NSArray *array = [YooSeeApplication shareApplication].devInfoListArray;
        if (!array)
        {
            [self getDeviceListRequest];
        }
        else
        {
            if ([array count] == 0)
            {
                AddCameraMainViewController *addCameraMainViewController = [[AddCameraMainViewController alloc] init];
                viewController = addCameraMainViewController;
            }
            else
            {
                CameraMainViewController *cameraMainViewController = [[CameraMainViewController alloc] init];
                viewController = cameraMainViewController;
            }
        }

      
    }
    
    if (viewController)
    {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


#pragma mark 获取设备列表
- (void)getDeviceListRequest
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    NSDictionary *requestDic = @{@"userid":uid};
    [[RequestTool alloc] requestWithUrl:DEVICE_LIST_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"DEVICE_LIST_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             NSArray *bodyArray = dataDic[@"resultList"];
             if ([bodyArray count] == 0 || !bodyArray)
             {
                 [YooSeeApplication shareApplication].devInfoListArray = nil;
                 AddCameraMainViewController *addCameraMainViewController = [[AddCameraMainViewController alloc] init];
                 [weakSelf.navigationController pushViewController:addCameraMainViewController animated:YES];
             }
             else
             {
                 NSString *defaultDeviceID = [USER_DEFAULT objectForKey:@"DefaultDeviceID"];
                 if (!defaultDeviceID)
                 {
                     defaultDeviceID = [NSString stringWithFormat:@"%@",bodyArray[0][@"camera_number"]];
                     [USER_DEFAULT setObject:defaultDeviceID forKey:@"DefaultDeviceID"];
                     Contact *contact = [[Contact alloc] init];
                     contact.contactId = defaultDeviceID;
                     contact.contactName = defaultDeviceID;
                     [YooSeeApplication shareApplication].contact = contact;
                 }
                 [YooSeeApplication shareApplication].devInfoListArray = bodyArray;
                 CameraMainViewController *cameraMainViewController = [[CameraMainViewController alloc] init];
                 [weakSelf.navigationController pushViewController:cameraMainViewController animated:YES];
             }
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"GET_ADV_URL====%@",error);
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:@"加载失败"];
     }];
    
}

#pragma mark item功能按钮
- (void)itemButtonPressed:(UIButton *)sender
{
    int type = (int)sender.tag/10;
    int tag = (int)sender.tag%10;
    
    BOOL isLogin = [YooSeeApplication shareApplication].isLogin;
    BOOL isLogin2cu = [YooSeeApplication shareApplication].isLogin2cu;
    
    if (!isLogin)
    {
        [self addLoginView];
        return;
    }
    
    if (type == 3)
    {
        if (!isLogin2cu)
        {
            [LoadingView showLoadingView];
            [DELEGATE login2CU:YES];
            return;
        }
    }
    if (type == 1)
    {
        //赚钱
        if (tag == 0)
        {
            //抢红包
            RobRedPackgeListVC *robRP = [[RobRedPackgeListVC alloc] init];
            [self.navigationController pushViewController:robRP animated:YES];
        }
        if (tag == 1)
        {
            //摇一摇
            Y1YViewController *y1y = [[Y1YViewController alloc] init];
            [self.navigationController pushViewController:y1y animated:YES];
        }
    }
    if (type == 3)
    {
        //家视频
        if (tag == 0)
        {
            //报警
            CameraSafeInfoViewController *cameraSafeInfoViewController = [[CameraSafeInfoViewController alloc] init];
            cameraSafeInfoViewController.contact = [YooSeeApplication shareApplication].contact;
            [self.navigationController pushViewController:cameraSafeInfoViewController animated:YES];
            
        }
        if (tag == 1)
        {
            //更多
            CameraListViewController *cameraListViewController = [[CameraListViewController alloc] init];
            [self.navigationController pushViewController:cameraListViewController animated:YES];
        }
    }
    if (type == 2)
    {
        if(tag == 1){
            [self userIsSellerRequest];
            return;
        }
        
        //商城
        //LocalWebViewController *storeDiscountViewController = [[LocalWebViewController alloc] init];
        //storeDiscountViewController.urlString = (tag == 0) ? SHOP : PUBLIC_ADV;
        //[self.navigationController pushViewController:storeDiscountViewController animated:YES];
        if (tag == 0)
        {
            TempPicViewController *tempPicViewController = [[TempPicViewController alloc] init];
            tempPicViewController.imageString = @"store";
            tempPicViewController.title = @"体验购";
            [self.navigationController pushViewController:tempPicViewController animated:YES];
        }
        if (tag == 1)
        {
            //发广告
        }
    }
}

#pragma mark 添加登录界面
- (void)addLoginView
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self presentViewController:nav animated:YES completion:Nil];
}


#pragma mark 修改密码
- (void)changePassword
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    CameraPasswordViewController *cameraPasswordViewController = [[CameraPasswordViewController alloc] init];
    cameraPasswordViewController.deviceID = [YooSeeApplication shareApplication].contact.contactId;
    cameraPasswordViewController.isChange = YES;
    [self.navigationController pushViewController:cameraPasswordViewController animated:YES];
}


#pragma mark UITableViewDelegate&UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *headerView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SECTION_HEIGHT) placeholderImage:nil];
    headerView.backgroundColor = section == 0 ? [UIColor whiteColor] : VIEW_BG_COLOR;
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.rowHeightArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEIGHT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.rowHeightArray[indexPath.section] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    cell.backgroundColor = (indexPath.section == 1) ? [UIColor clearColor] : [UIColor whiteColor];
    
    if (indexPath.section == 0)
    {
        [self initHeadNewView];
        [cell.contentView addSubview:self.headNewsView];
    }
    else if (indexPath.section == 1)
    {
        [self initMainFunctionView];
        [cell.contentView addSubview:self.mainView];
    }
    else if (indexPath.section == 2)
    {
        [self addCommendView];
        [cell.contentView addSubview:self.commendView];
    }
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
