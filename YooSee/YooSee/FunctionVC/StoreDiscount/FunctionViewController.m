//
//  FunctionViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/4/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y         50.0 * CURRENT_SCALE
#define ADD_Y           20.0 * CURRENT_SCALE
#define LABLE_HEIGHT    30.0 * CURRENT_SCALE

#import "FunctionViewController.h"

@interface FunctionViewController ()

@end

@implementation FunctionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"功能开发中";
    [self addBackItem];
    
    [self initUI];
    // Do any additional setup after loading the view.
}


#pragma mark 初始化UI
- (void)initUI
{
    UIImage *image = [UIImage imageNamed:@"img_info_cry"];
    float width = image.size.width/2 * CURRENT_SCALE;
    float height = image.size.height/2 * CURRENT_SCALE;
    float x = (self.view.frame.size.width - width)/2;
    float y = SPACE_Y + START_HEIGHT;
    UIImageView *imageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, height) placeholderImage:image];
    [self.view addSubview:imageView];
    
    x = 0.0;
    y += imageView.frame.size.height + ADD_Y;
    UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(x, y, self.view.frame.size.width, LABLE_HEIGHT) textString:@"程序员小哥正在加班开发中..." textColor:MAIN_TEXT_COLOR textFont:FONT(15.0)];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
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
