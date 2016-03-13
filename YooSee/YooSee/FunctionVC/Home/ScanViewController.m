//
//  ScanViewController.m
//  YooSee
//
//  Created by chenlei on 16/3/6.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController ()

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
