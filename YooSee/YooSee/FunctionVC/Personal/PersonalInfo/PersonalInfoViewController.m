//
//  PersonalInfoViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define ROW_HEIGHT          50.0 * CURRENT_SCALE
#define SPACE_X             10.0
#define SPACE_Y             10.0 * CURRENT_SCALE
#define ARROW_WIDTH         35.0
#define LABEL_WIDTH         120.0 * CURRENT_SCALE

#import "PersonalInfoViewController.h"
#import "ChangePasswordViewController.h"
#import "SetPayPasswordViewController.h"
#import "ReciverInfoViewController.h"
#import "BindCardViewController.h"

@interface PersonalInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *valueArray;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) NSDictionary *cardDic;

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"个人资料";
    [self addBackItem];
    
    _titleArray = @[@[@"  姓名",@"  电话(ID)",@"  性别"],@[@"  收获地址"],@[@"  支付宝绑定",@"  支付密码"],@[@"  修改登录密码"]];
    NSDictionary *dataDic = [YooSeeApplication shareApplication].userInfoDic;
    _valueArray = [NSMutableArray arrayWithArray:@[@[dataDic[@"username"],[USER_DEFAULT objectForKey:@"UserName"],dataDic[@"sex"]],@[@""],@[@"",@""],@[@""]]];

    [self initUI];
    
    [self getRealNamedRequest:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindCardSucess:) name:@"BindCardSucess" object:nil];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addTableView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    
    UIImageView *bgImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, self.table.frame.size.width, self.table.contentSize.height) placeholderImage:nil];
    bgImageView.backgroundColor = [UIColor clearColor];
    
    float x = SPACE_X;
    float y = SPACE_Y;
    float width = bgImageView.frame.size.width - 2 * x;
    
    UIImageView *bgImageView1 = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, [self.titleArray[0] count] * ROW_HEIGHT) placeholderImage:nil];
    bgImageView1.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:bgImageView1 withCornerRadius:10.0];
    [bgImageView addSubview:bgImageView1];
    
    y += bgImageView1.frame.size.height + SPACE_Y;
    UIImageView *bgImageView2 = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, [self.titleArray[1] count] * ROW_HEIGHT) placeholderImage:nil];
    bgImageView2.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:bgImageView2 withCornerRadius:10.0];
    [bgImageView addSubview:bgImageView2];
    
    y += bgImageView2.frame.size.height + SPACE_Y;
    UIImageView *bgImageView3 = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, [self.titleArray[2] count] * ROW_HEIGHT) placeholderImage:nil];
    bgImageView3.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:bgImageView3 withCornerRadius:10.0];
    [bgImageView addSubview:bgImageView3];
    
    y += bgImageView3.frame.size.height + SPACE_Y;
    UIImageView *bgImageView4 = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, [self.titleArray[3] count] * ROW_HEIGHT) placeholderImage:nil];
    bgImageView4.backgroundColor = [UIColor whiteColor];
    [CommonTool clipView:bgImageView4 withCornerRadius:10.0];
    [bgImageView addSubview:bgImageView4];
    
    [self.table insertSubview:bgImageView atIndex:0];
    
    
    if ([self.table respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.table setSeparatorInset:UIEdgeInsetsMake(0, 2 * SPACE_X, 0, SPACE_X)];
    }
    
    if ([self.table respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.table setLayoutMargins:UIEdgeInsetsMake(0, 2 * SPACE_X, 0, SPACE_X)];
    }
}

