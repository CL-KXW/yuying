//
//  LookDetailViewController.m
//  YooSee
//
//  Created by 周后云 on 16/4/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "LookDetailViewController.h"

#define SectionHeight 20
#define CellDefaultHeight 500

@interface LookDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *tableArray;

@end

@implementation LookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = self.dic[@"shop_name"];
    self.tableArray = Alloc(NSMutableArray);

    if (self.type == LookDetail_redLibary) {
        NSString *string = self.dic[@"title_url_1"];
        if (string.length != 0) {
            [self.tableArray addObject:string];
        }
        
        string = self.dic[@"title_url_2"];
        if (string.length != 0) {
            [self.tableArray addObject:string];
        }
        
        string = self.dic[@"title_url_3"];
        if (string.length != 0) {
            [self.tableArray addObject:string];
        }
    }else if (self.type == LookDetail_advertisement){
        NSString *string = self.dic[@"url_1"];
        if (string.length != 0) {
            [self.tableArray addObject:string];
        }
        
        string = self.dic[@"url_2"];
        if (string.length != 0) {
            [self.tableArray addObject:string];
        }
        
        string = self.dic[@"url_3"];
        if (string.length != 0) {
            [self.tableArray addObject:string];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, SCREEN_WIDTH, CellDefaultHeight-4)];
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageview];
        imageview.tag = 100;
    }
    
    UIImageView *imageview = [cell.contentView viewWithTag:100];
    [imageview sd_setImageWithURL:[NSURL URLWithString:self.tableArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"Common_defaultImageLogo"]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CellDefaultHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SectionHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SectionHeight)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, SectionHeight)];
    label.text = self.dic[@"begin_time"];
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    [view addSubview:label];
    
    return view;
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
