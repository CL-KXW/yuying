//
//  RechargeViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/20.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "RechargeViewController.h"
#import "RechargeTypeTableViewCell.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"

@interface RechargeViewController ()
{
    UIView *_headerView;
    UILabel *_phoneLabel;
    UILabel *_rechargeLabel;
}
@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    self.title = @"帐号充值";
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:0 tableDelegate:self];
    self.table.rowHeight = 80;
    [self.table setTableHeaderView:[self headerView]];
    self.table.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 56)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(26, 8, SCREEN_WIDTH - 26 * 2, 40)];
    [btn setBackgroundColor:RGB(80, 201, 45)];
    [btn setShowsTouchWhenHighlighted:YES];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [footView addSubview:btn];
    [btn addTarget:self action:@selector(zhiFuBaoNextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.table setTableFooterView:footView];
    self.view.backgroundColor = RGB(239, 239, 244);
}

- (UIView*)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 288)];
        _headerView.backgroundColor = RGB(239, 239, 244);
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(22, 3, SCREEN_WIDTH - 100, 20)];
        label1.font = FONT(17);
        label1.textColor = [UIColor grayColor];
        label1.text = @"您正在为一下账号充值:";
        [_headerView addSubview:label1];
        
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 33, 200, 29)];
        _phoneLabel.textColor = RGB(253, 88, 2);
        _phoneLabel.text = [USER_DEFAULT valueForKey:@"UserName"];
        _phoneLabel.font = FONT(24);
        [_headerView addSubview:_phoneLabel];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 71, SCREEN_WIDTH, 40)];
        [_headerView addSubview:view];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 60, 20)];
        label2.text = @"金额:";
        label2.textColor = [UIColor blackColor];
        label2.font = FONT(17);
        [view addSubview:label2];
        _rechargeLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 10, 200, 20)];
        [view addSubview:_rechargeLabel];
        _rechargeLabel.textColor = [UIColor lightGrayColor];
        _rechargeLabel.font = FONT(14);
        _rechargeLabel.text = @"请选择充值金额";
        
        for (int i = 0; i < 4; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(22 + (i % 2 * (SCREEN_WIDTH - 22 * 3) / 2.0) + (i % 2) * 22, 131 + 70 * (i / 2), (SCREEN_WIDTH - 22 * 3) / 2.0, 50)];
            [_headerView addSubview:btn];
            btn.tag = (i + 1) * 100;
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitle:[NSString stringWithFormat:@"%d元", (i + 1) * 100] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(15, 260, SCREEN_WIDTH - 30, 20)];
        label3.text = @"选择支付方式:";
        label3.font = FONT(17);
        label3.textColor = [UIColor lightGrayColor];
        [_headerView addSubview:label3];
    }
    return _headerView;
}

