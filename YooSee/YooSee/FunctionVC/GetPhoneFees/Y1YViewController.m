//
//  Y1YViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "Y1YViewController.h"
#import "Y1YDetailViewController.h"

@interface Y1YViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation Y1YViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"摇一摇";
    [self addBackItem];
    _dataArray = [NSMutableArray array];
    // Do any additional setup after loading the view.
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addRefreshHeaderView];
    [self addRefreshFooterView];
    [self refreshData];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (SCREEN_WIDTH-20)/2+100;
    //return [AdListCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     {
     begintime = "2016-03-28 15:38:00.0";
     endtime = "2016-03-28 15:38:00.0";
     ggid = 2598;
     ifread = Y;
     ifwin = N;
     largepic = "http://112.74.135.133/yywht/uploadfile/ggpic/093800380_1.PNG";
     moneytype = 3;
     ordertype = 1;
     robsum = null;
     smallpic = "http://112.74.135.133/yywht/uploadfile/ggpic/0959535953_1.JPG";
     state = 1;
     title = "\U6d4b\U8bd5";
     }
     */
    static NSString *identify = @"identifyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    //    cell.contentView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 10,SCREEN_WIDTH-20, (self.view.frame.size.width-20)/2+100-20)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        view.layer.cornerRadius = 10.0f;
        view.layer.masksToBounds = YES;
        
        //创建头像
        UIImageView *ImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-20, (SCREEN_WIDTH-20)/2)];
        ImageV.backgroundColor = [UIColor whiteColor];
        ImageV.tag = 105;
        [view addSubview:ImageV];
        
        //创建子视图
        //1.创建标题label
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,(SCREEN_WIDTH-20)/2+10 , SCREEN_WIDTH-30,20)];
        titleLabel.tag = 101;
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [view addSubview:titleLabel];
        
        UIView *va = [[UIView alloc]initWithFrame:CGRectMake(0, (SCREEN_WIDTH-20)/2+10+30, SCREEN_WIDTH-20, 1)];
        va.backgroundColor =[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        [view addSubview:va];
        
        
        //4.什么时候开抢红包
        UILabel *timeLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(20, (SCREEN_WIDTH-20)/2+50, SCREEN_WIDTH-30,20)];
        timeLabel4.tag = 104;
        timeLabel4.textColor = [UIColor orangeColor];
        //timeLabel4.backgroundColor = [UIColor yellowColor];
        timeLabel4.font = [UIFont systemFontOfSize:14];
        [view addSubview:timeLabel4];
        
        
        UILabel *timeLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-225+110, (SCREEN_WIDTH-20)/2+50, 80, 20)];
        timeLabel5.tag = 107;
        timeLabel5.textColor = [UIColor blackColor];
        timeLabel5.backgroundColor = [UIColor orangeColor];
        timeLabel5.font = [UIFont systemFontOfSize:14];
        timeLabel5.textAlignment = NSTextAlignmentCenter;
        [view addSubview:timeLabel5];
        
    }
    
    UIImageView *ImageV =[cell.contentView viewWithTag:105];
    
    //2.向子视图填充数据
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    //    UILabel *commentLabel = (UILabel *)[cell.contentView viewWithTag:102];
    //    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:103];
    UILabel *timeLabel4 = (UILabel *)[cell.contentView viewWithTag:104];
    UILabel *timeLabel5 = (UILabel *)[cell.contentView viewWithTag:107];
    
    
    NSDictionary *dataDic = _dataArray[indexPath.row];
    //NSLog(@"dataDic == %@",dataDic);
    NSString *title= [dataDic objectForKey:@"title"];
    NSString *smallpic = [dataDic objectForKey:@"smallpic"];
    
    NSURL *url = [NSURL URLWithString:smallpic];
    [ImageV setImageWithURL:url placeholderImage:[UIImage imageNamed:@"qhbletup.jpg"]];
    
    
    
    titleLabel.text = title;//@"鱼鹰手机广告精准投放平台5000000金币红包等你抢"; //dataDic[@"title"];
    
    NSString *begintime = [dataDic objectForKey:@"begintime"];
    NSString *month, *day, *hour, *minute;
    NSRange rang1 = NSMakeRange(5, 1);
    month = [begintime substringWithRange:rang1];
    if ([month intValue]==0) {
        NSRange rang2 = NSMakeRange(6, 1);
        month = [begintime substringWithRange:rang2];
    }else {
        NSRange rang3 = NSMakeRange(5, 2);
        month = [begintime substringWithRange:rang3];
    }
    
    NSRange rang4 = NSMakeRange(8, 2);
    day = [begintime substringWithRange:rang4];
    
    NSRange rang7 = NSMakeRange(11, 1);
    hour = [begintime substringWithRange:rang7];
    if ([hour intValue]==0) {
        NSRange rang8 = NSMakeRange(12, 1);
        hour = [begintime substringWithRange:rang8];
        
        
    }else {
        NSRange rang9 = NSMakeRange(11, 2);
        hour = [begintime substringWithRange:rang9];
    }
    //NSLog(@"hour == %@",hour);
    
    NSRange rang10 = NSMakeRange(14, 2);
    minute = [begintime substringWithRange:rang10];
    
    timeLabel4.text = [NSString stringWithFormat:@"%@月%@日 %@:%@ 红包准时抢",month,day,hour,minute];
    
    NSString *ifwin = [dataDic objectForKey:@"ifwin"];
    if ([ifwin isEqualToString:@"Y"]) {
        timeLabel5.text = @"抢到红包";
    }else if ([ifwin isEqualToString:@"U"]){
        timeLabel5.text  = @"未抢到";
    }else if ([ifwin isEqualToString:@"N"]){
        timeLabel5.backgroundColor = [UIColor clearColor];
        timeLabel5.text = @"";
        
    }
    
    
    
    cell.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    ;
    return cell;
    
//    static NSString *cellID = @"cellID";
//    AdListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//    if (!cell) {
//        cell = [[AdListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//    }
//    cell.nameLabel.text = dic[@"title"];
//    NSString *logtime = dic[@"logtime"];
//    logtime = [CommonTool dateString2MDString:logtime];
//    cell.timeLabel.text = logtime;
//    [cell.adView setImageWithURL:[NSURL URLWithString:dic[@"smallpic"]]];
//    [cell dealHadGet:NO descTitle:[NSString stringWithFormat:@"%d亮币", [dic[@"leftnum"] intValue]]];
//    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.row];
    Y1YDetailViewController *detail = [[Y1YDetailViewController alloc] init];
    detail.dataDic = dic;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark -

- (void)request {
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{
                                 @"uid":uid,
                                 @"pageid":@(_currentPage),
                                 @"type":@(1),
                                 @"pagenum":@(5)};
    [[RequestTool alloc] getRequestWithUrl:GET_Y1Y_LIST
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_Y1Y_LIST===%@",responseDic);
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
                 NSArray *ary = dic[@"redpacketlist"];
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
         NSLog(@"GET_Y1Y_LIST====%@",error);
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
