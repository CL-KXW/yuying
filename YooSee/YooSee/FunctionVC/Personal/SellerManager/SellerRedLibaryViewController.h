//
//  SellerRedLibaryViewController.h
//  YooSee
//
//  Created by 周后云 on 16/3/15.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "BasicViewController.h"

typedef NS_ENUM(NSUInteger, DetailType) {
    DetailType_redLibary = 0,
    DetailType_advertisement,
};

@interface SellerRedLibaryViewController : BasicViewController

@property(nonatomic)BOOL reject;   //被拒绝
@property(nonatomic,strong)NSMutableDictionary *dic;
@property(nonatomic)DetailType type;   //详情类型
@property(nonatomic,strong)NSNumber *shop_number;

@end
