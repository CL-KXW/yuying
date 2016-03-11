//
//  NewsListViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SECTION_HEIGHT              15.0  * CURRENT_SCALE
#define ROW_HEIGHT                  160.0 * CURRENT_SCALE

#import "NewsListViewController.h"
#import "NewsListCell.h"
#import "WebViewController.h"

@interface NewsListViewController ()

@end

@implementation NewsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"消息";
    [self addBackItem];
    
    [self initUI];
    
    if (!self.dataArray)
    {
        [self getNewsListRequest];
    }
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addTableView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
}

#pragma mark 获取消息
- (void)getNewsListRequest
{
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid":uid};
    [[RequestTool alloc] desRequestWithUrl:GET_HEADNEWS_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_HEADNEWS_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 1)
         {
             //[weakSelf setDataWithDictionary:dataDic];
             weakSelf.dataArray = dataDic[@"body"];
             [weakSelf.table reloadData];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"GET_HEADNEWS_URL====%@",error);
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:@"加载失败"];
     }];
}

#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEIGHT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    NewsListCell *cell = (NewsListCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"NewsListCell" owner:nil options:nil];
        cell = (NewsListCell *)[array lastObject];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dataDic = self.dataArray[indexPath.section];
    
    cell.headerImageView.image = [UIImage imageNamed:@"icon_news"];
    cell.nameLabel.text = dataDic[@"title"];
    cell.timeLabel.text = dataDic[@"logtime"];
    cell.titleLabel.text = dataDic[@"info"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dataDic = self.dataArray[indexPath.section];
    if ([dataDic[@"targettype"] integerValue] == 2)
    {
        NSString *url = dataDic[@"targetpage"];
        url = url ? url : @"";
        NSString *title = dataDic[@"title"];
        title = title ? title : @"点亮科技";
        if (url.length > 0)
        {
            WebViewController *webViewController = [[WebViewController alloc] init];
            webViewController.urlString = url;
            webViewController.title = title;
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
