//
//  Y1YDetailViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "Y1YDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Y1YDetail2ViewController.h"

#define WIDTH   SCREEN_WIDTH
#define HEIGHT  SCREEN_HEIGHT
@interface Y1YDetailViewController ()
{
    UIImageView  *imageV;
    UIImageView  *imageV2;
    UIScrollView *advContentView;
    NSTimer *advTimer;
    NSTimer *countTimer;
    int currentPage;
    int totalPage;
    UILabel *lblTimerExample3;
    int leftSecond;

    NSDictionary *_stateDic;
    
    UIImageView *mainImageView;

    UIView *robResultView;

    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *audioPlayer2;
    AVAudioPlayer *audioPlayer3;
    AVAudioPlayer *audioPlayer4;
    NSMutableArray *roberArray;
    
    BOOL _isAuth;
    int _userSort;
    float _userRobNum;
    
    NSString *nowTime;
    NSDictionary *yaoyiyaoDic;
    NSString *bcount;
}
@end

@implementation Y1YDetailViewController
#pragma mark 生命周期
- (void)dealloc {
    NSLog(@"Y1YDetailViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestState];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAdvTimer];
    [self stopCountTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"摇一摇";
    [self addBackItem];
    roberArray = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"welcom_yhb.mp3" ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:NULL];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"shake_sound_male.mp3" ofType:nil];
    fileUrl = [NSURL fileURLWithPath:filePath];
    audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:NULL];
    [audioPlayer2 prepareToPlay];

    filePath = [[NSBundle mainBundle] pathForResource:@"weiqiangdao_yhb.mp3" ofType:nil];
    fileUrl = [NSURL fileURLWithPath:filePath];
    audioPlayer3 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:NULL];
    [audioPlayer3 prepareToPlay];

    filePath = [[NSBundle mainBundle] pathForResource:@"ZSYY.mp3" ofType:nil];
    fileUrl = [NSURL fileURLWithPath:filePath];
    audioPlayer4 = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:NULL];
    [audioPlayer4 prepareToPlay];

    
    imageV= [[UIImageView alloc]initWithFrame:CGRectMake(0, START_HEIGHT ,WIDTH, HEIGHT)];
    imageV.animationImages = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"y1y_bg_1.jpg"],
                              [UIImage imageNamed:@"y1y_bg_2.jpg"],
                              [UIImage imageNamed:@"y1y_bg_3.jpg"],
                              nil];
    [imageV setAnimationDuration:0.5f];
    [imageV setAnimationRepeatCount:0];
    [imageV startAnimating];
    imageV.userInteractionEnabled = YES;
    
    imageV2 = [[UIImageView alloc]initWithFrame:
                             CGRectMake(0+5,
                                        WIDTH*0.73333-10,
                                        WIDTH,
                                        WIDTH*1.005)];
    imageV2.image = [UIImage imageNamed:@"y1y_hb.png"];
    imageV2.userInteractionEnabled = YES;
    [imageV addSubview:imageV2];
    
    advContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, WIDTH,WIDTH*0.73333 )];
    advContentView.showsHorizontalScrollIndicator = NO;
    advContentView.showsVerticalScrollIndicator = NO;
    advContentView.pagingEnabled = YES;
    advContentView.userInteractionEnabled = NO;
    [imageV addSubview:advContentView];
    
    [self.view addSubview:imageV];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestState) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self addAdvViews];
}

#pragma mark 点击事件

