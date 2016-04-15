//
//  RedLibaryManageViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/15.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RedLibaryManageViewController.h"

#import "RedLibaryManageTableViewCell.h"
#import "SellerRedLibaryViewController.h"

//typedef NS_ENUM(NSUInteger, ActionType) {
//    ActionType_up = 0,
//    ActionType_down,
//};

#define CellDefaultHeight 105
#define SectionHeight 30

@interface RedLibaryManageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@property(nonatomic,strong)NSString *upId;
@property(nonatomic,strong)NSString *downId;
@property(nonatomic,strong)NSMutableArray *dataSourceArray;

@end

@implementation RedLibaryManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    if (self.type == ManageType_redLibary) {
        self.title = @"红包管理";
    }else if (self.type == ManageType_advertisement){
        self.title = @"赚钱广告管理";
    }
    
    self.tableView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    [self addTableViewWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) tableType:UITableViewStylePlain tableDelegate:self];
    UINib *nib = [UINib nibWithNibName:@"RedLibaryManageTableViewCell" bundle:nil];
    [self.table registerNib:nib forCellReuseIdentifier:@"Cell"];

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
        [self redLibaryListRequest:ActionType_up];
    }else{
        [self redLibaryListRequest:ActionType_down];
    }
}

- (void)getMoreData {
    [super getMoreData];
    [self redLibaryListRequest:ActionType_up];
}

#pragma mark - Request
-(void)redLibaryListRequest:(ActionType)actionType{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
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
    
    [requestDic setObject:[NSString stringWithFormat:@"%@",self.shop_number] forKey:@"shop_number"];
    [requestDic setObject:startid forKey:@"startid"];
    
    WeakSelf(weakSelf);
    
    NSString *url;
    if (self.type == ManageType_redLibary) {
        url = [Url_Host stringByAppendingString:@"app/red/send/querybyShop_number"];
    }else if (self.type == ManageType_advertisement){
        url = [Url_Host stringByAppendingString:@"app/ab/query"];
    }

    [HttpManager postUrl:url parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        [self.refreshFooterView setState:MJRefreshStateNormal];
        [self.refreshHeaderView setState:MJRefreshStateNormal];
  
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            NSArray *array = message.resultList;
            if(actionType == ActionType_up){
                for (NSDictionary *dic in array) {
                    NSMutableDictionary *mutabledic = [[NSMutableDictionary alloc] initWithDictionary:dic];
                    [weakSelf.dataSourceArray addObject:mutabledic];
                }
                
                if([array count] == 0){
                    [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
                }else{
                    NSDictionary *dic;
                    
                    if([self.upId intValue] == 0){
                        dic = [array firstObject];
                        self.downId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                    }
                    dic = [array lastObject];
                    self.upId = [NSString stringWithFormat:@"%@",dic[@"id"]];
                }
            }else{
                for (NSDictionary *dic in array) {
                    [weakSelf.dataSourceArray insertObject:dic atIndex:0];
                }
                
                if([array count] != 0){
                    NSDictionary *dic = [array lastObject];
                    weakSelf.downId = [NSString stringWithFormat:@"%@",dic[@"id"]];
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

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSourceArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RedLibaryManageTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
    cell1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell1.selectionStyle = UITableViewCellSelectionStyleGray;
    NSDictionary *dic = self.dataSourceArray[indexPath.row];
    
    if (self.type == ManageType_advertisement){
        cell1.customImageView.image = [UIImage imageNamed:@"Common_defaultImageLogo"];
        NSURL *url = [NSURL URLWithString:dic[@"url_1"]];
        [cell1.customImageView sd_setImageWithURL:url];
        cell1.contentMode = UIViewContentModeScaleAspectFit;
        cell1.nameLabel.text = dic[@"content_1"];
    }else{
        cell1.nameLabel.text = dic[@"title_1"];
        
        if ([dic[@"type"] intValue] == 1) {
            //进行中
            if([dic[@"hongbao_type"] intValue] == 1){
                //即时红包
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_immediate"];
            }else if ([dic[@"hongbao_type"] intValue] == 2){
                //摇一摇
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_shake"];
            }else if ([dic[@"hongbao_type"] intValue] == 3){
                //扫码红包
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_qrCode"];
            }
        }else if([dic[@"type"] intValue] == 2){
            //已结束
            if([dic[@"hongbao_type"] intValue] == 1){
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_immediateInvalid"];
            }else if ([dic[@"hongbao_type"] intValue] == 2){
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_shakeInvalid"];
            }else if ([dic[@"hongbao_type"] intValue] == 3){
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_qrCodeInvalid"];
            }
        }else if([dic[@"type"] intValue] == 3){
            //被驳回
            cell1.customImageView.image= [UIImage imageNamed:@"SellerRedLibaryDetail_reject"];
        }else if([dic[@"type"] intValue] == 4){
            //未开始
            if([dic[@"hongbao_type"] intValue] == 1){
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_immediateInvalid"];
            }else if ([dic[@"hongbao_type"] intValue] == 2){
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_shakeNoStart"];
            }else if ([dic[@"hongbao_type"] intValue] == 3){
                cell1.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_qrCodeInvalid"];
            }
        }
    }
    
    NSString *totalMoney = dic[@"fa_sum_money"];
    NSString *totalNumber = dic[@"fa_sum_number"];
    float money;
    int number = [totalNumber intValue]-[dic[@"lingqu_sum_number"] intValue];
    if(self.type == ManageType_advertisement){
        totalMoney = dic[@"guanggao_money"];
        money = [dic[@"shengyu_money"] floatValue];
        int totalnumber = (int)([totalMoney floatValue]/[dic[@"lingqu_money"] floatValue]);
        totalNumber = [NSString stringWithFormat:@"%d",totalnumber];
        number = totalnumber-[dic[@"lingqu_number"] intValue];
    }else{
        money = [totalMoney floatValue]-[dic[@"lingqu_sum_money"] floatValue];
    }
    cell1.totalMoneyLabel.text = [NSString stringWithFormat:@"%@元",totalMoney];
    cell1.totalNumberLabel.text = [NSString stringWithFormat:@"%@个",totalNumber];

    NSString *surplusMoney = [NSString stringWithFormat:@"%.2f元",money];
    cell1.surplusMoneyLabel.text = surplusMoney;
    
    cell1.surplusNumberLabel.text = [NSString stringWithFormat:@"%D个",number];
    cell1.timeLabel.text = [NSString stringWithFormat:@"开始时间:%@",dic[@"begin_time"]];
    
    return cell1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = CellDefaultHeight;
    return height;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    return SectionHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //分割线顶格
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *dic = self.dataSourceArray[indexPath.row];
    @autoreleasepool {
        SellerRedLibaryViewController *vc = Alloc_viewControllerNibName(SellerRedLibaryViewController);

        vc.dic = dic;
        if (self.type == ManageType_advertisement) {
            vc.type = DetailType_advertisement;
            
            if ([dic[@"type"] intValue] == 4) {
                vc.reject = YES;
            }
        }else if(self.type == ManageType_redLibary){
            vc.type = DetailType_redLibary;
            
            if ([dic[@"type"] intValue] == 3) {
                vc.reject = YES;
            }
        }
        vc.shop_number = self.shop_number;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
