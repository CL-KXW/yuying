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
#import "SellerCentreReviewStatusViewController.h"

#define CellDefaultHeight 40

#define Hud_uploadFail @"上传失败,请您重试"

typedef NS_ENUM(NSUInteger, SellerType) {
    SellerType_personal = 0,
    SellerType_merchant = 1,
};

typedef NS_ENUM(NSUInteger, ButtonTag) {
    ButtonTag_businessLicence = 1,
    ButtonTag_identificationPositive = 2,
    ButtonTag_identificationOpposite = 3,
    
    ButtonTag_identificationPositive1 = 4,
    ButtonTag_identificationOpposite1 = 5,
};

typedef NS_OPTIONS(NSUInteger, ActionSheetTag) {
    ActionSheetTag_professionType = 1 << 0,
    ActionSheetTag_addPicture = 1 << 1,
};

#define TextFont 14

@interface SellerCentreWriteDataViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
}

@property(nonatomic,strong)PromptTextfield *professionTypePromptField1;
@property(nonatomic,strong)PromptTextfield *namePromptField1;
@property(nonatomic,strong)PromptTextfield *identificationPromptField1;

@property(nonatomic,strong)SelectPictureButton *identificationPositiveSelectView1;
@property(nonatomic,strong)SelectPictureButton *identificationOppositeSelectView1;

@property(nonatomic,strong)UIImage *identificationPositiveImage1;  //正面的
@property(nonatomic,strong)UIImage *identificationOppositeImage1;

@property(nonatomic,weak)IBOutlet UITableView *tableView;
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

@property(nonatomic,strong)UIImage *businessLicenceImage;
@property(nonatomic,strong)UIImage *identificationPositiveImage;  //正面的
@property(nonatomic,strong)UIImage *identificationOppositeImage;

@property(nonatomic,strong)NSMutableArray *professionNameArray;
@property(nonatomic,strong)NSMutableArray *professionIdArray;

@property(nonatomic,strong)NSString *professionId;
@property(nonatomic,strong)NSString *professionName;
@property(nonatomic)SellerType sellerType;
@property(nonatomic)ButtonTag buttonTag;

@property(nonatomic,strong)NSString *idcrad_one_url;
@property(nonatomic,strong)NSString *idcrad_two_url;
@property(nonatomic,strong)NSString *idcrad_one_uuid; //正面
@property(nonatomic,strong)NSString *idcrad_two_uuid; //反面

@property(nonatomic,strong)NSString *ic_url;          //工商
@property(nonatomic,strong)NSString *ic_uuid;

@end

@implementation SellerCentreWriteDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackItem];
    
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
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,  [UIFont systemFontOfSize:16.f],NSFontAttributeName,nil];
    [self.sellerTypeSegmented setTitleTextAttributes:dic forState:UIControlStateSelected];
    dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.f],NSFontAttributeName ,[UIColor blackColor],NSForegroundColorAttributeName,nil];
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
    
    [self setTableFootView];
    
    self.professionNameArray = Alloc(NSMutableArray);
    self.professionIdArray = Alloc(NSMutableArray);
    
    self.idcrad_one_url = @"";
    self.idcrad_two_url = @"";
    self.idcrad_one_uuid = @"";
    self.idcrad_two_uuid = @"";
    self.ic_url =@"";
    self.ic_uuid = @"";
    
    [self getProfessiontyperRequest];
}

