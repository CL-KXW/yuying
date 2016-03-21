//
//  CameraMainViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/25.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X                 10.0
#define SPACE_Y                 15.0
#define ADD_Y                   10.0
#define ADV_HEIGHT              195.0 * CURRENT_SCALE
#define PLAYER_HEIGHT           360.0 * CURRENT_SCALE
#define REMOTEVIEW_HEIGHT       195.0 * CURRENT_SCALE
#define PLAYER_HEADER_HEIGHT    35.0 * CURRENT_SCALE
#define NUMBER_LABEL_HEIGHT     30.0
#define PROCESS_HEIGHT          5.0
#define PROCESS_COLOR           RGB(55.0, 171.0, 55.0)
#define PROCESS_LABEL_WIDTH     35.0
#define PROCESS_LABEL_HEIGHT    15.0
#define PLAYER_SPACE_X          15.0 * CURRENT_SCALE
#define PLAYER_SPACE_Y          10.0 * CURRENT_SCALE
#define NAME_LABEL_WIDTH        100.0 * CURRENT_SCALE
#define SPAKER_BUTTON_WH        84.0  * CURRENT_SCALE
#define PHOTO_AV_BUTTON_WH      49.0 * CURRENT_SCALE
#define BUTTON_SPACE_X          35.0 * CURRENT_SCALE
#define TIPLABEL_HEIGHT         30.0 * CURRENT_SCALE
#define RATIOS_BUTTON_WIDTH     60.0
#define RATIOS_BUTTON_HEIGHT    30.0
#define RATIOS_BUTTON_SPACE_X   0 * CURRENT_SCALE

#import "CameraMainViewController.h"
#import "P2PClient.h"
#import "RtspInterface.h"
#import "PAIOUnit.h"
#import "OpenGLView.h"
#import "BannerView.h"
#import "Utils.h"
#import "UDManager.h"
#import "FListManager.h"
#import "CameraListViewController.h"
#import "ContactDAO.h"
#import "WebViewController.h"
#import "PlayerAdvDetailViewController.h"

@interface CameraMainViewController ()<P2PClientDelegate,OpenGLViewDelegate,UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isReject;
@property (nonatomic, strong) OpenGLView  *remoteView;
@property (nonatomic, strong) NSArray *bannerListArray;
@property (nonatomic, strong) BannerView *bannerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *videoProgressView;
@property (nonatomic, strong) NSTimer  *progressingTimer;
@property (nonatomic, strong) UILabel  *videoProgressLabel;
@property (nonatomic, strong) UIImageView *controlView;
@property (nonatomic, strong) UIImageView *soundImageView;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *ratiosView;
@property (nonatomic, strong) UIImageView *voiceView;
@property (nonatomic, strong) UIImageView *playView;
@property (nonatomic, strong) UIImageView *advImageView;
@property (nonatomic, strong) NSDictionary *playerDic;
@property (nonatomic, assign) BOOL getVideoFirstImg;//录像时获取第一张截图做为显示
@property (nonatomic, assign) float count;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation CameraMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"摄像头";
    [self addBackItem];
    
    _count = 0;
    
    [self initUI];
    
    [self addGestures];
    
    [self getAdvRequestWithPostion:5];
    [self getAdvRequestWithPostion:9];
    
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    [[PAIOUnit sharedUnit] setSpeckState:YES];
    [[P2PClient sharedClient] setDelegate:self];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isReject = YES;
    [self connectCamera];
    [self addNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isReject = YES;
    [self.remoteView setCaptureFinishScreen:YES];
    [[P2PClient sharedClient] p2pHungUp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)connectCamera
{
    Contact *contact = [YooSeeApplication  shareApplication].contact;
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    contact = [contactDAO isContact:contact.contactId];
    if (contact)
    {
        [self setUpCallWithId:contact.contactId
                     password:contact.contactPassword
                     callType:P2PCALL_TYPE_MONITOR];
        
        self.nameLabel.text = contact.contactName;
    }
}

- (void)enterBackground
{
    if (self.navigationController.topViewController == self)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 返回
- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addScrollView];
    [self addAdvView];
    [self addPlayerView];
}

