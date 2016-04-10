//
//  TurnoverWithdrawalsViewController.h
//  YooSee
//
//  Created by 周后云 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

typedef enum {
    WithdrawTypeStoreBalance    = 0,  //商家余额
    WithdrawTypeStoreTurnover   = 1,  //商家营业额提现
    WithdrawTypePersonBalance   = 2,  //个人余额
} WithdrawType;

@interface TurnoverWithdrawalsViewController : BasicViewController

@property (nonatomic, assign) WithdrawType turnoverWithdrawals;

@property(nonatomic,weak)IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *textArray;
@property (nonatomic, strong) UITextField *alipayField;
@property(nonatomic,strong) UITextField *nameField;
@property(nonatomic,strong) UITextField *moneyField;
@property(nonatomic,assign) CGFloat rate;

-(void)withdrawalsApplyButtonClick:(UIButton *)button;
@end
