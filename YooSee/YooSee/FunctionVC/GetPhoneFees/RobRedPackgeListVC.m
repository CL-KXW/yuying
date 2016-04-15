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
@property(nonatomic,strong)NSString *upId;
@property(nonatomic,strong)NSString *downId;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation RobRedPackgeListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抢红包";
    self.dataArray = [NSMutableArray array];
    
    [self addBackItem];
    self.upId = @"0";
    self.downId = @"0";
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:1 tableDelegate:self];
    
    [self addRefreshHeaderView];
    [self addRefreshFooterView];
    
    _isLoading = NO;
    [LoadingView showLoadingView];
    [self refreshData];
    
    self.table.separatorStyle = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"receiveRed" object:nil];
}

- (void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    label.textColor = RGB(155, 155, 155);
    label.text = [NSString stringWithFormat:@" %@ ", dic[@"publish_time"]];
    label.backgroundColor = RGB(216, 216, 216);
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
    detail.title = dic[@"shop_name"];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)request:(ActionType)actionType {
    
    _isLoading = YES;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *pid = [[YooSeeApplication shareApplication] provinceID];
    NSString *cid = [[YooSeeApplication shareApplication] cityID];
    NSString *startid;
    NSString *loadtype;
    if(actionType == ActionType_up){
        startid = self.upId;
        loadtype = @"1";
    }else{
        startid = self.downId;
        loadtype = @"2";
    }
    NSDictionary *requestDic = @{
                                 @"province_id":[NSString stringWithFormat:@"%@",pid],
                                 @"city_id":[NSString stringWithFormat:@"%@",cid],
                                 @"hongbao_type":@"1",
                                 @"loadtype":loadtype,
                                 @"startid":startid};
    WeakSelf(weakSelf);
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
             NSArray *array = dataDic[@"resultList"];
             if(actionType == ActionType_up){
                 if([array count] == 0){
                     [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
                 }else{
                     for (NSDictionary *dic in array) {
                         [_dataArray addObject:dic];
                     }
                     
                     NSDictionary *dic;
                     
                     if([self.upId intValue] == 0){
                         dic = [array firstObject];
                         self.downId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                     }
                     dic = [array lastObject];
                     self.upId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                 }
             }else{
                 if([array count] != 0){
                     NSDictionary *dic = [array lastObject];
                     weakSelf.downId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                     
                     for (NSDictionary *dic in array) {
                         [_dataArray insertObject:dic atIndex:0];
                     }
                 }else{
                     [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
                 }
             }
             if(_dataArray.count != 0){
                 weakSelf.refreshFooterView.hidden = NO;
             }else{
                 weakSelf.refreshFooterView.hidden = YES;
             }
             [self.table reloadData];
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
    
    //没有数据的时候当作刚进来的时候处理
    if (_dataArray.count == 0) {
        [self request:ActionType_up];
    }else{
        [self request:ActionType_down];
    }
}

- (void)getMoreData {
    if (_isLoading)
    {
        return;
    }
    [super getMoreData];
    [self request:ActionType_up];
}
@end