- (void)ganxingquAction {
    NSLog(@"点击了感兴趣");
    Y1YDetail2ViewController *detail2  = [[Y1YDetail2ViewController alloc]init];
    detail2.ggid = self.dataDic[@"only_number"];
    detail2.title = self.dataDic[@"shop_name"];
    NSMutableArray *ary = [NSMutableArray array];
    NSMutableArray *titleAry = [NSMutableArray array];
    
    if ([self isVaildURL:self.dataDic[@"title_url_1"]]) {
        [ary addObject:self.dataDic[@"title_url_1"]];
        
        if (self.dataDic[@"title_2"] != nil) {
            [titleAry addObject:self.dataDic[@"title_2"]];
        }else{
            [titleAry addObject:@""];
        }
    }
    if ([self isVaildURL:self.dataDic[@"title_url_2"]]) {
        [ary addObject:self.dataDic[@"title_url_2"]];
        [titleAry addObject:@""];
    }
    if ([self isVaildURL:self.dataDic[@"title_url_3"]]) {
        [ary addObject:self.dataDic[@"title_url_3"]];
        [titleAry addObject:@""];
    }
    if ([self isVaildURL:self.dataDic[@"title_url_4"]]) {
        [ary addObject:self.dataDic[@"title_url_4"]];
        [titleAry addObject:@""];
    }
    detail2.dataArray = ary;
    detail2.descArray = titleAry;
    detail2.timeString = self.dataDic[@"publish_time"];
    detail2.authorString = self.dataDic[@"shop_name"];
    detail2.nameString = self.dataDic[@"title_1"];
    detail2.startTimeString = self.dataDic[@"begin_time"];
    [self.navigationController pushViewController:detail2 animated:NO];
}

- (void)paihangbangAction {
    //排行榜
    [robResultView removeFromSuperview];
    robResultView = nil;
    [self requestState];
}

#pragma mark 文字处理

- (BOOL)isVaildURL:(NSString*)string {
    if (string && [string isKindOfClass:[NSString class]] && string.length > 6) {
        return YES;
    }
    return NO;
}

- (NSString*)secondToString:(int)second {
    if (second > 0) {
        int day = 0, hour = 0,minute = 0, sec = 0;
        day = (int)ceil(second/(3600*24.0));
        hour = second/3600;
        minute = second%3600/60;
        sec = second%3600%60;
        if (second > 3600 * 24) {
            NSString *dayString = [NSString stringWithFormat:@"%d天", day];
            return dayString;
        }
        NSString *string = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, sec];
        return string;
    }
    return @"00:00:00";
}
#pragma mark 计时器

- (void)countTimerCallback {
    if (leftSecond > 0) {
        leftSecond--;
    } else {
        [self yaoyiyao];
        [self stopCountTimer];
    }
    if (leftSecond > 3600 * 24) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[self secondToString:leftSecond]];
        [attr addAttribute:NSFontAttributeName
                                 value:FONT(24)
                                 range:NSMakeRange(attr.length - 1, 1)];
        lblTimerExample3.attributedText = attr;
    } else {
        lblTimerExample3.text = [self secondToString:leftSecond];
    }
}

- (void)startCountTimer {
    [self stopCountTimer];
    countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTimerCallback) userInfo:nil repeats:YES];
}

- (void)stopCountTimer {
    if (countTimer) {
        [countTimer invalidate];
        countTimer = nil;
    }
}

- (void)startAdvTimer {
    [self stopAdvTimer];
    currentPage = 0;
    advTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(advScroll) userInfo:nil repeats:YES];
    [advTimer fire];
}

- (void)stopAdvTimer {
    if (advTimer) {
        [advTimer invalidate];
        advTimer = nil;
    }
}

- (void)advScroll {
    [advContentView setContentOffset:CGPointMake(currentPage * advContentView.frame.size.width, 0) animated:YES];
    currentPage ++;
    if (currentPage == totalPage) {
        currentPage = 0;
    }
}

#pragma mark 视图

