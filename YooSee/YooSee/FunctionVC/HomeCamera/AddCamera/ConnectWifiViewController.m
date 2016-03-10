//
//  ConnectWifiViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/25.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X             10.0
#define SPACE_Y             15.0

#define VIEW_HEIGHT         480.0 * CURRENT_SCALE
#define VIEW_SPACE_Y        30.0 * CURRENT_SCALE
#define VIEW_SPACE_X        20.0 * CURRENT_SCALE
#define VIEW_ADD_Y          20.0 * CURRENT_SCALE
#define LABEL_HEIGHT        50.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2


#define ERROR_TIME          60

#define TIP_NORMAL          @"是否听到 “叮” 的一声？"
#define TIP_ERROR           @"WIFI密码输入错误\n或当前网络环境较差"

#define TITLE_NORMAL        @"正在加入网络"
#define TITLE_ERROR         @"加入网络失败"

#define BUTTON_NORMAL       @"听到了"
#define BUTTON_ERROR        @"返回，重新连接"


#import "ConnectWifiViewController.h"
#import "smtiot.h"
#import "SerachCameraViewController.h"

@interface ConnectWifiViewController ()

@property (nonatomic, strong) UIImageView *scanImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int count;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation ConnectWifiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"摄像头链接网络";
    [self addBackItem];
    
    [self initUI];
    [self startScanningAnimation];
    
    _count = 0;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //丢包连接摄像头
    InitSmartConnection();
    //发包
    [self sendBag];
    [self createTimer];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelTimer];
    StopSmartConnection();
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
    _titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:TITLE_NORMAL textColor:MAIN_TEXT_COLOR textFont:FONT(20.0)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_titleLabel];
    
    y += _titleLabel.frame.size.height + 2 * VIEW_ADD_Y;
    UIImage *image = [UIImage imageNamed:@"camera_link_on1"];
    float width = image.size.width/2.0;
    float height = image.size.height/2.0;
    x = (bgView.frame.size.width - width)/2;
    _scanImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, height) placeholderImage:image];
    [bgView addSubview:_scanImageView];
    
    y += _scanImageView.frame.size.height + 2 * VIEW_ADD_Y;
    _tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, bgView.frame.size.width, LABEL_HEIGHT) textString:TIP_NORMAL textColor:DE_TEXT_COLOR textFont:FONT(17.0)];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_tipLabel];
    
    y += _tipLabel.frame.size.height + 2 * VIEW_ADD_Y;
    _nextButton = [CreateViewTool createButtonWithFrame:CGRectMake(VIEW_SPACE_X, y, bgView.frame.size.width - 2 * VIEW_SPACE_X, BUTTON_HEIGHT) buttonTitle:BUTTON_NORMAL titleColor:[UIColor whiteColor] normalBackgroundColor:APP_MAIN_COLOR highlightedBackgroundColor:nil selectorName:@"nextButtonPressed:" tagDelegate:self];
    [CommonTool clipView:_nextButton withCornerRadius:BUTTON_RADIUS];
    [bgView addSubview:_nextButton];
}


#pragma mark 开始动画
- (void)startScanningAnimation
{
    self.scanImageView.animationImages =
    @[[UIImage imageNamed:@"camera_link_on1"],[UIImage imageNamed:@"camera_link_on2"]];
    self.scanImageView.animationDuration = 0.5;
    [self.scanImageView startAnimating];
}


#pragma mark 发包
//发包
-(void)sendBag
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /*!
         *  当 self.ssidString 包含中文的时候， ssid = nil，
         *  1. const char *SSID 参数是否允许 [self.ssidString UTF8String] 这样的形式 ?
         *  2. const char *SSID 参数是否允许包含中文 ?
         */
        const char *ssid = [weakSelf.wifiName cStringUsingEncoding:NSASCIIStringEncoding];
        const char *password = [weakSelf.password cStringUsingEncoding:NSASCIIStringEncoding];
        if (!ssid)
        {
            ssid = [weakSelf.wifiName UTF8String];
        }
        StartSmartConnection(ssid, password, NULL, 0, "", 2);
        usleep(1000000);
    });
}

#pragma mark 定时器
- (void)createTimer
{
    [self cancelTimer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(addCount) userInfo:nil repeats:YES];
    
}

- (void)cancelTimer
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}


- (void)addCount
{
    _count++;
    
    if (_count >= ERROR_TIME)
    {
        [self cancelTimer];
        [self changeStatus:0];
        return;
    }
    
    if (_count%10 == 0)
    {
        [self sendBag];
    }
}


#pragma mark 设置状态
- (void)changeStatus:(BOOL)status
{
    self.titleLabel.text = (status) ? TITLE_NORMAL : TIP_ERROR;
    self.titleLabel.textColor = (status) ? MAIN_TEXT_COLOR : [UIColor redColor];
    
    [_nextButton setTitle:(status) ? BUTTON_NORMAL : BUTTON_ERROR forState:UIControlStateNormal];
    [_nextButton setBackgroundImage:[CommonTool imageWithColor:(status) ? APP_MAIN_COLOR : [UIColor clearColor]] forState:UIControlStateNormal];

    if (!status)
    {
        StopSmartConnection();
        [self.scanImageView stopAnimating];
        self.scanImageView.image = [UIImage imageNamed:@"camera_link_off"];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:TIP_ERROR];
        [CommonTool makeString:TIP_ERROR toAttributeString:string withString:TIP_ERROR withLineSpacing:5.0];
        self.tipLabel.attributedText = string;
        self.tipLabel.numberOfLines = 2;
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        
        [_nextButton setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
        [CommonTool setViewLayer:_nextButton withLayerColor:[UIColor grayColor] bordWidth:1.0];

    }
    else
    {
        self.tipLabel.attributedText = nil;
        self.tipLabel.text = TIP_NORMAL;
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [CommonTool setViewLayer:_nextButton withLayerColor:[UIColor clearColor] bordWidth:0];
        
        self.count = 0;
        [self createTimer];
        [self startScanningAnimation];
        InitSmartConnection();
        [self sendBag];
    }
}


#pragma mark 点击听到了
- (void)nextButtonPressed:(UIButton *)sender
{
    if (self.count == ERROR_TIME)
    {
        [self changeStatus:YES];
        return;
    }
    else
    {
        SerachCameraViewController *serachCameraViewController = [[SerachCameraViewController alloc] init];
        [self.navigationController pushViewController:serachCameraViewController animated:YES];
    }
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
