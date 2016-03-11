//
//  GetMoneyDetailViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "GetMoneyDetailViewController.h"

@implementation GetMoneyDetailViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"详情";
    
    [self addBackItem];
    
    // Do any additional setup after loading the view.
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:UITableViewStylePlain tableDelegate:self];
    
    [self refreshData];
}
@end
