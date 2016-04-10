//
//  RobRedPackgeListVC.m
//  YooSee
//
//  Created by Shaun on 16/3/16.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RobRedPackgeListVC.h"
#import "RobRedPackgeListCell.h"
#import "RobRedPackgeDetailVC.h"
@interface RobRedPackgeListVC ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *startID;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation RobRedPackgeListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抢红包";
    self.dataArray = [NSMutableArray array];
    
    [self addBackItem];
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:1 tableDelegate:self];
    
    [self addRefreshHeaderView];
    
    _isLoading = NO;
    [LoadingView showLoadingView];
    [self refreshData];
    
    self.table.separatorStyle = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"receiveAdvertisement" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RobRedPackgeListCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _dataArray[indexPath.section];
    static NSString *key = @"cellID";
    RobRedPackgeListCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[RobRedPackgeListCell alloc] initWithStyle:0 reuseIdentifier:key];
    }
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:dic[@"logo"]] placeholderImage:[UIImage imageNamed:@"default_image1"]];
    cell.descLabel.text = dic[@"title_1"];
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = _dataArray[section];
    UIView *header = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    label.textColor = [UIColor grayColor];
    label.text = [NSString stringWithFormat:@" %@ ", dic[@"publish_time"]];
    label.backgroundColor = [UIColor lightGrayColor];
    label.layer.cornerRadius = 2;
    label.layer.masksToBounds = YES;
    label.font = FONT(12);
    [label sizeToFit];
    label.frame = CGRectMake(0, 0, label.frame.size.width, 20);
    label.center = CGPointMake(SCREEN_WIDTH * 0.5, 25);
    [header addSubview:label];
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _dataArray[indexPath.section];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RobRedPackgeDetailVC *detail = [[RobRedPackgeDetailVC alloc] init];
    detail.redPackgeId = dic[@"only_number"];
    detail.logoUrl = dic[@"title_url_1"];
    detail.desc = dic[@"title_1"];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)request {
    
    _isLoading = YES;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *pid = [[YooSeeApplication shareApplication] provinceID];
    NSString *cid = [[YooSeeApplication shareApplication] cityID];
    NSDictionary *requestDic = @{
                                 @"province_id":[NSString stringWithFormat:@"%@",pid],
                                 @"city_id":[NSString stringWithFormat:@"%@",cid],
                                 @"hongbao_type":@"1",
                                 @"loadtype":[NSString stringWithFormat:@"%d",_currentPage == 1 ? 1 : 1],
                                 @"startid":self.startID};
    [[RequestTool alloc] requestWithUrl:ROB_RED_PACKGE_LIST
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         _isLoading = NO;
         NSLog(@"ROB_RED_PACKGE_LIST===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             @synchronized(_dataArray) {
                 if (_currentPage == 1) {
                     [_dataArray removeAllObjects];
                 }
                 NSArray *ary = dataDic[@"resultList"];
                 if (ary && [ary isKindOfClass:[NSArray class]])
                 {
                     if (ary.count > 0)
                     {
                         [self addRefreshFooterView];
                         self.refreshFooterView.hidden = NO;
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
                     NSDictionary *d = (NSDictionary*)ary;
                     self.startID = d[@"id"];
                 }
                 [self.table reloadData];
             }
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
         _isLoading = NO;
         [LoadingView dismissLoadingView];
         NSLog(@"ROB_RED_PACKGE_LIST====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
         [self.refreshFooterView setState:MJRefreshStateNormal];
         [self.refreshHeaderView setState:MJRefreshStateNormal];
     }];
}

- (void)refreshData {
    if (_isLoading)
    {
        return;
    }
    [super refreshData];
    self.startID = @"0";
    [self request];
}

- (void)getMoreData {
    if (_isLoading)
    {
        return;
    }
    [super getMoreData];
    [self request];
}
@end
