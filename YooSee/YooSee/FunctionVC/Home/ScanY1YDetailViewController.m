//
//  ScanY1YDetailViewController.m
//  YooSee
//
//  Created by 陈磊 on 16/4/10.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "ScanY1YDetailViewController.h"

@interface ScanY1YDetailViewController ()

@end

@implementation ScanY1YDetailViewController

- (void)viewDidLoad
{
    [self requestDetail];
    // Do any additional setup after loading the view.
}


- (void)requestDetail
{
    //红包详情
    //yyw_redpackedgg
    [LoadingView showLoadingView];
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    
    NSDictionary *requestDic = @{
                                 @"lingqu_user_id":[NSString stringWithFormat:@"%@", uid],
                                 @"only_number":[NSString stringWithFormat:@"%@",self.dataDic[@"only_number"]]};
    requestDic = [RequestDataTool encryptWithDictionary:requestDic];
    [[RequestTool alloc] requestWithUrl:ROB_RED_PACKGE_DETAIL
                         requestParamas:requestDic
                            requestType:RequestTypeAsynchronous
                          requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"ROB_RED_PACKGE_DETAIL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         [LoadingView dismissLoadingView];
         if (dataDic[@"only_number"])
         {
             self.dataDic = dataDic;
         }
         //else
         //{
         //    [SVProgressHUD showErrorWithStatus:errorMessage];
         //}
         [super viewDidLoad];
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [LoadingView dismissLoadingView];
         [super viewDidLoad];
         NSLog(@"ROB_RED_PACKGE_DETAIL====%@",error);
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
