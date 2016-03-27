//
//  GoldLibraryViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "GoldLibraryViewController.h"
#import "MoneyDetailVC.h"
#import "RechargeViewController.h"
#import "WithdrawViewcontroller.h"

#define kTableHeaderHeight    35
#define ktenementCellHeight   90

#define CongWIDTH  self.view.frame.size.width
#define CongHEIGHT  self.view.frame.size.height
@interface GoldLibraryViewController ()
{
    UIButton *button;
    UILabel *label2;
    UILabel *label3;
    NSMutableArray *_listArray;
}
@end

@implementation GoldLibraryViewController

- (void)viewDidAppear:(BOOL)animated {
    [self requestGoldInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"现金库";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    button = [[UIButton alloc]initWithFrame:CGRectMake(12.5,12.5, CongWIDTH-25,CongHEIGHT-100)];
    button.backgroundColor= [UIColor whiteColor];
    [scrollView addSubview:button];
    [button.layer setShadowColor:[UIColor blackColor].CGColor];
    [button.layer setShadowOpacity:0.1];
    [button.layer setShadowOffset:CGSizeMake(0, 1)];
    [button.layer setShadowRadius:0.01];
    button.layer.cornerRadius = 10.0f;
    
    UIImageView *iVa = [[UIImageView alloc]initWithFrame:CGRectMake((CongWIDTH-15-120)/2, 80-40, 110, 110)];
    iVa.image = [UIImage imageNamed:@"icon_usercenter_2_up.png"];
    [button addSubview:iVa];
    
    float gg = 40;
    
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(0, 205-gg, CongWIDTH-25, 40)];
    label.text = @"我的现金";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = FONT(20);
    label.textColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0];
    [button addSubview:label];
    
    NSString *paymoney = [[YooSeeApplication shareApplication] userDic][@"paymoney"];
    label2 =[[UILabel alloc]initWithFrame:CGRectMake(0, 255-gg, CongWIDTH-25, 40)];
    label2.text = [NSString stringWithFormat:@"%@元", paymoney];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = FONT(38);
    label2.textColor = [UIColor colorWithRed:253.0/255.0 green:133.0/255.0 blue:63.0/255.0 alpha:1.0];
    [button addSubview:label2];
    
//    label3 =[[UILabel alloc]initWithFrame:CGRectMake(0, 295-gg, CongWIDTH-25, 50)];
//    label3.text = @"可用于消费与提现";
//    label3.textAlignment = NSTextAlignmentCenter;
//    label3.font = FONT(13);
//    label3.textColor =  [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//    [button addSubview:label3];
    
    
    
    
    UIButton   *view2 = [UIButton buttonWithType:UIButtonTypeCustom];
    view2.layer.cornerRadius = 21.0f;
    view2.frame =CGRectMake(20, 315, self.view.frame.size.width-65, 50);
    view2.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:177.0/255.0 blue:31.0/255.0 alpha:1.0];
    view2.layer.masksToBounds = YES;
    [view2 setTitle:@"充值" forState:UIControlStateNormal];
    [button addSubview:view2];
    [view2 addTarget:self action:@selector(buttonAction1) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(20, 380, self.view.frame.size.width-65, 50)];
    [button2 setTitle:@"提现" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(buttonAction3) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:button2];
    button2.layer.cornerRadius = 20.0f;
    button2.layer.borderColor = [[UIColor blackColor] CGColor];
    button2.layer.borderWidth = 0.5f;
    
    
    UIButton *ba4 = [[UIButton alloc]initWithFrame:CGRectMake((CongWIDTH-150-25)/2,440, 150, 40)];
    ba4.titleLabel.font = [UIFont systemFontOfSize:12];
    [ba4 setTitle:@"查看现金明细" forState:UIControlStateNormal];
    [ba4 setTitleColor:[UIColor colorWithRed:119.0/255.0 green:170.0/255.0 blue:227.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [ba4 addTarget:self action:@selector(HFMXAction) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:ba4];
    if (SCREEN_HEIGHT == 480) {
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT + 1);
    } else {
        scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT - 63);
    }
    
    [self addBackItem];
}

- (void)buttonAction1 {
    //充值
    RechargeViewController *vc = [[RechargeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)buttonAction3 {
    //提现
    WithdrawViewcontroller *vc = [[WithdrawViewcontroller alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)HFMXAction {
    //查看现金明细
    MoneyDetailVC *detail = [[MoneyDetailVC alloc] init];
    detail.detailArray = _listArray;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark 网络请求
//请求现金信息
-(void)requestGoldInfo {
    
    NSString *uid = [YooSeeApplication shareApplication].uid;
    
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"id":uid};
    [[RequestTool alloc] requestWithUrl:USER_INFO_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_GOLD_INFO===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 8)
         {
             NSDictionary *dic = dataDic[@"resultList"];
             if (dic && [dic isKindOfClass:[NSDictionary class]] && dic[@"paymoney"]) {
                 label2.text = [NSString stringWithFormat:@"%@元",dic[@"paymoney"]];
             }
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage duration:2.5];
         }
     }
                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];

}

@end
