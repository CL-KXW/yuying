//
//  HabbitsViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/4/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X             25.0 * CURRENT_SCALE
#define ADD_Y               20.0 * CURRENT_SCALE
#define BUTTON_HEIGHT       50.0 * CURRENT_SCALE
#define BUTTON_RADIUS       BUTTON_HEIGHT/2
#define SELECT_COLOR        RGB(251.0,80.0,36.0)

#import "HabbitsViewController.h"

@interface HabbitsViewController ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *valueArray;

@end

@implementation HabbitsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleArray = @[@"餐饮美食",@"休闲娱乐",@"旅游酒店",@"医疗美容",@"高新科技",@"购物",@"汽车",@"亲子",@"房产装修"];
    _valueArray = [NSMutableArray arrayWithCapacity:0];
    
    [self initUI];
    
    
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    UIButton *closeButton = [CreateViewTool createButtonWithFrame:CGRectMake(self.view.frame.size.width - 80.0, START_HEIGHT - 20.0, 80.0, 20.0) buttonTitle:@"关闭" titleColor:SELECT_COLOR normalBackgroundColor:[UIColor clearColor] highlightedBackgroundColor:[UIColor clearColor] selectorName:@"closeButtonPressed:" tagDelegate:self];
    [self.view addSubview:closeButton];
    
    float y = closeButton.frame.size.height + closeButton.frame.origin.y + 40.0;
    UILabel *tipLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, y, self.view.frame.size.width, 30.0) textString:@"请选择你感兴趣的" textColor:SELECT_COLOR textFont:FONT(24.0)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    float add_y = 25.0 * CURRENT_SCALE;
    y += tipLabel.frame.size.height + 2 * add_y;
    

    float width = 80.0 * CURRENT_SCALE;
    float height = 40.0 * CURRENT_SCALE;
    float add_x = (self.view.frame.size.width - 3 * width)/4.0;

    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            int index = i * 3 + j + 1;
            UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(add_x * (j + 1) + j * width, y + i * (height + add_y), width, height) buttonTitle:_titleArray[index - 1] titleColor:MAIN_TEXT_COLOR normalBackgroundColor:[UIColor whiteColor] highlightedBackgroundColor:SELECT_COLOR selectorName:@"itemButtonPressed:" tagDelegate:self];
            [CommonTool setViewLayer:button withLayerColor:[UIColor lightGrayColor] bordWidth:0.5];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            button.tag = index;
            [self.view addSubview:button];
        }
    }
    
    y += 3 * height + 2 * add_y + 2 * add_y;
    UIButton *doneButton = [CreateViewTool createButtonWithFrame:CGRectMake(SPACE_X, y, self.view.frame.size.width - 2 * SPACE_X, BUTTON_HEIGHT) buttonTitle:@"完成" titleColor:[UIColor whiteColor] normalBackgroundColor:SELECT_COLOR highlightedBackgroundColor:nil selectorName:@"doneButtonPressed:" tagDelegate:self];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [CommonTool clipView:doneButton withCornerRadius:BUTTON_RADIUS];
    [self.view addSubview:doneButton];
    
}

#pragma mark 关闭
- (void)closeButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark item
- (void)itemButtonPressed:(UIButton *)sender
{
    int index = (int)sender.tag - 1;
    NSString *title = _titleArray[index];
   
    if (!sender.selected)
    {
        if ([_valueArray count] == 3)
            [CommonTool addPopTipWithMessage:@"最多可选3个"];
        else
        {
            [_valueArray addObject:title];
            sender.selected = !sender.selected;
        }
        
        
    }
    else
    {
        [_valueArray removeObject:title];
        sender.selected = !sender.selected;
    }
    
    
}

#pragma mark 完成
- (void)doneButtonPressed:(UIButton *)sender
{
    [self.personalInfoViewController changeUserInfoRequest:[_valueArray componentsJoinedByString:@","] forKey:@"xingqu_id"];
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