- (void)selectButtonClick:(UIButton*)sender {
    for (int i = 1; i <= 4; i++) {
        UIButton *btn = (UIButton*)[_headerView viewWithTag:i * 100];
        if (sender != btn) {
            btn.backgroundColor = [UIColor whiteColor];
        } else {
            btn.backgroundColor = [UIColor lightGrayColor];
        }
    }
    _rechargeLabel.text = [NSString stringWithFormat:@"%d", sender.tag];
    _rechargeLabel.textColor = [UIColor blackColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = ;
    static NSString *cellIdentify = @"RechargeTypeTableViewCell";
    RechargeTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if(!cell)
    {
        cell = [[RechargeTypeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.row == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"img_bank_zfb"];
        cell.textLabel.text = @"支付宝支付";
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(tableView.frame.size.width-100, (80-20)/2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"icon_Selection_Checked"];
        cell.accessoryView = imageView;
        cell.accessoryView.userInteractionEnabled = NO;
        cell.isSelect = YES;
    }else{
        cell.textLabel.text = @"更多支付方式接入中…";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //最后一个cell点击事件不处理
    if(indexPath.row < [tableView numberOfRowsInSection:0]-1)
    {
        RechargeTypeTableViewCell *cell = (RechargeTypeTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.isSelect = !cell.isSelect;
        UIImageView *imageView = (UIImageView*)cell.accessoryView;
        imageView.image = [UIImage imageNamed: cell.isSelect ? @"icon_Selection_Checked" : @"icon_Selection_Unchecked"];
    }
}

//现金充值方式视图下一步按钮
- (IBAction)zhiFuBaoNextBtnClicked:(id)sender {
    
    //检测是否输入支付金额
    if([_rechargeLabel.text isEqualToString:@"请选择充值金额"])
    {
        [SVProgressHUD showErrorWithStatus:@"请选择充值金额" duration:2.0];
        return;
    }
    
    //检测选择的支付方式
    int i = 0;
    for(;i<[self.table numberOfRowsInSection:0];i++)
    {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
        RechargeTypeTableViewCell *cell = (RechargeTypeTableViewCell*)[self.table cellForRowAtIndexPath:indexpath];
        if(cell.isSelect)
        {
            break;
        }
    }
    
    if(i == [self.table numberOfRowsInSection:0])
    {
        [SVProgressHUD showErrorWithStatus:@"请选择支付方式！" duration:2.0];
        return;
    }
    
    switch (i) {
        case 0:
        {//支付宝支付方式
            [self createZhiFuBaoOrder];
            /* RechargeZhiFuBaoViewController *vc = [[RechargeZhiFuBaoViewController alloc]initWithNibName:@"RechargeZhiFuBaoViewController" bundle:nil];
             vc.view.frame = self.view.frame;
             self.navigationController.navigationBarHidden = YES;
             [self.navigationController pushViewController:vc animated:YES];
             [vc release];*/
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 创建支付宝订单
-(void)createZhiFuBaoOrder{
    NSString *money = _rechargeLabel.text;
    if(money.length == 0)
        return;
    NSDictionary *dic = @{@"user_id":[[YooSeeApplication shareApplication] uid],@"recharge_money":money, @"type":@"1"};
    dic = [RequestDataTool encryptWithDictionary:dic];
    [[RequestTool alloc] requestWithUrl:CREATEORDER_URL requestParamas:dic requestType:RequestTypeAsynchronous requestSucess:^(AFHTTPRequestOperation *operation, id responseDic) {
        if ([responseDic[@"returnCode"] intValue] == 8) {
            
            NSDictionary *dic = responseDic;
            //orderno pid sellermail publickey notifyurl moneynum
            if (dic) {
                [self rechargeZhiFuBao:dic[@"pid"] seller:dic[@"seller_account"] tradeNO:dic[@"only_number"] notifyURL:dic[@"notifyurl"]
                                 price:money privateKey:dic[@"alipaykey"]];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:responseDic[@"returnMessage"] duration:2.0];
        }
    } requestFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.description duration:2.0];
    }];
}

#pragma mark - 提交支付宝订单
-(void)rechargeZhiFuBao:(NSString*) partner
                 seller:(NSString*) seller
                tradeNO:(NSString*) tradeNO
              notifyURL:(NSString*) notifyURL
                  price:(NSString*) price
             privateKey:(NSString*) privateKey
{
    
    //生成订单信息及签名
    
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = tradeNO; //订单ID（由商家自行制定）
    order.productName = @"帐号充值"; //商品标题
    order.productDescription = @"用支付宝给鱼鹰帐号充值。"; //商品描述
    order.amount = price; //商品价格
    order.notifyURL =  notifyURL; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,
    NSString *appScheme = @"yuying";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    //NSString *privateKey = privateKey;
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            
            NSInteger i = [[resultDic objectForKey:@"resultStatus"] integerValue];
            
            NSString *title = @"";
            switch (i) {
                case 9000:
                {
                    title = @"订单支付成功";
                }
                    break;
                case 8000:
                {
                    title = @"正在处理中";
                }
                    break;
                case 4000:
                {
                    title = @"订单支付失败";
                }
                    break;
                case 6001:
                {
                    title = @"用户中途取消";
                }
                    break;
                case 6002:
                {
                    title = @"网络连接出错";
                }
                    break;
                    
                default:
                    break;
            }
            
            UIAlertView *alt = [[UIAlertView alloc] initWithTitle:@"支付结果" message:title delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alt show];
        }];
    }
}
@end
