//
//  GetMoneryViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define FOOTVIEW_HEIGHT 5

#import "GetMoneryViewController.h"
#import "AdListCell.h"
#import "GetMoneyDetailViewController.h"

@interface GetMoneryViewController ()
{
    NSMutableArray *_dataArray;
}
@property (nonatomic, strong) NSString *startID;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation GetMoneryViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"赚钱";
    _dataArray = [[NSMutableArray alloc] init];
    _isLoading = NO;
    
    [self addBackItem];
    
    // Do any additional setup after loading the view.
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:UITableViewStylePlain tableDelegate:self];
    [self addRefreshHeaderView];
    [LoadingView showLoadingView];
    [self refreshData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"receiveRed" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AdListCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FOOTVIEW_HEIGHT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     {
     ggid = 373;
     ifnew = N;
     info = " ";
     largepic = "http://112.74.135.133/yywht/uploadfile/ggpic/1120472047_1.jpg";
     leftnum = "79724.00";
     logtime = "2015-10-19 10:41:23.456";
     money1 = 5;
     money2 = 2;
     moneytype = 3;
     secs = null;
     smallpic = "http://112.74.135.133/yywht/uploadfile/ggpic/110453453_1.jpg";
     title = "\U667a\U80fd\U6444\U50cf\U5934\Uff0c\U5c45\U5bb6\U5c0f\U536b\U58eb";
     }
     */
    NSDictionary *dic = _dataArray[indexPath.section];
    static NSString *cellID = @"cellID";
    AdListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[AdListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.nameLabel.text = dic[@"content_1"];
    NSString *logtime = dic[@"begin_time"];
    logtime = [CommonTool dateString2MDString:logtime];
    cell.timeLabel.text = logtime;
    [cell.adView sd_setImageWithURL:[NSURL URLWithString:dic[@"url_1"]] placeholderImage:[UIImage imageNamed:@"default_image2"]];
    float leftMoney = [dic[@"shengyu_money"] floatValue];
    if (leftMoney < 0) {
        leftMoney = 0;
    }
    [cell dealHadGet:NO descTitle:[NSString stringWithFormat:@"%.2f元", leftMoney]];
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.section];
    
    GetMoneyDetailViewController *detail2 = [[GetMoneyDetailViewController alloc] init];
    detail2.dataDic = dic;
    detail2.ggid = dic[@"id"];
    NSMutableArray *ary = [NSMutableArray array];
    NSMutableArray *titleAry = [NSMutableArray array];
    
    if ([self isVaildURL:dic[@"url_1"]]) {
        [ary addObject:dic[@"url_1"]];
        [titleAry addObject:dic[@"content_1"]];
    }
    if ([self isVaildURL:dic[@"url_2"]]) {
        [ary addObject:dic[@"url_2"]];
        [titleAry addObject:dic[@"content_2"]];
    }
    if ([self isVaildURL:dic[@"url_3"]]) {
        [ary addObject:dic[@"url_3"]];
        [titleAry addObject:dic[@"content_3"]];
    }
    if ([self isVaildURL:dic[@"url_4"]]) {
        [ary addObject:dic[@"url_4"]];
        [titleAry addObject:dic[@"content_4"]];
    }
    detail2.dataArray = ary;
    detail2.descArray = titleAry;
    detail2.timeString = dic[@"begin_time"];
    detail2.authorString = dic[@"content_1"];
    detail2.nameString = dic[@"shop_name"];
    [self.navigationController pushViewController:detail2 animated:NO];
}

#pragma mark -

- (void)request {
    
    _isLoading = YES;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *pid = [[YooSeeApplication shareApplication] provinceID];
    pid = pid ? pid : @"";
    NSString *cid = [[YooSeeApplication shareApplication] cityID];
    cid = cid ? cid : @"";
    NSDictionary *requestDic = @{@"province_id":pid,@"city_id":cid,
                                 @"loadtype":[NSString stringWithFormat:@"%d",_currentPage == 1 ? 1 : 1],
                                 @"startid":self.startID,
                                 @"page":@(_currentPage)};
    [[RequestTool alloc] requestWithUrl:GET_AD_LIST
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_AD_LIST===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         _isLoading = NO;
         if (errorCode == 8)
         {
             @synchronized(_dataArray) {
                 if (_currentPage == 1)
                 {
                     [_dataArray removeAllObjects];
                 }
                 id ary = dataDic[@"resultList"];
                 if (ary && [ary isKindOfClass:[NSArray class]])
                 {
                     if ([ary count] > 0)
                     {
                         if (_currentPage == 1)
                         {
                             [self addRefreshFooterView];
                             self.refreshFooterView.hidden = NO;
                         }
                         [_dataArray addObjectsFromArray:ary];
                         self.startID = [ary lastObject][@"id"];
                     }
                     else
                     {
                         [CommonTool addPopTipWithMessage:@"没有更多数据"];
                         self.refreshFooterView.hidden = YES;
                     }

                 } else if (ary && [ary isKindOfClass:[NSDictionary class]]) {
                     [_dataArray addObject:ary];
                 }
                 
                 [self.table reloadData];
             }
         }
         else
         {
             if (_currentPage > 1)
             {
                 _currentPage--;
             }
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         [self.refreshFooterView setState:MJRefreshStateNormal];
         [self.refreshHeaderView setState:MJRefreshStateNormal];
     }
      requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [LoadingView dismissLoadingView];
         NSLog(@"GET_AD_LIST====%@",error);
         _isLoading = NO;
         if (_currentPage > 1)
         {
             _currentPage--;
         }
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
         [self.refreshFooterView setState:MJRefreshStateNormal];
         [self.refreshHeaderView setState:MJRefreshStateNormal];
     }];
}

- (void)refreshData
{
    if (_isLoading)
    {
        return;
    }
    [super refreshData];
    self.startID = @"0";
    [self request];
}

- (void)getMoreData
{
    if (_isLoading)
    {
        return;
    }
    [super getMoreData];
    [self request];
}
@end
