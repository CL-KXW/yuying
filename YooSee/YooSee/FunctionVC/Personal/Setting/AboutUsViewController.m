//
//  AboutUsViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_Y         30.0 * CURRENT_SCALE
#define BOTTOM_SPACE_Y  20.0 * CURRENT_SCALE
#define LABEL_HEIGHT    25.0 * CURRENT_SCALE
#define ADD_Y           10.0
#define SELECT_COLOR    RGB(251.0,80.0,36.0)


#import "AboutUsViewController.h"
#import "RegistRulesViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于";
    [self addBackItem];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addAppInfoView];
    [self addCompanyInfoView];
}

- (void)addAppInfoView
{
    UIImage *iconImage = [UIImage imageNamed:@"big_icon"];
    float icon_wh = iconImage.size.width/3 * CURRENT_SCALE;
    float y = SPACE_Y + START_HEIGHT;
    
    UIImageView *iconImageView = [CreateViewTool createImageViewWithFrame:CGRectMake((self.view.frame.size.width - icon_wh)/2, y, icon_wh, icon_wh) placeholderImage:iconImage];
    [self.view addSubview:iconImageView];
    
    y += iconImageView.frame.size.height + ADD_Y;
    
    UILabel *appNameLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, self.view.frame.size.width, LABEL_HEIGHT) textString:@"鱼鹰" textColor:SELECT_COLOR textFont:BOLD_FONT(17.0)];
    appNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:appNameLabel];
    
    y += appNameLabel.frame.size.height;
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDict[@"CFBundleShortVersionString"];
    UILabel *versionLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, self.view.frame.size.width, LABEL_HEIGHT) textString:[@"版本号: " stringByAppendingString:version] textColor:DE_TEXT_COLOR textFont:FONT(15.0)];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
}

- (void)addCompanyInfoView
{
    float y = self.view.frame.size.height - BOTTOM_SPACE_Y - LABEL_HEIGHT;
    NSArray *array = @[@"湖南映山红科技有限公司 版权所有",@"鱼鹰热线: 400-0731-611",@"客服电话: 0731-89875328",@"《鱼鹰应用使用条款及隐私规则》"];
    for (int i = 0; i < [array count]; i++)
    {
        UILabel *label = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, self.view.frame.size.width, LABEL_HEIGHT) textString:array[i] textColor:DE_TEXT_COLOR textFont:FONT(15.0)];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        if (i == 0)
        {
            label.textColor = MAIN_TEXT_COLOR;
        }
        if (i == 3)
        {
            label.textColor = SELECT_COLOR;
        }
        
        if (i != 0)
        {
            CGSize size = [label.text sizeWithFont:FONT(15.0)];
            UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake((label.frame.size.width - size.width)/2, y, size.width, label.frame.size.height) buttonImage:@"" selectorName:@"buttonPressed:" tagDelegate:self];
            button.tag = 100 + i;
            [self.view addSubview:button];
        }
        
        y -= label.frame.size.height;
    }
}

#pragma mark 点击事件
- (void)buttonPressed:(UIButton *)sender
{
    int tag = (int)sender.tag - 100;
    if (tag == 3)
    {
        RegistRulesViewController *registRulesViewController = [[RegistRulesViewController alloc] init];
        [self.navigationController pushViewController:registRulesViewController animated:YES];
    }
    if (tag == 1 || tag == 2)
    {
        [self makeCallWithNumber:tag == 1 ? @"400-0731-611" : @"0731-89875328"];
    }
}

#pragma mark 打电话
- (void)makeCallWithNumber:(NSString *)number
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",number]];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        //设备不支持
        [CommonTool addPopTipWithMessage:@"设备不支持"];
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