- (void)addAdvView
{
    if (_bannerView)
    {
        [_bannerView removeFromSuperview];
        _bannerView = nil;
    }
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    
    if (self.bannerListArray && [self.bannerListArray count] > 0)
    {
        if ([self.bannerListArray count] == 1)
        {
            self.bannerListArray = @[self.bannerListArray[0],self.bannerListArray[0],self.bannerListArray[0]];
        }
        if ([self.bannerListArray count] == 2)
        {
            self.bannerListArray = @[self.bannerListArray[0],self.bannerListArray[1],self.bannerListArray[0]];
        }
        for (NSDictionary *dataDic in self.bannerListArray)
        {
            NSString *imageUrl = dataDic[@"meitiurl"];
            imageUrl = imageUrl ? imageUrl : @"";
            if (imageUrl.length > 0)
            {
                [imageArray addObject:imageUrl];
            }
            
        }
    }
    
    __weak typeof(self) weakSelf = self;
    _bannerView = [[BannerView alloc] initWithFrame:CGRectMake(SPACE_X, SPACE_Y, self.view.frame.size.width - 2 * SPACE_X, ADV_HEIGHT) WithNetImages:imageArray];
    _bannerView.AutoScrollDelay = 3;
    _bannerView.placeImage = [UIImage imageNamed:@"adv_default"];
    [CommonTool clipView:_bannerView withCornerRadius:10.0];
    [_bannerView setSmartImgdidSelectAtIndex:^(NSInteger index)
     {
         NSLog(@"网络图片 %d",index);
         NSDictionary *dic = weakSelf.bannerListArray[index];
         NSString *urlString = dic[@"linkurl"];
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
    [_scrollView addSubview:_bannerView];
}


- (void)addScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, SPACE_Y + ADD_Y + ADV_HEIGHT + PLAYER_HEIGHT + 2 * ADD_Y);
    [self.view addSubview:_scrollView];
}


