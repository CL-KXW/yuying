//
//  AddCameraFailViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/27.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X             10.0
#define SPACE_Y             15.0

#define VIEW_HEIGHT         480.0 * CURRENT_SCALE
#define VIEW_SPACE_Y        60.0 * CURRENT_SCALE
#define VIEW_BT_SPACE_Y     50.0 * CURRENT_SCALE
#define VIEW_SPACE_X        20.0 * CURRENT_SCALE
#define VIEW_ADD_Y          20.0 * CURRENT_SCALE
#define LABEL_HEIGHT        35.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2

#import "AddCameraFailViewController.h"


@interface AddCameraFailViewController ()

@end

@implementation AddCameraFailViewController

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
    UILabel *tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:@"添加摄像头失败" textColor:[UIColor redColor] textFont:FONT(24.0)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:tipLabel];
    
    y += tipLabel.frame.size.height;
    
    UILabel *errorLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, bgView.frame.size.width, LABEL_HEIGHT) textString:self.errorString textColor:DE_TEXT_COLOR textFont:FONT(20.0)];
    errorLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:errorLabel];
    
    y = bgView.frame.size.height - VIEW_BT_SPACE_Y - BUTTON_HEIGHT;
    x = VIEW_SPACE_X;
    UIButton *retryButton = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, bgView.frame.size.width - 2 * x, BUTTON_HEIGHT) buttonTitle:@"返回，重新添加" titleColor:[UIColor grayColor] normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:nil selectorName:@"retryButtonPressed:" tagDelegate:self];
    [retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CommonTool clipView:retryButton withCornerRadius:BUTTON_RADIUS];
    [CommonTool setViewLayer:retryButton withLayerColor:[UIColor grayColor] bordWidth:1.0];
    [bgView addSubview:retryButton];
    
}

#pragma mark 重试按钮
- (void)retryButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
