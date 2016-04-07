//
//  SellerRedLibaryViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/15.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerRedLibaryViewController.h"

#import "CommonThreeButtonTableViewCell.h"
#import "SellerRedLibaryRow0TableViewCell.h"
#import "SellerRedLibaryRow2TableViewCell.h"

#import "RedLibaryQRcodeViewController.h"

#define CellDefaultHeight 44

@interface SellerRedLibaryViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)NSString *maxId;

@end

@implementation SellerRedLibaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == DetailType_redLibary) {
        self.title = @"红包详情";
    }else if(self.type == DetailType_advertisement){
        self.title = @"广告详情";
    }
    
    self.maxId = @"0";
    
    [self addTableViewWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) tableType:UITableViewStyleGrouped tableDelegate:self];
    [self addRefreshHeaderView];
    self.refreshHeaderView.hidden = YES;
    [self addRefreshFooterView];
    self.refreshFooterView.hidden = YES;
    [self refreshData];
    
    UINib *nib1 = [UINib nibWithNibName:@"SellerRedLibaryRow0TableViewCell" bundle:nil];
    UINib *nib2 = [UINib nibWithNibName:@"CommonThreeButtonTableViewCell" bundle:nil];
    UINib *nib3 = [UINib nibWithNibName:@"SellerRedLibaryRow2TableViewCell" bundle:nil];
    [self.table registerNib:nib1 forCellReuseIdentifier:@"CELL1"];
    [self.table registerNib:nib2 forCellReuseIdentifier:@"CELL2"];
    [self.table registerNib:nib3 forCellReuseIdentifier:@"CELL3"];
    
    if(self.reject){
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CellDefaultHeight)];
        headView.backgroundColor = [UIColor redColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-10, CellDefaultHeight)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor clearColor];
        label.text = @"红包内容违规，已被强制驳回!";
        label.textColor = [UIColor whiteColor];
        [headView addSubview:label];
        self.table.tableHeaderView = headView;
    }
}

#pragma mark - init
-(NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = Alloc(NSMutableArray);
    }
    return _dataArray;
}

#pragma mark -
- (void)refreshData {
    [super refreshData];
    [self detailRequest];
}

- (void)getMoreData {
    [super getMoreData];
    [self detailRequest];
}

