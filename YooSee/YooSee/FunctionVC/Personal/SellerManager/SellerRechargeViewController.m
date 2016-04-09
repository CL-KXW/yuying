//
//  SellerRechargeViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerRechargeViewController.h"

#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"

#define CellDefaultHeight 50

@interface SellerRechargeViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;
@property(nonatomic,strong)UITextField *moneyField;

@end

@implementation SellerRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    self.title = @"充值";
    [self setTableFootView];
}

#pragma mark -
-(void)setTableFootView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    footView.backgroundColor = VIEW_BG_COLOR;
    self.tableView.tableFooterView = footView;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"下一步" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).with.offset(20);
        make.leading.equalTo(footView.mas_leading).with.offset(20);
        make.trailing.equalTo(footView.mas_trailing).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    [submitButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
}

#pragma mark -
-(void)nextButtonClick:(UIButton *)button{
    if (self.moneyField.text.length == 0) {
        [CommonTool addPopTipWithMessage:@"请输入金额"];
        return;
    }
    
    [self createZhiFuBaoOrder];
}

#pragma mark - init
-(UITextField *)moneyField{
    if (!_moneyField) {
        _moneyField = Alloc(UITextField);
        _moneyField.font = [UIFont systemFontOfSize:16];
        _moneyField.placeholder = @"输入金额";
        _moneyField.width = 180;
        _moneyField.height = CellDefaultHeight;
        _moneyField.textAlignment = NSTextAlignmentRight;
        _moneyField.keyboardType = UIKeyboardTypeDecimalPad;
        _moneyField.delegate = self;
    }
    
    return _moneyField;
}

#pragma mark - 创建支付宝订单
-(void)createZhiFuBaoOrder{
    NSString *money = self.moneyField.text;
    if(money.length == 0)
        return;
    //商家type＝2
    NSDictionary *dic = @{@"user_id":[[YooSeeApplication shareApplication] uid],@"recharge_money":money, @"type":@"2"};
    dic = [RequestDataTool encryptWithDictionary:dic];
    [[RequestTool alloc] requestWithUrl:CREATEORDER_URL requestParamas:dic requestType:RequestTypeAsynchronous requestSucess:^(AFHTTPRequestOperation *operation, id responseDic) {
        if ([responseDic[@"returnCode"] intValue] == 8) {
            
            NSDictionary *dic = responseDic;
            //orderno pid sellermail publickey notifyurl moneynum
            if (dic && dic[@"payInfo"]) {
                [self pay:dic[@"payInfo"]];
                //[self rechargeZhiFuBao:dic[@"pid"] seller:dic[@"seller_account"] tradeNO:dic[@"only_number"] notifyURL:dic[@"notifyurl"]
                //               price:money privateKey:dic[@"alipaykey"]];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:responseDic[@"returnMessage"] duration:2.0];
        }
    } requestFail:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.description duration:2.0];
    }];
}

- (void)pay:(NSString*)orderString {
    NSString *appScheme = @"yuying";
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

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.textLabel.text = @"充值金额";

    UIView *view = Alloc(UIView);
    view.width = self.moneyField.width+20;
    view.height = CellDefaultHeight;
    [view addSubview:self.moneyField];
    UILabel *label = Alloc(UILabel);
    label.text = @"元";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentRight;
    label.frame = CGRectMake(view.width-20, 0, 20, CellDefaultHeight);
    [view addSubview:label];
    cell.accessoryView = view;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = CellDefaultHeight;
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+0, bounds.size.height-lineHeight, bounds.size.width-0, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}


@end
