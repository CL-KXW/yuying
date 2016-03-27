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

@interface SellerRedLibaryViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation SellerRedLibaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"红包详情";
    UINib *nib1 = [UINib nibWithNibName:@"SellerRedLibaryRow0TableViewCell" bundle:nil];
    UINib *nib2 = [UINib nibWithNibName:@"CommonThreeButtonTableViewCell" bundle:nil];
    UINib *nib3 = [UINib nibWithNibName:@"SellerRedLibaryRow2TableViewCell" bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:@"CELL1"];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"CELL2"];
    [self.tableView registerNib:nib3 forCellReuseIdentifier:@"CELL3"];
    
    if(!self.progressing){
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CellDefaultHeight)];
        headView.backgroundColor = [UIColor redColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-10, CellDefaultHeight)];
        label.font = [UIFont systemFontOfSize:14];
        label.tag = 10;
        label.textColor = [UIColor clearColor];
        label.text = @"红包内容违规，已被强制驳回!";
        [headView addSubview:label];
        self.tableView.tableHeaderView = headView;
    }
}

#pragma mark - init
-(NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = Alloc(NSMutableArray);
    }
    return _dataArray;
}

#pragma mark - UIButtonClick
-(void)lookButtonClick:(UIButton *)button{
    
}

-(void)downButtonClick:(UIButton *)button{
    
}

-(void)qrCodeButtonClick:(UIButton *)button{
    @autoreleasepool {
        RedLibaryQRcodeViewController *vc = Alloc_viewControllerNibName(RedLibaryQRcodeViewController);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 2){
        return arc4random()%10;
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
        
        if(self.progressing){
            cell0.customImageView.image = [UIImage imageNamed:@"SellerRedLibaryDetail_processing"];
            cell0.statusLabel.text = @"进行中";
        }else{
            cell0.customImageView.image = [UIImage imageNamed:@"SellerRedLibaryDetail_reject"];
            cell0.statusLabel.text = @"被驳回";
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
        }else{
            cell2.rankingLabel.textColor = [UIColor lightGrayColor];
            cell2.timeLabel.textColor = [UIColor lightGrayColor];
            cell2.manLabel.textColor = [UIColor lightGrayColor];
            cell2.moneyLabel.textColor = [UIColor lightGrayColor];
            cell2.rankingLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
            cell2.timeLabel.text = @"2016-02-08 15:23:12";
            cell2.manLabel.text = @"12345678901";
            cell2.moneyLabel.text = @"2323.23元";
        }
        
        return cell2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 44;
    
    switch (indexPath.section) {
        case 0:{
            height = 120;
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