#pragma mark -
-(void)setTableFootView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    footView.backgroundColor = VIEW_BG_COLOR;
    self.tableView.tableFooterView = footView;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).with.offset(20);
        make.leading.equalTo(footView.mas_leading).with.offset(20);
        make.trailing.equalTo(footView.mas_trailing).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    [submitButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
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
    NSString *cellIdentifier = [NSString stringWithFormat:@"%d_%d",self.sellerType,indexPath.row];
    SellerCentreWriteDataBusinessLicenseTableViewCell *cell1;
    UITableViewCell *cell;
    
    if (self.sellerType == SellerType_merchant && indexPath.row == 3) {
        cell1 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell1) {
            cell1 = (SellerCentreWriteDataBusinessLicenseTableViewCell *)[[SellerCentreWriteDataBusinessLicenseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell1.accessoryType = UITableViewCellAccessoryNone;
            
            cell1.businessLicenseView.promptLabel.text = @"工商营业执照";
            cell1.businessLicenseView.selectButton.tag = ButtonTag_businessLicence;
            [cell1.businessLicenseView.selectButton addTarget:self action:@selector(selectPictureButton:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell1;
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            if(self.sellerType == SellerType_merchant){
                switch (indexPath.row) {
                    case 0:
                    {
                            self.professionTypePromptField1 = [[PromptTextfield alloc] init];
                            self.professionTypePromptField1.promptLabel.text = @"行业类别";
                            self.professionTypePromptField1.inputTextField.placeholder = @"请选择所属行业类型";
                            self.professionTypePromptField1.inputTextField.delegate = self;
                            [self.professionTypePromptField1.inputTextField addTarget:self action:@selector(textFieldShouldEditing) forControlEvents:UIControlEventEditingDidBegin];
                            [cell.contentView addSubview:self.professionTypePromptField1];
                            [self.professionTypePromptField1 mas_makeConstraints:^(MASConstraintMaker *make) {
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
                            self.sellerNamePromptField.inputTextField.tag = indexPath.row;
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
                        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell1.accessoryType = UITableViewCellAccessoryNone;
                        
                        cell1.businessLicenseView.promptLabel.text = @"工商营业执照";
                        cell1.businessLicenseView.selectButton.tag = ButtonTag_businessLicence;
                        [cell1.businessLicenseView.selectButton addTarget:self action:@selector(selectPictureButton:) forControlEvents:UIControlEventTouchUpInside];
                        
                        return cell1;
                    }
                        break;
                        
                    case 4:{
                        self.namePromptField1 = [[PromptTextfield alloc] init];
                        self.namePromptField1.inputTextField.placeholder = @"姓名";
                        self.namePromptField1.promptLabel.text = @"姓名";
                        self.namePromptField1.inputTextField.delegate = self;
                        [cell.contentView addSubview:self.namePromptField1];
                        [self.namePromptField1 mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                            make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                            make.trailing.equalTo(cell.contentView.mas_trailing).with.offset(-10);
                            make.height.mas_equalTo(CellDefaultHeight);
                        }];
                    }
                        break;
                        
                    case 5:{
                        self.identificationPromptField1 = [[PromptTextfield alloc] init];
                        self.identificationPromptField1.inputTextField.placeholder = @"身份证号码";
                        self.identificationPromptField1.promptLabel.text = @"身份证";
                        self.identificationPromptField1.inputTextField.delegate = self;
                        [cell.contentView addSubview:self.identificationPromptField1];
                        [self.identificationPromptField1 mas_makeConstraints:^(MASConstraintMaker *make) {
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
                        self.identificationPositiveSelectView1 = Alloc(SelectPictureButton);
                        self.identificationPositiveSelectView1.promptLabel.text = @"身份证正面";
                        self.identificationPositiveSelectView1.selectButton.tag = ButtonTag_identificationPositive1;
                        [cell.contentView addSubview:self.identificationPositiveSelectView1];
                        [self.identificationPositiveSelectView1.selectButton addTarget:self action:@selector(selectPictureButton:) forControlEvents:UIControlEventTouchUpInside];
                        
                        self.identificationOppositeSelectView1 = Alloc(SelectPictureButton);
                        self.identificationOppositeSelectView1.promptLabel.text = @"身份证反面";
                        self.identificationOppositeSelectView1.selectButton.tag = ButtonTag_identificationOpposite1;
                        [cell.contentView addSubview:self.identificationOppositeSelectView1];
                        [self.identificationOppositeSelectView1.selectButton addTarget:self action:@selector(selectPictureButton:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [self.identificationPositiveSelectView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                            make.leading.equalTo(cell.contentView.mas_leading).with.offset(10);
                            make.trailing.equalTo(self.identificationOppositeSelectView1.mas_leading).with.offset(-10);
                            make.width.equalTo(self.identificationOppositeSelectView1.mas_width);
                            make.bottom.equalTo(cell.contentView.mas_bottom).with.offset(0);
                        }];
                        
                        [self.identificationOppositeSelectView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.top.equalTo(cell.contentView.mas_top).with.offset(0);
                            make.leading.equalTo(self.identificationPositiveSelectView1.mas_trailing).with.offset(10);
                            make.width.equalTo(self.identificationPositiveSelectView1.mas_width);
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
                        [self.professionTypePromptField.inputTextField addTarget:self action:@selector(textFieldShouldEditing) forControlEvents:UIControlEventEditingDidBegin];
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
                        self.namePromptField.inputTextField.delegate = self;
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
                        self.identificationPromptField.inputTextField.placeholder = @"身份证号码";
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
                        self.identificationPositiveSelectView.selectButton.tag = ButtonTag_identificationPositive;
                        [cell.contentView addSubview:self.identificationPositiveSelectView];
                        [self.identificationPositiveSelectView.selectButton addTarget:self action:@selector(selectPictureButton:) forControlEvents:UIControlEventTouchUpInside];
                        
                        self.identificationOppositeSelectView = Alloc(SelectPictureButton);
                        self.identificationOppositeSelectView.promptLabel.text = @"身份证反面";
                        self.identificationOppositeSelectView.selectButton.tag = ButtonTag_identificationOpposite;
                        [cell.contentView addSubview:self.identificationOppositeSelectView];
                        [self.identificationOppositeSelectView.selectButton addTarget:self action:@selector(selectPictureButton:) forControlEvents:UIControlEventTouchUpInside];
                        
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
        }
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;

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
    NSString *message;

    if (self.sellerType == SellerType_merchant) {
        if (self.professionTypePromptField1.inputTextField.text.length == 0) {
            message = @"请选择行业类别";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if(self.namePromptField1.inputTextField.text.length == 0){
            message = @"请输入姓名";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if(self.identificationPromptField1.inputTextField.text.length == 0){
            message = @"请输入身份证号码";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if (self.sellerNamePromptField.inputTextField.text.length == 0) {
            message = @"请填写工商注册全称";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if(self.registrationNumberPromptField.inputTextField.text.length == 0){
            message = @"请填写工商注册号";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if(self.telephonePromptField.inputTextField.text.length == 0){
            message = @"请填写手机号";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if (self.identificationPositiveImage1 == nil) {
            message = @"请选择身份证正面";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if (self.identificationPositiveImage1 == nil) {
            message = @"请选择身份证反面";
            [CommonTool addPopTipWithMessage:message];
            return;
        }
    }else{
        if (self.professionTypePromptField.inputTextField.text.length == 0) {
            message = @"请选择行业类别";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if(self.namePromptField.inputTextField.text.length == 0){
            message = @"请输入姓名";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if(self.identificationPromptField.inputTextField.text.length == 0){
            message = @"请输入身份证号码";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if (self.identificationPositiveImage == nil) {
            message = @"请选择身份证正面";
            [CommonTool addPopTipWithMessage:message];
            return;
        }else if (self.identificationPositiveImage == nil) {
            message = @"请选择身份证反面";
            [CommonTool addPopTipWithMessage:message];
            return;
        }
    }
    
    [self uploadImageRequest];
}

-(void)selectPictureButton:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
    self.buttonTag = button.tag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从相册中选取",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    actionSheet.tag = ActionSheetTag_addPicture;
}

#pragma mark -
-(void)getProfessiontyperRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSString *urlString = [Url_Host stringByAppendingString:@"app/goods/classify/query"];
    WeakSelf(weakSelf);
    
    [HttpManager postUrl:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            for(NSDictionary *dic in message.resultList){
                [weakSelf.professionNameArray addObject:dic[@"fenlei_content"]];
                [weakSelf.professionIdArray addObject:[NSString stringWithFormat:@"%@",dic[@"id"]]];
            }
        }else if ([message.returnCode intValue] == 1){
            [SVProgressHUD showSuccessWithStatus:@"获取数据失败"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

-(void)sendSubmitRequest{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    NSString *type;
    NSString *user_name;
    NSString *idcrad;
    if(self.sellerType == SellerType_personal){
        type = @"1";
        user_name = self.namePromptField.inputTextField.text;
        idcrad = self.identificationPromptField.inputTextField.text;
    }else{
        type = @"2";
        user_name = self.namePromptField1.inputTextField.text;
        idcrad = self.identificationPromptField1.inputTextField.text;
        
        [dic setObject:self.registrationNumberPromptField.inputTextField.text forKey:@"ic_content"];
        [dic setObject:self.ic_url forKey:@"ic_url"];
        [dic setObject:self.ic_uuid forKey:@"ic_uuid"];
        [dic setObject:self.sellerNamePromptField.inputTextField.text forKey:@"shop_name"];
        [dic setObject:self.telephonePromptField.inputTextField.text forKey:@"legal_phone"];
    }
    [dic setObject:type forKey:@"type"];
    
    NSString *user_id = [YooSeeApplication shareApplication].uid;
    [dic setObject:user_id forKey:@"user_id"];
    
    [dic setObject:idcrad forKey:@"idcrad"];
    [dic setObject:self.professionId forKey:@"hangye_id"];
    [dic setObject:self.professionName forKey:@"hangye_name"];
    
    [dic setObject:self.idcrad_one_url forKey:@"idcrad_one_url"];
    [dic setObject:self.idcrad_two_url forKey:@"idcrad_two_url"];
    
    [dic setObject:self.idcrad_one_uuid forKey:@"idcrad_one_uuid"];
    [dic setObject:self.idcrad_two_uuid forKey:@"idcrad_two_uuid"];
    [dic setObject:user_name forKey:@"user_name"];
    
    NSString *urlString = [Url_Host stringByAppendingString:@"app/registration/add"];
    WeakSelf(weakSelf);
    
    [HttpManager postUrl:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            [SVProgressHUD showSuccessWithStatus:@"申请成功"];
            SellerCentreReviewStatusViewController *vc = Alloc_viewControllerNibName(SellerCentreReviewStatusViewController);
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else if ([message.returnCode intValue] == 1){
            [SVProgressHUD showSuccessWithStatus:@"申请失败"];
        }else if ([message.returnCode intValue] == 2){
            [SVProgressHUD showSuccessWithStatus:@"已申请过不能重复申请"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

-(void)uploadImageRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    
    int totalCount = 0;
    __block int sendCount = 0;
    if (self.sellerType == SellerType_merchant) {
        totalCount++;
    }
    
    totalCount++;
    totalCount++;
    
    WeakSelf(weakSelf);
    
    NSData *data1;
    NSData *data2;
    
    if (self.sellerType == SellerType_merchant) {
        NSData *data =  UIImageJPEGRepresentation(self.businessLicenceImage, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                weakSelf.ic_uuid = response.uuid;
                weakSelf.ic_url = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];
        
        data1 =  UIImageJPEGRepresentation(self.identificationPositiveImage1, CompressionRatio);
        data2 =  UIImageJPEGRepresentation(self.identificationOppositeImage1, CompressionRatio);
    }else{
        //个人
        data1 =  UIImageJPEGRepresentation(self.identificationPositiveImage, CompressionRatio);
        data2 =  UIImageJPEGRepresentation(self.identificationOppositeImage, CompressionRatio);
    }
    
    //正面
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data1 name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
        if ([response.returnCode intValue] == SucessFlag) {
            weakSelf.idcrad_one_uuid = response.uuid;
            weakSelf.idcrad_one_url = response.access_url;
            sendCount++;
            if(sendCount == totalCount){
                [self sendSubmitRequest];
            }
        }else{
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
    
    //反面
    AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
    [manager2 POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data2 name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
        if ([response.returnCode intValue] == SucessFlag) {
            weakSelf.idcrad_two_uuid = response.uuid;
            weakSelf.idcrad_two_url = response.access_url;
            sendCount++;
            if(sendCount == totalCount){
                [self sendSubmitRequest];
            }
        }else{
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark - UITextFieldDelegate
-(void)textFieldShouldEditing{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    for (NSString *string in self.professionNameArray) {
        [actionSheet addButtonWithTitle:string];
    }
    
    [actionSheet showInView:self.view];
    [self performSelector:@selector(allTextFieldResignFirstResponder) withObject:nil afterDelay:0.1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.sellerType == SellerType_merchant) {
        if (textField == self.professionTypePromptField1.inputTextField) {
            [self.sellerNamePromptField.inputTextField becomeFirstResponder];
        }else if (textField == self.sellerNamePromptField.inputTextField){
            [self.registrationNumberPromptField.inputTextField becomeFirstResponder];
        }else if(textField == self.registrationNumberPromptField.inputTextField){
            [self.namePromptField.inputTextField becomeFirstResponder];
        }else if(textField == self.namePromptField1.inputTextField){
            [self.identificationPromptField.inputTextField becomeFirstResponder];
        }else if(textField == self.identificationPromptField1.inputTextField){
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
    
    [self.professionTypePromptField1.inputTextField resignFirstResponder];
    [self.namePromptField1.inputTextField resignFirstResponder];
    [self.identificationPromptField1 resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{

    if(actionSheet.tag == ActionSheetTag_addPicture){
        if (buttonIndex == 0) {
            // 拍照
            if ([Utils isCameraAvailable] && [Utils doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([Utils isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([Utils isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
        return;
    }else{
        if (buttonIndex == 0) {
            return;
        }
        
        self.professionId = self.professionIdArray[buttonIndex-1];
        self.professionName = self.professionNameArray[buttonIndex-1];
        
        if (self.sellerType == SellerType_merchant) {
            self.professionTypePromptField1.inputTextField.text = self.professionNameArray[buttonIndex-1];
            [self.sellerNamePromptField.inputTextField becomeFirstResponder];
        }else{
            self.professionTypePromptField.inputTextField.text = self.professionNameArray[buttonIndex-1];
            [self.namePromptField.inputTextField becomeFirstResponder];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.buttonTag == ButtonTag_businessLicence) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        SellerCentreWriteDataBusinessLicenseTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [picker dismissViewControllerAnimated:YES completion:^() {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [cell.businessLicenseView.selectButton setBackgroundImage:image forState:UIControlStateNormal];
            self.businessLicenceImage = image;
        }];
    }else if (self.buttonTag == ButtonTag_identificationPositive){
        [picker dismissViewControllerAnimated:YES completion:^() {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [self.identificationPositiveSelectView.selectButton setBackgroundImage:image forState:UIControlStateNormal];
            self.identificationPositiveImage = image;
        }];
    }else if (self.buttonTag == ButtonTag_identificationOpposite){
        [picker dismissViewControllerAnimated:YES completion:^() {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [self.identificationOppositeSelectView.selectButton setBackgroundImage:image forState:UIControlStateNormal];
            self.identificationOppositeImage = image;
        }];
    }else if (self.buttonTag == ButtonTag_identificationPositive1){
        [picker dismissViewControllerAnimated:YES completion:^() {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [self.identificationPositiveSelectView1.selectButton setBackgroundImage:image forState:UIControlStateNormal];
            self.identificationPositiveImage1 = image;
        }];
    }else if (self.buttonTag == ButtonTag_identificationOpposite1){
        [picker dismissViewControllerAnimated:YES completion:^() {
            UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [self.identificationOppositeSelectView1.selectButton setBackgroundImage:image forState:UIControlStateNormal];
            self.identificationOppositeImage1 = image;
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

@end
