//
//  RedPackgeLibraryVC.m
//  YooSee
//
//  Created by Shaun on 16/3/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RedPackgeLibraryVC.h"
#import "RedPackgeLibraryCell.h"
#import "RedPackgeLibraryDetailVC.h"

@interface RedPackgeLibraryVC ()
{
    NSString *startID[2];
    MJRefreshFooterView *refreshFooterView[2];
    MJRefreshHeaderView *refreshHeaderView[2];
    BOOL isLoading[2];
}
@property (nonatomic, strong) NSMutableArray *hasGetArray;
@property (nonatomic, strong) NSMutableArray *ungetArray;
@property (nonatomic, strong) UITableView *ungetTable;
@property (nonatomic, strong) UITableView *hasGetTable;

@property (nonatomic, strong) UIView *segmentView;
@property (nonatomic, strong) UIButton *hasGetBtn;
@property (nonatomic, strong) UIButton *ungetBtn;
@property (nonatomic, strong) UIView *selectView;
@end
@implementation RedPackgeLibraryVC

- (void)dealloc {
    [refreshFooterView[0] free];
    [refreshFooterView[1] free];
    [refreshHeaderView[0] free];
    [refreshHeaderView[1] free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.title = @"红包库";
    self.hasGetArray = [NSMutableArray array];
//    [self.hasGetArray addObject:@"1"];
//    [self.hasGetArray addObject:@"1"];
//    [self.hasGetArray addObject:@"1"];

    self.ungetArray = [NSMutableArray array];
//    [self.ungetArray addObject:@"1"];
//    [self.ungetArray addObject:@"1"];
//    [self.ungetArray addObject:@"1"];
//    [self.ungetArray addObject:@"1"];
    startID[0] = @"";
    startID[1] = @"";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self performSelector:@selector(initViews) withObject:nil afterDelay:0.1];
}

