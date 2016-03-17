//
//  RedPackgeLibraryVC.m
//  YooSee
//
//  Created by Shaun on 16/3/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RedPackgeLibraryVC.h"
#import "RedPackgeLibraryCell.h"
@interface RedPackgeLibraryVC ()
@property (nonatomic, strong) NSMutableArray *hasGetArray;
@property (nonatomic, strong) NSMutableArray *ungetArray;
@property (nonatomic, strong) UITableView *ungetTable;
@property (nonatomic, strong) UITableView *hasGetTable;

@property (nonatomic, strong) UIView *segmentView;
@property (nonatomic, strong) UIButton *hasGetBtn;
@property (nonatomic, strong) UIButton *ungetBtn;
@property (nonatomic, strong) UIView *selectView;
@end
@implementation RedPackgeLibraryVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.title = @"红包库";
    self.hasGetArray = [NSMutableArray array];
    [self.hasGetArray addObject:@"1"];
    [self.hasGetArray addObject:@"1"];
    [self.hasGetArray addObject:@"1"];

    self.ungetArray = [NSMutableArray array];
    [self.ungetArray addObject:@"1"];
    [self.ungetArray addObject:@"1"];
    [self.ungetArray addObject:@"1"];
    [self.ungetArray addObject:@"1"];
    [self performSelector:@selector(initViews) withObject:nil afterDelay:0.1];
}

- (void)initViews {
    _hasGetTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + 64, SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 64) style:0];
    _hasGetTable.dataSource = self;
    _hasGetTable.delegate = self;
    _hasGetTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_hasGetTable];
    UIView *view = [UIView new];
    _hasGetTable.tableFooterView = view;
    _hasGetTable.hidden = YES;
    
    
    _ungetTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 44 + 64, SCREEN_WIDTH, SCREEN_HEIGHT - 44 - 64) style:0];
    _ungetTable.dataSource = self;
    _ungetTable.delegate = self;
    _ungetTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_ungetTable];
    view = [UIView new];
    _ungetTable.tableFooterView = view;
    
    _segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 44)];
    _segmentView.backgroundColor = [UIColor whiteColor];
    UIView *lineX = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, SCREEN_WIDTH, 0.5)];
    lineX.backgroundColor = [UIColor lightGrayColor];
    [_segmentView addSubview:lineX];
    
    _ungetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.5, 44)];
    [_ungetBtn setTitle:@"未收" forState:UIControlStateNormal];
    [_ungetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateSelected];
    [_ungetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateHighlighted];
    [_ungetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_ungetBtn addTarget:self action:@selector(segmentViewAction:) forControlEvents:UIControlEventTouchUpInside];
    _ungetBtn.titleLabel.font = FONT(15);
    [_segmentView addSubview:_ungetBtn];
    
    _hasGetBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5, 0, SCREEN_WIDTH * 0.5, 44)];
    [_hasGetBtn setTitle:@"已收" forState:UIControlStateNormal];
    [_hasGetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateSelected];
    [_hasGetBtn setTitleColor:RGB(252, 100, 45) forState:UIControlStateHighlighted];
    [_hasGetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_hasGetBtn addTarget:self action:@selector(segmentViewAction:) forControlEvents:UIControlEventTouchUpInside];
    _hasGetBtn.titleLabel.font = FONT(15);
    [_segmentView addSubview:_hasGetBtn];
    
    [self.view addSubview:_segmentView];
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH * 0.5, 4)];
    _selectView.backgroundColor = RGB(252, 100, 45);
    [_ungetBtn addSubview:_selectView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RedPackgeLibraryCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _ungetTable) {
        return [_hasGetArray count];
    } else {
        return [_ungetArray count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *key = @"cellID";
    RedPackgeLibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[RedPackgeLibraryCell alloc] initWithStyle:0 reuseIdentifier:key];
    }
    cell.nameLabel.text = @"gagagaga";
    cell.descLabel.text = @"hahahahaha";
    cell.timeLabel.text = @"2016.10.10";
    cell.moneyLabel.text = @"0.25元";
    if (tableView == _ungetTable) {
        cell.moneyLabel.hidden = YES;
    } else {
        cell.moneyLabel.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)segmentViewAction:(UIButton*)segmentView {
    _ungetBtn.selected = segmentView == _ungetBtn;
    _hasGetBtn.selected = segmentView == _hasGetBtn;
    self.hasGetTable.hidden = _ungetBtn.selected;
    self.ungetTable.hidden = _hasGetBtn.selected;
    if (_ungetBtn.selected) {
        [_ungetBtn addSubview:_selectView];
    } else {
        [_hasGetBtn addSubview:_selectView];
    }
}
@end
