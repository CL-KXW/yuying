//
//  SettingCameraBasicViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/12.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y         25.0 * CURRENT_SCALE
#define LABEL_HEIGHT    30.0 * CURRENT_SCALE
#define IMAGEVIEW_WH    100.0 * CURRENT_SCALE
#define SECTION_HEIGHT  LABEL_HEIGHT + IMAGEVIEW_WH + SPACE_Y

#import "SettingCameraBasicViewController.h"


@interface SettingCameraBasicViewController ()

@end

@implementation SettingCameraBasicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackItem];
    
    [self initUI];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 初始化UI
- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *headerView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, START_HEIGHT, self.view.frame.size.width, SECTION_HEIGHT) placeholderImage:nil];
    headerView.backgroundColor = [UIColor whiteColor];
    
    float y = SPACE_Y;
    UIImageView *iconImageView = [CreateViewTool createRoundImageViewWithFrame:CGRectMake((headerView.frame.size.width - IMAGEVIEW_WH)/2, y, IMAGEVIEW_WH, IMAGEVIEW_WH) placeholderImage:[UIImage imageNamed:@"camera_icon_default"] borderColor:DE_TEXT_COLOR imageUrl:self.imageUrl];
    [iconImageView setImageURL:self.imageUrl];
    [headerView addSubview:iconImageView];
    
    y += iconImageView.frame.size.height;
    
    UILabel *nameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, headerView.frame.size.width, LABEL_HEIGHT) textString:@"" textColor:DE_TEXT_COLOR textFont:FONT(16)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = self.contact.contactName;
    [headerView addSubview:nameLabel];
    
    [self.view addSubview:headerView];
    
    start_y = headerView.frame.size.height + headerView.frame.origin.y;
}

#pragma mark 通知
- (void)receiveRemoteMessage:(NSNotification *)notificaiton
{
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notificaiton
{
    
}

#pragma mark 密码错误
- (void)passwordError
{
    [CommonTool addPopTipWithMessage:@"设备密码错误"];
    [self.navigationController popViewControllerAnimated:YES];
    
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
