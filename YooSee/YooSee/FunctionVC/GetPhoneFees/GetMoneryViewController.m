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
@end

@implementation GetMoneryViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"看广告赚话费";
    _dataArray = [[NSMutableArray alloc] init];
    
    [self addBackItem];
    
    // Do any additional setup after loading the view.
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:UITableViewStylePlain tableDelegate:self];
    [self addRefreshHeaderView];
    [self addRefreshFooterView];
    [self refreshData];
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
    cell.nameLabel.text = dic[@"title"];
    NSString *logtime = dic[@"logtime"];
    logtime = [CommonTool dateString2MDString:logtime];
    cell.timeLabel.text = logtime;
    [cell.adView setImageWithURL:[NSURL URLWithString:dic[@"smallpic"]]];
    [cell dealHadGet:NO descTitle:[NSString stringWithFormat:@"%d亮币", [dic[@"leftnum"] intValue]]];
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.section];
    GetMoneyDetailViewController *detail = [[GetMoneyDetailViewController alloc] init];
    detail.dataDic = dic;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark -

- (void)request {
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid":uid,@"pageid":@(_currentPage),@"verytype":@"2"};
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
         if (errorCode == 1)
         {
             @synchronized(_dataArray) {
                 if (_currentPage == 1) {
                     [_dataArray removeAllObjects];
                 }
                 NSDictionary *dic = dataDic[@"body"];
                 NSArray *ary = dic[@"data"];
                 if (ary) {
                     [_dataArray addObjectsFromArray:ary];
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
         
         [LoadingView dismissLoadingView];
         NSLog(@"GET_AD_LIST====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
         [self.refreshFooterView setState:MJRefreshStateNormal];
         [self.refreshHeaderView setState:MJRefreshStateNormal];
     }];
}

- (void)refreshData {
    [super refreshData];
    [self request];
}

- (void)getMoreData {
    [super getMoreData];
    [self request];
}
@end
