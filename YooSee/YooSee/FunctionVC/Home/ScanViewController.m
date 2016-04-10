//
//  ScanViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ScanViewController.h"
#import "ScanY1YDetailViewController.h"
#import "ScanRedPackageDetailViewController.h"
#import "ScanMonertDetailViewController.h"
#import "Y1YViewController.h"
#import "GetMoneryViewController.h"
#import "RobRedPackgeListVC.h"

@interface ScanViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *qrCodeString;
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *only_number;

@end

@implementation ScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"扫一扫";
    _only_number = @"";
    _idString = @"";
    // Do any additional setup after loading the view.
}


#pragma mark 获取成功
- (void)getQrcodeSucess:(NSString *)qrCodeString
{
    _qrCodeString = UNNULL_STRING(qrCodeString);
    NSString *preString = @"http://www.dianliang.yuying/app?type=";
    if ([qrCodeString hasPrefix:preString])
    {
        NSString *dataString = [qrCodeString stringByReplacingOccurrencesOfString:preString withString:@""];
        dataString = [dataString stringByReplacingOccurrencesOfString:@"id=" withString:@""];
        dataString = [dataString stringByReplacingOccurrencesOfString:@"only_number=" withString:@""];
        NSArray *array = [dataString componentsSeparatedByString:@"&"];
        if (array)
        {
            if ([array count] < 2)
            {
                return;
            }
            NSString *type = array[0];
            NSString *idString = array[1];
            
            if (!idString.length)
            {
                [self errorTip];
            }
            
            self.idString = idString;
            
            NSString *tipMessage = @"";
            NSString *action = @"";
            NSString *only_number = @"";
            if ([@"hb-js" isEqualToString:type])
            {
                tipMessage = @"即时红包";
            }
            if ([@"hb-sm" isEqualToString:type])
            {
                //扫描红包
                tipMessage = @"扫描红包";
            }
            if ([@"yyy" isEqualToString:type])
            {
                //摇一摇红包
                tipMessage = @"摇一摇红包";
                if ([array count] == 3)
                {
                    only_number = array[2];
                    _only_number = only_number;
                }
            }
            if ([@"gg" isEqualToString:type])
            {
                //广告
                tipMessage = @"赚钱广告";
                action = @"打开";
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:tipMessage delegate:self cancelButtonTitle:(action.length) ? @"打开" : @"去抢红包" otherButtonTitles:@"取消", nil];
            [alertView show];
        }
    }
    else
    {
        qrCodeString = @"无效结果";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:qrCodeString delegate:self cancelButtonTitle:@"重试" otherButtonTitles:@"取消", nil];
        [alertView show];
    }
}

- (void)errorTip
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:@"数据异常" delegate:self cancelButtonTitle:@"重试" otherButtonTitles:@"取消", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"重试"])
    {
        [self reset];
    }
    if ([title isEqualToString:@"打开"])
    {
         [self getScanDetailWithType:2];
    }
    if ([title isEqualToString:@"去抢红包"])
    {
        if (_only_number.length != 0)
        {
            _only_number = UNNULL_STRING(_only_number);
            if (_only_number.length == 0)
            {
                [self errorTip];
                return;
            }
            [self goToY1Y];
            return;
        }
        [self getScanDetailWithType:1];
    }
    if ([title isEqualToString:@"取消"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark 摇一摇红包
- (void)goToY1Y
{
    [self addViewController:[[Y1YViewController alloc] init]];
    ScanY1YDetailViewController *scanY1YDetailViewController = [[ScanY1YDetailViewController alloc] init];
    scanY1YDetailViewController.dataDic = @{@"only_number":_only_number};
    [self.navigationController pushViewController:scanY1YDetailViewController animated:YES];
}

#pragma mark 获取详情
//type 1:红包 2:广告
- (void)getScanDetailWithType:(int)type
{
    if (_idString.length)
    {
        if (type == 1)
        {
            [self addViewController:[[RobRedPackgeListVC alloc] init]];
            ScanRedPackageDetailViewController *scanRedPackageDetailViewController = [[ScanRedPackageDetailViewController alloc] init];
            scanRedPackageDetailViewController.packageID = _idString;
            [self.navigationController pushViewController:scanRedPackageDetailViewController animated:YES];
        }
        else if (type == 2)
        {
            [self addViewController:[[GetMoneryViewController alloc] init]];
            ScanMonertDetailViewController *scanMonertDetailViewController = [[ScanMonertDetailViewController alloc] init];
            scanMonertDetailViewController.adID = _idString;
            [self.navigationController pushViewController:scanMonertDetailViewController animated:YES];
        }

    }
    //NSString *urlString = type == 1 ? ;
}


- (void)addViewController:(UIViewController *)viewController
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array insertObject:viewController atIndex:2];
    [self.navigationController setViewControllers:array animated:NO];
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
