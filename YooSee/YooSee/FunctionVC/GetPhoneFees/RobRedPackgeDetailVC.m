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
#import "RedPackgeLibraryVC.h"

@interface RobRedPackgeDetailVC ()
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *robButton;

@property (nonatomic, strong) UILabel *resultDescLabel;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation RobRedPackgeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, START_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - START_HEIGHT)];
    [self.view addSubview:scroll];
    [self addBackItem];
    self.view.backgroundColor = RGB(205, 11, 36);
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SPACE_X, SPACE_Y, IMG_H, IMG_H)];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.logoUrl]];
    [scroll addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACE_X, SPACE_Y * 2 + IMG_H, IMG_H, 80)];
    self.descLabel.font = FONT(30);
    self.descLabel.textColor = [UIColor orangeColor];
    self.descLabel.text = self.desc;
    self.descLabel.numberOfLines = 0;
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    [scroll addSubview:self.descLabel];
    
    self.robButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 95 * CURRENT_SCALE, 95 * CURRENT_SCALE)];
    self.robButton.backgroundColor = [UIColor orangeColor];
    [self.robButton setTitle:@"抢" forState:UIControlStateNormal];
    self.robButton.titleLabel.font = FONT(50);
    [self.robButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.robButton.layer.cornerRadius = 95 * CURRENT_SCALE * 0.5;
    [self.robButton setShowsTouchWhenHighlighted:YES];
    self.robButton.center = CGPointMake(SCREEN_WIDTH * 0.5, 70 + IMG_H + SPACE_Y * 3 + 95 *CURRENT_SCALE * 0.5);
    [self.robButton addTarget:self action:@selector(robButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:self.robButton];
    
    CGRect rect = self.robButton.frame;
    rect.size.width = IMG_H;
    rect.size.height = 45;
    self.resultDescLabel = [[UILabel alloc] initWithFrame:rect];
    self.resultDescLabel.center = self.robButton.center;
    self.resultDescLabel.textColor = [UIColor whiteColor];
    self.resultDescLabel.font = FONT(18);
    self.resultDescLabel.textAlignment = NSTextAlignmentCenter;
    self.resultDescLabel.numberOfLines = 0;
    self.resultDescLabel.text = @"已存入红包库\n请24小时内收取红包";
    [scroll addSubview:self.resultDescLabel];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.resultDescLabel.text];
    [CommonTool makeString:self.resultDescLabel.text toAttributeString:string withString:@"红包库" withTextColor:RGB(254, 126, 37) withTextFont:FONT(18)];
    self.resultDescLabel.attributedText = string;
    self.resultDescLabel.userInteractionEnabled = YES;
    
    if (SCREEN_HEIGHT == 480) {
        scroll.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT + 100);
    } else {
        scroll.contentSize = CGSizeMake(SCREEN_WIDTH ,SCREEN_HEIGHT + 1);
    }
    [self unknowState];
    [self requestState];
}

- (void)toRedPackgeLib {
    NSLog(@"toRedPackgeLib");
    RedPackgeLibraryVC *vc = [[RedPackgeLibraryVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)unknowState {
    self.descLabel.hidden = YES;
    self.robButton.hidden = YES;
    self.resultDescLabel.hidden = YES;
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

- (void)dealResponse:(NSDictionary*)dic {
    /*
     returnCode	Integer
     状态码("1", "参数错误","2","太慢了已抢完","3","红包已经领取过了不能再次被领取","4","时间还没有到","8","已领到红包")
     
     returnMessage	String
     返回状态消息
     
     lingqu_money	String
     红包领取金额
     
     only_number	String
     红包唯一号 息
     
     lingqu_user_id	String
     抢红包的用户id
     
     title_url_1	String	
     红包图片
     
     title_1	String	
     红包标题
     */
/*    @property (nonatomic, strong) UIImageView *imageView;
    
    @property (nonatomic, strong) UILabel *descLabel;
    @property (nonatomic, strong) UIButton *robButton;
    
    @property (nonatomic, strong) UILabel *resultDescLabel;*/
    int code = [dic[@"returnCode"] intValue];
    if (code == 2 || code == 3 || code == 8) {
        [self robedView];
        float money = [dic[@"lingqu_money"] floatValue];
        if (money < 0) {
            money = 0;
        }
        self.descLabel.text = [NSString stringWithFormat:@"%.2f元",money];
        if (code == 8) {
            self.resultDescLabel.text = @"已存入红包库\n请24小时内收取红包";
        }
    } else if (code == 4) {
        [self unrobView];
        //self.descLabel.text = [NSString stringWithFormat:@"%@元",dic[@"title_1"]];
    }
    //[self unrobView];
}

- (void)moneyLabelAction:(NSTimer*)timer {
    int bigmoney = arc4random()%99;
    int smallmoney = arc4random()%99;
    self.descLabel.text = [NSString stringWithFormat:@"%02d.%02d元",bigmoney, smallmoney];
}

- (void)robButtonClicked {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moneyLabelAction:) userInfo:nil repeats:YES];
    [self.timer fire];
    [self robingView];
    [self performSelector:@selector(request) withObject:nil afterDelay:0.2];
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
//         if (errorCode == 8)
//         {
//             
//         }
//         else
//         {
//             [SVProgressHUD showErrorWithStatus:errorMessage];
//         }
         if (self.timer) {
             [self.timer invalidate];
             self.timer = nil;
         }
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toRedPackgeLib)];
         [self.resultDescLabel addGestureRecognizer:tap];
         [self dealResponse:dataDic];
     }
                            requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [LoadingView dismissLoadingView];
         NSLog(@"ROB_RED_PACKGE_DETAIL====%@",error);
     }];
}

- (void)requestState {
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"user_id":[NSString stringWithFormat:@"%@", uid],
                                 @"only_number":[NSString stringWithFormat:@"%@",self.redPackgeId]};
    //requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:RED_PACKAGE_STATE
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"RED_PACKAGE_STATE===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             [self unrobView];
         }
         else if (errorCode == 3) {
             //未开始
             self.robButton.hidden = YES;
             self.resultDescLabel.text = @"红包还未开始";
             [self unrobView];
         }
         else if (errorCode == 4) {
             //已抢光
             self.robButton.hidden = YES;
             self.resultDescLabel.text = @"你来迟了，红包已被抢光";
             [self robedView];
         }
         else if (errorCode == 7) {
             [self request];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         //[self dealResponse:dataDic];
     }
                            requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [LoadingView dismissLoadingView];
         NSLog(@"RED_PACKAGE_STATE====%@",error);
     }];
}
@end
