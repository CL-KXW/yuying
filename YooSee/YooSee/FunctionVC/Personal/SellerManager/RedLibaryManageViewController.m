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

#define CellDefaultHeight 110
#define SectionHeight 30

@interface RedLibaryManageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@end

@implementation RedLibaryManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"红包管理";
    UINib *nib = [UINib nibWithNibName:@"RedLibaryManageTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1+3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-10, 50)];
        label.font = [UIFont systemFontOfSize:14];
        label.tag = 10;
        [cell.contentView addSubview:label];
    }
    
    if(indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *string = [NSString stringWithFormat:@"累计发红包总金额:4556元"];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        UIColor *color = [UIColor blackColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, 9)];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(string.length-1,1)];
        color =[ UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(9, string.length-10)];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:10];
        label.attributedText = attrString;
    }else{
        RedLibaryManageTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        cell1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell1.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell1;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = CellDefaultHeight;
    
    if(indexPath.section == 0){
        return 50;
    }
    
    return height;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SectionHeight)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-10, SectionHeight)];
    label.text = @"1月";
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    
    [view addSubview:label];
    return view;
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
    
    @autoreleasepool {
        SellerRedLibaryViewController *vc = Alloc_viewControllerNibName(SellerRedLibaryViewController);
        vc.progressing = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
