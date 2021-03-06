//
//  TurnoverWithdrawalsViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/14.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "TurnoverWithdrawalsViewController.h"

#import "TurnoverWithdrawalsFootView.h"

#define CellDefaultHeight 50
#define RightWidth SCREEN_WIDTH-120

@interface TurnoverWithdrawalsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *arrivalLabel;

@property(nonatomic,strong)TurnoverWithdrawalsFootView *footView;
@end

@implementation TurnoverWithdrawalsViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
    if (self.turnoverWithdrawals == WithdrawTypeStoreTurnover) {
        self.title = @"营业额提现";
        
        TurnoverWithdrawalsFootView *footView = Alloc(TurnoverWithdrawalsFootView);
        footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 330);
        self.tableView.tableFooterView = footView;
        [footView.serviceAgreementButton addTarget:self action:@selector(serviceAgreementButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [footView.withdrawalsApplyButton addTarget:self action:@selector(withdrawalsApplyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [footView.transferToSurplusButton addTarget:self action:@selector(transferToSurplusButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [footView.withdrawalsApplyButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
        [footView.transferToSurplusButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Green];
    }else{
        self.title = @"余额提现";
        [self setTableFootView];
    }
    
    self.textArray = [NSMutableArray arrayWithArray:@[@"支付宝",@"姓名",@"提现金额",@"¥", @"到账金额:",@"当前"]];
    [self requestRate];
}

#pragma mark -
-(void)setTableFootView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80+20)];
    footView.backgroundColor = VIEW_BG_COLOR;
    self.tableView.tableFooterView = footView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    label.text = @"一个工作日内到账";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    [footView addSubview:label];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提现申请" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(withdrawalsApplyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).with.offset(40);
        make.leading.equalTo(footView.mas_leading).with.offset(20);
        make.trailing.equalTo(footView.mas_trailing).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    [submitButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
}

#pragma mark -init
-(UITextField *)alipayField{
    if (!_alipayField) {
        _alipayField = Alloc(UITextField);
        _alipayField.font = [UIFont systemFontOfSize:16];
        _alipayField.placeholder = @"请输入账号";
        _alipayField.width = RightWidth;
        _alipayField.height = CellDefaultHeight;
        _alipayField.textAlignment = NSTextAlignmentRight;
        _alipayField.keyboardType = UIKeyboardTypeDefault;
    }
    
    return _alipayField;
}

-(UITextField *)nameField{
    if (!_nameField) {
        _nameField = Alloc(UITextField);
        _nameField.font = [UIFont systemFontOfSize:16];
        _nameField.placeholder = @"请输入姓名";
        _nameField.width = RightWidth;
        _nameField.height = CellDefaultHeight;
        _nameField.textAlignment = NSTextAlignmentRight;
        _nameField.keyboardType = UIKeyboardTypeDefault;
    }
    
    return _nameField;
}

-(UITextField *)moneyField{
    if (!_moneyField) {
        _moneyField = Alloc(UITextField);
        _moneyField.font = [UIFont systemFontOfSize:16];
        _moneyField.placeholder = @"请输入金额";
        _moneyField.width = RightWidth-20;
        _moneyField.height = CellDefaultHeight;
        _moneyField.textAlignment = NSTextAlignmentRight;
        _moneyField.keyboardType = UIKeyboardTypeNumberPad;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldValueChanged:) name:UITextFieldTextDidChangeNotification object:_moneyField];
    }
    
    return _moneyField;
}

#pragma mark -UIButtonClick
-(void)serviceAgreementButtonClick:(UIButton *)button{
    @autoreleasepool {
        
    }
}

-(void)withdrawalsApplyButtonClick:(UIButton *)button{
    if(self.turnoverWithdrawals){
        
    }else{
        
    }
}

-(void)transferToSurplusButtonClick:(UIButton *)button{
    
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.textArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdent = [NSString stringWithFormat:@"cell_%d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.textLabel.text = self.textArray[indexPath.row];
    
    switch (indexPath.row) {
        case 0:{
            cell.accessoryView = self.alipayField;
        }
            break;
            
        case 1:{
            cell.accessoryView = self.nameField;
        }
            break;
            
        case 2:{
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
            cell.accessoryView = label;
            label.font = FONT(13);
            label.text = [NSString stringWithFormat:@"手续费：%.2f%%", self.rate];
            label.textColor = RGB(179, 94, 111);
            label.textAlignment = NSTextAlignmentRight;
        }
            break;
        case 3:
        {
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
        }
            break;
        case 4:{
            cell.textLabel.textColor = RGB(179, 94, 111);
            self.arrivalLabel = cell.textLabel;
        }
            break;
        case 5: {
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [UIColor lightGrayColor];
        }
            break;
    }
    
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

#pragma mark -
#pragma mark Request
- (void)requestRate {
    [LoadingView showLoadingView];
    [HttpManager postUrl:Url_systemRate parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag) {
            NSArray *array = jsonObject[@"resultList"];
            NSDictionary *dic = [array firstObject];
            if (self.turnoverWithdrawals == WithdrawTypePersonBalance) {
                self.rate = [dic[@"rate_personal_tixian"] floatValue];
            } else if (self.turnoverWithdrawals == WithdrawTypeStoreTurnover) {
                self.rate = [dic[@"rate_shop_tixian"] floatValue];
            } else if (self.turnoverWithdrawals == WithdrawTypeStoreTurnover) {
                self.rate = [dic[@"rate_shop_revert"] floatValue];
            }             [self.tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionError];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark -
#pragma mark Delegate
- (void)textFieldValueChanged:(NSNotification*)notification {
    NSLog(@"notif = %@", notification);
    if (notification.object == _moneyField) {
        [self.textArray replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"到账金额：%.2f元",_moneyField.text.floatValue * (1 - self.rate/100.0)]];
        self.arrivalLabel.text = self.textArray[4];
    }
}
@end
