//
//  WithdrawViewcontroller.m
//  YooSee
//
//  Created by Shaun on 16/3/20.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "WithdrawViewcontroller.h"
#import "BindCardViewController.h"
#import "CheckPwdVC.h"
@interface WithdrawMoneyView : UIButton
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *goldLabel;
@end
@implementation WithdrawMoneyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, self.frame.size.width - 10, 20)];
    _moneyLabel.font = FONT(16);
    _moneyLabel.textAlignment = NSTextAlignmentCenter;
    _moneyLabel.textColor = [UIColor grayColor];
    [self addSubview:_moneyLabel];
    
//    _goldLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 27, self.frame.size.width - 10, 20)];
//    _goldLabel.textAlignment = NSTextAlignmentCenter;
//    _goldLabel.textColor = [UIColor grayColor];
//    _goldLabel.font = FONT(14);
//    [self addSubview:_goldLabel];
}

@end

@interface WithdrawViewcontroller ()
{
//    UIScrollView    *_scrollView;
//    UITableViewCell *_acountView;
//    UILabel         *_leftMoneyLabel;
//    UILabel         *_canUseLabel;
//    UIButton        *_requestBtn;
//    int             _selectMoney;
//    CGFloat         _canUseMoney;
//    NSString        *_cardID;
}
@end
@implementation WithdrawViewcontroller

- (void)viewDidLoad {
    self.turnoverWithdrawals = WithdrawTypePersonBalance;
    [super viewDidLoad];
    //[self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:0 tableDelegate:self];
    self.title = @"提取现金";
}

-(void)withdrawalsApplyButtonClick:(UIButton *)button {
    CheckPwdVC *vc = [[CheckPwdVC alloc] init];
    vc.money = self.moneyField.text.floatValue;
    vc.cardID = self.alipayField.text;
    vc.name = self.nameField.text;
    vc.rate = self.rate;
    [self.navigationController pushViewController:vc animated:NO];
}
@end
