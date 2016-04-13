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

@end