- (void)initViews {
    _hasGetTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 64) style:0];
    _hasGetTable.dataSource = self;
    _hasGetTable.delegate = self;
    _hasGetTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_hasGetTable];
    UIView *view = [UIView new];
    _hasGetTable.tableFooterView = view;
    _hasGetTable.hidden = YES;
    _hasGetTable.autoresizingMask = 0;
    
    _ungetTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 64) style:0];
    _ungetTable.dataSource = self;
    _ungetTable.delegate = self;
    _ungetTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_ungetTable];
    view = [UIView new];
    _ungetTable.tableFooterView = view;
    
    _segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    _segmentView.backgroundColor = [UIColor whiteColor];
    UIView *lineX = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, SCREEN_WIDTH, 0.5)];
    lineX.backgroundColor = [UIColor lightGrayColor];
    [_segmentView addSubview:lineX];
    
    _ungetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.5, 44)];
    [_ungetBtn setTitle:@"未收" forState:UIControlStateNormal];
    [_ungetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateSelected];
    [_ungetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateHighlighted];
    [_ungetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_ungetBtn addTarget:self action:@selector(segmentViewAction:) forControlEvents:UIControlEventTouchUpInside];
    _ungetBtn.titleLabel.font = FONT(15);
    [_segmentView addSubview:_ungetBtn];
    
    _hasGetBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5, 0, SCREEN_WIDTH * 0.5, 44)];
    [_hasGetBtn setTitle:@"已收" forState:UIControlStateNormal];
    [_hasGetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateSelected];
    [_hasGetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateHighlighted];
    [_hasGetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_hasGetBtn addTarget:self action:@selector(segmentViewAction:) forControlEvents:UIControlEventTouchUpInside];
    _hasGetBtn.titleLabel.font = FONT(15);
    [_segmentView addSubview:_hasGetBtn];
    
    [self.view addSubview:_segmentView];
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH * 0.5, 4)];
    _selectView.backgroundColor = RGB(252, 100, 45);
    [_ungetBtn addSubview:_selectView];
    
    [LoadingView showLoadingView];
    [self segmentViewAction:_ungetBtn];
    
    __weak typeof(self) weakSelf = self;
    isLoading[0] = NO;
    isLoading[1] = NO;
    MJRefreshFooterView *_refreshFooterView1 = [MJRefreshFooterView footer];
    _refreshFooterView1.scrollView = _ungetTable;
    _refreshFooterView1.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView)
    {
        [weakSelf loadMore:0];
    };
    refreshFooterView[0] = _refreshFooterView1;
    
    MJRefreshFooterView *_refreshFooterView2 = [MJRefreshFooterView footer];
    _refreshFooterView2.scrollView = _hasGetTable;
    _refreshFooterView2.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView)
    {
        [weakSelf loadMore:1];
    };
    refreshFooterView[1] = _refreshFooterView2;
    
    MJRefreshHeaderView *_refreshHeaderView1 = [MJRefreshHeaderView header];
    _refreshHeaderView1.scrollView = _ungetTable;
    _refreshHeaderView1.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView)
    {
        [weakSelf refresh:0];
    };
    refreshHeaderView[0] = _refreshHeaderView1;
    
    MJRefreshHeaderView *_refreshHeaderView2 = [MJRefreshHeaderView header];
    _refreshHeaderView2.scrollView = _hasGetTable;
    _refreshHeaderView2.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView)
    {
        [weakSelf refresh:1];
    };
    refreshHeaderView[1] = _refreshHeaderView2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RedPackgeLibraryCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _ungetTable) {
        return [_ungetArray count];
    } else {
        return [_hasGetArray count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    if (tableView == self.ungetTable) {
        dic = self.ungetArray[indexPath.row];
    } else {
        dic = self.hasGetArray[indexPath.row];
    }
    static NSString *key = @"cellID";
    RedPackgeLibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[RedPackgeLibraryCell alloc] initWithStyle:0 reuseIdentifier:key];
    }
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", dic[@"title_1"]];
    cell.descLabel.text = [NSString stringWithFormat:@"%@", dic[@"shop_name"]];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@", dic[@"end_time"]];
    cell.moneyLabel.text = [NSString stringWithFormat:@"%.2f元", [dic[@"lingqu_money"] floatValue]];
    if (tableView == _ungetTable) {
        cell.moneyLabel.hidden = YES;
    } else {
        cell.moneyLabel.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    if (tableView == _ungetTable) {
        dic = _ungetArray[indexPath.row];
    } else {
        dic = _hasGetArray[indexPath.row];
    }
    
    
    RedPackgeLibraryDetailVC *detail2 = [[RedPackgeLibraryDetailVC alloc] init];
    detail2.dataDic = dic;
    detail2.ggid = dic[@"only_number"];
    NSMutableArray *ary = [NSMutableArray array];
    NSMutableArray *titleAry = [NSMutableArray array];
    
    if ([self isVaildURL:dic[@"title_url_1"]]) {
        [ary addObject:dic[@"title_url_1"]];
        
        if (dic[@"title_2"] != nil) {
           [titleAry addObject:dic[@"title_2"]];
        }else{
           [titleAry addObject:@""]; 
        }
    }
    if ([self isVaildURL:dic[@"title_url_2"]]) {
        [ary addObject:dic[@"title_url_2"]];
        [titleAry addObject:@""];
    }
    if ([self isVaildURL:dic[@"title_url_3"]]) {
        [ary addObject:dic[@"title_url_3"]];
        [titleAry addObject:@""];
    }
    if ([self isVaildURL:dic[@"title_url_4"]]) {
        [ary addObject:dic[@"title_url_4"]];
        [titleAry addObject:@""];
    }
    detail2.dataArray = ary;
    detail2.descArray = titleAry;
    detail2.timeString = dic[@"begin_time"];
    detail2.authorString = dic[@"shop_name"];
    detail2.nameString = dic[@"title_1"];
    detail2.title = dic[@"shop_name"];
    detail2.hasGetMoney = (tableView == _hasGetTable);
    [self.navigationController pushViewController:detail2 animated:NO];
    __weak typeof(self) weakSelf = self;
    detail2.block = ^(){
        [weakSelf refresh:0];
    };
}

- (void)segmentViewAction:(UIButton*)segmentView {
    _ungetBtn.selected = segmentView == _ungetBtn;
    _hasGetBtn.selected = segmentView == _hasGetBtn;
    self.hasGetTable.hidden = _ungetBtn.selected;
    self.ungetTable.hidden = _hasGetBtn.selected;
    if (_ungetBtn.selected) {
        [_ungetBtn addSubview:_selectView];
    } else {
        [_hasGetBtn addSubview:_selectView];
    }
    if (self.hasGetBtn.selected == YES) {
        if (self.hasGetArray.count == 0) {
            [LoadingView showLoadingView];
            [self requestHadGetRedPackage];
        }
    } else {
        if (self.ungetArray.count == 0) {
            
            [self requestUngetRedPackage];
        }
    }
}