- (void)addPlayerView
{
    
    _playView = [CreateViewTool createImageViewWithFrame:CGRectMake(SPACE_X, SPACE_Y + ADV_HEIGHT + ADD_Y, SCREEN_WIDTH - 2 * SPACE_X, PLAYER_HEIGHT) placeholderImage:nil];
    _playView.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:_playView withCornerRadius:10.0];
    [self.scrollView addSubview:_playView];

    float space_x = PLAYER_SPACE_X;
    float label_width = NAME_LABEL_WIDTH;
    float add_x = 5.0;
    _nameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(space_x, 0, label_width, PLAYER_HEADER_HEIGHT) textString:@"无设备" textColor:DE_TEXT_COLOR textFont:FONT(16.0)];
    [_playView addSubview:_nameLabel];
    
    UIImage *image = [UIImage imageNamed:@"manage_up.png"];
    float button_wh = image.size.width/2;
    float y = (PLAYER_HEADER_HEIGHT - button_wh)/2;
    UIButton *manageButton = [CreateViewTool createButtonWithFrame:CGRectMake(_playView.frame.size.width - button_wh - space_x, y, button_wh, button_wh) buttonImage:@"manage" selectorName:@"manageButtonPressed:" tagDelegate:self];
    [_playView addSubview:manageButton];
    
    UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(manageButton.frame.origin.x - label_width - add_x, 0, label_width, PLAYER_HEADER_HEIGHT) textString:@"管理" textColor:DE_TEXT_COLOR textFont:FONT(16.0)];
    label.textAlignment = NSTextAlignmentRight;
    [_playView addSubview:label];
    
    

    [self addRemoteView];
    
    //当前观看人数
    float height = NUMBER_LABEL_HEIGHT;
    _numberLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, 0, self.remoteView.frame.size.width - SPACE_X, height) textString:@"" textColor:[UIColor whiteColor] textFont:FONT(12.0)];
    _numberLabel.textAlignment = NSTextAlignmentRight;
    [self.remoteView addSubview:_numberLabel];
    
    
    _advImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, self.remoteView.frame.size.width, self.remoteView.frame.size.height) placeholderImage:[UIImage imageNamed:@"adv_default"]];
    [self.remoteView addSubview:_advImageView];
    UIButton *button = [CreateViewTool createButtonWithFrame:_advImageView.frame buttonImage:@"" selectorName:@"platerAdvPressed" tagDelegate:self];
    [_advImageView addSubview:button];
    
    //进度
    _videoProgressView = [CreateViewTool createLabelWithFrame:CGRectMake(0, self.remoteView.frame.size.height, PROCESS_HEIGHT, self.remoteView.frame.size.height) textString:@"" textColor:nil textFont:FONT(14)];
    _videoProgressView.backgroundColor = PROCESS_COLOR;
    [self.remoteView addSubview:_videoProgressView];
    
    float lable_width = PROCESS_LABEL_WIDTH;
    float lable_height = PROCESS_LABEL_HEIGHT;
    
    _videoProgressLabel = [CreateViewTool createLabelWithFrame:CGRectMake(PROCESS_HEIGHT, 0, lable_width, lable_height) textString:@"" textColor:PROCESS_COLOR textFont:FONT(10.0)];
    _videoProgressLabel.textAlignment = NSTextAlignmentCenter;
    [self.remoteView addSubview:self.videoProgressLabel];
    
    //控制按钮
    y = self.remoteView.frame.origin.y + self.remoteView.frame.size.height;
    _controlView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, y, _playView.frame.size.width, _playView.frame.size.height - y) placeholderImage:nil];
    _controlView.userInteractionEnabled = NO;
    [_playView addSubview:_controlView];
    
    y = PLAYER_SPACE_Y;
    float speak_WH = SPAKER_BUTTON_WH;
    float x = (_controlView.frame.size.width - speak_WH)/2;
    
    UIButton *speakButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, speak_WH, speak_WH) buttonImage:@"icon_speak" selectorName:@"speakButtonPressed:" tagDelegate:self];
    [_controlView addSubview:speakButton];
    
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(speakButtonLongPressed:)];
    longPressGesture.minimumPressDuration = 0.5;
    [speakButton addGestureRecognizer:longPressGesture];
    
    
    UIImage *iconImage = [UIImage imageNamed:@"icon_sound_on"];
    float icon_W = image.size.width/3 * CURRENT_SCALE;
    float icon_H = image.size.height/3 * CURRENT_SCALE;
    _soundImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x - icon_W, y, icon_W, icon_H) placeholderImage:iconImage];
    [_controlView addSubview:_soundImageView];
    

    
    
    lable_height = TIPLABEL_HEIGHT;
    UILabel *tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y + speakButton.frame.size.height, _controlView.frame.size.width, lable_height) textString:@"点按静音，长按对讲" textColor:DE_TEXT_COLOR textFont:FONT(12.0)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [_controlView addSubview:tipLabel];
    
    float buton_WH = PHOTO_AV_BUTTON_WH;
    y += (speak_WH - buton_WH)/2;
    x = BUTTON_SPACE_X;

    UIButton *photosButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, buton_WH, buton_WH) buttonImage:@"icon_photos" selectorName:@"photosButtonPressed:" tagDelegate:self];
    [_controlView addSubview:photosButton];
    
    x = _controlView.frame.size.width - BUTTON_SPACE_X - buton_WH;
    UIButton *avButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, buton_WH, buton_WH) buttonImage:@"icon_av" selectorName:@"avButtonPressed:" tagDelegate:self];
    [_controlView addSubview:avButton];
    
    //添加码流
    [self createRatiosViewWithArray:@[@"高清",@"标清",@"流畅"]];
}

- (void)addRemoteView
{
    if (!_remoteView)
    {
        //视频播放视图
        OpenGLView *glView = [[OpenGLView alloc] init];
        CGFloat scale;
        BOOL is16B9 = [[P2PClient sharedClient] is16B9];
        if(is16B9){
            scale = 9.0 / 16.0; // 16 : 9
        }else{
            scale = 3.0 / 4.0; // 4 : 3
        }
        [glView setFrame:CGRectMake(0, PLAYER_HEADER_HEIGHT, _playView.frame.size.width, REMOTEVIEW_HEIGHT)];
        //_orientationRect = [glView frame];
        _remoteView = glView;
        _remoteView.delegate = self;
        [_remoteView.layer setMasksToBounds:YES];
        _remoteView.backgroundColor = [UIColor blackColor];
        self.remoteView.clipsToBounds = YES;
        self.originalFrame = _remoteView.frame;
    }
    
    [self.playView addSubview:_remoteView];
}