#pragma mark 检查实名
- (void)getRealNamedRequest:(int)type
{
    if (type)
    {
        [LoadingView showLoadingView];
    }
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid":uid};
    [[RequestTool alloc] desRequestWithUrl:BANK_CARD_LIST_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"BANK_CARD_LIST_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (type)
         {
             [LoadingView dismissLoadingView];
         }
         if (errorCode == 1)
         {
             [weakSelf setDataWithDictionary:dataDic type:type];
         }
         else
         {
             if (type)
                 [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (type)
         {
             [LoadingView dismissLoadingView];
         }
         NSLog(@"BANK_CARD_LIST_URL====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];

}

#pragma mark 设置数据
- (void)setDataWithDictionary:(NSDictionary *)dataDic type:(int)type
{
    if (!dataDic)
    {
        return;
    }
    NSArray *array = dataDic[@"body"];
    if (!array || [array count] == 0)
    {
        if (type)
        {
            [self goToNextView];
        }
    }
    else
    {
        for (NSDictionary *dic in array)
        {
            if ([dic[@"acctype"] intValue] == 2)
            {
                self.cardDic = dic;
                NSString *idName = dic[@"account"];
                idName = idName ? idName : @"";
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.valueArray[2]];
                [array replaceObjectAtIndex:0 withObject:idName];
                [self.valueArray replaceObjectAtIndex:2 withObject:array];
                [self.table reloadData];
                if (type == 1)
                {
                    [SVProgressHUD showErrorWithStatus:@"已绑定"];
                }
                break;
            }
        }
        if (!self.cardDic)
        {
            if (type)
            {
                [self goToNextView];
            }
        }
    }
}

- (void)goToNextView
{
    BindCardViewController *realNameCheckViewController = [[BindCardViewController alloc] init];
    [self.navigationController pushViewController:realNameCheckViewController animated:YES];
}

#pragma mark 绑定成功
- (void)bindCardSucess:(NSNotification *)notification
{
    NSString *object = (NSString *)notification.object;
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.valueArray[2]];
    [array replaceObjectAtIndex:0 withObject:object];
    [self.valueArray replaceObjectAtIndex:2 withObject:array];
    [self.table reloadData];
}


#pragma mark - tableView datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SPACE_Y;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.valueArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.valueArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    UILabel *valueLabel = (UILabel *)[cell.contentView viewWithTag:100];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        valueLabel =  [CreateViewTool createLabelWithFrame:CGRectMake(SCREEN_WIDTH - ARROW_WIDTH - LABEL_WIDTH, 0, LABEL_WIDTH, ROW_HEIGHT) textString:@"" textColor:DE_TEXT_COLOR textFont:FONT(16.0)];
        //rightLabel.backgroundColor = [UIColor redColor];
        valueLabel.textAlignment = NSTextAlignmentRight;
        valueLabel.tag = 100;
        [cell.contentView addSubview:valueLabel];;
    }
    
    cell.accessoryType = (indexPath.row == 1 && indexPath.section == 0) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.titleArray[indexPath.section][indexPath.row];
    cell.textLabel.font = FONT(16.0);
    
    valueLabel.text = self.valueArray[indexPath.section][indexPath.row];
    
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 2 * SPACE_X, 0, SPACE_X)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 2 * SPACE_X, 0, SPACE_X)];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            //修改昵称
            [self changeNickName];
        }
        else if (indexPath.row == 2)
        {
            [self changeSex];
        }
    }
    if (indexPath.section == 1)
    {
        ReciverInfoViewController *reciverInfoViewController = [[ReciverInfoViewController alloc] init];
        [self.navigationController pushViewController:reciverInfoViewController animated:YES];
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            if (self.cardDic)
            {
                [SVProgressHUD showErrorWithStatus:@"已绑定"];
                return;
            }
           [self getRealNamedRequest:1];
        }
        else if (indexPath.row == 1)
        {
            [self checkPayPasswordRequest];
        }
        
    }
    if (indexPath.section == 3)
    {
        ChangePasswordViewController *changePasswordViewController = [[ChangePasswordViewController alloc] init];
        changePasswordViewController.isPayPassword = NO;
        [self.navigationController pushViewController:changePasswordViewController animated:YES];
    }
}

#pragma mark 修改昵称
- (void)changeNickName
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改昵称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    _usernameTextField = [alertView textFieldAtIndex:0];
    _usernameTextField.text = self.valueArray[0][0];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *username = _usernameTextField.text;
    if (buttonIndex == 1)
    {
        if (![username isEqualToString:self.valueArray[0][0]])
        {
            if (username.length == 0)
            {
                [CommonTool addPopTipWithMessage:@"昵称不能为空"];
                return;
            }
            [_usernameTextField resignFirstResponder];
            [self changeUserInfoRequest:username forKey:@"username"];
        }
    }
}

#pragma mark 修改性别
- (void)changeSex
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"修改性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (![title isEqualToString:@"取消"] && ![title isEqualToString:self.valueArray[0][2]])
    {
       [self changeUserInfoRequest:title forKey:@"sex"];
    }
}



#pragma mark 修改个人信息
- (void)changeUserInfoRequest:(NSString *)string forKey:(NSString *)key
{
    string = string ? string : @"";
    key = key ? key : @"";
    if (key.length == 0)
    {
        return;
    }
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSMutableDictionary *paramasDic = [NSMutableDictionary dictionaryWithDictionary:[YooSeeApplication shareApplication].userInfoDic];
    paramasDic[key] = string;
    paramasDic[@"uid"] = uid;
    NSDictionary *requestDic = paramasDic;
    [[RequestTool alloc] desRequestWithUrl:UPDATE_USER_INFO_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"UPDATE_USER_INFO_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             [SVProgressHUD showSuccessWithStatus:@"修改成功"];
             [YooSeeApplication shareApplication].userInfoDic = paramasDic;
             NSMutableArray *array = [NSMutableArray arrayWithArray:weakSelf.valueArray[0]];
             [array replaceObjectAtIndex:([key isEqualToString:@"username"] ? 0 : 2) withObject:string];
             [weakSelf.valueArray replaceObjectAtIndex:0 withObject:array];
             [weakSelf.table reloadData];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"UPDATE_USER_INFO_URL====%@",error);
         [LoadingView dismissLoadingView];
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}


#pragma mark 校验支付密码
- (void)checkPayPasswordRequest
{
    
    [LoadingView showLoadingView];
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid":uid,@"paypasswd":@""};
    [[RequestTool alloc] desRequestWithUrl:CHECK_PAY_PASSWORD_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"CHECK_PAY_PASSWORD_URL===%@",responseDic);
         [LoadingView dismissLoadingView];
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [weakSelf goToPasswordViewWithType:errorCode];
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"CHECK_PAY_PASSWORD_URL====%@",error);
         [LoadingView dismissLoadingView];
         [SVProgressHUD showErrorWithStatus:@"加载失败"];
     }];
}

- (void)goToPasswordViewWithType:(int)type
{
    if (type == 0)
    {
        //未设置密码
        SetPayPasswordViewController *setPayPasswordViewController = [[SetPayPasswordViewController alloc] init];
        [self.navigationController pushViewController:setPayPasswordViewController animated:YES];
    }
    else if (type == 1)
    {
        //修改密码
        ChangePasswordViewController *changePasswordViewController = [[ChangePasswordViewController alloc] init];
        changePasswordViewController.isPayPassword = YES;
        [self.navigationController pushViewController:changePasswordViewController animated:YES];
        
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"数据异常"];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
