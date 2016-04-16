//
//  RedLibaryTypeListViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RedLibaryTypeListViewController.h"

#import "RedLibaryTypeListTableViewCell.h"
#import "SendRedLibaryViewController.h"

@interface RedLibaryTypeListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSArray *imageArray;
@property(nonatomic,strong)NSArray *nameArray;
@property(nonatomic,strong)NSArray *contentArray;

@end

@implementation RedLibaryTypeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = @"发红包";
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"RedLibaryTypeListTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.imageArray = @[@"RedLibaryTypeList_immediate",@"RedLibaryTypeList_qrCode",@"RedLibaryTypeList_shake"];
    self.nameArray = @[@"即时红包",@"扫码红包",@"摇一摇红包"];
    self.contentArray = @[@"该类型红包,将发布在主页面抢红包板块,所选区域的人都可见,红包金额随机。",@"该类型红包,不会显示在任何板块中,只有通过扫描二维码,才可以进入,红包金额随机。",@"该类型红包,将发布在主页面摇一摇板块，设定开始时间,预约参与的用户可以抢,红包金额随机。"];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    footView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footView;
}

#pragma mark -
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RedLibaryTypeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    cell.customImageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.titleLabel.text = self.nameArray[indexPath.row];
    cell.contentLabel.text = self.contentArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @autoreleasepool {
        SendRedLibaryViewController *vc = Alloc_viewControllerNibName(SendRedLibaryViewController);
        switch (indexPath.row) {
            case 0:
            {
                vc.type = RedLibaryType_immediate;
            }
                break;
                
            case 1:
            {
                vc.type = RedLibaryType_qrCode;
            }
                break;
                
            case 2:
            {
                vc.type = RedLibaryType_shake;
            }
                break;
        }
        vc.shop_number = self.shop_number;
        [self.navigationController pushViewController:vc animated:YES];
    }
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

@end
