//
//  GetMoneyDetailViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "GetMoneyDetailViewController.h"
#import "YCMoneyAnimation.h"
#import <AVFoundation/AVFoundation.h>

@interface GetMoneyDetailViewController ()
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) YCMoneyAnimation *moneyAniView;
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@end

@implementation GetMoneyDetailViewController
- (void)dealloc {
    NSLog(@"GetMoneyDetailViewController dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"详细";
    
    [self addBackItem];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    
    NSString *title = @"立即领取现金";
    self.getMoneyButton = [[UIButton alloc] initWithFrame:CGRectMake(35, self.descLabel.frame.size.height + 40, SCREEN_WIDTH - 70, 50)];
    [self.getMoneyButton setBackgroundColor:RGB(206, 11, 36)];
    self.getMoneyButton.layer.cornerRadius = 25;
    [self.getMoneyButton setShowsTouchWhenHighlighted:YES];
    [self.getMoneyButton setTitle:title forState:UIControlStateNormal];
    [self.getMoneyButton addTarget:self action:@selector(getMoneyClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:self.getMoneyButton];
    self.table.tableFooterView = footView;
}

- (void)updateViews:(UIImage*)image {
    if (!image) {
        return;
    }
    if (image.size.width == 0 || image.size.height == 0) {
        return;
    }
    CGFloat imageH = image.size.height/image.size.width*SCREEN_WIDTH;
    self.logoImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, imageH);
    self.table.tableHeaderView = self.logoImageView;
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
    NSDictionary *requestDic = @{@"lingqu_user_id":[NSString stringWithFormat:@"%@", uid],@"id":[NSString stringWithFormat:@"%@", ggid]};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:GET_AD_REWARD
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
             NSString *moneyName = [NSString stringWithFormat:@"您本次看一看获得%@元", self.dataDic[@"lingqu_money"]];
            [self startMoneyAnimation:^{
                [self setMoneyAniView:nil];
            }];//显示金钱下落动画
            [SVProgressHUD showSuccessWithStatus:moneyName];
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

#pragma mark - 下金钱动画效果
- (void)startMoneyAnimation:(void(^)())didBlock
{
    
    if (!self.avPlayer)
    {
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"shake_match" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:audioPath];
        NSError *error = nil;
        AVAudioPlayer *avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [avPlayer prepareToPlay];
        [avPlayer setNumberOfLoops:0];
        [self setAvPlayer:avPlayer];
    }
    
    if (!self.moneyAniView) {
        __weak typeof(self) weakSelf = self;
        YCMoneyAnimation *moneyAn = [[YCMoneyAnimation alloc] initWithAnimation:^{
            [self.avPlayer play];
        } :nil];
        moneyAn.didAnimation = ^(){
            [weakSelf.avPlayer pause];
            [weakSelf.moneyAniView removeFromSuperview];
            if(didBlock) didBlock();
        };
        [self setMoneyAniView:moneyAn];
    }
    
    //[self.moneyAniView.bagView setImage:[UIImage imageNamed:@"hongbao"]];
    [self.moneyAniView getCoinAction];
}

@end
