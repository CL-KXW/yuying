//
//  ScanViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSString *qrCodeString;

@end

@implementation ScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"扫一扫";
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
        NSArray *array = [dataString componentsSeparatedByString:@"&"];
        if (!array || [array count] != 2)
        {
            NSString *type = array[0];
            NSString *idString = array[1];
            if ([@"hb-js" isEqualToString:type])
            {
                
            }
        }
    }
    else
    {
        qrCodeString = @"无效结果";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:qrCodeString delegate:self cancelButtonTitle:@"重试" otherButtonTitles:@"取消", nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"重试"])
    {
        [self reset];
    }
    if ([title isEqualToString:@"取消"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