#pragma mark - Request
-(void)detailRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    NSString *shop_number = [YooSeeApplication shareApplication].userInfoDic[@"shop_number"];
    [requestDic setObject:shop_number forKey:@"shop_number"];
    [requestDic setObject:self.dic[@"only_number"] forKey:@"only_number"];
    [requestDic setObject:self.maxId forKey:@"startid"];
    
    WeakSelf(weakSelf);
    
    NSString *url;
    if (self.type == DetailType_redLibary) {
        url = [Url_Host stringByAppendingString:@"app/red/get/querybyShop_number"];
    }else if (self.type == DetailType_advertisement){
        url = [Url_Host stringByAppendingString:@"app/ab/get/querybyshop_number"];
    }
    
    [HttpManager postUrl:url parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        [self.refreshFooterView setState:MJRefreshStateNormal];
        [self.refreshHeaderView setState:MJRefreshStateNormal];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            NSArray *array = message.resultList;

            for (NSDictionary *dic in array) {
                [weakSelf.dataArray addObject:dic];
            }
            
            if([array count] == 0){
                [SVProgressHUD showSuccessWithStatus:@"无更多数据"];
            }else{
                NSDictionary *dic = [array lastObject];
                self.maxId = [NSString stringWithFormat:@"%@",dic[@"id"]];
            }

            if(weakSelf.dataArray.count != 0){
                weakSelf.refreshFooterView.hidden = NO;
            }else{
                weakSelf.refreshHeaderView.hidden = NO;
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

-(void)updateStatusRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:[NSString stringWithFormat:@"%@",self.dic[@"id"]] forKey:@"id"];
    
    WeakSelf(weakSelf);
    
    NSString *url;
    if (self.type == DetailType_redLibary) {
        url = [Url_Host stringByAppendingString:@"app/red/send/updateType"];
    }else if (self.type == DetailType_advertisement){
        url = [Url_Host stringByAppendingString:@"app/ab/updateType"];
    }
    
    [HttpManager postUrl:url parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            NSIndexPath *indpath = [NSIndexPath indexPathForRow:0 inSection:1];
            CommonThreeButtonTableViewCell *cell1 = [self.table cellForRowAtIndexPath:indpath];
            [cell1.button2 setTitle:@"已下架" forState:UIControlStateNormal];
            cell1.button2.userInteractionEnabled = NO;
            weakSelf.dic[@"type"] = [NSNumber numberWithInt:2];
            [self.table reloadData];
        }else if ([message.returnCode intValue] == 1){
            [SVProgressHUD showSuccessWithStatus:@"下架失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshFooterView setState:MJRefreshStateNormal];
        [self.refreshHeaderView setState:MJRefreshStateNormal];
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];

}

#pragma mark - UIButtonClick
-(void)lookButtonClick:(UIButton *)button{
    
}

-(void)downButtonClick:(UIButton *)button{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定下架?" message:@"下架后剩余金额将退回" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

-(void)qrCodeButtonClick:(UIButton *)button{
    @autoreleasepool {
        RedLibaryQRcodeViewController *vc = Alloc_viewControllerNibName(RedLibaryQRcodeViewController);
        if(self.type == DetailType_redLibary){
            vc.type = QRcodeType_redLibary;
        }else{
            vc.type = QRcodeType_advertisement;
        }
        vc.dic = self.dic;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self updateStatusRequest];
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 2){
        return [self.dataArray count]+1;
    }
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        SellerRedLibaryRow0TableViewCell *cell0 = [tableView dequeueReusableCellWithIdentifier:@"CELL1"];
        cell0.accessoryType = UITableViewCellAccessoryNone;
        cell0.selectionStyle = UITableViewCellSelectionStyleNone;
        cell0.statusLabel.layer.masksToBounds = YES;
        cell0.statusLabel.layer.cornerRadius = 20/2;
        
        cell0.nameLabel.text = self.dic[@"title_1"];
        cell0.startTimeLabel.text = [NSString stringWithFormat:@"%@",self.dic[@"begin_time"]];
        cell0.endTimeLabel.text = [NSString stringWithFormat:@"%@",self.dic[@"end_time"]];
        
        NSString *totalMoney = self.dic[@"fa_sum_money"];
        NSString *totalNumber = self.dic[@"fa_sum_number"];
        float money;
        int number = [totalNumber intValue]-[self.dic[@"lingqu_sum_number"] intValue];
        if(self.type == DetailType_advertisement){
            totalMoney = self.dic[@"guanggao_money"];
            money = [self.dic[@"shengyu_money"] floatValue];
            int totalnumber = (int)([totalMoney floatValue]/[self.dic[@"lingqu_money"] floatValue]);
            totalNumber = [NSString stringWithFormat:@"%d",totalnumber];
            number = totalnumber-[self.dic[@"lingqu_number"] intValue];
        }else{
            money = [totalMoney floatValue]-[self.dic[@"lingqu_sum_money"] floatValue];
        }
        cell0.totalMoneyLabel.text = [NSString stringWithFormat:@"%@元",totalMoney];
        cell0.totalNumberLabel.text = [NSString stringWithFormat:@"%@个",totalNumber];
        
        NSString *surplusMoney = [NSString stringWithFormat:@"%.2f元",money];
        cell0.surplusMoneyLabel.text = surplusMoney;
        cell0.retreatLabel.text = surplusMoney;
        cell0.surplusNumberLabel.text = [NSString stringWithFormat:@"%D个",number];
        
        if ([self.dic[@"type"] intValue] == 1) {
            cell0.statusLabel.text = @"进行中";
            if([self.dic[@"hongbao_type"] intValue] == 1){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_immediate"];
            }else if ([self.dic[@"hongbao_type"] intValue] == 2){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_qrCode"];
            }else if ([self.dic[@"hongbao_type"] intValue] == 3){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_shake"];
            }
        }else if([self.dic[@"type"] intValue] == 2){
            cell0.statusLabel.text = @"已结束";
            if([self.dic[@"hongbao_type"] intValue] == 1){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_immediateInvalid"];
            }else if ([self.dic[@"hongbao_type"] intValue] == 2){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_qrCodeInvalid"];
            }else if ([self.dic[@"hongbao_type"] intValue] == 3){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_shakeInvalid"];
            }
        }else if([self.dic[@"type"] intValue] == 3){
            cell0.statusLabel.text = @"被驳回";
            cell0.customImageView.image= [UIImage imageNamed:@"SellerRedLibaryDetail_reject"];
        }else if([self.dic[@"type"] intValue] == 4){
            cell0.statusLabel.text = @"未开始";
            if([self.dic[@"hongbao_type"] intValue] == 1){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_immediateInvalid"];
            }else if ([self.dic[@"hongbao_type"] intValue] == 2){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_qrCodeInvalid"];
            }else if ([self.dic[@"hongbao_type"] intValue] == 3){
                cell0.customImageView.image= [UIImage imageNamed:@"RedLibaryTypeList_shakeInvalid"];
            }
        }
        
        if (self.type == DetailType_advertisement) {
            cell0.customImageView.image = [UIImage imageNamed:@"Common_defaultImageLogo"];
            NSURL *url = [NSURL URLWithString:self.dic[@"url_1"]];
            [cell0.customImageView sd_setImageWithURL:url];
            cell0.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        return cell0;
    }else if (indexPath.section == 1){
        CommonThreeButtonTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"CELL2"];
        cell1.accessoryType = UITableViewCellAccessoryNone;
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *image = [UIImage imageNamed:@"SellerRedLibaryDetail_qdCode"];
        [cell1.button3 setImage:image forState:UIControlStateNormal];
        image = [UIImage imageNamed:@"SellerRedLibaryDetail_down"];
        [cell1.button2 setImage:image forState:UIControlStateNormal];
        image = [UIImage imageNamed:@"SellerRedLibaryDetail_look"];
        [cell1.button1 setImage:image forState:UIControlStateNormal];
        
        [cell1.button1 addTarget:self action:@selector(lookButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.button2 addTarget:self action:@selector(downButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.button3 addTarget:self action:@selector(qrCodeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.dic[@"type"] intValue] == 2 || [self.dic[@"type"] intValue] == 3) {
            [cell1.button2 setTitle:@"已下架" forState:UIControlStateNormal];
            cell1.button2.userInteractionEnabled = NO;
        }
        
        return cell1;
    }else{
        SellerRedLibaryRow2TableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"CELL3"];
        cell2.accessoryType = UITableViewCellAccessoryNone;
        cell2.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell2.rankingLabel.text = @"排名";
            cell2.timeLabel.text = @"时间";
            cell2.manLabel.text = @"领取人";
            cell2.moneyLabel.text = @"金额";
            cell2.statusLabel.text = @"状态";
        }else{
            NSDictionary *dic = self.dataArray[indexPath.row-1];
            
            cell2.rankingLabel.textColor = [UIColor lightGrayColor];
            cell2.timeLabel.textColor = [UIColor lightGrayColor];
            cell2.manLabel.textColor = [UIColor lightGrayColor];
            cell2.moneyLabel.textColor = [UIColor lightGrayColor];
            cell2.statusLabel.textColor = [UIColor lightGrayColor];
            
            cell2.rankingLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
            cell2.manLabel.text = dic[@"lingqu_user_phone"];
            cell2.moneyLabel.text = [NSString stringWithFormat:@"%.2f",[dic[@"lingqu_money"] floatValue]];
            
            if ([dic[@"type"] intValue] == 1) {
                cell2.statusLabel.text = @"未拆";
            }else if ([dic[@"type"] intValue] == 2){
                cell2.statusLabel.text = @"已领";
            }else if ([dic[@"type"] intValue] == 3){
                cell2.statusLabel.text = @"过期";
            }
            
            if(self.type == DetailType_advertisement){
                cell2.timeLabel.text = dic[@"lingqu_user_time"];
                cell2.statusLabel.text = @"已领";
            }else{
                cell2.timeLabel.text = dic[@"update_time"];
            }
        }
        
        return cell2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = CellDefaultHeight;
    
    switch (indexPath.section) {
        case 0:{
            height = 140;
        }
            break;
            
        case 1:{
            height = 50;
        }
            break;
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //分割线顶格
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
