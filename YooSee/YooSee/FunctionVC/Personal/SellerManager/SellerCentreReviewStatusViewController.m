//
//  SellerCentreReviewStatusViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreReviewStatusViewController.h"

#import "UserCenterMainViewController.h"

@interface SellerCentreReviewStatusViewController ()

@end

@implementation SellerCentreReviewStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarItemWithImageName:@"back" navItemType:LeftItem selectorName:@"backButtonPressed:"];
    
    self.title = @"等待审核";
}

- (void)backButtonPressed:(UIButton *)sender
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[UserCenterMainViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Request
-(void)sellerMessageRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    
    NSString *user_id = UNNULL_STRING([[YooSeeApplication shareApplication] uid]);
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",nil];
    
    NSString *string = [Url_Host stringByAppendingString:@"app/registration/list"];
    [HttpManager postUrl:string parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag)
        {
            NSArray *array = jsonObject[@"resultList"];
            NSDictionary *resultlist = [array firstObject];
            if ([resultlist[@"state"] intValue] == 3) {
                [SVProgressHUD showErrorWithStatus:resultlist[@"content"]];
                [self deleteMessageRequest:[NSString stringWithFormat:@"%@",resultlist[@"id"]]];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:message.returnMessage];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}


-(void)deleteMessageRequest:(NSString *)nuId{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        return;
    }
    
    [LoadingView showLoadingView];
    
    NSString *user_id = UNNULL_STRING([[YooSeeApplication shareApplication] uid]);
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",nil];
    
    NSString *string = [Url_Host stringByAppendingString:@"app/shop/delete"];
    [HttpManager postUrl:string parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag)
        {
            NSDictionary *resultlist = jsonObject[@"resultList"];
            if ([resultlist[@"state"] intValue] == 3) {
                [SVProgressHUD showErrorWithStatus:resultlist[@"content"]];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:message.returnMessage];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

@end