- (void)addAdvViews {
    //添加滚动广告
    [[advContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    totalPage = 0;
    
    if ([self isVaildURL:_dataDic[@"title_url_1"]]) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(totalPage * advContentView.frame.size.width, 0, advContentView.frame.size.width, advContentView.frame.size.height)];
        [advContentView addSubview:view];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [view sd_setImageWithURL:[NSURL URLWithString:_dataDic[@"title_url_1"]]];
        totalPage++;
    }
    
    if ([self isVaildURL:_dataDic[@"title_url_2"]]) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(totalPage * advContentView.frame.size.width, 0, advContentView.frame.size.width, advContentView.frame.size.height)];
        [advContentView addSubview:view];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [view sd_setImageWithURL:[NSURL URLWithString:_dataDic[@"title_url_2"]]];
        totalPage++;
    }
    if ([self isVaildURL:_dataDic[@"title_url_3"]]) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(totalPage * advContentView.frame.size.width, 0, advContentView.frame.size.width, advContentView.frame.size.height)];
        [advContentView addSubview:view];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [view sd_setImageWithURL:[NSURL URLWithString:_dataDic[@"title_url_3"]]];
        totalPage++;
    }
    if ([self isVaildURL:_dataDic[@"title_url_4"]]) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(totalPage * advContentView.frame.size.width, 0, advContentView.frame.size.width, advContentView.frame.size.height)];
        [advContentView addSubview:view];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [view sd_setImageWithURL:[NSURL URLWithString:_dataDic[@"title_url_4"]]];
        totalPage++;
    }
    [advContentView setContentSize:CGSizeMake(advContentView.frame.size.width * totalPage, advContentView.frame.size.height)];
    if (totalPage <= 1) {
        [self stopAdvTimer];
    } else {
        [self startAdvTimer];
    }
}

- (void)removeOtherViews {
    
    [[imageV2 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.table) {
        [self.table removeFromSuperview];
        self.table = nil;
    }
}

- (void)ganxingqu {
    
    //感兴趣
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((WIDTH-130)/2, imageV2.frame.size.height*0.4,130, 40)];
    [button addTarget:self action:@selector(ganxingquAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"感兴趣" forState:UIControlStateNormal];
    [imageV2 addSubview:button];
    [button setBackgroundImage:[UIImage imageNamed:@"HBGXQANTP.png"] forState:UIControlStateNormal];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, imageV2.frame.size.height*0.55+5, WIDTH - 100, 20)];
    label.text =[NSString stringWithFormat:@"%@  准时抢",self.dataDic[@"begin_time"]]; //@"2015年9月10日  15:30 准时抢!";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.font = FONT(14);
    
    [imageV2 addSubview:label];
}

- (void)daojishi {
    //倒计时
    NSLog(@"倒计时");
    [self removeOtherViews];
    self.title = @"倒计时";
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((WIDTH -200)/2, imageV2.frame.size.height*0.35,200,25)];
    label.text = @"倒计时";
    label.textColor = [UIColor orangeColor];
    label.font = FONT(18);
    label.textAlignment = NSTextAlignmentCenter;
    [imageV2 addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake((WIDTH -200)/2, imageV2.frame.size.height*0.35 + 44 + 25 + 15,200,25)];
    label2.text = [NSString stringWithFormat:@"%@个人参与",bcount];
    label2.textColor = [UIColor orangeColor];
    label2.font = FONT(16);
    label2.textAlignment = NSTextAlignmentCenter;
    [imageV2 addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake((WIDTH -200)/2, imageV2.frame.size.height*0.35+15+44+20 + 25,200,25)];
    label3.text = [CommonTool dateString2MDHMString:_dataDic[@"begin_time"]];//begintime;//@"2015年9月12日  18:00:00";
    label3.textColor = [UIColor orangeColor];
    label3.font = FONT(16);
    label3.textAlignment = NSTextAlignmentCenter;
    [imageV2 addSubview:label3];
    
    lblTimerExample3 = [[UILabel  alloc]initWithFrame:CGRectMake((WIDTH -300)/2, imageV2.frame.size.height*0.35 + 25 + 7.5,300,40)];
    lblTimerExample3.text = @"--:--:--";
    lblTimerExample3.textAlignment = NSTextAlignmentCenter;
    lblTimerExample3.font = FONT(48);
    lblTimerExample3.textColor = [UIColor whiteColor];
    [imageV2 addSubview:lblTimerExample3];
}

