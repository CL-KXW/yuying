//
//  ScanMonertDetailViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/4/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ScanMonertDetailViewController.h"

@interface ScanMonertDetailViewController ()

@end

@implementation ScanMonertDetailViewController

- (void)viewDidLoad
{
    [self detailRequest];
    
    // Do any additional setup after loading the view.
}


- (void)detailRequest
{
    [LoadingView showLoadingView];
    
    NSDictionary *requestDic = @{@"id":[NSString stringWithFormat:@"%@", UNNULL_STRING(self.adID)]};
    [[RequestTool alloc] requestWithUrl:AD_DETAIL_URL
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
                 self.dataDic = dataDic;
                 NSMutableArray *ary = [NSMutableArray array];
                 NSMutableArray *titleAry = [NSMutableArray array];
                 if ([self isVaildURL:dataDic[@"url_1"]]) {
                     [ary addObject:dataDic[@"url_1"]];
                     [titleAry addObject:dataDic[@"content_1"]];
                 }
                 if ([self isVaildURL:dataDic[@"url_2"]]) {
                     [ary addObject:dataDic[@"url_2"]];
                     [titleAry addObject:dataDic[@"content_2"]];
                 }
                 if ([self isVaildURL:dataDic[@"url_3"]]) {
                     [ary addObject:dataDic[@"url_3"]];
                     [titleAry addObject:dataDic[@"content_3"]];
                 }
                 if ([self isVaildURL:dataDic[@"url_4"]]) {
                     [ary addObject:dataDic[@"url_4"]];
                     [titleAry addObject:dataDic[@"content_4"]];
                 }
                 self.dataArray = ary;
                 self.descArray = titleAry;
                 self.timeString = dataDic[@"begin_time"];
                 self.authorString = dataDic[@"content_1"];
                 self.nameString = dataDic[@"shop_name"];
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

- (BOOL)isVaildURL:(NSString*)string {
    if (string && [string isKindOfClass:[NSString class]] && string.length > 6) {
        return YES;
    }
    return NO;
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