- (void)requestHadGetRedPackage {
    isLoading[1] = YES;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"lingqu_user_id":uid,
                                 @"type":@"2",
                                 @"loadtype":[NSString stringWithFormat:@"%d",[startID[1] intValue] == 0 ? 1 : 1],
                                 @"time":startID[1]};
    [[RequestTool alloc] requestWithUrl:MY_RED_PACKGE_LIST
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         isLoading[1] = NO;
         NSLog(@"MY_RED_PACKGE_LIST===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             if ([startID[1] intValue] == 0) {
                 [_hasGetArray removeAllObjects];
             }
             NSArray *ary = dataDic[@"resultList"];
             if (ary && [ary isKindOfClass:[NSArray class]])
             {
                 if ( ary.count > 0)
                 {
                     [_hasGetArray addObjectsFromArray:ary];
                     startID[1] = [ary lastObject][@"update_time"];
                 }
                 else
                 {
                     [CommonTool addPopTipWithMessage:@"没有更多数据"];
                 }
                 
                 
             } else if (ary && [ary isKindOfClass:[NSDictionary class]]) {
                 [_hasGetArray addObject:ary];
                 startID[1] = ((NSDictionary*)ary)[@"update_time"];
             }
             [self.hasGetTable reloadData];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         [refreshFooterView[1] setState:MJRefreshStateNormal];
         [refreshHeaderView[1] setState:MJRefreshStateNormal];
     }
                            requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         isLoading[1] = NO;
         [LoadingView dismissLoadingView];
         NSLog(@"MY_RED_PACKGE_LIST====%@",error);
         [refreshFooterView[1] setState:MJRefreshStateNormal];
         [refreshHeaderView[1] setState:MJRefreshStateNormal];
     }];
}

- (void)requestUngetRedPackage {
    isLoading[0] = YES;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"lingqu_user_id":uid,
                                 @"type":@"4",
                                 @"loadtype":[NSString stringWithFormat:@"%d",[startID[0] intValue] == 0 ? 1 : 1],
                                 @"time":startID[0]};
    [[RequestTool alloc] requestWithUrl:MY_RED_PACKGE_LIST
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         isLoading[0] = NO;
         NSLog(@"MY_RED_PACKGE_LIST===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             if ([startID[0] intValue] == 0) {
                 [_ungetArray removeAllObjects];
             }
             NSArray *ary = dataDic[@"resultList"];
             if (ary && [ary isKindOfClass:[NSArray class]])
             {
                 if ( ary.count > 0)
                 {
                     [_ungetArray addObjectsFromArray:ary];
                     startID[0] = [ary lastObject][@"update_time"];
                 }
                 else
                 {
                     [CommonTool addPopTipWithMessage:@"没有更多数据"];
                 }
             } else if (ary && [ary isKindOfClass:[NSDictionary class]]) {
                 [_ungetArray addObject:ary];
                 startID[0] = ((NSDictionary*)ary)[@"update_time"];
             }
             [self.ungetTable reloadData];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         [refreshFooterView[0] setState:MJRefreshStateNormal];
         [refreshHeaderView[0] setState:MJRefreshStateNormal];
     }
                            requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         isLoading[0] = NO;
         [LoadingView dismissLoadingView];
         NSLog(@"MY_RED_PACKGE_LIST====%@",error);
         [refreshFooterView[0] setState:MJRefreshStateNormal];
         [refreshHeaderView[0] setState:MJRefreshStateNormal];
     }];
}

- (void)loadMore:(int)type {
    if (type == 0) {
        if (isLoading[0])
        {
            return;
        }
        [self requestUngetRedPackage];
    } else {
        if (isLoading[1])
        {
            return;
        }
        [self requestHadGetRedPackage];
    }
}

- (void)refresh:(int)type {
    startID[type] = @"";
    if (type == 0) {
        if (isLoading[0])
        {
            return;
        }
        [self requestUngetRedPackage];
    } else {
        if (isLoading[1])
        {
            return;
        }
        [self requestHadGetRedPackage];
    }
}
@end
