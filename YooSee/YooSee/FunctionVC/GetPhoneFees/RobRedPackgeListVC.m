//
//  RobRedPackgeListVC.m
//  YooSee
//
//  Created by Shaun on 16/3/16.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RobRedPackgeListVC.h"
#import "RobRedPackgeListCell.h"
#import "RobRedPackgeDetailVC.h"

@implementation RobRedPackgeListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"抢红包";
    [self addBackItem];
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:1 tableDelegate:self];
    self.table.separatorStyle = 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RobRedPackgeListCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *key = @"cellID";
    RobRedPackgeListCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[RobRedPackgeListCell alloc] initWithStyle:0 reuseIdentifier:key];
    }
    [cell.iconImageView setImageWithURL:[NSURL URLWithString:@""]];
    cell.descLabel.text = @"测试测试";
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    label.textColor = [UIColor grayColor];
    label.text = @" 12:30 ";
    label.backgroundColor = [UIColor lightGrayColor];
    label.layer.cornerRadius = 2;
    label.layer.masksToBounds = YES;
    label.font = FONT(12);
    [label sizeToFit];
    label.frame = CGRectMake(0, 0, label.frame.size.width, 20);
    label.center = CGPointMake(SCREEN_WIDTH * 0.5, 25);
    [header addSubview:label];
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RobRedPackgeDetailVC *detail = [[RobRedPackgeDetailVC alloc] init];
    detail.redPackgeId = @"1";
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)request {
    
}
@end
