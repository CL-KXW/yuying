//
//  LookDetailViewController.h
//  YooSee
//
//  Created by 周后云 on 16/4/8.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

typedef NS_ENUM(NSUInteger, LookDetail) {
    LookDetail_redLibary = 0,
    LookDetail_advertisement,
};

@interface LookDetailViewController : BasicViewController

@property(nonatomic,strong)NSDictionary *dic;
@property(nonatomic)LookDetail type;   //详情类型

@end
