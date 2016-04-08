//
//  RedPackgeLibraryDetailVC.h
//  YooSee
//
//  Created by Shaun on 16/4/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "GetMoneyDetailViewController.h"
typedef void (^NeedRefresh) ();
@interface RedPackgeLibraryDetailVC : GetMoneyDetailViewController
@property (nonatomic, assign) BOOL hasGetMoney;
@property (nonatomic, copy) NeedRefresh block;
@end
