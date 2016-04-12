//
//  MoneyDetailVC.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "MoneyDetailVC.h"
#import "MarqueeLabel.h"

@interface MoneyDetailVC ()

@property(nonatomic,strong)NSString *upId;
@property(nonatomic,strong)NSString *downId;

@end

@implementation MoneyDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.title = @"现金明细";
    self.upId = @"0";
    self.downId = @"0";
    self.detailArray = [NSMutableArray array];
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:0 tableDelegate:self];
    [self addRefreshHeaderView];
    [self addRefreshFooterView];
    [self refreshData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.detailArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellname = @"cellname";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellname];
        cell.selectionStyle = 0;
        NSString *temp = @"2015-07-08 12:24:10";
        CGSize size = [temp sizeWithAttributes:@{NSFontAttributeName:FONT(15)}];
        
        UILabel *tiemLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, size.width,cell.frame.size.height)];
        tiemLabel.textColor = [UIColor lightGrayColor];
        tiemLabel.font      = FONT(15);
        tiemLabel.tag       = 100;
        
        NSInteger x     = CGRectGetMaxX(tiemLabel.frame) + 10;
        NSInteger width = SCREEN_WIDTH - x - 20;
        
        MarqueeLabel *contentLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(x, 0, width, cell.frame.size.height) duration:8 andFadeLength:10];
        contentLabel.marqueeType    = MLContinuous;
        contentLabel.trailingBuffer = 100;
        contentLabel.textAlignment  = NSTextAlignmentCenter;
        contentLabel.textColor = [UIColor lightGrayColor];
        contentLabel.font      = FONT(15);
        contentLabel.tag = 101;
        
        
        [cell.contentView addSubview:tiemLabel];
        [cell.contentView addSubview:contentLabel];
    }
    
    UILabel *timeLabel = (UILabel*)[cell.contentView viewWithTag:100];
    NSString *time    = _detailArray[indexPath.row][@"createtime"];
    if(time.length > 19)
        time = [time substringToIndex:19];
    timeLabel.text = time;
    
    MarqueeLabel *contentLabel = (MarqueeLabel*)[cell.contentView viewWithTag:101];
    contentLabel.text = _detailArray[indexPath.row][@"tixian_money"];
    return cell;
}

- (void)request:(ActionType)actionType {
    //GET_TIXIAN_LIST
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *startid;
    NSString *loadtype;
    if(actionType == ActionType_up){
        startid = self.upId;
        loadtype = @"1";
    }else{
        startid = self.downId;
        loadtype = @"2";
    }
    NSDictionary *requestDic = @{@"user_id":uid,
                                 @"loadtype":loadtype,
                                 @"startid":startid};
    WeakSelf(weakSelf);
    [[RequestTool alloc] requestWithUrl:GET_TIXIAN_LIST
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
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
                         [_detailArray addObject:dic];
                     }
                     
                     NSDictionary *dic = [array lastObject];
                     
                     if([self.upId intValue] == 0){
                         dic = [array firstObject];
                         self.downId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                     }
                     
                     self.upId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                 }
             }else{
                 if([array count] != 0){
                     NSDictionary *dic = [array lastObject];
                     weakSelf.downId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                     
                     for (NSDictionary *dic in array) {
                         [_detailArray insertObject:dic atIndex:0];
                     }
                 }else{
                     [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
                 }
             }
             if(_detailArray.count != 0){
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
     }requestFail:^(AFHTTPRequestOperation *operation, NSError *error){
         [LoadingView dismissLoadingView];
         [self.refreshFooterView setState:MJRefreshStateNormal];
         [self.refreshHeaderView setState:MJRefreshStateNormal];
     }];
}

- (void)refreshData
{
    [super refreshData];
    
    //没有数据的时候当作刚进来的时候处理
    if (_detailArray.count == 0) {
        [self request:ActionType_up];
    }else{
        [self request:ActionType_down];
    }
}

- (void)getMoreData
{
    [super getMoreData];
    [self request:ActionType_up];
}
@end