- (void)createRatiosViewWithArray:(NSArray *)array
{
    if (!array || [array count] == 0)
    {
        return;
    }
    float button_height = RATIOS_BUTTON_HEIGHT;
    if (!_ratiosView)
    {
        float x = self.remoteView.frame.size.width - RATIOS_BUTTON_WIDTH - RATIOS_BUTTON_SPACE_X;
        float height = button_height * [array count];
        float y = (self.remoteView.frame.size.height - height)/2;
        
        _ratiosView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, RATIOS_BUTTON_WIDTH, height) placeholderImage:nil];
        _ratiosView.backgroundColor = RGBA(0.0, 0.0, 0.0, .6);
        [self.remoteView addSubview:_ratiosView];
        
        float width = _ratiosView.frame.size.width;
        
        for (int i = 0; i < [array count]; i++)
        {
            NSString *title = array[i];
            
            if (title.length > 0)
            {
                UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(0, i * button_height, width, button_height) buttonTitle:array[i] titleColor:[UIColor whiteColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:[UIColor clearColor] selectorName:@"ratiosButtonPressed:" tagDelegate:self];
                button.titleLabel.font = FONT(12.0);
                button.showsTouchWhenHighlighted = YES;
                button.tag = i + 100;
                [button setTitleColor:APP_MAIN_COLOR forState:UIControlStateSelected];
                [_ratiosView addSubview:button];
                
                if (i > 0)
                {
                    UIImageView *lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, button.frame.origin.y - 1.0, button.frame.size.width, 1.0) placeholderImage:nil];
                    lineImageView.backgroundColor = RGBA(255, 255, 255, .7);
                    [_ratiosView addSubview:lineImageView];
                }

                if (i == 2)
                {
                    button.selected = YES;
                }
            }
        }
    }
    _ratiosView.hidden = YES;
}


#pragma mark - 视频加载进度条
- (void)playVideoProgressView
{
    [self.progressingTimer invalidate];
    _progressingTimer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(videoProgressViewProgressing) userInfo:nil repeats:YES];
}

- (void)videoProgressViewProgressing
{
    CGRect frame = self.videoProgressView.frame;
    frame.origin.y -= (0.01 * self.remoteView.frame.size.height);
    self.videoProgressView.frame = frame;
    _count += 0.01;
    self.videoProgressLabel.text = [NSString stringWithFormat:@"%d％", (int)(_count * 100)];
    if (_count >= 0.99)
    {
        _count = 0;
        [self.progressingTimer invalidate];
    }
}


#pragma mark 添加手势
- (void)addGestures
{
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeGestureUp setCancelsTouchesInView:YES];
    [swipeGestureUp setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureUp];
    
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [swipeGestureDown setCancelsTouchesInView:YES];
    [swipeGestureDown setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureDown];
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGestureLeft setCancelsTouchesInView:YES];
    [swipeGestureLeft setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeGestureRight setCancelsTouchesInView:YES];
    [swipeGestureRight setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureRight];
}

#pragma mark 手势控制摄像头
- (void)swipeUp:(id)sender
{
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_DOWN];
}

- (void)swipeDown:(id)sender
{
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_UP];
}

- (void)swipeLeft:(id)sender
{
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_LEFT];
}

- (void)swipeRight:(id)sender
{
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_RIGHT];
}

#pragma mark 添加通知
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlayingCommand:) name:RECEIVE_PLAYING_CMD object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PClientRejectHandler:) name:@"P2PClientReject" object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:@"EnterBackground" object:nil];
}



#pragma mark 接收到播放命令
- (void)receivePlayingCommand:(NSNotification *)notification
{
    NSDictionary *parameter = [notification userInfo];
    int value  = [[parameter valueForKey:@"value"] intValue];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        weakSelf.numberLabel.text = [NSString stringWithFormat:@"当前观看人数:%i人",value];
    });
}