- (void)yaoyiyao {
    //时间到了可以摇一摇了
    NSLog(@"摇一摇");
    self.title = @"摇一摇";
    [self removeOtherViews];
    mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 50, imageV2.frame.size.width-120, imageV2.frame.size.width-120)];
    mainImageView.image = [UIImage imageNamed:@"yyy2.png"];
    mainImageView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"yyy2.png"],
                                     [UIImage imageNamed:@"yyy1.png"],
                                     nil];
    [mainImageView setAnimationDuration:1.0f];
    [mainImageView setAnimationRepeatCount:0];
    [imageV2 addSubview:mainImageView];
}

- (void)resultView {
    //结果
    NSLog(@"结果");
    self.title = @"红包活动";
    [self removeOtherViews];
    [self addTableViewWithFrame:CGRectMake(10, SCREEN_HEIGHT - 160, SCREEN_WIDTH - 20, 160) tableType:0 tableDelegate:self];
    [CommonTool clipView:self.table withCornerRadius:10.0];
    self.table.backgroundColor = [UIColor whiteColor];
    [self requestRoberList];
}

- (void)robSuccessView:(NSString*)company robsum:(NSString*)robsum {
    
    if (robResultView == nil) {
        robResultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 350)];
        [self.view addSubview:robResultView];
        robResultView.center = CGPointMake(SCREEN_WIDTH * 0.5, (SCREEN_HEIGHT - 64) * 0.5);
    }
    [[robResultView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *iamgeV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 280, 350)];//690 780
    iamgeV.image = [UIImage imageNamed:@"kuang.png"];
    [robResultView addSubview:iamgeV];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0,  40, 280, 40)];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text  =[NSString stringWithFormat:@"%@",company];//company;
    label1.numberOfLines = 0;
    label1.textColor = [UIColor blackColor];
    //label.backgroundColor = [UIColor redColor];
    label1.font = FONT(15);
    [iamgeV addSubview:label1];
    
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake((280-200)/2,  20+50, 200, 80)];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text  = @"祝贺你"; //[NSString stringWithFormat:@"%@公司",company];//company;
    label2.numberOfLines = 0;
    label2.textColor = [UIColor redColor];
    //label.backgroundColor = [UIColor redColor];
    label2.font = FONT(35);
    [iamgeV addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake((280-200)/2,  20+50+40+10, 200, 80)];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text  = @"获得现金红包"; //[NSString stringWithFormat:@"%@公司",company];//company;
    label3.numberOfLines = 0;
    label3.textColor = RGB(100, 100, 100);
    label3.font = FONT(14);
    [iamgeV addSubview:label3];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((280-200)/2,(350-90)/2+20 , 200, 140)];
    label.textAlignment = NSTextAlignmentCenter;
    float money = [robsum floatValue];
    if (money < 0) {
        money = 0;
    }
    label.text  =[NSString stringWithFormat:@"%.2f元",money];
    label.numberOfLines = 0;
    label.textColor = RGB(206, 10, 35);
    label.font = FONT(30);
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:label.text];
    [CommonTool makeString:label.text toAttributeString:string withString:@"元" withTextColor:RGB(100, 100, 100) withTextFont:FONT(13)];
    label.attributedText = string;
    [iamgeV addSubview:label];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(80, 290, 120, 40)];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"查看排行榜 >>" forState:UIControlStateNormal];
    button.titleLabel.font = FONT(14);
    [button addTarget:self action:@selector(paihangbangAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:RGB(146, 212, 238) forState:UIControlStateNormal];
    [robResultView addSubview:button];
}

