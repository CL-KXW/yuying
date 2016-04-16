//
//  RedPackgeLibraryDetailVC.m
//  YooSee
//
//  Created by Shaun on 16/4/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RedPackgeLibraryDetailVC.h"

@interface RedPackgeLibraryDetailVC ()
{
    UILabel *_countLabel;
    int _count;
}
@end

@implementation RedPackgeLibraryDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.dataDic[@"shop_name"];
    if (self.hasGetMoney == NO) {
        _count = 5;
    }
    [self updateButtonState];
    
    if (_count > 0) {
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 12.5 - 44, 75, 44, 44)];
        _countLabel.backgroundColor = RGB(208, 2, 2);
        _countLabel.layer.cornerRadius = 22;
        _countLabel.layer.masksToBounds = YES;
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = FONT(18);
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self.table.tableHeaderView addSubview:_countLabel];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countTimer:) userInfo:nil repeats:YES];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:timer forMode:NSRunLoopCommonModes];
        [timer fire];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)countTimer:(NSTimer*)timer {
    _countLabel.text = [NSString stringWithFormat:@"%02d",_count];
    _count--;
    if (_count < 0) {
        [timer invalidate];
        timer = nil;
        _countLabel.hidden = YES;
        [self updateButtonState];
    } else {
        _countLabel.hidden = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateButtonState {
    if (self.hasGetMoney == NO) {
        
        NSString *str = [NSString stringWithFormat:@"点击领取 +%.2f元", [self.dataDic[@"lingqu_money"] floatValue]];
        [self.getMoneyButton setTitle:str forState:UIControlStateNormal];
        if (_count <= 0) {
            self.getMoneyButton.enabled = YES;
            [self.getMoneyButton setBackgroundColor:RGB(206, 11, 36)];
        } else {
            self.getMoneyButton.enabled = NO;
            self.getMoneyButton.backgroundColor = RGB(204, 204, 204);
        }
    } else {
        
        self.getMoneyButton.backgroundColor = RGB(204, 204, 204);
        NSString *str = [NSString stringWithFormat:@"已领取红包 ＋%.2f元", [self.dataDic[@"lingqu_money"] floatValue]];
        [self.getMoneyButton setTitle:str forState:UIControlStateNormal];
        self.getMoneyButton.enabled = NO;
    }
}

- (void)startMoneyAnimation:(void(^)())didBlock {
    
}

- (void)getMoneyClick:(UIButton*)sender {
    [self getAdRewardRequest];
}

- (void)getAdRewardRequest
{
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *ggid = self.ggid;
    ggid = ggid ? ggid : @"";
    NSDictionary *requestDic = @{@"lingqu_user_id":[NSString stringWithFormat:@"%@", uid],@"only_number":[NSString stringWithFormat:@"%@", ggid]};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:RED_PACKGE_DETAIL_GET_MONEY
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         [LoadingView dismissLoadingView];
         NSLog(@"GET_AD_REWARD===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 8)
         {
             NSString *moneyName = [NSString stringWithFormat:@"已经领取红包 +%.2f元", [self.dataDic[@"lingqu_money"] floatValue]];
             self.hasGetMoney = YES;
             [self updateButtonState];
             [SVProgressHUD showSuccessWithStatus:moneyName];
             if (self.block) {
                 self.block();
             }
         }
         else
         {
             [CommonTool addPopTipWithMessage:errorMessage];
             //[SVProgressHUD showErrorWithStatus:errorMessage duration:2.5];
         }
     }
                            requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [LoadingView dismissLoadingView];
         [CommonTool addPopTipWithMessage:@"网络错误"];
     }];
}
@end