#pragma mark 设备方位变化
- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification
{
    UIDevice *device = (UIDevice *)[notification object];
    if (self.isReject)
    {
        return;
    }
    if (self.remoteView)
    {
        CGRect frame;
        float angel = 0;
        if (device.orientation == UIDeviceOrientationLandscapeRight || device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationPortrait)
        {
            self.remoteView.transform = CGAffineTransformIdentity;
            if (device.orientation == UIDeviceOrientationPortrait)
            {
                angel = 0;
                frame = self.originalFrame;
            }
            if (device.orientation == UIDeviceOrientationLandscapeRight || device.orientation == UIDeviceOrientationLandscapeLeft)
            {
                frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                if ([SYSTEM_VERSION floatValue] < 8.0)
                {
                    frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
                }
                angel = device.orientation == UIDeviceOrientationLandscapeRight ? - M_PI_2 : M_PI_2;
            }
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:.35 animations:^
             {
                 weakSelf.remoteView.transform = CGAffineTransformMakeRotation(angel);
                 weakSelf.remoteView.frame = frame;
                 [[UIApplication sharedApplication] setStatusBarHidden:!(angel == 0) withAnimation:UIStatusBarAnimationFade];
                 if (angel == 0)
                 {
                     [weakSelf.playView addSubview:weakSelf.remoteView];
                 }
                 else
                 {
                     [[DELEGATE window] addSubview:weakSelf.remoteView];
                 }
                 weakSelf.numberLabel.frame = CGRectMake(0, 0, ((angel == 0) ? frame.size.width : frame.size.height) - SPACE_X, NUMBER_LABEL_HEIGHT) ;
                 float x = ((angel == 0) ? frame.size.width : frame.size.height) - RATIOS_BUTTON_WIDTH - RATIOS_BUTTON_SPACE_X;
                 float height = RATIOS_BUTTON_HEIGHT * 3;
                 float y = (((angel == 0) ? frame.size.height : frame.size.width) - height)/2;
                 weakSelf.ratiosView.frame = CGRectMake(x, y, RATIOS_BUTTON_WIDTH, height);
                 
             }];
        }
    }
    
}

#pragma mark 点击播放器广告
- (void)platerAdvPressed
{
    NSString *title = self.playerDic[@"title"];
    title = title ? title : @"";
    NSString *url = self.playerDic[@"linkurl"];
    url = url ? url : @"";
    PlayerAdvDetailViewController *playerAdvDetailViewController = [[PlayerAdvDetailViewController alloc] init];
    playerAdvDetailViewController.urlString = url;
    playerAdvDetailViewController.title = title;
    [self.navigationController pushViewController:playerAdvDetailViewController animated:YES];
}

#pragma mark 获取广告
//postion 5 家生活 9视频广告
- (void)getAdvRequestWithPostion:(int)postion
{
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid":uid,@"pos":@(postion)};
    [[RequestTool alloc] desRequestWithUrl:GET_ADV_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_ADV_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             //[weakSelf setDataWithDictionary:dataDic];
             if (postion == 5)
             {
                 weakSelf.bannerListArray = dataDic[@"body"];
                 [weakSelf addAdvView];
             }
             else if (postion == 9)
             {
                 NSArray *array = dataDic[@"body"];
                 NSDictionary *dic = array[0];
                 NSString *imageUrl = dic[@"meitiurl"];
                 imageUrl = imageUrl ? imageUrl : @"";
                 weakSelf.playerDic = array[0];
                 [weakSelf.advImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"adv_default"]];
             }

         }
         else
         {
             //[SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"GET_ADV_URL====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}


#pragma mark 码流
- (void)ratiosButtonPressed:(UIButton *)sender
{
    sender.selected = YES;
    for (UIView *view in self.ratiosView.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            if (view.tag != sender.tag)
            {
                ((UIButton *)view).selected = NO;
            }
            
        }
    }
    NSArray *ratiosArray = @[@(7),@(5),@(6)];
    [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:[ratiosArray[sender.tag - 100] intValue]];
    
}

#pragma mark 截图
- (void)photosButtonPressed:(UIButton *)sender
{
     [self.remoteView setIsScreenShotting:YES];
}

