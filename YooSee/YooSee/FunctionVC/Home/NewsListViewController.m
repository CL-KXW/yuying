//
//  NewsListViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "NewsListViewController.h"

@interface NewsListViewController ()

@end

@implementation NewsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"消息";
    [self addBackItem];
    
    [self initUI];
    
//    if (!self.dataArray)
//    {
//        [self getNewsListRequest];
//    }
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    
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