- (void)robFailView:(NSString*)message {
    
    if (robResultView == nil) {
        robResultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 350)];
        [self.view addSubview:robResultView];
        robResultView.center = CGPointMake(SCREEN_WIDTH * 0.5, (SCREEN_HEIGHT) * 0.5);
    }
    [[robResultView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *iamgeV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 280, 350)];
    iamgeV.image = [UIImage imageNamed:@"kuang.png"];
    [robResultView addSubview:iamgeV];
    
    
    UIImageView *iamgeV1 = [[UIImageView alloc]initWithFrame:CGRectMake( (280-150)/2, (350-150)/2, 150, 150)];
    iamgeV1.image = [UIImage imageNamed:@"face.png"];
    [iamgeV addSubview:iamgeV1];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 280, 40)];
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.font  = FONT(18);
    [iamgeV addSubview:label];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(80, 290, 120, 40)];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"查看排行榜 >>" forState:UIControlStateNormal];
    button.titleLabel.font = FONT(14);
    [button addTarget:self action:@selector(paihangbangAction) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:RGB(146, 212, 238) forState:UIControlStateNormal];
    [robResultView addSubview:button];
}

- (void)updateRobResult {
    UIView *tabHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
    tabHeadView.backgroundColor = [UIColor whiteColor];
    //设置头视图
    self.table.tableHeaderView = tabHeadView;
    int state = [_stateDic[@"returnCode"] intValue];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 15-5, 95, 30)];
    label.text = @"你目前的排名:";
    label.font = FONT(14);
    [tabHeadView addSubview:label];
    if (state == 7) {
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(20+10+95, 15-5, 30, 30)];
        //label1.backgroundColor = [UIColor orangeColor];
        label1.textColor = [UIColor orangeColor];
        label1.text = [NSString stringWithFormat:@"%d", _userSort];
        label1.font = FONT(14);
        [tabHeadView addSubview:label1];
        
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-140-20, 15-5, 120, 30)];
        //label2.backgroundColor = [UIColor orangeColor];
        label2.textColor = [UIColor orangeColor];
        label2.text = [NSString stringWithFormat:@"%.2f元",_userRobNum];
        label2.textAlignment = NSTextAlignmentRight;
        label2.font = FONT(14);
        [tabHeadView addSubview:label2];
        
    }else if (state == 4){
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(20+10+95-10, 0,self.view.frame.size.width-20+10+95-10, 50)];
        //label1.backgroundColor = [UIColor orangeColor];
        label1.textColor = [UIColor orangeColor];
        label1.numberOfLines =0;
        if (self.view.frame.size.width <= 320.000000) {
            label1.font = FONT(12);
            
        }else {
            label1.font = FONT(14);
        }
        label1.text = @"很遗憾您没有抢到红包，没有排名!";
        //label1.font = [UIFont fontWithName:nil size:14];
        [tabHeadView addSubview:label1];
    }

}
#pragma mark 红包状态网络请求

- (void)requestState {
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"user_id":[NSString stringWithFormat:@"%@", uid],
                                 @"only_number":[NSString stringWithFormat:@"%@",self.dataDic[@"only_number"]]};
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
             //[self unrobView];
         }
         else if (errorCode == 3) {
             //未开始
             //self.robButton.hidden = YES;
             //self.resultDescLabel.text = @"红包还未开始";
         }
         else if (errorCode == 4) {
             //已抢光
             //self.robButton.hidden = YES;
             //self.resultDescLabel.text = @"你来迟了，红包已被抢光";
         }
         else if (errorCode == 7) {
             //[self request];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         _stateDic = dataDic;
         [self dealViews];
     }requestFail:^(AFHTTPRequestOperation *operation, NSError *error){
         [LoadingView dismissLoadingView];
         [self.navigationController popViewControllerAnimated:YES];
         NSLog(@"RED_PACKAGE_STATE====%@",error);
     }];
}

- (void)getTime {
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"user_id":[NSString stringWithFormat:@"%@", uid],
                                 @"only_number":[NSString stringWithFormat:@"%@",self.dataDic[@"only_number"]]};
    //requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:[NSString stringWithFormat:@"%@%@",SERVER_URL,@"app/register/getTime"]
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
             bcount = dataDic[@"rezheng_number"];
             nowTime = dataDic[@"time"];
             NSDate *date = [CommonTool timeStringToDate:_dataDic[@"begin_time"] format:@"yyyy-MM-dd HH:mm:ss"];
             ;
             NSDate *nowDate = [CommonTool timeStringToDate:nowTime format:@"yyyy-MM-dd HH:mm:ss"];
             leftSecond = [date timeIntervalSinceDate:nowDate];
             [self startCountTimer];
             [self daojishi];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }requestFail:^(AFHTTPRequestOperation *operation, NSError *error){
         [LoadingView dismissLoadingView];
         [self.navigationController popViewControllerAnimated:YES];
         NSLog(@"RED_PACKAGE_STATE====%@",error);
     }];
}