-(void)onScreenShotted:(UIImage *)image{
    UIImage *tempImage = [[UIImage alloc] initWithCGImage:image.CGImage];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(tempImage)];
    [self saveScreenshotFileWithId:loginResult.contactId data:imgData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!_getVideoFirstImg)
            //[self.view makeToast:NSLocalizedString(@"screenshot_success", nil)];
            [SVProgressHUD showSuccessWithStatus:@"截图成功"];
        else
            _getVideoFirstImg = NO;
    });
    
}
- (void)saveScreenshotFileWithId:(NSString*)contactId data:(NSData*)data{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    long timeInterval = [Utils getCurrentTimeInterval];
    NSString *savePath = nil;
    if(_getVideoFirstImg)
    {
        savePath = [NSString stringWithFormat:@"%@/videorecord/%@",rootPath,contactId];
        
    }
    else
        savePath = [NSString stringWithFormat:@"%@/screenshot/%@",rootPath,contactId];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:savePath]){
        [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filepath = nil;
    if(_getVideoFirstImg)
    {
        P2PClient *client = [P2PClient sharedClient];
        //如果已经创建了视频文件名，使用该名字作为图片的名称
        if(client.recordFileName == nil)
            client.recordFileName = [NSString stringWithFormat:@"%@/%@_%d.mp4",savePath,self.nameLabel.text,(int)timeInterval];
        filepath = [client.recordFileName stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"];
    }
    else
    {
        filepath = [NSString stringWithFormat:@"%@/%@_%d.png",savePath,self.nameLabel.text,(int)timeInterval];
    }
    
    [data writeToFile:filepath atomically:YES];
    
}

#pragma mark 声音
- (void)speakButtonPressed:(UIButton *)sender
{
    static BOOL isMuteAudio = NO;
    if (isMuteAudio == YES)
    {
        [[PAIOUnit sharedUnit] setMuteAudio:NO];
        isMuteAudio = NO;
        [self.soundImageView setImage:[UIImage imageNamed:@"icon_sound_on.png"]];
    }
    else
    {
        [[PAIOUnit sharedUnit] setMuteAudio:YES];
        isMuteAudio = YES;
        [self.soundImageView setImage:[UIImage imageNamed:@"icon_sound_off.png"]];
    }
}

- (void)speakButtonLongPressed:(UILongPressGestureRecognizer *)gesture
{
    BOOL isMuteSpeak = YES;
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        isMuteSpeak = NO;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        isMuteSpeak = YES;
    }
    [[PAIOUnit sharedUnit] setSpeckState:isMuteSpeak];
}

#pragma mark 录制
- (void)avButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    P2PClient *client = [P2PClient sharedClient];
    client.startRecord = !client.startRecord;
    //isRecording = !isRecording;
    if(client.startRecord)
    {
        [SVProgressHUD showSuccessWithStatus:@"开始录像" duration:1.5];
        _getVideoFirstImg = YES;
        [self.remoteView setIsScreenShotting:YES];
        
        [client createRecordFile];
        
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"结束录像" duration:1.5];
        [client stopRecord];
    }

}

#pragma mark 管理
- (void)manageButtonPressed:(UIButton *)sender
{
    CameraListViewController *cameraListViewController = [[CameraListViewController alloc] init];
    [self.navigationController pushViewController:cameraListViewController animated:YES];
}

#pragma mark - 进入呼叫设备界面1
-(void)setUpCallWithId:(NSString *)contactId password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];
    
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_CALLING];
   
    
    //rtsp监控界面弹出修改
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO)
    {
        if(!self.presentedViewController)
        {
            
//            P2PCallController *p2pCallController = [[P2PCallController alloc] init];
//            p2pCallController.contactName = self.contactName;
//            
//            AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
//            [self presentViewController:controller animated:YES completion:^{
//                
//            }];
        }
        
    }
    else
    {
        [self playVideoProgressView];
        [[P2PClient sharedClient] p2pCallWithId:contactId password:password callType:type];
    }
}


-(void)P2PClientCalling:(NSDictionary*)info
{
//    DLog(@"P2PClientCalling");
//    BOOL isBCalled = [[P2PClient sharedClient] isBCalled];
//    NSString *callId = [[P2PClient sharedClient] callId];
//    if(isBCalled){
//        if([[AppDelegate sharedDefault] isGoBack]){
//            UILocalNotification *alarmNotify = [[[UILocalNotification alloc] init] autorelease];
//            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
//            alarmNotify.soundName = @"default";
//            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:Calling!",callId];
//            alarmNotify.applicationIconBadgeNumber = 1;
//            alarmNotify.alertAction = NSLocalizedString(@"open", nil);
//            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
//            return;
//        }
//        
//        if(!self.isShowP2PView){
//            self.isShowP2PView = YES;
//            UIViewController *presentView1 = self.presentedViewController;
//            UIViewController *presentView2 = self.presentedViewController.presentedViewController;
//            if(presentView2){
//                [self dismissViewControllerAnimated:YES completion:^{
//                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
//                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
//                    
//                    [self presentViewController:controller animated:YES completion:^{
//                        
//                    }];
//                    
//                    [p2pCallController release];
//                    [controller release];
//                }];
//            }else if(presentView1){
////                [presentView1 dismissViewControllerAnimated:YES completion:^{
////                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
////                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
////                    
////                    [self presentViewController:controller animated:YES completion:^{
////                        
////                    }];
////                    
////                    [p2pCallController release];
////                    [controller release];
//                }];
//            }else{
////                P2PCallController *p2pCallController = [[P2PCallController alloc] init];
////                AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
////                
////                [self presentViewController:controller animated:YES completion:^{
////                    
////                }];
////                
////                [p2pCallController release];
////                [controller release];
//            }
//            
//            
//        }
//        
//    }
}


