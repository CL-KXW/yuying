//
//  SellerCentreViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreViewController.h"

#import "SellerCentreSection0Row0TableViewCell.h"
#import "SellerCentreSection1Row0TableViewCell.h"
#import "SellerCentreSection1Row1TableViewCell.h"
#import "SellerCentreSection2Row0TableViewCell.h"
#import "SellerCentreSection2Row1TableViewCell.h"
#import "CommonTableViewCell.h"


#import "SellerCentreJoinViewController.h"
#import "SellerCentreWriteDataViewController.h"
#import "PublishAdvertisementViewController.h"
#import "SellerSurplusViewController.h"

#import "TurnoverWithdrawalsViewController.h"

#import "RedLibaryManageViewController.h"

#import "VerticalButton.h"
#import "CashDetailedViewController.h"
#import "RedLibaryTypeListViewController.h"

#import "ResponseSellerMessage.h"
#import "SellerMessageEditViewController.h"

#define CellDefaultHeight 70

@interface SellerCentreViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSArray *cellTextArray;
@property(nonatomic,strong)UIButton *sellerEditButton;
@property(nonatomic,strong)UIImageView *logoImageView;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)VerticalButton *sendRedLibaryButton;
@property(nonatomic,strong)VerticalButton *publishAdvertisementButton;
@property(nonatomic,strong)UIButton *withdrawalsButton;

@property(nonatomic,strong)NSArray *buttonTitleArray;
@property(nonatomic,strong)NSArray *buttonImageArray;

@property(nonatomic,strong)SellerMessage *sellerMessage;

@end

@implementation SellerCentreViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"商家管理";
    self.cellTextArray =@[@"余额",@"商城营业额",@""];
    self.buttonTitleArray = @[@"红包管理",@"赚钱广告管理",@"商品管理",@"订单管理",@"会员卡管理",@"优惠券管理",@"提现进度查询",@"发票管理"];
    self.buttonImageArray = @[@"SellerManager_redLibaryManager",@"SellerManager_advertisementManager",@"SellerManager_commodityManager",@"SellerManager_orderFormManager",@"SellerManager_vipManager",@"SellerManager_preferentialManager",@"SellerManager_statusInquiry",@"SellerManager_invoiceManager"];
    
    float headViewHeight = 120;
    self.sellerEditButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, headViewHeight);
    self.tableView.tableHeaderView = self.sellerEditButton;
    
    float logoImageDiameter = 80;
    self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (headViewHeight-logoImageDiameter)/2, logoImageDiameter, logoImageDiameter)];
    self.logoImageView.image = [UIImage imageNamed:@"Common_defaultImageLogo"];
    self.logoImageView.layer.cornerRadius = logoImageDiameter/2;
    self.logoImageView.layer.masksToBounds = YES;
    [self.sellerEditButton addSubview:self.logoImageView];
    
    self.nameLabel.frame = CGRectMake(10*2+logoImageDiameter, 0, SCREEN_WIDTH-(10*3+logoImageDiameter), headViewHeight);
    [self.sellerEditButton addSubview:self.nameLabel];
    
    [self sellerMessageRequest];
}