//摇一摇请求
- (void)requestRob {
    
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"lingqu_user_id":[NSString stringWithFormat:@"%@", uid],
                                 @"only_number":[NSString stringWithFormat:@"%@",self.dataDic[@"only_number"]]};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:[NSString stringWithFormat:@"%@%@",SERVER_URL,@"app/red/get/yaoyiyao/add"]
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
         yaoyiyaoDic = dataDic;
          if (errorCode == 8)
          {
               [self robSuccessView:self.dataDic[@"shop_name"] robsum:yaoyiyaoDic[@"lingqu_money"]];
               [audioPlayer4 play];
          } else if (errorCode == 2) {
              [self robFailView:errorMessage];
              [audioPlayer3 play];
          }
          else
          {
              [SVProgressHUD showErrorWithStatus:errorMessage];
               [self requestState];
          }
     }
                            requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [LoadingView dismissLoadingView];
         NSLog(@"ROB_RED_PACKGE_DETAIL====%@",error);
     }];
    
//    //抢红包
//    //yyw_robredpacked
//    [LoadingView showLoadingView];
//    NSString *uid = [YooSeeApplication shareApplication].uid;
//    uid = uid ? uid : @"";
//    NSDictionary *requestDic = @{
//                                 @"uid":uid,
//                                 @"ggid":_dataDic[@"ggid"]
//                                 };
//    [[RequestTool alloc] getRequestWithUrl:RED_POCKET_ROB
//                            requestParamas:requestDic
//                               requestType:RequestTypeAsynchronous
//                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
//     {
//         NSLog(@"RED_POCKET_ROB===%@",responseDic);
//         NSDictionary *dataDic = (NSDictionary *)responseDic;
//         int errorCode = [dataDic[@"returnCode"] intValue];
//         NSString *errorMessage = dataDic[@"returnMessage"];
//         errorMessage = errorMessage ? errorMessage : @"";
//         [LoadingView dismissLoadingView];
//         if (errorCode == 1)
//         {
//             NSString *state = dataDic[@"body"][@"state"];
//             NSString *message = dataDic[@"body"][@"message"];
//             NSString *company = dataDic[@"body"][@"company"];
//             NSString *robsum = dataDic[@"body"][@"robsum"];
//             if ([state intValue] == 1 || [state intValue] == 2) {
//                 [self robFailView:message];
//                 [audioPlayer3 play];
//             } else if ([state intValue] == 3) {
//                 [self robSuccessView:company robsum:robsum];
//                 [audioPlayer4 play];
//             }
//             [self requestDetail];
//         }
//         else
//         {
//             [SVProgressHUD showErrorWithStatus:errorMessage];
//         }
//     }
//                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         
//         [LoadingView dismissLoadingView];
//         NSLog(@"RED_POCKET_ROB====%@",error);
//     }];
}

- (void)dealViews {
    int orderType = [_stateDic[@"renzheng_type"] intValue];
    int state = [_stateDic[@"returnCode"] intValue];

    if (orderType == 2) {
        [self ganxingqu];
    } else {
        if (state == 3) {
            //未开始
            [self getTime];
            bcount = _dataDic[@"rezheng_number"];
            [self daojishi];
        } else if (state == 8) {
            //进行中
            [self yaoyiyao];
            
        } else if (state == 7 || state == 4) {
            //已结束
            [self resultView];
        }
    }
}

