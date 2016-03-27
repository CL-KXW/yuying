//
//  MoneyDetailVC.m
//  YooSee
//
//  Created by Shaun on 16/3/13.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "MoneyDetailVC.h"
#import "MarqueeLabel.h"

@implementation MoneyDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.title = @"现金明细";
    self.detailArray = [NSMutableArray array];
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:0 tableDelegate:self];
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
    NSString *time    = _detailArray[indexPath.row][@"logtime"];
    if(time.length > 19)
        time = [time substringToIndex:19];
    timeLabel.text = time;
    
    MarqueeLabel *contentLabel = (MarqueeLabel*)[cell.contentView viewWithTag:101];
    contentLabel.text = _detailArray[indexPath.row][@"info"];
    return cell;
}

@end