#pragma mark - 挂断监控设备回调
-(void)P2PClientReject:(NSDictionary*)info{
    DLog("P2PClientReject");
    
    self.isReject = YES;
    __weak typeof(self) weakSelf = self;
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_NONE];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        usleep(1000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            int errorFlag = [[info objectForKey:@"errorFlag"] intValue];
            NSArray *array = @[@"未知原因",@"对方ID已过期",@"对方ID被禁用",@"对方ID未激活",@"设备离线",@"设备繁忙",@"对方关机",@"连接失败",@"挂断",@"连接超时",@"内部错误",@"无人接听",@"设备密码错误",@"连接失败",@"设备不支持"];
            
            NSString *message = @"";
            if (errorFlag >= [array count])
            {
                message = @"未知原因";
            }
            else
            {
                message = array[errorFlag];
            }
            [CommonTool addPopTipWithMessage:message];
            [weakSelf clientRejectWithErrorCode:errorFlag];
        });
    });
    
    
    
    
}


-(void)P2PClientAccept:(NSDictionary*)info{
    DLog(@"P2PClientAccept");
}

#pragma mark - 连接设备就绪
-(void)P2PClientReady:(NSDictionary*)info{
    DLog(@"P2PClientReady");
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_READY];
    
    if([[P2PClient sharedClient] p2pCallType] == P2PCALL_TYPE_MONITOR){
        //rtsp监控界面弹出修改
        /*
         * 监控连接已经准备就绪，发送监控开始渲染通知
         * 在监控界面上，接收通知，并开始渲染监控画面
         */
//        [[NSNotificationCenter defaultCenter] postNotificationName:MONITOR_START_RENDER_MESSAGE
//                                                            object:self
//                                                          userInfo:NULL];
        //
        [self connectDeviceSuccess];
    }
    else if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO)
    {
//        P2PVideoController *videoController = [[P2PVideoController alloc] init];
//        if (self.presentedViewController) {
//            [self.presentedViewController presentViewController:videoController animated:YES completion:nil];
//        }else{
//            [self presentViewController:videoController animated:YES completion:nil];
//        }
//        
//        [videoController release];
    }
    
    
}


//连接摄像头成功，开始播放视频
- (void)connectDeviceSuccess
{
    //默认流畅
    [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:6];
    //[self updateRightButtonState:CONTROLLER_BTN_TAG_LD];
    
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    
    [_progressingTimer invalidate];
    _progressingTimer = nil;
    _videoProgressLabel.hidden = YES;
    _videoProgressView.hidden = YES;
    _advImageView.hidden = YES;
    
     _ratiosView.hidden = NO;
    _controlView.userInteractionEnabled = YES;
    [NSThread detachNewThreadSelector:@selector(renderView) toTarget:self withObject:nil];
    self.isReject = NO;
}

- (void)renderView
{
    
    GAVFrame * m_pAVFrame ;
    //    [_remoteView setInitialized:YES];
    while (!self.isReject)
    {
        if(fgGetVideoFrameToDisplay(&m_pAVFrame))
        {
            NSLog(@"=========!!!!!!!!!!!!");
            [self.remoteView render:m_pAVFrame];
            
            //NSLog(@"接收视频帧！");
            vReleaseVideoFrame();
        }
        usleep(10000);
    }
}


#pragma mark 连接拒绝
- (void)clientRejectWithErrorCode:(int)errorCode
{
    [_progressingTimer invalidate];
    _progressingTimer = nil;
    _videoProgressLabel.hidden = YES;
    _videoProgressView.hidden = YES;
    _controlView.userInteractionEnabled = NO;
    [[P2PClient sharedClient] p2pHungUp];
    if (errorCode == CALL_ERROR_PW_WRONG)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedPassword" object:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (self.progressingTimer)
    {
        [self.progressingTimer invalidate];
        self.progressingTimer = nil;
    }
    self.remoteView.delegate = nil;
    self.remoteView = nil;
    
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
