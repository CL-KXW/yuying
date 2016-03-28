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
    UIScrollView    *_scrollView;
    UITableViewCell *_acountView;
    UILabel         *_leftMoneyLabel;
    UILabel         *_canUseLabel;
    UIButton        *_requestBtn;
    int             _selectMoney;
    CGFloat         _canUseMoney;
    NSString        *_cardID;
}
@end
@implementation WithdrawViewcontroller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"提取现金";
    [self addBackItem];
    
    self.view = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    _acountView = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    _acountView.backgroundColor = [UIColor whiteColor];
    _acountView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
    [self.view addSubview:_acountView];
    
    _leftMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, SCREEN_WIDTH - 20, 20)];
    _leftMoneyLabel.text = @"";
    _leftMoneyLabel.textAlignment = NSTextAlignmentCenter;
    _leftMoneyLabel.font = FONT(14);
    _leftMoneyLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:_leftMoneyLabel];
    
    _canUseLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, SCREEN_WIDTH - 20, 20)];
    _canUseLabel.text = @"可提现人民币：0元";
    _canUseLabel.textAlignment = NSTextAlignmentCenter;
    _canUseLabel.textColor = [UIColor lightGrayColor];
    _canUseLabel.font = FONT(14);
    [self.view addSubview:_canUseLabel];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 56 - 64, SCREEN_WIDTH, 56)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(26, 8, SCREEN_WIDTH - 26 * 2, 40)];
    _requestBtn = btn;
    _requestBtn.enabled = NO;
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setShowsTouchWhenHighlighted:YES];
    [btn setTitle:@"提交申请" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [footView addSubview:btn];
    [btn addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:footView];
    
    self.view.backgroundColor = RGB(239, 239, 244);
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT + 1);
}

- (void)initMoneyView:(NSArray*)array {
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[WithdrawMoneyView class]]) {
            [view removeFromSuperview];
        }
    }
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dic = array[i];
        WithdrawMoneyView *btn = [[WithdrawMoneyView alloc] initWithFrame:CGRectMake(22 + (i % 2 * (SCREEN_WIDTH - 22 * 3) / 2.0) + (i % 2) * 22, 141 + 70 * (i / 2), (SCREEN_WIDTH - 22 * 3) / 2.0, 50)];
        [self.view addSubview:btn];
        btn.tag = [dic[@"allownum"] intValue];
        btn.moneyLabel.text = [NSString stringWithFormat:@"%d元", [dic[@"allownum"] intValue]];
//        btn.goldLabel.text = [NSString stringWithFormat:@"消耗%d金币", [dic[@"neednum"] intValue]];
        if (_selectMoney != btn.tag) {
            btn.backgroundColor = [UIColor whiteColor];
        } else {
            btn.backgroundColor = [UIColor lightGrayColor];
        }
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self requestMoneyInfo];
    [self reuqestCardList];
}

- (void)selectButtonClick:(UIButton*)sender {
    if (sender.tag > _canUseMoney) {
        //没那么多钱可以取
        [SVProgressHUD showErrorWithStatus:@"亲，余额不足" duration:2.0];
        return;
    }
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[WithdrawMoneyView class]]) {
            if (view != sender) {
                view.backgroundColor = [UIColor whiteColor];
            } else {
                view.backgroundColor = [UIColor lightGrayColor];
            }
        }
    }
    _selectMoney = sender.tag;
    if (_cardID) {
        _requestBtn.enabled = YES;
        _requestBtn.backgroundColor = RGB(80, 201, 45);
    }
}

- (void)tapAction:(id)sender {
    NSLog(@"tapAction");
    BindCardViewController *bind = [[BindCardViewController alloc] init];
    [self.navigationController pushViewController:bind animated:YES];
}

- (void)requestAction:(UIButton*)sender {
    CheckPwdVC *vc = [[CheckPwdVC alloc] init];
    vc.money = _selectMoney;
    vc.cardID = _cardID;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)reuqestCardList {
//    BANK_CARD_LIST_URL
    NSString *alipay = [[YooSeeApplication shareApplication] userInfoDic][@"alipay"];
    _cardID = alipay;
    if (alipay && [alipay isKindOfClass:[NSString class]] && alipay.length
         > 0) {
        _acountView.accessoryView = nil;
        _acountView.textLabel.text = [NSString stringWithFormat:@"支付宝账号:%@", alipay];
        if (_selectMoney > 0) {
            _requestBtn.enabled = YES;
            _requestBtn.backgroundColor = RGB(80, 201, 45);
        } else {
            _requestBtn.backgroundColor = [UIColor lightGrayColor];
            _requestBtn.enabled = NO;
        }
    } else {
        _acountView.textLabel.text = @"未绑定支付宝账户";
        UIButton *binding = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
        [binding setTitle:@"去绑定" forState:UIControlStateNormal];
        [binding setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _acountView.accessoryView = binding;
        [binding addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)requestMoneyInfo {
    NSString *paymoney = [[YooSeeApplication shareApplication] userInfoDic][@"paymoney"];
    _canUseMoney = [paymoney floatValue];
    _canUseLabel.text = [NSString stringWithFormat:@"可提现人民币：%@元", paymoney];
    NSArray *ary = @[@{@"allownum":@"100"},
                     @{@"allownum":@"200"},
                     @{@"allownum":@"300"},
                     @{@"allownum":@"400"},];
    [self initMoneyView:ary];
}

@end
