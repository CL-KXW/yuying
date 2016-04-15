//
//  SellerCentreReviewStatusViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SellerCentreReviewStatusViewController.h"

#import "UserCenterMainViewController.h"
#import "SellerCentreJoinViewController.h"

@interface SellerCentreReviewStatusViewController ()

@property(nonatomic,weak)IBOutlet UIImageView *custonImageView;
@property(nonatomic,weak)IBOutlet UILabel *contentLabel;
@property(nonatomic,weak)IBOutlet UIButton *button;
@property(nonatomic,strong)NSString *nuId;

@end

@implementation SellerCentreReviewStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarItemWithImageName:@"back" navItemType:LeftItem selectorName:@"backButtonPressed:"];
    
    self.title = @"等待审核";
    self.button.hidden = YES;
    [self.button viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
    [self sellerMessageRequest];
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
        //1.待审核 2 再次上传 3,不通过 4通过
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag)
        {
            NSArray *array = jsonObject[@"resultList"];
            NSDictionary *resultlist = [array firstObject];
            if ([resultlist[@"state"] intValue] == 3 || [resultlist[@"state"] intValue] == 2) {
                NSString *content = resultlist[@"content"];
                if (content.length == 0) {
                    self.contentLabel.text = @"审核被拒绝,请认真上传真实资料";
                }else{
                    self.contentLabel.text = resultlist[@"content"];
                }
                
                self.custonImageView.image = [UIImage imageNamed:@"SellerCentreReviewStatus_reject"];
                self.button.hidden = NO;
                self.nuId = [NSString stringWithFormat:@"%@",resultlist[@"id"]];
                self.title = @"审核被拒";
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
    
    NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:nuId,@"id",nil];
    
    NSString *string = [Url_Host stringByAppendingString:@"app/shop/delete"];
    [HttpManager postUrl:string parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag)
        {
            SellerCentreJoinViewController *vc = Alloc_viewControllerNibName(SellerCentreJoinViewController);
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:message.returnMessage];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

-(IBAction)deleteButtonClick:(id)sender{
    [self deleteMessageRequest:self.nuId];
}

@end
