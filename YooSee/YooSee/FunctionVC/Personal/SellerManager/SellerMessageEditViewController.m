//
//  SellerMessageEditViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/29.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerMessageEditViewController.h"

@interface SellerMessageEditViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@property(nonatomic,strong)UIButton *logoButton;
@property(nonatomic,strong)UITextField *professionTypeField;
@property(nonatomic,strong)UITextField *sellNameField;
@property(nonatomic,strong)UITextField *phoneField;
@property(nonatomic,strong)UITextField *contentField;
@property(nonatomic,strong)UITextField *addressField;

@end

@implementation SellerMessageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.title = @"编辑";
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *cellIdentifier = [NSString stringWithFormat:@"1"];
//    UITableViewCell *cell;
//    if(indexPath.row == 0){
//        cellIdentifier = @"0";
//        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if(!cell){
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
//        }
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        
//        cell.textLabel.text = self.cellTextArray[indexPath.section];
//        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        
//        cell.detailTextLabel.text = @"查看明细";
//        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
//        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
//    }else{
//        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (!cell) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//        }
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        
//        NSString *string;
//        
//        if(indexPath.section == 0){
//            cell.selectionStyle = UITableViewCellSelectionStyleGray;
//            
//            string = [NSString stringWithFormat:@"%.2f元",[self.sellerMessage.capital_money floatValue]];
//            cell.detailTextLabel.text = @"余额用于发红包,发广告";
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, CellDefaultHeight)];
//            self.sendRedLibaryButton.frame = CGRectMake(0, 0, 50, CellDefaultHeight);
//            [view addSubview:self.sendRedLibaryButton];
//            
//            self.publishAdvertisementButton.frame = CGRectMake(50, 0, 50, CellDefaultHeight);
//            [view addSubview:self.publishAdvertisementButton];
//            cell.accessoryView = view;
//        }else{
//            cell.selectionStyle = UITableViewCellSelectionStyleGray;
//            
//            string = [NSString stringWithFormat:@"%.2f元",[self.sellerMessage.turnover_money floatValue]];
//            float withdrawalsMoney = [self.sellerMessage.turnover_money floatValue]-[self.sellerMessage.freeze_money floatValue];
//            NSString *string = [NSString stringWithFormat:@"冻结:%0.2f元,可提现:%0.2f元",[self.sellerMessage.freeze_money floatValue],withdrawalsMoney];
//            cell.detailTextLabel.text = string;
//            cell.accessoryView = self.withdrawalsButton;
//        }
//        
//        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
//        UIColor *color = [UIColor redColor];
//        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length-1)];
//        color =[ UIColor blackColor];
//        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(string.length-1,1)];
//        cell.textLabel.attributedText = attrString;
//        cell.textLabel.font = [UIFont systemFontOfSize:18];
//    }
//    
//    if(indexPath.section == 2){
//        SellerCentreSection1Row1TableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"CCC"];
//        if (!cell1) {
//            cell1 = [[SellerCentreSection1Row1TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CCC"];
//        }
//        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell1.accessoryType = UITableViewCellAccessoryNone;
//        
//        [cell1.button1 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4]] forState:UIControlStateNormal];
//        [cell1.button2 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4+1]] forState:UIControlStateNormal];
//        [cell1.button3 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4+2]] forState:UIControlStateNormal];
//        [cell1.button4 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4+3]] forState:UIControlStateNormal];
//        
//        [cell1.button1 setTitle:self.buttonTitleArray[indexPath.row*4] forState:UIControlStateNormal];
//        [cell1.button2 setTitle:self.buttonTitleArray[indexPath.row*4+1] forState:UIControlStateNormal];
//        [cell1.button3 setTitle:self.buttonTitleArray[indexPath.row*4+2] forState:UIControlStateNormal];
//        [cell1.button4 setTitle:self.buttonTitleArray[indexPath.row*4+3] forState:UIControlStateNormal];
//        
//        cell1.button1.tag = indexPath.row*4;
//        cell1.button2.tag = indexPath.row*4+1;
//        cell1.button3.tag = indexPath.row*4+2;
//        cell1.button4.tag = indexPath.row*4+3;
//        
//        [cell1.button1 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [cell1.button2 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [cell1.button3 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [cell1.button4 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        return cell1;
//    }
//    
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    switch (indexPath.row) {
//        case 0:
//        {
//            @autoreleasepool {
//                CashDetailedViewController *vc = Alloc_viewControllerNibName(CashDetailedViewController);
//                if (indexPath.section == 0) {
//                    
//                }else if(indexPath.section == 1){
//                    
//                }
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//            break;
//            
//        case 1:
//        {
//            @autoreleasepool {
//                SellerSurplusViewController *vc = Alloc_viewControllerNibName(SellerSurplusViewController);
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//            break;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat height = 44;
//    
//    if(indexPath.section == 2){
//        height = SCREEN_WIDTH/4;
//        return height;
//    }
//    
//    switch (indexPath.row) {
//        case 1:{
//            height = CellDefaultHeight;
//        }
//            break;
//    }
//    
//    return height;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    //分割线顶格
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 5;
//}

@end
