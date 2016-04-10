//
//  ScanRedPackageDetailViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/4/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ScanRedPackageDetailViewController.h"

@interface ScanRedPackageDetailViewController ()

@end

@implementation ScanRedPackageDetailViewController

- (void)viewDidLoad
{
    [self performSelectorOnMainThread:@selector(detailRequest) withObject:nil waitUntilDone:YES];
    // Do any additional setup after loading the view.
}


- (void)detailRequest
{
    [LoadingView showLoadingView];
    
    NSDictionary *requestDic = @{@"id":[NSString stringWithFormat:@"%@", UNNULL_STRING(self.packageID)]};
    [[RequestTool alloc] requestWithUrl:RED_POCKET_DETAIL
                         requestParamas:requestDic
                            requestType:RequestTypeSynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"RED_POCKET_DETAIL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (errorCode == 8)
         {
             NSArray *ary = dataDic[@"resultList"];
             if (ary && [ary isKindOfClass:[NSArray class]] && [ary count] > 0)
             {
                 NSDictionary *dataDic = [ary objectAtIndex:0];
                 self.redPackgeId = dataDic[@"only_number"];
                 self.logoUrl = dataDic[@"title_url_1"];
                 self.desc = dataDic[@"title_1"];
             }
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage];
         }
         [super viewDidLoad];
         
     }
      requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [super viewDidLoad];
         [LoadingView dismissLoadingView];
         NSLog(@"RED_POCKET_DETAIL====%@",error);
     }];
}

- (void)didReceiveMemoryWarning {
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