#pragma mark - init
-(UIButton *)sellerEditButton{
    if(!_sellerEditButton){
        _sellerEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sellerEditButton.backgroundColor = RGB(251, 93, 8);
        [_sellerEditButton addTarget:self action:@selector(sellerEditButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sellerEditButton;
}

-(UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = Alloc(UILabel);
        _nameLabel.font = FONT(16);
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _nameLabel;
}

-(UIButton *)sendRedLibaryButton{
    if (!_sendRedLibaryButton) {
        _sendRedLibaryButton = [VerticalButton buttonWithType:UIButtonTypeCustom];
        [_sendRedLibaryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sendRedLibaryButton setTitle:@"发红包" forState:UIControlStateNormal];
        [_sendRedLibaryButton addTarget:self action:@selector(sendRedLibaryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_sendRedLibaryButton setImage:[UIImage imageNamed:@"SellerManager_sendRedLibary"] forState:UIControlStateNormal];
        _sendRedLibaryButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }

    return _sendRedLibaryButton;
}

-(UIButton *)publishAdvertisementButton{
    if (!_publishAdvertisementButton) {
        _publishAdvertisementButton = [VerticalButton buttonWithType:UIButtonTypeCustom];
        [_publishAdvertisementButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_publishAdvertisementButton setTitle:@"发广告" forState:UIControlStateNormal];

        [_publishAdvertisementButton addTarget:self action:@selector(publishAdvertisementButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_publishAdvertisementButton setImage:[UIImage imageNamed:@"SellerManager_publishAdvertisement"] forState:UIControlStateNormal];
        _publishAdvertisementButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    
    return _publishAdvertisementButton;
}

-(UIButton *)withdrawalsButton{
    if (!_withdrawalsButton) {
        _withdrawalsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_withdrawalsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_withdrawalsButton setTitle:@"提现" forState:UIControlStateNormal];
        _withdrawalsButton.height = 50;
        _withdrawalsButton.width = 50;
        [_withdrawalsButton addTarget:self action:@selector(withdrawalsButtonButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_withdrawalsButton viewRadius:25 backgroundColor:RGB(240, 149, 28)];
        _withdrawalsButton.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    
    return _withdrawalsButton;
}

#pragma mark - Request
-(void)sellerMessageRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    NSString *user_id = [YooSeeApplication shareApplication].userInfoDic[@"id"];
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",nil];

    WeakSelf(weakSelf);
    [HttpManager postUrl:Url_sellerMessage parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ResponseSellerMessage *message = [ResponseSellerMessage yy_modelWithDictionary:jsonObject];
        if (message.returnCode.intValue == SucessFlag)
        {
            weakSelf.sellerMessage = [message.resultList firstObject];
            NSURL *url = [NSURL URLWithString:weakSelf.sellerMessage.dian_logo];
            [weakSelf.logoImageView sd_setImageWithURL:url];
            weakSelf.nameLabel.text = weakSelf.sellerMessage.dian_name;
            [weakSelf.tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:message.returnMessage];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark - UIButtonClick
-(void)sellerEditButtonClick:(UIButton *)button{
    @autoreleasepool {
        SellerMessageEditViewController *vc = Alloc_viewControllerNibName(SellerMessageEditViewController);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)sendRedLibaryButtonClick:(UIButton *)button{
    @autoreleasepool {
        RedLibaryTypeListViewController *vc = Alloc_viewControllerNibName(RedLibaryTypeListViewController);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)publishAdvertisementButtonClick:(UIButton *)button{
    @autoreleasepool {
        PublishAdvertisementViewController *vc = Alloc_viewControllerNibName(PublishAdvertisementViewController);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)withdrawalsButtonButtonClick:(UIButton *)button{
    @autoreleasepool {
        TurnoverWithdrawalsViewController *vc = Alloc_viewControllerNibName(TurnoverWithdrawalsViewController);
        vc.turnoverWithdrawals = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [NSString stringWithFormat:@"1"];
    UITableViewCell *cell;
    if(indexPath.row == 0){
        cellIdentifier = @"0";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = self.cellTextArray[indexPath.section];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        cell.detailTextLabel.text = @"查看明细";
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSString *string;

        if(indexPath.section == 0){
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            string = [NSString stringWithFormat:@"%.2f元",[self.sellerMessage.capital_money floatValue]];
            cell.detailTextLabel.text = @"余额用于发红包,发广告";
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, CellDefaultHeight)];
            self.sendRedLibaryButton.frame = CGRectMake(0, 0, 50, CellDefaultHeight);
            [view addSubview:self.sendRedLibaryButton];
            
            self.publishAdvertisementButton.frame = CGRectMake(50, 0, 50, CellDefaultHeight);
            [view addSubview:self.publishAdvertisementButton];
            cell.accessoryView = view;
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            string = [NSString stringWithFormat:@"%.2f元",[self.sellerMessage.turnover_money floatValue]];
            float withdrawalsMoney = [self.sellerMessage.turnover_money floatValue]-[self.sellerMessage.freeze_money floatValue];
            NSString *string = [NSString stringWithFormat:@"冻结:%0.2f元,可提现:%0.2f元",[self.sellerMessage.freeze_money floatValue],withdrawalsMoney];
            cell.detailTextLabel.text = string;
            cell.accessoryView = self.withdrawalsButton;
        }
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        UIColor *color = [UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length-1)];
        color =[ UIColor blackColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(string.length-1,1)];
        cell.textLabel.attributedText = attrString;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }

    if(indexPath.section == 2){
        SellerCentreSection1Row1TableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"CCC"];
        if (!cell1) {
            cell1 = [[SellerCentreSection1Row1TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CCC"];
        }
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        cell1.accessoryType = UITableViewCellAccessoryNone;
        
        [cell1.button1 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4]] forState:UIControlStateNormal];
        [cell1.button2 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4+1]] forState:UIControlStateNormal];
        [cell1.button3 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4+2]] forState:UIControlStateNormal];
        [cell1.button4 setImage:[UIImage imageNamed:self.buttonImageArray[indexPath.row*4+3]] forState:UIControlStateNormal];
        
        [cell1.button1 setTitle:self.buttonTitleArray[indexPath.row*4] forState:UIControlStateNormal];
        [cell1.button2 setTitle:self.buttonTitleArray[indexPath.row*4+1] forState:UIControlStateNormal];
        [cell1.button3 setTitle:self.buttonTitleArray[indexPath.row*4+2] forState:UIControlStateNormal];
        [cell1.button4 setTitle:self.buttonTitleArray[indexPath.row*4+3] forState:UIControlStateNormal];
        
        cell1.button1.tag = indexPath.row*4;
        cell1.button2.tag = indexPath.row*4+1;
        cell1.button3.tag = indexPath.row*4+2;
        cell1.button4.tag = indexPath.row*4+3;
        
        [cell1.button1 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.button2 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.button3 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.button4 addTarget:self action:@selector(cellButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell1;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    switch (indexPath.row) {
        case 0:
        {
            @autoreleasepool {
                CashDetailedViewController *vc = Alloc_viewControllerNibName(CashDetailedViewController);
                if (indexPath.section == 0) {
                    vc.type = CashDetailType_sellerCapitalLibrary;
                }else if(indexPath.section == 1){
                    vc.type = CashDetailType_sellerTurnover;
                }
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case 1:
        {
            @autoreleasepool {
                if (indexPath.section == 0) {
                    SellerSurplusViewController *vc = Alloc_viewControllerNibName(SellerSurplusViewController);
                    [self.navigationController pushViewController:vc animated:YES];
                }else if(indexPath.section == 1){
                    CashDetailedViewController *vc = Alloc_viewControllerNibName(CashDetailedViewController);
                    vc.type = CashDetailType_sellerTurnover;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 44;
    
    if(indexPath.section == 2){
        height = SCREEN_WIDTH/4;
        return height;
    }
    
    switch (indexPath.row) {
        case 1:{
            height = CellDefaultHeight;
        }
            break;
    }
    
    return height;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

#pragma mark -
-(void)cellButtonClick:(UIButton *)button{
    switch (button.tag) {
        case 0:
        {
            @autoreleasepool {
                //红包管理
                RedLibaryManageViewController *vc = Alloc_viewControllerNibName(RedLibaryManageViewController);
                vc.type = ManageType_redLibary;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case 1:
        {
            @autoreleasepool {
                RedLibaryManageViewController *vc = Alloc_viewControllerNibName(RedLibaryManageViewController);
                vc.type = ManageType_advertisement;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case 2:
        {
            @autoreleasepool {
                
            }
        }
            break;
            
        case 3:
        {
            @autoreleasepool {
                
            }
        }
            break;
            
        case 4:
        {
            @autoreleasepool {
                
            }
        }
            break;
            
        case 5:
        {
            @autoreleasepool {
                
            }
        }
            break;
            
        case 6:
        {
            @autoreleasepool {
                SellerCentreWriteDataViewController *vc = Alloc_viewControllerNibName(SellerCentreWriteDataViewController);
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case 7:
        {
            @autoreleasepool {
                SellerCentreJoinViewController *vc = Alloc_viewControllerNibName(SellerCentreJoinViewController);
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
    }
}

@end
