//
//  CashDetailedViewController.h
//  YooSee
//
//  Created by 周川 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

typedef NS_OPTIONS(NSUInteger, DetailType) {
    DetailType_surplus = 0,
    DetailType_turnover = 1,
};

@interface CashDetailedViewController : BasicViewController

@property(nonatomic)DetailType *type;

@end
