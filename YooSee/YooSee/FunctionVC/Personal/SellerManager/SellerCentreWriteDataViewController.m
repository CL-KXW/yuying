//
//  SellerCentreWriteDataViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreWriteDataViewController.h"

#import "SellerCentreWriteDataBusinessLicenseTableViewCell.h"
#import "PromptTextfield.h"
#import "SelectPictureButton.h"

#import "IQKeyboardManager.h"

#define CellDefaultHeight 40

typedef NS_ENUM(NSUInteger, SellerType) {
    SellerType_personal = 0,
    SellerType_merchant = 1,
};

typedef NS_ENUM(NSUInteger, ButtonTag) {
    ButtonTag_businessLicence = 1,
    ButtonTag_identificationPositive = 2,
    ButtonTag_identificationOpposite = 3,
};

#define TextFont 14

@interface SellerCentreWriteDataViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    
}

@property(nonatomic,weak)IBOutlet UITableView *tableView;
@property(nonatomic)NSInteger sellerType;
@property(nonatomic,strong)UISegmentedControl *sellerTypeSegmented;

@property(nonatomic,strong)PromptTextfield *professionTypePromptField;
@property(nonatomic,strong)PromptTextfield *sellerNamePromptField;
@property(nonatomic,strong)PromptTextfield *registrationNumberPromptField;

@property(nonatomic,strong)PromptTextfield *namePromptField;
@property(nonatomic,strong)PromptTextfield *identificationPromptField;
@property(nonatomic,strong)PromptTextfield *telephonePromptField;

@property(nonatomic,strong)SelectPictureButton *businessLicenceSelectView;
@property(nonatomic,strong)SelectPictureButton *identificationPositiveSelectView;
@property(nonatomic,strong)SelectPictureButton *identificationOppositeSelectView;

@end

@implementation SellerCentreWriteDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = VIEW_BG_COLOR;
    self.title = @"商家注册";
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    headView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headView;
    
    UILabel *promptLabel = Alloc(UILabel);
    promptLabel.font = [UIFont systemFontOfSize:14];
    promptLabel.textColor = [UIColor lightGrayColor];
    promptLabel.text = @"请选择商户类型";
    promptLabel.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:promptLabel];
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView.mas_top).with.offset(0);
        make.leading.equalTo(headView.mas_leading).with.offset(0);
        make.trailing.equalTo(headView.mas_trailing).with.offset(0);
        make.height.mas_equalTo(40);
    }];
    
    self.sellerTypeSegmented = [[UISegmentedControl alloc] initWithItems:@[@"个人",@"商户"]];
    self.sellerType = SellerType_personal;
    self.sellerTypeSegmented.selectedSegmentIndex = 0;
    [self.sellerTypeSegmented addTarget:self action:@selector(didClickSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    self.sellerTypeSegmented.tintColor = ButtonColor_Common;
    self.sellerTypeSegmented.segmentedControlStyle=UISegmentedControlStylePlain;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,  [UIFont systemFontOfSize:16.f],UITextAttributeFont ,[UIColor whiteColor],UITextAttributeTextShadowColor,nil];
    [self.sellerTypeSegmented setTitleTextAttributes:dic forState:UIControlStateSelected];
    dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,  [UIFont systemFontOfSize:16.f],UITextAttributeFont ,[UIColor whiteColor],UITextAttributeTextShadowColor,[UIColor lightTextColor],NSForegroundColorAttributeName,nil];
    [self.sellerTypeSegmented setTitleTextAttributes:dic forState:UIControlStateNormal];
    [headView addSubview:self.sellerTypeSegmented];
    [self.sellerTypeSegmented mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(promptLabel.mas_bottom).with.offset(0);
        make.centerX.equalTo(headView.mas_centerX).with.offset(0);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(30);
    }];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    footView.backgroundColor = VIEW_BG_COLOR;
    self.tableView.tableFooterView = footView;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).with.offset(20);
        make.leading.equalTo(footView.mas_leading).with.offset(20);
        make.trailing.equalTo(footView.mas_trailing).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    submitButton.backgroundColor = [UIColor yellowColor];
}