- (void)requestRoberList {
    //抢红包排行榜
    //yyw_getrobredlist
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{
                                 @"user_id":uid,
                                 @"only_number":_dataDic[@"only_number"]
                                 };
    [[RequestTool alloc] requestWithUrl:RED_POCKET_ROBER_LIST
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"RED_POCKET_ROBER_LIST===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             _userSort = [dataDic[@"count"] intValue];
             _userRobNum = [dataDic[@"user_lingqu_money"] floatValue];
             if (_userRobNum < 0) {
                 _userRobNum = 0;
             }
             NSArray *ary = dataDic[@"resultList"];
             if (ary && [ary isKindOfClass:[NSArray class]]) {
                 @synchronized(roberArray) {
                     [roberArray removeAllObjects];
                     [roberArray addObjectsFromArray:ary];
                     [self.table reloadData];
                 }
             }
             [self updateRobResult];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [LoadingView dismissLoadingView];
         NSLog(@"RED_POCKET_ROBER_LIST====%@",error);
     }];
}

#pragma mark 摇一摇事件监听

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (mainImageView == nil) {
        return;
    }
    if (motion == UIEventSubtypeMotionShake) {
        
        [mainImageView startAnimating];
        NSLog(@"开始要一摇");
        [audioPlayer2 play];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (mainImageView == nil) {
        return;
    }
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"停止要一摇");
        [mainImageView stopAnimating];
        [self requestRob];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return roberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"identifyCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = 0;
        //创建子视图
        //1.创建标题label
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 40, 30)];
        titleLabel.tag = 101;
        //titleLabel.backgroundColor = [UIColor redColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:titleLabel];
        
        
        //2.创建评论标题
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+10+30+5, 10, 130, 30)];
        commentLabel.tag = 102;
        commentLabel.font = [UIFont systemFontOfSize:14];
        //commentLabel.backgroundColor = [UIColor purpleColor];
        [cell.contentView addSubview:commentLabel];
        
        //3.创建时间label
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.table.frame.size.width-120, 10, 100, 30)];
        timeLabel.tag = 103;
        timeLabel.textAlignment = NSTextAlignmentRight;
        //timeLabel.backgroundColor = [UIColor orangeColor];
        timeLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:timeLabel];
        cell.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:229.0/255.0 blue:218.0/255.0 alpha:1.0];
        
        
    }
    
    
    //2.向子视图填充数据
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *commentLabel = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:103];
    NSLog(@"%d",indexPath.row);
    NSDictionary *dataDic = roberArray[indexPath.row];
    
//    int i = 0;
//    if ([dataDic[@"account"] isEqualToString:@""]) {
//        i++;
//        dataDic = roberArray[indexPath.row + i];
//    }
    
    
    titleLabel.text = [NSString stringWithFormat:@"%@",dataDic[@"sort"]];
    NSString  *SJH = [NSString stringWithFormat:@"%@",dataDic[@"lingqu_user_phone"]];
    //    NSRange rang1 = NSMakeRange(5, 1);
    // month = [begintime substringWithRange:rang1];
    NSLog(@"1111%@",SJH);
    
    NSRange SJrange = NSMakeRange(0, 3);
    NSString *SJHsan =[SJH substringWithRange:SJrange];
    
    NSRange SJrange1 = NSMakeRange(7, 4);
    NSString *SJHHSi =[SJH substringWithRange:SJrange1];
    
    
    
    
    
    //commentLabel.text = [NSString stringWithFormat:@"%@",dataDic[@"account"]];
    commentLabel.text = [NSString stringWithFormat:@"%@****%@",SJHsan,SJHHSi];
    
    
    timeLabel.text = [NSString stringWithFormat:@"%.2f元",[dataDic[@"lingqu_money"] floatValue]];
    if (_userSort == [dataDic[@"sort"] intValue] && _userRobNum > 0) {
        //设置cell的背景颜色
        cell.backgroundColor = [UIColor orangeColor];
        //cell.textLabel.text = [_data objectAtIndex:indexPath.row];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:229.0/255.0 blue:218.0/255.0 alpha:1.0];
    }
    
    
    return cell;
}

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self ganxingquAction];
//}
@end
