//
//  TurnoverWithdrawalsViewController.h
//  YooSee
//
//  Created by 周后云 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

@interface TurnoverWithdrawalsViewController : BasicViewController

@property (nonatomic) BOOL turnoverWithdrawals;
@property (nonatomic, strong) NSArray *textArray;

@property (nonatomic, strong) UITextField *alipayField;
@property(nonatomic,strong) UITextField *nameField;
@property(nonatomic,strong) UITextField *moneyField;
@property(nonatomic,assign) CGFloat rate;

-(void)withdrawalsApplyButtonClick:(UIButton *)button;
@end
