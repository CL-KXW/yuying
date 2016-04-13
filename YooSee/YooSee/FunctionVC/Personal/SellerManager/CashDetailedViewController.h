//
//  CashDetailedViewController.h
//  YooSee
//
//  Created by 周川 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

typedef NS_ENUM(NSUInteger, CashDetailType) {
    CashDetailType_person,
    CashDetailType_sellerTurnover,
    CashDetailType_sellerCapitalLibrary,
};

@interface CashDetailedViewController : BasicViewController

@property(nonatomic)CashDetailType type;
@property(nonatomic,strong)NSNumber *shop_number;

@end
