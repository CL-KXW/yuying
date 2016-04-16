//
//  CashDetailedViewController.m
//  YooSee
//
//  Created by 周川 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "CashDetailedViewController.h"

#import "CashDetailedTableViewCell.h"
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"

#define SectionHeight 30

//typedef NS_ENUM(NSUInteger, ActionType) {
//    ActionType_up = 0,
//    ActionType_down,
//};

@interface CashDetailedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(weak,nonatomic) IBOutlet UITableView *myTableView;
@property(nonatomic,strong)NSMutableArray * dataSourceArray;

@property(nonatomic,strong)NSString *upId;
@property(nonatomic,strong)NSString *downId;
@property(nonatomic,strong)NSDateFormatter *formatter;
@property(nonatomic,strong)NSCalendar *calendar;
@property(nonatomic,strong)NSArray *weekArray;

@end

@implementation CashDetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = @"明细";
    self.myTableView.hidden = YES;

    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [self.formatter setDateFormat:@"yyyy-MM-dd"];
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //设置每周的第一天从星期几开始，比如：1代表星期日开始，2代表星期一开始，以此类推。默认值是1
    [self.calendar setFirstWeekday:2];
    self.weekArray = [NSArray arrayWithObjects:@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",nil];
    
    [self addTableViewWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) tableType:UITableViewStyleGrouped tableDelegate:self];
    [self.table registerNib:[UINib nibWithNibName:@"CashDetailedTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addRefreshHeaderView];
    [self addRefreshFooterView];
    self.refreshFooterView.hidden = YES;
    self.upId = @"0";
    self.downId = @"0";
    [self getMoreData];
}

#pragma mark - Getter
- (NSMutableArray *)dataSourceArray
{
    if (!_dataSourceArray) {
        _dataSourceArray = [[NSMutableArray alloc]init];
    }
    return _dataSourceArray;
}

#pragma mark -
- (void)refreshData {
    [super refreshData];
    
    //没有数据的时候当作刚进来的时候处理
    if (self.dataSourceArray.count == 0) {
        [self detailRequest:ActionType_up];
    }else{
        [self detailRequest:ActionType_down];
    }
}

- (void)getMoreData {
    [super getMoreData];
    [self detailRequest:ActionType_up];
}

#pragma mark - request
-(void)detailRequest:(ActionType)actionType{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        [self.refreshFooterView setState:MJRefreshStateNormal];
        [self.refreshHeaderView setState:MJRefreshStateNormal];
        return;
    }
    
    [LoadingView showLoadingView];
    
    //第一次 startid=0   loadtype=1 上拉
    //如果是下拉刷新，那后台传过来就是升序，客户端拿到之后，往列表的最前端插
    //如果是上拉加载更多，那后台传过来就是降序的
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    NSString *startid;
    if(actionType == ActionType_up){
        startid = self.upId;
        [requestDic setObject:@"1" forKey:@"loadtype"];
    }else{
        startid = self.downId;
        [requestDic setObject:@"2" forKey:@"loadtype"];
    }
    
    NSString *urlString = Url_sellerTurnoverCashDetail;
    if(self.type == CashDetailType_sellerCapitalLibrary){
        urlString = Url_sellerCapitalLibraryCashDetail;
        [requestDic setObject:[NSString stringWithFormat:@"%@",self.shop_number] forKey:@"shop_number"];
    }else if(self.type == CashDetailType_person){
        urlString = Url_personCashDetail;
        
        NSString *user_id = [YooSeeApplication shareApplication].uid;
        [requestDic setObject:user_id forKey:@"user_id"];
    }else if(self.type == CashDetailType_sellerTurnover){
        urlString = Url_sellerTurnoverCashDetail;
        [requestDic setObject:[NSString stringWithFormat:@"%@",self.shop_number] forKey:@"shop_number"];
    }
    
    [requestDic setObject:startid forKey:@"startid"];
    
    WeakSelf(weakSelf);
    
    [HttpManager postUrl:urlString parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        [self.refreshFooterView setState:MJRefreshStateNormal];
        [self.refreshHeaderView setState:MJRefreshStateNormal];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            NSArray *array = message.resultList;
            if(actionType == ActionType_up){
                if([array count] == 0){
                    [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
                }else{
                    for (NSDictionary *dic in array) {
                        [weakSelf.dataSourceArray addObject:dic];
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
                        [weakSelf.dataSourceArray insertObject:dic atIndex:0];
                    }
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
                }
            }
            if(weakSelf.dataSourceArray.count != 0){
                weakSelf.refreshFooterView.hidden = NO;
            }else{
                weakSelf.refreshFooterView.hidden = YES;
            }
            [self.table reloadData];
        }else if ([message.returnCode intValue] == 1){
            [SVProgressHUD showSuccessWithStatus:@"无请求数据"];
        }else if ([message.returnCode intValue] == 2){
            [SVProgressHUD showSuccessWithStatus:@"无此商家"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshFooterView setState:MJRefreshStateNormal];
        [self.refreshHeaderView setState:MJRefreshStateNormal];
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark - UITableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CashDetailedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = self.dataSourceArray[indexPath.section];
    if([dic[@"type"] intValue] == 1){
        //减
        cell.moneyLabel.text = [NSString stringWithFormat:@"-%.2f",[dic[@"money"] floatValue]];
        
        if(self.type == CashDetailType_person){
            //个人账户
            if ([dic[@"state"] intValue] == 1) {
                //提现
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_withdrawals"];
            }
        }else if (self.type == CashDetailType_sellerCapitalLibrary){
            //资金库
            if ([dic[@"state"] intValue] == 4) {
                //发广告
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_advertisement"];
            }else if([dic[@"state"] intValue] == 5){
                //提现
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_withdrawals"];
            }
        }else if (self.type == CashDetailType_sellerTurnover){
            //营业额
            cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_withdrawals"];
        }
    }else if ([dic[@"type"] intValue] ==  2){
        //加
        cell.moneyLabel.text = [NSString stringWithFormat:@"+%.2f",[dic[@"money"] floatValue]];
        if(self.type == CashDetailType_person){
            //个人账户
            if ([dic[@"state"] intValue] == 4) {
                //充值
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_recharge"];
            }else if([dic[@"state"] intValue] == 5){
                //提现
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_withdrawals"];
            }
        }else if (self.type == CashDetailType_sellerCapitalLibrary){
            //资金库
            if ([dic[@"state"] intValue] == 4) {
                //发广告
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_advertisement"];
            }else if([dic[@"state"] intValue] == 5){
                //充值
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_recharge"];
            }else if([dic[@"state"] intValue] == 6){
                //提现
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_withdrawals"];
            }
        }else if (self.type == CashDetailType_sellerTurnover){
            //营业额
            if([dic[@"state"] intValue] == 1){
                //提现
                cell.headerImageView.image = [UIImage imageNamed:@"CashDetail_withdrawals"];
            }
        }
    }else if ([dic[@"type"] intValue] == 3){
        //冻结
    }
    
    NSString *timeStr = dic[@"createtime"];
    NSString *day = [timeStr substringWithRange:NSMakeRange(0, 10)];
    NSDate *date = [self.formatter dateFromString:day];
    NSDateComponents *components = [self.calendar components:NSWeekOfMonthCalendarUnit | NSWeekdayCalendarUnit | NSCalendarUnitHour | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    
    // 星期几（注意，周日是“1”，周一是“2”。。。。）
    NSInteger weekday = [components weekday];
    weekday = weekday-1;
    cell.weekLabel.text = self.weekArray[weekday];
    cell.timeLabel.text = [timeStr substringWithRange:NSMakeRange(5, 5)];
    cell.contentLabel.text = [NSString stringWithFormat:@"%@",dic[@"content"]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SectionHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SectionHeight)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, SectionHeight)];
    NSDictionary *dic = self.dataSourceArray[section];
    label.text = dic[@"createtime"];
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    
    [view addSubview:label];
    return view;
}

@end
