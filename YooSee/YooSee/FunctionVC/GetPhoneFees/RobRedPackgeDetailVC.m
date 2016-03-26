//
//  RobRedPackgeDetailVC.m
//  YooSee
//
//  Created by Shaun on 16/3/16.
//  Copyright © 2016年 chenlei. All rights reserved.
//
#define SPACE_X     12.5
#define SPACE_Y     12.5
#define IMG_H       350 * CURRENT_SCALE

#import "RobRedPackgeDetailVC.h"

@interface RobRedPackgeDetailVC ()
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *robButton;

@property (nonatomic, strong) UILabel *resultDescLabel;
@end

@implementation RobRedPackgeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抢红包";
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.view = scroll;
    [self addBackItem];
    self.view.backgroundColor = RGB(205, 11, 36);
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SPACE_X, 64 + SPACE_Y, IMG_H, IMG_H)];
    self.imageView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.imageView];
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACE_X, 64 + SPACE_Y * 2 + IMG_H, IMG_H, 80)];
    self.descLabel.font = FONT(30);
    self.descLabel.textColor = [UIColor orangeColor];
    self.descLabel.text = @"祝爸爸妈妈身体健康，幸福安康";
    self.descLabel.numberOfLines = 0;
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.descLabel];
    
    self.robButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 95 * CURRENT_SCALE, 95 * CURRENT_SCALE)];
    self.robButton.backgroundColor = [UIColor yellowColor];
    self.robButton.center = CGPointMake(SCREEN_WIDTH * 0.5, 70 + IMG_H + SPACE_Y * 3 + 95 *CURRENT_SCALE * 0.5 + 64);
    [self.view addSubview:self.robButton];
    
    CGRect rect = self.robButton.frame;
    rect.size.width = IMG_H;
    rect.size.height = 45;
    self.resultDescLabel = [[UILabel alloc] initWithFrame:rect];
    self.resultDescLabel.center = self.robButton.center;
    self.resultDescLabel.backgroundColor = [UIColor blackColor];
    self.resultDescLabel.textColor = [UIColor whiteColor];
    self.resultDescLabel.font = FONT(18);
    self.resultDescLabel.textAlignment = NSTextAlignmentCenter;
    self.resultDescLabel.numberOfLines = 0;
    self.resultDescLabel.text = @"已存入红包库\n请12小时内收取红包";
    [self.view addSubview:self.resultDescLabel];
    
    [self robedView];
    if (SCREEN_HEIGHT == 480) {
        scroll.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT + 100);
    } else {
        scroll.contentSize = CGSizeMake(SCREEN_WIDTH ,SCREEN_HEIGHT + 1);
    }
    [self request];
}

- (void)unrobView {
    self.descLabel.hidden = NO;
    self.robButton.hidden = NO;
    self.resultDescLabel.hidden = YES;
}

- (void)robedView {
    self.descLabel.hidden = NO;
    self.robButton.hidden = YES;
    self.resultDescLabel.hidden = NO;
}

- (void)robingView {
    self.descLabel.hidden = NO;
    self.robButton.hidden = YES;
    self.resultDescLabel.hidden = YES;
}

- (void)request {
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"lingqu_user_id":[NSString stringWithFormat:@"%@", uid],
                                 @"only_number":[NSString stringWithFormat:@"%@",self.redPackgeId]};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:ROB_RED_PACKGE_DETAIL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"ROB_RED_PACKGE_DETAIL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         [self.refreshFooterView setState:MJRefreshStateNormal];
         [self.refreshHeaderView setState:MJRefreshStateNormal];
     }
                            requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [LoadingView dismissLoadingView];
         NSLog(@"ROB_RED_PACKGE_DETAIL====%@",error);
     }];
}
@end
