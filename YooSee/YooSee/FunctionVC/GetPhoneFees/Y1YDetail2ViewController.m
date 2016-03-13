//
//  Y1YDetail2ViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "Y1YDetail2ViewController.h"
//领取资格
@implementation Y1YDetail2ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:0 tableDelegate:self];
}

- (void)getPicRequest {
    
}
@end
