//
//  AddCameraSucessViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/27.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X             10.0
#define SPACE_Y             15.0

#define VIEW_HEIGHT         480.0 * CURRENT_SCALE
#define VIEW_SPACE_Y        60.0 * CURRENT_SCALE
#define VIEW_SPACE_X        20.0 * CURRENT_SCALE
#define VIEW_ADD_Y          20.0 * CURRENT_SCALE
#define LABEL_HEIGHT        50.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "AddCameraSucessViewController.h"
#import "SetCameraInfoViewController.h"
#import "CameraMainViewController.h"
#import "ContactDAO.h"

@interface AddCameraSucessViewController ()

@end

@implementation AddCameraSucessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"添加摄像头";
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
    UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:@"添加摄像头成功" textColor:APP_MAIN_COLOR textFont:FONT(24.0)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:titleLabel];
    
    y += titleLabel.frame.size.height + 2 * VIEW_ADD_Y;
    UIImage *image = [UIImage imageNamed:@"camera_see_up"];
    float button_wh = image.size.width/2;
    x = (bgView.frame.size.width - button_wh)/2;
    UIButton *playButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, button_wh, button_wh) buttonImage:@"camera_see" selectorName:@"playButtonPressed:" tagDelegate:self];
    [bgView addSubview:playButton];
    
    y += playButton.frame.size.height  + 3 * VIEW_ADD_Y;
    
    UILabel *tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, bgView.frame.size.width, LABEL_HEIGHT) textString:@"" textColor:DE_TEXT_COLOR textFont:FONT(17.0)];
    tipLabel.numberOfLines = 2.0;
    NSString *text = @"您可以备注摄像头名称,\n添加封面图片.";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [CommonTool makeString:text toAttributeString:string withString:text withLineSpacing:5.0];
    tipLabel.attributedText = string;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:tipLabel];
    
    y += tipLabel.frame.size.height  + 2 * VIEW_ADD_Y;
    x = VIEW_SPACE_X;
    UIButton *infoButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, bgView.frame.size.width - 2 * x, BUTTON_HEIGHT) buttonTitle:@"完善更多信息" titleColor:[UIColor grayColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:nil selectorName:@"infoButtonPressed:" tagDelegate:self];
    [infoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CommonTool clipView:infoButton withCornerRadius:BUTTON_RADIUS];
    [CommonTool setViewLayer:infoButton withLayerColor:[UIColor grayColor] bordWidth:1.0];
    [bgView addSubview:infoButton];
    
    
}


#pragma mark 播放
- (void)playButtonPressed:(UIButton *)sender
{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:self.deviceID];
    [YooSeeApplication shareApplication].contact = contact;
    CameraMainViewController *cameraMainViewController = [[CameraMainViewController alloc] init];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array replaceObjectAtIndex:1 withObject:cameraMainViewController];
    self.navigationController.viewControllers = array;
    [self.navigationController popToViewController:cameraMainViewController animated:YES];
}


#pragma mark 设置信息
- (void)infoButtonPressed:(UIButton *)sender
{
    SetCameraInfoViewController *setCameraInfoViewController = [[SetCameraInfoViewController alloc] init];
    setCameraInfoViewController.deviceID = self.deviceID;
    [self.navigationController pushViewController:setCameraInfoViewController animated:YES];
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
