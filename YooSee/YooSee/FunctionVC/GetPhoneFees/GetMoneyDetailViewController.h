//
//  GetMoneyDetailViewController.h
//  YooSee
//
//  Created by Shaun on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"
#import "Y1YDetail2ViewController.h"
@interface GetMoneyDetailViewController : Y1YDetail2ViewController
@property (nonatomic, strong) UIButton *getMoneyButton;
@property (nonatomic, strong) NSDictionary *dataDic;
- (void)startMoneyAnimation:(void(^)())didBlock;
- (void)getMoneyClick:(UIButton*)sender;
@end
