//
//  SellerSurplusViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerSurplusViewController.h"

#import "SellerRechargeViewController.h"
#import "TurnoverWithdrawalsViewController.h"

#import "FunctionViewController.h"

@interface SellerSurplusViewController ()

@property(nonatomic,weak)IBOutlet UIButton *rechargeButton;
@property(nonatomic,weak)IBOutlet UIButton *withdrawalsButton;

@property(nonatomic,weak)IBOutlet UILabel *moneyLabel;


@end

@implementation SellerSurplusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = @"余额";
    [self.withdrawalsButton.layer setBorderWidth:1.0];//设置边界的宽度
    self.withdrawalsButton.layer.borderColor=[UIColor grayColor].CGColor;
    [self.rechargeButton viewRadius:40/2 backgroundColor:RGB(24, 168, 2)];
    [self.withdrawalsButton viewRadius:40/2 backgroundColor:[UIColor whiteColor]];
    
    self.moneyLabel.text = self.moneyString;
}

#pragma mark -ButtonClick
-(IBAction)rechargeButtonClick:(id)sender{
    @autoreleasepool {
        SellerRechargeViewController *vc = Alloc_viewControllerNibName(SellerRechargeViewController);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(IBAction)withdrawalsButtonClick:(id)sender{
    @autoreleasepool {
//        TurnoverWithdrawalsViewController *vc = Alloc_viewControllerNibName(TurnoverWithdrawalsViewController);
//        vc.turnoverWithdrawals = WithdrawTypeStoreBalance;
//        [self.navigationController pushViewController:vc animated:YES];
        
        //TODO:功能正在开发中
        FunctionViewController *functionViewController = [[FunctionViewController alloc] init];
        [self.navigationController pushViewController:functionViewController animated:YES];
    }
}

#pragma mark -
-(void)surplusRequest{
    
}


@end
