//
//  CashDetailedViewController.m
//  YooSee
//
//  Created by 周川 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "CashDetailedViewController.h"
//#import "ScreenViewController.h"
#import "CashDetailedTableViewCell.h"

#define SectionHeight 30

@interface CashDetailedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(weak,nonatomic) IBOutlet UITableView *myTableView;
@property(nonatomic,strong)NSMutableArray * dataSourceArray;

@end

@implementation CashDetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"明细";
    [self.myTableView registerNib:[UINib nibWithNibName:@"CashDetailedTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self setNavBarItemWithTitle:@"筛选" navItemType:RightItem selectorName:@"rightItemClicked:"];
    [self.dataSourceArray addObject:@""];
}

#pragma mark - Getter
- (NSMutableArray *)dataSourceArray
{
    if (!_dataSourceArray) {
        _dataSourceArray = [[NSMutableArray alloc]init];
    }
    return _dataSourceArray;
}

#pragma mark - UITableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CashDetailedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SectionHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SectionHeight)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-10, SectionHeight)];
    label.text = @"1月";
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    
    [view addSubview:label];
    return view;
}

//#pragma mark - 右导航
//- (void)rightItemClicked:(UIButton *)button
//{
//    ScreenViewController * screen = [[ScreenViewController alloc]initWithNibName:@"ScreenViewController" bundle:nil];
//    [self.navigationController pushViewController:screen animated:NO];
//}

@end