#pragma mark - UISegmentedControl
-(void)didClickSegmentedControl:(UISegmentedControl *)seg{
    self.sellerType = seg.selectedSegmentIndex;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.sellerType == SellerType_merchant) {
        return 8;
    }else{
        return 4;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if(self.sellerType == SellerType_merchant){
        switch (indexPath.row) {
            case 0:
            {
                self.professionTypePromptField = [[PromptTextfield alloc] init];
                self.professionTypePromptField.promptLabel.text = @"行业类别";
                self.professionTypePromptField.inputTextField.placeholder = @"请选择所属行业类型";
                self.professionTypePromptField.inputTextField.delegate = self;
                [cell.contentView addSubview:self.professionTypePromptField];
                [self.professionTypePromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 1:{
                self.sellerNamePromptField = [[PromptTextfield alloc] init];
                self.sellerNamePromptField.inputTextField.placeholder = @"填写工商注册全称";
                self.sellerNamePromptField.promptLabel.text = @"商户名称";
                self.sellerNamePromptField.inputTextField.delegate = self;
                [cell.contentView addSubview:self.sellerNamePromptField];
                [self.sellerNamePromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(10);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 2:{
                self.registrationNumberPromptField = [[PromptTextfield alloc] init];
                self.registrationNumberPromptField.inputTextField.placeholder = @"填写工商注册号";
                self.registrationNumberPromptField.promptLabel.text = @"注册号";
                self.registrationNumberPromptField.inputTextField.delegate = self;
                [cell.contentView addSubview:self.registrationNumberPromptField];
                [self.registrationNumberPromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 3:{
                NSString *cellIdent = [NSString stringWithFormat:@"%d_%d",indexPath.section,indexPath.row];
                
                SellerCentreWriteDataBusinessLicenseTableViewCell *cell1 = (SellerCentreWriteDataBusinessLicenseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdent];
                if (!cell1) {
                    cell1 = [[SellerCentreWriteDataBusinessLicenseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell1.businessLicenseView.promptLabel.text = @"工商营业执照";
                cell1.businessLicenseView.selectButton.tag = ButtonTag_businessLicence;
                
                return cell1;
            }
                break;
                
            case 4:{
                self.namePromptField = [[PromptTextfield alloc] init];
                self.namePromptField.inputTextField.placeholder = @"姓名";
                self.namePromptField.promptLabel.text = @"姓名";
                self.namePromptField.inputTextField.delegate = self;
                [cell.contentView addSubview:self.namePromptField];
                [self.namePromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 5:{
                self.identificationPromptField = [[PromptTextfield alloc] init];
                self.identificationPromptField.inputTextField.placeholder = @"身份证";
                self.identificationPromptField.promptLabel.text = @"身份证";
                self.identificationPromptField.inputTextField.delegate = self;
                [cell.contentView addSubview:self.identificationPromptField];
                [self.identificationPromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 6:{
                self.telephonePromptField = [[PromptTextfield alloc] init];
                self.telephonePromptField.inputTextField.placeholder = @"手机号";
                self.telephonePromptField.promptLabel.text = @"手机号";
                self.telephonePromptField.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
                self.telephonePromptField.inputTextField.delegate = self;
                [cell.contentView addSubview:self.telephonePromptField];
                [self.telephonePromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 7:{
                self.identificationPositiveSelectView = Alloc(SelectPictureButton);
                self.identificationPositiveSelectView.promptLabel.text = @"身份证正面";
                [cell.contentView addSubview:self.identificationPositiveSelectView];
                
                self.identificationOppositeSelectView = Alloc(SelectPictureButton);
                self.identificationOppositeSelectView.promptLabel.text = @"身份证反面";
                [cell.contentView addSubview:self.identificationOppositeSelectView];
                
                [self.identificationPositiveSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(self.identificationOppositeSelectView.mas_leading).with.offset(-10);
                    make.width.equalTo(self.identificationOppositeSelectView.mas_width);
                    make.bottom.equalTo(cell.contentView.mas_bottom).with.offset(0);
                }];
                
                [self.identificationOppositeSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(self.identificationPositiveSelectView.mas_trailing).with.offset(10);
                    make.width.equalTo(self.identificationPositiveSelectView.mas_width);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.bottom.equalTo(cell.contentView.mas_bottom).with.offset(0);
                }];
            }
                break;
        }
    }else{
        //个人
        switch (indexPath.row) {
            case 0:
            {
                self.professionTypePromptField = [[PromptTextfield alloc] init];
                self.professionTypePromptField.promptLabel.text = @"行业类别";
                self.professionTypePromptField.inputTextField.placeholder = @"请选择所属行业类型";
                [cell.contentView addSubview:self.professionTypePromptField];
                [self.professionTypePromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 1:{
                self.namePromptField = [[PromptTextfield alloc] init];
                self.namePromptField.inputTextField.placeholder = @"姓名";
                self.namePromptField.promptLabel.text = @"姓名";
                [cell.contentView addSubview:self.namePromptField];
                [self.namePromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(10);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 2:{
                self.identificationPromptField = [[PromptTextfield alloc] init];
                self.identificationPromptField.inputTextField.placeholder = @"";
                self.identificationPromptField.promptLabel.text = @"身份证";
                [cell.contentView addSubview:self.identificationPromptField];
                [self.identificationPromptField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.height.mas_equalTo(CellDefaultHeight);
                }];
            }
                break;
                
            case 3:{
                self.identificationPositiveSelectView = Alloc(SelectPictureButton);
                self.identificationPositiveSelectView.promptLabel.text = @"身份证正面";
                [cell.contentView addSubview:self.identificationPositiveSelectView];

                self.identificationOppositeSelectView = Alloc(SelectPictureButton);
                self.identificationOppositeSelectView.promptLabel.text = @"身份证反面";
                [cell.contentView addSubview:self.identificationOppositeSelectView];
                
                [self.identificationPositiveSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                    make.trailing.equalTo(self.identificationOppositeSelectView.mas_leading).with.offset(-10);
                    make.width.equalTo(self.identificationOppositeSelectView.mas_width);
                    make.bottom.equalTo(cell.contentView.mas_bottom).with.offset(0);
                }];
                
                [self.identificationOppositeSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                    make.leading.equalTo(self.identificationPositiveSelectView.mas_trailing).with.offset(10);
                    make.width.equalTo(self.identificationPositiveSelectView.mas_width);
                    make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                    make.bottom.equalTo(cell.contentView.mas_bottom).with.offset(0);
                }]; 
            }
                
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 40;
    if(self.sellerType == SellerType_merchant){
        switch (indexPath.row) {
            case 1:{
                height = 50;
            }
                break;
  
            case 3:{
                height = 170;
            }
                break;
                
            case 7:{
                height = 150;
            }
                break;
        }
    }else{
        switch (indexPath.row) {
            case 1:{
                height = 50;
            }
                break;
                
            case 3:{
                height = 150;
            }
                break;
        }
    }
    
    return height;
}

#pragma mark - UIButtonClick
-(void)submitButtonClick:(UIButton *)button{
    if (self.sellerType == SellerType_merchant) {
        
    }else{
        
    }
}

-(void)selectPictureButton:(UIButton *)button{
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.sellerType == SellerType_merchant) {
        if (textField == self.professionTypePromptField.inputTextField) {
            [self.sellerNamePromptField.inputTextField becomeFirstResponder];
        }else if (textField == self.sellerNamePromptField.inputTextField){
            [self.registrationNumberPromptField.inputTextField becomeFirstResponder];
        }else if(textField == self.registrationNumberPromptField.inputTextField){
            [self.namePromptField.inputTextField becomeFirstResponder];
        }else if(textField == self.namePromptField.inputTextField){
            [self.identificationPromptField.inputTextField becomeFirstResponder];
        }else if(textField == self.identificationPromptField.inputTextField){
            [self.telephonePromptField.inputTextField becomeFirstResponder];
        }else if(textField == self.telephonePromptField.inputTextField){
            [self.telephonePromptField.inputTextField resignFirstResponder];
        }
    }else{
        if (textField == self.professionTypePromptField.inputTextField) {
            [self.namePromptField.inputTextField becomeFirstResponder];
        }else if (textField == self.namePromptField.inputTextField){
            [self.identificationPromptField.inputTextField becomeFirstResponder];
        }else{
            [self.identificationPromptField.inputTextField resignFirstResponder];
        }
    }
    
    return YES;
}

#pragma mark -
-(void)allTextFieldResignFirstResponder{
    [self.professionTypePromptField.inputTextField resignFirstResponder];
    [self.sellerNamePromptField.inputTextField resignFirstResponder];
    [self.registrationNumberPromptField.inputTextField resignFirstResponder];
    [self.namePromptField.inputTextField resignFirstResponder];
    [self.identificationPromptField.inputTextField resignFirstResponder];
    [self.telephonePromptField.inputTextField resignFirstResponder];
}

#pragma mark - UIScrollerViewDelegate
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self allTextFieldResignFirstResponder];
//}

@end
